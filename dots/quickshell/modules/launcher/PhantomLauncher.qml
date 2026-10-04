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
        WlrLayershell.keyboardFocus: PhantomState.launcherOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
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
                item.entryObj.execute()
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

        onVisibleChanged: {
            if (visible && PhantomState.launcherOpen) {
                query = ""
                selectedIndex = 0
                searchInput.text = ""
                searchInput.forceActiveFocus()
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

            // kontainer utama aplikasi launcher di tengah layar
            Item {
                id: launcherStage
                width: Math.min(parent.width - 80, 900)
                height: Math.min(parent.height - 80, 680)
                anchors.centerIn: parent

                // penahan klik di dalam area launcher
                MouseArea { anchors.fill: parent }

                // latar kartu miring launcher beserta aksen sudut
                Canvas {
                    anchors.fill: parent
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

                    // lencana judul miring launcher
                    Item {
                        Layout.preferredWidth: 270
                        Layout.preferredHeight: 62
                        rotation: -2.5

                        Canvas {
                            anchors.fill: parent
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
                                    text: "PHANTOM LAUNCH"
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 18
                                    font.weight: Font.Black
                                    font.italic: true
                                }
                                Text {
                                    text: launcherWin.filteredItems.length + " APPS & COMMANDS"
                                    color: PhantomState.secondary
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

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 22
                            anchors.rightMargin: 24
                            anchors.bottomMargin: 6
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
                                font.italic: true
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
                                    text: "Search installed apps or type >theme, >settings..."
                                    color: "#777777"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    font.italic: true
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

                        Canvas {
                            id: rowCanvas
                            anchors.fill: parent
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
                                color: "#FFFFFF"
                                border.color: "#08080A"
                                border.width: 2
                                rotation: index % 2 === 0 ? -2 : 2
                                Text {
                                    id: keyText
                                    anchors.centerIn: parent
                                    text: modelData.key
                                    color: "#08080A"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                }
                            }
                            Text {
                                text: modelData.label
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 12
                                font.weight: Font.Black
                                font.italic: true
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
                    anchors.horizontalCenterOffset: 80
                    width: 190
                    height: 66
                    rotation: -6
                    z: 30
                    scale: okMouse.containsMouse ? 1.06 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                    Canvas {
                        anchors.fill: parent
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

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        P5Icon {
                            name: "star"
                            color: okMouse.containsMouse ? "#FFFFFF" : PhantomState.primary
                            size: 24
                        }

                        Text {
                            text: "OK"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 32
                            font.weight: Font.Black
                            font.italic: true
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
        }
    }
}
