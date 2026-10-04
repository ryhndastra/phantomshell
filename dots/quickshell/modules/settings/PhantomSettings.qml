import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: settingsWin
        property var modelData
        screen: modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: PhantomState.settingsOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"
        visible: PhantomState.settingsOpen || fadeBg.opacity > 0.01
        onVisibleChanged: {
            if (visible) PhantomState.refreshMonitors()
        }

        // indeks tab pengaturan yang sedang aktif
        property int activeTab: 0
        property int brightnessPct: 80
        property bool showDisplayModeDropdown: false

        // komponen header sub-bagian pengaturan
        component P5SectionHeader: Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            property string text: ""

            RowLayout {
                anchors.fill: parent
                spacing: 8
                P5Icon { name: "star"; size: 12; color: PhantomState.secondary }
                Text {
                    text: parent.parent.text
                    color: PhantomState.secondary
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 12
                    font.weight: Font.Black
                    font.italic: true
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1.5
                    color: PhantomState.primary
                    opacity: 0.65
                }
            }
        }

        // komponen baris tombol toggle pengaturan
        component P5ConfigToggleRow: Item {
            id: toggleRow
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            property string label: ""
            property string desc: ""
            property string valueText: "ON"
            property bool active: true
            signal triggered()

            Canvas {
                anchors.fill: parent
                property bool isOn: toggleRow.active
                property bool isHov: rowMouse.containsMouse
                property color accent: PhantomState.primary
                onIsOnChanged: requestPaint()
                onIsHovChanged: requestPaint()
                onAccentChanged: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height
                    var rightX = w - 210

                    // bilah miring kiri saat opsi aktif atau di-hover
                    ctx.fillStyle = (isOn || isHov) ? accent : "#16161F"
                    ctx.beginPath()
                    ctx.moveTo(12, 4)
                    ctx.lineTo(rightX + 20, 2)
                    ctx.lineTo(rightX + 8, h - 4)
                    ctx.lineTo(0, h - 6)
                    ctx.closePath()
                    ctx.fill()

                    if (isOn || isHov) {
                        // aksen garis putih di sisi kiri bilah
                        ctx.fillStyle = "#FFFFFF"
                        ctx.beginPath()
                        ctx.moveTo(0, h - 6)
                        ctx.lineTo(14, 4)
                        ctx.lineTo(22, 4)
                        ctx.lineTo(8, h - 6)
                        ctx.closePath()
                        ctx.fill()
                    }

                    // bingkai nilai di sisi kanan dengan lekukan panah
                    ctx.fillStyle = "#FFFFFF"
                    ctx.beginPath()
                    ctx.moveTo(rightX, 2)
                    ctx.lineTo(w - 10, 0)
                    ctx.lineTo(w - 22, h - 2)
                    ctx.lineTo(rightX - 10, h - 2)
                    ctx.lineTo(rightX - 5, h * 0.65)
                    ctx.lineTo(rightX - 20, h * 0.50)
                    ctx.lineTo(rightX - 4, h * 0.35)
                    ctx.closePath()
                    ctx.fill()

                    ctx.fillStyle = "#08080A"
                    ctx.beginPath()
                    ctx.moveTo(rightX + 7, 6)
                    ctx.lineTo(w - 17, 4)
                    ctx.lineTo(w - 28, h - 6)
                    ctx.lineTo(rightX - 3, h - 6)
                    ctx.closePath()
                    ctx.fill()
                }
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 28
                anchors.right: parent.right
                anchors.rightMargin: 225
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: toggleRow.label
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 15
                    font.weight: Font.Black
                    font.italic: true
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: toggleRow.desc
                    color: (toggleRow.active || rowMouse.containsMouse) ? "#08080A" : "#9E9EAE"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                anchors.right: parent.right
                anchors.rightMargin: 32
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                P5Icon {
                    name: toggleRow.active ? "star" : "close"
                    color: toggleRow.active ? PhantomState.secondary : "#777777"
                    size: 13
                }
                Text {
                    text: toggleRow.valueText
                    color: toggleRow.active ? PhantomState.secondary : "#999999"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 14
                    font.weight: Font.Black
                    font.italic: true
                }
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: toggleRow.triggered()
            }
        }

        // komponen baris pemilih multi-opsi pengaturan
        component P5ConfigChoiceRow: Item {
            id: choiceRow
            Layout.fillWidth: true
            Layout.preferredHeight: 54

            property string label: ""
            property string desc: ""
            property string currentValue: ""
            property var options: []
            signal selected(string val)

            Canvas {
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height
                    ctx.fillStyle = "#161620"
                    ctx.beginPath()
                    ctx.moveTo(12, 4)
                    ctx.lineTo(w - 10, 2)
                    ctx.lineTo(w - 22, h - 4)
                    ctx.lineTo(0, h - 6)
                    ctx.closePath()
                    ctx.fill()
                }
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: choicesLayout.left
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: choiceRow.label
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 15
                    font.weight: Font.Black
                    font.italic: true
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: choiceRow.desc
                    color: "#9E9EAE"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                id: choicesLayout
                anchors.right: parent.right
                anchors.rightMargin: 26
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Repeater {
                    model: choiceRow.options
                    delegate: Item {
                        required property var modelData
                        readonly property bool isSel: choiceRow.currentValue === modelData.id
                        Layout.preferredWidth: Math.max(74, optText.implicitWidth + 24)
                        Layout.preferredHeight: 34

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: parent.isSel ? PhantomState.primary : "#0B0B10"
                            borderColor: parent.isSel ? "#FFFFFF" : "#444456"
                            shadowColor: parent.isSel ? PhantomState.secondary : "#000000"
                            borderWidth: parent.isSel ? 2 : 1
                            skewPx: 6
                            shadowOffsetX: 2
                            shadowOffsetY: 2
                        }

                        Text {
                            id: optText
                            anchors.centerIn: parent
                            text: modelData.label
                            color: parent.isSel ? "#FFFFFF" : "#BBBBCC"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 11
                            font.weight: Font.Black
                            font.italic: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: choiceRow.selected(modelData.id)
                        }
                    }
                }
            }
        }

        // komponen baris slider nilai numerik pengaturan
        component P5ConfigSliderRow: Item {
            id: sliderRow
            Layout.fillWidth: true
            Layout.preferredHeight: 52

            property string label: ""
            property string desc: ""
            property real minVal: 0
            property real maxVal: 100
            property real currentVal: 50
            property string unit: ""
            signal valueModified(real newValue)

            Canvas {
                anchors.fill: parent
                property color accent: PhantomState.primary
                onAccentChanged: requestPaint()
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height
                    var rightX = w - 290

                    ctx.fillStyle = "#181822"
                    ctx.beginPath()
                    ctx.moveTo(12, 4)
                    ctx.lineTo(rightX + 20, 2)
                    ctx.lineTo(rightX + 8, h - 4)
                    ctx.lineTo(0, h - 6)
                    ctx.closePath()
                    ctx.fill()

                    // bingkai kontrol slider di sisi kanan
                    ctx.fillStyle = "#FFFFFF"
                    ctx.beginPath()
                    ctx.moveTo(rightX, 2)
                    ctx.lineTo(w - 10, 0)
                    ctx.lineTo(w - 22, h - 2)
                    ctx.lineTo(rightX - 10, h - 2)
                    ctx.lineTo(rightX - 5, h * 0.65)
                    ctx.lineTo(rightX - 20, h * 0.50)
                    ctx.lineTo(rightX - 4, h * 0.35)
                    ctx.closePath()
                    ctx.fill()

                    ctx.fillStyle = "#08080A"
                    ctx.beginPath()
                    ctx.moveTo(rightX + 7, 6)
                    ctx.lineTo(w - 17, 4)
                    ctx.lineTo(w - 28, h - 6)
                    ctx.lineTo(rightX - 3, h - 6)
                    ctx.closePath()
                    ctx.fill()
                }
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.leftMargin: 26
                anchors.right: parent.right
                anchors.rightMargin: 305
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: sliderRow.label
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 15
                    font.weight: Font.Black
                    font.italic: true
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: sliderRow.desc
                    color: "#9E9EAE"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                anchors.right: parent.right
                anchors.rightMargin: 28
                anchors.verticalCenter: parent.verticalCenter
                width: 256
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    color: "#1F1F28"
                    border.color: "#FFFFFF"
                    border.width: 1
                    P5Icon { anchors.centerIn: parent; name: "minus"; size: 9; color: "#FFFFFF" }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var step = (sliderRow.maxVal - sliderRow.minVal) >= 20 ? 2 : 1
                            sliderRow.valueModified(Math.max(sliderRow.minVal, sliderRow.currentVal - step))
                        }
                    }
                }

                Item {
                    id: trackArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: 26
                    readonly property real ratio: Math.min(1.0, Math.max(0.0, (sliderRow.currentVal - sliderRow.minVal) / Math.max(1, sliderRow.maxVal - sliderRow.minVal)))

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 6
                        color: "#262632"
                        border.color: "#FFFFFF"
                        border.width: 1

                        Rectangle {
                            width: parent.width * trackArea.ratio
                            height: parent.height
                            color: PhantomState.primary
                        }
                    }

                    P5Star {
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        x: (trackArea.width - 20) * trackArea.ratio
                        starColor: PhantomState.secondary
                        innerColor: "#08080A"
                        coreColor: PhantomState.primary
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        function updateFromMouse(mx) {
                            var r = Math.min(1.0, Math.max(0.0, mx / Math.max(1, trackArea.width)))
                            sliderRow.valueModified(Math.round(sliderRow.minVal + r * (sliderRow.maxVal - sliderRow.minVal)))
                        }
                        onPressed: mouse => updateFromMouse(mouse.x)
                        onPositionChanged: mouse => { if (pressed) updateFromMouse(mouse.x) }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    color: "#1F1F28"
                    border.color: "#FFFFFF"
                    border.width: 1
                    P5Icon { anchors.centerIn: parent; name: "plus"; size: 9; color: "#FFFFFF" }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var step = (sliderRow.maxVal - sliderRow.minVal) >= 20 ? 2 : 1
                            sliderRow.valueModified(Math.min(sliderRow.maxVal, sliderRow.currentVal + step))
                        }
                    }
                }

                Text {
                    Layout.preferredWidth: 46
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(sliderRow.currentVal) + sliderRow.unit
                    color: PhantomState.secondary
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 13
                    font.weight: Font.Black
                }
            }
        }

        // kontainer utama jendela pengaturan
        Rectangle {
            id: fadeBg
            anchors.fill: parent
            color: "#CC07070A"
            opacity: PhantomState.settingsOpen ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.settingsOpen = false
            }

            Item {
                width: Math.min(parent.width - 60, 980)
                height: Math.min(parent.height - 60, 700)
                anchors.centerIn: parent

                MouseArea { anchors.fill: parent }

                // latar kartu miring utama jendela pengaturan
                Canvas {
                    anchors.fill: parent
                    property color accent: PhantomState.primary
                    onAccentChanged: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var h = height

                        ctx.fillStyle = Qt.rgba(accent.r, accent.g, accent.b, 0.28)
                        ctx.beginPath()
                        ctx.moveTo(26, 16)
                        ctx.lineTo(w, 6)
                        ctx.lineTo(w - 18, h - 46)
                        ctx.lineTo(8, h - 38)
                        ctx.closePath()
                        ctx.fill()

                        ctx.fillStyle = "#EE0B0B0F"
                        ctx.strokeStyle = "#FFFFFF"
                        ctx.lineWidth = 2.5
                        ctx.beginPath()
                        ctx.moveTo(18, 8)
                        ctx.lineTo(w - 10, 0)
                        ctx.lineTo(w - 26, h - 54)
                        ctx.lineTo(0, h - 46)
                        ctx.closePath()
                        ctx.fill()
                        ctx.stroke()
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 22
                    anchors.bottomMargin: 78
                    anchors.leftMargin: 36
                    anchors.rightMargin: 42
                    spacing: 12

                    // baris judul atas dan deretan tab kategori pengaturan
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // lencana judul pengaturan di kiri atas
                        Item {
                            Layout.preferredWidth: 235
                            Layout.preferredHeight: 54
                            rotation: -2

                            Canvas {
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.reset()
                                    ctx.fillStyle = "#FFFFFF"
                                    ctx.beginPath()
                                    ctx.moveTo(10, 0)
                                    ctx.lineTo(width, 4)
                                    ctx.lineTo(width - 12, height)
                                    ctx.lineTo(0, height - 4)
                                    ctx.closePath()
                                    ctx.fill()

                                    ctx.fillStyle = "#08080A"
                                    ctx.beginPath()
                                    ctx.moveTo(15, 5)
                                    ctx.lineTo(width - 6, 8)
                                    ctx.lineTo(width - 16, height - 5)
                                    ctx.lineTo(5, height - 8)
                                    ctx.closePath()
                                    ctx.fill()
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 8

                                Image {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    source: PhantomState.logoPath
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    mipmap: true
                                }

                                ColumnLayout {
                                    spacing: 0
                                    Text {
                                        text: "SYSTEM CONFIG"
                                        color: "#FFFFFF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 17
                                        font.weight: Font.Black
                                        font.italic: true
                                    }
                                    Text {
                                        text: "VELVET ROOM // FULL SUITE"
                                        color: PhantomState.secondary
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 8
                                        font.weight: Font.Black
                                    }
                                }
                            }
                        }

                        // deretan tombol tab kategori
                        Repeater {
                            model: [
                                { idx: 0, icon: "palette",  label: "1. THEME" },
                                { idx: 1, icon: "bars",     label: "2. BAR" },
                                { idx: 2, icon: "sparkles", label: "3. DESKTOP" },
                                { idx: 3, icon: "frame",    label: "4. UI & IM" },
                                { idx: 4, icon: "polygon",  label: "5. HYPR" },
                                { idx: 5, icon: "star",     label: "6. ABOUT" }
                            ]

                            delegate: Item {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                readonly property bool isCurr: settingsWin.activeTab === modelData.idx

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: parent.isCurr ? PhantomState.primary : "#15151E"
                                    borderColor: "#FFFFFF"
                                    shadowColor: parent.isCurr ? PhantomState.secondary : "#08080A"
                                    borderWidth: 2
                                    skewPx: 7
                                }

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    P5Icon {
                                        name: modelData.icon
                                        size: 12
                                        color: parent.parent.isCurr ? "#FFFFFF" : PhantomState.secondary
                                    }
                                    Text {
                                        text: modelData.label
                                        color: "#FFFFFF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.weight: Font.Black
                                        font.italic: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: settingsWin.activeTab = modelData.idx
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 2
                        color: PhantomState.primary
                    }

                    // area konten tab yang dapat digulir
                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: activeTabCol.implicitHeight + 20
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: activeTabCol
                            width: parent.width
                            spacing: 10

                            // halaman tab pengaturan tema, wallpaper, dan sudut kemiringan poligon
                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: settingsWin.activeTab === 0
                                spacing: 10

                                P5SectionHeader { text: "WALLPAPER ENGINE & PARALLAX" }

                                // kartu pratinjau dan kontrol pergantian wallpaper
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 115
                                    spacing: 12

                                    P5SkewedCard {
                                        Layout.preferredWidth: 240
                                        Layout.fillHeight: true
                                        fillColor: "#08080C"
                                        borderColor: "#FFFFFF"
                                        shadowColor: PhantomState.primary
                                        skewPx: 10

                                        Image {
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            source: "file://" + PhantomState.wallpaperPath
                                            fillMode: Image.PreserveAspectCrop
                                            smooth: true
                                        }

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.margins: 8
                                            width: wpLbl.implicitWidth + 12
                                            height: 20
                                            color: "#CC08080C"
                                            border.color: PhantomState.primary
                                            border.width: 1
                                            Text {
                                                id: wpLbl
                                                anchors.centerIn: parent
                                                text: PhantomState.wallpaperPath.split("/").pop()
                                                color: "#FFFFFF"
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                font.weight: Font.Black
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        P5ConfigToggleRow {
                                            label: "Cycle Desktop Wallpaper"
                                            desc: "Switch between wallpapers in ~/Pictures/Wallpapers"
                                            valueText: "NEXT WP"
                                            active: true
                                            onTriggered: PhantomState.cycleWallpaper()
                                        }

                                        P5ConfigToggleRow {
                                            label: "Workspace Parallax Shift"
                                            desc: "Smoothly pan desktop wallpaper when switching workspaces (1..6)"
                                            valueText: PhantomState.wallpaperParallax ? "ON" : "OFF"
                                            active: PhantomState.wallpaperParallax
                                            onTriggered: {
                                                PhantomState.wallpaperParallax = !PhantomState.wallpaperParallax
                                                PhantomState.saveState()
                                            }
                                        }
                                    }
                                }

                                P5SectionHeader { text: "SELECT METAVERSE PALETTE (9 SCHEMES)" }

                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 3
                                    rowSpacing: 8
                                    columnSpacing: 10

                                    Repeater {
                                        model: [
                                            { id: "p5-crimson",    title: "P5 CRIMSON",  sub: "Joker Phantom Red",   col: "#E60012" },
                                            { id: "p3-reload",     title: "P3 RELOAD",   sub: "S.E.E.S. Makoto Blue",col: "#00B4D8" },
                                            { id: "p4-golden",     title: "P4 GOLDEN",   sub: "Midnight Channel",    col: "#FFB703" },
                                            { id: "kasumi-violet", title: "VIOLET",      sub: "Kasumi Yoshizawa",    col: "#B829FF" },
                                            { id: "akechi-crow",   title: "CROW GOLD",   sub: "Goro Akechi Royal",   col: "#D4AF37" },
                                            { id: "futaba-matrix", title: "ORACLE",      sub: "Futaba Hacker Green", col: "#39FF14" },
                                            { id: "monochrome",    title: "MONOCHROME",  sub: "Noir Manga Contrast", col: "#E2E2EC" },
                                            { id: "expressive",    title: "EXPRESSIVE",  sub: "Velvet Cyber Neon",   col: "#7B61FF" },
                                            { id: "tonal-spot",    title: "GORE MAGALA", sub: "Iceshard Frost Blue", col: "#8AB4F8" }
                                        ]

                                        delegate: P5SkewedCard {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 54
                                            fillColor: PhantomState.themeId === modelData.id ? modelData.col : "#0E0E14"
                                            borderColor: "#FFFFFF"
                                            shadowColor: modelData.col
                                            skewPx: 10

                                            ColumnLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 16
                                                anchors.rightMargin: 16
                                                anchors.topMargin: 6
                                                anchors.bottomMargin: 6
                                                spacing: 1

                                                RowLayout {
                                                    Layout.fillWidth: true
                                                    P5Icon {
                                                        name: PhantomState.themeId === modelData.id ? "star" : "rounded"
                                                        color: PhantomState.themeId === modelData.id ? "#08080A" : modelData.col
                                                        size: 12
                                                    }
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: modelData.title
                                                        color: PhantomState.themeId === modelData.id ? "#08080A" : "#FFFFFF"
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 13
                                                        font.weight: Font.Black
                                                        font.italic: true
                                                        elide: Text.ElideRight
                                                    }
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: modelData.sub
                                                    color: PhantomState.themeId === modelData.id ? "#08080A" : "#AAAAAA"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Bold
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: PhantomState.applyPreset(modelData.id)
                                            }
                                        }
                                    }
                                }

                                P5SectionHeader { text: "GEOMETRY & SURFACE MODE" }

                                P5ConfigChoiceRow {
                                    label: "Surface Polarity Mode"
                                    desc: "Switch between Dark Metaverse Onyx and Light High-Contrast"
                                    currentValue: PhantomState.darkMode ? "dark" : "light"
                                    options: [
                                        { id: "dark",  label: "★ DARK" },
                                        { id: "light", label: "☀ LIGHT" }
                                    ]
                                    onSelected: val => PhantomState.setDarkMode(val === "dark")
                                }

                                P5ConfigToggleRow {
                                    label: "Polygon Skew Mode"
                                    desc: "Toggle sharp Persona 5 slanted polygons vs standard cards"
                                    valueText: PhantomState.polygonMode ? "P5 SKEW" : "ROUNDED"
                                    active: PhantomState.polygonMode
                                    onTriggered: {
                                        PhantomState.polygonMode = !PhantomState.polygonMode
                                        PhantomState.saveState()
                                    }
                                }

                                P5ConfigSliderRow {
                                    label: "Polygon Skew Angle"
                                    desc: "Diagonal slant angle for Persona 5 UI cards"
                                    minVal: 0; maxVal: 18
                                    currentVal: Math.abs(PhantomState.skewAngle)
                                    unit: "°"
                                    onValueModified: newValue => {
                                        PhantomState.skewAngle = -newValue
                                        PhantomState.saveState()
                                    }
                                }
                            }

                            // halaman tab pengaturan posisi bar, gaya bar, dan format nomor workspace
                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: settingsWin.activeTab === 1
                                spacing: 10

                                P5SectionHeader { text: "BAR POSITIONING & STYLE" }

                                P5ConfigChoiceRow {
                                    label: "Bar Edge Position"
                                    desc: "Anchor Phantom Bar at the top or bottom of your monitor"
                                    currentValue: PhantomState.barPosition
                                    options: [
                                        { id: "top",    label: "↑ TOP" },
                                        { id: "bottom", label: "↓ BOTTOM" }
                                    ]
                                    onSelected: val => { PhantomState.barPosition = val; PhantomState.saveState() }
                                }

                                P5ConfigChoiceRow {
                                    label: "Bar Visual Style"
                                    desc: "Select how bar modules and backing are framed"
                                    currentValue: PhantomState.barStyle
                                    options: [
                                        { id: "p5-skew", label: "★ P5 SKEW" },
                                        { id: "float",   label: "FLOAT" },
                                        { id: "hug",     label: "HUG BAR" },
                                        { id: "islands", label: "ISLANDS" }
                                    ]
                                    onSelected: val => {
                                        PhantomState.barStyle = val
                                        PhantomState.polygonMode = (val === "p5-skew")
                                        PhantomState.barShowBackground = (val === "hug")
                                        PhantomState.saveState()
                                    }
                                }

                                P5ConfigToggleRow {
                                    label: "Solid Bar Backing Strip"
                                    desc: "Draw dark full-width backing strip with crimson edge under bar pills"
                                    valueText: PhantomState.barShowBackground ? "ON" : "FLOAT"
                                    active: PhantomState.barShowBackground
                                    onTriggered: {
                                        PhantomState.barShowBackground = !PhantomState.barShowBackground
                                        PhantomState.saveState()
                                    }
                                }

                                P5SectionHeader { text: "WORKSPACES & NUMERAL FORMAT" }

                                P5ConfigSliderRow {
                                    label: "Workspaces Shown on Bar"
                                    desc: "Number of workspace pills displayed in the bar"
                                    minVal: 4; maxVal: 12
                                    currentVal: PhantomState.workspaceCount
                                    unit: ""
                                    onValueModified: newValue => {
                                        PhantomState.workspaceCount = newValue
                                        PhantomState.saveState()
                                    }
                                }

                                P5ConfigChoiceRow {
                                    label: "Workspace Number Style"
                                    desc: "Format workspace numbers as Arabic, Roman numerals, or Japanese Kanji"
                                    currentValue: PhantomState.workspaceNumStyle
                                    options: [
                                        { id: "arabic", label: "1, 2, 3" },
                                        { id: "roman",  label: "I, II, III" },
                                        { id: "kanji",  label: "一, 二, 三" }
                                    ]
                                    onSelected: val => {
                                        PhantomState.workspaceNumStyle = val
                                        PhantomState.saveState()
                                    }
                                }

                                P5SectionHeader { text: "BAR SECTIONS & QUICK UTILITY BUTTONS" }

                                P5ConfigToggleRow {
                                    label: "Left: Date & Weather HUD Pill"
                                    desc: "Show Persona 5 date, day of week, and time period badge"
                                    valueText: PhantomState.showWeatherHud ? "VISIBLE" : "HIDDEN"
                                    active: PhantomState.showWeatherHud
                                    onTriggered: { PhantomState.showWeatherHud = !PhantomState.showWeatherHud; PhantomState.saveState() }
                                }

                                P5ConfigToggleRow {
                                    label: "Center: Dynamic Island"
                                    desc: "Show active window title and quick SUPER launcher trigger"
                                    valueText: PhantomState.showDynamicIsland ? "VISIBLE" : "HIDDEN"
                                    active: PhantomState.showDynamicIsland
                                    onTriggered: { PhantomState.showDynamicIsland = !PhantomState.showDynamicIsland; PhantomState.saveState() }
                                }

                                P5ConfigToggleRow {
                                    label: "Utility: Screen Snip + Color Picker Strip"
                                    desc: "Show quick screenshot snip and hyprpicker color buttons on bar"
                                    valueText: PhantomState.showUtilButtons ? "ENABLED" : "OFF"
                                    active: PhantomState.showUtilButtons
                                    onTriggered: { PhantomState.showUtilButtons = !PhantomState.showUtilButtons; PhantomState.saveState() }
                                }

                                P5ConfigToggleRow {
                                    label: "Utility: Microphone & Polarity Toggles"
                                    desc: "Include mic mute and dark/light buttons inside the utility strip"
                                    valueText: PhantomState.showUtilMic ? "SHOWN" : "HIDDEN"
                                    active: PhantomState.showUtilMic
                                    onTriggered: {
                                        PhantomState.showUtilMic = !PhantomState.showUtilMic
                                        PhantomState.showUtilDark = PhantomState.showUtilMic
                                        PhantomState.saveState()
                                    }
                                }
                            }

                            // halaman tab pengaturan widget jam desktop, cava visualizer, dan lirik lagu
                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: settingsWin.activeTab === 2
                                spacing: 10

                                P5SectionHeader { text: "DESKTOP CLOCK & MOTTO WIDGET" }

                                P5ConfigToggleRow {
                                    label: "Desktop Clock & Date Widget"
                                    desc: "Render Persona 5 clock widget directly on the desktop wallpaper"
                                    valueText: PhantomState.showDesktopClock ? "ENABLED" : "OFF"
                                    active: PhantomState.showDesktopClock
                                    onTriggered: { PhantomState.showDesktopClock = !PhantomState.showDesktopClock; PhantomState.saveState() }
                                }

                                P5ConfigChoiceRow {
                                    label: "Desktop Clock Visual Style"
                                    desc: "Choose between Slanted Persona 5 Editorial, Minimal Giant, or Cyber HUD"
                                    currentValue: PhantomState.desktopClockStyle
                                    options: [
                                        { id: "p5-editorial", label: "★ P5 SLANT" },
                                        { id: "minimal",      label: "MINIMAL" },
                                        { id: "cyber",        label: "CYBER HUD" }
                                    ]
                                    onSelected: val => { PhantomState.desktopClockStyle = val; PhantomState.saveState() }
                                }

                                P5ConfigChoiceRow {
                                    label: "Desktop Clock Placement"
                                    desc: "Select screen quadrant for the desktop clock widget"
                                    currentValue: PhantomState.desktopClockPosition
                                    options: [
                                        { id: "top-left",    label: "TOP-L" },
                                        { id: "center",      label: "CENTER" },
                                        { id: "top-right",   label: "TOP-R" },
                                        { id: "bottom-left", label: "BOT-L" }
                                    ]
                                    onSelected: val => { PhantomState.desktopClockPosition = val; PhantomState.saveState() }
                                }

                                P5ConfigSliderRow {
                                    label: "Desktop Clock Scale (%)"
                                    desc: "Resize the desktop clock widget from 70% to 150%"
                                    minVal: 70; maxVal: 150
                                    currentVal: PhantomState.desktopClockScale
                                    unit: "%"
                                    onValueModified: newValue => { PhantomState.desktopClockScale = newValue; PhantomState.saveState() }
                                }

                                P5ConfigToggleRow {
                                    label: "Show Phantom Thieves Motto Tag"
                                    desc: "Display 'TAKE YOUR TIME // STEAL BACK YOUR FUTURE' under clock"
                                    valueText: PhantomState.desktopClockShowQuote ? "SHOWN" : "HIDDEN"
                                    active: PhantomState.desktopClockShowQuote
                                    onTriggered: { PhantomState.desktopClockShowQuote = !PhantomState.desktopClockShowQuote; PhantomState.saveState() }
                                }

                                P5SectionHeader { text: "SPLIT LEFT/RIGHT CAVA & CENTER LIVE LYRICS" }

                                P5ConfigToggleRow {
                                    label: "Split Left/Right Cava Audio Visualizer"
                                    desc: "Run live 64-bar Cava spectrum split across bottom-left & bottom-right"
                                    valueText: PhantomState.showDesktopCava ? "ACTIVE" : "OFF"
                                    active: PhantomState.showDesktopCava
                                    onTriggered: { PhantomState.showDesktopCava = !PhantomState.showDesktopCava; PhantomState.saveState() }
                                }

                                P5ConfigSliderRow {
                                    label: "Cava Spectrum Max Height"
                                    desc: "Maximum vertical bar height for the bottom audio visualizer"
                                    minVal: 40; maxVal: 200
                                    currentVal: PhantomState.cavaMaxHeight
                                    unit: "px"
                                    onValueModified: newValue => { PhantomState.cavaMaxHeight = newValue; PhantomState.saveState() }
                                }

                                P5ConfigToggleRow {
                                    label: "Center Slot Live Synced Lyrics"
                                    desc: "Fetch real-time synced lyrics from Spotify, Apple Music, or Browser"
                                    valueText: PhantomState.showDesktopLyrics ? "ACTIVE" : "OFF"
                                    active: PhantomState.showDesktopLyrics
                                    onTriggered: { PhantomState.showDesktopLyrics = !PhantomState.showDesktopLyrics; PhantomState.saveState() }
                                }

                                P5ConfigToggleRow {
                                    label: "Lyrics Slot Skewed Backing Card"
                                    desc: "Show slanted dark Persona 5 card behind center lyrics for high contrast"
                                    valueText: PhantomState.lyricsShowCard ? "CARD ON" : "TEXT ONLY"
                                    active: PhantomState.lyricsShowCard
                                    onTriggered: { PhantomState.lyricsShowCard = !PhantomState.lyricsShowCard; PhantomState.saveState() }
                                }
                            }

                            // halaman tab pengaturan gaya grafik statistik sistem dan notifikasi pesan
                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: settingsWin.activeTab === 3
                                spacing: 10

                                P5SectionHeader { text: "SYSTEM STATS & SCREEN CORNERS" }

                                P5ConfigChoiceRow {
                                    label: "System Stats Radar Style"
                                    desc: "Choose 5-Point Persona Star Radar or Horizontal Progress Bars"
                                    currentValue: PhantomState.statsStyle
                                    options: [
                                        { id: "pentagon", label: "★ 5-PT STAR" },
                                        { id: "bars",     label: "☰ BARS" }
                                    ]
                                    onSelected: val => { PhantomState.statsStyle = val; PhantomState.saveState() }
                                }

                                P5ConfigToggleRow {
                                    label: "Workspace Perimeter Frame"
                                    desc: "Optional chamfered border around workspace area (Default OFF for clean apps)"
                                    valueText: PhantomState.screenFrame ? "ON" : "OFF"
                                    active: PhantomState.screenFrame
                                    onTriggered: { PhantomState.screenFrame = !PhantomState.screenFrame; PhantomState.saveState() }
                                }

                                P5SectionHeader { text: "PERSONA 5 IM CHAT NOTIFICATIONS" }

                                P5ConfigToggleRow {
                                    label: "Do Not Disturb (Mute Popups)"
                                    desc: "Silence incoming comic bubble popups on top-right"
                                    valueText: PhantomState.dndEnabled ? "DND ON" : "POPUPS ON"
                                    active: !PhantomState.dndEnabled
                                    onTriggered: PhantomState.dndEnabled = !PhantomState.dndEnabled
                                }

                                P5ConfigToggleRow {
                                    label: "Unread Notification Count Badge"
                                    desc: "Show unread message counter inside the IM pill on the bar"
                                    valueText: PhantomState.showUnreadCount ? "SHOWN" : "HIDDEN"
                                    active: PhantomState.showUnreadCount
                                    onTriggered: { PhantomState.showUnreadCount = !PhantomState.showUnreadCount; PhantomState.saveState() }
                                }

                                P5ConfigToggleRow {
                                    label: "Dispatch Calling Card Test"
                                    desc: "Send a test Persona 5 comic notification from Ren"
                                    valueText: "FIRE TEST"
                                    active: true
                                    onTriggered: PhantomState.sendTestNotification()
                                }
                            }

                            // halaman tab pengaturan layar monitor, mode proyektor, audio, dan hyprland
                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: settingsWin.activeTab === 4
                                spacing: 10

                                P5SectionHeader { text: "DISPLAYS & INFOCUS PROJECTOR MIRROR" }

                                // kartu pratinjau tata letak layar monitor
                                P5SkewedCard {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 168
                                    fillColor: "#0D0D14"
                                    borderColor: "#FFFFFF"
                                    shadowColor: PhantomState.primary
                                    skewPx: 8

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 8

                                        // deretan kotak pratinjau monitor
                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 16

                                                Repeater {
                                                    model: PhantomState.monitorList

                                                    delegate: Item {
                                                        required property var modelData
                                                        required property int index
                                                        width: 220
                                                        height: 106
                                                        readonly property bool isSel: PhantomState.selectedMonitorIdx === index

                                                        P5SkewedCard {
                                                            anchors.fill: parent
                                                            fillColor: parent.isSel ? "#242842" : "#161824"
                                                            borderColor: parent.isSel ? PhantomState.secondary : "#FFFFFF"
                                                            shadowColor: parent.isSel ? PhantomState.primary : "#06060A"
                                                            borderWidth: parent.isSel ? 2.5 : 1.5
                                                            skewPx: 6
                                                        }

                                                        Column {
                                                            anchors.centerIn: parent
                                                            spacing: 3

                                                            P5Icon {
                                                                anchors.horizontalCenter: parent.horizontalCenter
                                                                name: "frame"
                                                                size: 18
                                                                color: parent.parent.isSel ? PhantomState.secondary : "#FFFFFF"
                                                            }

                                                            Text {
                                                                anchors.horizontalCenter: parent.horizontalCenter
                                                                text: modelData.name || "eDP-1"
                                                                color: "#FFFFFF"
                                                                font.family: "JetBrainsMono NFM"
                                                                font.pixelSize: 14
                                                                font.weight: Font.Black
                                                            }

                                                            Text {
                                                                anchors.horizontalCenter: parent.horizontalCenter
                                                                text: (modelData.width || 1920) + "x" + (modelData.height || 1080) + " @ " + Math.round(modelData.refreshRate || 60) + "Hz"
                                                                color: PhantomState.muted
                                                                font.family: "JetBrainsMono NFM"
                                                                font.pixelSize: 10
                                                                font.weight: Font.Bold
                                                            }

                                                            Text {
                                                                visible: (modelData.mirrorOf && modelData.mirrorOf !== "none") || PhantomState.presentationMode !== "extend"
                                                                anchors.horizontalCenter: parent.horizontalCenter
                                                                text: "★ MIRROR ACTIVE"
                                                                color: PhantomState.secondary
                                                                font.family: "JetBrainsMono NFM"
                                                                font.pixelSize: 9
                                                                font.weight: Font.Black
                                                            }
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: PhantomState.loadMonitorIntoState(index)
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        // deskripsi perangkat keras monitor dan tombol pindai ulang
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 10

                                            Text {
                                                Layout.fillWidth: true
                                                text: PhantomState.displayName + " • " + PhantomState.displayDesc
                                                color: PhantomState.muted
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 11
                                                font.weight: Font.Bold
                                                elide: Text.ElideRight
                                            }

                                            Rectangle {
                                                width: 96
                                                height: 22
                                                color: PhantomState.primary
                                                border.color: "#FFFFFF"
                                                border.width: 1.5

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "↻ RESCAN"
                                                    color: "#FFFFFF"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 10
                                                    font.weight: Font.Black
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: PhantomState.refreshMonitors()
                                                }
                                            }
                                        }
                                    }
                                }

                                // pemilih mode proyektor atau perpanjangan layar
                                P5ConfigChoiceRow {
                                    label: "InFocus / Presentation Mirror"
                                    desc: "Mirror screen to projector/InFocus or extend workspace"
                                    currentValue: PhantomState.presentationMode
                                    options: [
                                        { id: "extend",       label: "EXTEND" },
                                        { id: "mirror-auto",  label: "MIRROR AUTO" },
                                        { id: "mirror-1080p", label: "INFOCUS 1080" },
                                        { id: "mirror-720p",  label: "INFOCUS 720" }
                                    ]
                                    onSelected: val => PhantomState.setPresentationMode(val)
                                }

                                // sakelar aktif atau nonaktif untuk monitor terpilih
                                P5ConfigToggleRow {
                                    label: "Enabled (" + PhantomState.displayName + ")"
                                    desc: "Enable or disable the selected monitor output"
                                    valueText: PhantomState.displayEnabled ? "ON" : "OFF"
                                    active: PhantomState.displayEnabled
                                    onTriggered: {
                                        if (PhantomState.monitorList.length > 1 || !PhantomState.displayEnabled) {
                                            PhantomState.displayEnabled = !PhantomState.displayEnabled
                                            PhantomState.applyDisplayConfig()
                                        }
                                    }
                                }

                                // tombol pembuka daftar resolusi dan refresh rate
                                P5ConfigToggleRow {
                                    label: "Resolution & Refresh Rate"
                                    desc: "Click to open framerate & resolution options (" + PhantomState.displayAvailableModes.length + " modes available)"
                                    valueText: PhantomState.displayMode + (settingsWin.showDisplayModeDropdown ? " ▲" : " ▼")
                                    active: true
                                    onTriggered: settingsWin.showDisplayModeDropdown = !settingsWin.showDisplayModeDropdown
                                }

                                // daftar pilihan resolusi dan refresh rate monitor
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 18
                                    Layout.rightMargin: 6
                                    visible: settingsWin.showDisplayModeDropdown
                                    spacing: 6

                                    Repeater {
                                        model: PhantomState.displayAvailableModes

                                        delegate: Item {
                                            required property string modelData
                                            required property int index
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 38
                                            readonly property bool isSelected: PhantomState.displayMode === modelData

                                            P5SkewedCard {
                                                anchors.fill: parent
                                                fillColor: parent.isSelected ? PhantomState.primary : "#171722"
                                                borderColor: parent.isSelected ? "#FFFFFF" : "#353548"
                                                shadowColor: parent.isSelected ? PhantomState.secondary : "#08080C"
                                                borderWidth: parent.isSelected ? 2 : 1
                                                skewPx: 8
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 18
                                                anchors.rightMargin: 18
                                                spacing: 10

                                                P5Icon {
                                                    name: parent.parent.isSelected ? "check" : "sparkles"
                                                    size: 13
                                                    color: parent.parent.isSelected ? "#FFFFFF" : PhantomState.secondary
                                                }

                                                Text {
                                                    text: modelData
                                                    color: "#FFFFFF"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 13
                                                    font.weight: Font.Black
                                                    font.italic: parent.parent.isSelected
                                                }

                                                Rectangle {
                                                    visible: index === 0
                                                    width: 104
                                                    height: 20
                                                    color: PhantomState.secondary
                                                    border.color: "#09090D"
                                                    border.width: 1.5

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "★ BEST (MAX HZ)"
                                                        color: "#09090D"
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 9
                                                        font.weight: Font.Black
                                                    }
                                                }

                                                Item { Layout.fillWidth: true }

                                                Text {
                                                    text: parent.parent.isSelected ? "ACTIVE" : "SELECT"
                                                    color: parent.parent.isSelected ? "#FFFFFF" : PhantomState.muted
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 10
                                                    font.weight: Font.Black
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    PhantomState.setDisplayMode(modelData)
                                                    settingsWin.showDisplayModeDropdown = false
                                                }
                                            }
                                        }
                                    }
                                }

                                // pemilih orientasi putaran layar
                                P5ConfigChoiceRow {
                                    label: "Orientation"
                                    desc: "Rotate display output (Normal, 90°, 180°, 270°)"
                                    currentValue: String(PhantomState.displayTransform)
                                    options: [
                                        { id: "0", label: "NORMAL" },
                                        { id: "1", label: "90°" },
                                        { id: "2", label: "180°" },
                                        { id: "3", label: "270°" }
                                    ]
                                    onSelected: val => PhantomState.setDisplayTransform(Number(val))
                                }

                                // pengatur skala tampilan monitor
                                P5ConfigSliderRow {
                                    label: "Scale"
                                    desc: "Display fractional/integer UI scaling percentage"
                                    minVal: 75; maxVal: 200
                                    currentVal: PhantomState.displayScalePct
                                    unit: "%"
                                    onValueModified: newValue => {
                                        PhantomState.displayScalePct = Math.round(newValue)
                                        PhantomState.applyDisplayConfig()
                                    }
                                }

                                // pengatur koordinat posisi horizontal monitor
                                P5ConfigSliderRow {
                                    label: "Position X"
                                    desc: "Horizontal monitor layout coordinate in pixels"
                                    minVal: -1920; maxVal: 3840
                                    currentVal: PhantomState.displayPosX
                                    unit: "px"
                                    onValueModified: newValue => {
                                        PhantomState.displayPosX = Math.round(newValue)
                                        PhantomState.applyDisplayConfig()
                                    }
                                }

                                // pengatur koordinat posisi vertikal monitor
                                P5ConfigSliderRow {
                                    label: "Position Y"
                                    desc: "Vertical monitor layout coordinate in pixels"
                                    minVal: -1080; maxVal: 2160
                                    currentVal: PhantomState.displayPosY
                                    unit: "px"
                                    onValueModified: newValue => {
                                        PhantomState.displayPosY = Math.round(newValue)
                                        PhantomState.applyDisplayConfig()
                                    }
                                }

                                P5SectionHeader { text: "AUDIO & BACKLIGHT SERVICES" }

                                P5ConfigSliderRow {
                                    label: "Master Audio Volume (PipeWire)"
                                    desc: "Live system audio output volume via wpctl"
                                    minVal: 0; maxVal: 100
                                    currentVal: PhantomState.volumePct
                                    unit: "%"
                                    onValueModified: newValue => {
                                        PhantomState.volumePct = newValue
                                        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (newValue / 100.0).toFixed(2)])
                                        PhantomState.triggerOsd("VOLUME", newValue)
                                    }
                                }

                                P5ConfigSliderRow {
                                    label: "Display Backlight Brightness"
                                    desc: "Live monitor brightness via brightnessctl"
                                    minVal: 5; maxVal: 100
                                    currentVal: settingsWin.brightnessPct
                                    unit: "%"
                                    onValueModified: newValue => {
                                        settingsWin.brightnessPct = newValue
                                        Quickshell.execDetached(["brightnessctl", "set", newValue + "%"])
                                        PhantomState.triggerOsd("BRIGHTNESS", newValue)
                                    }
                                }

                                P5ConfigToggleRow {
                                    label: "UI Sound Effects (SFX)"
                                    desc: "Play audio cues when notifications and presets trigger"
                                    valueText: PhantomState.sfxEnabled ? "ENABLED" : "MUTED"
                                    active: PhantomState.sfxEnabled
                                    onTriggered: { PhantomState.sfxEnabled = !PhantomState.sfxEnabled; PhantomState.saveState() }
                                }

                                P5SectionHeader { text: "HYPRLAND LIVE IPC TUNING" }

                                P5ConfigSliderRow {
                                    label: "Hyprland Inner Gaps (gaps_in)"
                                    desc: "Live spacing between tiled windows"
                                    minVal: 0; maxVal: 24
                                    currentVal: PhantomState.hyprGapsIn
                                    unit: "px"
                                    onValueModified: newValue => { PhantomState.hyprGapsIn = newValue; PhantomState.syncHyprland() }
                                }

                                P5ConfigSliderRow {
                                    label: "Hyprland Outer Gaps (gaps_out)"
                                    desc: "Live spacing between windows and monitor edges"
                                    minVal: 0; maxVal: 40
                                    currentVal: PhantomState.hyprGapsOut
                                    unit: "px"
                                    onValueModified: newValue => { PhantomState.hyprGapsOut = newValue; PhantomState.syncHyprland() }
                                }

                                P5ConfigSliderRow {
                                    label: "Window Border Thickness"
                                    desc: "Active/inactive window border width in pixels"
                                    minVal: 0; maxVal: 6
                                    currentVal: PhantomState.hyprBorderSize
                                    unit: "px"
                                    onValueModified: newValue => { PhantomState.hyprBorderSize = newValue; PhantomState.syncHyprland() }
                                }

                                P5ConfigSliderRow {
                                    label: "Window Corner Rounding"
                                    desc: "Hyprland decoration:rounding radius in pixels"
                                    minVal: 0; maxVal: 24
                                    currentVal: PhantomState.hyprRounding
                                    unit: "px"
                                    onValueModified: newValue => { PhantomState.hyprRounding = newValue; PhantomState.syncHyprland() }
                                }

                                P5ConfigToggleRow {
                                    label: "Hyprland Frosted Glass Blur"
                                    desc: "Toggle decoration:blur:enabled in real time"
                                    valueText: PhantomState.hyprBlurEnabled ? "ON" : "OFF"
                                    active: PhantomState.hyprBlurEnabled
                                    onTriggered: { PhantomState.hyprBlurEnabled = !PhantomState.hyprBlurEnabled; PhantomState.syncHyprland() }
                                }

                                P5ConfigToggleRow {
                                    label: "Edit hyprland.lua Config File"
                                    desc: "Open /mnt/data/Projects/rice/phantomshell/dots/hypr/hyprland.lua in Neovim"
                                    valueText: "OPEN FILE"
                                    active: true
                                    onTriggered: {
                                        Quickshell.execDetached(["sh", "-c", "ghostty -e nvim /mnt/data/Projects/rice/phantomshell/dots/hypr/hyprland.lua || kitty -e nvim /mnt/data/Projects/rice/phantomshell/dots/hypr/hyprland.lua || xdg-open /mnt/data/Projects/rice/phantomshell/dots/hypr/hyprland.lua"])
                                    }
                                }
                            }

                            // halaman tab informasi proyek phantomshell, pembuat, dan spesifikasi perangkat keras
                            ColumnLayout {
                                Layout.fillWidth: true
                                visible: settingsWin.activeTab === 5
                                spacing: 12

                                P5SectionHeader { text: "ABOUT PHANTOMSHELL // CREATOR & PROJECT DOSSIER" }

                                // kartu identitas utama proyek phantomshell
                                P5SkewedCard {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 154
                                    fillColor: "#12121A"
                                    borderColor: "#FFFFFF"
                                    shadowColor: PhantomState.primary
                                    skewPx: 10

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 18
                                        spacing: 18

                                        Image {
                                            Layout.preferredWidth: 92
                                            Layout.preferredHeight: 92
                                            source: PhantomState.logoPath
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                            mipmap: true
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4
                                            RowLayout {
                                                spacing: 10
                                                Text {
                                                    text: "PHANTOMSHELL v1.0.0 // \"TAKE YOUR HEART\""
                                                    color: "#FFFFFF"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 18
                                                    font.weight: Font.Black
                                                    font.italic: true
                                                }
                                                Rectangle {
                                                    width: 118
                                                    height: 20
                                                    color: PhantomState.secondary
                                                    border.color: "#09090D"
                                                    border.width: 2
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "★ BY SHO (JOKER)"
                                                        color: "#09090D"
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 9
                                                        font.weight: Font.Black
                                                    }
                                                }
                                            }
                                            Text {
                                                text: "Created & Engineered by sho • Custom Persona 5 Royal Wayland Desktop Shell"
                                                color: PhantomState.secondary
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 11
                                                font.weight: Font.Black
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                wrapMode: Text.WordWrap
                                                text: "Phantomshell adalah desktop environment custom bergaya Persona 5 Royal yang dibangun khusus di atas Quickshell (Qt6) & Hyprland (Lua Engine) untuk NixOS. Menggabungkan comic-cutout UI, Velvet Room Settings, Jagged Desktop Clock + Real-Time Weather, 64-Band Split Cava, serta LRCLIB Live Lyrics dengan tetap hemat CPU/GPU untuk gaming."
                                                color: PhantomState.muted
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                                lineHeight: 1.15
                                            }

                                            // deretan tombol aksi cepat pada kartu informasi
                                            RowLayout {
                                                spacing: 8
                                                Layout.topMargin: 4

                                                Repeater {
                                                    model: [
                                                        { label: "↻ REFRESH SPECS", action: "refresh" },
                                                        { label: "★ FIRE CALLING CARD", action: "test_im" },
                                                        { label: "✎ OPEN DOTFILES", action: "open_dir" }
                                                    ]

                                                    delegate: Rectangle {
                                                        required property var modelData
                                                        width: chipTxt.implicitWidth + 20
                                                        height: 24
                                                        color: chipMouse.containsMouse ? PhantomState.primary : "#1E1E2A"
                                                        border.color: "#FFFFFF"
                                                        border.width: 2

                                                        Text {
                                                            id: chipTxt
                                                            anchors.centerIn: parent
                                                            text: modelData.label
                                                            color: "#FFFFFF"
                                                            font.family: "JetBrainsMono NFM"
                                                            font.pixelSize: 9
                                                            font.weight: Font.Black
                                                        }

                                                        MouseArea {
                                                            id: chipMouse
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: {
                                                                if (modelData.action === "refresh") {
                                                                    PhantomState.refreshSystemDossier()
                                                                    PhantomState.refreshMonitors()
                                                                } else if (modelData.action === "test_im") {
                                                                    PhantomState.sendTestNotification()
                                                                } else if (modelData.action === "open_dir") {
                                                                    Quickshell.execDetached(["sh", "-c", "ghostty --working-directory=/mnt/data/Projects/rice/phantomshell || kitty -d /mnt/data/Projects/rice/phantomshell || xdg-open /mnt/data/Projects/rice/phantomshell"])
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // grid informasi pembuat dan arsitektur shell
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    rowSpacing: 10
                                    columnSpacing: 10

                                    Repeater {
                                        model: [
                                            {
                                                tag: "AUTHOR // CREATOR",
                                                title: "sho (Ren Amamiya / Joker)",
                                                sub: "Lead Architect, UI/UX Designer & NixOS System Builder",
                                                badge: "CREATOR"
                                            },
                                            {
                                                tag: "SHELL // ARCHITECTURE",
                                                title: "Phantomshell v1.0.0 (Metaverse Build)",
                                                sub: "Quickshell 0.3 (Qt6 QML) • Hyprland 0.56 (Lua Config)",
                                                badge: "v1.0.0"
                                            },
                                            {
                                                tag: "ART DIRECTION // UI",
                                                title: "Persona 5 Royal Comic-Cutout Engine",
                                                sub: "Inspired by ATLUS & Shigenori Soejima • 9 Theme Palettes",
                                                badge: "P5 ROYAL"
                                            },
                                            {
                                                tag: "MODULES // ECOSYSTEM",
                                                title: "Bar • Launcher • Radar • SNS • Clock • Cava • Lyrics",
                                                sub: "PipeWire Audio • LRCLIB Synced Lyrics • Open-Meteo Weather",
                                                badge: "FULL SUITE"
                                            }
                                        ]

                                        delegate: Item {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 72

                                            P5SkewedCard {
                                                anchors.fill: parent
                                                fillColor: "#161622"
                                                borderColor: PhantomState.secondary
                                                shadowColor: PhantomState.primary
                                                borderWidth: 2
                                                skewPx: 8
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 16
                                                anchors.rightMargin: 16
                                                spacing: 10

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2

                                                    Text {
                                                        text: "★ " + modelData.tag
                                                        color: PhantomState.secondary
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 9
                                                        font.weight: Font.Black
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: modelData.title
                                                        color: "#FFFFFF"
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 13
                                                        font.weight: Font.Black
                                                        font.italic: true
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: modelData.sub
                                                        color: PhantomState.muted
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 10
                                                        font.weight: Font.Bold
                                                        elide: Text.ElideRight
                                                    }
                                                }

                                                Rectangle {
                                                    width: 78
                                                    height: 24
                                                    color: PhantomState.secondary
                                                    border.color: "#09090D"
                                                    border.width: 2
                                                    rotation: -3

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.badge
                                                        color: "#09090D"
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 9
                                                        font.weight: Font.Black
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                P5SectionHeader { text: "HOST HARDWARE & OPERATING SYSTEM SPECIFICATIONS" }

                                // grid spesifikasi perangkat keras dan sistem operasi
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    rowSpacing: 10
                                    columnSpacing: 10

                                    Repeater {
                                        model: [
                                            {
                                                tag: "OS // DISTRO",
                                                title: PhantomState.sysOs,
                                                sub: "Host: " + PhantomState.sysHost + " • NixOS Declarative Flake",
                                                badge: "NIXOS"
                                            },
                                            {
                                                tag: "KERNEL // UPTIME",
                                                title: PhantomState.sysKernel,
                                                sub: "Session Uptime: " + PhantomState.sysUptime + " • Wayland Protocol",
                                                badge: "LIVE"
                                            },
                                            {
                                                tag: "PROCESSOR // CPU",
                                                title: PhantomState.sysCpuModel,
                                                sub: "Current Load: " + Math.round(PhantomState.cpuPct) + "% • Thermal: " + Math.round(PhantomState.tempPct) + "°C",
                                                badge: Math.round(PhantomState.cpuPct) + "%"
                                            },
                                            {
                                                tag: "GRAPHICS // GPU",
                                                title: PhantomState.sysGpuModel,
                                                sub: "Hardware Accelerated OpenGL / Vulkan SceneGraph",
                                                badge: Math.round(PhantomState.gpuPct) + "%"
                                            },
                                            {
                                                tag: "MEMORY // STORAGE",
                                                title: "RAM: " + PhantomState.sysRamText,
                                                sub: "Memory Usage: " + Math.round(PhantomState.ramPct) + "% • Disk Usage: " + Math.round(PhantomState.diskPct) + "%",
                                                badge: Math.round(PhantomState.ramPct) + "%"
                                            },
                                            {
                                                tag: "DISPLAY // COMPOSITOR",
                                                title: PhantomState.displayName + " • " + PhantomState.displayMode,
                                                sub: "Hyprland 0.56.2 (Lua Engine) + Quickshell 0.3.0 (Qt6)",
                                                badge: "MAX HZ"
                                            }
                                        ]

                                        delegate: Item {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 74

                                            P5SkewedCard {
                                                anchors.fill: parent
                                                fillColor: "#14141D"
                                                borderColor: "#FFFFFF"
                                                shadowColor: PhantomState.primary
                                                borderWidth: 2
                                                skewPx: 8
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 16
                                                anchors.rightMargin: 16
                                                spacing: 10

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2

                                                    Text {
                                                        text: "★ " + modelData.tag
                                                        color: PhantomState.secondary
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 9
                                                        font.weight: Font.Black
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: modelData.title
                                                        color: "#FFFFFF"
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 13
                                                        font.weight: Font.Black
                                                        font.italic: true
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: modelData.sub
                                                        color: PhantomState.muted
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 10
                                                        font.weight: Font.Bold
                                                        elide: Text.ElideRight
                                                    }
                                                }

                                                Rectangle {
                                                    width: 68
                                                    height: 26
                                                    color: PhantomState.primary
                                                    border.color: "#FFFFFF"
                                                    border.width: 1.5
                                                    rotation: -3

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.badge
                                                        color: "#FFFFFF"
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 10
                                                        font.weight: Font.Black
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                P5SectionHeader { text: "PHANTOM THIEVES ENGINE // ARCHITECTURE & CREDITS" }

                                P5SkewedCard {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 68
                                    fillColor: "#101017"
                                    borderColor: PhantomState.secondary
                                    shadowColor: PhantomState.primary
                                    borderWidth: 2
                                    skewPx: 8

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 14

                                        P5Star {
                                            Layout.preferredWidth: 34
                                            Layout.preferredHeight: 34
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            Text {
                                                text: "\"TAKE YOUR TIME // STEAL BACK YOUR FUTURE\""
                                                color: "#FFFFFF"
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 13
                                                font.weight: Font.Black
                                                font.italic: true
                                            }
                                            Text {
                                                text: "Inspired by ATLUS Persona 5 Royal • Built with Quickshell Qt6, Hyprland Lua, PipeWire, Cava, LRCLIB & Open-Meteo"
                                                color: PhantomState.muted
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }
                                P5SectionHeader { text: "PHANTOM ENGINE // UPDATER \u0026 SYNC" }

                                // kartu status git dan kontrol sinkronisasi
                                P5SkewedCard {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 90
                                    fillColor: {
                                        if (PhantomState.syncStatus === "ERROR") return "#1A0A0A"
                                        if (PhantomState.syncStatus === "DONE") return "#0A1A0F"
                                        if (PhantomState.syncUpdateAvailable) return "#1A1300"
                                        return "#12121C"
                                    }
                                    borderColor: {
                                        if (PhantomState.syncStatus === "ERROR") return "#FF3333"
                                        if (PhantomState.syncStatus === "DONE") return PhantomState.success
                                        if (PhantomState.syncUpdateAvailable) return PhantomState.secondary
                                        return "#FFFFFF"
                                    }
                                    shadowColor: PhantomState.primary
                                    borderWidth: 2
                                    skewPx: 8

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 6

                                        // baris header dan badge status
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 10
                                            Text {
                                                text: "★ GIT // UPDATER"
                                                color: PhantomState.secondary
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                font.weight: Font.Black
                                            }
                                            Item { Layout.fillWidth: true }
                                            Rectangle {
                                                width: statusBadgeTxt.implicitWidth + 16
                                                height: 20
                                                color: {
                                                    const s = PhantomState.syncStatus
                                                    if (s === "ERROR") return "#FF3333"
                                                    if (s === "DONE") return PhantomState.success
                                                    if (s === "UPDATE_AVAILABLE") return PhantomState.secondary
                                                    if (s === "UP_TO_DATE") return "#204020"
                                                    return "#1E1E2A"
                                                }
                                                border.color: "#FFFFFF"
                                                border.width: 1
                                                Text {
                                                    id: statusBadgeTxt
                                                    anchors.centerIn: parent
                                                    text: {
                                                        const s = PhantomState.syncStatus
                                                        if (s === "IDLE") return "IDLE"
                                                        if (s === "CHECKING") return "CHECKING..."
                                                        if (s === "UP_TO_DATE") return "UP TO DATE ✓"
                                                        if (s === "UPDATE_AVAILABLE") return PhantomState.gitBehind + " COMMITS BEHIND"
                                                        if (s === "AHEAD") return PhantomState.gitAhead + " AHEAD"
                                                        if (s === "PULLING") return "PULLING..."
                                                        if (s === "SYNCING") return "SYNCING..."
                                                        if (s === "RELOADING") return "RELOADING..."
                                                        if (s === "DONE") return "DONE ★"
                                                        if (s === "ERROR") return "ERROR ✗"
                                                        if (s === "OFFLINE") return "OFFLINE"
                                                        return s
                                                    }
                                                    color: "#FFFFFF"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Black
                                                }
                                            }
                                        }

                                        // baris hash commit lokal dan remote
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8
                                            Text {
                                                text: PhantomState.gitBranch + " @ " + PhantomState.gitLocalHash
                                                color: "#FFFFFF"
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 12
                                                font.weight: Font.Black
                                                font.italic: true
                                            }
                                            Text {
                                                text: "→ " + PhantomState.gitRemoteHash
                                                color: PhantomState.secondary
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 11
                                                font.weight: Font.Black
                                                visible: PhantomState.gitRemoteHash !== "-------" && PhantomState.gitRemoteHash !== PhantomState.gitLocalHash
                                            }
                                            Item { Layout.fillWidth: true }
                                            Text {
                                                text: PhantomState.gitLastDate
                                                color: PhantomState.muted
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                elide: Text.ElideRight
                                                Layout.maximumWidth: 110
                                            }
                                        }

                                        // baris pesan commit dan tombol aksi
                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 8
                                            Text {
                                                Layout.fillWidth: true
                                                text: PhantomState.gitLastMsg || "No commit info"
                                                color: PhantomState.muted
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                elide: Text.ElideRight
                                            }

                                            // tombol check update dari remote
                                            Rectangle {
                                                width: checkUpdTxt.implicitWidth + 14
                                                height: 22
                                                color: checkUpdMouse.containsMouse ? PhantomState.primary : "#1E1E2E"
                                                border.color: "#FFFFFF"
                                                border.width: 1.5
                                                opacity: PhantomState.syncBusy ? 0.4 : 1.0
                                                Text {
                                                    id: checkUpdTxt
                                                    anchors.centerIn: parent
                                                    text: "↺ CHECK"
                                                    color: "#FFFFFF"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Black
                                                }
                                                MouseArea {
                                                    id: checkUpdMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: PhantomState.checkSyncUpdate()
                                                }
                                            }

                                            // tombol apply dev ke sistem tanpa pull
                                            Rectangle {
                                                width: applyUpdTxt.implicitWidth + 14
                                                height: 22
                                                color: applyUpdMouse.containsMouse ? PhantomState.secondary : "#1E1E2E"
                                                border.color: PhantomState.secondary
                                                border.width: 1.5
                                                opacity: PhantomState.syncBusy ? 0.4 : 1.0
                                                Text {
                                                    id: applyUpdTxt
                                                    anchors.centerIn: parent
                                                    text: "↗ APPLY"
                                                    color: applyUpdMouse.containsMouse ? "#09090D" : PhantomState.secondary
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Black
                                                }
                                                MouseArea {
                                                    id: applyUpdMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: PhantomState.syncToSystem()
                                                }
                                            }

                                            // tombol pull dari github + sync
                                            Rectangle {
                                                width: pullUpdTxt.implicitWidth + 14
                                                height: 22
                                                color: pullUpdMouse.containsMouse ? PhantomState.primary : (PhantomState.syncUpdateAvailable ? "#2A1800" : "#1E1E2E")
                                                border.color: PhantomState.syncUpdateAvailable ? PhantomState.secondary : "#FFFFFF"
                                                border.width: PhantomState.syncUpdateAvailable ? 2 : 1.5
                                                opacity: PhantomState.syncBusy ? 0.4 : 1.0
                                                Text {
                                                    id: pullUpdTxt
                                                    anchors.centerIn: parent
                                                    text: "↓ PULL \u0026 SYNC"
                                                    color: "#FFFFFF"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Black
                                                }
                                                MouseArea {
                                                    id: pullUpdMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: PhantomState.pullAndSync()
                                                }
                                            }
                                        }
                                    }
                                }

                                // terminal log output sinkronisasi
                                P5SkewedCard {
                                    id: syncLogCard
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: syncLogCard.logVisible ? 130 : 34
                                    fillColor: "#080810"
                                    borderColor: "#2A2A44"
                                    shadowColor: PhantomState.primary
                                    borderWidth: 1
                                    skewPx: 4
                                    clip: true

                                    property bool logVisible: PhantomState.syncBusy || PhantomState.syncLog.length > 0

                                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 4

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6
                                            Text {
                                                text: "SYNC LOG //"
                                                color: PhantomState.muted
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                font.weight: Font.Black
                                            }
                                            Text {
                                                text: PhantomState.syncBusy ? "RUNNING..." : (PhantomState.syncStatus === "DONE" ? "COMPLETED" : (PhantomState.syncStatus === "ERROR" ? "FAILED" : "READY"))
                                                color: PhantomState.syncStatus === "ERROR" ? "#FF4444" : (PhantomState.syncStatus === "DONE" ? PhantomState.success : PhantomState.muted)
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                font.weight: Font.Black
                                            }
                                            Item { Layout.fillWidth: true }
                                            Text {
                                                text: "CLR"
                                                color: clrLogMouse.containsMouse ? "#FFFFFF" : PhantomState.muted
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                font.weight: Font.Black
                                                MouseArea {
                                                    id: clrLogMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: PhantomState.clearSyncLog()
                                                }
                                            }
                                        }

                                        Flickable {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            contentWidth: width
                                            contentHeight: syncLogText.implicitHeight
                                            clip: true
                                            boundsBehavior: Flickable.StopAtBounds
                                            onContentHeightChanged: contentY = Math.max(0, contentHeight - height)
                                            Text {
                                                id: syncLogText
                                                width: parent.width
                                                text: PhantomState.syncLog || "— waiting for operation —"
                                                color: "#6E7EB8"
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                                lineHeight: 1.4
                                            }
                                        }
                                    }
                                }

                                P5SectionHeader { text: "KEYBOARD BINDS // PHANTOM THIEF TACTICS COMPENDIUM" }

                                // cheat sheet seluruh keybind aktif hyprland
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    rowSpacing: 6
                                    columnSpacing: 8

                                    Repeater {
                                        model: [
                                            { cat: "PHANTOM SHELL // PANELS", key: "SUPER + D", act: "Toggle Launcher (P5 Command Search)" },
                                            { cat: "", key: "SUPER (tap)", act: "Toggle Launcher (Quick)" },
                                            { cat: "", key: "SUPER + N", act: "Control Center \u0026 Pentagon Stats" },
                                            { cat: "", key: "SUPER + I", act: "Unified Settings (Velvet Room)" },
                                            { cat: "", key: "SUPER + M", act: "SNS Notification Center" },
                                            { cat: "", key: "SUPER + P", act: "Lock Screen (Calling Card Lock)" },
                                            { cat: "", key: "SUPER + SHIFT + L", act: "Lock Screen (alternate)" },
                                            { cat: "", key: "SUPER + Escape", act: "Power Menu (Calling Card Session)" },
                                            { cat: "APPLICATIONS", key: "SUPER + Return", act: "Launch Kitty Terminal" },
                                            { cat: "WINDOW MANAGEMENT", key: "SUPER + Q", act: "Close Active Window" },
                                            { cat: "", key: "SUPER + F", act: "Toggle Fullscreen" },
                                            { cat: "", key: "SUPER + Space", act: "Toggle Float" },
                                            { cat: "", key: "SUPER + SHIFT + E", act: "Exit Hyprland" },
                                            { cat: "FOCUS \u0026 MOVE", key: "SUPER + ← / → / ↑ / ↓", act: "Move Focus (Arrow Keys)" },
                                            { cat: "", key: "SUPER + H / J / K / L", act: "Move Focus (Vim Keys)" },
                                            { cat: "", key: "SUPER + SHIFT + ←→↑↓", act: "Move Window in Direction" },
                                            { cat: "MOUSE", key: "SUPER + LMB drag", act: "Drag \u0026 Move Window" },
                                            { cat: "", key: "SUPER + RMB drag", act: "Resize Window" },
                                            { cat: "WORKSPACES", key: "SUPER + 1-9 / 0", act: "Switch to Workspace 1-10" },
                                            { cat: "", key: "SUPER + SHIFT + 1-9 / 0", act: "Move Window to Workspace 1-10" },
                                            { cat: "MEDIA \u0026 SYSTEM", key: "XF86AudioRaiseVolume", act: "Volume Up +5% (OSD)" },
                                            { cat: "", key: "XF86AudioLowerVolume", act: "Volume Down -5% (OSD)" },
                                            { cat: "", key: "XF86AudioMute", act: "Toggle Mute (OSD)" },
                                            { cat: "", key: "XF86MonBrightnessUp", act: "Brightness Up +5% (OSD)" },
                                            { cat: "", key: "XF86MonBrightnessDown", act: "Brightness Down -5% (OSD)" }
                                        ]

                                        delegate: Item {
                                            required property var modelData
                                            required property int index
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: modelData.cat !== "" ? 54 : 32

                                            // label kategori keybind
                                            Text {
                                                anchors.top: parent.top
                                                anchors.left: parent.left
                                                text: "★ " + modelData.cat
                                                color: PhantomState.secondary
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                font.weight: Font.Black
                                                visible: modelData.cat !== ""
                                            }

                                            // baris shortcut individual
                                            P5SkewedCard {
                                                anchors.bottom: parent.bottom
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                height: 28
                                                fillColor: "#12121C"
                                                borderColor: "#2A2A40"
                                                shadowColor: PhantomState.primary
                                                borderWidth: 1
                                                skewPx: 4

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 10
                                                    anchors.rightMargin: 10
                                                    spacing: 8
                                                    Rectangle {
                                                        width: kbTxt.implicitWidth + 14
                                                        height: 18
                                                        color: "#1A1A2E"
                                                        border.color: PhantomState.secondary
                                                        border.width: 1
                                                        radius: 2
                                                        Text {
                                                            id: kbTxt
                                                            anchors.centerIn: parent
                                                            text: modelData.key
                                                            color: PhantomState.secondary
                                                            font.family: "JetBrainsMono NFM"
                                                            font.pixelSize: 8
                                                            font.weight: Font.Black
                                                        }
                                                    }
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: modelData.act
                                                        color: "#FFFFFF"
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 9
                                                        font.weight: Font.Bold
                                                        elide: Text.ElideRight
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

                // tombol stempel penutup jendela pengaturan di bagian bawah
                Item {

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 195
                    height: 66
                    rotation: -6
                    z: 30
                    scale: okSettingsMouse.containsMouse ? 1.06 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                    Canvas {
                        anchors.fill: parent
                        property bool hov: okSettingsMouse.containsMouse
                        property color accent: PhantomState.primary
                        onHovChanged: requestPaint()
                        onAccentChanged: requestPaint()
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.fillStyle = "#FFFFFF"
                            ctx.beginPath()
                            ctx.moveTo(14, 0)
                            ctx.lineTo(width, 6)
                            ctx.lineTo(width - 16, height)
                            ctx.lineTo(0, height - 6)
                            ctx.closePath()
                            ctx.fill()

                            ctx.fillStyle = hov ? accent : "#08080A"
                            ctx.beginPath()
                            ctx.moveTo(20, 6)
                            ctx.lineTo(width - 8, 12)
                            ctx.lineTo(width - 22, height - 6)
                            ctx.lineTo(6, height - 12)
                            ctx.closePath()
                            ctx.fill()
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        P5Icon {
                            name: "star"
                            color: okSettingsMouse.containsMouse ? "#FFFFFF" : PhantomState.primary
                            size: 24
                        }
                        Text {
                            text: "OK"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 32
                            font.weight: Font.Black
                            font.italic: true
                        }
                    }

                    MouseArea {
                        id: okSettingsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PhantomState.settingsOpen = false
                    }
                }
            }
        }
    }
}
