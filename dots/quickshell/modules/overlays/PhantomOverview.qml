import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.config
import qs.components

// =============================================================================
// PERSONA 3 RELOAD: TATSUMI PORT ISLAND TOWN MAP & AREA SELECT
// Ikhtisar Workspace (Super + Tab) bertema P3R Town Map & Velvet Room Elevator
// =============================================================================
Scope {
    id: root

    readonly property int activeWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    readonly property var districtNames: [
        { num: 1, name: "GEKKOUKAN HIGH",  sub: "Classrooms & Rooftop" },
        { num: 2, name: "IWATODAI STRIP",  sub: "Dormitory & Station" },
        { num: 3, name: "PAULOWNIA MALL",  sub: "Arcade & Police Dept" },
        { num: 4, name: "PORT ISLAND STN", sub: "Outskirts & Square" },
        { num: 5, name: "NAGANAKI SHRINE", sub: "Shrine Grounds" },
        { num: 6, name: "TARTARUS GATE",   sub: "Monorail & Bridge" },
        { num: 7, name: "SHIRAKAWA BLVD",  sub: "Commercial Outskirts" },
        { num: 8, name: "CLUB ESCAPADE",   sub: "Underground Lounge" },
        { num: 9, name: "TATSUMI HOSPITAL",sub: "Memorial Ward" },
        { num: 10, name: "COASTAL PIER",   sub: "Ocean Outskirts" }
    ]

    function getDistrict(id) {
        for (var i = 0; i < districtNames.length; i++) {
            if (districtNames[i].num === id) return districtNames[i]
        }
        return { num: id, name: "SECTOR " + (id < 10 ? "0" + id : id), sub: "Tatsumi Ward" }
    }

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

        // Backdrop Dim Gelap Khas P3R
        Rectangle {
            anchors.fill: parent
            color: "#CC030818"
            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.overviewOpen = false
            }
        }

        Item {
            id: ovKeyCatcher
            focus: true
            Keys.onEscapePressed: PhantomState.overviewOpen = false
            Keys.onTabPressed: (event) => {
                if (event.modifiers & Qt.ShiftModifier) {
                    Hyprland.dispatch("hl.dsp.focus({ workspace = 'r-1' })")
                } else {
                    Hyprland.dispatch("hl.dsp.focus({ workspace = 'r+1' })")
                }
                event.accepted = true
            }
        }

        // Kontainer Utama Town Map Persona 3 Reload
        Item {
            id: ovCard
            width: Math.min(parent.width - 60, 1060)
            height: Math.min(parent.height - 70, 710)
            anchors.centerIn: parent

            readonly property var specialApps: (PhantomState.workspaceApps && PhantomState.workspaceApps["special"])
                ? PhantomState.workspaceApps["special"]
                : []

            ParallelAnimation {
                id: ovAnim
                NumberAnimation { target: ovCard; property: "scale"; from: 0.92; to: 1.0; duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
                NumberAnimation { target: ovCard; property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            }

            // Kartu Latar Belakang 3D Slanted Khas P3R
            Canvas {
                id: bgCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height

                    // Bayangan 3D Tebal
                    ctx.beginPath()
                    ctx.moveTo(14, 10)
                    ctx.lineTo(w, 10)
                    ctx.lineTo(w, h + 10)
                    ctx.lineTo(0, h + 10)
                    ctx.closePath()
                    ctx.fillStyle = "#01040d"
                    ctx.fill()

                    // Panel Utama Kaca Deep Ocean
                    ctx.beginPath()
                    ctx.moveTo(14, 0)
                    ctx.lineTo(w, 0)
                    ctx.lineTo(w, h)
                    ctx.lineTo(0, h)
                    ctx.closePath()
                    ctx.fillStyle = "rgba(4, 13, 36, 0.96)"
                    ctx.fill()

                    // Border Luar Cyan Elektrik P3R
                    ctx.lineWidth = 2.5
                    ctx.strokeStyle = "#00dbff"
                    ctx.stroke()
                }
            }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                // ── HEADER: TATSUMI PORT ISLAND // AREA SELECT ──
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Badge Ikon Slanted P3R
                    Item {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 38

                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.beginPath()
                                ctx.moveTo(10, 0)
                                ctx.lineTo(width, 0)
                                ctx.lineTo(width - 10, height)
                                ctx.lineTo(0, height)
                                ctx.closePath()
                                ctx.fillStyle = "#00d0ff"
                                ctx.fill()
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "🗺"
                            font.pixelSize: 18
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        RowLayout {
                            spacing: 8
                            Text {
                                text: "TATSUMI PORT ISLAND"
                                color: "#8df6ff"
                                font.family: "Rubik"
                                font.pixelSize: 20
                                font.weight: Font.Black
                                font.italic: true
                            }
                            Text {
                                text: "// AREA SELECT & DISPATCH"
                                color: "#ffffff"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                        Text {
                            text: "L-CLICK: FAST TRAVEL • R-CLICK: SEND ACTIVE WIN • R-CLICK APP: TO VELVET ROOM • M-CLICK: CLOSE"
                            color: "#5b8bb8"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Tombol Buka / Tutup Velvet Room Elevator
                    Item {
                        Layout.preferredWidth: velvetBtnRow.implicitWidth + 24
                        Layout.preferredHeight: 34

                        Rectangle {
                            anchors.fill: parent
                            radius: 3
                            color: velvetBtnMouse.containsMouse
                                ? "#0055d4"
                                : (PhantomState.specialWorkspaceActive ? "#0038a8" : "#07173e")
                            border.color: PhantomState.specialWorkspaceActive ? "#ffd700" : "#00d0ff"
                            border.width: 1.5
                            antialiasing: true
                        }

                        RowLayout {
                            id: velvetBtnRow
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: "🛗"
                                font.pixelSize: 13
                            }
                            Text {
                                text: PhantomState.specialWorkspaceActive ? "EXIT VELVET ELEVATOR" : "ENTER VELVET ELEVATOR"
                                color: PhantomState.specialWorkspaceActive ? "#ffd700" : "#ffffff"
                                font.family: "Rubik"
                                font.pixelSize: 11
                                font.weight: Font.Black
                            }
                        }

                        MouseArea {
                            id: velvetBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                PhantomState.overviewOpen = false
                                PhantomState.toggleVelvetRoom()
                            }
                        }
                    }

                    // Tombol Tutup (ESC)
                    Item {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34

                        Rectangle {
                            anchors.fill: parent
                            radius: 3
                            color: closeBtnMouse.containsMouse ? "#c2002f" : "#091738"
                            border.color: closeBtnMouse.containsMouse ? "#ff4060" : "#00dbff"
                            border.width: 1.5
                            antialiasing: true
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.family: "Rubik"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#ffffff"
                        }

                        MouseArea {
                            id: closeBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.overviewOpen = false
                        }
                    }
                }

                // ── GRID AREA DISTRICT SECTORS (WORKSPACES 1..N) ──
                GridLayout {
                    id: districtsGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: {
                        const count = PhantomState.visibleWorkspaces.length
                        if (count <= 4) return 2
                        if (count <= 6) return 3
                        if (count <= 8) return 4
                        return 5
                    }
                    rowSpacing: 10
                    columnSpacing: 10

                    Repeater {
                        model: PhantomState.visibleWorkspaces

                        delegate: Item {
                            id: wsDelegateItem
                            required property int index
                            required property var modelData
                            readonly property int wsNum: (typeof modelData === "number" ? modelData : (index + 1))
                            readonly property bool isCurrent: !PhantomState.specialWorkspaceActive && (root.activeWsId === wsNum)
                            readonly property var apps: (PhantomState.workspaceApps && PhantomState.workspaceApps[String(wsNum)]) ? PhantomState.workspaceApps[String(wsNum)] : []
                            readonly property var districtInfo: root.getDistrict(wsNum)

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            // Kotak Kartu District Persona 3 Reload
                            Rectangle {
                                id: cardBackdrop
                                anchors.fill: parent
                                radius: 4
                                color: wsDelegateItem.isCurrent
                                    ? Qt.rgba(0/255, 120/255, 230/255, 0.28)
                                    : (wsCardMouse.containsMouse ? Qt.rgba(0/255, 180/255, 255/255, 0.12) : Qt.rgba(6/255, 18/255, 48/255, 0.85))
                                border.color: wsDelegateItem.isCurrent
                                    ? "#00f0ff"
                                    : (wsDelegateItem.apps.length > 0 ? "#00a0dc" : "#1a3258")
                                border.width: wsDelegateItem.isCurrent ? 2 : 1
                                antialiasing: true

                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            // Glow Aksen Sudut saat Aktif
                            Rectangle {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 3
                                color: "#00f0ff"
                                visible: wsDelegateItem.isCurrent
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
                                anchors.margins: 10
                                spacing: 6

                                // Baris Header District
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    // Badge Nomor Sektor (Slanted P3)
                                    Rectangle {
                                        width: 32
                                        height: 22
                                        radius: 2
                                        color: wsDelegateItem.isCurrent ? "#00e0ff" : "#0d285a"
                                        border.color: wsDelegateItem.isCurrent ? "#ffffff" : "#0090d0"
                                        border.width: 1
                                        antialiasing: true

                                        Text {
                                            anchors.centerIn: parent
                                            text: (wsDelegateItem.wsNum < 10 ? "0" : "") + wsDelegateItem.wsNum
                                            color: wsDelegateItem.isCurrent ? "#02091c" : "#ffffff"
                                            font.family: "Rubik"
                                            font.pixelSize: 11
                                            font.weight: Font.Black
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        Text {
                                            Layout.fillWidth: true
                                            text: wsDelegateItem.districtInfo.name
                                            font.family: "Rubik"
                                            font.pixelSize: 11
                                            font.weight: Font.Black
                                            color: wsDelegateItem.isCurrent ? "#ffffff" : "#8df6ff"
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: wsDelegateItem.districtInfo.sub
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 8
                                            font.bold: true
                                            color: "#5b8bb8"
                                            elide: Text.ElideRight
                                        }
                                    }

                                    // Status Tag
                                    Rectangle {
                                        height: 16
                                        width: statusTagText.implicitWidth + 8
                                        radius: 2
                                        color: wsDelegateItem.isCurrent ? "#00c853" : (wsDelegateItem.apps.length > 0 ? "#0070ba" : "transparent")
                                        border.color: wsDelegateItem.isCurrent ? "#69f0ae" : (wsDelegateItem.apps.length > 0 ? "#00b0ff" : "#1a3258")
                                        border.width: 1

                                        Text {
                                            id: statusTagText
                                            anchors.centerIn: parent
                                            text: wsDelegateItem.isCurrent ? "ACTIVE" : (wsDelegateItem.apps.length > 0 ? (wsDelegateItem.apps.length + " WIN") : "VACANT")
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 8
                                            font.weight: Font.Black
                                            color: "#ffffff"
                                        }
                                    }
                                }

                                // Pemisah Garis
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: Qt.rgba(0/255, 219/255, 255/255, 0.2)
                                }

                                // Daftar Jendela Aktif dalam District
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 3

                                    Repeater {
                                        model: Math.min(wsDelegateItem.apps.length, 3)

                                        delegate: Item {
                                            id: appRowItem
                                            required property int index
                                            readonly property var appData: wsDelegateItem.apps[index]
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 22

                                            Rectangle {
                                                anchors.fill: parent
                                                color: appRowMouse.containsMouse ? Qt.rgba(0/255, 219/255, 255/255, 0.2) : "transparent"
                                                radius: 2
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 4
                                                anchors.rightMargin: 4
                                                spacing: 6

                                                Image {
                                                    id: rowAppImg
                                                    Layout.preferredWidth: 16
                                                    Layout.preferredHeight: 16
                                                    source: appRowItem.appData ? (appRowItem.appData.iconUrl || "") : ""
                                                    fillMode: Image.PreserveAspectFit
                                                    visible: source !== "" && status === Image.Ready
                                                    smooth: true
                                                    mipmap: true
                                                }

                                                Text {
                                                    visible: !rowAppImg.visible
                                                    text: appRowItem.appData ? (appRowItem.appData.glyph || "•") : "•"
                                                    color: "#00dbff"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 11
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    text: appRowItem.appData ? (appRowItem.appData.title || appRowItem.appData.cls || "Window") : "Window"
                                                    color: appRowMouse.containsMouse ? "#ffffff" : "#c0dcf8"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 9
                                                    font.bold: true
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
                                                    const addr = String(appRowItem.appData.addr || "")
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

                                    // Teks jika kosong
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        visible: wsDelegateItem.apps.length === 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: "NO ACTIVE SIGNALS"
                                            color: "#304870"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 8
                                            font.bold: true
                                            font.letterSpacing: 1
                                        }
                                    }

                                    Item { Layout.fillHeight: true }
                                }
                            }
                        }
                    }
                }

                // ── THE VELVET ROOM // ELEVATOR OF THE SOUL (SPECIAL WORKSPACE SCRATCHPAD) ──
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 84

                    Rectangle {
                        id: velvetBox
                        anchors.fill: parent
                        radius: 4
                        // Gradien Beludru Safir Khas Velvet Room P3R
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: PhantomState.specialWorkspaceActive ? "#06184a" : "#020a22" }
                            GradientStop { position: 0.5; color: PhantomState.specialWorkspaceActive ? "#0d2d78" : "#051336" }
                            GradientStop { position: 1.0; color: PhantomState.specialWorkspaceActive ? "#06184a" : "#020a22" }
                        }
                        border.color: PhantomState.specialWorkspaceActive ? "#ffd700" : "#00a8e8"
                        border.width: PhantomState.specialWorkspaceActive ? 2 : 1.5
                        antialiasing: true
                    }

                    MouseArea {
                        id: velvetDockMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                Quickshell.execDetached([
                                    "hyprctl", "eval",
                                    "hl.dispatch(hl.dsp.window.move({ workspace = 'special:special', follow = false }))"
                                ])
                                PhantomState.refreshWorkspaces()
                            } else {
                                PhantomState.overviewOpen = false
                                PhantomState.toggleVelvetRoom()
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            // Ikon Jam / Elevator Velvet Room
                            Text {
                                text: "🛗"
                                font.pixelSize: 16
                            }

                            ColumnLayout {
                                spacing: 0
                                RowLayout {
                                    spacing: 8
                                    Text {
                                        text: "THE VELVET ROOM"
                                        color: PhantomState.specialWorkspaceActive ? "#ffd700" : "#ffffff"
                                        font.family: "Rubik"
                                        font.pixelSize: 12
                                        font.weight: Font.Black
                                        font.letterSpacing: 1
                                    }
                                    Text {
                                        text: "// ELEVATOR OF THE SOUL [SPECIAL SCRATCHPAD]"
                                        color: "#8df6ff"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                                Text {
                                    text: "L-CLICK: TOGGLE ELEVATOR (SUPER + S) • R-CLICK BAR: SEND FOCUSED WINDOW HERE"
                                    color: "#5b8bb8"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 8
                                    font.bold: true
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                height: 18
                                width: velvetStateTxt.implicitWidth + 10
                                radius: 2
                                color: PhantomState.specialWorkspaceActive ? "#ffd700" : "#082054"
                                border.color: PhantomState.specialWorkspaceActive ? "#ffffff" : "#00a0dc"
                                border.width: 1

                                Text {
                                    id: velvetStateTxt
                                    anchors.centerIn: parent
                                    text: PhantomState.specialWorkspaceActive ? "ELEVATOR ACTIVE" : (ovCard.specialApps.length > 0 ? (ovCard.specialApps.length + " APPS DOCKED") : "ELEVATOR STANDBY")
                                    color: PhantomState.specialWorkspaceActive ? "#040b20" : "#8df6ff"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 8
                                    font.weight: Font.Black
                                }
                            }
                        }

                        // Jendela-Jendela yang Sedang Parkir di Velvet Room
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: ovCard.specialApps.length > 0

                            Repeater {
                                model: ovCard.specialApps

                                delegate: Item {
                                    id: velvetAppChip
                                    required property var modelData
                                    Layout.preferredWidth: Math.min(180, chipRow.implicitWidth + 16)
                                    Layout.preferredHeight: 26

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 3
                                        color: chipMouse.containsMouse ? "#0a3690" : "#061a48"
                                        border.color: chipMouse.containsMouse ? "#ffd700" : "#00b4f0"
                                        border.width: 1
                                        antialiasing: true
                                    }

                                    RowLayout {
                                        id: chipRow
                                        anchors.centerIn: parent
                                        spacing: 6

                                        Image {
                                            id: chipIcon
                                            Layout.preferredWidth: 14
                                            Layout.preferredHeight: 14
                                            source: velvetAppChip.modelData ? (velvetAppChip.modelData.iconUrl || "") : ""
                                            fillMode: Image.PreserveAspectFit
                                            visible: source !== "" && status === Image.Ready
                                            smooth: true
                                            mipmap: true
                                        }

                                        Text {
                                            visible: !chipIcon.visible
                                            text: velvetAppChip.modelData ? (velvetAppChip.modelData.glyph || "•") : "•"
                                            color: "#ffd700"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 10
                                        }

                                        Text {
                                            Layout.preferredWidth: Math.min(120, implicitWidth)
                                            text: velvetAppChip.modelData ? (velvetAppChip.modelData.title || velvetAppChip.modelData.cls || "App") : "App"
                                            color: "#ffffff"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: chipMouse
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

                        // Pesan jika kosong
                        Item {
                            Layout.fillWidth: true
                            visible: ovCard.specialApps.length === 0

                            Text {
                                text: "CHAMBER IS TRANQUIL • RIGHT-CLICK ANY WINDOW ABOVE TO SUMMON INTO THE VELVET ROOM ELEVATOR"
                                color: "#486a9a"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 9
                                font.bold: true
                                font.italic: true
                            }
                        }
                    }
                }
            }
        }
    }
}
