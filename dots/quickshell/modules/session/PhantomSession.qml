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
                    if (event.key === Qt.Key_Escape) {
                        if (p3Overlay.currentSection !== "main") {
                            PhantomState.playSfx("select")
                            p3Overlay.currentSection = "main"
                        } else {
                            PhantomState.sessionOpen = false
                        }
                        event.accepted = true
                        return
                    }
                    if (p3Overlay.currentSection === "main") {
                        if (event.key >= Qt.Key_1 && event.key <= Qt.Key_5) {
                            const secs = ["stats", "network", "bluetooth", "palette", "dispatch"]
                            p3Overlay.currentSection = secs[event.key - Qt.Key_1]
                            PhantomState.playSfx("confirm")
                            event.accepted = true
                            return
                        }
                    } else if (p3Overlay.currentSection === "dispatch") {
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
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

            property int stage: 0
            property string currentSection: PhantomState.p3SessionSection
            onCurrentSectionChanged: {
                if (PhantomState.p3SessionSection !== currentSection) {
                    PhantomState.p3SessionSection = currentSection
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
                        p3FrameAnim.stop()
                    }
                }
                function onP3SessionSectionChanged() {
                    if (p3Overlay.currentSection !== PhantomState.p3SessionSection) {
                        p3Overlay.currentSection = PhantomState.p3SessionSection
                    }
                }
            }

            function resetMenu() {
                stage = 0
                currentSection = "main"
                p3PngSequence.currentFrame = 0
                p3PngSequence.visible = true

                p3Part2Video.stop()
                p3Part2Video.visible = false
                p3Part2Video.opacity = 1.0
                p3Part2Video.seek(0)
                p3Part3Video.stop()
                p3Part3Video.seek(0)

                p3FrameAnim.restart()
                PhantomState.refreshWifi()
                PhantomState.refreshBluetooth()
            }

            // Latar Biru Samudra Pekat (Mencegah Layar Ngeblink / Tembus Desktop)
            Rectangle {
                anchors.fill: parent
                color: "#0048aa"
                z: 0
            }

            // Lapisan Poster Bawah Air Statis (Menghilangkan kedipan hitam saat video loop/decode)
            Image {
                id: p3PosterBase
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/p3r menu/part3_poster.png")
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
                z: 1
            }

            // Stage 0: Animasi Shatter Kaca Intro (12 Frame)
            Image {
                id: p3PngSequence
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                visible: false
                cache: true
                property int currentFrame: 0
                property int totalFrames: 12
                source: Qt.resolvedUrl("../../assets/themes/p3/p3r menu/png/pngseq" + String(currentFrame).padStart(2, '0') + ".png")
                z: 4
            }

            Timer {
                id: p3FrameAnim
                interval: 1000 / 60
                repeat: true
                running: false
                onTriggered: {
                    if (p3PngSequence.currentFrame < p3PngSequence.totalFrames - 1) {
                        p3PngSequence.currentFrame++
                    } else {
                        stop()
                        p3Overlay.stage = 1
                        p3Part2Video.visible = true
                        p3Part2Video.opacity = 1.0
                        p3Part2Video.play()
                        p3PngSequence.visible = false
                    }
                }
            }

            // Stage 1: Video Animasi Makoto Yuki Tenggelam ke Bawah Air (part2_fast.mp4)
            Video {
                id: p3Part2Video
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/p3r menu/part2_fast.mp4")
                fillMode: VideoOutput.PreserveAspectCrop
                volume: 0
                visible: false
                opacity: 1.0
                z: 3

                onPositionChanged: {
                    if (duration > 0 && position >= duration - 120 && p3Overlay.stage === 1) {
                        p3Overlay.stage = 2
                        p3Part3Video.play()
                        part2FadeOut.restart()
                    }
                }
                onPlaybackStateChanged: {
                    if (playbackState === MediaPlayer.StoppedState && p3Overlay.stage === 1) {
                        p3Overlay.stage = 2
                        p3Part3Video.play()
                        part2FadeOut.restart()
                    }
                }
                onErrorOccurred: (error, errorString) => {
                    console.warn("[P3 VIDEO ERROR]", error, errorString)
                    p3Overlay.stage = 2
                    p3Part3Video.play()
                }
            }

            NumberAnimation {
                id: part2FadeOut
                target: p3Part2Video
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: 250
                easing.type: Easing.OutQuad
                onFinished: {
                    p3Part2Video.stop()
                    p3Part2Video.visible = false
                }
            }

            // Stage 2: Video Animasi Mengambang Terus Menerus di Bawah Air (part3_fast.mp4 Infinite Loop)
            Video {
                id: p3Part3Video
                anchors.fill: parent
                source: Qt.resolvedUrl("../../assets/themes/p3/p3r menu/part3_fast.mp4")
                fillMode: VideoOutput.PreserveAspectCrop
                loops: MediaPlayer.Infinite
                volume: 0
                visible: true
                z: 2
            }

            // ── Pusat Menu Game Taktis Lengkap Beranak (S.E.E.S. Tactical Hub) ──
            Item {
                id: p3TacticalHub
                anchors.fill: parent
                visible: p3Overlay.stage >= 1
                z: 10

                // ── LEVEL 0: MENU UTAMA TINGKAT PERTAMA (Tipografi Atlus Persona 3 Reload Otentik) ──
                Item {
                    id: p3MainMenuContainer
                    visible: p3Overlay.currentSection === "main"
                    anchors.right: parent.right
                    anchors.rightMargin: 60
                    anchors.verticalCenter: parent.verticalCenter
                    width: 620
                    height: 520

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 14

                        // Header Menu Taktis SEES
                        RowLayout {
                            spacing: 8
                            Rectangle {
                                width: 8; height: 8
                                radius: 4
                                color: "#65e7ff"
                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.3; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                                    NumberAnimation { from: 1.0; to: 0.3; duration: 800; easing.type: Easing.InOutQuad }
                                }
                            }
                            Text {
                                text: "S.E.E.S. // TACTICAL COMMAND PROTOCOL"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 12
                                font.weight: Font.Black
                                color: "#65e7ff"
                            }
                        }

                        // 5 Menu Utama Bergaya Tipografi Mengambang Persona 3 Reload (Sama dengan Shutdown / Restart / Logout)
                        Repeater {
                            model: [
                                { id: "stats", arcana: "I", title: "SYSTEM STATS", sub: "Hardware Telemetry & Protocol Toggles" },
                                { id: "network", arcana: "II", title: "TATSUMI LINK", sub: "Wi-Fi Radar & Grid Connectivity" },
                                { id: "bluetooth", arcana: "III", title: "EVOKER LINK", sub: "Wireless Audio & Tactical Devices" },
                                { id: "palette", arcana: "IV", title: "METAVERSE ERAS", sub: "Timeline Palette & Character Select" },
                                { id: "dispatch", arcana: "V", title: "DISPATCH", sub: "Shutdown, Restart, Logout Session" }
                            ]

                            delegate: Item {
                                id: mainMenuItem
                                required property var modelData
                                required property int index
                                Layout.fillWidth: true
                                Layout.preferredHeight: 78
                                rotation: [2, -4, 3, -2, -5][index % 5]

                                readonly property bool isHovered: itemMouse.containsMouse

                                Item {
                                    anchors.fill: parent
                                    scale: mainMenuItem.isHovered ? 1.06 : 1.0
                                    transformOrigin: Item.Left
                                    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

                                    // Pita Aksen Merah Atlus (Sama persis dengan style ribbon shutdown1.png)
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.leftMargin: -16
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: mainMenuItem.isHovered ? Math.min(parent.width, 580) : 0
                                        height: 52
                                        color: "#ff1f29"
                                        radius: 3
                                        rotation: -1.5
                                        visible: width > 0
                                        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                                        // Garis aksen cyan di tepi bawah
                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            height: 3
                                            color: "#65e7ff"
                                        }
                                    }

                                    ColumnLayout {
                                        anchors.left: parent.left
                                        anchors.leftMargin: mainMenuItem.isHovered ? 26 : 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 1
                                        Behavior on anchors.leftMargin { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

                                        RowLayout {
                                            spacing: 12

                                            // Angka Romawi Arcana
                                            Text {
                                                text: modelData.arcana + "."
                                                font.family: "Rubik"
                                                font.pixelSize: 26
                                                font.weight: Font.Black
                                                font.italic: true
                                                color: mainMenuItem.isHovered ? "#ffffff" : Qt.rgba(101/255, 231/255, 255/255, 0.6)
                                                Behavior on color { ColorAnimation { duration: 120 } }
                                            }

                                            // Judul Menu Utama Tipografi Atlus P3
                                            Text {
                                                text: modelData.title
                                                font.family: "Rubik"
                                                font.pixelSize: 42
                                                font.weight: Font.Black
                                                font.italic: true
                                                font.capitalization: Font.AllUppercase
                                                color: mainMenuItem.isHovered ? "#ffffff" : "#65e7ff"
                                                Behavior on color { ColorAnimation { duration: 120 } }
                                            }
                                        }

                                        // Subtitle Tracker Taktis
                                        Text {
                                            Layout.leftMargin: 38
                                            text: "// " + modelData.sub.toUpperCase()
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                            color: mainMenuItem.isHovered ? "#ffffff" : Qt.rgba(101/255, 231/255, 255/255, 0.55)
                                            opacity: mainMenuItem.isHovered ? 1.0 : 0.75
                                        }
                                    }

                                    MouseArea {
                                        id: itemMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: PhantomState.playSfx("select")
                                        onClicked: {
                                            PhantomState.playSfx("confirm")
                                            p3Overlay.currentSection = modelData.id
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── LEVEL 1: SUB-MENU POWER / DISPATCH (3 Tombol Ikonik Asli P3) ──
                Item {
                    id: p3DispatchSubMenu
                    visible: p3Overlay.currentSection === "dispatch"
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 50
                    anchors.verticalCenterOffset: 10
                    width: 800
                    height: 520

                    P3PowerItem {
                        offsetY: -75
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
                        offsetY: 100
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
                        offsetY: 280
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
                                p3Overlay.currentSection = "main"
                            }
                        }
                    }
                }

                // ── LEVEL 1: SUB-MENU METAVERSE ERAS (KARTU KARAKTER HERO) ──
                Item {
                    id: p3PaletteSubMenu
                    visible: p3Overlay.currentSection === "palette"
                    anchors.right: parent.right
                    anchors.rightMargin: 100
                    anchors.verticalCenter: parent.verticalCenter
                    width: 660
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
                            model: [
                                { id: "p3-reload", name: "PERSONA 3 RELOAD", role: "LEADER", desc: "Makoto Yuki // Tartarus Oceanic Modernism", charImg: Qt.resolvedUrl("../../assets/themes/p3/components/char1.png"), accent: "#00dbff" },
                                { id: "p5-crimson", name: "PERSONA 5 CRIMSON", role: "TRICKSTER", desc: "Ren Amamiya // Metaverse Punk Rebellion", charImg: Qt.resolvedUrl("../../assets/themes/p3/components/char2.png"), accent: "#ff2a4b" },
                                { id: "p4-golden", name: "PERSONA 4 GOLDEN", role: "SEEKER", desc: "Yu Narukami // Yasogami Retro Amber Investigation", charImg: Qt.resolvedUrl("../../assets/themes/p3/components/char3.png"), accent: "#f5b800" }
                            ]

                            delegate: Item {
                                id: cCard
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 88

                                readonly property bool isSelected: PhantomState.themeId === modelData.id
                                readonly property bool isHovered: cMouse.containsMouse

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 6
                                    clip: true
                                    color: cCard.isSelected ? Qt.rgba(0/255, 20/255, 60/255, 0.90) : (cCard.isHovered ? Qt.rgba(12/255, 26/255, 78/255, 0.85) : Qt.rgba(6/255, 14/255, 46/255, 0.80))
                                    border.color: cCard.isSelected ? modelData.accent : (cCard.isHovered ? "#ffffff" : Qt.rgba(0/255, 219/255, 255/255, 0.3))
                                    border.width: cCard.isSelected ? 2 : 1

                                    Image {
                                        anchors.right: parent.right
                                        anchors.rightMargin: -20
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 190
                                        height: parent.height + 20
                                        source: modelData.charImg
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        opacity: cCard.isSelected ? 1.0 : (cCard.isHovered ? 0.9 : 0.6)
                                        scale: cCard.isHovered ? 1.05 : 1.0
                                        Behavior on opacity { NumberAnimation { duration: 180 } }
                                        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 14

                                        Rectangle {
                                            Layout.preferredWidth: 42
                                            Layout.preferredHeight: 42
                                            radius: 4
                                            color: cCard.isSelected ? modelData.accent : "#030a20"
                                            border.color: modelData.accent
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.role.substring(0, 3)
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 11
                                                font.weight: Font.Black
                                                color: cCard.isSelected ? "#020718" : modelData.accent
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            Text {
                                                text: modelData.name
                                                font.family: "Inter Display"
                                                font.pixelSize: 14
                                                font.weight: Font.Black
                                                color: cCard.isSelected ? modelData.accent : "#ffffff"
                                            }
                                            Text {
                                                text: modelData.desc
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                font.weight: Font.Bold
                                                color: "#8df6ff"
                                                opacity: 0.85
                                            }
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 84
                                            Layout.preferredHeight: 28
                                            radius: 3
                                            color: cCard.isSelected ? modelData.accent : "transparent"
                                            border.color: modelData.accent
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: cCard.isSelected ? "ACTIVE ✓" : "ACTIVATE"
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 10
                                                font.weight: Font.Black
                                                color: cCard.isSelected ? "#020718" : modelData.accent
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
                                            PhantomState.applyPreset(modelData.id)
                                        }
                                    }
                                }
                            }
                        }

                        // Tombol Kembali Bergaya Atlus
                        Item {
                            Layout.preferredWidth: 260
                            Layout.preferredHeight: 46
                            Layout.alignment: Qt.AlignRight

                            RowLayout {
                                anchors.right: parent.right
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
                                    p3Overlay.currentSection = "main"
                                }
                            }
                        }
                    }
                }

                // ── LEVEL 1: SUB-MENU SYSTEM STATS (TELEMETRY & TOGGLES) ──
                Item {
                    id: p3StatsSubMenu
                    visible: p3Overlay.currentSection === "stats"
                    anchors.right: parent.right
                    anchors.rightMargin: 100
                    anchors.verticalCenter: parent.verticalCenter
                    width: 640
                    height: 520

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text {
                            text: "SYSTEM STATS // HARDWARE TELEMETRY & PROTOCOLS"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 12
                            font.weight: Font.Black
                            color: "#00dbff"
                        }

                        // Telemetri Hardware
                        Repeater {
                            model: [
                                { label: "CPU", sub: PhantomState.sysCpuModel || "Intel Core i5-12450H", text: Math.round(PhantomState.cpuPct) + "%", val: PhantomState.cpuPct },
                                { label: "RAM", sub: PhantomState.sysRamText || "Memory Matrix", text: Math.round(PhantomState.ramPct) + "%", val: PhantomState.ramPct },
                                { label: "GPU", sub: PhantomState.sysGpuModel || "NVIDIA RTX 3050 Mobile", text: Math.round(PhantomState.gpuPct) + "%", val: PhantomState.gpuPct },
                                { label: "BATTERY", sub: "Power Cell", text: Math.round(PhantomState.batteryPct) + "%", val: PhantomState.batteryPct }
                            ]
                            delegate: Item {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 52

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 6
                                    color: Qt.rgba(3/255, 10/255, 36/255, 0.85)
                                    border.color: Qt.rgba(0/255, 219/255, 255/255, 0.4)
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 4

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Text {
                                                text: modelData.label
                                                font.family: "Inter Display"
                                                font.pixelSize: 12
                                                font.weight: Font.Black
                                                color: "#ffffff"
                                            }
                                            Text {
                                                text: modelData.sub
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                color: PhantomState.muted
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                                Layout.leftMargin: 8
                                            }
                                            Text {
                                                text: modelData.text
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 11
                                                font.weight: Font.Black
                                                color: "#00dbff"
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 4
                                            radius: 2
                                            color: Qt.rgba(0, 0, 0, 0.5)

                                            Rectangle {
                                                width: parent.width * Math.max(0.02, Math.min(1.0, modelData.val / 100.0))
                                                height: parent.height
                                                radius: 2
                                                color: modelData.val > 88 ? "#ff3355" : "#00dbff"
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Sakelar Protokol CAVA & Parallax
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                radius: 4
                                color: PhantomState.showDesktopCava ? Qt.rgba(0/255, 219/255, 255/255, 0.25) : "#02081d"
                                border.color: PhantomState.showDesktopCava ? "#00dbff" : "#1a3d80"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "CAVA VISUALIZER: " + (PhantomState.showDesktopCava ? "ENABLED" : "DISABLED")
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    color: PhantomState.showDesktopCava ? "#00dbff" : "#7aa2d6"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("select")
                                        PhantomState.showDesktopCava = !PhantomState.showDesktopCava
                                        PhantomState.saveState()
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 42
                                radius: 4
                                color: PhantomState.showWallpaperLayer ? Qt.rgba(0/255, 219/255, 255/255, 0.25) : "#02081d"
                                border.color: PhantomState.showWallpaperLayer ? "#00dbff" : "#1a3d80"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "PARALLAX DEPTH: " + (PhantomState.showWallpaperLayer ? "ENABLED" : "DISABLED")
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    color: PhantomState.showWallpaperLayer ? "#00dbff" : "#7aa2d6"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        PhantomState.playSfx("select")
                                        PhantomState.showWallpaperLayer = !PhantomState.showWallpaperLayer
                                        PhantomState.saveState()
                                    }
                                }
                            }
                        }

                        // Tombol Kembali Bergaya Atlus
                        Item {
                            Layout.preferredWidth: 260
                            Layout.preferredHeight: 46
                            Layout.alignment: Qt.AlignRight

                            RowLayout {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8
                                scale: statsBackMouse.containsMouse ? 1.08 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                                Text {
                                    text: "◄"
                                    font.family: "Rubik"
                                    font.pixelSize: 20
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: statsBackMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                                Text {
                                    text: "RETURN TO MENU"
                                    font.family: "Rubik"
                                    font.pixelSize: 22
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: statsBackMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                            }

                            MouseArea {
                                id: statsBackMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: PhantomState.playSfx("select")
                                onClicked: {
                                    PhantomState.playSfx("select")
                                    p3Overlay.currentSection = "main"
                                }
                            }
                        }
                    }
                }

                // ── LEVEL 1: SUB-MENU TATSUMI LINK & EVOKER LINK ──
                Item {
                    id: p3NetworkSubMenu
                    visible: p3Overlay.currentSection === "network" || p3Overlay.currentSection === "bluetooth"
                    anchors.right: parent.right
                    anchors.rightMargin: 100
                    anchors.verticalCenter: parent.verticalCenter
                    width: 640
                    height: 520

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 14

                        Text {
                            text: p3Overlay.currentSection === "network" ? "TATSUMI LINK // WI-FI RADAR" : "EVOKER LINK // BLUETOOTH DEVICES"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 12
                            font.weight: Font.Black
                            color: "#00dbff"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 64
                            radius: 6
                            color: Qt.rgba(3/255, 10/255, 36/255, 0.85)
                            border.color: "#00dbff"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 14
                                spacing: 12

                                P5Icon {
                                    name: p3Overlay.currentSection === "network" ? "wifi" : "bluetooth"
                                    size: 18
                                    color: "#00dbff"
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: p3Overlay.currentSection === "network" ? (PhantomState.wifiSsid || "Connected") : "Bluetooth Adapter Active"
                                        font.family: "Inter Display"
                                        font.pixelSize: 14
                                        font.weight: Font.Bold
                                        color: "#ffffff"
                                    }
                                    Text {
                                        text: p3Overlay.currentSection === "network" ? ("IP: " + (PhantomState.wifiIp || "192.168.1.1")) : "Audio Sinks & Evoker Links Ready"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        color: "#8df6ff"
                                    }
                                }
                                Rectangle {
                                    Layout.preferredWidth: 90
                                    Layout.preferredHeight: 28
                                    radius: 3
                                    color: "#00dbff"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "ONLINE ✓"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        font.weight: Font.Black
                                        color: "#02081d"
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Tombol Kembali Bergaya Atlus
                        Item {
                            Layout.preferredWidth: 260
                            Layout.preferredHeight: 46
                            Layout.alignment: Qt.AlignRight

                            RowLayout {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8
                                scale: netBackMouse.containsMouse ? 1.08 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                                Text {
                                    text: "◄"
                                    font.family: "Rubik"
                                    font.pixelSize: 20
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: netBackMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                                Text {
                                    text: "RETURN TO MENU"
                                    font.family: "Rubik"
                                    font.pixelSize: 22
                                    font.weight: Font.Black
                                    font.italic: true
                                    color: netBackMouse.containsMouse ? "#ffffff" : "#65e7ff"
                                }
                            }

                            MouseArea {
                                id: netBackMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: PhantomState.playSfx("select")
                                onClicked: {
                                    PhantomState.playSfx("select")
                                    p3Overlay.currentSection = "main"
                                }
                            }
                        }
                    }
                }
            }

            // Klik latar kosong untuk menutup menu jeda
            MouseArea {
                anchors.fill: parent
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

        x: 30
        y: offsetY
        width: 900
        height: 350
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
                mipmap: true
                smooth: true
                opacity: powerItemRoot.hovered ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
        }

        MouseArea {
            anchors.centerIn: parent
            width: parent.width * 0.4
            height: parent.height * 0.4
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
}
