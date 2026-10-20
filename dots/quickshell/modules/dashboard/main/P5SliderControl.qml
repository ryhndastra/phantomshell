import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// slider generik reusable untuk kontrol nilai 0.0 sampai 1.0 dengan knob bintang
RowLayout {
    id: root

    property string label: ""
    property real value: 0.0
    property string valueText: ""
    property color activeColor: PhantomState.primary
    property bool enabledFlag: true
    property string leftTag: ""
    property string rightTag: ""
    property bool dimmer: false

    signal valuePicked(real pct)
    signal committed()

    readonly property real clamped: Math.max(0.0, Math.min(1.0, root.value))
    readonly property real trackInset: 26
    readonly property color dimForeground: Qt.rgba(PhantomState.foreground.r, PhantomState.foreground.g, PhantomState.foreground.b, 0.55)

    Layout.fillWidth: true
    spacing: 8

    // blok label kiri: ikon opsional, value utama, dan tag nilai
    Row {
        Layout.preferredWidth: 84
        spacing: 6

        P5Star {
            width: 14
            height: 14
            anchors.verticalCenter: parent.verticalCenter
            starColor: root.dimmer ? PhantomState.muted : root.activeColor
            innerColor: root.dimmer ? PhantomState.surfaceAlt : root.activeColor
            opacity: root.dimmer ? 0.6 : 1.0
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: root.label
                color: PhantomState.muted
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 0.4
            }

            Text {
                text: root.valueText
                color: root.dimmer ? PhantomState.muted : root.dimForeground
                font.pixelSize: 13
                font.weight: Font.Black
                font.italic: true
            }
        }
    }

    Item {
        id: track
        Layout.fillWidth: true
        Layout.preferredHeight: 28

        P5SkewedCard {
            anchors.fill: parent
            fillColor: PhantomState.surfaceAlt
            borderColor: root.dimmer ? PhantomState.surfaceAlt : Qt.rgba(1, 1, 1, 0.12)
            shadowColor: "transparent"
            showShadowOffset: false
            borderWidth: 1
            skewPx: PhantomState.polygonMode ? 3 : 0
        }

        Rectangle {
            id: fillBar
            anchors.left: parent.left
            anchors.leftMargin: root.trackInset
            anchors.verticalCenter: parent.verticalCenter
            height: 6
            width: (track.width - root.trackInset * 2) * root.clamped
            color: root.activeColor
            opacity: root.dimmer ? 0.35 : 1.0
        }

        Text {
            visible: root.leftTag !== ""
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: root.leftTag
            color: PhantomState.muted
            font.pixelSize: 8
            font.weight: Font.Bold
            opacity: root.dimmer ? 0.5 : 1.0
        }

        Text {
            visible: root.rightTag !== ""
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: root.rightTag
            color: PhantomState.muted
            font.pixelSize: 8
            font.weight: Font.Bold
            opacity: root.dimmer ? 0.5 : 1.0
        }

        P5Star {
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            x: root.trackInset + (track.width - root.trackInset * 2) * root.clamped - width / 2
            starColor: root.activeColor
            innerColor: root.activeColor
            coreColor: PhantomState.background
            opacity: root.dimmer ? 0.5 : 1.0

            Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.enabledFlag
            cursorShape: Qt.PointingHandCursor

            function setFromMouse(mx) {
                var span = track.width - root.trackInset * 2
                if (span <= 0) return
                var pct = Math.round(Math.max(0, Math.min(100, ((mx - root.trackInset) / span) * 100)))
                root.valuePicked(pct)
            }

            onPressed: mouse => setFromMouse(mouse.x)
            onPositionChanged: mouse => { if (pressed) setFromMouse(mouse.x) }
            onReleased: root.committed()
        }
    }
}
