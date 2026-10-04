import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

// modul menu sesi dan manajemen daya bergaya calling card persona
Scope {
    PanelWindow {
        id: sessionWin

        property int selectedIndex: 0

        visible: PhantomState.sessionOpen || cardContainer.opacity > 0.01

        WlrLayershell.namespace: "phantomshell-session"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: PhantomState.sessionOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
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
                label: "LOCK",
                sub: "SEAL METAVERSE",
                action: "lock",
                cmd: []
            },
            {
                arcana: "II // REST",
                keyHint: "2",
                icon: "moon",
                label: "SUSPEND",
                sub: "SLEEP IN LEBLANC",
                action: "cmd",
                cmd: ["systemctl", "suspend"]
            },
            {
                arcana: "III // EXIT",
                keyHint: "3",
                icon: "logout",
                label: "LOGOUT",
                sub: "LEAVE PALACE",
                action: "cmd",
                cmd: ["hyprctl", "dispatch", "exit"]
            },
            {
                arcana: "IV // CYCLE",
                keyHint: "4",
                icon: "reboot",
                label: "REBOOT",
                sub: "RELOAD SYSTEM",
                action: "cmd",
                cmd: ["systemctl", "reboot"]
            },
            {
                arcana: "V // HALT",
                keyHint: "5",
                icon: "power",
                label: "POWEROFF",
                sub: "SHUT DOWN",
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
                    sessionWin.selectedIndex = 0
                    keyCatcher.forceActiveFocus()
                }
            }
        }

        // penangkap navigasi papan ketik untuk memilih aksi sesi
        Item {
            id: keyCatcher
            anchors.fill: parent
            focus: PhantomState.sessionOpen

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    PhantomState.sessionOpen = false
                    event.accepted = true
                } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                    sessionWin.selectedIndex = (sessionWin.selectedIndex + sessionWin.actionsModel.length - 1) % sessionWin.actionsModel.length
                    event.accepted = true
                } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L || event.key === Qt.Key_Tab) {
                    sessionWin.selectedIndex = (sessionWin.selectedIndex + 1) % sessionWin.actionsModel.length
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
            readonly property bool isOpen: PhantomState.sessionOpen
            opacity: isOpen ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 190; easing.type: Easing.OutCubic } }

            Rectangle {
                anchors.fill: parent
                color: "#D806060A"
            }

            Canvas {
                anchors.fill: parent
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

        // kontainer kartu utama menu sesi
        Item {
            id: cardContainer
            width: Math.min(780, parent.width - 48)
            height: Math.min(410, parent.height - 72)
            anchors.centerIn: parent

            readonly property bool isOpen: PhantomState.sessionOpen

            opacity: isOpen ? 1.0 : 0.0
            scale: isOpen ? 1.0 : 0.88
            rotation: isOpen ? (PhantomState.polygonMode ? -0.8 : 0) : -3.5

            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 220; easing.type: cardContainer.isOpen ? Easing.OutBack : Easing.InCubic } }
            Behavior on rotation { NumberAnimation { duration: 220; easing.type: cardContainer.isOpen ? Easing.OutBack : Easing.InCubic } }

            MouseArea { anchors.fill: parent }

            // bingkai luar miring dengan bayangan berlapis
            P5SkewedCard {
                anchors.fill: parent
                fillColor: "#0A0A0F"
                borderColor: PhantomState.borderLight
                shadowColor: PhantomState.primary
                borderWidth: 3
                skewPx: PhantomState.polygonMode ? 16 : 0
                shadowOffsetX: 9
                shadowOffsetY: 9
            }

            // dekorasi garis miring dan bintang besar di dalam kartu
            Item {
                anchors.fill: parent
                anchors.margins: 6
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

                // baris header atas dengan pita calling card dan info sesi
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    P5Star {
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        spinning: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        RowLayout {
                            spacing: 8

                            // lencana putih miring khas surat peringatan phantom thieves
                            Rectangle {
                                width: 138
                                height: 20
                                color: "#FFFFFF"
                                rotation: -2
                                Text {
                                    anchors.centerIn: parent
                                    text: "CALLING CARD // MENU"
                                    color: "#09090D"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                }
                            }

                            Rectangle {
                                width: 112
                                height: 20
                                color: PhantomState.primary
                                border.color: "#FFFFFF"
                                border.width: 1
                                rotation: 1.5
                                Text {
                                    anchors.centerIn: parent
                                    text: "METAVERSE LINK"
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "TAKE YOUR TIME // SESSION COMMAND"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 21
                            font.weight: Font.Black
                            font.italic: true
                            elide: Text.ElideRight
                        }
                    }

                    // lencana identitas pengguna dan waktu aktif sistem
                    Item {
                        Layout.preferredWidth: 168
                        Layout.preferredHeight: 42

                        P5SkewedCard {
                            anchors.fill: parent
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

                        P5SkewedCard {
                            anchors.fill: parent
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
                            rotation: isHighlighted ? -2.0 : ((index % 2 === 0) ? -0.6 : 0.6)
                            z: isHighlighted ? 10 : 1

                            transform: Translate {
                                y: cardDelegate.isHighlighted ? -7 : 0
                                Behavior on y { NumberAnimation { duration: 170; easing.type: Easing.OutBack } }
                            }

                            Behavior on scale { NumberAnimation { duration: 170; easing.type: Easing.OutBack } }
                            Behavior on rotation { NumberAnimation { duration: 170; easing.type: Easing.OutCubic } }

                            // kartu latar miring untuk setiap opsi aksi
                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: cardDelegate.isHighlighted ? PhantomState.primary : "#13131C"
                                borderColor: cardDelegate.isHighlighted ? "#FFFFFF" : "#3E3E52"
                                shadowColor: cardDelegate.isHighlighted ? PhantomState.secondary : "#050508"
                                borderWidth: cardDelegate.isHighlighted ? 3 : 2
                                skewPx: PhantomState.polygonMode ? 9 : 0
                                shadowOffsetX: cardDelegate.isHighlighted ? 6 : 4
                                shadowOffsetY: cardDelegate.isHighlighted ? 6 : 4
                            }

                            // aksen diagonal internal pada kartu opsi
                            Canvas {
                                anchors.fill: parent
                                anchors.margins: 4
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
                                        color: cardDelegate.isHighlighted ? "#09090D" : "#222230"
                                        border.color: cardDelegate.isHighlighted ? PhantomState.secondary : "#45455A"
                                        border.width: 1

                                        Text {
                                            id: arcanaTxt
                                            anchors.centerIn: parent
                                            text: cardDelegate.modelData.arcana
                                            color: cardDelegate.isHighlighted ? PhantomState.secondary : PhantomState.muted
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 8
                                            font.weight: Font.Black
                                        }
                                    }

                                    Item { Layout.fillWidth: true }

                                    Rectangle {
                                        width: 20
                                        height: 18
                                        color: cardDelegate.isHighlighted ? PhantomState.secondary : "#1E1E2C"
                                        border.color: "#FFFFFF"
                                        border.width: 1
                                        rotation: 4

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

                                // emblem berlian tengah dengan ikon aksi
                                Item {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 68
                                    Layout.preferredHeight: 68

                                    Rectangle {
                                        anchors.centerIn: parent
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

                                    P5Icon {
                                        anchors.centerIn: parent
                                        name: cardDelegate.modelData.icon
                                        size: 24
                                        color: cardDelegate.isHighlighted ? PhantomState.secondary : "#FFFFFF"
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
                                        color: cardDelegate.isHighlighted ? "#FFFFFF" : "#0A0A10"
                                        border.color: cardDelegate.isHighlighted ? "#09090D" : "#FFFFFF"
                                        border.width: 1.5
                                        rotation: cardDelegate.isHighlighted ? -2.2 : 0

                                        Behavior on rotation { NumberAnimation { duration: 150 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: cardDelegate.modelData.label
                                            color: cardDelegate.isHighlighted ? "#09090D" : "#FFFFFF"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 13
                                            font.weight: Font.Black
                                            font.italic: true
                                        }
                                    }

                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: cardDelegate.modelData.sub
                                        color: cardDelegate.isHighlighted ? "#FFFFFF" : PhantomState.muted
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
                                onEntered: sessionWin.selectedIndex = cardDelegate.index
                                onClicked: sessionWin.triggerAction(cardDelegate.index)
                            }
                        }
                    }
                }

                // bilah informasi pintasan dan target aktif di bagian bawah
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34

                    P5SkewedCard {
                        anchors.fill: parent
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
                            rotation: 45
                            color: PhantomState.primary
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
    }
}
