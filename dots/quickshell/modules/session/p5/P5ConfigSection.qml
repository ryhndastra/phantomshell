import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    signal backToMain()

    property int selectedConfigIndex: 0

    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            PhantomState.playSfx("cancel")
            root.backToMain()
            event.accepted = true
            return
        }
        if (event.key >= Qt.Key_1 && event.key <= Qt.Key_5) {
            selectedConfigIndex = event.key - Qt.Key_1
            PhantomState.playSfx("select")
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Up) {
            selectedConfigIndex = (selectedConfigIndex + 4) % 5
            PhantomState.playSfx("select")
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Down) {
            selectedConfigIndex = (selectedConfigIndex + 1) % 5
            PhantomState.playSfx("select")
            event.accepted = true
            return
        }

        // Adjust volume or brightness with Left/Right
        if (selectedConfigIndex === 0) { // Volume
            if (event.key === Qt.Key_Left) {
                const cur = (PhantomState.audioOsdService && PhantomState.audioOsdService.systemVolume) || 50
                PhantomState.setSystemVolume(Math.max(0, cur - 5))
                PhantomState.playSfx("select")
                event.accepted = true
                return
            }
            if (event.key === Qt.Key_Right) {
                const cur = (PhantomState.audioOsdService && PhantomState.audioOsdService.systemVolume) || 50
                PhantomState.setSystemVolume(Math.min(100, cur + 5))
                PhantomState.playSfx("select")
                event.accepted = true
                return
            }
        } else if (selectedConfigIndex === 1) { // Brightness
            if (event.key === Qt.Key_Left) {
                const cur = (PhantomState.audioOsdService && PhantomState.audioOsdService.systemBrightness) || 50
                PhantomState.setSystemBrightness(Math.max(10, cur - 5))
                PhantomState.playSfx("select")
                event.accepted = true
                return
            }
            if (event.key === Qt.Key_Right) {
                const cur = (PhantomState.audioOsdService && PhantomState.audioOsdService.systemBrightness) || 50
                PhantomState.setSystemBrightness(Math.min(100, cur + 5))
                PhantomState.playSfx("select")
                event.accepted = true
                return
            }
        }

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            if (selectedConfigIndex === 3) {
                PhantomState.toggleDarkMode()
                PhantomState.playSfx("confirm")
                event.accepted = true
                return
            } else if (selectedConfigIndex === 4) {
                PhantomState.sfxEnabled = !PhantomState.sfxEnabled
                PhantomState.playSfx("confirm")
                event.accepted = true
                return
            }
        }
    }

    // Title banner
    Item {
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        width: 600
        height: 60

        Rectangle {
            anchors.fill: parent
            color: "#D6001C"
            rotation: -2
            border.color: "black"
            border.width: 3

            Text {
                anchors.centerIn: parent
                text: "SYSTEM CONFIG // INFILTRATION GEAR"
                color: "white"
                font.family: "Persona 5 Menu Font Prototype"
                font.pixelSize: 28
                font.bold: true
            }
        }
    }

    // 5 Horizontal Slanted Config Rows
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        spacing: 12
        width: 680

        Repeater {
            model: [
                {
                    key: "1",
                    label: "MASTER AUDIO VOLUME",
                    val: ((PhantomState.audioOsdService && PhantomState.audioOsdService.systemVolume) || 50) + "%",
                    sub: "Use [◄ / ►] to adjust master volume output"
                },
                {
                    key: "2",
                    label: "PANEL BRIGHTNESS",
                    val: ((PhantomState.audioOsdService && PhantomState.audioOsdService.systemBrightness) || 100) + "%",
                    sub: "Use [◄ / ►] to adjust display brightness level"
                },
                {
                    key: "3",
                    label: "DISPLAY MONITOR",
                    val: "PRIMARY // 1920x1080 @ 60Hz",
                    sub: "Wayland hardware output mode and resolution"
                },
                {
                    key: "4",
                    label: "DARK THEME MODE",
                    val: PhantomState.darkMode ? "ACTIVE (DARK)" : "INACTIVE (LIGHT)",
                    sub: "Press [ENTER] to toggle dark mode color scheme"
                },
                {
                    key: "5",
                    label: "PERSONA SOUND FX",
                    val: PhantomState.sfxEnabled ? "ENABLED (ON)" : "MUTED (OFF)",
                    sub: "Press [ENTER] to toggle audio cue sound effects"
                }
            ]

            Item {
                id: rowItem
                width: 680
                height: 56
                property bool isHovered: root.selectedConfigIndex === index

                scale: isHovered ? 1.02 : 1.0
                rotation: isHovered ? -1 : 0
                x: isHovered ? 12 : 0

                Behavior on scale { NumberAnimation { duration: 140 } }
                Behavior on x { NumberAnimation { duration: 140 } }

                Rectangle {
                    anchors.fill: parent
                    color: rowItem.isHovered ? "#D6001C" : "#141414"
                    border.color: rowItem.isHovered ? "white" : "#333333"
                    border.width: rowItem.isHovered ? 3 : 1

                    // Key badge
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 50
                        color: rowItem.isHovered ? "black" : "#222222"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.key
                            color: "white"
                            font.bold: true
                            font.pixelSize: 18
                            font.family: "Arsenal"
                        }
                    }

                    // Content
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 65
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: modelData.label
                            color: "white"
                            font.bold: true
                            font.pixelSize: 14
                            font.family: "Arsenal"
                        }

                        Text {
                            text: modelData.sub
                            color: rowItem.isHovered ? "#FFDDDD" : "#888888"
                            font.pixelSize: 11
                            font.family: "Arsenal"
                        }
                    }

                    // Value Pill
                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        width: 220
                        height: 34
                        color: rowItem.isHovered ? "black" : "#222222"
                        border.color: "white"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.val
                            color: rowItem.isHovered ? "#00E5FF" : "white"
                            font.bold: true
                            font.pixelSize: 13
                            font.family: "Arsenal"
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        if (root.selectedConfigIndex !== index) {
                            root.selectedConfigIndex = index
                            PhantomState.playSfx("select")
                        }
                    }
                }
            }
        }
    }

    // Bottom Navigation Prompts
    Item {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        width: 560
        height: 38

        Rectangle {
            anchors.fill: parent
            color: "black"
            border.color: "white"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "[ESC] Back to Camp   [▲/▼] Select   [◄/►] Adjust   [ENTER] Toggle"
                color: "white"
                font.pixelSize: 14
                font.bold: true
                font.family: "Arsenal"
            }
        }
    }
}
