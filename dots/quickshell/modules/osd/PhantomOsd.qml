import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

Scope {
    PanelWindow {
        id: osdWin
        visible: PhantomState.osdVisible

        WlrLayershell.namespace: "phantomshell-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            bottom: true
        }
        margins.bottom: 72

        implicitWidth: 340
        implicitHeight: 74
        color: "transparent"

        Item {
            anchors.fill: parent
            rotation: PhantomState.polygonMode ? -3 : 0

            P5SkewedCard {
                anchors.fill: parent
                fillColor: PhantomState.background
                borderColor: PhantomState.borderLight
                shadowColor: PhantomState.primary
                borderWidth: 3
                skewPx: PhantomState.polygonMode ? 12 : 0
                shadowOffsetX: 5
                shadowOffsetY: 5
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 22
                anchors.rightMargin: 22
                spacing: 12

                P5Star {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: PhantomState.osdLabel + " GAUGE"
                            color: PhantomState.primary
                            font.pixelSize: 12
                            font.weight: Font.Black
                            font.italic: true
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: PhantomState.osdValue + "%"
                            color: PhantomState.secondary
                            font.pixelSize: 16
                            font.weight: Font.Black
                            font.italic: true
                        }
                    }

                    // Slanted P5 HP/SP Gauge Bar
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: PhantomState.surfaceAlt
                            borderColor: PhantomState.borderLight
                            showShadowOffset: false
                            borderWidth: 1
                            skewPx: 6
                        }

                        P5SkewedCard {
                            width: Math.max(14, parent.width * Math.min(1.0, PhantomState.osdValue / 100.0))
                            height: parent.height
                            fillColor: PhantomState.secondary
                            borderColor: "transparent"
                            showShadowOffset: false
                            borderWidth: 0
                            skewPx: 6
                        }
                    }
                }
            }
        }
    }
}
