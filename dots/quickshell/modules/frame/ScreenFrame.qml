import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: frameWin
            required property ShellScreen modelData
            screen: modelData
            visible: true

            WlrLayershell.namespace: "phantomshell-frame"
            WlrLayershell.layer: WlrLayer.Bottom
            // ExclusionMode.Normal makes the frame sit cleanly inside the workspace area below PhantomBar!
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

            Connections {
                target: PhantomState
                function onPrimaryChanged() { frameCanvas.requestPaint() }
                function onBackgroundChanged() { frameCanvas.requestPaint() }
                function onFrameThicknessChanged() { frameCanvas.requestPaint() }
                function onCornerRadiusChanged() { frameCanvas.requestPaint() }
                function onPolygonModeChanged() { frameCanvas.requestPaint() }
                function onScreenFrameChanged() { frameCanvas.requestPaint() }
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

                    // 4 thin outer border strips
                    ctx.fillRect(0, 0, w, t)
                    ctx.fillRect(0, h - t, w, t)
                    ctx.fillRect(0, t, t, h - t * 2)
                    ctx.fillRect(w - t, t, t, h - t * 2)

                    // 4 chamfered inner corner triangles
                    ctx.beginPath()
                    ctx.moveTo(t, t); ctx.lineTo(t + c, t); ctx.lineTo(t, t + c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(w - t, t); ctx.lineTo(w - t - c, t); ctx.lineTo(w - t, t + c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(w - t, h - t); ctx.lineTo(w - t - c, h - t); ctx.lineTo(w - t, h - t - c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(t, h - t); ctx.lineTo(t + c, h - t); ctx.lineTo(t, h - t - c); ctx.closePath(); ctx.fill()

                    // Crisp Persona 5 accent hairline along inner perimeter
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
        }
    }
}
