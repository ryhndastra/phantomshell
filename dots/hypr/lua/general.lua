-- pengaturan monitor, gaps, border, blur, dan input keyboard/touchpad
-- mode = "highrr" otomatis pilih refresh rate tertinggi (misal 144Hz), ganti ke "1920x1080@60" kalau mau kunci manual

hl.monitor({
    output = "",
    mode = "highrr",
    position = "auto",
    scale = 1
})

local s = Phantom.settings
local c = Phantom.colors

hl.config({
    general = {
        gaps_in = s.gapsIn,
        gaps_out = s.gapsOut,
        border_size = s.borderSize,
        col = {
            active_border = Phantom.hexToRgba(c.primary, "ff"),
            inactive_border = Phantom.hexToRgba(c.surface, "aa")
        },
        resize_on_border = true,
        allow_tearing = true,
        layout = "dwindle"
    },
    decoration = {
        rounding = s.rounding,
        active_opacity = 0.96,
        inactive_opacity = 0.90,
        fullscreen_opacity = 1.0,
        blur = {
            enabled = s.blurEnabled,
            size = s.blurSize,
            passes = s.blurPasses,
            new_optimizations = true,
            xray = false,
            popups = true
        },
        shadow = {
            enabled = true,
            range = 18,
            render_power = 4,
            color = "rgba(00000088)"
        }
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = false
    },
    misc = {
        background_color = Phantom.hexToRgba(c.background, "FF"),
        disable_hyprland_logo = true,
        disable_splash_rendering = true
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true
        }
    }
})
