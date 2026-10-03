import QtQuick
import qs.config

Item {
    id: root
    property color fillColor: PhantomState.surface
    property color borderColor: PhantomState.borderLight
    property color shadowColor: PhantomState.primary
    property int borderWidth: 2
    property real skewPx: PhantomState.polygonMode ? 6 : 0
    property bool showShadowOffset: true
    property int shadowOffsetX: 3
    property int shadowOffsetY: 3
    property int radius: PhantomState.cornerRadius

    onFillColorChanged: canvas.requestPaint()
    onBorderColorChanged: canvas.requestPaint()
    onShadowColorChanged: canvas.requestPaint()
    onSkewPxChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Connections {
        target: PhantomState
        function onPolygonModeChanged() { canvas.requestPaint() }
        function onPrimaryChanged() { canvas.requestPaint() }
        function onSurfaceChanged() { canvas.requestPaint() }
    }

    // Sleek Rounded mode (when polygonMode is off)
    Rectangle {
        anchors.fill: parent
        visible: !PhantomState.polygonMode
        color: root.fillColor
        radius: root.radius
        border.color: root.borderColor
        border.width: root.borderWidth
    }

    // Persona 5 Skewed / Jagged Comic Polygon mode
    // Canvas extends by shadowOffsetX/Y on right/bottom so the main polygon is 100% centered on root!
    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.rightMargin: -(root.showShadowOffset ? Math.abs(root.shadowOffsetX) : 0)
        anchors.bottomMargin: -(root.showShadowOffset ? Math.abs(root.shadowOffsetY) : 0)
        visible: PhantomState.polygonMode
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var ox = root.showShadowOffset ? Math.abs(root.shadowOffsetX) : 0
            var oy = root.showShadowOffset ? Math.abs(root.shadowOffsetY) : 0
            var w = root.width
            var h = root.height
            var s = Math.min(Math.abs(root.skewPx), w * 0.16)

            // 1. Offset Crimson/Accent Shadow Polygon
            if (root.showShadowOffset) {
                ctx.fillStyle = root.shadowColor
                ctx.beginPath()
                ctx.moveTo(s + ox, oy + 1)
                ctx.lineTo(w + ox - 1, oy)
                ctx.lineTo(w - s + ox, h + oy - 1)
                ctx.lineTo(ox + 1, h + oy - 1)
                ctx.closePath()
                ctx.fill()
            }

            // 2. Main Skewed Polygon Fill — Centered symmetrically on (0..w, 0..h)!
            ctx.fillStyle = root.fillColor
            ctx.strokeStyle = root.borderColor
            ctx.lineWidth = root.borderWidth

            ctx.beginPath()
            ctx.moveTo(s, 1)
            ctx.lineTo(w - 1, 1)
            ctx.lineTo(w - s, h - 1)
            ctx.lineTo(1, h - 1)
            ctx.closePath()
            ctx.fill()
            if (root.borderWidth > 0) {
                ctx.stroke()
            }
        }
    }
}
