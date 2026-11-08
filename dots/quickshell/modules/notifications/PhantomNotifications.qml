import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

// =============================================================================
// PERSONA 3 RELOAD: S.E.E.S. TACTICAL PHONE MAIL TOAST & NOTIFICATION CENTER
// Pop-up notifikasi real-time bertema Tactical Phone Mail Persona 3 Reload
// =============================================================================
Scope {
    // Jendela popup notifikasi pesan di pojok kanan layar
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
            right: 14
        }

        implicitWidth: 420
        implicitHeight: Math.min(500, popupCol.implicitHeight + 20)
        color: "transparent"

        Column {
            id: popupCol
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 12

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

                    width: 390
                    height: Math.max(76, toastLayout.implicitHeight + 18)

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

                    // Animasi Masuk dari Kanan Layar
                    ParallelAnimation {
                        id: toastEnterAnim
                        running: true
                        NumberAnimation { target: p3ToastRoot; property: "x"; from: 60; to: 0; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                        NumberAnimation { target: p3ToastRoot; property: "opacity"; from: 0.0; to: 1.0; duration: 180; easing.type: Easing.OutCubic }
                    }

                    // Latar Belakang Kartu Slanted P3R
                    Canvas {
                        id: toastBgCanvas
                        anchors.fill: parent
                        antialiasing: true
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var w = width
                            var h = height
                            var sk = 12.0

                            // Bayangan Safir Gelap
                            ctx.beginPath()
                            ctx.moveTo(sk + 3, 3)
                            ctx.lineTo(w + 3, 3)
                            ctx.lineTo(w - sk + 3, h + 3)
                            ctx.lineTo(3, h + 3)
                            ctx.closePath()
                            ctx.fillStyle = "rgba(0, 15, 45, 0.7)"
                            ctx.fill()

                            // Dasar Kartu Navy P3R
                            ctx.beginPath()
                            ctx.moveTo(sk, 0)
                            ctx.lineTo(w, 0)
                            ctx.lineTo(w - sk, h)
                            ctx.lineTo(0, h)
                            ctx.closePath()
                            ctx.fillStyle = "#040b1e"
                            ctx.fill()

                            // Garis Tepi Neon Cyan
                            ctx.strokeStyle = "#00dbff"
                            ctx.lineWidth = 1.8
                            ctx.stroke()
                        }
                    }

                    // Pita Header Miring: "✉ NEW TRANSMISSION"
                    Item {
                        x: 18
                        y: -8
                        width: 156
                        height: 20
                        z: 5

                        Rectangle {
                            anchors.fill: parent
                            radius: 2
                            color: "#0038a8"
                            border.color: "#00dbff"
                            border.width: 1.2

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5
                                Text {
                                    text: "✉"
                                    font.pixelSize: 10
                                    color: "#ffffff"
                                }
                                Text {
                                    text: "NEW TRANSMISSION"
                                    color: "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.letterSpacing: 0.8
                                }
                            }
                        }
                    }

                    // Baris Konten: Slashed Avatar, Teks Pengirim & Pesan, Tombol Dismiss
                    RowLayout {
                        id: toastLayout
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 14
                        anchors.topMargin: 12
                        anchors.bottomMargin: 8
                        spacing: 10

                        // Avatar Slashed
                        Item {
                            Layout.preferredWidth: 44
                            Layout.preferredHeight: 44

                            Canvas {
                                id: toastAvCanvas
                                anchors.fill: parent
                                antialiasing: true
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.reset()
                                    ctx.beginPath()
                                    ctx.moveTo(0, 0)
                                    ctx.lineTo(width, 0)
                                    ctx.lineTo(width - 12, height)
                                    ctx.lineTo(0, height)
                                    ctx.closePath()
                                    ctx.fillStyle = "#0038a8"
                                    ctx.fill()
                                    ctx.strokeStyle = "#00dbff"
                                    ctx.lineWidth = 1.2
                                    ctx.stroke()
                                }
                            }

                            Image {
                                id: toastAvImg
                                anchors.centerIn: parent
                                width: 26
                                height: 26
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
                                    return s.length > 0 ? s.charAt(0).toUpperCase() : "✉"
                                }
                                font.family: "Rubik"
                                font.pixelSize: 16
                                font.weight: Font.Black
                                color: "#ffffff"
                            }
                        }

                        // Teks Pengirim dan Pesan
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    Layout.fillWidth: true
                                    text: p3ToastRoot.senderName
                                    color: "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 12
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                    renderType: Text.CurveRendering
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
                                color: "#9fb4cc"
                                font.family: "Rubik"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                renderType: Text.CurveRendering
                            }
                        }

                        // Tombol Tutup / Dismiss
                        Rectangle {
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            radius: 11
                            color: toastCloseMouse.containsMouse ? "#ff2a55" : "#0d1b38"
                            border.color: "#00dbff"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                font.family: "Rubik"
                                font.pixelSize: 13
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

                    // Klik pada Kartu: Buka Pesan di Mail Detail Reader
                    MouseArea {
                        anchors.fill: parent
                        anchors.rightMargin: 30
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
