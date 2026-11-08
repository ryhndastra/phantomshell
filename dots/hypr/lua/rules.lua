-- aturan tata letak jendela aplikasi dan lapisan permukaan quickshell

hl.window_rule({
    match = { class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol|nm-connection-editor)$" },
    float = true,
    center = true
})

hl.window_rule({
    match = { title = "^(Open File|Select a File|Save As|Open Folder)(.*)$" },
    float = true,
    center = true
})

hl.layer_rule({
    match = { namespace = "phantomshell-.*" },
    no_anim = true
})

-- muat aturan kustom dinamis yang dikonfigurasi dari phantomshell settings gui
local custom_rules = os.getenv("HOME") .. "/.config/hypr/lua/custom_rules.lua"
local f = io.open(custom_rules, "r")
if f then
    f:close()
    pcall(dofile, custom_rules)
end

