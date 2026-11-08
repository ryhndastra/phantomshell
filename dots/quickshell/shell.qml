//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import qs.config
import qs.modules.background
import qs.modules.frame
import qs.modules.bar
import qs.modules.launcher
import qs.modules.notifications
import qs.modules.osd
import qs.modules.dashboard
import qs.modules.session
import qs.modules.lock
import qs.modules.overlays

// titik masuk utama seluruh modul phantomshell
ShellRoot {
    id: root

    // modul latar belakang wallpaper, jam desktop, cuaca, cava, dan lirik
    PhantomBackground {}

    // modul bingkai tepi layar
    ScreenFrame {}

    // modul bar status utama dan dynamic island
    PhantomBar {}

    // modul pencari aplikasi dan perintah cepat
    PhantomLauncher {}

    // modul popup balon notifikasi dan riwayat pesan
    PhantomNotifications {}

    // modul indikator volume dan kecerahan layar
    PhantomOsd {}

    // modul pusat kontrol dan grafik statistik sistem
    PhantomDashboard {}


    // modul menu daya dan sesi pengguna
    PhantomSession {}

    // modul pemilih wallpaper galeri
    PhantomWallpaperSelector {}

    // modul overlay taktis keybind, clipboard, emoji, dan ikhtisar workspace
    PhantomCheatsheet {}
    PhantomClipboard {}
    PhantomEmoji {}
    PhantomOverview {}

    // modul pengunci layar sesi wayland
    PhantomLock {}

    // antarmuka ipc untuk pemanggilan fungsi dari skrip atau keybind
    IpcHandler {
        target: "phantom"

        function toggleLauncher(): void {
            PhantomState.toggleLauncher()
        }

        function toggleDashboard(): void {
            PhantomState.toggleDashboard()
        }

        function toggleP3Menu(): void {
            PhantomState.toggleDashboard()
        }

        function setP3Card(idx: int): void {
            PhantomState.p3MenuCard = idx
        }

        function setP3LauncherTab(tab: string): void {
            PhantomState.p3LauncherTab = tab
            PhantomState.launcherOpen = true
        }

        function openP3ReaderIndex(idx: int): void {
            PhantomState.p3LauncherTab = "mail"
            PhantomState.p3ReaderIndex = -1
            PhantomState.p3ReaderIndex = idx
            PhantomState.launcherOpen = true
        }

        function toggleSettings(): void {
            PhantomState.toggleSettings()
        }

        function setSettingsTab(idx: int): void {
            PhantomState.p3ConfigTab = idx
            if (!PhantomState.sessionOpen) {
                PhantomState.closeAllModals()
                PhantomState.p3SessionSection = "config"
                PhantomState.sessionOpen = true
            } else {
                PhantomState.p3SessionSection = "config"
            }
        }

        function setSettingsScroll(y: real): void {
            PhantomState.settingsScrollY = y
        }

        function addWindowRule(cls: string, ws: string, flt: bool, ctr: bool): void {
            PhantomState.addWindowRule(cls, ws, flt, ctr)
        }

        function addKeybind(k: string, c: string, d: string): void {
            PhantomState.addKeybind(k, c, d)
        }

        function toggleWallpaperSelector(): void {
            PhantomState.toggleWallpaperSelector()
        }

        function setWallpaperSelectorTab(tab: int): void {
            PhantomState.wallpaperSelectorTab = tab
        }

        function openWallpaperSelector(): void {
            if (!PhantomState.wallpaperSelectorOpen) PhantomState.toggleWallpaperSelector()
        }

        function closeWallpaperSelector(): void {
            if (PhantomState.wallpaperSelectorOpen) PhantomState.toggleWallpaperSelector()
        }

        function setWallpaper(path: string): void {
            PhantomState.setWallpaper(path)
        }

        function toggleNotifications(): void {
            PhantomState.toggleNotifications()
        }

        function toggleCalendar(): void {
            PhantomState.toggleCalendar()
        }

        function advanceCalendarDay(delta: int): void {
            PhantomState.calendarDayOffset += delta
        }

        function toggleSession(): void {
            PhantomState.toggleSession()
        }

        function openSession(): void {
            if (!PhantomState.sessionOpen) PhantomState.toggleSession()
        }

        function closeSession(): void {
            if (PhantomState.sessionOpen) PhantomState.toggleSession()
        }

        function setSessionSection(sec: string): void {
            PhantomState.p3SessionSection = sec
        }

        function setStatsTab(tab: int): void {
            PhantomState.p3StatsTab = tab
        }

        function setConfigTab(tab: int): void {
            PhantomState.p3ConfigTab = tab
        }

        function showThemeConfirm(idx: int): void {
            PhantomState.p3ThemeConfirmIdx = idx
            PhantomState.p3ThemeConfirm = true
        }

        function toggleMedia(): void {
            PhantomState.toggleMediaPopup()
        }

        function toggleBar(): void {
            PhantomState.barAutoHide = !PhantomState.barAutoHide
            PhantomState.saveState()
        }

        function toggleDarkMode(): void {
            PhantomState.setDarkMode(!PhantomState.darkMode)
        }

        function cycleTheme(): void {
            PhantomState.cyclePreset()
        }

        function cycleWallpaper(): void {
            PhantomState.cycleWallpaper()
        }

        function toggleCheatsheet(): void {
            PhantomState.toggleCheatsheet()
        }

        function toggleClipboard(): void {
            PhantomState.toggleClipboard()
        }

        function toggleEmoji(): void {
            PhantomState.toggleEmoji()
        }

        function toggleOverview(): void {
            PhantomState.toggleOverview()
        }

        function triggerOsd(label: string, val: int): void {
            PhantomState.triggerOsd(label, val)
        }

        function toggleVelvetRoom(): void {
            PhantomState.toggleVelvetRoom()
        }

        function toggleDesktopTray(): void {
            PhantomState.toggleDesktopTray()
        }

        function toggleTrayPopup(): void {
            PhantomState.toggleTrayPopup()
        }

        function toggleLock(): void {
            if (PhantomState.lockOpen) {
                PhantomState.unlockScreen()
            } else {
                PhantomState.lockScreen()
            }
        }

        function lock(): void {
            PhantomState.lockScreen()
        }

        function setPreset(presetId: string): void {
            PhantomState.applyPreset(presetId)
        }

        function showOsd(label: string, val: string): void {
            PhantomState.triggerOsd(label, Number(val))
        }

        function pushImNotification(sender: string, message: string, urgency: string): void {
            PhantomState.pushImNotification(sender, message, urgency)
        }
    }
}
