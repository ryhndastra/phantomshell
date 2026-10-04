pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// pusat state global phantomshell yang menghubungkan seluruh layanan modular
Singleton {
    id: root

    // instansiasi layanan modular
    ThemePresets {
        id: themePresets
    }

    DisplayService {
        id: displayService
        onSfxRequested: kind => root.playSfx(kind)
    }

    NetworkService {
        id: networkService
    }

    SystemService {
        id: systemService
        pollWorkspaces: root.showWorkspaces
        pollStats: root.showStatsPill || root.dashboardOpen
    }

    NotificationService {
        id: notificationService
        onSfxRequested: kind => root.playSfx(kind)
    }

    MediaService {
        id: mediaService
    }

    AudioOsdService {
        id: audioOsdService
    }

    UpdaterService {
        id: updaterService
    }

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
    property bool cheatsheetOpen: false
    property bool clipboardOpen: false
    property bool emojiOpen: false
    property bool overviewOpen: false
    property bool lockClosing: false

    // state animasi transisi tema dan wallpaper
    property int transitionTick: 0
    property string transitionTitle: "METAVERSE SHIFT"
    property string transitionSub: "PALETTE SYNCHRONIZED"
    property string previousWallpaperPath: ""

    function closeAllModals() {
        launcherOpen = false
        dashboardOpen = false
        settingsOpen = false
        notificationsOpen = false
        calendarOpen = false
        sessionOpen = false
        wallpaperSelectorOpen = false
        mediaPopupOpen = false
        cheatsheetOpen = false
        clipboardOpen = false
        emojiOpen = false
        overviewOpen = false
    }

    function toggleLauncher() {
        const next = !launcherOpen
        if (next) closeAllModals()
        launcherOpen = next
    }

    function toggleSettings() {
        const next = !settingsOpen
        if (next) closeAllModals()
        settingsOpen = next
    }

    function toggleWallpaperSelector() {
        const next = !wallpaperSelectorOpen
        if (next) closeAllModals()
        wallpaperSelectorOpen = next
    }

    function toggleMediaPopup() {
        const next = !mediaPopupOpen
        if (next) closeAllModals()
        mediaPopupOpen = next
        if (next) refreshMedia()
    }

    function toggleCheatsheet() {
        const next = !cheatsheetOpen
        if (next) closeAllModals()
        cheatsheetOpen = next
    }

    function toggleClipboard() {
        const next = !clipboardOpen
        if (next) closeAllModals()
        clipboardOpen = next
    }

    function toggleEmoji() {
        const next = !emojiOpen
        if (next) closeAllModals()
        emojiOpen = next
    }

    function toggleOverview() {
        const next = !overviewOpen
        if (next) closeAllModals()
        overviewOpen = next
        if (next) refreshWorkspaces()
    }

    function cyclePreset() {
        const order = [
            "p5-crimson",
            "p3-reload",
            "p4-golden",
            "kasumi-violet",
            "akechi-crow",
            "futaba-matrix",
            "monochrome",
            "expressive",
            "tonal-spot"
        ]
        const idx = order.indexOf(root.themeId)
        const nextIdx = (idx + 1) % order.length
        applyPreset(order[nextIdx])
    }

    function lockScreen() {
        closeAllModals()
        lockClosing = false
        lockOpen = true
    }

    function unlockScreen() {
        if (lockOpen && !lockClosing) {
            lockClosing = true
        }
    }

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

    // alias preset tema dan daftar wallpaper
    property alias presets: themePresets.presets
    property alias defaultWallpaperPath: themePresets.defaultWallpaperPath
    property alias availableWallpapers: themePresets.availableWallpapers

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

    // konfigurasi logo dan wallpaper aktif
    readonly property string logoPath: themeId === "p5-crimson"
        ? Qt.resolvedUrl("../assets/pshell.png")
        : Qt.resolvedUrl("../assets/pshell-" + themeId + ".png")
    property bool showWallpaperLayer: true
    property bool wallpaperParallax: true
    property int wallpaperZoom: 104
    property string wallpaperPath: "/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets/pshell-wallpaper.png"

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

    function applyDefaultCursor() {
        Quickshell.execDetached([
            "bash", "-c",
            "hyprctl setcursor Persona5-Animated 24 2>/dev/null; " +
            "gsettings set org.gnome.desktop.interface cursor-theme 'Persona5-Animated' 2>/dev/null; " +
            "gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true"
        ])
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

    // alias dan fungsi layanan audio & osd
    property alias osdVisible: audioOsdService.osdVisible
    property alias osdLabel: audioOsdService.osdLabel
    property alias osdValue: audioOsdService.osdValue
    property alias osdMuted: audioOsdService.osdMuted
    property alias volumePct: audioOsdService.volumePct
    property alias volumeMuted: audioOsdService.volumeMuted
    property alias brightnessPct: audioOsdService.brightnessPct

    function triggerOsd(label, val) { audioOsdService.triggerOsd(label, val) }
    function setSystemVolume(pct) { audioOsdService.setSystemVolume(pct) }
    function toggleSystemMute() { audioOsdService.toggleSystemMute() }
    function setSystemBrightness(pct) { audioOsdService.setSystemBrightness(pct) }

    // alias dan fungsi layanan layar monitor & proyektor
    property alias monitorList: displayService.monitorList
    property alias selectedMonitorIdx: displayService.selectedMonitorIdx
    property alias displayName: displayService.displayName
    property alias displayDesc: displayService.displayDesc
    property alias displayEnabled: displayService.displayEnabled
    property alias displayMode: displayService.displayMode
    property alias displayAvailableModes: displayService.displayAvailableModes
    property alias displayTransform: displayService.displayTransform
    property alias displayScalePct: displayService.displayScalePct
    property alias displayPosX: displayService.displayPosX
    property alias displayPosY: displayService.displayPosY
    property alias displayMirrorOf: displayService.displayMirrorOf
    property alias presentationMode: displayService.presentationMode

    function refreshMonitors() { displayService.refreshMonitors() }
    function loadMonitorIntoState(idx) { displayService.loadMonitorIntoState(idx) }
    function cycleSelectedMonitor() { displayService.cycleSelectedMonitor() }
    function setDisplayMode(modeStr) { displayService.setDisplayMode(modeStr) }
    function cycleDisplayMode() { displayService.cycleDisplayMode() }
    function setDisplayTransform(t) { displayService.setDisplayTransform(t) }
    function applyDisplayConfig() { displayService.applyDisplayConfig() }
    function setPresentationMode(mode) { displayService.setPresentationMode(mode) }

    // alias dan fungsi layanan jaringan wifi & bluetooth
    property alias wifiConnected: networkService.wifiConnected
    property alias wifiSsid: networkService.wifiSsid
    property alias wifiIp: networkService.wifiIp
    property alias wifiSecurity: networkService.wifiSecurity
    property alias wifiSignal: networkService.wifiSignal
    property alias wifiScanning: networkService.wifiScanning
    property alias wifiStatusMsg: networkService.wifiStatusMsg
    property alias wifiNetworks: networkService.wifiNetworks

    property alias btConnected: networkService.btConnected
    property alias btDeviceName: networkService.btDeviceName
    property alias btDeviceMac: networkService.btDeviceMac
    property alias btScanning: networkService.btScanning
    property alias btStatusMsg: networkService.btStatusMsg
    property alias btDevices: networkService.btDevices

    function refreshWifi() { networkService.refreshWifi() }
    function scanWifi() { networkService.scanWifi() }
    function setWifiPower(enable) { networkService.setWifiPower(enable) }
    function connectWifi(ssid, password) { networkService.connectWifi(ssid, password) }
    function disconnectWifi(ssid) { networkService.disconnectWifi(ssid) }

    function refreshBluetooth() { networkService.refreshBluetooth() }
    function scanBluetooth() { networkService.scanBluetooth() }
    function setBluetoothPower(enable) { networkService.setBluetoothPower(enable) }
    function connectBluetooth(mac, name) { networkService.connectBluetooth(mac, name) }
    function disconnectBluetooth(mac, name) { networkService.disconnectBluetooth(mac, name) }

    // alias dan fungsi layanan statistik perangkat keras & ruang kerja
    property alias cpuPct: systemService.cpuPct
    property alias ramPct: systemService.ramPct
    property alias gpuPct: systemService.gpuPct
    property alias diskPct: systemService.diskPct
    property alias tempPct: systemService.tempPct
    property alias batteryPct: systemService.batteryPct

    property alias sysHost: systemService.sysHost
    property alias sysOs: systemService.sysOs
    property alias sysKernel: systemService.sysKernel
    property alias sysCpuModel: systemService.sysCpuModel
    property alias sysGpuModel: systemService.sysGpuModel
    property alias sysRamText: systemService.sysRamText
    property alias sysUptime: systemService.sysUptime

    property alias workspaceApps: systemService.workspaceApps

    function refreshSystemDossier() {
        systemService.refreshSystemInfo()
        networkService.refreshWifi()
        networkService.refreshBluetooth()
    }
    function refreshWorkspaces() { systemService.refreshWorkspaces() }
    function resolveAppIconUrl(cls) { return systemService.resolveAppIconUrl(cls) }
    function resolveAppGlyph(cls) { return systemService.resolveAppGlyph(cls) }

    // alias dan fungsi layanan notifikasi im
    property alias dndEnabled: notificationService.dndEnabled
    property alias imNotifications: notificationService.imNotifications
    property alias imPopupStack: notificationService.imPopupStack
    property alias renTestQuotes: notificationService.renTestQuotes

    function sendTestNotification() { notificationService.sendTestNotification() }
    function pushImNotification(sender, message, urgency, icon) { notificationService.pushImNotification(sender, message, urgency, icon) }
    function dismissPopup(index) { notificationService.dismissPopup(index) }

    // alias dan fungsi layanan pemutar media mpris
    property alias mediaAvailable: mediaService.mediaAvailable
    property alias mediaPlaying: mediaService.mediaPlaying
    property alias mediaPlayerName: mediaService.mediaPlayerName
    property alias mediaTitle: mediaService.mediaTitle
    property alias mediaArtist: mediaService.mediaArtist
    property alias mediaAlbum: mediaService.mediaAlbum
    property alias mediaArtUrl: mediaService.mediaArtUrl
    property alias mediaPositionSec: mediaService.mediaPositionSec
    property alias mediaLengthSec: mediaService.mediaLengthSec
    property alias mediaShuffle: mediaService.mediaShuffle
    property alias mediaLoop: mediaService.mediaLoop

    function formatMediaTime(sec) { return mediaService.formatMediaTime(sec) }
    function refreshMedia() { mediaService.refreshMedia() }
    function mediaPlayPause() { mediaService.mediaPlayPause() }
    function mediaNext() { mediaService.mediaNext() }
    function mediaPrev() { mediaService.mediaPrev() }
    function mediaSeek(ratio) { mediaService.mediaSeek(ratio) }
    function mediaToggleShuffle() { mediaService.mediaToggleShuffle() }
    function mediaToggleLoop() { mediaService.mediaToggleLoop() }

    // alias dan fungsi layanan updater & sinkronisasi git
    property alias syncScriptPath: updaterService.syncScriptPath
    property alias syncStatus: updaterService.syncStatus
    property alias syncLog: updaterService.syncLog
    property alias syncLogLines: updaterService.syncLogLines
    property alias gitBranch: updaterService.gitBranch
    property alias gitLocalHash: updaterService.gitLocalHash
    property alias gitRemoteHash: updaterService.gitRemoteHash
    property alias gitAhead: updaterService.gitAhead
    property alias gitBehind: updaterService.gitBehind
    property alias gitLastMsg: updaterService.gitLastMsg
    property alias gitLastDate: updaterService.gitLastDate
    property alias syncUpdateAvailable: updaterService.syncUpdateAvailable
    property alias syncBusy: updaterService.syncBusy

    function appendSyncLog(line) { updaterService.appendSyncLog(line) }
    function clearSyncLog() { updaterService.clearSyncLog() }
    function checkSyncUpdate() { updaterService.checkSyncUpdate() }
    function syncToSystem() { updaterService.syncToSystem() }
    function pullAndSync() { updaterService.pullAndSync() }

    Component.onCompleted: {
        applyDefaultCursor()
        refreshSystemDossier()
        refreshWorkspaces()
        refreshMedia()
        updaterService.refreshGitStatus()
    }
}
