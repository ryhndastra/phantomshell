import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.config
import qs.components

// jendela popup daftar aplikasi system tray bergaya persona 5
PanelWindow {
    id: trayPopupWin
    visible: PhantomState.trayPopupOpen

    HyprlandFocusGrab {
        active: PhantomState.trayPopupOpen
        windows: [trayPopupWin]
        onCleared: PhantomState.trayPopupOpen = false
    }

    readonly property bool isBottom: PhantomState.barPosition === "bottom"

    WlrLayershell.namespace: "phantomshell-tray-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusiveZone: 0

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins {
        top: trayPopupWin.isBottom ? 0 : 38
        bottom: trayPopupWin.isBottom ? 38 : 0
    }

    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            trayPopupAnim.restart()
        }
    }

    // area klik luar untuk menutup popup saat klik di tempat kosong
    MouseArea {
        anchors.fill: parent
        onClicked: PhantomState.trayPopupOpen = false
    }

    Item {
        id: trayCard
        width: 280
        height: Math.max(110, 56 + trayListCol.implicitHeight + 18)
        anchors.top: !trayPopupWin.isBottom ? parent.top : undefined
        anchors.bottom: trayPopupWin.isBottom ? parent.bottom : undefined
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        anchors.rightMargin: 150
        transformOrigin: trayPopupWin.isBottom ? Item.BottomRight : Item.TopRight

        // penahan klik agar klik di dalam kartu tidak menutup popup
        MouseArea {
            anchors.fill: parent
        }

        ParallelAnimation {
            id: trayPopupAnim
            NumberAnimation {
                target: trayCard
                property: "scale"
                from: 0.85
                to: 1.0
                duration: 210
                easing.type: Easing.OutBack
                easing.overshoot: 1.3
            }
            NumberAnimation {
                target: trayCard
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        P5SkewedCard {
            anchors.fill: parent
            fillColor: PhantomState.surface
            borderColor: PhantomState.borderLight
            shadowColor: PhantomState.primary
            borderWidth: 2.5
            skewPx: PhantomState.polygonMode ? 8 : 0
            shadowOffsetX: 5
            shadowOffsetY: 5
        }

        // pita tajuk atas bergaya persona 5
        Item {
            id: headerBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            height: 28

            P5SkewedCard {
                anchors.fill: parent
                fillColor: PhantomState.primary
                borderColor: PhantomState.borderLight
                showShadowOffset: false
                borderWidth: 1.5
                skewPx: PhantomState.polygonMode ? 5 : 0
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                P5Star {
                    width: 14
                    height: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spinning: true
                }

                Text {
                    text: "ACTIVE BACKSTAGE APPS"
                    color: PhantomState.foreground
                    font.pixelSize: 10
                    font.weight: Font.Black
                    font.italic: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: countBadgeTxt.implicitWidth + 10
                height: 16
                color: PhantomState.background
                border.color: PhantomState.borderLight
                border.width: 1

                Text {
                    id: countBadgeTxt
                    anchors.centerIn: parent
                    text: String(SystemTray.items.values.length)
                    color: PhantomState.secondary
                    font.pixelSize: 9
                    font.weight: Font.Black
                }
            }
        }

        // daftar aplikasi latar belakang di system tray
        Column {
            id: trayListCol
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 6

            Repeater {
                model: SystemTray.items

                delegate: Item {
                    id: trayEntry
                    required property SystemTrayItem modelData
                    required property int index
                    width: trayListCol.width
                    height: 36

                    readonly property string displayTitle: {
                        const t = modelData.title || modelData.tooltipTitle || modelData.id || "Background App"
                        return String(t).replace(/^_/, "")
                    }

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: entryMouse.containsMouse ? PhantomState.primary : PhantomState.surfaceAlt
                        borderColor: entryMouse.containsMouse ? PhantomState.borderLight : "transparent"
                        shadowColor: PhantomState.secondary
                        showShadowOffset: entryMouse.containsMouse
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                        borderWidth: entryMouse.containsMouse ? 1.5 : 1
                        skewPx: PhantomState.polygonMode ? 5 : 0
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.right: hintLabel.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        IconImage {
                            width: 18
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter
                            source: trayEntry.modelData.icon
                            asynchronous: true
                        }

                        Text {
                            width: parent.width - 30
                            anchors.verticalCenter: parent.verticalCenter
                            text: trayEntry.displayTitle.toUpperCase()
                            color: PhantomState.foreground
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        id: hintLabel
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: entryMouse.containsMouse ? "OPEN ▸" : "TRAY"
                        color: entryMouse.containsMouse ? PhantomState.secondary : PhantomState.muted
                        font.pixelSize: 9
                        font.weight: Font.Black
                        font.italic: true
                    }

                    MouseArea {
                        id: entryMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                if (trayEntry.modelData.onlyMenu && trayEntry.modelData.hasMenu) {
                                    const pos = trayEntry.mapToItem(null, 0, trayEntry.height + 2)
                                    trayEntry.modelData.display(trayPopupWin, Math.max(8, pos.x), pos.y)
                                } else {
                                    trayEntry.modelData.activate()
                                    PhantomState.trayPopupOpen = false
                                }
                            } else if (mouse.button === Qt.RightButton) {
                                if (trayEntry.modelData.hasMenu) {
                                    const pos = trayEntry.mapToItem(null, 0, trayEntry.height + 2)
                                    trayEntry.modelData.display(trayPopupWin, Math.max(8, pos.x), pos.y)
                                } else {
                                    trayEntry.modelData.secondaryActivate()
                                    PhantomState.trayPopupOpen = false
                                }
                            } else if (mouse.button === Qt.MiddleButton) {
                                trayEntry.modelData.secondaryActivate()
                                PhantomState.trayPopupOpen = false
                            }
                        }
                    }
                }
            }
        }
    }
}
