import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

// Dialogue HUD on-screen display for volume and brightness.
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

        implicitWidth: 460
        implicitHeight: 96
        color: "transparent"

        Item {
            id: osdBody
            anchors.fill: parent
            anchors.margins: 4

            readonly property bool isOpen: PhantomState.osdVisible
            readonly property bool isVolume: PhantomState.osdLabel === "VOLUME"
            readonly property bool isMuted: isVolume && (PhantomState.osdMuted || PhantomState.osdValue <= 0)
            readonly property real ratio: Math.max(0.0, Math.min(1.0, PhantomState.osdValue / 100.0))

            // Icon selection
            readonly property string resolvedIconUrl: {
                const home = Quickshell.env("HOME") || "/home/sho"
                if (!osdBody.isVolume) {
                    return "file://" + home + "/.config/quickshell/assets/icons/brightness.svg"
                }
                if (osdBody.isMuted) {
                    return "file://" + home + "/.config/quickshell/assets/icons/volume-muted.svg"
                }
                if (osdBody.ratio > 0.6) {
                    return "file://" + home + "/.config/quickshell/assets/icons/volume-high.svg"
                }
                if (osdBody.ratio > 0.25) {
                    return "file://" + home + "/.config/quickshell/assets/icons/volume-medium.svg"
                }
                return "file://" + home + "/.config/quickshell/assets/icons/volume-low.svg"
            }

            opacity: isOpen ? 1.0 : 0.0
            scale: isOpen ? 1.0 : 0.92

            transform: Translate {
                y: osdBody.isOpen ? 0 : 16
                Behavior on y { NumberAnimation { duration: 180; easing.type: osdBody.isOpen ? Easing.OutBack : Easing.InCubic } }
            }

            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            HoverHandler {
                id: bodyHover
            }

            // Speech bubble canvas
            Canvas {
                id: p3BubbleCanvas
                anchors.fill: parent
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height

                    ctx.fillStyle = "rgba(0, 160, 255, 0.32)"
                    ctx.beginPath()
                    ctx.moveTo(w - 75, -2)
                    ctx.lineTo(w + 4, -2)
                    ctx.lineTo(w - 8, h + 2)
                    ctx.lineTo(w - 88, h + 2)
                    ctx.closePath()
                    ctx.fill()

                    var bx = 16
                    var by = 8
                    var bw = w - 34
                    var bh = h - 14
                    var r = 6

                    ctx.beginPath()
                    ctx.moveTo(bx + r, by)
                    ctx.lineTo(bx + bw - r, by)
                    ctx.quadraticCurveTo(bx + bw, by, bx + bw, by + r)
                    ctx.lineTo(bx + bw, by + bh - r)
                    ctx.quadraticCurveTo(bx + bw, by + bh, bx + bw - r, by + bh)
                    ctx.lineTo(bx + r, by + bh)
                    ctx.quadraticCurveTo(bx, by + bh, bx, by + bh - r)
                    ctx.lineTo(bx, by + r)
                    ctx.quadraticCurveTo(bx, by, bx + r, by)
                    ctx.closePath()

                    ctx.fillStyle = "rgba(4, 12, 38, 0.95)"
                    ctx.fill()

                    ctx.strokeStyle = osdBody.isMuted ? "rgba(255, 42, 85, 0.85)" : "rgba(0, 219, 255, 0.75)"
                    ctx.lineWidth = 1.6
                    ctx.stroke()

                    ctx.beginPath()
                    ctx.moveTo(-2, 18)           // Ujung runcing kiri
                    ctx.lineTo(135, -2)          // Titik atas kanan
                    ctx.lineTo(146, 20)          // Titik bawah kanan
                    ctx.lineTo(34, 30)           // Titik bawah kiri
                    ctx.closePath()

                    ctx.fillStyle = osdBody.isMuted ? "#d60032" : "#0028e0"
                    ctx.fill()
                    ctx.strokeStyle = osdBody.isMuted ? "#ffffff" : "#00f0ff"
                    ctx.lineWidth = 1.3
                    ctx.stroke()
                }

                Connections {
                    target: osdBody
                    function onIsMutedChanged() { p3BubbleCanvas.requestPaint() }
                }
            }

            // Label on wedge tag
            Item {
                x: 8
                y: -1
                width: 130
                height: 28
                z: 10

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.topMargin: 2
                    spacing: 0

                    Text {
                        text: osdBody.isVolume
                            ? (osdBody.isMuted ? "MUTED" : "VOLUME")
                            : "BRIGHTNESS"
                        color: "#ffffff"
                        font.family: "Rubik"
                        font.pixelSize: 10
                        font.weight: Font.Black
                        font.letterSpacing: 0.8
                    }

                    Text {
                        text: osdBody.isVolume ? "AUDIO LEVEL" : "DISPLAY LEVEL"
                        color: "#00f0ff"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 8
                        font.bold: true
                        font.letterSpacing: 0.5
                    }
                }
            }

            // Main content: icon, gauge bar, and percentage
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                anchors.topMargin: 18
                anchors.bottomMargin: 8
                spacing: 12
                z: 5

                Rectangle {
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38
                    radius: 4
                    color: osdBody.isMuted ? "#2a0610" : "#061536"
                    border.color: osdBody.isMuted ? "#ff2a55" : "#00dbff"
                    border.width: 1.2

                    Image {
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        source: osdBody.resolvedIconUrl
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    MouseArea {
                        id: iconMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (osdBody.isVolume) PhantomState.toggleVolumeMute()
                        }
                    }
                }

                // Gauge bar
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
                            var sk = 7.0

                            ctx.beginPath()
                            ctx.moveTo(sk, 0)
                            ctx.lineTo(w, 0)
                            ctx.lineTo(w - sk, h)
                            ctx.lineTo(0, h)
                            ctx.closePath()
                            ctx.fillStyle = "#06122c"
                            ctx.fill()
                            ctx.strokeStyle = "rgba(0, 219, 255, 0.35)"
                            ctx.lineWidth = 1.0
                            ctx.stroke()

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
                                    grad.addColorStop(0.0, "#0028e0")
                                    grad.addColorStop(0.5, "#0077ff")
                                    grad.addColorStop(1.0, "#00e5ff")
                                    ctx.fillStyle = grad
                                }
                                ctx.fill()

                                ctx.beginPath()
                                ctx.moveTo(sk + fillW, 0)
                                ctx.lineTo(fillW, h)
                                ctx.strokeStyle = "#ffffff"
                                ctx.lineWidth = 2.0
                                ctx.stroke()
                            }

                            ctx.strokeStyle = "rgba(4, 12, 38, 0.65)"
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

                Rectangle {
                    Layout.preferredWidth: 58
                    Layout.preferredHeight: 34
                    radius: 3
                    color: osdBody.isMuted ? "#d60032" : "#0028e0"
                    border.color: osdBody.isMuted ? "#ffffff" : "#00f0ff"
                    border.width: 1.2

                    Text {
                        anchors.centerIn: parent
                        text: osdBody.isMuted ? "MUTED" : (PhantomState.osdValue + "%")
                        color: "#ffffff"
                        font.family: "Rubik"
                        font.pixelSize: osdBody.isMuted ? 10 : 12
                        font.weight: Font.Black
                        font.letterSpacing: 0.5
                    }
                }
            }
        }
    }
}
