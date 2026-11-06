import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Mpris
import qs.config
import qs.components

// Widget Pemutar Musik Kapsul Ikonik Makoto Yuki - Persona 3 Reload MP3 Player
// Fitur: Terpasang di tepi kiri layar, auto-hide jika tidak ada musik yang dimainkan (hanya nongol sedikit),
// dan otomatis meluncur keluar penuh saat di-hover, diklik, atau saat musik berputar.
Item {
    id: p3CapsuleRoot
    visible: PhantomState.isP3
    width: 500
    height: 270
    z: 25

    // Posisi vertikal: Lebih ke atas di sisi kiri layar ("nyantol di tepi layar")
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    anchors.verticalCenterOffset: 60

    property var mpris: (Mpris.players && Mpris.players.values.length > 0) ? Mpris.players.values[0] : null

    readonly property bool isPlaying: mpris ? (mpris.playbackState === MprisPlaybackState.Playing) : PhantomState.mediaPlaying
    readonly property string songTitle: mpris ? (mpris.trackTitle || "No Track Playing") : (PhantomState.mediaTitle || "No Track Playing")
    readonly property string songArtist: mpris ? (mpris.trackArtist || "Persona 3 Reload") : (PhantomState.mediaArtist || "S.E.E.S. Audio")
    readonly property url songArt: mpris ? (mpris.trackArtUrl || "") : ""

    property bool isHovered: hoverZone.containsMouse || bodyMouse.containsMouse || vinylMouse.containsMouse
    property bool isManuallyOpened: false

    // Muncul penuh jika musik sedang berputar, kursor mouse mengarah ke kapsul, atau diklik user
    readonly property bool isRevealed: isPlaying || isHovered || isManuallyOpened

    // Animasi geser horizontal: Nyantol di tepi layar saat aktif, mundur menyisakan ujung saat sembunyi
    x: isRevealed ? 0 : -350
    Behavior on x {
        NumberAnimation {
            duration: 380
            easing.type: Easing.OutBack
            easing.overshoot: 1.15
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
        }

        // ── Indikator Ujung Kapsul Menyala Saat Sedang Tersembunyi ──
        Rectangle {
            visible: !p3CapsuleRoot.isRevealed
            anchors.right: parent.right
            anchors.rightMargin: 80
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 12
            width: 8
            height: 38
            radius: 4
            color: "#00dbff"
            opacity: 0.8
            rotation: 6

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 0.3; to: 0.9; duration: 900; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.9; to: 0.3; duration: 900; easing.type: Easing.InOutQuad }
            }
        }

        // ── Kluster Kontrol & Tampilan di Atas Kapsul (Diputar Menyesuaikan Kemiringan) ──
        Item {
            id: playerUiContent
            anchors.centerIn: playerBody
            anchors.horizontalCenterOffset: 50
            anchors.verticalCenterOffset: 1
            rotation: 6
            width: 240
            height: 60

            Row {
                anchors.centerIn: parent
                spacing: 12

                // Piringan Vinyl Berputar (Album Mask & Play/Pause Dial)
                Item {
                    id: vinylDial
                    width: 50
                    height: 50
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
                    width: 146
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

        // MouseArea untuk seluruh badan kapsul: Klik untuk toggle buka/tutup jika tidak sedang memainkan lagu
        MouseArea {
            id: bodyMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: -1
            onClicked: {
                p3CapsuleRoot.isManuallyOpened = !p3CapsuleRoot.isManuallyOpened
            }
        }
    }

    // Zona deteksi kursor di ujung layar agar mudah membuka kapsul saat tersembunyi
    MouseArea {
        id: hoverZone
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        z: -2
        onEntered: {
            p3CapsuleRoot.isHovered = true
        }
        onExited: {
            p3CapsuleRoot.isHovered = false
        }
        onClicked: {
            p3CapsuleRoot.isManuallyOpened = !p3CapsuleRoot.isManuallyOpened
        }
    }
}
