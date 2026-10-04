import QtQuick
import qs.config

Item {
    id: root
    width: 32
    height: 32
    property color starColor: PhantomState.borderLight
    property color innerColor: PhantomState.primary
    property color coreColor: PhantomState.background
    property bool spinning: false

    Connections {
        target: PhantomState
        function onPrimaryChanged() { starCanvas.requestPaint() }
        function onBorderLightChanged() { starCanvas.requestPaint() }
    }

    Canvas {
        id: starCanvas
        anchors.fill: parent
        antialiasing: true

        function drawStar(ctx, cx, cy, spikes, outerR, innerR, rotOffset, fillStyle) {
            var rot = Math.PI / 2 * 3 + rotOffset
            var x = cx
            var y = cy
            var step = Math.PI / spikes

            ctx.beginPath()
            ctx.moveTo(cx + Math.cos(rot) * outerR, cy + Math.sin(rot) * outerR)
            for (var i = 0; i < spikes; i++) {
                x = cx + Math.cos(rot) * outerR
                y = cy + Math.sin(rot) * outerR
                ctx.lineTo(x, y)
                rot += step

                x = cx + Math.cos(rot) * innerR
                y = cy + Math.sin(rot) * innerR
                ctx.lineTo(x, y)
                rot += step
            }
            ctx.closePath()
            ctx.fillStyle = fillStyle
            ctx.fill()
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var cx = width / 2
            var cy = height / 2
            var r = Math.min(width, height) / 2

            // lapisan bintang luar, tengah, inti gelap, dan titik pusat
            drawStar(ctx, cx, cy, 5, r, r * 0.42, -0.18, root.starColor)
            drawStar(ctx, cx, cy, 5, r * 0.74, r * 0.31, -0.10, root.innerColor)
            drawStar(ctx, cx, cy, 5, r * 0.46, r * 0.19, -0.18, root.coreColor)
            drawStar(ctx, cx, cy, 5, r * 0.22, r * 0.09, -0.10, root.starColor)
        }
    }
}
