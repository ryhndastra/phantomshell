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

# pilih ikon phantomshell sesuai warna primary preset aktif
ICON_FILE="$DOTS_DIR/quickshell/assets/pshell.png"
case "${PRIMARY^^}" in
    "#00B4D8"|"#0096C7") ICON_FILE="$DOTS_DIR/quickshell/assets/pshell-p3-reload.png" ;;
    "#FFD60A"|"#FFC300") ICON_FILE="$DOTS_DIR/quickshell/assets/pshell-p4-golden.png" ;;
    "#FF2A85"|"#E83E8C") ICON_FILE="$DOTS_DIR/quickshell/assets/pshell-kasumi-violet.png" ;;
    "#00F59B"|"#39FF14") ICON_FILE="$DOTS_DIR/quickshell/assets/pshell-futaba-matrix.png" ;;
    "#C8A24A"|"#D4AF37") ICON_FILE="$DOTS_DIR/quickshell/assets/pshell-akechi-crow.png" ;;
    "#E5E5E5"|"#FFFFFF") ICON_FILE="$DOTS_DIR/quickshell/assets/pshell-monochrome.png" ;;
esac
[[ ! -f "$ICON_FILE" ]] && ICON_FILE="$DOTS_DIR/quickshell/assets/pshell.png"

if command -v magick >/dev/null 2>&1; then
    PSHELL_ICON_B64="$(magick "$ICON_FILE" -trim +repage -resize 96x96 PNG32:- 2>/dev/null | base64 -w0)"
else
    PSHELL_ICON_B64="$(base64 -w0 "$ICON_FILE" 2>/dev/null || true)"
fi

# sinkronisasi tema vesktop (discord)
VESKTOP_THEME_DIR="$HOME/.config/vesktop/themes"
VESKTOP_SETTINGS_DIR="$HOME/.config/vesktop/settings"
VESKTOP_SETTINGS="$VESKTOP_SETTINGS_DIR/settings.json"
mkdir -p "$VESKTOP_THEME_DIR" "$VESKTOP_SETTINGS_DIR" "$DOTS_DIR/vesktop/themes"

write_vesktop_css() {
    local target="$1"
    cat > "$target" <<EOF
/**
 * @name PhantomShell Persona Metaverse
 * @version 5.1.0
 * @description tema discord/vesktop persona 5 phantomshell dengan background metaverse & ikon phantomshell
 * @author PhantomShell
 */

:root,
html,
body,
.theme-dark,
.theme-darker,
.theme-midnight,
.theme-light,
html.theme-dark,
html.visual-refresh,
.default-colors,
[data-popout-root] {
    --p5-red: ${PRIMARY};
    --p5-gold: ${SECONDARY};
    --p5-accent: ${ACCENT};
    --p5-bg: ${BG};
    --p5-surface: ${SURFACE};
    --p5-surface2: ${SURFACE_ALT};
    --p5-fg: ${FG};
    --p5-muted: ${MUTED};
    --p5-border: ${BORDER};
    --p5-urgent: ${URGENT};
    --p5-success: ${SUCCESS};
    --p5-red-rgb: ${PRIMARY_RGB};
    --p5-gold-rgb: ${SECONDARY_RGB};
    --p5-logo-url: url("data:image/png;base64,${PSHELL_ICON_B64}");

    /* token warna dasar discord klasik & visual refresh */
    --background-primary: var(--p5-bg) !important;
    --background-secondary: var(--p5-surface) !important;
    --background-secondary-alt: #09090D !important;
    --background-tertiary: #060609 !important;
    --background-accent: var(--p5-red) !important;
    --background-floating: var(--p5-surface) !important;
    --background-nested-floating: var(--p5-surface) !important;
    --background-modifier-hover: rgba(var(--p5-red-rgb), 0.16) !important;
    --background-modifier-active: rgba(var(--p5-red-rgb), 0.26) !important;
    --background-modifier-selected: rgba(var(--p5-red-rgb), 0.34) !important;
    --background-modifier-accent: rgba(var(--p5-red-rgb), 0.22) !important;

    --background-base-low: var(--p5-bg) !important;
    --background-base-lower: var(--p5-surface) !important;
    --background-base-lowest: #060609 !important;
    --background-surface-high: var(--p5-surface) !important;
    --background-surface-higher: var(--p5-surface2) !important;
    --background-surface-highest: var(--p5-surface2) !important;

    --bg-base-primary: var(--p5-bg) !important;
    --bg-base-secondary: var(--p5-surface) !important;
    --bg-base-tertiary: #060609 !important;
    --bg-surface-overlay: var(--p5-surface) !important;
    --bg-surface-raised: var(--p5-surface2) !important;
    --bg-overlay-chat: var(--p5-bg) !important;
    --bg-overlay-1: var(--p5-surface) !important;
    --bg-overlay-2: var(--p5-surface) !important;
    --bg-overlay-3: var(--p5-surface2) !important;
    --chat-background: var(--p5-bg) !important;
    --chat-background-default: var(--p5-bg) !important;
    --home-background: var(--p5-bg) !important;
    --custom-channel-members-bg: var(--p5-surface) !important;
    --channeltextarea-background: var(--p5-surface) !important;
    --input-background: var(--p5-surface) !important;

    --brand-experiment: var(--p5-red) !important;
    --brand-experiment-560: var(--p5-accent) !important;
    --brand-500: var(--p5-red) !important;
    --brand-560: var(--p5-accent) !important;

    --header-primary: var(--p5-fg) !important;
    --header-secondary: var(--p5-gold) !important;
    --text-normal: var(--p5-fg) !important;
    --text-muted: var(--p5-muted) !important;
    --text-link: var(--p5-gold) !important;
    --text-brand: var(--p5-red) !important;
    --text-positive: var(--p5-success) !important;
    --text-danger: var(--p5-urgent) !important;

    --interactive-normal: var(--p5-fg) !important;
    --interactive-hover: var(--p5-gold) !important;
    --interactive-active: var(--p5-fg) !important;
    --channels-default: var(--p5-muted) !important;
    --channel-icon: var(--p5-red) !important;

    --mention-background: rgba(var(--p5-red-rgb), 0.22) !important;
    --mention-foreground: var(--p5-gold) !important;
    --status-danger: var(--p5-urgent) !important;
    --status-positive: var(--p5-success) !important;
    --status-warning: var(--p5-gold) !important;

    --scrollbar-thin-thumb: rgba(var(--p5-red-rgb), 0.65) !important;
    --scrollbar-thin-track: transparent !important;
    --scrollbar-auto-thumb: rgba(var(--p5-red-rgb), 0.65) !important;
    --scrollbar-auto-track: var(--p5-surface) !important;
}

/* ganti ikon discord di pojok kiri atas (home / direct messages) dengan ikon phantomshell transparan tanpa kotak hitam */
[data-list-item-id="guildsnav___home"],
[data-list-item-id="guildsnav___home"] [class*="childWrapper_"],
[class*="tutorialContainer_"] [class*="wrapper_"],
[class*="tutorialContainer_"] [class*="childWrapper_"],
[class*="tutorialContainer_"] [class*="childWrapperNoHoverBg_"] {
    background: transparent !important;
    background-color: transparent !important;
    border: none !important;
    box-shadow: none !important;
}

[class*="tutorialContainer_"] foreignObject {
    mask: none !important;
    -webkit-mask: none !important;
}

[data-list-item-id="guildsnav___home"] svg,
[class*="tutorialContainer_"] [class*="childWrapper_"] svg {
    background-image: var(--p5-logo-url) !important;
    background-size: contain !important;
    background-position: center !important;
    background-repeat: no-repeat !important;
    width: 44px !important;
    height: 44px !important;
    filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.85)) !important;
    transition: transform 0.15s cubic-bezier(0.22, 1, 0.36, 1), filter 0.15s ease !important;
}

[data-list-item-id="guildsnav___home"]:hover svg,
[data-list-item-id="guildsnav___home"][class*="selected_"] svg,
[class*="tutorialContainer_"] [class*="selected_"] svg {
    transform: scale(1.1) rotate(-4deg) !important;
    filter: drop-shadow(0 0 6px rgba(var(--p5-red-rgb), 0.75)) !important;
}

[data-list-item-id="guildsnav___home"] svg > *,
[class*="tutorialContainer_"] [class*="childWrapper_"] svg > * {
    display: none !important;
}

/* latar belakang utama seluruh aplikasi & area chat bertema persona 5 / phantomshell */
body,
#app-mount,
[class*="appMount_"],
[class*="app_"],
[class*="bg_"],
[class*="layers_"],
[class*="chat_"],
main[class*="chatContent_"],
[class*="chatContent_"],
[class*="messagesWrapper_"],
[class*="noChannel_"],
[class*="pageWrapper_"],
[class*="tabBody_"],
[class*="peopleColumn_"],
[class*="nowPlayingColumn_"],
[class*="nowPlayingColumn_"] > [class*="container_"],
[class*="homeWrapper_"] {
    background-color: var(--p5-bg) !important;
    background-image:
        radial-gradient(circle at 82% 14%, rgba(var(--p5-red-rgb), 0.12) 0%, transparent 48%),
        radial-gradient(circle at 18% 88%, rgba(var(--p5-red-rgb), 0.08) 0%, transparent 45%),
        repeating-linear-gradient(
            -45deg,
            rgba(var(--p5-red-rgb), 0.065) 0px,
            rgba(var(--p5-red-rgb), 0.065) 2px,
            transparent 2px,
            transparent 16px
        ) !important;
}

/* pastikan wrapper dalam chat & form input bawah transparan agar motif p5 di chatContent_ terlihat */
[class*="content_"] > [class*="chatContent_"] [class*="scroller_"],
[class*="messagesWrapper_"] [class*="scroller_"],
ol[class*="scrollerInner_"],
form[class*="form_"],
form[class*="form_"]::before,
form[class*="form_"]::after,
[class*="channelTextArea_"] {
    background: transparent !important;
    background-color: transparent !important;
    background-image: none !important;
}

/* bilah server paling kiri (guilds rail) */
nav[class*="guilds_"],
[class*="guilds_"] [class*="tree_"],
[class*="guilds_"] [class*="scroller_"] {
    background-color: #07070A !important;
    background-image: repeating-linear-gradient(
        -45deg,
        rgba(var(--p5-red-rgb), 0.04) 0px,
        rgba(var(--p5-red-rgb), 0.04) 1.5px,
        transparent 1.5px,
        transparent 14px
    ) !important;
}

nav[class*="guilds_"] {
    border-right: 1.5px solid rgba(var(--p5-red-rgb), 0.45) !important;
}

/* sidebar daftar channel & dm di sebelah kiri */
[class*="sidebar_"],
[class*="sidebar_"] > nav[class*="container_"],
[class*="sidebar_"] > [class*="container_"],
[class*="privateChannels_"] {
    background-color: var(--p5-surface) !important;
    background-image:
        linear-gradient(180deg, rgba(var(--p5-red-rgb), 0.09) 0%, transparent 220px),
        repeating-linear-gradient(
            -45deg,
            rgba(var(--p5-red-rgb), 0.035) 0px,
            rgba(var(--p5-red-rgb), 0.035) 1.5px,
            transparent 1.5px,
            transparent 16px
        ) !important;
}

[class*="sidebar_"] {
    border-right: 2px solid var(--p5-red) !important;
}

[class*="privateChannels_"] [class*="scroller_"],
[class*="sidebar_"] [class*="scroller_"] {
    background: transparent !important;
    background-color: transparent !important;
}

/* header nama server & bar atas channel */
header[class*="header_"],
[class*="title_"][class*="container_"],
section[class*="container_"][class*="themed_"] {
    background-color: var(--p5-surface) !important;
    background-image: linear-gradient(90deg, rgba(var(--p5-red-rgb), 0.16) 0%, transparent 65%) !important;
    border-bottom: 2px solid var(--p5-red) !important;
    box-shadow: 0 3px 10px rgba(0, 0, 0, 0.65) !important;
}

/* daftar member di sebelah kanan */
[class*="membersWrap_"],
[class*="members_"],
[class*="members_"] > div {
    background-color: var(--p5-surface) !important;
    background-image: repeating-linear-gradient(
        -45deg,
        rgba(var(--p5-red-rgb), 0.035) 0px,
        rgba(var(--p5-red-rgb), 0.035) 1.5px,
        transparent 1.5px,
        transparent 16px
    ) !important;
}

[class*="membersWrap_"] {
    border-left: 2px solid rgba(var(--p5-red-rgb), 0.55) !important;
}

[class*="member_"],
[class*="memberInner_"] {
    background: transparent !important;
    background-color: transparent !important;
    border-radius: 3px !important;
    transition: background-color 0.12s ease, transform 0.12s ease !important;
}

[class*="member_"]:hover {
    background-color: rgba(var(--p5-red-rgb), 0.18) !important;
    border-left: 3px solid var(--p5-red) !important;
    transform: translateX(3px) !important;
}

/* tab navigasi (Online, All, Pending) */
[class*="topPill_"] [class*="item_"],
[class*="tabBar_"] [class*="item_"] {
    border-radius: 3px !important;
    font-weight: 700 !important;
    letter-spacing: 0.03em !important;
    transition: background 0.12s ease, color 0.12s ease !important;
}

[class*="topPill_"] [class*="item_"]:hover,
[class*="tabBar_"] [class*="item_"]:hover {
    background-color: rgba(var(--p5-red-rgb), 0.18) !important;
    color: var(--p5-fg) !important;
}

[class*="topPill_"] [class*="selected_"],
[class*="tabBar_"] [class*="selected_"] {
    background-color: var(--p5-red) !important;
    color: var(--p5-fg) !important;
    font-weight: 900 !important;
    font-style: italic !important;
    text-transform: uppercase !important;
    letter-spacing: 0.05em !important;
    transform: skewX(-8deg) !important;
    border-radius: 2px !important;
    box-shadow: 3px 3px 0px var(--p5-gold) !important;
}

[class*="addFriend_"] {
    background-color: var(--p5-red) !important;
    color: var(--p5-fg) !important;
    font-weight: 800 !important;
    border-radius: 3px !important;
}

/* item channel & dm di sidebar kiri */
[class*="channel_"] [class*="interactive_"],
[class*="channel_"] [class*="link_"] {
    border-radius: 3px !important;
    margin: 1px 6px !important;
    border-left: 2px solid transparent !important;
    transition: background 0.12s ease, border-color 0.12s ease, transform 0.12s ease !important;
}

[class*="channel_"]:hover [class*="interactive_"],
[class*="channel_"]:hover [class*="link_"] {
    background-color: rgba(var(--p5-red-rgb), 0.16) !important;
    border-left-color: var(--p5-red) !important;
    transform: translateX(2px) !important;
}

[class*="selected_"] [class*="interactive_"],
[class*="modeSelected_"] [class*="link_"] {
    background-color: rgba(var(--p5-red-rgb), 0.28) !important;
    border-left: 3px solid var(--p5-red) !important;
    box-shadow: inset 0 -1px 0 var(--p5-gold) !important;
    color: var(--p5-fg) !important;
    font-weight: 800 !important;
}

/* hover pesan di ruang chat */
[class*="message_"]:hover {
    background-color: rgba(var(--p5-red-rgb), 0.08) !important;
}

/* daftar teman (friends list) */
[class*="peopleListItem_"] {
    background-color: var(--p5-surface) !important;
    border: 1px solid rgba(255, 255, 255, 0.07) !important;
    border-left: 3px solid var(--p5-red) !important;
    border-radius: 4px !important;
    margin: 4px 12px !important;
    padding: 8px 12px !important;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.7) !important;
    transition: all 0.13s ease !important;
}

[class*="peopleListItem_"]:hover {
    background-color: var(--p5-surface2) !important;
    border-color: var(--p5-red) !important;
    border-left: 4px solid var(--p5-gold) !important;
    box-shadow: 4px 4px 0px var(--p5-red) !important;
    transform: translateX(3px) !important;
}

/* kartu active now di kolom kanan */
[class*="nowPlayingColumn_"] {
    border-left: 2px solid rgba(var(--p5-red-rgb), 0.45) !important;
}

[class*="itemCard_"] {
    background-color: var(--p5-surface) !important;
    border: 1.5px solid rgba(var(--p5-red-rgb), 0.45) !important;
    border-radius: 4px !important;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.85) !important;
    transition: transform 0.13s ease, box-shadow 0.13s ease !important;
}

[class*="itemCard_"]:hover {
    border-color: var(--p5-gold) !important;
    box-shadow: 4px 4px 0px var(--p5-red) !important;
    transform: translateY(-2px) !important;
}

/* panel profil & voice di kiri bawah */
[class*="panels_"],
[class*="panels_"] > div {
    background-color: var(--p5-surface) !important;
}

[class*="panels_"] {
    border: 1.5px solid var(--p5-red) !important;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.85) !important;
    border-radius: 4px !important;
}

/* kotak ketik pesan & search bar */
[class*="searchBar_"],
[class*="channelTextArea_"] [class*="scrollableContainer_"] {
    background-color: var(--p5-surface) !important;
    border: 1.5px solid var(--p5-red) !important;
    border-radius: 4px !important;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.8) !important;
    transition: border-color 0.12s ease, box-shadow 0.12s ease !important;
}

[class*="searchBar_"]:focus-within,
[class*="channelTextArea_"]:focus-within [class*="scrollableContainer_"] {
    border-color: var(--p5-gold) !important;
    box-shadow: 3px 3px 0px var(--p5-red) !important;
}

/* lencana angka notifikasi & indikator live */
[class*="numberBadge_"],
[class*="live_"] {
    background-color: var(--p5-red) !important;
    color: var(--p5-fg) !important;
    border-radius: 2px !important;
    transform: skewX(-8deg) !important;
    font-weight: 900 !important;
    font-size: 10px !important;
    letter-spacing: 0.05em !important;
}
EOF
}

write_vesktop_css "$DOTS_DIR/vesktop/themes/PhantomShell.theme.css"
write_vesktop_css "$VESKTOP_THEME_DIR/PhantomShell.theme.css"
write_vesktop_css "$VESKTOP_SETTINGS_DIR/quickCss.css"
if [[ -f "$VESKTOP_THEME_DIR/NieR-Light-Source.theme.css" ]]; then
    write_vesktop_css "$VESKTOP_THEME_DIR/NieR-Light-Source.theme.css"
fi

if [[ -f "$VESKTOP_SETTINGS" ]]; then
    sed -i 's/"NieR-Light-Source.theme.css"/"PhantomShell.theme.css"/g' "$VESKTOP_SETTINGS" 2>/dev/null || true
fi

# sinkronisasi tema spotify (spicetify)
SPICE_CFG_DIR="$HOME/.config/spicetify"
mkdir -p "$SPICE_CFG_DIR" "$DOTS_DIR/spicetify"

write_spicetify_css() {
    local target="$1"
    cat > "$target" <<EOF
/* tema spotify (spicetify) persona 5 phantomshell — seragam dengan tema discord */
:root,
html,
body,
.encore-dark-theme,
.encore-layout-themes {
    --p5-red: ${PRIMARY};
    --p5-gold: ${SECONDARY};
    --p5-accent: ${ACCENT};
    --p5-bg: ${BG};
    --p5-surface: ${SURFACE};
    --p5-surface2: ${SURFACE_ALT};
    --p5-fg: ${FG};
    --p5-muted: ${MUTED};
    --p5-red-rgb: ${PRIMARY_RGB};
    --p5-gold-rgb: ${SECONDARY_RGB};
    --p5-logo-url: url("data:image/png;base64,${PSHELL_ICON_B64}");

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
    --spice-highlight: rgba(${PRIMARY_RGB}, 0.18) !important;
    --spice-highlight-elevated: ${SURFACE_ALT} !important;
    --spice-tab-active: ${PRIMARY} !important;
    --spice-notification: ${PRIMARY} !important;
    --spice-notification-error: ${URGENT} !important;
    --spice-text: ${FG} !important;
    --spice-subtext: ${MUTED} !important;
    --spice-button: ${PRIMARY} !important;
    --spice-button-active: ${SECONDARY} !important;
    --spice-button-disabled: #3A3A4A !important;
    --spice-selected-row: ${SECONDARY} !important;
    --spice-red: ${PRIMARY} !important;
    --spice-maroon: ${ACCENT} !important;
    --spice-peach: ${SECONDARY} !important;
    --spice-yellow: ${SECONDARY} !important;
    --spice-green: ${SUCCESS} !important;
    --spice-blue: ${PRIMARY} !important;
    --spice-lavender: ${SECONDARY} !important;
    --spice-mauve: ${PRIMARY} !important;
    --spice-pink: ${ACCENT} !important;
    --spice-flamingo: ${ACCENT} !important;
    --spice-rosewater: ${FG} !important;
    --spice-overlay0: rgba(${PRIMARY_RGB}, 0.14) !important;
    --spice-overlay1: rgba(${PRIMARY_RGB}, 0.24) !important;
    --spice-overlay2: rgba(${PRIMARY_RGB}, 0.34) !important;
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

    --background-base: ${BG} !important;
    --background-highlight: ${SURFACE_ALT} !important;
    --background-press: ${SURFACE} !important;
    --background-elevated-base: ${SURFACE} !important;
    --background-elevated-highlight: ${SURFACE_ALT} !important;
    --background-tinted-base: rgba(${PRIMARY_RGB}, 0.14) !important;
    --background-tinted-highlight: rgba(${PRIMARY_RGB}, 0.24) !important;
}

/* ganti ikon home spotify di bar atas dengan logo phantomshell transparan tanpa kotak hitam */
button[data-testid="home-button"],
.main-globalNav-searchSection > button,
button[aria-label="Home"] {
    background: transparent !important;
    background-color: transparent !important;
    border: none !important;
    box-shadow: none !important;
}

button[data-testid="home-button"] svg,
.main-globalNav-searchSection > button svg,
button[aria-label="Home"] svg {
    background-image: var(--p5-logo-url) !important;
    background-size: contain !important;
    background-position: center !important;
    background-repeat: no-repeat !important;
    width: 38px !important;
    height: 38px !important;
    filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.85)) !important;
    transition: transform 0.15s cubic-bezier(0.22, 1, 0.36, 1), filter 0.15s ease !important;
}

button[data-testid="home-button"]:hover svg,
button[aria-label="Home"]:hover svg {
    transform: scale(1.12) rotate(-4deg) !important;
    filter: drop-shadow(0 0 6px rgba(var(--p5-red-rgb), 0.8)) !important;
}

button[data-testid="home-button"] svg > *,
.main-globalNav-searchSection > button svg > *,
button[aria-label="Home"] svg > * {
    display: none !important;
}

/* latar belakang utama spotify (sama persis dengan area chat discord: radial merah + garis diagonal metaverse) */
body,
#main,
.Root__top-container,
.Root__main-view,
.main-view-container {
    background-color: var(--p5-bg) !important;
    background-image:
        radial-gradient(circle at 82% 14%, rgba(var(--p5-red-rgb), 0.13) 0%, transparent 48%),
        radial-gradient(circle at 18% 88%, rgba(var(--p5-red-rgb), 0.09) 0%, transparent 45%),
        repeating-linear-gradient(
            -45deg,
            rgba(var(--p5-red-rgb), 0.065) 0px,
            rgba(var(--p5-red-rgb), 0.065) 2px,
            transparent 2px,
            transparent 16px
        ) !important;
}

.Root__main-view {
    border: 1.5px solid rgba(var(--p5-red-rgb), 0.55) !important;
    border-radius: 4px !important;
}

/* pastikan layer internal di dalam main-view transparan agar motif diagonal metaverse tidak tertutup hitam polos */
.under-main-view,
.under-main-view > div,
.main-view-container__scroll-node,
.main-view-container__scroll-node-child,
.main-view-container__scroll-node-child-spacer,
.os-host,
.os-padding,
.os-viewport,
.os-content,
.main-home-content,
.main-home-homeHeader,
.main-entityHeader-backgroundColor,
.main-actionBarBackground-background,
section[data-testid="home-page"] {
    background: transparent !important;
    background-color: transparent !important;
    background-image: none !important;
}

/* beri pendaran gradasi merah halus di bagian paling atas halaman */
.main-home-homeHeader,
.main-entityHeader-backgroundColor {
    background: linear-gradient(180deg, rgba(var(--p5-red-rgb), 0.22) 0%, transparent 100%) !important;
}

/* sidebar kiri (your library) seragam dengan sidebar channel discord */
.Root__nav-bar,
.YourLibraryX,
[data-testid="LeftSidebar"],
.main-yourLibraryX-entryPoints,
.main-yourLibraryX-libraryContainer {
    background-color: var(--p5-surface) !important;
    background-image:
        linear-gradient(180deg, rgba(var(--p5-red-rgb), 0.09) 0%, transparent 220px),
        repeating-linear-gradient(
            -45deg,
            rgba(var(--p5-red-rgb), 0.035) 0px,
            rgba(var(--p5-red-rgb), 0.035) 1.5px,
            transparent 1.5px,
            transparent 16px
        ) !important;
}

.Root__nav-bar {
    border: 1.5px solid rgba(var(--p5-red-rgb), 0.55) !important;
    border-radius: 4px !important;
}

/* sidebar kanan (now playing view & lirik) — hapus warna biru/warna-warni bawaan album dan ganti ke tema p5 */
.Root__right-sidebar,
.Root__right-sidebar aside,
.NowPlayingView,
[data-testid="NPV_Panel_Open_Div"],
[data-testid="NPV_Panel_Open_Div"] > div,
.main-nowPlayingView-content,
.main-nowPlayingView-gradient {
    background-color: var(--p5-surface) !important;
    background-image:
        linear-gradient(180deg, rgba(var(--p5-red-rgb), 0.14) 0%, transparent 260px),
        repeating-linear-gradient(
            -45deg,
            rgba(var(--p5-red-rgb), 0.04) 0px,
            rgba(var(--p5-red-rgb), 0.04) 1.5px,
            transparent 1.5px,
            transparent 16px
        ) !important;
}

.Root__right-sidebar aside {
    border: 1.5px solid rgba(var(--p5-red-rgb), 0.55) !important;
    border-radius: 4px !important;
}

/* kartu seksi & kartu lirik di sidebar kanan */
.main-nowPlayingView-section,
.main-nowPlayingView-lyricsContent,
[data-testid="lyrics-npv-section"] {
    background-color: var(--p5-bg) !important;
    background-image: linear-gradient(160deg, rgba(var(--p5-red-rgb), 0.14) 0%, rgba(11, 11, 14, 0.95) 100%) !important;
    border: 1.5px solid var(--p5-red) !important;
    border-radius: 4px !important;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.85) !important;
}

/* plakat judul rak (Pre-save upcoming releases, Your top mixes) */
.main-shelf-header h2,
.main-shelf-title,
[data-encore-id="type"].encore-text-title-small,
[data-encore-id="type"].encore-text-title-medium {
    display: inline-block !important;
    background-color: var(--p5-red) !important;
    color: var(--p5-fg) !important;
    padding: 3px 14px !important;
    transform: skewX(-10deg) !important;
    font-weight: 900 !important;
    font-style: italic !important;
    text-transform: uppercase !important;
    letter-spacing: 0.06em !important;
    border: 1.5px solid var(--p5-fg) !important;
    box-shadow: 4px 4px 0px var(--p5-gold) !important;
    border-radius: 2px !important;
}

/* pil filter atas (All, Music, Podcasts) — seragam dengan tab Online / All di discord */
[role="listitem"] button[data-encore-id="chip"],
button[class*="ChipInner"],
.x-filterChip-chip {
    background-color: var(--p5-surface) !important;
    color: var(--p5-fg) !important;
    border: 1.5px solid rgba(var(--p5-red-rgb), 0.45) !important;
    border-radius: 2px !important;
    transform: skewX(-8deg) !important;
    font-weight: 800 !important;
    font-style: italic !important;
    text-transform: uppercase !important;
    letter-spacing: 0.04em !important;
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.8) !important;
    transition: all 0.12s ease !important;
}

[role="listitem"] button[data-encore-id="chip"] span,
button[class*="ChipInner"] span {
    background: transparent !important;
    color: inherit !important;
}

[role="listitem"] button[data-encore-id="chip"][aria-checked="true"],
.x-filterChip-chip[aria-checked="true"] {
    background-color: var(--p5-red) !important;
    color: var(--p5-fg) !important;
    border-color: var(--p5-fg) !important;
    box-shadow: 3px 3px 0px var(--p5-gold) !important;
    font-weight: 900 !important;
}

/* kartu pintasan atas (8 kotak di beranda) — seragam dengan kartu confidant discord */
.view-homeShortcutsGrid-shortcut {
    background-color: var(--p5-surface) !important;
    border: 1px solid rgba(255, 255, 255, 0.08) !important;
    border-left: 3px solid var(--p5-red) !important;
    border-radius: 4px !important;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.8) !important;
    transform: none !important;
    transition: all 0.14s ease !important;
    overflow: hidden !important;
}

.view-homeShortcutsGrid-shortcut:hover {
    background-color: var(--p5-surface2) !important;
    border-color: var(--p5-red) !important;
    border-left: 4px solid var(--p5-gold) !important;
    box-shadow: 4px 4px 0px var(--p5-red) !important;
    transform: translateX(3px) !important;
}

/* kartu album & mix di rak beranda */
.main-card-card {
    background-color: var(--p5-surface) !important;
    border: 1.5px solid rgba(255, 255, 255, 0.08) !important;
    border-bottom: 3px solid var(--p5-red) !important;
    border-radius: 4px !important;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.85) !important;
    transition: all 0.15s ease !important;
}

.main-card-card:hover {
    background-color: var(--p5-surface2) !important;
    border-color: var(--p5-red) !important;
    border-bottom-color: var(--p5-gold) !important;
    box-shadow: 5px 5px 0px var(--p5-red) !important;
    transform: translateY(-3px) !important;
}

/* perbaikan tombol play/pause di bar bawah & kartu agar tidak putih polos */
.main-playButton-PlayButton,
button[data-testid="control-button-playpause"],
button[data-testid="play-button"] {
    background: transparent !important;
    border: none !important;
    box-shadow: none !important;
}

button[data-testid="control-button-playpause"] > span,
button[data-testid="control-button-playpause"] [class*="ButtonInner"],
button[data-testid="play-button"] > span,
button[data-testid="play-button"] [class*="ButtonInner"],
.main-playButton-PlayButton > button > span,
.main-card-card [data-testid="play-button"] > span,
.view-homeShortcutsGrid-shortcut [data-testid="play-button"] > span {
    background-color: var(--p5-red) !important;
    color: #FFFFFF !important;
    border: 2px solid #FFFFFF !important;
    border-radius: 4px !important;
    box-shadow: 3px 3px 0px var(--p5-gold) !important;
    transform: skewX(-8deg) !important;
    transition: transform 0.12s ease, background-color 0.12s ease, box-shadow 0.12s ease !important;
}

button[data-testid="control-button-playpause"]:hover > span,
button[data-testid="control-button-playpause"]:hover [class*="ButtonInner"],
button[data-testid="play-button"]:hover > span,
.main-playButton-PlayButton > button:hover > span {
    background-color: var(--p5-gold) !important;
    color: #0B0B0E !important;
    border-color: #0B0B0E !important;
    box-shadow: 3px 3px 0px var(--p5-red) !important;
    transform: skewX(-8deg) scale(1.06) !important;
}

button[data-testid="control-button-playpause"] svg,
button[data-testid="control-button-playpause"] svg path,
button[data-testid="play-button"] svg,
button[data-testid="play-button"] svg path,
.main-playButton-PlayButton svg,
.main-playButton-PlayButton svg path {
    fill: currentColor !important;
    color: inherit !important;
}

/* ikon kontrol player lainnya (shuffle, prev, next, repeat, queue, lyrics) */
[data-testid="control-button-skip-back"] svg,
[data-testid="control-button-skip-forward"] svg,
[data-testid="control-button-shuffle"] svg,
[data-testid="control-button-repeat"] svg {
    fill: var(--p5-muted) !important;
    transition: fill 0.12s ease, transform 0.12s ease !important;
}

[data-testid="control-button-skip-back"]:hover svg,
[data-testid="control-button-skip-forward"]:hover svg,
[data-testid="control-button-shuffle"]:hover svg,
[data-testid="control-button-repeat"]:hover svg {
    fill: var(--p5-fg) !important;
    transform: scale(1.1) !important;
}

[data-testid="control-button-shuffle"][aria-checked="true"] svg,
[data-testid="control-button-repeat"][aria-checked="true"] svg {
    fill: var(--p5-gold) !important;
}

/* baris lagu di playlist */
.main-trackList-trackListRow {
    border-radius: 3px !important;
    border-left: 3px solid transparent !important;
    transition: background-color 0.12s ease, border-color 0.12s ease, transform 0.12s ease !important;
}

.main-trackList-trackListRow:hover {
    background-color: rgba(var(--p5-red-rgb), 0.16) !important;
    border-left-color: var(--p5-red) !important;
    transform: translateX(3px) !important;
}

.main-trackList-trackListRow[aria-selected="true"] {
    background-color: rgba(var(--p5-red-rgb), 0.25) !important;
    border-left-color: var(--p5-gold) !important;
}

/* dek kontrol pemutar bawah (now playing bar) */
.Root__now-playing-bar,
[data-testid="now-playing-bar"] {
    background-color: #09090D !important;
    border: 1.5px solid rgba(var(--p5-red-rgb), 0.65) !important;
    border-top: 2px solid var(--p5-red) !important;
    border-radius: 4px !important;
    box-shadow: 0 -4px 16px rgba(0, 0, 0, 0.85) !important;
}

.main-nowPlayingWidget-coverArt .cover-art,
[data-testid="CoverSlotCollapsed"] {
    border-radius: 4px !important;
    border: 1.5px solid var(--p5-red) !important;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.85) !important;
}

/* bilah progres lagu & volume */
.x-progressBar-progressBarBg {
    background-color: rgba(255, 255, 255, 0.12) !important;
    border-radius: 2px !important;
    height: 5px !important;
    transform: skewX(-14deg) !important;
}

.x-progressBar-fillColor,
:root .Root__now-playing-bar .x-progressBar-progressBarBg > div > div {
    background-color: var(--p5-red) !important;
    border-radius: 2px !important;
}

.playback-bar:hover .x-progressBar-fillColor,
.progress-bar:hover .x-progressBar-fillColor,
:root .Root__now-playing-bar .playback-bar:hover .x-progressBar-progressBarBg > div > div {
    background-color: var(--p5-gold) !important;
}

/* kotak pencarian atas — seragam dengan search bar discord */
.main-globalNav-searchInputContainer input,
.x-searchInput-searchInputInput,
[data-testid="search-input"] {
    background-color: var(--p5-surface) !important;
    color: var(--p5-fg) !important;
    border: 1.5px solid var(--p5-red) !important;
    border-radius: 4px !important;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.8) !important;
    transition: border-color 0.12s ease, box-shadow 0.12s ease !important;
}

.main-globalNav-searchInputContainer:focus-within input,
.x-searchInput-searchInputInput:focus,
[data-testid="search-input"]:focus {
    border-color: var(--p5-gold) !important;
    box-shadow: 3px 3px 0px var(--p5-red) !important;
}
EOF
}

write_spicetify_css "$SPICE_CFG_DIR/phantom-colors.css"
write_spicetify_css "$DOTS_DIR/spicetify/phantom-colors.css"

# pastikan theme.js di overlay spotify menyuntikkan style di akhir body agar mengalahkan user.css catppuccin
OVERLAY_DIR="$HOME/.local/share/phantomshell-spotify"
if [[ -d "$OVERLAY_DIR/Apps/xpui/extensions" ]]; then
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
    cp -f "$OVERLAY_DIR/Apps/xpui/extensions/theme.js" "$DOTS_DIR/spicetify/theme.js"
fi

# sinkronisasi warna terminal kitty secara live
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
