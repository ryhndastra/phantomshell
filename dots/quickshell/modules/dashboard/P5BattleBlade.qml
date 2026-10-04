import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// komponen bilah tombol aksi berbentuk baji segitiga dengan lencana ikon bulat
Item {
    id: blade
    Layout.fillWidth: true
    Layout.preferredHeight: 54
    Layout.minimumHeight: 46
    implicitHeight: 54

    property string title: "COMMAND"
    property string subtitle: "Execute Action"
    property string iconName: "star"
    property string badgeTag: "A"
    property color badgeColor: "#00F59B"
    property bool active: false
    property real bladeTilt: -2.0
    property bool tailOnRight: false
    property real fanProgress: 1.0
    signal clicked()

    property real hoverScale: bladeMouse.containsMouse ? 1.05 : 1.0
    property real hoverTiltOffset: bladeMouse.containsMouse
        ? (tailOnRight ? (bladeTilt >= 0 ? 1.5 : -1.5) : -1.5)
        : 0.0
    Behavior on hoverScale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }
    Behavior on hoverTiltOffset { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

    transformOrigin: tailOnRight ? Item.Right : Item.Left
    scale: hoverScale
    rotation: (bladeTilt * fanProgress) + hoverTiltOffset

    Canvas {
        id: bladeCanvas
        anchors.fill: parent
        property bool isAct: blade.active
        property bool isHov: bladeMouse.containsMouse
        property bool isRightTail: blade.tailOnRight
        property color cPrimary: PhantomState.primary
        property color cSecondary: PhantomState.secondary
        property color cBadge: blade.badgeColor
        onIsActChanged: requestPaint()
        onIsHovChanged: requestPaint()
        onIsRightTailChanged: requestPaint()
        onCPrimaryChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width
            var h = height

            if (!isRightTail) {
                // orientasi bilah dari kiri ke kanan
                var tipX = 2
                var tipY = h * 0.52
                var bx = 38
                var by = h * 0.48
                var br = 13.5

                // poligon bayangan merah bertingkat
                ctx.fillStyle = (isAct || isHov) ? "#FF1E2E" : "#E60012"
                ctx.beginPath()
                ctx.moveTo(tipX, tipY + 1)
                ctx.lineTo(bx, tipY - 3)
                ctx.lineTo(w - 2, 10)
                ctx.lineTo(w, 34)
                ctx.lineTo(w - 8, 35)
                ctx.lineTo(w - 5, h - 1)
                ctx.lineTo(w * 0.42, h - 4)
                ctx.lineTo(w * 0.40, h - 13)
                ctx.lineTo(bx - 4, tipY + 7)
                ctx.closePath()
                ctx.fill()

                // bidang baji segitiga hitam utama
                ctx.fillStyle = "#05060A"
                ctx.beginPath()
                ctx.moveTo(tipX, tipY)
                ctx.lineTo(bx, by - 6)
                ctx.lineTo(w - 10, 3)
                ctx.lineTo(w - 6, 31)
                ctx.lineTo(bx, by + 6)
                ctx.closePath()
                ctx.fill()

                // kotak label subjudul di bagian kanan bawah
                ctx.fillStyle = "#05060A"
                ctx.beginPath()
                ctx.moveTo(w * 0.36, 28)
                ctx.lineTo(w - 14, 26)
                ctx.lineTo(w - 11, h - 7)
                ctx.lineTo(w * 0.38, h - 9)
                ctx.closePath()
                ctx.fill()

                // lingkaran lencana ikon dengan cincin tepi putih
                ctx.fillStyle = "#FFFFFF"
                ctx.beginPath()
                ctx.arc(bx, by, br + 2.8, 0, Math.PI * 2)
                ctx.fill()

                ctx.fillStyle = "#05060A"
                ctx.beginPath()
                ctx.arc(bx, by, br, 0, Math.PI * 2)
                ctx.fill()
            } else {
                // orientasi bilah dari kanan ke kiri untuk menu radial
                var rTipX = w - 2
                var rTipY = h * 0.52
                var rbx = w - 42
                var rby = h * 0.48
                var rbr = 14.0

                // poligon bayangan merah bertingkat dengan garis tepi putih
                ctx.fillStyle = (isAct || isHov) ? "#FF2434" : "#E60012"
                ctx.strokeStyle = "#FFFFFF"
                ctx.lineWidth = 1.2
                ctx.beginPath()
                ctx.moveTo(rTipX, rTipY + 1)
                ctx.lineTo(rbx, rTipY - 3)
                ctx.lineTo(2, 10)
                ctx.lineTo(0, 34)
                ctx.lineTo(10, 35)
                ctx.lineTo(6, h - 1)
                ctx.lineTo(w * 0.60, h - 4)
                ctx.lineTo(w * 0.62, h - 13)
                ctx.lineTo(rbx + 4, rTipY + 7)
                ctx.closePath()
                ctx.fill()
                ctx.stroke()

                // bidang baji segitiga hitam utama melebar ke kiri
                ctx.fillStyle = "#05060A"
                ctx.beginPath()
                ctx.moveTo(rTipX, rTipY)
                ctx.lineTo(rbx, rby - 6)
                ctx.lineTo(12, 3)
                ctx.lineTo(8, 31)
                ctx.lineTo(rbx, rby + 6)
                ctx.closePath()
                ctx.fill()

                // kotak label subjudul di bagian kiri bawah
                ctx.fillStyle = "#05060A"
                ctx.beginPath()
                ctx.moveTo(w * 0.64, 28)
                ctx.lineTo(16, 26)
                ctx.lineTo(13, h - 7)
                ctx.lineTo(w * 0.62, h - 9)
                ctx.closePath()
                ctx.fill()

                // lingkaran lencana ikon di pangkal kanan
                ctx.fillStyle = "#FFFFFF"
                ctx.beginPath()
                ctx.arc(rbx, rby, rbr + 3.0, 0, Math.PI * 2)
                ctx.fill()

                ctx.fillStyle = "#05060A"
                ctx.beginPath()
                ctx.arc(rbx, rby, rbr, 0, Math.PI * 2)
                ctx.fill()
            }
        }
    }

    // ikon vektor di dalam lencana bulat
    P5Icon {
        x: blade.tailOnRight ? (parent.width - 49) : 31
        y: parent.height * 0.48 - 7
        name: blade.iconName
        size: 14
        color: blade.badgeColor
    }

    // teks judul utama bilah perintah
    Text {
        x: blade.tailOnRight ? 20 : 58
        y: 5
        width: parent.width - 82
        horizontalAlignment: blade.tailOnRight ? Text.AlignRight : Text.AlignLeft
        text: blade.title
        color: (blade.active || bladeMouse.containsMouse) ? PhantomState.secondary : "#FFFFFF"
        font.family: "JetBrainsMono NFM"
        font.pixelSize: 17
        font.weight: Font.Black
        font.italic: true
        font.letterSpacing: -0.5
        rotation: blade.tailOnRight ? 2.2 : -2.2
        elide: Text.ElideRight
    }

    // teks subjudul di dalam kotak label bawah
    Text {
        x: blade.tailOnRight ? 20 : (parent.width * 0.39)
        y: parent.height - 22
        width: parent.width * 0.54
        horizontalAlignment: blade.tailOnRight ? Text.AlignLeft : Text.AlignRight
        text: blade.subtitle
        color: "#FFFFFF"
        font.family: "JetBrainsMono NFM"
        font.pixelSize: 9
        font.weight: Font.Black
        font.italic: true
        elide: Text.ElideRight
    }

    MouseArea {
        id: bladeMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: blade.clicked()
    }
}
