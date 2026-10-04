import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// widget jam dan informasi cuaca desktop dengan tiga pilihan gaya tampilan
Item {
    id: desktopClockWidget
    visible: PhantomState.showDesktopClock
    width: 430
    height: 250
    z: 10
    scale: PhantomState.desktopClockScale / 100.0

    property string hoursStr: "23"
    property string minsStr: "10"
    property string secsStr: "00"
    property string dayNameStr: "SATURDAY"
    property string dateFullStr: "SATURDAY // OCT 03"
    property string weatherTemp: "24°C"
    property string weatherHumidity: "69%"
    property string weatherIcon: "cloudy"
    property string weatherLabel: "CLOUDY"
    property string weatherCity: "BANDUNG"

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
                text: desktopClockWidget.hoursStr
                color: "#F4F4F0"
                font.family: "Serif"
                font.pixelSize: desktopClockWidget.hoursStr.length > 1 ? 64 : 78
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
                text: desktopClockWidget.minsStr
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
                text: desktopClockWidget.dayNameStr
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
                property string wIcon: desktopClockWidget.weatherIcon
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
                text: desktopClockWidget.weatherHumidity
                color: "#D8DADE"
                font.family: "JetBrainsMono NFM"
                font.pixelSize: 44
                font.weight: Font.Black
                style: Text.Outline
                styleColor: "#AA050508"
            }

            Text {
                x: 4
                text: desktopClockWidget.weatherTemp + " // " + desktopClockWidget.weatherCity
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
            text: desktopClockWidget.hoursStr + ":" + desktopClockWidget.minsStr + (PhantomState.desktopClockShowSeconds ? (":" + desktopClockWidget.secsStr) : "")
            color: "#FFFFFF"
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 76
            font.weight: Font.Black
            style: Text.Outline
            styleColor: "#08080C"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: desktopClockWidget.dateFullStr + " • " + desktopClockWidget.weatherTemp + " " + desktopClockWidget.weatherLabel
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
                text: desktopClockWidget.hoursStr + ":" + desktopClockWidget.minsStr + (PhantomState.desktopClockShowSeconds ? (":" + desktopClockWidget.secsStr) : "")
                color: PhantomState.secondary
                font.family: "JetBrainsMono NFM"
                font.pixelSize: 44
                font.weight: Font.Black
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: desktopClockWidget.dateFullStr + " // " + desktopClockWidget.weatherTemp + " (" + desktopClockWidget.weatherHumidity + ")"
                color: "#FFFFFF"
                font.family: "JetBrainsMono NFM"
                font.pixelSize: 11
                font.weight: Font.Black
            }
        }
    }
}
