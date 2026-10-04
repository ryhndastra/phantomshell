import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

Scope {
    // jendela popup balon notifikasi pesan di pojok kanan layar
    PanelWindow {
        id: popupWin
        visible: PhantomState.imPopupStack.count > 0 && !PhantomState.notificationsOpen

        readonly property bool isBottom: PhantomState.barPosition === "bottom"

        WlrLayershell.namespace: "phantomshell-im-popup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            top: !popupWin.isBottom
            bottom: popupWin.isBottom
            right: true
        }
        margins {
            top: 44
            bottom: 44
            right: 10
        }

        implicitWidth: 445
        implicitHeight: Math.min(460, popupCol.implicitHeight + 16)
        color: "transparent"

        Column {
            id: popupCol
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 10

            Repeater {
                model: PhantomState.imPopupStack
                delegate: P5ComicBubble {
                    required property string senderName
                    required property string msgBody
                    required property string msgTime
                    required property string msgUrgency
                    required property string msgIcon
                    required property int index

                    sender: senderName
                    message: msgBody
                    timeText: msgTime
                    urgency: msgUrgency
                    appIcon: msgIcon
                    onDismissed: PhantomState.dismissPopup(index)
                }
            }
        }
    }

    // panel pusat riwayat notifikasi pesan
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: snsPhoneWin
            required property ShellScreen modelData
            screen: modelData
            visible: PhantomState.notificationsOpen

            HyprlandFocusGrab {
                active: PhantomState.notificationsOpen
                windows: [snsPhoneWin]
                onCleared: PhantomState.notificationsOpen = false
            }

            readonly property bool isBottom: PhantomState.barPosition === "bottom"

            WlrLayershell.namespace: "phantomshell-sns-phone"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusiveZone: 0

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            margins {
                top: snsPhoneWin.isBottom ? 0 : 38
                bottom: snsPhoneWin.isBottom ? 38 : 0
            }

            color: "transparent"

            onVisibleChanged: {
                if (visible) snsEntryAnim.restart()
            }

            // area klik luar untuk menutup panel sns saat klik di tempat kosong
            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.notificationsOpen = false
            }

            Item {
                id: snsCard
                width: Math.min(430, parent.width - 20)
                height: Math.min(490, parent.height - 14)
                anchors.top: !snsPhoneWin.isBottom ? parent.top : undefined
                anchors.bottom: snsPhoneWin.isBottom ? parent.bottom : undefined
                anchors.right: parent.right
                anchors.topMargin: 4
                anchors.bottomMargin: 4
                anchors.rightMargin: 10
                transformOrigin: snsPhoneWin.isBottom ? Item.BottomRight : Item.TopRight

                // penahan klik agar klik di dalam kartu sns tidak menutup panel
                MouseArea {
                    anchors.fill: parent
                }

                ParallelAnimation {
                    id: snsEntryAnim
                    NumberAnimation {
                        target: snsCard
                        property: "scale"
                        from: 0.85
                        to: 1.0
                        duration: 240
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.35
                    }
                    NumberAnimation {
                        target: snsCard
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: PhantomState.background
                    borderColor: PhantomState.borderLight
                    shadowColor: PhantomState.primary
                    borderWidth: 2
                    skewPx: PhantomState.polygonMode ? 8 : 0
                    shadowOffsetX: 4
                    shadowOffsetY: 4
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    // baris header pusat notifikasi
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        P5Star {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                Layout.fillWidth: true
                                text: "PHANTOM IM // SNS LOG"
                                color: PhantomState.primary
                                font.pixelSize: 15
                                font.weight: Font.Black
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Persona 5 Instant Messaging & Alerts"
                                color: PhantomState.muted
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                        }

                        // tombol pengirim notifikasi uji coba
                        Item {
                            Layout.preferredWidth: testBtnRow.implicitWidth + 20
                            Layout.preferredHeight: 28

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.primary
                                borderColor: PhantomState.borderLight
                                shadowColor: PhantomState.borderDark
                                borderWidth: 1
                                skewPx: 4
                                shadowOffsetX: 2
                                shadowOffsetY: 2
                            }

                            Row {
                                id: testBtnRow
                                anchors.centerIn: parent
                                spacing: 4
                                P5Icon { name: "plus"; size: 9; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "TEST IM"
                                    color: PhantomState.foreground
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    PhantomState.notificationsOpen = false
                                    PhantomState.sendTestNotification()
                                }
                            }
                        }

                        // tombol penghapus seluruh riwayat notifikasi
                        Item {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 28

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.surfaceAlt
                                borderColor: PhantomState.borderLight
                                showShadowOffset: false
                                borderWidth: 1
                                skewPx: 4
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "CLEAR"
                                color: PhantomState.foreground
                                font.pixelSize: 9
                                font.weight: Font.Black
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.imNotifications.clear()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: PhantomState.primary
                    }

                    // daftar riwayat pesan masuk dan tampilan kosong
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            visible: PhantomState.imNotifications.count === 0

                            P5Star {
                                width: 38
                                height: 38
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "NO NEW MESSAGES"
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                font.weight: Font.Black
                                font.italic: true
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Your SNS inbox is clear — Take Your Time."
                                color: PhantomState.muted
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }
                        }

                        ListView {
                            id: chatList
                            anchors.fill: parent
                            clip: true
                            spacing: 12
                            visible: PhantomState.imNotifications.count > 0
                            model: PhantomState.imNotifications

                            delegate: P5ComicBubble {
                                required property string senderName
                                required property string msgBody
                                required property string msgTime
                                required property string msgUrgency
                                required property string msgIcon
                                required property int index

                                width: chatList.width - 6
                                sender: senderName
                                message: msgBody
                                timeText: msgTime
                                urgency: msgUrgency
                                appIcon: msgIcon
                                onDismissed: PhantomState.imNotifications.remove(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
