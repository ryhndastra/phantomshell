import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

Scope {
    Variants {
        model: Quickshell.screens

        // bingkai layar opsional + efek transisi tebasan diagonal ala persona 5 waktu ganti tema / wallpaper
        PanelWindow {
            id: frameWin
            required property ShellScreen modelData
            screen: modelData
            visible: true

            WlrLayershell.namespace: "phantomshell-frame"
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: 0

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"
            mask: Region {}

            property real waterPlungeProg: 1.0
            onWaterPlungeProgChanged: console.log("[PLUNGE] prog=" + waterPlungeProg + " depth=" + waterDepthOpacity + " banner=" + waterBannerOpacity)
            property real waterDepthOpacity: 0.0
            property real waterBannerOpacity: 0.0
            property real waterBannerScale: 0.85

            ParallelAnimation {
                id: p3WaterPlungeAnim
                NumberAnimation {
                    target: frameWin
                    property: "waterPlungeProg"
                    from: 0.0
                    to: 1.0
                    duration: 1200
                    easing.type: Easing.OutCubic
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "waterDepthOpacity"
                        from: 0.0
                        to: 0.92
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                    PauseAnimation { duration: 420 }
                    NumberAnimation {
                        target: frameWin
                        property: "waterDepthOpacity"
                        from: 0.92
                        to: 0.0
                        duration: 480
                        easing.type: Easing.InCubic
                    }
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "waterBannerOpacity"
                        from: 0.0
                        to: 1.0
                        duration: 220
                        easing.type: Easing.OutQuad
                    }
                    PauseAnimation { duration: 480 }
                    NumberAnimation {
                        target: frameWin
                        property: "waterBannerOpacity"
                        from: 1.0
                        to: 0.0
                        duration: 320
                        easing.type: Easing.InCubic
                    }
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "waterBannerScale"
                        from: 0.82
                        to: 1.0
                        duration: 260
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.25
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "waterBannerScale"
                        from: 1.0
                        to: 1.05
                        duration: 800
                        easing.type: Easing.OutQuad
                    }
                }
            }

            property real slashProg: 1.0
            property real bannerOpacity: 0.0
            property real bannerScale: 0.8

            ParallelAnimation {
                id: p5TransitionAnim
                NumberAnimation {
                    target: frameWin
                    property: "slashProg"
                    from: 0.0
                    to: 1.0
                    duration: 1150
                    easing.type: Easing.OutCubic
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "bannerOpacity"
                        from: 0.0
                        to: 1.0
                        duration: 180
                        easing.type: Easing.OutQuad
                    }
                    PauseAnimation { duration: 640 }
                    NumberAnimation {
                        target: frameWin
                        property: "bannerOpacity"
                        from: 1.0
                        to: 0.0
                        duration: 320
                        easing.type: Easing.InCubic
                    }
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "bannerScale"
                        from: 0.78
                        to: 1.0
                        duration: 260
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.35
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "bannerScale"
                        from: 1.0
                        to: 1.06
                        duration: 880
                        easing.type: Easing.OutQuad
                    }
                }
            }

            property real velvetSlashProg: 1.0
            property real velvetBannerOpacity: 0.0
            property real velvetBannerScale: 0.8

            ParallelAnimation {
                id: velvetTransitionAnim
                NumberAnimation {
                    target: frameWin
                    property: "velvetSlashProg"
                    from: 0.0
                    to: 1.0
                    duration: PhantomState.specialWorkspaceActive ? 920 : 620
                    easing.type: Easing.OutCubic
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "velvetBannerOpacity"
                        from: 0.0
                        to: 1.0
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                    PauseAnimation { duration: PhantomState.specialWorkspaceActive ? 480 : 240 }
                    NumberAnimation {
                        target: frameWin
                        property: "velvetBannerOpacity"
                        from: 1.0
                        to: 0.0
                        duration: 260
                        easing.type: Easing.InCubic
                    }
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "velvetBannerScale"
                        from: 0.80
                        to: 1.0
                        duration: 220
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.32
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "velvetBannerScale"
                        from: 1.0
                        to: 1.04
                        duration: 650
                        easing.type: Easing.OutQuad
                    }
                }
            }

            Connections {
                target: PhantomState
                function onPrimaryChanged() { frameCanvas.requestPaint() }
                function onBackgroundChanged() { frameCanvas.requestPaint() }
                function onFrameThicknessChanged() { frameCanvas.requestPaint() }
                function onCornerRadiusChanged() { frameCanvas.requestPaint() }
                function onPolygonModeChanged() { frameCanvas.requestPaint() }
                function onScreenFrameChanged() { frameCanvas.requestPaint() }
                function onSpecialWorkspaceActiveChanged() { frameCanvas.requestPaint() }
                function onTransitionTickChanged() {
                    console.log("[SCREEN FRAME] onTransitionTickChanged: themeId=" + PhantomState.themeId)
                    if (PhantomState.themeId === "p3-reload") {
                        console.log("[SCREEN FRAME] Starting p3WaterPlungeAnim")
                        p3WaterPlungeAnim.restart()
                    } else {
                        console.log("[SCREEN FRAME] Starting p5TransitionAnim")
                        p5TransitionAnim.restart()
                    }
                }
                function onVelvetTransitionTickChanged() {
                    velvetTransitionAnim.restart()
                }
            }

            Canvas {
                id: frameCanvas
                anchors.fill: parent
                visible: PhantomState.screenFrame || PhantomState.specialWorkspaceActive
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)

                    var isVelvet = PhantomState.specialWorkspaceActive
                    var t = isVelvet ? Math.max(3, PhantomState.frameThickness) : PhantomState.frameThickness
                    var c = PhantomState.polygonMode ? 14 : PhantomState.cornerRadius
                    var w = width
                    var h = height

                    ctx.fillStyle = isVelvet ? "#060B1E" : PhantomState.background

                    // strip garis batas tepi luar layar
                    ctx.fillRect(0, 0, w, t)
                    ctx.fillRect(0, h - t, w, t)
                    ctx.fillRect(0, t, t, h - t * 2)
                    ctx.fillRect(w - t, t, t, h - t * 2)

                    // potongan segitiga di keempat sudut dalam
                    ctx.beginPath()
                    ctx.moveTo(t, t); ctx.lineTo(t + c, t); ctx.lineTo(t, t + c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(w - t, t); ctx.lineTo(w - t - c, t); ctx.lineTo(w - t, t + c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(w - t, h - t); ctx.lineTo(w - t - c, h - t); ctx.lineTo(w - t, h - t - c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(t, h - t); ctx.lineTo(t + c, h - t); ctx.lineTo(t, h - t - c); ctx.closePath(); ctx.fill()

                    // garis aksen di sepanjang tepi dalam bingkai
                    ctx.strokeStyle = isVelvet ? "#60A5FA" : PhantomState.primary
                    ctx.lineWidth = isVelvet ? 2.0 : 1.5
                    ctx.beginPath()
                    ctx.moveTo(t + c, t)
                    ctx.lineTo(w - t - c, t)
                    ctx.lineTo(w - t, t + c)
                    ctx.lineTo(w - t, h - t - c)
                    ctx.lineTo(w - t - c, h - t)
                    ctx.lineTo(t + c, h - t)
                    ctx.lineTo(t, h - t - c)
                    ctx.lineTo(t, t + c)
                    ctx.closePath()
                    ctx.stroke()
                }
            }

            // atmosfer dan indikator pasif saat berada di dalam velvet room (special workspace)
            Item {
                id: velvetAtmosphere
                anchors.fill: parent
                visible: opacity > 0.01
                opacity: PhantomState.specialWorkspaceActive ? 1.0 : 0.0

                readonly property var specialApps: (PhantomState.workspaceApps && PhantomState.workspaceApps["special"])
                    ? PhantomState.workspaceApps["special"]
                    : []
                readonly property int specialCount: specialApps.length

                Behavior on opacity {
                    NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                }

                // Garis aksen biru laut velvet di sudut kanan atas
                Rectangle {
                    width: 240
                    height: 3
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 56
                    anchors.rightMargin: -30
                    rotation: 18
                    color: "#0077B6"
                    opacity: 0.65
                }

                Rectangle {
                    width: 180
                    height: 2
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 66
                    anchors.rightMargin: -20
                    rotation: 18
                    color: "#00F0FF"
                    opacity: 0.55
                }

                // Kartu panduan di tengah layar apabila belum ada jendela di dalam special workspace
                Item {
                    anchors.centerIn: parent
                    width: 480
                    height: 104
                    visible: velvetAtmosphere.specialCount === 0 && frameWin.velvetSlashProg >= 0.85
                    opacity: visible ? 0.95 : 0.0

                    Behavior on opacity {
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#EE040D26"
                        border.color: "#00F0FF"
                        border.width: 1.5

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 5
                            color: "transparent"
                            border.color: "#4D0077B6"
                            border.width: 1
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 16

                        // Dial Velvet Room
                        Item {
                            width: 40
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: 38
                                height: 38
                                radius: 19
                                color: "transparent"
                                border.color: "#00F0FF"
                                border.width: 1.5
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 26
                                height: 26
                                radius: 13
                                color: "#2200F0FF"
                                border.color: "#93C5FD"
                                border.width: 1
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "V"
                                color: "#00F0FF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 14
                                font.weight: Font.Black
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                text: "THE VELVET ROOM // EMPTY CHAMBER"
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 15
                                font.weight: Font.Black
                                font.letterSpacing: 1.2
                            }

                            Text {
                                text: "NO ACTIVE WINDOWS IN SPECIAL WORKSPACE"
                                color: "#7DD3FC"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                width: emptyHintTxt.implicitWidth + 16
                                height: 22
                                radius: 3
                                color: "#0A255C"
                                border.color: "#00F0FF"
                                border.width: 1

                                Text {
                                    id: emptyHintTxt
                                    anchors.centerIn: parent
                                    text: "[SUPER + ALT + S] MOVE WINDOW HERE   •   [SUPER + S] EXIT"
                                    color: "#F0F9FF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.letterSpacing: 0.5
                                }
                            }
                        }
                    }
                }

                // Lencana status velvet room di sudut kanan bawah layar
                Item {
                    width: velvetCornerRow.implicitWidth + 24
                    height: 32
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.bottomMargin: PhantomState.barPosition === "bottom" ? 48 : 16
                    anchors.rightMargin: 18

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: "#EE040D26"
                        border.color: "#00F0FF"
                        border.width: 1.5
                    }

                    Row {
                        id: velvetCornerRow
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#00F0FF"
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "VELVET ROOM"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Black
                            font.letterSpacing: 1.0
                        }

                        Rectangle {
                            width: contractTxt.implicitWidth + 10
                            height: 18
                            radius: 3
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#0A255C"
                            border.color: "#38BDF8"
                            border.width: 1

                            Text {
                                id: contractTxt
                                anchors.centerIn: parent
                                text: velvetAtmosphere.specialCount + (velvetAtmosphere.specialCount === 1 ? " WINDOW" : " WINDOWS")
                                color: "#38BDF8"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 9
                                font.weight: Font.Black
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "[SUPER+S] EXIT"
                            color: "#7DD3FC"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // overlay transisi velvet room (special workspace) ala Persona 3 Reload Sea of Soul
            Item {
                id: velvetSlashOverlay
                anchors.fill: parent
                visible: frameWin.velvetSlashProg < 0.995
                clip: true

                // Latar belakang sapphire / velvet navy
                Rectangle {
                    anchors.fill: parent
                    color: "#030A1E"
                    opacity: Math.sin(frameWin.velvetSlashProg * Math.PI) * 0.75
                }

                // Efek tirai cahaya horizontal sapphire & cyan
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * (1.0 - frameWin.velvetSlashProg) * 0.85
                    opacity: Math.sin(frameWin.velvetSlashProg * Math.PI) * 0.45
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: "#4D0077B6" }
                        GradientStop { position: 0.5; color: "#8000F0FF" }
                        GradientStop { position: 0.7; color: "#4D0077B6" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // Ring aperture / dial elevator velvet room
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.height * (0.3 + frameWin.velvetSlashProg * 0.9)
                    height: width
                    radius: width / 2
                    color: "transparent"
                    border.color: "#00F0FF"
                    border.width: Math.max(1, (1.0 - frameWin.velvetSlashProg) * 3)
                    opacity: Math.sin(frameWin.velvetSlashProg * Math.PI) * 0.6
                }

                // Kartu status banner velvet room di tengah layar
                Item {
                    anchors.centerIn: parent
                    width: 480
                    height: 80
                    scale: frameWin.velvetBannerScale
                    opacity: frameWin.velvetBannerOpacity

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#EE030B22"
                        border.color: "#00F0FF"
                        border.width: 2

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 5
                            color: "transparent"
                            border.color: "#4D00B4D8"
                            border.width: 1
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 16

                        // Dial emblem velvet room berputar
                        Item {
                            width: 40
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: 38
                                height: 38
                                radius: 19
                                color: "transparent"
                                border.color: "#00F0FF"
                                border.width: 1.5
                                rotation: frameWin.velvetSlashProg * 360
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 26
                                height: 26
                                radius: 13
                                color: "#2200F0FF"
                                border.color: "#93C5FD"
                                border.width: 1
                                rotation: -frameWin.velvetSlashProg * 240
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "V"
                                color: "#00F0FF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 14
                                font.weight: Font.Black
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3

                            Text {
                                text: PhantomState.specialWorkspaceActive
                                    ? "WELCOME TO THE VELVET ROOM"
                                    : "LEAVING THE VELVET ROOM"
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 16
                                font.weight: Font.Black
                                font.letterSpacing: 1.2
                            }

                            Row {
                                spacing: 6
                                Rectangle {
                                    height: 18
                                    width: velvetSubLbl.implicitWidth + 12
                                    radius: 3
                                    color: "#0A255C"
                                    border.color: "#00F0FF"
                                    border.width: 1

                                    Text {
                                        id: velvetSubLbl
                                        anchors.centerIn: parent
                                        text: PhantomState.specialWorkspaceActive
                                            ? "SEA OF SOUL // SPECIAL WORKSPACE"
                                            : "METAVERSE SHIFT // CONTRACT SUSPENDED"
                                        color: "#00F0FF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                        font.letterSpacing: 0.8
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // overlay animasi tebasan diagonal & banner waktu ganti tema (Persona 5 & tema lainnya)
            Item {
                id: slashOverlay
                anchors.fill: parent
                visible: frameWin.slashProg < 0.995 && PhantomState.themeId !== "p3-reload"
                clip: true

                // kilatan tipis warna tema di awal transisi
                Rectangle {
                    anchors.fill: parent
                    color: PhantomState.primary
                    opacity: Math.max(0.0, (1.0 - frameWin.slashProg) * 0.16)
                }

                // pita tebasan diagonal miring dari kiri ke kanan
                Item {
                    anchors.centerIn: parent
                    width: parent.width * 1.6
                    height: 220
                    rotation: -13

                    // pita aksen warna sekunder
                    Rectangle {
                        width: parent.width * 0.55
                        height: 28
                        y: 16
                        x: -width + (parent.width + width) * frameWin.slashProg
                        color: PhantomState.secondary
                        border.color: "#05060A"
                        border.width: 2
                    }

                    // pita tebasan utama warna primer
                    Rectangle {
                        width: parent.width * 0.72
                        height: 82
                        y: 48
                        x: -width + (parent.width + width) * Math.min(1.0, frameWin.slashProg * 1.08)
                        color: PhantomState.primary
                        border.color: "#FFFFFF"
                        border.width: 3

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 16
                            anchors.bottomMargin: 16
                            color: "#05060A"
                        }
                    }

                    // pita tebasan putih di bagian bawah
                    Rectangle {
                        width: parent.width * 0.48
                        height: 14
                        y: 142
                        x: parent.width - (parent.width + width) * frameWin.slashProg
                        color: "#FFFFFF"
                        border.color: "#05060A"
                        border.width: 2
                    }
                }

                // kartu banner indikator transisi di tengah layar
                Item {
                    anchors.centerIn: parent
                    width: 440
                    height: 76
                    rotation: -5
                    scale: frameWin.bannerScale
                    opacity: frameWin.bannerOpacity

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: "#06070B"
                        borderColor: "#FFFFFF"
                        shadowColor: PhantomState.primary
                        borderWidth: 2.5
                        skewPx: 14
                        shadowOffsetX: 6
                        shadowOffsetY: 6
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 14

                        P5Star {
                            width: 34
                            height: 34
                            anchors.verticalCenter: parent.verticalCenter
                            spinning: slashOverlay.visible
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: PhantomState.transitionTitle
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 18
                                font.weight: Font.Black
                                font.italic: true
                            }

                            Rectangle {
                                width: subLbl.implicitWidth + 14
                                height: 18
                                color: PhantomState.primary
                                border.color: "#FFFFFF"
                                border.width: 1

                                Text {
                                    id: subLbl
                                    anchors.centerIn: parent
                                    text: PhantomState.transitionSub
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.italic: true
                                }
                            }
                        }
                    }
                }
            }

            // overlay transisi terjun ke dalam air (water plunge / bubbles) khusus Persona 3 Reload
            Item {
                id: p3WaterPlungeOverlay
                anchors.fill: parent
                visible: frameWin.waterPlungeProg < 0.995
                clip: true

                // Latar belakang gelombang air samudra biru pekat
                Rectangle {
                    anchors.fill: parent
                    opacity: frameWin.waterDepthOpacity
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#000814" }
                        GradientStop { position: 0.35; color: "#001D3D" }
                        GradientStop { position: 0.65; color: "#003566" }
                        GradientStop { position: 0.88; color: "#0077B6" }
                        GradientStop { position: 1.0; color: "#00B4D8" }
                    }
                }

                // Gelombang riak air melingkar (shockwaves) menyebar ke segala arah
                Repeater {
                    model: 4
                    delegate: Rectangle {
                        required property int index
                        readonly property real prog: Math.max(0.0, Math.min(1.0, (frameWin.waterPlungeProg * 1.5) - (index * 0.16)))
                        anchors.centerIn: parent
                        width: parent.width * (0.15 + prog * 1.6)
                        height: parent.height * (0.15 + prog * 1.4)
                        radius: width / 2
                        color: "transparent"
                        border.color: index % 2 === 0 ? "#00F0FF" : "#FFFFFF"
                        border.width: Math.max(1, (1.0 - prog) * 3.5)
                        opacity: Math.sin(prog * Math.PI) * 0.65
                        visible: prog > 0.001 && prog < 0.999
                    }
                }

                // Berkas cahaya matahari menembus ke dalam kedalaman air (sunbeams caustics)
                Repeater {
                    model: 5
                    delegate: Rectangle {
                        required property int index
                        width: 90 + (index * 40)
                        height: parent.height * 1.3
                        x: (parent.width * (0.12 + index * 0.18)) + Math.sin(frameWin.waterPlungeProg * 3.5 + index) * 18
                        y: -parent.height * 0.15
                        rotation: -12 + index * 2
                        opacity: Math.sin(frameWin.waterPlungeProg * Math.PI) * 0.15
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#B300F0FF" }
                            GradientStop { position: 0.55; color: "#4D0077B6" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                }

                // Rombongan gelembung air (bubbles) naik ke permukaan dengan osilasi goyangan riil
                Repeater {
                    model: 36
                    delegate: Item {
                        required property int index
                        readonly property real baseX: ((index * 53 + 27) % 100) / 100.0 * parent.width
                        readonly property real startY: parent.height * (0.6 + ((index * 29) % 50) / 100.0)
                        readonly property real speed: 0.65 + ((index * 17) % 10) / 12.0
                        readonly property real bSize: 6 + (index * 7) % 24
                        readonly property real wobble: Math.sin(frameWin.waterPlungeProg * (10 + (index % 5) * 3) + index) * (10 + (index % 4) * 5)
                        readonly property real currentY: startY - (parent.height * 1.15 * frameWin.waterPlungeProg * speed)
                        x: baseX + wobble
                        y: currentY
                        width: bSize
                        height: bSize
                        opacity: Math.sin(frameWin.waterPlungeProg * Math.PI) * (0.35 + (index % 5) * 0.14)
                        visible: currentY > -50 && currentY < parent.height + 50

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "#2600F0FF"
                            border.color: "#CCFFFFFF"
                            border.width: 1.2

                            // Titik kilauan refleksi cahaya dalam gelembung
                            Rectangle {
                                x: parent.width * 0.22
                                y: parent.height * 0.2
                                width: Math.max(2, parent.width * 0.28)
                                height: Math.max(2, parent.height * 0.28)
                                radius: width / 2
                                color: "#FFFFFF"
                                opacity: 0.85
                            }
                        }
                    }
                }

                // Kartu status banner Persona 3 Reload di tengah layar (Murni Efek Air, Tanpa Makoto Yuki)
                Item {
                    anchors.centerIn: parent
                    width: 520
                    height: 90
                    scale: frameWin.waterBannerScale
                    opacity: frameWin.waterBannerOpacity

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#EE020B20"
                        border.color: "#00F0FF"
                        border.width: 2

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 5
                            color: "transparent"
                            border.color: "#4D00B4D8"
                            border.width: 1
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 16

                        // Emblem Dial Jam P3R Berputar
                        Item {
                            width: 44
                            height: 44
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: 44
                                height: 44
                                radius: 22
                                color: "transparent"
                                border.color: "#00F0FF"
                                border.width: 2
                                rotation: frameWin.waterPlungeProg * 360
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 32
                                height: 32
                                radius: 16
                                color: "#1A00F0FF"
                                border.color: "#FFFFFF"
                                border.width: 1.5
                                rotation: -frameWin.waterPlungeProg * 280
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "3"
                                color: "#00F0FF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 18
                                font.weight: Font.Black
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3

                            Row {
                                spacing: 8
                                Text {
                                    text: "PERSONA 3 RELOAD"
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 18
                                    font.weight: Font.Black
                                    font.letterSpacing: 1.5
                                }
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: 16
                                    width: 54
                                    radius: 2
                                    color: "#00F0FF"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "S.E.E.S."
                                        color: "#020B20"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }
                                }
                            }

                            Text {
                                text: "SEA OF SOUL // TARTARUS FREQUENCY SYNCHRONIZED"
                                color: "#7DD3FC"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                font.letterSpacing: 0.8
                            }
                        }
                    }
                }
            }
        }
    }
}

