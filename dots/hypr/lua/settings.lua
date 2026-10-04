-- pemuat pengaturan dan palet warna dari berkas json phantomshell

Phantom = {}

local home = os.getenv("HOME") or ""
local xdg = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
Phantom.dotsDir = os.getenv("PHANTOMSHELL_DOTS") or xdg
Phantom.qsDir = Phantom.dotsDir .. "/quickshell"
Phantom.stateDir = Phantom.dotsDir .. "/phantomshell"
Phantom.cli = (os.getenv("PHANTOMSHELL_DOTS") and (Phantom.dotsDir .. "/../scripts/phantomshell")) or "phantomshell"

-- penentuan tombol modifier utama berdasarkan sesi nested atau sesi utama
Phantom.isNested = (os.getenv("PHANTOMSHELL_NESTED") == "1")
Phantom.mod = Phantom.isNested and "ALT" or "SUPER"

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

local function extract_string(json, key, default)
    if not json then return default end
    local val = json:match('"' .. key .. '"%s*:%s*"([^"]*)"')
    return val or default
end

local function extract_number(json, key, default)
    if not json then return default end
    local val = json:match('"' .. key .. '"%s*:%s*([%-]?%d+%.?%d*)')
    return val and tonumber(val) or default
end

local function extract_bool(json, key, default)
    if not json then return default end
    local val = json:match('"' .. key .. '"%s*:%s*(true|false)')
    if val == "true" then return true end
    if val == "false" then return false end
    return default
end

function Phantom.hexToRgba(hex, alphaHex)
    local clean = (hex or "#E60012"):gsub("#", "")
    return "rgba(" .. clean .. (alphaHex or "ee") .. ")"
end

local settingsRaw = read_file(Phantom.stateDir .. "/settings.json")
local colorsRaw = read_file(Phantom.stateDir .. "/colors.json")

Phantom.settings = {
    gapsIn = extract_number(settingsRaw, "gapsIn", 5),
    gapsOut = extract_number(settingsRaw, "gapsOut", 12),
    borderSize = extract_number(settingsRaw, "borderSize", 2),
    rounding = extract_number(settingsRaw, "rounding", 10),
    blurEnabled = extract_bool(settingsRaw, "blurEnabled", true),
    blurSize = extract_number(settingsRaw, "blurSize", 6),
    blurPasses = extract_number(settingsRaw, "blurPasses", 2),
    animationsEnabled = extract_bool(settingsRaw, "animationsEnabled", true),
}

Phantom.colors = {
    primary = extract_string(colorsRaw, "primary", "#E60012"),
    secondary = extract_string(colorsRaw, "secondary", "#FFD700"),
    accent = extract_string(colorsRaw, "accent", "#FF1E2E"),
    background = extract_string(colorsRaw, "background", "#0B0B0E"),
    surface = extract_string(colorsRaw, "surface", "#141419"),
    foreground = extract_string(colorsRaw, "foreground", "#FFFFFF"),
}

return Phantom
