-- titik masuk utama konfigurasi hyprland berbasis lua

local base_dots = os.getenv("PHANTOMSHELL_DOTS") or os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local hypr_dir = base_dots .. "/hypr"
package.path = hypr_dir .. "/?.lua;" .. hypr_dir .. "/?/init.lua;" .. package.path

local modules = {
    "lua.settings",
    "lua.env",
    "lua.general",
    "lua.animations",
    "lua.rules",
    "lua.binds",
}

for _, m in ipairs(modules) do
    package.loaded[m] = nil
    require(m)
end
