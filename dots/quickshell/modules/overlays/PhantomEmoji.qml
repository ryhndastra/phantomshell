import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

// S.E.E.S. symbol & emoji picker overlay (Super + .)
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
        PhantomState.playSfx("select")
        const notifTitle = PhantomState.isP3 ? "S.E.E.S. Archive" : "Emoji Compendium"
        PhantomState.pushImNotification(notifTitle, item.char + " copied to clipboard!", "NORMAL", "")
    }

    PanelWindow {
        id: emojiWin
        visible: PhantomState.emojiOpen

        WlrLayershell.namespace: "phantomshell-emoji"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: PhantomState.emojiOpen
            ? (PhantomState.modalForceExclusive ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand)
            : WlrKeyboardFocus.None
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
                PhantomState.playSfx("open")
            } else {
                PhantomState.playSfx("close")
            }
        }

        Rectangle {
            anchors.fill: parent
            color: PhantomState.isP3 ? "#D0020716" : "#AA050508"
            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.emojiOpen = false
            }
        }

        Item {
            id: emojiCard
            width: Math.min(parent.width - 64, 620)
            height: Math.min(parent.height - 80, 480)
            anchors.centerIn: parent

            ParallelAnimation {
                id: emojiAnim
                NumberAnimation { target: emojiCard; property: "scale"; from: 0.90; to: 1.0; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
                NumberAnimation { target: emojiCard; property: "opacity"; from: 0.0; to: 1.0; duration: 160; easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.fill: parent
                visible: PhantomState.isP3
                color: "#F203091C"
                border.color: "#8000DBFF"
                border.width: 1.8
                radius: 8

                Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 34; height: 3; color: "#00f0ff" }
                Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 3; height: 34; color: "#00f0ff" }
                Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 34; height: 3; color: "#00f0ff" }
                Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 3; height: 34; color: "#00f0ff" }
            }

            P5SkewedCard {
                anchors.fill: parent
                visible: !PhantomState.isP3
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
                anchors.margins: 20
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        visible: PhantomState.isP3
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        radius: 4
                        color: "#0028e0"
                        border.color: "#00f0ff"
                        border.width: 1.4

                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                var cx = width / 2
                                var cy = height / 2

                                ctx.strokeStyle = "#00f0ff"
                                ctx.lineWidth = 1.4

                                ctx.beginPath()
                                ctx.arc(cx, cy, 8, 0, Math.PI * 2)
                                ctx.stroke()

                                ctx.beginPath()
                                ctx.arc(cx, cy, 3, 0, Math.PI * 2)
                                ctx.fillStyle = "#ffffff"
                                ctx.fill()

                                ctx.beginPath(); ctx.moveTo(cx - 12, cy); ctx.lineTo(cx - 8, cy); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx + 8, cy); ctx.lineTo(cx + 12, cy); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx, cy - 12); ctx.lineTo(cx, cy - 8); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx, cy + 8); ctx.lineTo(cx, cy + 12); ctx.stroke()
                            }
                        }
                    }

                    P5Star {
                        visible: !PhantomState.isP3
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        spinning: true
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: PhantomState.isP3 ? "S.E.E.S. ARCHIVE // SYMBOL COMPENDIUM" : "PHANTOM EMOJI // SYMBOL COMPENDIUM"
                            color: "#FFFFFF"
                            font.family: PhantomState.isP3 ? "Rubik" : "JetBrainsMono NFM"
                            font.pixelSize: 13
                            font.weight: Font.Black
                            font.italic: !PhantomState.isP3
                            font.letterSpacing: PhantomState.isP3 ? 0.8 : 0
                        }
                        Text {
                            text: root.filteredEmojis.length + " SYMBOLS • [ENTER] COPY • [ESC] CLOSE"
                            color: PhantomState.isP3 ? "#00dbff" : PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 4
                        color: closeEmMouse.containsMouse ? "#d60032" : (PhantomState.isP3 ? "#0A183C" : "#1A1A26")
                        border.color: closeEmMouse.containsMouse ? "#ffffff" : (PhantomState.isP3 ? "#6000DBFF" : "#ffffff")
                        border.width: 1.4

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            id: closeEmMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.emojiOpen = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 4
                    color: "#07122C"
                    border.color: emojiSearch.activeFocus ? "#00f0ff" : "#4000DBFF"
                    border.width: 1.4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Canvas {
                            Layout.preferredWidth: 14
                            Layout.preferredHeight: 14
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.strokeStyle = "#00f0ff"
                                ctx.lineWidth = 1.6
                                ctx.beginPath()
                                ctx.arc(5.5, 5.5, 3.8, 0, Math.PI * 2)
                                ctx.stroke()
                                ctx.beginPath()
                                ctx.moveTo(8.5, 8.5)
                                ctx.lineTo(12.5, 12.5)
                                ctx.stroke()
                            }
                        }

                        TextInput {
                            id: emojiSearch
                            Layout.fillWidth: true
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 11
                            font.bold: true
                            clip: true
                            selectByMouse: true
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
                            Keys.onDownPressed: {
                                if (root.filteredEmojis.length > 0) root.selectedIdx = Math.min(root.filteredEmojis.length - 1, root.selectedIdx + 5)
                            }
                            Keys.onUpPressed: {
                                if (root.filteredEmojis.length > 0) root.selectedIdx = Math.max(0, root.selectedIdx - 5)
                            }
                            Keys.onReturnPressed: {
                                if (root.filteredEmojis.length > 0 && root.selectedIdx < root.filteredEmojis.length) {
                                    root.pickEmoji(root.filteredEmojis[root.selectedIdx])
                                }
                            }

                            Text {
                                anchors.fill: parent
                                text: "Search symbols (e.g. fire, sword, moon, heart)..."
                                color: "#4A6894"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 11
                                visible: !emojiSearch.text && !emojiSearch.activeFocus
                            }
                        }

                        Text {
                            visible: emojiSearch.text.length > 0
                            text: "✕"
                            color: "#00f0ff"
                            font.pixelSize: 11
                            font.bold: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    emojiSearch.text = ""
                                    root.searchQuery = ""
                                }
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
                    boundsBehavior: Flickable.StopAtBounds

                    GridLayout {
                        id: emojiGrid
                        width: parent.width
                        columns: 5
                        rowSpacing: 8
                        columnSpacing: 8

                        Repeater {
                            model: root.filteredEmojis

                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: 4

                                readonly property bool isSel: index === root.selectedIdx

                                color: isSel ? "#0028e0" : (emCellMouse.containsMouse ? "#0E2456" : "#071638")
                                border.color: isSel ? "#00f0ff" : (emCellMouse.containsMouse ? "#00f0ff" : "#2800DBFF")
                                border.width: isSel || emCellMouse.containsMouse ? 1.4 : 1.0

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 3

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.char
                                        font.pixelSize: 22
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.name.split(" ")[0].toUpperCase()
                                        color: parent.parent.isSel ? "#ffffff" : "#8AA6CE"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 8
                                        font.weight: Font.Black
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
