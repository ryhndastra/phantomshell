import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.components

// modul riwayat papan klip (cliphist) bergaya persona 5 compendium (super + v)
Scope {
    id: root

    property string searchQuery: ""
    property var clipEntries: []
    property int selectedIdx: 0

    readonly property var filteredEntries: {
        const q = root.searchQuery.trim().toLowerCase()
        if (q === "") return root.clipEntries
        return root.clipEntries.filter(function(item) {
            return item.preview.toLowerCase().indexOf(q) !== -1
        })
    }

    Process {
        id: clipListProc
        command: ["bash", "-c", "cliphist list 2>/dev/null | head -n 60"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const lines = String(data).split("\n")
                const arr = []
                for (let i = 0; i < lines.length; i++) {
                    const raw = lines[i]
                    if (!raw || !raw.trim()) continue
                    const tabIdx = raw.indexOf("\t")
                    const idStr = tabIdx !== -1 ? raw.slice(0, tabIdx).trim() : String(i + 1)
                    const content = tabIdx !== -1 ? raw.slice(tabIdx + 1).trim() : raw.trim()
                    arr.push({
                        id: idStr,
                        raw: raw,
                        preview: content
                    })
                }
                root.clipEntries = arr
                root.selectedIdx = 0
            }
        }
    }

    function refreshClips() {
        clipListProc.running = false
        clipListProc.running = true
    }

    function selectEntry(entry) {
        if (!entry) return
        const safeId = String(entry.id).replace(/[^0-9]/g, "")
        if (safeId) {
            Quickshell.execDetached(["bash", "-c", "cliphist decode " + safeId + " | wl-copy"])
        }
        PhantomState.clipboardOpen = false
        PhantomState.pushImNotification("Thief Compendium", "Item disalin ke clipboard!", "NORMAL", "")
    }

    function wipeHistory() {
        Quickshell.execDetached(["bash", "-c", "cliphist wipe 2>/dev/null || true"])
        root.clipEntries = []
        PhantomState.pushImNotification("Thief Compendium", "Riwayat clipboard telah dibersihkan.", "NORMAL", "")
    }

    PanelWindow {
        id: clipWin
        visible: PhantomState.clipboardOpen

        WlrLayershell.namespace: "phantomshell-clipboard"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: PhantomState.clipboardOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
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
                clipSearchInput.text = ""
                root.refreshClips()
                clipAnim.restart()
                clipSearchInput.forceActiveFocus()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#AA050508"
            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.clipboardOpen = false
            }
        }

        Item {
            id: clipCard
            width: 620
            height: 500
            anchors.centerIn: parent

            ParallelAnimation {
                id: clipAnim
                NumberAnimation { target: clipCard; property: "scale"; from: 0.88; to: 1.0; duration: 210; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                NumberAnimation { target: clipCard; property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
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
                            text: "THIEF COMPENDIUM // CLIPBOARD HISTORY"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 16
                            font.weight: Font.Black
                            font.italic: true
                        }
                        Text {
                            text: root.filteredEntries.length + " ITEMS • [ENTER] COPY • [ESC] CLOSE"
                            color: PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // tombol hapus semua riwayat
                    Item {
                        Layout.preferredWidth: wipeTxt.implicitWidth + 20
                        Layout.preferredHeight: 28
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: wipeMouse.containsMouse ? PhantomState.primary : "#1A1A26"
                            borderColor: "#FFFFFF"
                            borderWidth: 1.5
                            skewPx: 4
                            showShadowOffset: false
                        }
                        Text {
                            id: wipeTxt
                            anchors.centerIn: parent
                            text: "WIPE ALL"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                        MouseArea {
                            id: wipeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.wipeHistory()
                        }
                    }

                    // tombol tutup
                    Item {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: closeClipMouse.containsMouse ? PhantomState.primary : "#1A1A26"
                            borderColor: "#FFFFFF"
                            borderWidth: 1.5
                            skewPx: 4
                            showShadowOffset: false
                        }
                        P5Icon { anchors.centerIn: parent; name: "close"; size: 10; color: "#FFFFFF" }
                        MouseArea {
                            id: closeClipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.clipboardOpen = false
                        }
                    }
                }

                // bilah pencarian riwayat
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
                            id: clipSearchInput
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
                            Keys.onEscapePressed: PhantomState.clipboardOpen = false
                            Keys.onDownPressed: {
                                if (root.filteredEntries.length > 0) {
                                    root.selectedIdx = (root.selectedIdx + 1) % root.filteredEntries.length
                                }
                            }
                            Keys.onUpPressed: {
                                if (root.filteredEntries.length > 0) {
                                    root.selectedIdx = (root.selectedIdx - 1 + root.filteredEntries.length) % root.filteredEntries.length
                                }
                            }
                            Keys.onReturnPressed: {
                                if (root.filteredEntries.length > 0 && root.selectedIdx < root.filteredEntries.length) {
                                    root.selectEntry(root.filteredEntries[root.selectedIdx])
                                }
                            }

                            Text {
                                anchors.fill: parent
                                text: "Filter clipboard entries..."
                                color: PhantomState.muted
                                font: parent.font
                                visible: !parent.text
                            }
                        }
                    }
                }

                // daftar item clipboard
                ListView {
                    id: clipListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6
                    clip: true
                    model: root.filteredEntries
                    currentIndex: root.selectedIdx

                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: clipListView.width
                        height: 38

                        readonly property bool isSel: index === root.selectedIdx

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: parent.isSel || itemMouse.containsMouse ? PhantomState.primary : "#13131E"
                            borderColor: parent.isSel ? PhantomState.secondary : "#2E2E44"
                            borderWidth: parent.isSel ? 2 : 1.2
                            skewPx: 5
                            showShadowOffset: false

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Text {
                                    text: "#" + modelData.id
                                    color: parent.parent.parent.isSel ? PhantomState.secondary : PhantomState.muted
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.preview
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selectedIdx = index
                            onClicked: root.selectEntry(modelData)
                        }
                    }
                }
            }
        }
    }
}
