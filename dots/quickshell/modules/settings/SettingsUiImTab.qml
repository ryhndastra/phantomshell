import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// halaman tab pengaturan gaya grafik statistik sistem dan notifikasi pesan
ColumnLayout {
    Layout.fillWidth: true
    spacing: 10

    P5SectionHeader { text: "SYSTEM STATS & SCREEN CORNERS" }

    P5ConfigChoiceRow {
        label: "System Stats Radar Style"
        desc: "Choose 5-Point Persona Star Radar or Horizontal Progress Bars"
        currentValue: PhantomState.statsStyle
        options: [
            { id: "pentagon", label: "★ 5-PT STAR" },
            { id: "bars",     label: "☰ BARS" }
        ]
        onSelected: val => { PhantomState.statsStyle = val; PhantomState.saveState() }
    }

    P5ConfigToggleRow {
        label: "Workspace Perimeter Frame"
        desc: "Optional chamfered border around workspace area (Default OFF for clean apps)"
        valueText: PhantomState.screenFrame ? "ON" : "OFF"
        active: PhantomState.screenFrame
        onTriggered: { PhantomState.screenFrame = !PhantomState.screenFrame; PhantomState.saveState() }
    }

    P5SectionHeader { text: "PERSONA 5 IM CHAT NOTIFICATIONS" }

    P5ConfigToggleRow {
        label: "Do Not Disturb (Mute Popups)"
        desc: "Silence incoming comic bubble popups on top-right"
        valueText: PhantomState.dndEnabled ? "DND ON" : "POPUPS ON"
        active: !PhantomState.dndEnabled
        onTriggered: PhantomState.dndEnabled = !PhantomState.dndEnabled
    }

    P5ConfigToggleRow {
        label: "Unread Notification Count Badge"
        desc: "Show unread message counter inside the IM pill on the bar"
        valueText: PhantomState.showUnreadCount ? "SHOWN" : "HIDDEN"
        active: PhantomState.showUnreadCount
        onTriggered: { PhantomState.showUnreadCount = !PhantomState.showUnreadCount; PhantomState.saveState() }
    }

    P5ConfigToggleRow {
        label: "Dispatch Calling Card Test"
        desc: "Send a test Persona 5 comic notification from Ren"
        valueText: "FIRE TEST"
        active: true
        onTriggered: PhantomState.sendTestNotification()
    }
}
