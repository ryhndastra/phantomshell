import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config

// Selektor Wallpaper Persona 3 Reload: Minimalis, Bersih, Anti-Alay, Tanpa Ikon
Scope {
    id: wpScope

    property int activeTab: PhantomState.wallpaperSelectorTab
    property string searchQuery: ""
    property var localFiles: []

    // 7 Ambient Wallpaper Bawaan Persona 3 Reload
    readonly property var liveAmbients: [
        {
            id: "train_shader",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_train_shader.png")
        },
        {
            id: "velvet",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_velvet.png")
        },
        {
            id: "dorm",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_dorm.png")
        },
        {
            id: "monorail",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_monorail.png")
        },
        {
            id: "fuuka",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_fuuka.png")
        },
        {
            id: "train_loop",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_train_loop.png")
        },
        {
            id: "tartarus",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_tartarus.png")
        }
    ]

    readonly property var filteredLocalFiles: {
        const q = searchQuery.trim().toLowerCase()
        if (q === "") return localFiles
        return localFiles.filter(item => item.name.toLowerCase().indexOf(q) !== -1)
    }

    function scanLocalWallpapers() {
        localScanProc.running = false
        localScanProc.running = true
    }

    Process {
        id: localScanProc
        command: [
            "bash", "-c",
            "find $HOME/Pictures/Wallpapers -maxdepth 2 -type f \\( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' -o -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) 2>/dev/null | grep -vE 'pshell-wallpaper|thumbnails|menu/png|Depth masks|shaders' | awk '!seen[$0]++' | head -n 120"
        ]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const lines = String(data).trim().split("\n")
                const items = []
                for (let i = 0; i < lines.length; i++) {
                    const p = lines[i].trim()
                    if (!p) continue
                    const name = p.split("/").pop()
                    const isVideo = p.match(/\.(mp4|webm|mkv|mov|avi)$/i) !== null
                    items.push({
                        path: p,
                        name: name,
                        isVideo: isVideo
                    })
                }
                wpScope.localFiles = items
            }
        }
    }

    Component.onCompleted: {
        scanLocalWallpapers()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: wpWin
            required property ShellScreen modelData
            screen: modelData
            visible: PhantomState.wallpaperSelectorOpen

            WlrLayershell.namespace: "phantomshell-wallpaper-selector"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: PhantomState.wallpaperSelectorOpen
                ? WlrKeyboardFocus.OnDemand
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
                    wpModalAnim.restart()
                    if (wpScope.localFiles.length === 0) {
                        wpScope.scanLocalWallpapers()
                    }
                } else {
                    searchInput.focus = false
                }
            }

            // Lapisan Latar Belakang Gelap Penutup Layar
            Rectangle {
                anchors.fill: parent
                color: "#B2020612"
                opacity: wpWin.visible ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: PhantomState.wallpaperSelectorOpen = false
                }
            }

            // Pintasan Tombol Escape
            Shortcut {
                sequence: "Escape"
                onActivated: PhantomState.wallpaperSelectorOpen = false
            }

            // ── Kartu Dialog Utama Persona 3 Reload ──
            Rectangle {
                id: selectorModal
                width: Math.min(1180, parent.width - 48)
                height: Math.min(740, parent.height - 64)
                anchors.centerIn: parent
                color: "#040A1A"
                border.color: "#00B4D8"
                border.width: 1.5
                radius: 10
                clip: true

                ParallelAnimation {
                    id: wpModalAnim
                    NumberAnimation {
                        target: selectorModal
                        property: "scale"
                        from: 0.95
                        to: 1.0
                        duration: 200
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.15
                    }
                    NumberAnimation {
                        target: selectorModal
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    // ── Header Bersih Tanpa Ikon ──
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        spacing: 14

                        Text {
                            text: "WALLPAPER SELECTOR"
                            color: "#F8FBFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 15
                            font.weight: Font.Black
                            font.letterSpacing: 1.2
                        }

                        // Tab Navigasi Bersih
                        Row {
                            spacing: 8
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                width: tab0Txt.implicitWidth + 24
                                height: 32
                                radius: 4
                                color: wpScope.activeTab === 0 ? "#00B4D8" : (tab0Mouse.containsMouse ? "#0E1B38" : "#070F22")
                                border.color: wpScope.activeTab === 0 ? "#00F0FF" : "#1B2E52"
                                border.width: 1

                                Text {
                                    id: tab0Txt
                                    anchors.centerIn: parent
                                    text: "PREINSTALLED AMBIENT"
                                    color: wpScope.activeTab === 0 ? "#040A1A" : "#F8FBFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                }

                                MouseArea {
                                    id: tab0Mouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.wallpaperSelectorTab = 0
                                        PhantomState.playSfx("select")
                                    }
                                }
                            }

                            Rectangle {
                                width: tab1Txt.implicitWidth + 24
                                height: 32
                                radius: 4
                                color: wpScope.activeTab === 1 ? "#00B4D8" : (tab1Mouse.containsMouse ? "#0E1B38" : "#070F22")
                                border.color: wpScope.activeTab === 1 ? "#00F0FF" : "#1B2E52"
                                border.width: 1

                                Text {
                                    id: tab1Txt
                                    anchors.centerIn: parent
                                    text: "WALLPAPERS"
                                    color: wpScope.activeTab === 1 ? "#040A1A" : "#F8FBFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                }

                                MouseArea {
                                    id: tab1Mouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.wallpaperSelectorTab = 1
                                        wpScope.scanLocalWallpapers()
                                        PhantomState.playSfx("select")
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Kolom Pencarian
                        Rectangle {
                            visible: wpScope.activeTab === 1
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 32
                            radius: 4
                            color: "#091224"
                            border.color: searchInput.activeFocus ? "#00F0FF" : "#1B2A4A"
                            border.width: 1

                            TextInput {
                                id: searchInput
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                verticalAlignment: TextInput.AlignVCenter
                                color: "#F8FBFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                clip: true
                                onTextChanged: wpScope.searchQuery = text

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Search wallpapers..."
                                    color: "#546882"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    visible: searchInput.text.length === 0
                                }
                            }
                        }

                        // Tombol Tutup Bersih
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 4
                            color: closeMouse.containsMouse ? "#FF2A6D" : "#0E1830"
                            border.color: closeMouse.containsMouse ? "#FF6B98" : "#22355A"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 12
                                font.weight: Font.Black
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.wallpaperSelectorOpen = false
                            }
                        }
                    }

                    // Garis Pemisah Cyan
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#182C4E"
                    }

                    // ── Konten Utama Grid Wallpaper Murni Pratinjau (Tanpa Judul Alay) ──
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // View 0: Grid Live Ambients Persona 3 Reload
                        GridView {
                            id: liveGrid
                            visible: wpScope.activeTab === 0
                            anchors.fill: parent
                            clip: true
                            cellWidth: Math.floor(width / 3)
                            cellHeight: 215
                            boundsBehavior: Flickable.StopAtBounds
                            cacheBuffer: 500
                            model: wpScope.liveAmbients

                            delegate: Item {
                                id: liveCardDelegate
                                required property var modelData
                                required property int index
                                width: liveGrid.cellWidth
                                height: liveGrid.cellHeight

                                readonly property bool isEquipped: {
                                    if (modelData.id === "train_shader") {
                                        return PhantomState.p3LiveScene === "train_shader" || PhantomState.p3LiveScene === "" || PhantomState.p3LiveScene === undefined
                                    }
                                    return PhantomState.p3LiveScene === modelData.id
                                }
                                readonly property bool isHov: cardArea.containsMouse

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    radius: 6
                                    color: "#030712"
                                    border.color: liveCardDelegate.isEquipped ? "#05FFA1" : (liveCardDelegate.isHov ? "#00F0FF" : "#1A2C4C")
                                    border.width: liveCardDelegate.isEquipped ? 2.5 : (liveCardDelegate.isHov ? 1.5 : 1)
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: modelData.thumb
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        mipmap: true
                                        scale: liveCardDelegate.isHov ? 1.03 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                                    }

                                    // Lencana ACTIVE yang Minimalis di Sudut Kanan Atas
                                    Rectangle {
                                        visible: liveCardDelegate.isEquipped
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 8
                                        height: 20
                                        width: 58
                                        radius: 3
                                        color: "#05FFA1"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "ACTIVE"
                                            color: "#040A1A"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                        }
                                    }

                                    MouseArea {
                                        id: cardArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.setWallpaper(modelData.id)
                                        }
                                    }
                                }
                            }
                        }

                        // View 1: Grid Wallpaper / Video Kustom
                        GridView {
                            id: localGrid
                            visible: wpScope.activeTab === 1
                            anchors.fill: parent
                            clip: true
                            cellWidth: Math.floor(width / 4)
                            cellHeight: 180
                            boundsBehavior: Flickable.StopAtBounds
                            cacheBuffer: 300
                            model: wpScope.filteredLocalFiles

                            delegate: Item {
                                id: localCardDelegate
                                required property var modelData
                                required property int index
                                width: localGrid.cellWidth
                                height: localGrid.cellHeight

                                readonly property bool isEquipped: PhantomState.wallpaperPath === modelData.path
                                readonly property bool isHov: localCardMouse.containsMouse

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    radius: 6
                                    color: "#030712"
                                    border.color: localCardDelegate.isEquipped ? "#05FFA1" : (localCardDelegate.isHov ? "#00F0FF" : "#1A2C4C")
                                    border.width: localCardDelegate.isEquipped ? 2.5 : (localCardDelegate.isHov ? 1.5 : 1)
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: "file://" + modelData.path
                                        sourceSize.width: 320
                                        sourceSize.height: 180
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        smooth: true
                                        scale: localCardDelegate.isHov ? 1.03 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                                    }

                                    // Indikator Format Video
                                    Rectangle {
                                        visible: modelData.isVideo
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.margins: 8
                                        height: 18
                                        width: 48
                                        radius: 3
                                        color: "#B2001D4A"
                                        border.color: "#00F0FF"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: "VIDEO"
                                            color: "#00F0FF"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 8
                                            font.weight: Font.Black
                                        }
                                    }

                                    // Lencana ACTIVE Minimalis di Sudut Kanan Atas
                                    Rectangle {
                                        visible: localCardDelegate.isEquipped
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 8
                                        height: 20
                                        width: 58
                                        radius: 3
                                        color: "#05FFA1"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "ACTIVE"
                                            color: "#040A1A"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                        }
                                    }

                                    MouseArea {
                                        id: localCardMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.setWallpaper(modelData.path)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Strip Kontrol Bawah Bersih ──
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 6
                        color: "#060F22"
                        border.color: "#182C4E"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            Row {
                                spacing: 6
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "TIME PHASE:"
                                    color: "#8DA4C4"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                }

                                Repeater {
                                    model: [
                                        { id: "auto", label: "AUTO" },
                                        { id: "morning", label: "MORNING" },
                                        { id: "afterschool", label: "AFTER SCHOOL" },
                                        { id: "evening", label: "EVENING" },
                                        { id: "night", label: "NIGHT" },
                                        { id: "darkhour", label: "DARK HOUR" }
                                    ]

                                    delegate: Rectangle {
                                        required property var modelData
                                        width: phaseBtnText.implicitWidth + 12
                                        height: 24
                                        radius: 3
                                        color: PhantomState.p3TimePhaseOverride === modelData.id
                                            ? "#00B4D8"
                                            : (phaseMouse.containsMouse ? "#0E1D3B" : "#0A1428")
                                        border.color: PhantomState.p3TimePhaseOverride === modelData.id
                                            ? "#00F0FF"
                                            : "#1C2E4E"
                                        border.width: 1

                                        Text {
                                            id: phaseBtnText
                                            anchors.centerIn: parent
                                            text: modelData.label
                                            color: PhantomState.p3TimePhaseOverride === modelData.id
                                                ? "#040A1A"
                                                : "#F8FBFF"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                        }

                                        MouseArea {
                                            id: phaseMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                PhantomState.setTimePhase(modelData.id)
                                                PhantomState.playSfx("select")
                                            }
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // Toggle Jeda Otomatis
                            Row {
                                spacing: 8
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "GPU OPTIMIZATION:"
                                    color: "#8DA4C4"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                }

                                Rectangle {
                                    width: pauseText.implicitWidth + 14
                                    height: 24
                                    radius: 3
                                    color: PhantomState.p3WallpaperAutoPause ? "#1405FFA1" : "#1A2438"
                                    border.color: PhantomState.p3WallpaperAutoPause ? "#05FFA1" : "#2E3D5C"
                                    border.width: 1

                                    Text {
                                        id: pauseText
                                        anchors.centerIn: parent
                                        text: PhantomState.p3WallpaperAutoPause ? "AUTO-PAUSE" : "ALWAYS ACTIVE"
                                        color: PhantomState.p3WallpaperAutoPause ? "#05FFA1" : "#8DA4C4"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.p3WallpaperAutoPause = !PhantomState.p3WallpaperAutoPause
                                            PhantomState.saveState()
                                            PhantomState.playSfx("select")
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
