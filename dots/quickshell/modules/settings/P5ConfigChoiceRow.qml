import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// komponen baris pemilih multi-opsi pengaturan
Item {
    id: choiceRow
    Layout.fillWidth: true
    Layout.preferredHeight: 54

    property string label: ""
    property string desc: ""
    property string currentValue: ""
    property var options: []
    signal selected(string val)

    Canvas {
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var w = width
            var h = height
            ctx.fillStyle = "#161620"
            ctx.beginPath()
            ctx.moveTo(12, 4)
            ctx.lineTo(w - 10, 2)
            ctx.lineTo(w - 22, h - 4)
            ctx.lineTo(0, h - 6)
            ctx.closePath()
            ctx.fill()
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.right: choicesLayout.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            Layout.fillWidth: true
            text: choiceRow.label
            color: "#FFFFFF"
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 15
            font.weight: Font.Black
            font.italic: true
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            text: choiceRow.desc
            color: "#9E9EAE"
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 10
            font.weight: Font.Bold
            elide: Text.ElideRight
        }
    }

    RowLayout {
        id: choicesLayout
        anchors.right: parent.right
        anchors.rightMargin: 26
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            model: choiceRow.options
            delegate: Item {
                required property var modelData
                readonly property bool isSel: choiceRow.currentValue === modelData.id
                Layout.preferredWidth: Math.max(74, optText.implicitWidth + 24)
                Layout.preferredHeight: 34

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: parent.isSel ? PhantomState.primary : "#0B0B10"
                    borderColor: parent.isSel ? "#FFFFFF" : "#444456"
                    shadowColor: parent.isSel ? PhantomState.secondary : "#000000"
                    borderWidth: parent.isSel ? 2 : 1
                    skewPx: 6
                    shadowOffsetX: 2
                    shadowOffsetY: 2
                }

                Text {
                    id: optText
                    anchors.centerIn: parent
                    text: modelData.label
                    color: parent.isSel ? "#FFFFFF" : "#BBBBCC"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 11
                    font.weight: Font.Black
                    font.italic: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: choiceRow.selected(modelData.id)
                }
            }
        }
    }
}
