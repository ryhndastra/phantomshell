import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    signal backToMain()

    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            PhantomState.playSfx("cancel")
            root.backToMain()
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
                text: "THIEVES ARCHIVE // METAVERSE RECORDS"
                color: "white"
                font.family: "Persona 5 Menu Font Prototype"
                font.pixelSize: 28
                font.bold: true
            }
        }
    }

    // Archive Dossier Content
    Item {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        width: 720
        height: 380

        Rectangle {
            anchors.fill: parent
            color: "#0F0F0F"
            border.color: "#D6001C"
            border.width: 3

            // Top bar
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 36
                color: "#D6001C"

                Text {
                    anchors.centerIn: parent
                    text: "CONFIDENTIAL // PHANTOM THIEVES SPECIFICATION DOSSIER"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 13
                    font.family: "Arsenal"
                }
            }

            Column {
                anchors.top: parent.top
                anchors.topMargin: 50
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 24
                spacing: 16

                // Section 1
                Column {
                    spacing: 4
                    Text {
                        text: "SYSTEM COMPOSITOR & SHELL"
                        color: "#00E5FF"
                        font.bold: true
                        font.pixelSize: 15
                        font.family: "Arsenal"
                    }
                    Text {
                        text: "Hyprland Wayland Compositor • Quickshell Dynamic Desktop Environment • Arch Linux x86_64"
                        color: "white"
                        font.pixelSize: 13
                        font.family: "Arsenal"
                    }
                }

                // Section 2
                Column {
                    spacing: 4
                    Text {
                        text: "PALACE THEME ARCHITECTURE"
                        color: "#00E5FF"
                        font.bold: true
                        font.pixelSize: 15
                        font.family: "Arsenal"
                    }
                    Text {
                        text: "Dual Persona Persona 5 Royal Crimson & Persona 3 Reload Dark Hour engines with authentic glass-shatter and water transitions."
                        color: "white"
                        font.pixelSize: 13
                        font.family: "Arsenal"
                    }
                }

                // Section 3
                Column {
                    spacing: 4
                    Text {
                        text: "AUDIO & HAPTIC INTERACTION"
                        color: "#00E5FF"
                        font.bold: true
                        font.pixelSize: 15
                        font.family: "Arsenal"
                    }
                    Text {
                        text: "Native Persona 5 UI SFX triggers (OpenMenu, Select, Confirm, Cancel, ShatterKick) synchronized with QML animations."
                        color: "white"
                        font.pixelSize: 13
                        font.family: "Arsenal"
                    }
                }

                // Section 4
                Rectangle {
                    width: parent.width
                    height: 40
                    color: "#1A1A1A"
                    border.color: "#333333"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Take Your Time // Wake Up, Get Up, Get Out There"
                        color: "#FFD700"
                        font.bold: true
                        font.pixelSize: 14
                        font.family: "Arsenal"
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
                text: "[ESC] Back to Camp Menu"
                color: "white"
                font.pixelSize: 14
                font.bold: true
                font.family: "Arsenal"
            }
        }
    }
}
