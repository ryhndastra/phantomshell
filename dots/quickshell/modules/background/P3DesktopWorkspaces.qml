import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.config

// Indikator Workspace Numerik Stensil Kaca Persona 3 Reload
// Menyatu dengan background gerbong monorail kiri atas.
// Nomor samar/almost transparent menyatu dengan background.
// Saat occupied, ikon aplikasi me-override nomor workspace.
// Saat active, tampil putih/terang bersih tanpa underline.
// Disertai tombol simbol "V" expander untuk baki aplikasi (tray) yang menyatu dinamis.
Item {
    id: root

    // Status ekspansi baki aplikasi (tray) di samping workspace
    property bool trayExpanded: PhantomState.desktopTrayExpanded
    readonly property int trayCount: SystemTray.items.values.length

    // Deteksi posisi sesuai setting desktopWorkspacesPosition atau auto berdasarkan posisi jam desktop
    readonly property string effectivePosition: {
        const customPos = PhantomState.desktopWorkspacesPosition || "auto"
        if (customPos !== "auto") return customPos
        return PhantomState.desktopClockPosition === "top-left" ? "top-right" : "top-left"
    }

    readonly property bool isDockedRight: effectivePosition === "top-right" || effectivePosition === "bottom-right"
    readonly property bool isDockedBottom: effectivePosition === "bottom-left" || effectivePosition === "bottom-right"

    anchors.top: !isDockedBottom ? parent.top : undefined
    anchors.bottom: isDockedBottom ? parent.bottom : undefined
    anchors.topMargin: !isDockedBottom ? 38 : 0
    anchors.bottomMargin: isDockedBottom ? 38 : 0

    x: isDockedRight ? (parent.width - width - 48) : 48
    width: wsRow.implicitWidth
    height: 42
    implicitWidth: wsRow.implicitWidth
    implicitHeight: 46

    Behavior on width {
        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
    }

    Behavior on x {
        NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
    }

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

    // Deretan Slot Workspace + Tray Expander
    Row {
        id: wsRow
        spacing: 24
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: PhantomState.visibleWorkspaces

            delegate: Item {
                id: wsItem
                required property int index
                required property var modelData
                readonly property int wsId: (typeof modelData === "number" ? modelData : (index + 1))
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

        // Bagian Baki Aplikasi (Tray) Terintegrasi di Desktop Workspace
        // Terhubung langsung di container yang sama sehingga otomatis bergeser jika workspace bertambah (mis. WS 7)
        Row {
            id: traySection
            spacing: 12
            anchors.verticalCenter: parent.verticalCenter
            visible: root.trayCount > 0

            // Garis pemisah stensil tipis
            Rectangle {
                width: 1
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "#64aff0"
                opacity: 0.25
            }

            // Tombol Simbol "V" / Toggle Tray Expander
            Item {
                id: vBtn
                width: 30
                height: 42
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: vText
                    anchors.centerIn: parent
                    text: "V"
                    font.family: "Bebas Neue"
                    font.pixelSize: root.trayExpanded ? 40 : 36
                    font.bold: true
                    font.italic: true
                    color: root.trayExpanded ? "#ffffff" : (vMouse.containsMouse ? "#ffffff" : "#64aff0")

                    // Rotasi halus saat di-expand: V berputar -90° menghadap ke kanan (>)
                    rotation: root.trayExpanded ? -90 : 0
                    transformOrigin: Item.Center

                    Behavior on rotation {
                        NumberAnimation { duration: 250; easing.type: Easing.OutBack }
                    }
                    Behavior on font.pixelSize {
                        NumberAnimation { duration: 160 }
                    }
                }

                // Opacity & scale interaktif
                opacity: root.trayExpanded ? 1.0 : (vMouse.containsMouse ? 0.90 : 0.35)
                scale: vMouse.containsMouse ? 1.14 : (root.trayExpanded ? 1.06 : 1.0)
                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                MouseArea {
                    id: vMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: PhantomState.playSfx("select")
                    onClicked: {
                        PhantomState.playSfx("select")
                        PhantomState.toggleDesktopTray()
                    }
                }
            }

            // Ikon-ikon aplikasi tray yang muncul saat expand
            Item {
                id: trayIconsClip
                height: 42
                anchors.verticalCenter: parent.verticalCenter
                clip: true

                // Lebar menganimasi otomatis saat expand/collapse
                width: root.trayExpanded ? trayIconsRow.implicitWidth : 0
                opacity: root.trayExpanded ? 1.0 : 0.0

                Behavior on width {
                    NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                Row {
                    id: trayIconsRow
                    spacing: 10
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: SystemTray.items

                        delegate: Item {
                            id: trayAppItem
                            required property SystemTrayItem modelData
                            required property int index

                            width: 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            // Hover scale & opacity
                            scale: trayAppMouse.containsMouse ? 1.15 : 1.0
                            opacity: trayAppMouse.containsMouse ? 1.0 : 0.85
                            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                            Behavior on opacity { NumberAnimation { duration: 140 } }

                            // Frame stensil halus saat hover
                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: trayAppMouse.containsMouse ? Qt.rgba(0, 0.85, 1, 0.20) : Qt.rgba(0, 0, 0, 0.25)
                                border.color: trayAppMouse.containsMouse ? "#00f0ff" : Qt.rgba(0, 0.85, 1, 0.18)
                                border.width: 1
                            }

                            // Ikon aplikasi dari StatusNotifierItem
                            IconImage {
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                source: trayAppItem.modelData.icon
                                asynchronous: true
                            }

                            MouseArea {
                                id: trayAppMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                onEntered: PhantomState.playSfx("select")
                                onClicked: mouse => {
                                    PhantomState.playSfx("select")
                                    if (mouse.button === Qt.LeftButton) {
                                        PhantomState.activateTrayItem(trayAppItem.modelData)
                                    } else if (mouse.button === Qt.RightButton) {
                                        if (trayAppItem.modelData.hasMenu && root.Window.window) {
                                            const pos = trayAppItem.mapToItem(null, 0, trayAppItem.height + 6)
                                            trayAppItem.modelData.display(root.Window.window, Math.max(8, pos.x), pos.y)
                                        } else {
                                            trayAppItem.modelData.secondaryActivate()
                                        }
                                    } else if (mouse.button === Qt.MiddleButton) {
                                        trayAppItem.modelData.secondaryActivate()
                                    }
                                }
                                onWheel: wheel => {
                                    trayAppItem.modelData.scroll(wheel.angleDelta.y, false)
                                }
                            }

                            // Tooltip nama aplikasi saat di-hover
                            Item {
                                visible: trayAppMouse.containsMouse
                                anchors.bottom: parent.top
                                anchors.bottomMargin: 8
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: tipTxt.implicitWidth + 14
                                height: 22
                                z: 100

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 3
                                    color: "#020718"
                                    border.color: "#00dbff"
                                    border.width: 1
                                }

                                Text {
                                    id: tipTxt
                                    anchors.centerIn: parent
                                    text: {
                                        const t = trayAppItem.modelData.title || trayAppItem.modelData.tooltipTitle || trayAppItem.modelData.id || "APP"
                                        return String(t).replace(/^_/, "").toUpperCase()
                                    }
                                    color: "#00dbff"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }
                        }
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
