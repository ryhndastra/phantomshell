import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

Scope {
    Variants {
        model: Quickshell.screens

        // panel control center thieves den (muncul pas klik tombol stats di bar)
        // ubah implicitWidth / implicitHeight di bawah kalau mau gedein ukuran panel dashboard
        PanelWindow {
            id: dashWin
            required property ShellScreen modelData
            screen: modelData
            visible: PhantomState.dashboardOpen

            readonly property bool isBottom: PhantomState.barPosition === "bottom"
            property int brightnessPct: 80

            WlrLayershell.namespace: "phantomshell-dashboard"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusiveZone: 0

            anchors {
                top: !dashWin.isBottom
                bottom: dashWin.isBottom
                right: true
            }
            margins {
                top: 42
                bottom: 42
                right: 10
            }

            implicitWidth: Math.min(415, (modelData?.width ?? 1280) - 20)
            implicitHeight: Math.min(585, (modelData?.height ?? 720) - 52)
            color: "transparent"

            onVisibleChanged: {
                if (visible) dashEntryAnim.restart()
            }

            Item {
                id: dashCard
                anchors.fill: parent
                transformOrigin: dashWin.isBottom ? Item.BottomRight : Item.TopRight

                ParallelAnimation {
                    id: dashEntryAnim
                    NumberAnimation {
                        target: dashCard
                        property: "scale"
                        from: 0.85
                        to: 1.0
                        duration: 240
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.35
                    }
                    NumberAnimation {
                        target: dashCard
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
                    spacing: 8

                    // 1. Phantom Thief Calling Card Profile Header
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

                    // 2. PERSONA 5 STAR SLIDERS (Modeled after Screenshot 4: `Dim [-- ★ --] Bright`)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        // A. Volume Star Slider
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Row {
                                Layout.preferredWidth: 88
                                spacing: 5
                                P5Icon { name: "volume"; size: 12; color: PhantomState.secondary; anchors.verticalCenter: parent.verticalCenter }
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

                                // White comic outer cutout box (`Dim [ --- ★ --- ] Bright` style!)
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

                                // Inner track line
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

                                // 5-Point Star Slider Thumb (Screenshot 4!)
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

                        // B. Screen Brightness Star Slider (Screenshot 4 `Dim [ --- ★ --- ] Bright`)
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Row {
                                Layout.preferredWidth: 88
                                spacing: 5
                                P5Icon { name: "sun"; size: 12; color: PhantomState.secondary; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "LIGHT " + dashWin.brightnessPct + "%"
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
                                        width: parent.width * Math.min(1.0, dashWin.brightnessPct / 100.0)
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
                                    x: 24 + (brtTrack.width - 68) * Math.min(1.0, Math.max(0.0, dashWin.brightnessPct / 100.0))
                                    Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    function setBrt(mx) {
                                        var pct = Math.round(Math.max(5, Math.min(100, ((mx - 24) / (brtTrack.width - 48)) * 100)))
                                        dashWin.brightnessPct = pct
                                        Quickshell.execDetached(["brightnessctl", "set", pct + "%"])
                                    }
                                    onPressed: mouse => setBrt(mouse.x)
                                    onPositionChanged: mouse => { if (pressed) setBrt(mouse.x) }
                                }
                            }
                        }
                    }

                    // 3. Quick Toggle Grid (3x2)
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: 5
                        columnSpacing: 6

                        Repeater {
                            model: [
                                { icon: "wifi",      label: "WI-FI",     active: PhantomState.wifiConnected, toggle: function() { PhantomState.wifiConnected = !PhantomState.wifiConnected } },
                                { icon: "bluetooth", label: "BT",        active: PhantomState.btConnected,   toggle: function() { PhantomState.btConnected = !PhantomState.btConnected } },
                                { icon: "bell-off",  label: "DND",       active: PhantomState.dndEnabled,    toggle: function() { PhantomState.dndEnabled = !PhantomState.dndEnabled } },
                                { icon: "polygon",   label: "POLYGON",   active: PhantomState.polygonMode,   toggle: function() { PhantomState.polygonMode = !PhantomState.polygonMode; PhantomState.saveState() } },
                                { icon: "frame",     label: "FRAME",     active: PhantomState.screenFrame,   toggle: function() { PhantomState.screenFrame = !PhantomState.screenFrame; PhantomState.saveState() } },
                                { icon: "volume",    label: "AUDIO SFX", active: PhantomState.sfxEnabled,    toggle: function() { PhantomState.sfxEnabled = !PhantomState.sfxEnabled; PhantomState.saveState() } }
                            ]

                            delegate: Item {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                scale: tileMouse.containsMouse ? 1.04 : 1.0
                                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: modelData.active ? PhantomState.primary : PhantomState.surface
                                    borderColor: PhantomState.borderLight
                                    shadowColor: modelData.active ? PhantomState.secondary : PhantomState.borderDark
                                    borderWidth: 1
                                    skewPx: PhantomState.polygonMode ? 5 : 0
                                    shadowOffsetX: 2
                                    shadowOffsetY: 2
                                }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    P5Icon {
                                        name: modelData.icon
                                        size: 11
                                        color: PhantomState.foreground
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.label
                                        color: PhantomState.foreground
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    id: tileMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.toggle()
                                }
                            }
                        }
                    }

                    // 4. Persona Theme Preset Switcher Row
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
                                Layout.preferredHeight: 28

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
                                    spacing: 5
                                    P5Icon {
                                        name: modelData.icon
                                        size: 10
                                        color: parent.parent.isCurrent ? PhantomState.background : PhantomState.foreground
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.label
                                        color: parent.parent.isCurrent ? PhantomState.background : PhantomState.foreground
                                        font.pixelSize: 9
                                        font.weight: Font.Black
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

                    // 5. 5-Point Star Header + Mode Switcher
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
                                    size: 10
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

                    // 6. The Giant 5-Point Star / Bars Component
                    P5PentagonStats {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    // 7. Footer shortcut to Full Unified Settings GUI
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: PhantomState.surface
                            borderColor: PhantomState.primary
                            shadowColor: PhantomState.primary
                            borderWidth: 2
                            skewPx: PhantomState.polygonMode ? 5 : 0
                            shadowOffsetX: 2
                            shadowOffsetY: 2
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            P5Icon {
                                name: "settings"
                                size: 12
                                color: PhantomState.secondary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "OPEN UNIFIED SETTINGS GUI"
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
                                PhantomState.dashboardOpen = false
                                PhantomState.settingsOpen = true
                            }
                        }
                    }
                }
            }
        }
    }
}
