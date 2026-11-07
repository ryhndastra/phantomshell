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

        // daftar aplikasi desktop terinstal di sistem
        property var rawDesktopApps: DesktopEntries.applications.values

        // daftar perintah cepat bawaan phantomshell
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
                    if (appCmdList.length > 0) {
                        var cleanArgs = ["env", "-u", "QT_PLUGIN_PATH", "-u", "QML2_IMPORT_PATH", "-u", "QML_IMPORT_PATH", "-u", "NIXPKGS_QT6_QML_IMPORT_PATH"]
                        for (var m = 0; m < appCmdList.length; m++) {
                            cleanArgs.push(String(appCmdList[m]))
                        }
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
                PhantomState.settingsOpen = true
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
                        searchInput.text = ""
                        searchInput.forceActiveFocus()
                    }
                } else {
                    PhantomState.playSfx("close")
                }
            }
            function onModalForceExclusiveChanged() {
                if (PhantomState.launcherOpen && PhantomState.modalForceExclusive) {
                    if (PhantomState.isP3) p3SearchInput.forceActiveFocus()
                    else searchInput.forceActiveFocus()
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
                    searchInput.text = ""
                    searchInput.forceActiveFocus()
                }
            }
        }

        // lapisan latar redup transparan
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

            // kontainer utama aplikasi launcher di tengah layar (Persona 5)
            Item {
                id: launcherStage
                visible: !PhantomState.isP3
                width: Math.min(parent.width - 80, 900)
                height: Math.min(parent.height - 80, 680)
                anchors.centerIn: parent

                // penahan klik di dalam area launcher
                MouseArea { anchors.fill: parent }

                // latar kartu bersih minimalis khas Persona 3 Reload
                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: 16
                    anchors.bottomMargin: 48
                    visible: PhantomState.isP3
                    radius: 10
                    color: Qt.rgba(7/255, 14/255, 32/255, 0.94)
                    border.color: Qt.rgba(0/255, 219/255, 255/255, 0.5)
                    border.width: 1

                    // garis aksen biru cyan di atas
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 3
                        radius: 1
                        color: PhantomState.primary
                    }
                }

                // latar kartu miring launcher beserta aksen sudut (P5)
                Canvas {
                    anchors.fill: parent
                    visible: !PhantomState.isP3
                    property color accent: PhantomState.primary
                    onAccentChanged: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var h = height

                        // bayangan offset warna aksen
                        ctx.fillStyle = Qt.rgba(accent.r, accent.g, accent.b, 0.28)
                        ctx.beginPath()
                        ctx.moveTo(26, 16)
                        ctx.lineTo(w, 6)
                        ctx.lineTo(w - 18, h - 50)
                        ctx.lineTo(8, h - 42)
                        ctx.closePath()
                        ctx.fill()

                        // bidang gelap utama kartu launcher
                        ctx.fillStyle = "#E80B0B0F"
                        ctx.strokeStyle = "#FFFFFF"
                        ctx.lineWidth = 2.5
                        ctx.beginPath()
                        ctx.moveTo(18, 8)
                        ctx.lineTo(w - 10, 0)
                        ctx.lineTo(w - 26, h - 58)
                        ctx.lineTo(0, h - 50)
                        ctx.closePath()
                        ctx.fill()
                        ctx.stroke()

                        // aksen pita miring di pojok kanan atas
                        ctx.fillStyle = accent
                        ctx.beginPath()
                        ctx.moveTo(w - 170, 0)
                        ctx.lineTo(w - 10, 0)
                        ctx.lineTo(w - 14, 18)
                        ctx.lineTo(w - 185, 18)
                        ctx.closePath()
                        ctx.fill()
                    }
                }

                // baris header atas dan kotak pencarian aplikasi
                RowLayout {
                    id: topHeaderRow
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 24
                    anchors.leftMargin: 36
                    anchors.rightMargin: 42
                    spacing: 18

                    // lencana judul launcher
                    Item {
                        Layout.preferredWidth: PhantomState.isP3 ? 320 : 270
                        Layout.preferredHeight: 62
                        rotation: PhantomState.isP3 ? 0 : -2.5

                        Canvas {
                            anchors.fill: parent
                            visible: !PhantomState.isP3
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

                        Rectangle {
                            anchors.fill: parent
                            visible: PhantomState.isP3
                            radius: 4
                            color: Qt.rgba(4/255, 13/255, 36/255, 0.85)
                            border.color: "#00dbff"
                            border.width: 1

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 3
                                color: "#00dbff"
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 18
                            anchors.rightMargin: 18
                            spacing: 10

                            Image {
                                Layout.preferredWidth: 42
                                Layout.preferredHeight: 42
                                source: PhantomState.logoPath
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                            }

                            ColumnLayout {
                                spacing: 0
                                Text {
                                    text: PhantomState.isP3 ? "S.E.E.S. // TACTICAL SEARCH" : "PHANTOM LAUNCH"
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: PhantomState.isP3 ? 15 : 18
                                    font.weight: Font.Black
                                    font.italic: !PhantomState.isP3
                                }
                                Text {
                                    text: PhantomState.isP3 ? "MEMENTO MORI • PROTOCOL DISPATCH" : (launcherWin.filteredItems.length + " APPS & COMMANDS")
                                    color: PhantomState.isP3 ? "#00dbff" : PhantomState.secondary
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                }
                            }
                        }
                    }

                    // kotak input pencarian aplikasi dan perintah
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56

                        Canvas {
                            anchors.fill: parent
                            visible: !PhantomState.isP3
                            property color accent: PhantomState.primary
                            onAccentChanged: requestPaint()
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width
                                var h = height

                                ctx.fillStyle = accent
                                ctx.beginPath()
                                ctx.moveTo(14, 6)
                                ctx.lineTo(w, 4)
                                ctx.lineTo(w - 10, h)
                                ctx.lineTo(4, h - 2)
                                ctx.closePath()
                                ctx.fill()

                                ctx.fillStyle = "#FFFFFF"
                                ctx.beginPath()
                                ctx.moveTo(10, 0)
                                ctx.lineTo(w - 6, 0)
                                ctx.lineTo(w - 16, h - 6)
                                ctx.lineTo(0, h - 6)
                                ctx.closePath()
                                ctx.fill()

                                ctx.fillStyle = "#08080A"
                                ctx.beginPath()
                                ctx.moveTo(14, 4)
                                ctx.lineTo(w - 10, 4)
                                ctx.lineTo(w - 20, h - 10)
                                ctx.lineTo(5, h - 10)
                                ctx.closePath()
                                ctx.fill()
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: PhantomState.isP3
                            radius: 4
                            color: Qt.rgba(4/255, 13/255, 36/255, 0.85)
                            border.color: searchInput.activeFocus ? "#8df6ff" : Qt.rgba(0/255, 219/255, 255/255, 0.5)
                            border.width: 1
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 22
                            anchors.rightMargin: 24
                            anchors.bottomMargin: PhantomState.isP3 ? 0 : 6
                            spacing: 10

                            P5Icon {
                                name: "search"
                                color: PhantomState.primary
                                size: 16
                            }

                            TextInput {
                                id: searchInput
                                Layout.fillWidth: true
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 17
                                font.weight: Font.Black
                                font.italic: !PhantomState.isP3
                                selectionColor: PhantomState.primary
                                selectedTextColor: "#FFFFFF"
                                clip: true

                                onTextChanged: {
                                    launcherWin.query = text
                                    launcherWin.selectedIndex = 0
                                }

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Escape) {
                                        PhantomState.launcherOpen = false
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                                        if (launcherWin.filteredItems.length > 0) {
                                            launcherWin.selectedIndex = (launcherWin.selectedIndex + 1) % launcherWin.filteredItems.length
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up) {
                                        if (launcherWin.filteredItems.length > 0) {
                                            launcherWin.selectedIndex = (launcherWin.selectedIndex - 1 + launcherWin.filteredItems.length) % launcherWin.filteredItems.length
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        launcherWin.executeItem(launcherWin.selectedIndex)
                                        event.accepted = true
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: PhantomState.isP3 ? "Search apps or system commands (>theme, >settings)..." : "Search installed apps or type >theme, >settings..."
                                    color: "#777777"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    font.italic: !PhantomState.isP3
                                    visible: searchInput.text.length === 0
                                }
                            }
                        }
                    }
                }

                // daftar hasil pencarian aplikasi dan perintah
                ListView {
                    id: resultsList
                    anchors.top: topHeaderRow.bottom
                    anchors.topMargin: 18
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 86
                    anchors.left: parent.left
                    anchors.leftMargin: 36
                    anchors.right: parent.right
                    anchors.rightMargin: 42
                    clip: true
                    spacing: 10
                    model: launcherWin.filteredItems
                    currentIndex: launcherWin.selectedIndex

                    onCurrentIndexChanged: {
                        positionViewAtIndex(currentIndex, ListView.Contain)
                    }

                    delegate: Item {
                        id: rowDelegate
                        width: resultsList.width
                        height: 62
                        readonly property bool isSelected: index === launcherWin.selectedIndex
                        readonly property bool isHovered: rowMouse.containsMouse

                        // baris minimalis bersih untuk Persona 3 Reload
                        Rectangle {
                            anchors.fill: parent
                            visible: PhantomState.isP3
                            radius: 6
                            color: rowDelegate.isSelected 
                                ? Qt.rgba(0/255, 219/255, 255/255, 0.18) 
                                : (rowDelegate.isHovered ? Qt.rgba(255, 255, 255, 0.05) : "transparent")
                            border.color: rowDelegate.isSelected ? PhantomState.primary : "transparent"
                            border.width: 1

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 3
                                radius: 1
                                visible: rowDelegate.isSelected
                                color: PhantomState.primary
                            }
                        }

                        Canvas {
                            id: rowCanvas
                            anchors.fill: parent
                            visible: !PhantomState.isP3
                            property bool active: rowDelegate.isSelected || rowDelegate.isHovered
                            property color accent: PhantomState.primary
                            onActiveChanged: requestPaint()
                            onAccentChanged: requestPaint()
                            onWidthChanged: requestPaint()
                            onHeightChanged: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width
                                var h = height
                                var rightBoxX = w - 210

                                if (active) {
                                    // bilah miring beraksen saat baris dipilih atau di-hover
                                    ctx.fillStyle = "#08080A"
                                    ctx.beginPath()
                                    ctx.moveTo(18, 10)
                                    ctx.lineTo(rightBoxX + 30, 6)
                                    ctx.lineTo(rightBoxX + 16, h)
                                    ctx.lineTo(4, h - 2)
                                    ctx.closePath()
                                    ctx.fill()

                                    ctx.fillStyle = accent
                                    ctx.beginPath()
                                    ctx.moveTo(12, 4)
                                    ctx.lineTo(rightBoxX + 24, 2)
                                    ctx.lineTo(rightBoxX + 10, h - 6)
                                    ctx.lineTo(0, h - 8)
                                    ctx.closePath()
                                    ctx.fill()

                                    // garis sorot putih di tepi kiri bilah
                                    ctx.fillStyle = "#FFFFFF"
                                    ctx.beginPath()
                                    ctx.moveTo(0, h - 8)
                                    ctx.lineTo(16, 4)
                                    ctx.lineTo(25, 4)
                                    ctx.lineTo(10, h - 8)
                                    ctx.closePath()
                                    ctx.fill()
                                } else {
                                    // latar baris gelap saat tidak aktif
                                    ctx.fillStyle = "#D0121218"
                                    ctx.beginPath()
                                    ctx.moveTo(56, 6)
                                    ctx.lineTo(rightBoxX + 18, 4)
                                    ctx.lineTo(rightBoxX + 8, h - 6)
                                    ctx.lineTo(44, h - 6)
                                    ctx.closePath()
                                    ctx.fill()
                                }

                                // kotak lencana kanan dengan lekukan panah kiri
                                ctx.fillStyle = "#FFFFFF"
                                ctx.beginPath()
                                ctx.moveTo(rightBoxX, 3)
                                ctx.lineTo(w - 10, 1)
                                ctx.lineTo(w - 22, h - 4)
                                ctx.lineTo(rightBoxX - 10, h - 3)
                                ctx.lineTo(rightBoxX - 5, h * 0.64)
                                ctx.lineTo(rightBoxX - 22, h * 0.50)
                                ctx.lineTo(rightBoxX - 4, h * 0.36)
                                ctx.closePath()
                                ctx.fill()

                                // latar gelap di dalam kotak lencana kanan
                                ctx.fillStyle = "#08080A"
                                ctx.beginPath()
                                ctx.moveTo(rightBoxX + 7, 8)
                                ctx.lineTo(w - 17, 6)
                                ctx.lineTo(w - 28, h - 9)
                                ctx.lineTo(rightBoxX - 3, h - 8)
                                ctx.closePath()
                                ctx.fill()
                            }
                        }

                        // konten kiri berupa ikon aplikasi, nama, dan deskripsi
                        RowLayout {
                            anchors.left: parent.left
                            anchors.leftMargin: (rowDelegate.isSelected || rowDelegate.isHovered) ? 34 : 68
                            anchors.right: parent.right
                            anchors.rightMargin: 230
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 14

                            Behavior on anchors.leftMargin {
                                NumberAnimation { duration: 120; easing.type: Easing.OutBack }
                            }

                            // bingkai ikon aplikasi
                            Rectangle {
                                Layout.preferredWidth: 46
                                Layout.preferredHeight: 46
                                color: (rowDelegate.isSelected || rowDelegate.isHovered) ? "#08080A" : "#181822"
                                border.color: "#FFFFFF"
                                border.width: 2
                                rotation: (rowDelegate.isSelected || rowDelegate.isHovered) ? -5 : 0

                                // gambar ikon asli aplikasi desktop
                                Image {
                                    id: realAppIcon
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    source: modelData.appIcon || ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    mipmap: true
                                    visible: modelData.appIcon !== "" && status === Image.Ready
                                }

                                // ikon vektor cadangan jika aplikasi tidak memiliki file ikon
                                P5Icon {
                                    anchors.centerIn: parent
                                    name: modelData.iconName || "app"
                                    color: (rowDelegate.isSelected || rowDelegate.isHovered) ? PhantomState.secondary : PhantomState.primary
                                    size: 24
                                    visible: !realAppIcon.visible
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    color: (rowDelegate.isSelected || rowDelegate.isHovered) ? "#FFFFFF" : "#F0F0F5"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: (rowDelegate.isSelected || rowDelegate.isHovered) ? 19 : 16
                                    font.weight: Font.Black
                                    font.italic: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.desc
                                    color: (rowDelegate.isSelected || rowDelegate.isHovered) ? "#08080A" : "#9E9EAE"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        // teks lencana aksi di sisi kanan baris
                        Item {
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            width: 185
                            height: parent.height

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                P5Icon {
                                    name: (rowDelegate.isSelected || rowDelegate.isHovered) ? "star" : "chevron-right"
                                    color: (rowDelegate.isSelected || rowDelegate.isHovered) ? PhantomState.secondary : PhantomState.primary
                                    size: 13
                                }

                                Text {
                                    text: modelData.badge
                                    color: (rowDelegate.isSelected || rowDelegate.isHovered) ? PhantomState.secondary : "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 16
                                    font.weight: Font.Black
                                    font.italic: true
                                }
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                launcherWin.selectedIndex = index
                                launcherWin.executeItem(index)
                            }
                        }
                    }
                }

                // baris petunjuk navigasi keyboard di bagian bawah
                RowLayout {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 36
                    anchors.bottomMargin: 12
                    spacing: 14
                    z: 20

                    Repeater {
                        model: [
                            { key: "↑/↓", label: "Navigate" },
                            { key: "ENTER", label: "Launch" },
                            { key: "CLICK OK", label: "Close" }
                        ]

                        delegate: RowLayout {
                            spacing: 6
                            Rectangle {
                                width: keyText.implicitWidth + 12
                                height: 22
                                radius: PhantomState.isP3 ? 3 : 0
                                color: PhantomState.isP3 ? Qt.rgba(0/255, 219/255, 255/255, 0.2) : "#FFFFFF"
                                border.color: PhantomState.isP3 ? "#00dbff" : "#08080A"
                                border.width: PhantomState.isP3 ? 1 : 2
                                rotation: PhantomState.isP3 ? 0 : (index % 2 === 0 ? -2 : 2)

                                Text {
                                    id: keyText
                                    anchors.centerIn: parent
                                    text: modelData.key
                                    color: PhantomState.isP3 ? "#00dbff" : "#08080A"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                }
                            }
                            Text {
                                text: modelData.label
                                color: PhantomState.isP3 ? "#8df6ff" : "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 12
                                font.weight: Font.Black
                                font.italic: !PhantomState.isP3
                            }
                        }
                    }
                }

                // tombol stempel penutup launcher di bagian bawah
                Item {
                    id: okStampButton
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: PhantomState.isP3 ? 0 : 80
                    width: 190
                    height: 66
                    rotation: PhantomState.isP3 ? 0 : -6
                    z: 30
                    scale: okMouse.containsMouse ? 1.06 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                    Canvas {
                        anchors.fill: parent
                        visible: !PhantomState.isP3
                        property bool hovered: okMouse.containsMouse
                        property color accent: PhantomState.primary
                        onHoveredChanged: requestPaint()
                        onAccentChanged: requestPaint()
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var w = width
                            var h = height

                            ctx.fillStyle = "#FFFFFF"
                            ctx.beginPath()
                            ctx.moveTo(14, 0)
                            ctx.lineTo(w, 6)
                            ctx.lineTo(w - 16, h)
                            ctx.lineTo(0, h - 6)
                            ctx.closePath()
                            ctx.fill()

                            ctx.fillStyle = hovered ? accent : "#08080A"
                            ctx.beginPath()
                            ctx.moveTo(20, 6)
                            ctx.lineTo(w - 8, 11)
                            ctx.lineTo(w - 22, h - 6)
                            ctx.lineTo(6, h - 11)
                            ctx.closePath()
                            ctx.fill()
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: PhantomState.isP3
                        radius: 4
                        color: okMouse.containsMouse ? "#00dbff" : Qt.rgba(4/255, 13/255, 36/255, 0.95)
                        border.color: "#00dbff"
                        border.width: 1
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        P5Icon {
                            name: "star"
                            color: PhantomState.isP3
                                ? (okMouse.containsMouse ? "#040d24" : "#00dbff")
                                : (okMouse.containsMouse ? "#FFFFFF" : PhantomState.primary)
                            size: 24
                        }

                        Text {
                            text: "OK"
                            color: PhantomState.isP3
                                ? (okMouse.containsMouse ? "#040d24" : "#FFFFFF")
                                : "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 32
                            font.weight: Font.Black
                            font.italic: !PhantomState.isP3
                        }
                    }

                    MouseArea {
                        id: okMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            PhantomState.launcherOpen = false
                        }
                    }
                }
            }

            // =========================================================================
            // KONTAINER APLIKASI LAUNCHER KHUSUS PERSONA 3 RELOAD: S.E.E.S. MAIL MENU
            // Terinspirasi dari UI "MAIL" (Today's New Message) Persona 3 Reload
            // Diposisikan di BOTTOM-LEFT layar sesuai arahan pengguna dan game aslinya
            // =========================================================================
            Item {
                id: p3MailStage
                visible: PhantomState.isP3
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 32
                width: 630
                height: Math.min(parent.height - 70, 710)

                // Animasi buka/tutup halus
                opacity: PhantomState.launcherOpen ? 1.0 : 0.0
                scale: PhantomState.launcherOpen ? 1.0 : 0.94
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }

                // Penahan klik agar tidak menutup launcher saat mengklik di dalam kartu
                MouseArea { anchors.fill: parent }

                // Latar Belakang Kartu Miring P3R (Render via Canvas Anti-Aliased Subpixel)
                Canvas {
                    id: p3CardBgCanvas
                    anchors.fill: parent
                    antialiasing: true
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var h = height

                        // 1. Bayangan Luar Cyan/Navy di Bawah dan Kanan Kartu
                        ctx.beginPath()
                        ctx.moveTo(14, 18)
                        ctx.lineTo(w - 6, 8)
                        ctx.lineTo(w + 2, h - 8)
                        ctx.lineTo(8, h + 2)
                        ctx.closePath()
                        ctx.fillStyle = "rgba(0, 219, 255, 0.28)"
                        ctx.fill()

                        // 2. Badan Kartu Utama Persona 3 Reload (Perspektif Trapesium Mulus)
                        ctx.beginPath()
                        ctx.moveTo(8, 12)
                        ctx.lineTo(w - 12, 4)
                        ctx.lineTo(w - 6, h - 16)
                        ctx.lineTo(2, h - 4)
                        ctx.closePath()
                        ctx.fillStyle = "rgba(5, 11, 28, 0.98)"
                        ctx.fill()

                        // 3. Garis Border Putih Tebal 2.5px Anti-Aliased Mulus Sempurna
                        ctx.lineWidth = 2.5
                        ctx.strokeStyle = "#ffffff"
                        ctx.stroke()
                    }
                }

                // Konten Kartu Utama (Item level horizontal agar teks & garis baris tajam sempurna)
                Item {
                    id: p3MailContent
                    anchors.fill: parent
                    anchors.margins: 12
                    clip: true

                    // Watermark "MAIL" besar di latar belakang atas kartu
                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        text: "MAIL"
                        font.family: "Rubik"
                        font.pixelSize: 96
                        font.weight: Font.Black
                        font.italic: true
                        color: Qt.rgba(1, 1, 1, 0.07)
                        renderType: Text.CurveRendering
                    }

                    // Pita miring biru "TODAY'S New Message" di kanan atas kartu
                    Canvas {
                        id: p3RibbonCanvas
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -4
                        anchors.rightMargin: 10
                        width: 240
                        height: 58
                        antialiasing: true
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            ctx.beginPath()
                            ctx.moveTo(38, 0)
                            ctx.lineTo(width, 0)
                            ctx.lineTo(width, height)
                            ctx.lineTo(0, height)
                            ctx.closePath()
                            ctx.fillStyle = "#0055d4"
                            ctx.fill()
                            ctx.strokeStyle = "#00ffff"
                            ctx.lineWidth = 1.5
                            ctx.stroke()
                        }

                        Column {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: 16
                            spacing: -3

                            Text {
                                text: "TODAY'S"
                                font.family: "Rubik"
                                font.pixelSize: 21
                                font.weight: Font.Black
                                font.italic: true
                                color: "#ffffff"
                                renderType: Text.CurveRendering
                            }
                            Text {
                                text: "New Message"
                                font.family: "Dancing Script"
                                font.pixelSize: 19
                                font.bold: true
                                font.italic: true
                                color: "#8df6ff"
                                renderType: Text.CurveRendering
                            }
                        }
                    }

                    // Kolom Input Pencarian Aplikasi (Di bawah Ribbon)
                    Rectangle {
                        id: p3SearchContainer
                        anchors.top: p3RibbonCanvas.bottom
                        anchors.topMargin: 12
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        height: 44
                        radius: 3
                        color: Qt.rgba(2/255, 7/255, 20/255, 0.94)
                        border.color: p3SearchInput.activeFocus ? "#00ffff" : Qt.rgba(0/255, 219/255, 255/255, 0.35)
                        border.width: 1.5
                        antialiasing: true

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            Text {
                                text: "✉"
                                font.pixelSize: 16
                                color: p3SearchInput.activeFocus ? "#00ffff" : "#00dbff"
                            }

                            TextInput {
                                id: p3SearchInput
                                Layout.fillWidth: true
                                color: "#ffffff"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 13
                                font.weight: Font.Black
                                selectionColor: "#00dbff"
                                selectedTextColor: "#000000"
                                clip: true

                                onTextChanged: {
                                    launcherWin.query = text
                                    launcherWin.selectedIndex = 0
                                }

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Escape) {
                                        PhantomState.launcherOpen = false
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                                        if (launcherWin.filteredItems.length > 0) {
                                            launcherWin.selectedIndex = (launcherWin.selectedIndex + 1) % launcherWin.filteredItems.length
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Up) {
                                        if (launcherWin.filteredItems.length > 0) {
                                            launcherWin.selectedIndex = (launcherWin.selectedIndex - 1 + launcherWin.filteredItems.length) % launcherWin.filteredItems.length
                                        }
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        launcherWin.executeItem(launcherWin.selectedIndex)
                                        event.accepted = true
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Search dispatch or >settings, >theme..."
                                    color: "#5b78a2"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    visible: p3SearchInput.text.length === 0
                                }
                            }
                        }
                    }

                    // Daftar Aplikasi (Sesuai Gaya Kartu Pesan Masuk P3R)
                    ListView {
                        id: p3AppList
                        anchors.top: p3SearchContainer.bottom
                        anchors.topMargin: 10
                        anchors.bottom: p3BottomPrompts.top
                        anchors.bottomMargin: 10
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        clip: true
                        spacing: 4
                        model: launcherWin.filteredItems
                        currentIndex: launcherWin.selectedIndex

                        onCurrentIndexChanged: {
                            positionViewAtIndex(currentIndex, ListView.Contain)
                        }

                        delegate: Item {
                            id: p3RowDelegate
                            width: p3AppList.width
                            height: 58
                            readonly property bool isSelected: index === launcherWin.selectedIndex
                            readonly property bool isHovered: p3RowMouse.containsMouse

                            // Sentuhan taktil Persona 3: kartu aktif sedikit bergeser ke kanan
                            x: isSelected ? 6 : (isHovered ? 3 : 0)
                            Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                            // Warna duotone avatar bergaya P3
                            readonly property var duotoneColors: ["#0088cc", "#c2185b", "#d32f2f", "#e65100", "#2e7d32", "#1565c0"]
                            readonly property color avatarBg: duotoneColors[index % duotoneColors.length]

                            // Latar Belakang Kartu:
                            // Saat SELECTED: Putih solid bersih dengan border biru royal (seperti Mitsuru Kirijo)
                            // Saat UNSELECTED: Transparan bersih tanpa border kotak kaku, menghilangkan kesan bergerigi/crowded
                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: p3RowDelegate.isSelected ? "#ffffff" : (p3RowDelegate.isHovered ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(8/255, 18/255, 42/255, 0.65))
                                border.color: p3RowDelegate.isSelected ? "#0038a8" : "transparent"
                                border.width: p3RowDelegate.isSelected ? 2.5 : 0
                                antialiasing: true

                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            // Garis pemisah halus antar baris pesan tidak aktif
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                height: 1
                                color: Qt.rgba(255, 255, 255, 0.05)
                                visible: !p3RowDelegate.isSelected
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 14
                                spacing: 12

                                // 1. Tanda Seru Biru "!" (Sesuai Screenshot Game P3R)
                                Rectangle {
                                    Layout.preferredWidth: 22
                                    Layout.preferredHeight: 22
                                    radius: 11
                                    color: "#00dbff"
                                    antialiasing: true

                                    Text {
                                        anchors.centerIn: parent
                                        text: "!"
                                        font.family: "Rubik"
                                        font.pixelSize: 13
                                        font.weight: Font.Black
                                        color: "#030e28"
                                    }
                                }

                                // 2. Bingkai Avatar / Ikon Aplikasi
                                Rectangle {
                                    Layout.preferredWidth: 40
                                    Layout.preferredHeight: 40
                                    radius: 4
                                    // Saat selected, berikan kontras merah cerah khas Mitsuru atau biru kobalt
                                    color: p3RowDelegate.isSelected ? (index % 2 === 0 ? "#e60039" : "#0055d4") : p3RowDelegate.avatarBg
                                    antialiasing: true
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        source: modelData.appIcon || ""
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        mipmap: true
                                        visible: modelData.appIcon !== "" && status === Image.Ready
                                    }

                                    P5Icon {
                                        anchors.centerIn: parent
                                        name: modelData.iconName || "app"
                                        color: "#ffffff"
                                        size: 22
                                        visible: !modelData.appIcon || modelData.appIcon === ""
                                    }
                                }

                                // 3. Nama Aplikasi & Deskripsi (Format Pesan Masuk P3R)
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    RowLayout {
                                        spacing: 6
                                        Text {
                                            text: "✉"
                                            font.pixelSize: 14
                                            color: p3RowDelegate.isSelected ? "#004bbd" : "#00dbff"
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: p3RowDelegate.isSelected ? "#041238" : "#ffffff"
                                            font.family: "Rubik"
                                            font.pixelSize: 15
                                            font.weight: Font.Black
                                            elide: Text.ElideRight
                                            renderType: Text.CurveRendering
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.desc
                                        color: p3RowDelegate.isSelected ? "#2b4674" : "#7fa2cc"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.bold: true
                                        elide: Text.ElideRight
                                        renderType: Text.CurveRendering
                                    }
                                }

                                // 4. Status Aksi di Kanan:
                                // Bersih dan rapi; tombol OPEN hanya muncul saat kartu terpilih (Selected),
                                // menghilangkan deretan tombol kaku bergerigi yang mengotori tampilan
                                Rectangle {
                                    visible: p3RowDelegate.isSelected
                                    Layout.preferredWidth: 68
                                    Layout.preferredHeight: 22
                                    radius: 3
                                    color: "#0038a8"
                                    antialiasing: true

                                    Text {
                                        anchors.centerIn: parent
                                        text: "OPEN ↵"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        font.bold: true
                                        color: "#ffffff"
                                    }
                                }

                                Text {
                                    visible: !p3RowDelegate.isSelected
                                    text: "NEW"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: Qt.rgba(0/255, 219/255, 255/255, 0.45)
                                    Layout.rightMargin: 4
                                }
                            }

                            MouseArea {
                                id: p3RowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: {
                                    if (launcherWin.selectedIndex !== index) PhantomState.playSfx("select")
                                    launcherWin.selectedIndex = index
                                }
                                onClicked: {
                                    launcherWin.selectedIndex = index
                                    launcherWin.executeItem(index)
                                }
                            }
                        }
                    }

                    // Petunjuk Navigasi Tombol di Bagian Bawah
                    RowLayout {
                        id: p3BottomPrompts
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.bottomMargin: 14
                        spacing: 18

                        Item {
                            implicitWidth: aRow.implicitWidth
                            implicitHeight: aRow.implicitHeight

                            RowLayout {
                                id: aRow
                                anchors.fill: parent
                                spacing: 6
                                Rectangle {
                                    width: 22; height: 22; radius: 11
                                    color: "#00dbff"
                                    antialiasing: true
                                    Text {
                                        anchors.centerIn: parent
                                        text: "A"
                                        font.family: "Rubik"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#030e28"
                                    }
                                }
                                Text {
                                    text: "Launch"
                                    color: "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: launcherWin.executeItem(launcherWin.selectedIndex)
                            }
                        }

                        Item {
                            implicitWidth: bRow.implicitWidth
                            implicitHeight: bRow.implicitHeight

                            RowLayout {
                                id: bRow
                                anchors.fill: parent
                                spacing: 6
                                Rectangle {
                                    width: 22; height: 22; radius: 11
                                    color: "#ff3366"
                                    antialiasing: true
                                    Text {
                                        anchors.centerIn: parent
                                        text: "B"
                                        font.family: "Rubik"
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#ffffff"
                                    }
                                }
                                Text {
                                    text: "Close"
                                    color: "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.launcherOpen = false
                            }
                        }

                        RowLayout {
                            spacing: 6
                            Text {
                                text: "↑/↓"
                                color: "#00dbff"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 13
                                font.bold: true
                            }
                            Text {
                                text: "Select"
                                color: "#8df6ff"
                                font.family: "Rubik"
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
