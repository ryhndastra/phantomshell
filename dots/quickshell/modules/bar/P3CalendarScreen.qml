import QtQuick
import QtQuick.Effects
import qs.config

// Layar Transisi Kalender Otentik Persona 3 Reload - Game-Accurate Atlus SEES Calendar
Item {
    id: p3CalRoot
    anchors.fill: parent

    property bool active: false

    // State tanggal aktif terikat ke PhantomState.calendarDayOffset
    property int dayOffset: PhantomState.calendarDayOffset
    property var realToday: new Date()
    property var selectedDate: {
        const now = realToday
        const base = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12, 0, 0)
        return new Date(base.getTime() + dayOffset * 86400000)
    }

    readonly property int currentYear: selectedDate.getFullYear()
    readonly property int currentMonth: selectedDate.getMonth()
    readonly property int currentDay: selectedDate.getDate()
    readonly property int currentDayOfWeek: selectedDate.getDay() // 0 = Sun, 6 = Sat

    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    readonly property var weekdayNames: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    readonly property string monthNameStr: monthNames[currentMonth]
    readonly property string monthNumStr: String(currentMonth + 1)
    readonly property string yearStr: String(currentYear)
    readonly property string dayNumStr: String(currentDay)
    readonly property string weekdayStr: weekdayNames[currentDayOfWeek]

    // Geometri persilangan otentik (Ribbon biru -14.5° dan Rel timeline +35.5°)
    readonly property real cx: width * 0.58
    readonly property real cy: height * 0.54
    readonly property real ribbonAngle: -14.5
    readonly property real railAngle: 35.5
    readonly property real ribbonHeight: 154.0
    readonly property real daySpacing: 156.0

    // Animasi pergeseran rel yang halus saat navigasi hari
    property real visualRailSlide: 0.0
    Behavior on visualRailSlide {
        NumberAnimation {
            duration: 240
            easing.type: Easing.OutBack
            easing.overshoot: 1.12
        }
    }

    // Fungsi navigasi hari dan bulan
    function advanceDay(delta) {
        visualRailSlide += delta * daySpacing
        PhantomState.calendarDayOffset += delta
        railSlideResetTimer.restart()
        PhantomState.playSfx("hover")
    }

    function advanceMonth(delta) {
        const d = new Date(selectedDate)
        d.setMonth(d.getMonth() + delta)
        const base = new Date(realToday.getFullYear(), realToday.getMonth(), realToday.getDate(), 12, 0, 0)
        PhantomState.calendarDayOffset = Math.round((d.getTime() - base.getTime()) / 86400000)
        visualRailSlide = 0.0
        PhantomState.playSfx("select")
    }

    function resetToToday() {
        PhantomState.calendarDayOffset = 0
        visualRailSlide = 0.0
        PhantomState.playSfx("select")
    }

    Timer {
        id: railSlideResetTimer
        interval: 16
        onTriggered: p3CalRoot.visualRailSlide = 0.0
    }

    // Perhitungan derajat fase bulan astronomis (0 - 360)
    function calcMoonDegree(dateObj) {
        const cycleLength = 29.53059
        const knownNewMoon = new Date('2024-03-10T15:00:00Z')
        const daysSince = (dateObj.getTime() - knownNewMoon.getTime()) / 86400000
        const percentage = ((daysSince % cycleLength) + cycleLength) % cycleLength / cycleLength
        var deg = 360 - Math.floor(percentage * 360)
        if (deg >= 355 || deg <= 5) return 0
        if (deg >= 175 && deg <= 185) return 180
        return deg % 360
    }

    // Tangkapan keyboard & mouse wheel
    focus: true
    Keys.onLeftPressed: advanceDay(-1)
    Keys.onRightPressed: advanceDay(1)
    Keys.onUpPressed: advanceMonth(1)
    Keys.onDownPressed: advanceMonth(-1)
    Keys.onSpacePressed: resetToToday()
    Keys.onEscapePressed: PhantomState.calendarOpen = false
    Keys.onPressed: event => {
        if (event.key === Qt.Key_PageUp) {
            advanceMonth(-1)
            event.accepted = true
        } else if (event.key === Qt.Key_PageDown) {
            advanceMonth(1)
            event.accepted = true
        }
    }

    onActiveChanged: {
        if (active) {
            realToday = new Date()
            visualRailSlide = 0.0
            p3CalRoot.forceActiveFocus()
            entryAnim.restart()
        }
    }

    // ── 1. Latar Belakang Tartarus Deep Midnight Otentik ──
    Rectangle {
        id: bgDark
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#090d19" }
            GradientStop { position: 0.35; color: "#0e1528" }
            GradientStop { position: 0.65; color: "#11182e" }
            GradientStop { position: 1.0; color: "#070a14" }
        }
    }

    // Area interaksi klik luar untuk menutup popup kalender & scroll wheel
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onWheel: event => {
            if (event.angleDelta.y > 0) {
                p3CalRoot.advanceDay(1)
            } else if (event.angleDelta.y < 0) {
                p3CalRoot.advanceDay(-1)
            }
        }
        onClicked: PhantomState.calendarOpen = false
    }

    // ── 2. Pita Biru Kobalt Diagonal Persona 3 Reload (-14.5°) ──
    Item {
        id: ribbonContainer
        x: p3CalRoot.cx - width / 2
        y: p3CalRoot.cy - height / 2
        width: p3CalRoot.width * 2.6
        height: p3CalRoot.ribbonHeight
        rotation: p3CalRoot.ribbonAngle
        transformOrigin: Item.Center

        // Bilah warna biru kobalt Atlus yang kaya dan pekat
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#003b9e" }
                GradientStop { position: 0.35; color: "#004ebf" }
                GradientStop { position: 0.70; color: "#005ad4" }
                GradientStop { position: 1.0; color: "#003d9e" }
            }
        }

        // Stempel Tanggal Kiri (Tahun, Nama Bulan, Angka Raksasa)
        // Posisi di sepertiga kiri pita, rotasi balasan +14.5° agar teks tegak lurus sempurna
        Item {
            id: monthStampArea
            x: ribbonContainer.width * 0.33
            anchors.verticalCenter: parent.verticalCenter
            width: 320
            height: p3CalRoot.ribbonHeight
            rotation: -p3CalRoot.ribbonAngle
            transformOrigin: Item.Center

            // Penahan klik agar tidak menutup kalender
            MouseArea { anchors.fill: parent }

            Row {
                anchors.centerIn: parent
                spacing: 14

                // Blok Tahun & Nama Bulan
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        text: p3CalRoot.yearStr
                        color: "#ffffff"
                        font.family: "Inter Display"
                        font.pixelSize: 32
                        font.weight: Font.Black
                        font.letterSpacing: -0.5
                    }

                    Text {
                        text: p3CalRoot.monthNameStr
                        color: "#ffffff"
                        font.family: "Inter Display"
                        font.pixelSize: 21
                        font.weight: Font.Bold
                    }
                }

                // Angka Bulan Raksasa Menembus Batas Pita (Otentik P3R)
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: p3CalRoot.monthNumStr
                    color: "#ffffff"
                    font.family: "Bebas Neue"
                    font.pixelSize: 206
                    font.weight: Font.Black
                    font.letterSpacing: 2
                }
            }
        }
    }

    // ── 3. Rel Garis Putih Diagonal Bersilang (+35.5°) ──
    Item {
        id: railContainer
        x: p3CalRoot.cx
        y: p3CalRoot.cy
        rotation: -p3CalRoot.railAngle
        transformOrigin: Item.Center

        // Garis putih membelah layar dengan presisi 4px
        Rectangle {
            anchors.centerIn: parent
            width: p3CalRoot.width * 2.8
            height: 4.0
            color: "#ffffff"
        }

        // Kontainer strip tanggal yang bergeser sepanjang rel
        Item {
            id: daysStrip
            x: -p3CalRoot.visualRailSlide
            y: 0

            // Rentang 11 hari berurutan sekeliling hari terpilih (-5 s/d +5)
            Repeater {
                model: [
                    { offset: -5 },
                    { offset: -4 },
                    { offset: -3 },
                    { offset: -2 },
                    { offset: -1 },
                    { offset:  0 },
                    { offset:  1 },
                    { offset:  2 },
                    { offset:  3 },
                    { offset:  4 },
                    { offset:  5 }
                ]

                delegate: Item {
                    id: dayNode
                    required property var modelData

                    readonly property int off: modelData.offset
                    readonly property var nodeDate: {
                        const t = p3CalRoot.selectedDate.getTime() + off * 86400000
                        return new Date(t)
                    }
                    readonly property int nodeDayNum: nodeDate.getDate()
                    readonly property int nodeDow: nodeDate.getDay()
                    readonly property string nodeDowStr: p3CalRoot.weekdayNames[nodeDow]
                    readonly property bool isSat: nodeDow === 6
                    readonly property bool isSun: nodeDow === 0
                    readonly property real nodeMoonDeg: p3CalRoot.calcMoonDegree(nodeDate)
                    readonly property bool isCenter: off === 0

                    x: off * p3CalRoot.daySpacing
                    y: 0
                    rotation: p3CalRoot.railAngle // rotasi balasan agar teks & bulan tetap tegak lurus

                    // ══════════════════════════════════════════════════════
                    // KASUS 1: HARI BIASA (off !== 0) DI LUAR PITA BIRU
                    // ══════════════════════════════════════════════════════

                    // Teks Tanggal Hari Biasa (Di Sisi Kiri-Atas Garis Rel: y = -38)
                    Item {
                        id: normalDateText
                        visible: !dayNode.isCenter
                        x: -24
                        y: -38
                        width: 78
                        height: 38

                        Row {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            spacing: 5

                            Text {
                                text: String(dayNode.nodeDayNum)
                                color: "#ffffff"
                                font.family: "Bebas Neue"
                                font.pixelSize: 38
                                font.weight: Font.Black
                                anchors.bottom: parent.bottom
                            }

                            Column {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 4
                                spacing: 2

                                Text {
                                    text: dayNode.nodeDowStr
                                    color: "#ffffff"
                                    font.family: "Bebas Neue"
                                    font.pixelSize: 16
                                    font.weight: Font.Black
                                }

                                // Garis bawah biru untuk Sabtu, merah untuk Minggu
                                Rectangle {
                                    width: parent.width
                                    height: 3.2
                                    color: dayNode.isSat ? "#00a8e8" : (dayNode.isSun ? "#ff3355" : "transparent")
                                    visible: dayNode.isSat || dayNode.isSun
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: p3CalRoot.advanceDay(dayNode.off)
                        }
                    }

                    // Bola Bulan 3D Hari Biasa (Di Sisi Kanan-Bawah Garis Rel: y = +22)
                    Item {
                        id: normalMoonSphere
                        visible: !dayNode.isCenter
                        x: 22
                        y: 20
                        width: 34
                        height: 34

                        P3MoonSphere {
                            anchors.fill: parent
                            moonDegree: dayNode.nodeMoonDeg
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: p3CalRoot.advanceDay(dayNode.off)
                        }
                    }

                    // ══════════════════════════════════════════════════════
                    // KASUS 2: HARI PUSAT TERPILIH (off === 0) DI DALAM PITA
                    // ══════════════════════════════════════════════════════

                    // Lencana Riak Air & Tanggal Pusat (Di Sisi Kiri-Atas Garis Rel: y = -42)
                    Item {
                        id: centerRippleCluster
                        visible: dayNode.isCenter
                        x: -32
                        y: -42
                        width: 90
                        height: 90

                        // Cincin Riak Luar
                        Rectangle {
                            anchors.centerIn: parent
                            width: 178 * ripplePulseAnim.scaleFactor
                            height: width
                            radius: width / 2
                            color: "transparent"
                            border.color: "#3082f0"
                            border.width: 2.0
                            opacity: 0.45 * ripplePulseAnim.opacityFactor
                        }

                        // Cincin Riak Tengah
                        Rectangle {
                            anchors.centerIn: parent
                            width: 122 * ripplePulseAnim.scaleFactor
                            height: width
                            radius: width / 2
                            color: "transparent"
                            border.color: "#3ea2ff"
                            border.width: 3.0
                            opacity: 0.70 * ripplePulseAnim.opacityFactor
                        }

                        // Piringan Biru Pekat Pusat Riak
                        Rectangle {
                            anchors.centerIn: parent
                            width: 80
                            height: width
                            radius: width / 2
                            color: "#1658b4"
                            border.color: "#52a6ff"
                            border.width: 4.0
                            opacity: 0.95
                        }

                        // Teks Hari & Angka Terpilih
                        Row {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: String(dayNode.nodeDayNum)
                                color: "#ffffff"
                                font.family: "Bebas Neue"
                                font.pixelSize: 52
                                font.weight: Font.Black
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: dayNode.nodeDowStr
                                    color: "#ffffff"
                                    font.family: "Bebas Neue"
                                    font.pixelSize: 22
                                    font.weight: Font.Black
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 3.2
                                    color: dayNode.isSat ? "#00a8e8" : (dayNode.isSun ? "#ff3355" : "transparent")
                                    visible: dayNode.isSat || dayNode.isSun
                                }
                            }
                        }
                    }

                    // Lambang Bulan Emas Hari Pusat (Di Sisi Kanan-Bawah Garis Rel: y = +20)
                    Item {
                        id: centerGoldenMoon
                        visible: dayNode.isCenter
                        x: 22
                        y: 16
                        width: 44
                        height: 44

                        // Bayangan lembut khas P3R
                        Rectangle {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 3
                            width: 42
                            height: 42
                            radius: 21
                            color: "#70000000"
                        }

                        // Cincin putih luar
                        Rectangle {
                            anchors.centerIn: parent
                            width: 44
                            height: 44
                            radius: 22
                            color: "#081020"
                            border.color: "#ffffff"
                            border.width: 3.5
                        }

                        // Piringan emas bercahaya
                        Rectangle {
                            anchors.centerIn: parent
                            width: 32
                            height: 32
                            radius: 16
                            color: "#ffd200"
                            border.color: "#cf9e00"
                            border.width: 1.2

                            Rectangle {
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                radius: 12
                                color: "#ffe055"
                                opacity: 0.4
                            }
                        }
                    }
                }
            }
        }
    }

    // Animasi riak air berdenyut lembut
    SequentialAnimation {
        id: ripplePulseAnim
        running: p3CalRoot.active
        loops: Animation.Infinite
        property real scaleFactor: 1.0
        property real opacityFactor: 1.0

        ParallelAnimation {
            NumberAnimation { target: ripplePulseAnim; property: "scaleFactor"; from: 0.94; to: 1.06; duration: 1600; easing.type: Easing.InOutSine }
            NumberAnimation { target: ripplePulseAnim; property: "opacityFactor"; from: 0.65; to: 1.0; duration: 1600; easing.type: Easing.InOutSine }
        }
        ParallelAnimation {
            NumberAnimation { target: ripplePulseAnim; property: "scaleFactor"; from: 1.06; to: 0.94; duration: 1600; easing.type: Easing.InOutSine }
            NumberAnimation { target: ripplePulseAnim; property: "opacityFactor"; from: 1.0; to: 0.65; duration: 1600; easing.type: Easing.InOutSine }
        }
    }

    // ── 4. Bilah Kontrol & Petunjuk Pintasan Khas Persona 3 Reload ──
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 60

        // Petunjuk Keyboard Sisi Kiri
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 42
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            Text {
                text: "[SCROLL / ← →] NAVIGATE"
                color: "#5b769f"
                font.family: "Bebas Neue"
                font.pixelSize: 17
                font.letterSpacing: 1
            }

            Text {
                text: "[↑ ↓] MONTH"
                color: "#5b769f"
                font.family: "Bebas Neue"
                font.pixelSize: 17
                font.letterSpacing: 1
            }

            Text {
                text: "[SPACE] TODAY"
                color: "#5b769f"
                font.family: "Bebas Neue"
                font.pixelSize: 17
                font.letterSpacing: 1
            }

            Text {
                text: "[ESC] RETURN"
                color: "#5b769f"
                font.family: "Bebas Neue"
                font.pixelSize: 17
                font.letterSpacing: 1
            }
        }

        // Tombol Interaktif Sisi Kanan
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 42
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            // Tombol Lompat ke Hari Ini
            Rectangle {
                width: todayBtnTxt.implicitWidth + 28
                height: 30
                radius: 4
                color: todayBtnMouse.containsMouse ? "#0062d2" : "#0c1529"
                border.color: "#ffffff"
                border.width: 1.5

                Text {
                    id: todayBtnTxt
                    anchors.centerIn: parent
                    text: "TODAY"
                    color: "#ffffff"
                    font.family: "Bebas Neue"
                    font.pixelSize: 16
                    font.weight: Font.Black
                    font.letterSpacing: 1
                }

                MouseArea {
                    id: todayBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: p3CalRoot.resetToToday()
                }
            }

            // Tombol Tutup / Kembali
            Rectangle {
                width: returnBtnTxt.implicitWidth + 28
                height: 30
                radius: 4
                color: returnBtnMouse.containsMouse ? "#ff3355" : "#0c1529"
                border.color: "#ffffff"
                border.width: 1.5

                Text {
                    id: returnBtnTxt
                    anchors.centerIn: parent
                    text: "RETURN"
                    color: "#ffffff"
                    font.family: "Bebas Neue"
                    font.pixelSize: 16
                    font.weight: Font.Black
                    font.letterSpacing: 1
                }

                MouseArea {
                    id: returnBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PhantomState.calendarOpen = false
                }
            }
        }
    }

    // Tanda air khas Atlus / SEES di sudut kanan bawah
    Text {
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        text: "CARAK GEEA • SEES CALENDAR TRANSITION"
        color: "#18243c"
        font.family: "JetBrainsMono NFM"
        font.pixelSize: 9
        font.weight: Font.Black
    }

    // ── Animasi Pembuka Layar P3R ──
    ParallelAnimation {
        id: entryAnim

        NumberAnimation {
            target: p3CalRoot
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 220
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: ribbonContainer
            property: "scale"
            from: 0.94
            to: 1.0
            duration: 260
            easing.type: Easing.OutBack
            easing.overshoot: 1.05
        }

        NumberAnimation {
            target: railContainer
            property: "scale"
            from: 0.88
            to: 1.0
            duration: 280
            easing.type: Easing.OutBack
            easing.overshoot: 1.10
        }
    }
}
