import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// halaman tab pengaturan posisi bar, gaya bar, dan format nomor workspace
ColumnLayout {
    Layout.fillWidth: true
    spacing: 10

    P5SectionHeader { text: "BAR POSITIONING & STYLE" }

    P5ConfigChoiceRow {
        label: "Bar Edge Position"
        desc: "Anchor Phantom Bar at the top or bottom of your monitor"
        currentValue: PhantomState.barPosition
        options: [
            { id: "top",    label: "↑ TOP" },
            { id: "bottom", label: "↓ BOTTOM" }
        ]
        onSelected: val => { PhantomState.barPosition = val; PhantomState.saveState() }
    }

    P5ConfigChoiceRow {
        label: "Bar Visual Style"
        desc: "Select how bar modules and backing are framed"
        currentValue: PhantomState.barStyle
        options: [
            { id: "p5-skew", label: "★ P5 SKEW" },
            { id: "float",   label: "FLOAT" },
            { id: "hug",     label: "HUG BAR" },
            { id: "islands", label: "ISLANDS" }
        ]
        onSelected: val => {
            PhantomState.barStyle = val
            PhantomState.polygonMode = (val === "p5-skew")
            PhantomState.barShowBackground = (val === "hug")
            PhantomState.saveState()
        }
    }

    P5ConfigToggleRow {
        label: "Solid Bar Backing Strip"
        desc: "Draw dark full-width backing strip with crimson edge under bar pills"
        valueText: PhantomState.barShowBackground ? "ON" : "FLOAT"
        active: PhantomState.barShowBackground
        onTriggered: {
            PhantomState.barShowBackground = !PhantomState.barShowBackground
            PhantomState.saveState()
        }
    }

    P5SectionHeader { text: "WORKSPACES & NUMERAL FORMAT" }

    P5ConfigSliderRow {
        label: "Workspaces Shown on Bar"
        desc: "Number of workspace pills displayed in the bar"
        minVal: 4; maxVal: 12
        currentVal: PhantomState.workspaceCount
        unit: ""
        onValueModified: newValue => {
            PhantomState.workspaceCount = newValue
            PhantomState.saveState()
        }
    }

    P5ConfigChoiceRow {
        label: "Workspace Number Style"
        desc: "Format workspace numbers as Arabic, Roman numerals, or Japanese Kanji"
        currentValue: PhantomState.workspaceNumStyle
        options: [
            { id: "arabic", label: "1, 2, 3" },
            { id: "roman",  label: "I, II, III" },
            { id: "kanji",  label: "一, 二, 三" }
        ]
        onSelected: val => {
            PhantomState.workspaceNumStyle = val
            PhantomState.saveState()
        }
    }

    P5SectionHeader { text: "BAR SECTIONS & QUICK UTILITY BUTTONS" }

    P5ConfigToggleRow {
        label: "Left: Date & Weather HUD Pill"
        desc: "Show Persona 5 date, day of week, and time period badge"
        valueText: PhantomState.showWeatherHud ? "VISIBLE" : "HIDDEN"
        active: PhantomState.showWeatherHud
        onTriggered: { PhantomState.showWeatherHud = !PhantomState.showWeatherHud; PhantomState.saveState() }
    }

    P5ConfigToggleRow {
        label: "Center: Dynamic Island"
        desc: "Show active window title and quick SUPER launcher trigger"
        valueText: PhantomState.showDynamicIsland ? "VISIBLE" : "HIDDEN"
        active: PhantomState.showDynamicIsland
        onTriggered: { PhantomState.showDynamicIsland = !PhantomState.showDynamicIsland; PhantomState.saveState() }
    }

    P5ConfigToggleRow {
        label: "Utility: Screen Snip + Color Picker Strip"
        desc: "Show quick screenshot snip and hyprpicker color buttons on bar"
        valueText: PhantomState.showUtilButtons ? "ENABLED" : "OFF"
        active: PhantomState.showUtilButtons
        onTriggered: { PhantomState.showUtilButtons = !PhantomState.showUtilButtons; PhantomState.saveState() }
    }

    P5ConfigToggleRow {
        label: "Utility: Microphone & Polarity Toggles"
        desc: "Include mic mute and dark/light buttons inside the utility strip"
        valueText: PhantomState.showUtilMic ? "SHOWN" : "HIDDEN"
        active: PhantomState.showUtilMic
        onTriggered: {
            PhantomState.showUtilMic = !PhantomState.showUtilMic
            PhantomState.showUtilDark = PhantomState.showUtilMic
            PhantomState.saveState()
        }
    }
}
