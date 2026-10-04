import QtQuick
import Quickshell
import Quickshell.Io

// layanan manajemen jaringan wifi (nmcli) dan perangkat bluetooth (bluetoothctl)
Scope {
    id: root

    property bool wifiConnected: true
    property string wifiSsid: "Scanning..."
    property string wifiIp: "127.0.0.1"
    property string wifiSecurity: "WPA2"
    property int wifiSignal: 100
    property bool wifiScanning: false
    property string wifiStatusMsg: ""
    property var wifiNetworks: []

    property bool btConnected: true
    property string btDeviceName: "Ready"
    property string btDeviceMac: ""
    property bool btScanning: false
    property string btStatusMsg: ""
    property var btDevices: []

    Process {
        id: wifiListProc
        command: ["bash", "-c",
            "RADIO=$(nmcli radio wifi 2>/dev/null || echo enabled); " +
            "IP=$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | head -n1); " +
            "echo \"META|${RADIO}|${IP:-0.0.0.0}\"; " +
            "nmcli -t -f NAME,TYPE connection show 2>/dev/null | awk -F: '$2==\"802-11-wireless\"{print \"SAVED|\"$1}'; " +
            "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan no 2>/dev/null | head -n 25"
        ]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                root.wifiScanning = false
                const lines = String(data).trim().split("\n")
                const list = []
                const seen = {}
                const savedMap = {}
                let activeFound = false
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].trim()
                    if (!line) continue
                    if (line.indexOf("META|") === 0) {
                        const mp = line.split("|")
                        root.wifiConnected = (mp[1] !== "disabled")
                        if (mp[2]) root.wifiIp = mp[2]
                        continue
                    }
                    if (line.indexOf("SAVED|") === 0) {
                        const savedName = line.slice(6).trim()
                        if (savedName) savedMap[savedName] = true
                        continue
                    }
                    const parts = line.split(":")
                    if (parts.length < 4) continue
                    const inUse = parts[0].trim() === "*"
                    const sec = parts[parts.length - 1].trim() || "OPEN"
                    const sig = parseInt(parts[parts.length - 2], 10) || 0
                    const ssid = parts.slice(1, parts.length - 2).join(":").trim()
                    if (!ssid) continue
                    if (seen[ssid] && !inUse) continue
                    seen[ssid] = true
                    const item = {
                        inUse: inUse,
                        ssid: ssid,
                        signal: sig,
                        security: sec === "--" ? "OPEN" : sec,
                        saved: Boolean(savedMap[ssid] || inUse)
                    }
                    if (inUse) {
                        activeFound = true
                        root.wifiSsid = ssid
                        root.wifiSignal = sig
                        root.wifiSecurity = item.security
                        list.unshift(item)
                    } else {
                        list.push(item)
                    }
                }
                if (!activeFound) {
                    root.wifiSsid = root.wifiConnected ? (list.length > 0 ? "Disconnected" : "No Networks") : "Wi-Fi Off"
                }
                const oldKey = root.wifiNetworks.map(n => n.ssid + "|" + (n.inUse ? "1" : "0") + "|" + (n.saved ? "1" : "0") + "|" + n.security).join(";")
                const newKey = list.map(n => n.ssid + "|" + (n.inUse ? "1" : "0") + "|" + (n.saved ? "1" : "0") + "|" + n.security).join(";")
                if (oldKey !== newKey || root.wifiNetworks.length !== list.length) {
                    root.wifiNetworks = list
                }
            }
        }
    }

    Process {
        id: wifiScanProc
        command: ["bash", "-c", "nmcli device wifi rescan 2>/dev/null || true"]
        onExited: wifiListProc.running = true
    }

    property string _wifiActionCmd: ""
    Process {
        id: wifiActionProc
        command: ["bash", "-c", root._wifiActionCmd]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const out = String(data).trim()
                if (out.indexOf("OK|") === 0) {
                    root.wifiStatusMsg = out.slice(3)
                } else if (out.indexOf("ERR|") === 0) {
                    root.wifiStatusMsg = out.slice(4)
                }
            }
        }
        onExited: {
            wifiListProc.running = true
            wifiRefreshDelay.restart()
        }
    }

    function refreshWifi() {
        wifiListProc.running = true
    }

    function scanWifi() {
        root.wifiScanning = true
        root.wifiStatusMsg = "Scanning nearby frequencies..."
        wifiScanProc.running = true
    }

    function setWifiPower(enable) {
        root.wifiConnected = enable
        root.wifiStatusMsg = enable ? "Enabling Wi-Fi radio..." : "Wi-Fi radio disabled"
        Quickshell.execDetached(["bash", "-c", "nmcli radio wifi " + (enable ? "on" : "off")])
        wifiRefreshDelay.restart()
    }

    function connectWifi(ssid, password) {
        if (!ssid) return
        root.wifiStatusMsg = "Linking to " + ssid + "..."
        const safeSsid = String(ssid).replace(/'/g, "'\\''")
        const safePass = String(password || "").replace(/'/g, "'\\''")
        if (safePass !== "") {
            root._wifiActionCmd =
                "(nmcli connection delete '" + safeSsid + "' >/dev/null 2>&1 || true); " +
                "if nmcli -w 12 device wifi connect '" + safeSsid + "' password '" + safePass + "' >/dev/null 2>&1; then " +
                "  echo 'OK|★ LINKED TO " + safeSsid + "'; " +
                "else " +
                "  echo 'ERR|AUTH FAILED // Check Passkey'; " +
                "fi"
        } else {
            root._wifiActionCmd =
                "if nmcli -w 10 connection up '" + safeSsid + "' >/dev/null 2>&1 || nmcli -w 10 device wifi connect '" + safeSsid + "' >/dev/null 2>&1; then " +
                "  echo 'OK|★ LINKED TO " + safeSsid + "'; " +
                "else " +
                "  echo 'ERR|PASSKEY REQUIRED // Click PASSKEY'; " +
                "fi"
        }
        wifiActionProc.running = false
        wifiActionProc.running = true
    }

    function disconnectWifi(ssid) {
        if (!ssid) return
        root.wifiStatusMsg = "Disconnecting " + ssid + "..."
        const safeSsid = String(ssid).replace(/'/g, "'\\''")
        root._wifiActionCmd =
            "if nmcli connection down '" + safeSsid + "' >/dev/null 2>&1; then " +
            "  echo 'OK|DISCONNECTED " + safeSsid + "'; " +
            "else " +
            "  echo 'ERR|Failed to disconnect'; " +
            "fi"
        wifiActionProc.running = false
        wifiActionProc.running = true
    }

    Timer {
        id: wifiRefreshDelay
        interval: 3200
        repeat: false
        onTriggered: {
            root.wifiStatusMsg = ""
            wifiListProc.running = true
        }
    }

    Process {
        id: btListProc
        command: ["bash", "-c",
            "POW=$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2}'); " +
            "CONN=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}'); " +
            "PAIR=$(bluetoothctl devices Paired 2>/dev/null | awk '{print $2}'); " +
            "echo \"META|${POW:-yes}\"; " +
            "bluetoothctl devices 2>/dev/null | while read -r _ mac name; do " +
            "  [ -z \"$mac\" ] && continue; " +
            "  c=0; p=0; " +
            "  echo \"$CONN\" | grep -q \"$mac\" && c=1; " +
            "  echo \"$PAIR\" | grep -q \"$mac\" && p=1; " +
            "  echo \"DEV|${mac}|${c}|${p}|${name}\"; " +
            "done"
        ]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                root.btScanning = false
                const lines = String(data).trim().split("\n")
                const list = []
                let connectedName = ""
                let connectedMac = ""
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].trim()
                    if (!line) continue
                    if (line.indexOf("META|") === 0) {
                        const mp = line.split("|")
                        root.btConnected = (mp[1] !== "no")
                        continue
                    }
                    if (line.indexOf("DEV|") === 0) {
                        const dp = line.split("|")
                        if (dp.length >= 5) {
                            const mac = dp[1]
                            const isConn = dp[2] === "1"
                            const isPair = dp[3] === "1"
                            const name = dp.slice(4).join("|").trim() || mac
                            const item = {
                                mac: mac,
                                name: name,
                                connected: isConn,
                                paired: isPair
                            }
                            if (isConn) {
                                connectedName = name
                                connectedMac = mac
                                list.unshift(item)
                            } else {
                                list.push(item)
                            }
                        }
                    }
                }
                const oldBtKey = root.btDevices.map(d => d.mac + "|" + (d.connected ? "1" : "0") + "|" + (d.paired ? "1" : "0") + "|" + d.name).join(";")
                const newBtKey = list.map(d => d.mac + "|" + (d.connected ? "1" : "0") + "|" + (d.paired ? "1" : "0") + "|" + d.name).join(";")
                if (oldBtKey !== newBtKey || root.btDevices.length !== list.length) {
                    root.btDevices = list
                }
                root.btDeviceName = connectedName !== "" ? connectedName : (root.btConnected ? (list.length > 0 ? (list.length + " Devices") : "Ready") : "BT Off")
                root.btDeviceMac = connectedMac
            }
        }
    }

    Process {
        id: btScanProc
        command: ["bash", "-c", "bluetoothctl --timeout 4 scan on >/dev/null 2>&1 || true"]
        onExited: btListProc.running = true
    }

    function refreshBluetooth() {
        btListProc.running = true
    }

    function scanBluetooth() {
        root.btScanning = true
        root.btStatusMsg = "Scanning Bluetooth devices..."
        btScanProc.running = true
    }

    function setBluetoothPower(enable) {
        root.btConnected = enable
        root.btStatusMsg = enable ? "Powering Bluetooth ON..." : "Bluetooth powered OFF"
        Quickshell.execDetached(["bash", "-c", "bluetoothctl power " + (enable ? "on" : "off")])
        btRefreshDelay.restart()
    }

    function connectBluetooth(mac, name) {
        if (!mac) return
        root.btStatusMsg = "Linking " + (name || mac) + "..."
        Quickshell.execDetached(["bash", "-c", "bluetoothctl trust '" + mac + "' >/dev/null 2>&1; bluetoothctl connect '" + mac + "' >/dev/null 2>&1 || true"])
        btRefreshDelay.restart()
    }

    function disconnectBluetooth(mac, name) {
        if (!mac) return
        root.btStatusMsg = "Disconnecting " + (name || mac) + "..."
        Quickshell.execDetached(["bash", "-c", "bluetoothctl disconnect '" + mac + "' >/dev/null 2>&1 || true"])
        btRefreshDelay.restart()
    }

    Timer {
        id: btRefreshDelay
        interval: 2200
        repeat: false
        onTriggered: {
            root.btStatusMsg = ""
            btListProc.running = true
        }
    }
}
