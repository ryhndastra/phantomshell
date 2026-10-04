import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.components

Scope {
    id: wpScope

    property string activeCategory: "wallpapers" // "home" | "wallpapers" | "phantom"
    property string searchQuery: ""
    property var allFiles: []

    readonly property var filteredFiles: {
        const q = searchQuery.trim().toLowerCase()
        if (q === "") return allFiles
        return allFiles.filter(item => item.name.toLowerCase().indexOf(q) !== -1)
    }

    function scanFolder(category) {
        activeCategory = category
        wpScanProc.running = false
        wpScanProc.running = true
    }

    function pickRandomWallpaper() {
        const pool = filteredFiles.length > 0 ? filteredFiles : allFiles
        if (pool.length === 0) {
            PhantomState.cycleWallpaper()
            return
        }
        let candidates = pool.filter(item => item.path !== PhantomState.wallpaperPath)
        if (candidates.length === 0) candidates = pool
        const pick = candidates[Math.floor(Math.random() * candidates.length)]
        if (pick && pick.path) {
            PhantomState.setWallpaper(pick.path)
        }
    }

    Process {
        id: wpScanProc
        command: [
            "bash", "-c",
            "CAT='" + wpScope.activeCategory + "'; " +
            "if [ \"$CAT\" = 'home' ]; then " +
            "  DIRS=\"$HOME/Pictures $HOME/Downloads $HOME\"; MAXD=1; " +
            "elif [ \"$CAT\" = 'phantom' ]; then " +
            "  DIRS=\"/mnt/data/Projects/rice/phantomshell/dots/quickshell/assets $HOME/Pictures/Wallpapers\"; MAXD=2; " +
            "else " +
            "  DIRS=\"$HOME/Pictures/Wallpapers /mnt/data/Projects/rice/phantomshell/dots/quickshell/assets\"; MAXD=2; " +
            "fi; " +
            "find $DIRS -maxdepth $MAXD -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) 2>/dev/null " +
            "| grep -vE '/pshell\\.png$|/pshell-(p3|p4|kasumi|akechi|futaba|monochrome|expressive|tonal)' | awk '!seen[$0]++' | head -n 120"
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
                    if (wpScope.activeCategory === "phantom" && i > 0) {
                        const low = name.toLowerCase()
                        if (low.indexOf("pshell") === -1 && low.indexOf("p5") === -1 && low.indexOf("persona") === -1 && items.length >= 12) {
                            continue
                        }
                    }
                    items.push({
                        path: p,
                        name: name
                    })
                }
                wpScope.allFiles = items
            }
        }
    }

    Component.onCompleted: {
        scanFolder("wallpapers")
    }

    Variants {
        model: Quickshell.screens

        // jendela panel pemilih wallpaper
        PanelWindow {
            id: wpWin
            required property ShellScreen modelData
            screen: modelData
            visible: PhantomState.wallpaperSelectorOpen

            readonly property bool isBottom: PhantomState.barPosition === "bottom"

            WlrLayershell.namespace: "phantomshell-wallpaper-selector"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: (PhantomState.wallpaperSelectorOpen && searchInput.activeFocus)
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
                    wpEntryAnim.restart()
                    if (wpScope.allFiles.length === 0) {
                        wpScope.scanFolder(wpScope.activeCategory)
                    }
                } else {
                    searchInput.focus = false
                }
            }

            // area klik luar untuk menutup panel
            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.wallpaperSelectorOpen = false
            }

            // kontainer utama kartu pemilih wallpaper
            Item {
                id: selectorCard
                width: Math.min(1060, parent.width - 48)
                height: Math.min(640, parent.height - 96)
                anchors.horizontalCenter: parent.horizontalCenter
                y: wpWin.isBottom ? (parent.height - height - 50) : 50
                transformOrigin: wpWin.isBottom ? Item.Bottom : Item.Top

                ParallelAnimation {
                    id: wpEntryAnim
                    NumberAnimation {
                        target: selectorCard
                        property: "scale"
                        from: 0.88
                        to: 1.0
                        duration: 240
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.28
                    }
                    NumberAnimation {
                        target: selectorCard
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                // penahan klik di dalam kartu agar tidak menutup panel
                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                // bingkai luar miring dengan bayangan aksen
                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: "#0B0C12"
                    borderColor: "#FFFFFF"
                    shadowColor: PhantomState.primary
                    borderWidth: 2.5
                    skewPx: PhantomState.polygonMode ? 10 : 0
                    shadowOffsetX: 6
                    shadowOffsetY: 6
                }

                // aksen pita miring di sudut kanan atas latar belakang
                Canvas {
                    anchors.fill: parent
                    opacity: 0.14
                    property color cPrimary: PhantomState.primary
                    onCPrimaryChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.fillStyle = cPrimary
                        ctx.beginPath()
                        ctx.moveTo(width - 260, 0)
                        ctx.lineTo(width - 140, 0)
                        ctx.lineTo(width - 20, height)
                        ctx.lineTo(width - 140, height)
                        ctx.closePath()
                        ctx.fill()
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    // baris header judul, tab kategori, tombol acak, dan kolom pencarian
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        spacing: 12

                        // bagian kiri: ikon dan judul pemilih wallpaper
                        Row {
                            spacing: 10
                            Layout.alignment: Qt.AlignVCenter

                            Item {
                                width: 36
                                height: 34
                                anchors.verticalCenter: parent.verticalCenter

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: PhantomState.primary
                                    borderColor: "#FFFFFF"
                                    shadowColor: PhantomState.secondary
                                    borderWidth: 1.5
                                    skewPx: 5
                                    shadowOffsetX: 2
                                    shadowOffsetY: 2
                                }

                                P5Icon {
                                    anchors.centerIn: parent
                                    name: "wallpaper"
                                    size: 16
                                    color: "#FFFFFF"
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 0

                                Text {
                                    text: "WALLPAPER SELECTOR"
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 15
                                    font.weight: Font.Black
                                    font.italic: true
                                }
                                Text {
                                    text: "METAVERSE VISUAL GALLERY // " + wpScope.filteredFiles.length + " ARTWORKS"
                                    color: PhantomState.secondary
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // bagian tengah: tab navigasi kategori dan tombol acak
                        Item {
                            Layout.preferredWidth: navTabsRow.implicitWidth + 24
                            Layout.preferredHeight: 38

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: "#131520"
                                borderColor: "#35384D"
                                shadowColor: "#05060A"
                                borderWidth: 1.5
                                skewPx: 7
                                shadowOffsetX: 3
                                shadowOffsetY: 3
                            }

                            Row {
                                id: navTabsRow
                                anchors.centerIn: parent
                                spacing: 6

                                // daftar tab sumber folder wallpaper
                                Repeater {
                                    model: [
                                        { id: "home",       label: "Home",       icon: "home" },
                                        { id: "wallpapers", label: "Wallpapers", icon: "wallpaper" },
                                        { id: "phantom",    label: "Phantom",    icon: "phantom" }
                                    ]

                                    delegate: Item {
                                        required property var modelData
                                        readonly property bool isAct: wpScope.activeCategory === modelData.id
                                        width: tabInnerRow.implicitWidth + 22
                                        height: 28

                                        P5SkewedCard {
                                            anchors.fill: parent
                                            fillColor: parent.isAct ? PhantomState.primary : (tabMouse.containsMouse ? "#222536" : "transparent")
                                            borderColor: parent.isAct ? "#FFFFFF" : "transparent"
                                            shadowColor: parent.isAct ? PhantomState.secondary : "transparent"
                                            showShadowOffset: parent.isAct
                                            borderWidth: parent.isAct ? 1.5 : 0
                                            skewPx: 5
                                            shadowOffsetX: 2
                                            shadowOffsetY: 2
                                        }

                                        Row {
                                            id: tabInnerRow
                                            anchors.centerIn: parent
                                            spacing: 6

                                            P5Icon {
                                                anchors.verticalCenter: parent.verticalCenter
                                                name: modelData.icon
                                                size: 13
                                                color: parent.parent.isAct ? "#FFFFFF" : PhantomState.muted
                                            }
                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.label
                                                color: parent.parent.isAct ? "#FFFFFF" : "#D0D2E0"
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 11
                                                font.weight: Font.Black
                                                font.italic: parent.parent.isAct
                                            }
                                        }

                                        MouseArea {
                                            id: tabMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: wpScope.scanFolder(modelData.id)
                                        }
                                    }
                                }

                                // tombol pilih wallpaper acak
                                Item {
                                    width: randInnerRow.implicitWidth + 22
                                    height: 28

                                    P5SkewedCard {
                                        anchors.fill: parent
                                        fillColor: randMouse.containsMouse ? PhantomState.secondary : "#1D2030"
                                        borderColor: randMouse.containsMouse ? "#05060A" : PhantomState.secondary
                                        showShadowOffset: false
                                        borderWidth: 1.5
                                        skewPx: 5
                                    }

                                    Row {
                                        id: randInnerRow
                                        anchors.centerIn: parent
                                        spacing: 6

                                        P5Icon {
                                            anchors.verticalCenter: parent.verticalCenter
                                            name: "random"
                                            size: 13
                                            color: randMouse.containsMouse ? "#05060A" : PhantomState.secondary
                                        }
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "Random"
                                            color: randMouse.containsMouse ? "#05060A" : "#FFFFFF"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 11
                                            font.weight: Font.Black
                                            font.italic: true
                                        }
                                    }

                                    MouseArea {
                                        id: randMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: wpScope.pickRandomWallpaper()
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // bagian kanan: kolom pencarian dan tombol tutup
                        Row {
                            spacing: 8
                            Layout.alignment: Qt.AlignVCenter

                            // kotak pencarian nama file wallpaper
                            Item {
                                width: 176
                                height: 34

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: "#141622"
                                    borderColor: searchInput.activeFocus ? PhantomState.secondary : "#3A3D52"
                                    shadowColor: searchInput.activeFocus ? PhantomState.primary : "#05060A"
                                    borderWidth: 1.5
                                    skewPx: 6
                                    shadowOffsetX: 2
                                    shadowOffsetY: 2
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 10
                                    spacing: 6

                                    P5Icon {
                                        name: "search"
                                        size: 12
                                        color: PhantomState.secondary
                                    }

                                    TextInput {
                                        id: searchInput
                                        Layout.fillWidth: true
                                        color: "#FFFFFF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        clip: true
                                        onTextChanged: wpScope.searchQuery = text

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "Search wallpaper..."
                                            color: "#76798E"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 10
                                            visible: searchInput.text.length === 0
                                        }
                                    }
                                }
                            }

                            // tombol tutup panel
                            Item {
                                width: 34
                                height: 34

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: closeMouse.containsMouse ? PhantomState.primary : "#181A28"
                                    borderColor: "#FFFFFF"
                                    shadowColor: PhantomState.primary
                                    borderWidth: 1.5
                                    skewPx: 5
                                    shadowOffsetX: 2
                                    shadowOffsetY: 2
                                }

                                P5Icon {
                                    anchors.centerIn: parent
                                    name: "close"
                                    size: 12
                                    color: "#FFFFFF"
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
                    }

                    // garis pemisah horizontal
                    Rectangle {
                        Layout.fillWidth: true
                        height: 2
                        color: PhantomState.primary
                    }

                    // grid empat kolom kartu pratinjau wallpaper
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        GridView {
                            id: wpGrid
                            anchors.fill: parent
                            clip: true
                            cellWidth: Math.floor(width / 4)
                            cellHeight: 168
                            boundsBehavior: Flickable.StopAtBounds
                            cacheBuffer: 340
                            model: wpScope.filteredFiles

                            delegate: Item {
                                required property var modelData
                                required property int index
                                width: wpGrid.cellWidth
                                height: wpGrid.cellHeight

                                readonly property bool isEquipped: PhantomState.wallpaperPath === modelData.path
                                readonly property bool isHov: cardMouse.containsMouse

                                Item {
                                    anchors.fill: parent
                                    anchors.margins: 7
                                    scale: parent.isHov ? 1.03 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

                                    // bingkai kartu pratinjau
                                    P5SkewedCard {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        height: parent.height - 22
                                        fillColor: "#151722"
                                        borderColor: isEquipped ? "#00F59B" : (isHov ? "#FFFFFF" : "#32354A")
                                        shadowColor: isEquipped ? "#00F59B" : (isHov ? PhantomState.primary : "#05060A")
                                        borderWidth: (isEquipped || isHov) ? 2.2 : 1.2
                                        skewPx: 6
                                        shadowOffsetX: (isEquipped || isHov) ? 4 : 2
                                        shadowOffsetY: (isEquipped || isHov) ? 4 : 2
                                    }

                                    // gambar thumbnail pratinjau wallpaper
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        height: parent.height - 22
                                        anchors.margins: 5
                                        color: "#0D0E15"
                                        clip: true

                                        Image {
                                            anchors.fill: parent
                                            source: "file://" + modelData.path
                                            sourceSize.width: 360
                                            sourceSize.height: 202
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            cache: true
                                            smooth: true
                                        }

                                        // lencana penanda wallpaper aktif
                                        Rectangle {
                                            visible: isEquipped
                                            anchors.top: parent.top
                                            anchors.right: parent.right
                                            anchors.margins: 6
                                            width: 78
                                            height: 20
                                            color: "#00F59B"
                                            border.color: "#05060A"
                                            border.width: 1.5
                                            rotation: -3

                                            Text {
                                                anchors.centerIn: parent
                                                text: "★ EQUIPPED"
                                                color: "#05060A"
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 8
                                                font.weight: Font.Black
                                            }
                                        }
                                    }

                                    // label nama file wallpaper di bawah gambar
                                    Text {
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: parent.width - 12
                                        horizontalAlignment: Text.AlignHCenter
                                        text: modelData.name
                                        color: isEquipped ? "#00F59B" : (isHov ? PhantomState.secondary : "#D4D7E6")
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        font.weight: (isEquipped || isHov) ? Font.Black : Font.Bold
                                        font.italic: isEquipped || isHov
                                        elide: Text.ElideMiddle
                                    }

                                    MouseArea {
                                        id: cardMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.setWallpaper(modelData.path)
                                            PhantomState.wallpaperSelectorOpen = false
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
