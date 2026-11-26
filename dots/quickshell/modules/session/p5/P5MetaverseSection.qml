import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    signal backToMain()

    property int selectedEraIndex: 0

    readonly property var erasData: [
        {
            key: "1",
            id: "p5-crimson",
            name: "PERSONA 5 ROYAL",
            role: "TRICKSTER // REN AMAMIYA",
            desc: "Metaverse Rebellion • Neo-Tokyo Shujin Aesthetic",
            accent: "#D6001C",
            heroPortrait: Qt.resolvedUrl("../../../assets/themes/p3/components/card_face_p5.png")
        },
        {
            key: "2",
            id: "p3-reload",
            name: "PERSONA 3 RELOAD",
            role: "LEADER // MAKOTO YUKI",
            desc: "Tartarus Oceanic Modernism • S.E.E.S. Evoker Protocol",
            accent: "#00B4D8",
            heroPortrait: Qt.resolvedUrl("../../../assets/themes/p3/components/card_face_p3.png")
        },
        {
            key: "3",
            id: "p4-golden",
            name: "PERSONA 4 GOLDEN",
            role: "SEEKER // YU NARUKAMI",
            desc: "Midnight Channel Truth • Inaba Yellow Pop",
            accent: "#FFB703",
            heroPortrait: Qt.resolvedUrl("../../../assets/themes/p3/components/card_face_p4.png")
        }
    ]

    function applyIndex(idx) {
        if (idx < 0 || idx >= erasData.length) return
        PhantomState.playSfx("confirm")
        PhantomState.sessionOpen = false
        const target = erasData[idx]
        PhantomState.applyPreset(target.id)
    }

    function handleKey(event) {
        if (event.key === Qt.Key_Escape) {
            PhantomState.playSfx("cancel")
            root.backToMain()
            event.accepted = true
            return
        }
        if (event.key >= Qt.Key_1 && event.key <= Qt.Key_3) {
            applyIndex(event.key - Qt.Key_1)
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
            selectedEraIndex = (selectedEraIndex + 2) % 3
            PhantomState.playSfx("select")
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
            selectedEraIndex = (selectedEraIndex + 1) % 3
            PhantomState.playSfx("select")
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            applyIndex(selectedEraIndex)
            event.accepted = true
            return
        }
    }

    // Title banner
    Item {
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        width: 640
        height: 60

        Rectangle {
            anchors.fill: parent
            color: "#D6001C"
            rotation: -2
            border.color: "black"
            border.width: 3

            Text {
                anchors.centerIn: parent
                text: "METAVERSE ERAS // TIMELINE SELECTOR"
                color: "white"
                font.family: "Persona 5 Menu Font Prototype"
                font.pixelSize: 28
                font.bold: true
            }
        }
    }

    // Slanted Timeline Calling Cards
    Row {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        spacing: 30

        Repeater {
            model: root.erasData

            Item {
                id: eraCard
                width: 250
                height: 380
                property bool isHovered: root.selectedEraIndex === index
                property bool isCurrentActive: PhantomState.themeId === modelData.id

                scale: isHovered ? 1.06 : 1.0
                rotation: isHovered ? (index === 0 ? -3 : (index === 1 ? 0 : 3)) : (index === 0 ? -1 : (index === 1 ? 0 : 1))
                y: isHovered ? -16 : 0

                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                Behavior on rotation { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                // Shadow
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -4
                    color: "black"
                    rotation: eraCard.rotation
                    opacity: 0.8
                }

                // Card Body
                Rectangle {
                    anchors.fill: parent
                    color: eraCard.isHovered ? "#161616" : "#0D0D0D"
                    border.color: eraCard.isHovered ? modelData.accent : (eraCard.isCurrentActive ? "#FFFFFF" : "#333333")
                    border.width: eraCard.isHovered ? 4 : 2

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
                        width: 32
                        height: 32
                        color: eraCard.isHovered ? modelData.accent : "#222222"
                        border.color: "white"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData.key
                            color: eraCard.isHovered ? "black" : "white"
                            font.bold: true
                            font.pixelSize: 16
                            font.family: "Arsenal"
                        }
                    }

                    // Role subtitle
                    Text {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 46
                        text: modelData.role
                        color: eraCard.isHovered ? modelData.accent : "#888888"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "Arsenal"
                        elide: Text.ElideRight
                    }

                    // Hero Portrait Frame
                    Rectangle {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -20
                        width: 200
                        height: 200
                        color: "#050505"
                        border.color: eraCard.isHovered ? "white" : "#222222"
                        border.width: 2
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: modelData.heroPortrait
                            fillMode: Image.PreserveAspectCrop
                            opacity: eraCard.isHovered ? 1.0 : 0.8
                            mipmap: true
                        }
                    }

                    // Timeline Title & Description
                    Column {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 14
                        spacing: 4

                        Text {
                            text: modelData.name
                            color: "white"
                            font.bold: true
                            font.pixelSize: 16
                            font.family: "Arsenal"
                        }

                        Text {
                            width: parent.width
                            text: modelData.desc
                            color: eraCard.isHovered ? "#DDDDDD" : "#777777"
                            font.pixelSize: 10
                            font.family: "Arsenal"
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            width: parent.width
                            height: 28
                            color: eraCard.isCurrentActive ? "#D6001C" : (eraCard.isHovered ? modelData.accent : "#222222")
                            border.color: "white"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: eraCard.isCurrentActive ? "ACTIVE METAVERSE" : (eraCard.isHovered ? "AWAKEN ERA" : "SELECT")
                                color: (eraCard.isCurrentActive || !eraCard.isHovered) ? "white" : "black"
                                font.bold: true
                                font.pixelSize: 11
                                font.family: "Arsenal"
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        if (root.selectedEraIndex !== index) {
                            root.selectedEraIndex = index
                            PhantomState.playSfx("select")
                        }
                    }
                    onClicked: {
                        root.applyIndex(index)
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
        width: 520
        height: 38

        Rectangle {
            anchors.fill: parent
            color: "black"
            border.color: "white"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "[ESC] Back to Camp   [1-3] Choose Era   [ENTER] Awaken Timeline"
                color: "white"
                font.pixelSize: 14
                font.bold: true
                font.family: "Arsenal"
            }
        }
    }
}
