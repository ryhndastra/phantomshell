pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    // state visibilitas panel antarmuka
    property bool launcherOpen: false
    property bool dashboardOpen: false
    property bool settingsOpen: false
    property bool notificationsOpen: false
    property bool calendarOpen: false
    property bool sessionOpen: false
    property bool lockOpen: false
    property bool wallpaperSelectorOpen: false
    property bool mediaPopupOpen: false

    // state animasi transisi tema dan wallpaper
    property int transitionTick: 0
    property string transitionTitle: "METAVERSE SHIFT"
    property string transitionSub: "PALETTE SYNCHRONIZED"
    property string previousWallpaperPath: ""

    function toggleLauncher() {
        const next = !launcherOpen
        if (next) {
            dashboardOpen = false
            settingsOpen = false
            notificationsOpen = false
            calendarOpen = false
            sessionOpen = false
            wallpaperSelectorOpen = false
            mediaPopupOpen = false
        }
        launcherOpen = next
    }

    function toggleSettings() {
        const next = !settingsOpen
        if (next) {
            launcherOpen = false
            dashboardOpen = false
            notificationsOpen = false
            calendarOpen = false
            wallpaperSelectorOpen = false
            mediaPopupOpen = false
        }
        settingsOpen = next
    }

    function toggleWallpaperSelector() {
        const next = !wallpaperSelectorOpen
        if (next) {
            launcherOpen = false
            dashboardOpen = false
            settingsOpen = false
            notificationsOpen = false
            calendarOpen = false
            sessionOpen = false
            mediaPopupOpen = false
        }
        wallpaperSelectorOpen = next
    }

    function toggleMediaPopup() {
        const next = !mediaPopupOpen
        if (next) {
            launcherOpen = false
            dashboardOpen = false
            settingsOpen = false
            notificationsOpen = false
            calendarOpen = false
            sessionOpen = false
            wallpaperSelectorOpen = false
        }
        mediaPopupOpen = next
        if (next) refreshMedia()
    }

    property bool lockClosing: false

    function lockScreen() {
        launcherOpen = false
        dashboardOpen = false
        settingsOpen = false
        notificationsOpen = false
        calendarOpen = false
        sessionOpen = false
        wallpaperSelectorOpen = false
        mediaPopupOpen = false
        lockClosing = false
        lockOpen = true
    }

    function unlockScreen() {
        if (lockOpen && !lockClosing) {
            lockClosing = true
        }
    }

    // state osd volume dan kecerahan layar
    property bool osdVisible: false
    property string osdLabel: "VOLUME"
    property int osdValue: 65
    property bool osdMuted: false
    property bool volumeMuted: false
    property int brightnessPct: 50

    // palet warna aktif dan tema default
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

    Behavior on primary { ColorAnimation { duration: 650; easing.type: Easing.OutCubic } }
    Behavior on secondary { ColorAnimation { duration: 650; easing.type: Easing.OutCubic } }
    Behavior on accent { ColorAnimation { duration: 650; easing.type: Easing.OutCubic } }
    Behavior on background { ColorAnimation { duration: 650; easing.type: Easing.OutCubic } }
    Behavior on surface { ColorAnimation { duration: 650; easing.type: Easing.OutCubic } }
    Behavior on surfaceAlt { ColorAnimation { duration: 650; easing.type: Easing.OutCubic } }
    Behavior on foreground { ColorAnimation { duration: 650; easing.type: Easing.OutCubic } }
    Behavior on muted { ColorAnimation { duration: 650; easing.type: Easing.OutCubic } }
    Behavior on borderLight { ColorAnimation { duration: 650; easing.type: Easing.OutCubic } }
    Behavior on borderDark { ColorAnimation { duration: 650; easing.type: Easing.OutCubic } }

    readonly property var presets: ({
        "p5-crimson": {
            name: "P5 Phantom Crimson",
            id: "p5-crimson",
            wallpaper: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper.png",
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
            wallpaper: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-p3-reload.png",
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
            wallpaper: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-p4-golden.png",
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
            wallpaper: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-kasumi-violet.png",
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
            wallpaper: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-akechi-crow.png",
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
            wallpaper: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-futaba-matrix.png",
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
            wallpaper: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-monochrome.png",
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
            wallpaper: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-expressive.png",
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
            wallpaper: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-tonal-spot.png",
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

    // konfigurasi bentuk poligon dan kemiringan
    property bool polygonMode: true
    property real skewAngle: -10
    property int cornerRadius: 14

    // opsi tata letak dan visibilitas komponen bar
    property string barPosition: "top"
    property string barStyle: "p5-skew"
    property string groupStyle: "pills"
    property bool barShowBackground: false
    property bool barAutoHide: false
    property bool showWeatherHud: true
    property bool showWorkspaces: true
    property bool showDynamicIsland: true
    property bool showMediaPill: true
    property bool showThemePill: true
    property bool showImPill: true
    property bool showStatsPill: true
    property bool showUnreadCount: true

    // opsi indikator workspace
    property int workspaceCount: 6
    property string workspaceNumStyle: "arabic"

    // opsi tombol utilitas bar
    property bool showUtilButtons: true
    property bool showUtilSnip: true
    property bool showUtilPicker: true
    property bool showUtilMic: false
    property bool showUtilDark: false

    // opsi bingkai tepi layar
    property bool screenFrame: false
    property string screenRoundCorner: "no"
    property int frameThickness: 2

    // konfigurasi logo dan daftar wallpaper
    readonly property string logoPath: themeId === "p5-crimson"
        ? Qt.resolvedUrl("../assets/pshell.png")
        : Qt.resolvedUrl("../assets/pshell-" + themeId + ".png")
    readonly property string defaultWallpaperPath: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper.png"
    property bool showWallpaperLayer: true
    property bool wallpaperParallax: true
    property int wallpaperZoom: 104
    property string wallpaperPath: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper.png"
    readonly property var availableWallpapers: [
        "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper.png",
        "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-p3-reload.png",
        "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-p4-golden.png",
        "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-kasumi-violet.png",
        "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-akechi-crow.png",
        "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-futaba-matrix.png",
        "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-monochrome.png",
        "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-expressive.png",
        "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper-tonal-spot.png",
        "/home/sho/Pictures/Wallpapers/goremagala_iceshard.jpg",
        "/home/sho/Pictures/Wallpapers/1409986.png",
        "/home/sho/Pictures/Wallpapers/wallhaven-0q3yqq.jpg",
        "/home/sho/Pictures/Wallpapers/wallhaven-28z766.png",
        "/home/sho/Pictures/Wallpapers/wallhaven-6d9o96.png",
        "/home/sho/Pictures/Wallpapers/wallhaven-72m78v.png",
        "/home/sho/Pictures/Wallpapers/wallhaven-l3g222.png",
        "/home/sho/Pictures/Wallpapers/wallhaven-j3vvdw.png"
    ]

    function setWallpaper(newPath) {
        if (!newPath) return
        wallpaperSelectorOpen = false
        if (newPath !== wallpaperPath) {
            previousWallpaperPath = wallpaperPath
            wallpaperPath = newPath
        }
        transitionTitle = "WALLPAPER SHIFT"
        transitionSub = newPath.split("/").pop().toUpperCase()
        transitionTick++
        Quickshell.execDetached(["sh", "-c", "swww img '" + newPath + "' --transition-type grow --transition-duration 1.1 --transition-fps 60 2>/dev/null || true"])
        saveState()
        playSfx("select")
    }

    function cycleWallpaper() {
        var idx = availableWallpapers.indexOf(wallpaperPath)
        var nextIdx = (idx + 1) % availableWallpapers.length
        setWallpaper(availableWallpapers[nextIdx])
    }

    // konfigurasi widget jam desktop, visualizer cava, dan lirik
    property bool showDesktopClock: true
    property string desktopClockStyle: "p5-editorial"
    property string desktopClockPosition: "top-left"
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

    // opsi grafik statistik dan efek suara notifikasi
    property string statsStyle: "pentagon"
    property bool dndEnabled: false
    property bool sfxEnabled: true
    property real sfxVolume: 0.7

    // parameter live tuning hyprland
    property int hyprGapsIn: 5
    property int hyprGapsOut: 10
    property int hyprBorderSize: 2
    property int hyprRounding: 10
    property bool hyprBlurEnabled: true
    property int hyprBlurSize: 6
    property int hyprBlurPasses: 2
    property bool hyprAnimationsEnabled: true

    // konfigurasi layar monitor dan mode proyektor
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
    property int displayTransform: 0
    property int displayScalePct: 100
    property int displayPosX: 0
    property int displayPosY: 0
    property string displayMirrorOf: "none"
    property string presentationMode: "extend"

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

        // daftar mode fallback saat berjalan di sesi nested wayland
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

        // pilih mode resolusi dan refresh rate tertinggi sebagai default
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

    // state panel wifi & bluetooth interaktif (nmcli & bluetoothctl)
    property string wifiSsid: "Scanning..."
    property string wifiIp: "127.0.0.1"
    property string wifiSecurity: "WPA2"
    property int wifiSignal: 100
    property bool wifiScanning: false
    property string wifiStatusMsg: ""
    property var wifiNetworks: []

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

    // informasi spesifikasi sistem dan perangkat keras
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
        wifiListProc.running = true
        btListProc.running = true
    }

    // server notifikasi dan antrean riwayat pesan
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

    function applyDefaultCursor() {
        Quickshell.execDetached([
            "bash", "-c",
            "hyprctl setcursor Persona5-Animated 24 2>/dev/null; " +
            "gsettings set org.gnome.desktop.interface cursor-theme 'Persona5-Animated' 2>/dev/null; " +
            "gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true"
        ])
    }


    // sinkronisasi preset tema, wallpaper bawaan, dan warna border hyprland
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

            if (p.wallpaper && p.wallpaper !== wallpaperPath) {
                previousWallpaperPath = wallpaperPath
                wallpaperPath = p.wallpaper
                Quickshell.execDetached(["sh", "-c", "swww img '" + p.wallpaper + "' --transition-type grow --transition-duration 1.1 --transition-fps 60 2>/dev/null || true"])
            }

            transitionTitle = p.name.toUpperCase()
            transitionSub = "METAVERSE PALETTE & WALLPAPER SYNCHRONIZED"
            transitionTick++

            const cleanHex = String(p.primary).replace("#", "")
            Quickshell.execDetached(["hyprctl", "keyword", "general:col.active_border", "rgba(" + cleanHex + "ff)"])
            saveState()
            playSfx("select")
        }
    }

    // pelacak daftar jendela aplikasi aktif pada tiap workspace
    property var workspaceApps: ({})

    function resolveAppIconUrl(cls) {
        if (!cls) return ""
        const c = String(cls).toLowerCase().trim()
        const candidates = [c]
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
        else if (c.indexOf("steam") !== -1) candidates.push("steam")
        else if (c.indexOf("telegram") !== -1) candidates.push("telegram", "org.telegram.desktop")
        else if (c.indexOf("mpv") !== -1) candidates.push("mpv")
        else if (c.indexOf("vlc") !== -1) candidates.push("vlc")

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

    function refreshWorkspaces() {
        wsClientsProc.running = false
        wsClientsProc.running = true
    }

    Process {
        id: wsClientsProc
        command: ["hyprctl", "clients", "-j"]
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
                        const wsId = win.workspace ? win.workspace.id : 0
                        if (!wsId || wsId <= 0) continue
                        const cls = String(win.class || win.initialClass || "").trim()
                        if (!cls) continue
                        const key = String(wsId)
                        if (!map[key]) map[key] = []
                        if (map[key].length < 4) {
                            map[key].push({
                                cls: cls,
                                title: String(win.title || cls),
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
        running: root.showWorkspaces
        repeat: true
        triggeredOnStart: true
        onTriggered: wsClientsProc.running = true
    }

    // pengendali media player mpris dengan prioritas spotify
    property bool mediaAvailable: false
    property bool mediaPlaying: false
    property string mediaPlayerName: "SPOTIFY"
    property string mediaTitle: "No Track Playing"
    property string mediaArtist: "Open Spotify or play media"
    property string mediaAlbum: ""
    property string mediaArtUrl: ""
    property real mediaPositionSec: 0
    property real mediaLengthSec: 0
    property string mediaShuffle: "Off"
    property string mediaLoop: "None"

    function formatMediaTime(sec) {
        const s = Math.max(0, Math.floor(Number(sec) || 0))
        const m = Math.floor(s / 60)
        const r = s % 60
        return (m < 10 ? "0" + m : String(m)) + ":" + (r < 10 ? "0" + r : String(r))
    }

    function refreshMedia() {
        mediaProc.running = false
        mediaProc.running = true
    }

    function mediaPlayPause() {
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any play-pause 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    function mediaNext() {
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any next 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    function mediaPrev() {
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any previous 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    function mediaSeek(ratio) {
        if (root.mediaLengthSec <= 0) return
        const targetSec = Math.max(0, Math.min(root.mediaLengthSec, ratio * root.mediaLengthSec))
        root.mediaPositionSec = targetSec
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any position " + targetSec.toFixed(1) + " 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    function mediaToggleShuffle() {
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any shuffle Toggle 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    function mediaToggleLoop() {
        const nextLoop = root.mediaLoop === "None" ? "Playlist" : (root.mediaLoop === "Playlist" ? "Track" : "None")
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any loop " + nextLoop + " 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    Timer {
        id: mediaRefreshDelay
        interval: 220
        repeat: false
        onTriggered: root.refreshMedia()
    }

    Process {
        id: mediaProc
        command: [
            "bash", "-c",
            "playerctl -p spotify,%any metadata --format '{{playerName}}|{{status}}|{{artist}}|{{title}}|{{album}}|{{mpris:artUrl}}|{{position}}|{{mpris:length}}|{{shuffle}}|{{loop}}' 2>/dev/null | head -n 1 || echo 'NONE'"
        ]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const line = String(data).trim()
                if (!line || line === "NONE" || line.indexOf("|") === -1) {
                    root.mediaAvailable = false
                    root.mediaPlaying = false
                    return
                }
                const p = line.split("|")
                root.mediaAvailable = true
                root.mediaPlayerName = (p[0] || "MEDIA").toUpperCase()
                root.mediaPlaying = (p[1] === "Playing")
                root.mediaArtist = p[2] || "Unknown Artist"
                root.mediaTitle = p[3] || "Unknown Track"
                root.mediaAlbum = p[4] || ""
                root.mediaArtUrl = p[5] || ""
                root.mediaPositionSec = (Number(p[6]) || 0) / 1000000.0
                root.mediaLengthSec = (Number(p[7]) || 0) / 1000000.0
                root.mediaShuffle = p[8] || "Off"
                root.mediaLoop = p[9] || "None"
            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: mediaProc.running = true
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
        if (label === "VOLUME") {
            volumePct = osdValue
            osdMuted = volumeMuted || (osdValue === 0)
        } else {
            brightnessPct = osdValue
            osdMuted = false
        }
        osdVisible = true
        osdHideTimer.restart()
    }

    function setSystemVolume(pct) {
        const clamped = Math.max(0, Math.min(150, Math.round(Number(pct) || 0)))
        volumePct = clamped
        volumeMuted = (clamped === 0)
        Quickshell.execDetached(["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 2>/dev/null; wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ " + clamped + "% 2>/dev/null || true"])
        triggerOsd("VOLUME", clamped)
    }

    function toggleSystemMute() {
        Quickshell.execDetached(["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 2>/dev/null || true"])
    }

    function setSystemBrightness(pct) {
        const clamped = Math.max(1, Math.min(100, Math.round(Number(pct) || 50)))
        brightnessPct = clamped
        Quickshell.execDetached(["bash", "-c", "brightnessctl set " + clamped + "% >/dev/null 2>&1 || true"])
        triggerOsd("BRIGHTNESS", clamped)
    }

    // pemantau perubahan volume audio dan kecerahan layar secara otomatis
    Process {
        id: osdWatcherProc
        running: true
        command: [
            "bash", "-c",
            "prev_v=\"\"; prev_b=\"\"; " +
            "while true; do " +
            "  v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null); " +
            "  b=$(brightnessctl -m 2>/dev/null | cut -d',' -f4 | tr -dc '0-9'); " +
            "  if [ -n \"$v\" ] && [ \"$v\" != \"$prev_v\" ]; then " +
            "    if [ -n \"$prev_v\" ]; then echo \"VOL|$v\"; else echo \"INIT_VOL|$v\"; fi; " +
            "    prev_v=\"$v\"; " +
            "  fi; " +
            "  if [ -n \"$b\" ] && [ \"$b\" != \"$prev_b\" ]; then " +
            "    if [ -n \"$prev_b\" ]; then echo \"BRI|$b\"; else echo \"INIT_BRI|$b\"; fi; " +
            "    prev_b=\"$b\"; " +
            "  fi; " +
            "  sleep 0.16; " +
            "done"
        ]
        stdout: SplitParser {
            onRead: data => {
                const line = String(data).trim()
                if (!line) return
                if (line.indexOf("INIT_VOL|") === 0 || line.indexOf("VOL|") === 0) {
                    const isInit = line.indexOf("INIT_") === 0
                    const raw = line.slice(isInit ? 9 : 4)
                    const muted = raw.indexOf("MUTED") !== -1
                    const numMatch = raw.match(/([0-9]+(?:\.[0-9]+)?)/)
                    const pct = numMatch ? Math.round( parseFloat(numMatch[1]) * 100 ) : root.volumePct
                    root.volumeMuted = muted
                    root.volumePct = pct
                    root.osdMuted = muted || (pct === 0)
                    if (!isInit) {
                        root.triggerOsd("VOLUME", pct)
                    }
                } else if (line.indexOf("INIT_BRI|") === 0 || line.indexOf("BRI|") === 0) {
                    const isInit = line.indexOf("INIT_") === 0
                    const pct = parseInt(line.slice(isInit ? 9 : 4), 10)
                    if (!isNaN(pct)) {
                        root.brightnessPct = pct
                        if (!isInit) {
                            root.osdMuted = false
                            root.triggerOsd("BRIGHTNESS", pct)
                        }
                    }
                }
            }
        }
        onExited: osdWatcherRestart.restart()
    }

    Timer {
        id: osdWatcherRestart
        interval: 1500
        repeat: false
        onTriggered: osdWatcherProc.running = true
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

    // state updater & sync phantomshell — terintegrasi sama phantom-sync
    readonly property string syncScriptPath: {
        const base = Qt.resolvedUrl("../../../scripts/phantom-sync").toString().replace("file://", "")
        return base
    }

    property string syncStatus: "IDLE"
    property string syncLog: ""
    property var syncLogLines: []
    property string gitBranch: "main"
    property string gitLocalHash: "-------"
    property string gitRemoteHash: "-------"
    property int gitAhead: 0
    property int gitBehind: 0
    property string gitLastMsg: "Loading..."
    property string gitLastDate: ""
    property bool syncUpdateAvailable: false
    property bool syncBusy: false

    function appendSyncLog(line) {
        const lines = root.syncLogLines.slice()
        lines.push(line)
        if (lines.length > 60) lines.splice(0, lines.length - 60)
        root.syncLogLines = lines
        root.syncLog = lines.join("\n")
    }

    function clearSyncLog() {
        root.syncLogLines = []
        root.syncLog = ""
    }

    // proses cek status git lokal
    Process {
        id: syncStatusProc
        command: [root.syncScriptPath, "status"]
        stdout: SplitParser {
            onRead: data => {
                const line = String(data).trim()
                if (!line) return
                if (line.indexOf("STATUS|") === 0) {
                    const p = line.split("|")
                    if (p.length >= 6) {
                        root.gitBranch = p[1] || "main"
                        root.gitLocalHash = p[2] || "-------"
                        root.gitLastMsg = p[4] || ""
                        root.gitLastDate = p[5] || ""
                    }
                }
            }
        }
    }

    // proses cek update dari remote github
    Process {
        id: syncCheckProc
        command: [root.syncScriptPath, "check-remote"]
        stdout: SplitParser {
            onRead: data => {
                const line = String(data).trim()
                if (!line) return
                if (line.indexOf("REMOTE_CHECK|") === 0) {
                    const p = line.split("|")
                    if (p.length >= 8) {
                        root.gitBranch = p[1] || "main"
                        root.gitLocalHash = p[2] || "-------"
                        root.gitRemoteHash = p[3] || "-------"
                        root.gitAhead = parseInt(p[4], 10) || 0
                        root.gitBehind = parseInt(p[5], 10) || 0
                        root.gitLastMsg = p[6] || ""
                        root.gitLastDate = p[7] || ""
                        root.syncUpdateAvailable = root.gitBehind > 0
                        root.syncStatus = root.gitBehind > 0
                            ? "UPDATE_AVAILABLE"
                            : (root.gitAhead > 0 ? "AHEAD" : "UP_TO_DATE")
                    }
                } else if (line.indexOf("ERR|") === 0) {
                    root.syncStatus = "OFFLINE"
                    root.appendSyncLog("✗ " + line.slice(4))
                }
                root.syncBusy = false
            }
        }
        onExited: root.syncBusy = false
    }

    // proses pull + sync + reload lengkap
    Process {
        id: syncPullSyncProc
        command: [root.syncScriptPath, "pull-sync"]
        stdout: SplitParser {
            onRead: data => {
                const line = String(data).trim()
                if (!line) return
                if (line.indexOf("PULL_START|") === 0) {
                    root.syncStatus = "PULLING"
                    root.appendSyncLog("↓ " + line.slice(11))
                } else if (line.indexOf("PULL_LOG|") === 0) {
                    root.appendSyncLog("  " + line.slice(9))
                } else if (line.indexOf("PULL_DONE|") === 0) {
                    const p = line.split("|")
                    const kind = p[1] || ""
                    const msg = p[2] || ""
                    if (kind === "UPDATED") {
                        root.syncStatus = "SYNCING"
                        root.appendSyncLog("✓ " + msg)
                    } else {
                        root.appendSyncLog("✓ " + msg)
                    }
                } else if (line.indexOf("SYNC_START|") === 0) {
                    root.syncStatus = "SYNCING"
                    root.appendSyncLog("↗ " + line.slice(11))
                } else if (line.indexOf("SYNC_LOG|") === 0) {
                    root.appendSyncLog("  " + line.slice(9))
                } else if (line.indexOf("SYNC_OK|") === 0) {
                    root.appendSyncLog("✓ synced " + line.slice(8))
                } else if (line.indexOf("SYNC_WARN|") === 0) {
                    root.appendSyncLog("⚠ " + line.slice(10))
                } else if (line.indexOf("SYNC_DONE|") === 0) {
                    root.syncStatus = "RELOADING"
                    root.appendSyncLog("✓ " + line.slice(10))
                } else if (line.indexOf("RELOAD_START|") === 0) {
                    root.appendSyncLog("↺ " + line.slice(13))
                } else if (line.indexOf("RELOAD_DONE|") === 0) {
                    root.syncStatus = "DONE"
                    root.syncUpdateAvailable = false
                    root.appendSyncLog("★ " + line.slice(12))
                    syncDoneTimer.restart()
                } else if (line.indexOf("ERR|") === 0) {
                    root.syncStatus = "ERROR"
                    root.appendSyncLog("✗ " + line.slice(4))
                    syncDoneTimer.restart()
                }
            }
        }
        onExited: {
            root.syncBusy = false
            if (root.syncStatus !== "DONE" && root.syncStatus !== "ERROR") {
                root.syncStatus = "DONE"
                syncDoneTimer.restart()
            }
            // refresh status hash setelah selesai
            syncStatusProc.running = false
            syncStatusProc.running = true
        }
    }

    // proses sync saja (tanpa pull), buat "apply ke sistem" lokal
    Process {
        id: syncOnlyProc
        command: [root.syncScriptPath, "sync"]
        stdout: SplitParser {
            onRead: data => {
                const line = String(data).trim()
                if (!line) return
                if (line.indexOf("SYNC_START|") === 0) {
                    root.syncStatus = "SYNCING"
                    root.appendSyncLog("↗ " + line.slice(11))
                } else if (line.indexOf("SYNC_LOG|") === 0) {
                    root.appendSyncLog("  " + line.slice(9))
                } else if (line.indexOf("SYNC_OK|") === 0) {
                    root.appendSyncLog("✓ synced " + line.slice(8))
                } else if (line.indexOf("SYNC_WARN|") === 0) {
                    root.appendSyncLog("⚠ " + line.slice(10))
                } else if (line.indexOf("SYNC_DONE|") === 0) {
                    root.syncStatus = "DONE"
                    root.appendSyncLog("★ " + line.slice(10))
                    syncDoneTimer.restart()
                } else if (line.indexOf("ERR|") === 0) {
                    root.syncStatus = "ERROR"
                    root.appendSyncLog("✗ " + line.slice(4))
                    syncDoneTimer.restart()
                }
            }
        }
        onExited: {
            root.syncBusy = false
            if (root.syncStatus !== "DONE" && root.syncStatus !== "ERROR") {
                root.syncStatus = "DONE"
                syncDoneTimer.restart()
            }
        }
    }

    Timer {
        id: syncDoneTimer
        interval: 4000
        repeat: false
        onTriggered: {
            if (root.syncStatus === "DONE" || root.syncStatus === "ERROR") {
                root.syncStatus = "IDLE"
            }
        }
    }

    function checkSyncUpdate() {
        if (root.syncBusy) return
        root.syncBusy = true
        root.syncStatus = "CHECKING"
        root.clearSyncLog()
        root.appendSyncLog("★ Checking remote origin/main...")
        syncCheckProc.running = false
        syncCheckProc.running = true
    }

    function syncToSystem() {
        if (root.syncBusy) return
        root.syncBusy = true
        root.clearSyncLog()
        root.appendSyncLog("★ Applying local dev changes to system config...")
        syncOnlyProc.running = false
        syncOnlyProc.running = true
    }

    function pullAndSync() {
        if (root.syncBusy) return
        root.syncBusy = true
        root.clearSyncLog()
        root.appendSyncLog("★ Initiating full phantom sync operation...")
        syncPullSyncProc.running = false
        syncPullSyncProc.running = true
    }

    // auto-cek status git saat shell start
    Component.onCompleted: {
        applyDefaultCursor()
        refreshSystemDossier()
        refreshWorkspaces()
        refreshMedia()
        syncStatusProc.running = true
    }
}
