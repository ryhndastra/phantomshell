import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// komponen baris slider nilai numerik pengaturan
Item {
    id: sliderRow
    Layout.fillWidth: true
    Layout.preferredHeight: 52

    property string label: ""
    property string desc: ""
    property real minVal: 0
    property real maxVal: 100
    property real currentVal: 50
    property string unit: ""
    signal valueModified(real newValue)

    Canvas {
        anchors.fill: parent
        property color accent: PhantomState.primary
        onAccentChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width
            var h = height
            var rightX = w - 290

            ctx.fillStyle = "#181822"
            ctx.beginPath()
            ctx.moveTo(12, 4)
            ctx.lineTo(rightX + 20, 2)
            ctx.lineTo(rightX + 8, h - 4)
            ctx.lineTo(0, h - 6)
            ctx.closePath()
            ctx.fill()

            // bingkai kontrol slider di sisi kanan
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
        anchors.leftMargin: 26
        anchors.right: parent.right
        anchors.rightMargin: 305
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            Layout.fillWidth: true
            text: sliderRow.label
            color: "#FFFFFF"
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 15
            font.weight: Font.Black
            font.italic: true
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            text: sliderRow.desc
            color: "#9E9EAE"
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 10
            font.weight: Font.Bold
            elide: Text.ElideRight
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 28
        anchors.verticalCenter: parent.verticalCenter
        width: 256
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            color: "#1F1F28"
            border.color: "#FFFFFF"
            border.width: 1
            P5Icon { anchors.centerIn: parent; name: "minus"; size: 9; color: "#FFFFFF" }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var step = (sliderRow.maxVal - sliderRow.minVal) >= 20 ? 2 : 1
                    sliderRow.valueModified(Math.max(sliderRow.minVal, sliderRow.currentVal - step))
                }
            }
        }

        Item {
            id: trackArea
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            readonly property real ratio: Math.min(1.0, Math.max(0.0, (sliderRow.currentVal - sliderRow.minVal) / Math.max(1, sliderRow.maxVal - sliderRow.minVal)))

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 6
                color: "#262632"
                border.color: "#FFFFFF"
                border.width: 1

                Rectangle {
                    width: parent.width * trackArea.ratio
                    height: parent.height
                    color: PhantomState.primary
                }
            }

            P5Star {
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                x: (trackArea.width - 20) * trackArea.ratio
                starColor: PhantomState.secondary
                innerColor: "#08080A"
                coreColor: PhantomState.primary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                function updateFromMouse(mx) {
                    var r = Math.min(1.0, Math.max(0.0, mx / Math.max(1, trackArea.width)))
                    sliderRow.valueModified(Math.round(sliderRow.minVal + r * (sliderRow.maxVal - sliderRow.minVal)))
                }
                onPressed: mouse => updateFromMouse(mouse.x)
                onPositionChanged: mouse => { if (pressed) updateFromMouse(mouse.x) }
            }
        }

        Rectangle {
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            color: "#1F1F28"
            border.color: "#FFFFFF"
            border.width: 1
            P5Icon { anchors.centerIn: parent; name: "plus"; size: 9; color: "#FFFFFF" }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var step = (sliderRow.maxVal - sliderRow.minVal) >= 20 ? 2 : 1
                    sliderRow.valueModified(Math.min(sliderRow.maxVal, sliderRow.currentVal + step))
                }
            }
        }

        Text {
            Layout.preferredWidth: 46
            horizontalAlignment: Text.AlignRight
            text: Math.round(sliderRow.currentVal) + sliderRow.unit
            color: PhantomState.secondary
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 13
            font.weight: Font.Black
        }
    }
}
