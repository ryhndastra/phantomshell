pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    // state buka/tutup panel ui
    // set salah satu ke true kalau mau panel langsung kebuka pas shell baru start
    property bool launcherOpen: false
    property bool dashboardOpen: false
    property bool settingsOpen: false
    property bool notificationsOpen: false
    property bool calendarOpen: false
    property bool sessionOpen: false
    property bool lockOpen: false

    function lockScreen() {
        launcherOpen = false
        dashboardOpen = false
        settingsOpen = false
        notificationsOpen = false
        calendarOpen = false
        sessionOpen = false
        lockOpen = true
    }

    // state osd volume & brightness
    property bool osdVisible: false
    property string osdLabel: "VOLUME"
    property int osdValue: 65

    // palet warna aktif & tema default
    // ganti themeId & warna hex di bawah buat ubah tema default pas pertama jalan
    property string themeName: "P5 Phantom Crimson"
    property string themeId: "p5-crimson"
    property bool darkMode: true
    property bool transparencyEnabled: true
    property bool autoScheme: false

    property color primary: "#E60012"
    property color secondary: "#FFD700"
    property color accent: "#FF1E2E"
    property color background: "#0B0B0E"
    property color surface: "#141419"
    property color surfaceAlt: "#1F1F27"
    property color foreground: "#FFFFFF"
    property color muted: "#9E9EAE"
    property color borderLight: "#FFFFFF"
    property color borderDark: "#000000"
    property color urgent: "#FF0033"
    property color success: "#00F59B"

    readonly property var presets: ({
        "p5-crimson": {
            name: "P5 Phantom Crimson",
            id: "p5-crimson",
            primary: "#E60012",
            secondary: "#FFD700",
            accent: "#FF1E2E",
            background: "#0B0B0E",
            surface: "#141419",
            surfaceAlt: "#1F1F27",
            foreground: "#FFFFFF",
            muted: "#9E9EAE",
            borderLight: "#FFFFFF",
            borderDark: "#000000",
            urgent: "#FF0033",
            success: "#00F59B"
        },
        "p3-reload": {
            name: "P3 Reload S.E.E.S. Blue",
            id: "p3-reload",
            primary: "#00B4D8",
            secondary: "#90E0EF",
            accent: "#00F0FF",
            background: "#070C18",
            surface: "#0E172C",
            surfaceAlt: "#182544",
            foreground: "#F8FBFF",
            muted: "#8DA4C4",
            borderLight: "#E0F7FF",
            borderDark: "#040811",
            urgent: "#FF2A6D",
            success: "#05FFA1"
        },
        "p4-golden": {
            name: "P4 Golden Midnight",
            id: "p4-golden",
            primary: "#FFB703",
            secondary: "#FB8500",
            accent: "#FFE600",
            background: "#100F0C",
            surface: "#1C1A14",
            surfaceAlt: "#2B271E",
            foreground: "#FFFDF7",
            muted: "#B5AC96",
            borderLight: "#FFF5D6",
            borderDark: "#080705",
            urgent: "#E63946",
            success: "#52B788"
        },
        "kasumi-violet": {
            name: "Violet Kasumi",
            id: "kasumi-violet",
            primary: "#B829FF",
            secondary: "#FF70A6",
            accent: "#D96BFF",
            background: "#0C0812",
            surface: "#171122",
            surfaceAlt: "#231934",
            foreground: "#FDF8FF",
            muted: "#A899B8",
            borderLight: "#F5E6FF",
            borderDark: "#06030A",
            urgent: "#FF2A85",
            success: "#00F5D4"
        },
        "akechi-crow": {
            name: "Crow Royal Gold",
            id: "akechi-crow",
            primary: "#D4AF37",
            secondary: "#E60012",
            accent: "#FFF3B0",
            background: "#0A0A0C",
            surface: "#151519",
            surfaceAlt: "#222228",
            foreground: "#FAFAFC",
            muted: "#9E9EA8",
            borderLight: "#FFF8DC",
            borderDark: "#050507",
            urgent: "#E60012",
            success: "#52B788"
        },
        "futaba-matrix": {
            name: "Oracle Hacker Matrix",
            id: "futaba-matrix",
            primary: "#39FF14",
            secondary: "#FF9F1C",
            accent: "#72FF57",
            background: "#060C08",
            surface: "#0E1912",
            surfaceAlt: "#16281D",
            foreground: "#F0FFF4",
            muted: "#84A98C",
            borderLight: "#D8F3DC",
            borderDark: "#030704",
            urgent: "#FF595E",
            success: "#39FF14"
        },
        "monochrome": {
            name: "Phantom Monochrome",
            id: "monochrome",
            primary: "#E2E2EC",
            secondary: "#A0A0B2",
            accent: "#FFFFFF",
            background: "#09090B",
            surface: "#141418",
            surfaceAlt: "#202026",
            foreground: "#FFFFFF",
            muted: "#8E8E9E",
            borderLight: "#FFFFFF",
            borderDark: "#000000",
            urgent: "#FF4D6D",
            success: "#80ED99"
        },
        "expressive": {
            name: "Velvet Expressive",
            id: "expressive",
            primary: "#7B61FF",
            secondary: "#00F5D4",
            accent: "#9D85FF",
            background: "#0B0B14",
            surface: "#141526",
            surfaceAlt: "#1F2138",
            foreground: "#F8F8FF",
            muted: "#9A9CB8",
            borderLight: "#E8E8FF",
            borderDark: "#06060C",
            urgent: "#FF3366",
            success: "#00F5D4"
        },
        "tonal-spot": {
            name: "Gore Magala Ice",
            id: "tonal-spot",
            primary: "#8AB4F8",
            secondary: "#C58AF9",
            accent: "#A8C7FA",
            background: "#0A0C12",
            surface: "#131722",
            surfaceAlt: "#1D2232",
            foreground: "#F2F6FC",
            muted: "#94A0B8",
            borderLight: "#E2ECFF",
            borderDark: "#05060A",
            urgent: "#F28B82",
            success: "#81C995"
        }
    })

    // pengaturan default komponen bar, desktop widget, dan hyprland
    // ubah nilai default di bawah buat ngatur tampilan awal bar & widget desktop
    property bool polygonMode: true
    property real skewAngle: -10
    property int cornerRadius: 14

    // Bar & Layout Options
    property string barPosition: "top" // "top", "bottom"
    property string barStyle: "p5-skew" // "p5-skew", "float", "hug", "islands"
    property string groupStyle: "pills" // "no", "pills", "separated"
    property bool barShowBackground: false
    property bool barAutoHide: false
    property bool showWeatherHud: true
    property bool showWorkspaces: true
    property bool showDynamicIsland: true
    property bool showThemePill: true
    property bool showImPill: true
    property bool showStatsPill: true
    property bool showUnreadCount: true

    // Workspaces Options (like ii BarConfig)
    property int workspaceCount: 6
    property string workspaceNumStyle: "arabic" // "arabic", "roman", "kanji"

    // Bar Utility Buttons (like ii BarConfig)
    property bool showUtilButtons: true
    property bool showUtilSnip: true
    property bool showUtilPicker: true
    property bool showUtilMic: false
    property bool showUtilDark: false

    // Screen Frame / Corners (Default OFF so it never clashes with open app windows!)
    property bool screenFrame: false
    property string screenRoundCorner: "no" // "no", "yes", "not-fullscreen"
    property int frameThickness: 2

    // Shell Logo & Wallpaper Layer (Default TRUE with PhantomShell Logo Wallpaper!)
    readonly property string logoPath: Qt.resolvedUrl("../assets/pshell.png")
    readonly property string defaultWallpaperPath: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper.png"
    property bool showWallpaperLayer: true
    property bool wallpaperParallax: true
    property int wallpaperZoom: 104
    property string wallpaperPath: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper.png"
    readonly property var availableWallpapers: [
        "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper.png",
        "/home/sho/Pictures/Wallpapers/goremagala_iceshard.jpg",
        "/home/sho/Pictures/Wallpapers/1409986.png",
        "/home/sho/Pictures/Wallpapers/wallhaven-0q3yqq.jpg",
        "/home/sho/Pictures/Wallpapers/wallhaven-28z766.png",
        "/home/sho/Pictures/Wallpapers/wallhaven-6d9o96.png",
        "/home/sho/Pictures/Wallpapers/wallhaven-72m78v.png",
        "/home/sho/Pictures/Wallpapers/wallhaven-l3g222.png",
        "/home/sho/Pictures/Wallpapers/wallhaven-j3vvdw.png"
    ]

    function cycleWallpaper() {
        var idx = availableWallpapers.indexOf(wallpaperPath)
        var nextIdx = (idx + 1) % availableWallpapers.length
        wallpaperPath = availableWallpapers[nextIdx]
        Quickshell.execDetached(["sh", "-c", "swww img '" + wallpaperPath + "' --transition-type grow --transition-fps 60 2>/dev/null || true"])
        saveState()
    }

    // Desktop Widgets (Clock + Quote + Split Cava + Center Live Lyrics)
    property bool showDesktopClock: true
    property string desktopClockStyle: "p5-editorial" // "p5-editorial", "minimal", "cyber"
    property string desktopClockPosition: "top-left" // "top-left", "center", "top-right", "bottom-left"
    property int desktopClockScale: 100
    property bool desktopClockShowSeconds: false
    property bool desktopClockShowQuote: true
    property string desktopQuoteText: "TAKE YOUR TIME // STEAL BACK YOUR FUTURE"

    property bool showDesktopCava: true
    property bool cavaIdleWave: false
    property int cavaBarCount: 36
    property int cavaMaxHeight: 110

    property bool showDesktopLyrics: true
    property bool lyricsShowCard: false

    // Widgets & Notifications
    property string statsStyle: "pentagon" // "pentagon" or "bars"
    property bool dndEnabled: false
    property bool sfxEnabled: true
    property real sfxVolume: 0.7

    // Hyprland Live Tuning
    property int hyprGapsIn: 5
    property int hyprGapsOut: 10
    property int hyprBorderSize: 2
    property int hyprRounding: 10
    property bool hyprBlurEnabled: true
    property int hyprBlurSize: 6
    property int hyprBlurPasses: 2
    property bool hyprAnimationsEnabled: true

    // Display / Monitor Configuration & InFocus Projector Mirroring
    property var monitorList: ([{
        name: "eDP-1",
        description: "Chimei Innolux Corporation 0x1521",
        width: 1920,
        height: 1080,
        refreshRate: 144.0,
        x: 0,
        y: 0,
        scale: 1.0,
        transform: 0,
        disabled: false,
        mirrorOf: "none",
        availableModes: ["1920x1080@144.00Hz", "1920x1080@60.02Hz"]
    }])
    property int selectedMonitorIdx: 0
    property string displayName: "eDP-1"
    property string displayDesc: "Chimei Innolux Corporation 0x1521"
    property bool displayEnabled: true
    property string displayMode: "1920x1080@144.00Hz"
    property var displayAvailableModes: ["1920x1080@144.00Hz", "1920x1080@60.02Hz"]
    property int displayTransform: 0 // 0=Normal, 1=90°, 2=180°, 3=270°
    property int displayScalePct: 100
    property int displayPosX: 0
    property int displayPosY: 0
    property string displayMirrorOf: "none"
    property string presentationMode: "extend" // "extend", "mirror-auto", "mirror-1080p", "mirror-720p"

    Process {
        id: monitorsProc
        command: ["hyprctl", "monitors", "all", "-j"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    const arr = JSON.parse(data)
                    if (Array.isArray(arr) && arr.length > 0) {
                        root.monitorList = arr
                        if (root.selectedMonitorIdx >= arr.length) {
                            root.selectedMonitorIdx = 0
                        }
                        root.loadMonitorIntoState(root.selectedMonitorIdx)
                    }
                } catch (e) {}
            }
        }
    }

    function refreshMonitors() {
        monitorsProc.running = true
    }

    property bool _displayAutoOptimized: false

    function parseModeScore(modeStr) {
        const m = String(modeStr).match(/(\d+)x(\d+)@([\d.]+)/)
        if (!m) return { pixels: 0, rate: 0 }
        return {
            pixels: Number(m[1]) * Number(m[2]),
            rate: Number(m[3])
        }
    }

    function sortDisplayModes(rawModes) {
        const seen = {}
        const unique = []
        for (let i = 0; i < rawModes.length; i++) {
            const s = String(rawModes[i]).trim()
            if (s && !seen[s]) {
                seen[s] = true
                unique.push(s)
            }
        }
        unique.sort(function(a, b) {
            const sa = root.parseModeScore(a)
            const sb = root.parseModeScore(b)
            if (sb.pixels !== sa.pixels) return sb.pixels - sa.pixels
            return sb.rate - sa.rate
        })
        return unique
    }

    function loadMonitorIntoState(idx) {
        if (!root.monitorList || idx < 0 || idx >= root.monitorList.length) return
        root.selectedMonitorIdx = idx
        const m = root.monitorList[idx]
        root.displayName = m.name || "eDP-1"
        root.displayDesc = m.description || m.model || "Display"
        root.displayEnabled = !m.disabled

        let rawModes = (m.availableModes && m.availableModes.length > 0)
            ? m.availableModes.slice()
            : [(m.width || 1920) + "x" + (m.height || 1080) + "@" + Number(m.refreshRate || 144).toFixed(2) + "Hz"]

        // If running inside nested Hyprland (WAYLAND-1) with only 1 virtual mode, expose full hardware framerate options
        if (String(root.displayName).indexOf("WAYLAND") === 0 || rawModes.length <= 1) {
            const fallbackModes = [
                "1920x1080@144.00Hz",
                "1920x1080@120.00Hz",
                "1920x1080@60.02Hz",
                "1920x1080@60.00Hz",
                "1600x900@60.00Hz",
                "1280x720@60.00Hz"
            ]
            for (let i = 0; i < fallbackModes.length; i++) {
                rawModes.push(fallbackModes[i])
            }
        }

        const modes = root.sortDisplayModes(rawModes)
        root.displayAvailableModes = modes

        // Default to the BEST mode (highest resolution & highest refresh rate, e.g. 1920x1080@144.00Hz)
        const bestMode = modes[0] || "1920x1080@144.00Hz"
        const curRate = Number(m.refreshRate || 144).toFixed(2)
        const curModeGuess = (m.width || 1920) + "x" + (m.height || 1080) + "@" + curRate + "Hz"

        if (!root._displayAutoOptimized) {
            root._displayAutoOptimized = true
            root.displayMode = bestMode
            if (String(root.displayName).indexOf("WAYLAND") !== 0 && curModeGuess !== bestMode) {
                Qt.callLater(function() { root.applyDisplayConfig() })
            }
        } else {
            root.displayMode = modes.indexOf(curModeGuess) !== -1 ? curModeGuess : bestMode
        }

        root.displayTransform = Number(m.transform || 0)
        root.displayScalePct = Math.round(Number(m.scale || 1.0) * 100)
        root.displayPosX = Number(m.x || 0)
        root.displayPosY = Number(m.y || 0)
        root.displayMirrorOf = (m.mirrorOf && m.mirrorOf !== "none") ? m.mirrorOf : "none"
    }

    function cycleSelectedMonitor() {
        if (!root.monitorList || root.monitorList.length <= 1) {
            refreshMonitors()
            return
        }
        const nextIdx = (root.selectedMonitorIdx + 1) % root.monitorList.length
        loadMonitorIntoState(nextIdx)
    }

    function setDisplayMode(modeStr) {
        if (!modeStr) return
        root.displayMode = modeStr
        applyDisplayConfig()
        playSfx("select")
    }

    function cycleDisplayMode() {
        if (!root.displayAvailableModes || root.displayAvailableModes.length === 0) return
        const idx = root.displayAvailableModes.indexOf(root.displayMode)
        const nextIdx = (idx + 1) % root.displayAvailableModes.length
        setDisplayMode(root.displayAvailableModes[nextIdx])
    }

    function setDisplayTransform(t) {
        root.displayTransform = t
        applyDisplayConfig()
    }

    function applyDisplayConfig() {
        if (!root.displayEnabled && root.monitorList.length > 1) {
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", root.displayName + ",disable"])
            return
        }
        const cleanMode = root.displayMode.replace("Hz", "")
        const scaleVal = (Math.max(50, Math.min(300, root.displayScalePct)) / 100.0).toFixed(2)
        let rule = root.displayName + "," + cleanMode + "," + root.displayPosX + "x" + root.displayPosY + "," + scaleVal + ",transform," + root.displayTransform
        if (root.displayMirrorOf !== "none" && root.displayMirrorOf !== root.displayName) {
            rule += ",mirror," + root.displayMirrorOf
        }
        Quickshell.execDetached(["hyprctl", "keyword", "monitor", rule])
    }

    function setPresentationMode(mode) {
        root.presentationMode = mode
        const primaryMon = (root.monitorList && root.monitorList.length > 0) ? root.monitorList[0].name : "eDP-1"
        if (mode === "extend") {
            Quickshell.execDetached(["bash", "-c",
                "hyprctl keyword monitor ',preferred,auto,1'; " +
                "for m in $(hyprctl monitors all -j | grep -o '\"name\": *\"[^\"]*\"' | cut -d'\"' -f4); do " +
                "  if [ \"$m\" != \"" + primaryMon + "\" ]; then hyprctl keyword monitor \"$m,preferred,auto,1\"; fi; " +
                "done"
            ])
        } else if (mode === "mirror-auto") {
            Quickshell.execDetached(["bash", "-c",
                "hyprctl keyword monitor ',preferred,auto,1,mirror," + primaryMon + "'; " +
                "for m in $(hyprctl monitors all -j | grep -o '\"name\": *\"[^\"]*\"' | cut -d'\"' -f4); do " +
                "  if [ \"$m\" != \"" + primaryMon + "\" ]; then hyprctl keyword monitor \"$m,preferred,auto,1,mirror," + primaryMon + "\"; fi; " +
                "done"
            ])
        } else if (mode === "mirror-1080p") {
            Quickshell.execDetached(["bash", "-c",
                "hyprctl keyword monitor ',1920x1080@60,auto,1,mirror," + primaryMon + "'; " +
                "for m in $(hyprctl monitors all -j | grep -o '\"name\": *\"[^\"]*\"' | cut -d'\"' -f4); do " +
                "  if [ \"$m\" != \"" + primaryMon + "\" ]; then hyprctl keyword monitor \"$m,1920x1080@60,auto,1,mirror," + primaryMon + "\"; fi; " +
                "done"
            ])
        } else if (mode === "mirror-720p") {
            Quickshell.execDetached(["bash", "-c",
                "hyprctl keyword monitor ',1280x720@60,auto,1,mirror," + primaryMon + "'; " +
                "for m in $(hyprctl monitors all -j | grep -o '\"name\": *\"[^\"]*\"' | cut -d'\"' -f4); do " +
                "  if [ \"$m\" != \"" + primaryMon + "\" ]; then hyprctl keyword monitor \"$m,1280x720@60,auto,1,mirror," + primaryMon + "\"; fi; " +
                "done"
            ])
        }
        refreshMonitors()
    }

    // data statistik sistem & spesifikasi hardware buat radar & tab about
    property real cpuPct: 28
    property real ramPct: 45
    property real gpuPct: 34
    property real diskPct: 52
    property real tempPct: 42
    property int volumePct: 65
    property int batteryPct: 88
    property bool wifiConnected: true
    property bool btConnected: true

    // info spesifikasi os & hardware buat tab 6. about
    property string sysHost: "sho@nixos"
    property string sysOs: "NixOS 26.11 (Zokor) x86_64"
    property string sysKernel: "Linux 7.1.8"
    property string sysCpuModel: "12th Gen Intel Core i5-12450H"
    property string sysGpuModel: "NVIDIA GeForce RTX 3050 Mobile + Intel UHD"
    property string sysRamText: "11 GiB / 23 GiB"
    property string sysUptime: "Active Session"

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

    function refreshSystemDossier() {
        sysInfoProc.running = true
    }

    // server notifikasi & riwayat chat sns
    // tambahin kalimat di renTestQuotes kalau mau nambah variasi pesan tombol test im
    property ListModel imNotifications: ListModel {}
    property ListModel imPopupStack: ListModel {}
    property int _testQuoteIdx: 0
    readonly property var renTestQuotes: [
        "It's showtime. Let's infiltrate the Palace.",
        "I should check today's requests in Mementos...",
        "I'll write this down in my diary before sleeping.",
        "Time to brew some Leblanc curry and coffee.",
        "All systems ready. Steal back your future."
    ]

    NotificationServer {
        id: notifServer
        keepOnReload: false
        actionsSupported: true
        bodyMarkupSupported: true

        onNotification: notif => {
            notif.tracked = true
            const sender = notif.appName || "Ren"
            const summary = notif.summary || "New Message"
            const body = notif.body ? (summary + " — " + notif.body) : summary
            const icon = notif.image || notif.appIcon || ""
            root.pushImNotification(sender, body, "NORMAL", icon)
        }
    }

    function sendTestNotification() {
        const msg = root.renTestQuotes[root._testQuoteIdx % root.renTestQuotes.length]
        root._testQuoteIdx = (root._testQuoteIdx + 1) % root.renTestQuotes.length
        root.pushImNotification("Ren", msg, "CRITICAL", "")
    }

    function pushImNotification(sender, message, urgency, icon) {
        const now = new Date()
        const timeStr = Qt.formatTime(now, "hh:mm")
        const cleanSender = sender || "Ren"
        const cleanMsg = message || "It's showtime. Let's infiltrate the Palace."
        const cleanUrg = urgency || "NORMAL"
        const cleanIcon = icon || ""
        const item = {
            "uid": Date.now() + Math.floor(Math.random() * 1000),
            "sender": cleanSender,
            "senderName": cleanSender,
            "message": cleanMsg,
            "msgBody": cleanMsg,
            "urgency": cleanUrg,
            "msgUrgency": cleanUrg,
            "time": timeStr,
            "msgTime": timeStr,
            "appIcon": cleanIcon,
            "msgIcon": cleanIcon
        }
        imNotifications.insert(0, item)
        if (!root.dndEnabled) {
            imPopupStack.insert(0, item)
            if (imPopupStack.count > 3) {
                imPopupStack.remove(imPopupStack.count - 1)
            }
            popupCleanupTimer.restart()
        }
        playSfx("notif")
    }

    function dismissPopup(index) {
        if (index >= 0 && index < imPopupStack.count) {
            imPopupStack.remove(index)
        }
    }

    Timer {
        id: popupCleanupTimer
        interval: 6000
        repeat: true
        running: root.imPopupStack.count > 0
        onTriggered: {
            if (root.imPopupStack.count > 0) {
                root.imPopupStack.remove(root.imPopupStack.count - 1)
            }
        }
    }

    Component.onCompleted: {
        refreshSystemDossier()
    }

    // fungsi sinkronisasi tema & konfigurasi live ke hyprland
    function applyPreset(presetId) {
        if (presets[presetId]) {
            const p = presets[presetId]
            themeId = p.id
            themeName = p.name
            primary = p.primary
            secondary = p.secondary
            accent = p.accent
            background = p.background
            surface = p.surface
            surfaceAlt = p.surfaceAlt
            foreground = p.foreground
            muted = p.muted
            borderLight = p.borderLight
            borderDark = p.borderDark
            urgent = p.urgent
            success = p.success

            const cleanHex = String(p.primary).replace("#", "")
            Quickshell.execDetached(["hyprctl", "keyword", "general:col.active_border", "rgba(" + cleanHex + "ff)"])
            saveState()
            playSfx("select")
        }
    }

    function setDarkMode(isDark) {
        darkMode = isDark
        if (isDark) {
            applyPreset(themeId)
        } else {
            background = "#F4F4F8"
            surface = "#FFFFFF"
            surfaceAlt = "#E6E6F0"
            foreground = "#101016"
            muted = "#5A5A6E"
            borderLight = "#101016"
            borderDark = "#CCCCD8"
            saveState()
        }
    }

    function syncHyprland() {
        const cleanHex = String(root.primary).replace("#", "")
        const cmd = [
            "hyprctl --batch \"",
            "keyword general:gaps_in " + root.hyprGapsIn + ";",
            "keyword general:gaps_out " + root.hyprGapsOut + ";",
            "keyword general:border_size " + root.hyprBorderSize + ";",
            "keyword decoration:rounding " + root.hyprRounding + ";",
            "keyword decoration:blur:enabled " + (root.hyprBlurEnabled ? "true" : "false") + ";",
            "keyword decoration:blur:size " + root.hyprBlurSize + ";",
            "keyword decoration:blur:passes " + root.hyprBlurPasses + ";",
            "keyword animations:enabled " + (root.hyprAnimationsEnabled ? "true" : "false") + ";",
            "keyword general:col.active_border rgba(" + cleanHex + "ff)\""
        ].join(" ")
        Quickshell.execDetached(["bash", "-c", cmd])
        saveState()
    }

    function saveState() {
        const settingsData = {
            theme: {
                mode: root.darkMode ? "dark" : "light",
                preset: root.themeId,
                polygonMode: root.polygonMode,
                skewAngle: root.skewAngle,
                transparency: root.transparencyEnabled,
                wallpaperPath: root.wallpaperPath,
                wallpaperParallax: root.wallpaperParallax,
                wallpaperZoom: root.wallpaperZoom
            },
            bar: {
                position: root.barPosition,
                barStyle: root.barStyle,
                groupStyle: root.groupStyle,
                barShowBackground: root.barShowBackground,
                barAutoHide: root.barAutoHide,
                workspaceCount: root.workspaceCount,
                workspaceNumStyle: root.workspaceNumStyle,
                showUtilButtons: root.showUtilButtons,
                showUtilSnip: root.showUtilSnip,
                showUtilPicker: root.showUtilPicker,
                showUtilMic: root.showUtilMic,
                showUtilDark: root.showUtilDark,
                screenFrame: root.screenFrame,
                screenRoundCorner: root.screenRoundCorner,
                frameThickness: root.frameThickness,
                cornerRadius: root.cornerRadius,
                showWeatherHud: root.showWeatherHud,
                showWorkspaces: root.showWorkspaces,
                showDynamicIsland: root.showDynamicIsland,
                showThemePill: root.showThemePill,
                showImPill: root.showImPill,
                showStatsPill: root.showStatsPill
            },
            desktop: {
                showDesktopClock: root.showDesktopClock,
                desktopClockStyle: root.desktopClockStyle,
                desktopClockPosition: root.desktopClockPosition,
                desktopClockScale: root.desktopClockScale,
                desktopClockShowSeconds: root.desktopClockShowSeconds,
                desktopClockShowQuote: root.desktopClockShowQuote,
                showDesktopCava: root.showDesktopCava,
                cavaIdleWave: root.cavaIdleWave,
                showDesktopLyrics: root.showDesktopLyrics,
                lyricsShowCard: root.lyricsShowCard,
                cavaBarCount: root.cavaBarCount,
                cavaMaxHeight: root.cavaMaxHeight
            },
            widgets: {
                statsStyle: root.statsStyle,
                notifStyle: "p5-bubble"
            },
            hyprland: {
                gapsIn: root.hyprGapsIn,
                gapsOut: root.hyprGapsOut,
                borderSize: root.hyprBorderSize,
                rounding: root.hyprRounding,
                blurEnabled: root.hyprBlurEnabled,
                blurSize: root.hyprBlurSize,
                blurPasses: root.hyprBlurPasses,
                animationsEnabled: root.hyprAnimationsEnabled
            },
            sfx: {
                enabled: root.sfxEnabled,
                volume: root.sfxVolume
            }
        }
        const statePath = Quickshell.shellPath("../phantomshell/settings.json")
        Quickshell.execDetached(["bash", "-c", "cat << 'EOF' > '" + statePath + "'\n" + JSON.stringify(settingsData, null, 2) + "\nEOF"])
    }

    function triggerOsd(label, val) {
        osdLabel = label
        osdValue = Math.max(0, Math.min(150, val))
        if (label === "VOLUME") volumePct = osdValue
        osdVisible = true
        osdHideTimer.restart()
    }

    Timer {
        id: osdHideTimer
        interval: 2200
        repeat: false
        onTriggered: root.osdVisible = false
    }

    function playSfx(kind) {
        if (!root.sfxEnabled) return
        if (kind === "notif") {
            const wavPath = Quickshell.shellPath("assets/persona-5-notif-sound.wav")
            const mp3Path = Quickshell.shellPath("assets/persona-5-notif-sound.mp3")
            const vol = Math.max(0.1, Math.min(1.0, root.sfxVolume)).toFixed(2)
            Quickshell.execDetached([
                "bash", "-c",
                "pw-play --volume=" + vol + " '" + wavPath + "' 2>/dev/null || ffplay -nodisp -autoexit -loglevel quiet '" + mp3Path + "' 2>/dev/null || true"
            ])
        }
    }

    // poller metrik sistem (cuma jalan pas dashboard atau settings dibuka biar hemat cpu)
    Process {
        id: statsProc
        command: ["bash", "-c", "awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf \"%.0f\", (t-a)*100/t}' /proc/meminfo; echo -n ' '; df / --output=pcent | tail -1 | tr -dc '0-9'; echo -n ' '; cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf \"%.0f\", $1/1000}' || echo 45"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 1 && !isNaN(Number(parts[0]))) root.ramPct = Number(parts[0])
                if (parts.length >= 2 && !isNaN(Number(parts[1]))) root.diskPct = Number(parts[1])
                if (parts.length >= 3 && !isNaN(Number(parts[2]))) root.tempPct = Math.min(100, Number(parts[2]))
                const loadJitter = Math.floor(Math.random() * 10) - 4
                root.cpuPct = Math.max(12, Math.min(96, root.cpuPct + loadJitter))
                root.gpuPct = Math.max(15, Math.min(92, root.gpuPct + Math.floor(Math.random() * 8) - 3))
            }
        }
    }

    Timer {
        interval: 5000
        running: root.showStatsPill || root.dashboardOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProc.running = true
    }
}
