import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

// Dialogue toast notifications.
Scope {
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
            top: 48
            bottom: 48
            right: 18
        }

        implicitWidth: 440
        implicitHeight: Math.min(520, popupCol.implicitHeight + 24)
        color: "transparent"

        Column {
            id: popupCol
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 16

            Repeater {
                model: PhantomState.imPopupStack
                delegate: Item {
                    id: p3ToastRoot
                    required property string senderName
                    required property string msgBody
                    required property string msgTime
                    required property string msgUrgency
                    required property string msgIcon
                    required property int index

                    width: 410
                    height: Math.max(90, toastLayout.implicitHeight + 36)

                    readonly property string resolvedIcon: {
                        const ic = (msgIcon || "").trim()
                        const lowerName = (senderName || "").toLowerCase()
                        const lowerIcon = ic.toLowerCase()
                        const lowerDesc = (msgBody || "").toLowerCase()
                        if (lowerIcon.indexOf("whatsapp") !== -1 || lowerName.indexOf("whatsapp") !== -1 || lowerDesc.indexOf("whatsapp") !== -1) {
                            return "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/icons/whatsapp.svg"
                        }
                        if (lowerIcon.indexOf("zen") !== -1 || lowerName.indexOf("zen") !== -1) {
                            return "file:///etc/profiles/per-user/sho/share/icons/hicolor/128x128/apps/zen-browser.png"
                        }
                        if (ic.startsWith("file://") || ic.startsWith("/")) {
                            return ic.startsWith("/") ? ("file://" + ic) : ic
                        }
                        if (ic.startsWith("image://")) return ic
                        if (ic.length > 0) {
                            const r = Quickshell.iconPath(ic, true)
                            if (r && String(r).length > 0) return r
                        }
                        return PhantomState.resolveAppIconUrl(senderName)
                    }

                    // Slide-in enter animation
                    ParallelAnimation {
                        id: toastEnterAnim
                        running: true
                        NumberAnimation { target: p3ToastRoot; property: "x"; from: 70; to: 0; duration: 240; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                        NumberAnimation { target: p3ToastRoot; property: "opacity"; from: 0.0; to: 1.0; duration: 190; easing.type: Easing.OutCubic }
                    }

                    // Speech bubble canvas
                    Canvas {
                        id: toastCanvas
                        anchors.fill: parent
                        antialiasing: true

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var w = width
                            var h = height

                            ctx.fillStyle = "rgba(0, 160, 255, 0.30)"
                            ctx.beginPath()
                            ctx.moveTo(w - 75, -2)
                            ctx.lineTo(w + 4, -2)
                            ctx.lineTo(w - 8, h + 2)
                            ctx.lineTo(w - 88, h + 2)
                            ctx.closePath()
                            ctx.fill()

                            var bx = 16
                            var by = 10
                            var bw = w - 34
                            var bh = h - 16
                            var r = 6

                            ctx.beginPath()
                            ctx.moveTo(bx + r, by)
                            ctx.lineTo(bx + bw - r, by)
                            ctx.quadraticCurveTo(bx + bw, by, bx + bw, by + r)
                            ctx.lineTo(bx + bw, by + bh - r)
                            ctx.quadraticCurveTo(bx + bw, by + bh, bx + bw - r, by + bh)
                            ctx.lineTo(bx + r, by + bh)
                            ctx.quadraticCurveTo(bx, by + bh, bx, by + bh - r)
                            ctx.lineTo(bx, by + r)
                            ctx.quadraticCurveTo(bx, by, bx + r, by)
                            ctx.closePath()

                            ctx.fillStyle = "rgba(4, 12, 38, 0.95)"
                            ctx.fill()

                            ctx.strokeStyle = "rgba(0, 219, 255, 0.75)"
                            ctx.lineWidth = 1.6
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.moveTo(-2, 20)           // Ujung runcing kiri
                            ctx.lineTo(150, -2)          // Titik atas kanan
                            ctx.lineTo(162, 22)          // Titik bawah kanan
                            ctx.lineTo(36, 32)           // Titik bawah kiri
                            ctx.closePath()

                            ctx.fillStyle = "#0028e0"
                            ctx.fill()
                            ctx.strokeStyle = "#00f0ff"
                            ctx.lineWidth = 1.3
                            ctx.stroke()
                        }
                    }

                    // Sender label on wedge tag
                    Item {
                        x: 8
                        y: -1
                        width: 145
                        height: 30
                        z: 10

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.topMargin: 2
                            spacing: 0

                            Text {
                                text: p3ToastRoot.senderName
                                color: "#ffffff"
                                font.family: "Rubik"
                                font.pixelSize: 10
                                font.weight: Font.Black
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "NEW TRANSMISSION"
                                color: "#00f0ff"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 8
                                font.bold: true
                                font.letterSpacing: 0.5
                            }
                        }
                    }

                    // Notification content row
                    RowLayout {
                        id: toastLayout
                        anchors.fill: parent
                        anchors.leftMargin: 28
                        anchors.rightMargin: 26
                        anchors.topMargin: 24
                        anchors.bottomMargin: 10
                        spacing: 12
                        z: 5

                        Rectangle {
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 38
                            radius: 4
                            color: "#061536"
                            border.color: "#00dbff"
                            border.width: 1.2

                            Image {
                                id: toastAvImg
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                source: p3ToastRoot.resolvedIcon
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                visible: source !== "" && status === Image.Ready && implicitWidth > 0
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !toastAvImg.visible
                                text: {
                                    const s = (p3ToastRoot.senderName || "").trim()
                                    return s.length > 0 ? s.charAt(0).toUpperCase() : "M"
                                }
                                font.family: "Rubik"
                                font.pixelSize: 16
                                font.weight: Font.Black
                                color: "#ffffff"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    Layout.fillWidth: true
                                    text: p3ToastRoot.senderName
                                    color: "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: p3ToastRoot.msgTime
                                    color: "#00dbff"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: p3ToastRoot.msgBody
                                color: "#b8d0ee"
                                font.family: "Rubik"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                renderType: Text.CurveRendering
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 12
                            color: toastCloseMouse.containsMouse ? "#d60032" : "#0d1f42"
                            border.color: "#00dbff"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                font.family: "Rubik"
                                font.pixelSize: 14
                                font.weight: Font.Black
                                color: "#ffffff"
                            }

                            MouseArea {
                                id: toastCloseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.dismissPopup(p3ToastRoot.index)
                            }
                        }
                    }

                    // Click card to open message
                    MouseArea {
                        anchors.fill: parent
                        anchors.rightMargin: 34
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            PhantomState.openP3ReaderIndex(p3ToastRoot.index)
                            PhantomState.dismissPopup(p3ToastRoot.index)
                        }
                    }
                }
            }
        }
    }
}
