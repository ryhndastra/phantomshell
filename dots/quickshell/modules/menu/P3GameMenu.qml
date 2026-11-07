import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtMultimedia
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

// Menu Game Otentik Persona 3 Reload - Pause & Tactical System Menu (Resume.mp4 Engine)
Scope {
    id: p3MenuScope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: p3MenuWin
            required property ShellScreen modelData
            screen: modelData
            visible: PhantomState.dashboardOpen && PhantomState.isP3

            WlrLayershell.namespace: "phantomshell-p3menu"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            exclusiveZone: 0

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            color: "transparent"

            property int activeCard: PhantomState.p3MenuCard
            onActiveCardChanged: {
                if (PhantomState.p3MenuCard !== activeCard) PhantomState.p3MenuCard = activeCard
            }
            property bool contentVisible: false
            property bool canDismiss: false

            Component.onCompleted: {
                console.log("[P3MENU DEBUG] PanelWindow created, screen=" + modelData + ", visible=" + visible + ", dashboardOpen=" + PhantomState.dashboardOpen + ", isP3=" + PhantomState.isP3)
            }
            onVisibleChanged: {
                console.log("[P3MENU DEBUG] onVisibleChanged: " + visible)
                if (visible) {
                    p3MenuWin.canDismiss = false
                    p3MenuWin.contentVisible = false
                    p3MenuWin.activeCard = 0

                    resumeVideo.seek(0)
                    resumeVideo.play()

                    wipeAnim.restart()
                    delayTimer.restart()
                    dismissArmTimer.restart()
                    PhantomState.refreshWifi()
                    PhantomState.refreshBluetooth()
                    keyCatcher.forceActiveFocus()
                } else {
                    wipeAnim.stop()
                    resumeVideo.stop()
                    p3MenuWin.contentVisible = false
                    p3MenuWin.canDismiss = false
                }
            }

            Timer {
                id: dismissArmTimer
                interval: 400
                repeat: false
                onTriggered: p3MenuWin.canDismiss = true
            }

            Timer {
                id: delayTimer
                interval: 650
                repeat: false
                onTriggered: {
                    p3MenuWin.contentVisible = true
                }
            }

        // ── Dasar Samudra Pekat (Mencegah Layar Ngeblink / Tembus Desktop) ──
        Rectangle {
            anchors.fill: parent
            color: "#02071a"
            z: 0
        }

        // ── Video Latar Menu Taktis Asli Persona 3 Reload (Resume.mp4 Engine) ──
        Video {
            id: resumeVideo
            anchors.fill: parent
            source: Qt.resolvedUrl("../../assets/themes/p3/videos/Resume.mp4")
            fillMode: VideoOutput.PreserveAspectCrop
            loops: MediaPlayer.Infinite
            volume: 0
            z: 1

            // Overlay gradasi biru samudra tipis agar teks selalu terbaca kontras
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(4/255, 10/255, 30/255, 0.15)
            }
        }

        // ── Efek Wipe Transisi Biru S.E.E.S. Khas Persona 3 Reload ──
        Item {
            id: wipeLayer
            anchors.fill: parent
            z: 99
            visible: wipeScale3.xScale > 0.001

            Rectangle {
                id: wipeBlock1
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: parent.width
                color: "#071330"
                transformOrigin: Item.Left
                transform: Scale { id: wipeScale1; xScale: 0 }
            }
            Rectangle {
                id: wipeBlock2
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: parent.width
                color: "#0048cc"
                transformOrigin: Item.Left
                transform: Scale { id: wipeScale2; xScale: 0 }
            }
            Rectangle {
                id: wipeBlock3
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: parent.width
                color: "#00dbff"
                transformOrigin: Item.Left
                transform: Scale { id: wipeScale3; xScale: 0 }
            }

            SequentialAnimation {
                id: wipeAnim
                running: false
                ParallelAnimation {
                    NumberAnimation { target: wipeScale1; property: "xScale"; from: 0; to: 1; duration: 220; easing.type: Easing.OutQuart }
                    NumberAnimation { target: wipeScale2; property: "xScale"; from: 0; to: 1; duration: 260; easing.type: Easing.OutQuart }
                    NumberAnimation { target: wipeScale3; property: "xScale"; from: 0; to: 1; duration: 300; easing.type: Easing.OutQuart }
                }
                PauseAnimation { duration: 60 }
                ParallelAnimation {
                    NumberAnimation { target: wipeScale1; property: "xScale"; from: 1; to: 0; duration: 220; easing.type: Easing.InQuart }
                    NumberAnimation { target: wipeScale2; property: "xScale"; from: 1; to: 0; duration: 260; easing.type: Easing.InQuart }
                    NumberAnimation { target: wipeScale3; property: "xScale"; from: 1; to: 0; duration: 300; easing.type: Easing.InQuart }
                }
            }
        }

        // ── Penangkap Navigasi Papan Ketik ──
        Item {
            id: keyCatcher
            anchors.fill: parent
            focus: p3MenuWin.visible

            Keys.onPressed: event => {
                console.log("[KEY DEBUG] Keys.onPressed key=" + event.key + " (Qt.Key_Escape is " + Qt.Key_Escape + ") canDismiss=" + p3MenuWin.canDismiss)
                if (event.key === Qt.Key_Escape) {
                    if (!p3MenuWin.canDismiss) {
                        console.log("[KEY DEBUG] Escape ignored because canDismiss is false")
                        event.accepted = true
                        return
                    }
                    console.log("[KEY DEBUG] Escape accepted! closing dashboard")
                    PhantomState.dashboardOpen = false
                    event.accepted = true
                } else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                    p3MenuWin.activeCard = (p3MenuWin.activeCard + 5 - 1) % 5
                    PhantomState.playSfx("select")
                    event.accepted = true
                } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J || event.key === Qt.Key_Tab) {
                    p3MenuWin.activeCard = (p3MenuWin.activeCard + 1) % 5
                    PhantomState.playSfx("select")
                    event.accepted = true
                } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_5) {
                    p3MenuWin.activeCard = event.key - Qt.Key_1
                    PhantomState.playSfx("select")
                    event.accepted = true
                }
            }
        }

        // ── Konten Menu Taktis Persona 3 Reload ──
        Item {
            id: contentContainer
            anchors.fill: parent
            z: 10
            opacity: p3MenuWin.contentVisible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

            // Klik latar kosong untuk menutup menu
            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: PhantomState.dashboardOpen = false
            }

            // ── Sisi Kiri: Daftar Kartu Taktis Persona ("LIST") ──
            Column {
                anchors {
                    left: parent.left
                    leftMargin: Math.max(32, parent.width * 0.04)
                    top: parent.top
                    topMargin: Math.max(48, parent.height * 0.08)
                }
                spacing: 8

                // Header LIST tipografi besar khas Persona 3
                Row {
                    spacing: 12
                    Text {
                        text: "LIST"
                        font.family: "Inter Display"
                        font.pixelSize: 68
                        font.weight: Font.Black
                        color: "#f6fbff"
                        style: Text.Raised
                        styleColor: "#05164d"
                    }

                    Rectangle {
                        width: 140
                        height: 24
                        radius: 4
                        color: "#002c90"
                        border.color: "#00dbff"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: "S.E.E.S. // TACTICAL"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Black
                            color: "#00dbff"
                        }
                    }
                }

                // Pengulang 5 Kartu Utama
                Repeater {
                    model: [
                        {
                            badge: "I",
                            title: "STATS",
                            subtitle: "System Hardware & Social Telemetry",
                            rank: 5
                        },
                        {
                            badge: "II",
                            title: "NETWORK",
                            subtitle: "Wi-Fi & Tatsumi Grid Links",
                            rank: 4
                        },
                        {
                            badge: "III",
                            title: "BLUETOOTH",
                            subtitle: "Wireless Evokers & Audio Devices",
                            rank: 3
                        },
                        {
                            badge: "IV",
                            title: "PALETTE",
                            subtitle: "Era Switching & Metaverse Colors",
                            rank: 2
                        },
                        {
                            badge: "V",
                            title: "DISPATCH",
                            subtitle: "Power Controls & Sector Logout",
                            rank: 1
                        }
                    ]

                    delegate: Item {
                        id: cardWrap
                        required property var modelData
                        required property int index

                        readonly property bool isActive: p3MenuWin.activeCard === index
                        width: Math.min(640, contentContainer.width * 0.44)
                        height: isActive ? 122 : 98
                        x: isActive ? 12 : 0

                        layer.enabled: true
                        layer.smooth: true
                        layer.samples: 4

                        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                        // Geometri Trapesium Miring Persona 3 Reload
                        Canvas {
                            id: cardCanvas
                            anchors.fill: parent
                            antialiasing: true
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width
                                var h = height

                                ctx.beginPath()
                                ctx.moveTo(0, 0)
                                ctx.lineTo(w * 0.97, 0)
                                ctx.lineTo(w, h)
                                ctx.lineTo(w * 0.03, h)
                                ctx.closePath()
                                ctx.fillStyle = cardWrap.isActive ? "#8df6ff" : "rgba(12, 22, 85, 0.90)"
                                ctx.fill()

                                // Garis batas halus
                                ctx.lineWidth = cardWrap.isActive ? 2 : 1
                                ctx.strokeStyle = cardWrap.isActive ? "#00dbff" : "rgba(0, 219, 255, 0.35)"
                                ctx.stroke()

                                // Bayangan potongan miring bawah
                                ctx.beginPath()
                                ctx.moveTo(w * 0.03, h)
                                ctx.lineTo(w, h)
                                ctx.lineTo(w + 8, h + 6)
                                ctx.lineTo(w * 0.03 + 8, h + 6)
                                ctx.closePath()
                                ctx.fillStyle = cardWrap.isActive ? "rgba(0, 219, 255, 0.45)" : "rgba(4, 9, 36, 0.7)"
                                ctx.fill()
                            }
                            onWidthChanged: requestPaint()
                            onHeightChanged: requestPaint()
                            Connections {
                                target: cardWrap
                                function onIsActiveChanged() { cardCanvas.requestPaint() }
                            }
                        }

                        // Lencana Angka Romawi Miring di Sisi Kiri
                        Rectangle {
                            x: -6
                            y: 8
                            width: 44
                            height: 54
                            color: cardWrap.isActive ? "#061230" : "#0a1848"
                            border.color: cardWrap.isActive ? "#000000" : "#00dbff"
                            border.width: 2
                            radius: 2
                            rotation: -8
                            antialiasing: true

                            Text {
                                anchors.centerIn: parent
                                text: cardWrap.modelData.badge
                                font.family: "Inter Display"
                                font.pixelSize: 24
                                font.weight: Font.Black
                                color: cardWrap.isActive ? "#00dbff" : "#d2fdff"
                                rotation: 8
                                renderType: Text.CurveRendering
                            }
                        }

                        // Judul Kartu Besar
                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 54
                                top: parent.top
                                topMargin: 10
                            }
                            text: cardWrap.modelData.title
                            font.family: "Inter Display"
                            font.pixelSize: 38
                            font.weight: Font.Black
                            color: cardWrap.isActive ? "#041235" : "#a5f6ff"
                        }

                        // Label Rank S.E.E.S. di Sisi Kanan
                        Row {
                            anchors {
                                right: parent.right
                                rightMargin: 24
                                top: parent.top
                                topMargin: 10
                            }
                            spacing: 6
                            Text {
                                text: "RANK"
                                font.family: "Inter Display"
                                font.pixelSize: 16
                                font.weight: Font.Black
                                color: cardWrap.isActive ? "#061845" : "#9ffbff"
                                anchors.bottom: parent.bottom
                                bottomPadding: 6
                            }
                            Text {
                                text: cardWrap.modelData.rank
                                font.family: "Inter Display"
                                font.pixelSize: 46
                                font.weight: Font.Black
                                color: cardWrap.isActive ? "#061845" : "#9ffbff"
                            }
                        }

                        // Pita Subtitle di Bagian Bawah Kartu
                        Canvas {
                            id: subCanvas
                            anchors {
                                left: parent.left
                                leftMargin: 56
                                right: parent.right
                                rightMargin: 18
                                bottom: parent.bottom
                                bottomMargin: 8
                            }
                            height: 26
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width
                                var h = height
                                ctx.beginPath()
                                ctx.moveTo(0, 0)
                                ctx.lineTo(w, 0)
                                ctx.lineTo(w - 8, h)
                                ctx.lineTo(0, h)
                                ctx.closePath()
                                ctx.fillStyle = cardWrap.isActive ? "#061230" : "#00dbff"
                                ctx.fill()
                            }
                            onWidthChanged: requestPaint()
                            Connections {
                                target: cardWrap
                                function onIsActiveChanged() { subCanvas.requestPaint() }
                            }

                            Text {
                                anchors {
                                    fill: parent
                                    leftMargin: 12
                                }
                                text: cardWrap.modelData.subtitle
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: cardWrap.isActive ? "#00dbff" : "#041238"
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                if (p3MenuWin.activeCard !== cardWrap.index) {
                                    p3MenuWin.activeCard = cardWrap.index
                                    PhantomState.playSfx("select")
                                }
                            }
                            onClicked: {
                                p3MenuWin.activeCard = cardWrap.index
                                PhantomState.playSfx("select")
                            }
                        }
                    }
                }
            }

            // ── Sisi Kanan: Panel Detail Taktis S.E.E.S. (detailPanel) ──
            Item {
                id: detailPanel
                anchors {
                    right: parent.right
                    rightMargin: Math.max(32, parent.width * 0.04)
                    top: parent.top
                    topMargin: Math.max(48, parent.height * 0.08)
                }
                width: Math.min(620, contentContainer.width * 0.45)
                height: Math.min(parent.height * 0.80, 780)

                // Latar Belakang Kartu Kaca Biru Samudra Bergradasi
                Canvas {
                    id: panelBg
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var h = height

                        ctx.beginPath()
                        ctx.moveTo(0, 0)
                        ctx.lineTo(w, 0)
                        ctx.lineTo(w - 18, h)
                        ctx.lineTo(0, h)
                        ctx.closePath()
                        var grad = ctx.createLinearGradient(0, 0, 0, h)
                        grad.addColorStop(0, "rgba(12, 24, 92, 0.94)")
                        grad.addColorStop(1, "rgba(6, 12, 45, 0.97)")
                        ctx.fillStyle = grad
                        ctx.fill()

                        ctx.lineWidth = 1.5
                        ctx.strokeStyle = "rgba(0, 219, 255, 0.45)"
                        ctx.stroke()
                    }
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                }

                // Header Slanted Detail Panel
                Canvas {
                    id: detailHeader
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    height: 64

                    property var sectionTitles: [
                        "SYSTEM STATS // TELEMETRY",
                        "NETWORK // TATSUMI GRID",
                        "BLUETOOTH // WIRELESS LINKS",
                        "PALETTE // METAVERSE ERAS",
                        "DISPATCH // S.E.E.S. LOGOUT"
                    ]
                    property string titleText: sectionTitles[p3MenuWin.activeCard] || "DETAIL"
                    property string indexText: "0" + (p3MenuWin.activeCard + 1)

                    onTitleTextChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var h = height

                        ctx.beginPath()
                        ctx.moveTo(0, 0)
                        ctx.lineTo(w, 0)
                        ctx.lineTo(w - 14, h)
                        ctx.lineTo(0, h)
                        ctx.closePath()
                        var grad = ctx.createLinearGradient(0, 0, w, 0)
                        grad.addColorStop(0, "#8df6ff")
                        grad.addColorStop(1, "#cbf8ff")
                        ctx.fillStyle = grad
                        ctx.fill()
                    }

                    Row {
                        anchors {
                            fill: parent
                            leftMargin: 20
                            rightMargin: 20
                        }
                        spacing: 12
                        Text {
                            text: detailHeader.indexText
                            font.family: "Inter Display"
                            font.pixelSize: 28
                            font.weight: Font.Black
                            color: "#061845"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: detailHeader.titleText
                            font.family: "Inter Display"
                            font.pixelSize: 18
                            font.weight: Font.Black
                            color: "#061845"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // ── Konten Kontrol Dinamis Berdasarkan Tab Terpilih ──
                Item {
                    id: detailPanelContent
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: detailHeader.bottom
                        bottom: parent.bottom
                        margins: 18
                    }

                    transform: Translate {
                        id: tabTranslate
                        x: 0
                    }
                    opacity: 1.0

                    Connections {
                        target: p3MenuWin
                        function onActiveCardChanged() {
                            tabSlideAnim.restart()
                        }
                    }

                    ParallelAnimation {
                        id: tabSlideAnim
                        NumberAnimation {
                            target: tabTranslate
                            property: "x"
                            from: 35
                            to: 0
                            duration: 260
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: detailPanelContent
                            property: "opacity"
                            from: 0.3
                            to: 1.0
                            duration: 220
                            easing.type: Easing.OutQuad
                        }
                    }

                    // ── TAB 0: SYSTEM STATS ──
                    ColumnLayout {
                        anchors.fill: parent
                        visible: p3MenuWin.activeCard === 0
                        spacing: 12

                        // Banner Info Sistem
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 46
                            radius: 6
                            color: Qt.rgba(0/255, 44/255, 144/255, 0.35)
                            border.color: "#00dbff"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                Text {
                                    text: "HOST: " + PhantomState.sysHost.toUpperCase()
                                    color: "#ffffff"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "UPTIME: " + PhantomState.sysUptime
                                    color: "#00dbff"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        // Bar Metrik Hardware
                        Repeater {
                            model: [
                                { label: "CPU", val: PhantomState.cpuPct, text: PhantomState.cpuPct + "%", sub: PhantomState.sysCpuModel },
                                { label: "RAM", val: PhantomState.ramPct, text: PhantomState.sysRamText, sub: "Memory Allocation" },
                                { label: "GPU", val: PhantomState.gpuPct, text: PhantomState.gpuPct + "%", sub: PhantomState.sysGpuModel },
                                { label: "BATTERY", val: PhantomState.batteryPct, text: PhantomState.batteryPct + "%", sub: "Power Cell Capacity" },
                                { label: "TEMP", val: Math.min(100, PhantomState.tempPct), text: PhantomState.tempPct + "°C", sub: "Thermal Status" }
                            ]

                            delegate: Item {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 64

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 6
                                    color: Qt.rgba(8/255, 18/255, 64/255, 0.7)
                                    border.color: Qt.rgba(0/255, 219/255, 255/255, 0.25)
                                    border.width: 1
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 4

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: modelData.label
                                            font.family: "Inter Display"
                                            font.pixelSize: 13
                                            font.weight: Font.Black
                                            color: "#ffffff"
                                        }
                                        Text {
                                            text: modelData.sub
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            color: PhantomState.muted
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                            Layout.leftMargin: 8
                                        }
                                        Text {
                                            text: modelData.text
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 12
                                            font.weight: Font.Black
                                            color: "#00dbff"
                                        }
                                    }

                                    // Bar Indikator P3 Cyan
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 6
                                        radius: 3
                                        color: Qt.rgba(0, 0, 0, 0.4)

                                        Rectangle {
                                            width: parent.width * Math.max(0.02, Math.min(1.0, modelData.val / 100.0))
                                            height: parent.height
                                            radius: 3
                                            color: modelData.val > 88 ? "#ff3355" : "#00dbff"
                                        }
                                    }
                                }
                            }
                        }

                        // Baris Sakelar Taktis Protokol S.E.E.S.
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            // Toggle Cava Visualizer
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 38
                                radius: 4
                                color: PhantomState.showDesktopCava ? Qt.rgba(0/255, 219/255, 255/255, 0.2) : "#081330"
                                border.color: PhantomState.showDesktopCava ? "#00dbff" : "#1a3d80"
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "CAVA // " + (PhantomState.showDesktopCava ? "ON" : "OFF")
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        font.weight: Font.Black
                                        color: PhantomState.showDesktopCava ? "#00dbff" : "#7aa2d6"
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("select")
                                        PhantomState.showDesktopCava = !PhantomState.showDesktopCava
                                        PhantomState.saveState()
                                    }
                                }
                            }

                            // Toggle Parallax
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 38
                                radius: 4
                                color: PhantomState.showWallpaperLayer ? Qt.rgba(0/255, 219/255, 255/255, 0.2) : "#081330"
                                border.color: PhantomState.showWallpaperLayer ? "#00dbff" : "#1a3d80"
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "PARALLAX // " + (PhantomState.showWallpaperLayer ? "ON" : "OFF")
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        font.weight: Font.Black
                                        color: PhantomState.showWallpaperLayer ? "#00dbff" : "#7aa2d6"
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("select")
                                        PhantomState.showWallpaperLayer = !PhantomState.showWallpaperLayer
                                        PhantomState.saveState()
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }

                    // ── TAB 1: NETWORK GRID ──
                    ColumnLayout {
                        anchors.fill: parent
                        visible: p3MenuWin.activeCard === 1
                        spacing: 12

                        // Kartu Wi-Fi Aktif
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 62
                            radius: 6
                            color: Qt.rgba(0/255, 44/255, 144/255, 0.4)
                            border.color: "#00dbff"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 10

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: PhantomState.wifiConnected ? "CONNECTED: " + PhantomState.wifiSsid : "WI-FI DISCONNECTED"
                                        color: "#ffffff"
                                        font.family: "Inter Display"
                                        font.pixelSize: 13
                                        font.weight: Font.Black
                                    }
                                    Text {
                                        text: "IP: " + (PhantomState.wifiIp || "No IP") + " • SIGNAL: " + PhantomState.wifiSignal + "%"
                                        color: "#00dbff"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 84
                                    Layout.preferredHeight: 28
                                    radius: 4
                                    color: scanMouse.containsMouse ? "#00dbff" : "#002c90"
                                    border.color: "#00dbff"
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "RESCAN"
                                        color: scanMouse.containsMouse ? "#000" : "#fff"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        font.weight: Font.Black
                                    }
                                    MouseArea {
                                        id: scanMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.playSfx("select")
                                            PhantomState.scanWifi()
                                        }
                                    }
                                }
                            }
                        }

                        // Daftar Jaringan Wi-Fi Sekitar
                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 8
                            model: PhantomState.wifiNetworks

                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                height: 48
                                radius: 6
                                color: Qt.rgba(8/255, 18/255, 64/255, 0.75)
                                border.color: Qt.rgba(0/255, 219/255, 255/255, 0.3)
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.ssid || "Unknown Network"
                                        font.family: "Inter Display"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        color: "#ffffff"
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: (modelData.strength || "0") + "%"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        color: "#00dbff"
                                    }
                                }
                            }
                        }
                    }

                    // ── TAB 2: BLUETOOTH LINKS ──
                    ColumnLayout {
                        anchors.fill: parent
                        visible: p3MenuWin.activeCard === 2
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            radius: 6
                            color: Qt.rgba(0/255, 44/255, 144/255, 0.4)
                            border.color: "#00dbff"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 10
                                Text {
                                    Layout.fillWidth: true
                                    text: PhantomState.btConnected ? "CONNECTED: " + PhantomState.btDeviceName : "BLUETOOTH STANDBY"
                                    color: "#ffffff"
                                    font.family: "Inter Display"
                                    font.pixelSize: 13
                                    font.weight: Font.Black
                                }
                                Rectangle {
                                    Layout.preferredWidth: 84
                                    Layout.preferredHeight: 28
                                    radius: 4
                                    color: btScanMouse.containsMouse ? "#00dbff" : "#002c90"
                                    border.color: "#00dbff"
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: "REFRESH"
                                        color: btScanMouse.containsMouse ? "#000" : "#fff"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        font.weight: Font.Black
                                    }
                                    MouseArea {
                                        id: btScanMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.playSfx("select")
                                            PhantomState.scanBluetooth()
                                        }
                                    }
                                }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 8
                            model: PhantomState.btDevices

                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                height: 48
                                radius: 6
                                color: Qt.rgba(8/255, 18/255, 64/255, 0.75)
                                border.color: Qt.rgba(0/255, 219/255, 255/255, 0.3)
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name || "Bluetooth Device"
                                        font.family: "Inter Display"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        color: "#ffffff"
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: modelData.connected ? "CONNECTED" : (modelData.paired ? "PAIRED" : "FOUND")
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        color: modelData.connected ? "#00dbff" : PhantomState.muted
                                    }
                                }
                            }
                        }
                    }

                    // ── TAB 3: PALETTE & ERAS (ERA SWITCHER WITH HERO CHARACTER CARDS) ──
                    ColumnLayout {
                        anchors.fill: parent
                        visible: p3MenuWin.activeCard === 3
                        spacing: 10

                        Text {
                            text: "METAVERSE CHRONICLE // SELECT ACTIVE TIMELINE"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Black
                            color: "#00dbff"
                        }

                        // 3 Kartu Pahlawan Persona dengan Gambar Karakter Otentik (char1, char2, char3)
                        Repeater {
                            model: [
                                {
                                    id: "p3-reload",
                                    name: "PERSONA 3 RELOAD",
                                    role: "LEADER",
                                    desc: "Makoto Yuki // Tartarus Oceanic Modernism",
                                    charImg: Qt.resolvedUrl("../../assets/themes/p3/components/char1.png"),
                                    accent: "#00dbff",
                                    bgGrad: "#0048cc"
                                },
                                {
                                    id: "p5-crimson",
                                    name: "PERSONA 5 CRIMSON",
                                    role: "TRICKSTER",
                                    desc: "Ren Amamiya // Metaverse Punk Rebellion",
                                    charImg: Qt.resolvedUrl("../../assets/themes/p3/components/char2.png"),
                                    accent: "#ff2a4b",
                                    bgGrad: "#990014"
                                },
                                {
                                    id: "p4-golden",
                                    name: "PERSONA 4 GOLDEN",
                                    role: "SEEKER",
                                    desc: "Yu Narukami // Yasogami Retro Amber Investigation",
                                    charImg: Qt.resolvedUrl("../../assets/themes/p3/components/char3.png"),
                                    accent: "#f5b800",
                                    bgGrad: "#997300"
                                }
                            ]

                            delegate: Item {
                                id: charCard
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: isSelected ? 86 : 74
                                Behavior on Layout.preferredHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                                readonly property bool isSelected: PhantomState.themeId === modelData.id
                                readonly property bool isHovered: charMouse.containsMouse

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 6
                                    clip: true
                                    color: charCard.isSelected
                                        ? Qt.rgba(0/255, 20/255, 60/255, 0.90)
                                        : (charCard.isHovered ? Qt.rgba(12/255, 26/255, 78/255, 0.85) : Qt.rgba(6/255, 14/255, 46/255, 0.80))
                                    border.color: charCard.isSelected ? modelData.accent : (charCard.isHovered ? "#ffffff" : Qt.rgba(0/255, 219/255, 255/255, 0.3))
                                    border.width: charCard.isSelected ? 2 : 1

                                    // Latar belakang gradasi miring aksen karakter
                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: parent.width * 0.45
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: "transparent" }
                                            GradientStop { position: 1.0; color: Qt.rgba(charCard.isSelected ? 0.25 : 0.12, 0.4, 0.8, 0.3) }
                                        }
                                    }

                                    // Gambar Karakter Pahlawan (char1, char2, char3) Terpotong Rapi
                                    Image {
                                        anchors.right: parent.right
                                        anchors.rightMargin: -20
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 190
                                        height: parent.height + 20
                                        source: modelData.charImg
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        opacity: charCard.isSelected ? 1.0 : (charCard.isHovered ? 0.9 : 0.6)
                                        scale: charCard.isHovered ? 1.05 : 1.0
                                        Behavior on opacity { NumberAnimation { duration: 180 } }
                                        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                                    }

                                    // Konten Teks & Label Karakter
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 14

                                        // Badge Role Angled
                                        Rectangle {
                                            Layout.preferredWidth: 42
                                            Layout.preferredHeight: 42
                                            radius: 4
                                            color: charCard.isSelected ? modelData.accent : "#030a20"
                                            border.color: modelData.accent
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.role.substring(0, 3)
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 11
                                                font.weight: Font.Black
                                                color: charCard.isSelected ? "#020718" : modelData.accent
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Text {
                                                text: modelData.name
                                                font.family: "Inter Display"
                                                font.pixelSize: 14
                                                font.weight: Font.Black
                                                color: charCard.isSelected ? modelData.accent : "#ffffff"
                                            }
                                            Text {
                                                text: modelData.desc
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                font.weight: Font.Bold
                                                color: "#8df6ff"
                                                opacity: 0.85
                                            }
                                        }

                                        // Tombol Status Seleksi
                                        Rectangle {
                                            Layout.preferredWidth: 84
                                            Layout.preferredHeight: 28
                                            radius: 3
                                            color: charCard.isSelected ? modelData.accent : "transparent"
                                            border.color: modelData.accent
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: charCard.isSelected ? "ACTIVE ✓" : "ACTIVATE"
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 10
                                                font.weight: Font.Black
                                                color: charCard.isSelected ? "#020718" : modelData.accent
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: charMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.playSfx("select")
                                            PhantomState.applyPreset(modelData.id)
                                        }
                                    }
                                }
                            }
                        }

                        // Garis Pemisah untuk Preset Tambahan
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Qt.rgba(0/255, 219/255, 255/255, 0.25)
                        }

                        // Preset Tambahan (Kasumi, Akechi, Futaba)
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: [
                                    { id: "kasumi-violet", name: "Kasumi Violet", color: "#9B5DE5" },
                                    { id: "akechi-crow", name: "Akechi Crow", color: "#C2A649" },
                                    { id: "futaba-matrix", name: "Futaba Matrix", color: "#00F59B" }
                                ]
                                delegate: Item {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 38

                                    readonly property bool isSelected: PhantomState.themeId === modelData.id
                                    readonly property bool isHovered: subMouse.containsMouse

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        color: isSelected ? Qt.rgba(1,1,1,0.15) : (isHovered ? Qt.rgba(1,1,1,0.08) : "#081330")
                                        border.color: isSelected ? modelData.color : Qt.rgba(255,255,255,0.2)
                                        border.width: isSelected ? 2 : 1

                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: 6
                                            Rectangle {
                                                width: 10; height: 10
                                                radius: 5
                                                color: modelData.color
                                            }
                                            Text {
                                                text: modelData.name
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                                color: isSelected ? "#ffffff" : "#c0d0e8"
                                            }
                                        }

                                        MouseArea {
                                            id: subMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                PhantomState.playSfx("select")
                                                PhantomState.applyPreset(modelData.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }

                    // ── TAB 4: DISPATCH / POWER ──
                    ColumnLayout {
                        anchors.fill: parent
                        visible: p3MenuWin.activeCard === 4
                        spacing: 10

                        Repeater {
                            model: [
                                { label: "LOCK SCREEN", sub: "Seal S.E.E.S. workstation", icon: "", p3Icon: "", cmd: "lock" },
                                { label: "SUSPEND", sub: "Enter low-power standby", icon: "", p3Icon: "", cmd: "suspend" },
                                { label: "LOGOUT", sub: "Terminate Wayland session", icon: "", p3Icon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/logout.png"), cmd: "logout" },
                                { label: "REBOOT", sub: "Restart operating system", icon: "", p3Icon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/restart.png"), cmd: "reboot" },
                                { label: "POWER OFF", sub: "Safely shutdown system", icon: "", p3Icon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/shutdown.png"), cmd: "poweroff" }
                            ]

                            delegate: Item {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56

                                readonly property bool isHovered: dMouse.containsMouse

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 6
                                    color: isHovered 
                                        ? Qt.rgba(0/255, 219/255, 255/255, 0.25)
                                        : Qt.rgba(8/255, 18/255, 64/255, 0.75)
                                    border.color: isHovered ? "#00dbff" : Qt.rgba(0/255, 219/255, 255/255, 0.3)
                                    border.width: isHovered ? 2 : 1
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Image {
                                        visible: modelData.p3Icon !== ""
                                        source: modelData.p3Icon || ""
                                        width: 32
                                        height: 32
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                    }

                                    Rectangle {
                                        visible: modelData.p3Icon === ""
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: Qt.rgba(0/255, 44/255, 144/255, 0.6)
                                        border.color: "#00dbff"
                                        border.width: 1
                                        P5Icon {
                                            anchors.centerIn: parent
                                            name: modelData.cmd === "lock" ? "lock" : "moon"
                                            size: 16
                                            color: "#00dbff"
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: modelData.label
                                            font.family: "Inter Display"
                                            font.pixelSize: 14
                                            font.weight: Font.Black
                                            color: "#ffffff"
                                        }
                                        Text {
                                            text: modelData.sub
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            color: PhantomState.muted
                                        }
                                    }

                                    Text {
                                        text: "EXECUTE ↗"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        font.weight: Font.Black
                                        color: isHovered ? "#00dbff" : PhantomState.muted
                                    }
                                }

                                MouseArea {
                                    id: dMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("select")
                                        PhantomState.dashboardOpen = false
                                        if (modelData.cmd === "lock") PhantomState.lockScreen()
                                        else if (modelData.cmd === "suspend") Quickshell.execDetached(["systemctl", "suspend"])
                                        else if (modelData.cmd === "logout") Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
                                        else if (modelData.cmd === "reboot") Quickshell.execDetached(["systemctl", "reboot"])
                                        else if (modelData.cmd === "poweroff") Quickshell.execDetached(["systemctl", "poweroff"])
                                    }
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }

            // ── Baris Bawah Layar Penuh: HUD Taktis & Tombol Pintasan Persona 3 Reload ──
            Item {
                id: bottomHudBar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 48
                z: 15

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.rgba(4/255, 10/255, 32/255, 0.96) }
                        GradientStop { position: 0.45; color: Qt.rgba(6/255, 18/255, 54/255, 0.92) }
                        GradientStop { position: 1.0; color: Qt.rgba(2/255, 6/255, 20/255, 0.96) }
                    }
                    border.color: Qt.rgba(0/255, 219/255, 255/255, 0.4)
                    border.width: 1
                }

                // Garis aksen cyan neon di atas
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 2
                    color: "#00dbff"
                }

                // Sisi Kiri: Status Operasional S.E.E.S. & Grid Link
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 36
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    Rectangle {
                        width: 8; height: 8
                        radius: 4
                        color: "#00dbff"
                        anchors.verticalCenter: parent.verticalCenter
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.4; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                            NumberAnimation { from: 1.0; to: 0.4; duration: 800; easing.type: Easing.InOutQuad }
                        }
                    }

                    Text {
                        text: "S.E.E.S. TACTICAL LINK"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 11
                        font.weight: Font.Black
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "// SYSTEM OPERATIONAL • TATSUMI NETWORK STABLE"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: "#8df6ff"
                        opacity: 0.8
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Sisi Kanan: Panduan Tombol Ala Atlus Persona
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 36
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Repeater {
                        model: [
                            { key: "▲ / ▼", label: "NAVIGATE" },
                            { key: "1 - 5", label: "QUICK JUMP" },
                            { key: "ESC", label: "DISMISS" }
                        ]

                        Row {
                            spacing: 6
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: keyTxt.implicitWidth + 12
                                height: 22
                                radius: 3
                                color: "#00dbff"
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    id: keyTxt
                                    anchors.centerIn: parent
                                    text: modelData.key
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    color: "#040b1e"
                                }
                            }

                            Text {
                                text: modelData.label
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
        }
    }
}
