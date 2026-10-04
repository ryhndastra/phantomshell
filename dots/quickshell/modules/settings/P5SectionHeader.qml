import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// komponen header sub-bagian pengaturan
Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 30
    property string text: ""

    RowLayout {
        anchors.fill: parent
        spacing: 8
        P5Icon { name: "star"; size: 12; color: PhantomState.secondary }
        Text {
            text: parent.parent.text
            color: PhantomState.secondary
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 12
            font.weight: Font.Black
            font.italic: true
        }
        Rectangle {
            Layout.fillWidth: true
            height: 1.5
            color: PhantomState.primary
            opacity: 0.65
        }
    }
}
