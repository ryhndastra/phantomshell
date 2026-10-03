import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

Scope {
    id: barScope

    property string monthStr: "10"
    property string dayStr: "03"
    property string dowStr: "SAT"
    property string timeStr: "22:25"
    property string periodStr: "EVENING"

    readonly property var romanMap: ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]
    readonly property var kanjiMap: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"]

    function formatWsLabel(num) {
        if (PhantomState.workspaceNumStyle === "roman") return romanMap[num - 1] || String(num)
        if (PhantomState.workspaceNumStyle === "kanji") return kanjiMap[num - 1] || String(num)
        return String(num)
    }

    function updateClock() {
        const now = new Date()
        monthStr = Qt.formatDateTime(now, "MM")
        dayStr = Qt.formatDateTime(now, "dd")
        dowStr = Qt.formatDateTime(now, "ddd").toUpperCase()
        timeStr = Qt.formatDateTime(now, "hh:mm")
        const hr = now.getHours()
        if (hr < 6) periodStr = "DARK HOUR"
        else if (hr < 12) periodStr = "MORNING"
        else if (hr < 15) periodStr = "LUNCHTIME"
        else if (hr < 18) periodStr = "AFTER SCHOOL"
        else periodStr = "EVENING"
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: barScope.updateClock()
    }

    // waybar utama atas/bawah
    // ubah exclusiveZone & implicitHeight di bawah kalau mau gedein/kecilin tinggi bar
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWin
            required property ShellScreen modelData
            screen: modelData

            readonly property bool isBottom: PhantomState.barPosition === "bottom"
            readonly property string activeTitle: Hyprland.activeToplevel?.title || "METAVERSE // PHANTOM DESKTOP"

            WlrLayershell.namespace: "phantomshell-bar"
            WlrLayershell.layer: WlrLayer.Top
            exclusiveZone: 38
            implicitHeight: 38
            color: "transparent"

            anchors {
                top: !barWin.isBottom
                bottom: barWin.isBottom
                left: true
                right: true
            }

            // background solid opsional (aktif kalau opsi bar background atau style hug dipilih)
            Rectangle {
                anchors.fill: parent
                visible: PhantomState.barShowBackground || PhantomState.barStyle === "hug"
                color: PhantomState.background
                opacity: 0.92

                Rectangle {
                    x: 0
                    y: barWin.isBottom ? 0 : (parent.height - 2)
                    width: parent.width
                    height: 2
                    color: PhantomState.primary
                }
            }

            // bagian kiri bar: logo, tanggal/jam, workspace, dan tombol utility
            // ubah spacing atau urutan item di dalam Row ini buat custom isi bar kiri
            Row {
                id: leftRow
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // tombol logo phantomshell (klik kiri buka launcher, klik kanan buka settings)
                Item {
                    width: 42
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.launcherOpen ? PhantomState.primary : (logoMouse.containsMouse ? PhantomState.surfaceAlt : PhantomState.surface)
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.launcherOpen ? PhantomState.secondary : PhantomState.primary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 6 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        source: PhantomState.logoPath
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        scale: logoMouse.containsMouse ? 1.12 : 1.0
                        Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }
                    }

                    MouseArea {
                        id: logoMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                PhantomState.toggleSettings()
                            } else {
                                PhantomState.toggleLauncher()
                            }
                        }
                    }
                }

                // pill tanggal & waktu ala persona 5 (klik buat buka popup kalender)
                Item {
                    visible: PhantomState.showWeatherHud
                    width: hudRow.implicitWidth + 24
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.calendarOpen ? PhantomState.primary : (hudMouse.containsMouse ? PhantomState.surfaceAlt : PhantomState.surface)
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.calendarOpen ? PhantomState.secondary : PhantomState.primary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 6 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    Row {
                        id: hudRow
                        anchors.centerIn: parent
                        spacing: 7

                        P5Star {
                            width: 18
                            height: 18
                            anchors.verticalCenter: parent.verticalCenter
                            spinning: PhantomState.calendarOpen
                        }

                        Text {
                            text: barScope.monthStr + "/" + barScope.dayStr
                            color: PhantomState.foreground
                            font.pixelSize: 14
                            font.weight: Font.Black
                            font.italic: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: dowLabel.implicitWidth + 10
                            height: 16
                            color: PhantomState.calendarOpen ? PhantomState.background : PhantomState.primary
                            border.color: PhantomState.borderLight
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: dowLabel
                                anchors.centerIn: parent
                                text: barScope.dowStr
                                color: PhantomState.foreground
                                font.pixelSize: 9
                                font.weight: Font.Black
                            }
                        }

                        Text {
                            text: barScope.timeStr + " • " + barScope.periodStr
                            color: PhantomState.calendarOpen ? PhantomState.foreground : PhantomState.secondary
                            font.pixelSize: 10
                            font.weight: Font.Black
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: hudMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PhantomState.calendarOpen = !PhantomState.calendarOpen
                    }
                }

                // daftar nomor workspace
                // jumlah & format angka (1/I/kanji) bisa diatur lewat menu settings -> tab 2. bar
                Item {
                    visible: PhantomState.showWorkspaces
                    width: wsRow.implicitWidth + 18
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.surface
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.borderDark
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 6 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    Row {
                        id: wsRow
                        anchors.centerIn: parent
                        spacing: 3

                        Repeater {
                            model: PhantomState.workspaceCount
                            delegate: Item {
                                required property int index
                                readonly property int wsId: index + 1
                                readonly property bool isActive: (Hyprland.focusedWorkspace?.id ?? 1) === wsId

                                width: isActive ? 30 : 22
                                height: 22

                                Behavior on width {
                                    NumberAnimation { duration: 160; easing.type: Easing.OutBack }
                                }

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: parent.isActive ? PhantomState.primary : "transparent"
                                    borderColor: parent.isActive ? PhantomState.borderLight : "transparent"
                                    showShadowOffset: false
                                    borderWidth: parent.isActive ? 1 : 0
                                    skewPx: PhantomState.polygonMode ? 4 : 0
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: barScope.formatWsLabel(parent.wsId)
                                    color: parent.isActive ? PhantomState.foreground : PhantomState.muted
                                    font.pixelSize: parent.isActive ? 11 : 10
                                    font.weight: Font.Black
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "workspace", String(parent.wsId)])
                                }
                            }
                        }
                    }
                }

                // deretan tombol utility cepat (screenshot, color picker, mute mic, dark mode)
                // ganti command di onClicked masing-masing tombol kalau mau pakai tool lain
                Item {
                    visible: PhantomState.showUtilButtons && (PhantomState.showUtilSnip || PhantomState.showUtilPicker || PhantomState.showUtilMic || PhantomState.showUtilDark)
                    width: utilRow.implicitWidth + 18
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.surface
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.primary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 5 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    Row {
                        id: utilRow
                        anchors.centerIn: parent
                        spacing: 6

                        // tombol screenshot area
                        Item {
                            visible: PhantomState.showUtilSnip
                            width: 22; height: 22
                            P5Icon { anchors.centerIn: parent; name: "frame"; size: 11; color: PhantomState.foreground }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["sh", "-c", "grim -g \"$(slurp)\" - | swappy -f - 2>/dev/null || hyprshot -m region 2>/dev/null || true"])
                            }
                        }

                        // tombol color picker
                        Item {
                            visible: PhantomState.showUtilPicker
                            width: 22; height: 22
                            P5Icon { anchors.centerIn: parent; name: "palette"; size: 11; color: PhantomState.secondary }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["sh", "-c", "hyprpicker -a 2>/dev/null || true"])
                            }
                        }

                        // tombol toggle mute mic
                        Item {
                            visible: PhantomState.showUtilMic
                            width: 22; height: 22
                            P5Icon { anchors.centerIn: parent; name: "volume"; size: 11; color: PhantomState.foreground }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"])
                            }
                        }

                        // tombol ganti dark/light mode
                        Item {
                            visible: PhantomState.showUtilDark
                            width: 22; height: 22
                            P5Icon { anchors.centerIn: parent; name: PhantomState.darkMode ? "moon" : "sun"; size: 11; color: PhantomState.secondary }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.setDarkMode(!PhantomState.darkMode)
                            }
                        }
                    }
                }
            }

            // bagian tengah bar: dynamic island judul aplikasi aktif & tombol buka launcher
            // ubah Math.min(310, ...) di width kalau mau kotak judul tengah lebih lebar
            Item {
                id: dynamicIsland
                visible: PhantomState.showDynamicIsland
                anchors.centerIn: parent
                width: Math.min(310, Math.max(200, barWin.width - leftRow.width - rightRow.width - 48))
                height: 30

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: PhantomState.launcherOpen ? PhantomState.primary : PhantomState.surface
                    borderColor: PhantomState.borderLight
                    shadowColor: PhantomState.launcherOpen ? PhantomState.secondary : PhantomState.primary
                    borderWidth: 2
                    skewPx: PhantomState.polygonMode ? 6 : 0
                    shadowOffsetX: 2
                    shadowOffsetY: 2
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 18
                        color: PhantomState.launcherOpen ? PhantomState.background : PhantomState.primary
                        border.color: PhantomState.borderLight
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "SUPER"
                            color: PhantomState.foreground
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: barWin.activeTitle
                        color: PhantomState.foreground
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    P5Icon {
                        name: "search"
                        size: 12
                        color: PhantomState.secondary
                    }
                }

                MouseArea {
                    id: islandMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PhantomState.launcherOpen = !PhantomState.launcherOpen
                }
            }

            // bagian kanan bar: tema, notifikasi im, radar stats, settings, dan power
            // ubah spacing di bawah buat atur jarak antar tombol kanan
            Row {
                id: rightRow
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // tombol ganti cepat preset warna (p5 red / p3 blue / p4 gold)
                Item {
                    visible: PhantomState.showThemePill
                    width: themePillRow.implicitWidth + 24
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.primary
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.borderDark
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 5 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    Row {
                        id: themePillRow
                        anchors.centerIn: parent
                        spacing: 6

                        P5Icon {
                            name: PhantomState.themeId === "p5-crimson" ? "phantom" : (PhantomState.themeId === "p3-reload" ? "moon" : "tv")
                            size: 12
                            color: PhantomState.foreground
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: PhantomState.themeId === "p5-crimson" ? "P5 RED" : (PhantomState.themeId === "p3-reload" ? "P3 BLUE" : (PhantomState.themeId === "p4-golden" ? "P4 GOLD" : PhantomState.themeId.toUpperCase()))
                            color: PhantomState.foreground
                            font.pixelSize: 10
                            font.weight: Font.Black
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (PhantomState.themeId === "p5-crimson") PhantomState.applyPreset("p3-reload")
                            else if (PhantomState.themeId === "p3-reload") PhantomState.applyPreset("p4-golden")
                            else PhantomState.applyPreset("p5-crimson")
                        }
                    }
                }

                // tombol buka riwayat chat notifikasi sns
                Item {
                    visible: PhantomState.showImPill
                    width: imPillRow.implicitWidth + 22
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.notificationsOpen ? PhantomState.primary : PhantomState.surface
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.secondary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 5 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    Row {
                        id: imPillRow
                        anchors.centerIn: parent
                        spacing: 5

                        P5Icon {
                            name: "message"
                            size: 12
                            color: PhantomState.secondary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "IM"
                            color: PhantomState.foreground
                            font.pixelSize: 10
                            font.weight: Font.Black
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            visible: PhantomState.showUnreadCount
                            width: imCountText.implicitWidth + 10
                            height: 16
                            color: PhantomState.primary
                            border.color: PhantomState.borderLight
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: imCountText
                                anchors.centerIn: parent
                                text: PhantomState.imNotifications.count
                                color: PhantomState.foreground
                                font.pixelSize: 9
                                font.weight: Font.Black
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            PhantomState.dashboardOpen = false
                            PhantomState.notificationsOpen = !PhantomState.notificationsOpen
                        }
                    }
                }

                // tombol buka control center & pentagon star radar
                Item {
                    visible: PhantomState.showStatsPill
                    width: statsPillRow.implicitWidth + 24
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.dashboardOpen ? PhantomState.primary : PhantomState.surface
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.primary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 5 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    Row {
                        id: statsPillRow
                        anchors.centerIn: parent
                        spacing: 5

                        P5Icon {
                            name: "star"
                            size: 11
                            color: PhantomState.secondary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "STATS " + Math.round(PhantomState.cpuPct) + "%"
                            color: PhantomState.foreground
                            font.pixelSize: 10
                            font.weight: Font.Black
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            PhantomState.notificationsOpen = false
                            PhantomState.dashboardOpen = !PhantomState.dashboardOpen
                        }
                    }
                }

                // tombol buka menu pengaturan (settings)
                Item {
                    width: 36
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.settingsOpen ? PhantomState.secondary : PhantomState.surface
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.primary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 4 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    P5Icon {
                        anchors.centerIn: parent
                        name: "settings"
                        size: 13
                        color: PhantomState.settingsOpen ? PhantomState.background : PhantomState.foreground
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PhantomState.settingsOpen = !PhantomState.settingsOpen
                    }
                }

                // tombol buka menu power & lock screen
                Item {
                    width: 36
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.sessionOpen ? PhantomState.urgent : PhantomState.surfaceAlt
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.primary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 4 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    P5Icon {
                        anchors.centerIn: parent
                        name: "power"
                        size: 13
                        color: PhantomState.foreground
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PhantomState.sessionOpen = !PhantomState.sessionOpen
                    }
                }
            }
        }
    }

    // popup kalender & jadwal (muncul pas pill tanggal di kiri atas diklik)
    // ubah implicitWidth & implicitHeight di bawah buat atur ukuran popup kalender
    PanelWindow {
        id: calPopupWin
        visible: PhantomState.calendarOpen

        readonly property bool isBottom: PhantomState.barPosition === "bottom"

        WlrLayershell.namespace: "phantomshell-calendar"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            top: !calPopupWin.isBottom
            bottom: calPopupWin.isBottom
            left: true
        }
        margins {
            top: 42
            bottom: 42
            left: 8
        }

        implicitWidth: 340
        implicitHeight: 180
        color: "transparent"

        onVisibleChanged: {
            if (visible) calEntryAnim.restart()
        }

        Item {
            id: calCard
            anchors.fill: parent
            transformOrigin: calPopupWin.isBottom ? Item.BottomLeft : Item.TopLeft

            ParallelAnimation {
                id: calEntryAnim
                NumberAnimation {
                    target: calCard
                    property: "scale"
                    from: 0.84
                    to: 1.0
                    duration: 220
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.35
                }
                NumberAnimation {
                    target: calCard
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            P5SkewedCard {
                anchors.fill: parent
                fillColor: PhantomState.background
                borderColor: PhantomState.borderLight
                shadowColor: PhantomState.primary
                borderWidth: 2
                skewPx: PhantomState.polygonMode ? 8 : 0
                shadowOffsetX: 4
                shadowOffsetY: 4
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    P5Icon {
                        name: "sun"
                        size: 14
                        color: PhantomState.secondary
                    }

                    Text {
                        text: "METAVERSE LOG // " + barScope.monthStr + "/" + barScope.dayStr + " (" + barScope.dowStr + ")"
                        color: PhantomState.primary
                        font.pixelSize: 13
                        font.weight: Font.Black
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        width: 22
                        height: 22
                        color: PhantomState.surfaceAlt
                        border.color: PhantomState.borderLight
                        border.width: 1
                        P5Icon { anchors.centerIn: parent; name: "close"; size: 10 }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.calendarOpen = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    color: PhantomState.borderLight
                }

                Text {
                    text: "TIME PERIOD : " + barScope.periodStr + " (" + barScope.timeStr + ")"
                    color: PhantomState.foreground
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Text {
                    text: "WEATHER     : CLEAR SKIES • 27°C"
                    color: PhantomState.secondary
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Text {
                    text: "ACTIVE THEME: " + PhantomState.themeName.toUpperCase()
                    color: PhantomState.foreground
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Text {
                    text: "SHORTCUTS   : [SUPER] Launcher • [ALT+I] Settings"
                    color: PhantomState.muted
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
