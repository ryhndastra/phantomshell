import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    signal backToMain()

    property int selectedDispatchIndex: 0

    readonly property var dispatchItems: [
        {
            key: "1",
            arcana: "I // GUARD",
            label: "LOCK",
            hudImage: Qt.resolvedUrl("../../../assets/themes/p5/menu/Lock_HUD.png"),
            sub: "SEAL METAVERSE",
            cmd: ["hyprlock"]
        },
        {
            key: "2",
            arcana: "II // REST",
            label: "SUSPEND",
            hudImage: Qt.resolvedUrl("../../../assets/themes/p5/menu/Suspend_HUD.png"),
            sub: "SLEEP IN LEBLANC",
            cmd: ["systemctl", "suspend"]
        },
        {
            key: "3",
            arcana: "III // EXIT",
            label: "LOGOUT",
            hudImage: Qt.resolvedUrl("../../../assets/themes/p5/menu/Logout_HUD.png"),
            sub: "LEAVE PALACE",
            cmd: ["hyprctl", "dispatch", "exit"]
        },
        {
            key: "4",
            arcana: "IV // CYCLE",
            label: "REBOOT",
            hudImage: Qt.resolvedUrl("../../../assets/themes/p5/menu/Reboot_HUD.png"),
            sub: "RELOAD SYSTEM",
            cmd: ["systemctl", "reboot"]
        },
        {
            key: "5",
            arcana: "V // HALT",
            label: "POWEROFF",
            hudImage: Qt.resolvedUrl("../../../assets/themes/p5/menu/Poweroff_HUD.png"),
            sub: "SHUT DOWN",
            cmd: ["systemctl", "poweroff"]
        }
    ]

    function executeIndex(idx) {
        if (idx < 0 || idx >= dispatchItems.length) return
        PhantomState.playSfx("confirm")
        PhantomState.sessionOpen = false
        const target = dispatchItems[idx]
        if (target.label === "LOCK") {
            Quickshell.execDetached(["hyprlock"])
        } else {
            Quickshell.execDetached(target.cmd)
        }
    }

    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            PhantomState.playSfx("cancel")
            root.backToMain()
            event.accepted = true
            return
        }
        if (event.key >= Qt.Key_1 && event.key <= Qt.Key_5) {
            executeIndex(event.key - Qt.Key_1)
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
            selectedDispatchIndex = (selectedDispatchIndex + 4) % 5
            PhantomState.playSfx("select")
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
            selectedDispatchIndex = (selectedDispatchIndex + 1) % 5
            PhantomState.playSfx("select")
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            executeIndex(selectedDispatchIndex)
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
                text: "MISSION DISPATCH // EXECUTION"
                color: "white"
                font.family: "Persona 5 Menu Font Prototype"
                font.pixelSize: 28
                font.bold: true
            }
        }
    }

    // 5 Slanted Dispatch Cards
    Row {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        spacing: 20

        Repeater {
            model: root.dispatchItems

            Item {
                id: card
                width: 170
                height: 320
                property bool isHovered: root.selectedDispatchIndex === index

                scale: isHovered ? 1.06 : 1.0
                rotation: isHovered ? (index % 2 === 0 ? -3 : 3) : (index % 2 === 0 ? -1 : 1)
                y: isHovered ? -16 : 0

                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                Behavior on rotation { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                // Card Backing Shadow
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    color: "black"
                    rotation: card.rotation
                    opacity: 0.8
                }

                // Card Body
                Rectangle {
                    anchors.fill: parent
                    color: card.isHovered ? "#D6001C" : "#1A1A1A"
                    border.color: card.isHovered ? "white" : "#444444"
                    border.width: card.isHovered ? 4 : 2

                    Behavior on color { ColorAnimation { duration: 140 } }

                    // Number Key Badge
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        width: 32
                        height: 32
                        color: card.isHovered ? "white" : "#333333"
                        border.color: "black"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: modelData.key
                            color: card.isHovered ? "#D6001C" : "white"
                            font.bold: true
                            font.pixelSize: 18
                            font.family: "Arsenal"
                        }
                    }

                    // Arcana subtitle
                    Text {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 12
                        text: modelData.arcana
                        color: card.isHovered ? "white" : "#888888"
                        font.pixelSize: 12
                        font.bold: true
                        font.family: "Arsenal"
                    }

                    // HUD sticker image
                    Image {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -20
                        source: modelData.hudImage
                        fillMode: Image.PreserveAspectFit
                        width: 140
                        height: 60
                        mipmap: true
                    }

                    // Subtitle / Mission label
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10
                        height: 34
                        color: card.isHovered ? "black" : "#262626"
                        border.color: card.isHovered ? "white" : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.sub
                            color: "white"
                            font.pixelSize: 11
                            font.bold: true
                            font.family: "Arsenal"
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        if (root.selectedDispatchIndex !== index) {
                            root.selectedDispatchIndex = index
                            PhantomState.playSfx("select")
                        }
                    }
                    onClicked: {
                        root.executeIndex(index)
                    }
                }
            }
        }
    }

    // Bottom Navigation Badge
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
                text: "[ESC] Back to Camp   [1-5] Execute Directly   [ENTER] Confirm"
                color: "white"
                font.pixelSize: 14
                font.bold: true
                font.family: "Arsenal"
            }
        }
    }
}
