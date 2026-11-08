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
            // Dynamic Tabs: "APPS" (S.E.E.S. System Apps) & "MAIL" (TODAY'S New Message)
            // Overlay Mail Detail Reader (Membaca pesan panjang secara utuh ala P3R)
            // =========================================================================
            Item {
                id: p3MailStage
                visible: PhantomState.isP3
                anchors.left: parent.left
                anchors.leftMargin: 56
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 38
                width: 590
                height: Math.min(parent.height - 70, 700)

                // State Tab Aktif: "apps" (Launcher Aplikasi) atau "mail" (Riwayat Notifikasi)
                readonly property string activeTab: PhantomState.p3LauncherTab
                property int selectedNotifIndex: 0

                // State Overlay Mail Reader untuk Membaca Pesan Notifikasi Lengkap
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

                // Rotasi miring otentik Persona 3 Reload (-5.5 derajat) dengan layer multisample antialiasing
                transformOrigin: Item.BottomLeft
                rotation: -5.5
                layer.enabled: true
                layer.smooth: true
                layer.samples: 4

                // Animasi buka/tutup taktil halus
                opacity: PhantomState.launcherOpen ? 1.0 : 0.0
                scale: PhantomState.launcherOpen ? 1.0 : 0.94
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }

                // Penahan klik agar tidak tembus ke background
                MouseArea { anchors.fill: parent }

                // ---------------------------------------------------------------------
                // Latar Belakang Kartu P3R & Pelat Bayangan 3D Hitam Tebal (Canvas 2D)
                // ---------------------------------------------------------------------
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

                        // 1. Pelat Ekstrusi 3D Hitam Solid (Offset +12px kanan, +10px bawah)
                        drawRoundRect(ctx, pad + 12, pad + 10, w, h, r);
                        ctx.fillStyle = "#070b14";
                        ctx.fill();

                        // 2. Badan Kartu Utama Slate Gelap P3R (#131926)
                        drawRoundRect(ctx, pad, pad, w, h, r);
                        ctx.fillStyle = "#131926";
                        ctx.fill();

                        // 3. Garis Tepi Putih Bersih Tebal Otentik 3.5px
                        ctx.lineWidth = 3.5;
                        ctx.strokeStyle = "#ffffff";
                        ctx.stroke();
                    }
                }

                // ---------------------------------------------------------------------
                // Konten Kartu Utama (Watermark, Ribbon, Tab Switcher, Search, Daftar)
                // ---------------------------------------------------------------------
                Item {
                    id: p3CardArea
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true

                    // 1. Dynamic Watermark Kiri Atas: "APPS" saat Launcher, "MAIL" saat Notifikasi
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

                    // 2. Dynamic Ribbon Kanan Atas: "S.E.E.S. System Apps" vs "TODAY'S New Message"
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

                            // Bayangan gelap di bawah pita miring (3D fold)
                            ctx.beginPath();
                            ctx.moveTo(34, 4);
                            ctx.lineTo(w, 4);
                            ctx.lineTo(w, h + 8);
                            ctx.lineTo(26, h + 8);
                            ctx.closePath();
                            ctx.fillStyle = "#061332";
                            ctx.fill();

                            // Pita Biru Kobalt Utama
                            ctx.beginPath();
                            ctx.moveTo(42, 0);
                            ctx.lineTo(w, 0);
                            ctx.lineTo(w, h);
                            ctx.lineTo(0, h);
                            ctx.closePath();
                            ctx.fillStyle = "#0052cc";
                            ctx.fill();

                            // Garis outline cyan halus
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

                    // 3. Tab Switcher: [ APPS ] & [ MAIL (Count) ] + [Clear All]
                    Row {
                        id: p3TabRow
                        anchors.top: p3RibbonCanvas.bottom
                        anchors.topMargin: 4
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        spacing: 8

                        // Tombol Tab APPS
                        Rectangle {
                            width: 86
                            height: 26
                            radius: 3
                            color: p3MailStage.activeTab === "apps" ? "#0038a8" : "transparent"
                            border.color: p3MailStage.activeTab === "apps" ? "#00d0ff" : "#2EFFFFFF"
                            border.width: 1.5

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    text: "⊞"
                                    font.pixelSize: 11
                                    color: p3MailStage.activeTab === "apps" ? "#ffffff" : "#6f8cb0"
                                }
                                Text {
                                    text: "APPS"
                                    font.family: "Rubik"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                    color: p3MailStage.activeTab === "apps" ? "#ffffff" : "#6f8cb0"
                                }
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

                        // Tombol Tab MAIL
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
                                    text: "✉"
                                    font.pixelSize: 11
                                    color: p3MailStage.activeTab === "mail" ? "#ffffff" : "#6f8cb0"
                                }
                                Text {
                                    text: "MAIL"
                                    font.family: "Rubik"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                    color: p3MailStage.activeTab === "mail" ? "#ffffff" : "#6f8cb0"
                                }
                                // Badge Notifikasi Baru
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

                        // Tombol Clear All (Hanya di mode MAIL jika ada pesan)
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

                        // Petunjuk Tombol Tab
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "[Tab] switch"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.bold: true
                            color: "#4e6a91"
                        }
                    }

                    // 4. Baris Input Pencarian Aplikasi / Notifikasi
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
                                text: p3MailStage.activeTab === "apps" ? "⊞" : "✉"
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
                                                // Buka Overlay Mail Detail Reader
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

                    // 5. Pesan Kosong Jika Tidak Ada Notifikasi
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
                                text: "✉"
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

                    // 6. Daftar Aplikasi / Notifikasi (ListView Bersih)
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
                            readonly property bool isApps: p3MailStage.activeTab === "apps"
                            readonly property bool isSelected: isApps ? (index === launcherWin.selectedIndex) : (index === p3MailStage.selectedNotifIndex)
                            readonly property bool isHovered: p3RowMouse.containsMouse

                            width: p3AppList.width - (isSelected ? 0 : 8)
                            height: 54

                            // Data Helper tergantung tab (Safe untuk JS Array & ListModel)
                            readonly property string itemName: isApps ? (modelData ? (modelData.name || "") : "") : (typeof senderName !== "undefined" ? senderName : (typeof sender !== "undefined" ? sender : (typeof model !== "undefined" && model ? (model.senderName || model.sender || "") : "")))
                            readonly property string itemDesc: isApps ? (modelData ? (modelData.desc || "") : "") : (typeof msgBody !== "undefined" ? msgBody : (typeof message !== "undefined" ? message : (typeof model !== "undefined" && model ? (model.msgBody || model.message || "") : "")))
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

                            // Pergeseran taktil: baris aktif sedikit melompat ke kanan
                            x: isSelected ? 8 : (isHovered ? 4 : 0)
                            Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

                            // Palet warna karakter Persona 3 Reload untuk avatar tidak aktif
                            readonly property var duotoneColors: ["#0099cc", "#9c27b0", "#1565c0", "#e65100", "#2e7d32", "#00838f"]
                            readonly property color avatarColor: isSelected ? "#e60039" : ((typeof index === "number" && index >= 0) ? duotoneColors[index % duotoneColors.length] : "#0099cc")

                            // A. Ikon Lingkaran Biru Tanda Seru "!" di Sebelah Kiri Baris
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

                            // B. Avatar Karakter dengan Potongan Diagonal Slash 25 Derajat
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

                                // Ikon Aplikasi / Notifikasi di dalam Avatar Slashed
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

                                // Fallback Avatar Karakter / Monogram Persona 3 Reload saat ikon tidak tersedia
                                Item {
                                    anchors.fill: parent
                                    visible: !avatarImg.visible

                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            const n = (p3RowDelegate.itemName || "").trim()
                                            return n.length > 0 ? n.charAt(0).toUpperCase() : "✉"
                                        }
                                        font.family: "Rubik"
                                        font.pixelSize: 20
                                        font.weight: Font.Black
                                        color: "#ffffff"
                                    }
                                }
                            }

                            // C. Kartu Pesan (Menyambung presisi dengan sudut diagonal slash avatar)
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
                                            // --- KARTU MITSURU KIRIJO: PUTIH SOLID DENGAN BORDER BIRU ROYAL ---
                                            ctx.beginPath();
                                            ctx.moveTo(18, 0);
                                            ctx.lineTo(w, 0);
                                            ctx.lineTo(w, h);
                                            ctx.lineTo(0, h);
                                            ctx.closePath();
                                            ctx.fillStyle = "#ffffff";
                                            ctx.fill();

                                            // Border Biru Royal Tebal 2.5px
                                            ctx.lineWidth = 2.5;
                                            ctx.strokeStyle = "#0038a8";
                                            ctx.stroke();

                                            // Aksen Garis Cyan Elektrik di Tepi Bawah Kartu
                                            ctx.beginPath();
                                            ctx.moveTo(0, h);
                                            ctx.lineTo(w, h);
                                            ctx.lineWidth = 2.5;
                                            ctx.strokeStyle = "#0099ff";
                                            ctx.stroke();
                                        } else {
                                            // --- KARTU TIDAK TERPILIH: SLATE GELAP BERSIH ---
                                            ctx.beginPath();
                                            ctx.moveTo(18, 0);
                                            ctx.lineTo(w, 0);
                                            ctx.lineTo(w, h);
                                            ctx.lineTo(0, h);
                                            ctx.closePath();
                                            ctx.fillStyle = p3RowDelegate.isHovered ? "#2a3750" : "#1e293c";
                                            ctx.fill();

                                            // Garis Pemisah Halus di Bawah
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

                                // Konten Teks Nama Aplikasi / Pengirim & Deskripsi
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
                                            text: "✉"
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
                                                    text: p3RowDelegate.itemName
                                                    color: p3RowDelegate.isSelected ? "#0038a8" : "#ffffff"
                                                    font.family: "Rubik"
                                                    font.pixelSize: 14
                                                    font.weight: p3RowDelegate.isSelected ? Font.Black : Font.Bold
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

                                            // Garis bawah biru otentik di bawah nama kontak terpilih
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
                                        text: p3RowDelegate.itemDesc
                                        color: p3RowDelegate.isSelected ? "#060f22" : "#9fb4cc"
                                        font.family: "Rubik"
                                        font.pixelSize: 11
                                        font.bold: true
                                        elide: Text.ElideRight
                                        renderType: Text.CurveRendering
                                    }
                                }
                            }

                            // D. Area Interaksi Klik dan Hover
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
                                        // Buka Overlay Mail Detail Reader
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

                    // -----------------------------------------------------------------
                    // 7. Overlay Mail Detail Reader (P3R In-Game Authentic Message Card)
                    // -----------------------------------------------------------------
                    Item {
                        id: p3MailReaderModal
                        anchors.fill: parent
                        anchors.margins: -4
                        z: 50
                        opacity: p3MailStage.activeDetailNotif !== null ? 1.0 : 0.0
                        visible: opacity > 0.0
                        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                        // Latar Belakang Redup Gelap Mencegah Klik ke Bawah
                        Rectangle {
                            anchors.fill: parent
                            color: "#F5080C16"
                            radius: 4
                            MouseArea { anchors.fill: parent } // block clicks
                        }

                        // Badan Kartu Pembaca Pesan P3R
                        Item {
                            anchors.fill: parent
                            anchors.margins: 14

                            // Pita Header "MESSAGE DETAIL // INBOX"
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
                                        text: "✉ MESSAGE DETAIL"
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

                            // Header Profil Pengirim
                            RowLayout {
                                id: readerSenderRow
                                anchors.top: readerRibbon.bottom
                                anchors.topMargin: 14
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 12

                                // Slashed Avatar Pengirim
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
                                                return s.length > 0 ? s.charAt(0).toUpperCase() : "✉"
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

                            // Garis Pemisah
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

                            // Area Isi Pesan Lengkap (Scrollable Flickable)
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

                            // Baris Tombol Aksi di Bagian Bawah Reader
                            RowLayout {
                                id: readerActionsRow
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 12

                                // Tombol Hapus Pesan (DISMISS)
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

                                // Tombol Tutup (CLOSE / BACK)
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
