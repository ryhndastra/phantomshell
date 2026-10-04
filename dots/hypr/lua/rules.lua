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
