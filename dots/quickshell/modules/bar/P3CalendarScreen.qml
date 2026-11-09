import QtQuick
import QtQuick.Effects
import qs.config

Item {
    id: root
    anchors.fill: parent

    property bool active: false
    property bool contentVisible: false

    // Navigation
    property int dayOffset: 0
    property var baseDate: new Date()
    readonly property var now: {
        var d = new Date(baseDate)
        d.setDate(d.getDate() + dayOffset)
        return d
    }

    focus: true

    // ── Dedicated Key Catcher for ESC and Arrow Keys ──
    Item {
        id: screenKeyCatcher
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: {
            PhantomState.calendarOpen = false
            event.accepted = true
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                PhantomState.calendarOpen = false
                event.accepted = true
            } else if (event.key === Qt.Key_Left) {
                root.dayOffset -= 1
                event.accepted = true
            } else if (event.key === Qt.Key_Right) {
                root.dayOffset += 1
                event.accepted = true
            } else if (event.key === Qt.Key_Space) {
                root.dayOffset = 0
                event.accepted = true
            }
        }
    }

    Timer {
        interval: 40
        running: root.contentVisible
        repeat: false
        onTriggered: screenKeyCatcher.forceActiveFocus()
    }

    // ── Entrance Animation ──
    property real animProgress: 0.0

    NumberAnimation {
        id: enterAnim
        target: root
        property: "animProgress"
        from: 0.0
        to: 1.0
        duration: 350
        easing.type: Easing.OutCubic
    }

    onActiveChanged: {
        if (active) {
            baseDate = new Date()
            dayOffset = 0
            contentVisible = true
            animProgress = 0.0
            enterAnim.restart()
            screenKeyCatcher.forceActiveFocus()
        } else {
            contentVisible = false
            animProgress = 0.0
        }
    }

    // ── Background: Authentic P3R Deep Indigo Navy ──
    Rectangle {
        anchors.fill: parent
        color: "#0b113d"
        visible: root.contentVisible
        opacity: root.animProgress
        z: 0
    }

    // ── Blue Ribbon: 215px thick, centered at X=1060, Y=520, angle 20 deg ──
    Item {
        anchors.fill: parent
        visible: root.contentVisible
        clip: true
        opacity: root.animProgress
        transform: Translate { x: (1.0 - root.animProgress) * -180 }
        z: 1

        Rectangle {
            id: blueRibbon
            width: parent.width * 2.8
            height: 215
            color: "#1a50a8"
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 100
            anchors.verticalCenterOffset: -20
            rotation: 20
            antialiasing: true
        }
    }

    // ── White Line Rail: Centered at X=1060, Y=590, angle -19.5 deg ──
    Item {
        anchors.fill: parent
        visible: root.contentVisible
        clip: true
        opacity: root.animProgress
        transform: Translate { x: (1.0 - root.animProgress) * -120 }
        z: 2

        Rectangle {
            id: whiteRail
            width: parent.width * 2.8
            height: 4
            color: "white"
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 100
            anchors.verticalCenterOffset: 50
            rotation: -19.5
            antialiasing: true
        }
    }

    // ── Year / Month Section: Angka Bulan di DEPAN (kiri), ukuran pas dengan ribbon (200px) ──
    Item {
        visible: root.contentVisible
        opacity: root.animProgress
        transform: Translate { x: (1.0 - root.animProgress) * -80 }
        z: 3
        x: 40
        y: 70
        width: 420
        height: 220

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            // Angka Bulan Besar di DEPAN (kiri), hampir pas dengan ukuran ribbon
            Text {
                id: bigMonthNum
                text: root.now.getMonth() + 1
                font.family: "Rubik"
                font.pixelSize: 200
                font.bold: true
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
            }

            // Tahun dan Nama Bulan di BELAKANGNYA (kanan)
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: -4

                Text {
                    text: root.now.getFullYear()
                    font.family: "Rubik"
                    font.pixelSize: 48
                    font.bold: true
                    color: "white"
                }

                Text {
                    text: Qt.formatDate(root.now, "MMMM")
                    font.family: "Rubik"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#b4c8ff"
                }
            }
        }
    }

    // ── 7 Date Entries across the screen (Spacing 280px ensures neighbor dates never touch ribbon) ──
    Item {
        id: datesContainer
        anchors.fill: parent
        visible: root.contentVisible
        z: 4

        Repeater {
            model: 7
            delegate: CalendarEntry {
                required property int index
                readonly property int offset: index - 3
                readonly property var entryDate: {
                    var d = new Date(root.now)
                    d.setDate(d.getDate() + offset)
                    d.setHours(12, 0, 0, 0)
                    return d
                }

                dateObj: entryDate
                todayFlag: offset === 0
                pastFlag: offset < 0
                dayOffsetVal: offset
            }
        }
    }

    // ── Background Click to Dismiss ──
    MouseArea {
        anchors.fill: parent
        z: 5
        hoverEnabled: true
        onWheel: event => {
            if (event.angleDelta.y > 0)
                root.dayOffset += 1
            else if (event.angleDelta.y < 0)
                root.dayOffset -= 1
        }
        onClicked: PhantomState.calendarOpen = false
    }

    // ── Calendar Entry Component ──
    component CalendarEntry: Item {
        id: entryRoot
        required property var dateObj
        required property bool todayFlag
        required property bool pastFlag
        required property int dayOffsetVal

        // White rail: centered at X=1060, Y=590, angle -19.5 deg
        // Spacing 280px guarantees 8 SUN and 10 TUE have a wide gap and never touch the blue ribbon!
        readonly property real targetCenterX: 1060 + dayOffsetVal * 280
        readonly property real whiteLineY: 590 - Math.tan(19.5 * Math.PI / 180) * (targetCenterX - 1060)

        // Jarak bersih 26px di atas rel garis putih (tidak ada angka yang terpotong/tersentuh)
        x: targetCenterX - 45
        y: whiteLineY - 26 - 115
        width: 170
        height: 260
        z: 6

        transform: Translate { y: (1.0 - root.animProgress) * 35 }

        // Opacity gradient:
        readonly property real alphaVal: {
            if (todayFlag) return 1.0
            if (dayOffsetVal === -1) return 0.82
            if (dayOffsetVal === -2) return 0.60
            if (dayOffsetVal === -3) return 0.38
            if (dayOffsetVal === 1) return 0.88
            if (dayOffsetVal === 2) return 0.72
            if (dayOffsetVal === 3) return 0.58
            return 0.5
        }

        // Moon size:
        // 3 days back: decreasing (17, 25, 34)
        // today: most prominent (68)
        // 3 days future: smaller than today but larger than past 3 (44, 40, 36)
        readonly property real moonSize: {
            if (todayFlag) return 68
            if (dayOffsetVal === -1) return 34
            if (dayOffsetVal === -2) return 25
            if (dayOffsetVal === -3) return 17
            if (dayOffsetVal === 1) return 44
            if (dayOffsetVal === 2) return 40
            if (dayOffsetVal === 3) return 36
            return 30
        }

        // Lunar phase degree calculation
        readonly property real moonPhaseDeg: {
            const synodicMonth = 29.53059
            const ref = new Date(Date.UTC(2000, 0, 6, 18, 14))
            const diffDays = (dateObj - ref) / 86400000
            const days = ((diffDays % synodicMonth) + synodicMonth) % synodicMonth
            var deg = 360 - Math.floor((days / synodicMonth) * 360)
            if (deg >= 355 || deg <= 5) return 0
            if (deg >= 175 && deg <= 185) return 180
            return deg
        }

        readonly property var dayNames: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        readonly property int dayOfWeek: dateObj.getDay()
        readonly property bool isSunday: dayOfWeek === 0
        readonly property bool isSaturday: dayOfWeek === 6

        opacity: alphaVal * root.animProgress

        // ── Ripple concentric rings (Today only) ──
        Item {
            visible: entryRoot.todayFlag
            x: dayNumText.x + dayNumText.width / 2
            y: dayNumText.y + dayNumText.height / 2
            width: 0
            height: 0
            z: 0

            Rectangle {
                anchors.centerIn: parent
                width: 220
                height: 220
                radius: 110
                color: "transparent"
                border.color: "#3870dc"
                border.width: 14
                opacity: 0.5
            }

            Rectangle {
                anchors.centerIn: parent
                width: 136
                height: 136
                radius: 68
                color: "transparent"
                border.color: "#3870dc"
                border.width: 10
                opacity: 0.65
            }
        }

        // ── Date Number + 3-Letter Day Name (Chunky Rubik Bold, identical font size 115 across all dates) ──
        Row {
            id: dateRow
            x: 0
            y: 0
            spacing: 6
            z: 1

            Text {
                id: dayNumText
                text: entryRoot.dateObj.getDate()
                font.family: "Rubik"
                font.pixelSize: 115
                font.bold: true
                color: "white"
            }

            Column {
                id: dayNameCol
                anchors.top: dayNumText.top
                anchors.topMargin: 24
                spacing: 2

                Text {
                    id: dayNameText
                    text: entryRoot.dayNames[entryRoot.dayOfWeek]
                    font.family: "Rubik"
                    font.pixelSize: 24
                    font.bold: true
                    color: entryRoot.isSunday ? "#ff4444" : entryRoot.isSaturday ? "#4488ff" : "white"
                }

                Rectangle {
                    visible: entryRoot.isSunday || entryRoot.isSaturday
                    width: dayNameText.implicitWidth
                    height: 2.5
                    color: entryRoot.isSunday ? "#ff4444" : "#4488ff"
                }
            }
        }

        // ── Lunar Moon Sphere (Directly below day name & with clean 18px gap beneath white rail) ──
        Item {
            id: moonContainer
            x: dayNumText.width + 6 + (dayNameCol.width / 2) - (width / 2)
            y: 160
            width: entryRoot.moonSize
            height: entryRoot.moonSize
            z: 2

            // Glowing golden halo ring around Today's moon
            Rectangle {
                visible: entryRoot.todayFlag
                anchors.centerIn: parent
                width: parent.width + 8
                height: width
                radius: width / 2
                color: "transparent"
                border.color: "#ffe700"
                border.width: 2.5
            }

            Item {
                id: moonSphere
                anchors.fill: parent
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
                    color: entryRoot.moonPhaseDeg < 180 ? "#ffe700" : "#242730"
                }

                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    x: parent.width / 2
                    color: entryRoot.moonPhaseDeg < 180 ? "#242730" : "#ffe700"
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
                    color: Math.cos(entryRoot.moonPhaseDeg * Math.PI / 180) >= 0 ? "#242730" : "#ffe700"
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dayOffset += entryRoot.dayOffsetVal
        }
    }
}
