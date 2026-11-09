import QtQuick
import QtQuick.Effects
import qs.config

// Layar Kalender Otentik Persona 3 Reload - 1:1 Persona-Quickshell (Yujonpradhananga)
Item {
    id: p3CalRoot
    anchors.fill: parent

    property bool active: false

    // State tanggal aktif dan navigasi
    property int dayOffset: PhantomState.calendarDayOffset
    property var realToday: new Date()
    property var selectedDate: {
        const now = realToday
        const base = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12, 0, 0)
        return new Date(base.getTime() + dayOffset * 86400000)
    }

    readonly property int currentYear: selectedDate.getFullYear()
    readonly property int currentMonth: selectedDate.getMonth()
    readonly property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    readonly property string monthNameStr: monthNames[currentMonth]
    readonly property string monthNumStr: String(currentMonth + 1)

    function advanceDay(delta) {
        PhantomState.calendarDayOffset += delta
        PhantomState.playSfx("hover")
    }

    function advanceMonth(delta) {
        const d = new Date(selectedDate)
        d.setMonth(d.getMonth() + delta)
        const base = new Date(realToday.getFullYear(), realToday.getMonth(), realToday.getDate(), 12, 0, 0)
        PhantomState.calendarDayOffset = Math.round((d.getTime() - base.getTime()) / 86400000)
        PhantomState.playSfx("select")
    }

    function resetToToday() {
        PhantomState.calendarDayOffset = 0
        PhantomState.playSfx("select")
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
            p3CalRoot.forceActiveFocus()
        }
    }

    // ── 1. Background Indigo Gelap Otentik P3R (#0b113d) ──
    Rectangle {
        anchors.fill: parent
        color: "#0b113d"
        z: 0
    }

    // Area interaksi klik luar & scroll wheel
    MouseArea {
        anchors.fill: parent
        z: 0
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

    // ── 2. Pita Biru Miring (bluebar - #1a4fa8 rotasi +20.0°) ──
    Item {
        anchors.fill: parent
        z: 1
        clip: true

        Item {
            x: parent.width * 0.50
            y: parent.height * 0.458
            rotation: 20.0

            Rectangle {
                anchors.centerIn: parent
                width: p3CalRoot.width * 2.5
                height: p3CalRoot.height * 0.22
                color: "#1a4fa8"
            }
        }
    }

    // ── 3. Garis Rel Putih Menyilang (whiteline - rotasi -20.0°) ──
    Item {
        anchors.fill: parent
        z: 2
        clip: true

        Item {
            x: parent.width * 0.50
            y: parent.height * 0.539
            rotation: -20.0

            Rectangle {
                anchors.centerIn: parent
                width: p3CalRoot.width * 2.5
                height: 4.5
                color: "#ffffff"
            }
        }
    }

    // ── 4. Label Tahun & Bulan (Di dalam pita sisi kiri atas) ──
    Item {
        z: 3
        x: parent.width * 0.05
        y: parent.height * 0.11
        width: 450
        height: 260

        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: -4

            Text {
                text: String(p3CalRoot.currentYear)
                font.family: "Montserrat Alternates"
                font.pixelSize: 56
                font.bold: true
                color: "#ffffff"
            }

            Text {
                text: p3CalRoot.monthNameStr
                font.family: "Inter Display"
                font.pixelSize: 28
                font.bold: true
                color: "#b4c8ff"
            }
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 195
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -12
            text: p3CalRoot.monthNumStr
            font.family: "Montserrat Alternates"
            font.pixelSize: 220
            font.bold: true
            color: "#ffffff"
        }
    }

    // ── 5. Kontainer 7 Entri Tanggal Sepanjang Rel Putih ──
    Item {
        id: datesContainer
        anchors.fill: parent
        z: 4

        readonly property real slopeTan: Math.tan(20.0 * Math.PI / 180.0) // 0.36397
        readonly property real railCenterY: parent.height * 0.539
        readonly property real railCenterX: parent.width * 0.50

        Repeater {
            model: 7

            delegate: CalendarEntry {
                required property int index

                readonly property int offset: index - 3
                readonly property var entryDate: {
                    var d = new Date(p3CalRoot.realToday)
                    d.setDate(d.getDate() + offset + p3CalRoot.dayOffset)
                    d.setHours(12, 0, 0, 0)
                    return d
                }
                readonly property bool isToday: offset === 0
                readonly property bool isPast: offset < 0
                readonly property real t: index / 6.0

                // Posisi X linier di sepanjang layar
                readonly property real targetX: datesContainer.width * (0.24 + t * 0.64)
                // Posisi Y persis pada garis rel putih
                readonly property real targetY: datesContainer.railCenterY - datesContainer.slopeTan * (targetX - datesContainer.railCenterX)

                x: targetX
                y: targetY

                dateObj: entryDate
                todayFlag: isToday
                pastFlag: isPast
            }
        }
    }

    // ── 6. Komponen Entri Kalender Otentik (Angka, Riak, dan Fase Bulan) ──
    component CalendarEntry: Item {
        id: entryRoot
        required property var dateObj
        required property bool todayFlag
        required property bool pastFlag

        readonly property int offset: {
            var d = new Date(p3CalRoot.realToday)
            d.setHours(12, 0, 0, 0)
            return Math.round((dateObj - d) / 86400000)
        }

        // Skala perspektif 3D mendalam khas Persona 3 Reload
        readonly property real scaleFactor: todayFlag ? 1.0 : (offset === -3 ? 0.50 : offset === -2 ? 0.65 : offset === -1 ? 0.80 : offset === 1 ? 1.15 : offset === 2 ? 1.30 : 1.45)
        readonly property real alphaVal: todayFlag ? 1.0 : (offset === -3 ? 0.45 : offset === -2 ? 0.65 : offset === -1 ? 0.85 : offset === 1 ? 0.90 : offset === 2 ? 0.75 : 0.60)
        readonly property real numSize: todayFlag ? 95 : Math.round(95 * scaleFactor)
        readonly property real dayLabelSize: todayFlag ? 22 : Math.round(22 * scaleFactor)

        readonly property real moonPhaseDeg: {
            const synodicMonth = 29.53059
            const ref = new Date(Date.UTC(2000, 0, 6, 18, 14))
            const diffDays = (dateObj - ref) / 86400000
            const days = ((diffDays % synodicMonth) + synodicMonth) % synodicMonth
            var deg = 360 - Math.floor((days / synodicMonth) * 360)
            if (deg >= 355 || deg <= 5)
                return 0
            if (deg >= 175 && deg <= 185)
                return 180
            return deg
        }

        readonly property var dayNames: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        readonly property int dayOfWeek: dateObj.getDay()
        readonly property bool isSunday: dayOfWeek === 0
        readonly property bool isSaturday: dayOfWeek === 6

        width: 1
        height: 1
        opacity: alphaVal

        // Cincin Riak Air Konsentris Biru (#4a88f0) untuk Hari Aktif (Today)
        Item {
            visible: entryRoot.todayFlag
            anchors.centerIn: dayNumText
            anchors.horizontalCenterOffset: 0
            width: entryRoot.numSize * 2.3
            height: width
            z: -1

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: width
                radius: width / 2
                color: "transparent"
                border.color: "#4a88f0"
                border.width: 14
                opacity: 0.55
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.66
                height: width
                radius: width / 2
                color: "transparent"
                border.color: "#4a88f0"
                border.width: 9
                opacity: 0.65
            }
        }

        // Angka Tanggal - Duduk persis di ATAS garis rel putih
        Text {
            id: dayNumText
            anchors.left: parent.left
            anchors.bottom: parent.top
            anchors.bottomMargin: 8
            text: String(entryRoot.dateObj.getDate())
            font.family: "Montserrat Alternates"
            font.pixelSize: entryRoot.numSize
            font.bold: true
            color: "#ffffff"
        }

        // Teks Hari (SUN/MON/...) & Garis Bawah
        Column {
            id: dayLabelCol
            anchors.left: dayNumText.right
            anchors.leftMargin: 6
            anchors.bottom: dayNumText.bottom
            anchors.bottomMargin: entryRoot.todayFlag ? 14 : Math.max(6, 8 * entryRoot.scaleFactor)
            spacing: 2

            Text {
                text: entryRoot.dayNames[entryRoot.dayOfWeek]
                font.family: "Inter Display"
                font.pixelSize: entryRoot.dayLabelSize
                font.bold: true
                color: entryRoot.isSunday ? "#ff4444" : entryRoot.isSaturday ? "#4488ff" : "#ffffff"
            }

            Rectangle {
                visible: entryRoot.isSunday || entryRoot.isSaturday
                width: parent.children[0].implicitWidth
                height: 2.0
                color: entryRoot.isSunday ? "#ff4444" : "#4488ff"
            }
        }

        // Bola Bulan 3D di BAWAH garis rel putih
        Item {
            id: moonItem
            readonly property real moonR: entryRoot.todayFlag ? 36 : Math.max(14, 25 * entryRoot.scaleFactor)
            readonly property color litColor: entryRoot.todayFlag ? "#ffe700" : "#f0f4fc"
            readonly property color darkColor: entryRoot.todayFlag ? "#2a2720" : "#1a1e2d"

            anchors.horizontalCenter: dayLabelCol.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 12
            width: moonR * 2
            height: moonR * 2

            // Cincin Emas Mengelilingi Bulan Hari Ini
            Rectangle {
                visible: entryRoot.todayFlag
                anchors.centerIn: parent
                width: parent.moonR * 2 + 8
                height: width
                radius: width / 2
                color: "transparent"
                border.color: "#ffe700"
                border.width: 2.5
            }

            // Faint border rim
            Rectangle {
                anchors.centerIn: parent
                width: parent.moonR * 2
                height: width
                radius: width / 2
                color: "transparent"
                border.color: entryRoot.todayFlag ? "#ffe700" : "#3b4462"
                border.width: 1.0
                opacity: 0.6
                z: 2
            }

            Item {
                id: moonSphere
                anchors.centerIn: parent
                width: parent.moonR * 2
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
                    color: entryRoot.moonPhaseDeg < 180 ? moonItem.litColor : moonItem.darkColor
                }

                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    x: parent.width / 2
                    color: entryRoot.moonPhaseDeg < 180 ? moonItem.darkColor : moonItem.litColor
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    radius: width / 2
                    transform: Scale {
                        origin.x: moonSphere.width / 2
                        origin.y: moonSphere.height / 2
                        xScale: Math.max(0.001, Math.abs(Math.cos(entryRoot.moonPhaseDeg * Math.PI / 180)))
                        yScale: 1
                    }
                    color: Math.cos(entryRoot.moonPhaseDeg * Math.PI / 180) >= 0 ? moonItem.darkColor : moonItem.litColor
                }
            }
        }

        // Animasi transisi halus saat tanggal bergeser
        Behavior on x {
            SpringAnimation {
                spring: 2.2
                damping: 0.35
            }
        }
        Behavior on y {
            SpringAnimation {
                spring: 2.2
                damping: 0.35
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        // Klik untuk memusatkan hari ini
        MouseArea {
            anchors.fill: parent
            anchors.margins: -10
            cursorShape: Qt.PointingHandCursor
            onClicked: p3CalRoot.advanceDay(entryRoot.offset)
        }
    }

    // ── 7. Bilah Bawah & Petunjuk Navigasi ──
    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 56
        z: 10

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 40
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            Text {
                text: "[SCROLL / ← →] NAVIGATE"
                color: "#6c85b5"
                font.family: "Inter Display"
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                text: "[SPACE] TODAY"
                color: "#6c85b5"
                font.family: "Inter Display"
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                text: "[ESC] RETURN"
                color: "#6c85b5"
                font.family: "Inter Display"
                font.pixelSize: 13
                font.bold: true
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Rectangle {
                width: todayBtnTxt.implicitWidth + 24
                height: 28
                radius: 4
                color: todayBtnMouse.containsMouse ? "#1a4fa8" : "#0d173d"
                border.color: "#ffffff"
                border.width: 1.5

                Text {
                    id: todayBtnTxt
                    anchors.centerIn: parent
                    text: "TODAY"
                    color: "#ffffff"
                    font.family: "Inter Display"
                    font.pixelSize: 12
                    font.bold: true
                }

                MouseArea {
                    id: todayBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: p3CalRoot.resetToToday()
                }
            }

            Rectangle {
                width: returnBtnTxt.implicitWidth + 24
                height: 28
                radius: 4
                color: returnBtnMouse.containsMouse ? "#ff4444" : "#0d173d"
                border.color: "#ffffff"
                border.width: 1.5

                Text {
                    id: returnBtnTxt
                    anchors.centerIn: parent
                    text: "RETURN"
                    color: "#ffffff"
                    font.family: "Inter Display"
                    font.pixelSize: 12
                    font.bold: true
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
}
