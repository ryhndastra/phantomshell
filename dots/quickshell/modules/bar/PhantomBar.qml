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

    // jendela panel bar utama pada setiap monitor
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

            // latar belakang bar solid opsional
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

            // deretan komponen kiri bar: logo, tanggal/jam, workspace, dan tombol utilitas
            Row {
                id: leftRow
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // tombol logo utama untuk membuka launcher atau pengaturan
                Item {
                    width: 60
                    height: 36
                    clip: false

                    Image {
                        anchors.centerIn: parent
                        width: 62
                        height: 46
                        source: PhantomState.logoPath
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true
                        scale: logoMouse.pressed ? 0.92 : (logoMouse.containsMouse || PhantomState.launcherOpen ? 1.14 : 1.0)
                        rotation: (logoMouse.containsMouse || PhantomState.launcherOpen) ? -4 : 0
                        Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }
                        Behavior on rotation { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
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

                // indikator nomor workspace dan ikon aplikasi aktif
                Item {
                    visible: PhantomState.showWorkspaces
                    width: wsRow.implicitWidth + 18
                    height: 30

                    Connections {
                        target: Hyprland
                        function onRawEvent(event) {
                            PhantomState.refreshWorkspaces()
                        }
                    }

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
                        spacing: 4

                        Repeater {
                            model: PhantomState.workspaceCount
                            delegate: Item {
                                id: wsDel
                                required property int index
                                readonly property int wsId: index + 1
                                readonly property bool isActive: (Hyprland.focusedWorkspace?.id ?? 1) === wsId
                                readonly property var appList: (PhantomState.workspaceApps && PhantomState.workspaceApps[String(wsId)])
                                    ? PhantomState.workspaceApps[String(wsId)]
                                    : []
                                readonly property bool hasApps: appList.length > 0

                                width: Math.max(isActive ? 28 : 22, wsInnerRow.implicitWidth + (hasApps ? 14 : 10))
                                height: 22

                                Behavior on width {
                                    NumberAnimation { duration: 180; easing.type: Easing.OutBack }
                                }

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: wsDel.isActive ? PhantomState.primary : (wsDel.hasApps ? PhantomState.surfaceAlt : "transparent")
                                    borderColor: wsDel.isActive ? PhantomState.borderLight : (wsDel.hasApps ? "#383B52" : "transparent")
                                    showShadowOffset: false
                                    borderWidth: (wsDel.isActive || wsDel.hasApps) ? 1 : 0
                                    skewPx: PhantomState.polygonMode ? 4 : 0
                                }

                                Row {
                                    id: wsInnerRow
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: barScope.formatWsLabel(wsDel.wsId)
                                        color: wsDel.isActive ? PhantomState.foreground : (wsDel.hasApps ? PhantomState.secondary : PhantomState.muted)
                                        font.pixelSize: wsDel.isActive ? 11 : 10
                                        font.weight: Font.Black
                                    }

                                    // deretan ikon aplikasi yang terbuka di workspace ini
                                    Repeater {
                                        model: wsDel.appList
                                        delegate: Item {
                                            required property var modelData
                                            width: 14
                                            height: 14
                                            anchors.verticalCenter: parent.verticalCenter

                                            Image {
                                                id: wsAppImg
                                                anchors.fill: parent
                                                source: modelData.iconUrl || ""
                                                sourceSize.width: 28
                                                sourceSize.height: 28
                                                fillMode: Image.PreserveAspectFit
                                                smooth: true
                                                visible: status === Image.Ready
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                visible: wsAppImg.status !== Image.Ready
                                                text: modelData.glyph || "\uf2d0"
                                                color: wsDel.isActive ? PhantomState.foreground : PhantomState.foreground
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 11
                                                font.weight: Font.Black
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", String(wsDel.wsId)])
                                        PhantomState.refreshWorkspaces()
                                    }
                                }
                            }
                        }
                    }
                }

                // deretan tombol utilitas tangkapan layar dan pemilih warna
                Item {
                    visible: PhantomState.showUtilButtons && (PhantomState.showUtilSnip || PhantomState.showUtilPicker || PhantomState.showUtilMic || PhantomState.showUtilDark)
                    width: utilRow.implicitWidth + 20
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

                        // tombol tangkapan layar area
                        Item {
                            visible: PhantomState.showUtilSnip
                            width: snipBtnRow.implicitWidth + 14
                            height: 22

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: snipMouse.containsMouse ? PhantomState.primary : PhantomState.surfaceAlt
                                borderColor: snipMouse.containsMouse ? PhantomState.borderLight : "transparent"
                                showShadowOffset: false
                                borderWidth: 1
                                skewPx: 4
                            }

                            Row {
                                id: snipBtnRow
                                anchors.centerIn: parent
                                spacing: 4
                                P5Icon { anchors.verticalCenter: parent.verticalCenter; name: "snip"; size: 12; color: PhantomState.foreground }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "SNIP"
                                    color: PhantomState.foreground
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.italic: true
                                }
                            }

                            MouseArea {
                                id: snipMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["sh", "-c", "grim -g \"$(slurp)\" - | swappy -f - 2>/dev/null || hyprshot -m region 2>/dev/null || true"])
                            }
                        }

                        // tombol pemilih warna layar
                        Item {
                            visible: PhantomState.showUtilPicker
                            width: pickBtnRow.implicitWidth + 14
                            height: 22

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: pickMouse.containsMouse ? PhantomState.primary : PhantomState.surfaceAlt
                                borderColor: pickMouse.containsMouse ? PhantomState.borderLight : "transparent"
                                showShadowOffset: false
                                borderWidth: 1
                                skewPx: 4
                            }

                            Row {
                                id: pickBtnRow
                                anchors.centerIn: parent
                                spacing: 4
                                P5Icon { anchors.verticalCenter: parent.verticalCenter; name: "picker"; size: 12; color: PhantomState.secondary }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "PICK"
                                    color: PhantomState.foreground
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.italic: true
                                }
                            }

                            MouseArea {
                                id: pickMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["sh", "-c", "hyprpicker -a 2>/dev/null || true"])
                            }
                        }

                        // tombol toggle mute mic
                        Item {
                            visible: PhantomState.showUtilMic
                            width: 24; height: 22
                            P5Icon { anchors.centerIn: parent; name: "volume"; size: 12; color: PhantomState.foreground }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"])
                            }
                        }

                        // tombol ganti dark/light mode
                        Item {
                            visible: PhantomState.showUtilDark
                            width: 24; height: 22
                            P5Icon { anchors.centerIn: parent; name: PhantomState.darkMode ? "moon" : "sun"; size: 12; color: PhantomState.secondary }
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
            Item {
                id: dynamicIsland
                visible: PhantomState.showDynamicIsland
                anchors.centerIn: parent
                width: Math.min(320, Math.max(200, barWin.width - leftRow.width - rightRow.width - 48))
                height: 30

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: PhantomState.launcherOpen ? PhantomState.primary : (islandMouse.containsMouse ? PhantomState.surfaceAlt : PhantomState.surface)
                    borderColor: PhantomState.borderLight
                    shadowColor: PhantomState.launcherOpen ? PhantomState.secondary : PhantomState.primary
                    borderWidth: 2
                    skewPx: PhantomState.polygonMode ? 6 : 0
                    shadowOffsetX: 2
                    shadowOffsetY: 2
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 14
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: barWin.activeTitle
                        color: PhantomState.foreground
                        font.pixelSize: 11
                        font.weight: Font.Black
                        font.italic: true
                        elide: Text.ElideRight
                    }

                    P5Icon {
                        name: "search"
                        size: 12
                        color: PhantomState.launcherOpen ? PhantomState.foreground : PhantomState.secondary
                    }
                }

                MouseArea {
                    id: islandMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PhantomState.toggleLauncher()
                }
            }

            // deretan komponen kanan bar: media player, tema, wallpaper, notifikasi, statistik, pengaturan, dan sesi
            Row {
                id: rightRow
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                // pill pengendali media player dan pembuka popup jukebox
                Item {
                    visible: PhantomState.showMediaPill
                    width: mediaPillRow.implicitWidth + 20
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.mediaPopupOpen ? PhantomState.primary : PhantomState.surface
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.mediaPlaying ? PhantomState.secondary : PhantomState.primary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 5 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    Row {
                        id: mediaPillRow
                        anchors.centerIn: parent
                        spacing: 5

                        // bagian kiri: ikon musik dan judul lagu aktif
                        Item {
                            width: mediaTitleRow.implicitWidth
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                id: mediaTitleRow
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5

                                P5Icon {
                                    name: "music"
                                    size: 12
                                    color: PhantomState.mediaPlaying ? PhantomState.secondary : PhantomState.muted
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    width: Math.min(130, implicitWidth)
                                    text: PhantomState.mediaAvailable ? PhantomState.mediaTitle : "NO MEDIA"
                                    color: PhantomState.foreground
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    font.italic: true
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.toggleMediaPopup()
                            }
                        }

                        // garis pemisah kecil
                        Rectangle {
                            width: 1
                            height: 14
                            color: "#44FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // tombol prev
                        Item {
                            width: 18
                            height: 20
                            anchors.verticalCenter: parent.verticalCenter

                            P5Icon {
                                anchors.centerIn: parent
                                name: "prev"
                                size: 10
                                color: prevBarMouse.containsMouse ? PhantomState.secondary : PhantomState.foreground
                            }
                            MouseArea {
                                id: prevBarMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.mediaPrev()
                            }
                        }

                        // tombol play / pause
                        Item {
                            width: 20
                            height: 20
                            anchors.verticalCenter: parent.verticalCenter

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: playBarMouse.containsMouse ? PhantomState.secondary : PhantomState.primary
                                borderColor: PhantomState.borderLight
                                showShadowOffset: false
                                borderWidth: 1
                                skewPx: 3
                            }

                            P5Icon {
                                anchors.centerIn: parent
                                name: PhantomState.mediaPlaying ? "pause" : "play"
                                size: 9
                                color: playBarMouse.containsMouse ? "#05060A" : "#FFFFFF"
                            }
                            MouseArea {
                                id: playBarMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.mediaPlayPause()
                            }
                        }

                        // tombol next
                        Item {
                            width: 18
                            height: 20
                            anchors.verticalCenter: parent.verticalCenter

                            P5Icon {
                                anchors.centerIn: parent
                                name: "next"
                                size: 10
                                color: nextBarMouse.containsMouse ? PhantomState.secondary : PhantomState.foreground
                            }
                            MouseArea {
                                id: nextBarMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.mediaNext()
                            }
                        }
                    }
                }

                // tombol ganti cepat preset warna
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

                // tombol pembuka panel pemilih wallpaper
                Item {
                    width: 34
                    height: 30

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.wallpaperSelectorOpen ? PhantomState.primary : (wpBtnMouse.containsMouse ? PhantomState.surfaceAlt : PhantomState.surface)
                        borderColor: PhantomState.borderLight
                        shadowColor: PhantomState.wallpaperSelectorOpen ? PhantomState.secondary : PhantomState.primary
                        borderWidth: 2
                        skewPx: PhantomState.polygonMode ? 5 : 0
                        shadowOffsetX: 2
                        shadowOffsetY: 2
                    }

                    P5Icon {
                        anchors.centerIn: parent
                        name: "wallpaper"
                        size: 14
                        color: PhantomState.wallpaperSelectorOpen ? PhantomState.foreground : PhantomState.secondary
                    }

                    MouseArea {
                        id: wpBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                PhantomState.cycleWallpaper()
                            } else {
                                PhantomState.toggleWallpaperSelector()
                            }
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

    // jendela popup kalender dan jadwal harian
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

    // jendela popup media player mpris
    PanelWindow {
        id: mediaPopupWin
        visible: PhantomState.mediaPopupOpen

        readonly property bool isBottom: PhantomState.barPosition === "bottom"

        WlrLayershell.namespace: "phantomshell-media-popup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            top: !mediaPopupWin.isBottom
            bottom: mediaPopupWin.isBottom
            right: true
        }
        margins {
            top: 42
            bottom: 42
            right: 190
        }

        implicitWidth: 420
        implicitHeight: 196
        color: "transparent"

        onVisibleChanged: {
            if (visible) {
                mediaPopupAnim.restart()
                PhantomState.refreshMedia()
            }
        }

        Item {
            id: mediaCard
            anchors.fill: parent
            transformOrigin: mediaPopupWin.isBottom ? Item.BottomRight : Item.TopRight

            ParallelAnimation {
                id: mediaPopupAnim
                NumberAnimation {
                    target: mediaCard
                    property: "scale"
                    from: 0.85
                    to: 1.0
                    duration: 220
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.32
                }
                NumberAnimation {
                    target: mediaCard
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            P5SkewedCard {
                anchors.fill: parent
                fillColor: "#0B0C12"
                borderColor: "#FFFFFF"
                shadowColor: PhantomState.primary
                borderWidth: 2.5
                skewPx: PhantomState.polygonMode ? 9 : 0
                shadowOffsetX: 5
                shadowOffsetY: 5
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                // sampul album dengan bingkai miring
                Item {
                    Layout.preferredWidth: 124
                    Layout.preferredHeight: 124
                    Layout.alignment: Qt.AlignVCenter

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: "#161824"
                        borderColor: PhantomState.secondary
                        shadowColor: PhantomState.primary
                        borderWidth: 2
                        skewPx: 5
                        shadowOffsetX: 3
                        shadowOffsetY: 3
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 5
                        color: "#0F111A"
                        clip: true

                        Image {
                            id: albumArtImg
                            anchors.fill: parent
                            source: PhantomState.mediaArtUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            smooth: true
                            visible: status === Image.Ready
                        }

                        // ikon bintang cadangan saat sampul album tidak tersedia
                        P5Star {
                            anchors.centerIn: parent
                            width: 54
                            height: 54
                            visible: albumArtImg.status !== Image.Ready
                            spinning: PhantomState.mediaPlaying
                        }

                        // lencana nama aplikasi pemutar media di sudut kiri atas
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 4
                            width: playerBadgeTxt.implicitWidth + 10
                            height: 16
                            color: PhantomState.primary
                            border.color: "#FFFFFF"
                            border.width: 1

                            Text {
                                id: playerBadgeTxt
                                anchors.centerIn: parent
                                text: PhantomState.mediaPlayerName
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 8
                                font.weight: Font.Black
                            }
                        }
                    }
                }

                // informasi lagu, bilah progres interaktif, dan tombol kontrol media
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            Layout.fillWidth: true
                            text: PhantomState.mediaTitle
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 13
                            font.weight: Font.Black
                            font.italic: true
                            elide: Text.ElideRight
                        }

                        // tombol tutup popup
                        Item {
                            width: 22
                            height: 22
                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: closeMediaMouse.containsMouse ? PhantomState.primary : "#1A1D2B"
                                borderColor: "#FFFFFF"
                                showShadowOffset: false
                                borderWidth: 1
                                skewPx: 3
                            }
                            P5Icon { anchors.centerIn: parent; name: "close"; size: 9; color: "#FFFFFF" }
                            MouseArea {
                                id: closeMediaMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.mediaPopupOpen = false
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: PhantomState.mediaArtist + (PhantomState.mediaAlbum ? (" • " + PhantomState.mediaAlbum) : "")
                        color: PhantomState.secondary
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    // bilah progres posisi lagu interaktif
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Item {
                            id: seekTrack
                            Layout.fillWidth: true
                            Layout.preferredHeight: 16

                            readonly property real progRatio: PhantomState.mediaLengthSec > 0
                                ? Math.min(1.0, Math.max(0.0, PhantomState.mediaPositionSec / PhantomState.mediaLengthSec))
                                : 0.0

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                height: 5
                                color: "#282B3E"
                                border.color: "#454966"
                                border.width: 1

                                Rectangle {
                                    width: parent.width * seekTrack.progRatio
                                    height: parent.height
                                    color: PhantomState.primary
                                }
                            }

                            P5Star {
                                width: 15
                                height: 15
                                anchors.verticalCenter: parent.verticalCenter
                                x: Math.max(0, Math.min(seekTrack.width - width, seekTrack.width * seekTrack.progRatio - width / 2))
                                spinning: PhantomState.mediaPlaying
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    if (seekTrack.width > 0) {
                                        PhantomState.mediaSeek(mouse.x / seekTrack.width)
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: PhantomState.formatMediaTime(PhantomState.mediaPositionSec)
                                color: PhantomState.muted
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: PhantomState.formatMediaTime(PhantomState.mediaLengthSec)
                                color: PhantomState.muted
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }
                        }
                    }

                    // deretan tombol kontrol pemutaran lagu
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // tombol shuffle
                        Item {
                            width: 30
                            height: 28
                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.mediaShuffle === "On" ? PhantomState.secondary : (shufMouse.containsMouse ? "#25283B" : "#161824")
                                borderColor: PhantomState.mediaShuffle === "On" ? "#05060A" : "#3A3E58"
                                showShadowOffset: false
                                borderWidth: 1.2
                                skewPx: 4
                            }
                            P5Icon {
                                anchors.centerIn: parent
                                name: "shuffle"
                                size: 11
                                color: PhantomState.mediaShuffle === "On" ? "#05060A" : "#FFFFFF"
                            }
                            MouseArea {
                                id: shufMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.mediaToggleShuffle()
                            }
                        }

                        // tombol previous
                        Item {
                            width: 36
                            height: 30
                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: prevPopMouse.containsMouse ? PhantomState.primary : "#1A1D2C"
                                borderColor: "#FFFFFF"
                                showShadowOffset: false
                                borderWidth: 1.5
                                skewPx: 4
                            }
                            P5Icon {
                                anchors.centerIn: parent
                                name: "prev"
                                size: 12
                                color: "#FFFFFF"
                            }
                            MouseArea {
                                id: prevPopMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.mediaPrev()
                            }
                        }

                        // tombol play dan pause utama
                        Item {
                            Layout.fillWidth: true
                            height: 32
                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: playPopMouse.containsMouse ? PhantomState.secondary : PhantomState.primary
                                borderColor: "#FFFFFF"
                                shadowColor: PhantomState.secondary
                                borderWidth: 2
                                skewPx: 5
                                shadowOffsetX: 2
                                shadowOffsetY: 2
                            }
                            Row {
                                anchors.centerIn: parent
                                spacing: 6
                                P5Icon {
                                    anchors.verticalCenter: parent.verticalCenter
                                    name: PhantomState.mediaPlaying ? "pause" : "play"
                                    size: 12
                                    color: playPopMouse.containsMouse ? "#05060A" : "#FFFFFF"
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: PhantomState.mediaPlaying ? "PAUSE" : "PLAY"
                                    color: playPopMouse.containsMouse ? "#05060A" : "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    font.italic: true
                                }
                            }
                            MouseArea {
                                id: playPopMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.mediaPlayPause()
                            }
                        }

                        // tombol next
                        Item {
                            width: 36
                            height: 30
                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: nextPopMouse.containsMouse ? PhantomState.primary : "#1A1D2C"
                                borderColor: "#FFFFFF"
                                showShadowOffset: false
                                borderWidth: 1.5
                                skewPx: 4
                            }
                            P5Icon {
                                anchors.centerIn: parent
                                name: "next"
                                size: 12
                                color: "#FFFFFF"
                            }
                            MouseArea {
                                id: nextPopMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.mediaNext()
                            }
                        }

                        // tombol loop
                        Item {
                            width: 30
                            height: 28
                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: PhantomState.mediaLoop !== "None" ? PhantomState.secondary : (loopMouse.containsMouse ? "#25283B" : "#161824")
                                borderColor: PhantomState.mediaLoop !== "None" ? "#05060A" : "#3A3E58"
                                showShadowOffset: false
                                borderWidth: 1.2
                                skewPx: 4
                            }
                            P5Icon {
                                anchors.centerIn: parent
                                name: "repeat"
                                size: 11
                                color: PhantomState.mediaLoop !== "None" ? "#05060A" : "#FFFFFF"
                            }
                            MouseArea {
                                id: loopMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.mediaToggleLoop()
                            }
                        }
                    }
                }
            }
        }
    }
}
