import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config

// modul latar belakang wallpaper, jam desktop, cuaca, spektrum cava, dan lirik lagu
Scope {
    id: bgScope

    // state waktu dan tanggal jam desktop
    property string hoursStr: "23"
    property string minsStr: "10"
    property string secsStr: "00"
    property string dayNameStr: "SATURDAY"
    property string dateFullStr: "SATURDAY // OCT 03"
    property string periodStr: "EVENING"

    // state data cuaca desktop
    property string weatherTemp: "24°C"
    property string weatherHumidity: "69%"
    property string weatherIcon: "cloudy"
    property string weatherLabel: "CLOUDY"
    property string weatherCity: "BANDUNG"

    // state lirik lagu tersinkronisasi
    property bool musicPlaying: false
    property string musicPlayer: ""
    property string musicTitle: ""
    property string musicArtist: ""
    property string past2Lyric: ""
    property string past1Lyric: ""
    property string currentLyric: ""
    property string next1Lyric: ""
    property string next2Lyric: ""

    property bool hasLiveAudio: false
    property var leftBars: []
    property var rightBars: []
    property int cavaTick: 0

    // timer penyembunyi visualizer cava saat audio hening
    Timer {
        id: cavaSilenceTimer
        interval: 450
        repeat: false
        onTriggered: {
            bgScope.hasLiveAudio = false
            bgScope.leftBars = []
            bgScope.rightBars = []
            bgScope.cavaTick++
        }
    }

    function updateDesktopClock() {
        var now = new Date()
        var h = now.getHours()
        hoursStr = String(h)
        minsStr = Qt.formatDateTime(now, "mm")
        secsStr = Qt.formatDateTime(now, "ss")
        dayNameStr = Qt.formatDateTime(now, "dddd").toUpperCase()
        dateFullStr = Qt.formatDateTime(now, "dddd // MMM dd").toUpperCase()
        if (h < 6) periodStr = "DARK HOUR"
        else if (h < 12) periodStr = "MORNING"
        else if (h < 15) periodStr = "LUNCHTIME"
        else if (h < 18) periodStr = "AFTER SCHOOL"
        else periodStr = "EVENING"
    }

    Timer {
        interval: PhantomState.desktopClockShowSeconds ? 1000 : 10000
        running: PhantomState.showDesktopClock
        repeat: true
        triggeredOnStart: true
        onTriggered: bgScope.updateDesktopClock()
    }

    // proses pengambil data cuaca berkala
    Process {
        id: weatherProc
        command: ["python3", "/mnt/data/Projects/rice/phantomshell/scripts/phantom-weather.py"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (!line) return
                try {
                    var w = JSON.parse(line)
                    if (w.temp) bgScope.weatherTemp = w.temp
                    if (w.humidity) bgScope.weatherHumidity = w.humidity
                    if (w.icon) bgScope.weatherIcon = w.icon
                    if (w.label) bgScope.weatherLabel = w.label
                    if (w.city) bgScope.weatherCity = w.city
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 900000
        running: PhantomState.showDesktopClock
        repeat: true
        triggeredOnStart: true
        onTriggered: weatherProc.running = true
    }

    // proses pembaca spektrum audio cava secara real-time
    Process {
        id: cavaProc
        running: PhantomState.showDesktopCava
        command: [
            "bash", "-c",
            "cat << 'EOF' > /tmp/phantomshell-cava.conf\n" +
            "[general]\n" +
            "framerate = 24\n" +
            "bars = 64\n" +
            "autosens = 1\n" +
            "sleep_timer = 1\n" +
            "[smoothing]\n" +
            "integral = 70\n" +
            "monstercat = 1\n" +
            "waves = 0\n" +
            "[output]\n" +
            "method = raw\n" +
            "raw_target = /dev/stdout\n" +
            "data_format = ascii\n" +
            "ascii_max_range = 100\n" +
            "bar_delimiter = 59\n" +
            "frame_delimiter = 10\n" +
            "EOF\n" +
            "exec cava -p /tmp/phantomshell-cava.conf 2>/dev/null"
        ]
        stdout: SplitParser {
            onRead: data => {
                var raw = data.trim()
                if (!raw) return
                var parts = raw.split(";")
                if (parts.length < 32) return
                var l = new Array(32)
                var r = new Array(32)
                var nonZero = 0
                for (var i = 0; i < 32; i++) {
                    var v1 = parseInt(parts[i], 10) || 0
                    if (v1 > 2) nonZero++
                    l[i] = v1
                }
                for (var j = 0; j < 32; j++) {
                    var v2 = parseInt(parts[j + 32], 10) || 0
                    if (v2 > 2) nonZero++
                    r[j] = v2
                }
                if (nonZero > 0) {
                    bgScope.hasLiveAudio = true
                    bgScope.leftBars = l
                    bgScope.rightBars = r
                    cavaSilenceTimer.restart()
                } else {
                    bgScope.hasLiveAudio = false
                    bgScope.leftBars = []
                    bgScope.rightBars = []
                }
                bgScope.cavaTick++
            }
        }
    }

    // proses pengambil lirik lagu tersinkronisasi
    Process {
        id: lyricsProc
        running: PhantomState.showDesktopLyrics
        command: ["python3", "/mnt/data/Projects/rice/phantomshell/scripts/phantom-lyrics.py"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (!line) return
                try {
                    var obj = JSON.parse(line)
                    bgScope.musicPlaying = !!obj.playing
                    bgScope.musicPlayer = obj.player || ""
                    bgScope.musicTitle = obj.title || ""
                    bgScope.musicArtist = obj.artist || ""
                    bgScope.past2Lyric = obj.past2 || ""
                    bgScope.past1Lyric = obj.past1 || ""
                    bgScope.currentLyric = obj.now || ""
                    bgScope.next1Lyric = obj.next1 || ""
                    bgScope.next2Lyric = obj.next2 || ""
                } catch (e) {}
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bgWin
            required property ShellScreen modelData
            screen: modelData
            visible: true

            WlrLayershell.namespace: "phantomshell-background"
            WlrLayershell.layer: WlrLayer.Background
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: PhantomState.background

            readonly property int activeWs: Hyprland.focusedWorkspace?.id ?? 1
            readonly property real zoomFactor: Math.max(1.0, PhantomState.wallpaperZoom / 100.0)
            readonly property real parallaxOffsetX: PhantomState.wallpaperParallax ? ((activeWs - 3.5) * -14) : 0
            property real wpCrossfade: 1.0
            property real wpPunchScale: 1.0
            property real wpSlideX: 0.0

            ParallelAnimation {
                id: wpSwitchAnim
                NumberAnimation {
                    target: bgWin
                    property: "wpCrossfade"
                    from: 0.0
                    to: 1.0
                    duration: 920
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: bgWin
                    property: "wpPunchScale"
                    from: 1.09
                    to: 1.0
                    duration: 1060
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.15
                }
                NumberAnimation {
                    target: bgWin
                    property: "wpSlideX"
                    from: 34.0
                    to: 0.0
                    duration: 920
                    easing.type: Easing.OutCubic
                }
            }

            Connections {
                target: PhantomState
                function onWallpaperPathChanged() {
                    wpSwitchAnim.restart()
                }
            }

            // lapisan gambar wallpaper sebelumnya untuk transisi crossfade
            Image {
                id: wpPrevImg
                visible: PhantomState.showWallpaperLayer && PhantomState.previousWallpaperPath !== "" && bgWin.wpCrossfade < 0.99
                width: parent.width * bgWin.zoomFactor
                height: parent.height * bgWin.zoomFactor
                x: (parent.width - width) / 2 + bgWin.parallaxOffsetX
                y: (parent.height - height) / 2
                source: PhantomState.previousWallpaperPath !== "" ? ("file://" + PhantomState.previousWallpaperPath) : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                smooth: true
            }

            // lapisan gambar wallpaper aktif dengan efek parallax dan transisi
            Image {
                id: wpImg
                visible: PhantomState.showWallpaperLayer && PhantomState.wallpaperPath !== ""
                width: parent.width * bgWin.zoomFactor
                height: parent.height * bgWin.zoomFactor
                x: (parent.width - width) / 2 + bgWin.parallaxOffsetX + bgWin.wpSlideX
                y: (parent.height - height) / 2
                scale: bgWin.wpPunchScale
                opacity: bgWin.wpCrossfade
                source: PhantomState.wallpaperPath !== "" ? ("file://" + PhantomState.wallpaperPath) : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                smooth: true

                Behavior on x {
                    NumberAnimation { duration: 360; easing.type: Easing.OutCubic }
                }
            }

            // gradasi vignette gelap pada bagian atas dan bawah layar
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#44000000" }
                    GradientStop { position: 0.18; color: "#00000000" }
                    GradientStop { position: 0.78; color: "#00000000" }
                    GradientStop { position: 1.0; color: "#77000000" }
                }
            }

            // widget jam dan informasi cuaca desktop
            DesktopClockWidget {
                hoursStr: bgScope.hoursStr
                minsStr: bgScope.minsStr
                secsStr: bgScope.secsStr
                dayNameStr: bgScope.dayNameStr
                dateFullStr: bgScope.dateFullStr
                weatherTemp: bgScope.weatherTemp
                weatherHumidity: bgScope.weatherHumidity
                weatherIcon: bgScope.weatherIcon
                weatherLabel: bgScope.weatherLabel
                weatherCity: bgScope.weatherCity
            }

            // kontainer bawah untuk visualizer audio cava dan lirik lagu
            DesktopCavaLyrics {
                musicPlaying: bgScope.musicPlaying
                past2Lyric: bgScope.past2Lyric
                past1Lyric: bgScope.past1Lyric
                currentLyric: bgScope.currentLyric
                next1Lyric: bgScope.next1Lyric
                next2Lyric: bgScope.next2Lyric
                hasLiveAudio: bgScope.hasLiveAudio
                leftBars: bgScope.leftBars
                rightBars: bgScope.rightBars
                cavaTick: bgScope.cavaTick
            }
        }
    }
}
