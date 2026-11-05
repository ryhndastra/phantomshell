import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import qs.config
import qs.components

// Widget Pemutar Musik Kapsul Ikonik Makoto Yuki - Persona 3 Reload MP3 Player
Item {
    id: p3CapsuleRoot
    visible: PhantomState.isP3
    width: 520
    height: 220
    anchors.left: parent.left
    anchors.leftMargin: -10
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10
    z: 20

    property var mpris: (Mpris.players && Mpris.players.values.length > 0) ? Mpris.players.values[0] : null

    readonly property bool isPlaying: mpris ? (mpris.playbackState === MprisPlaybackState.Playing) : PhantomState.mediaPlaying
    readonly property string songTitle: mpris ? (mpris.trackTitle || "No Track") : (PhantomState.mediaTitle || "No Media")
    readonly property string songArtist: mpris ? (mpris.trackArtist || "Persona 3 Reload") : (PhantomState.mediaArtist || "S.E.E.S. Audio")
    readonly property url songArt: mpris ? (mpris.trackArtUrl || "") : ""

    Item {
        id: capsuleContainer
        anchors.fill: parent

        // ── Gambar Fisik Pemutar MP3 Kapsul Makoto Yuki (player.png) ──
        Image {
            id: playerBody
            source: Qt.resolvedUrl("../../assets/themes/p3/components/player.png")
            width: 480
            height: 200
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -20
            anchors.verticalCenterOffset: 10
            rotation: 10
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        // ── Kluster Kontrol & Tampilan di Atas Kapsul (Diputar 10° Menyesuaikan Kemiringan) ──
        Item {
            id: playerUiContent
            anchors.centerIn: playerBody
            anchors.horizontalCenterOffset: 62
            anchors.verticalCenterOffset: 8
            rotation: 10
            width: 220
            height: 70

            Row {
                anchors.centerIn: parent
                spacing: 12

                // Piringan Vinyl Berputar (Album Mask & Play/Pause Dial)
                Item {
                    id: vinylDial
                    width: 54
                    height: 54
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
                        anchors.margins: 4

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
                            width: 10
                            height: 10
                            radius: 5
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
                            size: 16
                            color: "#00dbff"
                        }
                    }

                    MouseArea {
                        id: vinylMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
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
                    width: 130
                    spacing: 2

                    // Artis Lagu
                    Text {
                        width: parent.width
                        text: p3CapsuleRoot.songArtist
                        font.family: "Inter Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: "#0078d4"
                        elide: Text.ElideRight
                    }

                    // Judul Lagu
                    Text {
                        width: parent.width
                        text: p3CapsuleRoot.songTitle
                        font.family: "Inter Display"
                        font.pixelSize: 13
                        font.weight: Font.Black
                        color: "#000a1f"
                        elide: Text.ElideRight
                    }

                    // Baris Tombol Prev / Play-Pause / Next
                    Row {
                        spacing: 10
                        anchors.left: parent.left
                        anchors.leftMargin: 2

                        // Tombol Prev
                        Item {
                            width: 18
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter

                            P5Icon {
                                anchors.centerIn: parent
                                name: "prev"
                                size: 11
                                color: prevCapMouse.containsMouse ? "#00dbff" : "#1a2c50"
                            }
                            MouseArea {
                                id: prevCapMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
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
                            width: 18
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter

                            P5Icon {
                                anchors.centerIn: parent
                                name: p3CapsuleRoot.isPlaying ? "pause" : "play"
                                size: 11
                                color: playCapMouse.containsMouse ? "#00dbff" : "#1a2c50"
                            }
                            MouseArea {
                                id: playCapMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
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
                            width: 18
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter

                            P5Icon {
                                anchors.centerIn: parent
                                name: "next"
                                size: 11
                                color: nextCapMouse.containsMouse ? "#00dbff" : "#1a2c50"
                            }
                            MouseArea {
                                id: nextCapMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
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
