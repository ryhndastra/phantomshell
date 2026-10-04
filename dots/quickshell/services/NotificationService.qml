import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// layanan server notifikasi freedesktop dan antrean balon pesan im
Scope {
    id: root

    signal sfxRequested(string kind)

    property bool dndEnabled: false
    property ListModel imNotifications: ListModel {}
    property ListModel imPopupStack: ListModel {}
    property int _testQuoteIdx: 0

    readonly property var renTestQuotes: [
        "It's showtime. Let's infiltrate the Palace.",
        "I should check today's requests in Mementos...",
        "I'll write this down in my diary before sleeping.",
        "Time to brew some Leblanc curry and coffee.",
        "All systems ready. Steal back your future."
    ]

    NotificationServer {
        id: notifServer
        keepOnReload: false
        actionsSupported: true
        bodyMarkupSupported: true

        onNotification: notif => {
            notif.tracked = true
            const sender = notif.appName || "Ren"
            const summary = notif.summary || "New Message"
            const body = notif.body ? (summary + " — " + notif.body) : summary
            const icon = notif.image || notif.appIcon || ""
            root.pushImNotification(sender, body, "NORMAL", icon)
        }
    }

    function sendTestNotification() {
        const msg = root.renTestQuotes[root._testQuoteIdx % root.renTestQuotes.length]
        root._testQuoteIdx = (root._testQuoteIdx + 1) % root.renTestQuotes.length
        root.pushImNotification("Ren", msg, "CRITICAL", "")
    }

    function pushImNotification(sender, message, urgency, icon) {
        const now = new Date()
        const timeStr = Qt.formatTime(now, "hh:mm")
        const cleanSender = sender || "Ren"
        const cleanMsg = message || "It's showtime. Let's infiltrate the Palace."
        const cleanUrg = urgency || "NORMAL"
        const cleanIcon = icon || ""
        const item = {
            "uid": Date.now() + Math.floor(Math.random() * 1000),
            "sender": cleanSender,
            "senderName": cleanSender,
            "message": cleanMsg,
            "msgBody": cleanMsg,
            "urgency": cleanUrg,
            "msgUrgency": cleanUrg,
            "time": timeStr,
            "msgTime": timeStr,
            "appIcon": cleanIcon,
            "msgIcon": cleanIcon
        }
        imNotifications.insert(0, item)
        if (!root.dndEnabled) {
            imPopupStack.insert(0, item)
            if (imPopupStack.count > 3) {
                imPopupStack.remove(imPopupStack.count - 1)
            }
            popupCleanupTimer.restart()
        }
        root.sfxRequested("notif")
    }

    function dismissPopup(index) {
        if (index >= 0 && index < imPopupStack.count) {
            imPopupStack.remove(index)
        }
    }

    Timer {
        id: popupCleanupTimer
        interval: 6000
        repeat: true
        running: root.imPopupStack.count > 0
        onTriggered: {
            if (root.imPopupStack.count > 0) {
                root.imPopupStack.remove(root.imPopupStack.count - 1)
            }
        }
    }
}
