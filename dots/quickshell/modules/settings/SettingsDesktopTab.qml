import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// halaman tab pengaturan widget jam desktop, cava visualizer, dan lirik lagu
ColumnLayout {
    Layout.fillWidth: true
    spacing: 10

    P5SectionHeader { text: "DESKTOP CLOCK & MOTTO WIDGET" }

    P5ConfigToggleRow {
        label: "Desktop Clock & Date Widget"
        desc: "Render Persona 5 clock widget directly on the desktop wallpaper"
        valueText: PhantomState.showDesktopClock ? "ENABLED" : "OFF"
        active: PhantomState.showDesktopClock
        onTriggered: { PhantomState.showDesktopClock = !PhantomState.showDesktopClock; PhantomState.saveState() }
    }

    P5ConfigChoiceRow {
        label: "Desktop Clock Visual Style"
        desc: "Choose between Slanted Persona 5 Editorial, Minimal Giant, or Cyber HUD"
        currentValue: PhantomState.desktopClockStyle
        options: [
            { id: "p5-editorial", label: "★ P5 SLANT" },
            { id: "minimal",      label: "MINIMAL" },
            { id: "cyber",        label: "CYBER HUD" }
        ]
        onSelected: val => { PhantomState.desktopClockStyle = val; PhantomState.saveState() }
    }

    P5ConfigChoiceRow {
        label: "Desktop Clock Placement"
        desc: "Select screen quadrant for the desktop clock widget"
        currentValue: PhantomState.desktopClockPosition
        options: [
            { id: "top-left",    label: "TOP-L" },
            { id: "center",      label: "CENTER" },
            { id: "top-right",   label: "TOP-R" },
            { id: "bottom-left", label: "BOT-L" }
        ]
        onSelected: val => { PhantomState.desktopClockPosition = val; PhantomState.saveState() }
    }

    P5ConfigSliderRow {
        label: "Desktop Clock Scale (%)"
        desc: "Resize the desktop clock widget from 70% to 150%"
        minVal: 70; maxVal: 150
        currentVal: PhantomState.desktopClockScale
        unit: "%"
        onValueModified: newValue => { PhantomState.desktopClockScale = newValue; PhantomState.saveState() }
    }

    P5ConfigToggleRow {
        label: "Show Phantom Thieves Motto Tag"
        desc: "Display 'TAKE YOUR TIME // STEAL BACK YOUR FUTURE' under clock"
        valueText: PhantomState.desktopClockShowQuote ? "SHOWN" : "HIDDEN"
        active: PhantomState.desktopClockShowQuote
        onTriggered: { PhantomState.desktopClockShowQuote = !PhantomState.desktopClockShowQuote; PhantomState.saveState() }
    }

    P5SectionHeader { text: "SPLIT LEFT/RIGHT CAVA & CENTER LIVE LYRICS" }

    P5ConfigToggleRow {
        label: "Split Left/Right Cava Audio Visualizer"
        desc: "Run live 64-bar Cava spectrum split across bottom-left & bottom-right"
        valueText: PhantomState.showDesktopCava ? "ACTIVE" : "OFF"
        active: PhantomState.showDesktopCava
        onTriggered: { PhantomState.showDesktopCava = !PhantomState.showDesktopCava; PhantomState.saveState() }
    }

    P5ConfigSliderRow {
        label: "Cava Spectrum Max Height"
        desc: "Maximum vertical bar height for the bottom audio visualizer"
        minVal: 40; maxVal: 200
        currentVal: PhantomState.cavaMaxHeight
        unit: "px"
        onValueModified: newValue => { PhantomState.cavaMaxHeight = newValue; PhantomState.saveState() }
    }

    P5ConfigToggleRow {
        label: "Center Slot Live Synced Lyrics"
        desc: "Fetch real-time synced lyrics from Spotify, Apple Music, or Browser"
        valueText: PhantomState.showDesktopLyrics ? "ACTIVE" : "OFF"
        active: PhantomState.showDesktopLyrics
        onTriggered: { PhantomState.showDesktopLyrics = !PhantomState.showDesktopLyrics; PhantomState.saveState() }
    }

    P5ConfigToggleRow {
        label: "Lyrics Slot Skewed Backing Card"
        desc: "Show slanted dark Persona 5 card behind center lyrics for high contrast"
        valueText: PhantomState.lyricsShowCard ? "CARD ON" : "TEXT ONLY"
        active: PhantomState.lyricsShowCard
        onTriggered: { PhantomState.lyricsShowCard = !PhantomState.lyricsShowCard; PhantomState.saveState() }
    }
}
