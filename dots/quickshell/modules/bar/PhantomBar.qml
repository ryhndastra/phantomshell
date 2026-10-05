import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

// modul bar status utama phantomshell beserta popup kalender dan media player
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
                        onClicked: PhantomState.toggleCalendar()
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
                            const evName = String(event.name || "")
                            if (evName === "activespecial" || evName === "activespecialv2") {
                                const dataStr = String(event.data || "")
                                const isOpen = dataStr.indexOf("special") !== -1
                                if (!isOpen && PhantomState.specialWorkspaceActive) {
                                    PhantomState.ensureSpecialWorkspaceOpen()
                                } else if (isOpen && !PhantomState.specialWorkspaceActive) {
                                    PhantomState.setSpecialWorkspaceActive(true)
                                }
                                PhantomState.refreshWorkspaces()
                            } else if (evName === "workspace" || evName === "workspacev2" || evName === "focusedmon" || evName === "focusedmonv2") {
                                if (PhantomState.specialWorkspaceActive) {
                                    PhantomState.ensureSpecialWorkspaceOpen()
                                }
                                PhantomState.scheduleModalFocusPulse()
                                Hyprland.refreshWorkspaces()
                                PhantomState.refreshWorkspaces()
                            } else if (evName === "openwindow") {
                                if (PhantomState.specialWorkspaceActive) {
                                    const parts = String(event.data || "").split(",")
                                    const addr = (parts[0] || "").trim()
                                    const wsName = (parts[1] || "").trim()
                                    if (addr !== "" && wsName.indexOf("special") !== 0) {
                                        Quickshell.execDetached([
                                            "hyprctl", "eval",
                                            "hl.dispatch(hl.dsp.window.move({ workspace = 'special:special', window = 'address:0x" + addr + "' })); if not hl.get_active_special_workspace() then hl.dispatch(hl.dsp.workspace.toggle_special('special')) end"
                                        ])
                                    } else {
                                        PhantomState.ensureSpecialWorkspaceOpen()
                                    }
                                }
                                PhantomState.refreshWorkspaces()
                            } else if (evName === "closewindow" || evName === "movewindow" || evName === "movewindowv2") {
                                if (PhantomState.specialWorkspaceActive) {
                                    PhantomState.ensureSpecialWorkspaceOpen()
                                }
                                PhantomState.refreshWorkspaces()
                            }
                        }
                    }

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: PhantomState.specialWorkspaceActive ? "#0A1024" : PhantomState.surface
                        borderColor: PhantomState.specialWorkspaceActive ? "#60A5FA" : PhantomState.borderLight
                        shadowColor: PhantomState.specialWorkspaceActive ? "#1D4ED8" : PhantomState.borderDark
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
                                readonly property bool isActive: !PhantomState.specialWorkspaceActive
                                    && ((Hyprland.focusedMonitor?.activeWorkspace?.id ?? Hyprland.focusedWorkspace?.id ?? 1) === wsId)
                                readonly property bool isUnderlyingActive: PhantomState.specialWorkspaceActive
                                    && ((Hyprland.focusedMonitor?.activeWorkspace?.id ?? Hyprland.focusedWorkspace?.id ?? 1) === wsId)
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
                                    fillColor: wsDel.isActive
                                        ? PhantomState.primary
                                        : (wsDel.isUnderlyingActive ? "#172554" : (wsDel.hasApps ? PhantomState.surfaceAlt : "transparent"))
                                    borderColor: wsDel.isActive
                                        ? PhantomState.borderLight
                                        : (wsDel.isUnderlyingActive ? "#3B82F6" : (wsDel.hasApps ? "#383B52" : "transparent"))
                                    showShadowOffset: false
                                    borderWidth: (wsDel.isActive || wsDel.isUnderlyingActive || wsDel.hasApps) ? 1 : 0
                                    skewPx: PhantomState.polygonMode ? 4 : 0
                                }

                                Row {
                                    id: wsInnerRow
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: barScope.formatWsLabel(wsDel.wsId)
                                        color: wsDel.isActive
                                            ? PhantomState.foreground
                                            : (wsDel.isUnderlyingActive ? "#93C5FD" : (wsDel.hasApps ? PhantomState.secondary : PhantomState.muted))
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
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Hyprland.dispatch("hl.dsp.focus({ workspace = " + String(wsDel.wsId) + " })")
                                        if (PhantomState.specialWorkspaceActive) {
                                            PhantomState.ensureSpecialWorkspaceOpen()
                                        }
                                        Hyprland.refreshWorkspaces()
                                        PhantomState.refreshWorkspaces()
                                    }
                                    onWheel: wheel => {
                                        if (wheel.angleDelta.y > 0) {
                                            Hyprland.dispatch("hl.dsp.focus({ workspace = 'r-1' })")
                                        } else if (wheel.angleDelta.y < 0) {
                                            Hyprland.dispatch("hl.dsp.focus({ workspace = 'r+1' })")
                                        }
                                    }
                                }
                            }
                        }

                        // indikator ruang kerja khusus (special workspace) bertema velvet room
                        Item {
                            id: velvetWsPill
                            readonly property bool isActive: PhantomState.specialWorkspaceActive
                            readonly property var appList: (PhantomState.workspaceApps && PhantomState.workspaceApps["special"])
                                ? PhantomState.workspaceApps["special"]
                                : []
                            readonly property bool hasApps: appList.length > 0

                            width: Math.max(isActive ? 68 : 26, velvetInnerRow.implicitWidth + 14)
                            height: 22

                            Behavior on width {
                                NumberAnimation { duration: 200; easing.type: Easing.OutBack }
                            }

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: velvetWsPill.isActive
                                    ? "#1D4ED8"
                                    : (velvetMouse.containsMouse ? "#1E3A8A" : (velvetWsPill.hasApps ? "#111C38" : "transparent"))
                                borderColor: velvetWsPill.isActive
                                    ? "#93C5FD"
                                    : (velvetMouse.containsMouse || velvetWsPill.hasApps ? "#3B82F6" : "#2A2F45")
                                showShadowOffset: velvetWsPill.isActive
                                shadowColor: "#FACC15"
                                shadowOffsetX: 1.5
                                shadowOffsetY: 1.5
                                borderWidth: 1.5
                                skewPx: PhantomState.polygonMode ? 4 : 0
                            }

                            Row {
                                id: velvetInnerRow
                                anchors.centerIn: parent
                                spacing: 4

                                P5Star {
                                    visible: velvetWsPill.isActive || velvetWsPill.hasApps
                                    width: 12
                                    height: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    spinning: velvetWsPill.isActive
                                    starColor: "#FACC15"
                                    innerColor: "#3B82F6"
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: velvetWsPill.isActive ? "VELVET" : "V"
                                    color: velvetWsPill.isActive
                                        ? "#FFFFFF"
                                        : (velvetWsPill.hasApps || velvetMouse.containsMouse ? "#60A5FA" : PhantomState.muted)
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    font.italic: true
                                }

                                Repeater {
                                    model: velvetWsPill.appList
                                    delegate: Item {
                                        required property var modelData
                                        width: 14
                                        height: 14
                                        anchors.verticalCenter: parent.verticalCenter

                                        Image {
                                            id: velvetAppImg
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
                                            visible: velvetAppImg.status !== Image.Ready
                                            text: modelData.glyph || "\uf2d0"
                                            color: "#E0F2FE"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 11
                                            font.weight: Font.Black
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: velvetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    PhantomState.toggleVelvetRoom()
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
                width: Math.min(340, Math.max(200, barWin.width - leftRow.width - rightRow.width - 48))
                height: 30

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: PhantomState.launcherOpen
                        ? PhantomState.primary
                        : (PhantomState.specialWorkspaceActive
                            ? (islandMouse.containsMouse ? "#1E3A8A" : "#0A1024")
                            : (islandMouse.containsMouse ? PhantomState.surfaceAlt : PhantomState.surface))
                    borderColor: PhantomState.specialWorkspaceActive ? "#60A5FA" : PhantomState.borderLight
                    shadowColor: PhantomState.launcherOpen
                        ? PhantomState.secondary
                        : (PhantomState.specialWorkspaceActive ? "#1D4ED8" : PhantomState.primary)
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

                    P5Star {
                        visible: PhantomState.specialWorkspaceActive
                        Layout.preferredWidth: 14
                        Layout.preferredHeight: 14
                        spinning: PhantomState.specialWorkspaceActive
                        starColor: "#FACC15"
                        innerColor: "#3B82F6"
                    }

                    Text {
                        Layout.fillWidth: true
                        text: PhantomState.specialWorkspaceActive
                            ? ("VELVET ROOM // " + barWin.activeTitle)
                            : barWin.activeTitle
                        color: PhantomState.specialWorkspaceActive ? "#E0F2FE" : PhantomState.foreground
                        font.pixelSize: 11
                        font.weight: Font.Black
                        font.italic: true
                        elide: Text.ElideRight
                    }

                    P5Icon {
                        name: "search"
                        size: 12
                        color: PhantomState.launcherOpen
                            ? PhantomState.foreground
                            : (PhantomState.specialWorkspaceActive ? "#FACC15" : PhantomState.secondary)
                    }
                }

                MouseArea {
                    id: islandMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            PhantomState.toggleOverview()
                        } else {
                            PhantomState.toggleLauncher()
                        }
                    }
                    onWheel: wheel => {
                        if (wheel.angleDelta.y > 0) {
                            Hyprland.dispatch("hl.dsp.focus({ direction = 'l' })")
                        } else if (wheel.angleDelta.y < 0) {
                            Hyprland.dispatch("hl.dsp.focus({ direction = 'r' })")
                        }
                    }
                }
            }

            // deretan komponen kanan bar
            BarRightPills {
                id: rightRow
                barWin: barWin
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // jendela popup kalender bulanan dan buku catatan daily log ala persona 5
    PhantomCalendarPopup {
        periodStr: barScope.periodStr
        timeStr: barScope.timeStr
    }

    // jendela popup media player mpris
    PhantomMediaPopup {}

    // jendela popup daftar aplikasi system tray jika lebih dari 2 aplikasi
    PhantomTrayPopup {}
}
