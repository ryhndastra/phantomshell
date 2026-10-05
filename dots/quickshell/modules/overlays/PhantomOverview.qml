import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.config
import qs.components

// modul ikhtisar 10 ruang kerja (workspace overview) bergaya persona 5 (super + tab)
Scope {
    id: root

    readonly property int activeWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    PanelWindow {
        id: ovWin
        visible: PhantomState.overviewOpen

        WlrLayershell.namespace: "phantomshell-overview"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: PhantomState.overviewOpen
            ? (PhantomState.modalForceExclusive ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand)
            : WlrKeyboardFocus.None
        exclusiveZone: 0

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        onVisibleChanged: {
            if (visible) {
                PhantomState.refreshWorkspaces()
                ovAnim.restart()
                ovKeyCatcher.forceActiveFocus()
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#AA050508"
            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.overviewOpen = false
            }
        }

        Item {
            id: ovKeyCatcher
            focus: true
            Keys.onEscapePressed: PhantomState.overviewOpen = false
        }

        Item {
            id: ovCard
            width: Math.min(parent.width - 80, 960)
            height: Math.min(parent.height - 100, 520)
            anchors.centerIn: parent

            readonly property var specialApps: (PhantomState.workspaceApps && PhantomState.workspaceApps["special"])
                ? PhantomState.workspaceApps["special"]
                : []

            ParallelAnimation {
                id: ovAnim
                NumberAnimation { target: ovCard; property: "scale"; from: 0.88; to: 1.0; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.25 }
                NumberAnimation { target: ovCard; property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            }

            P5SkewedCard {
                anchors.fill: parent
                fillColor: "#0B0B10"
                borderColor: PhantomState.specialWorkspaceActive ? "#60A5FA" : "#FFFFFF"
                shadowColor: PhantomState.specialWorkspaceActive ? "#1D4ED8" : PhantomState.primary
                borderWidth: 3
                skewPx: 14
                shadowOffsetX: 8
                shadowOffsetY: 8
            }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    P5Star {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        spinning: true
                        starColor: PhantomState.specialWorkspaceActive ? "#FACC15" : PhantomState.borderLight
                        innerColor: PhantomState.specialWorkspaceActive ? "#3B82F6" : PhantomState.primary
                    }

                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "METAVERSE NAVIGATION // WORKSPACE OVERVIEW"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 18
                            font.weight: Font.Black
                            font.italic: true
                        }
                        Text {
                            text: "L-CLICK: FOCUS • R-CLICK CARD: SEND ACTIVE WIN • R-CLICK APP: TO VELVET ROOM • M-CLICK APP: CLOSE"
                            color: PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // tombol buka atau tutup velvet room (special workspace)
                    Item {
                        Layout.preferredWidth: scratchTxt.implicitWidth + 24
                        Layout.preferredHeight: 30
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: scratchMouse.containsMouse
                                ? "#2563EB"
                                : (PhantomState.specialWorkspaceActive ? "#1D4ED8" : "#111C38")
                            borderColor: "#93C5FD"
                            borderWidth: 1.5
                            skewPx: 5
                            showShadowOffset: false
                        }
                        Text {
                            id: scratchTxt
                            anchors.centerIn: parent
                            text: PhantomState.specialWorkspaceActive ? "★ EXIT VELVET ROOM" : "★ ENTER VELVET ROOM"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                            font.italic: true
                        }
                        MouseArea {
                            id: scratchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                PhantomState.overviewOpen = false
                                PhantomState.toggleVelvetRoom()
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: closeOvMouse.containsMouse ? PhantomState.primary : "#181826"
                            borderColor: "#FFFFFF"
                            borderWidth: 1.5
                            skewPx: 5
                            showShadowOffset: false
                        }
                        P5Icon { anchors.centerIn: parent; name: "close"; size: 11; color: "#FFFFFF" }
                        MouseArea {
                            id: closeOvMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.overviewOpen = false
                        }
                    }
                }

                // kisi 2 baris x 5 kolom untuk ruang kerja 1-10
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 5
                    rowSpacing: 12
                    columnSpacing: 12

                    Repeater {
                        model: 10

                        delegate: Item {
                            id: wsDelegateItem
                            required property int index
                            readonly property int wsNum: index + 1
                            readonly property bool isCurrent: !PhantomState.specialWorkspaceActive && (root.activeWsId === wsNum)
                            readonly property var apps: PhantomState.workspaceApps[String(wsNum)] || []

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: wsDelegateItem.isCurrent ? "#1D0E14" : (wsCardMouse.containsMouse ? "#181826" : "#12121B")
                                borderColor: wsDelegateItem.isCurrent ? PhantomState.secondary : (wsDelegateItem.apps.length > 0 ? "#FFFFFF" : "#34344A")
                                shadowColor: wsDelegateItem.isCurrent ? PhantomState.secondary : PhantomState.primary
                                borderWidth: wsDelegateItem.isCurrent ? 2.5 : 1.5
                                skewPx: 8
                            }

                            MouseArea {
                                id: wsCardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) {
                                        Hyprland.dispatch("hl.dsp.window.move({ workspace = " + wsDelegateItem.wsNum + ", follow = false })")
                                        PhantomState.refreshWorkspaces()
                                    } else {
                                        PhantomState.overviewOpen = false
                                        Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsDelegateItem.wsNum + " })")
                                    }
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 6

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    Rectangle {
                                        width: 24
                                        height: 20
                                        color: wsDelegateItem.isCurrent ? PhantomState.primary : "#202030"
                                        border.color: "#FFFFFF"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: String(wsDelegateItem.wsNum)
                                            color: "#FFFFFF"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 11
                                            font.weight: Font.Black
                                            font.italic: true
                                        }
                                    }

                                    Text {
                                        text: wsDelegateItem.isCurrent ? "ACTIVE" : (wsDelegateItem.apps.length > 0 ? (wsDelegateItem.apps.length + " WIN") : "EMPTY")
                                        color: wsDelegateItem.isCurrent ? PhantomState.secondary : PhantomState.muted
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }

                                    Item { Layout.fillWidth: true }
                                }

                                // daftar jendela pada workspace ini
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 4

                                    Repeater {
                                        model: wsDelegateItem.apps

                                        delegate: Item {
                                            id: appRowItem
                                            required property var modelData
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 18

                                            Rectangle {
                                                anchors.fill: parent
                                                color: appRowMouse.containsMouse ? "#282A3E" : "transparent"
                                                radius: 2
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 3
                                                anchors.rightMargin: 3
                                                spacing: 6

                                                IconImage {
                                                    Layout.preferredWidth: 14
                                                    Layout.preferredHeight: 14
                                                    source: appRowItem.modelData.iconUrl || ""
                                                    visible: Boolean(appRowItem.modelData.iconUrl)
                                                }

                                                Text {
                                                    visible: !appRowItem.modelData.iconUrl
                                                    text: appRowItem.modelData.glyph || "\uf2d0"
                                                    color: PhantomState.secondary
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 11
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: appRowItem.modelData.title || appRowItem.modelData.cls
                                                    color: appRowMouse.containsMouse ? PhantomState.secondary : "#FFFFFF"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Bold
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            MouseArea {
                                                id: appRowMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: mouse => {
                                                    const addr = String(appRowItem.modelData.addr || "")
                                                    if (mouse.button === Qt.RightButton && addr !== "") {
                                                        Quickshell.execDetached([
                                                            "hyprctl", "eval",
                                                            "hl.dispatch(hl.dsp.window.move({ workspace = 'special:special', window = 'address:" + addr + "', follow = false }))"
                                                        ])
                                                        PhantomState.refreshWorkspaces()
                                                    } else if (mouse.button === Qt.MiddleButton && addr !== "") {
                                                        Quickshell.execDetached([
                                                            "hyprctl", "eval",
                                                            "hl.dispatch(hl.dsp.window.close({ window = 'address:" + addr + "' }))"
                                                        ])
                                                        PhantomState.refreshWorkspaces()
                                                    } else {
                                                        PhantomState.overviewOpen = false
                                                        Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsDelegateItem.wsNum + " })")
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Item { Layout.fillHeight: true }
                                }
                            }
                        }
                    }
                }

                // bilah bawah khusus velvet room (special workspace)
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 54

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.specialWorkspaceActive
                            ? "#10214B"
                            : (velvetDockMouse.containsMouse ? "#111C38" : "#0A1024")
                        borderColor: PhantomState.specialWorkspaceActive ? "#93C5FD" : "#3B82F6"
                        shadowColor: "#1D4ED8"
                        borderWidth: 2
                        skewPx: 8
                        shadowOffsetX: 4
                        shadowOffsetY: 4
                    }

                    MouseArea {
                        id: velvetDockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                Hyprland.dispatch("hl.dsp.window.move({ workspace = 'special:special', follow = false })")
                                PhantomState.refreshWorkspaces()
                            } else {
                                PhantomState.overviewOpen = false
                                PhantomState.toggleVelvetRoom()
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        P5Star {
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            spinning: PhantomState.specialWorkspaceActive
                            starColor: "#FACC15"
                            innerColor: "#3B82F6"
                        }

                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: "THE VELVET ROOM // SPECIAL WORKSPACE"
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 12
                                font.weight: Font.Black
                                font.italic: true
                            }
                            Text {
                                text: ovCard.specialApps.length > 0
                                    ? (ovCard.specialApps.length + " CONTRACT(S) IN CHAMBER • RIGHT-CLICK APP TO RETURN TO WORKSPACE " + root.activeWsId)
                                    : "EMPTY CHAMBER • RIGHT-CLICK ANY APP ABOVE TO SEND TO VELVET ROOM"
                                color: "#93C5FD"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Row {
                            spacing: 8

                            Repeater {
                                model: ovCard.specialApps

                                delegate: Item {
                                    id: velvetAppChip
                                    required property var modelData
                                    width: Math.min(160, velvetChipRow.implicitWidth + 16)
                                    height: 30

                                    P5SkewedCard {
                                        anchors.fill: parent
                                        fillColor: velvetChipMouse.containsMouse ? "#2563EB" : "#172554"
                                        borderColor: velvetChipMouse.containsMouse ? "#FACC15" : "#60A5FA"
                                        showShadowOffset: false
                                        borderWidth: 1.5
                                        skewPx: 4
                                    }

                                    Row {
                                        id: velvetChipRow
                                        anchors.centerIn: parent
                                        spacing: 6

                                        IconImage {
                                            width: 15
                                            height: 15
                                            anchors.verticalCenter: parent.verticalCenter
                                            source: velvetAppChip.modelData.iconUrl || ""
                                            visible: Boolean(velvetAppChip.modelData.iconUrl)
                                        }

                                        Text {
                                            visible: !velvetAppChip.modelData.iconUrl
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: velvetAppChip.modelData.glyph || "\uf2d0"
                                            color: "#FACC15"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 11
                                        }

                                        Text {
                                            width: Math.min(110, implicitWidth)
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: velvetAppChip.modelData.title || velvetAppChip.modelData.cls
                                            color: "#FFFFFF"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: velvetChipMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: mouse => {
                                            const addr = String(velvetAppChip.modelData.addr || "")
                                            if (mouse.button === Qt.RightButton && addr !== "") {
                                                Quickshell.execDetached([
                                                    "hyprctl", "eval",
                                                    "hl.dispatch(hl.dsp.window.move({ workspace = " + root.activeWsId + ", window = 'address:" + addr + "', follow = false }))"
                                                ])
                                                PhantomState.refreshWorkspaces()
                                            } else if (mouse.button === Qt.MiddleButton && addr !== "") {
                                                Quickshell.execDetached([
                                                    "hyprctl", "eval",
                                                    "hl.dispatch(hl.dsp.window.close({ window = 'address:" + addr + "' }))"
                                                ])
                                                PhantomState.refreshWorkspaces()
                                            } else {
                                                PhantomState.overviewOpen = false
                                                if (!PhantomState.specialWorkspaceActive) {
                                                    PhantomState.toggleVelvetRoom()
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
