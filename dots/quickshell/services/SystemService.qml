import QtQuick
import Quickshell
import Quickshell.Io

// layanan statistik perangkat keras, spesifikasi sistem, dan pelacak aplikasi tiap workspace
Scope {
    id: root

    property bool pollStats: false
    property bool pollWorkspaces: true

    property real cpuPct: 8
    property real ramPct: 24
    property real gpuPct: 4
    property real diskPct: 47
    property real tempPct: 45
    property int batteryPct: 100

    property double prevCpuTotal: 0
    property double prevCpuIdle: 0

    property string sysHost: "sho@nixos"
    property string sysOs: "NixOS 26.11 (Zokor) x86_64"
    property string sysKernel: "Linux 7.1.8"
    property string sysCpuModel: "12th Gen Intel Core i5-12450H"
    property string sysGpuModel: "NVIDIA GeForce RTX 3050 Mobile + Intel UHD"
    property string sysRamText: "11 GiB / 23 GiB"
    property string sysUptime: "Active Session"

    property var workspaceApps: ({})
    property int activeWorkspaceId: 1

    Process {
        id: sysInfoProc
        command: ["bash", "-c",
            "HOST=\"$(whoami)@$(hostname)\"; " +
            "OS=$(grep -m1 '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d'\"' -f2); " +
            "KERN=$(uname -sr 2>/dev/null); " +
            "CPU=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d':' -f2 | sed 's/(R)//g; s/(TM)//g; s/^[ \\t]*//'); " +
            "RAM=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 \" / \" $2}'); " +
            "UP_SEC=$(awk '{print int($1)}' /proc/uptime 2>/dev/null); " +
            "UP_H=$((UP_SEC / 3600)); UP_M=$(((UP_SEC % 3600) / 60)); " +
            "echo \"${HOST}|${OS}|${KERN}|${CPU}|${RAM}|${UP_H}h ${UP_M}m\""
        ]
        stdout: SplitParser {
            onRead: data => {
                const parts = String(data).trim().split("|")
                if (parts.length >= 6) {
                    if (parts[0]) root.sysHost = parts[0]
                    if (parts[1]) root.sysOs = parts[1]
                    if (parts[2]) root.sysKernel = parts[2]
                    if (parts[3]) root.sysCpuModel = parts[3]
                    if (parts[4]) root.sysRamText = parts[4]
                    if (parts[5]) root.sysUptime = parts[5]
                }
            }
        }
    }

    function refreshSystemInfo() {
        sysInfoProc.running = true
    }

    function resolveAppIconUrl(cls) {
        if (!cls) return ""
        const raw = String(cls).trim()
        const c = raw.toLowerCase()

        // deteksi khusus game steam (steam_app_<appid> -> steam_icon_<appid>)
        if (c.indexOf("steam_app_") === 0) {
            const appId = c.substring(10).trim()
            if (appId.length > 0) {
                const steamIconName = "steam_icon_" + appId
                const p = Quickshell.iconPath(steamIconName, true)
                if (p && String(p).length > 0) return p
                const homeDir = Quickshell.env("HOME") || "/home/sho"
                return "file://" + homeDir + "/.local/share/icons/hicolor/48x48/apps/" + steamIconName + ".png"
            }
        }

        // cocokkan dengan daftar DesktopEntries sistem terlebih dahulu
        const apps = DesktopEntries.applications.values || []
        for (let j = 0; j < apps.length; j++) {
            const entry = apps[j]
            if (!entry || !entry.icon) continue
            const sClass = String(entry.startupClass || "").toLowerCase()
            const eId = String(entry.id || "").toLowerCase().replace(/\.desktop$/, "")
            const eName = String(entry.name || "").toLowerCase()
            if ((sClass && sClass === c) || (eId && eId === c) || (eName && eName === c)) {
                const ic = String(entry.icon).trim()
                if (ic.startsWith("file://") || ic.startsWith("image://")) return ic
                if (ic.startsWith("/")) return "file://" + ic
                const resolved = Quickshell.iconPath(ic, true)
                if (resolved && String(resolved).length > 0) return resolved
            }
        }

        const candidates = [raw, c]
        if (c.indexOf("zen") !== -1) candidates.push("zen-browser", "zen", "firefox")
        else if (c.indexOf("vesktop") !== -1 || c.indexOf("discord") !== -1) candidates.push("vesktop", "discord", "com.discordapp.Discord")
        else if (c === "code" || c.indexOf("vscode") !== -1 || c.indexOf("codium") !== -1) candidates.push("vscode", "code", "com.visualstudio.code", "vscodium")
        else if (c.indexOf("spotify") !== -1) candidates.push("spotify", "spotify-client", "com.spotify.Client")
        else if (c.indexOf("kitty") !== -1) candidates.push("kitty")
        else if (c.indexOf("alacritty") !== -1) candidates.push("Alacritty", "utilities-terminal")
        else if (c.indexOf("wezterm") !== -1 || c.indexOf("foot") !== -1 || c.indexOf("ghostty") !== -1) candidates.push("utilities-terminal")
        else if (c.indexOf("thunar") !== -1 || c.indexOf("nautilus") !== -1 || c.indexOf("dolphin") !== -1 || c.indexOf("nemo") !== -1) candidates.push("system-file-manager", "folder")
        else if (c.indexOf("chrome") !== -1 || c.indexOf("chromium") !== -1) candidates.push("google-chrome", "chromium")
        else if (c.indexOf("brave") !== -1) candidates.push("brave-browser", "brave")
        else if (c.indexOf("firefox") !== -1) candidates.push("firefox")
        else if (c.indexOf("obs") !== -1) candidates.push("com.obsproject.Studio", "obs")
        else if (c.indexOf("steam") !== -1) candidates.push("steam", "steam-icon")
        else if (c.indexOf("telegram") !== -1) candidates.push("telegram", "org.telegram.desktop")
        else if (c.indexOf("mpv") !== -1) candidates.push("mpv")
        else if (c.indexOf("vlc") !== -1) candidates.push("vlc")
        else if (c.indexOf("btop") !== -1) candidates.push("btop")
        else if (c.indexOf("nvtop") !== -1) candidates.push("nvtop")

        for (let i = 0; i < candidates.length; i++) {
            const p = Quickshell.iconPath(candidates[i], true)
            if (p && String(p).length > 0) return p
        }
        return ""
    }

    function resolveAppGlyph(cls) {
        if (!cls) return "\uf2d0"
        const c = String(cls).toLowerCase()
        if (c.indexOf("kitty") !== -1 || c.indexOf("alacritty") !== -1 || c.indexOf("foot") !== -1 || c.indexOf("wezterm") !== -1 || c.indexOf("ghostty") !== -1 || c.indexOf("term") !== -1) return "\uf489"
        if (c.indexOf("zen") !== -1 || c.indexOf("firefox") !== -1 || c.indexOf("floorp") !== -1 || c.indexOf("librewolf") !== -1) return "\uf269"
        if (c.indexOf("chrome") !== -1 || c.indexOf("chromium") !== -1 || c.indexOf("brave") !== -1 || c.indexOf("vivaldi") !== -1) return "\uf268"
        if (c === "code" || c.indexOf("vscode") !== -1 || c.indexOf("codium") !== -1 || c.indexOf("nvim") !== -1 || c.indexOf("neovide") !== -1 || c.indexOf("zed") !== -1 || c.indexOf("cursor") !== -1 || c.indexOf("antigravity") !== -1) return "\uf121"
        if (c.indexOf("vesktop") !== -1 || c.indexOf("discord") !== -1 || c.indexOf("webcord") !== -1) return "\uf392"
        if (c.indexOf("telegram") !== -1) return "\uf2c6"
        if (c.indexOf("spotify") !== -1 || c.indexOf("music") !== -1 || c.indexOf("amberol") !== -1 || c.indexOf("cider") !== -1) return "\uf1bc"
        if (c.indexOf("mpv") !== -1 || c.indexOf("vlc") !== -1 || c.indexOf("celluloid") !== -1) return "\uf144"
        if (c.indexOf("thunar") !== -1 || c.indexOf("nautilus") !== -1 || c.indexOf("dolphin") !== -1 || c.indexOf("nemo") !== -1 || c.indexOf("pcmanfm") !== -1) return "\uf07b"
        if (c.indexOf("steam") !== -1 || c.indexOf("lutris") !== -1 || c.indexOf("heroic") !== -1) return "\uf1b6"
        if (c.indexOf("obs") !== -1) return "\uf03d"
        if (c.indexOf("gimp") !== -1 || c.indexOf("inkscape") !== -1 || c.indexOf("krita") !== -1 || c.indexOf("blender") !== -1) return "\uf1fc"
        if (c.indexOf("zathura") !== -1 || c.indexOf("evince") !== -1 || c.indexOf("okular") !== -1 || c.indexOf("office") !== -1) return "\uf15c"
        return "\uf2d0"
    }

    property bool wsRefreshPending: false

    function triggerClientsRefresh() {
        if (wsClientsProc.running) {
            root.wsRefreshPending = true
        } else {
            wsClientsProc.running = true
        }
    }

    function refreshWorkspaces() {
        root.triggerClientsRefresh()
        wsFollowUpTimer.restart()
    }

    // pengecekan susulan 180ms untuk menangkap aplikasi electron/xwayland yang baru selesai minimize ke tray
    Timer {
        id: wsFollowUpTimer
        interval: 180
        repeat: false
        onTriggered: root.triggerClientsRefresh()
    }

    Process {
        id: wsClientsProc
        command: ["hyprctl", "clients", "-j"]
        onExited: {
            if (root.wsRefreshPending) {
                root.wsRefreshPending = false
                wsClientsProc.running = true
            }
        }
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    const arr = JSON.parse(data)
                    if (!Array.isArray(arr)) return
                    const map = {}
                    for (let i = 0; i < arr.length; i++) {
                        const win = arr[i]
                        if (!win || !win.mapped || win.hidden) continue
                        if (win.size && (win.size[0] <= 4 || win.size[1] <= 4)) continue
                        const wsId = win.workspace ? win.workspace.id : 0
                        if (!wsId || wsId <= 0) continue
                        const rawTitle = String(win.title || win.initialTitle || "").trim()
                        if (rawTitle.toLowerCase() === "steamwebhelper") continue
                        const cls = String(win.class || win.initialClass || rawTitle || "").trim()
                        if (!cls) continue
                        const key = String(wsId)
                        if (!map[key]) map[key] = []
                        if (map[key].length < 4) {
                            map[key].push({
                                cls: cls,
                                title: rawTitle || cls,
                                iconUrl: root.resolveAppIconUrl(cls),
                                glyph: root.resolveAppGlyph(cls)
                            })
                        }
                    }
                    root.workspaceApps = map
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 1500
        running: root.pollWorkspaces
        repeat: true
        triggeredOnStart: true
        onTriggered: root.triggerClientsRefresh()
    }

    // poller metrik sistem nyata (cpu, ram, disk, suhu, baterai, dan gpu)
    Process {
        id: statsProc
        command: ["bash", "-c",
            "CPU_LINE=$(awk '/^cpu / {total=0; for(i=2;i<=NF;i++) total+=$i; idle=$5+$6; print total \" \" idle}' /proc/stat); " +
            "RAM=$(awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf \"%.0f\", (t-a)*100/t}' /proc/meminfo); " +
            "DISK=$(df / --output=pcent 2>/dev/null | tail -1 | tr -dc '0-9'); " +
            "TEMP=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf \"%.0f\", $1/1000}' || echo 45); " +
            "BAT=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 || echo 100); " +
            "GPU=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 | tr -dc '0-9'); " +
            "[ -z \"$GPU\" ] && GPU=0; " +
            "echo \"${CPU_LINE} ${RAM} ${DISK} ${TEMP} ${BAT} ${GPU}\""
        ]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 7) {
                    const curTotal = Number(parts[0])
                    const curIdle = Number(parts[1])
                    if (root.prevCpuTotal > 0 && curTotal > root.prevCpuTotal) {
                        const dTotal = curTotal - root.prevCpuTotal
                        const dIdle = curIdle - root.prevCpuIdle
                        root.cpuPct = Math.max(0, Math.min(100, Math.round(((dTotal - dIdle) / dTotal) * 100)))
                    }
                    root.prevCpuTotal = curTotal
                    root.prevCpuIdle = curIdle

                    if (!isNaN(Number(parts[2]))) root.ramPct = Number(parts[2])
                    if (!isNaN(Number(parts[3]))) root.diskPct = Number(parts[3])
                    if (!isNaN(Number(parts[4]))) root.tempPct = Math.min(100, Number(parts[4]))
                    if (!isNaN(Number(parts[5]))) root.batteryPct = Math.max(0, Math.min(100, Number(parts[5])))
                    if (!isNaN(Number(parts[6]))) root.gpuPct = Math.max(0, Math.min(100, Number(parts[6])))
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: root.pollStats
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProc.running = true
    }
}
