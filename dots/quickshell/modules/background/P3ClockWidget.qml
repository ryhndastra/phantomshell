import QtQuick
import QtQuick.Effects

// Widget Jam & Lunar HUD otentik Persona 3 Reload - Game-Accurate Atlus HUD
Item {
    id: p3ClockRoot
    implicitWidth: 560
    implicitHeight: 180

    readonly property real vw: width / 28.0

    property var currentTime: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: p3ClockRoot.currentTime = new Date()
    }

    readonly property string timeStr: {
        const h = p3ClockRoot.currentTime.getHours().toString().padStart(2, "0")
        const m = p3ClockRoot.currentTime.getMinutes().toString().padStart(2, "0")
        return h + ":" + m
    }

    readonly property string dateStr: {
        const months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
        const m = months[p3ClockRoot.currentTime.getMonth()]
        const d = p3ClockRoot.currentTime.getDate().toString().padStart(2, "0")
        return m + "·" + d
    }

    readonly property string weekdayStr: {
        const days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        return days[p3ClockRoot.currentTime.getDay()]
    }

    readonly property string daytimeStr: {
        const h = p3ClockRoot.currentTime.getHours()
        if (h >= 0 && h < 1) return "DARK HOUR"
        if (h >= 1 && h < 6) return "LATE NIGHT"
        if (h >= 6 && h < 9) return "EARLY MORNING"
        if (h >= 9 && h < 12) return "MORNING"
        if (h >= 12 && h < 14) return "LUNCHTIME"
        if (h >= 14 && h < 18) return "AFTER SCHOOL"
        return "EVENING"
    }

    readonly property real moonPhaseDegree: {
        const cycleLength = 29.53059
        const knownNewMoon = new Date('2024-03-10T15:00:00Z')
        const daysSince = (p3ClockRoot.currentTime - knownNewMoon) / (1000 * 60 * 60 * 24)
        const percentage = ((daysSince % cycleLength) + cycleLength) % cycleLength / cycleLength
        var degree = 360 - Math.floor(percentage * 360)
        if (degree >= 355 || degree <= 5) return 0
        if (degree >= 175 && degree <= 185) return 180
        return degree
    }

    readonly property string moonPhaseName: {
        const deg = moonPhaseDegree
        if (deg >= 350 || deg <= 10) return "NEW MOON"
        if (deg > 10 && deg < 80) return "WAXING CRESCENT"
        if (deg >= 80 && deg <= 100) return "FIRST QUARTER"
        if (deg > 100 && deg < 170) return "WAXING GIBBOUS"
        if (deg >= 170 && deg <= 190) return "FULL MOON"
        if (deg > 190 && deg < 260) return "WANING GIBBOUS"
        if (deg >= 260 && deg <= 280) return "LAST QUARTER"
        return "WANING CRESCENT"
    }

    Item {
        id: clockContent
        anchors.fill: parent

        // ── Gelombang Air Laut Latar Belakang ──
        Item {
            id: waveContainerOuter
            z: 1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: -p3ClockRoot.vw * 1.5625
            width: p3ClockRoot.vw * 26.0417
            height: p3ClockRoot.vw * 7.2917
            clip: true

            Repeater {
                model: [
                    Qt.resolvedUrl("../../assets/themes/p3/img/wave1.png"),
                    Qt.resolvedUrl("../../assets/themes/p3/img/wave2.png"),
                    Qt.resolvedUrl("../../assets/themes/p3/img/wave3.png"),
                    Qt.resolvedUrl("../../assets/themes/p3/img/wave4.png")
                ]
                delegate: Item {
                    id: wavePairDelegate
                    required property url modelData
                    required property int index
                    width: waveContainerOuter.width * 2
                    height: waveContainerOuter.height

                    Image {
                        source: wavePairDelegate.modelData
                        width: waveContainerOuter.width
                        height: waveContainerOuter.height
                        fillMode: Image.Stretch
                        x: 0
                    }
                    Image {
                        source: wavePairDelegate.modelData
                        width: waveContainerOuter.width
                        height: waveContainerOuter.height
                        fillMode: Image.Stretch
                        x: waveContainerOuter.width
                    }

                    NumberAnimation on x {
                        from: 0
                        to: -waveContainerOuter.width
                        duration: 10000 + wavePairDelegate.index * 1500
                        loops: Animation.Infinite
                        running: true
                    }
                }
            }
        }

        // ── Huruf Tanggal Bermasker Air Biru Mengalir (NOV·05) ──
        Item {
            id: waveTextLayer
            z: 5
            anchors.top: parent.top
            anchors.topMargin: -p3ClockRoot.vw * 0.5
            anchors.right: parent.right
            anchors.rightMargin: -p3ClockRoot.vw * 1.5625
            width: p3ClockRoot.vw * 26.0417
            height: p3ClockRoot.vw * 6.25
            clip: true

            Item {
                id: scrollingBg
                width: waveTextLayer.width * 2
                height: waveTextLayer.height

                Image {
                    source: Qt.resolvedUrl("../../assets/themes/p3/img/wave8.png")
                    width: waveTextLayer.width
                    height: waveTextLayer.height
                    fillMode: Image.Stretch
                    x: 0
                }
                Image {
                    source: Qt.resolvedUrl("../../assets/themes/p3/img/wave8.png")
                    width: waveTextLayer.width
                    height: waveTextLayer.height
                    fillMode: Image.Stretch
                    x: waveTextLayer.width
                }

                NumberAnimation on x {
                    from: 0
                    to: -waveTextLayer.width
                    duration: 10000
                    loops: Animation.Infinite
                    running: true
                }
            }

            Text {
                id: textMask
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: p3ClockRoot.vw * 2
                text: p3ClockRoot.dateStr
                font.family: "Inter Display"
                font.pixelSize: p3ClockRoot.vw * 6.75
                font.weight: Font.Black
                font.letterSpacing: -p3ClockRoot.vw * 0.65
                color: "white"
                visible: false
            }

            ShaderEffectSource {
                id: textMaskSource
                sourceItem: textMask
                hideSource: true
                visible: false
            }

            MultiEffect {
                source: scrollingBg
                anchors.fill: scrollingBg
                maskEnabled: true
                maskSource: textMaskSource
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
            }
        }

        // ── Lingkaran Cahaya Halo Bulan Kuning Keemasan ──
        Rectangle {
            id: circle1
            z: 60
            anchors.top: parent.top
            anchors.topMargin: p3ClockRoot.vw * 2.3
            anchors.right: parent.right
            anchors.rightMargin: p3ClockRoot.vw * 1.5
            width: p3ClockRoot.vw * 4.2
            height: width
            radius: width / 2
            color: "#ffd200"
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#402b00"
                shadowHorizontalOffset: 1
                shadowVerticalOffset: 1
                shadowBlur: 0.1
            }
        }

        Rectangle {
            id: circle2
            z: 61
            anchors.centerIn: circle1
            width: p3ClockRoot.vw * 4.0
            height: width
            radius: width / 2
            color: "#ffe500"
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#fff72a"
                shadowBlur: p3ClockRoot.vw * 0.3
            }
        }

        // ── Bola Bulan 3D Kosinus Dinamis ──
        Item {
            id: moonSphere
            z: 62
            anchors.centerIn: circle1
            width: p3ClockRoot.vw * 4.0
            height: width
            clip: true

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        width: moonSphere.width
                        height: moonSphere.height
                        radius: moonSphere.width / 2
                        color: "white"
                    }
                }
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
            }

            Rectangle {
                width: parent.width / 2
                height: parent.height
                x: 0
                color: p3ClockRoot.moonPhaseDegree < 180 ? "#ffe700" : "#302c24"
            }
            Rectangle {
                width: parent.width / 2
                height: parent.height
                x: parent.width / 2
                color: p3ClockRoot.moonPhaseDegree < 180 ? "#302c24" : "#ffe700"
            }
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                radius: width / 2
                transform: Scale {
                    origin.x: moonSphere.width / 2
                    origin.y: moonSphere.height / 2
                    xScale: Math.cos(p3ClockRoot.moonPhaseDegree * Math.PI / 180)
                    yScale: 1
                }
                color: Math.cos(p3ClockRoot.moonPhaseDegree * Math.PI / 180) >= 0 ? "#302c24" : "#ffe700"
            }
        }

        // ── Kolom Informasi Fase, Hari, dan Periode di Sebelah Kiri Bulan ──
        Column {
            id: dateMetaCol
            z: 50
            anchors.verticalCenter: circle1.verticalCenter
            anchors.right: circle1.left
            anchors.rightMargin: 16
            spacing: 2

            // Nama Fase Bulan (WAXING CRESCENT / FULL MOON)
            Text {
                anchors.right: parent.right
                text: p3ClockRoot.moonPhaseName
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: p3ClockRoot.vw * 1.15
                font.weight: Font.Bold
                color: "#fffb9f"
                style: Text.Raised
                styleColor: "#635400d9"
            }

            // Teks Hari dalam Pekan (THU) dengan Garis Biru
            Text {
                anchors.right: parent.right
                text: p3ClockRoot.weekdayStr
                font.family: "Inter Display"
                font.pixelSize: p3ClockRoot.vw * 1.5
                font.weight: Font.Black
                font.letterSpacing: 0.5
                color: "#ffffff"
                style: Text.Outline
                styleColor: "#0000ff"
            }

            // Teks Periode Hari (MORNING / AFTER SCHOOL / DARK HOUR)
            Text {
                anchors.right: parent.right
                text: p3ClockRoot.daytimeStr
                font.family: "Inter Display"
                font.pixelSize: p3ClockRoot.vw * 1.3
                font.weight: Font.Black
                font.letterSpacing: -0.3
                color: p3ClockRoot.daytimeStr === "DARK HOUR" ? "#72ff95" : "#00dbff"
                style: Text.Outline
                styleColor: "#002c90"
            }
        }

        // ── Angka Jam Utama Putih Tebal dengan Drop-Shadow Atlus ──
        Text {
            id: timeText
            z: 50
            anchors.verticalCenter: circle1.verticalCenter
            anchors.right: dateMetaCol.left
            anchors.rightMargin: 16
            text: p3ClockRoot.timeStr
            font.family: "Inter Display"
            font.pixelSize: p3ClockRoot.vw * 5.8
            font.weight: Font.Black
            font.letterSpacing: -p3ClockRoot.vw * 0.25
            color: "#ffffff"
            style: Text.Raised
            styleColor: "#d11300b8"
        }
    }
}
