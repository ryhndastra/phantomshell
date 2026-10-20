import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// baris tiga chip pemilih preset tema cepat
RowLayout {
    id: root

    // diteruskan ke panel utama, aksi sebenarnya dilakukan pemanggil
    signal presetChosen(string id)

    Layout.fillWidth: true
    spacing: 8

    // daftar preset yang ditampilkan, urutan tampil p5 p3 p4
    readonly property var themeOrder: [
        { id: "p5-crimson", icon: "phantom", label: "P5 CRIMSON" },
        { id: "p3-reload", icon: "moon", label: "P3 RELOAD" },
        { id: "p4-golden", icon: "tv", label: "P4 GOLDEN" }
    ]

    Repeater {
        model: root.themeOrder

        delegate: Item {
            id: chip

            required property var modelData
            readonly property bool isCurrent: PhantomState.themeId === modelData.id
            readonly property bool isHover: chipMouse.containsMouse

            Layout.fillWidth: true
            Layout.preferredHeight: 32
            Layout.minimumHeight: 32
            implicitHeight: 32

            P5SkewedCard {
                anchors.fill: parent
                fillColor: chip.isCurrent
                    ? PhantomState.secondary
                    : (chip.isHover ? PhantomState.surfaceAlt : PhantomState.surface)
                borderColor: chip.isCurrent ? PhantomState.secondary : "#1FFFFFFF"
                borderWidth: 1
                showShadowOffset: false
                shadowOffsetX: 0
                shadowOffsetY: 0
                skewPx: PhantomState.polygonMode ? 3 : 0
            }

            Row {
                anchors.centerIn: parent
                spacing: 6

                P5Icon {
                    name: chip.modelData.icon
                    size: 13
                    color: chip.isCurrent ? PhantomState.background : PhantomState.muted
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: chip.modelData.label
                    color: chip.isCurrent ? PhantomState.background : PhantomState.muted
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.italic: false
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: chipMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.presetChosen(chip.modelData.id)
            }
        }
    }
}
