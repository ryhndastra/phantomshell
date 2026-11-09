import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.config

// Layar Kalender Otentik Persona 3 Reload - 1:1 Persona-Quickshell (Yujonpradhananga)
Item {
    id: p3CalRoot
    anchors.fill: parent

    property bool active: false
    property var targetScreen: Quickshell.screens[0]
    property bool contentVisible: true

    property int dayOffset: 0
    property var baseDate: new Date()
    readonly property var now: {
        var d = new Date(baseDate);
        d.setDate(d.getDate() + dayOffset);
        return d;
    }

    P3rTransition3 {
        id: calTransition
        targetScreen: p3CalRoot.targetScreen
        onPeaked: {
            p3CalRoot.contentVisible = true;
        }
        onFinished: {
            p3CalRoot.contentVisible = true;
        }
    }

    onActiveChanged: {
        if (active) {
            baseDate = new Date();
            dayOffset = 0;
            contentVisible = false;
            calTransition.targetScreen = p3CalRoot.targetScreen;
            calTransition.shouldShow = true;
            fallbackTimer.restart();
            p3CalRoot.forceActiveFocus();
        } else {
            contentVisible = false;
            calTransition.shouldShow = false;
        }
    }

    Timer {
        id: fallbackTimer
        interval: 650
        repeat: false
        onTriggered: p3CalRoot.contentVisible = true
    }

    // ── Background ──
    Rectangle {
        anchors.fill: parent
        color: "#0b113d"
        visible: p3CalRoot.contentVisible
        z: 0
    }

    // ── Bluebar ──
    Item {
        anchors.fill: parent
        visible: p3CalRoot.contentVisible
        z: 1
        clip: true

        Rectangle {
            width: parent.width * 2
            height: parent.height * 0.2
            x: -parent.width * 0.2
            y: parent.height * -0.1
            color: "#1a4fa8"
            transform: Rotation {
                origin.x: parent.width / 2
                origin.y: parent.height / 2
                angle: 20
            }
        }
    }

    // ── Whiteline ──
    Item {
        anchors.fill: parent
        visible: p3CalRoot.contentVisible
        z: 2
        clip: true

        Rectangle {
            width: parent.width * 200
            height: 5
            x: -parent.width * 0.2
            y: parent.height * 0.99
            color: "white"
            transform: Rotation {
                origin.x: parent.width / 2
                origin.y: parent.height / 2
                angle: -20
            }
        }
    }

    // ── Year/Month label — inside band on the left ──
    Column {
        visible: p3CalRoot.contentVisible
        z: 2
        x: 40
        y: parent.height * 0.1
        spacing: -20

        Text {
            text: p3CalRoot.now.getFullYear()
            font.family: "Montserrat, Montserrat Alternates, sans-serif"
            font.pixelSize: 60
            font.bold: true
            color: "white"
        }

        Text {
            text: Qt.formatDate(p3CalRoot.now, "MMMM")
            font.family: "Microsoft Yahei, Montserrat Alternates, Inter Display, sans-serif"
            font.pixelSize: 30
            font.bold: true
            color: "#b4c8ff"
        }

        Text {
            text: p3CalRoot.now.getMonth() + 1
            x: 200
            topPadding: -100
            font.family: "Microsoft Yahei, Montserrat Alternates, sans-serif"
            font.pixelSize: 250
            font.bold: true
            color: "white"
        }
    }

    // ── Dates Container ──
    Item {
        id: datesContainer
        anchors.fill: parent
        visible: p3CalRoot.contentVisible
        z: 2

        Repeater {
            model: 7
            delegate: CalendarEntry {
                required property int index
                readonly property int offset: index - 3
                readonly property var entryDate: {
                    var d = new Date(p3CalRoot.now);
                    d.setDate(d.getDate() + offset);
                    d.setHours(12, 0, 0, 0);
                    return d;
                }
                readonly property bool isToday: offset === 0
                readonly property bool isPast: offset < 0
                readonly property real t: index / 6.0

                x: parent.width * 0.08 + t * (parent.width * 0.82)
                y: parent.height * 0.72 - t * (parent.height * 0.55) - numSize * 0.5

                dateObj: entryDate
                todayFlag: isToday
                pastFlag: isPast
            }
        }
    }

    // ── Dismiss & Keyboard Focus ──
    FocusScope {
        anchors.fill: parent
        focus: visible
        z: 3

        MouseArea {
            anchors.fill: parent
            z: -1
            hoverEnabled: true
            onWheel: event => {
                if (event.angleDelta.y > 0) {
                    p3CalRoot.dayOffset += 1;
                } else if (event.angleDelta.y < 0) {
                    p3CalRoot.dayOffset -= 1;
                }
            }
            onClicked: PhantomState.calendarOpen = false
        }

        Keys.onLeftPressed: p3CalRoot.dayOffset -= 1
        Keys.onRightPressed: p3CalRoot.dayOffset += 1
        Keys.onSpacePressed: p3CalRoot.dayOffset = 0
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                PhantomState.calendarOpen = false;
                event.accepted = true;
            }
        }
    }

    // ── CalendarEntry Component (1:1 Yujonpradhananga) ──
    component CalendarEntry: Item {
        id: entryRoot
        required property var dateObj
        required property bool todayFlag
        required property bool pastFlag

        readonly property int offset: {
            var d = new Date(p3CalRoot.now);
            d.setHours(12, 0, 0, 0);
            return Math.round((dateObj - d) / 86400000);
        }
        readonly property real scaleFactor: todayFlag ? 1.0 : (pastFlag ? Math.max(0.4, 0.75 - Math.abs(offset) * 0.1) : Math.min(1.4, 0.75 + offset * 0.1))
        readonly property real alphaVal: todayFlag ? 1.0 : Math.max(0.35, 1.0 - Math.abs(offset) * 0.15)
        readonly property real numSize: todayFlag ? 90 : Math.max(26, 65 * scaleFactor)
        readonly property real dayLabelSize: todayFlag ? 17 : Math.max(9, 13 * scaleFactor)

        readonly property real moonPhaseDeg: {
            const synodicMonth = 29.53059;
            const ref = new Date(Date.UTC(2000, 0, 6, 18, 14));
            const diffDays = (dateObj - ref) / 86400000;
            const days = ((diffDays % synodicMonth) + synodicMonth) % synodicMonth;
            var deg = 360 - Math.floor((days / synodicMonth) * 360);
            if (deg >= 355 || deg <= 5)
                return 0;
            if (deg >= 175 && deg <= 185)
                return 180;
            return deg;
        }

        readonly property var dayNames: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        readonly property int dayOfWeek: dateObj.getDay()
        readonly property bool isSunday: dayOfWeek === 0
        readonly property bool isSaturday: dayOfWeek === 6

        width: numSize * 3.5
        height: numSize * 1.4
        opacity: alphaVal

        Item {
            visible: entryRoot.todayFlag
            anchors.left: parent.left
            anchors.leftMargin: -109
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -10
            width: entryRoot.numSize * 1.5
            height: width
            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 7
                width: entryRoot.numSize * 2.3
                height: width
                radius: width / 2
                color: "transparent"
                border.color: "#6490ff"
                border.width: 15
                opacity: 0.6
            }
            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                width: entryRoot.numSize * 1
                height: width
                radius: width / 2
                color: "transparent"
                border.color: "#6490ff"
                border.width: 10
                opacity: 0.6
            }
        }

        Text {
            id: dayNumText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: entryRoot.dateObj.getDate()
            font.family: "Microsoft Yahei, Montserrat Alternates, sans-serif"
            font.pixelSize: entryRoot.numSize
            font.bold: true
            color: "white"
        }

        Column {
            anchors.left: dayNumText.right
            anchors.leftMargin: 6
            anchors.bottom: dayNumText.bottom
            anchors.bottomMargin: 50
            spacing: 2

            Text {
                text: entryRoot.dayNames[entryRoot.dayOfWeek]
                font.family: "Bahnschrift Condensed, Roboto Condensed, sans-serif"
                font.pixelSize: 20
                font.bold: true
                color: entryRoot.isSunday ? "#ff4444" : entryRoot.isSaturday ? "#4488ff" : "white"
            }
            Rectangle {
                visible: entryRoot.isSunday || entryRoot.isSaturday
                width: parent.children[0].implicitWidth
                height: 1.5
                color: entryRoot.isSunday ? "#ff4444" : "#4488ff"
            }
        }

        // Moon sphere
        Item {
            id: moonItem
            readonly property real moonR: entryRoot.todayFlag ? 35 : Math.max(12, 25 * entryRoot.scaleFactor)
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 100
            anchors.left: parent.left
            anchors.leftMargin: 150
            width: moonR
            height: moonR * 2

            Rectangle {
                visible: entryRoot.todayFlag
                anchors.centerIn: parent
                width: parent.moonR * 2 + 6
                height: width
                radius: width / 2
                color: "transparent"
                border.color: "#ffe700"
                border.width: 1.5
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
                    color: entryRoot.moonPhaseDeg < 180 ? "#ffe700" : "#302c24"
                }
                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    x: parent.width / 2
                    color: entryRoot.moonPhaseDeg < 180 ? "#302c24" : "#ffe700"
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    radius: width / 2
                    transform: Scale {
                        origin.x: moonSphere.width / 2
                        origin.y: moonSphere.height / 2
                        xScale: Math.cos(entryRoot.moonPhaseDeg * Math.PI / 180)
                        yScale: 1
                    }
                    color: Math.cos(entryRoot.moonPhaseDeg * Math.PI / 180) >= 0 ? "#302c24" : "#ffe700"
                }
            }
        }

        Behavior on x {
            SpringAnimation {
                spring: 2.0
                damping: 0.3
            }
        }
        Behavior on y {
            SpringAnimation {
                spring: 2.0
                damping: 0.3
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: p3CalRoot.dayOffset += entryRoot.offset
        }
    }
}
