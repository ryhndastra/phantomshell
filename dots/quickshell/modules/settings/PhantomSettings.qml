import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: settingsWin
        property var modelData
        screen: modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: PhantomState.settingsOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"
        visible: PhantomState.settingsOpen || fadeBg.opacity > 0.01
        onVisibleChanged: {
            if (visible) PhantomState.refreshMonitors()
        }

        // indeks tab pengaturan yang sedang aktif
        property int activeTab: 0

        // kontainer utama jendela pengaturan
        Rectangle {
            id: fadeBg
            anchors.fill: parent
            color: "#CC07070A"
            opacity: PhantomState.settingsOpen ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.settingsOpen = false
            }

            Item {
                width: Math.min(parent.width - 60, 980)
                height: Math.min(parent.height - 60, 700)
                anchors.centerIn: parent

                MouseArea { anchors.fill: parent }

                // latar kartu miring utama jendela pengaturan
                Canvas {
                    anchors.fill: parent
                    property color accent: PhantomState.primary
                    onAccentChanged: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var h = height

                        ctx.fillStyle = Qt.rgba(accent.r, accent.g, accent.b, 0.28)
                        ctx.beginPath()
                        ctx.moveTo(26, 16)
                        ctx.lineTo(w, 6)
                        ctx.lineTo(w - 18, h - 46)
                        ctx.lineTo(8, h - 38)
                        ctx.closePath()
                        ctx.fill()

                        ctx.fillStyle = "#EE0B0B0F"
                        ctx.strokeStyle = "#FFFFFF"
                        ctx.lineWidth = 2.5
                        ctx.beginPath()
                        ctx.moveTo(18, 8)
                        ctx.lineTo(w - 10, 0)
                        ctx.lineTo(w - 26, h - 54)
                        ctx.lineTo(0, h - 46)
                        ctx.closePath()
                        ctx.fill()
                        ctx.stroke()
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 22
                    anchors.bottomMargin: 78
                    anchors.leftMargin: 36
                    anchors.rightMargin: 42
                    spacing: 12

                    // baris judul atas dan deretan tab kategori pengaturan
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // lencana judul pengaturan di kiri atas
                        Item {
                            Layout.preferredWidth: 235
                            Layout.preferredHeight: 54
                            rotation: -2

                            Canvas {
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.reset()
                                    ctx.fillStyle = "#FFFFFF"
                                    ctx.beginPath()
                                    ctx.moveTo(10, 0)
                                    ctx.lineTo(width, 4)
                                    ctx.lineTo(width - 12, height)
                                    ctx.lineTo(0, height - 4)
                                    ctx.closePath()
                                    ctx.fill()

                                    ctx.fillStyle = "#08080A"
                                    ctx.beginPath()
                                    ctx.moveTo(15, 5)
                                    ctx.lineTo(width - 6, 8)
                                    ctx.lineTo(width - 16, height - 5)
                                    ctx.lineTo(5, height - 8)
                                    ctx.closePath()
                                    ctx.fill()
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 8

                                Image {
                                    Layout.preferredWidth: 34
                                    Layout.preferredHeight: 34
                                    source: PhantomState.logoPath
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    mipmap: true
                                }

                                ColumnLayout {
                                    spacing: 0
                                    Text {
                                        text: "SYSTEM CONFIG"
                                        color: "#FFFFFF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 17
                                        font.weight: Font.Black
                                        font.italic: true
                                    }
                                    Text {
                                        text: "VELVET ROOM // FULL SUITE"
                                        color: PhantomState.secondary
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 8
                                        font.weight: Font.Black
                                    }
                                }
                            }
                        }

                        // deretan tombol tab kategori
                        Repeater {
                            model: [
                                { idx: 0, icon: "palette",  label: "1. THEME" },
                                { idx: 1, icon: "bars",     label: "2. BAR" },
                                { idx: 2, icon: "sparkles", label: "3. DESKTOP" },
                                { idx: 3, icon: "frame",    label: "4. UI & IM" },
                                { idx: 4, icon: "polygon",  label: "5. HYPR" },
                                { idx: 5, icon: "star",     label: "6. ABOUT" }
                            ]

                            delegate: Item {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                readonly property bool isCurr: settingsWin.activeTab === modelData.idx

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: parent.isCurr ? PhantomState.primary : "#15151E"
                                    borderColor: "#FFFFFF"
                                    shadowColor: parent.isCurr ? PhantomState.secondary : "#08080A"
                                    borderWidth: 2
                                    skewPx: 7
                                }

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 5
                                    P5Icon {
                                        name: modelData.icon
                                        size: 12
                                        color: parent.parent.isCurr ? "#FFFFFF" : PhantomState.secondary
                                    }
                                    Text {
                                        text: modelData.label
                                        color: "#FFFFFF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.weight: Font.Black
                                        font.italic: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: settingsWin.activeTab = modelData.idx
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 2
                        color: PhantomState.primary
                    }

                    // area konten tab yang dapat digulir
                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: activeTabCol.implicitHeight + 20
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: activeTabCol
                            width: parent.width
                            spacing: 10

                            SettingsThemeTab {
                                visible: settingsWin.activeTab === 0
                            }

                            SettingsBarTab {
                                visible: settingsWin.activeTab === 1
                            }

                            SettingsDesktopTab {
                                visible: settingsWin.activeTab === 2
                            }

                            SettingsUiImTab {
                                visible: settingsWin.activeTab === 3
                            }

                            SettingsHyprTab {
                                visible: settingsWin.activeTab === 4
                            }

                            SettingsAboutTab {
                                visible: settingsWin.activeTab === 5
                            }
                        }
                    }
                }

                // tombol stempel penutup jendela pengaturan di bagian bawah
                Item {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 195
                    height: 66
                    rotation: -6
                    z: 30
                    scale: okSettingsMouse.containsMouse ? 1.06 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                    Canvas {
                        anchors.fill: parent
                        property bool hov: okSettingsMouse.containsMouse
                        property color accent: PhantomState.primary
                        onHovChanged: requestPaint()
                        onAccentChanged: requestPaint()
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.fillStyle = "#FFFFFF"
                            ctx.beginPath()
                            ctx.moveTo(14, 0)
                            ctx.lineTo(width, 6)
                            ctx.lineTo(width - 16, height)
                            ctx.lineTo(0, height - 6)
                            ctx.closePath()
                            ctx.fill()

                            ctx.fillStyle = hov ? accent : "#08080A"
                            ctx.beginPath()
                            ctx.moveTo(20, 6)
                            ctx.lineTo(width - 8, 12)
                            ctx.lineTo(width - 22, height - 6)
                            ctx.lineTo(6, height - 12)
                            ctx.closePath()
                            ctx.fill()
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        P5Icon {
                            name: "star"
                            color: okSettingsMouse.containsMouse ? "#FFFFFF" : PhantomState.primary
                            size: 24
                        }
                        Text {
                            text: "OK"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 32
                            font.weight: Font.Black
                            font.italic: true
                        }
                    }

                    MouseArea {
                        id: okSettingsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PhantomState.settingsOpen = false
                    }
                }
            }
        }
    }
}
