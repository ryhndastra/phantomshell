#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$ROOT_DIR/dots"
export PHANTOMSHELL_DOTS="$DOTS_DIR"
export PATH="$ROOT_DIR/scripts:$PATH"

MODE="${1:-live}"

case "$MODE" in
    live|ui)
        echo "🎭 [Phantomshell] Menjalankan LIVE di atas Desktop Utama lu sekarang!"
        echo "💡 Shell lama (ii) di-pause sementara biar TopBar gak ketumpuk / gak ada jarak di atas."
        echo "   Tekan Ctrl+C kapan aja buat matiin Phantomshell & nyalain balik shell lama lu!"

        # Check if old quickshell (ii) is running so we can restore it on exit
        RESTORE_II=0
        if pgrep -x "quickshell" >/dev/null 2>&1 || pgrep -x "qs" >/dev/null 2>&1; then
            RESTORE_II=1
            pkill -x "quickshell" 2>/dev/null || true
            pkill -x "qs" 2>/dev/null || true
            sleep 0.3
        fi

        cleanup() {
            echo ""
            echo "🔄 Mengembalikan shell lama (qs -c ii)..."
            if [ "$RESTORE_II" -eq 1 ]; then
                nohup qs -c ii >/dev/null 2>&1 &
            fi
        }
        trap cleanup EXIT INT TERM

        qs -p "$DOTS_DIR/quickshell"
        ;;

    nested)
        echo "🪟 [Phantomshell] Menjalankan Full Nested Hyprland (hyprland.lua) + Phantomshell (dengan Wallpaper)..."
        echo "💡 Keybind di dalam window nested:"
        echo "   - Tap SUPER (atau ALT+D) : Buka All-in-One P5 Command Launcher"
        echo "   - ALT + Enter            : Buka Kitty (Tema P5)"
        echo "   - ALT + N                : Buka Control Center & Pentagon Stats Dashboard"
        echo "   - ALT + I                : Buka Unified Settings GUI"
        echo "   - ALT + B                : Kirim Test P5 IM Chat Bubble Notification"
        echo "   - ALT + Q                : Tutup window aktif"
        echo "   - ALT + Shift + E        : Keluar dari Nested Hyprland"
        export PHANTOMSHELL_DOTS="$DOTS_DIR"
        export PHANTOMSHELL_NESTED=1
        exec Hyprland -c "$DOTS_DIR/hypr/hyprland.lua"
        ;;

    tty|full)
        echo "🚀 [Phantomshell] Menjalankan Full Desktop Session..."
        export PHANTOMSHELL_DOTS="$DOTS_DIR"
        export PHANTOMSHELL_NESTED=0
        exec Hyprland -c "$DOTS_DIR/hypr/hyprland.lua"
        ;;

    *)
        echo "Usage: ./dev.sh [live|nested|full]"
        echo "  ./dev.sh live    -> (Default) Jalankan langsung di desktop utama lu sekarang (bisa lihat semua window & auto-restore pas Ctrl+C)"
        echo "  ./dev.sh nested  -> Buka jendela Hyprland baru (hyprland.lua + Phantomshell + Wallpaper)"
        echo "  ./dev.sh full    -> Jalankan dari TTY sebagai session penuh"
        ;;
esac
