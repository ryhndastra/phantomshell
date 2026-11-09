import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

// Tatsumi Port Island workspace overview.
Scope {
    id: root

    readonly property int activeWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
    property int selectedDistrictIdx: 0

    // District layout coordinates
    readonly property var districts: [
        {
            num: 1,
            name: "Moonlight Gate & Bridge",
            code: "MOONLIGHT GATE",
            sub: "Western Coast & Bridge",
            mapX: 0.20,
            mapY: 0.36,
            cardSide: "right"
        },
        {
            num: 2,
            name: "Iwatodai Strip Mall",
            code: "IWATODAI STRIP",
            sub: "Station & Dormitory",
            mapX: 0.36,
            mapY: 0.28,
            cardSide: "bottom"
        },
        {
            num: 3,
            name: "Naganaki Shrine",
            code: "NAGANAKI SHRINE",
            sub: "Shrine Grounds & Woods",
            mapX: 0.52,
            mapY: 0.20,
            cardSide: "bottom"
        },
        {
            num: 4,
            name: "Port Island Station",
            code: "PORT ISLAND STN",
            sub: "Harbor & Rail Terminal",
            mapX: 0.44,
            mapY: 0.64,
            cardSide: "right"
        },
        {
            num: 5,
            name: "Paulownia Mall",
            code: "PAULOWNIA MALL",
            sub: "Arcade & Police Dept",
            mapX: 0.58,
            mapY: 0.44,
            cardSide: "left"
        },
        {
            num: 6,
            name: "Gekkoukan High School",
            code: "GEKKOUKAN HIGH",
            sub: "Classrooms & Rooftop",
            mapX: 0.72,
            mapY: 0.52,
            cardSide: "left"
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
                // Set seleksi awal ke workspace aktif saat ini jika dalam range 1-6
                const actId = root.activeWsId
                let found = -1
                for (let i = 0; i < root.districts.length; ++i) {
                    if (root.districts[i].num === actId) {
                        found = i
                        break
                    }
                }
                root.selectedDistrictIdx = (found >= 0) ? found : 0
                tacticalMapCanvas.requestPaint()
                ovKeyHandler.forceActiveFocus()
            }
        }

        // Keyboard navigation (1-6, arrows, WASD, Enter, Esc)
        Item {
            id: ovKeyHandler
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_C) {
                    PhantomState.overviewOpen = false
                    event.accepted = true
                } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_6) {
                    const targetWs = event.key - Qt.Key_0
                    root.fastTravelTo(targetWs)
                    event.accepted = true
                } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right || event.key === Qt.Key_D) {
                    root.selectedDistrictIdx = (root.selectedDistrictIdx + 1) % root.districts.length
                    event.accepted = true
                } else if (event.key === Qt.Key_Left || event.key === Qt.Key_A) {
                    root.selectedDistrictIdx = (root.selectedDistrictIdx - 1 + root.districts.length) % root.districts.length
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                    const d = root.districts[root.selectedDistrictIdx]
                    if (d) root.fastTravelTo(d.num)
                    event.accepted = true
                } else if (event.key === Qt.Key_V) {
                    PhantomState.overviewOpen = false
                    PhantomState.toggleVelvetRoom()
                    event.accepted = true
                }
            }
        }

        // Vector map canvas
        Canvas {
            id: tacticalMapCanvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var w = width
                var h = height

                // A. Latar Belakang Gradien Samudera Gelap
                var bgGrad = ctx.createRadialGradient(w * 0.52, h * 0.48, Math.min(w, h) * 0.12, w * 0.50, h * 0.50, Math.max(w, h) * 0.75)
                bgGrad.addColorStop(0.0, "#061b4a")
                bgGrad.addColorStop(0.4, "#030f2d")
                bgGrad.addColorStop(0.85, "#010718")
                bgGrad.addColorStop(1.0, "#00030a")
                ctx.fillStyle = bgGrad
                ctx.fillRect(0, 0, w, h)

                // B. Grid Taktikal Halus di Permukaan Air
                ctx.strokeStyle = "rgba(0, 219, 255, 0.04)"
                ctx.lineWidth = 1.0
                for (var y = 60; y < h; y += 48) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(w, y)
                    ctx.stroke()
                }
                for (var x = 60; x < w; x += 64) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, h)
                    ctx.stroke()
                }

                // C. Lingkaran Sonar / Radar Taktikal S.E.E.S.
                var cx = w * 0.52
                var cy = h * 0.46
                var radii = [h * 0.16, h * 0.30, h * 0.46, h * 0.62]

                ctx.strokeStyle = "rgba(0, 219, 255, 0.10)"
                ctx.lineWidth = 1.2
                ctx.setLineDash([4, 6])
                for (var i = 0; i < radii.length; i++) {
                    ctx.beginPath()
                    ctx.arc(cx, cy, radii[i], 0, Math.PI * 2)
                    ctx.stroke()
                }
                ctx.setLineDash([])

                // Crosshairs Radar Sumbu Tengah
                ctx.strokeStyle = "rgba(0, 219, 255, 0.16)"
                ctx.lineWidth = 1.0
                ctx.beginPath()
                ctx.moveTo(cx - radii[3], cy); ctx.lineTo(cx + radii[3], cy)
                ctx.moveTo(cx, cy - radii[3]); ctx.lineTo(cx, cy + radii[3])
                ctx.stroke()

                // D. Kontur Teluk & Kedalaman Air (Bathymetry Waves)
                ctx.strokeStyle = "rgba(0, 180, 255, 0.08)"
                ctx.lineWidth = 1.5
                ctx.beginPath()
                ctx.moveTo(w * 0.15, h * 0.58)
                ctx.quadraticCurveTo(w * 0.35, h * 0.52, w * 0.48, h * 0.78)
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(w * 0.25, h * 0.32)
                ctx.quadraticCurveTo(w * 0.48, h * 0.38, w * 0.82, h * 0.32)
                ctx.stroke()

                // Layer Gelombang Luar Pulau (Reef/Shallows)
                ctx.strokeStyle = "rgba(0, 219, 255, 0.14)"
                ctx.lineWidth = 1.0
                ctx.beginPath()
                ctx.moveTo(w * 0.40, h * 0.53)
                ctx.lineTo(w * 0.42, h * 0.74)
                ctx.lineTo(w * 0.60, h * 0.77)
                ctx.lineTo(w * 0.77, h * 0.66)
                ctx.lineTo(w * 0.81, h * 0.44)
                ctx.lineTo(w * 0.74, h * 0.25)
                ctx.lineTo(w * 0.54, h * 0.25)
                ctx.lineTo(w * 0.41, h * 0.38)
                ctx.closePath()
                ctx.stroke()

                // E. Daratan Pesisir Utara / Mainland (Iwatodai & Naganaki Shrine)
                ctx.beginPath()
                ctx.moveTo(0, 0)
                ctx.lineTo(w, 0)
                ctx.lineTo(w, h * 0.18)
                ctx.quadraticCurveTo(w * 0.72, h * 0.18, w * 0.58, h * 0.15)
                ctx.quadraticCurveTo(w * 0.48, h * 0.25, w * 0.40, h * 0.23)
                ctx.quadraticCurveTo(w * 0.34, h * 0.37, w * 0.26, h * 0.35)
                ctx.quadraticCurveTo(w * 0.18, h * 0.44, w * 0.12, h * 0.42)
                ctx.quadraticCurveTo(w * 0.05, h * 0.40, 0, h * 0.44)
                ctx.closePath()

                var landGrad = ctx.createLinearGradient(0, 0, 0, h * 0.45)
                landGrad.addColorStop(0.0, "rgba(8, 28, 76, 0.85)")
                landGrad.addColorStop(1.0, "rgba(4, 16, 48, 0.90)")
                ctx.fillStyle = landGrad
                ctx.fill()

                ctx.strokeStyle = "rgba(0, 200, 255, 0.55)"
                ctx.lineWidth = 1.8
                ctx.stroke()

                // F. Daratan Pulau Buatan Tatsumi Port Island (Center-Right)
                ctx.beginPath()
                ctx.moveTo(w * 0.42, h * 0.54) // Western Bridgehead
                ctx.lineTo(w * 0.44, h * 0.72) // Port Island Station South Docks
                ctx.lineTo(w * 0.58, h * 0.74) // South Pier Breakwater
                ctx.lineTo(w * 0.74, h * 0.64) // Gekkoukan Athletics Bay
                ctx.lineTo(w * 0.78, h * 0.44) // Eastern Peninsula
                ctx.lineTo(w * 0.72, h * 0.28) // Paulownia Plaza North Coast
                ctx.lineTo(w * 0.56, h * 0.28) // North Harbor
                ctx.lineTo(w * 0.44, h * 0.40) // Inner Channel
                ctx.closePath()

                var islandGrad = ctx.createLinearGradient(w * 0.44, h * 0.28, w * 0.74, h * 0.74)
                islandGrad.addColorStop(0.0, "rgba(12, 38, 102, 0.90)")
                islandGrad.addColorStop(1.0, "rgba(5, 18, 56, 0.95)")
                ctx.fillStyle = islandGrad
                ctx.fill()

                ctx.strokeStyle = "#00e5ff"
                ctx.lineWidth = 2.2
                ctx.stroke()

                // Garis Jalan / Blok Distrik Internal di Port Island
                ctx.strokeStyle = "rgba(0, 219, 255, 0.14)"
                ctx.lineWidth = 1.0
                ctx.beginPath()
                ctx.moveTo(w * 0.56, h * 0.30); ctx.lineTo(w * 0.52, h * 0.64); ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(w * 0.46, h * 0.54); ctx.lineTo(w * 0.74, h * 0.46); ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(w * 0.62, h * 0.36); ctx.lineTo(w * 0.68, h * 0.52); ctx.stroke()

                // G. Moonlight Bridge (Gate 01 ke Port Island 04)
                ctx.beginPath()
                ctx.moveTo(w * 0.20, h * 0.36)
                ctx.lineTo(w * 0.42, h * 0.58)
                ctx.strokeStyle = "rgba(0, 240, 255, 0.7)"
                ctx.lineWidth = 3.0
                ctx.stroke()

                ctx.beginPath()
                ctx.moveTo(w * 0.20, h * 0.38)
                ctx.lineTo(w * 0.42, h * 0.60)
                ctx.strokeStyle = "rgba(0, 160, 255, 0.4)"
                ctx.lineWidth = 1.5
                ctx.stroke()

                // H. Jalur Transit Monorel (Menghubungkan 6 Distrik Berurutan 1-6)
                ctx.setLineDash([8, 6])
                ctx.beginPath()
                ctx.moveTo(w * 0.20, h * 0.36) // 01 Moonlight Gate
                ctx.lineTo(w * 0.36, h * 0.28) // 02 Iwatodai Strip
                ctx.lineTo(w * 0.52, h * 0.20) // 03 Naganaki Shrine
                ctx.lineTo(w * 0.72, h * 0.52) // 06 Gekkoukan High
                ctx.lineTo(w * 0.58, h * 0.44) // 05 Paulownia Mall
                ctx.lineTo(w * 0.44, h * 0.64) // 04 Port Island Station
                ctx.closePath() // Kembali menyambung ke 01
                ctx.strokeStyle = "#00ffcc"
                ctx.lineWidth = 2.0
                ctx.stroke()
                ctx.setLineDash([])

                // I. Teks Koordinat Taktikal S.E.E.S.
                ctx.fillStyle = "rgba(0, 219, 255, 0.32)"
                ctx.font = "bold 9px 'JetBrainsMono NFM', monospace"
                ctx.fillText("TACTICAL BAY // SOUNDING: 42M", w * 0.36, h * 0.48)
                ctx.fillText("MONORAIL LOOP LINE", w * 0.52, h * 0.38)
                ctx.fillText("GRID: LAT 35°38'N / LONG 139°45'E", w * 0.08, h * 0.88)
                ctx.fillText("S.E.E.S. SATELLITE TACTICAL LINK", w * 0.08, h * 0.90)

                // J. Vignette Bayangan Tepian Layar
                var vig = ctx.createRadialGradient(w / 2, h / 2, Math.min(w, h) * 0.40, w / 2, h / 2, Math.max(w, h) * 0.72)
                vig.addColorStop(0.0, "transparent")
                vig.addColorStop(1.0, "rgba(2, 6, 18, 0.82)")
                ctx.fillStyle = vig
                ctx.fillRect(0, 0, w, h)
            }
        }

        // Header
        Item {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 24
            anchors.leftMargin: 28
            width: 440
            height: 52
            z: 20

            ColumnLayout {
                anchors.fill: parent
                spacing: 2

                RowLayout {
                    spacing: 8
                    Rectangle {
                        width: 8
                        height: 20
                        color: "#00dbff"
                    }
                    Text {
                        text: "S.E.E.S. TACTICAL MAP // WORKSPACE OVERVIEW"
                        color: "#ffffff"
                        font.family: "Rubik"
                        font.pixelSize: 16
                        font.weight: Font.Black
                        font.letterSpacing: 1.2
                    }
                }

                Text {
                    text: "S.E.E.S. RADAR NET • SELECT DISTRICT TO DISPATCH HYPRLAND WORKSPACE"
                    color: "#00dbff"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 0.5
                }
            }
        }

        // Close button
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 24
            anchors.rightMargin: 28
            height: 34
            width: closeLayout.implicitWidth + 24
            radius: 4
            color: closeMouse.containsMouse ? "#d60032" : "#F0040C26"
            border.color: closeMouse.containsMouse ? "#ffffff" : "#9900DBFF"
            border.width: 1.2
            z: 20

            RowLayout {
                id: closeLayout
                anchors.centerIn: parent
                spacing: 8

                Rectangle {
                    width: 32
                    height: 18
                    radius: 2
                    color: closeMouse.containsMouse ? "#ffffff" : "#0028e0"
                    Text {
                        anchors.centerIn: parent
                        text: "ESC"
                        color: closeMouse.containsMouse ? "#d60032" : "#ffffff"
                        font.family: "Rubik"
                        font.pixelSize: 9
                        font.bold: true
                    }
                }

                Text {
                    text: "CLOSE MAP"
                    color: "#ffffff"
                    font.family: "Rubik"
                    font.pixelSize: 11
                    font.weight: Font.Black
                    font.letterSpacing: 0.8
                }
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PhantomState.overviewOpen = false
            }
        }

        // Townmap stencil
        Item {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 320
            height: 90
            z: 15

            Canvas {
                anchors.fill: parent
                antialiasing: true
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    var w = width
                    var h = height

                    ctx.beginPath()
                    ctx.moveTo(0, h * 0.45)
                    ctx.lineTo(w, h)
                    ctx.lineTo(0, h)
                    ctx.closePath()
                    ctx.fillStyle = "rgba(0, 40, 224, 0.4)"
                    ctx.fill()
                }
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.bottomMargin: 8
                text: "TOWNMAP"
                font.family: "Rubik"
                font.pixelSize: 44
                font.weight: Font.Black
                font.italic: true
                color: "#030e38"
                renderType: Text.CurveRendering
            }
        }

        // Navigation controls bar
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 24
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

        // Interactive district pins
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

                    // A. Glowing Target Reticle Cyan
                    Item {
                        anchors.centerIn: parent
                        width: 84
                        height: 84
                        visible: pinItem.isSelected

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

                                // Lingkaran Dalam
                                ctx.beginPath()
                                ctx.arc(cx, cy, 28, 0, Math.PI * 2)
                                ctx.strokeStyle = "rgba(0, 240, 255, 0.45)"
                                ctx.lineWidth = 1.0
                                ctx.stroke()

                                // Notches Crosshair
                                var notch = 8
                                ctx.strokeStyle = "#00f0ff"
                                ctx.lineWidth = 2.0
                                ctx.beginPath(); ctx.moveTo(cx, cy - 36); ctx.lineTo(cx, cy - 36 + notch); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx, cy + 36); ctx.lineTo(cx, cy + 36 - notch); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx - 36, cy); ctx.lineTo(cx - 36 + notch, cy); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx + 36, cy); ctx.lineTo(cx + 36 - notch, cy); ctx.stroke()
                            }
                        }
                    }

                    // Teardrop pin icon
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

                            // Pin drop shadow
                            ctx.beginPath()
                            ctx.ellipse(cx, height - 4, 12, 4, 0, 0, Math.PI * 2)
                            ctx.fillStyle = "rgba(0, 0, 0, 0.6)"
                            ctx.fill()

                            // Pin body
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

                    // Workspace number inside pin
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 8
                        text: pinItem.modelData.num < 10 ? ("0" + pinItem.modelData.num) : pinItem.modelData.num
                        font.family: "Rubik"
                        font.pixelSize: 13
                        font.weight: Font.Black
                        color: pinItem.isActiveWs ? "#020818" : "#ffffff"
                    }

                    // District name label (hidden when pin is active)
                    Rectangle {
                        anchors.left: parent.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -8
                        height: 26
                        width: pinLabelText.implicitWidth + 20
                        radius: 3
                        visible: !pinItem.isSelected
                        color: "#E6040C26"
                        border.color: "#4DFFFFFF"
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

                    // Workspace detail popup
                    Item {
                        id: detailHoverCard
                        visible: pinItem.isSelected
                        width: 340
                        height: Math.max(140, appListCol.implicitHeight + 64)
                        z: 50

                        x: pinItem.modelData.cardSide === "left" ? -350 : (pinItem.modelData.cardSide === "bottom" ? -140 : 60)
                        y: pinItem.modelData.cardSide === "bottom" ? 54 : -30

                        Canvas {
                            anchors.fill: parent
                            antialiasing: true
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.reset()
                                var w = width
                                var h = height

                                // Shard accent
                                ctx.fillStyle = "rgba(0, 160, 255, 0.28)"
                                ctx.beginPath()
                                ctx.moveTo(w - 60, -2)
                                ctx.lineTo(w + 4, -2)
                                ctx.lineTo(w - 6, h + 2)
                                ctx.lineTo(w - 70, h + 2)
                                ctx.closePath()
                                ctx.fill()

                                // Dialog body
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

                                // Wedge accent
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
                                        height: 26
                                        radius: 3
                                        color: "#071638"
                                        border.color: "#4000DBFF"
                                        border.width: 1
                                        clip: true

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            spacing: 6

                                            Image {
                                                Layout.preferredWidth: 16
                                                Layout.preferredHeight: 16
                                                sourceSize.width: 16
                                                sourceSize.height: 16
                                                source: modelData.iconUrl || PhantomState.resolveAppIconUrl(modelData.cls || modelData.title)
                                                fillMode: Image.PreserveAspectFit
                                                smooth: true
                                                clip: true
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.title || modelData.cls || "App"
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

        // Velvet Room shortcut card
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: 84
            anchors.leftMargin: 24
            width: 290
            height: 50
            radius: 4
            z: 25

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#010718" }
                GradientStop { position: 0.5; color: "#051848" }
                GradientStop { position: 1.0; color: "#0d2d78" }
            }
            border.color: PhantomState.specialWorkspaceActive ? "#ffd700" : (velvetMouse.containsMouse ? "#00f0ff" : "#0055c8")
            border.width: 1.8

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 12
                spacing: 12

                Image {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    source: "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/icons/elevator.svg"
                    sourceSize.width: 22
                    sourceSize.height: 22
                    fillMode: Image.PreserveAspectFit
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "THE VELVET ROOM"
                        color: PhantomState.specialWorkspaceActive ? "#ffd700" : "#ffffff"
                        font.family: "Rubik"
                        font.pixelSize: 11
                        font.weight: Font.Black
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
                    width: 62
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
                id: velvetMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    PhantomState.overviewOpen = false
                    PhantomState.toggleVelvetRoom()
                }
            }
        }
    }
}
