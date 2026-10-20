import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// header calling card panel, bintang statis plus tombol tutup
RowLayout {
    id: root

    signal closeRequested()

    Layout.fillWidth: true
    spacing: 10

    P5Star {
        Layout.preferredWidth: 20
        Layout.preferredHeight: 20
        spinning: false
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Text {
            Layout.fillWidth: true
            text: "THIEVES DEN // CONTROL CENTER"
            color: PhantomState.primary
            font.pixelSize: 16
            font.weight: Font.Black
            font.italic: false
            font.letterSpacing: -0.5
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: "joker, battery " + PhantomState.batteryPct + " persen, " + PhantomState.themeName
            color: PhantomState.muted
            font.pixelSize: 9
            elide: Text.ElideRight
        }
    }

    Rectangle {
        id: closeBtn
        width: 24
        height: 24
        color: closeMouse.containsMouse ? PhantomState.primary : PhantomState.surfaceAlt
        border.color: closeMouse.containsMouse ? PhantomState.primary : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        P5Icon {
            anchors.centerIn: parent
            name: "close"
            size: 11
            color: closeMouse.containsMouse ? PhantomState.foreground : PhantomState.muted
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeRequested()
        }
    }
}
