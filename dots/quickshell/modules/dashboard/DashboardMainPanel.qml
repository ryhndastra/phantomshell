import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components

// tampilan utama control center: slider bintang, tombol aksi cepat, dan grafik statistik sistem
ColumnLayout {
    id: mainPanel
    anchors.fill: parent
    anchors.margins: 16
    spacing: 8

    required property var dashWin

    // header calling card control center
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        P5Star {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            spinning: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: "THIEVES DEN // CONTROL CENTER"
                color: PhantomState.primary
                font.pixelSize: 14
                font.weight: Font.Black
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: "JOKER (SHO) • BAT " + PhantomState.batteryPct + "% • " + PhantomState.themeName.toUpperCase()
                color: PhantomState.muted
                font.pixelSize: 9
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
        }

        Rectangle {
            width: 24
            height: 24
            color: PhantomState.surfaceAlt
            border.color: PhantomState.borderLight
            border.width: 1
            P5Icon { anchors.centerIn: parent; name: "close"; size: 11 }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: PhantomState.dashboardOpen = false
            }
        }
    }

    // slider bintang volume & brightness
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Row {
                Layout.preferredWidth: 92
                spacing: 6
                P5Icon { name: "volume"; size: 13; color: PhantomState.secondary; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: "AUDIO " + PhantomState.volumePct + "%"
                    color: PhantomState.foreground
                    font.pixelSize: 10
                    font.weight: Font.Black
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: volTrack
                Layout.fillWidth: true
                Layout.preferredHeight: 26

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: "#080A0F"
                    borderColor: "#FFFFFF"
                    shadowColor: PhantomState.primary
                    borderWidth: 2
                    skewPx: 5
                    shadowOffsetX: 2
                    shadowOffsetY: 2
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 32
                    anchors.rightMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                    height: 3
                    color: "#44FFFFFF"

                    Rectangle {
                        width: parent.width * Math.min(1.0, PhantomState.volumePct / 100.0)
                        height: parent.height
                        color: PhantomState.primary
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "MIN"
                    color: PhantomState.muted
                    font.pixelSize: 8
                    font.weight: Font.Black
                    rotation: -12
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "MAX"
                    color: PhantomState.secondary
                    font.pixelSize: 8
                    font.weight: Font.Black
                    rotation: -12
                }

                P5Star {
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    x: 24 + (volTrack.width - 68) * Math.min(1.0, Math.max(0.0, PhantomState.volumePct / 100.0))
                    Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function setFromMouse(mx) {
                        var pct = Math.round(Math.max(0, Math.min(100, ((mx - 24) / (volTrack.width - 48)) * 100)))
                        PhantomState.volumePct = pct
                        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct + "%"])
                    }
                    onPressed: mouse => setFromMouse(mouse.x)
                    onPositionChanged: mouse => { if (pressed) setFromMouse(mouse.x) }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Row {
                Layout.preferredWidth: 92
                spacing: 6
                P5Icon { name: "sun"; size: 13; color: PhantomState.secondary; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: "LIGHT " + mainPanel.dashWin.brightnessPct + "%"
                    color: PhantomState.foreground
                    font.pixelSize: 10
                    font.weight: Font.Black
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                id: brtTrack
                Layout.fillWidth: true
                Layout.preferredHeight: 26

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: "#080A0F"
                    borderColor: "#FFFFFF"
                    shadowColor: PhantomState.primary
                    borderWidth: 2
                    skewPx: 5
                    shadowOffsetX: 2
                    shadowOffsetY: 2
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 32
                    anchors.rightMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                    height: 3
                    color: "#44FFFFFF"

                    Rectangle {
                        width: parent.width * Math.min(1.0, mainPanel.dashWin.brightnessPct / 100.0)
                        height: parent.height
                        color: PhantomState.secondary
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "DIM"
                    color: PhantomState.muted
                    font.pixelSize: 8
                    font.weight: Font.Black
                    rotation: -12
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: "BRT"
                    color: PhantomState.secondary
                    font.pixelSize: 8
                    font.weight: Font.Black
                    rotation: -12
                }

                P5Star {
                    width: 20
                    height: 20
                    anchors.verticalCenter: parent.verticalCenter
                    x: 24 + (brtTrack.width - 68) * Math.min(1.0, Math.max(0.0, mainPanel.dashWin.brightnessPct / 100.0))
                    Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function setBrt(mx) {
                        var pct = Math.round(Math.max(5, Math.min(100, ((mx - 24) / (brtTrack.width - 48)) * 100)))
                        mainPanel.dashWin.brightnessPct = pct
                        Quickshell.execDetached(["brightnessctl", "set", pct + "%"])
                    }
                    onPressed: mouse => setBrt(mouse.x)
                    onPositionChanged: mouse => { if (pressed) setBrt(mouse.x) }
                }
            }
        }
    }

    // grid tombol aksi cepat sistem
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 6
        columnSpacing: 8

        P5BattleBlade {
            title: "WI-FI"
            subtitle: PhantomState.wifiConnected ? (PhantomState.wifiSsid + " ▸") : "Radio Off • Open Menu"
            iconName: PhantomState.wifiConnected ? "wifi" : "wifi-off"
            badgeColor: "#00F0FF"
            active: PhantomState.wifiConnected
            bladeTilt: -1.5
            onClicked: {
                mainPanel.dashWin.selectedWifiIdx = -1
                mainPanel.dashWin.showWifiInfo = false
                mainPanel.dashWin.showWifiPasswordBox = false
                mainPanel.dashWin.subPanel = "wifi"
                PhantomState.refreshWifi()
            }
        }

        P5BattleBlade {
            title: "BLUETOOTH"
            subtitle: PhantomState.btConnected ? (PhantomState.btDeviceName + " ▸") : "Power Off • Open Menu"
            iconName: "bluetooth"
            badgeColor: "#48CAE4"
            active: PhantomState.btConnected
            bladeTilt: 1.2
            onClicked: {
                mainPanel.dashWin.selectedBtIdx = -1
                mainPanel.dashWin.showBtInfo = false
                mainPanel.dashWin.subPanel = "bluetooth"
                PhantomState.refreshBluetooth()
            }
        }

        P5BattleBlade {
            title: "STEALTH"
            subtitle: PhantomState.dndEnabled ? "DND Active (Muted)" : "SNS Popups Active"
            iconName: PhantomState.dndEnabled ? "bell-off" : "bell"
            badgeColor: "#FFD700"
            active: PhantomState.dndEnabled
            bladeTilt: 1.0
            onClicked: PhantomState.dndEnabled = !PhantomState.dndEnabled
        }

        P5BattleBlade {
            title: "POLYGON"
            subtitle: PhantomState.polygonMode ? "Skewed P5 Cutouts" : "Flat Rectangles"
            iconName: "polygon"
            badgeColor: "#00F59B"
            active: PhantomState.polygonMode
            bladeTilt: -1.2
            onClicked: {
                PhantomState.polygonMode = !PhantomState.polygonMode
                PhantomState.saveState()
            }
        }

        P5BattleBlade {
            title: "AUDIO SFX"
            subtitle: PhantomState.sfxEnabled ? "Persona 5 Cues ON" : "UI Sounds Muted"
            iconName: PhantomState.sfxEnabled ? "volume" : "mute"
            badgeColor: "#FF4D88"
            active: PhantomState.sfxEnabled
            bladeTilt: -1.0
            onClicked: {
                PhantomState.sfxEnabled = !PhantomState.sfxEnabled
                PhantomState.saveState()
            }
        }

        P5BattleBlade {
            title: "LOCK CARD"
            subtitle: "Lock Session Screen"
            iconName: "lock"
            badgeColor: "#FFFFFF"
            active: false
            bladeTilt: 1.4
            onClicked: PhantomState.lockScreen()
        }
    }

    // baris tombol pemilih preset tema cepat
    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Repeater {
            model: [
                { id: "p5-crimson", icon: "phantom", label: "P5 CRIMSON" },
                { id: "p3-reload",  icon: "moon",    label: "P3 RELOAD" },
                { id: "p4-golden",  icon: "tv",      label: "P4 GOLDEN" }
            ]

            delegate: Item {
                required property var modelData
                readonly property bool isCurrent: PhantomState.themeId === modelData.id
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Layout.minimumHeight: 28
                implicitHeight: 30

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: parent.isCurrent ? PhantomState.secondary : PhantomState.surfaceAlt
                    borderColor: PhantomState.borderLight
                    showShadowOffset: false
                    borderWidth: parent.isCurrent ? 2 : 1
                    skewPx: PhantomState.polygonMode ? 4 : 0
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    P5Icon {
                        name: modelData.icon
                        size: 13
                        color: parent.parent.isCurrent ? PhantomState.background : PhantomState.foreground
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: modelData.label
                        color: parent.parent.isCurrent ? PhantomState.background : PhantomState.foreground
                        font.pixelSize: 10
                        font.weight: Font.Black
                        font.italic: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PhantomState.applyPreset(modelData.id)
                }
            }
        }
    }

    // header grafik statistik sistem dan tombol ganti mode tampilan
    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        Text {
            Layout.fillWidth: true
            text: "SYSTEM SOCIAL STATS // 5-POINT STAR"
            color: PhantomState.secondary
            font.pixelSize: 11
            font.weight: Font.Black
            elide: Text.ElideRight
        }

        Item {
            Layout.preferredWidth: modeSwitchRow.implicitWidth + 20
            Layout.preferredHeight: 22
            implicitHeight: 22

            P5SkewedCard {
                anchors.fill: parent
                fillColor: PhantomState.surfaceAlt
                borderColor: PhantomState.borderLight
                showShadowOffset: false
                borderWidth: 1
                skewPx: 4
            }

            Row {
                id: modeSwitchRow
                anchors.centerIn: parent
                spacing: 4
                P5Icon {
                    name: PhantomState.statsStyle === "pentagon" ? "star" : "bars"
                    size: 11
                    color: PhantomState.secondary
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: PhantomState.statsStyle === "pentagon" ? "STAR MODE" : "BARS MODE"
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
                    PhantomState.statsStyle = (PhantomState.statsStyle === "pentagon") ? "bars" : "pentagon"
                    PhantomState.saveState()
                }
            }
        }
    }

    // komponen grafik statistik sistem
    P5PentagonStats {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 125
        Layout.preferredHeight: 175
    }

    // tombol pembuka jendela pengaturan lengkap
    Item {
        id: openSettingsBtn
        Layout.fillWidth: true
        Layout.minimumHeight: 36
        Layout.preferredHeight: 36
        implicitHeight: 36
        z: 10

        P5SkewedCard {
            anchors.fill: parent
            fillColor: openSettingsMouse.containsMouse ? PhantomState.primary : PhantomState.surface
            borderColor: openSettingsMouse.containsMouse ? "#FFFFFF" : PhantomState.primary
            shadowColor: openSettingsMouse.containsMouse ? PhantomState.secondary : PhantomState.primary
            borderWidth: 2
            skewPx: PhantomState.polygonMode ? 6 : 0
            shadowOffsetX: 3
            shadowOffsetY: 3
        }

        Row {
            anchors.centerIn: parent
            spacing: 8
            P5Icon {
                name: "settings"
                size: 14
                color: openSettingsMouse.containsMouse ? "#FFFFFF" : PhantomState.secondary
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "OPEN UNIFIED SETTINGS GUI"
                color: "#FFFFFF"
                font.pixelSize: 11
                font.weight: Font.Black
                font.italic: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: openSettingsMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                PhantomState.playSfx("select")
                PhantomState.toggleSettings()
            }
        }
    }
}
