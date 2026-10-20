import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// section grafik social stats dengan tombol ganti mode tampilan
ColumnLayout {
    id: root

    // mode berikutnya diteruskan ke composer, mutasi state dilakukan pemanggil
    signal statsStyleToggled(string nextStyle)

    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 6

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            Layout.fillWidth: true
            text: "SYSTEM SOCIAL STATS"
            color: PhantomState.secondary
            font.pixelSize: 11
            font.weight: Font.Bold
            font.letterSpacing: 0.6
            elide: Text.ElideRight
        }

        Rectangle {
            id: modeBtn
            Layout.preferredWidth: 32
            Layout.preferredHeight: 22
            color: "transparent"
            border.color: modeMouse.containsMouse ? PhantomState.primary : Qt.rgba(1, 1, 1, 0.12)
            border.width: 1

            P5Icon {
                anchors.centerIn: parent
                name: PhantomState.statsStyle === "pentagon" ? "star" : "bars"
                size: 11
                color: modeMouse.containsMouse ? PhantomState.foreground : PhantomState.muted
            }

            MouseArea {
                id: modeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const next = (PhantomState.statsStyle === "pentagon") ? "bars" : "pentagon"
                    root.statsStyleToggled(next)
                }
            }
        }
    }

    P5PentagonStats {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 110
        Layout.preferredHeight: 170
    }
}
