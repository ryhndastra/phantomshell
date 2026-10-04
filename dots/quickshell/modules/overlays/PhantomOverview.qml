import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.config
import qs.components

// modul ikhtisar 10 ruang kerja (workspace overview) bergaya persona 5 (super + tab)
Scope {
    id: root

    readonly property int activeWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    PanelWindow {
        id: ovWin
        visible: PhantomState.overviewOpen

        WlrLayershell.namespace: "phantomshell-overview"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: PhantomState.overviewOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        exclusiveZone: 0

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        onVisibleChanged: {
            if (visible) {
                PhantomState.refreshWorkspaces()
                ovAnim.restart()
                ovKeyCatcher.forceActiveFocus()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#AA050508"
            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.overviewOpen = false
            }
        }

        Item {
            id: ovKeyCatcher
            focus: true
            Keys.onEscapePressed: PhantomState.overviewOpen = false
        }

        Item {
            id: ovCard
            width: Math.min(parent.width - 80, 940)
            height: Math.min(parent.height - 120, 440)
            anchors.centerIn: parent

            ParallelAnimation {
                id: ovAnim
                NumberAnimation { target: ovCard; property: "scale"; from: 0.88; to: 1.0; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                NumberAnimation { target: ovCard; property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            }

            P5SkewedCard {
                anchors.fill: parent
                fillColor: "#0B0B10"
                borderColor: "#FFFFFF"
                shadowColor: PhantomState.primary
                borderWidth: 3
                skewPx: 14
                shadowOffsetX: 8
                shadowOffsetY: 8
            }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    P5Star {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        spinning: true
                    }

                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "METAVERSE NAVIGATION // WORKSPACE OVERVIEW"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 18
                            font.weight: Font.Black
                            font.italic: true
                        }
                        Text {
                            text: "LEFT CLICK: JUMP TO WORKSPACE • RIGHT CLICK: SEND ACTIVE WINDOW • [SUPER+S] SCRATCHPAD"
                            color: PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // tombol buka scratchpad special workspace
                    Item {
                        Layout.preferredWidth: scratchTxt.implicitWidth + 20
                        Layout.preferredHeight: 30
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: scratchMouse.containsMouse ? PhantomState.secondary : "#181826"
                            borderColor: PhantomState.secondary
                            borderWidth: 1.5
                            skewPx: 5
                            showShadowOffset: false
                        }
                        Text {
                            id: scratchTxt
                            anchors.centerIn: parent
                            text: "★ TOGGLE SCRATCHPAD"
                            color: scratchMouse.containsMouse ? "#09090D" : PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                        MouseArea {
                            id: scratchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                PhantomState.overviewOpen = false
                                Hyprland.dispatch("hl.dsp.workspace.toggle_special('special')")
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: closeOvMouse.containsMouse ? PhantomState.primary : "#181826"
                            borderColor: "#FFFFFF"
                            borderWidth: 1.5
                            skewPx: 5
                            showShadowOffset: false
                        }
                        P5Icon { anchors.centerIn: parent; name: "close"; size: 11; color: "#FFFFFF" }
                        MouseArea {
                            id: closeOvMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.overviewOpen = false
                        }
                    }
                }

                // kisi 2 baris x 5 kolom untuk ruang kerja 1-10
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 5
                    rowSpacing: 12
                    columnSpacing: 12

                    Repeater {
                        model: 10

                        delegate: Item {
                            required property int index
                            readonly property int wsNum: index + 1
                            readonly property bool isCurrent: root.activeWsId === wsNum
                            readonly property var apps: PhantomState.workspaceApps[String(wsNum)] || []

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: parent.isCurrent ? "#1D0E14" : (wsCardMouse.containsMouse ? "#181826" : "#12121B")
                                borderColor: parent.isCurrent ? PhantomState.secondary : (parent.apps.length > 0 ? "#FFFFFF" : "#34344A")
                                shadowColor: parent.isCurrent ? PhantomState.secondary : PhantomState.primary
                                borderWidth: parent.isCurrent ? 2.5 : 1.5
                                skewPx: 8

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 6

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Rectangle {
                                            width: 24
                                            height: 20
                                            color: parent.parent.parent.parent.isCurrent ? PhantomState.primary : "#202030"
                                            border.color: "#FFFFFF"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: String(wsNum)
                                                color: "#FFFFFF"
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 11
                                                font.weight: Font.Black
                                                font.italic: true
                                            }
                                        }

                                        Text {
                                            text: parent.parent.parent.parent.isCurrent ? "ACTIVE" : (apps.length > 0 ? (apps.length + " WIN") : "EMPTY")
                                            color: parent.parent.parent.parent.isCurrent ? PhantomState.secondary : PhantomState.muted
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                        }

                                        Item { Layout.fillWidth: true }
                                    }

                                    // daftar jendela pada workspace ini
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 4

                                        Repeater {
                                            model: apps

                                            delegate: RowLayout {
                                                required property var modelData
                                                Layout.fillWidth: true
                                                spacing: 6

                                                IconImage {
                                                    Layout.preferredWidth: 14
                                                    Layout.preferredHeight: 14
                                                    source: modelData.iconUrl || ""
                                                    visible: Boolean(modelData.iconUrl)
                                                }

                                                Text {
                                                    visible: !modelData.iconUrl
                                                    text: modelData.glyph || "\uf2d0"
                                                    color: PhantomState.secondary
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 11
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: modelData.title || modelData.cls
                                                    color: "#FFFFFF"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Bold
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }

                                        Item { Layout.fillHeight: true }
                                    }
                                }
                            }

                            MouseArea {
                                id: wsCardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) {
                                        Hyprland.dispatch("hl.dsp.window.move({ workspace = " + wsNum + ", follow = false })")
                                        PhantomState.refreshWorkspaces()
                                    } else {
                                        PhantomState.overviewOpen = false
                                        Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsNum + " })")
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
