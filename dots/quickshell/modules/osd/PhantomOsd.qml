import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

// modul indikator pop-up volume audio dan kecerahan layar bergaya persona
Scope {
    PanelWindow {
        id: osdWin

        property bool closing: false
        visible: PhantomState.osdVisible || osdWin.closing

        WlrLayershell.namespace: "phantomshell-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            bottom: true
        }
        margins.bottom: 68

        implicitWidth: 386
        implicitHeight: 92
        color: "transparent"

        Connections {
            target: PhantomState
            function onOsdVisibleChanged() {
                if (PhantomState.osdVisible) {
                    osdExitTimer.stop()
                    osdWin.closing = false
                } else {
                    osdWin.closing = true
                    osdExitTimer.restart()
                }
            }
        }

        Timer {
            id: osdExitTimer
            interval: 230
            repeat: false
            onTriggered: osdWin.closing = false
        }

        // kontainer utama osd dengan animasi kemiringan khas persona
        Item {
            id: osdBody
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 14
            anchors.topMargin: 16
            anchors.bottomMargin: 10

            readonly property bool isOpen: PhantomState.osdVisible && !osdWin.closing
            readonly property bool isVolume: PhantomState.osdLabel === "VOLUME"
            readonly property bool isMuted: isVolume && (PhantomState.osdMuted || PhantomState.osdValue <= 0)
            readonly property real ratio: Math.max(0.0, Math.min(1.0, PhantomState.osdValue / 100.0))

            opacity: isOpen ? 1.0 : 0.0
            scale: isOpen ? 1.0 : 0.84
            rotation: isOpen ? (PhantomState.polygonMode ? -2.2 : 0) : -7.5

            transform: Translate {
                y: osdBody.isOpen ? 0 : 22
                Behavior on y { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }
            }

            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }
            Behavior on rotation { NumberAnimation { duration: 230; easing.type: Easing.OutBack } }

            // kartu poligon miring utama dengan bayangan berlapis
            P5SkewedCard {
                anchors.fill: parent
                fillColor: "#09090E"
                borderColor: "#FFFFFF"
                shadowColor: osdBody.isMuted ? PhantomState.urgent : PhantomState.primary
                borderWidth: 3
                skewPx: PhantomState.polygonMode ? 15 : 0
                shadowOffsetX: 6
                shadowOffsetY: 6
            }

            // dekorasi pita diagonal di latar dalam kartu osd
            Canvas {
                anchors.fill: parent
                anchors.margins: 4
                opacity: 0.18
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height

                    ctx.fillStyle = String(PhantomState.primary)
                    ctx.beginPath()
                    ctx.moveTo(w * 0.22, 0)
                    ctx.lineTo(w * 0.36, 0)
                    ctx.lineTo(w * 0.27, h)
                    ctx.lineTo(w * 0.13, h)
                    ctx.closePath()
                    ctx.fill()

                    ctx.fillStyle = "#FFFFFF"
                    ctx.beginPath()
                    ctx.moveTo(w * 0.38, 0)
                    ctx.lineTo(w * 0.40, 0)
                    ctx.lineTo(w * 0.31, h)
                    ctx.lineTo(w * 0.29, h)
                    ctx.closePath()
                    ctx.fill()
                }
            }

            // pita label miring di sudut kiri atas kartu osd
            Item {
                x: 18
                y: -11
                width: 128
                height: 22
                rotation: -3.5
                z: 5

                Rectangle {
                    x: 3
                    y: 3
                    width: parent.width
                    height: parent.height
                    color: osdBody.isMuted ? PhantomState.urgent : PhantomState.primary
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#FFFFFF"
                    border.color: "#09090E"
                    border.width: 2

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        P5Star {
                            Layout.preferredWidth: 13
                            Layout.preferredHeight: 13
                            spinning: true
                        }

                        Text {
                            text: osdBody.isVolume
                                ? (osdBody.isMuted ? "MUTED // SFX" : "AUDIO // GAUGE")
                                : "LIGHT // GAUGE"
                            color: "#09090E"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                            font.italic: true
                        }
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                anchors.topMargin: 8
                anchors.bottomMargin: 6
                spacing: 12

                // lencana poligon miring kiri untuk ikon speaker atau kecerahan
                Item {
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 42
                    rotation: -3

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: iconMouse.containsMouse
                            ? PhantomState.primary
                            : (osdBody.isMuted ? "#2A1218" : "#181824")
                        borderColor: osdBody.isMuted ? PhantomState.urgent : "#FFFFFF"
                        shadowColor: osdBody.isMuted ? PhantomState.urgent : PhantomState.primary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 8 : 0
                        shadowOffsetX: 3
                        shadowOffsetY: 3
                    }

                    P5Icon {
                        anchors.centerIn: parent
                        name: osdBody.isVolume
                            ? (osdBody.isMuted ? "mute" : "volume")
                            : "brightness"
                        size: 19
                        color: osdBody.isMuted
                            ? PhantomState.urgent
                            : (iconMouse.containsMouse ? "#FFFFFF" : PhantomState.secondary)
                    }

                    MouseArea {
                        id: iconMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: osdBody.isVolume ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (osdBody.isVolume) {
                                PhantomState.toggleSystemMute()
                            }
                        }
                    }
                }

                // bilah progres poligon miring terpisah dengan tebasan pembatas tengah
                Item {
                    id: trackArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42

                    property real animRatio: osdBody.ratio
                    Behavior on animRatio {
                        NumberAnimation { duration: 130; easing.type: Easing.OutCubic }
                    }

                    onAnimRatioChanged: gaugeCanvas.requestPaint()

                    Connections {
                        target: osdBody
                        function onIsMutedChanged() { gaugeCanvas.requestPaint() }
                    }

                    Connections {
                        target: PhantomState
                        function onPrimaryChanged() { gaugeCanvas.requestPaint() }
                        function onSecondaryChanged() { gaugeCanvas.requestPaint() }
                    }

                    Canvas {
                        id: gaugeCanvas
                        anchors.fill: parent

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()

                            var w = width
                            var h = height
                            var sk = PhantomState.polygonMode ? 9 : 0
                            var barTop = 8
                            var barBot = h - 8
                            var barH = barBot - barTop
                            var gap = 9
                            var r = Math.max(0.0, Math.min(1.0, trackArea.animRatio))
                            var usableW = Math.max(24, w - sk - gap)
                            var splitX = sk + usableW * r

                            // bagian kiri bilah miring yang terisi
                            if (r > 0.01) {
                                var leftEndTop = Math.max(sk + 2, splitX - gap * 0.45)
                                var leftEndBot = leftEndTop - sk

                                ctx.fillStyle = osdBody.isMuted
                                    ? "#4A4A5E"
                                    : (PhantomState.osdValue > 100 ? String(PhantomState.secondary) : String(PhantomState.primary))
                                ctx.beginPath()
                                ctx.moveTo(sk, barTop)
                                ctx.lineTo(leftEndTop, barTop)
                                ctx.lineTo(leftEndBot, barBot)
                                ctx.lineTo(0, barBot)
                                ctx.closePath()
                                ctx.fill()

                                // garis aksen miring internal pada bagian terisi
                                ctx.save()
                                ctx.clip()
                                ctx.fillStyle = "rgba(255, 255, 255, 0.18)"
                                for (var sx = -10; sx < leftEndTop + 20; sx += 16) {
                                    ctx.beginPath()
                                    ctx.moveTo(sx + 6, barTop)
                                    ctx.lineTo(sx + 11, barTop)
                                    ctx.lineTo(sx + 3, barBot)
                                    ctx.lineTo(sx - 2, barBot)
                                    ctx.closePath()
                                    ctx.fill()
                                }
                                ctx.restore()

                                ctx.strokeStyle = "#FFFFFF"
                                ctx.lineWidth = 1.8
                                ctx.stroke()
                            }

                            // bagian kanan bilah miring yang belum terisi
                            if (r < 0.99) {
                                var rightStartTop = Math.min(w - 2, splitX + gap * 0.55)
                                var rightStartBot = rightStartTop - sk

                                ctx.fillStyle = "#1E1F2B"
                                ctx.beginPath()
                                ctx.moveTo(rightStartTop, barTop)
                                ctx.lineTo(w, barTop)
                                ctx.lineTo(w - sk, barBot)
                                ctx.lineTo(rightStartBot, barBot)
                                ctx.closePath()
                                ctx.fill()

                                ctx.strokeStyle = "#484A60"
                                ctx.lineWidth = 1.5
                                ctx.stroke()
                            }

                            // bilah pisau pembatas miring di titik persentase saat ini
                            var thumbTopX = splitX + 1.5
                            var thumbBotX = splitX - sk - 1.5
                            var thumbW = 5.0

                            // bayangan warna tema di belakang garis pembatas
                            ctx.fillStyle = osdBody.isMuted ? String(PhantomState.urgent) : String(PhantomState.secondary)
                            ctx.beginPath()
                            ctx.moveTo(thumbTopX + 2, 2)
                            ctx.lineTo(thumbTopX + thumbW + 2, 2)
                            ctx.lineTo(thumbBotX + thumbW + 2, h - 1)
                            ctx.lineTo(thumbBotX + 2, h - 1)
                            ctx.closePath()
                            ctx.fill()

                            // inti putih tajam garis pembatas
                            ctx.fillStyle = "#FFFFFF"
                            ctx.beginPath()
                            ctx.moveTo(thumbTopX - thumbW * 0.5, 1)
                            ctx.lineTo(thumbTopX + thumbW * 0.5, 1)
                            ctx.lineTo(thumbBotX + thumbW * 0.5, h - 2)
                            ctx.lineTo(thumbBotX - thumbW * 0.5, h - 2)
                            ctx.closePath()
                            ctx.fill()

                            ctx.strokeStyle = "#09090E"
                            ctx.lineWidth = 1.4
                            ctx.stroke()
                        }
                    }

                    // interaksi klik dan geser langsung pada bilah osd
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        function applyAt(mx) {
                            const pct = Math.round(Math.max(0, Math.min(1, mx / Math.max(1, trackArea.width))) * 100)
                            if (osdBody.isVolume) {
                                PhantomState.setSystemVolume(pct)
                            } else {
                                PhantomState.setSystemBrightness(Math.max(1, pct))
                            }
                        }
                        onPressed: mouse => applyAt(mouse.x)
                        onPositionChanged: mouse => {
                            if (pressed) applyAt(mouse.x)
                        }
                    }
                }

                // lencana poligon miring kanan untuk angka nilai persentase
                Item {
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 42
                    rotation: 2.5

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: osdBody.isMuted ? PhantomState.urgent : PhantomState.primary
                        borderColor: "#FFFFFF"
                        shadowColor: PhantomState.secondary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 8 : 0
                        shadowOffsetX: 3
                        shadowOffsetY: 3
                    }

                    Text {
                        anchors.centerIn: parent
                        text: osdBody.isMuted ? "X" : String(PhantomState.osdValue)
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 17
                        font.weight: Font.Black
                        font.italic: true
                    }
                }
            }
        }
    }
}
