import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

Scope {
    PanelWindow {
        id: sessionWin
        visible: PhantomState.sessionOpen

        WlrLayershell.namespace: "phantomshell-session"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "#CC060609"

        MouseArea {
            anchors.fill: parent
            onClicked: PhantomState.sessionOpen = false
        }

        Item {
            width: Math.min(540, parent.width - 32)
            height: Math.min(280, parent.height - 64)
            anchors.centerIn: parent

            MouseArea { anchors.fill: parent }

            P5SkewedCard {
                anchors.fill: parent
                fillColor: PhantomState.background
                borderColor: PhantomState.borderLight
                shadowColor: PhantomState.primary
                borderWidth: 2
                skewPx: PhantomState.polygonMode ? 10 : 0
                shadowOffsetX: 5
                shadowOffsetY: 5
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    P5Star {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        spinning: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
                            text: "TAKE YOUR TIME // CALLING CARD SESSION"
                            color: PhantomState.primary
                            font.pixelSize: 16
                            font.weight: Font.Black
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "Select a Metaverse session action below"
                            color: PhantomState.muted
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    // daftar aksi power & session
                    // ubah array cmd di bawah kalau mau ganti perintah suspend/logout/reboot
                    Repeater {
                        model: [
                            { icon: "lock",   label: "LOCK",     action: "lock", cmd: [] },
                            { icon: "moon",   label: "SUSPEND",  action: "cmd",  cmd: ["systemctl", "suspend"] },
                            { icon: "logout", label: "LOGOUT",   action: "cmd",  cmd: ["hyprctl", "dispatch", "exit"] },
                            { icon: "reboot", label: "REBOOT",   action: "cmd",  cmd: ["systemctl", "reboot"] },
                            { icon: "power",  label: "POWEROFF", action: "cmd",  cmd: ["systemctl", "poweroff"] }
                        ]

                        delegate: Item {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: btnMouse.containsMouse ? PhantomState.primary : PhantomState.surface
                                borderColor: PhantomState.borderLight
                                shadowColor: btnMouse.containsMouse ? PhantomState.secondary : PhantomState.borderDark
                                borderWidth: 2
                                skewPx: PhantomState.polygonMode ? 6 : 0
                                shadowOffsetX: 3
                                shadowOffsetY: 3
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                P5Icon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    name: modelData.icon
                                    size: 18
                                    color: PhantomState.foreground
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    color: PhantomState.foreground
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                }
                            }

                            MouseArea {
                                id: btnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    PhantomState.sessionOpen = false
                                    if (modelData.action === "lock") {
                                        PhantomState.lockScreen()
                                    } else {
                                        Quickshell.execDetached(modelData.cmd)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
