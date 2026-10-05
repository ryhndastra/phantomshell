-- konfigurasi pintasan keyboard dan mouse hyprland selaras dengan pengaturan nixos pengguna

local mod = Phantom.mod
local qsCall = "qs -p " .. Phantom.qsDir .. " ipc call phantom "
local cli = Phantom.cli

-- pintasan pembuka aplikasi launcher
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd(qsCall .. "toggleLauncher"), {
    release = true,
    description = "Phantomshell: Toggle P5 Command Launcher (SUPER)"
})
hl.bind("SUPER + SUPER_R", hl.dsp.exec_cmd(qsCall .. "toggleLauncher"), {
    release = true,
    description = "Phantomshell: Toggle P5 Command Launcher (SUPER_R)"
})
hl.bind(mod .. " + D", hl.dsp.exec_cmd(qsCall .. "toggleLauncher"), {
    description = "Phantomshell: Toggle P5 Command Launcher"
})

-- pintasan pembuka panel antarmuka phantomshell
hl.bind(mod .. " + Tab", hl.dsp.exec_cmd(qsCall .. "toggleOverview"), {
    description = "Phantomshell: Toggle Workspace Overview"
})
hl.bind(mod .. " + V", hl.dsp.exec_cmd(qsCall .. "toggleClipboard"), {
    description = "Phantomshell: Toggle Clipboard Compendium"
})
hl.bind(mod .. " + Period", hl.dsp.exec_cmd(qsCall .. "toggleEmoji"), {
    description = "Phantomshell: Toggle Emoji Picker"
})
hl.bind(mod .. " + Slash", hl.dsp.exec_cmd(qsCall .. "toggleCheatsheet"), {
    description = "Phantomshell: Toggle Tactics Keybind Cheatsheet"
})
hl.bind(mod .. " + A", hl.dsp.exec_cmd(qsCall .. "toggleNotifications"), {
    description = "Phantomshell: Toggle SNS Notification Center"
})
hl.bind(mod .. " + B", hl.dsp.exec_cmd(qsCall .. "toggleNotifications"), {
    description = "Phantomshell: Toggle SNS Notification Center"
})
hl.bind(mod .. " + O", hl.dsp.exec_cmd(qsCall .. "toggleNotifications"), {
    description = "Phantomshell: Toggle SNS Notification Center"
})
hl.bind(mod .. " + N", hl.dsp.exec_cmd(qsCall .. "toggleDashboard"), {
    description = "Phantomshell: Toggle Control Center & Pentagon Stats"
})
hl.bind(mod .. " + G", hl.dsp.exec_cmd(qsCall .. "toggleDashboard"), {
    description = "Phantomshell: Toggle Control Center & Pentagon Stats"
})
hl.bind(mod .. " + M", hl.dsp.exec_cmd(qsCall .. "toggleMedia"), {
    description = "Phantomshell: Toggle Media Controls Popup"
})
hl.bind(mod .. " + I", hl.dsp.exec_cmd(qsCall .. "toggleSettings"), {
    description = "Phantomshell: Toggle Velvet Room Settings GUI"
})
hl.bind(mod .. " + J", hl.dsp.exec_cmd(qsCall .. "toggleBar"), {
    description = "Phantomshell: Toggle Top Bar Auto-Hide"
})
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd(qsCall .. "toggleSession"), {
    description = "Phantomshell: Toggle Calling Card Power Menu"
})
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(qsCall .. "toggleSession"), {
    description = "Phantomshell: Toggle Calling Card Power Menu"
})

-- pintasan tema, wallpaper, dan muat ulang cepat shell
hl.bind("CTRL + " .. mod .. " + T", hl.dsp.exec_cmd(qsCall .. "toggleWallpaperSelector"), {
    description = "Phantomshell: Open Wallpaper Selector"
})
hl.bind("CTRL + " .. mod .. " + ALT + T", hl.dsp.exec_cmd(qsCall .. "cycleWallpaper"), {
    description = "Phantomshell: Cycle Next Wallpaper"
})
hl.bind("CTRL + " .. mod .. " + SHIFT + D", hl.dsp.exec_cmd(qsCall .. "toggleDarkMode"), {
    description = "Phantomshell: Toggle Light/Dark Mode"
})
hl.bind("CTRL + " .. mod .. " + P", hl.dsp.exec_cmd(qsCall .. "cycleTheme"), {
    description = "Phantomshell: Cycle Persona Theme Palette"
})
hl.bind("CTRL + " .. mod .. " + R", hl.dsp.exec_cmd(cli .. " restart"), {
    description = "Phantomshell: Restart Quickshell"
})
hl.bind("CTRL + " .. mod .. " + ALT + Slash", hl.dsp.exec_cmd("xdg-open " .. Phantom.dotsDir .. "/hypr/lua/binds.lua"), {
    description = "Phantomshell: Edit Keybinds Config"
})

-- pintasan utilitas tangkapan layar, ocr, pemilih warna, dan perekam layar
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(cli .. " snip"), {
    description = "Utilities: Region Screenshot >> Clipboard & File"
})
hl.bind(mod .. " + SHIFT + X", hl.dsp.exec_cmd(cli .. " ocr"), {
    description = "Utilities: Region OCR Text Recognition >> Clipboard"
})
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd(cli .. " picker"), {
    description = "Utilities: Pick Color #RRGGBB >> Clipboard"
})
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd(cli .. " record region"), {
    locked = true,
    description = "Utilities: Record Region (Toggle)"
})
hl.bind(mod .. " + ALT + R", hl.dsp.exec_cmd(cli .. " record region"), {
    locked = true
})
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd(cli .. " record fullscreen"), {
    locked = true,
    description = "Utilities: Record Fullscreen (No Sound)"
})
hl.bind(mod .. " + SHIFT + ALT + R", hl.dsp.exec_cmd(cli .. " record sound"), {
    locked = true,
    description = "Utilities: Record Fullscreen (With Sound)"
})
hl.bind("Print", hl.dsp.exec_cmd(cli .. " screenshot copy"), {
    locked = true,
    description = "Utilities: Fullscreen Screenshot >> Clipboard"
})
hl.bind("CTRL + Print", hl.dsp.exec_cmd(cli .. " screenshot save"), {
    locked = true,
    description = "Utilities: Fullscreen Screenshot >> Clipboard & File"
})

-- pintasan pembesar layar (cursor zoom)
local function zoom_screen(delta)
    local cur = hl.get_config("cursor:zoom_factor") or 1.0
    local next_val = math.max(1.0, math.min(3.0, cur + delta))
    hl.config({ cursor = { zoom_factor = next_val } })
end
hl.bind(mod .. " + Minus", function() zoom_screen(-0.3) end, {
    repeating = true,
    description = "Screen: Zoom Out"
})
hl.bind(mod .. " + Equal", function() zoom_screen(0.3) end, {
    repeating = true,
    description = "Screen: Zoom In"
})
hl.bind(mod .. " + code:82", function() zoom_screen(-0.3) end, { repeating = true })
hl.bind(mod .. " + code:86", function() zoom_screen(0.3) end, { repeating = true })

-- pintasan tombol multimedia, volume, dan kecerahan layar
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(cli .. " osd volume up 2"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(cli .. " osd volume down 2"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(cli .. " osd volume mute"), { locked = true })
hl.bind(mod .. " + SHIFT + M",  hl.dsp.exec_cmd(cli .. " osd volume mute"), { locked = true, description = "Media: Toggle Audio Mute" })
hl.bind("ALT + XF86AudioMute",  hl.dsp.exec_cmd(cli .. " osd volume micmute"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(cli .. " osd volume micmute"), { locked = true })
hl.bind(mod .. " + ALT + M",    hl.dsp.exec_cmd(cli .. " osd volume micmute"), { locked = true, description = "Media: Toggle Mic Mute" })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd(cli .. " osd brightness up 5"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd(cli .. " osd brightness down 5"), { locked = true, repeating = true })

-- pintasan kontrol pemutar musik mpris
local mediaNextCmd = "playerctl -p spotify,%any next || true"
local mediaPrevCmd = "playerctl -p spotify,%any previous || true"
local mediaPlayCmd = "playerctl -p spotify,%any play-pause || true"
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd(mediaNextCmd), { locked = true, description = "Media: Next Track" })
hl.bind("XF86AudioNext",       hl.dsp.exec_cmd(mediaNextCmd), { locked = true })
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd(mediaPrevCmd), { locked = true, description = "Media: Previous Track" })
hl.bind("XF86AudioPrev",       hl.dsp.exec_cmd(mediaPrevCmd), { locked = true })
hl.bind(mod .. " + SHIFT + P", hl.dsp.exec_cmd(mediaPlayCmd), { locked = true, description = "Media: Play/Pause" })
hl.bind("XF86AudioPlay",       hl.dsp.exec_cmd(mediaPlayCmd), { locked = true })
hl.bind("XF86AudioPause",      hl.dsp.exec_cmd(mediaPlayCmd), { locked = true })
hl.bind(mod .. " + SHIFT + ALT + mouse:275", hl.dsp.exec_cmd(mediaPrevCmd))
hl.bind(mod .. " + SHIFT + ALT + mouse:276", hl.dsp.exec_cmd(mediaNextCmd))

-- pintasan peluncur aplikasi utama
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(cli .. " launch terminal"), { description = "App: Terminal (Kitty)" })
hl.bind(mod .. " + T",      hl.dsp.exec_cmd(cli .. " launch terminal"), { description = "App: Terminal (Kitty)" })
hl.bind("CTRL + ALT + T",   hl.dsp.exec_cmd(cli .. " launch terminal"), { description = "App: Terminal (Kitty)" })
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(cli .. " launch files"),    { description = "App: File Manager" })
hl.bind(mod .. " + W",      hl.dsp.exec_cmd(cli .. " launch browser"),  { description = "App: Web Browser" })
hl.bind(mod .. " + C",      hl.dsp.exec_cmd(cli .. " launch code"),     { description = "App: Code Editor" })
hl.bind(mod .. " + X",      hl.dsp.exec_cmd(cli .. " launch editor"),   { description = "App: Text Editor" })
hl.bind("CTRL + " .. mod .. " + SHIFT + ALT + W", hl.dsp.exec_cmd(cli .. " launch office"), { description = "App: Office Suite" })
hl.bind("CTRL + " .. mod .. " + V", hl.dsp.exec_cmd(cli .. " launch mixer"), { description = "App: Volume Mixer (Pavucontrol)" })
hl.bind("CTRL + SHIFT + Escape",    hl.dsp.exec_cmd(cli .. " launch tasks"), { description = "App: Task Manager" })

-- pintasan sesi kunci layar, tidur, dan matikan daya
hl.bind(mod .. " + L", hl.dsp.exec_cmd(qsCall .. "toggleLock"), {
    description = "Session: Lock Screen (Calling Card Lock)"
})
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"), {
    locked = true,
    description = "Session: Suspend / Sleep"
})
hl.bind("CTRL + SHIFT + ALT + " .. mod .. " + Delete", hl.dsp.exec_cmd("systemctl poweroff || loginctl poweroff"), {
    description = "Session: Power Off"
})
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("hyprctl dispatch exit"), {
    description = "Session: Exit Hyprland"
})

-- pintasan manajemen jendela aktif
hl.bind("ALT + F4", function()
    hl.exec_cmd(cli .. " notify-test 'Morgana' 'Gunakan Super + Q untuk menutup jendela! (Alt+F4 khusus VM)'")
end, { non_consuming = true })
hl.bind(mod .. " + Q", hl.dsp.window.close(), {
    description = "Window: Close Active Window"
})
hl.bind(mod .. " + SHIFT + ALT + Q", hl.dsp.exec_cmd("hyprctl kill"), {
    description = "Window: Force Kill Window (hyprctl kill)"
})
hl.bind(mod .. " + Space", hl.dsp.window.float({ action = "toggle" }), {
    description = "Window: Toggle Float/Tile"
})
hl.bind(mod .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }), {
    description = "Window: Toggle Float/Tile"
})
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), {
    description = "Window: Maximize (Keep Bar & Gaps)"
})
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), {
    description = "Window: Fullscreen"
})
hl.bind(mod .. " + ALT + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 3, action = "toggle" }), {
    description = "Window: Fullscreen Spoof"
})
hl.bind(mod .. " + P", hl.dsp.window.pin(), {
    description = "Window: Pin Floating Window"
})
hl.bind(mod .. " + Semicolon", hl.dsp.layout("splitratio -0.1"), {
    repeating = true,
    description = "Window: Decrease Split Ratio"
})
hl.bind(mod .. " + Apostrophe", hl.dsp.layout("splitratio +0.1"), {
    repeating = true,
    description = "Window: Increase Split Ratio"
})
hl.bind("CTRL + " .. mod .. " + Backslash", hl.dsp.window.resize({ x = 640, y = 480, "exact" }), {
    description = "Window: Resize Exact 640x480"
})

-- pintasan navigasi fokus dan pemindahan jendela dengan arah panah & bracket
local dirs = {
    { key = "Left",  dir = "l" },
    { key = "Right", dir = "r" },
    { key = "Up",    dir = "u" },
    { key = "Down",  dir = "d" },
}
for _, d in ipairs(dirs) do
    hl.bind(mod .. " + " .. d.key, hl.dsp.focus({ direction = d.dir }), {
        description = "Window: Focus " .. d.key
    })
    hl.bind(mod .. " + SHIFT + " .. d.key, hl.dsp.window.move({ direction = d.dir }), {
        description = "Window: Move " .. d.key
    })
end
hl.bind(mod .. " + BracketLeft",  hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + BracketRight", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))

-- pintasan geser dan ubah ukuran jendela menggunakan mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Window: Move (LMB Drag)" })
hl.bind(mod .. " + mouse:274", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize (RMB Drag)" })

-- pintasan perpindahan ruang kerja 1-10 dan pemindahan jendela antar ruang kerja
local numpadcodes = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mod .. " + " .. key, function()
        hl.dispatch(hl.dsp.focus({ workspace = i }))
    end, { description = "Workspace: Focus " .. i })

    hl.bind(mod .. " + code:" .. numpadcodes[i], function()
        hl.dispatch(hl.dsp.focus({ workspace = i }))
    end)

    hl.bind(mod .. " + SHIFT + " .. key, function()
        hl.dispatch(hl.dsp.window.move({ workspace = i, follow = true }))
    end, { description = "Window: Move to Workspace " .. i })

    hl.bind(mod .. " + SHIFT + code:" .. numpadcodes[i], function()
        hl.dispatch(hl.dsp.window.move({ workspace = i, follow = true }))
    end)

    hl.bind(mod .. " + ALT + " .. key, function()
        hl.dispatch(hl.dsp.window.move({ workspace = i, follow = false }))
    end, { description = "Window: Send Silently to Workspace " .. i })

    hl.bind(mod .. " + ALT + code:" .. numpadcodes[i], function()
        hl.dispatch(hl.dsp.window.move({ workspace = i, follow = false }))
    end)
end

-- pintasan navigasi ruang kerja relatif menggunakan keyboard dan scroll mouse
hl.bind("CTRL + " .. mod .. " + Left",  hl.dsp.focus({ workspace = "r-1" }), { description = "Workspace: Focus Left" })
hl.bind("CTRL + " .. mod .. " + Right", hl.dsp.focus({ workspace = "r+1" }), { description = "Workspace: Focus Right" })
hl.bind("CTRL + " .. mod .. " + ALT + Left",  hl.dsp.focus({ workspace = "m-1" }))
hl.bind("CTRL + " .. mod .. " + ALT + Right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("CTRL + " .. mod .. " + BracketLeft",  hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + " .. mod .. " + BracketRight", hl.dsp.focus({ workspace = "+1" }))
hl.bind("CTRL + " .. mod .. " + Up",   hl.dsp.focus({ workspace = "r-5" }))
hl.bind("CTRL + " .. mod .. " + Down", hl.dsp.focus({ workspace = "r+5" }))

hl.bind(mod .. " + Page_Up",          hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mod .. " + Page_Down",        hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + " .. mod .. " + Page_Up",   hl.dsp.focus({ workspace = "r-1" }))
hl.bind("CTRL + " .. mod .. " + Page_Down", hl.dsp.focus({ workspace = "r+1" }))

hl.bind(mod .. " + mouse_up",         hl.dsp.focus({ workspace = "+1" }))
hl.bind(mod .. " + mouse_down",       hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + " .. mod .. " + mouse_up",   hl.dsp.focus({ workspace = "r+1" }))
hl.bind("CTRL + " .. mod .. " + mouse_down", hl.dsp.focus({ workspace = "r-1" }))

-- pintasan kirim jendela ke ruang kerja relatif (kiri/kanan)
hl.bind(mod .. " + SHIFT + Page_Up",   hl.dsp.window.move({ workspace = "r-1" }), { description = "Window: Send to Workspace Left" })
hl.bind(mod .. " + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "r+1" }), { description = "Window: Send to Workspace Right" })
hl.bind(mod .. " + ALT + Page_Up",     hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mod .. " + ALT + Page_Down",   hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("CTRL + " .. mod .. " + SHIFT + Left",  hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("CTRL + " .. mod .. " + SHIFT + Right", hl.dsp.window.move({ workspace = "r+1" }))

hl.bind(mod .. " + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mod .. " + SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mod .. " + ALT + mouse_down",   hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mod .. " + ALT + mouse_up",     hl.dsp.window.move({ workspace = "r+1" }))

-- pintasan scratchpad (special workspace / velvet room)
hl.bind(mod .. " + S",       hl.dsp.exec_cmd(qsCall .. "toggleVelvetRoom"), { description = "Workspace: Toggle Velvet Room (Scratchpad)" })
hl.bind("CTRL + " .. mod .. " + S", hl.dsp.exec_cmd(qsCall .. "toggleVelvetRoom"))
hl.bind(mod .. " + mouse:275", hl.dsp.exec_cmd(qsCall .. "toggleVelvetRoom"))
hl.bind(mod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:special", follow = false }), {
    description = "Window: Send to Scratchpad"
})

-- submap khusus mesin virtual (nonaktifkan sementara pintasan hyprland)
hl.define_submap("virtual-machine", function()
    hl.bind(mod .. " + ALT + F1", function()
        local currentsubmap = hl.get_current_submap()
        if currentsubmap == "virtual-machine" then
            hl.dispatch(hl.dsp.exec_cmd(cli .. " notify-test 'Futaba (Oracle)' 'Keluar dari mode VM — Keybind Hyprland aktif kembali'"))
            hl.dispatch(hl.dsp.submap("reset"))
        elseif currentsubmap == "" then
            hl.dispatch(hl.dsp.exec_cmd(cli .. " notify-test 'Futaba (Oracle)' 'Mode VM aktif — Tekan SUPER+ALT+F1 untuk kembali'"))
            hl.dispatch(hl.dsp.submap("virtual-machine"))
        end
    end, { submap_universal = true })
end)
