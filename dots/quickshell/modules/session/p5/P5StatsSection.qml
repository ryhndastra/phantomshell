import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    signal backToMain()

    property int selectedStatIndex: 0

    readonly property var statsList: [
        {
            key: "1",
            arcana: "I // CORE",
            label: "CPU LOAD",
            val: PhantomState.cpuPct + "%",
            pct: PhantomState.cpuPct,
            sub: "Central Processor Load Matrix",
            accent: "#D6001C"
        },
        {
            key: "2",
            arcana: "II // ALLOC",
            label: "MEMORY",
            val: PhantomState.ramPct + "%",
            pct: PhantomState.ramPct,
            sub: "DDR System Memory Active",
            accent: "#00E5FF"
        },
        {
            key: "3",
            arcana: "III // ACCEL",
            label: "GPU CORE",
            val: PhantomState.gpuPct + "%",
            pct: PhantomState.gpuPct,
            sub: "Wayland Compositor Pipeline",
            accent: "#FFD700"
        },
        {
            key: "4",
            arcana: "IV // STORAGE",
            label: "NVMe DISK",
            val: PhantomState.diskPct + "%",
            pct: PhantomState.diskPct,
            sub: "Root File System Usage",
            accent: "#FF5500"
        },
        {
            key: "5",
            arcana: "V // COMMS",
            label: "NETWORK",
            val: (PhantomState.networkService && PhantomState.networkService.wifiSsid) ? PhantomState.networkService.wifiSsid : "LINKED",
            pct: 85,
            sub: "Radio Link & Mesh Telemetry",
            accent: "#00FF99"
        }
    ]

    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            PhantomState.playSfx("cancel")
            root.backToMain()
            event.accepted = true
            return
        }
        if (event.key >= Qt.Key_1 && event.key <= Qt.Key_5) {
            selectedStatIndex = event.key - Qt.Key_1
            PhantomState.playSfx("select")
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
            selectedStatIndex = (selectedStatIndex + 4) % 5
            PhantomState.playSfx("select")
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
            selectedStatIndex = (selectedStatIndex + 1) % 5
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
                text: "SYSTEM STATS // PHANTOM VITALS"
                color: "white"
                font.family: "Persona 5 Menu Font Prototype"
                font.pixelSize: 28
                font.bold: true
            }
        }
    }

    // 5 Slanted Sensor Cards
    Row {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        spacing: 20

        Repeater {
            model: root.statsList

            Item {
                id: card
                width: 175
                height: 330
                property bool isHovered: root.selectedStatIndex === index

                scale: isHovered ? 1.06 : 1.0
                rotation: isHovered ? (index % 2 === 0 ? -3 : 3) : (index % 2 === 0 ? -1 : 1)
                y: isHovered ? -16 : 0

                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                Behavior on rotation { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                // Shadow
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
                    color: card.isHovered ? "#1C1C1C" : "#0F0F0F"
                    border.color: card.isHovered ? modelData.accent : "#333333"
                    border.width: card.isHovered ? 4 : 2

                    // Accent top strip
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 6
                        color: modelData.accent
                    }

                    // Key badge
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        width: 30
                        height: 30
                        color: card.isHovered ? modelData.accent : "#222222"
                        border.color: "white"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.key
                            color: card.isHovered ? "black" : "white"
                            font.bold: true
                            font.pixelSize: 15
                            font.family: "Arsenal"
                        }
                    }

                    // Arcana subtitle
                    Text {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 12
                        text: modelData.arcana
                        color: card.isHovered ? modelData.accent : "#777777"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "Arsenal"
                    }

                    // Label
                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 46
                        anchors.left: parent.left
                        anchors.margins: 12
                        text: modelData.label
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                        font.family: "Arsenal"
                    }

                    // Large percentage / value read-out
                    Text {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -10
                        text: modelData.val
                        color: card.isHovered ? modelData.accent : "white"
                        font.family: "Persona 5 Menu Font Prototype"
                        font.pixelSize: 42
                        font.bold: true
                    }

                    // Progress Gauge Bar
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 60
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 14
                        height: 10
                        color: "#222222"
                        border.color: "black"
                        border.width: 1

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: Math.min(parent.width, parent.width * (modelData.pct / 100))
                            color: modelData.accent
                        }
                    }

                    // Subtitle footer
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10
                        height: 38
                        color: card.isHovered ? "#282828" : "#181818"
                        border.color: card.isHovered ? "white" : "transparent"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            width: parent.width - 12
                            text: modelData.sub
                            color: card.isHovered ? "white" : "#888888"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "Arsenal"
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        if (root.selectedStatIndex !== index) {
                            root.selectedStatIndex = index
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
                text: "[ESC] Back to Camp   [1-5] Focus Sensor"
                color: "white"
                font.pixelSize: 14
                font.bold: true
                font.family: "Arsenal"
            }
        }
    }
}
