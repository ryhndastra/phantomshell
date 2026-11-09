import QtQuick
import QtQuick.Effects
import qs.config

Item {
    id: root
    anchors.fill: parent

    property bool active: false
    property bool contentVisible: false

    // navigation
    property int dayOffset: 0
    property var baseDate: new Date()
    readonly property var now: {
        var d = new Date(baseDate)
        d.setDate(d.getDate() + dayOffset)
        return d
    }

    focus: true

    onActiveChanged: {
        if (active) {
            baseDate = new Date()
            dayOffset = 0
            contentVisible = true
            root.forceActiveFocus()
        } else {
            contentVisible = false
        }
    }

    // ── Background ──
    Rectangle {
        anchors.fill: parent
        color: "#080c24"
        visible: root.contentVisible
        z: 0
    }

    // ── Blue Ribbon (Centered diagonally across screen) ──
    Item {
        anchors.fill: parent
        visible: root.contentVisible
        clip: true
        z: 1

        Rectangle {
            id: blueRibbon
            width: parent.width * 2.8
            height: 300
            color: "#1153ba"
            anchors.centerIn: parent
            rotation: 20
            antialiasing: true
        }
    }

    // ── White Line (Centered diagonally across screen, opposing slope) ──
    Item {
        anchors.fill: parent
        visible: root.contentVisible
        clip: true
        z: 2

        Rectangle {
            id: whiteRail
            width: parent.width * 2.8
            height: 4
            color: "white"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 35
            rotation: -20
            antialiasing: true
        }
    }

    // ── Year / Month label (Inside the blue ribbon on the left) ──
    Item {
        visible: root.contentVisible
        z: 3
        x: 45
        y: 135
        width: 320
        height: 200

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: -2

                Text {
                    text: root.now.getFullYear()
                    font.family: "Montserrat Alternates"
                    font.pixelSize: 44
                    font.bold: true
                    color: "white"
                }

                Text {
                    text: Qt.formatDate(root.now, "MMMM")
                    font.family: "Inter Display"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#b4c8ff"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.now.getMonth() + 1
                font.family: "Montserrat Alternates"
                font.pixelSize: 175
                font.bold: true
                color: "white"
            }
        }
    }

    // ── 7 Date Entries across the screen ──
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

    // ── Dismiss & Keyboard Handling ──
    FocusScope {
        anchors.fill: parent
        focus: visible
        z: 10

        MouseArea {
            anchors.fill: parent
            z: -1
            hoverEnabled: true
            onWheel: event => {
                if (event.angleDelta.y > 0)
                    root.dayOffset += 1
                else if (event.angleDelta.y < 0)
                    root.dayOffset -= 1
            }
            onClicked: PhantomState.calendarOpen = false
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

    // ── Calendar Entry Component ──
    component CalendarEntry: Item {
        id: entryRoot
        required property var dateObj
        required property bool todayFlag
        required property bool pastFlag
        required property int dayOffsetVal

        // White line geometry:
        // center: cx = parent.width / 2, cy = parent.height / 2 + 35
        // slope = tan(-20 deg) = -0.36397
        readonly property real targetCenterX: parent.width / 2 + dayOffsetVal * 230
        readonly property real whiteLineY: (parent.height / 2 + 35) - Math.tan(20 * Math.PI / 180) * (targetCenterX - parent.width / 2)

        x: targetCenterX - width / 2
        y: whiteLineY - 95
        width: 150
        height: 200

        // Opacity gradient:
        readonly property real alphaVal: {
            if (todayFlag) return 1.0
            if (dayOffsetVal === -1) return 0.80
            if (dayOffsetVal === -2) return 0.58
            if (dayOffsetVal === -3) return 0.38
            if (dayOffsetVal === 1) return 0.88
            if (dayOffsetVal === 2) return 0.72
            if (dayOffsetVal === 3) return 0.58
            return 0.5
        }

        // Moon size:
        // 3 days back: decreasing (18, 26, 34)
        // today: most prominent (66)
        // 3 days future: smaller than today but bigger than past 3 (46, 42, 38)
        readonly property real moonSize: {
            if (todayFlag) return 66
            if (dayOffsetVal === -1) return 34
            if (dayOffsetVal === -2) return 25
            if (dayOffsetVal === -3) return 17
            if (dayOffsetVal === 1) return 46
            if (dayOffsetVal === 2) return 41
            if (dayOffsetVal === 3) return 37
            return 30
        }

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

        opacity: alphaVal

        // ── Ripple concentric rings (Today only) ──
        Item {
            visible: entryRoot.todayFlag
            anchors.centerIn: dayNumText
            width: 0
            height: 0
            z: 0

            Rectangle {
                anchors.centerIn: parent
                width: 210
                height: 210
                radius: 105
                color: "transparent"
                border.color: "#4f84ea"
                border.width: 14
                opacity: 0.55
            }

            Rectangle {
                anchors.centerIn: parent
                width: 126
                height: 126
                radius: 63
                color: "transparent"
                border.color: "#4f84ea"
                border.width: 10
                opacity: 0.65
            }
        }

        // ── Date Number + 3-Letter Day Name (IDENTICAL font size across all 7 dates) ──
        Row {
            id: dateRow
            anchors.top: parent.top
            anchors.left: parent.left
            spacing: 6
            z: 1

            Text {
                id: dayNumText
                text: entryRoot.dateObj.getDate()
                font.family: "Montserrat Alternates"
                font.pixelSize: 85
                font.bold: true
                color: "white"
            }

            Column {
                id: dayNameCol
                anchors.verticalCenter: dayNumText.verticalCenter
                anchors.verticalCenterOffset: 6
                spacing: 2

                Text {
                    id: dayNameText
                    text: entryRoot.dayNames[entryRoot.dayOfWeek]
                    font.family: "Inter Display"
                    font.pixelSize: 22
                    font.bold: true
                    color: entryRoot.isSunday ? "#ff4444" : entryRoot.isSaturday ? "#4488ff" : "white"
                }

                Rectangle {
                    visible: entryRoot.isSunday || entryRoot.isSaturday
                    width: dayNameText.implicitWidth
                    height: 2
                    color: entryRoot.isSunday ? "#ff4444" : "#4488ff"
                }
            }
        }

        // ── Lunar Moon Sphere (Directly below day name & white line) ──
        Item {
            id: moonContainer
            anchors.top: parent.top
            anchors.topMargin: 104
            anchors.horizontalCenter: dayNameCol.horizontalCenter
            width: entryRoot.moonSize
            height: entryRoot.moonSize
            z: 2

            // Golden halo ring around Today's moon
            Rectangle {
                visible: entryRoot.todayFlag
                anchors.centerIn: parent
                width: parent.width + 8
                height: width
                radius: width / 2
                color: "transparent"
                border.color: "#ffe700"
                border.width: 2.0
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
