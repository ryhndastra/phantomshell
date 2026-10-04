import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// komponen baris tombol toggle pengaturan
Item {
    id: toggleRow
    Layout.fillWidth: true
    Layout.preferredHeight: 50

    property string label: ""
    property string desc: ""
    property string valueText: "ON"
    property bool active: true
    signal triggered()

    Canvas {
        anchors.fill: parent
        property bool isOn: toggleRow.active
        property bool isHov: rowMouse.containsMouse
        property color accent: PhantomState.primary
        onIsOnChanged: requestPaint()
        onIsHovChanged: requestPaint()
        onAccentChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width
            var h = height
            var rightX = w - 210

            // bilah miring kiri saat opsi aktif atau di-hover
            ctx.fillStyle = (isOn || isHov) ? accent : "#16161F"
            ctx.beginPath()
            ctx.moveTo(12, 4)
            ctx.lineTo(rightX + 20, 2)
            ctx.lineTo(rightX + 8, h - 4)
            ctx.lineTo(0, h - 6)
            ctx.closePath()
            ctx.fill()

            if (isOn || isHov) {
                // aksen garis putih di sisi kiri bilah
                ctx.fillStyle = "#FFFFFF"
                ctx.beginPath()
                ctx.moveTo(0, h - 6)
                ctx.lineTo(14, 4)
                ctx.lineTo(22, 4)
                ctx.lineTo(8, h - 6)
                ctx.closePath()
                ctx.fill()
            }

            // bingkai nilai di sisi kanan dengan lekukan panah
            ctx.fillStyle = "#FFFFFF"
            ctx.beginPath()
            ctx.moveTo(rightX, 2)
            ctx.lineTo(w - 10, 0)
            ctx.lineTo(w - 22, h - 2)
            ctx.lineTo(rightX - 10, h - 2)
            ctx.lineTo(rightX - 5, h * 0.65)
            ctx.lineTo(rightX - 20, h * 0.50)
            ctx.lineTo(rightX - 4, h * 0.35)
            ctx.closePath()
            ctx.fill()

            ctx.fillStyle = "#08080A"
            ctx.beginPath()
            ctx.moveTo(rightX + 7, 6)
            ctx.lineTo(w - 17, 4)
            ctx.lineTo(w - 28, h - 6)
            ctx.lineTo(rightX - 3, h - 6)
            ctx.closePath()
            ctx.fill()
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.leftMargin: 28
        anchors.right: parent.right
        anchors.rightMargin: 225
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            Layout.fillWidth: true
            text: toggleRow.label
            color: "#FFFFFF"
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 15
            font.weight: Font.Black
            font.italic: true
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            text: toggleRow.desc
            color: (toggleRow.active || rowMouse.containsMouse) ? "#08080A" : "#9E9EAE"
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 10
            font.weight: Font.Bold
            elide: Text.ElideRight
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        P5Icon {
            name: toggleRow.active ? "star" : "close"
            color: toggleRow.active ? PhantomState.secondary : "#777777"
            size: 13
        }
        Text {
            text: toggleRow.valueText
            color: toggleRow.active ? PhantomState.secondary : "#999999"
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 14
            font.weight: Font.Black
            font.italic: true
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: toggleRow.triggered()
    }
}
