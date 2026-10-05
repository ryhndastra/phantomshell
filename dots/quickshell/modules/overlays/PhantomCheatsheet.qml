import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

// modul overlay daftar pintasan keyboard taktis bergaya persona 5 (super + /)
Scope {
    id: root

    property string searchQuery: ""
    property string activeCategory: "ALL"

    readonly property var categories: ["ALL", "PANELS", "APPS", "UTILITIES", "WINDOWS", "WORKSPACES", "MEDIA"]

    readonly property var allBinds: [
        { cat: "PANELS", key: "SUPER / SUPER + D", act: "Toggle P5 Command Launcher" },
        { cat: "PANELS", key: "SUPER + Tab", act: "Toggle Workspace Overview (10 Workspaces)" },
        { cat: "PANELS", key: "SUPER + V", act: "Open Clipboard History Compendium" },
        { cat: "PANELS", key: "SUPER + .", act: "Open Emoji & Symbol Picker" },
        { cat: "PANELS", key: "SUPER + /", act: "Toggle Tactics Keybind Cheatsheet" },
        { cat: "PANELS", key: "SUPER + N / G", act: "Toggle Control Center & Pentagon Stats" },
        { cat: "PANELS", key: "SUPER + A / B / O", act: "Toggle SNS Phone Notification Center" },
        { cat: "PANELS", key: "SUPER + M", act: "Toggle Media Jukebox Popup" },
        { cat: "PANELS", key: "SUPER + I", act: "Open Velvet Room Unified Settings" },
        { cat: "PANELS", key: "SUPER + J", act: "Toggle Top Bar Auto-Hide" },
        { cat: "PANELS", key: "CTRL + SUPER + T", act: "Open Wallpaper Gallery Selector" },
        { cat: "PANELS", key: "CTRL + SUPER + ALT + T", act: "Cycle Next Wallpaper" },
        { cat: "PANELS", key: "CTRL + SUPER + P", act: "Cycle 9 Persona Theme Palettes" },
        { cat: "PANELS", key: "CTRL + SUPER + SHIFT + D", act: "Toggle Light / Dark Mode" },
        { cat: "PANELS", key: "CTRL + SUPER + R", act: "Restart Quickshell" },
        { cat: "PANELS", key: "SUPER + L", act: "Lock Screen (Calling Card Lock)" },
        { cat: "PANELS", key: "SUPER + SHIFT + L", act: "Suspend / Sleep System" },
        { cat: "PANELS", key: "SUPER + Esc / Ctrl+Alt+Del", act: "Open Calling Card Power Menu" },
        { cat: "APPS", key: "SUPER + Return / T", act: "Launch Terminal (Kitty)" },
        { cat: "APPS", key: "CTRL + ALT + T", act: "Launch Terminal (Kitty)" },
        { cat: "APPS", key: "SUPER + E", act: "Launch File Manager" },
        { cat: "APPS", key: "SUPER + W", act: "Launch Web Browser" },
        { cat: "APPS", key: "SUPER + C", act: "Launch Code Editor" },
        { cat: "APPS", key: "SUPER + X", act: "Launch Text Editor" },
        { cat: "APPS", key: "CTRL + SUPER + V", act: "Launch Volume Mixer (Pavucontrol)" },
        { cat: "APPS", key: "CTRL + SHIFT + Esc", act: "Launch System Task Manager" },
        { cat: "UTILITIES", key: "SUPER + SHIFT + S", act: "Region Screenshot >> Clipboard & File" },
        { cat: "UTILITIES", key: "Print", act: "Fullscreen Screenshot >> Clipboard" },
        { cat: "UTILITIES", key: "CTRL + Print", act: "Fullscreen Screenshot >> Clipboard & File" },
        { cat: "UTILITIES", key: "SUPER + SHIFT + X", act: "Region OCR Text Scan >> Clipboard" },
        { cat: "UTILITIES", key: "SUPER + SHIFT + C", act: "Pick Screen Color (#RRGGBB) >> Clipboard" },
        { cat: "UTILITIES", key: "SUPER + SHIFT + R", act: "Record Screen Region (Toggle Start/Stop)" },
        { cat: "UTILITIES", key: "CTRL + ALT + R", act: "Record Fullscreen (No Audio)" },
        { cat: "UTILITIES", key: "SUPER + SHIFT + ALT + R", act: "Record Fullscreen (With Audio)" },
        { cat: "UTILITIES", key: "SUPER + - / =", act: "Zoom Screen Out / In" },
        { cat: "UTILITIES", key: "SUPER + ALT + F1", act: "Toggle Virtual Machine Keybind Submap" },
        { cat: "WINDOWS", key: "SUPER + Q", act: "Close Active Window" },
        { cat: "WINDOWS", key: "SUPER + SHIFT + ALT + Q", act: "Force Kill Window (hyprctl kill)" },
        { cat: "WINDOWS", key: "SUPER + F", act: "Maximize Window (Keep Bar & Gaps)" },
        { cat: "WINDOWS", key: "SUPER + SHIFT + F", act: "True Fullscreen Window" },
        { cat: "WINDOWS", key: "SUPER + Space / ALT+Space", act: "Toggle Float / Tile Window" },
        { cat: "WINDOWS", key: "SUPER + P", act: "Pin Floating Window Across Workspaces" },
        { cat: "WINDOWS", key: "SUPER + ; / '", act: "Decrease / Increase Split Ratio" },
        { cat: "WINDOWS", key: "SUPER + ←/→/↑/↓", act: "Move Window Focus" },
        { cat: "WINDOWS", key: "SUPER + SHIFT + ←/→/↑/↓", act: "Move Window in Direction" },
        { cat: "WINDOWS", key: "SUPER + LMB / RMB Drag", act: "Drag Move / Resize Window" },
        { cat: "WORKSPACES", key: "SUPER + 1..9 / 0", act: "Switch to Workspace 1..10" },
        { cat: "WORKSPACES", key: "SUPER + SHIFT + 1..9 / 0", act: "Move Window & Follow to Workspace 1..10" },
        { cat: "WORKSPACES", key: "SUPER + ALT + 1..9 / 0", act: "Send Window Silently to Workspace 1..10" },
        { cat: "WORKSPACES", key: "CTRL + SUPER + ← / →", act: "Switch to Previous / Next Workspace" },
        { cat: "WORKSPACES", key: "SUPER + PageUp / PageDown", act: "Switch to Previous / Next Workspace" },
        { cat: "WORKSPACES", key: "SUPER + Mouse Scroll", act: "Scroll Through Workspaces" },
        { cat: "WORKSPACES", key: "SUPER + S", act: "Toggle Special Scratchpad Workspace" },
        { cat: "WORKSPACES", key: "SUPER + ALT + S", act: "Send Window to Scratchpad" },
        { cat: "MEDIA", key: "SUPER + SHIFT + P", act: "Play / Pause Media (Spotify / MPRIS)" },
        { cat: "MEDIA", key: "SUPER + SHIFT + N / B", act: "Next / Previous Media Track" },
        { cat: "MEDIA", key: "SUPER + SHIFT + M", act: "Toggle Speaker Audio Mute" },
        { cat: "MEDIA", key: "SUPER + ALT + M", act: "Toggle Microphone Mute" }
    ]

    readonly property var filteredBinds: {
        const q = root.searchQuery.trim().toLowerCase()
        const cat = root.activeCategory
        return root.allBinds.filter(function(item) {
            if (cat !== "ALL" && item.cat !== cat) return false
            if (q === "") return true
            return item.key.toLowerCase().indexOf(q) !== -1 || item.act.toLowerCase().indexOf(q) !== -1 || item.cat.toLowerCase().indexOf(q) !== -1
        })
    }

    PanelWindow {
        id: sheetWin
        visible: PhantomState.cheatsheetOpen

        WlrLayershell.namespace: "phantomshell-cheatsheet"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: PhantomState.cheatsheetOpen
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
                root.activeCategory = "ALL"
                searchInput.text = ""
                sheetAnim.restart()
                searchInput.forceActiveFocus()
            }
        }

        // latar belakang gelap klik untuk menutup
        Rectangle {
            anchors.fill: parent
            color: "#AA050508"

            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.cheatsheetOpen = false
            }
        }

        Item {
            id: sheetCard
            width: Math.min(parent.width - 80, 920)
            height: Math.min(parent.height - 90, 620)
            anchors.centerIn: parent

            ParallelAnimation {
                id: sheetAnim
                NumberAnimation { target: sheetCard; property: "scale"; from: 0.88; to: 1.0; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                NumberAnimation { target: sheetCard; property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            }

            P5SkewedCard {
                anchors.fill: parent
                fillColor: "#0B0B10"
                borderColor: "#FFFFFF"
                shadowColor: PhantomState.primary
                borderWidth: 3
                skewPx: 14
                shadowOffsetX: 8
                shadowOffsetY: 8
            }

            // cegah klik tembus ke backdrop
            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                // baris judul dan kotak pencarian
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    P5Star {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        spinning: true
                    }

                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "THIEF TACTICS // KEYBIND COMPENDIUM"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 18
                            font.weight: Font.Black
                            font.italic: true
                        }
                        Text {
                            text: root.filteredBinds.length + " SHORTCUTS ACTIVE • PRESS [ESC] TO DISMISS"
                            color: PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // kotak input filter pencarian
                    Item {
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 34

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: "#151520"
                            borderColor: searchInput.activeFocus ? PhantomState.secondary : "#FFFFFF"
                            shadowColor: PhantomState.primary
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
                                id: searchInput
                                Layout.fillWidth: true
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                clip: true
                                onTextChanged: root.searchQuery = text
                                Keys.onEscapePressed: PhantomState.cheatsheetOpen = false

                                Text {
                                    anchors.fill: parent
                                    text: "Search key or action..."
                                    color: PhantomState.muted
                                    font: parent.font
                                    visible: !parent.text
                                }
                            }
                        }
                    }

                    // tombol tutup
                    Item {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: closeSheetMouse.containsMouse ? PhantomState.primary : "#181824"
                            borderColor: "#FFFFFF"
                            borderWidth: 2
                            skewPx: 5
                            showShadowOffset: false
                        }
                        P5Icon { anchors.centerIn: parent; name: "close"; size: 12; color: "#FFFFFF" }
                        MouseArea {
                            id: closeSheetMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.cheatsheetOpen = false
                        }
                    }
                }

                // deretan tab kategori
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.categories
                        delegate: Item {
                            required property string modelData
                            Layout.preferredWidth: catTxt.implicitWidth + 22
                            Layout.preferredHeight: 26

                            readonly property bool isSel: root.activeCategory === modelData

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: parent.isSel ? PhantomState.primary : (catMouse.containsMouse ? "#1E1E2C" : "#12121A")
                                borderColor: parent.isSel ? PhantomState.secondary : "#3A3A50"
                                borderWidth: parent.isSel ? 2 : 1
                                skewPx: 5
                                showShadowOffset: false
                            }

                            Text {
                                id: catTxt
                                anchors.centerIn: parent
                                text: parent.modelData
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                font.weight: Font.Black
                                font.italic: parent.isSel
                            }

                            MouseArea {
                                id: catMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeCategory = parent.modelData
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                // area daftar keybind 2 kolom
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: bindsGrid.implicitHeight + 12
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    GridLayout {
                        id: bindsGrid
                        width: parent.width
                        columns: 2
                        rowSpacing: 6
                        columnSpacing: 10

                        Repeater {
                            model: root.filteredBinds

                            delegate: Item {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: "#13131D"
                                    borderColor: "#2C2C42"
                                    shadowColor: PhantomState.primary
                                    borderWidth: 1.2
                                    skewPx: 5
                                    showShadowOffset: false

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        Rectangle {
                                            width: kTxt.implicitWidth + 14
                                            height: 20
                                            color: "#1F1F32"
                                            border.color: PhantomState.secondary
                                            border.width: 1
                                            radius: 2

                                            Text {
                                                id: kTxt
                                                anchors.centerIn: parent
                                                text: modelData.key
                                                color: PhantomState.secondary
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                font.weight: Font.Black
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.act
                                            color: "#FFFFFF"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: modelData.cat
                                            color: PhantomState.muted
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 8
                                            font.weight: Font.Black
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
