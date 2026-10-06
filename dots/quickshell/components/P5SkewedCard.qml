import QtQuick
import qs.config

Item {
    id: root
    property color fillColor: PhantomState.surface
    property color borderColor: PhantomState.borderLight
    property color shadowColor: PhantomState.primary
    property real borderWidth: 2
    property real skewPx: PhantomState.polygonMode ? 6 : 0
    property bool showShadowOffset: true
    property real shadowOffsetX: 3
    property real shadowOffsetY: 3
    property real radius: PhantomState.cornerRadius

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

    // mode sudut membulat saat mode poligon nonaktif
    Rectangle {
        anchors.fill: parent
        visible: !PhantomState.polygonMode
        color: root.fillColor
        radius: root.radius
        border.color: root.borderColor
        border.width: root.borderWidth
    }

    // mode poligon miring dengan bayangan aksen
    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.rightMargin: -(root.showShadowOffset ? Math.abs(root.shadowOffsetX) : 0)
        anchors.bottomMargin: -(root.showShadowOffset ? Math.abs(root.shadowOffsetY) : 0)
        visible: PhantomState.polygonMode
        antialiasing: true
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var ox = root.showShadowOffset ? Math.abs(root.shadowOffsetX) : 0
            var oy = root.showShadowOffset ? Math.abs(root.shadowOffsetY) : 0
            var w = root.width
            var h = root.height
            var s = Math.min(Math.abs(root.skewPx), w * 0.16)

            // poligon bayangan aksen di belakang
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

            // bidang utama poligon miring
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
