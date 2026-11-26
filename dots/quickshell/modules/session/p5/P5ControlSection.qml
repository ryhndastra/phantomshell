import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    signal backToMain()

    property int selectedIndex: 0

    readonly property var keybindsList: [
        { key: "SUPER + RETURN", desc: "Launch Terminal Emulator (Foot)", action: "TERMINAL" },
        { key: "SUPER + SPACE",  desc: "Metaverse Application Launcher", action: "LAUNCHER" },
        { key: "SUPER + Q",      desc: "Close Focused Active Window",   action: "KILL" },
        { key: "SUPER + E",      desc: "Infiltration File Manager",     action: "FILES" },
        { key: "SUPER + B",      desc: "Phantom Web Browser",           action: "BROWSER" },
        { key: "SUPER + ESC",    desc: "Open Session Camp Command Hub", action: "CAMP MENU" }
    ]

    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            PhantomState.playSfx("cancel")
            root.backToMain()
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Up) {
            selectedIndex = (selectedIndex + keybindsList.length - 1) % keybindsList.length
            PhantomState.playSfx("select")
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Down) {
            selectedIndex = (selectedIndex + 1) % keybindsList.length
            PhantomState.playSfx("select")
            event.accepted = true
            return
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
                text: "CONTROL CENTER // TACTICAL KEYBINDS"
                color: "white"
                font.family: "Persona 5 Menu Font Prototype"
                font.pixelSize: 28
                font.bold: true
            }
        }
    }

    // Keybind Cards
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        spacing: 10
        width: 680

        Repeater {
            model: root.keybindsList

            Item {
                id: kbItem
                width: 680
                height: 52
                property bool isHovered: root.selectedIndex === index

                scale: isHovered ? 1.02 : 1.0
                rotation: isHovered ? -1 : 0
                x: isHovered ? 12 : 0

                Behavior on scale { NumberAnimation { duration: 140 } }
                Behavior on x { NumberAnimation { duration: 140 } }

                Rectangle {
                    anchors.fill: parent
                    color: kbItem.isHovered ? "#D6001C" : "#141414"
                    border.color: kbItem.isHovered ? "white" : "#333333"
                    border.width: kbItem.isHovered ? 3 : 1

                    // Key Badge
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 6
                        width: 190
                        color: kbItem.isHovered ? "black" : "#222222"
                        border.color: "white"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.key
                            color: kbItem.isHovered ? "#00E5FF" : "white"
                            font.bold: true
                            font.pixelSize: 13
                            font.family: "Arsenal"
                        }
                    }

                    // Description
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 215
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.desc
                        color: "white"
                        font.bold: true
                        font.pixelSize: 14
                        font.family: "Arsenal"
                    }

                    // Action pill
                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 110
                        height: 28
                        color: kbItem.isHovered ? "black" : "#222222"
                        border.color: "white"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.action
                            color: "white"
                            font.bold: true
                            font.pixelSize: 11
                            font.family: "Arsenal"
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        if (root.selectedIndex !== index) {
                            root.selectedIndex = index
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
        width: 440
        height: 38

        Rectangle {
            anchors.fill: parent
            color: "black"
            border.color: "white"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "[ESC] Back to Camp   [▲/▼] Navigate Keybinds"
                color: "white"
                font.pixelSize: 14
                font.bold: true
                font.family: "Arsenal"
            }
        }
    }
}
