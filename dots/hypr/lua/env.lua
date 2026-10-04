-- konfigurasi variabel lingkungan dan layanan otomatis saat sesi hyprland dimulai

hl.env("PHANTOMSHELL_DOTS", Phantom.dotsDir)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QUICK_CONTROLS_STYLE", "Basic")
hl.env("XCURSOR_THEME", "Persona5-Animated")
hl.env("XCURSOR_SIZE", "24")

hl.on("hyprland.start", function()
    -- penerapan tema dan ukuran kursor bawaan
    hl.exec_cmd("hyprctl setcursor Persona5-Animated 24")

    -- peluncuran proses utama quickshell phantomshell
    hl.exec_cmd("qs -p " .. Phantom.qsDir)

    -- pencatatan riwayat papan klip teks dan gambar ke cliphist
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
