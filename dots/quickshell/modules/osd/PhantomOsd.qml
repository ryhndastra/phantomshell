import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

// =============================================================================
// PERSONA 3 RELOAD: S.E.E.S. TACTICAL HUD OSD (VOLUME & LUMINANCE)
// Tampilan pop-up volume dan brightness bertema HUD Tactical Persona 3 Reload
// =============================================================================
Scope {
    PanelWindow {
        id: osdWin

        visible: PhantomState.osdVisible || osdBody.opacity > 0.01

        WlrLayershell.namespace: "phantomshell-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            bottom: true
        }
        margins.bottom: 68

        implicitWidth: 420
        implicitHeight: 90
        color: "transparent"

        // Kontainer Utama HUD OSD Bergaya Persona 3 Reload
        Item {
            id: osdBody
            anchors.fill: parent
            anchors.margins: 6

            readonly property bool isOpen: PhantomState.osdVisible
            readonly property bool isVolume: PhantomState.osdLabel === "VOLUME"
            readonly property bool isMuted: isVolume && (PhantomState.osdMuted || PhantomState.osdValue <= 0)
            readonly property real ratio: Math.max(0.0, Math.min(1.0, PhantomState.osdValue / 100.0))

            opacity: isOpen ? 1.0 : 0.0
            scale: isOpen ? 1.0 : 0.88
            rotation: isOpen ? -2.0 : -5.0

            transform: Translate {
                y: osdBody.isOpen ? 0 : 20
                Behavior on y { NumberAnimation { duration: 180; easing.type: osdBody.isOpen ? Easing.OutBack : Easing.InCubic } }
            }

            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on rotation { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            HoverHandler {
                id: bodyHover
            }

            // Kartu Latar Belakang Slanted Khas P3R
            Canvas {
                id: bgCanvas
                anchors.fill: parent
                antialiasing: true
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height
                    var sk = 16.0

                    // Bayangan Luar Gelap Safir
                    ctx.beginPath()
                    ctx.moveTo(sk + 4, 4)
                    ctx.lineTo(w + 4, 4)
                    ctx.lineTo(w - sk + 4, h + 4)
                    ctx.lineTo(4, h + 4)
                    ctx.closePath()
                    ctx.fillStyle = "rgba(0, 20, 60, 0.75)"
                    ctx.fill()

                    // Dasar Kartu Navy Gelap
                    ctx.beginPath()
                    ctx.moveTo(sk, 0)
                    ctx.lineTo(w, 0)
                    ctx.lineTo(w - sk, h)
                    ctx.lineTo(0, h)
                    ctx.closePath()
                    ctx.fillStyle = "#030818"
                    ctx.fill()

                    // Garis Tepi Neon Cyan Otentik P3R
                    ctx.strokeStyle = osdBody.isMuted ? "#ff2a55" : "#00dbff"
                    ctx.lineWidth = 2.0
                    ctx.stroke()

                    // Aksen Garis Refleksi Interior P3R
                    ctx.beginPath()
                    ctx.moveTo(sk + 12, 4)
                    ctx.lineTo(w - 12, 4)
                    ctx.strokeStyle = osdBody.isMuted ? "rgba(255, 42, 85, 0.4)" : "rgba(0, 219, 255, 0.4)"
                    ctx.lineWidth = 1.0
                    ctx.stroke()
                }

                Connections {
                    target: osdBody
                    function onIsMutedChanged() { bgCanvas.requestPaint() }
                }
            }

            // Pita Header Slanted: S.E.E.S. TACTICAL HUD // AUDIO LEVEL
            Item {
                x: 24
                y: -10
                width: 170
                height: 22
                rotation: -2.0
                z: 10

                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: osdBody.isMuted ? "#ff2a55" : "#0038a8"
                    border.color: osdBody.isMuted ? "#ffffff" : "#00dbff"
                    border.width: 1.5

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: osdBody.isMuted ? "⚠" : (osdBody.isVolume ? "🔊" : "☀")
                            font.pixelSize: 11
                        }

                        Text {
                            text: osdBody.isVolume
                                ? (osdBody.isMuted ? "MUTED // S.E.E.S." : "S.E.E.S. // AUDIO")
                                : "S.E.E.S. // LUMINANCE"
                            color: "#ffffff"
                            font.family: "Rubik"
                            font.pixelSize: 9
                            font.weight: Font.Black
                            font.letterSpacing: 0.8
                        }
                    }
                }
            }

            // Baris Konten: Ikon, Baris Gauge Meter, dan Nilai Persentase
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 18
                anchors.topMargin: 12
                spacing: 12

                // Ikon Indikator
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 3
                    color: "#07122a"
                    border.color: osdBody.isMuted ? "#ff2a55" : "#00dbff"
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: osdBody.isVolume
                            ? (osdBody.isMuted ? "🔇" : (osdBody.ratio > 0.6 ? "🔊" : (osdBody.ratio > 0.25 ? "🔉" : "🔈")))
                            : "☀"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: iconMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (osdBody.isVolume) {
                                PhantomState.toggleVolumeMute()
                            }
                        }
                    }
                }

                // Bilah Meter Slanted Persona 3 Reload
                Item {
                    id: trackArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28

                    Canvas {
                        id: barCanvas
                        anchors.fill: parent
                        antialiasing: true

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var w = width
                            var h = height
                            var sk = 8.0

                            // 1. Lintasan Dasar (Track Background)
                            ctx.beginPath()
                            ctx.moveTo(sk, 0)
                            ctx.lineTo(w, 0)
                            ctx.lineTo(w - sk, h)
                            ctx.lineTo(0, h)
                            ctx.closePath()
                            ctx.fillStyle = "#07122a"
                            ctx.fill()
                            ctx.strokeStyle = "rgba(0, 219, 255, 0.3)"
                            ctx.lineWidth = 1.0
                            ctx.stroke()

                            // 2. Baris Isi Persentase (Fill Bar)
                            var fillW = Math.max(0, (w - sk) * osdBody.ratio)
                            if (fillW > 0) {
                                ctx.beginPath()
                                ctx.moveTo(sk, 0)
                                ctx.lineTo(sk + fillW, 0)
                                ctx.lineTo(fillW, h)
                                ctx.lineTo(0, h)
                                ctx.closePath()

                                if (osdBody.isMuted) {
                                    ctx.fillStyle = "#ff2a55"
                                } else {
                                    var grad = ctx.createLinearGradient(0, 0, w, 0)
                                    grad.addColorStop(0.0, "#0038a8")
                                    grad.addColorStop(0.5, "#0088ff")
                                    grad.addColorStop(1.0, "#00f0ff")
                                    ctx.fillStyle = grad
                                }
                                ctx.fill()

                                // Garis Pembatas Putih di Ujung Nilai (Slider Thumb Head)
                                ctx.beginPath()
                                ctx.moveTo(sk + fillW, 0)
                                ctx.lineTo(fillW, h)
                                ctx.strokeStyle = "#ffffff"
                                ctx.lineWidth = 2.5
                                ctx.stroke()
                            }

                            // 3. Garis Segmen / Grid Taktikal (Tick Marks Khas Persona 3)
                            ctx.strokeStyle = "rgba(3, 8, 24, 0.6)"
                            ctx.lineWidth = 1.5
                            for (var step = 1; step <= 9; step++) {
                                var tickX = (w - sk) * (step / 10.0)
                                ctx.beginPath()
                                ctx.moveTo(sk + tickX, 0)
                                ctx.lineTo(tickX, h)
                                ctx.stroke()
                            }
                        }

                        Connections {
                            target: osdBody
                            function onRatioChanged() { barCanvas.requestPaint() }
                            function onIsMutedChanged() { barCanvas.requestPaint() }
                        }
                    }

                    // Interaksi Klik dan Drag
                    MouseArea {
                        id: trackMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        readonly property bool interacting: pressed || containsMouse || iconMouse.containsMouse || bodyHover.hovered
                        onInteractingChanged: PhantomState.osdHovered = interacting

                        function applyAt(mx) {
                            const pct = Math.round(Math.max(0, Math.min(1, mx / Math.max(1, trackArea.width))) * 100)
                            if (osdBody.isVolume) {
                                PhantomState.setSystemVolume(pct)
                            } else {
                                PhantomState.setSystemBrightness(Math.max(1, pct))
                            }
                        }

                        onPressed: mouse => applyAt(mouse.x)
                        onPositionChanged: mouse => { if (pressed) applyAt(mouse.x) }
                        onWheel: wheel => {
                            const step = wheel.angleDelta.y > 0 ? 2 : -2
                            if (osdBody.isVolume) {
                                PhantomState.setSystemVolume(PhantomState.volumePct + step)
                            } else {
                                PhantomState.setSystemBrightness(PhantomState.brightnessPct + step)
                            }
                        }
                    }
                }

                // Lencana Persentase Slanted Kanan
                Rectangle {
                    Layout.preferredWidth: 62
                    Layout.preferredHeight: 36
                    radius: 3
                    color: osdBody.isMuted ? "#ff2a55" : "#0038a8"
                    border.color: osdBody.isMuted ? "#ffffff" : "#00dbff"
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: osdBody.isMuted ? "MUTED" : (PhantomState.osdValue + "%")
                        color: "#ffffff"
                        font.family: "Rubik"
                        font.pixelSize: osdBody.isMuted ? 10 : 13
                        font.weight: Font.Black
                        font.letterSpacing: 0.5
                    }
                }
            }
        }
    }
}
