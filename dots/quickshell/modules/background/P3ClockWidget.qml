import QtQuick
import QtQuick.Effects

// Widget Tanggal & Lunar HUD otentik Persona 3 Reload - Game-Accurate Atlus HUD
Item {
    id: p3ClockRoot
    implicitWidth: 660
    implicitHeight: 140

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

    // Format Tanggal Asli Persona 3 Reload: M/D (contoh 11/5 atau 4/20)
    readonly property string p3DateStr: {
        const m = (p3ClockRoot.currentTime.getMonth() + 1).toString()
        const d = p3ClockRoot.currentTime.getDate().toString()
        return m + "/" + d
    }

    // Nama Hari Asli Persona 3 Reload (Mon, Tue, Wed, Thu, Fri, Sat, Sun)
    readonly property string p3WeekdayStr: {
        const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days[p3ClockRoot.currentTime.getDay()]
    }

    readonly property int currentHour: p3ClockRoot.currentTime.getHours()

    // Penentuan Periode Waktu Persona 3 Reload
    readonly property string periodId: {
        const h = currentHour
        if (h >= 0 && h < 1) return "darkhour"     // 00:00 - 01:00 Dark Hour
        if (h >= 1 && h < 6) return "latenight"    // 01:00 - 06:00 Late Night
        if (h >= 6 && h < 12) return "morning"     // 06:00 - 12:00 Morning
        if (h >= 12 && h < 17) return "afterschool"// 12:00 - 17:00 After School
        if (h >= 17 && h < 20) return "evening"    // 17:00 - 20:00 Evening
        return "night"                              // 20:00 - 24:00 Night
    }

    readonly property string watermarkText: {
        switch (periodId) {
            case "darkhour": return "DARK HOUR"
            case "morning": return "MORNING"
            case "afterschool": return "AFTER SCHOOL"
            case "evening": return "EVENING"
            case "latenight": return "LATE NIGHT"
            default: return "NIGHT"
        }
    }

    readonly property string periodLabel: {
        switch (periodId) {
            case "darkhour": return "Dark Hour"
            case "morning": return "Morning"
            case "afterschool": return "After School"
            case "evening": return "Evening"
            case "latenight": return "Late Night"
            default: return "Night"
        }
    }

    // Warna Aksen Dinamis Berdasarkan Waktu
    readonly property color periodColor: {
        switch (periodId) {
            case "darkhour": return "#72ff95"  // Hijau Neon Ikonik Dark Hour
            case "morning": return "#00dbff"   // Biru Cyan Listrik P3 Atlus
            case "afterschool": return "#29b6f6" // Biru Cerah Sore
            case "evening": return "#ff9f43"   // Kuning-Oranye Sunset Dusk
            case "latenight": return "#82b1ff" // Biru Indigo Larut Malam
            default: return "#54a0ff"
        }
    }

    // Warna Tinting Gelombang Air
    readonly property color waveColorTint: {
        switch (periodId) {
            case "darkhour": return "#2ed573"
            case "evening": return "#ee5253"
            case "latenight": return "#341f97"
            default: return "#0099ff"
        }
    }

    readonly property real waveColorization: {
        return periodId === "darkhour" ? 0.92 : (periodId === "evening" ? 0.85 : (periodId === "latenight" ? 0.60 : 0.0))
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

        // ── Gelombang Air Laut Latar Belakang (Dinamis Berubah Warna Mengikuti Waktu) ──
        Item {
            id: waveContainerOuter
            z: 1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
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
                        duration: 12000 + wavePairDelegate.index * 1800
                        loops: Animation.Infinite
                        running: true
                    }
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                colorization: p3ClockRoot.waveColorization
                colorizationColor: p3ClockRoot.waveColorTint
                maskEnabled: true
                maskSource: ShaderEffectSource {
                    sourceItem: Rectangle {
                        width: waveContainerOuter.width
                        height: waveContainerOuter.height
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.12; color: "white" }
                            GradientStop { position: 1.0; color: "white" }
                        }
                    }
                }
            }
        }

        // ── Teks Watermark Raksasa Latar Belakang (DARK HOUR / MORNING / EVENING) ──
        Text {
            id: bgWatermark
            z: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 6
            anchors.left: parent.left
            anchors.leftMargin: 30
            text: p3ClockRoot.watermarkText
            font.family: "Inter Display"
            font.pixelSize: 88
            font.weight: Font.Black
            font.letterSpacing: -2
            color: p3ClockRoot.periodColor
            opacity: 0.22
            rotation: -5
        }

        // ── Badge Jam Digital Sistem (Menyatu Rapi di Sebelah Kiri Banner) ──
        Item {
            id: sysTimeBadge
            z: 50
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.centerIn: parent
                width: sysTimeRow.implicitWidth + 20
                height: 32
                radius: 4
                color: Qt.rgba(2/255, 7/255, 24/255, 0.75)
                border.color: Qt.rgba(p3ClockRoot.periodColor.r, p3ClockRoot.periodColor.g, p3ClockRoot.periodColor.b, 0.5)
                border.width: 1

                Row {
                    id: sysTimeRow
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 6; height: 6
                        radius: 3
                        color: p3ClockRoot.periodColor
                        anchors.verticalCenter: parent.verticalCenter
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.3; to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1.0; to: 0.3; duration: 1000; easing.type: Easing.InOutQuad }
                        }
                    }

                    Text {
                        text: p3ClockRoot.timeStr
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 18
                        font.weight: Font.Black
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // ── Lingkaran Cahaya Halo Bulan Kuning Keemasan ──
        Rectangle {
            id: circle1
            z: 60
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 18
            width: 76
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
            width: 72
            height: width
            radius: width / 2
            color: "#ffe500"
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#fff72a"
                shadowBlur: 0.3
            }
        }

        // ── Bola Bulan 3D Kosinus Dinamis ──
        Item {
            id: moonSphere
            z: 62
            anchors.centerIn: circle1
            width: 72
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

        // ── Nama Fase Bulan Di Atas Lingkaran Bulan ──
        Text {
            id: moonPhaseTxt
            z: 50
            anchors.bottom: circle1.top
            anchors.bottomMargin: 4
            anchors.right: circle1.right
            text: p3ClockRoot.moonPhaseName
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            font.weight: Font.Bold
            color: "#fffb9f"
            style: Text.Raised
            styleColor: "#635400d9"
        }

        // ── Kluster HUD Tanggal & Periode Otentik Persona 3 Reload (Foto 1 & 6) ──
        Item {
            id: p3DateCluster
            z: 50
            anchors.verticalCenter: circle1.verticalCenter
            anchors.right: circle1.left
            anchors.rightMargin: 20
            width: dateClusterCol.implicitWidth
            height: dateClusterCol.implicitHeight
            rotation: -5

            Column {
                id: dateClusterCol
                spacing: -4

                // Baris Tanggal M/D dan Hari dengan Penanda Segitiga Terbalik ▼
                Row {
                    spacing: 8
                    anchors.right: parent.right

                    // Angka Tanggal M/D Putih Tebal Miring (Contoh 4/20 atau 11/5)
                    Text {
                        text: p3ClockRoot.p3DateStr
                        font.family: "Inter Display"
                        font.pixelSize: 66
                        font.weight: Font.Black
                        font.letterSpacing: -3
                        color: "#ffffff"
                        style: Text.Raised
                        styleColor: Qt.rgba(0, 0, 0, 0.65)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Kolom Hari dalam Pekan dan Segitiga Terbalik
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        // Segitiga Terbalik Ikonik S.E.E.S. ▼
                        Canvas {
                            width: 18
                            height: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.beginPath()
                                ctx.moveTo(0, 0)
                                ctx.lineTo(18, 0)
                                ctx.lineTo(9, 12)
                                ctx.closePath()
                                ctx.fillStyle = "#000b21"
                                ctx.fill()
                                ctx.strokeStyle = p3ClockRoot.periodColor
                                ctx.lineWidth = 1.5
                                ctx.stroke()
                            }
                        }

                        // Teks Hari (Mon / Thu)
                        Text {
                            text: p3ClockRoot.p3WeekdayStr
                            font.family: "Inter Display"
                            font.pixelSize: 22
                            font.weight: Font.Black
                            color: "#ffffff"
                            style: Text.Outline
                            styleColor: "#000b21"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Teks Periode Waktu Bersinar di Bawah Tanggal (Dark Hour / Morning / Evening)
                Text {
                    anchors.right: parent.right
                    text: p3ClockRoot.periodLabel
                    font.family: "Inter Display"
                    font.pixelSize: 24
                    font.weight: Font.Black
                    font.letterSpacing: -0.5
                    color: p3ClockRoot.periodColor
                    style: Text.Outline
                    styleColor: "#000b21"
                }
            }
        }
    }
}
