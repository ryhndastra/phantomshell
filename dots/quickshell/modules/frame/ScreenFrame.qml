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
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"
            mask: Region {}

            property bool p3SplashActive: false
            property int p3SplashFrame: 0
            property real p3SplashOpacity: 1.0
            property real p3OceanCoverage: 0.0

            Timer {
                id: p3SplashTimer
                interval: 36
                repeat: true
                running: false
                onTriggered: {
                    if (frameWin.p3SplashFrame < 11) {
                        frameWin.p3SplashFrame++
                        // Cakupan samudra naik cepat di awal sehingga pada frame 4-8 layar tertutup 100%
                        if (frameWin.p3SplashFrame === 1) frameWin.p3OceanCoverage = 0.5
                        else if (frameWin.p3SplashFrame === 2) frameWin.p3OceanCoverage = 0.8
                        else if (frameWin.p3SplashFrame === 3) frameWin.p3OceanCoverage = 0.96
                        else if (frameWin.p3SplashFrame >= 4) frameWin.p3OceanCoverage = 1.0
                    } else {
                        p3SplashTimer.stop()
                        p3SplashFadeAnim.restart()
                    }
                }
            }

            SequentialAnimation {
                id: p3SplashFadeAnim
                PauseAnimation { duration: 180 }
                ParallelAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "p3SplashOpacity"
                        from: 1.0
                        to: 0.0
                        duration: 380
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "p3OceanCoverage"
                        from: 1.0
                        to: 0.0
                        duration: 380
                        easing.type: Easing.OutCubic
                    }
                }
                ScriptAction {
                    script: {
                        frameWin.p3SplashActive = false
                        frameWin.p3SplashFrame = 0
                        frameWin.p3OceanCoverage = 0.0
                    }
                }
            }

            function triggerP3Splash() {
                p3SplashTimer.stop()
                p3SplashFadeAnim.stop()
                frameWin.p3SplashFrame = 0
                frameWin.p3OceanCoverage = 0.25
                frameWin.p3SplashOpacity = 1.0
                frameWin.p3SplashActive = true
                PhantomState.playSfx("splash")
                p3SplashTimer.restart()
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
                    console.log("[SCREEN FRAME] onTransitionTickChanged: targetThemeId=" + PhantomState.targetThemeId)
                    if (PhantomState.targetThemeId === "p3-reload") {
                        frameWin.triggerP3Splash()
                    } else {
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

            // Efek transisi semburan air / water splash cel-shaded Persona 3 Reload (12 frame PNG)
            Item {
                id: p3SplashOverlay
                anchors.fill: parent
                visible: frameWin.p3SplashActive
                opacity: frameWin.p3SplashOpacity
                z: 100

                // 1. Lapisan samudra biru pekat P3R (Sea of Soul) menutup 100% layar tanpa celah
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -20
                    opacity: frameWin.p3OceanCoverage
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#010A1A" }
                        GradientStop { position: 0.28; color: "#021C42" }
                        GradientStop { position: 0.58; color: "#003A75" }
                        GradientStop { position: 0.85; color: "#0077B6" }
                        GradientStop { position: 1.0; color: "#00B4D8" }
                    }
                }

                // 2. Berkas cahaya matahari dan caustics bawah air
                Repeater {
                    model: 6
                    delegate: Rectangle {
                        required property int index
                        width: parent.width * 0.22 + (index * 25)
                        height: parent.height * 1.4
                        x: (parent.width * (0.04 + index * 0.17)) + Math.sin(frameWin.p3SplashFrame * 0.6 + index) * 24
                        y: -parent.height * 0.2
                        rotation: -14 + index * 4.5
                        opacity: frameWin.p3OceanCoverage * (0.14 + (index % 3) * 0.08)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#9900F0FF" }
                            GradientStop { position: 0.65; color: "#400077B6" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                }

                // 3. Gelembung udara spekular berombak naik dari bawah
                Repeater {
                    model: 28
                    delegate: Item {
                        required property int index
                        readonly property real baseX: ((index * 67 + 31) % 100) / 100.0 * parent.width
                        readonly property real startY: parent.height * (0.5 + ((index * 37) % 50) / 100.0)
                        readonly property real speed: 0.75 + ((index * 13) % 10) / 10.0
                        readonly property real bSize: 8 + ((index * 11) % 22)
                        readonly property real wobble: Math.sin(frameWin.p3SplashFrame * 0.8 + index) * (12 + (index % 4) * 6)
                        readonly property real currentY: startY - (parent.height * 0.85 * (frameWin.p3SplashFrame / 11.0) * speed)
                        x: baseX + wobble
                        y: currentY
                        width: bSize
                        height: bSize
                        opacity: frameWin.p3OceanCoverage * (0.4 + (index % 4) * 0.15)
                        visible: currentY > -30 && currentY < parent.height + 30

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "#2600F0FF"
                            border.color: "#E6FFFFFF"
                            border.width: 1.2

                            Rectangle {
                                x: parent.width * 0.22
                                y: parent.height * 0.2
                                width: Math.max(2, parent.width * 0.28)
                                height: Math.max(2, parent.height * 0.28)
                                radius: width / 2
                                color: "#FFFFFF"
                                opacity: 0.9
                            }
                        }
                    }
                }

                // 4. Hero Semburan Air Autentik P3R (Scaled 1.22x agar semburan dan buih melebar menembus sisi)
                Item {
                    anchors.fill: parent
                    scale: 1.22
                    transformOrigin: Item.Center

                    Repeater {
                        model: 12
                        delegate: Image {
                            required property int index
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            visible: frameWin.p3SplashFrame === index
                            asynchronous: false
                            cache: true
                            source: Qt.resolvedUrl("../../assets/themes/p3/menu/png/pngseq" + (index < 10 ? "0" + index : "" + index) + ".png")
                        }
                    }
                }

                // 5. Percikan air sekunder kiri & kanan (mirrored) untuk mengisi sudut samping secara organik
                Item {
                    anchors.fill: parent
                    scale: 1.18
                    opacity: 0.7
                    transformOrigin: Item.Center

                    Repeater {
                        model: 12
                        delegate: Image {
                            required property int index
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            visible: frameWin.p3SplashFrame === index
                            mirror: true
                            asynchronous: false
                            cache: true
                            source: Qt.resolvedUrl("../../assets/themes/p3/menu/png/pngseq" + (index < 10 ? "0" + index : "" + index) + ".png")
                        }
                    }
                }
            }
        }
    }
}

