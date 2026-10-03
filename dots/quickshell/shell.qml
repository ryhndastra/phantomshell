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

// daftar modul utama phantomshell
// komen salah satu baris di bawah kalau ada modul yang ga pengen di-load sama sekali
ShellRoot {
    id: root

    // layer wallpaper, jam desktop, cuaca, cava, dan lirik
    PhantomBackground {}

    // bingkai layar opsional (bisa dinyalain lewat menu settings)
    ScreenFrame {}

    // bar utama atas/bawah + workspace + dynamic island
    PhantomBar {}

    // app launcher & command menu (SUPER / ALT+D)
    PhantomLauncher {}

    // popup chat bubble notifikasi & sns log (ALT+M)
    PhantomNotifications {}

    // indikator osd volume & brightness
    PhantomOsd {}

    // control center & radar statistik 5-point star (ALT+N)
    PhantomDashboard {}

    // menu pengaturan velvet room (ALT+I)
    PhantomSettings {}

    // menu power & session calling card (ALT+Escape)
    PhantomSession {}

    // layar kunci wayland + pam auth (SUPER+L / ALT+L)
    PhantomLock {}

    // handler ipc buat dipanggil lewat script phantomshell atau keybind hyprland.lua
    IpcHandler {
        target: "phantom"

        function toggleLauncher(): void {
            PhantomState.launcherOpen = !PhantomState.launcherOpen
        }

        function toggleDashboard(): void {
            PhantomState.dashboardOpen = !PhantomState.dashboardOpen
        }

        function toggleSettings(): void {
            PhantomState.settingsOpen = !PhantomState.settingsOpen
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

        function toggleLock(): void {
            PhantomState.lockScreen()
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
