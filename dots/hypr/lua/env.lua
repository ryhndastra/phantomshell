-- environment variable & program yang otomatis jalan pas hyprland start
-- tambahin hl.exec_cmd("nama-app") di dalam blok hyprland.start buat autostart aplikasi lain

hl.env("PHANTOMSHELL_DOTS", Phantom.dotsDir)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QUICK_CONTROLS_STYLE", "Basic")

hl.on("hyprland.start", function()
    -- jalankan quickshell phantomshell
    hl.exec_cmd("qs -p " .. Phantom.qsDir)

    -- simpan riwayat clipboard teks & gambar ke cliphist
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
