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
                    p5TransitionAnim.restart()
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

                // rantai aksen diagonal di sudut kiri bawah dan kanan atas
                Rectangle {
                    width: 240
                    height: 3
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 56
                    anchors.rightMargin: -30
                    rotation: 18
                    color: "#3B82F6"
                    opacity: 0.55
                }

                Rectangle {
                    width: 180
                    height: 2
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 66
                    anchors.rightMargin: -20
                    rotation: 18
                    color: "#FACC15"
                    opacity: 0.45
                }

                // kartu panduan di tengah layar apabila belum ada jendela di dalam special workspace
                Item {
                    anchors.centerIn: parent
                    width: 470
                    height: 108
                    visible: velvetAtmosphere.specialCount === 0 && frameWin.velvetSlashProg >= 0.85
                    opacity: visible ? 0.92 : 0.0

                    Behavior on opacity {
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: "#080E24"
                        borderColor: "#60A5FA"
                        shadowColor: "#1D4ED8"
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 10 : 0
                        shadowOffsetX: 5
                        shadowOffsetY: 5
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 16

                        P5Star {
                            width: 38
                            height: 38
                            anchors.verticalCenter: parent.verticalCenter
                            spinning: PhantomState.specialWorkspaceActive
                            starColor: "#FACC15"
                            innerColor: "#2563EB"
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
                                font.italic: true
                            }

                            Text {
                                text: "BELUM ADA JENDELA DI RUANG KHUSUS INI"
                                color: "#93C5FD"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                width: emptyHintTxt.implicitWidth + 14
                                height: 20
                                color: "#1D4ED8"
                                border.color: "#FACC15"
                                border.width: 1

                                Text {
                                    id: emptyHintTxt
                                    anchors.centerIn: parent
                                    text: "[SUPER + ALT + S] KIRIM JENDELA   •   [SUPER + S] KELUAR"
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                }
                            }
                        }
                    }
                }

                // lencana status velvet room di sudut kanan bawah layar
                Item {
                    width: velvetCornerRow.implicitWidth + 28
                    height: 34
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.bottomMargin: PhantomState.barPosition === "bottom" ? 48 : 16
                    anchors.rightMargin: 18

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: "#080E24"
                        borderColor: "#60A5FA"
                        shadowColor: "#1D4ED8"
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 6 : 0
                        shadowOffsetX: 3
                        shadowOffsetY: 3
                    }

                    Row {
                        id: velvetCornerRow
                        anchors.centerIn: parent
                        spacing: 8

                        P5Star {
                            width: 16
                            height: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spinning: PhantomState.specialWorkspaceActive
                            starColor: "#FACC15"
                            innerColor: "#3B82F6"
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "VELVET ROOM"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 11
                            font.weight: Font.Black
                            font.italic: true
                        }

                        Rectangle {
                            width: contractTxt.implicitWidth + 10
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#1D4ED8"
                            border.color: "#93C5FD"
                            border.width: 1

                            Text {
                                id: contractTxt
                                anchors.centerIn: parent
                                text: velvetAtmosphere.specialCount + (velvetAtmosphere.specialCount === 1 ? " WINDOW" : " WINDOWS")
                                color: "#FACC15"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 9
                                font.weight: Font.Black
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "[SUPER+S] EXIT"
                            color: "#93C5FD"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // overlay animasi tebasan diagonal saat keluar-masuk velvet room (special workspace)
            Item {
                id: velvetSlashOverlay
                anchors.fill: parent
                visible: frameWin.velvetSlashProg < 0.995
                clip: true

                Rectangle {
                    anchors.fill: parent
                    color: "#1D4ED8"
                    opacity: Math.max(0.0, (1.0 - frameWin.velvetSlashProg) * 0.22)
                }

                Item {
                    anchors.centerIn: parent
                    width: parent.width * 1.6
                    height: 220
                    rotation: -12

                    Rectangle {
                        width: parent.width * 0.56
                        height: 26
                        y: 18
                        x: -width + (parent.width + width) * frameWin.velvetSlashProg
                        color: "#FACC15"
                        border.color: "#050814"
                        border.width: 2
                    }

                    Rectangle {
                        width: parent.width * 0.74
                        height: 80
                        y: 48
                        x: -width + (parent.width + width) * Math.min(1.0, frameWin.velvetSlashProg * 1.08)
                        color: "#1D4ED8"
                        border.color: "#93C5FD"
                        border.width: 3

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 15
                            anchors.bottomMargin: 15
                            color: "#060B1E"
                        }
                    }

                    Rectangle {
                        width: parent.width * 0.48
                        height: 14
                        y: 140
                        x: parent.width - (parent.width + width) * frameWin.velvetSlashProg
                        color: "#93C5FD"
                        border.color: "#050814"
                        border.width: 2
                    }
                }

                Item {
                    anchors.centerIn: parent
                    width: 470
                    height: 80
                    rotation: -5
                    scale: frameWin.velvetBannerScale
                    opacity: frameWin.velvetBannerOpacity

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: "#060B1E"
                        borderColor: "#93C5FD"
                        shadowColor: "#1D4ED8"
                        borderWidth: 2.5
                        skewPx: 14
                        shadowOffsetX: 6
                        shadowOffsetY: 6
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 14

                        P5Star {
                            width: 36
                            height: 36
                            anchors.verticalCenter: parent.verticalCenter
                            spinning: velvetSlashOverlay.visible
                            starColor: "#FACC15"
                            innerColor: "#2563EB"
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
                                font.pixelSize: 17
                                font.weight: Font.Black
                                font.italic: true
                            }

                            Rectangle {
                                width: velvetSubLbl.implicitWidth + 14
                                height: 18
                                color: "#1D4ED8"
                                border.color: "#FACC15"
                                border.width: 1

                                Text {
                                    id: velvetSubLbl
                                    anchors.centerIn: parent
                                    text: PhantomState.specialWorkspaceActive
                                        ? "SPECIAL WORKSPACE // BETWEEN DREAM AND REALITY"
                                        : "METAVERSE SHIFT // RETURNING TO REALITY"
                                    color: "#FACC15"
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

            // overlay animasi tebasan diagonal & banner waktu ganti tema atau wallpaper
            Item {
                id: slashOverlay
                anchors.fill: parent
                visible: frameWin.slashProg < 0.995
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
        }
    }
}

