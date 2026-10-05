import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.config
import qs.components

// jendela popup daftar aplikasi system tray bergaya persona 5
PanelWindow {
    id: trayPopupWin
    visible: PhantomState.trayPopupOpen

    readonly property bool isBottom: PhantomState.barPosition === "bottom"
    property int expandedMenuIndex: -1
    property int expandedSubIndex: -1

    WlrLayershell.namespace: "phantomshell-tray-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusiveZone: 0

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins {
        top: trayPopupWin.isBottom ? 0 : 38
        bottom: trayPopupWin.isBottom ? 38 : 0
    }

    color: "transparent"

    onVisibleChanged: {
        trayPopupWin.expandedMenuIndex = -1
        trayPopupWin.expandedSubIndex = -1
        if (visible) {
            trayPopupAnim.restart()
        }
    }

    // area klik luar untuk menutup popup saat klik di tempat kosong
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: PhantomState.trayPopupOpen = false
    }

    Item {
        id: trayCard
        width: 292
        height: Math.max(110, 56 + trayListCol.implicitHeight + 18)
        anchors.top: !trayPopupWin.isBottom ? parent.top : undefined
        anchors.bottom: trayPopupWin.isBottom ? parent.bottom : undefined
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        anchors.rightMargin: 150
        transformOrigin: trayPopupWin.isBottom ? Item.BottomRight : Item.TopRight

        Behavior on height {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        // penahan klik agar klik di dalam kartu tidak menutup popup
        MouseArea {
            anchors.fill: parent
        }

        ParallelAnimation {
            id: trayPopupAnim
            NumberAnimation {
                target: trayCard
                property: "scale"
                from: 0.85
                to: 1.0
                duration: 210
                easing.type: Easing.OutBack
                easing.overshoot: 1.3
            }
            NumberAnimation {
                target: trayCard
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        P5SkewedCard {
            anchors.fill: parent
            fillColor: PhantomState.surface
            borderColor: PhantomState.borderLight
            shadowColor: PhantomState.primary
            borderWidth: 2.5
            skewPx: PhantomState.polygonMode ? 8 : 0
            shadowOffsetX: 5
            shadowOffsetY: 5
        }

        // pita tajuk atas bergaya persona 5
        Item {
            id: headerBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            height: 28

            P5SkewedCard {
                anchors.fill: parent
                fillColor: PhantomState.primary
                borderColor: PhantomState.borderLight
                showShadowOffset: false
                borderWidth: 1.5
                skewPx: PhantomState.polygonMode ? 5 : 0
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                P5Star {
                    width: 14
                    height: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spinning: true
                }

                Text {
                    text: "ACTIVE BACKSTAGE APPS"
                    color: PhantomState.foreground
                    font.pixelSize: 10
                    font.weight: Font.Black
                    font.italic: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: countBadgeTxt.implicitWidth + 10
                height: 16
                color: PhantomState.background
                border.color: PhantomState.borderLight
                border.width: 1

                Text {
                    id: countBadgeTxt
                    anchors.centerIn: parent
                    text: String(SystemTray.items.values.length)
                    color: PhantomState.secondary
                    font.pixelSize: 9
                    font.weight: Font.Black
                }
            }
        }

        // daftar aplikasi latar belakang di system tray
        Column {
            id: trayListCol
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 6

            Repeater {
                model: SystemTray.items

                delegate: Column {
                    id: trayEntry
                    required property SystemTrayItem modelData
                    required property int index
                    width: trayListCol.width
                    spacing: 4

                    QsMenuOpener {
                        id: rowMenuOpener
                        menu: trayEntry.modelData.hasMenu ? trayEntry.modelData.menu : null
                    }

                    readonly property bool hasMenuEntries: rowMenuOpener.children.values.length > 0
                    readonly property bool isMenuExpanded: trayPopupWin.expandedMenuIndex === trayEntry.index && hasMenuEntries

                    readonly property string displayTitle: {
                        const t = modelData.title || modelData.tooltipTitle || modelData.id || "Background App"
                        return String(t).replace(/^_/, "")
                    }

                    function toggleContextMenu() {
                        if (trayEntry.hasMenuEntries) {
                            if (trayPopupWin.expandedMenuIndex === trayEntry.index) {
                                trayPopupWin.expandedMenuIndex = -1
                                trayPopupWin.expandedSubIndex = -1
                            } else {
                                trayPopupWin.expandedMenuIndex = trayEntry.index
                                trayPopupWin.expandedSubIndex = -1
                            }
                        } else if (trayEntry.modelData.hasMenu) {
                            const pos = mainRowItem.mapToItem(null, 0, mainRowItem.height + 2)
                            trayEntry.modelData.display(trayPopupWin, Math.max(8, pos.x), pos.y)
                        } else {
                            trayEntry.modelData.secondaryActivate()
                            PhantomState.trayPopupOpen = false
                        }
                    }

                    // baris utama aplikasi tray
                    Item {
                        id: mainRowItem
                        width: parent.width
                        height: 36

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: entryMouse.containsMouse || trayEntry.isMenuExpanded ? PhantomState.primary : PhantomState.surfaceAlt
                            borderColor: entryMouse.containsMouse || trayEntry.isMenuExpanded ? PhantomState.borderLight : "transparent"
                            shadowColor: PhantomState.secondary
                            showShadowOffset: entryMouse.containsMouse || trayEntry.isMenuExpanded
                            shadowOffsetX: 2
                            shadowOffsetY: 2
                            borderWidth: entryMouse.containsMouse || trayEntry.isMenuExpanded ? 1.5 : 1
                            skewPx: PhantomState.polygonMode ? 5 : 0
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.right: menuBadge.left
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            IconImage {
                                width: 18
                                height: 18
                                anchors.verticalCenter: parent.verticalCenter
                                source: trayEntry.modelData.icon
                                asynchronous: true
                            }

                            Text {
                                width: Math.max(40, parent.width - 30)
                                anchors.verticalCenter: parent.verticalCenter
                                text: trayEntry.displayTitle.toUpperCase()
                                color: PhantomState.foreground
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: entryMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton) {
                                    PhantomState.activateTrayItem(trayEntry.modelData)
                                } else if (mouse.button === Qt.RightButton) {
                                    trayEntry.toggleContextMenu()
                                } else if (mouse.button === Qt.MiddleButton) {
                                    trayEntry.modelData.secondaryActivate()
                                    PhantomState.trayPopupOpen = false
                                }
                            }
                        }

                        // tombol indikator klik kanan / ekspansi menu konteks
                        Rectangle {
                            id: menuBadge
                            visible: trayEntry.modelData.hasMenu || trayEntry.hasMenuEntries
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: menuBadgeTxt.implicitWidth + 12
                            height: 20
                            radius: 2
                            color: menuBadgeMouse.containsMouse || trayEntry.isMenuExpanded
                                ? PhantomState.secondary
                                : Qt.rgba(0, 0, 0, 0.35)
                            border.color: menuBadgeMouse.containsMouse || trayEntry.isMenuExpanded
                                ? PhantomState.background
                                : PhantomState.borderLight
                            border.width: 1

                            Text {
                                id: menuBadgeTxt
                                anchors.centerIn: parent
                                text: trayEntry.isMenuExpanded ? "MENU ▴" : "MENU ▾"
                                color: menuBadgeMouse.containsMouse || trayEntry.isMenuExpanded
                                    ? PhantomState.background
                                    : PhantomState.foreground
                                font.pixelSize: 8
                                font.weight: Font.Black
                                font.italic: true
                            }

                            MouseArea {
                                id: menuBadgeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: trayEntry.toggleContextMenu()
                            }
                        }
                    }

                    // daftar menu konteks (klik kanan) bergaya persona 5
                    Column {
                        id: inlineMenuCol
                        visible: trayEntry.isMenuExpanded
                        width: parent.width - 10
                        anchors.right: parent.right
                        spacing: 2

                        Repeater {
                            model: trayEntry.isMenuExpanded ? rowMenuOpener.children : []

                            delegate: Column {
                                id: menuEntryWrap
                                required property QsMenuEntry modelData
                                required property int index
                                width: inlineMenuCol.width
                                spacing: 2

                                QsMenuOpener {
                                    id: subMenuOpener
                                    menu: menuEntryWrap.modelData.hasChildren ? menuEntryWrap.modelData : null
                                }

                                readonly property bool isSubExpanded: trayPopupWin.expandedSubIndex === menuEntryWrap.index && menuEntryWrap.modelData.hasChildren
                                readonly property string cleanLabel: String(menuEntryWrap.modelData.text || "").replace(/_/g, "").trim()

                                // garis pemisah menu
                                Rectangle {
                                    visible: menuEntryWrap.modelData.isSeparator
                                    width: parent.width - 8
                                    height: 1
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    color: Qt.rgba(1, 1, 1, 0.14)
                                }

                                // item aksi menu
                                Rectangle {
                                    id: menuRowRect
                                    visible: !menuEntryWrap.modelData.isSeparator && menuEntryWrap.cleanLabel.length > 0
                                    width: parent.width
                                    height: 26
                                    color: !menuEntryWrap.modelData.enabled
                                        ? Qt.rgba(0, 0, 0, 0.25)
                                        : (menuItemMouse.containsMouse || menuEntryWrap.isSubExpanded ? PhantomState.secondary : PhantomState.background)
                                    border.color: menuItemMouse.containsMouse || menuEntryWrap.isSubExpanded ? PhantomState.primary : Qt.rgba(1, 1, 1, 0.08)
                                    border.width: 1

                                    Row {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        anchors.right: subArrowTxt.left
                                        anchors.rightMargin: 6
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 6

                                        Text {
                                            visible: menuEntryWrap.modelData.buttonType !== QsMenuButtonType.None
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: menuEntryWrap.modelData.checkState === Qt.Checked ? "◆" : "◇"
                                            color: menuItemMouse.containsMouse || menuEntryWrap.isSubExpanded ? PhantomState.background : PhantomState.primary
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                        }

                                        Text {
                                            width: Math.max(40, parent.width - 22)
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: menuEntryWrap.cleanLabel.toUpperCase()
                                            color: !menuEntryWrap.modelData.enabled
                                                ? PhantomState.muted
                                                : (menuItemMouse.containsMouse || menuEntryWrap.isSubExpanded ? PhantomState.background : PhantomState.foreground)
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Text {
                                        id: subArrowTxt
                                        anchors.right: parent.right
                                        anchors.rightMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: menuEntryWrap.modelData.hasChildren ? (menuEntryWrap.isSubExpanded ? "▴" : "▸") : ""
                                        color: menuItemMouse.containsMouse || menuEntryWrap.isSubExpanded ? PhantomState.background : PhantomState.muted
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }

                                    MouseArea {
                                        id: menuItemMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        enabled: menuEntryWrap.modelData.enabled
                                        cursorShape: menuEntryWrap.modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            if (menuEntryWrap.modelData.hasChildren) {
                                                if (subMenuOpener.children.values.length > 0) {
                                                    trayPopupWin.expandedSubIndex = (trayPopupWin.expandedSubIndex === menuEntryWrap.index ? -1 : menuEntryWrap.index)
                                                } else {
                                                    const pos = menuRowRect.mapToItem(null, 0, menuRowRect.height + 2)
                                                    menuEntryWrap.modelData.display(trayPopupWin, Math.max(8, pos.x), pos.y)
                                                }
                                            } else {
                                                const lowerLbl = menuEntryWrap.cleanLabel.toLowerCase()
                                                menuEntryWrap.modelData.triggered()
                                                if (/^(show|open|restore|maximize|buka|tampilkan)/.test(lowerLbl)) {
                                                    PhantomState.activateTrayItem(trayEntry.modelData)
                                                } else {
                                                    PhantomState.trayPopupOpen = false
                                                }
                                            }
                                        }
                                    }
                                }

                                // daftar submenu tingkat kedua jika ada
                                Column {
                                    id: nestedSubCol
                                    visible: menuEntryWrap.isSubExpanded
                                    width: parent.width - 12
                                    anchors.right: parent.right
                                    spacing: 2

                                    Repeater {
                                        model: menuEntryWrap.isSubExpanded ? subMenuOpener.children : []

                                        delegate: Rectangle {
                                            id: subItemRect
                                            required property QsMenuEntry modelData
                                            readonly property string subCleanLabel: String(modelData.text || "").replace(/_/g, "").trim()
                                            visible: !modelData.isSeparator && subCleanLabel.length > 0
                                            width: nestedSubCol.width
                                            height: 24
                                            color: subItemMouse.containsMouse ? PhantomState.primary : PhantomState.surfaceAlt
                                            border.color: subItemMouse.containsMouse ? PhantomState.borderLight : Qt.rgba(1, 1, 1, 0.08)
                                            border.width: 1

                                            Text {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 10
                                                anchors.right: parent.right
                                                anchors.rightMargin: 8
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: subItemRect.subCleanLabel.toUpperCase()
                                                color: !subItemRect.modelData.enabled ? PhantomState.muted : PhantomState.foreground
                                                font.pixelSize: 9
                                                font.weight: Font.Bold
                                                elide: Text.ElideRight
                                            }

                                            MouseArea {
                                                id: subItemMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                enabled: subItemRect.modelData.enabled
                                                cursorShape: subItemRect.modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                onClicked: {
                                                    subItemRect.modelData.triggered()
                                                    PhantomState.trayPopupOpen = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
