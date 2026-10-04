import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

Scope {
    Variants {
        model: Quickshell.screens

        // jendela panel control center dan pengaturan cepat jaringan
        PanelWindow {
            id: dashWin
            required property ShellScreen modelData
            screen: modelData
            visible: PhantomState.dashboardOpen

            readonly property bool isBottom: PhantomState.barPosition === "bottom"
            property int brightnessPct: 80

            // state navigasi sub-panel dan item jaringan atau perangkat terpilih
            property string subPanel: "main"
            property int selectedWifiIdx: -1
            property bool showWifiInfo: false
            property bool showWifiPasswordBox: false
            property string wifiPasswordInput: ""

            property int selectedBtIdx: -1
            property bool showBtInfo: false
            property real clickedCardCenterY: 195
            property bool animateRadialY: false

            readonly property bool wifiRadialOpen: subPanel === "wifi" && selectedWifiIdx >= 0 && selectedWifiIdx < PhantomState.wifiNetworks.length
            readonly property bool btRadialOpen: subPanel === "bluetooth" && selectedBtIdx >= 0 && selectedBtIdx < PhantomState.btDevices.length
            readonly property bool radialOpen: wifiRadialOpen || btRadialOpen

            // fungsi pemilihan kartu jaringan wi-fi dan pemosisian menu radial
            function selectWifiCard(idx, cardItem) {
                if (selectedWifiIdx === idx) {
                    selectedWifiIdx = -1
                    showWifiInfo = false
                    showWifiPasswordBox = false
                    return
                }
                const wasOpen = radialOpen
                const cy = cardItem.mapToItem(dashCard, 0, cardItem.height / 2).y
                animateRadialY = wasOpen
                clickedCardCenterY = cy
                showWifiPasswordBox = false
                selectedWifiIdx = idx
                if (wasOpen) {
                    leftRadialSwitchAnim.restart()
                }
            }

            function selectBtCard(idx, cardItem) {
                if (selectedBtIdx === idx) {
                    selectedBtIdx = -1
                    showBtInfo = false
                    return
                }
                const wasOpen = radialOpen
                const cy = cardItem.mapToItem(dashCard, 0, cardItem.height / 2).y
                animateRadialY = wasOpen
                clickedCardCenterY = cy
                selectedBtIdx = idx
                if (wasOpen) {
                    leftRadialSwitchAnim.restart()
                }
            }

            WlrLayershell.namespace: "phantomshell-dashboard"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: (PhantomState.dashboardOpen && dashWin.showWifiPasswordBox)
                ? WlrKeyboardFocus.OnDemand
                : WlrKeyboardFocus.None
            exclusiveZone: 0

            anchors {
                top: !dashWin.isBottom
                bottom: dashWin.isBottom
                right: true
            }
            margins {
                top: 42
                bottom: 42
                right: 10
            }

            // ukuran jendela tetap dengan mask input dinamis untuk area menu radial
            implicitWidth: Math.min(756, (modelData?.width ?? 1280) - 20)
            implicitHeight: Math.min(640, (modelData?.height ?? 720) - 52)
            color: "transparent"

            mask: Region {
                item: dashCard
                Region {
                    item: (dashWin.radialOpen || leftRadialMenu.openProgress > 0.01) ? leftRadialMenu : dashCard
                }
            }

            onVisibleChanged: {
                if (visible) {
                    dashEntryAnim.restart()
                    PhantomState.refreshWifi()
                    PhantomState.refreshBluetooth()
                } else {
                    animateRadialY = false
                    subPanel = "main"
                    selectedWifiIdx = -1
                    selectedBtIdx = -1
                    showWifiInfo = false
                    showBtInfo = false
                    showWifiPasswordBox = false
                }
            }

            // komponen bilah tombol aksi berbentuk baji segitiga dengan lencana ikon bulat
            component P5BattleBlade: Item {
                id: blade
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                Layout.minimumHeight: 46
                implicitHeight: 54

                property string title: "COMMAND"
                property string subtitle: "Execute Action"
                property string iconName: "star"
                property string badgeTag: "A"
                property color badgeColor: "#00F59B"
                property bool active: false
                property real bladeTilt: -2.0
                property bool tailOnRight: false
                property real fanProgress: 1.0
                signal clicked()

                property real hoverScale: bladeMouse.containsMouse ? 1.05 : 1.0
                property real hoverTiltOffset: bladeMouse.containsMouse
                    ? (tailOnRight ? (bladeTilt >= 0 ? 1.5 : -1.5) : -1.5)
                    : 0.0
                Behavior on hoverScale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }
                Behavior on hoverTiltOffset { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

                transformOrigin: tailOnRight ? Item.Right : Item.Left
                scale: hoverScale
                rotation: (bladeTilt * fanProgress) + hoverTiltOffset

                Canvas {
                    id: bladeCanvas
                    anchors.fill: parent
                    property bool isAct: blade.active
                    property bool isHov: bladeMouse.containsMouse
                    property bool isRightTail: blade.tailOnRight
                    property color cPrimary: PhantomState.primary
                    property color cSecondary: PhantomState.secondary
                    property color cBadge: blade.badgeColor
                    onIsActChanged: requestPaint()
                    onIsHovChanged: requestPaint()
                    onIsRightTailChanged: requestPaint()
                    onCPrimaryChanged: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var h = height

                        if (!isRightTail) {
                            // orientasi bilah dari kiri ke kanan
                            var tipX = 2
                            var tipY = h * 0.52
                            var bx = 38
                            var by = h * 0.48
                            var br = 13.5

                            // poligon bayangan merah bertingkat
                            ctx.fillStyle = (isAct || isHov) ? "#FF1E2E" : "#E60012"
                            ctx.beginPath()
                            ctx.moveTo(tipX, tipY + 1)
                            ctx.lineTo(bx, tipY - 3)
                            ctx.lineTo(w - 2, 10)
                            ctx.lineTo(w, 34)
                            ctx.lineTo(w - 8, 35)
                            ctx.lineTo(w - 5, h - 1)
                            ctx.lineTo(w * 0.42, h - 4)
                            ctx.lineTo(w * 0.40, h - 13)
                            ctx.lineTo(bx - 4, tipY + 7)
                            ctx.closePath()
                            ctx.fill()

                            // bidang baji segitiga hitam utama
                            ctx.fillStyle = "#05060A"
                            ctx.beginPath()
                            ctx.moveTo(tipX, tipY)
                            ctx.lineTo(bx, by - 6)
                            ctx.lineTo(w - 10, 3)
                            ctx.lineTo(w - 6, 31)
                            ctx.lineTo(bx, by + 6)
                            ctx.closePath()
                            ctx.fill()

                            // kotak label subjudul di bagian kanan bawah
                            ctx.fillStyle = "#05060A"
                            ctx.beginPath()
                            ctx.moveTo(w * 0.36, 28)
                            ctx.lineTo(w - 14, 26)
                            ctx.lineTo(w - 11, h - 7)
                            ctx.lineTo(w * 0.38, h - 9)
                            ctx.closePath()
                            ctx.fill()

                            // lingkaran lencana ikon dengan cincin tepi putih
                            ctx.fillStyle = "#FFFFFF"
                            ctx.beginPath()
                            ctx.arc(bx, by, br + 2.8, 0, Math.PI * 2)
                            ctx.fill()

                            ctx.fillStyle = "#05060A"
                            ctx.beginPath()
                            ctx.arc(bx, by, br, 0, Math.PI * 2)
                            ctx.fill()
                        } else {
                            // orientasi bilah dari kanan ke kiri untuk menu radial
                            var rTipX = w - 2
                            var rTipY = h * 0.52
                            var rbx = w - 42
                            var rby = h * 0.48
                            var rbr = 14.0

                            // poligon bayangan merah bertingkat dengan garis tepi putih
                            ctx.fillStyle = (isAct || isHov) ? "#FF2434" : "#E60012"
                            ctx.strokeStyle = "#FFFFFF"
                            ctx.lineWidth = 1.2
                            ctx.beginPath()
                            ctx.moveTo(rTipX, rTipY + 1)
                            ctx.lineTo(rbx, rTipY - 3)
                            ctx.lineTo(2, 10)
                            ctx.lineTo(0, 34)
                            ctx.lineTo(10, 35)
                            ctx.lineTo(6, h - 1)
                            ctx.lineTo(w * 0.60, h - 4)
                            ctx.lineTo(w * 0.62, h - 13)
                            ctx.lineTo(rbx + 4, rTipY + 7)
                            ctx.closePath()
                            ctx.fill()
                            ctx.stroke()

                            // bidang baji segitiga hitam utama melebar ke kiri
                            ctx.fillStyle = "#05060A"
                            ctx.beginPath()
                            ctx.moveTo(rTipX, rTipY)
                            ctx.lineTo(rbx, rby - 6)
                            ctx.lineTo(12, 3)
                            ctx.lineTo(8, 31)
                            ctx.lineTo(rbx, rby + 6)
                            ctx.closePath()
                            ctx.fill()

                            // kotak label subjudul di bagian kiri bawah
                            ctx.fillStyle = "#05060A"
                            ctx.beginPath()
                            ctx.moveTo(w * 0.64, 28)
                            ctx.lineTo(16, 26)
                            ctx.lineTo(13, h - 7)
                            ctx.lineTo(w * 0.62, h - 9)
                            ctx.closePath()
                            ctx.fill()

                            // lingkaran lencana ikon di pangkal kanan
                            ctx.fillStyle = "#FFFFFF"
                            ctx.beginPath()
                            ctx.arc(rbx, rby, rbr + 3.0, 0, Math.PI * 2)
                            ctx.fill()

                            ctx.fillStyle = "#05060A"
                            ctx.beginPath()
                            ctx.arc(rbx, rby, rbr, 0, Math.PI * 2)
                            ctx.fill()
                        }
                    }
                }

                // ikon vektor di dalam lencana bulat
                P5Icon {
                    x: blade.tailOnRight ? (parent.width - 49) : 31
                    y: parent.height * 0.48 - 7
                    name: blade.iconName
                    size: 14
                    color: blade.badgeColor
                }

                // teks judul utama bilah perintah
                Text {
                    x: blade.tailOnRight ? 20 : 58
                    y: 5
                    width: parent.width - 82
                    horizontalAlignment: blade.tailOnRight ? Text.AlignRight : Text.AlignLeft
                    text: blade.title
                    color: (blade.active || bladeMouse.containsMouse) ? PhantomState.secondary : "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 17
                    font.weight: Font.Black
                    font.italic: true
                    font.letterSpacing: -0.5
                    rotation: blade.tailOnRight ? 2.2 : -2.2
                    elide: Text.ElideRight
                }

                // teks subjudul di dalam kotak label bawah
                Text {
                    x: blade.tailOnRight ? 20 : (parent.width * 0.39)
                    y: parent.height - 22
                    width: parent.width * 0.54
                    horizontalAlignment: blade.tailOnRight ? Text.AlignLeft : Text.AlignRight
                    text: blade.subtitle
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    font.weight: Font.Black
                    font.italic: true
                    elide: Text.ElideRight
                }

                MouseArea {
                    id: bladeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: blade.clicked()
                }
            }

            Item {
                id: dashCard
                width: Math.min(450, parent.width)
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                transformOrigin: dashWin.isBottom ? Item.BottomRight : Item.TopRight

                ParallelAnimation {
                    id: dashEntryAnim
                    NumberAnimation {
                        target: dashCard
                        property: "scale"
                        from: 0.85
                        to: 1.0
                        duration: 240
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.35
                    }
                    NumberAnimation {
                        target: dashCard
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: PhantomState.background
                    borderColor: PhantomState.borderLight
                    shadowColor: PhantomState.primary
                    borderWidth: 2
                    skewPx: PhantomState.polygonMode ? 8 : 0
                    shadowOffsetX: 4
                    shadowOffsetY: 4
                }

                // tampilan utama control center
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8
                    visible: dashWin.subPanel === "main"

                    // header calling card control center
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        P5Star {
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            spinning: true
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                Layout.fillWidth: true
                                text: "THIEVES DEN // CONTROL CENTER"
                                color: PhantomState.primary
                                font.pixelSize: 14
                                font.weight: Font.Black
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "JOKER (SHO) • BAT " + PhantomState.batteryPct + "% • " + PhantomState.themeName.toUpperCase()
                                color: PhantomState.muted
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            width: 24
                            height: 24
                            color: PhantomState.surfaceAlt
                            border.color: PhantomState.borderLight
                            border.width: 1
                            P5Icon { anchors.centerIn: parent; name: "close"; size: 11 }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.dashboardOpen = false
                            }
                        }
                    }

                    // slider bintang volume & brightness
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Row {
                                Layout.preferredWidth: 92
                                spacing: 6
                                P5Icon { name: "volume"; size: 13; color: PhantomState.secondary; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "AUDIO " + PhantomState.volumePct + "%"
                                    color: PhantomState.foreground
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Item {
                                id: volTrack
                                Layout.fillWidth: true
                                Layout.preferredHeight: 26

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: "#080A0F"
                                    borderColor: "#FFFFFF"
                                    shadowColor: PhantomState.primary
                                    borderWidth: 2
                                    skewPx: 5
                                    shadowOffsetX: 2
                                    shadowOffsetY: 2
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 32
                                    anchors.rightMargin: 32
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: 3
                                    color: "#44FFFFFF"

                                    Rectangle {
                                        width: parent.width * Math.min(1.0, PhantomState.volumePct / 100.0)
                                        height: parent.height
                                        color: PhantomState.primary
                                    }
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "MIN"
                                    color: PhantomState.muted
                                    font.pixelSize: 8
                                    font.weight: Font.Black
                                    rotation: -12
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "MAX"
                                    color: PhantomState.secondary
                                    font.pixelSize: 8
                                    font.weight: Font.Black
                                    rotation: -12
                                }

                                P5Star {
                                    width: 20
                                    height: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: 24 + (volTrack.width - 68) * Math.min(1.0, Math.max(0.0, PhantomState.volumePct / 100.0))
                                    Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    function setFromMouse(mx) {
                                        var pct = Math.round(Math.max(0, Math.min(100, ((mx - 24) / (volTrack.width - 48)) * 100)))
                                        PhantomState.volumePct = pct
                                        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct + "%"])
                                    }
                                    onPressed: mouse => setFromMouse(mouse.x)
                                    onPositionChanged: mouse => { if (pressed) setFromMouse(mouse.x) }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Row {
                                Layout.preferredWidth: 92
                                spacing: 6
                                P5Icon { name: "sun"; size: 13; color: PhantomState.secondary; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "LIGHT " + dashWin.brightnessPct + "%"
                                    color: PhantomState.foreground
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Item {
                                id: brtTrack
                                Layout.fillWidth: true
                                Layout.preferredHeight: 26

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: "#080A0F"
                                    borderColor: "#FFFFFF"
                                    shadowColor: PhantomState.primary
                                    borderWidth: 2
                                    skewPx: 5
                                    shadowOffsetX: 2
                                    shadowOffsetY: 2
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 32
                                    anchors.rightMargin: 32
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: 3
                                    color: "#44FFFFFF"

                                    Rectangle {
                                        width: parent.width * Math.min(1.0, dashWin.brightnessPct / 100.0)
                                        height: parent.height
                                        color: PhantomState.secondary
                                    }
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "DIM"
                                    color: PhantomState.muted
                                    font.pixelSize: 8
                                    font.weight: Font.Black
                                    rotation: -12
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "BRT"
                                    color: PhantomState.secondary
                                    font.pixelSize: 8
                                    font.weight: Font.Black
                                    rotation: -12
                                }

                                P5Star {
                                    width: 20
                                    height: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: 24 + (brtTrack.width - 68) * Math.min(1.0, Math.max(0.0, dashWin.brightnessPct / 100.0))
                                    Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    function setBrt(mx) {
                                        var pct = Math.round(Math.max(5, Math.min(100, ((mx - 24) / (brtTrack.width - 48)) * 100)))
                                        dashWin.brightnessPct = pct
                                        Quickshell.execDetached(["brightnessctl", "set", pct + "%"])
                                    }
                                    onPressed: mouse => setBrt(mouse.x)
                                    onPositionChanged: mouse => { if (pressed) setBrt(mouse.x) }
                                }
                            }
                        }
                    }

                    // grid tombol aksi cepat sistem
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 6
                        columnSpacing: 8

                        P5BattleBlade {
                            title: "WI-FI"
                            subtitle: PhantomState.wifiConnected ? (PhantomState.wifiSsid + " ▸") : "Radio Off • Open Menu"
                            iconName: PhantomState.wifiConnected ? "wifi" : "wifi-off"
                            badgeColor: "#00F0FF"
                            active: PhantomState.wifiConnected
                            bladeTilt: -1.5
                            onClicked: {
                                dashWin.selectedWifiIdx = -1
                                dashWin.showWifiInfo = false
                                dashWin.showWifiPasswordBox = false
                                dashWin.subPanel = "wifi"
                                PhantomState.refreshWifi()
                            }
                        }

                        P5BattleBlade {
                            title: "BLUETOOTH"
                            subtitle: PhantomState.btConnected ? (PhantomState.btDeviceName + " ▸") : "Power Off • Open Menu"
                            iconName: "bluetooth"
                            badgeColor: "#48CAE4"
                            active: PhantomState.btConnected
                            bladeTilt: 1.2
                            onClicked: {
                                dashWin.selectedBtIdx = -1
                                dashWin.showBtInfo = false
                                dashWin.subPanel = "bluetooth"
                                PhantomState.refreshBluetooth()
                            }
                        }

                        P5BattleBlade {
                            title: "STEALTH"
                            subtitle: PhantomState.dndEnabled ? "DND Active (Muted)" : "SNS Popups Active"
                            iconName: PhantomState.dndEnabled ? "bell-off" : "bell"
                            badgeColor: "#FFD700"
                            active: PhantomState.dndEnabled
                            bladeTilt: 1.0
                            onClicked: PhantomState.dndEnabled = !PhantomState.dndEnabled
                        }

                        P5BattleBlade {
                            title: "POLYGON"
                            subtitle: PhantomState.polygonMode ? "Skewed P5 Cutouts" : "Flat Rectangles"
                            iconName: "polygon"
                            badgeColor: "#00F59B"
                            active: PhantomState.polygonMode
                            bladeTilt: -1.2
                            onClicked: {
                                PhantomState.polygonMode = !PhantomState.polygonMode
                                PhantomState.saveState()
                            }
                        }

                        P5BattleBlade {
                            title: "AUDIO SFX"
                            subtitle: PhantomState.sfxEnabled ? "Persona 5 Cues ON" : "UI Sounds Muted"
                            iconName: PhantomState.sfxEnabled ? "volume" : "mute"
                            badgeColor: "#FF4D88"
                            active: PhantomState.sfxEnabled
                            bladeTilt: -1.0
                            onClicked: {
                                PhantomState.sfxEnabled = !PhantomState.sfxEnabled
                                PhantomState.saveState()
                            }
                        }

                        P5BattleBlade {
                            title: "LOCK CARD"
                            subtitle: "Lock Session Screen"
                            iconName: "lock"
                            badgeColor: "#FFFFFF"
                            active: false
                            bladeTilt: 1.4
                            onClicked: PhantomState.lockScreen()
                        }
                    }

                    // baris tombol pemilih preset tema cepat
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: [
                                { id: "p5-crimson", icon: "phantom", label: "P5 CRIMSON" },
                                { id: "p3-reload",  icon: "moon",    label: "P3 RELOAD" },
                                { id: "p4-golden",  icon: "tv",      label: "P4 GOLDEN" }
                            ]

                            delegate: Item {
                                required property var modelData
                                readonly property bool isCurrent: PhantomState.themeId === modelData.id
                                Layout.fillWidth: true
                                Layout.preferredHeight: 30
                                Layout.minimumHeight: 28
                                implicitHeight: 30

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: parent.isCurrent ? PhantomState.secondary : PhantomState.surfaceAlt
                                    borderColor: PhantomState.borderLight
                                    showShadowOffset: false
                                    borderWidth: parent.isCurrent ? 2 : 1
                                    skewPx: PhantomState.polygonMode ? 4 : 0
                                }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    P5Icon {
                                        name: modelData.icon
                                        size: 13
                                        color: parent.parent.isCurrent ? PhantomState.background : PhantomState.foreground
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.label
                                        color: parent.parent.isCurrent ? PhantomState.background : PhantomState.foreground
                                        font.pixelSize: 10
                                        font.weight: Font.Black
                                        font.italic: true
                                        anchors.verticalCenter: parent.verticalCenter
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

                    // header grafik statistik sistem dan tombol ganti mode tampilan
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text {
                            Layout.fillWidth: true
                            text: "SYSTEM SOCIAL STATS // 5-POINT STAR"
                            color: PhantomState.secondary
                            font.pixelSize: 11
                            font.weight: Font.Black
                            elide: Text.ElideRight
                        }

                        Item {
                            Layout.preferredWidth: modeSwitchRow.implicitWidth + 20
                            Layout.preferredHeight: 22
                            implicitHeight: 22

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.surfaceAlt
                                borderColor: PhantomState.borderLight
                                showShadowOffset: false
                                borderWidth: 1
                                skewPx: 4
                            }

                            Row {
                                id: modeSwitchRow
                                anchors.centerIn: parent
                                spacing: 4
                                P5Icon {
                                    name: PhantomState.statsStyle === "pentagon" ? "star" : "bars"
                                    size: 11
                                    color: PhantomState.secondary
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: PhantomState.statsStyle === "pentagon" ? "STAR MODE" : "BARS MODE"
                                    color: PhantomState.foreground
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    PhantomState.statsStyle = (PhantomState.statsStyle === "pentagon") ? "bars" : "pentagon"
                                    PhantomState.saveState()
                                }
                            }
                        }
                    }

                    // komponen grafik statistik sistem
                    P5PentagonStats {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 125
                        Layout.preferredHeight: 175
                    }

                    // tombol pembuka jendela pengaturan lengkap
                    Item {
                        id: openSettingsBtn
                        Layout.fillWidth: true
                        Layout.minimumHeight: 36
                        Layout.preferredHeight: 36
                        implicitHeight: 36
                        z: 10

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: openSettingsMouse.containsMouse ? PhantomState.primary : PhantomState.surface
                            borderColor: openSettingsMouse.containsMouse ? "#FFFFFF" : PhantomState.primary
                            shadowColor: openSettingsMouse.containsMouse ? PhantomState.secondary : PhantomState.primary
                            borderWidth: 2
                            skewPx: PhantomState.polygonMode ? 6 : 0
                            shadowOffsetX: 3
                            shadowOffsetY: 3
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            P5Icon {
                                name: "settings"
                                size: 14
                                color: openSettingsMouse.containsMouse ? "#FFFFFF" : PhantomState.secondary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "OPEN UNIFIED SETTINGS GUI"
                                color: "#FFFFFF"
                                font.pixelSize: 11
                                font.weight: Font.Black
                                font.italic: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: openSettingsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                PhantomState.playSfx("select")
                                PhantomState.toggleSettings()
                            }
                        }
                    }
                }

                // sub-panel daftar jaringan wi-fi
                ColumnLayout {
                    id: wifiSubPanel
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    visible: dashWin.subPanel === "wifi"

                    readonly property var currentNet: (dashWin.selectedWifiIdx >= 0 && dashWin.selectedWifiIdx < PhantomState.wifiNetworks.length)
                        ? PhantomState.wifiNetworks[dashWin.selectedWifiIdx]
                        : null

                    // posisi titik tengah vertikal kartu wi-fi yang sedang dipilih
                    readonly property real selectedCardCenterY: wifiSubPanel.y + wifiListView.y
                        + (Math.max(0, dashWin.selectedWifiIdx) * (50 + wifiListView.spacing))
                        - wifiListView.contentY + 25

                    // header sub-panel wi-fi beserta tombol kembali, scan, dan power radio
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Item {
                            Layout.preferredWidth: 68
                            Layout.preferredHeight: 28

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.surfaceAlt
                                borderColor: "#FFFFFF"
                                shadowColor: PhantomState.primary
                                borderWidth: 1.5
                                skewPx: 5
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                P5Icon { name: "chevron-left"; size: 11; color: PhantomState.secondary; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "BACK"
                                    color: "#FFFFFF"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    font.italic: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    dashWin.selectedWifiIdx = -1
                                    dashWin.showWifiInfo = false
                                    dashWin.showWifiPasswordBox = false
                                    dashWin.subPanel = "main"
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                Layout.fillWidth: true
                                text: "WI-FI TACTICS // SELECT TARGET"
                                color: PhantomState.primary
                                font.pixelSize: 12
                                font.weight: Font.Black
                                font.italic: true
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: PhantomState.wifiStatusMsg !== ""
                                    ? PhantomState.wifiStatusMsg
                                    : ("ACTIVE: " + PhantomState.wifiSsid + " • IP " + PhantomState.wifiIp)
                                color: PhantomState.secondary
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                        }

                        Item {
                            Layout.preferredWidth: 62
                            Layout.preferredHeight: 26

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.wifiScanning ? PhantomState.primary : "#14151F"
                                borderColor: "#FFD700"
                                shadowColor: PhantomState.primary
                                borderWidth: 1.5
                                skewPx: 5
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                P5Icon { name: "scan"; size: 11; color: "#FFD700"; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: PhantomState.wifiScanning ? "..." : "SCAN"
                                    color: "#FFFFFF"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.italic: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.scanWifi()
                            }
                        }

                        Item {
                            Layout.preferredWidth: 58
                            Layout.preferredHeight: 26

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.wifiConnected ? "#0E2920" : "#221015"
                                borderColor: PhantomState.wifiConnected ? "#00F59B" : "#FF1E2E"
                                shadowColor: "#050508"
                                borderWidth: 1.5
                                skewPx: 5
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                P5Icon {
                                    name: PhantomState.wifiConnected ? "wifi" : "wifi-off"
                                    size: 11
                                    color: PhantomState.wifiConnected ? "#00F59B" : "#FF1E2E"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: PhantomState.wifiConnected ? "ON" : "OFF"
                                    color: "#FFFFFF"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.italic: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.setWifiPower(!PhantomState.wifiConnected)
                            }
                        }
                    }

                    // kartu informasi jaringan wi-fi dan kolom input password
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: dashWin.showWifiPasswordBox ? "#0D0E15" : "#12131C"
                            borderColor: dashWin.showWifiPasswordBox
                                ? PhantomState.secondary
                                : (dashWin.showWifiInfo ? "#00F0FF" : "#353548")
                            shadowColor: PhantomState.primary
                            borderWidth: 1.5
                            skewPx: 6
                        }

                        // tampilan input password jaringan wi-fi
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 12
                            spacing: 8
                            visible: dashWin.showWifiPasswordBox && wifiSubPanel.currentNet !== null

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "PASSKEY FOR // " + (wifiSubPanel.currentNet ? wifiSubPanel.currentNet.ssid.toUpperCase() : "")
                                    color: PhantomState.secondary
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.italic: true
                                }

                                TextInput {
                                    id: wifiPassField
                                    Layout.fillWidth: true
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    echoMode: TextInput.Password
                                    passwordCharacter: "★"
                                    clip: true
                                    onTextChanged: dashWin.wifiPasswordInput = text
                                    onVisibleChanged: {
                                        if (visible) {
                                            wifiPassField.forceActiveFocus()
                                        }
                                    }
                                    Keys.onReturnPressed: {
                                        if (wifiSubPanel.currentNet) {
                                            PhantomState.connectWifi(wifiSubPanel.currentNet.ssid, text)
                                            dashWin.showWifiPasswordBox = false
                                            text = ""
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Type Wi-Fi password & press Enter..."
                                        color: "#777788"
                                        font.pixelSize: 10
                                        visible: wifiPassField.text.length === 0
                                    }
                                }
                            }

                            Rectangle {
                                width: 58
                                height: 28
                                color: PhantomState.primary
                                border.color: "#FFFFFF"
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "JOIN"
                                    color: "#FFFFFF"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (wifiSubPanel.currentNet) {
                                            PhantomState.connectWifi(wifiSubPanel.currentNet.ssid, wifiPassField.text)
                                            dashWin.showWifiPasswordBox = false
                                            wifiPassField.text = ""
                                        }
                                    }
                                }
                            }
                        }

                        // tampilan ringkasan informasi jaringan wi-fi aktif
                        GridLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            columns: 2
                            rowSpacing: 2
                            columnSpacing: 14
                            visible: !dashWin.showWifiPasswordBox

                            readonly property var inspectNet: (dashWin.showWifiInfo && wifiSubPanel.currentNet)
                                ? wifiSubPanel.currentNet
                                : null

                            Text {
                                text: "SSID     : " + (parent.inspectNet ? parent.inspectNet.ssid : PhantomState.wifiSsid)
                                color: "#FFFFFF"; font.pixelSize: 10; font.weight: Font.Black; elide: Text.ElideRight; Layout.fillWidth: true
                            }
                            Text {
                                text: "SIGNAL   : " + (parent.inspectNet ? (parent.inspectNet.signal + "%") : (PhantomState.wifiSignal + "%"))
                                color: PhantomState.secondary; font.pixelSize: 10; font.weight: Font.Black
                            }
                            Text {
                                text: "SECURITY : " + (parent.inspectNet ? parent.inspectNet.security : PhantomState.wifiSecurity)
                                color: "#00F0FF"; font.pixelSize: 10; font.weight: Font.Black
                            }
                            Text {
                                text: "IPV4     : " + PhantomState.wifiIp
                                color: "#00F59B"; font.pixelSize: 10; font.weight: Font.Bold
                            }
                        }
                    }

                    Text {
                        text: wifiSubPanel.currentNet !== null
                            ? ("◂ COMMAND MENU OPEN ON THE LEFT FOR: " + wifiSubPanel.currentNet.ssid.toUpperCase())
                            : ("AVAILABLE NETWORKS (" + PhantomState.wifiNetworks.length + ") — CLICK A CARD TO POP OUT MENU ON THE LEFT")
                        color: wifiSubPanel.currentNet !== null ? PhantomState.secondary : PhantomState.muted
                        font.pixelSize: 9
                        font.weight: Font.Black
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    ListView {
                        id: wifiListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: PhantomState.wifiNetworks

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: wifiListView.width
                            height: 50
                            readonly property bool isSel: dashWin.selectedWifiIdx === index

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: parent.isSel ? PhantomState.primary : (modelData.inUse ? "#1A2228" : "#12131A")
                                borderColor: parent.isSel ? "#FFFFFF" : (modelData.inUse ? "#00F59B" : "#353545")
                                shadowColor: parent.isSel ? PhantomState.secondary : "#050508"
                                borderWidth: (parent.isSel || modelData.inUse) ? 2 : 1
                                skewPx: 6
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 10

                                // indikator panah kiri saat kartu jaringan dipilih
                                Rectangle {
                                    visible: parent.parent.isSel
                                    width: 24
                                    height: 22
                                    color: "#08090D"
                                    border.color: PhantomState.secondary
                                    border.width: 1.5
                                    rotation: 6

                                    P5Icon {
                                        anchors.centerIn: parent
                                        name: "chevron-left"
                                        size: 12
                                        color: PhantomState.secondary
                                    }
                                }

                                P5Icon {
                                    name: "wifi"
                                    size: 15
                                    color: modelData.inUse ? "#00F59B" : (parent.parent.isSel ? "#FFFFFF" : PhantomState.secondary)
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.ssid
                                        color: "#FFFFFF"
                                        font.pixelSize: 13
                                        font.weight: Font.Black
                                        font.italic: true
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: "SIGNAL " + modelData.signal + "% • " + modelData.security + ((modelData.saved && !modelData.inUse) ? " • SAVED" : "")
                                        color: parent.parent.parent.isSel ? "#08090D" : PhantomState.muted
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                        elide: Text.ElideRight
                                    }
                                }

                                Rectangle {
                                    visible: modelData.inUse
                                    width: 72
                                    height: 20
                                    color: "#00F59B"
                                    border.color: "#08090D"
                                    border.width: 1.5
                                    rotation: -3

                                    Text {
                                        anchors.centerIn: parent
                                        text: "★ LINKED"
                                        color: "#08090D"
                                        font.pixelSize: 8
                                        font.weight: Font.Black
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: dashWin.selectWifiCard(index, parent)
                                onDoubleClicked: {
                                    dashWin.animateRadialY = dashWin.radialOpen
                                    dashWin.clickedCardCenterY = parent.mapToItem(dashCard, 0, parent.height / 2).y
                                    dashWin.selectedWifiIdx = index
                                    if (!modelData.inUse) {
                                        PhantomState.connectWifi(modelData.ssid, "")
                                    }
                                }
                            }
                        }
                    }
                }

                // sub-panel daftar perangkat bluetooth
                ColumnLayout {
                    id: btSubPanel
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    visible: dashWin.subPanel === "bluetooth"

                    readonly property var currentBt: (dashWin.selectedBtIdx >= 0 && dashWin.selectedBtIdx < PhantomState.btDevices.length)
                        ? PhantomState.btDevices[dashWin.selectedBtIdx]
                        : null

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Item {
                            Layout.preferredWidth: 68
                            Layout.preferredHeight: 28

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.surfaceAlt
                                borderColor: "#FFFFFF"
                                shadowColor: PhantomState.primary
                                borderWidth: 1.5
                                skewPx: 5
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                P5Icon { name: "chevron-left"; size: 11; color: PhantomState.secondary; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "BACK"
                                    color: "#FFFFFF"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    font.italic: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    dashWin.selectedBtIdx = -1
                                    dashWin.showBtInfo = false
                                    dashWin.subPanel = "main"
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                Layout.fillWidth: true
                                text: "BLUETOOTH TACTICS // SELECT TARGET"
                                color: PhantomState.primary
                                font.pixelSize: 12
                                font.weight: Font.Black
                                font.italic: true
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: PhantomState.btStatusMsg !== ""
                                    ? PhantomState.btStatusMsg
                                    : ("STATUS: " + PhantomState.btDeviceName)
                                color: PhantomState.secondary
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                        }

                        Item {
                            Layout.preferredWidth: 62
                            Layout.preferredHeight: 26

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.btScanning ? PhantomState.primary : "#14151F"
                                borderColor: "#FFD700"
                                shadowColor: PhantomState.primary
                                borderWidth: 1.5
                                skewPx: 5
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                P5Icon { name: "scan"; size: 11; color: "#FFD700"; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: PhantomState.btScanning ? "..." : "SCAN"
                                    color: "#FFFFFF"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.italic: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.scanBluetooth()
                            }
                        }

                        Item {
                            Layout.preferredWidth: 58
                            Layout.preferredHeight: 26

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.btConnected ? "#0E2920" : "#221015"
                                borderColor: PhantomState.btConnected ? "#00F59B" : "#FF1E2E"
                                shadowColor: "#050508"
                                borderWidth: 1.5
                                skewPx: 5
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 4
                                P5Icon {
                                    name: "power"
                                    size: 11
                                    color: PhantomState.btConnected ? "#00F59B" : "#FF1E2E"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: PhantomState.btConnected ? "ON" : "OFF"
                                    color: "#FFFFFF"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.italic: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.setBluetoothPower(!PhantomState.btConnected)
                            }
                        }
                    }

                    // kartu ringkasan status perangkat bluetooth
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: "#12131C"
                            borderColor: dashWin.showBtInfo ? "#48CAE4" : "#353548"
                            shadowColor: PhantomState.primary
                            borderWidth: 1.5
                            skewPx: 6
                        }

                        GridLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            columns: 2
                            rowSpacing: 2
                            columnSpacing: 14

                            readonly property var inspectBt: (dashWin.showBtInfo && btSubPanel.currentBt)
                                ? btSubPanel.currentBt
                                : null

                            Text {
                                text: "DEVICE : " + (parent.inspectBt ? parent.inspectBt.name : PhantomState.btDeviceName)
                                color: "#FFFFFF"; font.pixelSize: 10; font.weight: Font.Black; elide: Text.ElideRight; Layout.fillWidth: true
                            }
                            Text {
                                text: "ADAPTER: " + (PhantomState.btConnected ? "POWERED ON" : "POWERED OFF")
                                color: PhantomState.secondary; font.pixelSize: 10; font.weight: Font.Black
                            }
                            Text {
                                text: "MAC    : " + (parent.inspectBt ? parent.inspectBt.mac : (PhantomState.btDeviceMac !== "" ? PhantomState.btDeviceMac : "N/A"))
                                color: "#48CAE4"; font.pixelSize: 10; font.weight: Font.Bold; Layout.columnSpan: 2
                            }
                        }
                    }

                    Text {
                        text: btSubPanel.currentBt !== null
                            ? ("◂ COMMAND MENU OPEN ON THE LEFT FOR: " + btSubPanel.currentBt.name.toUpperCase())
                            : ("BLUETOOTH DEVICES (" + PhantomState.btDevices.length + ") — CLICK A CARD TO POP OUT MENU ON THE LEFT")
                        color: btSubPanel.currentBt !== null ? PhantomState.secondary : PhantomState.muted
                        font.pixelSize: 9
                        font.weight: Font.Black
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Item {
                        id: btListContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Column {
                            anchors.centerIn: parent
                            spacing: 6
                            visible: PhantomState.btDevices.length === 0

                            P5Icon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                name: "bluetooth"
                                size: 28
                                color: PhantomState.primary
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: PhantomState.btScanning ? "SCANNING FOR DEVICES..." : "NO BLUETOOTH DEVICES FOUND"
                                color: "#FFFFFF"
                                font.pixelSize: 12
                                font.weight: Font.Black
                                font.italic: true
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Click 'SCAN' in the top right to search nearby devices."
                                color: PhantomState.muted
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }
                        }

                        ListView {
                            id: btListView
                            anchors.fill: parent
                            clip: true
                            spacing: 8
                            visible: PhantomState.btDevices.length > 0
                            model: PhantomState.btDevices

                            delegate: Item {
                                required property var modelData
                                required property int index
                                width: btListView.width
                                height: 50
                                readonly property bool isSel: dashWin.selectedBtIdx === index

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: parent.isSel ? PhantomState.primary : (modelData.connected ? "#1A2228" : "#12131A")
                                    borderColor: parent.isSel ? "#FFFFFF" : (modelData.connected ? "#00F59B" : "#353545")
                                    shadowColor: parent.isSel ? PhantomState.secondary : "#050508"
                                    borderWidth: (parent.isSel || modelData.connected) ? 2 : 1
                                    skewPx: 6
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 14
                                    anchors.rightMargin: 14
                                    spacing: 10

                                    Rectangle {
                                        visible: parent.parent.isSel
                                        width: 24
                                        height: 22
                                        color: "#08090D"
                                        border.color: PhantomState.secondary
                                        border.width: 1.5
                                        rotation: 6

                                        P5Icon {
                                            anchors.centerIn: parent
                                            name: "chevron-left"
                                            size: 12
                                            color: PhantomState.secondary
                                        }
                                    }

                                    P5Icon {
                                        name: "bluetooth"
                                        size: 15
                                        color: modelData.connected ? "#00F59B" : (parent.parent.isSel ? "#FFFFFF" : "#48CAE4")
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: "#FFFFFF"
                                            font.pixelSize: 13
                                            font.weight: Font.Black
                                            font.italic: true
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.mac + (modelData.paired ? " • PAIRED" : " • DISCOVERED")
                                            color: parent.parent.parent.isSel ? "#08090D" : PhantomState.muted
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        visible: modelData.connected
                                        width: 72
                                        height: 20
                                        color: "#00F59B"
                                        border.color: "#08090D"
                                        border.width: 1.5
                                        rotation: -3

                                        Text {
                                            anchors.centerIn: parent
                                            text: "★ LINKED"
                                            color: "#08090D"
                                            font.pixelSize: 8
                                            font.weight: Font.Black
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: dashWin.selectBtCard(index, parent)
                                    onDoubleClicked: {
                                        dashWin.animateRadialY = dashWin.radialOpen
                                        dashWin.clickedCardCenterY = parent.mapToItem(dashCard, 0, parent.height / 2).y
                                        dashWin.selectedBtIdx = index
                                        if (modelData.connected) PhantomState.disconnectBluetooth(modelData.mac, modelData.name)
                                        else PhantomState.connectBluetooth(modelData.mac, modelData.name)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // menu aksi radial melayang di sisi kiri kartu jaringan atau perangkat terpilih
            Item {
                id: leftRadialMenu
                property real openProgress: dashWin.radialOpen ? 1.0 : 0.0
                Behavior on openProgress {
                    NumberAnimation {
                        duration: dashWin.radialOpen ? 230 : 140
                        easing.type: dashWin.radialOpen ? Easing.OutBack : Easing.InCubic
                        easing.overshoot: 1.28
                    }
                }

                property real switchPulse: 1.0
                SequentialAnimation {
                    id: leftRadialSwitchAnim
                    NumberAnimation {
                        target: leftRadialMenu
                        property: "switchPulse"
                        from: 1.0
                        to: 0.90
                        duration: 55
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: leftRadialMenu
                        property: "switchPulse"
                        from: 0.90
                        to: 1.0
                        duration: 150
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.4
                    }
                }

                visible: openProgress > 0.005
                opacity: Math.max(0.0, Math.min(1.0, openProgress * 1.35))
                scale: (0.58 + 0.42 * openProgress) * switchPulse
                width: 296
                height: 244
                anchors.right: dashCard.left
                anchors.rightMargin: -6 - (1.0 - openProgress) * 28

                // posisi vertikal menu radial sejajar dengan titik tengah kartu terpilih
                readonly property real targetY: Math.max(6, Math.min(dashWin.height - height - 6, dashWin.clickedCardCenterY - height / 2))
                y: targetY
                Behavior on y {
                    enabled: dashWin.animateRadialY
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                transformOrigin: Item.Right

                // kanvas garis jarum penghubung dari kartu terpilih ke pangkal tiap bilah aksi
                Canvas {
                    id: leftRadialBurst
                    anchors.fill: parent
                    property color cPrimary: PhantomState.primary
                    property real apexY: Math.max(36, Math.min(height - 36, dashWin.clickedCardCenterY - leftRadialMenu.targetY))
                    onCPrimaryChanged: requestPaint()
                    onApexYChanged: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var cy = apexY

                        // titik koordinat pangkal kanan dari keempat bilah aksi
                        var tips = [
                            { x: w - 18, y: 34 },
                            { x: w - 6,  y: 92 },
                            { x: w - 6,  y: 150 },
                            { x: w - 18, y: 208 }
                        ]

                        for (var i = 0; i < tips.length; i++) {
                            // bayangan aksen garis penghubung
                            ctx.strokeStyle = cPrimary
                            ctx.lineWidth = 3.2
                            ctx.beginPath()
                            ctx.moveTo(w, cy + 1)
                            ctx.lineTo(tips[i].x, tips[i].y + 2)
                            ctx.stroke()

                            // garis inti putih penghubung
                            ctx.strokeStyle = "#FFFFFF"
                            ctx.lineWidth = 1.4
                            ctx.beginPath()
                            ctx.moveTo(w, cy)
                            ctx.lineTo(tips[i].x, tips[i].y)
                            ctx.stroke()
                        }

                        // simpul panah putih pada tepi kartu terpilih
                        ctx.fillStyle = "#FFFFFF"
                        ctx.beginPath()
                        ctx.moveTo(w, cy)
                        ctx.lineTo(w - 14, cy - 8)
                        ctx.lineTo(w - 10, cy)
                        ctx.lineTo(w - 14, cy + 8)
                        ctx.closePath()
                        ctx.fill()
                    }
                }

                // deretan empat bilah perintah aksi radial
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 4

                    // bilah aksi sambung atau putuskan koneksi
                    Item {
                        width: parent.width
                        height: 54

                        P5BattleBlade {
                            x: 12 + (1.0 - leftRadialMenu.openProgress) * 18
                            width: parent.width - 28
                            height: 54
                            tailOnRight: true
                            fanProgress: leftRadialMenu.openProgress
                            readonly property bool isWifiPanel: dashWin.subPanel === "wifi"
                            readonly property bool isTargetActive: isWifiPanel
                                ? (wifiSubPanel.currentNet ? wifiSubPanel.currentNet.inUse : false)
                                : (btSubPanel.currentBt ? btSubPanel.currentBt.connected : false)
                            title: isTargetActive ? "DISCONNECT" : "CONNECT"
                            subtitle: isWifiPanel
                                ? (wifiSubPanel.currentNet ? (isTargetActive ? ("Drop " + wifiSubPanel.currentNet.ssid) : ("Join " + wifiSubPanel.currentNet.ssid)) : "Select Network")
                                : (btSubPanel.currentBt ? (isTargetActive ? ("Unlink " + btSubPanel.currentBt.name) : ("Pair & Link " + btSubPanel.currentBt.name)) : "Select Device")
                            iconName: isWifiPanel ? "wifi" : "bluetooth"
                            badgeColor: "#00F59B"
                            active: isTargetActive
                            bladeTilt: 7.0
                            onClicked: {
                                if (dashWin.wifiRadialOpen) {
                                    var net = wifiSubPanel.currentNet
                                    if (!net) return
                                    if (net.inUse) {
                                        PhantomState.disconnectWifi(net.ssid)
                                    } else if (dashWin.showWifiPasswordBox && wifiPassField.text.length > 0) {
                                        PhantomState.connectWifi(net.ssid, wifiPassField.text)
                                        dashWin.showWifiPasswordBox = false
                                        wifiPassField.text = ""
                                    } else if (net.saved || net.security === "OPEN") {
                                        PhantomState.connectWifi(net.ssid, "")
                                    } else {
                                        dashWin.showWifiPasswordBox = true
                                        PhantomState.wifiStatusMsg = "TYPE PASSKEY ABOVE & PRESS ENTER"
                                        wifiPassField.forceActiveFocus()
                                    }
                                } else if (dashWin.btRadialOpen) {
                                    var dev = btSubPanel.currentBt
                                    if (!dev) return
                                    if (dev.connected) PhantomState.disconnectBluetooth(dev.mac, dev.name)
                                    else PhantomState.connectBluetooth(dev.mac, dev.name)
                                }
                            }
                        }
                    }

                    // bilah aksi informasi jaringan atau perangkat
                    Item {
                        width: parent.width
                        height: 54

                        P5BattleBlade {
                            x: 24 + (1.0 - leftRadialMenu.openProgress) * 10
                            width: parent.width - 28
                            height: 54
                            tailOnRight: true
                            fanProgress: leftRadialMenu.openProgress
                            readonly property bool isWifiPanel: dashWin.subPanel === "wifi"
                            title: isWifiPanel ? "NET INFO" : "DEV INFO"
                            subtitle: isWifiPanel
                                ? (dashWin.showWifiInfo ? "Showing Target Info" : "Inspect Signal & IP")
                                : (dashWin.showBtInfo ? "Showing MAC Dossier" : "Inspect MAC & State")
                            iconName: "info"
                            badgeColor: "#00F0FF"
                            active: isWifiPanel ? dashWin.showWifiInfo : dashWin.showBtInfo
                            bladeTilt: 2.2
                            onClicked: {
                                if (dashWin.wifiRadialOpen) dashWin.showWifiInfo = !dashWin.showWifiInfo
                                else if (dashWin.btRadialOpen) dashWin.showBtInfo = !dashWin.showBtInfo
                            }
                        }
                    }

                    // bilah aksi kata sandi wi-fi atau pemindaian bluetooth
                    Item {
                        width: parent.width
                        height: 54

                        P5BattleBlade {
                            x: 24 + (1.0 - leftRadialMenu.openProgress) * 10
                            width: parent.width - 28
                            height: 54
                            tailOnRight: true
                            fanProgress: leftRadialMenu.openProgress
                            readonly property bool isWifiPanel: dashWin.subPanel === "wifi"
                            title: isWifiPanel ? "PASSKEY" : "SCAN BT"
                            subtitle: isWifiPanel
                                ? (dashWin.showWifiPasswordBox ? "Hide Password Box" : "Enter Wi-Fi Password")
                                : (PhantomState.btScanning ? "Searching Nearby..." : "Refresh Device List")
                            iconName: isWifiPanel ? "lock" : "scan"
                            badgeColor: "#FFD700"
                            active: isWifiPanel ? dashWin.showWifiPasswordBox : PhantomState.btScanning
                            bladeTilt: -2.2
                            onClicked: {
                                if (dashWin.wifiRadialOpen) dashWin.showWifiPasswordBox = !dashWin.showWifiPasswordBox
                                else if (dashWin.btRadialOpen) PhantomState.scanBluetooth()
                            }
                        }
                    }

                    // bilah aksi tutup menu radial
                    Item {
                        width: parent.width
                        height: 54

                        P5BattleBlade {
                            x: 12 + (1.0 - leftRadialMenu.openProgress) * 18
                            width: parent.width - 28
                            height: 54
                            tailOnRight: true
                            fanProgress: leftRadialMenu.openProgress
                            title: "CANCEL"
                            subtitle: "Close Command Menu"
                            iconName: "close"
                            badgeColor: "#FF1E2E"
                            active: false
                            bladeTilt: -7.0
                            onClicked: {
                                dashWin.selectedWifiIdx = -1
                                dashWin.selectedBtIdx = -1
                                dashWin.showWifiInfo = false
                                dashWin.showBtInfo = false
                                dashWin.showWifiPasswordBox = false
                            }
                        }
                    }
                }
            }
        }
    }
}
