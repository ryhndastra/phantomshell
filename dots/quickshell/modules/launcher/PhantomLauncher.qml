import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: launcherWin
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
        WlrLayershell.keyboardFocus: PhantomState.launcherOpen
            ? (PhantomState.modalForceExclusive ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand)
            : WlrKeyboardFocus.None
        color: "transparent"
        visible: PhantomState.launcherOpen || bgFade.opacity > 0.01

        property string query: ""
        property int selectedIndex: 0

        // Installed desktop applications
        property var rawDesktopApps: DesktopEntries.applications.values

        // Built-in quick commands
        readonly property var builtinCommands: [
            { isApp: false, name: ">lock", desc: "Lock Screen (Persona 5 Calling Card Lock)", cmd: "__lock", iconName: "lock", appIcon: "", badge: "LOCK", entryObj: null },
            { isApp: false, name: ">settings", desc: "Open Complete Velvet Room Configuration GUI", cmd: "__settings", iconName: "settings", appIcon: "", badge: "CONFIG", entryObj: null },
            { isApp: false, name: ">stats", desc: "Open 5-Point Star System Monitor & Control Center", cmd: "__dashboard", iconName: "stats", appIcon: "", badge: "STATS", entryObj: null },
            { isApp: false, name: ">notify", desc: "Send test IM Chat Notification from Ren", cmd: "__notify", iconName: "bell", appIcon: "", badge: "TEST IM", entryObj: null },
            { isApp: false, name: ">theme p5-crimson", desc: "Switch to P5 Phantom Crimson Red", cmd: "__theme:p5-crimson", iconName: "phantom", appIcon: "", badge: "THEME", entryObj: null },
            { isApp: false, name: ">theme p3-reload", desc: "Switch to P3 Reload S.E.E.S. Blue", cmd: "__theme:p3-reload", iconName: "moon", appIcon: "", badge: "THEME", entryObj: null },
            { isApp: false, name: ">theme p4-golden", desc: "Switch to P4 Golden Midnight Channel", cmd: "__theme:p4-golden", iconName: "tv", appIcon: "", badge: "THEME", entryObj: null }
        ]

        function resolveAppIconUrl(iconStr) {
            if (!iconStr || iconStr.trim() === "") return ""
            var s = iconStr.trim()
            if (s.startsWith("file://") || s.startsWith("image://")) return s
            if (s.startsWith("/")) return "file://" + s
            return Quickshell.iconPath(s, true)
        }

        property var combinedItems: {
            var list = []
            var apps = rawDesktopApps || []
            for (var i = 0; i < apps.length; i++) {
                var a = apps[i]
                if (!a || !a.name) continue
                list.push({
                    isApp: true,
                    name: a.name,
                    desc: (a.comment && a.comment !== "") ? a.comment : (a.genericName && a.genericName !== "" ? a.genericName : (a.execString || "Desktop Application")),
                    cmd: a.execString || "",
                    iconName: "app",
                    appIcon: resolveAppIconUrl(a.icon || ""),
                    badge: "LAUNCH",
                    entryObj: a
                })
            }
            list.sort(function(x, y) {
                return x.name.localeCompare(y.name)
            })  
            for (var j = 0; j < builtinCommands.length; j++) {
                list.push(builtinCommands[j])
            }
            return list
        }

        property var filteredItems: {
            var q = query.trim().toLowerCase()
            if (q === "") return combinedItems
            var out = []
            for (var i = 0; i < combinedItems.length; i++) {
                var item = combinedItems[i]
                if (item.name.toLowerCase().indexOf(q) !== -1 ||
                    item.desc.toLowerCase().indexOf(q) !== -1 ||
                    item.badge.toLowerCase().indexOf(q) !== -1) {
                    out.push(item)
                }
            }
            return out
        }

        function executeItem(idx) {
            if (filteredItems.length === 0) return
            var safeIdx = Math.min(Math.max(0, idx), filteredItems.length - 1)
            var item = filteredItems[safeIdx]
            if (item.isApp && item.entryObj) {
                if (item.entryObj.runInTerminal) {
                    var termArgs = ["kitty", "-e"]
                    var cmdList = item.entryObj.command || []
                    for (var k = 0; k < cmdList.length; k++) {
                        termArgs.push(String(cmdList[k]))
                    }
                    if (cmdList.length === 0 && item.cmd) {
                        termArgs.push(item.cmd.replace(/%[fFuUdDnNickvm]/g, "").trim())
                    }
                    Quickshell.execDetached(termArgs)
                } else {
                    var appCmdList = item.entryObj.command || []
                    var cleanArgs = [
                        "env",
                        "-u", "QT_PLUGIN_PATH",
                        "-u", "QML2_IMPORT_PATH",
                        "-u", "QML_IMPORT_PATH",
                        "-u", "NIXPKGS_QT6_QML_IMPORT_PATH",
                        "-u", "ELECTRON_RUN_AS_NODE",
                        "-u", "ELECTRON_NO_ATTACH_CONSOLE"
                    ]
                    if (appCmdList.length > 0) {
                        for (var m = 0; m < appCmdList.length; m++) {
                            var arg = String(appCmdList[m])
                            if (arg.match(/^%[a-zA-Z]$/)) continue
                            cleanArgs.push(arg)
                        }
                        Quickshell.execDetached(cleanArgs)
                    } else if (item.cmd && item.cmd !== "") {
                        cleanArgs.push("sh", "-c", item.cmd.replace(/%[a-zA-Z]/g, "").trim())
                        Quickshell.execDetached(cleanArgs)
                    } else {
                        item.entryObj.execute()
                    }
                }
                PhantomState.launcherOpen = false
                query = ""
                return
            }
            var c = item.cmd
            if (c.indexOf("__theme:") === 0) {
                PhantomState.applyPreset(c.substring(8))
                PhantomState.launcherOpen = false
            } else if (c === "__lock") {
                PhantomState.lockScreen()
            } else if (c === "__settings") {
                PhantomState.launcherOpen = false
                PhantomState.toggleSettings()
            } else if (c === "__dashboard") {
                PhantomState.launcherOpen = false
                PhantomState.dashboardOpen = true
            } else if (c === "__notify") {
                PhantomState.sendTestNotification()
                PhantomState.launcherOpen = false
            } else if (c !== "") {
                Quickshell.execDetached(["sh", "-c", c])
                PhantomState.launcherOpen = false
            }
            query = ""
        }

        function cleanSnippet(str) {
            if (!str) return ""
            return String(str).replace(/[\r\n]+/g, " ").trim()
        }

        FontLoader {
            id: p5HeadlineFont
            source: "../../assets/themes/p5/fonts/Persona5RoyalHeadlineFont.ttf"
        }

        FontLoader {
            id: p5RegFont
            source: "../../assets/themes/p5/fonts/Persona5RoyalRegulerFont.ttf"
        }

        FontLoader {
            id: p5BodyFont
            source: "../../assets/themes/p5/fonts/Arsenal-Bold.ttf"
        }

        Connections {
            target: PhantomState
            function onLauncherOpenChanged() {
                if (PhantomState.launcherOpen) {
                    PhantomState.playSfx("open")
                    launcherWin.query = ""
                    launcherWin.selectedIndex = 0
                    if (PhantomState.isP3) {
                        p3SearchInput.text = ""
                        p3SearchInput.forceActiveFocus()
                    } else {
                        p5SearchInput.text = ""
                        p5SearchInput.forceActiveFocus()
                    }
                } else {
                    PhantomState.playSfx("close")
                }
            }
            function onModalForceExclusiveChanged() {
                if (PhantomState.launcherOpen && PhantomState.modalForceExclusive) {
                    if (PhantomState.isP3) p3SearchInput.forceActiveFocus()
                    else p5SearchInput.forceActiveFocus()
                }
            }
        }

        onVisibleChanged: {
            if (visible && PhantomState.launcherOpen) {
                query = ""
                selectedIndex = 0
                if (PhantomState.isP3) {
                    p3SearchInput.text = ""
                    p3SearchInput.forceActiveFocus()
                } else {
                    p5SearchInput.text = ""
                    p5SearchInput.forceActiveFocus()
                }
            }
        }

        Rectangle {
            id: bgFade
            anchors.fill: parent
            color: "#CC07070A"
            opacity: PhantomState.launcherOpen ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.launcherOpen = false
            }



            // Ren Amamiya's Persona 5 Smartphone Launcher Deck
            Item {
                id: p5PhoneStage
                visible: !PhantomState.isP3
                anchors.left: parent.left
                anchors.leftMargin: 64
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 28
                width: 510
                height: Math.min(parent.height - 150, 860)

                readonly property string activeTab: PhantomState.p3LauncherTab
                property int selectedNotifIndex: 0

                property var activeDetailNotif: null
                property int activeDetailIndex: -1

                Connections {
                    target: PhantomState
                    function onP3ReaderIndexChanged() {
                        if (PhantomState.p3ReaderIndex >= 0 && PhantomState.p3ReaderIndex < PhantomState.imNotifications.count) {
                            var n = PhantomState.imNotifications.get(PhantomState.p3ReaderIndex)
                            if (n) {
                                p5PhoneStage.activeDetailNotif = {
                                    "sender": n.senderName || n.sender || "New Message",
                                    "body": n.msgBody || n.message || "",
                                    "time": n.msgTime || n.time || "",
                                    "icon": n.msgIcon || n.appIcon || "",
                                    "color": "#E60012"
                                }
                                p5PhoneStage.activeDetailIndex = PhantomState.p3ReaderIndex
                            }
                        }
                    }
                }

                // Authentic Persona 5 phone tilt (-4.0 deg)
                transformOrigin: Item.BottomLeft
                rotation: -4.0
                layer.enabled: true
                layer.smooth: true
                layer.samples: 4

                opacity: PhantomState.launcherOpen ? 1.0 : 0.0
                scale: PhantomState.launcherOpen ? 1.0 : 0.94
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }

                MouseArea { anchors.fill: parent }

                // Persona 5 Smartphone Chassis with Crimson Drop Shadow and Thick White Bezel
                Canvas {
                    id: p5CardBackdrop
                    anchors.fill: parent
                    antialiasing: true

                    function drawRoundRect(ctx, x, y, w, h, r) {
                        ctx.beginPath();
                        ctx.moveTo(x + r, y);
                        ctx.lineTo(x + w - r, y);
                        ctx.quadraticCurveTo(x + w, y, x + w, y + r);
                        ctx.lineTo(x + w, y + h - r);
                        ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
                        ctx.lineTo(x + r, y + h);
                        ctx.quadraticCurveTo(x, y + h, x, y + h - r);
                        ctx.lineTo(x, y + r);
                        ctx.quadraticCurveTo(x, y, x + r, y);
                        ctx.closePath();
                    }

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        var pad = 6;
                        var w = width - pad * 2 - 14;
                        var h = height - pad * 2 - 12;

                        // 1. Black & Dark Crimson Drop Shadow
                        drawRoundRect(ctx, pad + 14, pad + 12, w, h, 18);
                        ctx.fillStyle = "#000000";
                        ctx.fill();

                        drawRoundRect(ctx, pad + 8, pad + 7, w, h, 18);
                        ctx.fillStyle = "#8B0007";
                        ctx.fill();

                        // 2. Main Phone Chassis: Crisp Thick White Bezel
                        drawRoundRect(ctx, pad, pad, w, h, 16);
                        ctx.fillStyle = "#FFFFFF";
                        ctx.fill();

                        // Crisp outer black border
                        ctx.lineWidth = 3.5;
                        ctx.strokeStyle = "#000000";
                        ctx.stroke();

                        // 3. Left Bezel vertical notch (Persona 5 iconic smartphone detail)
                        ctx.beginPath();
                        ctx.rect(pad + 3, pad + 140, 4, 52);
                        ctx.fillStyle = "#000000";
                        ctx.fill();

                        // 4. Inner Red Screen Area (inset by 12px from bezel)
                        drawRoundRect(ctx, pad + 12, pad + 12, w - 24, h - 24, 8);
                        ctx.fillStyle = "#C8000A";
                        ctx.fill();

                        // Inner black frame border around red screen
                        ctx.lineWidth = 2.0;
                        ctx.strokeStyle = "#000000";
                        ctx.stroke();
                    }
                }

                // White paint splatters across red screen
                Image {
                    id: p5SplatterBg
                    x: 20
                    y: 20
                    width: parent.width - 54
                    height: parent.height - 54
                    source: "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/themes/p5/ui/p5_splatters.svg"
                    fillMode: Image.PreserveAspectCrop
                    opacity: 0.28
                    smooth: true
                    visible: status === Image.Ready
                }

                // Top phone speaker slit & camera pinhole (positioned in white top bezel)
                Row {
                    anchors.top: parent.top
                    anchors.topMargin: 11
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    z: 15

                    Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5
                        color: "#181820"
                    }

                    Rectangle {
                        width: 36
                        height: 4
                        radius: 2
                        color: "#181820"
                    }
                }

                // Screen content area (Strictly inside the red screen!)
                Item {
                    id: p5CardArea
                    x: 20
                    y: 20
                    width: parent.width - 54
                    height: parent.height - 54
                    clip: true

                    // Persona 5 Iconic IM Header Row
                    Item {
                        id: p5HeaderContainer
                        anchors.top: parent.top
                        anchors.topMargin: 4
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 66
                        z: 10

                        // Iconic "IM" Logo SVG
                        Image {
                            id: p5ImLogoImg
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            width: 84
                            height: 60
                            source: "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/themes/p5/ui/p5_im_logo.svg"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        // Right section: Date sticker chips & Tabs
                        Column {
                            anchors.left: p5ImLogoImg.right
                            anchors.leftMargin: 12
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 5

                            // Persona 5 Date Sticker Banner
                            Row {
                                spacing: 6
                                Rectangle {
                                    height: 20
                                    width: 136
                                    color: "#FFFFFF"
                                    radius: 2
                                    border.color: "#000000"
                                    border.width: 1.5

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Text {
                                            text: "★"
                                            font.pixelSize: 9
                                            color: "#E60012"
                                        }
                                        Text {
                                            text: Qt.formatDateTime(new Date(), "ddd M/d").toUpperCase()
                                            font.family: "Rubik"
                                            font.pixelSize: 10
                                            font.weight: Font.Black
                                            color: "#000000"
                                        }
                                    }
                                }
                            }

                            // Slanted Tabs: APPS and CHAT
                            Row {
                                spacing: 6

                                // APPS Tab (Slanted Manga Pill)
                                Item {
                                    width: 74
                                    height: 26

                                    Canvas {
                                        id: appsTabCanvas
                                        anchors.fill: parent
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            var w = width; var h = height; var s = 8;
                                            var active = p5PhoneStage.activeTab === "apps";
                                            ctx.beginPath();
                                            ctx.moveTo(s, 0); ctx.lineTo(w, 0); ctx.lineTo(w - s, h); ctx.lineTo(0, h);
                                            ctx.closePath();
                                            ctx.fillStyle = active ? "#FFFFFF" : "#0A0A0E";
                                            ctx.fill();
                                            ctx.lineWidth = 1.5;
                                            ctx.strokeStyle = active ? "#000000" : "#FFFFFF";
                                            ctx.stroke();
                                        }

                                        Connections {
                                            target: p5PhoneStage
                                            function onActiveTabChanged() { appsTabCanvas.requestPaint() }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "APPS"
                                        font.family: "Rubik"
                                        font.pixelSize: 11
                                        font.weight: Font.Black
                                        color: p5PhoneStage.activeTab === "apps" ? "#000000" : "#FFFFFF"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (p5PhoneStage.activeTab !== "apps") {
                                                PhantomState.p3LauncherTab = "apps"
                                                p5PhoneStage.activeDetailNotif = null
                                                PhantomState.playSfx("select")
                                                p5SearchInput.forceActiveFocus()
                                            }
                                        }
                                    }
                                }

                                // CHAT Tab (Slanted Manga Pill)
                                Item {
                                    width: PhantomState.imNotifications.count > 0 ? 88 : 74
                                    height: 26

                                    Canvas {
                                        id: chatTabCanvas
                                        anchors.fill: parent
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            var w = width; var h = height; var s = 8;
                                            var active = p5PhoneStage.activeTab === "mail";
                                            ctx.beginPath();
                                            ctx.moveTo(s, 0); ctx.lineTo(w, 0); ctx.lineTo(w - s, h); ctx.lineTo(0, h);
                                            ctx.closePath();
                                            ctx.fillStyle = active ? "#FFFFFF" : "#0A0A0E";
                                            ctx.fill();
                                            ctx.lineWidth = 1.5;
                                            ctx.strokeStyle = active ? "#000000" : "#FFFFFF";
                                            ctx.stroke();
                                        }

                                        Connections {
                                            target: p5PhoneStage
                                            function onActiveTabChanged() { chatTabCanvas.requestPaint() }
                                        }
                                    }

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 5
                                        Text {
                                            text: "CHAT"
                                            font.family: "Rubik"
                                            font.pixelSize: 11
                                            font.weight: Font.Black
                                            color: p5PhoneStage.activeTab === "mail" ? "#000000" : "#FFFFFF"
                                        }

                                        Rectangle {
                                            visible: PhantomState.imNotifications.count > 0
                                            width: 16
                                            height: 16
                                            radius: 8
                                            color: p5PhoneStage.activeTab === "mail" ? "#000000" : "#E60012"
                                            Text {
                                                anchors.centerIn: parent
                                                text: PhantomState.imNotifications.count
                                                font.pixelSize: 9
                                                font.weight: Font.Black
                                                color: "#FFFFFF"
                                            }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (p5PhoneStage.activeTab !== "mail") {
                                                PhantomState.p3LauncherTab = "mail"
                                                p5PhoneStage.activeDetailNotif = null
                                                PhantomState.playSfx("select")
                                                p5SearchInput.forceActiveFocus()
                                            }
                                        }
                                    }
                                }

                                // Clear All button (in CHAT tab)
                                Rectangle {
                                    visible: p5PhoneStage.activeTab === "mail" && PhantomState.imNotifications.count > 0
                                    width: 62
                                    height: 26
                                    radius: 2
                                    color: p5ClearAllMouse.containsMouse ? "#B0000A" : "#1A0003"
                                    border.color: "#FFFFFF"
                                    border.width: 1.2

                                    Text {
                                        anchors.centerIn: parent
                                        text: "CLEAR"
                                        font.family: "Rubik"
                                        font.pixelSize: 10
                                        font.weight: Font.Black
                                        color: "#FFFFFF"
                                    }

                                    MouseArea {
                                        id: p5ClearAllMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.imNotifications.clear()
                                            p5PhoneStage.activeDetailNotif = null
                                            p5PhoneStage.activeDetailIndex = -1
                                            PhantomState.playSfx("select")
                                        }
                                    }
                                }
                            }
                        }
                    }


                    // Slanted Search Bar (Persona 5 style)
                    Rectangle {
                        id: p5SearchContainer
                        anchors.top: p5HeaderContainer.bottom
                        anchors.topMargin: 8
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        height: 38
                        radius: 3
                        color: "#0A0A0E"
                        border.color: p5SearchInput.activeFocus ? "#FFFFFF" : "#303038"
                        border.width: p5SearchInput.activeFocus ? 2.0 : 1.2
                        z: 10

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text {
                                text: ">"
                                font.family: "Rubik"
                                font.pixelSize: 15
                                font.weight: Font.Black
                                color: "#E60012"
                            }

                            TextInput {
                                id: p5SearchInput
                                Layout.fillWidth: true
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#FFFFFF"
                                clip: true
                                selectByMouse: true
                                selectionColor: "#E60012"

                                onTextChanged: {
                                    if (p5PhoneStage.activeTab === "apps") {
                                        launcherWin.query = text
                                        launcherWin.selectedIndex = 0
                                    } else {
                                        p5PhoneStage.selectedNotifIndex = 0
                                    }
                                }

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Escape) {
                                        if (p5PhoneStage.activeDetailNotif !== null) {
                                            p5PhoneStage.activeDetailNotif = null
                                            p5PhoneStage.activeDetailIndex = -1
                                            PhantomState.playSfx("close")
                                        } else {
                                            PhantomState.launcherOpen = false
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Tab) {
                                        PhantomState.playSfx("select")
                                        PhantomState.p3LauncherTab = (p5PhoneStage.activeTab === "apps" ? "mail" : "apps")
                                        p5PhoneStage.activeDetailNotif = null
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Down) {
                                        PhantomState.playSfx("select")
                                        if (p5PhoneStage.activeDetailNotif === null) {
                                            if (p5PhoneStage.activeTab === "apps") {
                                                if (launcherWin.filteredItems.length > 0) {
                                                    launcherWin.selectedIndex = (launcherWin.selectedIndex + 1) % launcherWin.filteredItems.length
                                                }
                                            } else {
                                                if (PhantomState.imNotifications.count > 0) {
                                                    p5PhoneStage.selectedNotifIndex = (p5PhoneStage.selectedNotifIndex + 1) % PhantomState.imNotifications.count
                                                }
                                            }
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up) {
                                        PhantomState.playSfx("select")
                                        if (p5PhoneStage.activeDetailNotif === null) {
                                            if (p5PhoneStage.activeTab === "apps") {
                                                if (launcherWin.filteredItems.length > 0) {
                                                    launcherWin.selectedIndex = (launcherWin.selectedIndex - 1 + launcherWin.filteredItems.length) % launcherWin.filteredItems.length
                                                }
                                            } else {
                                                if (PhantomState.imNotifications.count > 0) {
                                                    p5PhoneStage.selectedNotifIndex = (p5PhoneStage.selectedNotifIndex - 1 + PhantomState.imNotifications.count) % PhantomState.imNotifications.count
                                                }
                                            }
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (p5PhoneStage.activeTab === "apps") {
                                            launcherWin.executeItem(launcherWin.selectedIndex)
                                        } else {
                                            if (p5PhoneStage.activeDetailNotif !== null) {
                                                p5PhoneStage.activeDetailNotif = null
                                                p5PhoneStage.activeDetailIndex = -1
                                                PhantomState.playSfx("close")
                                            } else if (PhantomState.imNotifications.count > 0 && p5PhoneStage.selectedNotifIndex >= 0 && p5PhoneStage.selectedNotifIndex < PhantomState.imNotifications.count) {
                                                var n = PhantomState.imNotifications.get(p5PhoneStage.selectedNotifIndex)
                                                if (n) {
                                                    p5PhoneStage.activeDetailNotif = {
                                                        "sender": n.senderName || n.sender || "New Message",
                                                        "body": n.msgBody || n.message || "",
                                                        "time": n.msgTime || n.time || "",
                                                        "icon": n.msgIcon || n.appIcon || "",
                                                        "color": "#E60012"
                                                    }
                                                    p5PhoneStage.activeDetailIndex = p5PhoneStage.selectedNotifIndex
                                                    PhantomState.playSfx("open")
                                                }
                                            }
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) {
                                        if (p5PhoneStage.activeTab === "mail") {
                                            if (p5PhoneStage.activeDetailNotif !== null) {
                                                if (p5PhoneStage.activeDetailIndex >= 0 && p5PhoneStage.activeDetailIndex < PhantomState.imNotifications.count) {
                                                    PhantomState.imNotifications.remove(p5PhoneStage.activeDetailIndex)
                                                }
                                                p5PhoneStage.activeDetailNotif = null
                                                p5PhoneStage.activeDetailIndex = -1
                                                PhantomState.playSfx("select")
                                                event.accepted = true
                                            } else if (PhantomState.imNotifications.count > 0 && p5PhoneStage.selectedNotifIndex >= 0 && p5PhoneStage.selectedNotifIndex < PhantomState.imNotifications.count) {
                                                PhantomState.imNotifications.remove(p5PhoneStage.selectedNotifIndex)
                                                if (p5PhoneStage.selectedNotifIndex >= PhantomState.imNotifications.count && p5PhoneStage.selectedNotifIndex > 0) {
                                                    p5PhoneStage.selectedNotifIndex--
                                                }
                                                PhantomState.playSfx("select")
                                                event.accepted = true
                                            }
                                        }
                                    }
                                }

                                Text {
                                    anchors.fill: parent
                                    text: p5PhoneStage.activeTab === "apps" ? "Search applications or >settings, >theme..." : "Filter chat messages..."
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#606070"
                                    visible: p5SearchInput.text.length === 0
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }

                    // Empty state (Chat tab empty)
                    Item {
                        id: p5EmptyState
                        anchors.top: p5SearchContainer.bottom
                        anchors.bottom: p5PromptFooter.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        visible: p5PhoneStage.activeTab === "mail" && PhantomState.imNotifications.count === 0 && p5PhoneStage.activeDetailNotif === null

                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "NO NEW MESSAGES"
                                font.family: "Rubik"
                                font.pixelSize: 18
                                font.weight: Font.Black
                                font.italic: true
                                color: "#FFFFFF"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "All clear in the Metaverse, Joker."
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#F0C0C4"
                            }
                        }
                    }

                    // Persona 5 Controller Prompt Footer (Pill bar anchored to bottom)
                    Rectangle {
                        id: p5PromptFooter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: p5PromptRow.width + 24
                        height: 26
                        radius: 13
                        color: "#E0000000"
                        border.color: "#30FFFFFF"
                        border.width: 1
                        z: 20

                        Row {
                            id: p5PromptRow
                            anchors.centerIn: parent
                            spacing: 14

                            Row {
                                spacing: 5
                                anchors.verticalCenter: parent.verticalCenter
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#000000"
                                    border.color: "#FFFFFF"
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 9; font.bold: true; color: "#FFFFFF" }
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Esc Close"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                            }

                            Row {
                                spacing: 5
                                anchors.verticalCenter: parent.verticalCenter
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#000000"
                                    border.color: "#FFFFFF"
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: "★"; font.pixelSize: 9; font.bold: true; color: "#E60012" }
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Enter Confirm"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                            }

                            Row {
                                spacing: 5
                                anchors.verticalCenter: parent.verticalCenter
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#000000"
                                    border.color: "#FFFFFF"
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: "⇄"; font.pixelSize: 9; font.bold: true; color: "#FFFFFF" }
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Tab Switch"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                            }
                        }
                    }

                    // Application & Chat ListView (Authentic Persona 5 Slanted Black Banners)
                    ListView {
                        id: p5AppList
                        anchors.top: p5SearchContainer.bottom
                        anchors.topMargin: 8
                        anchors.bottom: p5PromptFooter.top
                        anchors.bottomMargin: 12
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        clip: true
                        spacing: 5
                        z: 10
                        model: p5PhoneStage.activeTab === "apps" ? launcherWin.filteredItems : PhantomState.imNotifications
                        currentIndex: p5PhoneStage.activeTab === "apps" ? launcherWin.selectedIndex : p5PhoneStage.selectedNotifIndex

                        onCurrentIndexChanged: {
                            positionViewAtIndex(currentIndex, ListView.Contain)
                        }

                        delegate: Item {
                            id: p5RowDelegate
                            clip: true
                            readonly property bool isApps: p5PhoneStage.activeTab === "apps"
                            readonly property bool isSelected: isApps ? (index === launcherWin.selectedIndex) : (index === p5PhoneStage.selectedNotifIndex)
                            readonly property bool isHovered: p5RowMouse.containsMouse

                            width: p5AppList.width
                            height: 52

                            readonly property string itemName: isApps ? (modelData ? (modelData.name || "") : "") : (typeof senderName !== "undefined" ? senderName : (typeof sender !== "undefined" ? sender : (typeof model !== "undefined" && model ? (model.senderName || model.sender || "") : "")))
                            readonly property string itemDesc: isApps ? (modelData ? (modelData.desc || "") : "") : (typeof msgBody !== "undefined" ? msgBody : (typeof message !== "undefined" ? message : (typeof model !== "undefined" && model ? (model.msgBody || model.message || "") : "")))
                            readonly property string titleClean: launcherWin.cleanSnippet(p5RowDelegate.itemName)
                            readonly property string itemPreview: launcherWin.cleanSnippet(p5RowDelegate.itemDesc)
                            readonly property string itemIcon: isApps ? (modelData ? (modelData.appIcon || "") : "") : (typeof msgIcon !== "undefined" ? msgIcon : (typeof appIcon !== "undefined" ? appIcon : (typeof model !== "undefined" && model ? (model.msgIcon || model.appIcon || "") : "")))
                            readonly property string itemTime: !isApps ? (typeof msgTime !== "undefined" ? msgTime : (typeof time !== "undefined" ? time : (typeof model !== "undefined" && model ? (model.msgTime || model.time || "") : ""))) : ""
                            readonly property string resolvedIcon: {
                                const ic = (p5RowDelegate.itemIcon || "").trim()
                                const lowerName = (p5RowDelegate.itemName || "").toLowerCase()
                                const lowerIcon = ic.toLowerCase()
                                const lowerDesc = (p5RowDelegate.itemDesc || "").toLowerCase()
                                if (lowerIcon.indexOf("whatsapp") !== -1 || lowerName.indexOf("whatsapp") !== -1 || lowerDesc.indexOf("whatsapp") !== -1) {
                                    return "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/icons/whatsapp.svg"
                                }
                                if (lowerIcon.indexOf("zen") !== -1 || lowerName.indexOf("zen") !== -1) {
                                    return "file:///etc/profiles/per-user/sho/share/icons/hicolor/128x128/apps/zen-browser.png"
                                }
                                if (ic.startsWith("file://") || ic.startsWith("/")) {
                                    return ic.startsWith("/") ? ("file://" + ic) : ic
                                }
                                if (ic.startsWith("image://")) {
                                    return ic
                                }
                                if (ic.length > 0) {
                                    const r = Quickshell.iconPath(ic, true)
                                    if (r && String(r).length > 0) return r
                                }
                                return PhantomState.resolveAppIconUrl(p5RowDelegate.itemName)
                            }

                            x: isSelected ? 6 : (isHovered ? 3 : 0)
                            Behavior on x { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

                            // Slanted Item Card Canvas (Persona 5 style)
                            Canvas {
                                id: p5RowCanvas
                                anchors.fill: parent
                                antialiasing: true

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();
                                    var w = width;
                                    var h = height;
                                    var s = 14.0;

                                    if (p5RowDelegate.isSelected) {
                                        // 1. Black shadow polygon in back
                                        ctx.beginPath();
                                        ctx.moveTo(s + 3, 3);
                                        ctx.lineTo(w, 3);
                                        ctx.lineTo(w - s, h + 1);
                                        ctx.lineTo(3, h + 1);
                                        ctx.closePath();
                                        ctx.fillStyle = "#000000";
                                        ctx.fill();

                                        // 2. Front Face (Vibrant Crimson Red with thick Black border)
                                        ctx.beginPath();
                                        ctx.moveTo(s, 0);
                                        ctx.lineTo(w - 2, 0);
                                        ctx.lineTo(w - 2 - s, h - 2);
                                        ctx.lineTo(0, h - 2);
                                        ctx.closePath();
                                        ctx.fillStyle = "#E60012";
                                        ctx.fill();

                                        ctx.lineWidth = 2.5;
                                        ctx.strokeStyle = "#000000";
                                        ctx.stroke();

                                        // 3. Black accent stripe on left
                                        ctx.beginPath();
                                        ctx.moveTo(s, 0);
                                        ctx.lineTo(s + 5, 0);
                                        ctx.lineTo(5, h - 2);
                                        ctx.lineTo(0, h - 2);
                                        ctx.closePath();
                                        ctx.fillStyle = "#000000";
                                        ctx.fill();
                                    } else {
                                        // Unselected slanted black banner
                                        ctx.beginPath();
                                        ctx.moveTo(s, 0);
                                        ctx.lineTo(w, 0);
                                        ctx.lineTo(w - s, h);
                                        ctx.lineTo(0, h);
                                        ctx.closePath();
                                        ctx.fillStyle = p5RowDelegate.isHovered ? "#14141E" : "#0A0A0E";
                                        ctx.fill();

                                        ctx.lineWidth = 1.2;
                                        ctx.strokeStyle = p5RowDelegate.isHovered ? "#FFFFFF" : "#222230";
                                        ctx.stroke();
                                    }
                                }

                                Connections {
                                    target: p5RowDelegate
                                    function onIsSelectedChanged() { p5RowCanvas.requestPaint() }
                                    function onIsHoveredChanged() { p5RowCanvas.requestPaint() }
                                    function onWidthChanged() { p5RowCanvas.requestPaint() }
                                }
                            }

                            // Content inside the card
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 16
                                spacing: 8

                                // Sticker Badges (Persona 5 APP / NEW / HOLD + Date Chip)
                                Row {
                                    spacing: 4
                                    Layout.alignment: Qt.AlignVCenter

                                    Rectangle {
                                        width: p5RowDelegate.isApps ? 34 : 38
                                        height: 18
                                        radius: 2
                                        color: p5RowDelegate.isSelected ? "#000000" : "#E60012"
                                        border.color: p5RowDelegate.isSelected ? "#FFFFFF" : "#000000"
                                        border.width: 1
                                        Text {
                                            anchors.centerIn: parent
                                            text: p5RowDelegate.isApps ? "APP" : (index === 0 ? "NEW" : "HOLD")
                                            font.family: p5HeadlineFont.name !== "" ? p5HeadlineFont.name : "Rubik"
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                            color: "#FFFFFF"
                                        }
                                    }

                                    // Only show date chip for messages in CHAT mode!
                                    Rectangle {
                                        visible: !p5RowDelegate.isApps
                                        width: 42
                                        height: 18
                                        radius: 2
                                        color: p5RowDelegate.isSelected ? "#000000" : "#FFFFFF"
                                        border.color: p5RowDelegate.isSelected ? "#FFFFFF" : "#000000"
                                        border.width: 1
                                        Text {
                                            anchors.centerIn: parent
                                            text: p5RowDelegate.itemTime !== "" ? p5RowDelegate.itemTime : Qt.formatDateTime(new Date(), "M/d")
                                            font.family: "Rubik"
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                            color: p5RowDelegate.isSelected ? "#FFFFFF" : "#000000"
                                        }
                                    }
                                }

                                // App Icon / Avatar Badge
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 2
                                    Layout.alignment: Qt.AlignVCenter
                                    color: p5RowDelegate.isSelected ? "#FFFFFF" : "#161622"
                                    border.color: p5RowDelegate.isSelected ? "#000000" : "#323244"
                                    border.width: 1.5

                                    Image {
                                        id: p5AvatarImg
                                        anchors.centerIn: parent
                                        width: 22
                                        height: 22
                                        source: p5RowDelegate.resolvedIcon
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        visible: p5RowDelegate.resolvedIcon !== "" && status === Image.Ready && implicitWidth > 0
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: !p5AvatarImg.visible
                                        text: {
                                            const n = (p5RowDelegate.itemName || "").trim()
                                            return n.length > 0 ? n.charAt(0).toUpperCase() : "★"
                                        }
                                        font.family: "Rubik"
                                        font.pixelSize: 14
                                        font.weight: Font.Black
                                        color: p5RowDelegate.isSelected ? "#000000" : "#FFFFFF"
                                    }
                                }

                                // App Title and Description
                                Column {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 1

                                    Text {
                                        width: parent.width
                                        text: p5RowDelegate.titleClean
                                        color: "#FFFFFF"
                                        font.family: "Rubik"
                                        font.pixelSize: 13
                                        font.weight: p5RowDelegate.isSelected ? Font.Black : Font.Bold
                                        maximumLineCount: 1
                                        elide: Text.ElideRight
                                        renderType: Text.CurveRendering
                                    }

                                    Text {
                                        width: parent.width
                                        text: p5RowDelegate.itemPreview
                                        color: p5RowDelegate.isSelected ? "#FFFFFF" : "#9898AC"
                                        opacity: p5RowDelegate.isSelected ? 0.92 : 1.0
                                        font.family: "Rubik"
                                        font.pixelSize: 10
                                        font.bold: true
                                        maximumLineCount: 1
                                        elide: Text.ElideRight
                                        renderType: Text.CurveRendering
                                    }
                                }

                                // Selection / Launch Tag (Sticker Pill)
                                Rectangle {
                                    visible: p5RowDelegate.isSelected
                                    Layout.alignment: Qt.AlignVCenter
                                    height: 22
                                    width: 72
                                    radius: 2
                                    color: "#000000"
                                    border.color: "#FFFFFF"
                                    border.width: 1.5

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Text {
                                            text: "★"
                                            font.pixelSize: 9
                                            color: "#E60012"
                                        }
                                        Text {
                                            text: p5RowDelegate.isApps ? "LAUNCH" : "OPEN"
                                            font.family: "Rubik"
                                            font.pixelSize: 10
                                            font.weight: Font.Black
                                            color: "#FFFFFF"
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: p5RowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: {
                                    if (p5RowDelegate.isApps) {
                                        if (launcherWin.selectedIndex !== index) PhantomState.playSfx("select")
                                        launcherWin.selectedIndex = index
                                    } else {
                                        if (p5PhoneStage.selectedNotifIndex !== index) PhantomState.playSfx("select")
                                        p5PhoneStage.selectedNotifIndex = index
                                    }
                                }
                                onClicked: {
                                    if (p5RowDelegate.isApps) {
                                        launcherWin.selectedIndex = index
                                        launcherWin.executeItem(index)
                                    } else {
                                        p5PhoneStage.selectedNotifIndex = index
                                        p5PhoneStage.activeDetailNotif = {
                                            "sender": p5RowDelegate.itemName,
                                            "body": p5RowDelegate.itemDesc,
                                            "time": p5RowDelegate.itemTime,
                                            "icon": p5RowDelegate.itemIcon,
                                            "color": "#E60012"
                                        }
                                        p5PhoneStage.activeDetailIndex = index
                                        PhantomState.playSfx("open")
                                    }
                                }
                            }
                        }
                    }

                    
                    // Message detail reader overlay
                    Item {
                        id: p5MailReaderModal
                        anchors.fill: parent
                        anchors.margins: -4
                        z: 50
                        opacity: p5PhoneStage.activeDetailNotif !== null ? 1.0 : 0.0
                        visible: opacity > 0.0
                        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                        Rectangle {
                            anchors.fill: parent
                            color: "#FA0A0A10"
                            radius: 6
                            MouseArea { anchors.fill: parent }
                        }

                        Item {
                            anchors.fill: parent
                            anchors.margins: 14

                            Canvas {
                                id: p5ReaderRibbon
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 44
                                antialiasing: true

                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();
                                    var w = width;
                                    var h = height;

                                    ctx.beginPath();
                                    ctx.moveTo(12, 0);
                                    ctx.lineTo(w, 0);
                                    ctx.lineTo(w - 12, h);
                                    ctx.lineTo(0, h);
                                    ctx.closePath();
                                    ctx.fillStyle = "#E60012";
                                    ctx.fill();

                                    ctx.lineWidth = 1.5;
                                    ctx.strokeStyle = "#FFFFFF";
                                    ctx.stroke();
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16

                                    Text {
                                        text: "★ MESSAGE DISPATCH"
                                        font.family: "Rubik"
                                        font.pixelSize: 14
                                        font.weight: Font.Black
                                        font.italic: true
                                        color: "#FFFFFF"
                                    }

                                    Item { Layout.fillWidth: true }

                                    Text {
                                        text: p5PhoneStage.activeDetailNotif ? p5PhoneStage.activeDetailNotif.time : ""
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: "#FFFFFF"
                                    }
                                }
                            }

                            // Sender header card
                            Rectangle {
                                id: p5SenderBox
                                anchors.top: p5ReaderRibbon.bottom
                                anchors.topMargin: 12
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 50
                                radius: 4
                                color: "#14141E"
                                border.color: "#FFFFFF"
                                border.width: 1.5

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 12

                                    Rectangle {
                                        width: 32
                                        height: 32
                                        radius: 3
                                        color: "#E60012"

                                        Image {
                                            id: p5DetailAvatar
                                            anchors.centerIn: parent
                                            width: 22
                                            height: 22
                                            source: {
                                                if (!p5PhoneStage.activeDetailNotif) return ""
                                                const ic = (p5PhoneStage.activeDetailNotif.icon || "").trim()
                                                const s = (p5PhoneStage.activeDetailNotif.sender || "").toLowerCase()
                                                if (s.indexOf("whatsapp") !== -1 || ic.indexOf("whatsapp") !== -1) {
                                                    return "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/icons/whatsapp.svg"
                                                }
                                                if (s.indexOf("zen") !== -1 || ic.indexOf("zen") !== -1) {
                                                    return "file:///etc/profiles/per-user/sho/share/icons/hicolor/128x128/apps/zen-browser.png"
                                                }
                                                if (ic.startsWith("file://") || ic.startsWith("/")) {
                                                    return ic.startsWith("/") ? ("file://" + ic) : ic
                                                }
                                                if (ic.length > 0) {
                                                    const r = Quickshell.iconPath(ic, true)
                                                    if (r && String(r).length > 0) return r
                                                }
                                                return PhantomState.resolveAppIconUrl(p5PhoneStage.activeDetailNotif.sender || "")
                                            }
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                            visible: status === Image.Ready && source !== ""
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: !p5DetailAvatar.visible
                                            text: {
                                                const s = (p5PhoneStage.activeDetailNotif ? p5PhoneStage.activeDetailNotif.sender : "").trim()
                                                return s.length > 0 ? s.charAt(0).toUpperCase() : "★"
                                            }
                                            font.family: "Rubik"
                                            font.pixelSize: 16
                                            font.weight: Font.Black
                                            color: "#FFFFFF"
                                        }
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text {
                                            text: "TRANSMITTER:"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.bold: true
                                            color: "#E60012"
                                        }
                                        Text {
                                            text: p5PhoneStage.activeDetailNotif ? p5PhoneStage.activeDetailNotif.sender : ""
                                            font.family: "Rubik"
                                            font.pixelSize: 14
                                            font.weight: Font.Black
                                            color: "#FFFFFF"
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }

                            // Body card
                            Rectangle {
                                anchors.top: p5SenderBox.bottom
                                anchors.topMargin: 10
                                anchors.bottom: p5ReaderActionRow.top
                                anchors.bottomMargin: 10
                                anchors.left: parent.left
                                anchors.right: parent.right
                                radius: 4
                                color: "#0E0E16"
                                border.color: "#2C2C3C"
                                border.width: 1

                                Flickable {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    contentWidth: width
                                    contentHeight: p5BodyText.height
                                    clip: true

                                    Text {
                                        id: p5BodyText
                                        width: parent.width
                                        text: p5PhoneStage.activeDetailNotif ? p5PhoneStage.activeDetailNotif.body : ""
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 12
                                        font.bold: true
                                        lineHeight: 1.35
                                        color: "#F0F0F8"
                                        wrapMode: Text.Wrap
                                    }
                                }
                            }

                            // Action buttons at bottom of reader
                            RowLayout {
                                id: p5ReaderActionRow
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 36
                                spacing: 10

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 34
                                    radius: 3
                                    color: p5DelMouse.containsMouse ? "#D0000A" : "#8A0006"
                                    border.color: "#FFFFFF"
                                    border.width: 1.5

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Text {
                                            text: "DELETE (DEL)"
                                            font.family: "Rubik"
                                            font.pixelSize: 11
                                            font.weight: Font.Black
                                            color: "#FFFFFF"
                                        }
                                    }

                                    MouseArea {
                                        id: p5DelMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (p5PhoneStage.activeDetailIndex >= 0 && p5PhoneStage.activeDetailIndex < PhantomState.imNotifications.count) {
                                                PhantomState.imNotifications.remove(p5PhoneStage.activeDetailIndex)
                                            }
                                            p5PhoneStage.activeDetailNotif = null
                                            p5PhoneStage.activeDetailIndex = -1
                                            PhantomState.playSfx("select")
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 34
                                    radius: 3
                                    color: p5CloseMouse.containsMouse ? "#222230" : "#14141E"
                                    border.color: "#FFFFFF"
                                    border.width: 1.5

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Text { text: "↵"; font.pixelSize: 14; font.bold: true; color: "#FFFFFF" }
                                        Text {
                                            text: "CLOSE / BACK"
                                            font.family: "Rubik"
                                            font.pixelSize: 11
                                            font.weight: Font.Black
                                            color: "#FFFFFF"
                                        }
                                    }

                                    MouseArea {
                                        id: p5CloseMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            p5PhoneStage.activeDetailNotif = null
                                            p5PhoneStage.activeDetailIndex = -1
                                            PhantomState.playSfx("select")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // S.E.E.S. mail and apps launcher container
            Item {
                id: p3MailStage
                visible: PhantomState.isP3
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 38
                width: 590
                height: Math.min(parent.height - 70, 700)

                readonly property string activeTab: PhantomState.p3LauncherTab
                property int selectedNotifIndex: 0

                property var activeDetailNotif: null
                property int activeDetailIndex: -1

                Connections {
                    target: PhantomState
                    function onP3ReaderIndexChanged() {
                        if (PhantomState.p3ReaderIndex >= 0 && PhantomState.p3ReaderIndex < PhantomState.imNotifications.count) {
                            var n = PhantomState.imNotifications.get(PhantomState.p3ReaderIndex)
                            if (n) {
                                p3MailStage.activeDetailNotif = {
                                    "sender": n.senderName || n.sender || "New Message",
                                    "body": n.msgBody || n.message || "",
                                    "time": n.msgTime || n.time || "",
                                    "icon": n.msgIcon || n.appIcon || "",
                                    "color": "#e60039"
                                }
                                p3MailStage.activeDetailIndex = PhantomState.p3ReaderIndex
                            }
                        }
                    }
                }

                // -5.5 deg rotation with multisample AA
                transformOrigin: Item.BottomLeft
                rotation: -5.5
                layer.enabled: true
                layer.smooth: true
                layer.samples: 4

                opacity: PhantomState.launcherOpen ? 1.0 : 0.0
                scale: PhantomState.launcherOpen ? 1.0 : 0.94
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }

                MouseArea { anchors.fill: parent }

                // Backdrop and drop shadow canvas
                Canvas {
                    id: p3CardBackdrop
                    anchors.fill: parent
                    antialiasing: true

                    function drawRoundRect(ctx, x, y, w, h, r) {
                        ctx.beginPath();
                        ctx.moveTo(x + r, y);
                        ctx.lineTo(x + w - r, y);
                        ctx.quadraticCurveTo(x + w, y, x + w, y + r);
                        ctx.lineTo(x + w, y + h - r);
                        ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
                        ctx.lineTo(x + r, y + h);
                        ctx.quadraticCurveTo(x, y + h, x, y + h - r);
                        ctx.lineTo(x, y + r);
                        ctx.quadraticCurveTo(x, y, x + r, y);
                        ctx.closePath();
                    }

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        var pad = 4;
                        var w = width - pad * 2 - 14;
                        var h = height - pad * 2 - 10;
                        var r = 6;

                        drawRoundRect(ctx, pad + 12, pad + 10, w, h, r);
                        ctx.fillStyle = "#070b14";
                        ctx.fill();

                        drawRoundRect(ctx, pad, pad, w, h, r);
                        ctx.fillStyle = "#131926";
                        ctx.fill();

                        ctx.lineWidth = 3.5;
                        ctx.strokeStyle = "#ffffff";
                        ctx.stroke();
                    }
                }

                // Main card content
                Item {
                    id: p3CardArea
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        text: p3MailStage.activeTab === "apps" ? "APPS" : "MAIL"
                        font.family: "Rubik"
                        font.pixelSize: 84
                        font.weight: Font.Black
                        font.italic: true
                        color: "#26354d"
                        renderType: Text.CurveRendering
                    }

                    Canvas {
                        id: p3RibbonCanvas
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -2
                        anchors.rightMargin: 0
                        width: 240
                        height: 58
                        antialiasing: true

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var w = width;
                            var h = height;

                            ctx.beginPath();
                            ctx.moveTo(34, 4);
                            ctx.lineTo(w, 4);
                            ctx.lineTo(w, h + 8);
                            ctx.lineTo(26, h + 8);
                            ctx.closePath();
                            ctx.fillStyle = "#061332";
                            ctx.fill();

                            ctx.beginPath();
                            ctx.moveTo(42, 0);
                            ctx.lineTo(w, 0);
                            ctx.lineTo(w, h);
                            ctx.lineTo(0, h);
                            ctx.closePath();
                            ctx.fillStyle = "#0052cc";
                            ctx.fill();

                            ctx.lineWidth = 1.5;
                            ctx.strokeStyle = "#00d0ff";
                            ctx.stroke();
                        }

                        Column {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 14
                            spacing: -4

                            Text {
                                text: p3MailStage.activeTab === "apps" ? "S.E.E.S." : "TODAY'S"
                                font.family: "Rubik"
                                font.pixelSize: 20
                                font.weight: Font.Black
                                font.italic: true
                                color: "#ffffff"
                                renderType: Text.CurveRendering
                            }
                            Text {
                                text: p3MailStage.activeTab === "apps" ? "System Apps" : (PhantomState.imNotifications.count > 0 ? (PhantomState.imNotifications.count + " Messages") : "New Message")
                                font.family: "Dancing Script"
                                font.pixelSize: 19
                                font.bold: true
                                font.italic: true
                                color: "#ffffff"
                                renderType: Text.CurveRendering
                            }
                        }
                    }

                    Row {
                        id: p3TabRow
                        anchors.top: p3RibbonCanvas.bottom
                        anchors.topMargin: 4
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        spacing: 8

                        Rectangle {
                            width: 86
                            height: 26
                            radius: 3
                            color: p3MailStage.activeTab === "apps" ? "#0038a8" : "transparent"
                            border.color: p3MailStage.activeTab === "apps" ? "#00d0ff" : "#2EFFFFFF"
                            border.width: 1.5

                            Text {
                                anchors.centerIn: parent
                                text: "APPS"
                                font.family: "Rubik"
                                font.pixelSize: 11
                                font.weight: Font.Black
                                color: p3MailStage.activeTab === "apps" ? "#ffffff" : "#6f8cb0"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (p3MailStage.activeTab !== "apps") {
                                        PhantomState.p3LauncherTab = "apps"
                                        p3MailStage.activeDetailNotif = null
                                        PhantomState.playSfx("select")
                                        p3SearchInput.forceActiveFocus()
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 96
                            height: 26
                            radius: 3
                            color: p3MailStage.activeTab === "mail" ? "#0038a8" : "transparent"
                            border.color: p3MailStage.activeTab === "mail" ? "#00d0ff" : "#2EFFFFFF"
                            border.width: 1.5

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: "MAIL"
                                    font.family: "Rubik"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                    color: p3MailStage.activeTab === "mail" ? "#ffffff" : "#6f8cb0"
                                }
                                Rectangle {
                                    visible: PhantomState.imNotifications.count > 0
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#e60039"
                                    Text {
                                        anchors.centerIn: parent
                                        text: PhantomState.imNotifications.count
                                        font.family: "Rubik"
                                        font.pixelSize: 9
                                        font.bold: true
                                        color: "#ffffff"
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (p3MailStage.activeTab !== "mail") {
                                        PhantomState.p3LauncherTab = "mail"
                                        p3MailStage.activeDetailNotif = null
                                        PhantomState.playSfx("select")
                                        p3SearchInput.forceActiveFocus()
                                    }
                                }
                            }
                        }

                        Rectangle {
                            visible: p3MailStage.activeTab === "mail" && PhantomState.imNotifications.count > 0
                            width: 72
                            height: 26
                            radius: 3
                            color: clearAllMouse.containsMouse ? "#e60039" : "transparent"
                            border.color: clearAllMouse.containsMouse ? "#ff3366" : "#33FFFFFF"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "Clear All"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                font.bold: true
                                color: clearAllMouse.containsMouse ? "#ffffff" : "#8ca4c4"
                            }

                            MouseArea {
                                id: clearAllMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    PhantomState.imNotifications.clear()
                                    p3MailStage.activeDetailNotif = null
                                    p3MailStage.activeDetailIndex = -1
                                    PhantomState.playSfx("select")
                                }
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "[Tab] switch"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#4e6a91"
                        }
                    }

                    Rectangle {
                        id: p3SearchContainer
                        anchors.top: p3TabRow.bottom
                        anchors.topMargin: 8
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        height: 38
                        radius: 3
                        color: "#0c1320"
                        border.color: p3SearchInput.activeFocus ? "#00e5ff" : "#24324a"
                        border.width: 1.5
                        antialiasing: true

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text {
                                text: p3MailStage.activeTab === "apps" ? ">" : "•"
                                font.pixelSize: 14
                                color: p3SearchInput.activeFocus ? "#00e5ff" : "#4e6a91"
                            }

                            TextInput {
                                id: p3SearchInput
                                Layout.fillWidth: true
                                color: "#ffffff"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                selectionColor: "#00dbff"
                                selectedTextColor: "#000000"
                                clip: true

                                onTextChanged: {
                                    if (p3MailStage.activeTab === "apps") {
                                        launcherWin.query = text
                                        launcherWin.selectedIndex = 0
                                    } else {
                                        p3MailStage.selectedNotifIndex = 0
                                    }
                                }

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Escape) {
                                        if (p3MailStage.activeDetailNotif !== null) {
                                            p3MailStage.activeDetailNotif = null
                                            p3MailStage.activeDetailIndex = -1
                                            PhantomState.playSfx("close")
                                            event.accepted = true
                                        } else {
                                            PhantomState.launcherOpen = false
                                            event.accepted = true
                                        }
                                    } else if (event.key === Qt.Key_Tab) {
                                        PhantomState.p3LauncherTab = (p3MailStage.activeTab === "apps" ? "mail" : "apps")
                                        p3MailStage.activeDetailNotif = null
                                        PhantomState.playSfx("select")
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Down) {
                                        if (p3MailStage.activeDetailNotif === null) {
                                            if (p3MailStage.activeTab === "apps") {
                                                if (launcherWin.filteredItems.length > 0) {
                                                    launcherWin.selectedIndex = (launcherWin.selectedIndex + 1) % launcherWin.filteredItems.length
                                                }
                                            } else {
                                                if (PhantomState.imNotifications.count > 0) {
                                                    p3MailStage.selectedNotifIndex = (p3MailStage.selectedNotifIndex + 1) % PhantomState.imNotifications.count
                                                }
                                            }
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up) {
                                        if (p3MailStage.activeDetailNotif === null) {
                                            if (p3MailStage.activeTab === "apps") {
                                                if (launcherWin.filteredItems.length > 0) {
                                                    launcherWin.selectedIndex = (launcherWin.selectedIndex - 1 + launcherWin.filteredItems.length) % launcherWin.filteredItems.length
                                                }
                                            } else {
                                                if (PhantomState.imNotifications.count > 0) {
                                                    p3MailStage.selectedNotifIndex = (p3MailStage.selectedNotifIndex - 1 + PhantomState.imNotifications.count) % PhantomState.imNotifications.count
                                                }
                                            }
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        if (p3MailStage.activeTab === "apps") {
                                            launcherWin.executeItem(launcherWin.selectedIndex)
                                        } else {
                                            if (p3MailStage.activeDetailNotif !== null) {
                                                p3MailStage.activeDetailNotif = null
                                                p3MailStage.activeDetailIndex = -1
                                                PhantomState.playSfx("close")
                                            } else if (PhantomState.imNotifications.count > 0) {
                                                var n = PhantomState.imNotifications.get(p3MailStage.selectedNotifIndex)
                                                if (n) {
                                                    p3MailStage.activeDetailNotif = {
                                                        "sender": n.senderName || n.sender || "New Message",
                                                        "body": n.msgBody || n.message || "",
                                                        "time": n.msgTime || n.time || "",
                                                        "icon": n.msgIcon || n.appIcon || "",
                                                        "color": "#e60039"
                                                    }
                                                    p3MailStage.activeDetailIndex = p3MailStage.selectedNotifIndex
                                                    PhantomState.playSfx("open")
                                                }
                                            }
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Delete) {
                                        if (p3MailStage.activeTab === "mail") {
                                            if (p3MailStage.activeDetailNotif !== null) {
                                                if (p3MailStage.activeDetailIndex >= 0 && p3MailStage.activeDetailIndex < PhantomState.imNotifications.count) {
                                                    PhantomState.imNotifications.remove(p3MailStage.activeDetailIndex)
                                                }
                                                p3MailStage.activeDetailNotif = null
                                                p3MailStage.activeDetailIndex = -1
                                                PhantomState.playSfx("select")
                                            } else if (PhantomState.imNotifications.count > 0) {
                                                PhantomState.imNotifications.remove(p3MailStage.selectedNotifIndex)
                                                if (p3MailStage.selectedNotifIndex >= PhantomState.imNotifications.count && p3MailStage.selectedNotifIndex > 0) {
                                                    p3MailStage.selectedNotifIndex--
                                                }
                                                PhantomState.playSfx("select")
                                            }
                                            event.accepted = true
                                        }
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: p3MailStage.activeTab === "apps" ? "Search applications or >settings, >theme..." : "Filter notifications..."
                                    color: "#4e6a91"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    visible: p3SearchInput.text.length === 0
                                }
                            }
                        }
                    }

                    Item {
                        anchors.centerIn: p3AppList
                        visible: p3MailStage.activeTab === "mail" && PhantomState.imNotifications.count === 0 && p3MailStage.activeDetailNotif === null
                        width: 300
                        height: 120

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "•"
                                font.pixelSize: 36
                                color: Qt.rgba(0/255, 219/255, 255/255, 0.25)
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "NO NEW MESSAGES"
                                font.family: "Rubik"
                                font.pixelSize: 15
                                font.weight: Font.Black
                                color: "#6b88b0"
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Your inbox is clear today."
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#3f5678"
                            }
                        }
                    }

                    ListView {
                        id: p3AppList
                        anchors.top: p3SearchContainer.bottom
                        anchors.topMargin: 10
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 16
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 12
                        anchors.rightMargin: 16
                        clip: true
                        spacing: 5
                        model: p3MailStage.activeTab === "apps" ? launcherWin.filteredItems : PhantomState.imNotifications
                        currentIndex: p3MailStage.activeTab === "apps" ? launcherWin.selectedIndex : p3MailStage.selectedNotifIndex

                        onCurrentIndexChanged: {
                            positionViewAtIndex(currentIndex, ListView.Contain)
                        }

                        delegate: Item {
                            id: p3RowDelegate
                            clip: true
                            readonly property bool isApps: p3MailStage.activeTab === "apps"
                            readonly property bool isSelected: isApps ? (index === launcherWin.selectedIndex) : (index === p3MailStage.selectedNotifIndex)
                            readonly property bool isHovered: p3RowMouse.containsMouse

                            width: p3AppList.width - (isSelected ? 0 : 8)
                            height: 54

                            readonly property string itemName: isApps ? (modelData ? (modelData.name || "") : "") : (typeof senderName !== "undefined" ? senderName : (typeof sender !== "undefined" ? sender : (typeof model !== "undefined" && model ? (model.senderName || model.sender || "") : "")))
                            readonly property string itemDesc: isApps ? (modelData ? (modelData.desc || "") : "") : (typeof msgBody !== "undefined" ? msgBody : (typeof message !== "undefined" ? message : (typeof model !== "undefined" && model ? (model.msgBody || model.message || "") : "")))
                            readonly property string titleClean: launcherWin.cleanSnippet(p3RowDelegate.itemName)
                            readonly property string itemPreview: launcherWin.cleanSnippet(p3RowDelegate.itemDesc)
                            readonly property string itemIcon: isApps ? (modelData ? (modelData.appIcon || "") : "") : (typeof msgIcon !== "undefined" ? msgIcon : (typeof appIcon !== "undefined" ? appIcon : (typeof model !== "undefined" && model ? (model.msgIcon || model.appIcon || "") : "")))
                            readonly property string itemTime: !isApps ? (typeof msgTime !== "undefined" ? msgTime : (typeof time !== "undefined" ? time : (typeof model !== "undefined" && model ? (model.msgTime || model.time || "") : ""))) : ""
                            readonly property string resolvedIcon: {
                                const ic = (p3RowDelegate.itemIcon || "").trim()
                                const lowerName = (p3RowDelegate.itemName || "").toLowerCase()
                                const lowerIcon = ic.toLowerCase()
                                const lowerDesc = (p3RowDelegate.itemDesc || "").toLowerCase()
                                if (lowerIcon.indexOf("whatsapp") !== -1 || lowerName.indexOf("whatsapp") !== -1 || lowerDesc.indexOf("whatsapp") !== -1) {
                                    return "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/icons/whatsapp.svg"
                                }
                                if (lowerIcon.indexOf("zen") !== -1 || lowerName.indexOf("zen") !== -1) {
                                    return "file:///etc/profiles/per-user/sho/share/icons/hicolor/128x128/apps/zen-browser.png"
                                }
                                if (ic.startsWith("file://") || ic.startsWith("/")) {
                                    return ic.startsWith("/") ? ("file://" + ic) : ic
                                }
                                if (ic.startsWith("image://")) {
                                    return ic
                                }
                                if (ic.length > 0) {
                                    const r = Quickshell.iconPath(ic, true)
                                    if (r && String(r).length > 0) return r
                                }
                                return PhantomState.resolveAppIconUrl(p3RowDelegate.itemName)
                            }

                            x: isSelected ? 8 : (isHovered ? 4 : 0)
                            Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                            readonly property var duotoneColors: ["#0099cc", "#9c27b0", "#1565c0", "#e65100", "#2e7d32", "#00838f"]
                            readonly property color avatarColor: isSelected ? "#e60039" : ((typeof index === "number" && index >= 0) ? duotoneColors[index % duotoneColors.length] : "#0099cc")

                            Rectangle {
                                id: exclBadge
                                x: 6
                                anchors.verticalCenter: parent.verticalCenter
                                width: 20
                                height: 20
                                radius: 10
                                color: p3RowDelegate.isSelected ? "#00c0f0" : "#0090c0"
                                antialiasing: true

                                Text {
                                    anchors.centerIn: parent
                                    text: "!"
                                    font.family: "Rubik"
                                    font.pixelSize: 13
                                    font.weight: Font.Black
                                    color: "#030c1e"
                                }
                            }

                            Item {
                                id: avatarContainer
                                x: 32
                                y: 3
                                width: 66
                                height: 48

                                Canvas {
                                    id: avatarCanvas
                                    anchors.fill: parent
                                    antialiasing: true
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.beginPath();
                                        ctx.moveTo(0, 0);
                                        ctx.lineTo(width, 0);
                                        ctx.lineTo(width - 18, height);
                                        ctx.lineTo(0, height);
                                        ctx.closePath();
                                        ctx.fillStyle = p3RowDelegate.avatarColor;
                                        ctx.fill();
                                    }

                                    Connections {
                                        target: p3RowDelegate
                                        function onAvatarColorChanged() { avatarCanvas.requestPaint() }
                                        function onIsSelectedChanged() { avatarCanvas.requestPaint() }
                                    }
                                }

                                Image {
                                    id: avatarImg
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: 6
                                    width: 32
                                    height: 32
                                    source: p3RowDelegate.resolvedIcon
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    visible: p3RowDelegate.resolvedIcon !== "" && status === Image.Ready && implicitWidth > 0
                                }

                                Item {
                                    anchors.fill: parent
                                    visible: !avatarImg.visible

                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            const n = (p3RowDelegate.itemName || "").trim()
                                            return n.length > 0 ? n.charAt(0).toUpperCase() : "•"
                                        }
                                        font.family: "Rubik"
                                        font.pixelSize: 20
                                        font.weight: Font.Black
                                        color: "#ffffff"
                                    }
                                }
                            }

                            Item {
                                id: messageCard
                                x: 80
                                y: 3
                                width: p3RowDelegate.width - 80 + (p3RowDelegate.isSelected ? 10 : 0)
                                height: 48

                                Canvas {
                                    id: msgBgCanvas
                                    anchors.fill: parent
                                    antialiasing: true
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        var w = width;
                                        var h = height;

                                        if (p3RowDelegate.isSelected) {
                                            // Selected item card styling
                                            ctx.beginPath();
                                            ctx.moveTo(18, 0);
                                            ctx.lineTo(w, 0);
                                            ctx.lineTo(w, h);
                                            ctx.lineTo(0, h);
                                            ctx.closePath();
                                            ctx.fillStyle = "#ffffff";
                                            ctx.fill();

                                            ctx.lineWidth = 2.5;
                                            ctx.strokeStyle = "#0038a8";
                                            ctx.stroke();

                                            ctx.beginPath();
                                            ctx.moveTo(0, h);
                                            ctx.lineTo(w, h);
                                            ctx.lineWidth = 2.5;
                                            ctx.strokeStyle = "#0099ff";
                                            ctx.stroke();
                                        } else {
                                            // Unselected item card styling
                                            ctx.beginPath();
                                            ctx.moveTo(18, 0);
                                            ctx.lineTo(w, 0);
                                            ctx.lineTo(w, h);
                                            ctx.lineTo(0, h);
                                            ctx.closePath();
                                            ctx.fillStyle = p3RowDelegate.isHovered ? "#2a3750" : "#1e293c";
                                            ctx.fill();

                                            ctx.beginPath();
                                            ctx.moveTo(0, h);
                                            ctx.lineTo(w, h);
                                            ctx.lineWidth = 1.0;
                                            ctx.strokeStyle = "rgba(255, 255, 255, 0.12)";
                                            ctx.stroke();
                                        }
                                    }

                                    Connections {
                                        target: p3RowDelegate
                                        function onIsSelectedChanged() { msgBgCanvas.requestPaint() }
                                        function onIsHoveredChanged() { msgBgCanvas.requestPaint() }
                                        function onWidthChanged() { msgBgCanvas.requestPaint() }
                                    }
                                }

                                Column {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 24
                                    anchors.right: parent.right
                                    anchors.rightMargin: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    RowLayout {
                                        width: parent.width
                                        spacing: 6

                                        Text {
                                            text: "•"
                                            font.pixelSize: 14
                                            color: p3RowDelegate.isSelected ? "#0048d0" : "#00dbff"
                                        }

                                        Column {
                                            Layout.fillWidth: true
                                            spacing: 1

                                            RowLayout {
                                                width: parent.width
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: p3RowDelegate.titleClean
                                                    color: p3RowDelegate.isSelected ? "#0038a8" : "#ffffff"
                                                    font.family: "Rubik"
                                                    font.pixelSize: 14
                                                    font.weight: p3RowDelegate.isSelected ? Font.Black : Font.Bold
                                                    maximumLineCount: 1
                                                    elide: Text.ElideRight
                                                    renderType: Text.CurveRendering
                                                }

                                                Text {
                                                    visible: p3RowDelegate.itemTime !== ""
                                                    text: p3RowDelegate.itemTime
                                                    color: p3RowDelegate.isSelected ? "#0038a8" : "#6f8cb0"
                                                    font.family: "JetBrainsMono NFM"
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                }
                                            }

                                            Rectangle {
                                                width: Math.min(parent.width, 180)
                                                height: 1.5
                                                color: "#0038a8"
                                                visible: p3RowDelegate.isSelected
                                            }
                                        }
                                    }

                                    Text {
                                        width: parent.width
                                        text: p3RowDelegate.itemPreview
                                        color: p3RowDelegate.isSelected ? "#060f22" : "#9fb4cc"
                                        font.family: "Rubik"
                                        font.pixelSize: 11
                                        font.bold: true
                                        maximumLineCount: 1
                                        elide: Text.ElideRight
                                        renderType: Text.CurveRendering
                                    }
                                }
                            }

                            MouseArea {
                                id: p3RowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: {
                                    if (p3RowDelegate.isApps) {
                                        if (launcherWin.selectedIndex !== index) PhantomState.playSfx("select")
                                        launcherWin.selectedIndex = index
                                    } else {
                                        if (p3MailStage.selectedNotifIndex !== index) PhantomState.playSfx("select")
                                        p3MailStage.selectedNotifIndex = index
                                    }
                                }
                                onClicked: {
                                    if (p3RowDelegate.isApps) {
                                        launcherWin.selectedIndex = index
                                        launcherWin.executeItem(index)
                                    } else {
                                        p3MailStage.selectedNotifIndex = index
                                        p3MailStage.activeDetailNotif = {
                                            "sender": p3RowDelegate.itemName,
                                            "body": p3RowDelegate.itemDesc,
                                            "time": p3RowDelegate.itemTime,
                                            "icon": p3RowDelegate.itemIcon,
                                            "color": p3RowDelegate.avatarColor
                                        }
                                        p3MailStage.activeDetailIndex = index
                                        PhantomState.playSfx("open")
                                    }
                                }
                            }
                        }
                    }

                    // Message detail reader overlay
                    Item {
                        id: p3MailReaderModal
                        anchors.fill: parent
                        anchors.margins: -4
                        z: 50
                        opacity: p3MailStage.activeDetailNotif !== null ? 1.0 : 0.0
                        visible: opacity > 0.0
                        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                        Rectangle {
                            anchors.fill: parent
                            color: "#F5080C16"
                            radius: 4
                            MouseArea { anchors.fill: parent } // block clicks
                        }

                        Item {
                            anchors.fill: parent
                            anchors.margins: 14

                            Canvas {
                                id: readerRibbon
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 38
                                antialiasing: true
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();
                                    ctx.beginPath();
                                    ctx.moveTo(0, 0);
                                    ctx.lineTo(width, 0);
                                    ctx.lineTo(width - 16, height);
                                    ctx.lineTo(0, height);
                                    ctx.closePath();
                                    ctx.fillStyle = "#0048cc";
                                    ctx.fill();
                                    ctx.lineWidth = 1.5;
                                    ctx.strokeStyle = "#00d0ff";
                                    ctx.stroke();
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 24

                                    Text {
                                        text: "MESSAGE DETAIL"
                                        font.family: "Rubik"
                                        font.pixelSize: 13
                                        font.weight: Font.Black
                                        font.italic: true
                                        color: "#ffffff"
                                        renderType: Text.CurveRendering
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: p3MailStage.activeDetailNotif ? p3MailStage.activeDetailNotif.time : ""
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: "#8df6ff"
                                    }
                                }
                            }

                            RowLayout {
                                id: readerSenderRow
                                anchors.top: readerRibbon.bottom
                                anchors.topMargin: 14
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 12

                                Item {
                                    width: 58
                                    height: 44
                                    Canvas {
                                        anchors.fill: parent
                                        antialiasing: true
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            ctx.beginPath();
                                            ctx.moveTo(0, 0);
                                            ctx.lineTo(width, 0);
                                            ctx.lineTo(width - 16, height);
                                            ctx.lineTo(0, height);
                                            ctx.closePath();
                                            ctx.fillStyle = p3MailStage.activeDetailNotif ? p3MailStage.activeDetailNotif.color : "#e60039";
                                            ctx.fill();
                                        }
                                    }
                                    Image {
                                        id: readerAvatarImg
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: 6
                                        width: 28
                                        height: 28
                                        source: {
                                            if (!p3MailStage.activeDetailNotif) return ""
                                            const ic = (p3MailStage.activeDetailNotif.icon || "").trim()
                                            const s = (p3MailStage.activeDetailNotif.sender || "").toLowerCase()
                                            const lowerIcon = ic.toLowerCase()
                                            if (lowerIcon === "whatsapp" || s.indexOf("whatsapp") !== -1) {
                                                return "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/icons/whatsapp.svg"
                                            }
                                            if (lowerIcon.indexOf("zen") !== -1 || s.indexOf("zen") !== -1) {
                                                return "file:///etc/profiles/per-user/sho/share/icons/hicolor/128x128/apps/zen-browser.png"
                                            }
                                            if (ic.startsWith("file://") || ic.startsWith("/")) return ic.startsWith("/") ? ("file://" + ic) : ic
                                            if (ic.startsWith("image://")) return ic
                                            if (ic.length > 0) {
                                                const r = Quickshell.iconPath(ic, true)
                                                if (r && String(r).length > 0) return r
                                            }
                                            return PhantomState.resolveAppIconUrl(p3MailStage.activeDetailNotif.sender || "")
                                        }
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        visible: source !== "" && status === Image.Ready && implicitWidth > 0
                                    }
                                    Item {
                                        anchors.fill: parent
                                        visible: !readerAvatarImg.visible
                                        Text {
                                            anchors.centerIn: parent
                                            text: {
                                                const s = (p3MailStage.activeDetailNotif ? p3MailStage.activeDetailNotif.sender : "").trim()
                                                return s.length > 0 ? s.charAt(0).toUpperCase() : "•"
                                            }
                                            font.family: "Rubik"
                                            font.pixelSize: 18
                                            font.weight: Font.Black
                                            color: "#ffffff"
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: "TRANSMISSION SOURCE"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.bold: true
                                        color: "#00dbff"
                                        font.letterSpacing: 1.5
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: p3MailStage.activeDetailNotif ? p3MailStage.activeDetailNotif.sender : ""
                                        font.family: "Rubik"
                                        font.pixelSize: 17
                                        font.weight: Font.Black
                                        color: "#ffffff"
                                        elide: Text.ElideRight
                                        renderType: Text.CurveRendering
                                    }
                                }
                            }

                            Rectangle {
                                id: readerDivider
                                anchors.top: readerSenderRow.bottom
                                anchors.topMargin: 12
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                height: 1.5
                                color: "#5900DBFF"
                            }

                            Flickable {
                                id: readerFlick
                                anchors.top: readerDivider.bottom
                                anchors.topMargin: 14
                                anchors.bottom: readerActionsRow.top
                                anchors.bottomMargin: 14
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                contentWidth: width
                                contentHeight: msgFullText.implicitHeight
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds

                                Text {
                                    id: msgFullText
                                    width: readerFlick.width
                                    text: p3MailStage.activeDetailNotif ? p3MailStage.activeDetailNotif.body : ""
                                    wrapMode: Text.WordWrap
                                    font.family: "Rubik"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    lineHeight: 1.4
                                    color: "#e2ecf8"
                                    renderType: Text.CurveRendering
                                }
                            }

                            RowLayout {
                                id: readerActionsRow
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 12

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 34
                                    radius: 3
                                    color: delMouse.containsMouse ? "#c2002f" : "#e60039"
                                    antialiasing: true

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Text { text: "×"; font.pixelSize: 16; font.bold: true; color: "#ffffff" }
                                        Text {
                                            text: "DISMISS / CLEAR"
                                            font.family: "Rubik"
                                            font.pixelSize: 11
                                            font.weight: Font.Black
                                            color: "#ffffff"
                                        }
                                    }

                                    MouseArea {
                                        id: delMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (p3MailStage.activeDetailIndex >= 0 && p3MailStage.activeDetailIndex < PhantomState.imNotifications.count) {
                                                PhantomState.imNotifications.remove(p3MailStage.activeDetailIndex)
                                            }
                                            p3MailStage.activeDetailNotif = null
                                            p3MailStage.activeDetailIndex = -1
                                            PhantomState.playSfx("select")
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 34
                                    radius: 3
                                    color: closeMouse.containsMouse ? "#0044b3" : "#0038a8"
                                    border.color: "#00d0ff"
                                    border.width: 1.5
                                    antialiasing: true

                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Text { text: "↵"; font.pixelSize: 14; font.bold: true; color: "#ffffff" }
                                        Text {
                                            text: "CLOSE / BACK"
                                            font.family: "Rubik"
                                            font.pixelSize: 11
                                            font.weight: Font.Black
                                            color: "#ffffff"
                                        }
                                    }

                                    MouseArea {
                                        id: closeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            p3MailStage.activeDetailNotif = null
                                            p3MailStage.activeDetailIndex = -1
                                            PhantomState.playSfx("select")
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
