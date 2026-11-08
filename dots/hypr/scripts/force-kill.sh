#!/usr/bin/env bash
# Force-kill active window and process (SIGKILL) with S.E.E.S. feedback
set -eo pipefail

win=$(hyprctl activewindow -j 2>/dev/null || echo "{}")
pid=$(echo "$win" | jq -r '.pid // empty' 2>/dev/null || true)
cls=$(echo "$win" | jq -r '.class // "Window"' 2>/dev/null || true)
addr=$(echo "$win" | jq -r '.address // empty' 2>/dev/null || true)

if [ -n "$pid" ] && [ "$pid" != "0" ] && [ "$pid" != "null" ]; then
    # Kirim SIGKILL ke process tree
    kill -9 -"$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null || true

    # Tutup surface di Hyprland jika address tersedia
    if [ -n "$addr" ] && [ "$addr" != "0x0" ]; then
        hyprctl dispatch closewindow "address:$addr" >/dev/null 2>&1 || true
    fi

    # Notifikasi taktis S.E.E.S.
    notify-send -a "S.E.E.S. Protocol" -i "process-stop" -u critical \
        "EXECUTION: FORCE KILL" "Aplikasi $cls (PID: $pid) dimatikan paksa." >/dev/null 2>&1 || true
fi
