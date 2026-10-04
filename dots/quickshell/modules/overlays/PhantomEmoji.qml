import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

// modul pemilih emoji cepat bergaya persona 5 (super + .)
Scope {
    id: root

    property string searchQuery: ""
    property int selectedIdx: 0

    readonly property var emojiList: [
        { char: "🎭", name: "phantom mask persona" },
        { char: "🔥", name: "fire lit hot" },
        { char: "💀", name: "skull dead ryuji" },
        { char: "⭐", name: "star phantom" },
        { char: "✨", name: "sparkles magic" },
        { char: "❤️", name: "heart love crimson" },
        { char: "⚡", name: "lightning bolt" },
        { char: "🃏", name: "joker wildcard" },
        { char: "👑", name: "crown king royal" },
        { char: "🐱", name: "cat morgana mona" },
        { char: "☕", name: "coffee leblanc" },
        { char: "🍛", name: "curry leblanc" },
        { char: "🎧", name: "headphones futaba oracle" },
        { char: "💻", name: "laptop code hacker" },
        { char: "🗡️", name: "dagger knife joker" },
        { char: "🔫", name: "gun pistol" },
        { char: "🎩", name: "tophat arsene phantom" },
        { char: "🦋", name: "butterfly velvet lavenza" },
        { char: "🌙", name: "moon dark hour p3" },
        { char: "📺", name: "tv midnight channel p4" },
        { char: "😂", name: "joy laugh" },
        { char: "😭", name: "sob cry" },
        { char: "😎", name: "cool sunglasses" },
        { char: "🤝", name: "handshake confidant deal" },
        { char: "👍", name: "thumbsup ok good" },
        { char: "🙏", name: "pray thanks" },
        { char: "🎉", name: "party celebrate" },
        { char: "🚀", name: "rocket fast" },
        { char: "✅", name: "check done success" },
        { char: "❌", name: "cross error cancel" },
        { char: "⚠️", name: "warning alert" },
        { char: "💡", name: "bulb idea" },
        { char: "🎵", name: "music note song" },
        { char: "🎮", name: "game controller" },
        { char: "📸", name: "camera screenshot" },
        { char: "🔒", name: "lock security" },
        { char: "❄️", name: "snowflake ice" },
        { char: "🌸", name: "sakura cherry blossom" },
        { char: "💎", name: "gem treasure" },
        { char: "🎯", name: "target bullseye" }
    ]

    readonly property var filteredEmojis: {
        const q = root.searchQuery.trim().toLowerCase()
        if (q === "") return root.emojiList
        return root.emojiList.filter(function(item) {
            return item.name.indexOf(q) !== -1 || item.char.indexOf(q) !== -1
        })
    }

    function pickEmoji(item) {
        if (!item) return
        Quickshell.execDetached(["bash", "-c", "printf '%s' '" + item.char + "' | wl-copy"])
        PhantomState.emojiOpen = false
        PhantomState.pushImNotification("Emoji Compendium", item.char + " disalin ke clipboard!", "NORMAL", "")
    }

    PanelWindow {
        id: emojiWin
        visible: PhantomState.emojiOpen

        WlrLayershell.namespace: "phantomshell-emoji"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: PhantomState.emojiOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        exclusiveZone: 0

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        onVisibleChanged: {
            if (visible) {
                root.searchQuery = ""
                root.selectedIdx = 0
                emojiSearch.text = ""
                emojiAnim.restart()
                emojiSearch.forceActiveFocus()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#AA050508"
            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.emojiOpen = false
            }
        }

        Item {
            id: emojiCard
            width: 560
            height: 440
            anchors.centerIn: parent

            ParallelAnimation {
                id: emojiAnim
                NumberAnimation { target: emojiCard; property: "scale"; from: 0.88; to: 1.0; duration: 210; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                NumberAnimation { target: emojiCard; property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            }

            P5SkewedCard {
                anchors.fill: parent
                fillColor: "#0B0B10"
                borderColor: "#FFFFFF"
                shadowColor: PhantomState.primary
                borderWidth: 3
                skewPx: 12
                shadowOffsetX: 7
                shadowOffsetY: 7
            }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    P5Star {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        spinning: true
                    }

                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "PHANTOM EMOJI // SYMBOL COMPENDIUM"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 16
                            font.weight: Font.Black
                            font.italic: true
                        }
                        Text {
                            text: "CLICK OR PRESS [ENTER] TO COPY TO CLIPBOARD"
                            color: PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Item {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: closeEmMouse.containsMouse ? PhantomState.primary : "#1A1A26"
                            borderColor: "#FFFFFF"
                            borderWidth: 1.5
                            skewPx: 4
                            showShadowOffset: false
                        }
                        P5Icon { anchors.centerIn: parent; name: "close"; size: 10; color: "#FFFFFF" }
                        MouseArea {
                            id: closeEmMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.emojiOpen = false
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: "#141420"
                        borderColor: PhantomState.secondary
                        borderWidth: 2
                        skewPx: 6
                        showShadowOffset: false
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        P5Icon { name: "search"; size: 12; color: PhantomState.secondary }

                        TextInput {
                            id: emojiSearch
                            Layout.fillWidth: true
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            clip: true
                            onTextChanged: {
                                root.searchQuery = text
                                root.selectedIdx = 0
                            }
                            Keys.onEscapePressed: PhantomState.emojiOpen = false
                            Keys.onRightPressed: {
                                if (root.filteredEmojis.length > 0) root.selectedIdx = (root.selectedIdx + 1) % root.filteredEmojis.length
                            }
                            Keys.onLeftPressed: {
                                if (root.filteredEmojis.length > 0) root.selectedIdx = (root.selectedIdx - 1 + root.filteredEmojis.length) % root.filteredEmojis.length
                            }
                            Keys.onReturnPressed: {
                                if (root.filteredEmojis.length > 0 && root.selectedIdx < root.filteredEmojis.length) {
                                    root.pickEmoji(root.filteredEmojis[root.selectedIdx])
                                }
                            }

                            Text {
                                anchors.fill: parent
                                text: "Search emoji (e.g. fire, joker, cat, heart)..."
                                color: PhantomState.muted
                                font: parent.font
                                visible: !parent.text
                            }
                        }
                    }
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: emojiGrid.implicitHeight + 10
                    clip: true

                    GridLayout {
                        id: emojiGrid
                        width: parent.width
                        columns: 5
                        rowSpacing: 8
                        columnSpacing: 8

                        Repeater {
                            model: root.filteredEmojis

                            delegate: Item {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 54

                                readonly property bool isSel: index === root.selectedIdx

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: parent.isSel || emCellMouse.containsMouse ? PhantomState.primary : "#14141F"
                                    borderColor: parent.isSel ? PhantomState.secondary : "#2E2E44"
                                    borderWidth: parent.isSel ? 2 : 1.2
                                    skewPx: 5
                                    showShadowOffset: false

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 2

                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.char
                                            font.pixelSize: 22
                                        }

                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.name.split(" ")[0].toUpperCase()
                                            color: "#FFFFFF"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 8
                                            font.weight: Font.Black
                                        }
                                    }
                                }

                                MouseArea {
                                    id: emCellMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectedIdx = index
                                    onClicked: root.pickEmoji(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
