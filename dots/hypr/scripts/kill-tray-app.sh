#!/usr/bin/env bash
# S.E.E.S. Protocol - Force Kill Tray Application
RAW_ID="$1"
RAW_TITLE="$2"
RAW_TOOLTIP="$3"

CANDIDATES=()

# 1. Bersihkan ID (contoh: vesktop_status_icon_1 -> vesktop)
CLEAN_ID=$(echo "$RAW_ID" | sed -E 's/_status_icon.*//i; s/[-_]tray.*//i; s/[-_]sni.*//i; s/.*\.//')
[[ -n "$CLEAN_ID" ]] && CANDIDATES+=("$CLEAN_ID")

# 2. Bersihkan Title
CLEAN_TITLE=$(echo "$RAW_TITLE" | sed -E 's/[^a-zA-Z0-9_-]//g')
[[ -n "$CLEAN_TITLE" ]] && CANDIDATES+=("$CLEAN_TITLE")

# 3. Bersihkan Tooltip
CLEAN_TOOLTIP=$(echo "$RAW_TOOLTIP" | awk '{print $1}' | sed -E 's/[^a-zA-Z0-9_-]//g')
[[ -n "$CLEAN_TOOLTIP" ]] && CANDIDATES+=("$CLEAN_TOOLTIP")

# 4. Ekstraksi nama aplikasi populer (vesktop, discord, spotify, steam, dsb.)
KNOWN=$(echo "$RAW_ID $RAW_TITLE $RAW_TOOLTIP" | tr '[:upper:]' '[:lower:]' | grep -o -E '(vesktop|discord|spotify|steam|telegram|obs|slack|thunderbird|element|signal|vencord)' | head -n 1)
[[ -n "$KNOWN" ]] && CANDIDATES+=("$KNOWN")

# 5. Raw input sebagai fallback
[[ -n "$RAW_TITLE" ]] && CANDIDATES+=("$RAW_TITLE")
[[ -n "$RAW_ID" ]] && CANDIDATES+=("$RAW_ID")

KILLED=0
for name in "${CANDIDATES[@]}"; do
    [[ -z "$name" ]] && continue
    if pkill -9 -i -x "$name" 2>/dev/null; then
        KILLED=1
    fi
    if pkill -9 -i -f "$name" 2>/dev/null; then
        KILLED=1
    fi
done

APP_DISPLAY="${RAW_TITLE:-$KNOWN}"
APP_DISPLAY="${APP_DISPLAY:-$CLEAN_ID}"
APP_DISPLAY="${APP_DISPLAY:-$RAW_ID}"

notify-send -a "S.E.E.S. Protocol" -i "process-stop" \
    "EXECUTION: TERMINATED" "Aplikasi ${APP_DISPLAY} dimatikan paksa."
