-- konfigurasi monitor, gestur touchpad, jarak celah jendela, bingkai, efek blur, dan perangkat input

hl.monitor({
    output = "",
    mode = "highrr",
    position = "auto",
    scale = 1
})

local s = Phantom.settings
local c = Phantom.colors
local qsCall = "qs -p " .. Phantom.qsDir .. " ipc call phantom "

-- konfigurasi gestur multi-sentuh touchpad
hl.gesture({
    fingers = 3,
    direction = "swipe",
    action = "move"
})
hl.gesture({
    fingers = 3,
    direction = "pinch",
    action = "fullscreen"
})
hl.gesture({
    fingers = 4,
    direction = "horizontal",
    action = "workspace"
})
hl.gesture({
    fingers = 4,
    direction = "up",
    action = function()
        hl.dispatch(hl.dsp.exec_cmd(qsCall .. "toggleOverview"))
    end
})
hl.gesture({
    fingers = 4,
    direction = "down",
    action = function()
        hl.dispatch(hl.dsp.exec_cmd(qsCall .. "toggleOverview"))
    end
})

hl.config({
    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.2,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true
    },
    general = {
        gaps_in = s.gapsIn,
        gaps_out = s.gapsOut,
        gaps_workspaces = 50,
        border_size = s.borderSize,
        col = {
            active_border = Phantom.hexToRgba(c.primary, "ff"),
            inactive_border = Phantom.hexToRgba(c.surface, "aa")
        },
        resize_on_border = true,
        no_focus_fallback = true,
        allow_tearing = true,
        layout = "dwindle",
        snap = {
            enabled = true,
            window_gap = 4,
            monitor_gap = 5,
            respect_gaps = true
        }
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
        },
        dim_inactive = true,
        dim_strength = 0.05,
        dim_special = 0.2
    },
    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = false
    },
    misc = {
        background_color = Phantom.hexToRgba(c.background, "FF"),
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 0,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = false,
        enable_swallow = false,
        on_focus_under_fullscreen = 2,
        allow_session_lock_restore = true,
        session_lock_xray = true,
        initial_workspace_tracking = false,
        focus_on_activate = true,
        close_special_on_empty = false
    },
    input = {
        kb_layout = "us",
        numlock_by_default = true,
        repeat_delay = 250,
        repeat_rate = 35,
        follow_mouse = 1,
        off_window_axis_events = 2,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor = 0.7
        }
    },
    binds = {
        scroll_event_delay = 0,
        hide_special_on_workspace_change = false
    },
    cursor = {
        zoom_factor = 1,
        zoom_rigid = false,
        zoom_disable_aa = true,
        hotspot_padding = 1
    },
    xwayland = {
        force_zero_scaling = true
    }
})
