import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

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
            Item {
                id: desktopClockWidget
                visible: PhantomState.showDesktopClock
                width: 430
                height: 250
                z: 10
                scale: PhantomState.desktopClockScale / 100.0
                transformOrigin: {
                    if (PhantomState.desktopClockPosition === "center") return Item.Center
                    if (PhantomState.desktopClockPosition === "top-right") return Item.TopRight
                    if (PhantomState.desktopClockPosition === "bottom-left") return Item.BottomLeft
                    return Item.TopLeft
                }

                x: {
                    if (PhantomState.desktopClockPosition === "center") return (parent.width - width) / 2
                    if (PhantomState.desktopClockPosition === "top-right") return parent.width - width - 38
                    return 28
                }
                y: {
                    if (PhantomState.desktopClockPosition === "center") return (parent.height - height) / 2 - 40
                    if (PhantomState.desktopClockPosition === "bottom-left") return parent.height - height - 155
                    return 48
                }

                // gaya jam potongan poligon editorial dengan ikon cuaca
                Item {
                    anchors.fill: parent
                    visible: PhantomState.desktopClockStyle === "p5-editorial"

                    // siluet poligon luar putih dan potongan dalam hitam
                    Canvas {
                        id: p5ClockHull
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()

                            function traceOuter(c) {
                                c.beginPath()
                                c.moveTo(64, 14)
                                c.lineTo(150, 28)
                                c.lineTo(145, 48)
                                c.lineTo(171, 52)
                                c.lineTo(177, 22)
                                c.lineTo(294, 42)
                                c.lineTo(278, 118)
                                c.lineTo(286, 118)
                                c.lineTo(274, 188)
                                // dua sudut runcing bawah
                                c.lineTo(222, 189)
                                c.lineTo(221, 232)
                                c.lineTo(209, 189)
                                c.lineTo(176, 189)
                                c.lineTo(172, 240)
                                c.lineTo(163, 189)
                                c.lineTo(150, 189)
                                c.lineTo(146, 128)
                                c.lineTo(154, 127)
                                c.lineTo(154, 116)
                                c.lineTo(72, 156)
                                c.lineTo(68, 145)
                                c.lineTo(54, 151)
                                c.lineTo(42, 128)
                                c.lineTo(58, 120)
                                c.lineTo(36, 114)
                                c.closePath()
                            }

                            function traceInner(c) {
                                c.beginPath()
                                c.moveTo(71, 24)
                                c.lineTo(139, 35)
                                c.lineTo(134, 57)
                                c.lineTo(179, 63)
                                c.lineTo(185, 33)
                                c.lineTo(282, 50)
                                c.lineTo(268, 125)
                                c.lineTo(275, 125)
                                c.lineTo(265, 180)
                                c.lineTo(220, 180)
                                c.lineTo(217, 198)
                                c.lineTo(212, 180)
                                c.lineTo(174, 180)
                                c.lineTo(171, 202)
                                c.lineTo(166, 180)
                                c.lineTo(158, 180)
                                c.lineTo(155, 120)
                                c.lineTo(162, 118)
                                c.lineTo(161, 104)
                                c.lineTo(77, 143)
                                c.lineTo(73, 134)
                                c.lineTo(59, 139)
                                c.lineTo(53, 126)
                                c.lineTo(68, 118)
                                c.lineTo(49, 108)
                                c.closePath()
                            }

                            ctx.save()
                            ctx.translate(4, 5)
                            traceOuter(ctx)
                            ctx.fillStyle = "rgba(0, 0, 0, 0.55)"
                            ctx.fill()
                            ctx.restore()

                            traceOuter(ctx)
                            ctx.fillStyle = "#F2F2EE"
                            ctx.fill()

                            traceInner(ctx)
                            ctx.fillStyle = "#06090E"
                            ctx.fill()

                            // garis bawah miring di dalam kotak angka jam
                            ctx.fillStyle = "#F2F2EE"
                            ctx.beginPath()
                            ctx.moveTo(68, 121)
                            ctx.lineTo(139, 92)
                            ctx.lineTo(143, 101)
                            ctx.lineTo(72, 130)
                            ctx.closePath()
                            ctx.fill()
                        }
                    }

                    // angka jam miring di sisi kiri
                    Item {
                        x: 52
                        y: 26
                        width: 96
                        height: 82
                        rotation: -13

                        Text {
                            anchors.centerIn: parent
                            text: bgScope.hoursStr
                            color: "#F4F4F0"
                            font.family: "Serif"
                            font.pixelSize: bgScope.hoursStr.length > 1 ? 64 : 78
                            font.weight: Font.Black
                        }
                    }

                    // angka menit miring di bagian tengah
                    Item {
                        x: 172
                        y: 38
                        width: 108
                        height: 76
                        rotation: -6

                        Text {
                            anchors.centerIn: parent
                            text: bgScope.minsStr
                            color: "#F4F4F0"
                            font.family: "Sans Serif"
                            font.pixelSize: 64
                            font.weight: Font.Black
                        }
                    }

                    // label nama hari dengan aksen garis potong horizontal
                    Item {
                        x: 156
                        y: 128
                        width: 112
                        height: 48

                        Text {
                            id: dayLabel
                            anchors.centerIn: parent
                            text: bgScope.dayNameStr
                            color: "#F2F2EE"
                            font.family: "Serif"
                            font.pixelSize: 25
                            font.weight: Font.Bold
                            font.letterSpacing: 0.5
                            transform: Scale {
                                origin.x: dayLabel.width / 2
                                origin.y: dayLabel.height / 2
                                xScale: Math.min(1.0, 104 / Math.max(1, dayLabel.implicitWidth))
                                yScale: 1.28
                            }
                        }

                        // garis potong gelap melintasi teks nama hari
                        Rectangle {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 2
                            width: 104
                            height: 2
                            color: "#06090E"
                            rotation: -1.5
                        }
                    }

                    // kotak stempel ikon cuaca di sisi kanan
                    Item {
                        x: 278
                        y: 38
                        width: 88
                        height: 88
                        rotation: -6.5

                        Rectangle {
                            anchors.fill: parent
                            color: "#EFECE6"
                        }

                        Canvas {
                            id: weatherStampCanvas
                            anchors.fill: parent
                            property string wIcon: bgScope.weatherIcon
                            onWIconChanged: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.save()
                                ctx.translate(width / 2, height / 2 + 4)
                                ctx.rotate(-0.36)
                                ctx.translate(-width / 2, -height / 2)

                                ctx.fillStyle = "#080B10"
                                ctx.strokeStyle = "#EFECE6"
                                ctx.lineWidth = 3.2

                                function drawCloud(yOff) {
                                    // siluet awan latar belakang
                                    ctx.beginPath()
                                    ctx.arc(44, 34 + yOff, 11, 0, Math.PI * 2)
                                    ctx.arc(57, 36 + yOff, 12, 0, Math.PI * 2)
                                    ctx.arc(68, 43 + yOff, 9, 0, Math.PI * 2)
                                    ctx.fill()

                                    // garis lengkung pemisah putih antar awan
                                    ctx.beginPath()
                                    ctx.arc(33, 41 + yOff, 16, -0.8, 0.5)
                                    ctx.arc(50, 40 + yOff, 15, -1.2, 0.4)
                                    ctx.arc(64, 47 + yOff, 11, -1.3, 0.3)
                                    ctx.stroke()

                                    // siluet awan utama bagian depan
                                    ctx.beginPath()
                                    ctx.moveTo(14, 56 + yOff)
                                    ctx.arc(22, 48 + yOff, 11, Math.PI * 0.85, Math.PI * 1.55)
                                    ctx.arc(34, 41 + yOff, 15, Math.PI * 1.05, Math.PI * 1.85)
                                    ctx.arc(51, 42 + yOff, 13, Math.PI * 1.15, Math.PI * 1.9)
                                    ctx.arc(64, 49 + yOff, 9, Math.PI * 1.2, Math.PI * 1.95)
                                    ctx.lineTo(74, 56 + yOff)
                                    ctx.closePath()
                                    ctx.fill()
                                }

                                if (wIcon === "clear-day") {
                                    // ikon matahari
                                    ctx.beginPath()
                                    ctx.arc(44, 42, 16, 0, Math.PI * 2)
                                    ctx.fill()
                                    for (var i = 0; i < 8; i++) {
                                        var a = i * Math.PI / 4
                                        ctx.beginPath()
                                        ctx.moveTo(44 + Math.cos(a) * 21, 42 + Math.sin(a) * 21)
                                        ctx.lineTo(44 + Math.cos(a - 0.15) * 32, 42 + Math.sin(a - 0.15) * 32)
                                        ctx.lineTo(44 + Math.cos(a + 0.15) * 32, 42 + Math.sin(a + 0.15) * 32)
                                        ctx.closePath()
                                        ctx.fill()
                                    }
                                } else if (wIcon === "clear-night") {
                                    // ikon bulan sabit dan bintang
                                    ctx.beginPath()
                                    ctx.arc(44, 42, 22, 0.3, Math.PI * 1.85)
                                    ctx.arc(52, 35, 17, Math.PI * 1.75, 0.45, true)
                                    ctx.closePath()
                                    ctx.fill()
                                    // bintang empat sudut kecil
                                    ctx.beginPath()
                                    ctx.moveTo(64, 18); ctx.lineTo(66, 25); ctx.lineTo(73, 27)
                                    ctx.lineTo(66, 29); ctx.lineTo(64, 36); ctx.lineTo(62, 29)
                                    ctx.lineTo(55, 27); ctx.lineTo(62, 25); ctx.closePath()
                                    ctx.fill()
                                } else if (wIcon === "partly-cloudy-day") {
                                    // ikon matahari di balik awan
                                    ctx.beginPath()
                                    ctx.arc(28, 30, 12, 0, Math.PI * 2)
                                    ctx.fill()
                                    ctx.stroke()
                                    drawCloud(2)
                                } else if (wIcon === "partly-cloudy-night") {
                                    // ikon awan ganda malam
                                    drawCloud(0)
                                } else if (wIcon === "rain") {
                                    // ikon awan dan garis hujan diagonal
                                    drawCloud(-6)
                                    var rx = [22, 35, 48, 61]
                                    for (var r = 0; r < rx.length; r++) {
                                        ctx.beginPath()
                                        ctx.moveTo(rx[r], 54)
                                        ctx.lineTo(rx[r] + 4, 54)
                                        ctx.lineTo(rx[r] - 2, 69)
                                        ctx.lineTo(rx[r] - 6, 69)
                                        ctx.closePath()
                                        ctx.fill()
                                    }
                                } else if (wIcon === "thunder") {
                                    // ikon awan dengan kilat dan hujan
                                    drawCloud(-7)
                                    ctx.beginPath()
                                    ctx.moveTo(45, 50)
                                    ctx.lineTo(35, 62)
                                    ctx.lineTo(43, 62)
                                    ctx.lineTo(37, 74)
                                    ctx.lineTo(53, 59)
                                    ctx.lineTo(44, 59)
                                    ctx.closePath()
                                    ctx.fill()
                                    ctx.fillRect(22, 55, 3, 11)
                                    ctx.fillRect(60, 55, 3, 11)
                                } else if (wIcon === "fog") {
                                    drawCloud(-6)
                                    ctx.fillRect(18, 55, 52, 3.5)
                                    ctx.fillRect(24, 62, 46, 3.5)
                                } else if (wIcon === "snow") {
                                    drawCloud(-6)
                                    ctx.fillRect(26, 56, 5, 5)
                                    ctx.fillRect(42, 58, 5, 5)
                                    ctx.fillRect(58, 56, 5, 5)
                                } else {
                                    drawCloud(0)
                                }
                                ctx.restore()
                            }
                        }
                    }

                    // indikator persentase kelembapan dan suhu di bawah ikon cuaca
                    Column {
                        x: 274
                        y: 132
                        spacing: -4

                        Text {
                            text: bgScope.weatherHumidity
                            color: "#D8DADE"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 44
                            font.weight: Font.Black
                            style: Text.Outline
                            styleColor: "#AA050508"
                        }

                        Text {
                            x: 4
                            text: bgScope.weatherTemp + " // " + bgScope.weatherCity
                            color: PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Black
                            style: Text.Outline
                            styleColor: "#CC050508"
                        }
                    }
                }

                // gaya jam teks minimalis
                Column {
                    anchors.centerIn: parent
                    visible: PhantomState.desktopClockStyle === "minimal"
                    spacing: 2

                    Text {
                        text: bgScope.hoursStr + ":" + bgScope.minsStr + (PhantomState.desktopClockShowSeconds ? (":" + bgScope.secsStr) : "")
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 76
                        font.weight: Font.Black
                        style: Text.Outline
                        styleColor: "#08080C"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: bgScope.dateFullStr + " • " + bgScope.weatherTemp + " " + bgScope.weatherLabel
                        color: PhantomState.primary
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 13
                        font.weight: Font.Black
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // gaya jam kartu poligon siber
                P5SkewedCard {
                    anchors.fill: parent
                    anchors.margins: 16
                    visible: PhantomState.desktopClockStyle === "cyber"
                    fillColor: "#C80B0B10"
                    borderColor: PhantomState.primary
                    shadowColor: PhantomState.secondary
                    skewPx: 12

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: bgScope.hoursStr + ":" + bgScope.minsStr + (PhantomState.desktopClockShowSeconds ? (":" + bgScope.secsStr) : "")
                            color: PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 44
                            font.weight: Font.Black
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: bgScope.dateFullStr + " // " + bgScope.weatherTemp + " (" + bgScope.weatherHumidity + ")"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 11
                            font.weight: Font.Black
                        }
                    }
                }
            }

            // kontainer bawah untuk visualizer audio cava dan lirik lagu
            Item {
                id: bottomAudioBar
                z: 10
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                anchors.bottomMargin: PhantomState.barPosition === "bottom" ? 42 : 6
                height: Math.max(128, PhantomState.cavaMaxHeight)
                visible: PhantomState.showDesktopCava || PhantomState.showDesktopLyrics

                // slot tengah untuk tampilan lirik lima baris
                Item {
                    id: centerLyricsSlot
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    width: PhantomState.showDesktopLyrics ? Math.min(640, parent.width * 0.46) : 24
                    height: 122
                    visible: PhantomState.showDesktopLyrics

                    Column {
                        anchors.centerIn: parent
                        width: parent.width
                        spacing: 2
                        visible: bgScope.musicPlaying && bgScope.currentLyric !== ""

                        // baris lirik dua langkah sebelumnya
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: bgScope.past2Lyric
                            visible: text !== ""
                            color: "#FFFFFF"
                            opacity: 0.24
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        // baris lirik satu langkah sebelumnya
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: bgScope.past1Lyric
                            visible: text !== ""
                            color: "#FFFFFF"
                            opacity: 0.48
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            style: Text.Outline
                            styleColor: "#66000000"
                            elide: Text.ElideRight
                        }

                        // baris lirik yang sedang dinyanyikan saat ini
                        Text {
                            id: activeLyricText
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: bgScope.currentLyric
                            color: "#FFFFFF"
                            opacity: 1.0
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 20
                            font.weight: Font.Black
                            style: Text.Outline
                            styleColor: "#CC050508"
                            elide: Text.ElideRight
                        }

                        // baris lirik satu langkah berikutnya
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: bgScope.next1Lyric
                            visible: text !== ""
                            color: "#FFFFFF"
                            opacity: 0.50
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            style: Text.Outline
                            styleColor: "#66000000"
                            elide: Text.ElideRight
                        }

                        // baris lirik dua langkah berikutnya
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: bgScope.next2Lyric
                            visible: text !== ""
                            color: "#FFFFFF"
                            opacity: 0.26
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                    }
                }

                // kanvas spektrum audio cava sisi kiri
                Canvas {
                    id: leftCavaCanvas
                    visible: PhantomState.showDesktopCava && bgScope.hasLiveAudio
                    anchors.left: parent.left
                    anchors.right: centerLyricsSlot.visible ? centerLyricsSlot.left : parent.horizontalCenter
                    anchors.rightMargin: centerLyricsSlot.visible ? 18 : 6
                    anchors.bottom: parent.bottom
                    height: PhantomState.cavaMaxHeight

                    property int tick: bgScope.cavaTick
                    property color cPrimary: PhantomState.primary
                    property color cSecondary: PhantomState.secondary
                    onTickChanged: requestPaint()
                    onCPrimaryChanged: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var bars = bgScope.leftBars
                        var n = bars.length
                        if (n === 0 || width <= 0 || !bgScope.hasLiveAudio) return
                        var barW = 4
                        var step = width / n
                        var maxH = height
                        for (var i = 0; i < n; i++) {
                            var pct = (bars[i] || 0) / 100.0
                            if (pct <= 0.01) continue
                            var bh = Math.max(3, maxH * pct)
                            var bx = i * step
                            var by = maxH - bh
                            ctx.fillStyle = pct > 0.65 ? cSecondary : cPrimary
                            ctx.globalAlpha = 0.85
                            ctx.fillRect(bx, by, barW, bh)
                        }
                    }
                }

                // kanvas spektrum audio cava sisi kanan
                Canvas {
                    id: rightCavaCanvas
                    visible: PhantomState.showDesktopCava && bgScope.hasLiveAudio
                    anchors.left: centerLyricsSlot.visible ? centerLyricsSlot.right : parent.horizontalCenter
                    anchors.leftMargin: centerLyricsSlot.visible ? 18 : 6
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: PhantomState.cavaMaxHeight

                    property int tick: bgScope.cavaTick
                    property color cPrimary: PhantomState.primary
                    property color cSecondary: PhantomState.secondary
                    onTickChanged: requestPaint()
                    onCPrimaryChanged: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var bars = bgScope.rightBars
                        var n = bars.length
                        if (n === 0 || width <= 0 || !bgScope.hasLiveAudio) return
                        var barW = 4
                        var step = width / n
                        var maxH = height
                        for (var i = 0; i < n; i++) {
                            var pct = (bars[i] || 0) / 100.0
                            if (pct <= 0.01) continue
                            var bh = Math.max(3, maxH * pct)
                            var bx = i * step
                            var by = maxH - bh
                            ctx.fillStyle = pct > 0.65 ? cSecondary : cPrimary
                            ctx.globalAlpha = 0.85
                            ctx.fillRect(bx, by, barW, bh)
                        }
                    }
                }
            }
        }
    }
}
