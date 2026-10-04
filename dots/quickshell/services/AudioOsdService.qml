import QtQuick
import Quickshell
import Quickshell.Io

// layanan pemantau dan pengendali volume audio pipewire serta kecerahan layar
Scope {
    id: root

    property bool osdVisible: false
    property string osdLabel: "VOLUME"
    property int osdValue: 65
    property bool osdMuted: false
    property int volumePct: 65
    property bool volumeMuted: false
    property int brightnessPct: 50

    function triggerOsd(label, val) {
        osdLabel = label
        osdValue = Math.max(0, Math.min(150, val))
        if (label === "VOLUME") {
            volumePct = osdValue
            osdMuted = volumeMuted || (osdValue === 0)
        } else {
            brightnessPct = osdValue
            osdMuted = false
        }
        osdVisible = true
        osdHideTimer.restart()
    }

    function setSystemVolume(pct) {
        const clamped = Math.max(0, Math.min(150, Math.round(Number(pct) || 0)))
        volumePct = clamped
        volumeMuted = (clamped === 0)
        Quickshell.execDetached(["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 2>/dev/null; wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ " + clamped + "% 2>/dev/null || true"])
        triggerOsd("VOLUME", clamped)
    }

    function toggleSystemMute() {
        Quickshell.execDetached(["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 2>/dev/null || true"])
    }

    function setSystemBrightness(pct) {
        const clamped = Math.max(1, Math.min(100, Math.round(Number(pct) || 50)))
        brightnessPct = clamped
        Quickshell.execDetached(["bash", "-c", "brightnessctl set " + clamped + "% >/dev/null 2>&1 || true"])
        triggerOsd("BRIGHTNESS", clamped)
    }

    // pemantau perubahan volume audio dan kecerahan layar secara otomatis
    Process {
        id: osdWatcherProc
        running: true
        command: [
            "bash", "-c",
            "prev_v=\"\"; prev_b=\"\"; " +
            "while true; do " +
            "  v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null); " +
            "  b=$(brightnessctl -m 2>/dev/null | cut -d',' -f4 | tr -dc '0-9'); " +
            "  if [ -n \"$v\" ] && [ \"$v\" != \"$prev_v\" ]; then " +
            "    if [ -n \"$prev_v\" ]; then echo \"VOL|$v\"; else echo \"INIT_VOL|$v\"; fi; " +
            "    prev_v=\"$v\"; " +
            "  fi; " +
            "  if [ -n \"$b\" ] && [ \"$b\" != \"$prev_b\" ]; then " +
            "    if [ -n \"$prev_b\" ]; then echo \"BRI|$b\"; else echo \"INIT_BRI|$b\"; fi; " +
            "    prev_b=\"$b\"; " +
            "  fi; " +
            "  sleep 0.16; " +
            "done"
        ]
        stdout: SplitParser {
            onRead: data => {
                const line = String(data).trim()
                if (!line) return
                if (line.indexOf("INIT_VOL|") === 0 || line.indexOf("VOL|") === 0) {
                    const isInit = line.indexOf("INIT_") === 0
                    const raw = line.slice(isInit ? 9 : 4)
                    const muted = raw.indexOf("MUTED") !== -1
                    const numMatch = raw.match(/([0-9]+(?:\.[0-9]+)?)/)
                    const pct = numMatch ? Math.round(parseFloat(numMatch[1]) * 100) : root.volumePct
                    root.volumeMuted = muted
                    root.volumePct = pct
                    root.osdMuted = muted || (pct === 0)
                    if (!isInit) {
                        root.triggerOsd("VOLUME", pct)
                    }
                } else if (line.indexOf("INIT_BRI|") === 0 || line.indexOf("BRI|") === 0) {
                    const isInit = line.indexOf("INIT_") === 0
                    const pct = parseInt(line.slice(isInit ? 9 : 4), 10)
                    if (!isNaN(pct)) {
                        root.brightnessPct = pct
                        if (!isInit) {
                            root.osdMuted = false
                            root.triggerOsd("BRIGHTNESS", pct)
                        }
                    }
                }
            }
        }
        onExited: osdWatcherRestart.restart()
    }

    Timer {
        id: osdWatcherRestart
        interval: 1500
        repeat: false
        onTriggered: osdWatcherProc.running = true
    }

    Timer {
        id: osdHideTimer
        interval: 2200
        repeat: false
        onTriggered: root.osdVisible = false
    }
}
