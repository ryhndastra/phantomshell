-- konfigurasi variabel lingkungan dan layanan otomatis saat sesi hyprland dimulai

hl.env("PHANTOMSHELL_DOTS", Phantom.dotsDir)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("NIXOS_OZONE_WL", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QUICK_CONTROLS_STYLE", "Basic")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("XCURSOR_THEME", "Persona5-Animated")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Persona5-Animated")
hl.env("HYPRCURSOR_SIZE", "24")

hl.on("hyprland.start", function()
    -- penerapan tema dan ukuran kursor bawaan
    hl.exec_cmd("hyprctl setcursor Persona5-Animated 24")

    -- peluncuran proses utama quickshell phantomshell
    hl.exec_cmd("qs -p " .. Phantom.qsDir)

    -- pencatatan riwayat papan klip teks dan gambar ke cliphist
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- layanan autentikasi, audio, dan manajemen sesi khusus sesi utama
    if not Phantom.isNested then
        hl.exec_cmd("swww-daemon 2>/dev/null || awww-daemon 2>/dev/null || true")
        hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
        hl.exec_cmd("hypridle")
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE QT_QPA_PLATFORMTHEME PATH")
        hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE QT_QPA_PLATFORMTHEME PATH")
        hl.exec_cmd("systemctl --user start nixos-fake-graphical-session.target xdg-desktop-portal-hyprland.service xdg-desktop-portal.service")
        hl.exec_cmd("easyeffects --hide-window --service-mode")
    end
end)
