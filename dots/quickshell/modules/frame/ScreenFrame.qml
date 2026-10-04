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

            Connections {
                target: PhantomState
                function onPrimaryChanged() { frameCanvas.requestPaint() }
                function onBackgroundChanged() { frameCanvas.requestPaint() }
                function onFrameThicknessChanged() { frameCanvas.requestPaint() }
                function onCornerRadiusChanged() { frameCanvas.requestPaint() }
                function onPolygonModeChanged() { frameCanvas.requestPaint() }
                function onScreenFrameChanged() { frameCanvas.requestPaint() }
                function onTransitionTickChanged() {
                    p5TransitionAnim.restart()
                }
            }

            Canvas {
                id: frameCanvas
                anchors.fill: parent
                visible: PhantomState.screenFrame
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)

                    var t = PhantomState.frameThickness
                    var c = PhantomState.polygonMode ? 12 : PhantomState.cornerRadius
                    var w = width
                    var h = height

                    ctx.fillStyle = PhantomState.background

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
                    ctx.strokeStyle = PhantomState.primary
                    ctx.lineWidth = 1.5
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
