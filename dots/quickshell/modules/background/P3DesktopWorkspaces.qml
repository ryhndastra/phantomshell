import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.config

// Persona 3 Reload glass stencil workspace indicator with integrated tray expander.
Item {
    id: root

    // Tray expander state
    property bool trayExpanded: PhantomState.desktopTrayExpanded
    readonly property int trayCount: SystemTray.items.values.length
    property int activeMenuIndex: -1

    readonly property var activeTrayItem: (root.activeMenuIndex >= 0 && root.activeMenuIndex < SystemTray.items.values.length)
        ? SystemTray.items.values[root.activeMenuIndex]
        : null

    // DBus menu opener for active tray item
    QsMenuOpener {
        id: activeMenuOpener
        menu: root.activeTrayItem && root.activeTrayItem.hasMenu ? root.activeTrayItem.menu : null
    }

    // Resolve docked position
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

    // Hyprland event listeners
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            const ev = String(event.name || "")
            if (ev.indexOf("workspace") !== -1 || ev.indexOf("window") !== -1 || ev.indexOf("mon") !== -1) {
                PhantomState.refreshWorkspaces()
            }
        }
    }

    // Workspace slots and tray expander
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

                scale: isActive ? 1.12 : (isHovered ? 1.06 : 1.0)
                transformOrigin: Item.Center
                Behavior on scale {
                    NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                }

                opacity: {
                    if (isActive) return 1.0
                    if (isHovered) return 0.85
                    return 0.30
                }
                Behavior on opacity {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                // App icon overrides workspace number when occupied
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

                // Workspace number when unoccupied
                Text {
                    id: numText
                    anchors.centerIn: parent
                    visible: !wsItem.isOccupied
                    text: (wsItem.wsId < 10 ? "0" : "") + wsItem.wsId
                    font.family: "Bebas Neue"
                    font.pixelSize: wsItem.isActive ? 42 : 38
                    font.bold: true
                    font.italic: true
                    color: wsItem.isActive ? "#ffffff" : "#64aff0"
                }

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

        // Integrated tray expander
        Row {
            id: traySection
            spacing: 12
            anchors.verticalCenter: parent.verticalCenter
            visible: root.trayCount > 0

            Rectangle {
                width: 1
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "#64aff0"
                opacity: 0.25
            }

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

                    rotation: root.trayExpanded ? -90 : 0
                    transformOrigin: Item.Center

                    Behavior on rotation {
                        NumberAnimation { duration: 250; easing.type: Easing.OutBack }
                    }
                    Behavior on font.pixelSize {
                        NumberAnimation { duration: 160 }
                    }
                }

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
                        root.activeMenuIndex = -1
                        PhantomState.toggleDesktopTray()
                    }
                }
            }

            Item {
                id: trayIconsClip
                height: 42
                anchors.verticalCenter: parent.verticalCenter
                clip: true

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
                    spacing: 12
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

                            scale: trayAppMouse.containsMouse ? 1.20 : 1.0
                            opacity: trayAppMouse.containsMouse ? 1.0 : 0.80
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            IconImage {
                                anchors.centerIn: parent
                                width: 24
                                height: 24
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
                                        root.activeMenuIndex = -1
                                        PhantomState.activateTrayItem(trayAppItem.modelData)
                                    } else if (mouse.button === Qt.RightButton) {
                                        root.activeMenuIndex = (root.activeMenuIndex === trayAppItem.index ? -1 : trayAppItem.index)
                                    } else if (mouse.button === Qt.MiddleButton) {
                                        root.activeMenuIndex = -1
                                        trayAppItem.modelData.secondaryActivate()
                                    }
                                }
                                onWheel: wheel => {
                                    trayAppItem.modelData.scroll(wheel.angleDelta.y, false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Stencil context menu
    Item {
        id: contextMenuCard
        visible: root.activeMenuIndex >= 0 && root.trayExpanded && root.activeTrayItem !== null
        anchors.top: wsRow.bottom
        anchors.topMargin: 8
        x: Math.max(0, traySection.x + trayIconsClip.x + (root.activeMenuIndex * 44) - 2)
        width: actionsCol.implicitWidth
        height: actionsCol.implicitHeight
        z: 1000

        Column {
            id: actionsCol
            spacing: 4
            anchors.left: parent.left
            anchors.top: parent.top

            // Fallback open action when application has no DBus menu
            Text {
                visible: activeMenuOpener.children.values.length === 0
                text: "OPEN"
                font.family: "Bebas Neue"
                font.pixelSize: 22
                font.bold: true
                font.italic: true
                color: "#ffffff"
                opacity: defOpenMouse.containsMouse ? 1.0 : 0.45
                scale: defOpenMouse.containsMouse ? 1.08 : 1.0
                transformOrigin: Item.Left

                Behavior on opacity { NumberAnimation { duration: 140 } }
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                MouseArea {
                    id: defOpenMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: PhantomState.playSfx("select")
                    onClicked: {
                        PhantomState.playSfx("select")
                        if (root.activeTrayItem) {
                            PhantomState.activateTrayItem(root.activeTrayItem)
                        }
                        root.activeMenuIndex = -1
                    }
                }
            }

            // Native DBus menu items
            Repeater {
                model: activeMenuOpener.children

                delegate: Item {
                    id: menuEntryWrap
                    required property QsMenuEntry modelData
                    readonly property string cleanLabel: String(modelData.text || "").replace(/_/g, "").trim()
                    readonly property bool isKillOrQuit: /^(quit|kill|exit|keluar|tutup)/i.test(cleanLabel)
                    visible: !modelData.isSeparator && cleanLabel.length > 0
                    width: entryText.implicitWidth
                    height: entryText.implicitHeight

                    Text {
                        id: entryText
                        text: menuEntryWrap.cleanLabel.toUpperCase()
                        font.family: "Bebas Neue"
                        font.pixelSize: 22
                        font.bold: true
                        font.italic: true
                        color: menuEntryWrap.isKillOrQuit
                            ? (entryMouse.containsMouse ? "#ff2255" : "#ff5577")
                            : "#ffffff"
                        opacity: !menuEntryWrap.modelData.enabled
                            ? 0.20
                            : (entryMouse.containsMouse ? 1.0 : (menuEntryWrap.isKillOrQuit ? 0.60 : 0.45))
                        scale: entryMouse.containsMouse ? 1.08 : 1.0
                        transformOrigin: Item.Left

                        Behavior on opacity { NumberAnimation { duration: 140 } }
                        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 140 } }
                    }

                    MouseArea {
                        id: entryMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: menuEntryWrap.modelData.enabled
                        cursorShape: menuEntryWrap.modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onEntered: PhantomState.playSfx("select")
                        onClicked: {
                            PhantomState.playSfx("select")
                            menuEntryWrap.modelData.triggered()
                            root.activeMenuIndex = -1
                        }
                    }
                }
            }

            // Force kill option
            Text {
                id: killText
                text: "KILL"
                font.family: "Bebas Neue"
                font.pixelSize: 22
                font.bold: true
                font.italic: true
                color: killMouse.containsMouse ? "#ff2255" : "#ff5577"
                opacity: killMouse.containsMouse ? 1.0 : 0.55
                scale: killMouse.containsMouse ? 1.08 : 1.0
                transformOrigin: Item.Left

                Behavior on color { ColorAnimation { duration: 140 } }
                Behavior on opacity { NumberAnimation { duration: 140 } }
                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                MouseArea {
                    id: killMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: PhantomState.playSfx("select")
                    onClicked: {
                        PhantomState.playSfx("select")
                        if (root.activeTrayItem) {
                            const rawId = String(root.activeTrayItem.id || "")
                            const rawTitle = String(root.activeTrayItem.title || "")
                            const rawTooltip = String(root.activeTrayItem.tooltipTitle || "")
                            Quickshell.execDetached([
                                "/home/sho/.config/hypr/scripts/kill-tray-app.sh",
                                rawId, rawTitle, rawTooltip
                            ])
                        }
                        root.activeMenuIndex = -1
                    }
                }
            }
        }
    }

    // Scroll wheel navigation
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
