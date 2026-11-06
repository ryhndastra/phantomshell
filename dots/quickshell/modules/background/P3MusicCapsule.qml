import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import qs.config
import qs.components

// Widget Pemutar Musik Kapsul Ikonik Makoto Yuki - Persona 3 Reload MP3 Player
// Fitur: Terpasang di tepi kiri layar, ditarik/geser (drag) atau diklik untuk buka/tutup,
// pas sempurna di dalam layar LCD kapsul, dan terintegrasi mulus dengan audio Mpris.
Item {
    id: p3CapsuleRoot
    visible: PhantomState.isP3
    width: 500
    height: 270
    z: 25

    // Posisi vertikal di sisi kiri layar
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    anchors.verticalCenterOffset: 60

    property var mpris: (Mpris.players && Mpris.players.values.length > 0) ? Mpris.players.values[0] : null

    readonly property bool isPlaying: mpris ? (mpris.playbackState === MprisPlaybackState.Playing) : PhantomState.mediaPlaying
    readonly property string songTitle: mpris ? (mpris.trackTitle || "No Track Playing") : (PhantomState.mediaTitle || "No Track Playing")
    readonly property string songArtist: mpris ? (mpris.trackArtist || "Persona 3 Reload") : (PhantomState.mediaArtist || "S.E.E.S. Audio")
    readonly property url songArt: mpris ? (mpris.trackArtUrl || "") : ""

    property bool isManuallyOpened: false
    readonly property bool isOpened: isPlaying || isManuallyOpened

    // Animasi geser horizontal dengan Drag & Click
    x: isOpened ? 0 : -360
    Behavior on x {
        enabled: !capsuleDragArea.drag.active
        NumberAnimation {
            duration: 340
            easing.type: Easing.OutBack
            easing.overshoot: 1.12
        }
    }

    Item {
        id: capsuleContainer
        anchors.fill: parent

        // ── Gambar Fisik Pemutar MP3 Kapsul Makoto Yuki (player.png) ──
        Image {
            id: playerBody
            source: Qt.resolvedUrl("../../assets/themes/p3/components/player.png")
            width: 480
            height: 270
            anchors.left: parent.left
            anchors.leftMargin: -12
            anchors.verticalCenter: parent.verticalCenter
            transformOrigin: Item.Left
            rotation: 6
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true

            // ── Kluster Kontrol & Tampilan di Dalam Layar LCD Kapsul (Child Langsung dari playerBody) ──
            Item {
                id: playerUiContent
                x: 214
                y: 99
                width: 216
                height: 52

                Row {
                    anchors.fill: parent
                    spacing: 8

                    // Piringan Vinyl Berputar (Album Mask & Play/Pause Dial)
                    Item {
                        id: vinylDial
                        width: 44
                        height: 44
                        anchors.verticalCenter: parent.verticalCenter

                        // Piringan Dasar Vinyl Hitam Elegan
                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "#080b14"
                            border.color: "#00dbff"
                            border.width: 1.5
                        }

                        // Lapisan Artwork Album atau Tekstur Vinyl Atlus yang Berputar
                        Item {
                            id: spinningDisc
                            anchors.fill: parent
                            anchors.margins: 3

                            Image {
                                id: albumImg
                                anchors.fill: parent
                                source: p3CapsuleRoot.songArt != "" ? p3CapsuleRoot.songArt : Qt.resolvedUrl("../../assets/themes/p3/components/AlbumCover-by-Squirrel-Modeller.svg")
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                mipmap: true

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSpreadAtMin: 1.0
                                    maskThresholdMin: 0.5
                                    maskSource: ShaderEffectSource {
                                        sourceItem: Rectangle {
                                            width: albumImg.width
                                            height: albumImg.height
                                            radius: albumImg.width / 2
                                            color: "white"
                                        }
                                    }
                                }
                            }

                            // Titik Poros Tengah Vinyl Cyan P3
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                radius: 4
                                color: "#00dbff"
                                border.color: "#ffffff"
                                border.width: 1
                            }

                            // Animasi Rotasi Piringan Saat Musik Diputar
                            NumberAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 5000
                                loops: Animation.Infinite
                                running: p3CapsuleRoot.isPlaying
                            }
                        }

                        // Indikator Ikon Play/Pause Kecil Saat Kursor Mengarah ke Piringan
                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: Qt.rgba(0, 10, 30, 0.6)
                            opacity: vinylMouse.containsMouse ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            P5Icon {
                                anchors.centerIn: parent
                                name: p3CapsuleRoot.isPlaying ? "pause" : "play"
                                size: 14
                                color: "#00dbff"
                            }
                        }

                        MouseArea {
                            id: vinylMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                PhantomState.playSfx("select")
                                if (p3CapsuleRoot.mpris && p3CapsuleRoot.mpris.canTogglePlaying) {
                                    p3CapsuleRoot.mpris.togglePlaying()
                                } else {
                                    PhantomState.mediaPlayPause()
                                }
                            }
                        }
                    }

                    // Informasi Trek (Artis, Judul Lagu, dan Tombol Kontrol Prev/Next)
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - vinylDial.width - 10
                        spacing: 1

                        // Artis Lagu
                        Text {
                            width: parent.width
                            text: p3CapsuleRoot.songArtist
                            font.family: "Inter Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: "#0078d4"
                            elide: Text.ElideRight
                        }

                        // Judul Lagu
                        Text {
                            width: parent.width
                            text: p3CapsuleRoot.songTitle
                            font.family: "Inter Display"
                            font.pixelSize: 12
                            font.weight: Font.Black
                            color: "#000a1f"
                            elide: Text.ElideRight
                        }

                        // Baris Tombol Prev / Play-Pause / Next
                        Row {
                            spacing: 8
                            anchors.left: parent.left
                            anchors.leftMargin: 0

                            // Tombol Prev
                            Item {
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter

                                P5Icon {
                                    anchors.centerIn: parent
                                    name: "prev"
                                    size: 10
                                    color: prevCapMouse.containsMouse ? "#00dbff" : "#024282"
                                }
                                MouseArea {
                                    id: prevCapMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("select")
                                        if (p3CapsuleRoot.mpris && p3CapsuleRoot.mpris.canGoPrevious) {
                                            p3CapsuleRoot.mpris.previous()
                                        } else {
                                            PhantomState.mediaPrev()
                                        }
                                    }
                                }
                            }

                            // Tombol Play / Pause
                            Item {
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter

                                P5Icon {
                                    anchors.centerIn: parent
                                    name: p3CapsuleRoot.isPlaying ? "pause" : "play"
                                    size: 10
                                    color: playCapMouse.containsMouse ? "#00dbff" : "#024282"
                                }
                                MouseArea {
                                    id: playCapMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("select")
                                        if (p3CapsuleRoot.mpris && p3CapsuleRoot.mpris.canTogglePlaying) {
                                            p3CapsuleRoot.mpris.togglePlaying()
                                        } else {
                                            PhantomState.mediaPlayPause()
                                        }
                                    }
                                }
                            }

                            // Tombol Next
                            Item {
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter

                                P5Icon {
                                    anchors.centerIn: parent
                                    name: "next"
                                    size: 10
                                    color: nextCapMouse.containsMouse ? "#00dbff" : "#024282"
                                }
                                MouseArea {
                                    id: nextCapMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("select")
                                        if (p3CapsuleRoot.mpris && p3CapsuleRoot.mpris.canGoNext) {
                                            p3CapsuleRoot.mpris.next()
                                        } else {
                                            PhantomState.mediaNext()
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

    // Area Interaksi Drag & Click: Pengguna dapat mengklik atau menggeser (drag) badan kapsul untuk membuka/menutup
    MouseArea {
        id: capsuleDragArea
        anchors.fill: parent
        z: -1
        hoverEnabled: true
        cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor

        drag.target: p3CapsuleRoot
        drag.axis: Drag.XAxis
        drag.minimumX: -360
        drag.maximumX: 0

        onClicked: {
            p3CapsuleRoot.isManuallyOpened = !p3CapsuleRoot.isOpened
            p3CapsuleRoot.x = p3CapsuleRoot.isManuallyOpened ? 0 : -360
            PhantomState.playSfx("select")
        }

        onReleased: {
            if (drag.active) {
                if (p3CapsuleRoot.x > -180) {
                    p3CapsuleRoot.isManuallyOpened = true
                    p3CapsuleRoot.x = 0
                } else {
                    p3CapsuleRoot.isManuallyOpened = false
                    p3CapsuleRoot.x = -360
                }
                PhantomState.playSfx("select")
            }
        }
    }
}
