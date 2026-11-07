import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config

// Indikator Workspace Numerik Stensil Kaca Persona 3 Reload
// Menyatu dengan background gerbong monorail kiri atas.
// Nomor samar/almost transparent menyatu dengan background.
// Saat occupied, ikon aplikasi me-override nomor workspace.
// Saat active, tampil putih/terang bersih tanpa underline.
Item {
    id: root

    // Posisi di pojok kiri atas wallpaper (pada bilah atap gerbong monorail)
    anchors.top: parent.top
    anchors.topMargin: 38
    anchors.left: parent.left
    anchors.leftMargin: 48

    implicitWidth: wsRow.implicitWidth
    implicitHeight: 46

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

    // Deretan Slot Workspace
    Row {
        id: wsRow
        spacing: 24
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

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

                width: Math.max(isOccupied ? (appList.length > 1 ? 52 : 36) : numText.implicitWidth, 38)
                height: 42

                // Scale interaktif halus
                scale: isActive ? 1.12 : (isHovered ? 1.06 : 1.0)
                transformOrigin: Item.Center
                Behavior on scale {
                    NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                }

                // Opacity kontrol:
                // Active: 1.0 (Putih / icon tegas terang)
                // Inactive: 0.30 (Samar-samar, almost transparent, nyaru dengan latar belakang)
                // Hovered: 0.85 (Feedback interaktif)
                opacity: {
                    if (isActive) return 1.0
                    if (isHovered) return 0.85
                    return 0.30
                }
                Behavior on opacity {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                // 1. Ikon Aplikasi: Meng-override nomor workspace saat ada aplikasi (occupied)
                Item {
                    anchors.centerIn: parent
                    visible: wsItem.isOccupied
                    width: appRow.implicitWidth
                    height: 32

                    Row {
                        id: appRow
                        anchors.centerIn: parent
                        spacing: 4

                        Repeater {
                            model: Math.min(wsItem.appList.length, 2)

                            delegate: Item {
                                required property int index
                                readonly property var appData: wsItem.appList[index]
                                width: wsItem.appList.length > 1 ? 22 : 32
                                height: wsItem.appList.length > 1 ? 22 : 32

                                Image {
                                    anchors.fill: parent
                                    source: appData.iconUrl || ""
                                    visible: Boolean(appData.iconUrl)
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    cache: true
                                    smooth: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: appData.glyph || "•"
                                    visible: !appData.iconUrl
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: wsItem.appList.length > 1 ? 14 : 20
                                    color: wsItem.isActive ? "#ffffff" : "#64aff0"
                                }
                            }
                        }
                    }
                }

                // 2. Nomor Workspace: Hanya tampil saat workspace KOSONG (tidak ter-override icon)
                Text {
                    id: numText
                    anchors.centerIn: parent
                    visible: !wsItem.isOccupied
                    text: (wsItem.wsId < 10 ? "0" : "") + wsItem.wsId
                    font.family: "Bebas Neue"
                    font.pixelSize: wsItem.isActive ? 42 : 38
                    font.bold: true
                    font.italic: true
                    // Putih murni saat active; warna biru lembut selaras background saat inactive
                    color: wsItem.isActive ? "#ffffff" : "#64aff0"
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
