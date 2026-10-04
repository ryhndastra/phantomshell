import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components

// halaman tab informasi proyek phantomshell, pembuat, dan spesifikasi perangkat keras
ColumnLayout {
    Layout.fillWidth: true
    spacing: 12

    P5SectionHeader { text: "ABOUT PHANTOMSHELL // CREATOR & PROJECT DOSSIER" }

    // kartu identitas utama proyek phantomshell
    P5SkewedCard {
        Layout.fillWidth: true
        Layout.preferredHeight: 154
        fillColor: "#12121A"
        borderColor: "#FFFFFF"
        shadowColor: PhantomState.primary
        skewPx: 10

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 18

            Image {
                Layout.preferredWidth: 92
                Layout.preferredHeight: 92
                source: PhantomState.logoPath
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    spacing: 10
                    Text {
                        text: "PHANTOMSHELL v1.0.0 // \"TAKE YOUR HEART\""
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 18
                        font.weight: Font.Black
                        font.italic: true
                    }
                    Rectangle {
                        width: 118
                        height: 20
                        color: PhantomState.secondary
                        border.color: "#09090D"
                        border.width: 2
                        Text {
                            anchors.centerIn: parent
                            text: "★ BY SHO (JOKER)"
                            color: "#09090D"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                    }
                }
                Text {
                    text: "Created & Engineered by sho • Custom Persona 5 Royal Wayland Desktop Shell"
                    color: PhantomState.secondary
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 11
                    font.weight: Font.Black
                }
                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: "Phantomshell adalah desktop environment custom bergaya Persona 5 Royal yang dibangun khusus di atas Quickshell (Qt6) & Hyprland (Lua Engine) untuk NixOS. Menggabungkan comic-cutout UI, Velvet Room Settings, Jagged Desktop Clock + Real-Time Weather, 64-Band Split Cava, serta LRCLIB Live Lyrics dengan tetap hemat CPU/GPU untuk gaming."
                    color: PhantomState.muted
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    lineHeight: 1.15
                }

                // deretan tombol aksi cepat pada kartu informasi
                RowLayout {
                    spacing: 8
                    Layout.topMargin: 4

                    Repeater {
                        model: [
                            { label: "↻ REFRESH SPECS", action: "refresh" },
                            { label: "★ FIRE CALLING CARD", action: "test_im" },
                            { label: "✎ OPEN DOTFILES", action: "open_dir" }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            width: chipTxt.implicitWidth + 20
                            height: 24
                            color: chipMouse.containsMouse ? PhantomState.primary : "#1E1E2A"
                            border.color: "#FFFFFF"
                            border.width: 2

                            Text {
                                id: chipTxt
                                anchors.centerIn: parent
                                text: modelData.label
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 9
                                font.weight: Font.Black
                            }

                            MouseArea {
                                id: chipMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.action === "refresh") {
                                        PhantomState.refreshSystemDossier()
                                        PhantomState.refreshMonitors()
                                    } else if (modelData.action === "test_im") {
                                        PhantomState.sendTestNotification()
                                    } else if (modelData.action === "open_dir") {
                                        Quickshell.execDetached(["sh", "-c", "ghostty --working-directory=/mnt/data/Projects/rice/phantomshell || kitty -d /mnt/data/Projects/rice/phantomshell || xdg-open /mnt/data/Projects/rice/phantomshell"])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // grid informasi pembuat dan arsitektur shell
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 10
        columnSpacing: 10

        Repeater {
            model: [
                {
                    tag: "AUTHOR // CREATOR",
                    title: "sho (Ren Amamiya / Joker)",
                    sub: "Lead Architect, UI/UX Designer & NixOS System Builder",
                    badge: "CREATOR"
                },
                {
                    tag: "SHELL // ARCHITECTURE",
                    title: "Phantomshell v1.0.0 (Metaverse Build)",
                    sub: "Quickshell 0.3 (Qt6 QML) • Hyprland 0.56 (Lua Config)",
                    badge: "v1.0.0"
                },
                {
                    tag: "ART DIRECTION // UI",
                    title: "Persona 5 Royal Comic-Cutout Engine",
                    sub: "Inspired by ATLUS & Shigenori Soejima • 9 Theme Palettes",
                    badge: "P5 ROYAL"
                },
                {
                    tag: "MODULES // ECOSYSTEM",
                    title: "Bar • Launcher • Radar • SNS • Clock • Cava • Lyrics",
                    sub: "PipeWire Audio • LRCLIB Synced Lyrics • Open-Meteo Weather",
                    badge: "FULL SUITE"
                }
            ]

            delegate: Item {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 72

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: "#161622"
                    borderColor: PhantomState.secondary
                    shadowColor: PhantomState.primary
                    borderWidth: 2
                    skewPx: 8
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "★ " + modelData.tag
                            color: PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.title
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 13
                            font.weight: Font.Black
                            font.italic: true
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.sub
                            color: PhantomState.muted
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        width: 78
                        height: 24
                        color: PhantomState.secondary
                        border.color: "#09090D"
                        border.width: 2
                        rotation: -3

                        Text {
                            anchors.centerIn: parent
                            text: modelData.badge
                            color: "#09090D"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                    }
                }
            }
        }
    }

    P5SectionHeader { text: "HOST HARDWARE & OPERATING SYSTEM SPECIFICATIONS" }

    // grid spesifikasi perangkat keras dan sistem operasi
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 10
        columnSpacing: 10

        Repeater {
            model: [
                {
                    tag: "OS // DISTRO",
                    title: PhantomState.sysOs,
                    sub: "Host: " + PhantomState.sysHost + " • NixOS Declarative Flake",
                    badge: "NIXOS"
                },
                {
                    tag: "KERNEL // UPTIME",
                    title: PhantomState.sysKernel,
                    sub: "Session Uptime: " + PhantomState.sysUptime + " • Wayland Protocol",
                    badge: "LIVE"
                },
                {
                    tag: "PROCESSOR // CPU",
                    title: PhantomState.sysCpuModel,
                    sub: "Current Load: " + Math.round(PhantomState.cpuPct) + "% • Thermal: " + Math.round(PhantomState.tempPct) + "°C",
                    badge: Math.round(PhantomState.cpuPct) + "%"
                },
                {
                    tag: "GRAPHICS // GPU",
                    title: PhantomState.sysGpuModel,
                    sub: "Hardware Accelerated OpenGL / Vulkan SceneGraph",
                    badge: Math.round(PhantomState.gpuPct) + "%"
                },
                {
                    tag: "MEMORY // STORAGE",
                    title: "RAM: " + PhantomState.sysRamText,
                    sub: "Memory Usage: " + Math.round(PhantomState.ramPct) + "% • Disk Usage: " + Math.round(PhantomState.diskPct) + "%",
                    badge: Math.round(PhantomState.ramPct) + "%"
                },
                {
                    tag: "DISPLAY // COMPOSITOR",
                    title: PhantomState.displayName + " • " + PhantomState.displayMode,
                    sub: "Hyprland 0.56.2 (Lua Engine) + Quickshell 0.3.0 (Qt6)",
                    badge: "MAX HZ"
                }
            ]

            delegate: Item {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 74

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: "#14141D"
                    borderColor: "#FFFFFF"
                    shadowColor: PhantomState.primary
                    borderWidth: 2
                    skewPx: 8
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "★ " + modelData.tag
                            color: PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.title
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 13
                            font.weight: Font.Black
                            font.italic: true
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.sub
                            color: PhantomState.muted
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        width: 68
                        height: 26
                        color: PhantomState.primary
                        border.color: "#FFFFFF"
                        border.width: 1.5
                        rotation: -3

                        Text {
                            anchors.centerIn: parent
                            text: modelData.badge
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Black
                        }
                    }
                }
            }
        }
    }

    P5SectionHeader { text: "PHANTOM THIEVES ENGINE // ARCHITECTURE & CREDITS" }

    P5SkewedCard {
        Layout.fillWidth: true
        Layout.preferredHeight: 68
        fillColor: "#101017"
        borderColor: PhantomState.secondary
        shadowColor: PhantomState.primary
        borderWidth: 2
        skewPx: 8

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 14

            P5Star {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "\"TAKE YOUR TIME // STEAL BACK YOUR FUTURE\""
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 13
                    font.weight: Font.Black
                    font.italic: true
                }
                Text {
                    text: "Inspired by ATLUS Persona 5 Royal • Built with Quickshell Qt6, Hyprland Lua, PipeWire, Cava, LRCLIB & Open-Meteo"
                    color: PhantomState.muted
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }

    P5SectionHeader { text: "PHANTOM ENGINE // UPDATER \u0026 SYNC" }

    // kartu status git dan kontrol sinkronisasi
    P5SkewedCard {
        Layout.fillWidth: true
        Layout.preferredHeight: 90
        fillColor: {
            if (PhantomState.syncStatus === "ERROR") return "#1A0A0A"
            if (PhantomState.syncStatus === "DONE") return "#0A1A0F"
            if (PhantomState.syncUpdateAvailable) return "#1A1300"
            return "#12121C"
        }
        borderColor: {
            if (PhantomState.syncStatus === "ERROR") return "#FF3333"
            if (PhantomState.syncStatus === "DONE") return PhantomState.success
            if (PhantomState.syncUpdateAvailable) return PhantomState.secondary
            return "#FFFFFF"
        }
        shadowColor: PhantomState.primary
        borderWidth: 2
        skewPx: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 6

            // baris header dan badge status
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Text {
                    text: "★ GIT // UPDATER"
                    color: PhantomState.secondary
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    font.weight: Font.Black
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    Layout.preferredWidth: statusBadgeTxt.implicitWidth + 18
                    Layout.preferredHeight: 20
                    width: statusBadgeTxt.implicitWidth + 18
                    height: 20
                    color: {
                        const s = PhantomState.syncStatus
                        if (s === "ERROR") return "#FF3333"
                        if (s === "DONE") return PhantomState.success
                        if (s === "UPDATE_AVAILABLE") return PhantomState.secondary
                        if (s === "UP_TO_DATE") return "#204020"
                        return "#1E1E2A"
                    }
                    border.color: "#FFFFFF"
                    border.width: 1
                    Text {
                        id: statusBadgeTxt
                        anchors.centerIn: parent
                        text: {
                            const s = PhantomState.syncStatus
                            if (s === "IDLE") return "UP TO DATE ✓"
                            if (s === "CHECKING") return "CHECKING..."
                            if (s === "UP_TO_DATE") return "UP TO DATE ✓"
                            if (s === "UPDATE_AVAILABLE") return PhantomState.gitBehind + " COMMITS BEHIND"
                            if (s === "AHEAD") return PhantomState.gitAhead + " AHEAD"
                            if (s === "PULLING") return "PULLING..."
                            if (s === "SYNCING") return "SYNCING..."
                            if (s === "RELOADING") return "RELOADING..."
                            if (s === "DONE") return "DONE ★"
                            if (s === "ERROR") return "ERROR ✗"
                            if (s === "OFFLINE") return "OFFLINE"
                            return s
                        }
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 9
                        font.weight: Font.Black
                    }
                }
            }

            // baris hash commit lokal dan remote
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: PhantomState.gitBranch + " @ " + PhantomState.gitLocalHash
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 12
                    font.weight: Font.Black
                    font.italic: true
                }
                Text {
                    text: "→ " + PhantomState.gitRemoteHash
                    color: PhantomState.secondary
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 11
                    font.weight: Font.Black
                    visible: PhantomState.gitRemoteHash !== "-------" && PhantomState.gitRemoteHash !== PhantomState.gitLocalHash
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: PhantomState.gitLastDate
                    color: PhantomState.muted
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    elide: Text.ElideRight
                    Layout.maximumWidth: 110
                }
            }

            // baris pesan commit dan tombol aksi
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    Layout.fillWidth: true
                    text: PhantomState.gitLastMsg || "Ready"
                    color: PhantomState.muted
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }

                // tombol check update dari remote
                Rectangle {
                    Layout.preferredWidth: checkUpdTxt.implicitWidth + 16
                    Layout.preferredHeight: 22
                    width: checkUpdTxt.implicitWidth + 16
                    height: 22
                    color: checkUpdMouse.containsMouse ? PhantomState.primary : "#1E1E2E"
                    border.color: "#FFFFFF"
                    border.width: 1.5
                    opacity: PhantomState.syncBusy ? 0.4 : 1.0
                    Text {
                        id: checkUpdTxt
                        anchors.centerIn: parent
                        text: "↺ CHECK"
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 9
                        font.weight: Font.Black
                    }
                    MouseArea {
                        id: checkUpdMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PhantomState.checkSyncUpdate()
                    }
                }

                // tombol apply dev ke sistem tanpa pull
                Rectangle {
                    Layout.preferredWidth: applyUpdTxt.implicitWidth + 16
                    Layout.preferredHeight: 22
                    width: applyUpdTxt.implicitWidth + 16
                    height: 22
                    color: applyUpdMouse.containsMouse ? PhantomState.secondary : "#1E1E2E"
                    border.color: PhantomState.secondary
                    border.width: 1.5
                    opacity: PhantomState.syncBusy ? 0.4 : 1.0
                    Text {
                        id: applyUpdTxt
                        anchors.centerIn: parent
                        text: "↗ APPLY"
                        color: applyUpdMouse.containsMouse ? "#09090D" : PhantomState.secondary
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 9
                        font.weight: Font.Black
                    }
                    MouseArea {
                        id: applyUpdMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PhantomState.syncToSystem()
                    }
                }

                // tombol pull dari github + sync
                Rectangle {
                    Layout.preferredWidth: pullUpdTxt.implicitWidth + 16
                    Layout.preferredHeight: 22
                    width: pullUpdTxt.implicitWidth + 16
                    height: 22
                    color: pullUpdMouse.containsMouse ? PhantomState.primary : (PhantomState.syncUpdateAvailable ? "#2A1800" : "#1E1E2E")
                    border.color: PhantomState.syncUpdateAvailable ? PhantomState.secondary : "#FFFFFF"
                    border.width: PhantomState.syncUpdateAvailable ? 2 : 1.5
                    opacity: PhantomState.syncBusy ? 0.4 : 1.0
                    Text {
                        id: pullUpdTxt
                        anchors.centerIn: parent
                        text: "↓ PULL \u0026 SYNC"
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 9
                        font.weight: Font.Black
                    }
                    MouseArea {
                        id: pullUpdMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PhantomState.pullAndSync()
                    }
                }
            }
        }
    }

    // terminal log output sinkronisasi
    P5SkewedCard {
        id: syncLogCard
        Layout.fillWidth: true
        Layout.preferredHeight: syncLogCard.logVisible ? 130 : 34
        fillColor: "#080810"
        borderColor: "#2A2A44"
        shadowColor: PhantomState.primary
        borderWidth: 1
        skewPx: 4
        clip: true

        property bool logVisible: PhantomState.syncBusy || PhantomState.syncLog.length > 0

        Behavior on Layout.preferredHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Text {
                    text: "SYNC LOG //"
                    color: PhantomState.muted
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    font.weight: Font.Black
                }
                Text {
                    text: PhantomState.syncBusy ? "RUNNING..." : (PhantomState.syncStatus === "DONE" ? "COMPLETED" : (PhantomState.syncStatus === "ERROR" ? "FAILED" : "READY"))
                    color: PhantomState.syncStatus === "ERROR" ? "#FF4444" : (PhantomState.syncStatus === "DONE" ? PhantomState.success : PhantomState.muted)
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    font.weight: Font.Black
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "CLR"
                    color: clrLogMouse.containsMouse ? "#FFFFFF" : PhantomState.muted
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    font.weight: Font.Black
                    MouseArea {
                        id: clrLogMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PhantomState.clearSyncLog()
                    }
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: syncLogText.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                onContentHeightChanged: contentY = Math.max(0, contentHeight - height)
                Text {
                    id: syncLogText
                    width: parent.width
                    text: PhantomState.syncLog || "— waiting for operation —"
                    color: "#6E7EB8"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    lineHeight: 1.4
                }
            }
        }
    }

    P5SectionHeader { text: "KEYBOARD BINDS // PHANTOM THIEF TACTICS COMPENDIUM" }

    // cheat sheet seluruh keybind aktif hyprland
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 6
        columnSpacing: 8

        Repeater {
            model: [
                { cat: "PHANTOM SHELL // PANELS", key: "SUPER / SUPER + D", act: "Toggle Launcher (P5 Command Search)" },
                { cat: "", key: "SUPER + Tab", act: "Workspace Overview (Metaverse Grid)" },
                { cat: "", key: "SUPER + V", act: "Clipboard History Compendium" },
                { cat: "", key: "SUPER + .", act: "Emoji Picker Compendium" },
                { cat: "", key: "SUPER + /", act: "Tactics Keybind Cheatsheet Overlay" },
                { cat: "", key: "SUPER + N / G", act: "Control Center \u0026 Pentagon Stats" },
                { cat: "", key: "SUPER + A / B / O", act: "SNS Phone Notification Center" },
                { cat: "", key: "SUPER + M", act: "Media Controls Popup" },
                { cat: "", key: "SUPER + I", act: "Unified Settings (Velvet Room)" },
                { cat: "", key: "SUPER + J", act: "Toggle Top Bar Auto-Hide" },
                { cat: "", key: "CTRL + SUPER + T", act: "Open Wallpaper Selector" },
                { cat: "", key: "CTRL + SUPER + P", act: "Cycle Persona Theme Palette" },
                { cat: "", key: "SUPER + L", act: "Lock Screen (Calling Card Lock)" },
                { cat: "", key: "SUPER + Esc / Ctrl+Alt+Del", act: "Power Menu (Calling Card Session)" },
                { cat: "APPLICATIONS", key: "SUPER + Return / T", act: "Launch Terminal (Kitty)" },
                { cat: "", key: "SUPER + E", act: "Launch File Manager" },
                { cat: "", key: "SUPER + W", act: "Launch Web Browser" },
                { cat: "", key: "SUPER + C", act: "Launch Code Editor" },
                { cat: "", key: "SUPER + X", act: "Launch Text Editor" },
                { cat: "", key: "CTRL + SUPER + V", act: "Launch Volume Mixer" },
                { cat: "", key: "CTRL + SHIFT + Esc", act: "Launch Task Manager" },
                { cat: "UTILITIES // CAPTURE", key: "SUPER + SHIFT + S", act: "Region Screenshot >> Clipboard \u0026 File" },
                { cat: "", key: "Print / CTRL + Print", act: "Fullscreen Screenshot (Copy / Save)" },
                { cat: "", key: "SUPER + SHIFT + X", act: "Region OCR Text Scan >> Clipboard" },
                { cat: "", key: "SUPER + SHIFT + C", act: "Color Picker (#RRGGBB >> Clipboard)" },
                { cat: "", key: "SUPER + SHIFT + R", act: "Record Region Screen (Toggle)" },
                { cat: "WINDOW \u0026 WORKSPACES", key: "SUPER + Q", act: "Close Active Window" },
                { cat: "", key: "SUPER + F / SHIFT + F", act: "Maximize / Fullscreen Window" },
                { cat: "", key: "SUPER + ALT + Space", act: "Toggle Float / Tile Window" },
                { cat: "", key: "SUPER + P", act: "Pin Floating Window" },
                { cat: "", key: "SUPER + S / ALT + S", act: "Toggle / Send to Scratchpad" },
                { cat: "", key: "SUPER + 1..0", act: "Switch / Send (SHIFT) Workspace 1-10" },
                { cat: "", key: "CTRL + SUPER + ← / →", act: "Switch Workspace Left / Right" },
                { cat: "", key: "SUPER + - / =", act: "Zoom Screen Out / In" }
            ]

            delegate: Item {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                Layout.preferredHeight: modelData.cat !== "" ? 54 : 32

                // label kategori keybind
                Text {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    text: "★ " + modelData.cat
                    color: PhantomState.secondary
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    font.weight: Font.Black
                    visible: modelData.cat !== ""
                }

                // baris shortcut individual
                P5SkewedCard {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 28
                    fillColor: "#12121C"
                    borderColor: "#2A2A40"
                    shadowColor: PhantomState.primary
                    borderWidth: 1
                    skewPx: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8
                        Rectangle {
                            width: kbTxt.implicitWidth + 14
                            height: 18
                            color: "#1A1A2E"
                            border.color: PhantomState.secondary
                            border.width: 1
                            radius: 2
                            Text {
                                id: kbTxt
                                anchors.centerIn: parent
                                text: modelData.key
                                color: PhantomState.secondary
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 8
                                font.weight: Font.Black
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.act
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
