import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// tombol pembuka unified settings, satu satunya elemen dengan border 2px
Item {
    id: root

    Layout.fillWidth: true
    Layout.preferredHeight: 40
    Layout.minimumHeight: 40
    implicitHeight: 40
    z: 10

    P5SkewedCard {
        anchors.fill: parent
        fillColor: openMouse.containsMouse ? PhantomState.primary : PhantomState.surface
        borderColor: PhantomState.primary
        shadowColor: PhantomState.primary
        borderWidth: 2
        skewPx: PhantomState.polygonMode ? 6 : 0
        shadowOffsetX: 3
        shadowOffsetY: 3
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        P5Icon {
            name: "settings"
            size: 14
            color: PhantomState.secondary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "OPEN UNIFIED SETTINGS"
            color: PhantomState.foreground
            font.pixelSize: 12
            font.weight: Font.Black
            font.letterSpacing: 0.5
            font.italic: false
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: openMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            PhantomState.playSfx("select")
            PhantomState.toggleSettings()
        }
    }
}
