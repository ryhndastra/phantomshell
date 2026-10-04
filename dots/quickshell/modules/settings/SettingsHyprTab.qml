import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components

// halaman tab pengaturan layar monitor, mode proyektor, audio, dan hyprland
ColumnLayout {
    id: hyprTab
    Layout.fillWidth: true
    spacing: 10

    property int brightnessPct: 80
    property bool showDisplayModeDropdown: false

    P5SectionHeader { text: "DISPLAYS & INFOCUS PROJECTOR MIRROR" }

    // kartu pratinjau tata letak layar monitor
    P5SkewedCard {
        Layout.fillWidth: true
        Layout.preferredHeight: 168
        fillColor: "#0D0D14"
        borderColor: "#FFFFFF"
        shadowColor: PhantomState.primary
        skewPx: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // deretan kotak pratinjau monitor
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Row {
                    anchors.centerIn: parent
                    spacing: 16

                    Repeater {
                        model: PhantomState.monitorList

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: 220
                            height: 106
                            readonly property bool isSel: PhantomState.selectedMonitorIdx === index

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: parent.isSel ? "#242842" : "#161824"
                                borderColor: parent.isSel ? PhantomState.secondary : "#FFFFFF"
                                shadowColor: parent.isSel ? PhantomState.primary : "#06060A"
                                borderWidth: parent.isSel ? 2.5 : 1.5
                                skewPx: 6
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 3

                                P5Icon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    name: "frame"
                                    size: 18
                                    color: parent.parent.isSel ? PhantomState.secondary : "#FFFFFF"
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.name || "eDP-1"
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 14
                                    font.weight: Font.Black
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: (modelData.width || 1920) + "x" + (modelData.height || 1080) + " @ " + Math.round(modelData.refreshRate || 60) + "Hz"
                                    color: PhantomState.muted
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }

                                Text {
                                    visible: (modelData.mirrorOf && modelData.mirrorOf !== "none") || PhantomState.presentationMode !== "extend"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "★ MIRROR ACTIVE"
                                    color: PhantomState.secondary
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PhantomState.loadMonitorIntoState(index)
                            }
                        }
                    }
                }
            }

            // deskripsi perangkat keras monitor dan tombol pindai ulang
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    Layout.fillWidth: true
                    text: PhantomState.displayName + " • " + PhantomState.displayDesc
                    color: PhantomState.muted
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }

                Rectangle {
                    width: 96
                    height: 22
                    color: PhantomState.primary
                    border.color: "#FFFFFF"
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: "↻ RESCAN"
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 10
                        font.weight: Font.Black
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: PhantomState.refreshMonitors()
                    }
                }
            }
        }
    }

    // pemilih mode proyektor atau perpanjangan layar
    P5ConfigChoiceRow {
        label: "InFocus / Presentation Mirror"
        desc: "Mirror screen to projector/InFocus or extend workspace"
        currentValue: PhantomState.presentationMode
        options: [
            { id: "extend",       label: "EXTEND" },
            { id: "mirror-auto",  label: "MIRROR AUTO" },
            { id: "mirror-1080p", label: "INFOCUS 1080" },
            { id: "mirror-720p",  label: "INFOCUS 720" }
        ]
        onSelected: val => PhantomState.setPresentationMode(val)
    }

    // sakelar aktif atau nonaktif untuk monitor terpilih
    P5ConfigToggleRow {
        label: "Enabled (" + PhantomState.displayName + ")"
        desc: "Enable or disable the selected monitor output"
        valueText: PhantomState.displayEnabled ? "ON" : "OFF"
        active: PhantomState.displayEnabled
        onTriggered: {
            if (PhantomState.monitorList.length > 1 || !PhantomState.displayEnabled) {
                PhantomState.displayEnabled = !PhantomState.displayEnabled
                PhantomState.applyDisplayConfig()
            }
        }
    }

    // tombol pembuka daftar resolusi dan refresh rate
    P5ConfigToggleRow {
        label: "Resolution & Refresh Rate"
        desc: "Click to open framerate & resolution options (" + PhantomState.displayAvailableModes.length + " modes available)"
        valueText: PhantomState.displayMode + (hyprTab.showDisplayModeDropdown ? " ▲" : " ▼")
        active: true
        onTriggered: hyprTab.showDisplayModeDropdown = !hyprTab.showDisplayModeDropdown
    }

    // daftar pilihan resolusi dan refresh rate monitor
    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 18
        Layout.rightMargin: 6
        visible: hyprTab.showDisplayModeDropdown
        spacing: 6

        Repeater {
            model: PhantomState.displayAvailableModes

            delegate: Item {
                required property string modelData
                required property int index
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                readonly property bool isSelected: PhantomState.displayMode === modelData

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: parent.isSelected ? PhantomState.primary : "#171722"
                    borderColor: parent.isSelected ? "#FFFFFF" : "#353548"
                    shadowColor: parent.isSelected ? PhantomState.secondary : "#08080C"
                    borderWidth: parent.isSelected ? 2 : 1
                    skewPx: 8
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 10

                    P5Icon {
                        name: parent.parent.isSelected ? "check" : "sparkles"
                        size: 13
                        color: parent.parent.isSelected ? "#FFFFFF" : PhantomState.secondary
                    }

                    Text {
                        text: modelData
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 13
                        font.weight: Font.Black
                        font.italic: parent.parent.isSelected
                    }

                    Rectangle {
                        visible: index === 0
                        width: 104
                        height: 20
                        color: PhantomState.secondary
                        border.color: "#09090D"
                        border.width: 1.5

                        Text {
                            anchors.centerIn: parent
                            text: "★ BEST (MAX HZ)"
                            color: "#09090D"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Black
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: parent.parent.isSelected ? "ACTIVE" : "SELECT"
                        color: parent.parent.isSelected ? "#FFFFFF" : PhantomState.muted
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 10
                        font.weight: Font.Black
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        PhantomState.setDisplayMode(modelData)
                        hyprTab.showDisplayModeDropdown = false
                    }
                }
            }
        }
    }

    // pemilih orientasi putaran layar
    P5ConfigChoiceRow {
        label: "Orientation"
        desc: "Rotate display output (Normal, 90°, 180°, 270°)"
        currentValue: String(PhantomState.displayTransform)
        options: [
            { id: "0", label: "NORMAL" },
            { id: "1", label: "90°" },
            { id: "2", label: "180°" },
            { id: "3", label: "270°" }
        ]
        onSelected: val => PhantomState.setDisplayTransform(Number(val))
    }

    // pengatur skala tampilan monitor
    P5ConfigSliderRow {
        label: "Scale"
        desc: "Display fractional/integer UI scaling percentage"
        minVal: 75; maxVal: 200
        currentVal: PhantomState.displayScalePct
        unit: "%"
        onValueModified: newValue => {
            PhantomState.displayScalePct = Math.round(newValue)
            PhantomState.applyDisplayConfig()
        }
    }

    // pengatur koordinat posisi horizontal monitor
    P5ConfigSliderRow {
        label: "Position X"
        desc: "Horizontal monitor layout coordinate in pixels"
        minVal: -1920; maxVal: 3840
        currentVal: PhantomState.displayPosX
        unit: "px"
        onValueModified: newValue => {
            PhantomState.displayPosX = Math.round(newValue)
            PhantomState.applyDisplayConfig()
        }
    }

    // pengatur koordinat posisi vertikal monitor
    P5ConfigSliderRow {
        label: "Position Y"
        desc: "Vertical monitor layout coordinate in pixels"
        minVal: -1080; maxVal: 2160
        currentVal: PhantomState.displayPosY
        unit: "px"
        onValueModified: newValue => {
            PhantomState.displayPosY = Math.round(newValue)
            PhantomState.applyDisplayConfig()
        }
    }

    P5SectionHeader { text: "AUDIO & BACKLIGHT SERVICES" }

    P5ConfigSliderRow {
        label: "Master Audio Volume (PipeWire)"
        desc: "Live system audio output volume via wpctl"
        minVal: 0; maxVal: 100
        currentVal: PhantomState.volumePct
        unit: "%"
        onValueModified: newValue => {
            PhantomState.volumePct = newValue
            Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (newValue / 100.0).toFixed(2)])
            PhantomState.triggerOsd("VOLUME", newValue)
        }
    }

    P5ConfigSliderRow {
        label: "Display Backlight Brightness"
        desc: "Live monitor brightness via brightnessctl"
        minVal: 5; maxVal: 100
        currentVal: hyprTab.brightnessPct
        unit: "%"
        onValueModified: newValue => {
            hyprTab.brightnessPct = newValue
            Quickshell.execDetached(["brightnessctl", "set", newValue + "%"])
            PhantomState.triggerOsd("BRIGHTNESS", newValue)
        }
    }

    P5ConfigToggleRow {
        label: "UI Sound Effects (SFX)"
        desc: "Play audio cues when notifications and presets trigger"
        valueText: PhantomState.sfxEnabled ? "ENABLED" : "MUTED"
        active: PhantomState.sfxEnabled
        onTriggered: { PhantomState.sfxEnabled = !PhantomState.sfxEnabled; PhantomState.saveState() }
    }

    P5SectionHeader { text: "HYPRLAND LIVE IPC TUNING" }

    P5ConfigSliderRow {
        label: "Hyprland Inner Gaps (gaps_in)"
        desc: "Live spacing between tiled windows"
        minVal: 0; maxVal: 24
        currentVal: PhantomState.hyprGapsIn
        unit: "px"
        onValueModified: newValue => { PhantomState.hyprGapsIn = newValue; PhantomState.syncHyprland() }
    }

    P5ConfigSliderRow {
        label: "Hyprland Outer Gaps (gaps_out)"
        desc: "Live spacing between windows and monitor edges"
        minVal: 0; maxVal: 40
        currentVal: PhantomState.hyprGapsOut
        unit: "px"
        onValueModified: newValue => { PhantomState.hyprGapsOut = newValue; PhantomState.syncHyprland() }
    }

    P5ConfigSliderRow {
        label: "Window Border Thickness"
        desc: "Active/inactive window border width in pixels"
        minVal: 0; maxVal: 6
        currentVal: PhantomState.hyprBorderSize
        unit: "px"
        onValueModified: newValue => { PhantomState.hyprBorderSize = newValue; PhantomState.syncHyprland() }
    }

    P5ConfigSliderRow {
        label: "Window Corner Rounding"
        desc: "Hyprland decoration:rounding radius in pixels"
        minVal: 0; maxVal: 24
        currentVal: PhantomState.hyprRounding
        unit: "px"
        onValueModified: newValue => { PhantomState.hyprRounding = newValue; PhantomState.syncHyprland() }
    }

    P5ConfigToggleRow {
        label: "Hyprland Frosted Glass Blur"
        desc: "Toggle decoration:blur:enabled in real time"
        valueText: PhantomState.hyprBlurEnabled ? "ON" : "OFF"
        active: PhantomState.hyprBlurEnabled
        onTriggered: { PhantomState.hyprBlurEnabled = !PhantomState.hyprBlurEnabled; PhantomState.syncHyprland() }
    }

    P5ConfigToggleRow {
        label: "Edit hyprland.lua Config File"
        desc: "Open /mnt/data/Projects/rice/phantomshell/dots/hypr/hyprland.lua in Neovim"
        valueText: "OPEN FILE"
        active: true
        onTriggered: {
            Quickshell.execDetached(["sh", "-c", "ghostty -e nvim /mnt/data/Projects/rice/phantomshell/dots/hypr/hyprland.lua || kitty -e nvim /mnt/data/Projects/rice/phantomshell/dots/hypr/hyprland.lua || xdg-open /mnt/data/Projects/rice/phantomshell/dots/hypr/hyprland.lua"])
        }
    }
}
