#!/usr/bin/env bash
# sinkronisasi otomatis tema persona phantomshell ke vesktop (discord), spotify (spicetify), dan terminal kitty
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DOTS_DIR="$REPO_DIR/dots"

PRIMARY="${1:-#E60012}"
SECONDARY="${2:-#FFD700}"
ACCENT="${3:-#FF1E2E}"
BG="${4:-#0B0B0E}"
SURFACE="${5:-#141419}"
SURFACE_ALT="${6:-#1F1F27}"
FG="${7:-#FFFFFF}"
MUTED="${8:-#9E9EAE}"
BORDER="${9:-#FFFFFF}"
URGENT="${10:-#FF0033}"
SUCCESS="${11:-#00F59B}"

hex_to_rgb() {
    local hex="${1#\#}"
    if [[ ${#hex} -ne 6 ]]; then
        echo "230, 0, 18"
        return
    fi
    printf "%d, %d, %d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

hex_to_rgb_nospace() {
    local hex="${1#\#}"
    if [[ ${#hex} -ne 6 ]]; then
        echo "230,0,18"
        return
    fi
    printf "%d,%d,%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

PRIMARY_RGB="$(hex_to_rgb "$PRIMARY")"
SECONDARY_RGB="$(hex_to_rgb "$SECONDARY")"

PRIMARY_RGB_NS="$(hex_to_rgb_nospace "$PRIMARY")"
SECONDARY_RGB_NS="$(hex_to_rgb_nospace "$SECONDARY")"
BG_RGB_NS="$(hex_to_rgb_nospace "$BG")"
SURFACE_RGB_NS="$(hex_to_rgb_nospace "$SURFACE")"
SURFACE_ALT_RGB_NS="$(hex_to_rgb_nospace "$SURFACE_ALT")"
FG_RGB_NS="$(hex_to_rgb_nospace "$FG")"
MUTED_RGB_NS="$(hex_to_rgb_nospace "$MUTED")"

# 1. sinkronisasi tema vesktop (discord)
VESKTOP_THEME_DIR="$HOME/.config/vesktop/themes"
VESKTOP_SETTINGS_DIR="$HOME/.config/vesktop/settings"
VESKTOP_SETTINGS="$VESKTOP_SETTINGS_DIR/settings.json"
mkdir -p "$VESKTOP_THEME_DIR" "$VESKTOP_SETTINGS_DIR" "$DOTS_DIR/vesktop/themes"

write_vesktop_css() {
    local target="$1"
    cat > "$target" <<EOF
/**
 * @name PhantomShell Persona Metaverse
 * @version 3.0.0
 * @description Tema Discord / Vesktop bergaya Persona 5 Confidant & IM yang tersinkronisasi otomatis dengan PhantomShell.
 * @author PhantomShell
 */

:root,
.theme-dark,
.theme-light,
html.theme-dark,
html.visual-refresh,
body {
    --p5-primary: ${PRIMARY};
    --p5-secondary: ${SECONDARY};
    --p5-accent: ${ACCENT};
    --p5-bg: ${BG};
    --p5-surface: ${SURFACE};
    --p5-surface-alt: ${SURFACE_ALT};
    --p5-fg: ${FG};
    --p5-muted: ${MUTED};
    --p5-border: ${BORDER};
    --p5-urgent: ${URGENT};
    --p5-success: ${SUCCESS};
    --p5-primary-rgb: ${PRIMARY_RGB};
    --p5-secondary-rgb: ${SECONDARY_RGB};

    --background-primary: var(--p5-bg) !important;
    --background-secondary: var(--p5-surface) !important;
    --background-secondary-alt: #08080B !important;
    --background-tertiary: #060609 !important;
    --background-accent: var(--p5-primary) !important;
    --background-floating: var(--p5-surface) !important;
    --background-nested-floating: var(--p5-surface) !important;
    --background-modifier-hover: rgba(var(--p5-primary-rgb), 0.22) !important;
    --background-modifier-active: rgba(var(--p5-primary-rgb), 0.35) !important;
    --background-modifier-selected: var(--p5-primary) !important;
    --background-modifier-accent: rgba(var(--p5-primary-rgb), 0.35) !important;

    --bg-base-primary: var(--p5-bg) !important;
    --bg-base-secondary: var(--p5-surface) !important;
    --bg-base-tertiary: #060609 !important;
    --bg-surface-overlay: var(--p5-surface) !important;
    --bg-surface-raised: var(--p5-surface-alt) !important;
    --bg-overlay-chat: var(--p5-bg) !important;
    --bg-overlay-1: var(--p5-surface) !important;
    --bg-overlay-2: var(--p5-surface) !important;
    --bg-overlay-3: var(--p5-surface-alt) !important;
    --chat-background-default: var(--p5-bg) !important;
    --home-background: var(--p5-bg) !important;
    --custom-channel-members-bg: var(--p5-surface) !important;
    --channeltextarea-background: var(--p5-surface) !important;
    --input-background: var(--p5-surface) !important;

    --brand-experiment: var(--p5-primary) !important;
    --brand-experiment-560: var(--p5-accent) !important;
    --brand-500: var(--p5-primary) !important;
    --brand-560: var(--p5-accent) !important;

    --header-primary: var(--p5-fg) !important;
    --header-secondary: var(--p5-secondary) !important;
    --text-normal: var(--p5-fg) !important;
    --text-muted: var(--p5-muted) !important;
    --text-link: var(--p5-secondary) !important;
    --text-brand: var(--p5-primary) !important;
    --text-positive: var(--p5-success) !important;
    --text-danger: var(--p5-urgent) !important;

    --interactive-normal: var(--p5-fg) !important;
    --interactive-hover: var(--p5-secondary) !important;
    --interactive-active: var(--p5-fg) !important;
    --channels-default: var(--p5-muted) !important;
    --channel-icon: var(--p5-primary) !important;

    --mention-background: rgba(var(--p5-primary-rgb), 0.24) !important;
    --mention-foreground: var(--p5-secondary) !important;
    --status-danger: var(--p5-urgent) !important;
    --status-positive: var(--p5-success) !important;
    --status-warning: var(--p5-secondary) !important;

    --scrollbar-thin-thumb: var(--p5-primary) !important;
    --scrollbar-thin-track: transparent !important;
    --scrollbar-auto-thumb: var(--p5-primary) !important;
    --scrollbar-auto-track: var(--p5-surface) !important;
}

/* latar belakang utama berpola diagonal khas metaverse persona 5 */
[class*="appMount_"],
[class*="app_"],
[class*="bg_"],
[class*="chat_"],
[class*="container_"][class*="themed_"],
[class*="peopleColumn_"],
[class*="nowPlayingColumn_"] [class*="container_"] {
    background-color: var(--p5-bg) !important;
    background-image: repeating-linear-gradient(
        -45deg,
        rgba(var(--p5-primary-rgb), 0.035) 0px,
        rgba(var(--p5-primary-rgb), 0.035) 8px,
        transparent 8px,
        transparent 18px
    ) !important;
}

/* panel sidebar daftar server & dm bergaya komik p5 */
[class*="sidebar_"] {
    background-color: var(--p5-surface) !important;
    border-right: 2px solid var(--p5-primary) !important;
}

[class*="privateChannels_"],
[class*="scroller_"][class*="thin_"] {
    background-color: transparent !important;
}

/* bar atas (friends / channel header) */
[class*="title_"][class*="container_"],
section[class*="container_"][class*="themed_"] {
    background-color: var(--p5-surface) !important;
    border-bottom: 2.5px solid var(--p5-primary) !important;
    box-shadow: 0 3px 0px rgba(0, 0, 0, 0.85) !important;
}

/* tab navigasi atas (Online, All, Pending, Add Friend) jadi plakat miring persona 5 */
[class*="topPill_"] [class*="item_"],
[class*="tabBar_"] [class*="item_"] {
    border-radius: 2px !important;
    transform: skewX(-10deg) !important;
    font-weight: 900 !important;
    font-style: italic !important;
    text-transform: uppercase !important;
    letter-spacing: 0.04em !important;
    border: 1.5px solid transparent !important;
    transition: all 0.14s cubic-bezier(0.22, 1, 0.36, 1) !important;
}

[class*="topPill_"] [class*="item_"]:hover,
[class*="tabBar_"] [class*="item_"]:hover {
    background-color: var(--p5-surface-alt) !important;
    border-color: var(--p5-primary) !important;
    color: var(--p5-secondary) !important;
    transform: skewX(-10deg) translateY(-1px) !important;
}

[class*="topPill_"] [class*="selected_"],
[class*="tabBar_"] [class*="selected_"],
[class*="addFriend_"] {
    background-color: var(--p5-primary) !important;
    color: var(--p5-fg) !important;
    border: 1.5px solid var(--p5-border) !important;
    box-shadow: 3px 3px 0px var(--p5-secondary) !important;
    transform: skewX(-10deg) !important;
}

/* daftar dm dan channel di sidebar kiri: miring tajam + hard shadow saat aktif/hover */
[class*="channel_"] [class*="interactive_"],
[class*="channel_"] [class*="link_"] {
    border-radius: 2px !important;
    margin: 2px 6px !important;
    border: 1.5px solid transparent !important;
    transition: all 0.14s cubic-bezier(0.22, 1, 0.36, 1) !important;
}

[class*="channel_"]:hover [class*="interactive_"],
[class*="channel_"]:hover [class*="link_"] {
    background-color: var(--p5-surface-alt) !important;
    border-color: var(--p5-primary) !important;
    box-shadow: 3px 3px 0px var(--p5-primary) !important;
    transform: skewX(-6deg) translateX(4px) !important;
}

[class*="selected_"] [class*="interactive_"],
[class*="modeSelected_"] [class*="link_"] {
    background-color: var(--p5-primary) !important;
    color: var(--p5-fg) !important;
    border: 1.5px solid var(--p5-border) !important;
    box-shadow: 4px 4px 0px var(--p5-secondary) !important;
    transform: skewX(-6deg) translateX(4px) !important;
}

/* baris daftar teman (Friends List) bergaya kartu confidant persona 5 */
[class*="peopleListItem_"] {
    background-color: var(--p5-surface) !important;
    border: 1.5px solid rgba(255, 255, 255, 0.12) !important;
    border-left: 4px solid var(--p5-primary) !important;
    border-radius: 2px !important;
    margin: 5px 14px !important;
    padding: 8px 14px !important;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.75) !important;
    transition: all 0.15s cubic-bezier(0.22, 1, 0.36, 1) !important;
}

[class*="peopleListItem_"]:hover {
    background-color: var(--p5-primary) !important;
    border: 2px solid var(--p5-border) !important;
    box-shadow: 5px 5px 0px var(--p5-secondary) !important;
    transform: skewX(-3deg) translateX(4px) !important;
}

/* kartu Active Now di kolom kanan bergaya Calling Card */
[class*="nowPlayingColumn_"] {
    background-color: var(--p5-bg) !important;
    border-left: 2px solid var(--p5-primary) !important;
}

[class*="itemCard_"] {
    background-color: var(--p5-surface) !important;
    border: 2px solid var(--p5-border) !important;
    border-radius: 2px !important;
    box-shadow: 4px 4px 0px var(--p5-primary) !important;
    transition: transform 0.15s ease, box-shadow 0.15s ease !important;
}

[class*="itemCard_"]:hover {
    background-color: var(--p5-surface-alt) !important;
    border-color: var(--p5-secondary) !important;
    box-shadow: 5px 5px 0px var(--p5-secondary) !important;
    transform: translateY(-2px) skewX(-2deg) !important;
}

/* panel profil & status voice di kiri bawah */
[class*="panels_"] {
    background-color: var(--p5-surface) !important;
    border: 2px solid var(--p5-border) !important;
    box-shadow: 4px 4px 0px var(--p5-primary) !important;
    border-radius: 2px !important;
    margin: 6px !important;
}

/* kotak pencarian & kotak ketik pesan */
[class*="searchBar_"],
[class*="channelTextArea_"] [class*="scrollableContainer_"] {
    background-color: var(--p5-surface) !important;
    border: 2px solid var(--p5-primary) !important;
    border-radius: 2px !important;
    box-shadow: 3px 3px 0px rgba(var(--p5-primary-rgb), 0.55) !important;
}

[class*="searchBar_"]:focus-within,
[class*="channelTextArea_"]:focus-within [class*="scrollableContainer_"] {
    border-color: var(--p5-secondary) !important;
    box-shadow: 4px 4px 0px var(--p5-primary) !important;
}

/* lencana angka notifikasi (unread / mention badge) */
[class*="numberBadge_"],
[class*="live_"] {
    background-color: var(--p5-primary) !important;
    color: var(--p5-fg) !important;
    border: 1.5px solid var(--p5-border) !important;
    border-radius: 2px !important;
    box-shadow: 2px 2px 0px var(--p5-secondary) !important;
    transform: skewX(-10deg) !important;
    font-weight: 900 !important;
}
EOF
}

write_vesktop_css "$DOTS_DIR/vesktop/themes/PhantomShell.theme.css"
write_vesktop_css "$VESKTOP_THEME_DIR/PhantomShell.theme.css"
# tulis juga ke quickCss.css dan NieR-Light-Source.theme.css agar vesktop yang sedang berjalan langsung hot-reload tanpa restart
write_vesktop_css "$VESKTOP_SETTINGS_DIR/quickCss.css"
if [[ -f "$VESKTOP_THEME_DIR/NieR-Light-Source.theme.css" ]]; then
    write_vesktop_css "$VESKTOP_THEME_DIR/NieR-Light-Source.theme.css"
fi

if [[ -f "$VESKTOP_SETTINGS" ]]; then
    sed -i 's/"NieR-Light-Source.theme.css"/"PhantomShell.theme.css"/g' "$VESKTOP_SETTINGS" 2>/dev/null || true
fi

# 2. sinkronisasi tema spotify (spicetify) bergaya komik persona 5
SPICE_CFG_DIR="$HOME/.config/spicetify"
mkdir -p "$SPICE_CFG_DIR" "$DOTS_DIR/spicetify"

write_spicetify_css() {
    local target="$1"
    cat > "$target" <<EOF
/* palet warna dan desain antarmuka komik persona 5 untuk spotify (spicetify) */
:root {
    --spice-main: ${BG} !important;
    --spice-base: ${BG} !important;
    --spice-mantle: ${SURFACE} !important;
    --spice-crust: #060609 !important;
    --spice-sidebar: ${SURFACE} !important;
    --spice-player: #09090D !important;
    --spice-card: ${SURFACE} !important;
    --spice-main-elevated: ${SURFACE} !important;
    --spice-surface0: ${SURFACE} !important;
    --spice-surface1: ${SURFACE_ALT} !important;
    --spice-surface2: ${SURFACE_ALT} !important;
    --spice-highlight: ${SURFACE_ALT} !important;
    --spice-highlight-elevated: ${SURFACE_ALT} !important;
    --spice-tab-active: ${PRIMARY} !important;
    --spice-notification: ${SURFACE} !important;
    --spice-notification-error: ${URGENT} !important;
    --spice-text: ${FG} !important;
    --spice-subtext: ${MUTED} !important;
    --spice-button: ${PRIMARY} !important;
    --spice-button-active: ${SECONDARY} !important;
    --spice-button-disabled: #454556 !important;
    --spice-selected-row: ${SECONDARY} !important;
    --spice-red: ${PRIMARY} !important;
    --spice-maroon: ${ACCENT} !important;
    --spice-peach: ${SECONDARY} !important;
    --spice-yellow: ${SECONDARY} !important;
    --spice-green: ${SUCCESS} !important;
    --spice-teal: #00F0FF !important;
    --spice-sky: #00B4D8 !important;
    --spice-sapphire: #00B4D8 !important;
    --spice-blue: ${PRIMARY} !important;
    --spice-lavender: ${SECONDARY} !important;
    --spice-mauve: ${PRIMARY} !important;
    --spice-pink: ${ACCENT} !important;
    --spice-flamingo: ${ACCENT} !important;
    --spice-rosewater: ${FG} !important;
    --spice-overlay0: #6C6C7E !important;
    --spice-overlay1: #858599 !important;
    --spice-overlay2: ${MUTED} !important;
    --spice-shadow: #000000 !important;
    --spice-misc: ${SURFACE_ALT} !important;

    --spice-rgb-main: ${BG_RGB_NS} !important;
    --spice-rgb-base: ${BG_RGB_NS} !important;
    --spice-rgb-mantle: ${SURFACE_RGB_NS} !important;
    --spice-rgb-crust: 6,6,9 !important;
    --spice-rgb-sidebar: ${SURFACE_RGB_NS} !important;
    --spice-rgb-player: 9,9,13 !important;
    --spice-rgb-card: ${SURFACE_RGB_NS} !important;
    --spice-rgb-main-elevated: ${SURFACE_RGB_NS} !important;
    --spice-rgb-surface0: ${SURFACE_RGB_NS} !important;
    --spice-rgb-surface1: ${SURFACE_ALT_RGB_NS} !important;
    --spice-rgb-surface2: ${SURFACE_ALT_RGB_NS} !important;
    --spice-rgb-highlight: ${SURFACE_ALT_RGB_NS} !important;
    --spice-rgb-tab-active: ${PRIMARY_RGB_NS} !important;
    --spice-rgb-text: ${FG_RGB_NS} !important;
    --spice-rgb-subtext: ${MUTED_RGB_NS} !important;
    --spice-rgb-button: ${PRIMARY_RGB_NS} !important;
    --spice-rgb-button-active: ${SECONDARY_RGB_NS} !important;
    --spice-rgb-selected-row: ${SECONDARY_RGB_NS} !important;
    --spice-rgb-red: ${PRIMARY_RGB_NS} !important;
    --spice-rgb-yellow: ${SECONDARY_RGB_NS} !important;
    --spice-rgb-mauve: ${PRIMARY_RGB_NS} !important;
}

/* latar belakang panel utama bertekstur garis diagonal metaverse */
.Root__main-view {
    background-color: var(--spice-main) !important;
    background-image: repeating-linear-gradient(
        -45deg,
        rgba(${PRIMARY_RGB}, 0.04) 0px,
        rgba(${PRIMARY_RGB}, 0.04) 8px,
        transparent 8px,
        transparent 18px
    ) !important;
    border: 2px solid var(--spice-button) !important;
    border-radius: 2px !important;
    box-shadow: 4px 4px 0px #000000 !important;
}

/* panel kiri (library) dan panel kanan (now playing view) */
.Root__nav-bar,
.Root__right-sidebar aside,
.Root__right-sidebar .main-nowPlayingView-section {
    background-color: var(--spice-mantle) !important;
    border: 2px solid rgba(255, 255, 255, 0.85) !important;
    border-radius: 2px !important;
    box-shadow: 4px 4px 0px var(--spice-button) !important;
}

/* hilangkan gradasi biru/warna-warni bawaan spotify di header & lirik agar selaras dengan tema p5 */
.main-entityHeader-backgroundColor,
.main-actionBarBackground-background,
.main-home-homeHeader,
[class*="under-main-view"] div {
    background: linear-gradient(180deg, rgba(${PRIMARY_RGB}, 0.28) 0%, transparent 100%) !important;
}

/* plakat judul seksi bergaya komik persona 5 (Pre-save, Your top mixes, dll.) */
.main-shelf-header h2,
.main-shelf-title,
[data-encore-id="type"].encore-text-title-small,
[data-encore-id="type"].encore-text-title-medium {
    display: inline-block !important;
    background-color: var(--spice-button) !important;
    color: var(--spice-text) !important;
    padding: 3px 14px !important;
    border: 2px solid var(--spice-text) !important;
    box-shadow: 4px 4px 0px var(--spice-button-active) !important;
    transform: skewX(-10deg) !important;
    font-weight: 900 !important;
    font-style: italic !important;
    text-transform: uppercase !important;
    letter-spacing: 0.05em !important;
}

/* kartu pintasan atas (8 kotak playlist cepat di beranda) */
.view-homeShortcutsGrid-shortcut {
    background-color: var(--spice-surface0) !important;
    border: 2px solid rgba(255, 255, 255, 0.75) !important;
    border-radius: 2px !important;
    box-shadow: 4px 4px 0px var(--spice-button) !important;
    transform: skewX(-5deg) !important;
    transition: all 0.15s cubic-bezier(0.22, 1, 0.36, 1) !important;
    overflow: hidden !important;
}

.view-homeShortcutsGrid-shortcut:hover {
    background-color: var(--spice-button) !important;
    border-color: var(--spice-button-active) !important;
    box-shadow: 6px 6px 0px var(--spice-button-active) !important;
    transform: skewX(-5deg) translateY(-2px) !important;
}

/* pastikan wadah tombol play tidak menjadi kotak merah solid saat tidak di-hover */
.main-playButton-PlayButton {
    background: transparent !important;
    border: none !important;
    box-shadow: none !important;
}

/* tombol bulat/miring di dalam play button saat muncul */
.main-playButton-PlayButton > button > span,
button[data-testid="control-button-playpause"] > span {
    background-color: var(--spice-button) !important;
    color: var(--spice-text) !important;
    border: 2px solid var(--spice-text) !important;
    border-radius: 3px !important;
    box-shadow: 3px 3px 0px var(--spice-button-active) !important;
    transform: skewX(-8deg) !important;
}

.main-playButton-PlayButton > button:hover > span,
button[data-testid="control-button-playpause"]:hover > span {
    background-color: var(--spice-button-active) !important;
    color: var(--spice-main) !important;
    border-color: var(--spice-main) !important;
    box-shadow: 3px 3px 0px var(--spice-button) !important;
}

/* kartu album & mix di rak beranda */
.main-card-card,
[class*="Card"] {
    background-color: var(--spice-surface0) !important;
    border: 1.5px solid rgba(255, 255, 255, 0.22) !important;
    border-radius: 2px !important;
    box-shadow: 4px 4px 0px rgba(0, 0, 0, 0.85) !important;
    transition: all 0.16s cubic-bezier(0.22, 1, 0.36, 1) !important;
}

.main-card-card:hover {
    background-color: var(--spice-surface1) !important;
    border: 2px solid var(--spice-text) !important;
    box-shadow: 6px 6px 0px var(--spice-button) !important;
    transform: translateY(-4px) skewX(-2deg) !important;
}

/* pil filter atas (All, Music, Podcasts) */
[role="listitem"] button[data-encore-id="chip"],
button[class*="ChipInner"] {
    border-radius: 2px !important;
    transform: skewX(-10deg) !important;
    border: 1.5px solid var(--spice-text) !important;
    font-weight: 900 !important;
    font-style: italic !important;
    text-transform: uppercase !important;
    box-shadow: 3px 3px 0px var(--spice-button) !important;
}

/* kolom pencarian atas */
.main-globalNav-searchInputContainer input,
.x-searchInput-searchInputInput {
    background-color: var(--spice-surface0) !important;
    color: var(--spice-text) !important;
    border: 2px solid var(--spice-button) !important;
    border-radius: 2px !important;
    box-shadow: 3px 3px 0px var(--spice-button-active) !important;
    transform: skewX(-6deg) !important;
}

/* baris lagu yang sedang dipilih atau diputar di dalam playlist */
.main-trackList-trackListRow {
    border-radius: 2px !important;
    border-left: 3px solid transparent !important;
    transition: all 0.12s ease !important;
}

.main-trackList-trackListRow:hover {
    background-color: rgba(${PRIMARY_RGB}, 0.22) !important;
    border-left: 4px solid var(--spice-button-active) !important;
    transform: skewX(-3deg) translateX(4px) !important;
}

/* dek kontrol pemutar bawah (Now Playing Bar) bergaya HUD Persona 5 */
.Root__now-playing-bar {
    background-color: var(--spice-player) !important;
    border: 2px solid var(--spice-text) !important;
    border-top: 3px solid var(--spice-button) !important;
    box-shadow: 0 -3px 0px var(--spice-button-active) !important;
    border-radius: 2px !important;
    padding: 4px 8px !important;
}

/* sampul album di pojok kiri bawah */
.main-nowPlayingWidget-coverArt .cover-art {
    border: 2px solid var(--spice-text) !important;
    box-shadow: 3px 3px 0px var(--spice-button) !important;
    border-radius: 2px !important;
    transform: rotate(-2deg) !important;
}

/* bilah progres lagu & volume bergaya jajar genjang crimson/gold */
.x-progressBar-progressBarBg {
    background-color: var(--spice-surface1) !important;
    border: 1px solid rgba(255, 255, 255, 0.35) !important;
    border-radius: 1px !important;
    height: 7px !important;
    transform: skewX(-18deg) !important;
}

.x-progressBar-fillColor {
    background-color: var(--spice-button) !important;
    border-radius: 1px !important;
}

.playback-bar:hover .x-progressBar-fillColor,
.progress-bar:hover .x-progressBar-fillColor {
    background-color: var(--spice-button-active) !important;
}

/* kartu lirik di sidebar kanan */
.main-nowPlayingView-lyricsContent,
[data-testid="lyrics-npv-section"] {
    background: linear-gradient(160deg, var(--spice-surface0) 0%, #1E050A 100%) !important;
    border: 2px solid var(--spice-button) !important;
    box-shadow: 4px 4px 0px var(--spice-button-active) !important;
    border-radius: 2px !important;
}
EOF
}

write_spicetify_css "$SPICE_CFG_DIR/phantom-colors.css"
write_spicetify_css "$DOTS_DIR/spicetify/phantom-colors.css"

# siapkan overlay runtime spotify agar tema spicetify bisa berubah langsung tanpa nixos-rebuild
SYS_SPOTIFY="/etc/profiles/per-user/$USER/bin/spotify"
if [[ -x "$SYS_SPOTIFY" ]]; then
    STORE_SPOTIFY="$(readlink -f "$SYS_SPOTIFY")"
    STORE_SHARE="$(dirname "$STORE_SPOTIFY")"
    OVERLAY_DIR="$HOME/.local/share/phantomshell-spotify"

    if [[ -d "$STORE_SHARE/Apps/xpui" ]]; then
        mkdir -p "$OVERLAY_DIR/Apps/xpui/extensions" "$HOME/.local/bin"

        for item in "$STORE_SHARE"/* "$STORE_SHARE"/.*; do
            base="$(basename "$item")"
            [[ "$base" == "." || "$base" == ".." || "$base" == "Apps" || "$base" == ".spotify-wrapped" || "$base" == "spotify" ]] && continue
            ln -sfn "$item" "$OVERLAY_DIR/$base"
        done

        if [[ ! -f "$OVERLAY_DIR/.spotify-wrapped" ]] || [[ "$STORE_SHARE/.spotify-wrapped" -nt "$OVERLAY_DIR/.spotify-wrapped" ]]; then
            cp -f "$STORE_SHARE/.spotify-wrapped" "$OVERLAY_DIR/.spotify-wrapped"
            chmod +x "$OVERLAY_DIR/.spotify-wrapped"
        fi

        ln -sfn "$STORE_SHARE/Apps/login" "$OVERLAY_DIR/Apps/login"

        for xitem in "$STORE_SHARE/Apps/xpui"/*; do
            xbase="$(basename "$xitem")"
            [[ "$xbase" == "colors.css" || "$xbase" == "extensions" ]] && continue
            ln -sfn "$xitem" "$OVERLAY_DIR/Apps/xpui/$xbase"
        done

        for ext in "$STORE_SHARE/Apps/xpui/extensions"/*; do
            ebase="$(basename "$ext")"
            [[ "$ebase" == "theme.js" ]] && continue
            ln -sfn "$ext" "$OVERLAY_DIR/Apps/xpui/extensions/$ebase"
        done

        ln -sfn "$SPICE_CFG_DIR/phantom-colors.css" "$OVERLAY_DIR/Apps/xpui/colors.css"

        # suntikkan live-reloader css di theme.js agar spotify otomatis ganti warna & gaya saat itu juga
        cat > "$OVERLAY_DIR/Apps/xpui/extensions/theme.js" <<'JSEOF'
(function phantomSpicetifyLiveSync() {
    let lastCss = "";
    async function pollColors() {
        try {
            const res = await fetch("colors.css?t=" + Date.now(), { cache: "no-store" });
            if (!res.ok) return;
            const css = await res.text();
            if (css && css !== lastCss) {
                lastCss = css;
                let styleEl = document.getElementById("phantomshell-live-colors");
                if (!styleEl) {
                    styleEl = document.createElement("style");
                    styleEl.id = "phantomshell-live-colors";
                    document.body.appendChild(styleEl);
                }
                styleEl.textContent = css;
            }
        } catch (e) {}
    }
    pollColors();
    setInterval(pollColors, 1200);
})();
JSEOF

        sed "s|$STORE_SHARE/.spotify-wrapped|$OVERLAY_DIR/.spotify-wrapped|g" "$STORE_SHARE/spotify" > "$HOME/.local/bin/spotify"
        chmod +x "$HOME/.local/bin/spotify"
    fi
fi

# 3. sinkronisasi warna terminal kitty secara live
KITTY_CONF="$HOME/.config/kitty/kitty.conf"
if [[ -f "$KITTY_CONF" ]]; then
    sed -i \
        -e "s/^foreground .*/foreground                  ${FG}/" \
        -e "s/^background .*/background                  ${BG}/" \
        -e "s/^selection_foreground .*/selection_foreground        ${BG}/" \
        -e "s/^selection_background .*/selection_background        ${PRIMARY}/" \
        -e "s/^cursor .*/cursor                      ${PRIMARY}/" \
        -e "s/^color0 .*/color0                      ${SURFACE}/" \
        -e "s/^color1 .*/color1                      ${PRIMARY}/" \
        -e "s/^color9 .*/color9                      ${ACCENT}/" \
        -e "s/^color3 .*/color3                      ${SECONDARY}/" \
        "$KITTY_CONF" 2>/dev/null || true

    pkill -USR1 -f "kitty" 2>/dev/null || true
fi
