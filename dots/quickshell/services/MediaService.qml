import QtQuick
import Quickshell
import Quickshell.Io

// layanan pengendali media player mpris dengan prioritas spotify
Scope {
    id: root

    property bool mediaAvailable: false
    property bool mediaPlaying: false
    property string mediaPlayerName: "SPOTIFY"
    property string mediaTitle: "No Track Playing"
    property string mediaArtist: "Open Spotify or play media"
    property string mediaAlbum: ""
    property string mediaArtUrl: ""
    property real mediaPositionSec: 0
    property real mediaLengthSec: 0
    property string mediaShuffle: "Off"
    property string mediaLoop: "None"

    function formatMediaTime(sec) {
        const s = Math.max(0, Math.floor(Number(sec) || 0))
        const m = Math.floor(s / 60)
        const r = s % 60
        return (m < 10 ? "0" + m : String(m)) + ":" + (r < 10 ? "0" + r : String(r))
    }

    function refreshMedia() {
        mediaProc.running = false
        mediaProc.running = true
    }

    function mediaPlayPause() {
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any play-pause 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    function mediaNext() {
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any next 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    function mediaPrev() {
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any previous 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    function mediaSeek(ratio) {
        if (root.mediaLengthSec <= 0) return
        const targetSec = Math.max(0, Math.min(root.mediaLengthSec, ratio * root.mediaLengthSec))
        root.mediaPositionSec = targetSec
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any position " + targetSec.toFixed(1) + " 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    function mediaToggleShuffle() {
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any shuffle Toggle 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    function mediaToggleLoop() {
        const nextLoop = root.mediaLoop === "None" ? "Playlist" : (root.mediaLoop === "Playlist" ? "Track" : "None")
        Quickshell.execDetached(["bash", "-c", "playerctl -p spotify,%any loop " + nextLoop + " 2>/dev/null || true"])
        mediaRefreshDelay.restart()
    }

    Timer {
        id: mediaRefreshDelay
        interval: 220
        repeat: false
        onTriggered: root.refreshMedia()
    }

    Process {
        id: mediaProc
        command: [
            "bash", "-c",
            "out=$(playerctl -p spotify,%any metadata --format '{{playerName}}|{{status}}|{{artist}}|{{title}}|{{album}}|{{mpris:artUrl}}|{{position}}|{{mpris:length}}|{{shuffle}}|{{loop}}' 2>/dev/null | head -n 1); if [ -n \"$out\" ]; then printf '%s\\n' \"$out\"; else echo 'NONE'; fi"
        ]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const line = String(data).trim()
                if (!line || line === "NONE" || line.indexOf("|") === -1) {
                    root.mediaAvailable = false
                    root.mediaPlaying = false
                    root.mediaPlayerName = "NO MEDIA"
                    root.mediaTitle = "No Track Playing"
                    root.mediaArtist = "Open Spotify or play media"
                    root.mediaAlbum = ""
                    root.mediaArtUrl = ""
                    root.mediaPositionSec = 0
                    root.mediaLengthSec = 0
                    root.mediaShuffle = "Off"
                    root.mediaLoop = "None"
                    return
                }
                const p = line.split("|")
                root.mediaAvailable = true
                root.mediaPlayerName = (p[0] || "MEDIA").toUpperCase()
                root.mediaPlaying = (p[1] === "Playing")
                root.mediaArtist = p[2] || "Unknown Artist"
                root.mediaTitle = p[3] || "Unknown Track"
                root.mediaAlbum = p[4] || ""
                root.mediaArtUrl = p[5] || ""
                root.mediaPositionSec = (Number(p[6]) || 0) / 1000000.0
                root.mediaLengthSec = (Number(p[7]) || 0) / 1000000.0
                root.mediaShuffle = p[8] || "Off"
                root.mediaLoop = p[9] || "None"
            }
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: mediaProc.running = true
    }
}
