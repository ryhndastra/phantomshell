import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config

// Indikator Workspace Numerik Stensil Kaca Persona 3 Reload
// Terintegrasi langsung pada background jendela monorail kiri atas tanpa panel bar
Item {
    id: root

    // Posisi di pojok kiri atas wallpaper (area kaca jendela monorail di bawah frame atap)
    anchors.top: parent.top
    anchors.topMargin: 46
    anchors.left: parent.left
    anchors.leftMargin: 48

    implicitWidth: wsRow.implicitWidth
    implicitHeight: 64

    z: 10

    // Hubungan ke Hyprland untuk refresh real-time saat ada event workspace/window
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            const ev = String(event.name || "")
            if (ev.indexOf("workspace") !== -1 || ev.indexOf("window") !== -1 || ev.indexOf("mon") !== -1) {
                PhantomState.refreshWorkspaces()
            }
        }
    }

    // Deretan Workspace Numerik
    Row {
        id: wsRow
        spacing: 22
        anchors.left: parent.left
        anchors.top: parent.top

        Repeater {
            model: PhantomState.workspaceCount

            delegate: Item {
                id: wsItem
                required property int index
                readonly property int wsId: index + 1
                readonly property bool isActive: (Hyprland.focusedMonitor?.activeWorkspace?.id ?? Hyprland.focusedWorkspace?.id ?? 1) === wsId
                readonly property var appList: (PhantomState.workspaceApps && PhantomState.workspaceApps[String(wsId)]) ? PhantomState.workspaceApps[String(wsId)] : []
                readonly property bool isOccupied: appList.length > 0
                readonly property bool isHovered: wsMouse.containsMouse

                width: Math.max(numText.implicitWidth, iconRow.implicitWidth, 34)
                height: 56

                // Scale interaktif halus
                scale: isActive ? 1.08 : (isHovered ? 1.04 : 1.0)
                transformOrigin: Item.TopLeft
                Behavior on scale {
                    NumberAnimation { duration: 180; easing.type: Easing.OutBack }
                }

                // Opacity kontrol:
                // Active: 1.0 (Putih solid tegas)
                // Inactive + Empty: 0.22 (Nyaru/samar dengan latar kaca awan)
                // Inactive + Occupied: 0.42 (Subtle translucent glass)
                // Hovered: 0.85 (Feedback interaktif)
                opacity: {
                    if (isActive) return 1.0
                    if (isHovered) return 0.85
                    if (isOccupied) return 0.45
                    return 0.22
                }
                Behavior on opacity {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                // Angka Workspace (01, 02, 03...)
                Text {
                    id: numText
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: (wsItem.wsId < 10 ? "0" : "") + wsItem.wsId
                    font.family: "Bebas Neue"
                    font.pixelSize: wsItem.isActive ? 38 : 34
                    font.bold: true
                    font.italic: true
                    color: "#ffffff"

                    // Bayangan halus stensil kaca agar kontras tetap terjaga
                    style: Text.Outline
                    styleColor: wsItem.isActive ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0, 0, 0, 0.2)
                }

                // Garis Aksen Stensil Kaca Khusus Active (Putih Bersih sesuai instruksi)
                Rectangle {
                    id: activeUnderline
                    anchors.top: numText.bottom
                    anchors.topMargin: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: numText.implicitWidth + 8
                    height: 2.5
                    radius: 1
                    color: "#ffffff"
                    visible: wsItem.isActive
                }

                // Ikon Aplikasi untuk Workspace yang Terisi (Occupied)
                Row {
                    id: iconRow
                    anchors.top: wsItem.isActive ? activeUnderline.bottom : numText.bottom
                    anchors.topMargin: wsItem.isActive ? 5 : 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4
                    visible: wsItem.isOccupied

                    Repeater {
                        model: wsItem.appList

                        delegate: Item {
                            required property var modelData
                            width: 14
                            height: 14

                            Image {
                                anchors.fill: parent
                                source: modelData.iconUrl || ""
                                visible: Boolean(modelData.iconUrl)
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                cache: true
                                smooth: true
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.glyph || "•"
                                visible: !modelData.iconUrl
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                color: "#ffffff"
                            }
                        }
                    }
                }

                // Area Interaksi Mouse: Klik untuk pindah workspace
                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        if (!wsItem.isActive) PhantomState.playSfx("select")
                    }
                    onClicked: {
                        PhantomState.playSfx("select")
                        Hyprland.dispatch("hl.dsp.focus({ workspace = " + String(wsItem.wsId) + " })")
                    }
                }
            }
        }
    }

    // Scroll Wheel Navigasi Antar Workspace
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                Hyprland.dispatch("hl.dsp.focus({ workspace = 'r-1' })")
                PhantomState.playSfx("select")
            } else if (wheel.angleDelta.y < 0) {
                Hyprland.dispatch("hl.dsp.focus({ workspace = 'r+1' })")
                PhantomState.playSfx("select")
            }
        }
    }
}
