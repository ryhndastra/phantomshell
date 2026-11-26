import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.config
import "../../components"

// Persona 5 Royal slanted polygon workspace indicator with integrated Phantom star tray expander.
Item {
    id: root

    FontLoader {
        id: p5HeadlineFont
        source: "../../assets/themes/p5/fonts/Persona5RoyalHeadlineFont.ttf"
    }

    FontLoader {
        id: p5BodyFont
        source: "../../assets/themes/p5/fonts/Arsenal-Bold.ttf"
    }

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
    height: 44
    implicitWidth: wsRow.implicitWidth
    implicitHeight: 44

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
        spacing: 16
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

                width: {
                    if (wsItem.isActive) {
                        if (wsItem.isOccupied) {
                            return wsItem.appList.length > 1 ? 70 : 54
                        }
                        return Math.max(numText.implicitWidth + 24, 52)
                    }
                    if (wsItem.isOccupied) {
                        return wsItem.appList.length > 1 ? 58 : 42
                    }
                    return Math.max(numText.implicitWidth + 6, 38)
                }
                height: 42

                scale: wsItem.isActive ? 1.12 : (wsItem.isHovered ? 1.06 : 1.0)
                transformOrigin: Item.Center
                Behavior on scale {
                    NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
                }

                opacity: {
                    if (wsItem.isActive) return 1.0
                    if (wsItem.isHovered) return 0.92
                    if (wsItem.isOccupied) return 0.78
                    return 0.35
                }
                Behavior on opacity {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                // Persona 5 Slanted Active Badge Canvas (White Face + Crimson Shadow)
                Canvas {
                    id: activeBadge
                    anchors.fill: parent
                    anchors.margins: -4
                    visible: wsItem.isActive
                    antialiasing: true

                    onVisibleChanged: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    Connections {
                        target: PhantomState
                        function onPrimaryChanged() { activeBadge.requestPaint() }
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()

                        var ox = 3.0
                        var oy = 3.0
                        var w = width - ox - 1.0
                        var h = height - oy - 1.0
                        var s = 7.0

                        // 1. Crimson Shadow Polygon in back
                        ctx.fillStyle = PhantomState.primary || "#E60012"
                        ctx.beginPath()
                        ctx.moveTo(s + ox, oy)
                        ctx.lineTo(w + ox, oy)
                        ctx.lineTo(w - s + ox, h + oy)
                        ctx.lineTo(ox, h + oy)
                        ctx.closePath()
                        ctx.fill()

                        // 2. White Front Face Polygon with crisp black stroke
                        ctx.fillStyle = "#FFFFFF"
                        ctx.strokeStyle = "#000000"
                        ctx.lineWidth = 1.8
                        ctx.beginPath()
                        ctx.moveTo(s, 0)
                        ctx.lineTo(w, 0)
                        ctx.lineTo(w - s, h)
                        ctx.lineTo(0, h)
                        ctx.closePath()
                        ctx.fill()
                        ctx.stroke()
                    }
                }

                // Persona 5 Subtle Slanted Dark Pill for Inactive Occupied Workspaces
                Canvas {
                    id: occupiedBadge
                    anchors.fill: parent
                    anchors.margins: 1
                    visible: wsItem.isOccupied && !wsItem.isActive
                    opacity: wsItem.isHovered ? 0.95 : 0.50
                    antialiasing: true

                    onVisibleChanged: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width - 1.0
                        var h = height - 1.0
                        var s = 5.0

                        ctx.fillStyle = "#121218"
                        ctx.strokeStyle = wsItem.isHovered ? (PhantomState.primary || "#E60012") : "#2A2A34"
                        ctx.lineWidth = 1.2

                        ctx.beginPath()
                        ctx.moveTo(s, 1)
                        ctx.lineTo(w, 1)
                        ctx.lineTo(w - s, h)
                        ctx.lineTo(1, h)
                        ctx.closePath()
                        ctx.fill()
                        ctx.stroke()
                    }
                }

                // App icon(s) when occupied
                Item {
                    anchors.centerIn: parent
                    visible: wsItem.isOccupied
                    width: appRow.implicitWidth
                    height: 30

                    Row {
                        id: appRow
                        anchors.centerIn: parent
                        spacing: 4

                        Repeater {
                            model: Math.min(wsItem.appList.length, 2)

                            delegate: Item {
                                required property int index
                                readonly property var appData: wsItem.appList[index]
                                width: wsItem.appList.length > 1 ? 22 : 28
                                height: wsItem.appList.length > 1 ? 22 : 28

                                Image {
                                    anchors.fill: parent
                                    source: appData.iconUrl || ""
                                    visible: Boolean(appData.iconUrl)
                                    fillMode: Image.PreserveAspectFit
                                    cache: true
                                    smooth: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: appData.glyph || "•"
                                    visible: !appData.iconUrl
                                    font.family: p5BodyFont.name
                                    font.pixelSize: wsItem.appList.length > 1 ? 14 : 18
                                    font.bold: true
                                    color: wsItem.isActive ? "#000000" : (wsItem.isHovered ? "#FFFFFF" : "#E60012")
                                }
                            }
                        }
                    }
                }

                // Tiny P5 Star Badge Accent when Active and Occupied
                Text {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: -2
                    anchors.rightMargin: -1
                    visible: wsItem.isActive && wsItem.isOccupied
                    text: "★"
                    font.pixelSize: 11
                    color: PhantomState.primary || "#E60012"
                }

                // Workspace number when unoccupied
                Text {
                    id: numText
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: wsItem.isActive ? -1 : 0
                    visible: !wsItem.isOccupied
                    text: (wsItem.wsId < 10 ? "0" : "") + wsItem.wsId
                    font.family: "Bebas Neue"
                    font.pixelSize: wsItem.isActive ? 36 : 38
                    font.bold: true
                    font.italic: true
                    color: wsItem.isActive ? "#000000" : (wsItem.isHovered ? "#FFFFFF" : "#9E9EAE")

                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on font.pixelSize { NumberAnimation { duration: 140 } }
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

            // Persona 5 Slanted Slash Divider "//"
            Text {
                text: "//"
                font.family: p5BodyFont.name
                font.pixelSize: 20
                font.bold: true
                font.italic: true
                color: PhantomState.primary || "#E60012"
                opacity: 0.65
                anchors.verticalCenter: parent.verticalCenter
                rotation: -8
            }

            // Persona 5 Phantom Star Tray Toggle Button
            Item {
                id: starBtn
                width: 32
                height: 42
                anchors.verticalCenter: parent.verticalCenter

                P5Star {
                    id: trayStar
                    anchors.centerIn: parent
                    width: 28
                    height: 28
                    starColor: root.trayExpanded ? "#FFFFFF" : (starMouse.containsMouse ? "#FFFFFF" : (PhantomState.primary || "#E60012"))
                    innerColor: root.trayExpanded ? (PhantomState.primary || "#E60012") : (starMouse.containsMouse ? (PhantomState.primary || "#E60012") : "#FFFFFF")
                    coreColor: root.trayExpanded ? "#0B0B0E" : (PhantomState.primary || "#E60012")
                    rotation: root.trayExpanded ? 72 : 0

                    Behavior on rotation {
                        NumberAnimation { duration: 250; easing.type: Easing.OutBack }
                    }
                }

                opacity: root.trayExpanded ? 1.0 : (starMouse.containsMouse ? 0.95 : 0.45)
                scale: starMouse.containsMouse ? 1.15 : (root.trayExpanded ? 1.08 : 1.0)
                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                MouseArea {
                    id: starMouse
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

            // Expanding tray icons container
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

    // Persona 5 Slanted Context Menu Card
    Item {
        id: contextMenuCard
        visible: root.activeMenuIndex >= 0 && root.trayExpanded && root.activeTrayItem !== null
        anchors.top: wsRow.bottom
        anchors.topMargin: 10
        x: Math.max(0, traySection.x + trayIconsClip.x + (root.activeMenuIndex * 44) - 4)
        width: actionsCol.implicitWidth + 24
        height: actionsCol.implicitHeight + 16
        z: 1000

        // Slanted Dark P5 Card Canvas
        Canvas {
            id: menuBgCanvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var ox = 3.0
                var oy = 3.0
                var w = width - ox
                var h = height - oy
                var s = 6.0

                // Red shadow
                ctx.fillStyle = PhantomState.primary || "#E60012"
                ctx.beginPath()
                ctx.moveTo(s + ox, oy)
                ctx.lineTo(w + ox, oy)
                ctx.lineTo(w - s + ox, h + oy)
                ctx.lineTo(ox, h + oy)
                ctx.closePath()
                ctx.fill()

                // Dark surface
                ctx.fillStyle = "#101016"
                ctx.strokeStyle = "#FFFFFF"
                ctx.lineWidth = 1.2
                ctx.beginPath()
                ctx.moveTo(s, 0)
                ctx.lineTo(w, 0)
                ctx.lineTo(w - s, h)
                ctx.lineTo(0, h)
                ctx.closePath()
                ctx.fill()
                ctx.stroke()
            }
        }

        Column {
            id: actionsCol
            spacing: 6
            anchors.centerIn: parent

            // Fallback open action when application has no DBus menu
            Text {
                visible: activeMenuOpener.children.values.length === 0
                text: "OPEN"
                font.family: p5BodyFont.name
                font.pixelSize: 18
                font.bold: true
                color: defOpenMouse.containsMouse ? (PhantomState.primary || "#E60012") : "#FFFFFF"
                opacity: defOpenMouse.containsMouse ? 1.0 : 0.65
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
                        font.family: p5BodyFont.name
                        font.pixelSize: 18
                        font.bold: true
                        color: menuEntryWrap.isKillOrQuit
                            ? (entryMouse.containsMouse ? "#FF2255" : "#FF5577")
                            : (entryMouse.containsMouse ? (PhantomState.primary || "#E60012") : "#FFFFFF")
                        opacity: !menuEntryWrap.modelData.enabled
                            ? 0.25
                            : (entryMouse.containsMouse ? 1.0 : (menuEntryWrap.isKillOrQuit ? 0.70 : 0.65))
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
                font.family: p5BodyFont.name
                font.pixelSize: 18
                font.bold: true
                color: killMouse.containsMouse ? "#FF2255" : "#FF5577"
                opacity: killMouse.containsMouse ? 1.0 : 0.65
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

    // Scroll wheel navigation across workspaces
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
