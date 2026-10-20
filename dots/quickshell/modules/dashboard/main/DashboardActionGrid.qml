import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// grid enam aksi cepat sistem dengan gaya tile seragam, tanpa lencana warna pelangi
GridLayout {
    id: root

    // sinyal diteruskan ke panel utama untuk membuka sub panel jaringan
    signal requestSubPanel(string name)

    // dipertahankan untuk kompatibilitas composer, aksi jaringan tetap via sinyal
    property var dashWin: null

    Layout.fillWidth: true
    columns: 2
    rowSpacing: 8
    columnSpacing: 8

    // satu tile seragam dipakai ulang oleh keenam aksi
    component ActionTile: Item {
        id: tile

        Layout.fillWidth: true
        Layout.preferredHeight: 56
        Layout.minimumHeight: 56
        implicitHeight: 56

        required property string title
        required property string subtitle
        required property string iconName
        required property bool lit
        // aksi non toggle: ikon pakai aksen muted agar terlihat beda tanpa fill aktif
        required property bool destructive
        property bool interactive: true

        signal activated()

        // hover menaikkan tile sebesar 1px saja, tanpa scale dan tanpa tilt
        property real hoverLift: tileMouse.containsMouse && tile.interactive ? -1 : 0
        Behavior on hoverLift { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
        y: hoverLift

        P5SkewedCard {
            anchors.fill: parent
            fillColor: tile.lit
                ? PhantomState.primary
                : (tileMouse.containsMouse && tile.interactive ? PhantomState.surfaceAlt : PhantomState.surface)
            borderColor: tile.lit
                ? PhantomState.primary
                : (tileMouse.containsMouse && tile.interactive ? PhantomState.primary : "#1FFFFFFF")
            borderWidth: 1
            showShadowOffset: false
            shadowOffsetX: 0
            shadowOffsetY: 0
            skewPx: PhantomState.polygonMode ? 5 : 0
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            P5Icon {
                name: tile.iconName
                size: 18
                color: tile.lit
                    ? PhantomState.foreground
                    : (tileMouse.containsMouse ? PhantomState.foreground : PhantomState.muted)
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: tile.title
                        color: PhantomState.foreground
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 14
                        font.weight: Font.Black
                        font.italic: false
                        font.letterSpacing: -0.2
                        elide: Text.ElideRight
                    }

                    // penanda aktif tunggal, hanya muncul saat toggle menyala
                    P5Icon {
                        visible: tile.lit
                        name: "check"
                        size: 11
                        color: PhantomState.secondary
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: tile.subtitle
                    color: PhantomState.muted
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    font.weight: Font.Medium
                    font.italic: false
                    font.letterSpacing: 0.3
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: tile.interactive
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.activated()
        }
    }

    ActionTile {
        title: "WI-FI"
        subtitle: PhantomState.wifiConnected ? (PhantomState.wifiSsid + " ▸") : "RADIO OFF • OPEN MENU"
        iconName: PhantomState.wifiConnected ? "wifi" : "wifi-off"
        lit: PhantomState.wifiConnected
        destructive: false
        onActivated: root.requestSubPanel("wifi")
    }

    ActionTile {
        title: "BLUETOOTH"
        subtitle: PhantomState.btConnected ? (PhantomState.btDeviceName + " ▸") : "POWER OFF • OPEN MENU"
        iconName: "bluetooth"
        lit: PhantomState.btConnected
        destructive: false
        onActivated: root.requestSubPanel("bluetooth")
    }

    ActionTile {
        title: "STEALTH"
        subtitle: PhantomState.dndEnabled ? "DND ACTIVE (MUTED)" : "SNS POPUPS ACTIVE"
        iconName: PhantomState.dndEnabled ? "bell-off" : "bell"
        lit: PhantomState.dndEnabled
        destructive: false
        onActivated: PhantomState.dndEnabled = !PhantomState.dndEnabled
    }

    ActionTile {
        title: "POLYGON"
        subtitle: PhantomState.polygonMode ? "SKEWED P5 CUTOUTS" : "FLAT RECTANGLES"
        iconName: "polygon"
        lit: PhantomState.polygonMode
        destructive: false
        onActivated: {
            PhantomState.polygonMode = !PhantomState.polygonMode
            PhantomState.saveState()
        }
    }

    ActionTile {
        title: "AUDIO SFX"
        subtitle: PhantomState.sfxEnabled ? ("PERSONA 5 CUES • " + Math.round(PhantomState.sfxVolume * 100) + "%") : "UI SOUNDS MUTED"
        iconName: PhantomState.sfxEnabled ? "volume" : "mute"
        lit: PhantomState.sfxEnabled
        destructive: false
        onActivated: {
            PhantomState.sfxEnabled = !PhantomState.sfxEnabled
            PhantomState.saveState()
        }
    }

    // aksi non toggle, ikon redup dan tanpa fill aktif
    ActionTile {
        title: "LOCK CARD"
        subtitle: "LOCK SESSION SCREEN"
        iconName: "lock"
        lit: false
        destructive: true
        onActivated: PhantomState.lockScreen()
    }
}
