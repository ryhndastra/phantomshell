import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

// jendela popup media player mpris
PanelWindow {
    id: mediaPopupWin
    visible: PhantomState.mediaPopupOpen

    readonly property bool isBottom: PhantomState.barPosition === "bottom"

    WlrLayershell.namespace: "phantomshell-media-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusiveZone: 0

    anchors {
        top: !mediaPopupWin.isBottom
        bottom: mediaPopupWin.isBottom
        right: true
    }
    margins {
        top: 42
        bottom: 42
        right: 190
    }

    implicitWidth: 420
    implicitHeight: 196
    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            mediaPopupAnim.restart()
            PhantomState.refreshMedia()
        }
    }

    Item {
        id: mediaCard
        anchors.fill: parent
        transformOrigin: mediaPopupWin.isBottom ? Item.BottomRight : Item.TopRight

        ParallelAnimation {
            id: mediaPopupAnim
            NumberAnimation {
                target: mediaCard
                property: "scale"
                from: 0.85
                to: 1.0
                duration: 220
                easing.type: Easing.OutBack
                easing.overshoot: 1.32
            }
            NumberAnimation {
                target: mediaCard
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        P5SkewedCard {
            anchors.fill: parent
            fillColor: "#0B0C12"
            borderColor: "#FFFFFF"
            shadowColor: PhantomState.primary
            borderWidth: 2.5
            skewPx: PhantomState.polygonMode ? 9 : 0
            shadowOffsetX: 5
            shadowOffsetY: 5
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // sampul album dengan bingkai miring
            Item {
                Layout.preferredWidth: 124
                Layout.preferredHeight: 124
                Layout.alignment: Qt.AlignVCenter

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: "#161824"
                    borderColor: PhantomState.secondary
                    shadowColor: PhantomState.primary
                    borderWidth: 2
                    skewPx: 5
                    shadowOffsetX: 3
                    shadowOffsetY: 3
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5
                    color: "#0F111A"
                    clip: true

                    Image {
                        id: albumArtImg
                        anchors.fill: parent
                        source: PhantomState.mediaArtUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                        visible: status === Image.Ready
                    }

                    // ikon bintang cadangan saat sampul album tidak tersedia
                    P5Star {
                        anchors.centerIn: parent
                        width: 54
                        height: 54
                        visible: albumArtImg.status !== Image.Ready
                        spinning: PhantomState.mediaPlaying
                    }

                    // lencana nama aplikasi pemutar media di sudut kiri atas
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 4
                        width: playerBadgeTxt.implicitWidth + 10
                        height: 16
                        color: PhantomState.primary
                        border.color: "#FFFFFF"
                        border.width: 1

                        Text {
                            id: playerBadgeTxt
                            anchors.centerIn: parent
                            text: PhantomState.mediaPlayerName
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 8
                            font.weight: Font.Black
                        }
                    }
                }
            }

            // informasi lagu, bilah progres interaktif, dan tombol kontrol media
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: PhantomState.mediaTitle
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 13
                        font.weight: Font.Black
                        font.italic: true
                        elide: Text.ElideRight
                    }

                    // tombol tutup popup
                    Item {
                        width: 22
                        height: 22
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: closeMediaMouse.containsMouse ? PhantomState.primary : "#1A1D2B"
                            borderColor: "#FFFFFF"
                            showShadowOffset: false
                            borderWidth: 1
                            skewPx: 3
                        }
                        P5Icon { anchors.centerIn: parent; name: "close"; size: 9; color: "#FFFFFF" }
                        MouseArea {
                            id: closeMediaMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.mediaPopupOpen = false
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: PhantomState.mediaArtist + (PhantomState.mediaAlbum ? (" • " + PhantomState.mediaAlbum) : "")
                    color: PhantomState.secondary
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                // bilah progres posisi lagu interaktif
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Item {
                        id: seekTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16

                        readonly property real progRatio: PhantomState.mediaLengthSec > 0
                            ? Math.min(1.0, Math.max(0.0, PhantomState.mediaPositionSec / PhantomState.mediaLengthSec))
                            : 0.0

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: 5
                            color: "#282B3E"
                            border.color: "#454966"
                            border.width: 1

                            Rectangle {
                                width: parent.width * seekTrack.progRatio
                                height: parent.height
                                color: PhantomState.primary
                            }
                        }

                        P5Star {
                            width: 15
                            height: 15
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.max(0, Math.min(seekTrack.width - width, seekTrack.width * seekTrack.progRatio - width / 2))
                            spinning: PhantomState.mediaPlaying
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (seekTrack.width > 0) {
                                    PhantomState.mediaSeek(mouse.x / seekTrack.width)
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: PhantomState.formatMediaTime(PhantomState.mediaPositionSec)
                            color: PhantomState.muted
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: PhantomState.formatMediaTime(PhantomState.mediaLengthSec)
                            color: PhantomState.muted
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                    }
                }

                // deretan tombol kontrol pemutaran lagu
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // tombol shuffle
                    Item {
                        width: 30
                        height: 28
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: PhantomState.mediaShuffle === "On" ? PhantomState.secondary : (shufMouse.containsMouse ? "#25283B" : "#161824")
                            borderColor: PhantomState.mediaShuffle === "On" ? "#05060A" : "#3A3E58"
                            showShadowOffset: false
                            borderWidth: 1.2
                            skewPx: 4
                        }
                        P5Icon {
                            anchors.centerIn: parent
                            name: "shuffle"
                            size: 11
                            color: PhantomState.mediaShuffle === "On" ? "#05060A" : "#FFFFFF"
                        }
                        MouseArea {
                            id: shufMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.mediaToggleShuffle()
                        }
                    }

                    // tombol previous
                    Item {
                        width: 36
                        height: 30
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: prevPopMouse.containsMouse ? PhantomState.primary : "#1A1D2C"
                            borderColor: "#FFFFFF"
                            showShadowOffset: false
                            borderWidth: 1.5
                            skewPx: 4
                        }
                        P5Icon {
                            anchors.centerIn: parent
                            name: "prev"
                            size: 12
                            color: "#FFFFFF"
                        }
                        MouseArea {
                            id: prevPopMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.mediaPrev()
                        }
                    }

                    // tombol play dan pause utama
                    Item {
                        Layout.fillWidth: true
                        height: 32
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: playPopMouse.containsMouse ? PhantomState.secondary : PhantomState.primary
                            borderColor: "#FFFFFF"
                            shadowColor: PhantomState.secondary
                            borderWidth: 2
                            skewPx: 5
                            shadowOffsetX: 2
                            shadowOffsetY: 2
                        }
                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            P5Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: PhantomState.mediaPlaying ? "pause" : "play"
                                size: 12
                                color: playPopMouse.containsMouse ? "#05060A" : "#FFFFFF"
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: PhantomState.mediaPlaying ? "PAUSE" : "PLAY"
                                color: playPopMouse.containsMouse ? "#05060A" : "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                font.weight: Font.Black
                                font.italic: true
                            }
                        }
                        MouseArea {
                            id: playPopMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.mediaPlayPause()
                        }
                    }

                    // tombol next
                    Item {
                        width: 36
                        height: 30
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: nextPopMouse.containsMouse ? PhantomState.primary : "#1A1D2C"
                            borderColor: "#FFFFFF"
                            showShadowOffset: false
                            borderWidth: 1.5
                            skewPx: 4
                        }
                        P5Icon {
                            anchors.centerIn: parent
                            name: "next"
                            size: 12
                            color: "#FFFFFF"
                        }
                        MouseArea {
                            id: nextPopMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.mediaNext()
                        }
                    }

                    // tombol loop
                    Item {
                        width: 30
                        height: 28
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: PhantomState.mediaLoop !== "None" ? PhantomState.secondary : (loopMouse.containsMouse ? "#25283B" : "#161824")
                            borderColor: PhantomState.mediaLoop !== "None" ? "#05060A" : "#3A3E58"
                            showShadowOffset: false
                            borderWidth: 1.2
                            skewPx: 4
                        }
                        P5Icon {
                            anchors.centerIn: parent
                            name: "repeat"
                            size: 11
                            color: PhantomState.mediaLoop !== "None" ? "#05060A" : "#FFFFFF"
                        }
                        MouseArea {
                            id: loopMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.mediaToggleLoop()
                        }
                    }
                }
            }
        }
    }
}
