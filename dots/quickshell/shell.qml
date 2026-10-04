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
import qs.modules.settings
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

    // modul jendela pengaturan sistem
    PhantomSettings {}

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
            PhantomState.dashboardOpen = !PhantomState.dashboardOpen
        }

        function toggleSettings(): void {
            PhantomState.toggleSettings()
        }

        function toggleWallpaperSelector(): void {
            PhantomState.toggleWallpaperSelector()
        }

        function toggleNotifications(): void {
            PhantomState.notificationsOpen = !PhantomState.notificationsOpen
        }

        function toggleCalendar(): void {
            PhantomState.calendarOpen = !PhantomState.calendarOpen
        }

        function toggleSession(): void {
            PhantomState.sessionOpen = !PhantomState.sessionOpen
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
