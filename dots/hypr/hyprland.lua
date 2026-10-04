-- titik masuk utama konfigurasi hyprland berbasis lua

local base_dots = os.getenv("PHANTOMSHELL_DOTS") or os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local hypr_dir = base_dots .. "/hypr"
package.path = hypr_dir .. "/?.lua;" .. hypr_dir .. "/?/init.lua;" .. package.path

require("lua.settings")
require("lua.env")
require("lua.general")
require("lua.animations")
require("lua.rules")
require("lua.binds")
