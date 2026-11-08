import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

// =============================================================================
// PERSONA 3 RELOAD: AUTHENTIC TATSUMI PORT ISLAND TOWN MAP OVERVIEW
// Tampilan ikhtisar workspace 100% presisi visual P3R Town Map (Sesuai Foto 1)
// =============================================================================
Scope {
    id: root

    readonly property int activeWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    property int selectedDistrictIdx: 0

    // Data 6 Sektor Distrik Utama Tatsumi Port Island & Koordinat pada Peta 3D (Foto 1)
    readonly property var districts: [
        {
            num: 1,
            name: "Gekkoukan High School",
            code: "GEKKOUKAN HIGH",
            sub: "Classrooms & Rooftop",
            // Kanan Tengah (Gedung Sekolah & Lapangan)
            mapX: 0.68,
            mapY: 0.50,
            cardSide: "left"
        },
        {
            num: 2,
            name: "Iwatodai Station Strip Mall",
            code: "IWATODAI STRIP",
            sub: "Dormitory & Station",
            // Kiri Atas (Stasiun & Asrama Mahasiswa)
            mapX: 0.36,
            mapY: 0.28,
            cardSide: "right"
        },
        {
            num: 3,
            name: "Paulownia Mall",
            code: "PAULOWNIA MALL",
            sub: "Arcade & Police Dept",
            // Kanan Atas Tengah (Plaza & Bianglala)
            mapX: 0.63,
            mapY: 0.32,
            cardSide: "left"
        },
        {
            num: 4,
            name: "Port Island Station",
            code: "PORT ISLAND STN",
            sub: "Outskirts & Square",
            // Bawah Tengah (Terminal Kereta)
            mapX: 0.52,
            mapY: 0.62,
            cardSide: "right"
        },
        {
            num: 5,
            name: "Naganaki Shrine",
            code: "NAGANAKI SHRINE",
            sub: "Shrine Grounds",
            // Atas Tengah (Gerbang Torii & Hutan)
            mapX: 0.48,
            mapY: 0.21,
            cardSide: "bottom"
        },
        {
            num: 6,
            name: "Tartarus Gate & Bridge",
            code: "TARTARUS GATE",
            sub: "Monorail & Moonlight Bridge",
            // Kiri Atas Pesisir (Jembatan Monorel)
            mapX: 0.22,
            mapY: 0.25,
            cardSide: "right"
        }
    ]

    function getDistrictApps(num) {
        if (!PhantomState.workspaceApps) return []
        const key = String(num)
        return PhantomState.workspaceApps[key] || []
    }

    function fastTravelTo(wsNum) {
        Quickshell.execDetached([
            "hyprctl", "eval",
            "hl.dispatch(hl.dsp.focus({ workspace = " + wsNum + " }))"
        ])
        PhantomState.overviewOpen = false
    }

    PanelWindow {
        id: ovWin
        visible: PhantomState.overviewOpen

        WlrLayershell.namespace: "phantomshell-overview"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: PhantomState.overviewOpen
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

        onVisibleChanged: {
            if (visible) {
                PhantomState.refreshWorkspaces()
                // Set seleksi awal ke workspace aktif saat ini
                for (var i = 0; i < root.districts.length; i++) {
                    if (root.districts[i].num === root.activeWsId) {
                        root.selectedDistrictIdx = i
                        break
                    }
                }
                ovKeyCatcher.forceActiveFocus()
            }
        }

        // Penanganan Tombol Keyboard Sesuai Navigasi Game P3R
        Item {
            id: ovKeyCatcher
            focus: true
            anchors.fill: parent

            Keys.onEscapePressed: PhantomState.overviewOpen = false

            // Navigasi Angka 1-6 Langsung Fast Travel
            Keys.onPressed: (event) => {
                if (event.key >= Qt.Key_1 && event.key <= Qt.Key_6) {
                    var targetWs = event.key - Qt.Key_0
                    root.fastTravelTo(targetWs)
                    event.accepted = true
                } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_D || event.key === Qt.Key_Right) {
                    root.selectedDistrictIdx = (root.selectedDistrictIdx + 1) % root.districts.length
                    event.accepted = true
                } else if (event.key === Qt.Key_A || event.key === Qt.Key_Left) {
                    root.selectedDistrictIdx = (root.selectedDistrictIdx - 1 + root.districts.length) % root.districts.length
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    var d = root.districts[root.selectedDistrictIdx]
                    if (d) root.fastTravelTo(d.num)
                    event.accepted = true
                } else if (event.key === Qt.Key_S) {
                    PhantomState.overviewOpen = false
                    PhantomState.toggleVelvetRoom()
                    event.accepted = true
                }
            }
        }

        // 1. Gambar Panorama Peta Tatsumi Port Island (Foto 1)
        Item {
            anchors.fill: parent

            Image {
                id: mapBgImage
                anchors.fill: parent
                source: "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/themes/p3/bg/p3r_town_map.png"
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }

            // Lapisan Vignette Gelap di Tepian Peta untuk Kedalaman Sinematik
            Canvas {
                anchors.fill: parent
                antialiasing: true
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height
                    var grad = ctx.createRadialGradient(w / 2, h / 2, Math.min(w, h) * 0.35, w / 2, h / 2, Math.max(w, h) * 0.72)
                    grad.addColorStop(0.0, "transparent")
                    grad.addColorStop(1.0, "rgba(2, 6, 18, 0.75)")
                    ctx.fillStyle = grad
                    ctx.fillRect(0, 0, w, h)
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "#18040b24"
            }
        }

        // 2. HUD Kalender dan Fase Bulan Kanan Atas (Sesuai Foto 1)
        Item {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 24
            anchors.rightMargin: 32
            width: 320
            height: 90
            z: 20

            // Latar Pita Biru Miring Tanggal & Waktu P3R
            Canvas {
                anchors.fill: parent
                antialiasing: true
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height

                    ctx.beginPath()
                    ctx.moveTo(36, 0)
                    ctx.lineTo(w, 0)
                    ctx.lineTo(w, h)
                    ctx.lineTo(0, h)
                    ctx.closePath()

                    var grad = ctx.createLinearGradient(0, 0, w, h)
                    grad.addColorStop(0.0, "#0028e0")
                    grad.addColorStop(1.0, "#001460")
                    ctx.fillStyle = grad
                    ctx.fill()

                    ctx.strokeStyle = "#00f0ff"
                    ctx.lineWidth = 1.8
                    ctx.stroke()
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 46
                anchors.rightMargin: 18
                spacing: 14

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        spacing: 8
                        Text {
                            text: {
                                const now = new Date()
                                const m = (now.getMonth() + 1)
                                const d = now.getDate()
                                const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                                return (m < 10 ? "0" + m : m) + "/" + (d < 10 ? "0" + d : d) + " " + days[now.getDay()]
                            }
                            color: "#ffffff"
                            font.family: "Rubik"
                            font.pixelSize: 22
                            font.weight: Font.Black
                        }
                    }

                    Text {
                        text: {
                            const hr = new Date().getHours()
                            if (hr >= 0 && hr < 1) return "Dark Hour"
                            if (hr >= 1 && hr < 6) return "Late Night"
                            if (hr >= 6 && hr < 12) return "Morning"
                            if (hr >= 12 && hr < 16) return "After School"
                            if (hr >= 16 && hr < 19) return "Evening"
                            return "Night"
                        }
                        color: "#00f0ff"
                        font.family: "Rubik"
                        font.pixelSize: 13
                        font.weight: Font.Black
                        font.italic: true
                    }
                }

                // Fase Bulan (Moon Phase Indicator P3R)
                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "LIMIT"
                        color: "#ffffff"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 8
                        font.bold: true
                    }
                    RowLayout {
                        spacing: 4
                        Text {
                            text: "13"
                            color: "#ffffff"
                            font.family: "Rubik"
                            font.pixelSize: 18
                            font.weight: Font.Black
                        }
                        // Lingkaran Bulan Kuning Sabit
                        Canvas {
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            antialiasing: true
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                ctx.beginPath()
                                ctx.arc(11, 11, 10, 0, Math.PI * 2)
                                ctx.fillStyle = "#020818"
                                ctx.fill()
                                ctx.strokeStyle = "#ffd700"
                                ctx.lineWidth = 1.5
                                ctx.stroke()

                                // Sabit Kuning
                                ctx.beginPath()
                                ctx.arc(11, 11, 9, -Math.PI / 2, Math.PI / 2, false)
                                ctx.fillStyle = "#ffd700"
                                ctx.fill()
                            }
                        }
                    }
                }
            }
        }

        // 3. Judul Raksasa "TOWNMAP" di Pojok Kiri Bawah (Sesuai Foto 1)
        Item {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 320
            height: 90
            z: 20

            // Poligon Segitiga Miring Biru di Kiri Bawah
            Canvas {
                anchors.fill: parent
                antialiasing: true
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height

                    ctx.beginPath()
                    ctx.moveTo(0, h * 0.4)
                    ctx.lineTo(w, h)
                    ctx.lineTo(0, h)
                    ctx.closePath()
                    ctx.fillStyle = "#0028e0"
                    ctx.fill()
                }
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.bottomMargin: 6
                text: "TOWNMAP"
                font.family: "Rubik"
                font.pixelSize: 42
                font.weight: Font.Black
                font.italic: true
                color: "#030e38"
                renderType: Text.CurveRendering
            }
        }

        // 4. Baris Kontrol Navigasi & Key Legend di Pojok Kanan Bawah (Sesuai Foto 1)
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 18
            anchors.rightMargin: 28
            height: 38
            width: legendLayout.implicitWidth + 32
            radius: 4
            color: "#F0040C26"
            border.color: "#9900DBFF"
            border.width: 1.2
            z: 20

            RowLayout {
                id: legendLayout
                anchors.centerIn: parent
                spacing: 16

                RowLayout {
                    spacing: 6
                    Rectangle {
                        width: 44; height: 20; radius: 2; color: "#0028e0"
                        Text { anchors.centerIn: parent; text: "1 - 6"; color: "#ffffff"; font.family: "Rubik"; font.pixelSize: 10; font.bold: true }
                    }
                    Text { text: "Travel"; color: "#ffffff"; font.family: "Rubik"; font.pixelSize: 11; font.bold: true }
                }

                RowLayout {
                    spacing: 6
                    Rectangle {
                        width: 38; height: 20; radius: 2; color: "#0028e0"
                        Text { anchors.centerIn: parent; text: "TAB"; color: "#ffffff"; font.family: "Rubik"; font.pixelSize: 9; font.bold: true }
                    }
                    Text { text: "Select"; color: "#ffffff"; font.family: "Rubik"; font.pixelSize: 11; font.bold: true }
                }

                RowLayout {
                    spacing: 6
                    Rectangle {
                        width: 52; height: 20; radius: 2; color: "#0028e0"
                        Text { anchors.centerIn: parent; text: "SPACE"; color: "#ffffff"; font.family: "Rubik"; font.pixelSize: 9; font.bold: true }
                    }
                    Text { text: "Confirm"; color: "#ffffff"; font.family: "Rubik"; font.pixelSize: 11; font.bold: true }
                }

                RowLayout {
                    spacing: 6
                    Rectangle {
                        width: 32; height: 20; radius: 2; color: "#d60032"
                        Text { anchors.centerIn: parent; text: "ESC"; color: "#ffffff"; font.family: "Rubik"; font.pixelSize: 9; font.bold: true }
                    }
                    Text { text: "Close"; color: "#ffffff"; font.family: "Rubik"; font.pixelSize: 11; font.bold: true }
                }
            }
        }

        // 5. Pin-Pin Lokasi Distrik di Atas Peta 3D (Foto 1)
        Item {
            anchors.fill: parent
            z: 10

            Repeater {
                model: root.districts
                delegate: Item {
                    id: pinItem
                    required property var modelData
                    required property int index

                    readonly property bool isSelected: index === root.selectedDistrictIdx
                    readonly property bool isActiveWs: modelData.num === root.activeWsId
                    readonly property var apps: root.getDistrictApps(modelData.num)

                    x: Math.round(ovWin.width * modelData.mapX) - 24
                    y: Math.round(ovWin.height * modelData.mapY) - 36
                    width: 48
                    height: 48

                    // A. Glowing Target Reticle Cyan (Pulsing Radar Circle Khas Foto 1)
                    Item {
                        anchors.centerIn: parent
                        width: 84
                        height: 84
                        visible: pinItem.isSelected

                        // Animasi Radar Berdenyut
                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            running: pinItem.isSelected
                            NumberAnimation { from: 0.94; to: 1.08; duration: 900; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 1.08; to: 0.94; duration: 900; easing.type: Easing.InOutSine }
                        }

                        Canvas {
                            anchors.fill: parent
                            antialiasing: true
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var cx = width / 2
                                var cy = height / 2

                                // Lingkaran Luar Berpendar
                                ctx.beginPath()
                                ctx.arc(cx, cy, 36, 0, Math.PI * 2)
                                ctx.strokeStyle = "#00f0ff"
                                ctx.lineWidth = 2.2
                                ctx.stroke()

                                // Lingkaran Dalam Halus
                                ctx.beginPath()
                                ctx.arc(cx, cy, 28, 0, Math.PI * 2)
                                ctx.strokeStyle = "rgba(0, 240, 255, 0.45)"
                                ctx.lineWidth = 1.0
                                ctx.stroke()

                                // Crosshairs / Notches
                                var notch = 8
                                ctx.strokeStyle = "#00f0ff"
                                ctx.lineWidth = 2.0
                                // Top
                                ctx.beginPath(); ctx.moveTo(cx, cy - 36); ctx.lineTo(cx, cy - 36 + notch); ctx.stroke()
                                // Bottom
                                ctx.beginPath(); ctx.moveTo(cx, cy + 36); ctx.lineTo(cx, cy + 36 - notch); ctx.stroke()
                                // Left
                                ctx.beginPath(); ctx.moveTo(cx - 36, cy); ctx.lineTo(cx - 36 + notch, cy); ctx.stroke()
                                // Right
                                ctx.beginPath(); ctx.moveTo(cx + 36, cy); ctx.lineTo(cx + 36 - notch, cy); ctx.stroke()
                            }
                        }
                    }

                    // B. Pin Teardrop Biru Otentik Persona 3 Reload (Foto 1)
                    Canvas {
                        id: pinCanvas
                        anchors.fill: parent
                        antialiasing: true

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var cx = width / 2
                            var cy = 18
                            var r = 16

                            // Bayangan Pin
                            ctx.beginPath()
                            ctx.ellipse(cx, height - 4, 12, 4, 0, 0, Math.PI * 2)
                            ctx.fillStyle = "rgba(0, 0, 0, 0.6)"
                            ctx.fill()

                            // Tubuh Pin Teardrop
                            ctx.beginPath()
                            ctx.arc(cx, cy, r, Math.PI * 0.8, Math.PI * 0.2, false)
                            ctx.lineTo(cx, height - 4)
                            ctx.closePath()

                            ctx.fillStyle = pinItem.isActiveWs ? "#00e5ff" : (pinItem.isSelected ? "#0055ff" : "#0038c8")
                            ctx.fill()

                            ctx.strokeStyle = "#ffffff"
                            ctx.lineWidth = 2.0
                            ctx.stroke()
                        }
                    }

                    // Nomor Workspace di Dalam Pin
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 8
                        text: pinItem.modelData.num < 10 ? ("0" + pinItem.modelData.num) : pinItem.modelData.num
                        font.family: "Rubik"
                        font.pixelSize: 13
                        font.weight: Font.Black
                        color: pinItem.isActiveWs ? "#020818" : "#ffffff"
                    }

                    // C. Label Nama Distrik Miring di Samping Pin (Foto 1: "Gekkoukan High School")
                    Rectangle {
                        anchors.left: parent.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -8
                        height: 26
                        width: pinLabelText.implicitWidth + 20
                        radius: 3
                        color: pinItem.isSelected ? "#0028e0" : "#E6040C26"
                        border.color: pinItem.isSelected ? "#00f0ff" : "#4DFFFFFF"
                        border.width: 1.2

                        Text {
                            id: pinLabelText
                            anchors.centerIn: parent
                            text: pinItem.modelData.name
                            font.family: "Rubik"
                            font.pixelSize: 11
                            font.weight: Font.Black
                            color: "#ffffff"
                        }
                    }

                    // D. Kartu Detail Workspace Sesuai Bentuk Foto 2 (Saat Dipilih / Hovered)
                    Item {
                        id: detailHoverCard
                        visible: pinItem.isSelected
                        width: 340
                        height: Math.max(140, appListCol.implicitHeight + 64)
                        z: 50

                        // Penempatan kartu agar tidak keluar layar
                        x: pinItem.modelData.cardSide === "left" ? -350 : 60
                        y: -30

                        // Bentuk Dialog P3R Otentik (Sesuai Foto 2)
                        Canvas {
                            anchors.fill: parent
                            antialiasing: true
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width
                                var h = height

                                // Shard Aksen Biru Muda di Kanan
                                ctx.fillStyle = "rgba(0, 160, 255, 0.28)"
                                ctx.beginPath()
                                ctx.moveTo(w - 60, -2)
                                ctx.lineTo(w + 4, -2)
                                ctx.lineTo(w - 6, h + 2)
                                ctx.lineTo(w - 70, h + 2)
                                ctx.closePath()
                                ctx.fill()

                                // Badan Dialog Navy
                                var bx = 12
                                var by = 8
                                var bw = w - 24
                                var bh = h - 12
                                var r = 6

                                ctx.beginPath()
                                ctx.moveTo(bx + r, by)
                                ctx.lineTo(bx + bw - r, by)
                                ctx.quadraticCurveTo(bx + bw, by, bx + bw, by + r)
                                ctx.lineTo(bx + bw, by + bh - r)
                                ctx.quadraticCurveTo(bx + bw, by + bh, bx + bw - r, by + bh)
                                ctx.lineTo(bx + r, by + bh)
                                ctx.quadraticCurveTo(bx, by + bh, bx, by + bh - r)
                                ctx.lineTo(bx, by + r)
                                ctx.quadraticCurveTo(bx, by, bx + r, by)
                                ctx.closePath()

                                ctx.fillStyle = "rgba(4, 12, 38, 0.96)"
                                ctx.fill()

                                ctx.strokeStyle = "#00dbff"
                                ctx.lineWidth = 1.6
                                ctx.stroke()

                                // Wedge Segitiga Kiri Atas P3R (Foto 2)
                                ctx.beginPath()
                                ctx.moveTo(-2, 18)
                                ctx.lineTo(140, -2)
                                ctx.lineTo(152, 20)
                                ctx.lineTo(32, 30)
                                ctx.closePath()

                                ctx.fillStyle = "#0028e0"
                                ctx.fill()
                                ctx.strokeStyle = "#00f0ff"
                                ctx.lineWidth = 1.2
                                ctx.stroke()
                            }
                        }

                        // Teks Header Wedge Segitiga
                        Item {
                            x: 6
                            y: -2
                            width: 140
                            height: 28
                            z: 10

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.topMargin: 2
                                spacing: 0

                                Text {
                                    text: pinItem.modelData.code
                                    color: "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "SECTOR 0" + pinItem.modelData.num
                                    color: "#00f0ff"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 8
                                    font.bold: true
                                }
                            }
                        }

                        // Konten Daftar Window Aplikasi di Workspace Ini
                        ColumnLayout {
                            id: appListCol
                            anchors.fill: parent
                            anchors.leftMargin: 22
                            anchors.rightMargin: 20
                            anchors.topMargin: 26
                            anchors.bottomMargin: 10
                            spacing: 6
                            z: 5

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: pinItem.modelData.sub
                                    color: "#7fa8d8"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    height: 18
                                    width: statusBadgeText.implicitWidth + 12
                                    radius: 2
                                    color: pinItem.isActiveWs ? "#00e5ff" : (pinItem.apps.length > 0 ? "#0038a8" : "#1a2c4e")
                                    Text {
                                        id: statusBadgeText
                                        anchors.centerIn: parent
                                        text: pinItem.isActiveWs ? "ACTIVE" : (pinItem.apps.length > 0 ? (pinItem.apps.length + " WINS") : "VACANT")
                                        color: pinItem.isActiveWs ? "#020818" : "#ffffff"
                                        font.family: "Rubik"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }
                                }
                            }

                            // Garis Pembatas
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: "#4D00DBFF"
                            }

                            // Daftar Window
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                visible: pinItem.apps.length > 0

                                Repeater {
                                    model: pinItem.apps.slice(0, 4)
                                    delegate: Rectangle {
                                        Layout.fillWidth: true
                                        height: 24
                                        radius: 3
                                        color: "#071638"
                                        border.color: "#4000DBFF"
                                        border.width: 1

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 6
                                            anchors.rightMargin: 6
                                            spacing: 6

                                            Image {
                                                width: 14; height: 14
                                                source: PhantomState.resolveAppIconUrl(modelData.class || modelData.title)
                                                fillMode: Image.PreserveAspectFit
                                                smooth: true
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.title || modelData.class || "App"
                                                color: "#ffffff"
                                                font.family: "JetBrainsMono NFM"
                                                font.pixelSize: 9
                                                font.bold: true
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }
                            }

                            // Tampilan jika kosong
                            Text {
                                visible: pinItem.apps.length === 0
                                text: "NO ACTIVE SIGNALS IN THIS SECTOR"
                                color: "#486a9a"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 9
                                font.bold: true
                                font.italic: true
                            }

                            // Tombol Fast Travel
                            Rectangle {
                                Layout.fillWidth: true
                                height: 26
                                radius: 3
                                color: ftBtnMouse.containsMouse ? "#00f0ff" : "#0028e0"

                                Text {
                                    anchors.centerIn: parent
                                    text: "FAST TRAVEL ➔"
                                    color: ftBtnMouse.containsMouse ? "#020818" : "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    font.letterSpacing: 0.8
                                }

                                MouseArea {
                                    id: ftBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.fastTravelTo(pinItem.modelData.num)
                                }
                            }
                        }
                    }

                    // Interaksi Klik Pin
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selectedDistrictIdx = index
                        onClicked: root.fastTravelTo(pinItem.modelData.num)
                    }
                }
            }
        }

        // 6. The Velvet Room (Elevator of the Soul) Scratchpad Pin di Bawah Kiri
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: 84
            anchors.leftMargin: 24
            width: 280
            height: 48
            radius: 4
            z: 25

            // Gradien Beludru Safir Khas Velvet Room
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#010718" }
                GradientStop { position: 0.5; color: "#051848" }
                GradientStop { position: 1.0; color: "#0d2d78" }
            }
            border.color: PhantomState.specialWorkspaceActive ? "#ffd700" : "#00dbff"
            border.width: 1.6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 12
                spacing: 10

                Image {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    source: "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/icons/elevator.svg"
                    sourceSize.width: 20
                    sourceSize.height: 20
                    fillMode: Image.PreserveAspectFit
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    RowLayout {
                        spacing: 6
                        Text {
                            text: "THE VELVET ROOM"
                            color: PhantomState.specialWorkspaceActive ? "#ffd700" : "#ffffff"
                            font.family: "Rubik"
                            font.pixelSize: 11
                            font.weight: Font.Black
                        }
                    }
                    Text {
                        text: "ELEVATOR OF THE SOUL [SPECIAL]"
                        color: "#00dbff"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 8
                        font.bold: true
                    }
                }

                Rectangle {
                    width: 60
                    height: 22
                    radius: 2
                    color: PhantomState.specialWorkspaceActive ? "#ffd700" : "#0028e0"
                    Text {
                        anchors.centerIn: parent
                        text: PhantomState.specialWorkspaceActive ? "ACTIVE" : "STANDBY"
                        color: PhantomState.specialWorkspaceActive ? "#020818" : "#ffffff"
                        font.family: "Rubik"
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    PhantomState.overviewOpen = false
                    PhantomState.toggleVelvetRoom()
                }
            }
        }
    }
}
