import QtQuick
import QtQuick.Layouts
import QtMultimedia
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

// modul menu sesi dan manajemen daya bergaya calling card persona
Scope {
    PanelWindow {
        id: sessionWin

        property int selectedIndex: 0

        visible: PhantomState.sessionOpen

        WlrLayershell.namespace: "phantomshell-session"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: PhantomState.sessionOpen
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

        readonly property var actionsModel: [
            {
                arcana: "I // GUARD",
                keyHint: "1",
                icon: "lock",
                p3Icon: "",
                label: "LOCK",
                sub: "SEAL METAVERSE",
                p3Sub: "SEAL S.E.E.S.",
                action: "lock",
                cmd: []
            },
            {
                arcana: "II // REST",
                keyHint: "2",
                icon: "moon",
                p3Icon: "",
                label: "SUSPEND",
                sub: "SLEEP IN LEBLANC",
                p3Sub: "STANDBY MODE",
                action: "cmd",
                cmd: ["systemctl", "suspend"]
            },
            {
                arcana: "III // EXIT",
                keyHint: "3",
                icon: "logout",
                p3Icon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/logout.png"),
                label: "LOGOUT",
                sub: "LEAVE PALACE",
                p3Sub: "LEAVE SECTOR",
                action: "cmd",
                cmd: ["hyprctl", "dispatch", "exit"]
            },
            {
                arcana: "IV // CYCLE",
                keyHint: "4",
                icon: "reboot",
                p3Icon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/restart.png"),
                label: "REBOOT",
                sub: "RELOAD SYSTEM",
                p3Sub: "SYSTEM REBOOT",
                action: "cmd",
                cmd: ["systemctl", "reboot"]
            },
            {
                arcana: "V // HALT",
                keyHint: "5",
                icon: "power",
                p3Icon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/shutdown.png"),
                label: "POWEROFF",
                sub: "SHUT DOWN",
                p3Sub: "DISCONNECT S.E.E.S.",
                action: "cmd",
                cmd: ["systemctl", "poweroff"]
            }
        ]

        function triggerAction(idx) {
            if (idx < 0 || idx >= sessionWin.actionsModel.length) return
            const item = sessionWin.actionsModel[idx]
            PhantomState.playSfx("select")
            PhantomState.sessionOpen = false
            if (item.action === "lock") {
                PhantomState.lockScreen()
            } else {
                Quickshell.execDetached(item.cmd)
            }
        }

        Connections {
            target: PhantomState
            function onSessionOpenChanged() {
                if (PhantomState.sessionOpen) {
                    PhantomState.playSfx("open")
                    sessionWin.selectedIndex = 0
                    keyCatcher.forceActiveFocus()
                } else {
                    PhantomState.playSfx("close")
                }
            }
        }

        // penangkap navigasi papan ketik untuk memilih aksi sesi
        Item {
            id: keyCatcher
            anchors.fill: parent
            focus: PhantomState.sessionOpen

            Keys.onPressed: event => {
                if (PhantomState.isP3) {
                    if (p3Overlay.showThemeConfirm) {
                        if (event.key === Qt.Key_Escape) {
                            PhantomState.playSfx("select")
                            p3Overlay.showThemeConfirm = false
                            event.accepted = true
                            return
                        }
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                            PhantomState.playSfx("confirm")
                            PhantomState.applyPreset(p3Overlay.p3ThemesData[p3Overlay.selectedThemeIndex].id)
                            p3Overlay.showThemeConfirm = false
                            event.accepted = true
                            return
                        }
                        if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                            p3Overlay.selectedThemeIndex = (p3Overlay.selectedThemeIndex + 2) % 3
                            PhantomState.playSfx("select")
                            event.accepted = true
                            return
                        }
                        if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                            p3Overlay.selectedThemeIndex = (p3Overlay.selectedThemeIndex + 1) % 3
                            PhantomState.playSfx("select")
                            event.accepted = true
                            return
                        }
                    }
                    if (event.key === Qt.Key_Escape) {
                        if (p3Overlay.currentSection !== "main") {
                            PhantomState.playSfx("select")
                            p3Overlay.navigateTo("main")
                        } else {
                            PhantomState.sessionOpen = false
                        }
                        event.accepted = true
                        return
                    }
                    if (p3Overlay.currentSection === "main") {
                        if (event.key >= Qt.Key_1 && event.key <= Qt.Key_6) {
                            const secs = ["stats", "config", "control", "palette", "archive", "dispatch"]
                            p3Overlay.navigateTo(secs[event.key - Qt.Key_1])
                            PhantomState.playSfx("confirm")
                            event.accepted = true
                            return
                        }
                    } else if (p3Overlay.currentSection === "dispatch" || p3Overlay.currentSection === "power") {
                        if (event.key === Qt.Key_1) {
                            PhantomState.sessionOpen = false
                            Quickshell.execDetached(["systemctl", "poweroff"])
                            event.accepted = true
                            return
                        } else if (event.key === Qt.Key_2) {
                            PhantomState.sessionOpen = false
                            Quickshell.execDetached(["systemctl", "reboot"])
                            event.accepted = true
                            return
                        } else if (event.key === Qt.Key_3) {
                            PhantomState.sessionOpen = false
                            Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
                            event.accepted = true
                            return
                        }
                    } else if (p3Overlay.currentSection === "stats" || p3Overlay.currentSection === "network" || p3Overlay.currentSection === "bluetooth") {
                        if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
                            p3Overlay.statsTab = (p3Overlay.statsTab + 3) % 4
                            PhantomState.playSfx("select")
                            event.accepted = true
                            return
                        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                            p3Overlay.statsTab = (p3Overlay.statsTab + 1) % 4
                            PhantomState.playSfx("select")
                            event.accepted = true
                            return
                        } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_4) {
                            p3Overlay.statsTab = event.key - Qt.Key_1
                            PhantomState.playSfx("select")
                            event.accepted = true
                            return
                        }
                    } else if (p3Overlay.currentSection === "config") {
                        if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
                            p3Overlay.configTab = (p3Overlay.configTab + 2) % 3
                            PhantomState.playSfx("select")
                            event.accepted = true
                            return
                        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                            p3Overlay.configTab = (p3Overlay.configTab + 1) % 3
                            PhantomState.playSfx("select")
                            event.accepted = true
                            return
                        } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_3) {
                            p3Overlay.configTab = event.key - Qt.Key_1
                            PhantomState.playSfx("select")
                            event.accepted = true
                            return
                        }
                    }
                }
                if (event.key === Qt.Key_Escape) {
                    PhantomState.sessionOpen = false
                    event.accepted = true
                } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                    sessionWin.selectedIndex = (sessionWin.selectedIndex + sessionWin.actionsModel.length - 1) % sessionWin.actionsModel.length
                    PhantomState.playSfx("select")
                    event.accepted = true
                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L || event.key === Qt.Key_Tab) {
                    sessionWin.selectedIndex = (sessionWin.selectedIndex + 1) % sessionWin.actionsModel.length
                    PhantomState.playSfx("select")
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    sessionWin.triggerAction(sessionWin.selectedIndex)
                    event.accepted = true
                } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_5) {
                    sessionWin.triggerAction(event.key - Qt.Key_1)
                    event.accepted = true
                }
            }
        }

        // lapisan latar gelap dan pita diagonal layar penuh
        Item {
            id: backdropItem
            anchors.fill: parent
            visible: !PhantomState.isP3
            readonly property bool isOpen: PhantomState.sessionOpen
            opacity: isOpen ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }

            Rectangle {
                anchors.fill: parent
                color: "#D806060A"
            }

            Canvas {
                anchors.fill: parent
                visible: !PhantomState.isP3
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height

                    ctx.fillStyle = Qt.rgba(PhantomState.primary.r, PhantomState.primary.g, PhantomState.primary.b, 0.14)
                    ctx.beginPath()
                    ctx.moveTo(0, h * 0.24)
                    ctx.lineTo(w, h * 0.06)
                    ctx.lineTo(w, h * 0.18)
                    ctx.lineTo(0, h * 0.38)
                    ctx.closePath()
                    ctx.fill()

                    ctx.fillStyle = Qt.rgba(PhantomState.primary.r, PhantomState.primary.g, PhantomState.primary.b, 0.09)
                    ctx.beginPath()
                    ctx.moveTo(0, h * 0.82)
                    ctx.lineTo(w, h * 0.64)
                    ctx.lineTo(w, h * 0.75)
                    ctx.lineTo(0, h * 0.94)
                    ctx.closePath()
                    ctx.fill()
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: !PhantomState.isP3
                onClicked: PhantomState.sessionOpen = false
            }
        }

        // kontainer kartu utama menu sesi (Mode P5)
        Item {
            id: cardContainer
            visible: !PhantomState.isP3
            width: Math.min(780, parent.width - 48)
            height: Math.min(410, parent.height - 72)
            anchors.centerIn: parent

            readonly property bool isOpen: PhantomState.sessionOpen

            opacity: isOpen ? 1.0 : 0.0
            scale: isOpen ? 1.0 : 0.88
            rotation: PhantomState.isP3 ? 0 : (isOpen ? (PhantomState.polygonMode ? -0.8 : 0) : -3.5)

            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 220; easing.type: cardContainer.isOpen ? Easing.OutBack : Easing.InCubic } }
            Behavior on rotation { NumberAnimation { duration: 220; easing.type: cardContainer.isOpen ? Easing.OutBack : Easing.InCubic } }

            MouseArea { anchors.fill: parent }

            // bingkai luar bersih minimalis persona 3 reload
            Rectangle {
                anchors.fill: parent
                visible: PhantomState.isP3
                radius: 12
                color: Qt.rgba(6/255, 12/255, 28/255, 0.95)
                border.color: Qt.rgba(0/255, 219/255, 255/255, 0.45)
                border.width: 1
                clip: true

                // garis aksen biru cyan di atas kartu
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 2
                    color: "#00dbff"
                }

                // gelombang laut halus persona 3 di latar kartu
                Item {
                    id: sessionWaves
                    anchors.fill: parent
                    opacity: 0.22
                    clip: true

                    Repeater {
                        model: [
                            Qt.resolvedUrl("../../assets/themes/p3/img/wave1.png"),
                            Qt.resolvedUrl("../../assets/themes/p3/img/wave2.png")
                        ]
                        delegate: Item {
                            id: swDel
                            required property url modelData
                            required property int index
                            width: sessionWaves.width * 2
                            height: sessionWaves.height

                            Image {
                                source: swDel.modelData
                                width: sessionWaves.width
                                height: sessionWaves.height
                                fillMode: Image.Stretch
                                x: 0
                            }
                            Image {
                                source: swDel.modelData
                                width: sessionWaves.width
                                height: sessionWaves.height
                                fillMode: Image.Stretch
                                x: sessionWaves.width
                            }
                            NumberAnimation on x {
                                from: 0
                                to: -sessionWaves.width
                                duration: 20000 + swDel.index * 5000
                                loops: Animation.Infinite
                                running: PhantomState.sessionOpen && PhantomState.isP3
                            }
                        }
                    }
                }
            }

            // bingkai luar miring dengan bayangan berlapis (P5)
            P5SkewedCard {
                anchors.fill: parent
                visible: !PhantomState.isP3
                fillColor: "#0A0A0F"
                borderColor: PhantomState.borderLight
                shadowColor: PhantomState.primary
                borderWidth: 3
                skewPx: PhantomState.polygonMode ? 16 : 0
                shadowOffsetX: 9
                shadowOffsetY: 9
            }

            // dekorasi garis miring dan bintang besar di dalam kartu (P5)
            Item {
                anchors.fill: parent
                anchors.margins: 6
                visible: !PhantomState.isP3
                clip: true

                Canvas {
                    anchors.fill: parent
                    opacity: 0.12
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var h = height

                        ctx.fillStyle = String(PhantomState.primary)
                        ctx.beginPath()
                        ctx.moveTo(w * 0.56, 0)
                        ctx.lineTo(w * 0.74, 0)
                        ctx.lineTo(w * 0.58, h)
                        ctx.lineTo(w * 0.40, h)
                        ctx.closePath()
                        ctx.fill()

                        ctx.fillStyle = "#FFFFFF"
                        ctx.beginPath()
                        ctx.moveTo(w * 0.76, 0)
                        ctx.lineTo(w * 0.79, 0)
                        ctx.lineTo(w * 0.63, h)
                        ctx.lineTo(w * 0.60, h)
                        ctx.closePath()
                        ctx.fill()
                    }
                }

                P5Star {
                    width: 220
                    height: 220
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: -45
                    anchors.bottomMargin: -55
                    opacity: 0.08
                    spinning: true
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                anchors.topMargin: 22
                anchors.bottomMargin: 20
                spacing: 14

                // baris header atas dengan pita calling card / S.E.E.S. dan info sesi
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // ikon header (P3 S.E.E.S. target ring vs P5 Star)
                    Item {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38

                        Rectangle {
                            anchors.fill: parent
                            visible: PhantomState.isP3
                            radius: 19
                            color: Qt.rgba(0/255, 44/255, 144/255, 0.6)
                            border.color: "#00dbff"
                            border.width: 1.5

                            Rectangle {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                radius: 9
                                color: "#00dbff"
                            }
                        }

                        P5Star {
                            anchors.fill: parent
                            visible: !PhantomState.isP3
                            spinning: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        RowLayout {
                            spacing: 8

                            Rectangle {
                                width: PhantomState.isP3 ? 160 : 138
                                height: 20
                                color: PhantomState.isP3 ? "#002c90" : "#FFFFFF"
                                border.color: PhantomState.isP3 ? "#00dbff" : "transparent"
                                border.width: PhantomState.isP3 ? 1 : 0
                                radius: PhantomState.isP3 ? 3 : 0
                                rotation: PhantomState.isP3 ? 0 : -2
                                Text {
                                    anchors.centerIn: parent
                                    text: PhantomState.isP3 ? "S.E.E.S. // TACTICAL EVOKER" : "CALLING CARD // MENU"
                                    color: PhantomState.isP3 ? "#00dbff" : "#09090D"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                }
                            }

                            Rectangle {
                                width: PhantomState.isP3 ? 120 : 112
                                height: 20
                                color: PhantomState.primary
                                border.color: "#FFFFFF"
                                border.width: 1
                                radius: PhantomState.isP3 ? 3 : 0
                                rotation: PhantomState.isP3 ? 0 : 1.5
                                Text {
                                    anchors.centerIn: parent
                                    text: PhantomState.isP3 ? "DARK HOUR PROTOCOL" : "METAVERSE LINK"
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: PhantomState.isP3 ? "PERSONA 3 RELOAD // SYSTEM LOGOUT" : "TAKE YOUR TIME // SESSION COMMAND"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 21
                            font.weight: Font.Black
                            font.italic: !PhantomState.isP3
                            elide: Text.ElideRight
                        }
                    }

                    // lencana identitas pengguna dan waktu aktif sistem
                    Item {
                        Layout.preferredWidth: 168
                        Layout.preferredHeight: 42

                        Rectangle {
                            anchors.fill: parent
                            visible: PhantomState.isP3
                            radius: 6
                            color: Qt.rgba(8/255, 18/255, 42/255, 0.85)
                            border.color: Qt.rgba(0/255, 219/255, 255/255, 0.35)
                            border.width: 1
                        }

                        P5SkewedCard {
                            anchors.fill: parent
                            visible: !PhantomState.isP3
                            fillColor: "#15151F"
                            borderColor: "#3A3A4E"
                            shadowColor: "#050508"
                            borderWidth: 1.5
                            skewPx: 8
                            shadowOffsetX: 3
                            shadowOffsetY: 3
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 1
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: PhantomState.sysHost.toUpperCase()
                                color: PhantomState.secondary
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 11
                                font.weight: Font.Black
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "UPTIME // " + PhantomState.sysUptime
                                color: PhantomState.muted
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }
                        }
                    }

                    // tombol penutup jendela menu sesi
                    Item {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 42

                        Rectangle {
                            anchors.fill: parent
                            visible: PhantomState.isP3
                            radius: 6
                            color: closeMouse.containsMouse ? PhantomState.primary : Qt.rgba(8/255, 18/255, 42/255, 0.85)
                            border.color: closeMouse.containsMouse ? "#00dbff" : Qt.rgba(0/255, 219/255, 255/255, 0.4)
                            border.width: 1
                        }

                        P5SkewedCard {
                            anchors.fill: parent
                            visible: !PhantomState.isP3
                            fillColor: closeMouse.containsMouse ? PhantomState.primary : "#181824"
                            borderColor: "#FFFFFF"
                            shadowColor: "#050508"
                            borderWidth: 2
                            skewPx: 6
                            shadowOffsetX: 3
                            shadowOffsetY: 3
                        }

                        P5Icon {
                            anchors.centerIn: parent
                            name: "close"
                            size: 15
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.sessionOpen = false
                        }
                    }
                }

                // deretan kartu tarot aksi sesi dan daya
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    Repeater {
                        model: sessionWin.actionsModel

                        delegate: Item {
                            id: cardDelegate
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            readonly property bool isHighlighted: btnMouse.containsMouse || (sessionWin.selectedIndex === index)

                            scale: isHighlighted ? 1.04 : 1.0
                            rotation: PhantomState.isP3 ? 0 : (isHighlighted ? -2.0 : ((index % 2 === 0) ? -0.6 : 0.6))
                            z: isHighlighted ? 10 : 1

                            transform: Translate {
                                y: cardDelegate.isHighlighted ? -7 : 0
                                Behavior on y { NumberAnimation { duration: 170; easing.type: Easing.OutBack } }
                            }

                            Behavior on scale { NumberAnimation { duration: 170; easing.type: Easing.OutBack } }
                            Behavior on rotation { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }

                            // kartu latar bersih Persona 3 Reload
                            Rectangle {
                                anchors.fill: parent
                                visible: PhantomState.isP3
                                radius: 8
                                color: cardDelegate.isHighlighted 
                                    ? Qt.rgba(0/255, 219/255, 255/255, 0.20) 
                                    : Qt.rgba(10/255, 20/255, 45/255, 0.85)
                                border.color: cardDelegate.isHighlighted ? "#00dbff" : Qt.rgba(0/255, 219/255, 255/255, 0.3)
                                border.width: cardDelegate.isHighlighted ? 2 : 1
                            }

                            // kartu latar miring untuk setiap opsi aksi (P5)
                            P5SkewedCard {
                                anchors.fill: parent
                                visible: !PhantomState.isP3
                                fillColor: cardDelegate.isHighlighted ? PhantomState.primary : "#13131C"
                                borderColor: cardDelegate.isHighlighted ? "#FFFFFF" : "#3E3E52"
                                shadowColor: cardDelegate.isHighlighted ? PhantomState.secondary : "#050508"
                                borderWidth: cardDelegate.isHighlighted ? 3 : 2
                                skewPx: PhantomState.polygonMode ? 9 : 0
                                shadowOffsetX: cardDelegate.isHighlighted ? 6 : 4
                                shadowOffsetY: cardDelegate.isHighlighted ? 6 : 4
                            }

                            // aksen diagonal internal pada kartu opsi (P5)
                            Canvas {
                                anchors.fill: parent
                                anchors.margins: 4
                                visible: !PhantomState.isP3
                                opacity: cardDelegate.isHighlighted ? 0.22 : 0.08
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.reset()
                                    ctx.fillStyle = cardDelegate.isHighlighted ? "#000000" : String(PhantomState.primary)
                                    ctx.beginPath()
                                    ctx.moveTo(0, height * 0.42)
                                    ctx.lineTo(width, height * 0.24)
                                    ctx.lineTo(width, height * 0.56)
                                    ctx.lineTo(0, height * 0.74)
                                    ctx.closePath()
                                    ctx.fill()
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                anchors.topMargin: 12
                                anchors.bottomMargin: 14
                                spacing: 6

                                // baris atas kode arcana dan pintasan angka
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Rectangle {
                                        height: 18
                                        width: arcanaTxt.implicitWidth + 10
                                        radius: PhantomState.isP3 ? 3 : 0
                                        color: cardDelegate.isHighlighted ? "#09090D" : (PhantomState.isP3 ? "#002c90" : "#222230")
                                        border.color: cardDelegate.isHighlighted ? PhantomState.secondary : (PhantomState.isP3 ? "#00dbff" : "#45455A")
                                        border.width: 1

                                        Text {
                                            id: arcanaTxt
                                            anchors.centerIn: parent
                                            text: cardDelegate.modelData.arcana
                                            color: cardDelegate.isHighlighted ? PhantomState.secondary : (PhantomState.isP3 ? "#00dbff" : PhantomState.muted)
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 8
                                            font.weight: Font.Black
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    Rectangle {
                                        width: 20
                                        height: 18
                                        radius: PhantomState.isP3 ? 3 : 0
                                        color: cardDelegate.isHighlighted ? (PhantomState.isP3 ? "#00dbff" : PhantomState.secondary) : "#1E1E2C"
                                        border.color: "#FFFFFF"
                                        border.width: 1
                                        rotation: PhantomState.isP3 ? 0 : 4

                                        Text {
                                            anchors.centerIn: parent
                                            text: cardDelegate.modelData.keyHint
                                            color: cardDelegate.isHighlighted ? "#09090D" : "#FFFFFF"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.weight: Font.Black
                                        }
                                    }
                                }

                                Item { Layout.fillHeight: true }

                                // emblem tengah dengan ikon aksi
                                Item {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 68
                                    Layout.preferredHeight: 68

                                    // Diamond P5
                                    Rectangle {
                                        anchors.centerIn: parent
                                        visible: !PhantomState.isP3
                                        width: 52
                                        height: 52
                                        rotation: 45
                                        color: cardDelegate.isHighlighted ? "#09090D" : "#1D1D2B"
                                        border.color: cardDelegate.isHighlighted ? PhantomState.secondary : PhantomState.primary
                                        border.width: 2.5

                                        Rectangle {
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            color: "transparent"
                                            border.color: "#FFFFFF"
                                            border.width: 1
                                            opacity: cardDelegate.isHighlighted ? 0.9 : 0.35
                                        }
                                    }

                                    // Rect P3
                                    Rectangle {
                                        anchors.centerIn: parent
                                        visible: PhantomState.isP3
                                        width: 52
                                        height: 52
                                        radius: 8
                                        color: cardDelegate.isHighlighted ? Qt.rgba(0/255, 219/255, 255/255, 0.28) : Qt.rgba(6/255, 12/255, 28/255, 0.6)
                                        border.color: cardDelegate.isHighlighted ? "#00dbff" : Qt.rgba(0/255, 219/255, 255/255, 0.4)
                                        border.width: 1.5
                                    }

                                    // Tampilkan iconpack Persona 3 jika ada
                                    Image {
                                        anchors.centerIn: parent
                                        visible: PhantomState.isP3 && cardDelegate.modelData.p3Icon !== ""
                                        source: cardDelegate.modelData.p3Icon || ""
                                        width: 44
                                        height: 44
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                    }

                                    // Tampilkan icon P5 umum jika bukan iconpack P3
                                    P5Icon {
                                        anchors.centerIn: parent
                                        visible: !PhantomState.isP3 || cardDelegate.modelData.p3Icon === ""
                                        name: cardDelegate.modelData.icon
                                        size: 24
                                        color: cardDelegate.isHighlighted ? (PhantomState.isP3 ? "#00dbff" : PhantomState.secondary) : "#FFFFFF"
                                    }
                                }

                                Item { Layout.fillHeight: true }

                                // pita label utama dan deskripsi sub-aksi di bagian bawah kartu
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 28
                                        color: cardDelegate.isHighlighted ? (PhantomState.isP3 ? "#00dbff" : "#FFFFFF") : "#0A0A10"
                                        border.color: cardDelegate.isHighlighted ? (PhantomState.isP3 ? "#00dbff" : "#09090D") : (PhantomState.isP3 ? Qt.rgba(0/255, 219/255, 255/255, 0.4) : "#FFFFFF")
                                        border.width: 1.5
                                        radius: PhantomState.isP3 ? 4 : 0
                                        rotation: PhantomState.isP3 ? 0 : (cardDelegate.isHighlighted ? -2.2 : 0)

                                        Behavior on rotation { NumberAnimation { duration: 150 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: cardDelegate.modelData.label
                                            color: cardDelegate.isHighlighted ? "#09090D" : "#FFFFFF"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 13
                                            font.weight: Font.Black
                                            font.italic: !PhantomState.isP3
                                        }
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: PhantomState.isP3 ? cardDelegate.modelData.p3Sub : cardDelegate.modelData.sub
                                        color: cardDelegate.isHighlighted ? (PhantomState.isP3 ? "#00dbff" : "#FFFFFF") : PhantomState.muted
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 8
                                        font.weight: Font.Black
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                id: btnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: {
                                    sessionWin.selectedIndex = cardDelegate.index
                                    PhantomState.playSfx("select")
                                }
                                onClicked: sessionWin.triggerAction(cardDelegate.index)
                            }
                        }
                    }
                }

                // bilah informasi pintasan dan target aktif di bagian bawah
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34

                    Rectangle {
                        anchors.fill: parent
                        visible: PhantomState.isP3
                        radius: 6
                        color: Qt.rgba(8/255, 18/255, 42/255, 0.85)
                        border.color: Qt.rgba(0/255, 219/255, 255/255, 0.35)
                        border.width: 1
                    }

                    P5SkewedCard {
                        anchors.fill: parent
                        visible: !PhantomState.isP3
                        fillColor: "#14141E"
                        borderColor: "#36364A"
                        shadowColor: "#050508"
                        borderWidth: 1.5
                        skewPx: 8
                        shadowOffsetX: 3
                        shadowOffsetY: 3
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 10

                        Rectangle {
                            width: 10
                            height: 10
                            radius: PhantomState.isP3 ? 5 : 0
                            rotation: PhantomState.isP3 ? 0 : 45
                            color: PhantomState.isP3 ? "#00dbff" : PhantomState.primary
                        }

                        Text {
                            text: "NAVIGATE [←/→] • EXECUTE [ENTER / 1-5] • DISMISS [ESC]"
                            color: PhantomState.muted
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Black
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "TARGET // " + sessionWin.actionsModel[sessionWin.selectedIndex].label
                            color: PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 11
                            font.weight: Font.Black
                            font.italic: true
                        }
                    }
                }
            }
        }

        // ── Menu Jeda & Daya Layar Penuh Otentik Persona 3 Reload (P3rpause Engine) ──
        Item {
            id: p3Overlay
            anchors.fill: parent
            visible: PhantomState.isP3 && (PhantomState.sessionOpen || opacity > 0.01)
            opacity: PhantomState.sessionOpen ? 1.0 : 0.0
            Behavior on opacity {
                enabled: !PhantomState.sessionOpen
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            property int stage: 0
            property string currentSection: PhantomState.p3SessionSection
            property string targetSection: "main"
            property bool showThemeConfirm: false
            property int selectedThemeIndex: 0
            property int statsTab: PhantomState.p3StatsTab
            onStatsTabChanged: {
                if (PhantomState.p3StatsTab !== statsTab) {
                    PhantomState.p3StatsTab = statsTab
                }
            }
            property int configTab: 0

            readonly property var p3ThemesData: [
                {
                    id: "p3-reload",
                    tabLabel: "P3 RELOAD",
                    name: "PERSONA 3 RELOAD",
                    role: "LEADER // MAKOTO YUKI",
                    heroName: "Makoto Yuki",
                    desc: "Tartarus Oceanic Modernism • S.E.E.S. Evoker Protocol",
                    lore: "Awaken persona under the Dark Hour. Tactical modernism with deep ocean blue and neon cyan accents.",
                    accent: "#00dbff",
                    heroBgColor: "#0055ff",
                    heroPortrait: Qt.resolvedUrl("../../assets/themes/p3/components/modal_hero_p3.png"),
                    charImg: Qt.resolvedUrl("../../assets/themes/p3/components/card_face_p3.png")
                },
                {
                    id: "p5-crimson",
                    tabLabel: "P5 ROYAL",
                    name: "PERSONA 5 ROYAL",
                    role: "TRICKSTER // REN AMAMIYA",
                    heroName: "Ren Amamiya",
                    desc: "Metaverse Royal Rebellion • Neo-Tokyo Shujin Aesthetic",
                    lore: "Steal the distorted desires of corrupt adults. Bold neo-punk aesthetics with stark monochrome and razor crimson accents.",
                    accent: "#ff2a4b",
                    heroBgColor: "#c4001a",
                    heroPortrait: Qt.resolvedUrl("../../assets/themes/p3/components/modal_hero_p5.png"),
                    charImg: Qt.resolvedUrl("../../assets/themes/p3/components/card_face_p5.png")
                },
                {
                    id: "p4-golden",
                    tabLabel: "P4 GOLDEN",
                    name: "PERSONA 4 GOLDEN",
                    role: "SEEKER // YU NARUKAMI",
                    heroName: "Yu Narukami",
                    desc: "Yasogami Retro Amber • Midnight Channel Investigation",
                    lore: "Reach out to the truth through the Midnight Channel. Retro television vibes with radiant amber gold accents.",
                    accent: "#f5b800",
                    heroBgColor: "#d99b00",
                    heroPortrait: Qt.resolvedUrl("../../assets/themes/p3/components/modal_hero_p4.png"),
                    charImg: Qt.resolvedUrl("../../assets/themes/p3/components/card_face_p4.png")
                }
            ]

            function navigateTo(sec) {
                if (sec === currentSection) return
                targetSection = sec
                showThemeConfirm = false

                if (sec === "main") {
                    if (currentSection === "dispatch" || currentSection === "power") {
                        currentSection = "main"
                    } else {
                        p3SectionVideo.stop()
                        p3StatsVideo.stop()
                        p3ConfigVideo.stop()
                        p3ControlVideo.stop()
                        p3ArchiveVideo.stop()
                        p3Part3Video.stop()
                        currentSection = "main"
                        stage = 1
                        p3Part2Video.position = 0
                        p3Part2Video.play()
                    }
                } else if (sec === "dispatch" || sec === "power") {
                    currentSection = sec
                } else if (sec === "palette") {
                    p3WipeTransition.trigger()
                } else if (sec === "stats" || sec === "network" || sec === "bluetooth") {
                    if (sec === "network") statsTab = 1
                    else if (sec === "bluetooth") statsTab = 2
                    else statsTab = 0
                    p3StatsTransition.trigger()
                } else if (sec === "config") {
                    p3ConfigTransition.trigger()
                } else if (sec === "control") {
                    p3ControlTransition.trigger()
                } else if (sec === "archive") {
                    p3ArchiveTransition.trigger()
                }
            }
            onCurrentSectionChanged: {
                if (PhantomState.p3SessionSection !== currentSection) {
                    PhantomState.p3SessionSection = currentSection
                }
                if (currentSection === "main") {
                    p3SectionVideo.stop()
                    p3StatsVideo.stop()
                    p3ConfigVideo.stop()
                    p3ControlVideo.stop()
                    p3ArchiveVideo.stop()
                } else if (currentSection === "dispatch" || currentSection === "power") {
                    p3SectionVideo.stop()
                    p3StatsVideo.stop()
                    p3ConfigVideo.stop()
                    p3ControlVideo.stop()
                    p3ArchiveVideo.stop()
                    if (stage >= 2 && p3Part3Video.playbackState !== MediaPlayer.PlayingState) {
                        p3Part3Video.play()
                    }
                } else if (currentSection === "palette") {
                    p3Part2Video.stop()
                    p3Part3Video.pause()
                    p3StatsVideo.stop()
                    p3ConfigVideo.stop()
                    p3ControlVideo.stop()
                    p3ArchiveVideo.stop()
                    p3SectionVideo.position = 0
                    p3SectionVideo.play()
                } else if (currentSection === "stats" || currentSection === "network" || currentSection === "bluetooth") {
                    p3Part2Video.stop()
                    p3Part3Video.pause()
                    p3SectionVideo.stop()
                    p3ConfigVideo.stop()
                    p3ControlVideo.stop()
                    p3ArchiveVideo.stop()
                    p3StatsVideo.position = 0
                    p3StatsVideo.play()
                    PhantomState.pollStats = true
                    PhantomState.refreshSystemDossier()
                } else if (currentSection === "config") {
                    p3Part2Video.stop()
                    p3Part3Video.pause()
                    p3SectionVideo.stop()
                    p3StatsVideo.stop()
                    p3ControlVideo.stop()
                    p3ArchiveVideo.stop()
                    p3ConfigVideo.position = 0
                    p3ConfigVideo.play()
                } else if (currentSection === "control") {
                    p3Part2Video.stop()
                    p3Part3Video.pause()
                    p3SectionVideo.stop()
                    p3StatsVideo.stop()
                    p3ConfigVideo.stop()
                    p3ArchiveVideo.stop()
                    p3ControlVideo.position = 0
                    p3ControlVideo.play()
                } else if (currentSection === "archive") {
                    p3Part2Video.stop()
                    p3Part3Video.pause()
                    p3SectionVideo.stop()
                    p3StatsVideo.stop()
                    p3ConfigVideo.stop()
                    p3ControlVideo.stop()
                    p3ArchiveVideo.position = 0
                    p3ArchiveVideo.play()
                    PhantomState.refreshSystemDossier()
                }
            }

            Connections {
                target: PhantomState
                function onSessionOpenChanged() {
                    if (PhantomState.sessionOpen && PhantomState.isP3) {
                        p3Overlay.resetMenu()
                    } else if (!PhantomState.sessionOpen && PhantomState.isP3) {
                        p3Part2Video.stop()
                        p3Part3Video.stop()
                        p3SectionVideo.stop()
                        p3StatsVideo.stop()
                        p3ConfigVideo.stop()
                        p3ControlVideo.stop()
                        p3ArchiveVideo.stop()
                        p3FrameAnim.stop()
                        PhantomState.pollStats = false
                    }
                }
                function onP3SessionSectionChanged() {
                    if (p3Overlay.currentSection !== PhantomState.p3SessionSection) {
                        p3Overlay.navigateTo(PhantomState.p3SessionSection)
                    }
                }
                function onP3StatsTabChanged() {
                    if (p3Overlay.statsTab !== PhantomState.p3StatsTab) {
                        p3Overlay.statsTab = PhantomState.p3StatsTab
                    }
                }
                function onP3ThemeConfirmChanged() {
                    if (PhantomState.p3ThemeConfirm) {
                        if (!PhantomState.sessionOpen) PhantomState.sessionOpen = true
                        p3Overlay.currentSection = "palette"
                        p3Overlay.selectedThemeIndex = PhantomState.p3ThemeConfirmIdx
                        p3Overlay.showThemeConfirm = true
                        PhantomState.p3ThemeConfirm = false
                    }
                }
            }

            Component.onCompleted: {
                p3Part2Video.position = 0
                p3Part3Video.position = 0
                p3SectionVideo.position = 0
                p3StatsVideo.position = 0
            }

            function resetMenu() {
                stage = 0
                currentSection = "main"
                targetSection = "main"
                showThemeConfirm = false
                selectedThemeIndex = 0
                statsTab = 0
                p3WipeTransition.running = false
                p3WipeTransition.opacity = 0
                p3StatsTransition.running = false
                p3StatsTransition.opacity = 0

                p3PngSequence.currentFrame = 0
                p3PngSequence.visible = true

                p3Part2Video.stop()
                p3Part2Video.position = 0
                p3Part3Video.stop()
                p3Part3Video.position = 0
                p3SectionVideo.stop()
                p3SectionVideo.position = 0
                p3StatsVideo.stop()
                p3StatsVideo.position = 0
                p3ConfigVideo.stop()
                p3ConfigVideo.position = 0
                p3ControlVideo.stop()
                p3ControlVideo.position = 0
                p3ArchiveVideo.stop()
                p3ArchiveVideo.position = 0

                p3ConfigTransition.running = false
                p3ConfigTransition.opacity = 0
                p3ControlTransition.running = false
                p3ControlTransition.opacity = 0
                p3ArchiveTransition.running = false
                p3ArchiveTransition.opacity = 0

                p3FrameAnim.restart()
                PhantomState.refreshWifi()
                PhantomState.refreshBluetooth()
            }

            // Latar Biru Samudra Pekat (Hanya aktif saat stage >= 1, sehingga stage 0 transparan memperlihatkan desktop)
            Rectangle {
                anchors.fill: parent
                color: "#0048aa"
                visible: p3Overlay.stage >= 1
                z: 0
            }

            // Poster Frame 0 Part 2 (Grounded underwater frame to eliminate decode flash)
            Image {
                id: p3PosterPart2
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/p3r menu/part2_poster.png")
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
                visible: p3Overlay.stage === 1 && (p3Overlay.currentSection === "main" || p3Overlay.currentSection === "dispatch" || p3Overlay.currentSection === "power")
                z: 1
            }

            // Lapisan Poster Bawah Air Statis
            Image {
                id: p3PosterBase
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/p3r menu/part3_poster.png")
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
                visible: false
                z: 2
            }

            // Stage 0: Animasi Shatter Kaca Intro (12 Frame - Optimized 8-bit PNG)
            Image {
                id: p3PngSequence
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                visible: false
                asynchronous: false
                cache: true
                z: 6
                property int currentFrame: 0
                property int totalFrames: 12
                property int frameRate: 35
                source: Qt.resolvedUrl("../../assets/themes/p3/p3r menu/png/pngseq" + String(currentFrame).padStart(2, '0') + ".png")

                Timer {
                    id: p3FrameAnim
                    interval: 1000 / p3PngSequence.frameRate
                    repeat: true
                    running: false
                    onTriggered: {
                        if (p3PngSequence.currentFrame < p3PngSequence.totalFrames - 1) {
                            p3PngSequence.currentFrame++
                        } else {
                            stop()
                            p3PngSequence.visible = false
                            p3Overlay.stage = 1
                            p3Part2Video.position = 0
                            p3Part2Video.play()
                        }
                    }
                }
            }

            // Stage 1: Video Animasi Makoto Yuki Tenggelam ke Bawah Air (1080p 60fps Pristine)
            Video {
                id: p3Part2Video
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/p3r menu/part2_60fps.mp4")
                fillMode: VideoOutput.PreserveAspectCrop
                volume: 0
                visible: p3Overlay.stage === 1 && (p3Overlay.currentSection === "main" || p3Overlay.currentSection === "dispatch" || p3Overlay.currentSection === "power")
                z: 4

                onVisibleChanged: {
                    if (visible) {
                        if (playbackState !== MediaPlayer.PlayingState) {
                            play()
                        }
                    }
                }
                onPositionChanged: {
                    if (duration > 0 && position >= duration - 50 && p3Overlay.stage === 1 && (p3Overlay.currentSection === "main" || p3Overlay.currentSection === "dispatch" || p3Overlay.currentSection === "power")) {
                        p3Overlay.stage = 2
                        p3Part3Video.position = 0
                        p3Part3Video.play()
                    }
                }
                onPlaybackStateChanged: {
                    if (playbackState === MediaPlayer.StoppedState && p3Overlay.stage === 1 && (p3Overlay.currentSection === "main" || p3Overlay.currentSection === "dispatch" || p3Overlay.currentSection === "power")) {
                        p3Overlay.stage = 2
                        p3Part3Video.position = 0
                        p3Part3Video.play()
                    }
                }
                onErrorOccurred: (error, errorString) => {
                    console.warn("[P3 VIDEO ERROR]", error, errorString)
                    p3Overlay.stage = 2
                    p3Part3Video.position = 0
                    p3Part3Video.play()
                }
            }

            // Stage 2: Video Animasi Mengambang Terus Menerus di Bawah Air (1080p 60fps Pristine Ping-Pong Loop)
            Video {
                id: p3Part3Video
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/p3r menu/part3_60fps.mp4")
                fillMode: VideoOutput.PreserveAspectCrop
                loops: MediaPlayer.Infinite
                volume: 0
                visible: p3Overlay.stage >= 2 && (p3Overlay.currentSection === "main" || p3Overlay.currentSection === "dispatch" || p3Overlay.currentSection === "power")
                z: 4

                onVisibleChanged: {
                    if (visible) {
                        if (playbackState !== MediaPlayer.PlayingState) {
                            play()
                        }
                    } else {
                        stop()
                    }
                }
            }

            // Lapisan Poster Section Sub-Menu
            Image {
                id: p3PosterSection
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/videos/options_poster.png")
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
                visible: false
                z: 2
            }

            // Video Animasi Section Sub-Menu (Options_60fps.mp4: S.E.E.S. 1080p 60fps Pristine Ping-Pong Loop)
            Video {
                id: p3SectionVideo
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/videos/Options_60fps.mp4")
                fillMode: VideoOutput.PreserveAspectCrop
                loops: MediaPlayer.Infinite
                volume: 0
                visible: p3Overlay.currentSection === "palette"
                z: 4

                onVisibleChanged: {
                    if (visible) play()
                    else stop()
                }
            }

            // Video Animasi Section Stats/List (Resume_60fps.mp4: Makoto Yuki Headphone & Butterflies 1080p 60fps Pristine Ping-Pong Loop)
            Video {
                id: p3StatsVideo
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/videos/Resume_60fps.mp4")
                fillMode: VideoOutput.PreserveAspectCrop
                loops: MediaPlayer.Infinite
                volume: 0
                visible: p3Overlay.currentSection === "stats" || p3Overlay.currentSection === "network" || p3Overlay.currentSection === "bluetooth"
                z: 4

                onVisibleChanged: {
                    if (visible) play()
                    else stop()
                }
            }

            // Video Animasi Section System Config (skills_ambient.mp4: Makoto Evoker & Skills Geometric 60fps Loop)
            Video {
                id: p3ConfigVideo
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/videos/skills_ambient.mp4")
                fillMode: VideoOutput.PreserveAspectCrop
                loops: MediaPlayer.Infinite
                volume: 0
                visible: p3Overlay.currentSection === "config"
                z: 4

                onVisibleChanged: {
                    if (visible) play()
                    else stop()
                }
            }

            // Video Animasi Section Control Center (fuuka_ambient.mp4: Fuuka Yamagishi S.E.E.S. Tactical Navigator 60fps Loop)
            Video {
                id: p3ControlVideo
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/videos/fuuka_ambient.mp4")
                fillMode: VideoOutput.PreserveAspectCrop
                loops: MediaPlayer.Infinite
                volume: 0
                visible: p3Overlay.currentSection === "control"
                z: 4

                onVisibleChanged: {
                    if (visible) play()
                    else stop()
                }
            }

            // Video Animasi Section S.E.E.S. Archive (dorm_ambient.mp4: S.E.E.S. Squad Iwatodai Dormitory Dark Hour 60fps Loop)
            Video {
                id: p3ArchiveVideo
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/videos/dorm_ambient.mp4")
                fillMode: VideoOutput.PreserveAspectCrop
                loops: MediaPlayer.Infinite
                volume: 0
                visible: p3Overlay.currentSection === "archive"
                z: 4

                onVisibleChanged: {
                    if (visible) play()
                    else stop()
                }
            }

            // ── Pusat Menu Game Taktis Lengkap Beranak (S.E.E.S. Tactical Hub - Aktif langsung saat stage >= 1) ──
            Item {
                id: p3TacticalHub
                anchors.fill: parent
                visible: p3Overlay.stage >= 1
                z: 10

                // ── LEVEL 0: MENU UTAMA TINGKAT PERTAMA (Pola Polished Atlus Persona 3 Reload - 6 Menu Lengkap) ──
                Item {
                    id: p3MainMenuContainer
                    visible: p3Overlay.currentSection === "main"
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 240
                    anchors.verticalCenterOffset: 0
                    width: 920
                    height: 700

                    P3PowerItem {
                        offsetY: -250
                        itemRotation: 3
                        itemWidth: 800
                        itemHeight: 220
                        offsetX: 20
                        normalIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_stats.png")
                        hoverIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_stats1.png")
                        action: () => { p3Overlay.navigateTo("stats") }
                    }

                    P3PowerItem {
                        offsetY: -150
                        itemRotation: -4
                        itemWidth: 800
                        itemHeight: 220
                        offsetX: 40
                        normalIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_config.png")
                        hoverIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_config1.png")
                        action: () => { p3Overlay.navigateTo("config") }
                    }

                    P3PowerItem {
                        offsetY: -50
                        itemRotation: 2
                        itemWidth: 800
                        itemHeight: 220
                        offsetX: 10
                        normalIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_control.png")
                        hoverIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_control1.png")
                        action: () => { p3Overlay.navigateTo("control") }
                    }

                    P3PowerItem {
                        offsetY: 50
                        itemRotation: -3
                        itemWidth: 800
                        itemHeight: 220
                        offsetX: 50
                        normalIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_palette.png")
                        hoverIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_palette1.png")
                        action: () => { p3Overlay.navigateTo("palette") }
                    }

                    P3PowerItem {
                        offsetY: 150
                        itemRotation: 2
                        itemWidth: 800
                        itemHeight: 220
                        offsetX: 20
                        normalIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_archive.png")
                        hoverIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_archive1.png")
                        action: () => { p3Overlay.navigateTo("archive") }
                    }

                    P3PowerItem {
                        offsetY: 250
                        itemRotation: -3
                        itemWidth: 800
                        itemHeight: 220
                        offsetX: 40
                        normalIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_dispatch.png")
                        hoverIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/p3_v4_dispatch1.png")
                        action: () => { p3Overlay.navigateTo("dispatch") }
                    }
                }

                // ── LEVEL 1: SUB-MENU POWER / DISPATCH (3 Tombol Ikonik Asli P3) ──
                Item {
                    id: p3DispatchSubMenu
                    visible: p3Overlay.currentSection === "dispatch" || p3Overlay.currentSection === "power"
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 50
                    anchors.verticalCenterOffset: 10
                    width: 800
                    height: 520

                    P3PowerItem {
                        offsetY: -140
                        itemRotation: 3
                        normalIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/shutdown.png")
                        hoverIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/shutdown1.png")
                        action: () => {
                            PhantomState.playSfx("select")
                            PhantomState.sessionOpen = false
                            Quickshell.execDetached(["systemctl", "poweroff"])
                        }
                    }
                    P3PowerItem {
                        offsetY: 0
                        itemRotation: -5
                        normalIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/restart.png")
                        hoverIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/restart1.png")
                        action: () => {
                            PhantomState.playSfx("select")
                            PhantomState.sessionOpen = false
                            Quickshell.execDetached(["systemctl", "reboot"])
                        }
                    }
                    P3PowerItem {
                        offsetY: 140
                        itemRotation: -12
                        normalIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/logout.png")
                        hoverIcon: Qt.resolvedUrl("../../assets/themes/p3/iconpack/logout1.png")
                        action: () => {
                            PhantomState.playSfx("select")
                            PhantomState.sessionOpen = false
                            Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
                        }
                    }

                    // Tombol Kembali ke Menu Utama Bergaya Atlus
                    Item {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -35
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 100
                        width: 260
                        height: 48

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            scale: dispatchBackMouse.containsMouse ? 1.08 : 1.0
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                            Text {
                                text: "◄"
                                font.family: "Rubik"
                                font.pixelSize: 20
                                font.weight: Font.Black
                                font.italic: true
                                color: dispatchBackMouse.containsMouse ? "#ffffff" : "#65e7ff"
                            }
                            Text {
                                text: "RETURN TO MENU"
                                font.family: "Rubik"
                                font.pixelSize: 22
                                font.weight: Font.Black
                                font.italic: true
                                color: dispatchBackMouse.containsMouse ? "#ffffff" : "#65e7ff"
                            }
                        }

                        MouseArea {
                            id: dispatchBackMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: PhantomState.playSfx("select")
                            onClicked: {
                                PhantomState.playSfx("select")
                                p3Overlay.navigateTo("main")
                            }
                        }
                    }
                }

                // ── LEVEL 1: SUB-MENU METAVERSE ERAS (KARTU KARAKTER HERO) ──
                Item {
                    id: p3PaletteSubMenu
                    visible: p3Overlay.currentSection === "palette"
                    anchors.left: parent.left
                    anchors.leftMargin: 80
                    anchors.verticalCenter: parent.verticalCenter
                    width: 580
                    height: 520

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            text: "METAVERSE ERAS // HERO TIMELINE SELECTOR"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 12
                            font.weight: Font.Black
                            color: "#00dbff"
                        }

                        Repeater {
                            model: p3Overlay.p3ThemesData

                            delegate: Item {
                                id: cCard
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 76

                                readonly property bool isSelected: PhantomState.themeId === modelData.id
                                readonly property bool isHovered: cMouse.containsMouse

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 2
                                    clip: true
                                    color: (cCard.isSelected || cCard.isHovered) ? "#ffffff" : "#091326"
                                    border.color: (cCard.isSelected || cCard.isHovered) ? "#e60012" : Qt.rgba(0/255, 219/255, 255/255, 0.3)
                                    border.width: (cCard.isSelected || cCard.isHovered) ? 2 : 1
                                    scale: cCard.isHovered ? 1.02 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    // Garis Aksen Merah Atlus di Bagian Atas Saat Aktif / Hovered (Sesuai Foto 3)
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: 4
                                        color: "#e60012"
                                        visible: cCard.isSelected || cCard.isHovered
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        // Badge Kiri (Role + Strip Wajah Karakter Sesuai Foto 3)
                                        Item {
                                            Layout.preferredWidth: 100
                                            Layout.fillHeight: true

                                            Rectangle {
                                                anchors.fill: parent
                                                color: "#050b18"

                                                Image {
                                                    anchors.fill: parent
                                                    source: modelData.charImg
                                                    fillMode: Image.PreserveAspectCrop
                                                    smooth: true
                                                    opacity: (cCard.isSelected || cCard.isHovered) ? 1.0 : 0.75
                                                }

                                                Rectangle {
                                                    anchors.top: parent.top
                                                    anchors.left: parent.left
                                                    anchors.margins: 4
                                                    width: 38
                                                    height: 18
                                                    color: (cCard.isSelected || cCard.isHovered) ? "#e60012" : "#0a1936"
                                                    radius: 2

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.role.substring(0, 3)
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 10
                                                        font.weight: Font.Black
                                                        color: "#ffffff"
                                                    }
                                                }
                                            }
                                        }

                                        // Body Kartu (Teks & Status)
                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 16
                                                anchors.rightMargin: 16
                                                spacing: 12

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 3

                                                    Text {
                                                        text: modelData.name
                                                        font.family: "Rubik"
                                                        font.pixelSize: 16
                                                        font.weight: Font.Black
                                                        font.italic: true
                                                        color: (cCard.isSelected || cCard.isHovered) ? "#020718" : "#ffffff"
                                                    }
                                                    Text {
                                                        text: modelData.desc
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 9
                                                        font.weight: Font.Bold
                                                        color: (cCard.isSelected || cCard.isHovered) ? "#d31027" : "#65e7ff"
                                                        elide: Text.ElideRight
                                                    }
                                                }

                                                Rectangle {
                                                    Layout.preferredWidth: 84
                                                    Layout.preferredHeight: 26
                                                    radius: 2
                                                    color: cCard.isSelected
                                                        ? ((cCard.isSelected || cCard.isHovered) ? "#020718" : "#00dbff")
                                                        : ((cCard.isSelected || cCard.isHovered) ? "#e60012" : Qt.rgba(2/255, 7/255, 24/255, 0.7))
                                                    border.color: cCard.isSelected
                                                        ? ((cCard.isSelected || cCard.isHovered) ? "#020718" : "#00dbff")
                                                        : ((cCard.isSelected || cCard.isHovered) ? "#e60012" : Qt.rgba(0/255, 219/255, 255/255, 0.5))
                                                    border.width: 1

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: cCard.isSelected ? "ACTIVE ✓" : (cCard.isHovered ? "SELECT" : "ACTIVATE")
                                                        font.family: "JetBrainsMono NFM"
                                                        font.pixelSize: 10
                                                        font.weight: Font.Black
                                                        color: cCard.isSelected
                                                            ? ((cCard.isSelected || cCard.isHovered) ? "#ffffff" : "#020718")
                                                            : "#ffffff"
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: cMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.playSfx("select")
                                            p3Overlay.selectedThemeIndex = index
                                            p3Overlay.showThemeConfirm = true
                                        }
                                    }
                                }
                            }
                        }

                        // Tombol Kembali Bergaya Atlus (Rata Kiri)
                        Item {
                            Layout.preferredWidth: 260
                            Layout.preferredHeight: 46
                            Layout.alignment: Qt.AlignLeft

                            RowLayout {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8
                                scale: palBackMouse.containsMouse ? 1.08 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                                Text {
                                    text: "◄"
                                    font.family: "Rubik"
                                    font.pixelSize: 20
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: palBackMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                                Text {
                                    text: "RETURN TO MENU"
                                    font.family: "Rubik"
                                    font.pixelSize: 22
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: palBackMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                            }

                            MouseArea {
                                id: palBackMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: PhantomState.playSfx("select")
                                onClicked: {
                                    PhantomState.playSfx("select")
                                    p3Overlay.navigateTo("main")
                                }
                            }
                        }
                    }
                }

                // ── LEVEL 1: SUB-MENU STATS / LIST (PURE HARDWARE & SYSTEM TELEMETRY) ──
                Item {
                    id: p3StatsSubMenu
                    visible: p3Overlay.currentSection === "stats"
                    anchors.fill: parent

                    readonly property var listCategories: [
                        { badge: "I",   title: "Core Telemetry",   subtitle: "Hardware Sensors & Load Matrix", rank: "MAX" },
                        { badge: "II",  title: "Memory & Storage", subtitle: "RAM Allocation & Disk Mounts",   rank: "VIII" },
                        { badge: "III", title: "Thermals & Power", subtitle: "Core Thermal & AC Power Matrix", rank: "VII" },
                        { badge: "IV",  title: "GPU & Displays",   subtitle: "Graphics Pipeline & Wayland HUD", rank: "IX" }
                    ]

                    // Kolom Kiri: Judul "LIST", 4 Kartu Rank P3, dan Tombol Kembali
                    Item {
                        anchors.left: parent.left
                        anchors.leftMargin: 60
                        anchors.verticalCenter: parent.verticalCenter
                        width: 580
                        height: 640

                        Column {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            spacing: 12

                            Text {
                                text: "LIST"
                                font.family: "Bebas Neue"
                                font.pixelSize: 52
                                font.bold: true
                                color: "#f6fbff"
                                leftPadding: 8
                            }

                            Repeater {
                                model: p3StatsSubMenu.listCategories
                                delegate: Item {
                                    id: cardWrap
                                    required property var modelData
                                    required property int index
                                    width: 560
                                    height: isActive ? 80 : 68
                                    x: isActive ? 12 : (isHovered ? 8 : 0)
                                    readonly property bool isActive: p3Overlay.statsTab === index
                                    readonly property bool isHovered: cardMouse.containsMouse

                                    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                                    Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                                    Canvas {
                                        id: cardCanvas
                                        anchors.fill: parent
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.clearRect(0, 0, width, height);
                                            // Kartu Poligon Miring P3
                                            ctx.beginPath();
                                            ctx.moveTo(0, 0);
                                            ctx.lineTo(width * 0.96, 0);
                                            ctx.lineTo(width, height);
                                            ctx.lineTo(width * 0.03, height);
                                            ctx.closePath();
                                            ctx.fillStyle = cardWrap.isActive ? "#8df6ff" : (cardWrap.isHovered ? "rgba(18, 48, 125, 0.96)" : "rgba(8, 24, 75, 0.88)");
                                            ctx.fill();
                                            if (!cardWrap.isActive) {
                                                ctx.strokeStyle = cardWrap.isHovered ? "#00ffff" : "rgba(0, 219, 255, 0.4)";
                                                ctx.lineWidth = cardWrap.isHovered ? 2.5 : 1.5;
                                                ctx.stroke();
                                            }

                                            // Bayangan bawah tebal
                                            ctx.beginPath();
                                            ctx.moveTo(width * 0.03, height);
                                            ctx.lineTo(width, height);
                                            ctx.lineTo(width + 6, height + 4);
                                            ctx.lineTo(width * 0.03 + 6, height + 4);
                                            ctx.closePath();
                                            ctx.fillStyle = cardWrap.isActive ? "#62d6e6" : (cardWrap.isHovered ? "#00b4d8" : "rgba(3, 10, 36, 0.75)");
                                            ctx.fill();
                                        }
                                        onWidthChanged: requestPaint()
                                        onHeightChanged: requestPaint()
                                        Connections {
                                            target: cardWrap
                                            function onIsActiveChanged() { cardCanvas.requestPaint() }
                                            function onIsHoveredChanged() { cardCanvas.requestPaint() }
                                        }
                                        Connections {
                                            target: p3Overlay
                                            function onCurrentSectionChanged() { cardCanvas.requestPaint() }
                                        }
                                    }

                                    // Lencana Angka Romawi Miring (I s.d. VI)
                                    Rectangle {
                                        x: -4
                                        y: 6
                                        width: 38
                                        height: 42
                                        color: cardWrap.isActive ? "#000000" : (cardWrap.isHovered ? "#0a1e50" : "#071238")
                                        border.color: cardWrap.isActive ? "#000000" : (cardWrap.isHovered ? "#00ffff" : "#8df6ff")
                                        border.width: cardWrap.isHovered ? 2.5 : 2.0
                                        rotation: -6

                                        Text {
                                            anchors.centerIn: parent
                                            text: cardWrap.modelData.badge
                                            font.family: "Bebas Neue"
                                            font.pixelSize: 19
                                            font.bold: true
                                            color: cardWrap.isActive ? "#ffffff" : (cardWrap.isHovered ? "#ffffff" : "#d2fdff")
                                            rotation: 6
                                        }
                                    }

                                    // Judul Kategori
                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 52
                                        anchors.top: parent.top
                                        anchors.topMargin: 6
                                        text: cardWrap.modelData.title
                                        font.family: "Rubik"
                                        font.pixelSize: 22
                                        font.weight: Font.Black
                                        color: cardWrap.isActive ? "#041238" : (cardWrap.isHovered ? "#ffffff" : "#8df6ff")
                                    }

                                    // Badge Rank di Kanan Atas
                                    Row {
                                        anchors.right: parent.right
                                        anchors.rightMargin: 18
                                        anchors.top: parent.top
                                        anchors.topMargin: 4
                                        spacing: 4

                                        Text {
                                            text: "RANK"
                                            font.family: "Bebas Neue"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: cardWrap.isActive ? "#041238" : (cardWrap.isHovered ? "#00ffff" : "#8df6ff")
                                            anchors.bottom: parent.bottom
                                            bottomPadding: 3
                                        }
                                        Text {
                                            text: cardWrap.modelData.rank
                                            font.family: "Bebas Neue"
                                            font.pixelSize: 28
                                            font.bold: true
                                            color: cardWrap.isActive ? "#041238" : (cardWrap.isHovered ? "#ffffff" : "#8df6ff")
                                        }
                                    }

                                    // Banner Subtitle Miring di Bagian Bawah Kartu
                                    Canvas {
                                        id: subtitleCanvas
                                        anchors.left: parent.left
                                        anchors.leftMargin: 50
                                        anchors.right: parent.right
                                        anchors.rightMargin: 16
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 6
                                        height: 20
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.clearRect(0, 0, width, height);
                                            ctx.beginPath();
                                            ctx.moveTo(0, 0);
                                            ctx.lineTo(width, 0);
                                            ctx.lineTo(width - 8, height);
                                            ctx.lineTo(0, height);
                                            ctx.closePath();
                                            ctx.fillStyle = cardWrap.isActive ? "#000000" : (cardWrap.isHovered ? "#9df0ff" : "#65e7ff");
                                            ctx.fill();
                                        }
                                        onWidthChanged: requestPaint()
                                        Connections {
                                            target: cardWrap
                                            function onIsActiveChanged() { subtitleCanvas.requestPaint() }
                                            function onIsHoveredChanged() { subtitleCanvas.requestPaint() }
                                        }

                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            text: cardWrap.modelData.subtitle
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                            color: cardWrap.isActive ? "#ffffff" : "#041238"
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: cardMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: {
                                            if (!cardWrap.isActive) PhantomState.playSfx("select")
                                        }
                                        onClicked: {
                                            PhantomState.playSfx("confirm")
                                            p3Overlay.statsTab = cardWrap.index
                                        }
                                    }
                                }
                            }
                        }

                        // Tombol Kembali ke Menu Utama
                        Item {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            width: 260
                            height: 40

                            RowLayout {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8
                                scale: statsReturnMouse.containsMouse ? 1.08 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                                Text {
                                    text: "◄"
                                    font.family: "Rubik"
                                    font.pixelSize: 16
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: statsReturnMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                                Text {
                                    text: "RETURN TO MENU"
                                    font.family: "Rubik"
                                    font.pixelSize: 18
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: statsReturnMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                            }

                            MouseArea {
                                id: statsReturnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: PhantomState.playSfx("select")
                                onClicked: {
                                    PhantomState.playSfx("select")
                                    p3Overlay.navigateTo("main")
                                }
                            }
                        }
                    }

                    // Kolom Kanan: Detail Panel Kaca P3 (Sesuai Foto 1 & P3R Asli)
                    Rectangle {
                        id: statsDetailPanel
                        anchors.right: parent.right
                        anchors.rightMargin: 70
                        anchors.verticalCenter: parent.verticalCenter
                        width: 470
                        height: 560
                        color: Qt.rgba(5 / 255, 14 / 255, 40 / 255, 0.92)
                        radius: 4
                        border.color: Qt.rgba(0 / 255, 219 / 255, 255 / 255, 0.35)
                        border.width: 1
                        clip: true

                        // Banner Header Detail Slanted Cyan (Sesuai Foto 1)
                        Canvas {
                            id: statsDetailHeaderCanvas
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 52
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width
                                var h = height
                                ctx.beginPath()
                                ctx.moveTo(0, 0)
                                ctx.lineTo(w, 0)
                                ctx.lineTo(w - 18, h)
                                ctx.lineTo(0, h)
                                ctx.closePath()
                                ctx.fillStyle = "#8df6ff"
                                ctx.fill()
                            }
                            onWidthChanged: requestPaint()

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                spacing: 12

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: [
                                        "01 Core Telemetry",
                                        "02 Memory & Storage",
                                        "03 Thermals & Power",
                                        "04 GPU & Displays"
                                    ][p3Overlay.statsTab] || "01 Core Telemetry"
                                    font.family: "Rubik"
                                    font.pixelSize: 21
                                    font.bold: true
                                    color: "#030e28"
                                }
                            }
                        }

                        // Isi Konten Tab Hardware Telemetry
                        Item {
                            anchors.top: statsDetailHeaderCanvas.bottom
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 4

                            // ── TAB 0: CORE TELEMETRY ──
                            Column {
                                anchors.fill: parent
                                visible: p3Overlay.statsTab === 0

                                P3StatRow {
                                    label: "Operating System"
                                    badgeText: (PhantomState.sysOs || "NixOS").replace(" x86_64", "")
                                }
                                P3StatRow {
                                    label: "Linux Kernel"
                                    badgeText: PhantomState.sysKernel || "Linux 6.12.0-zen"
                                }
                                P3StatRow {
                                    label: "Processor (CPU)"
                                    badgeText: PhantomState.sysCpuModel || "Intel Core / AMD Ryzen"
                                }
                                P3StatRow {
                                    label: "CPU Utilization"
                                    badgeText: Math.round(PhantomState.cpuPct) + "%"
                                }
                                P3StatRow {
                                    label: "Active Memory"
                                    badgeText: PhantomState.sysRamText || "Nominal"
                                }
                                P3StatRow {
                                    label: "Root Storage"
                                    badgeText: PhantomState.sysDiskText || "64.9 / 97.7 GB"
                                }
                                P3StatRow {
                                    label: "Session Uptime"
                                    badgeText: PhantomState.sysUptime || "Online"
                                }
                                P3StatRow {
                                    label: "Logged Users"
                                    badgeText: "1 Active Session"
                                    showDivider: false
                                }
                            }

                            // ── TAB 1: MEMORY & STORAGE ──
                            Column {
                                anchors.fill: parent
                                visible: p3Overlay.statsTab === 1

                                P3StatRow {
                                    label: "Physical RAM"
                                    badgeText: PhantomState.sysRamText || "8.8 / 15.5 GB"
                                }
                                P3StatRow {
                                    label: "Memory Load"
                                    badgeText: Math.round(PhantomState.ramPct) + "%"
                                }
                                P3StatRow {
                                    label: "Root FileSystem"
                                    badgeText: "/ (Root Partition)"
                                }
                                P3StatRow {
                                    label: "Root Disk Usage"
                                    badgeText: Math.round(PhantomState.diskPct) + "%"
                                }
                                P3StatRow {
                                    label: "Projects Partition"
                                    badgeText: "/mnt/data (Mounted)"
                                }
                                P3StatRow {
                                    label: "Swap / ZRAM"
                                    badgeText: "Dynamic ZRAM Pool"
                                }
                                P3StatRow {
                                    label: "Disk Health / IO"
                                    badgeText: "SMART Optimal / Active"
                                    showDivider: false
                                }
                            }

                            // ── TAB 2: THERMALS & POWER ──
                            Column {
                                anchors.fill: parent
                                visible: p3Overlay.statsTab === 2

                                P3StatRow {
                                    label: "CPU Package Temp"
                                    badgeText: Math.round(PhantomState.tempPct) + "°C"
                                }
                                P3StatRow {
                                    label: "Thermal State"
                                    badgeText: PhantomState.tempPct > 80 ? "HIGH HEAT" : (PhantomState.tempPct > 60 ? "WARM" : "OPTIMAL")
                                }
                                P3StatRow {
                                    label: "GPU Core Temp"
                                    badgeText: (Math.round(PhantomState.tempPct * 0.9)) + "°C"
                                }
                                P3StatRow {
                                    label: "Power Source"
                                    badgeText: PhantomState.batteryPct >= 100 ? "AC CONNECTED" : "BATTERY (" + PhantomState.batteryPct + "%)"
                                }
                                P3StatRow {
                                    label: "Battery Charge"
                                    badgeText: PhantomState.batteryPct + "%"
                                }
                                P3StatRow {
                                    label: "Power Governor"
                                    badgeText: "Balanced Mode"
                                    showDivider: false
                                }
                            }

                            // ── TAB 3: GPU & DISPLAYS ──
                            Column {
                                anchors.fill: parent
                                visible: p3Overlay.statsTab === 3

                                P3StatRow {
                                    label: "Graphics Hardware"
                                    badgeText: PhantomState.sysGpuModel || "NVIDIA / Intel UHD"
                                }
                                P3StatRow {
                                    label: "GPU Utilization"
                                    badgeText: Math.round(PhantomState.gpuPct) + "%"
                                }
                                P3StatRow {
                                    label: "Primary Monitor"
                                    badgeText: (PhantomState.displayName || "eDP-1") + " • " + (PhantomState.displayMode || "144Hz")
                                }
                                P3StatRow {
                                    label: "Wayland Compositor"
                                    badgeText: "Hyprland v0.53+"
                                }
                                P3StatRow {
                                    label: "Desktop Shell Runtime"
                                    badgeText: "Quickshell C++20 / Qt6"
                                }
                                P3StatRow {
                                    label: "Display Scaling"
                                    badgeText: "1.0x (100% Native)"
                                    showDivider: false
                                }
                            }
                        }
                    }
                }

                // ── LEVEL 1: SUB-MENU SYSTEM CONFIG (Bar & Desktop, Sound Engine, Hyprland FX) ──
                Item {
                    id: p3ConfigSubMenu
                    visible: p3Overlay.currentSection === "config"
                    anchors.fill: parent

                    readonly property var configCategories: [
                        { badge: "I",   title: "Desktop HUD & Widgets", subtitle: "P3 Moon Clock, Music Capsule & CAVA", rank: "MAX" },
                        { badge: "II",  title: "Sound Engine",          subtitle: "Master Output, SFX & CAVA Visualizer", rank: "VI" },
                        { badge: "III", title: "Hyprland Compositor",   subtitle: "Dual Blur, Window Animations & Gaps", rank: "VIII" }
                    ]

                    // Kolom Kiri: Judul "CONFIG", 3 Kartu Slanted P3, dan Tombol Kembali
                    Item {
                        anchors.left: parent.left
                        anchors.leftMargin: 60
                        anchors.verticalCenter: parent.verticalCenter
                        width: 580
                        height: 640

                        Column {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            spacing: 12

                            Text {
                                text: "CONFIG"
                                font.family: "Bebas Neue"
                                font.pixelSize: 52
                                font.bold: true
                                color: "#f6fbff"
                                leftPadding: 8
                            }

                            Repeater {
                                model: p3ConfigSubMenu.configCategories
                                delegate: Item {
                                    id: cfgCardWrap
                                    required property var modelData
                                    required property int index
                                    width: 560
                                    height: isActive ? 84 : 70
                                    x: isActive ? 12 : (isHovered ? 8 : 0)
                                    readonly property bool isActive: p3Overlay.configTab === index
                                    readonly property bool isHovered: cfgCardMouse.containsMouse

                                    Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                                    Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                                    Canvas {
                                        id: cfgCardCanvas
                                        anchors.fill: parent
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.clearRect(0, 0, width, height);
                                            ctx.beginPath();
                                            ctx.moveTo(0, 0);
                                            ctx.lineTo(width * 0.96, 0);
                                            ctx.lineTo(width, height);
                                            ctx.lineTo(width * 0.03, height);
                                            ctx.closePath();
                                            ctx.fillStyle = cfgCardWrap.isActive ? "#8df6ff" : (cfgCardWrap.isHovered ? "rgba(18, 48, 125, 0.96)" : "rgba(8, 24, 75, 0.88)");
                                            ctx.fill();
                                            if (!cfgCardWrap.isActive) {
                                                ctx.strokeStyle = cfgCardWrap.isHovered ? "#00ffff" : "rgba(0, 219, 255, 0.4)";
                                                ctx.lineWidth = cfgCardWrap.isHovered ? 2.5 : 1.5;
                                                ctx.stroke();
                                            }

                                            ctx.beginPath();
                                            ctx.moveTo(width * 0.03, height);
                                            ctx.lineTo(width, height);
                                            ctx.lineTo(width + 6, height + 4);
                                            ctx.lineTo(width * 0.03 + 6, height + 4);
                                            ctx.closePath();
                                            ctx.fillStyle = "#010817";
                                            ctx.fill();
                                        }
                                        onWidthChanged: requestPaint()
                                        onHeightChanged: requestPaint()
                                        Connections {
                                            target: cfgCardWrap
                                            function onIsActiveChanged() { cfgCardCanvas.requestPaint() }
                                            function onIsHoveredChanged() { cfgCardCanvas.requestPaint() }
                                        }
                                    }

                                    // Badge Angka Romawi Miring (I, II, III)
                                    Item {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 12
                                        anchors.top: parent.top
                                        anchors.topMargin: 8
                                        width: 32
                                        height: 38

                                        Canvas {
                                            id: cfgBadgeCanvas
                                            anchors.fill: parent
                                            onPaint: {
                                                var ctx = getContext("2d");
                                                ctx.clearRect(0, 0, width, height);
                                                ctx.beginPath();
                                                ctx.moveTo(4, 0);
                                                ctx.lineTo(width, 0);
                                                ctx.lineTo(width - 4, height);
                                                ctx.lineTo(0, height);
                                                ctx.closePath();
                                                ctx.fillStyle = cfgCardWrap.isActive ? "#041238" : (cfgCardWrap.isHovered ? "#00ffff" : "#103282");
                                                ctx.fill();
                                                ctx.strokeStyle = cfgCardWrap.isActive ? "#000000" : (cfgCardWrap.isHovered ? "#ffffff" : "#00d4ff");
                                                ctx.lineWidth = 1.5;
                                                ctx.stroke();
                                            }
                                            Connections {
                                                target: cfgCardWrap
                                                function onIsActiveChanged() { cfgBadgeCanvas.requestPaint() }
                                                function onIsHoveredChanged() { cfgBadgeCanvas.requestPaint() }
                                            }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: cfgCardWrap.modelData.badge
                                            font.family: "Bebas Neue"
                                            font.pixelSize: 19
                                            font.bold: true
                                            color: cfgCardWrap.isActive ? "#ffffff" : (cfgCardWrap.isHovered ? "#ffffff" : "#d2fdff")
                                            rotation: 6
                                        }
                                    }

                                    // Judul Kategori
                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 52
                                        anchors.top: parent.top
                                        anchors.topMargin: 6
                                        text: cfgCardWrap.modelData.title
                                        font.family: "Rubik"
                                        font.pixelSize: 22
                                        font.weight: Font.Black
                                        color: cfgCardWrap.isActive ? "#041238" : (cfgCardWrap.isHovered ? "#ffffff" : "#8df6ff")
                                    }

                                    // Badge Rank di Kanan Atas
                                    Row {
                                        anchors.right: parent.right
                                        anchors.rightMargin: 18
                                        anchors.top: parent.top
                                        anchors.topMargin: 4
                                        spacing: 4

                                        Text {
                                            text: "RANK"
                                            font.family: "Bebas Neue"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: cfgCardWrap.isActive ? "#041238" : (cfgCardWrap.isHovered ? "#00ffff" : "#8df6ff")
                                            anchors.bottom: parent.bottom
                                            bottomPadding: 3
                                        }
                                        Text {
                                            text: cfgCardWrap.modelData.rank
                                            font.family: "Bebas Neue"
                                            font.pixelSize: 28
                                            font.bold: true
                                            color: cfgCardWrap.isActive ? "#041238" : (cfgCardWrap.isHovered ? "#ffffff" : "#8df6ff")
                                        }
                                    }

                                    // Banner Subtitle Miring di Bagian Bawah Kartu
                                    Canvas {
                                        id: cfgSubtitleCanvas
                                        anchors.left: parent.left
                                        anchors.leftMargin: 50
                                        anchors.right: parent.right
                                        anchors.rightMargin: 16
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 6
                                        height: 20
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.clearRect(0, 0, width, height);
                                            ctx.beginPath();
                                            ctx.moveTo(0, 0);
                                            ctx.lineTo(width, 0);
                                            ctx.lineTo(width - 8, height);
                                            ctx.lineTo(0, height);
                                            ctx.closePath();
                                            ctx.fillStyle = cfgCardWrap.isActive ? "#000000" : (cfgCardWrap.isHovered ? "#9df0ff" : "#65e7ff");
                                            ctx.fill();
                                        }
                                        onWidthChanged: requestPaint()
                                        Connections {
                                            target: cfgCardWrap
                                            function onIsActiveChanged() { cfgSubtitleCanvas.requestPaint() }
                                            function onIsHoveredChanged() { cfgSubtitleCanvas.requestPaint() }
                                        }

                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            text: cfgCardWrap.modelData.subtitle
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                            color: cfgCardWrap.isActive ? "#ffffff" : "#041238"
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: cfgCardMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: {
                                            if (!cfgCardWrap.isActive) PhantomState.playSfx("select")
                                        }
                                        onClicked: {
                                            PhantomState.playSfx("confirm")
                                            p3Overlay.configTab = cfgCardWrap.index
                                        }
                                    }
                                }
                            }
                        }

                        // Tombol Kembali ke Menu Utama
                        Item {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            width: 260
                            height: 40

                            RowLayout {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8
                                scale: cfgReturnMouse.containsMouse ? 1.08 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                                Text {
                                    text: "◄"
                                    font.family: "Rubik"
                                    font.pixelSize: 16
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: cfgReturnMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                                Text {
                                    text: "RETURN TO MENU"
                                    font.family: "Rubik"
                                    font.pixelSize: 18
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: cfgReturnMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                            }

                            MouseArea {
                                id: cfgReturnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: PhantomState.playSfx("select")
                                onClicked: {
                                    PhantomState.playSfx("select")
                                    p3Overlay.navigateTo("main")
                                }
                            }
                        }
                    }

                    // Kolom Kanan: Detail Panel Kaca P3
                    Rectangle {
                        id: cfgDetailPanel
                        anchors.right: parent.right
                        anchors.rightMargin: 70
                        anchors.verticalCenter: parent.verticalCenter
                        width: 470
                        height: 560
                        color: Qt.rgba(5 / 255, 14 / 255, 40 / 255, 0.92)
                        radius: 4
                        border.color: Qt.rgba(0 / 255, 219 / 255, 255 / 255, 0.35)
                        border.width: 1
                        clip: true

                        // Banner Header Detail Slanted Cyan
                        Canvas {
                            id: cfgDetailHeaderCanvas
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 52
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width
                                var h = height
                                ctx.beginPath()
                                ctx.moveTo(0, 0)
                                ctx.lineTo(w, 0)
                                ctx.lineTo(w - 18, h)
                                ctx.lineTo(0, h)
                                ctx.closePath()
                                ctx.fillStyle = "#8df6ff"
                                ctx.fill()
                            }
                            onWidthChanged: requestPaint()

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 20
                                anchors.rightMargin: 20
                                spacing: 12

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: (p3Overlay.configTab === 0 ? "01 Desktop HUD & Widgets" : (p3Overlay.configTab === 1 ? "02 Sound Engine" : "03 Hyprland Compositor"))
                                    font.family: "Rubik"
                                    font.pixelSize: 22
                                    font.weight: Font.Black
                                    color: "#030e28"
                                }
                            }
                        }

                        // Isi Pengaturan Tiap Tab
                        Item {
                            anchors.top: cfgDetailHeaderCanvas.bottom
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 10

                            // ── TAB 0: DESKTOP HUD & WIDGETS ──
                            Column {
                                anchors.fill: parent
                                visible: p3Overlay.configTab === 0

                                P3StatRow {
                                    label: "P3 Moon Clock"
                                    badgeText: PhantomState.showDesktopClock ? "ENABLED" : "DISABLED"
                                    clickable: true
                                    onClicked: { PhantomState.showDesktopClock = !PhantomState.showDesktopClock; PhantomState.saveState() }
                                }
                                P3StatRow {
                                    label: "Clock Placement"
                                    badgeText: PhantomState.desktopClockPosition.toUpperCase()
                                    clickable: true
                                    onClicked: { const p = ["top-right", "top-left", "bottom-right"]; const i = p.indexOf(PhantomState.desktopClockPosition); PhantomState.desktopClockPosition = p[(i + 1) % p.length]; PhantomState.saveState() }
                                }
                                P3StatRow {
                                    label: "P3 Music Capsule"
                                    badgeText: PhantomState.p3CapsuleForceOpen ? "ALWAYS OPEN" : "AUTO (HOVER)"
                                    clickable: true
                                    onClicked: { PhantomState.p3CapsuleForceOpen = !PhantomState.p3CapsuleForceOpen; PhantomState.saveState() }
                                }
                                P3StatRow {
                                    label: "CAVA Visualizer"
                                    badgeText: PhantomState.showDesktopCava ? "ENABLED" : "DISABLED"
                                    clickable: true
                                    onClicked: { PhantomState.showDesktopCava = !PhantomState.showDesktopCava; PhantomState.saveState() }
                                }
                                P3StatRow {
                                    label: "CAVA Bar Count"
                                    badgeText: PhantomState.cavaBarCount + " BARS"
                                    clickable: true
                                    onClicked: { const b = [24, 36, 48, 64]; const i = b.indexOf(PhantomState.cavaBarCount); PhantomState.cavaBarCount = b[(i + 1) % b.length]; PhantomState.saveState() }
                                }
                                P3StatRow {
                                    label: "Floating Lyrics"
                                    badgeText: PhantomState.showDesktopLyrics ? "SHOWN" : "OFF"
                                    clickable: true
                                    onClicked: { PhantomState.showDesktopLyrics = !PhantomState.showDesktopLyrics; PhantomState.saveState() }
                                }
                                P3StatRow {
                                    label: "3D Water Shaders"
                                    badgeText: PhantomState.p3WallpaperAutoPause ? "POWER-SAVE" : "ACTIVE 60FPS"
                                    clickable: true
                                    onClicked: { PhantomState.p3WallpaperAutoPause = !PhantomState.p3WallpaperAutoPause; PhantomState.saveState() }
                                    showDivider: false
                                }
                            }

                            // ── TAB 1: SOUND ENGINE ──
                            Column {
                                anchors.fill: parent
                                visible: p3Overlay.configTab === 1

                                P3StatRow {
                                    label: "Master Output"
                                    badgeText: Math.round(Number(PhantomState.volumePct) || 0) + "%"
                                    clickable: true
                                    onClicked: {
                                        const cur = Math.round(Number(PhantomState.volumePct) || 0)
                                        const next = (cur >= 100 ? 20 : Math.min(100, Math.floor(cur / 10) * 10 + 15))
                                        PhantomState.setSystemVolume(next)
                                    }
                                }
                                P3StatRow {
                                    label: "Mute Output"
                                    badgeText: PhantomState.volumeMuted ? "MUTED" : "ACTIVE"
                                    clickable: true
                                    onClicked: PhantomState.toggleSystemMute()
                                }
                                P3StatRow {
                                    label: "Sound Effects (SFX)"
                                    badgeText: PhantomState.sfxEnabled ? "ENABLED" : "MUTED"
                                    clickable: true
                                    onClicked: { PhantomState.sfxEnabled = !PhantomState.sfxEnabled; PhantomState.saveState() }
                                }
                                P3StatRow {
                                    label: "SFX Volume"
                                    badgeText: Math.round(PhantomState.sfxVolume * 100) + "%"
                                    clickable: true
                                    onClicked: { PhantomState.sfxVolume = (PhantomState.sfxVolume >= 1.0 ? 0.2 : PhantomState.sfxVolume + 0.15); PhantomState.saveState() }
                                }
                                P3StatRow {
                                    label: "Audio Backend"
                                    badgeText: "PipeWire / WirePlumber"
                                }
                                P3StatRow {
                                    label: "Visualizer Source"
                                    badgeText: "CAVA FIFO Engine"
                                    showDivider: false
                                }
                            }

                            // ── TAB 2: HYPRLAND COMPOSITOR ──
                            Column {
                                anchors.fill: parent
                                visible: p3Overlay.configTab === 2

                                P3StatRow {
                                    label: "Dual Blur FX"
                                    badgeText: PhantomState.hyprBlurEnabled ? "ENABLED" : "DISABLED"
                                    clickable: true
                                    onClicked: { PhantomState.hyprBlurEnabled = !PhantomState.hyprBlurEnabled; PhantomState.syncHyprland() }
                                }
                                P3StatRow {
                                    label: "Window Animations"
                                    badgeText: PhantomState.hyprAnimationsEnabled ? "ENABLED" : "DISABLED"
                                    clickable: true
                                    onClicked: { PhantomState.hyprAnimationsEnabled = !PhantomState.hyprAnimationsEnabled; PhantomState.syncHyprland() }
                                }
                                P3StatRow {
                                    label: "Inner Gaps"
                                    badgeText: PhantomState.hyprGapsIn + " px"
                                    clickable: true
                                    onClicked: { const g = [0, 5, 10, 15]; const i = g.indexOf(PhantomState.hyprGapsIn); PhantomState.hyprGapsIn = g[(i + 1) % g.length]; PhantomState.syncHyprland() }
                                }
                                P3StatRow {
                                    label: "Outer Gaps"
                                    badgeText: PhantomState.hyprGapsOut + " px"
                                    clickable: true
                                    onClicked: { const g = [0, 8, 14, 20]; const i = g.indexOf(PhantomState.hyprGapsOut); PhantomState.hyprGapsOut = g[(i + 1) % g.length]; PhantomState.syncHyprland() }
                                }
                                P3StatRow {
                                    label: "Window Rounding"
                                    badgeText: PhantomState.hyprRounding + " px"
                                    clickable: true
                                    onClicked: { const r = [0, 8, 14, 20]; const i = r.indexOf(PhantomState.hyprRounding); PhantomState.hyprRounding = r[(i + 1) % r.length]; PhantomState.syncHyprland() }
                                }
                                P3StatRow {
                                    label: "Border Width"
                                    badgeText: PhantomState.hyprBorderSize + " px"
                                    clickable: true
                                    onClicked: { const b = [1, 2, 3]; const i = b.indexOf(PhantomState.hyprBorderSize); PhantomState.hyprBorderSize = b[(i + 1) % b.length]; PhantomState.syncHyprland() }
                                    showDivider: false
                                }
                            }
                        }
                    }
                }

                // ── LEVEL 1: SUB-MENU CONTROL CENTER (S.E.E.S. Tactical Deck) ──
                Item {
                    id: p3ControlCenterSubMenu
                    visible: p3Overlay.currentSection === "control"
                    anchors.fill: parent

                    // Header Atlus Persona 3 (Left-docked)
                    Item {
                        anchors.top: parent.top
                        anchors.topMargin: 40
                        anchors.left: parent.left
                        anchors.leftMargin: 80
                        width: 740
                        height: 56

                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.beginPath()
                                ctx.moveTo(0, 0)
                                ctx.lineTo(width, 0)
                                ctx.lineTo(width - 20, height)
                                ctx.lineTo(0, height)
                                ctx.closePath()
                                ctx.fillStyle = "rgba(7, 21, 57, 0.92)"
                                ctx.fill()
                                ctx.strokeStyle = "#00dbff"
                                ctx.lineWidth = 2
                                ctx.stroke()
                            }
                        }

                        RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 24
                            spacing: 14

                            Text {
                                text: "S.E.E.S. CONTROL CENTER"
                                font.family: "Rubik"
                                font.pixelSize: 22
                                font.weight: Font.Black
                                font.italic: true
                                color: "#8df6ff"
                            }
                            Rectangle {
                                width: 2
                                height: 20
                                color: Qt.rgba(0/255, 219/255, 255/255, 0.5)
                            }
                            Text {
                                text: "TACTICAL RADAR & QUICK ACTIONS"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#ffffff"
                                font.letterSpacing: 1.2
                            }
                        }
                    }

                    // Tactical Radar Status Callout on Right (Over Fuuka)
                    Item {
                        anchors.top: parent.top
                        anchors.topMargin: 40
                        anchors.right: parent.right
                        anchors.rightMargin: 60
                        width: 440
                        height: 48

                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.beginPath()
                                ctx.moveTo(20, 0)
                                ctx.lineTo(width, 0)
                                ctx.lineTo(width, height)
                                ctx.lineTo(0, height)
                                ctx.closePath()
                                ctx.fillStyle = "rgba(4, 15, 42, 0.85)"
                                ctx.fill()
                                ctx.strokeStyle = "rgba(0, 219, 255, 0.6)"
                                ctx.lineWidth = 1.5
                                ctx.stroke()
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 12

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: "#00ffff"
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1.0; to: 0.2; duration: 800 }
                                    NumberAnimation { from: 0.2; to: 1.0; duration: 800 }
                                }
                            }
                            Text {
                                text: "NAVIGATOR // FUUKA YAMAGISHI // RADAR ON"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#8df6ff"
                                font.letterSpacing: 1.5
                            }
                        }
                    }

                    // Content Container (Left-Docked Deck)
                    Item {
                        anchors.left: parent.left
                        anchors.leftMargin: 80
                        anchors.top: parent.top
                        anchors.topMargin: 116
                        width: 740
                        height: 560

                        // Dual Live Sliders Deck (Volume & Brightness)
                        Row {
                            id: slidersRow
                            anchors.top: parent.top
                            anchors.left: parent.left
                            spacing: 20

                            // 1. Master Audio Volume Deck
                            Rectangle {
                                width: 360
                                height: 100
                                color: Qt.rgba(6/255, 18/255, 52/255, 0.92)
                                radius: 4
                                border.color: Qt.rgba(0/255, 219/255, 255/255, 0.4)
                                border.width: 1.5

                                Row {
                                    anchors.top: parent.top
                                    anchors.topMargin: 12
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    spacing: 8

                                    Text {
                                        text: "VOLUME"
                                        font.family: "Rubik"
                                        font.pixelSize: 16
                                        font.weight: Font.Black
                                        color: "#ffffff"
                                    }
                                    Text {
                                        text: "// SINK"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: "#00dbff"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Item { width: 1; height: 1; Layout.fillWidth: true }
                                    Text {
                                        text: (Math.round(Number(PhantomState.volumePct) || 0)) + "%"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 16
                                        font.weight: Font.Black
                                        color: PhantomState.volumeMuted ? "#ff4060" : "#8df6ff"
                                    }
                                }

                                // Interactive Progress Track
                                Rectangle {
                                    id: volTrack
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 14
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.right: parent.right
                                    anchors.rightMargin: 96
                                    height: 26
                                    color: "#030c22"
                                    radius: 2
                                    border.color: Qt.rgba(0/255, 219/255, 255/255, 0.3)
                                    clip: true

                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        width: parent.width * Math.max(0, Math.min(100, Number(PhantomState.volumePct) || 0)) / 100
                                        color: PhantomState.volumeMuted ? "#6a2535" : "#00f0ff"
                                        Behavior on width { NumberAnimation { duration: 80 } }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onPositionChanged: (mouse) => {
                                            if (pressed) {
                                                let p = Math.max(0, Math.min(100, Math.round((mouse.x / width) * 100)))
                                                PhantomState.setSystemVolume(p)
                                            }
                                        }
                                        onClicked: (mouse) => {
                                            let p = Math.max(0, Math.min(100, Math.round((mouse.x / width) * 100)))
                                            PhantomState.setSystemVolume(p)
                                        }
                                    }
                                }

                                // Mute Button
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 14
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    width: 70
                                    height: 26
                                    color: PhantomState.volumeMuted ? "#ff2a4b" : Qt.rgba(0/255, 219/255, 255/255, 0.15)
                                    border.color: PhantomState.volumeMuted ? "#ff5e78" : "#00dbff"
                                    border.width: 1
                                    radius: 2

                                    Text {
                                        anchors.centerIn: parent
                                        text: PhantomState.volumeMuted ? "MUTED" : "MUTE"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        color: "#ffffff"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.playSfx("select")
                                            PhantomState.toggleSystemMute()
                                        }
                                    }
                                }
                            }

                            // 2. Display Brightness Deck
                            Rectangle {
                                width: 360
                                height: 100
                                color: Qt.rgba(6/255, 18/255, 52/255, 0.92)
                                radius: 4
                                border.color: Qt.rgba(0/255, 219/255, 255/255, 0.4)
                                border.width: 1.5

                                Row {
                                    anchors.top: parent.top
                                    anchors.topMargin: 12
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    spacing: 8

                                    Text {
                                        text: "BRIGHTNESS"
                                        font.family: "Rubik"
                                        font.pixelSize: 16
                                        font.weight: Font.Black
                                        color: "#ffffff"
                                    }
                                    Text {
                                        text: "// PANEL"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: "#ffd000"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Item { width: 1; height: 1; Layout.fillWidth: true }
                                    Text {
                                        text: (Math.round(Number(PhantomState.brightnessPct) || 0)) + "%"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 16
                                        font.weight: Font.Black
                                        color: "#ffe066"
                                    }
                                }

                                // Interactive Brightness Track
                                Rectangle {
                                    id: brightTrack
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 14
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    anchors.right: parent.right
                                    anchors.rightMargin: 16
                                    height: 26
                                    color: "#030c22"
                                    radius: 2
                                    border.color: Qt.rgba(255/255, 208/255, 0/255, 0.3)
                                    clip: true

                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.left: parent.left
                                        width: parent.width * Math.max(5, Math.min(100, Number(PhantomState.brightnessPct) || 0)) / 100
                                        color: "#ffd000"
                                        Behavior on width { NumberAnimation { duration: 80 } }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onPositionChanged: (mouse) => {
                                            if (pressed) {
                                                let p = Math.max(5, Math.min(100, Math.round((mouse.x / width) * 100)))
                                                PhantomState.setSystemBrightness(p)
                                            }
                                        }
                                        onClicked: (mouse) => {
                                            let p = Math.max(5, Math.min(100, Math.round((mouse.x / width) * 100)))
                                            PhantomState.setSystemBrightness(p)
                                        }
                                    }
                                }
                            }
                        }

                        // S.E.E.S. 8 Tactical Action Cards (2 rows x 4 cols)
                        Grid {
                            id: tacticalActionsGrid
                            anchors.top: slidersRow.bottom
                            anchors.topMargin: 20
                            anchors.left: parent.left
                            columns: 4
                            spacing: 16

                            // Card 1: Do Not Disturb
                            P3TacticalActionBtn {
                                width: 173
                                height: 96
                                title: "DO NOT DISTURB"
                                subtitle: PhantomState.dndEnabled ? "ACTIVE (SILENT)" : "STANDBY (NORMAL)"
                                isToggled: PhantomState.dndEnabled
                                iconGlyph: "󰂛"
                                onClicked: {
                                    PhantomState.dndEnabled = !PhantomState.dndEnabled
                                    PhantomState.triggerOsd("DND", PhantomState.dndEnabled ? "ENABLED" : "DISABLED")
                                }
                            }

                            // Card 2: Night Light / Blue Filter
                            P3TacticalActionBtn {
                                width: 173
                                height: 96
                                title: "NIGHT LIGHT"
                                subtitle: "WARM PROTOCOL"
                                isToggled: false
                                iconGlyph: "󰖔"
                                onClicked: {
                                    Quickshell.execDetached(["bash", "-c", "notify-send 'S.E.E.S. Radar' 'Night light filter engaged'"])
                                }
                            }

                            // Card 3: Airplane Mode
                            P3TacticalActionBtn {
                                width: 173
                                height: 96
                                title: "AIRPLANE MODE"
                                subtitle: (!PhantomState.wifiConnected && !PhantomState.btConnected) ? "ACTIVE (OFFLINE)" : "STANDBY (ONLINE)"
                                isToggled: (!PhantomState.wifiConnected && !PhantomState.btConnected)
                                iconGlyph: "󰀝"
                                onClicked: {
                                    let shouldTurnOff = (PhantomState.wifiConnected || PhantomState.btConnected)
                                    PhantomState.setWifiPower(!shouldTurnOff)
                                    PhantomState.setBluetoothPower(!shouldTurnOff)
                                }
                            }

                            // Card 4: Mic Mute
                            P3TacticalActionBtn {
                                width: 173
                                height: 96
                                title: "MIC MUTE"
                                subtitle: "CAPTURE TOGGLE"
                                isToggled: false
                                iconGlyph: "󰍬"
                                onClicked: {
                                    Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"])
                                    Quickshell.execDetached(["bash", "-c", "notify-send 'S.E.E.S. Audio' 'Microphone mute toggled'"])
                                }
                            }

                            // Card 5: Screen Snip
                            P3TacticalActionBtn {
                                width: 173
                                height: 96
                                title: "SCREEN SNIP"
                                subtitle: "AREA CAPTURE"
                                isToggled: false
                                iconGlyph: "󰄀"
                                onClicked: {
                                    PhantomState.sessionOpen = false
                                    Quickshell.execDetached(["bash", "-c", 'sleep 0.25 && grim -g "$(slurp)" - | wl-copy && notify-send "S.E.E.S. Snip" "Area screenshot copied to clipboard!"'])
                                }
                            }

                            // Card 6: Color Picker
                            P3TacticalActionBtn {
                                width: 173
                                height: 96
                                title: "COLOR PICKER"
                                subtitle: "HYPRPICKER HEX"
                                isToggled: false
                                iconGlyph: "󰌁"
                                onClicked: {
                                    PhantomState.sessionOpen = false
                                    Quickshell.execDetached(["bash", "-c", "sleep 0.25 && hyprpicker -a"])
                                }
                            }

                            // Card 7: Screen Mirror
                            P3TacticalActionBtn {
                                width: 173
                                height: 96
                                title: "DISPLAY LAYOUT"
                                subtitle: "CYCLE MONITORS"
                                isToggled: false
                                iconGlyph: "󰍹"
                                onClicked: {
                                    PhantomState.cycleDisplayMode()
                                }
                            }

                            // Card 8: Git Repo Sync
                            P3TacticalActionBtn {
                                width: 173
                                height: 96
                                title: "GIT REPO SYNC"
                                subtitle: "SYSTEM REBUILD"
                                isToggled: false
                                iconGlyph: "󰊢"
                                onClicked: {
                                    PhantomState.syncToSystem()
                                }
                            }
                        }

                        // Tombol Kembali ke Menu Utama
                        Item {
                            anchors.top: tacticalActionsGrid.bottom
                            anchors.topMargin: 20
                            anchors.left: parent.left
                            width: 240
                            height: 40

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                scale: ctrlReturnMouse.containsMouse ? 1.06 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                                Text {
                                    text: "◄"
                                    font.family: "Rubik"
                                    font.pixelSize: 15
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: ctrlReturnMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                                Text {
                                    text: "RETURN TO MENU"
                                    font.family: "Rubik"
                                    font.pixelSize: 16
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: ctrlReturnMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                            }

                            MouseArea {
                                id: ctrlReturnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: PhantomState.playSfx("select")
                                onClicked: {
                                    PhantomState.playSfx("select")
                                    p3Overlay.navigateTo("main")
                                }
                            }
                        }
                    }
                }

                // ── LEVEL 1: SUB-MENU S.E.E.S. ARCHIVE (About Dossier & Machine Architecture) ──
                Item {
                    id: p3ArchiveSubMenu
                    visible: p3Overlay.currentSection === "archive"
                    anchors.fill: parent

                    // Header Atlus Persona 3
                    Item {
                        anchors.top: parent.top
                        anchors.topMargin: 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 1040
                        height: 60

                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.beginPath()
                                ctx.moveTo(0, 0)
                                ctx.lineTo(width, 0)
                                ctx.lineTo(width - 24, height)
                                ctx.lineTo(24, height)
                                ctx.closePath()
                                ctx.fillStyle = "rgba(7, 21, 57, 0.9)"
                                ctx.fill()
                                ctx.strokeStyle = "#00dbff"
                                ctx.lineWidth = 2
                                ctx.stroke()
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 16

                            Text {
                                text: "PHANTOMSHELL ARCHIVE"
                                font.family: "Rubik"
                                font.pixelSize: 26
                                font.weight: Font.Black
                                font.italic: true
                                color: "#8df6ff"
                            }
                            Rectangle {
                                width: 2
                                height: 24
                                color: Qt.rgba(0/255, 219/255, 255/255, 0.5)
                            }
                            Text {
                                text: "SYSTEM SPECIFICATIONS & COMPONENT DOSSIER"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#ffffff"
                                font.letterSpacing: 1.5
                            }
                        }
                    }

                    // Content Container (Dual Tactical Cards)
                    Item {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 30
                        width: 1040
                        height: 540

                        Row {
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 30

                            // 1. Project Dossier Card (Left)
                            Rectangle {
                                width: 505
                                height: 420
                                color: Qt.rgba(6/255, 18/255, 52/255, 0.92)
                                radius: 4
                                border.color: Qt.rgba(0/255, 219/255, 255/255, 0.4)
                                border.width: 1.5
                                clip: true

                                Canvas {
                                    id: arcHeaderCanvas1
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 48
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.reset()
                                        ctx.beginPath()
                                        ctx.moveTo(0, 0)
                                        ctx.lineTo(width, 0)
                                        ctx.lineTo(width - 16, height)
                                        ctx.lineTo(0, height)
                                        ctx.closePath()
                                        ctx.fillStyle = "#8df6ff"
                                        ctx.fill()
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "PROJECT DOSSIER // PHANTOMSHELL"
                                        font.family: "Rubik"
                                        font.pixelSize: 18
                                        font.weight: Font.Black
                                        color: "#030e28"
                                    }
                                }

                                Column {
                                    anchors.top: arcHeaderCanvas1.bottom
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: 10

                                    P3StatRow { label: "Shell Environment"; badgeText: "PhantomShell v2.4 (NixOS)" }
                                    P3StatRow { label: "Compositor Target"; badgeText: "Hyprland (Wayland)" }
                                    P3StatRow { label: "Runtime Engine"; badgeText: "Quickshell C++20 / QML6" }
                                    P3StatRow { label: "Active Theme"; badgeText: "Persona 3 Reload (Full Moon Blue)" }
                                    P3StatRow { label: "Audio Visualizer"; badgeText: "PipeWire / Split 64-Band CAVA" }
                                    P3StatRow { label: "Dotfiles Repository"; badgeText: "ryhndastra/phantomshell" }
                                    P3StatRow { label: "Active Branch"; badgeText: "redesign/p3r-theme"; showDivider: false }
                                }
                            }

                            // 2. Hardware & Host Telemetry Card (Right)
                            Rectangle {
                                width: 505
                                height: 420
                                color: Qt.rgba(6/255, 18/255, 52/255, 0.92)
                                radius: 4
                                border.color: Qt.rgba(0/255, 219/255, 255/255, 0.4)
                                border.width: 1.5
                                clip: true

                                Canvas {
                                    id: arcHeaderCanvas2
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 48
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.reset()
                                        ctx.beginPath()
                                        ctx.moveTo(0, 0)
                                        ctx.lineTo(width, 0)
                                        ctx.lineTo(width - 16, height)
                                        ctx.lineTo(0, height)
                                        ctx.closePath()
                                        ctx.fillStyle = "#8df6ff"
                                        ctx.fill()
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "HARDWARE & SYSTEM TELEMETRY"
                                        font.family: "Rubik"
                                        font.pixelSize: 18
                                        font.weight: Font.Black
                                        color: "#030e28"
                                    }
                                }

                                Column {
                                    anchors.top: arcHeaderCanvas2.bottom
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: 10

                                    P3StatRow { label: "Operating System"; badgeText: (PhantomState.sysOs || PhantomState.osInfo || "NixOS 26.11 (Zokor)") }
                                    P3StatRow { label: "Host Machine"; badgeText: (PhantomState.sysHost ? (PhantomState.sysHost.indexOf("@") >= 0 ? PhantomState.sysHost.split("@")[1] : PhantomState.sysHost) : "nixos") }
                                    P3StatRow { label: "Linux Kernel"; badgeText: (PhantomState.sysKernel || PhantomState.kernelVersion || "6.12.0-zen") }
                                    P3StatRow { label: "Processor (CPU)"; badgeText: (PhantomState.sysCpuModel || "AMD Ryzen 7") }
                                    P3StatRow { label: "System Uptime"; badgeText: (PhantomState.sysUptime || PhantomState.uptime || "Online") }
                                    P3StatRow { label: "Memory Allocation"; badgeText: (PhantomState.sysRamText || PhantomState.memUsage || "Nominal") }
                                    P3StatRow { label: "Storage Root"; badgeText: (PhantomState.sysDiskText || PhantomState.diskUsage || "Mounted"); showDivider: false }
                                }
                            }
                        }

                        // Bottom Actions Row (Refresh Specs, Open Dotfiles, Git Update, Return)
                        Row {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 0
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 16

                            // Refresh Specs Button
                            Rectangle {
                                width: 220
                                height: 42
                                color: arcSyncMouse.containsMouse ? "#00ffff" : Qt.rgba(0/255, 219/255, 255/255, 0.15)
                                border.color: "#00dbff"
                                border.width: 1.5
                                radius: 3

                                Text {
                                    anchors.centerIn: parent
                                    text: "↻ REFRESH SPECS"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 12
                                    font.weight: Font.Black
                                    color: arcSyncMouse.containsMouse ? "#030e28" : "#ffffff"
                                }
                                MouseArea {
                                    id: arcSyncMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("confirm")
                                        PhantomState.refreshSystemDossier()
                                    }
                                }
                            }

                            // Open Dotfiles Button
                            Rectangle {
                                width: 220
                                height: 42
                                color: arcDotfilesMouse.containsMouse ? "#00ffff" : Qt.rgba(0/255, 219/255, 255/255, 0.15)
                                border.color: "#00dbff"
                                border.width: 1.5
                                radius: 3

                                Text {
                                    anchors.centerIn: parent
                                    text: "★ GITHUB REPO"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 12
                                    font.weight: Font.Black
                                    color: arcDotfilesMouse.containsMouse ? "#030e28" : "#ffffff"
                                }
                                MouseArea {
                                    id: arcDotfilesMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("confirm")
                                        Quickshell.execDetached(["xdg-open", "https://github.com/ryhndastra/phantomshell"])
                                    }
                                }
                            }

                            // Check Updates Button
                            Rectangle {
                                width: 220
                                height: 42
                                color: arcUpdMouse.containsMouse ? "#00ffff" : Qt.rgba(0/255, 219/255, 255/255, 0.15)
                                border.color: "#00dbff"
                                border.width: 1.5
                                radius: 3

                                Text {
                                    anchors.centerIn: parent
                                    text: "CHECK GIT UPDATES"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 12
                                    font.weight: Font.Black
                                    color: arcUpdMouse.containsMouse ? "#030e28" : "#ffffff"
                                }
                                MouseArea {
                                    id: arcUpdMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("confirm")
                                        PhantomState.checkSyncUpdate()
                                    }
                                }
                            }

                            // Return Button
                            Rectangle {
                                width: 220
                                height: 42
                                color: arcRetMouse.containsMouse ? "#ffffff" : Qt.rgba(255/255, 255/255, 255/255, 0.1)
                                border.color: "#ffffff"
                                border.width: 1.5
                                radius: 3

                                Text {
                                    anchors.centerIn: parent
                                    text: "RETURN TO MENU"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 12
                                    font.weight: Font.Black
                                    color: arcRetMouse.containsMouse ? "#030e28" : "#ffffff"
                                }
                                MouseArea {
                                    id: arcRetMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("select")
                                        p3Overlay.navigateTo("main")
                                    }
                                }
                            }
                        }
                    }
                }

                // ── MODAL KONFIRMASI PEMILIHAN TEMA BERGAYA ASLI ATLUS (Foto 4) ──
                Item {
                    id: p3ThemeConfirmModal
                    anchors.fill: parent
                    z: 80
                    visible: p3Overlay.showThemeConfirm || opacity > 0.01
                    opacity: p3Overlay.showThemeConfirm ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                    readonly property var currentThemeData: p3Overlay.p3ThemesData[p3Overlay.selectedThemeIndex] || p3Overlay.p3ThemesData[0]

                    // Latar Redup / Dimming
                    Rectangle {
                        anchors.fill: parent
                        color: "#a0020716"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                PhantomState.playSfx("select")
                                p3Overlay.showThemeConfirm = false
                            }
                        }
                    }

                    // SISI KANAN: Hero Character Full Portrait Showcase (Makoto / Ren / Yu)
                    Item {
                        id: confirmPortraitShell
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        x: parent.width * 0.72
                        width: parent.width * 0.28
                        clip: true
                        z: 50

                        transform: [
                            Translate {
                                x: p3Overlay.showThemeConfirm ? 0 : 78
                                Behavior on x {
                                    NumberAnimation {
                                        duration: 480
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.8
                                    }
                                }
                            },
                            Scale {
                                xScale: p3Overlay.showThemeConfirm ? 1.0 : 0.94
                                yScale: p3Overlay.showThemeConfirm ? 1.0 : 0.94
                                origin.x: confirmPortraitShell.width / 2
                                origin.y: confirmPortraitShell.height / 2
                                Behavior on xScale {
                                    NumberAnimation {
                                        duration: 480
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.8
                                    }
                                }
                                Behavior on yScale {
                                    NumberAnimation {
                                        duration: 480
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.8
                                    }
                                }
                            }
                        ]

                        // Gambar Karakter Asli Atlus (Makoto All-Out Attack, Ren ArtStation, Yu Yasogami)
                        Image {
                            anchors.fill: parent
                            source: confirmPortraitShell.parent.currentThemeData.heroPortrait
                            fillMode: Image.PreserveAspectCrop
                            horizontalAlignment: Image.AlignHCenter
                            verticalAlignment: Image.AlignTop
                            smooth: true
                        }
                    }

                    // SISI KIRI: Panel Kartu Skewed Atlus (-20 Derajat, Full Width Melintasi Bawah Karakter Sesuai Foto 2/5)
                    Item {
                        id: confirmRevealPanel
                        x: -parent.width * 0.08
                        y: parent.height * 0.52
                        width: parent.width * 1.35
                        height: parent.height * 0.60
                        z: 20

                        transform: [
                            Rotation {
                                angle: -20
                                origin.x: 0
                                origin.y: confirmRevealPanel.height
                            },
                            Scale {
                                xScale: p3Overlay.showThemeConfirm ? 1.0 : 0.72
                                origin.x: 0
                                origin.y: confirmRevealPanel.height
                                Behavior on xScale {
                                    NumberAnimation {
                                        duration: 460
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 2.5
                                    }
                                }
                            },
                            Translate {
                                x: p3Overlay.showThemeConfirm ? 0 : -140
                                Behavior on x {
                                    NumberAnimation {
                                        duration: 460
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1.5
                                    }
                                }
                            }
                        ]

                        // Latar Belakang Kartu Gradasi Persona (Sesuai Persona 3 Reload Asli)
                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#f50f1c69" }
                                GradientStop { position: 1.0; color: "#f7081044" }
                            }
                            border.color: Qt.rgba(255/255, 255/255, 255/255, 0.20)
                            border.width: 1
                        }

                        // Garis Aksen Atas (Theme Accent Color)
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 6
                            color: "#e60012"
                        }

                        // Tab Bar Navigasi 3 Timeline (P3 / P5 / P4)
                        Row {
                            id: confirmTabRow
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.topMargin: parent.height * 0.02
                            anchors.leftMargin: 480
                            width: 600
                            height: 42
                            spacing: 12

                            Repeater {
                                model: p3Overlay.p3ThemesData
                                delegate: Item {
                                    required property var modelData
                                    required property int index
                                    width: (confirmTabRow.width - 24) / 3
                                    height: confirmTabRow.height

                                    Rectangle {
                                        id: tabBox
                                        anchors.fill: parent
                                        color: index === p3Overlay.selectedThemeIndex ? modelData.accent : "#0a1122"
                                        border.color: index === p3Overlay.selectedThemeIndex ? modelData.accent : Qt.rgba(255/255, 255/255, 255/255, 0.2)
                                        border.width: 1
                                        scale: tabArea.containsMouse ? 1.04 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 120 } }
                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.tabLabel
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 13
                                            font.weight: Font.Black
                                            color: index === p3Overlay.selectedThemeIndex ? "#020718" : "#8df6ff"
                                        }
                                    }

                                    MouseArea {
                                        id: tabArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            PhantomState.playSfx("select")
                                            p3Overlay.selectedThemeIndex = index
                                        }
                                    }
                                }
                            }
                        }

                        // Area Tengah: Judul & Deskripsi Cerita Persona (FULL WIDTH ke kanan, Tinggi 65% Sesuai Foto 5)
                        Rectangle {
                            id: confirmUpperBar
                            anchors.top: confirmTabRow.bottom
                            anchors.topMargin: 8
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: parent.height * 0.65
                            color: "#eb000000"

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 480
                                spacing: 8
                                width: 680

                                Text {
                                    text: confirmRevealPanel.parent.currentThemeData.name
                                    font.family: "Rubik"
                                    font.pixelSize: 26
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: confirmRevealPanel.parent.currentThemeData.accent
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }

                                Text {
                                    text: confirmRevealPanel.parent.currentThemeData.role
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: "#ffffff"
                                }

                                Text {
                                    text: confirmRevealPanel.parent.currentThemeData.lore
                                    font.family: "Montserrat"
                                    font.pixelSize: 12
                                    color: "#8df6ff"
                                    wrapMode: Text.Wrap
                                    width: parent.width * 0.95
                                }

                                Text {
                                    text: "APPLY PROTOCOL TIMELINE THEME?"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                    color: Qt.rgba(255/255, 255/255, 255/255, 0.6)
                                }
                            }
                        }

                        // Tombol Aksi Konfirmasi (Apply / Return)
                        Row {
                            anchors.top: confirmUpperBar.bottom
                            anchors.topMargin: 16
                            anchors.left: parent.left
                            anchors.leftMargin: 480
                            spacing: 16

                            // Tombol Eksekusi / Apply
                            Rectangle {
                                width: 230
                                height: 44
                                color: confirmRevealPanel.parent.currentThemeData.accent
                                border.color: "#ffffff"
                                border.width: 1
                                radius: 4
                                scale: applyBtnM.containsMouse ? 1.05 : 1.0
                                Behavior on scale { NumberAnimation { duration: 120 } }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Text {
                                        text: PhantomState.themeId === confirmRevealPanel.parent.currentThemeData.id ? "ACTIVE ✓" : "EXECUTE // APPLY"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 13
                                        font.weight: Font.Black
                                        color: "#020718"
                                    }
                                }

                                MouseArea {
                                    id: applyBtnM
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("confirm")
                                        PhantomState.applyPreset(confirmRevealPanel.parent.currentThemeData.id)
                                        p3Overlay.showThemeConfirm = false
                                    }
                                }
                            }

                            // Tombol Batal / Return
                            Rectangle {
                                width: 140
                                height: 44
                                color: "#0c152a"
                                border.color: cancelBtnM.containsMouse ? "#ffffff" : Qt.rgba(255/255, 255/255, 255/255, 0.3)
                                border.width: 1
                                radius: 4
                                scale: cancelBtnM.containsMouse ? 1.05 : 1.0
                                Behavior on scale { NumberAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "◄ CANCEL"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    color: cancelBtnM.containsMouse ? "#ffffff" : "#8df6ff"
                                }

                                MouseArea {
                                    id: cancelBtnM
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("select")
                                        p3Overlay.showThemeConfirm = false
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── ANIMASI TRANSISI MULTI-BAR SKYSCRAPER SKEWED (P3rTransition2 Asli Atlus) ──
            Item {
                id: p3WipeTransition
                anchors.fill: parent
                z: 100
                visible: running || opacity > 0.01
                opacity: 0.0

                property bool running: false

                function trigger() {
                    running = true
                    opacity = 1.0
                    bgBlock.x = -bgBlock.width
                    wipeBar0.x = -wipeBar0.width
                    wipeBar1.x = -wipeBar1.width
                    wipeBar2.x = -wipeBar2.width
                    themeWipeAnim.restart()
                }

                Rectangle {
                    id: bgBlock
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * 1.4
                    color: "#030a1c"
                    x: -width
                }

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Item {
                        id: wipeBar0
                        width: p3Overlay.width * 1.35
                        height: p3Overlay.height * 0.35
                        x: -width
                        clip: true
                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(1, -0.15, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "#0d1a3a"
                        }
                    }

                    Item {
                        id: wipeBar1
                        width: p3Overlay.width * 1.35
                        height: p3Overlay.height * 0.35
                        x: -width
                        clip: true
                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(1, -0.15, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "#1a6aff"
                        }
                    }

                    Item {
                        id: wipeBar2
                        width: p3Overlay.width * 1.35
                        height: p3Overlay.height * 0.35
                        x: -width
                        clip: true
                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(1, -0.15, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "#7dd4fc"
                        }
                    }
                }

                SequentialAnimation {
                    id: themeWipeAnim
                    running: false

                    ParallelAnimation {
                        NumberAnimation {
                            target: bgBlock
                            property: "x"
                            from: -bgBlock.width
                            to: 0
                            duration: 320
                            easing.type: Easing.OutExpo
                        }
                        SequentialAnimation {
                            NumberAnimation {
                                target: wipeBar0
                                property: "x"
                                from: -wipeBar0.width
                                to: 0
                                duration: 300
                                easing.type: Easing.OutExpo
                            }
                        }
                        SequentialAnimation {
                            PauseAnimation { duration: 60 }
                            NumberAnimation {
                                target: wipeBar1
                                property: "x"
                                from: -wipeBar1.width
                                to: 0
                                duration: 300
                                easing.type: Easing.OutExpo
                            }
                        }
                        SequentialAnimation {
                            PauseAnimation { duration: 120 }
                            NumberAnimation {
                                target: wipeBar2
                                property: "x"
                                from: -wipeBar2.width
                                to: 0
                                duration: 300
                                easing.type: Easing.OutExpo
                            }
                        }
                    }

                    ScriptAction {
                        script: {
                            p3Overlay.currentSection = p3Overlay.targetSection
                        }
                    }

                    PauseAnimation { duration: 80 }

                    NumberAnimation {
                        target: p3WipeTransition
                        property: "opacity"
                        from: 1.0
                        to: 0.0
                        duration: 220
                        easing.type: Easing.InQuad
                    }

                    ScriptAction {
                        script: {
                            p3WipeTransition.running = false
                        }
                    }
                }
            }

            // ── ANIMASI TRANSISI STATS (P3R Vertical Ribbon Bands Swipe: Cyan, Blue, Solid Navy Sesuai Foto 2 & 3) ──
            Item {
                id: p3StatsTransition
                anchors.fill: parent
                z: 100
                visible: running || opacity > 0.01
                opacity: 0.0

                property bool running: false

                function trigger() {
                    running = true
                    opacity = 1.0
                    bandCyan.x = -p3Overlay.width
                    bandBlue.x = -p3Overlay.width
                    bandNavy.x = -p3Overlay.width
                    statsRibbonWipeAnim.restart()
                }

                // Band 1 (Bawah): Cyan (#7dd5fc) - memimpin sapuan ke kanan
                Rectangle {
                    id: bandCyan
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width
                    x: -parent.width
                    color: "#7dd5fc"
                    z: 1
                }

                // Band 2 (Tengah): Blue (#1b6afe) - menyusul di belakang cyan
                Rectangle {
                    id: bandBlue
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width
                    x: -parent.width
                    color: "#1b6afe"
                    z: 2
                }

                // Band 3 (Atas): Deep Navy (#071330) - menyusul dan menutup layar penuh
                Rectangle {
                    id: bandNavy
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width
                    x: -parent.width
                    color: "#071330"
                    z: 3
                }

                SequentialAnimation {
                    id: statsRibbonWipeAnim
                    running: false

                    // Fase 1: Sapuan Masuk dari Kiri ke Kanan (Wipe In)
                    // Cyan paling cepat mencapai ujung kanan, Blue menyusul, Navy menutup layar penuh (Foto 3 & Foto 2)
                    ParallelAnimation {
                        NumberAnimation {
                            target: bandCyan
                            property: "x"
                            from: -p3Overlay.width
                            to: 0
                            duration: 280
                            easing.type: Easing.OutQuart
                        }
                        NumberAnimation {
                            target: bandBlue
                            property: "x"
                            from: -p3Overlay.width
                            to: 0
                            duration: 320
                            easing.type: Easing.OutQuart
                        }
                        NumberAnimation {
                            target: bandNavy
                            property: "x"
                            from: -p3Overlay.width
                            to: 0
                            duration: 360
                            easing.type: Easing.OutQuart
                        }
                    }

                    // Section Swap terjadi saat layar 100% tertutup rapat oleh Deep Navy (Foto 2)
                    ScriptAction {
                        script: {
                            p3Overlay.currentSection = p3Overlay.targetSection
                        }
                    }

                    // Hold singkat untuk decode video Resume_60fps.mp4 frame 0
                    PauseAnimation { duration: 70 }

                    // Fase 2: Sapuan Keluar ke Kanan (Wipe Out)
                    // Navy bergerak ke kanan lebih dulu mengungkap Blue, lalu Cyan, lalu menu Stats
                    ParallelAnimation {
                        NumberAnimation {
                            target: bandNavy
                            property: "x"
                            from: 0
                            to: p3Overlay.width
                            duration: 280
                            easing.type: Easing.InQuart
                        }
                        NumberAnimation {
                            target: bandBlue
                            property: "x"
                            from: 0
                            to: p3Overlay.width
                            duration: 320
                            easing.type: Easing.InQuart
                        }
                        NumberAnimation {
                            target: bandCyan
                            property: "x"
                            from: 0
                            to: p3Overlay.width
                            duration: 360
                            easing.type: Easing.InQuart
                        }
                    }

                    ScriptAction {
                        script: {
                            p3StatsTransition.running = false
                            p3StatsTransition.opacity = 0
                        }
                    }
                }
            }

            // ── ANIMASI TRANSISI CONFIG (Diagonal Shard Slash: Razor Blade & Splitting Geometric Shards) ──
            Item {
                id: p3ConfigTransition
                anchors.fill: parent
                z: 100
                visible: running || opacity > 0.01
                opacity: 0.0
                property bool running: false

                function trigger() {
                    running = true
                    opacity = 1.0
                    slashShardTop.x = p3Overlay.width
                    slashShardTop.y = -p3Overlay.height
                    slashShardBottom.x = -p3Overlay.width
                    slashShardBottom.y = p3Overlay.height
                    slashLine.opacity = 0.0
                    slashFlash.opacity = 0.0
                    configSlashAnim.restart()
                }

                // Shard Top-Right
                Rectangle {
                    id: slashShardTop
                    width: parent.width * 1.6
                    height: parent.height * 1.6
                    color: "#071330"
                    rotation: -25
                    x: parent.width
                    y: -parent.height
                    z: 2
                }

                // Shard Bottom-Left
                Rectangle {
                    id: slashShardBottom
                    width: parent.width * 1.6
                    height: parent.height * 1.6
                    color: "#0f2b5c"
                    rotation: -25
                    x: -parent.width
                    y: parent.height
                    z: 2
                }

                // Neon Slash Cutting Line
                Rectangle {
                    id: slashLine
                    width: parent.width * 2
                    height: 8
                    color: "#00f0ff"
                    rotation: -25
                    anchors.centerIn: parent
                    opacity: 0.0
                    z: 3
                }

                // Flash curtain
                Rectangle {
                    id: slashFlash
                    anchors.fill: parent
                    color: "#00dbff"
                    opacity: 0.0
                    z: 4
                }

                SequentialAnimation {
                    id: configSlashAnim
                    running: false
                    ParallelAnimation {
                        NumberAnimation { target: slashShardTop; property: "x"; from: p3Overlay.width; to: -p3Overlay.width * 0.2; duration: 260; easing.type: Easing.OutCubic }
                        NumberAnimation { target: slashShardTop; property: "y"; from: -p3Overlay.height; to: -p3Overlay.height * 0.2; duration: 260; easing.type: Easing.OutCubic }
                        NumberAnimation { target: slashShardBottom; property: "x"; from: -p3Overlay.width; to: p3Overlay.width * 0.2; duration: 260; easing.type: Easing.OutCubic }
                        NumberAnimation { target: slashShardBottom; property: "y"; from: p3Overlay.height; to: p3Overlay.height * 0.2; duration: 260; easing.type: Easing.OutCubic }
                        NumberAnimation { target: slashLine; property: "opacity"; from: 0.0; to: 1.0; duration: 120 }
                    }
                    ParallelAnimation {
                        NumberAnimation { target: slashFlash; property: "opacity"; from: 0.0; to: 0.85; duration: 90 }
                    }
                    ScriptAction {
                        script: {
                            p3Overlay.currentSection = p3Overlay.targetSection
                        }
                    }
                    PauseAnimation { duration: 60 }
                    ParallelAnimation {
                        NumberAnimation { target: slashFlash; property: "opacity"; to: 0.0; duration: 180 }
                        NumberAnimation { target: slashShardTop; property: "x"; to: -p3Overlay.width * 1.5; duration: 280; easing.type: Easing.InCubic }
                        NumberAnimation { target: slashShardBottom; property: "x"; to: p3Overlay.width * 1.5; duration: 280; easing.type: Easing.InCubic }
                        NumberAnimation { target: slashLine; property: "opacity"; to: 0.0; duration: 200 }
                        NumberAnimation { target: p3ConfigTransition; property: "opacity"; to: 0.0; duration: 280 }
                    }
                    ScriptAction {
                        script: {
                            p3ConfigTransition.running = false
                        }
                    }
                }
            }

            // ── ANIMASI TRANSISI CONTROL CENTER (Sonar Radar Ripple: Expanding Concentric Tactical Rings) ──
            Item {
                id: p3ControlTransition
                anchors.fill: parent
                z: 100
                visible: running || opacity > 0.01
                opacity: 0.0
                property bool running: false

                function trigger() {
                    running = true
                    opacity = 1.0
                    sonarBg.opacity = 0.0
                    sonarDisc.width = 20
                    sonarDisc.height = 20
                    sonarRing1.width = 20
                    sonarRing1.height = 20
                    sonarRing1.opacity = 1.0
                    sonarRing2.width = 20
                    sonarRing2.height = 20
                    sonarRing2.opacity = 1.0
                    sonarCrossH.opacity = 0.0
                    sonarCrossV.opacity = 0.0
                    controlSonarAnim.restart()
                }

                Rectangle {
                    id: sonarBg
                    anchors.fill: parent
                    color: "#051126"
                    opacity: 0.0
                    z: 1
                }

                Rectangle {
                    id: sonarRing1
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    radius: width / 2
                    color: "transparent"
                    border.color: "#00f0ff"
                    border.width: 4
                    z: 2
                }

                Rectangle {
                    id: sonarRing2
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    radius: width / 2
                    color: "transparent"
                    border.color: "#1877f2"
                    border.width: 6
                    z: 2
                }

                Rectangle {
                    id: sonarDisc
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    radius: width / 2
                    color: "#071739"
                    z: 1
                }

                Rectangle {
                    id: sonarCrossH
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 2
                    color: "#00dbff"
                    opacity: 0.0
                    z: 3
                }
                Rectangle {
                    id: sonarCrossV
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 2
                    color: "#00dbff"
                    opacity: 0.0
                    z: 3
                }

                SequentialAnimation {
                    id: controlSonarAnim
                    running: false
                    ParallelAnimation {
                        NumberAnimation { target: sonarBg; property: "opacity"; from: 0.0; to: 1.0; duration: 250; easing.type: Easing.OutCubic }
                        NumberAnimation { target: sonarDisc; property: "width"; from: 20; to: p3Overlay.width * 1.8; duration: 320; easing.type: Easing.OutQuad }
                        NumberAnimation { target: sonarDisc; property: "height"; from: 20; to: p3Overlay.width * 1.8; duration: 320; easing.type: Easing.OutQuad }
                        NumberAnimation { target: sonarRing1; property: "width"; from: 20; to: p3Overlay.width * 1.6; duration: 300; easing.type: Easing.OutQuad }
                        NumberAnimation { target: sonarRing1; property: "height"; from: 20; to: p3Overlay.width * 1.6; duration: 300; easing.type: Easing.OutQuad }
                        NumberAnimation { target: sonarRing2; property: "width"; from: 20; to: p3Overlay.width * 1.4; duration: 280; easing.type: Easing.OutQuad }
                        NumberAnimation { target: sonarRing2; property: "height"; from: 20; to: p3Overlay.width * 1.4; duration: 280; easing.type: Easing.OutQuad }
                        NumberAnimation { target: sonarCrossH; property: "opacity"; from: 0.0; to: 0.9; duration: 150 }
                        NumberAnimation { target: sonarCrossV; property: "opacity"; from: 0.0; to: 0.9; duration: 150 }
                    }
                    ScriptAction {
                        script: {
                            p3Overlay.currentSection = p3Overlay.targetSection
                        }
                    }
                    PauseAnimation { duration: 70 }
                    ParallelAnimation {
                        NumberAnimation { target: sonarBg; property: "opacity"; to: 0.0; duration: 260 }
                        NumberAnimation { target: sonarCrossH; property: "opacity"; to: 0.0; duration: 180 }
                        NumberAnimation { target: sonarCrossV; property: "opacity"; to: 0.0; duration: 180 }
                        NumberAnimation { target: sonarRing1; property: "opacity"; to: 0.0; duration: 220 }
                        NumberAnimation { target: sonarRing2; property: "opacity"; to: 0.0; duration: 220 }
                        NumberAnimation { target: p3ControlTransition; property: "opacity"; to: 0.0; duration: 260 }
                    }
                    ScriptAction {
                        script: {
                            p3ControlTransition.running = false
                        }
                    }
                }
            }

            // ── ANIMASI TRANSISI ARCHIVE (Vertical Blinds Scan: Top-to-Bottom Shutter Drop & Cyber Laser Scan) ──
            Item {
                id: p3ArchiveTransition
                anchors.fill: parent
                z: 100
                visible: running || opacity > 0.01
                opacity: 0.0
                property bool running: false

                function trigger() {
                    running = true
                    opacity = 1.0
                    shutterNavy.y = -p3Overlay.height
                    shutterSteel.y = -p3Overlay.height
                    scanLaser.y = 0
                    scanLaser.opacity = 0.0
                    archiveScanAnim.restart()
                }

                // Vertical Shutter 1: Deep Navy
                Rectangle {
                    id: shutterNavy
                    anchors.left: parent.left
                    anchors.right: parent.right
                    y: -parent.height
                    height: parent.height
                    color: "#051126"
                    z: 1
                }

                // Vertical Shutter 2: Cobalt Steel
                Rectangle {
                    id: shutterSteel
                    anchors.left: parent.left
                    anchors.right: parent.right
                    y: -parent.height
                    height: parent.height
                    color: "#0f326e"
                    z: 2
                }

                // Scanning Laser Line
                Rectangle {
                    id: scanLaser
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 6
                    color: "#8df6ff"
                    y: 0
                    z: 3
                    opacity: 0.0
                }

                SequentialAnimation {
                    id: archiveScanAnim
                    running: false
                    ParallelAnimation {
                        NumberAnimation { target: shutterSteel; property: "y"; from: -p3Overlay.height; to: 0; duration: 260; easing.type: Easing.OutQuart }
                        NumberAnimation { target: shutterNavy; property: "y"; from: -p3Overlay.height; to: 0; duration: 320; easing.type: Easing.OutQuart }
                        NumberAnimation { target: scanLaser; property: "opacity"; from: 0.0; to: 1.0; duration: 100 }
                        NumberAnimation { target: scanLaser; property: "y"; from: 0; to: p3Overlay.height; duration: 320; easing.type: Easing.InOutSine }
                    }
                    ScriptAction {
                        script: {
                            p3Overlay.currentSection = p3Overlay.targetSection
                        }
                    }
                    PauseAnimation { duration: 70 }
                    ParallelAnimation {
                        NumberAnimation { target: shutterNavy; property: "y"; from: 0; to: p3Overlay.height; duration: 280; easing.type: Easing.InQuart }
                        NumberAnimation { target: shutterSteel; property: "y"; from: 0; to: p3Overlay.height; duration: 320; easing.type: Easing.InQuart }
                        NumberAnimation { target: scanLaser; property: "opacity"; to: 0.0; duration: 200 }
                        NumberAnimation { target: p3ArchiveTransition; property: "opacity"; to: 0.0; duration: 320 }
                    }
                    ScriptAction {
                        script: {
                            p3ArchiveTransition.running = false
                        }
                    }
                }
            }

            // Klik latar kosong untuk menutup menu jeda (dinonaktifkan di mode P3 agar tidak keluar saat missclick)
            MouseArea {
                anchors.fill: parent
                enabled: !PhantomState.isP3
                z: -1
                onClicked: PhantomState.sessionOpen = false
            }
        }
    }

    component P3PowerItem: Item {
        id: powerItemRoot
        required property string normalIcon
        required property string hoverIcon
        required property var action
        property real itemRotation: 0
        property int offsetY: 0
        property int itemWidth: 900
        property int itemHeight: 350
        property int offsetX: 30

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: offsetX
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: offsetY
        width: itemWidth
        height: itemHeight
        rotation: itemRotation
        property bool hovered: false

        Item {
            id: visualItem
            anchors.fill: parent
            scale: powerItemRoot.hovered ? 1.08 : 1.0
            transformOrigin: Item.Center
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Image {
                id: normalImg
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: powerItemRoot.normalIcon
                cache: false
                mipmap: true
                smooth: true
                opacity: powerItemRoot.hovered ? 0.0 : 1.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }

            Image {
                id: hoverImg
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: powerItemRoot.hoverIcon
                cache: false
                mipmap: true
                smooth: true
                opacity: powerItemRoot.hovered ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
        }

        MouseArea {
            anchors.centerIn: parent
            width: parent.width * 0.7
            height: parent.height * 0.5
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                powerItemRoot.hovered = true
                PhantomState.playSfx("select")
            }
            onExited: powerItemRoot.hovered = false
            onClicked: powerItemRoot.action()
        }
    }

    component P3StatRow: Item {
        id: rowRoot
        property string label: ""
        property string badgeText: ""
        property bool showDivider: true
        property bool clickable: false
        property color badgeColor: "#8df6ff"
        property color badgeHoverColor: "#c2f9ff"
        signal clicked()

        width: parent ? parent.width : 470
        height: 52

        Rectangle {
            anchors.fill: parent
            color: (rowRoot.clickable && rowMouse.containsMouse) ? Qt.rgba(0/255, 219/255, 255/255, 0.08) : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: badgeShell.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: rowRoot.label
            font.family: "Rubik"
            font.pixelSize: 17
            font.weight: Font.Bold
            color: (rowRoot.clickable && rowMouse.containsMouse) ? "#c2f9ff" : "#ffffff"
            elide: Text.ElideRight
        }

        // Slanted Parallelogram Badge Khas Persona 3 Reload (Sesuai Foto 1)
        Item {
            id: badgeShell
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(50, valText.implicitWidth + 24)
            height: 30

            Canvas {
                id: badgeCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height
                    var skew = 7
                    ctx.beginPath()
                    ctx.moveTo(skew, 0)
                    ctx.lineTo(w, 0)
                    ctx.lineTo(w - skew, h)
                    ctx.lineTo(0, h)
                    ctx.closePath()
                    ctx.fillStyle = (rowRoot.clickable && rowMouse.containsMouse) ? rowRoot.badgeHoverColor : rowRoot.badgeColor
                    ctx.fill()
                }
                onWidthChanged: requestPaint()
                Connections {
                    target: rowMouse
                    function onContainsMouseChanged() { badgeCanvas.requestPaint() }
                }
            }

            Text {
                id: valText
                anchors.centerIn: parent
                text: rowRoot.badgeText
                font.family: "JetBrainsMono NFM"
                font.pixelSize: 12
                font.weight: Font.Bold
                color: "#030e28"
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            enabled: rowRoot.clickable
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
                PhantomState.playSfx("select")
                rowRoot.clicked()
            }
        }

        // Garis Pembatas Halus Antar Baris
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Qt.rgba(255/255, 255/255, 255/255, 0.08)
            visible: rowRoot.showDivider
        }
    }

    component P3TacticalActionBtn: Item {
        id: actionBtnRoot
        property string title: ""
        property string subtitle: ""
        property string iconGlyph: ""
        property bool isToggled: false
        signal clicked()

        width: 173
        height: 96
        property bool isHovered: actionMouse.containsMouse

        Canvas {
            id: actionCardCanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var w = width
                var h = height
                ctx.beginPath()
                ctx.moveTo(0, 0)
                ctx.lineTo(w - 14, 0)
                ctx.lineTo(w, 14)
                ctx.lineTo(w, h)
                ctx.lineTo(0, h)
                ctx.closePath()
                ctx.fillStyle = actionBtnRoot.isToggled ? "rgba(0, 219, 255, 0.28)" : (actionBtnRoot.isHovered ? "rgba(18, 48, 125, 0.96)" : "rgba(7, 21, 57, 0.90)")
                ctx.fill()
                ctx.strokeStyle = actionBtnRoot.isToggled ? "#00ffff" : (actionBtnRoot.isHovered ? "#8df6ff" : "rgba(0, 219, 255, 0.35)")
                ctx.lineWidth = (actionBtnRoot.isToggled || actionBtnRoot.isHovered) ? 2.0 : 1.2
                ctx.stroke()
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Connections {
                target: actionBtnRoot
                function onIsToggledChanged() { actionCardCanvas.requestPaint() }
                function onIsHoveredChanged() { actionCardCanvas.requestPaint() }
            }
        }

        // Active LED dot indicator
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 14
            width: 7
            height: 7
            radius: 3.5
            color: actionBtnRoot.isToggled ? "#00ffff" : "#1e3a6e"
            border.color: actionBtnRoot.isToggled ? "#ffffff" : "transparent"
            border.width: 1
        }

        // Glyph Icon
        Text {
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 14
            text: actionBtnRoot.iconGlyph
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 20
            color: actionBtnRoot.isToggled ? "#00ffff" : (actionBtnRoot.isHovered ? "#ffffff" : "#8df6ff")
        }

        // Title
        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.right: parent.right
            anchors.rightMargin: 10
            text: actionBtnRoot.title
            font.family: "Rubik"
            font.pixelSize: 12
            font.weight: Font.Black
            color: actionBtnRoot.isToggled ? "#ffffff" : (actionBtnRoot.isHovered ? "#ffffff" : "#d2fdff")
            elide: Text.ElideRight
        }

        // Subtitle
        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.right: parent.right
            anchors.rightMargin: 10
            text: actionBtnRoot.subtitle
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 9
            font.bold: true
            color: actionBtnRoot.isToggled ? "#8df6ff" : (actionBtnRoot.isHovered ? "#00ffff" : "#4e82b8")
            elide: Text.ElideRight
        }

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: PhantomState.playSfx("select")
            onClicked: {
                PhantomState.playSfx("confirm")
                actionBtnRoot.clicked()
            }
        }
    }
}
