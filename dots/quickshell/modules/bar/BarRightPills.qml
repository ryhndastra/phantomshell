import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.config
import qs.components

// deretan komponen kanan bar: system tray, media player, tema, wallpaper, notifikasi, statistik, pengaturan, dan sesi
Row {
    id: rightRow
    spacing: 6

    property var barWin: null

    // pill pengendali media player dan pembuka popup jukebox
    Item {
        visible: PhantomState.showMediaPill
        width: mediaPillRow.implicitWidth + 20
        height: 30

        P5SkewedCard {
            anchors.fill: parent
            fillColor: PhantomState.mediaPopupOpen ? PhantomState.primary : PhantomState.surface
            borderColor: PhantomState.borderLight
            shadowColor: PhantomState.mediaPlaying ? PhantomState.secondary : PhantomState.primary
            borderWidth: 2
            skewPx: PhantomState.polygonMode ? 5 : 0
            shadowOffsetX: 2
            shadowOffsetY: 2
        }

        Row {
            id: mediaPillRow
            anchors.centerIn: parent
            spacing: 5

            // bagian kiri: ikon musik dan judul lagu aktif
            Item {
                width: mediaTitleRow.implicitWidth
                height: 24
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: mediaTitleRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    P5Icon {
                        name: "music"
                        size: 12
                        color: PhantomState.mediaPlaying ? PhantomState.secondary : PhantomState.muted
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        width: Math.min(130, implicitWidth)
                        text: PhantomState.mediaAvailable ? PhantomState.mediaTitle : "NO MEDIA"
                        color: PhantomState.foreground
                        font.pixelSize: 10
                        font.weight: Font.Black
                        font.italic: true
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PhantomState.toggleMediaPopup()
                }
            }

            // garis pemisah kecil
            Rectangle {
                width: 1
                height: 14
                color: "#44FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
            }

            // tombol prev
            Item {
                width: 18
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                P5Icon {
                    anchors.centerIn: parent
                    name: "prev"
                    size: 10
                    color: prevBarMouse.containsMouse ? PhantomState.secondary : PhantomState.foreground
                }
                MouseArea {
                    id: prevBarMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PhantomState.mediaPrev()
                }
            }

            // tombol play / pause
            Item {
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: playBarMouse.containsMouse ? PhantomState.secondary : PhantomState.primary
                    borderColor: PhantomState.borderLight
                    showShadowOffset: false
                    borderWidth: 1
                    skewPx: 3
                }

                P5Icon {
                    anchors.centerIn: parent
                    name: PhantomState.mediaPlaying ? "pause" : "play"
                    size: 9
                    color: playBarMouse.containsMouse ? "#05060A" : "#FFFFFF"
                }
                MouseArea {
                    id: playBarMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PhantomState.mediaPlayPause()
                }
            }

            // tombol next
            Item {
                width: 18
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                P5Icon {
                    anchors.centerIn: parent
                    name: "next"
                    size: 10
                    color: nextBarMouse.containsMouse ? PhantomState.secondary : PhantomState.foreground
                }
                MouseArea {
                    id: nextBarMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PhantomState.mediaNext()
                }
            }
        }
    }

    // tombol ganti cepat preset warna
    Item {
        visible: PhantomState.showThemePill
        width: themePillRow.implicitWidth + 24
        height: 30

        P5SkewedCard {
            anchors.fill: parent
            fillColor: PhantomState.primary
            borderColor: PhantomState.borderLight
            shadowColor: PhantomState.borderDark
            borderWidth: 2
            skewPx: PhantomState.polygonMode ? 5 : 0
            shadowOffsetX: 2
            shadowOffsetY: 2
        }

        Row {
            id: themePillRow
            anchors.centerIn: parent
            spacing: 6

            P5Icon {
                name: PhantomState.themeId === "p5-crimson" ? "phantom" : (PhantomState.themeId === "p3-reload" ? "moon" : "tv")
                size: 12
                color: PhantomState.foreground
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: PhantomState.themeId === "p5-crimson" ? "P5 RED" : (PhantomState.themeId === "p3-reload" ? "P3 BLUE" : (PhantomState.themeId === "p4-golden" ? "P4 GOLD" : PhantomState.themeId.toUpperCase()))
                color: PhantomState.foreground
                font.pixelSize: 10
                font.weight: Font.Black
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (PhantomState.themeId === "p5-crimson") PhantomState.applyPreset("p3-reload")
                else if (PhantomState.themeId === "p3-reload") PhantomState.applyPreset("p4-golden")
                else PhantomState.applyPreset("p5-crimson")
            }
        }
    }

    // tombol pembuka panel pemilih wallpaper
    Item {
        width: 34
        height: 30

        P5SkewedCard {
            anchors.fill: parent
            fillColor: PhantomState.wallpaperSelectorOpen ? PhantomState.primary : (wpBtnMouse.containsMouse ? PhantomState.surfaceAlt : PhantomState.surface)
            borderColor: PhantomState.borderLight
            shadowColor: PhantomState.wallpaperSelectorOpen ? PhantomState.secondary : PhantomState.primary
            borderWidth: 2
            skewPx: PhantomState.polygonMode ? 5 : 0
            shadowOffsetX: 2
            shadowOffsetY: 2
        }

        P5Icon {
            anchors.centerIn: parent
            name: "wallpaper"
            size: 14
            color: PhantomState.wallpaperSelectorOpen ? PhantomState.foreground : PhantomState.secondary
        }

        MouseArea {
            id: wpBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    PhantomState.cycleWallpaper()
                } else {
                    PhantomState.toggleWallpaperSelector()
                }
            }
        }
    }

    // tombol buka riwayat chat notifikasi sns
    Item {
        visible: PhantomState.showImPill
        width: imPillRow.implicitWidth + 22
        height: 30

        P5SkewedCard {
            anchors.fill: parent
            fillColor: PhantomState.notificationsOpen ? PhantomState.primary : PhantomState.surface
            borderColor: PhantomState.borderLight
            shadowColor: PhantomState.secondary
            borderWidth: 2
            skewPx: PhantomState.polygonMode ? 5 : 0
            shadowOffsetX: 2
            shadowOffsetY: 2
        }

        Row {
            id: imPillRow
            anchors.centerIn: parent
            spacing: 5

            P5Icon {
                name: "message"
                size: 12
                color: PhantomState.secondary
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "IM"
                color: PhantomState.foreground
                font.pixelSize: 10
                font.weight: Font.Black
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                visible: PhantomState.showUnreadCount
                width: imCountText.implicitWidth + 10
                height: 16
                color: PhantomState.primary
                border.color: PhantomState.borderLight
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: imCountText
                    anchors.centerIn: parent
                    text: PhantomState.imNotifications.count
                    color: PhantomState.foreground
                    font.pixelSize: 9
                    font.weight: Font.Black
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: PhantomState.toggleNotifications()
        }
    }

    // tombol buka control center & pentagon star radar
    Item {
        visible: PhantomState.showStatsPill
        width: statsPillRow.implicitWidth + 24
        height: 30

        P5SkewedCard {
            anchors.fill: parent
            fillColor: PhantomState.dashboardOpen ? PhantomState.primary : PhantomState.surface
            borderColor: PhantomState.borderLight
            shadowColor: PhantomState.primary
            borderWidth: 2
            skewPx: PhantomState.polygonMode ? 5 : 0
            shadowOffsetX: 2
            shadowOffsetY: 2
        }

        Row {
            id: statsPillRow
            anchors.centerIn: parent
            spacing: 5

            P5Icon {
                name: "star"
                size: 11
                color: PhantomState.secondary
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "STATS " + Math.round(PhantomState.cpuPct) + "%"
                color: PhantomState.foreground
                font.pixelSize: 10
                font.weight: Font.Black
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: PhantomState.toggleDashboard()
        }
    }

    // pill baki aplikasi latar belakang (maks 2 ikon langsung, selebihnya tombol dropdown persona 5)
    Item {
        id: sysTrayPill
        readonly property int trayCount: SystemTray.items.values.length
        readonly property bool isDropdownMode: trayCount > 2
        visible: trayCount > 0
        width: isDropdownMode ? (trayDropdownRow.implicitWidth + 22) : (trayRow.implicitWidth + 18)
        height: 30

        P5SkewedCard {
            anchors.fill: parent
            fillColor: (sysTrayPill.isDropdownMode && PhantomState.trayPopupOpen)
                ? PhantomState.primary
                : (trayDropdownMouse.containsMouse && sysTrayPill.isDropdownMode ? PhantomState.surfaceAlt : PhantomState.surface)
            borderColor: PhantomState.borderLight
            shadowColor: (sysTrayPill.isDropdownMode && PhantomState.trayPopupOpen) ? PhantomState.secondary : PhantomState.primary
            borderWidth: 2
            skewPx: PhantomState.polygonMode ? 5 : 0
            shadowOffsetX: 2
            shadowOffsetY: 2
        }

        // mode 1-2 aplikasi: tampilkan ikon aplikasi secara langsung
        Row {
            id: trayRow
            visible: !sysTrayPill.isDropdownMode
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: SystemTray.items

                delegate: Item {
                    id: trayItem
                    required property SystemTrayItem modelData
                    required property int index
                    visible: index < 2
                    width: visible ? 22 : 0
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: trayMouse.containsMouse ? PhantomState.primary : PhantomState.surfaceAlt
                        borderColor: trayMouse.containsMouse ? PhantomState.borderLight : "transparent"
                        showShadowOffset: false
                        borderWidth: trayMouse.containsMouse ? 1 : 0
                        skewPx: PhantomState.polygonMode ? 3 : 0
                    }

                    IconImage {
                        anchors.centerIn: parent
                        width: 15
                        height: 15
                        source: trayItem.modelData.icon
                        asynchronous: true
                    }

                    MouseArea {
                        id: trayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                if (trayItem.modelData.onlyMenu && trayItem.modelData.hasMenu && rightRow.barWin) {
                                    const pos = trayItem.mapToItem(null, 0, trayItem.height + 4)
                                    trayItem.modelData.display(rightRow.barWin, Math.max(8, pos.x - 120), pos.y)
                                } else {
                                    trayItem.modelData.activate()
                                }
                            } else if (mouse.button === Qt.RightButton) {
                                if (trayItem.modelData.hasMenu && rightRow.barWin) {
                                    const pos = trayItem.mapToItem(null, 0, trayItem.height + 4)
                                    trayItem.modelData.display(rightRow.barWin, Math.max(8, pos.x - 120), pos.y)
                                } else {
                                    trayItem.modelData.secondaryActivate()
                                }
                            } else if (mouse.button === Qt.MiddleButton) {
                                trayItem.modelData.secondaryActivate()
                            }
                        }
                        onWheel: wheel => {
                            trayItem.modelData.scroll(wheel.angleDelta.y, false)
                        }
                    }
                }
            }
        }

        // mode > 2 aplikasi: berubah menjadi tombol dropdown bergaya persona 5
        Row {
            id: trayDropdownRow
            visible: sysTrayPill.isDropdownMode
            anchors.centerIn: parent
            spacing: 5

            P5Star {
                width: 14
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                spinning: PhantomState.trayPopupOpen
            }

            Text {
                text: "TRAY"
                color: PhantomState.foreground
                font.pixelSize: 10
                font.weight: Font.Black
                font.italic: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: trayCountTxt.implicitWidth + 8
                height: 16
                color: PhantomState.trayPopupOpen ? PhantomState.background : PhantomState.primary
                border.color: PhantomState.borderLight
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: trayCountTxt
                    anchors.centerIn: parent
                    text: String(sysTrayPill.trayCount)
                    color: PhantomState.foreground
                    font.pixelSize: 9
                    font.weight: Font.Black
                }
            }

            P5Icon {
                name: PhantomState.trayPopupOpen ? "chevron-up" : "chevron-down"
                size: 9
                color: PhantomState.secondary
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: trayDropdownMouse
            anchors.fill: parent
            enabled: sysTrayPill.isDropdownMode
            visible: sysTrayPill.isDropdownMode
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: PhantomState.toggleTrayPopup()
        }
    }

    // tombol buka menu pengaturan (settings)
    Item {
        width: 36
        height: 30

        P5SkewedCard {
            anchors.fill: parent
            fillColor: PhantomState.settingsOpen ? PhantomState.secondary : PhantomState.surface
            borderColor: PhantomState.borderLight
            shadowColor: PhantomState.primary
            borderWidth: 2
            skewPx: PhantomState.polygonMode ? 4 : 0
            shadowOffsetX: 2
            shadowOffsetY: 2
        }

        P5Icon {
            anchors.centerIn: parent
            name: "settings"
            size: 13
            color: PhantomState.settingsOpen ? PhantomState.background : PhantomState.foreground
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: PhantomState.toggleSettings()
        }
    }

    // tombol buka menu power & lock screen
    Item {
        width: 36
        height: 30

        P5SkewedCard {
            anchors.fill: parent
            fillColor: PhantomState.sessionOpen ? PhantomState.urgent : PhantomState.surfaceAlt
            borderColor: PhantomState.borderLight
            shadowColor: PhantomState.primary
            borderWidth: 2
            skewPx: PhantomState.polygonMode ? 4 : 0
            shadowOffsetX: 2
            shadowOffsetY: 2
        }

        P5Icon {
            anchors.centerIn: parent
            name: "power"
            size: 13
            color: PhantomState.foreground
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: PhantomState.toggleSession()
        }
    }
}
