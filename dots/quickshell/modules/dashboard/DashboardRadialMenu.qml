import QtQuick
import qs.config

// menu aksi radial melayang di sisi kiri kartu jaringan atau perangkat terpilih
Item {
    id: leftRadialMenu

    required property var dashWin
    required property var dashCard
    required property var wifiPanel
    required property var btPanel

    property real openProgress: dashWin.radialOpen ? 1.0 : 0.0
    Behavior on openProgress {
        NumberAnimation {
            duration: leftRadialMenu.dashWin.radialOpen ? 230 : 140
            easing.type: leftRadialMenu.dashWin.radialOpen ? Easing.OutBack : Easing.InCubic
            easing.overshoot: 1.28
        }
    }

    property real switchPulse: 1.0
    function restartSwitchPulse() {
        leftRadialSwitchAnim.restart()
    }

    SequentialAnimation {
        id: leftRadialSwitchAnim
        NumberAnimation {
            target: leftRadialMenu
            property: "switchPulse"
            from: 1.0
            to: 0.90
            duration: 55
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: leftRadialMenu
            property: "switchPulse"
            from: 0.90
            to: 1.0
            duration: 150
            easing.type: Easing.OutBack
            easing.overshoot: 1.4
        }
    }

    visible: openProgress > 0.005
    opacity: Math.max(0.0, Math.min(1.0, openProgress * 1.35))
    scale: (0.58 + 0.42 * openProgress) * switchPulse
    width: 296
    height: 244

    // posisi vertikal menu radial sejajar dengan titik tengah kartu terpilih
    readonly property real targetY: dashCard.y + Math.max(6, Math.min(dashCard.height - height - 6, dashWin.clickedCardCenterY - height / 2))
    y: targetY
    Behavior on y {
        enabled: leftRadialMenu.dashWin.animateRadialY
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    transformOrigin: Item.Right

    // kanvas garis jarum penghubung dari kartu terpilih ke pangkal tiap bilah aksi
    Canvas {
        id: leftRadialBurst
        anchors.fill: parent
        property color cPrimary: PhantomState.primary
        property real apexY: Math.max(36, Math.min(height - 36, leftRadialMenu.dashWin.clickedCardCenterY - leftRadialMenu.targetY))
        onCPrimaryChanged: requestPaint()
        onApexYChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width
            var cy = apexY

            // titik koordinat pangkal kanan dari keempat bilah aksi
            var tips = [
                { x: w - 18, y: 34 },
                { x: w - 6,  y: 92 },
                { x: w - 6,  y: 150 },
                { x: w - 18, y: 208 }
            ]

            for (var i = 0; i < tips.length; i++) {
                // bayangan aksen garis penghubung
                ctx.strokeStyle = cPrimary
                ctx.lineWidth = 3.2
                ctx.beginPath()
                ctx.moveTo(w, cy + 1)
                ctx.lineTo(tips[i].x, tips[i].y + 2)
                ctx.stroke()

                // garis inti putih penghubung
                ctx.strokeStyle = "#FFFFFF"
                ctx.lineWidth = 1.4
                ctx.beginPath()
                ctx.moveTo(w, cy)
                ctx.lineTo(tips[i].x, tips[i].y)
                ctx.stroke()
            }

            // simpul panah putih pada tepi kartu terpilih
            ctx.fillStyle = "#FFFFFF"
            ctx.beginPath()
            ctx.moveTo(w, cy)
            ctx.lineTo(w - 14, cy - 8)
            ctx.lineTo(w - 10, cy)
            ctx.lineTo(w - 14, cy + 8)
            ctx.closePath()
            ctx.fill()
        }
    }

    // deretan empat bilah perintah aksi radial
    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 4

        // bilah aksi sambung atau putuskan koneksi
        Item {
            width: parent.width
            height: 54

            P5BattleBlade {
                x: 12 + (1.0 - leftRadialMenu.openProgress) * 18
                width: parent.width - 28
                height: 54
                tailOnRight: true
                fanProgress: leftRadialMenu.openProgress
                readonly property bool isWifiPanel: leftRadialMenu.dashWin.subPanel === "wifi"
                readonly property bool isTargetActive: isWifiPanel
                    ? (leftRadialMenu.wifiPanel.currentNet ? leftRadialMenu.wifiPanel.currentNet.inUse : false)
                    : (leftRadialMenu.btPanel.currentBt ? leftRadialMenu.btPanel.currentBt.connected : false)
                title: isTargetActive ? "DISCONNECT" : "CONNECT"
                subtitle: isWifiPanel
                    ? (leftRadialMenu.wifiPanel.currentNet ? (isTargetActive ? ("Drop " + leftRadialMenu.wifiPanel.currentNet.ssid) : ("Join " + leftRadialMenu.wifiPanel.currentNet.ssid)) : "Select Network")
                    : (leftRadialMenu.btPanel.currentBt ? (isTargetActive ? ("Unlink " + leftRadialMenu.btPanel.currentBt.name) : ("Pair & Link " + leftRadialMenu.btPanel.currentBt.name)) : "Select Device")
                iconName: isWifiPanel ? "wifi" : "bluetooth"
                badgeColor: "#00F59B"
                active: isTargetActive
                bladeTilt: 7.0
                onClicked: {
                    if (leftRadialMenu.dashWin.wifiRadialOpen) {
                        var net = leftRadialMenu.wifiPanel.currentNet
                        if (!net) return
                        if (net.inUse) {
                            PhantomState.disconnectWifi(net.ssid)
                        } else if (net.saved || net.security === "OPEN") {
                            PhantomState.connectWifi(net.ssid, "")
                        } else {
                            leftRadialMenu.wifiPanel.submitOrFocusPasskey(net.ssid)
                        }
                    } else if (leftRadialMenu.dashWin.btRadialOpen) {
                        var dev = leftRadialMenu.btPanel.currentBt
                        if (!dev) return
                        if (dev.connected) PhantomState.disconnectBluetooth(dev.mac, dev.name)
                        else PhantomState.connectBluetooth(dev.mac, dev.name)
                    }
                }
            }
        }

        // bilah aksi informasi jaringan atau perangkat
        Item {
            width: parent.width
            height: 54

            P5BattleBlade {
                x: 24 + (1.0 - leftRadialMenu.openProgress) * 10
                width: parent.width - 28
                height: 54
                tailOnRight: true
                fanProgress: leftRadialMenu.openProgress
                readonly property bool isWifiPanel: leftRadialMenu.dashWin.subPanel === "wifi"
                title: isWifiPanel ? "NET INFO" : "DEV INFO"
                subtitle: isWifiPanel
                    ? (leftRadialMenu.dashWin.showWifiInfo ? "Showing Target Info" : "Inspect Signal & IP")
                    : (leftRadialMenu.dashWin.showBtInfo ? "Showing MAC Dossier" : "Inspect MAC & State")
                iconName: "info"
                badgeColor: "#00F0FF"
                active: isWifiPanel ? leftRadialMenu.dashWin.showWifiInfo : leftRadialMenu.dashWin.showBtInfo
                bladeTilt: 2.2
                onClicked: {
                    if (leftRadialMenu.dashWin.wifiRadialOpen) leftRadialMenu.dashWin.showWifiInfo = !leftRadialMenu.dashWin.showWifiInfo
                    else if (leftRadialMenu.dashWin.btRadialOpen) leftRadialMenu.dashWin.showBtInfo = !leftRadialMenu.dashWin.showBtInfo
                }
            }
        }

        // bilah aksi kata sandi wi-fi atau pemindaian bluetooth
        Item {
            width: parent.width
            height: 54

            P5BattleBlade {
                x: 24 + (1.0 - leftRadialMenu.openProgress) * 10
                width: parent.width - 28
                height: 54
                tailOnRight: true
                fanProgress: leftRadialMenu.openProgress
                readonly property bool isWifiPanel: leftRadialMenu.dashWin.subPanel === "wifi"
                title: isWifiPanel ? "PASSKEY" : "SCAN BT"
                subtitle: isWifiPanel
                    ? (leftRadialMenu.dashWin.showWifiPasswordBox ? "Hide Password Box" : "Enter Wi-Fi Password")
                    : (PhantomState.btScanning ? "Searching Nearby..." : "Refresh Device List")
                iconName: isWifiPanel ? "lock" : "scan"
                badgeColor: "#FFD700"
                active: isWifiPanel ? leftRadialMenu.dashWin.showWifiPasswordBox : PhantomState.btScanning
                bladeTilt: -2.2
                onClicked: {
                    if (leftRadialMenu.dashWin.wifiRadialOpen) leftRadialMenu.dashWin.showWifiPasswordBox = !leftRadialMenu.dashWin.showWifiPasswordBox
                    else if (leftRadialMenu.dashWin.btRadialOpen) PhantomState.scanBluetooth()
                }
            }
        }

        // bilah aksi tutup menu radial
        Item {
            width: parent.width
            height: 54

            P5BattleBlade {
                x: 12 + (1.0 - leftRadialMenu.openProgress) * 18
                width: parent.width - 28
                height: 54
                tailOnRight: true
                fanProgress: leftRadialMenu.openProgress
                title: "CANCEL"
                subtitle: "Close Command Menu"
                iconName: "close"
                badgeColor: "#FF1E2E"
                active: false
                bladeTilt: -7.0
                onClicked: {
                    leftRadialMenu.dashWin.selectedWifiIdx = -1
                    leftRadialMenu.dashWin.selectedBtIdx = -1
                    leftRadialMenu.dashWin.showWifiInfo = false
                    leftRadialMenu.dashWin.showBtInfo = false
                    leftRadialMenu.dashWin.showWifiPasswordBox = false
                }
            }
        }
    }
}
