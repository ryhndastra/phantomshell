import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

Scope {
    id: root

    property string searchQuery: ""
    property string activeCategory: "ALL"

    readonly property var categories: ["ALL", "S.E.E.S. HUD", "APPS", "UTILITIES", "WINDOWS", "WORKSPACES", "MEDIA"]

    readonly property var allBinds: [
        // S.E.E.S. HUD & PANELS
        { cat: "S.E.E.S. HUD", key: "SUPER / SUPER + D", act: "Open S.E.E.S. Command Launcher & Mail" },
        { cat: "S.E.E.S. HUD", key: "SUPER + Tab", act: "Open Tactical Town Map (Workspace Overview)" },
        { cat: "S.E.E.S. HUD", key: "SUPER + S", act: "Toggle The Velvet Room (Special Workspace)" },
        { cat: "S.E.E.S. HUD", key: "SUPER + L", act: "Lock Screen (S.E.E.S. Dark Hour Protocol)" },
        { cat: "S.E.E.S. HUD", key: "SUPER + Esc / Ctrl+Alt+Del", act: "Open S.E.E.S. Dispatch & Power Menu" },
        { cat: "S.E.E.S. HUD", key: "SUPER + /", act: "Toggle Tactical Keybind Cheatsheet" },
        { cat: "S.E.E.S. HUD", key: "SUPER + V", act: "Open Clipboard History Compendium" },
        { cat: "S.E.E.S. HUD", key: "SUPER + .", act: "Open Symbol & Emoji Picker" },
        { cat: "S.E.E.S. HUD", key: "SUPER + B / A", act: "Toggle S.E.E.S. Notification Center" },
        { cat: "S.E.E.S. HUD", key: "SUPER + M", act: "Toggle Media Player Capsule" },
        { cat: "S.E.E.S. HUD", key: "SUPER + I", act: "Open S.E.E.S. Unified System Config" },
        { cat: "S.E.E.S. HUD", key: "SUPER + J", act: "Toggle Top Bar Auto-Hide" },
        { cat: "S.E.E.S. HUD", key: "SUPER + SHIFT + W", act: "Toggle Live Wallpaper Selector" },
        { cat: "S.E.E.S. HUD", key: "CTRL + SUPER + T", act: "Open Live Wallpaper Selector" },
        { cat: "S.E.E.S. HUD", key: "CTRL + SUPER + ALT + T", act: "Cycle Next Wallpaper" },
        { cat: "S.E.E.S. HUD", key: "CTRL + SUPER + P", act: "Cycle Persona Theme Palette" },
        { cat: "S.E.E.S. HUD", key: "CTRL + SUPER + SHIFT + D", act: "Toggle Light / Dark Mode" },
        { cat: "S.E.E.S. HUD", key: "CTRL + SUPER + R", act: "Restart Quickshell Daemon" },

        // APLIKASI
        { cat: "APPS", key: "SUPER + Return / T", act: "Launch Terminal (Kitty)" },
        { cat: "APPS", key: "CTRL + ALT + T", act: "Launch Terminal (Kitty)" },
        { cat: "APPS", key: "SUPER + E", act: "Launch File Manager" },
        { cat: "APPS", key: "SUPER + W", act: "Launch Web Browser (Zen)" },
        { cat: "APPS", key: "SUPER + C", act: "Launch Code Editor (VS Code / Neovim)" },
        { cat: "APPS", key: "SUPER + X", act: "Launch Text Editor" },
        { cat: "APPS", key: "CTRL + SUPER + V", act: "Launch Audio Volume Mixer (Pavucontrol)" },
        { cat: "APPS", key: "CTRL + SHIFT + Esc", act: "Launch System Task Manager" },

        // UTILITAS & SCREENSHOT
        { cat: "UTILITIES", key: "SUPER + SHIFT + S", act: "Region Screenshot >> Clipboard & File" },
        { cat: "UTILITIES", key: "Print", act: "Fullscreen Screenshot >> Clipboard" },
        { cat: "UTILITIES", key: "CTRL + Print", act: "Fullscreen Screenshot >> Clipboard & File" },
        { cat: "UTILITIES", key: "SUPER + SHIFT + X", act: "Region OCR Text Recognition >> Clipboard" },
        { cat: "UTILITIES", key: "SUPER + SHIFT + C", act: "Pick Screen Color (#RRGGBB) >> Clipboard" },
        { cat: "UTILITIES", key: "SUPER + SHIFT + R", act: "Record Screen Region (Toggle Start/Stop)" },
        { cat: "UTILITIES", key: "CTRL + ALT + R", act: "Record Fullscreen Video (No Audio)" },
        { cat: "UTILITIES", key: "SUPER + SHIFT + ALT + R", act: "Record Fullscreen Video (With Audio)" },
        { cat: "UTILITIES", key: "SUPER + - / =", act: "Zoom Screen Out / In" },
        { cat: "UTILITIES", key: "SUPER + ALT + F1", act: "Toggle Virtual Machine Keybind Submap" },

        // MANAJEMEN WINDOW
        { cat: "WINDOWS", key: "SUPER + Q", act: "Close Active Window" },
        { cat: "WINDOWS", key: "SUPER + SHIFT + ALT + Q", act: "Force Kill Window (hyprctl kill)" },
        { cat: "WINDOWS", key: "SUPER + F", act: "Maximize Window (Keep Margins)" },
        { cat: "WINDOWS", key: "SUPER + SHIFT + F", act: "Toggle True Fullscreen Window" },
        { cat: "WINDOWS", key: "SUPER + Space", act: "Toggle Floating / Tiling Window" },
        { cat: "WINDOWS", key: "SUPER + P", act: "Pin Floating Window to All Workspaces" },
        { cat: "WINDOWS", key: "SUPER + ; / '", act: "Adjust Window Split Ratio" },
        { cat: "WINDOWS", key: "SUPER + ←/→/↑/↓", act: "Move Window Focus" },
        { cat: "WINDOWS", key: "SUPER + SHIFT + ←/→/↑/↓", act: "Move Window in Direction" },
        { cat: "WINDOWS", key: "SUPER + LMB Drag", act: "Interactive Window Move" },
        { cat: "WINDOWS", key: "SUPER + RMB Drag", act: "Interactive Window Resize" },

        // WORKSPACES
        { cat: "WORKSPACES", key: "SUPER + 1..6", act: "Switch to Workspace 1..6" },
        { cat: "WORKSPACES", key: "SUPER + SHIFT + 1..6", act: "Move Window & Follow to Workspace 1..6" },
        { cat: "WORKSPACES", key: "SUPER + ALT + 1..6", act: "Send Window Silently to Workspace 1..6" },
        { cat: "WORKSPACES", key: "CTRL + SUPER + ← / →", act: "Switch to Previous / Next Workspace" },
        { cat: "WORKSPACES", key: "SUPER + PageUp / PageDown", act: "Switch to Previous / Next Workspace" },
        { cat: "WORKSPACES", key: "SUPER + Mouse Scroll", act: "Scroll Through Workspaces" },
        { cat: "WORKSPACES", key: "SUPER + ALT + S", act: "Send Active Window to Velvet Room" },

        // KONTROL MEDIA & AUDIO
        { cat: "MEDIA", key: "SUPER + SHIFT + P", act: "Play / Pause Media (Spotify / MPRIS)" },
        { cat: "MEDIA", key: "SUPER + SHIFT + N / B", act: "Next / Previous Media Track" },
        { cat: "MEDIA", key: "SUPER + SHIFT + M", act: "Toggle Speaker Audio Output Mute" },
        { cat: "MEDIA", key: "SUPER + ALT + M", act: "Toggle Microphone Input Mute" }
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

        // Latar Gelap Semi-Transparan
        Rectangle {
            anchors.fill: parent
            color: "#D0020716"

            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.cheatsheetOpen = false
            }
        }

        Item {
            id: sheetCard
            width: Math.min(parent.width - 64, 1020)
            height: Math.min(parent.height - 80, 640)
            anchors.centerIn: parent

            ParallelAnimation {
                id: sheetAnim
                NumberAnimation { target: sheetCard; property: "scale"; from: 0.92; to: 1.0; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
                NumberAnimation { target: sheetCard; property: "opacity"; from: 0.0; to: 1.0; duration: 160; easing.type: Easing.OutCubic }
            }

            // Bingkai Kartu Taktikal S.E.E.S. Modern (Bebas Skew P5)
            Rectangle {
                anchors.fill: parent
                color: "#F203091C"
                border.color: "#8000DBFF"
                border.width: 1.8
                radius: 8

                // Aksen Garis Biru Taktikal di Sudut
                Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 34; height: 3; color: "#00f0ff" }
                Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 3; height: 34; color: "#00f0ff" }
                Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 34; height: 3; color: "#00f0ff" }
                Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 3; height: 34; color: "#00f0ff" }
            }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                // -------------------------------------------------------------
                // 1. BARIS HEADER & PENCARIAN
                // -------------------------------------------------------------
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 4
                        color: "#0028e0"
                        border.color: "#00f0ff"
                        border.width: 1.4

                        Text {
                            anchors.centerIn: parent
                            text: "S3"
                            color: "#ffffff"
                            font.family: "Rubik"
                            font.pixelSize: 13
                            font.weight: Font.Black
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "S.E.E.S. TACTICAL KEYBINDS // OPERATIONAL MANUAL"
                            color: "#FFFFFF"
                            font.family: "Rubik"
                            font.pixelSize: 16
                            font.weight: Font.Black
                            font.letterSpacing: 1.0
                        }
                        Text {
                            text: root.filteredBinds.length + " ACTIVE PROTOCOLS • PRESS [ESC] TO CLOSE"
                            color: "#00dbff"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Kotak Input Pencarian
                    Rectangle {
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 32
                        radius: 4
                        color: "#07122C"
                        border.color: searchInput.activeFocus ? "#00f0ff" : "#4000DBFF"
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
                                id: searchInput
                                Layout.fillWidth: true
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 11
                                font.bold: true
                                clip: true
                                selectByMouse: true
                                onTextChanged: root.searchQuery = text

                                Keys.onEscapePressed: PhantomState.cheatsheetOpen = false

                                Text {
                                    anchors.fill: parent
                                    visible: !searchInput.text && !searchInput.activeFocus
                                    text: "Filter shortcuts..."
                                    color: "#4A6894"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                }
                            }

                            // Tombol Bersihkan Pencarian
                            Text {
                                visible: searchInput.text.length > 0
                                text: "✕"
                                color: "#00f0ff"
                                font.pixelSize: 11
                                font.bold: true
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        searchInput.text = ""
                                        root.searchQuery = ""
                                    }
                                }
                            }
                        }
                    }

                    // Tombol Tutup [ESC]
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 4
                        color: closeBtnMouse.containsMouse ? "#d60032" : "#0A183C"
                        border.color: closeBtnMouse.containsMouse ? "#ffffff" : "#6000DBFF"
                        border.width: 1.4

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            id: closeBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.cheatsheetOpen = false
                        }
                    }
                }

                // -------------------------------------------------------------
                // 2. BARIS TAB KATEGORI
                // -------------------------------------------------------------
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.categories

                        delegate: Rectangle {
                            required property string modelData
                            readonly property bool isSel: root.activeCategory === modelData
                            height: 24
                            width: catTxt.implicitWidth + 20
                            radius: 3
                            color: isSel ? "#0028e0" : (catMouse.containsMouse ? "#0C1F48" : "#06122E")
                            border.color: isSel ? "#00f0ff" : (catMouse.containsMouse ? "#6000DBFF" : "#2000DBFF")
                            border.width: isSel ? 1.4 : 1.0

                            Text {
                                id: catTxt
                                anchors.centerIn: parent
                                text: parent.modelData
                                color: parent.isSel ? "#ffffff" : (catMouse.containsMouse ? "#00f0ff" : "#8AA6CE")
                                font.family: "Rubik"
                                font.pixelSize: 10
                                font.weight: parent.isSel ? Font.Black : Font.Bold
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

                // -------------------------------------------------------------
                // 3. DAFTAR KARTU SHORTCUT 2 KOLOM
                // -------------------------------------------------------------
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

                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 4
                                color: rowMouse.containsMouse ? "#0E2456" : "#071638"
                                border.color: rowMouse.containsMouse ? "#00f0ff" : "#2800DBFF"
                                border.width: rowMouse.containsMouse ? 1.4 : 1.0

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 8

                                    // Lencana Tombol Keybind
                                    Rectangle {
                                        width: kTxt.implicitWidth + 14
                                        height: 20
                                        color: rowMouse.containsMouse ? "#0028e0" : "#020B1C"
                                        border.color: rowMouse.containsMouse ? "#00f0ff" : "#00dbff"
                                        border.width: 1
                                        radius: 3

                                        Text {
                                            id: kTxt
                                            anchors.centerIn: parent
                                            text: modelData.key
                                            color: "#ffffff"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                        }
                                    }

                                    // Deskripsi Aksi
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.act
                                        color: rowMouse.containsMouse ? "#00f0ff" : "#ffffff"
                                        font.family: "Rubik"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                    }

                                    // Kategori
                                    Text {
                                        text: modelData.cat
                                        color: "#4A6E9E"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 8
                                        font.weight: Font.Black
                                    }
                                }

                                MouseArea {
                                    id: rowMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
