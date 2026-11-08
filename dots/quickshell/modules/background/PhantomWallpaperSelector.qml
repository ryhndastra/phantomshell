import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.components

// Selektor Wallpaper Persona 3 Reload: Ambient Dinamis 60fps & Shader Samudra Real-Time S.E.E.S.
Scope {
    id: wpScope

    property int activeTab: 0 // 0: Live Ambients, 1: Local Wallpapers / Videos
    property string searchQuery: ""
    property var localFiles: []

    // ── 7 Ambient Wallpaper Bawaan Persona 3 Reload ──
    readonly property var liveAmbients: [
        {
            id: "train_shader",
            name: "Gekkoukan Train // Aigis & Makoto",
            subtitle: "Kereta Komuter S.E.E.S. dengan Awan Prosedural 60FPS & Cuaca Real-Time",
            badge: "LIVE SHADER ENGINE",
            fps: "60 FPS",
            type: "Dynamic Cloud & Ripple Shader",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_train_shader.png"),
            isShader: true
        },
        {
            id: "velvet",
            name: "Sea of Soul // The Velvet Room",
            subtitle: "Elevator Bawah Air Velvet Room dengan Aliran Jiwa Biru Azure",
            badge: "1080P 60FPS AMBIENT",
            fps: "60 FPS",
            type: "Loop Video Ambient",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_velvet.png"),
            videoPath: "/home/sho/.config/quickshell/assets/themes/p3/videos/skills_ambient.mp4",
            isShader: false
        },
        {
            id: "dorm",
            name: "Iwatodai Dormitory // S.E.E.S. Lounge",
            subtitle: "Lantai 4 Markas Operasi S.E.E.S. dengan Suasana Santai Malam Hari",
            badge: "1080P 60FPS AMBIENT",
            fps: "60 FPS",
            type: "Loop Video Ambient",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_dorm.png"),
            videoPath: "/home/sho/.config/quickshell/assets/themes/p3/videos/dorm_ambient.mp4",
            isShader: false
        },
        {
            id: "monorail",
            name: "Port Island Monorail // Makoto Commute",
            subtitle: "Makoto Yuki Mendengarkan Musik di Atas Jembatan Tatsumi Port Island",
            badge: "1080P 60FPS AMBIENT",
            fps: "60 FPS",
            type: "Loop Video Ambient",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_monorail.png"),
            videoPath: "/home/sho/.config/quickshell/assets/themes/p3/videos/makoto_train_ambient.mp4",
            isShader: false
        },
        {
            id: "fuuka",
            name: "Gekkoukan Roof // Fuuka Yamagishi",
            subtitle: "Atap Sekolah Gekkoukan dengan Embusan Angin & Radar Persona Fuuka",
            badge: "1080P 60FPS AMBIENT",
            fps: "60 FPS",
            type: "Loop Video Ambient",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_fuuka.png"),
            videoPath: "/home/sho/.config/quickshell/assets/themes/p3/videos/fuuka_ambient.mp4",
            isShader: false
        },
        {
            id: "train_loop",
            name: "Tatsumi Bay Loop // Night Monorail",
            subtitle: "Pemandangan Jendela Kereta Malam Melewati Kilau Lampu Kota Pelabuhan",
            badge: "1080P 60FPS AMBIENT",
            fps: "60 FPS",
            type: "Loop Video Ambient",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_train_loop.png"),
            videoPath: "/home/sho/.config/quickshell/assets/themes/p3/videos/train_ambient.mp4",
            isShader: false
        },
        {
            id: "tartarus",
            name: "Tartarus Abyss // The Dark Hour",
            subtitle: "Fenomena Jam ke-25 Gelap Gulita dengan Kabut Hijau Emerald Tartarus",
            badge: "EMERALD HOUR SHADER",
            fps: "60 FPS",
            type: "Supernatural Dark Hour Engine",
            thumb: Qt.resolvedUrl("../../assets/themes/p3/thumbnails/thumb_tartarus.png"),
            isShader: true
        }
    ]

    readonly property var filteredLiveAmbients: {
        const q = searchQuery.trim().toLowerCase()
        if (q === "") return liveAmbients
        return liveAmbients.filter(item => {
            return item.name.toLowerCase().indexOf(q) !== -1 ||
                   item.subtitle.toLowerCase().indexOf(q) !== -1 ||
                   item.type.toLowerCase().indexOf(q) !== -1
        })
    }

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
            "find $HOME/Pictures/Wallpapers $HOME/Pictures -maxdepth 2 -type f \\( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' -o -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) 2>/dev/null | grep -vE 'pshell-wallpaper|thumbnails|menu/png|Depth masks|shaders' | awk '!seen[$0]++' | head -n 120"
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

            // Lapisan Latar Belakang Gelap Penutup Layar (Mencegah Bleed-Through)
            Rectangle {
                anchors.fill: parent
                color: "#B2020612"
                opacity: wpWin.visible ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: PhantomState.wallpaperSelectorOpen = false
                }
            }

            // Pintasan Tombol Escape untuk Menutup Selektor
            Shortcut {
                sequence: "Escape"
                onActivated: PhantomState.wallpaperSelectorOpen = false
            }

            // ── Kartu Dialog Utama Persona 3 Reload ──
            Rectangle {
                id: selectorModal
                width: Math.min(1180, parent.width - 48)
                height: Math.min(760, parent.height - 64)
                anchors.centerIn: parent
                color: "#040A1A"
                border.color: "#00B4D8"
                border.width: 1.5
                radius: 12
                clip: true

                // Aksen Bayangan Glowing Biru S.E.E.S.
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -1
                    color: "transparent"
                    border.color: "#3300F0FF"
                    border.width: 1
                    radius: 13
                    z: -1
                }

                ParallelAnimation {
                    id: wpModalAnim
                    NumberAnimation {
                        target: selectorModal
                        property: "scale"
                        from: 0.94
                        to: 1.0
                        duration: 220
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.15
                    }
                    NumberAnimation {
                        target: selectorModal
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                // Penahan Klik Agar Tidak Menembus ke Belakang
                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                // Garis Grid Cyber Dekoratif S.E.E.S. di Latar Belakang
                Canvas {
                    anchors.fill: parent
                    opacity: 0.04
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = "#00F0FF"
                        ctx.lineWidth = 1
                        for (var x = 0; x < width; x += 36) {
                            ctx.beginPath()
                            ctx.moveTo(x, 0)
                            ctx.lineTo(x, height)
                            ctx.stroke()
                        }
                        for (var y = 0; y < height; y += 36) {
                            ctx.beginPath()
                            ctx.moveTo(0, y)
                            ctx.lineTo(width, y)
                            ctx.stroke()
                        }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 16

                    // ── Header Panel: Identitas S.E.E.S., Pencarian & Tombol Tutup ──
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        spacing: 14

                        // Ikon Emblem S.E.E.S.
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 8
                            color: "#0A1733"
                            border.color: "#00B4D8"
                            border.width: 1.5

                            Rectangle {
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                radius: 4
                                color: "#00B4D8"
                                rotation: 45
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "3"
                                color: "#040A1A"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 14
                                font.weight: Font.Black
                            }
                        }

                        // Judul & Subtitle S.E.E.S. Atmosphere Engine
                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: "S.E.E.S. ATMOSPHERE ENGINE"
                                    color: "#F8FBFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 16
                                    font.weight: Font.Black
                                    font.letterSpacing: 1.2
                                }
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: 18
                                    width: 72
                                    radius: 3
                                    color: "#1600B4D8"
                                    border.color: "#00B4D8"
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: "60 FPS"
                                        color: "#00F0FF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }
                                }
                            }

                            Text {
                                text: "LIVE AMBIENT WALLPAPER SELECTOR // DYNAMIC SHADERS & 1080P CINEMATIC LOOPS"
                                color: "#8DA4C4"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 0.8
                            }
                        }

                        // Kolom Pencarian Cepat
                        Rectangle {
                            Layout.preferredWidth: 220
                            Layout.preferredHeight: 38
                            radius: 6
                            color: "#091224"
                            border.color: searchInput.activeFocus ? "#00F0FF" : "#1B2A4A"
                            border.width: 1.5

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: "🔍"
                                    color: "#8DA4C4"
                                    font.pixelSize: 11
                                }

                                TextInput {
                                    id: searchInput
                                    Layout.fillWidth: true
                                    color: "#F8FBFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    clip: true
                                    onTextChanged: wpScope.searchQuery = text

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Cari ambient / video..."
                                        color: "#546882"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        visible: searchInput.text.length === 0
                                    }
                                }
                            }
                        }

                        // Tombol Tutup Selektor (Esc)
                        Rectangle {
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 38
                            radius: 6
                            color: closeMouse.containsMouse ? "#FF2A6D" : "#0E1830"
                            border.color: closeMouse.containsMouse ? "#FF6B98" : "#22355A"
                            border.width: 1.5

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 14
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

                    // ── Tab Navigasi: Live Preinstalled vs Local Storage ──
                    Row {
                        Layout.fillWidth: true
                        spacing: 10

                        // Tab 0: S.E.E.S. Live Ambients
                        Rectangle {
                            width: tab0Row.implicitWidth + 28
                            height: 36
                            radius: 6
                            color: wpScope.activeTab === 0 ? "#00B4D8" : (tab0Mouse.containsMouse ? "#0E1B38" : "#070F22")
                            border.color: wpScope.activeTab === 0 ? "#00F0FF" : "#1B2E52"
                            border.width: 1.5

                            Row {
                                id: tab0Row
                                anchors.centerIn: parent
                                spacing: 8

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: wpScope.activeTab === 0 ? "#040A1A" : "#00F0FF"
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "PREINSTALLED LIVE AMBIENTS (" + wpScope.liveAmbients.length + ")"
                                    color: wpScope.activeTab === 0 ? "#040A1A" : "#F8FBFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                }
                            }

                            MouseArea {
                                id: tab0Mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    wpScope.activeTab = 0
                                    PhantomState.playSfx("select")
                                }
                            }
                        }

                        // Tab 1: Local Wallpapers & Custom Videos
                        Rectangle {
                            width: tab1Row.implicitWidth + 28
                            height: 36
                            radius: 6
                            color: wpScope.activeTab === 1 ? "#00B4D8" : (tab1Mouse.containsMouse ? "#0E1B38" : "#070F22")
                            border.color: wpScope.activeTab === 1 ? "#00F0FF" : "#1B2E52"
                            border.width: 1.5

                            Row {
                                id: tab1Row
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "📁"
                                    font.pixelSize: 11
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "CUSTOM STORAGE & VIDEOS (" + wpScope.localFiles.length + ")"
                                    color: wpScope.activeTab === 1 ? "#040A1A" : "#F8FBFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                }
                            }

                            MouseArea {
                                id: tab1Mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    wpScope.activeTab = 1
                                    wpScope.scanLocalWallpapers()
                                    PhantomState.playSfx("select")
                                }
                            }
                        }
                    }

                    // Garis Pemisah Cyan
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#182C4E"
                    }

                    // ── Konten Utama Grid Wallpaper ──
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
                            cellHeight: 250
                            boundsBehavior: Flickable.StopAtBounds
                            cacheBuffer: 500
                            model: wpScope.filteredLiveAmbients

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
                                    anchors.margins: 8
                                    radius: 8
                                    color: liveCardDelegate.isEquipped ? "#0B1D3D" : (liveCardDelegate.isHov ? "#091730" : "#060F22")
                                    border.color: liveCardDelegate.isEquipped ? "#05FFA1" : (liveCardDelegate.isHov ? "#00F0FF" : "#1A2C4C")
                                    border.width: liveCardDelegate.isEquipped ? 2 : (liveCardDelegate.isHov ? 1.5 : 1)
                                    clip: true

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        spacing: 8

                                        // Area Gambar Pratinjau 16:9
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            radius: 6
                                            color: "#030712"
                                            clip: true

                                            Image {
                                                anchors.fill: parent
                                                source: modelData.thumb
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: true
                                                mipmap: true
                                                scale: liveCardDelegate.isHov ? 1.04 : 1.0
                                                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                                            }

                                            // Vignette Bawah Thumbnail
                                            Rectangle {
                                                anchors.fill: parent
                                                gradient: Gradient {
                                                    GradientStop { position: 0.0; color: "#22000000" }
                                                    GradientStop { position: 0.65; color: "#00000000" }
                                                    GradientStop { position: 1.0; color: "#77000000" }
                                                }
                                            }

                                            // Badge Tipe & Resolusi (Kiri Atas)
                                            Rectangle {
                                                anchors.top: parent.top
                                                anchors.left: parent.left
                                                anchors.margins: 8
                                                height: 20
                                                width: badgeText.implicitWidth + 14
                                                radius: 4
                                                color: "#B2040A1A"
                                                border.color: "#3300F0FF"
                                                border.width: 1

                                                Row {
                                                    anchors.centerIn: parent
                                                    spacing: 4
                                                    Rectangle {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        width: 6
                                                        height: 6
                                                        radius: 3
                                                        color: "#00F0FF"
                                                    }
                                                    Text {
                                                        id: badgeText
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        text: modelData.badge
                                                        color: "#00F0FF"
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 8
                                                        font.weight: Font.Black
                                                    }
                                                }
                                            }

                                            // Lencana EQUIPPED (Kanan Atas)
                                            Rectangle {
                                                visible: liveCardDelegate.isEquipped
                                                anchors.top: parent.top
                                                anchors.right: parent.right
                                                anchors.margins: 8
                                                height: 22
                                                width: equippedText.implicitWidth + 16
                                                radius: 4
                                                color: "#05FFA1"

                                                Text {
                                                    id: equippedText
                                                    anchors.centerIn: parent
                                                    text: "★ ACTIVE SCENE"
                                                    color: "#040A1A"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Black
                                                }
                                            }
                                        }

                                        // Bagian Bawah: Judul Ambient & Tombol Equip
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 38
                                            spacing: 6

                                            Column {
                                                Layout.fillWidth: true
                                                spacing: 2

                                                Text {
                                                    width: parent.width
                                                    text: modelData.name
                                                    color: liveCardDelegate.isEquipped ? "#05FFA1" : "#F8FBFF"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Black
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    width: parent.width
                                                    text: modelData.subtitle
                                                    color: "#8DA4C4"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Bold
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            // Tombol Equip
                                            Rectangle {
                                                Layout.preferredWidth: 84
                                                Layout.preferredHeight: 28
                                                radius: 4
                                                color: liveCardDelegate.isEquipped
                                                    ? "#1405FFA1"
                                                    : (cardArea.containsMouse ? "#00B4D8" : "#0E1A33")
                                                border.color: liveCardDelegate.isEquipped
                                                    ? "#05FFA1"
                                                    : (cardArea.containsMouse ? "#00F0FF" : "#1B2C4C")
                                                border.width: 1

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: liveCardDelegate.isEquipped ? "RUNNING" : "EQUIP →"
                                                    color: liveCardDelegate.isEquipped
                                                        ? "#05FFA1"
                                                        : (cardArea.containsMouse ? "#040A1A" : "#8DA4C4")
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Black
                                                }
                                            }
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
                                    color: localCardDelegate.isEquipped ? "#0B1D3D" : (localCardDelegate.isHov ? "#091730" : "#060F22")
                                    border.color: localCardDelegate.isEquipped ? "#05FFA1" : (localCardDelegate.isHov ? "#00F0FF" : "#1A2C4C")
                                    border.width: localCardDelegate.isEquipped ? 2 : 1
                                    clip: true

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        spacing: 6

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            radius: 4
                                            color: "#030712"
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
                                            }

                                            // Badge Video vs Image
                                            Rectangle {
                                                anchors.top: parent.top
                                                anchors.left: parent.left
                                                anchors.margins: 6
                                                height: 18
                                                width: 58
                                                radius: 3
                                                color: "#B2040A1A"
                                                border.color: modelData.isVideo ? "#00F0FF" : "#8DA4C4"
                                                border.width: 1

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.isVideo ? "▶ VIDEO" : "🖼 IMAGE"
                                                    color: modelData.isVideo ? "#00F0FF" : "#F8FBFF"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 8
                                                    font.weight: Font.Black
                                                }
                                            }

                                            // Lencana EQUIPPED
                                            Rectangle {
                                                visible: localCardDelegate.isEquipped
                                                anchors.top: parent.top
                                                anchors.right: parent.right
                                                anchors.margins: 6
                                                height: 18
                                                width: 68
                                                radius: 3
                                                color: "#05FFA1"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "★ ACTIVE"
                                                    color: "#040A1A"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 8
                                                    font.weight: Font.Black
                                                }
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignHCenter
                                            text: modelData.name
                                            color: localCardDelegate.isEquipped ? "#05FFA1" : "#8DA4C4"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                            elide: Text.ElideMiddle
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

                    // ── Strip Kontrol Bawah: Pengaturan Atmosfer Waktu & Mode Kinerja ──
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        radius: 8
                        color: "#060F22"
                        border.color: "#182C4E"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 12

                            // Pemilih Fase Waktu Atmosfer (Khusus Train & Tartarus Engine)
                            Row {
                                spacing: 6
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "FASE WAKTU:"
                                    color: "#8DA4C4"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                }

                                Repeater {
                                    model: [
                                        { id: "auto", label: "AUTO (JAM NYATA)" },
                                        { id: "morning", label: "PAGI" },
                                        { id: "afterschool", label: "SIANG AZURE" },
                                        { id: "evening", label: "SENJA" },
                                        { id: "night", label: "MALAM" },
                                        { id: "darkhour", label: "DARK HOUR" }
                                    ]

                                    delegate: Rectangle {
                                        required property var modelData
                                        width: phaseBtnText.implicitWidth + 14
                                        height: 26
                                        radius: 4
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

                            // Toggle Jeda Otomatis Saat Ada Jendela Aktif
                            Row {
                                spacing: 8
                                Layout.alignment: Qt.AlignVCenter

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "HEMAT GPU/BATERAI:"
                                    color: "#8DA4C4"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                }

                                Rectangle {
                                    width: pauseText.implicitWidth + 16
                                    height: 26
                                    radius: 4
                                    color: PhantomState.p3WallpaperAutoPause ? "#1405FFA1" : "#1A2438"
                                    border.color: PhantomState.p3WallpaperAutoPause ? "#05FFA1" : "#2E3D5C"
                                    border.width: 1

                                    Text {
                                        id: pauseText
                                        anchors.centerIn: parent
                                        text: PhantomState.p3WallpaperAutoPause ? "● JEDA AKTIF" : "○ SELALU JALAN"
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
