-- daftar shortcut keyboard & mouse hyprland
-- variabel mod otomatis berisi "SUPER" di session utama dan "ALT" di nested window

local mod = Phantom.mod
local qsCall = "qs -p " .. Phantom.qsDir .. " ipc call phantom "
local cli = Phantom.cli

-- buka app launcher (tekan tombol SUPER atau mod + D)
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

-- shortcut buka panel phantomshell (control center, settings, notifikasi, lock screen, power menu)
-- ganti huruf setelah mod .. " + " kalau mau ubah kombinasi tombol
hl.bind(mod .. " + N", hl.dsp.exec_cmd(qsCall .. "toggleDashboard"), {
    description = "Phantomshell: Toggle Control Center & Pentagon Stats"
})
hl.bind(mod .. " + I", hl.dsp.exec_cmd(qsCall .. "toggleSettings"), {
    description = "Phantomshell: Toggle Unified Settings GUI"
})
hl.bind(mod .. " + M", hl.dsp.exec_cmd(qsCall .. "toggleNotifications"), {
    description = "Phantomshell: Toggle SNS Phone Notification Center"
})
hl.bind(mod .. " + B", hl.dsp.exec_cmd(cli .. " notify-test"), {
    description = "Phantomshell: Trigger P5 IM Chat Bubble Notification"
})
hl.bind(mod .. " + P", hl.dsp.exec_cmd(qsCall .. "toggleLock"), {
    description = "Phantomshell: Lock Screen (Calling Card Lock)"
})
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd(qsCall .. "toggleLock"), {
    description = "Phantomshell: Lock Screen (Calling Card Lock)"
})
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd(qsCall .. "toggleSession"), {
    description = "Phantomshell: Toggle Calling Card Power Menu"
})

-- buka terminal & kontrol window aktif
-- ganti "kitty" di bawah ke "ghostty" atau terminal favorit lu
hl.bind(mod .. " + Return", hl.dsp.exec_cmd("kitty"), {
    description = "App: Launch Kitty Terminal"
})
hl.bind(mod .. " + Q", hl.dsp.window.close(), {
    description = "Window: Close active window"
})
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), {
    description = "Window: Toggle fullscreen"
})
hl.bind(mod .. " + Space", hl.dsp.window.float({ action = "toggle" }), {
    description = "Window: Toggle floating"
})
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("hyprctl dispatch exit"), {
    description = "Session: Exit Hyprland"
})

-- pindah fokus & geser posisi window pakai tombol panah atau vim (HJKL)
local dirs = {
    { key = "Left",  vim = "H", dir = "l" },
    { key = "Right", vim = "L", dir = "r" },
    { key = "Up",    vim = "K", dir = "u" },
    { key = "Down",  vim = "J", dir = "d" },
}
for _, d in ipairs(dirs) do
    hl.bind(mod .. " + " .. d.key, hl.dsp.focus({ direction = d.dir }))
    hl.bind(mod .. " + " .. d.vim, hl.dsp.focus({ direction = d.dir }))
    hl.bind(mod .. " + SHIFT + " .. d.key, hl.dsp.window.move({ direction = d.dir }))
end

-- geser & resize window pakai klik kiri/kanan mouse sambil tahan tombol mod
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- pindah workspace 1-10 & lempar window ke workspace lain
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mod .. " + " .. key, function()
        hl.dispatch(hl.dsp.focus({ workspace = i }))
    end, { description = "Workspace: Switch to " .. i })

    hl.bind(mod .. " + SHIFT + " .. key, function()
        hl.dispatch(hl.dsp.window.move({ workspace = i, follow = true }))
    end, { description = "Workspace: Move window to " .. i })
end

-- tombol multimedia volume & kecerahan layar (otomatis munculin osd phantomshell)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(cli .. " osd volume up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(cli .. " osd volume down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(cli .. " osd volume mute"), { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd(cli .. " osd brightness up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd(cli .. " osd brightness down"), { locked = true, repeating = true })
