import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config

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
            const sender = notif.appName || notif.summary || "Notification"
            const summary = notif.summary || "New Message"
            const body = notif.body ? (summary + " — " + notif.body) : summary
            
            // Ekstraksi icon cerdas dari freedesktop hints / appIcon / desktop entry
            const home = Quickshell.env("HOME") || "/home/sho"
            const lowerSender = sender.toLowerCase()
            const lowerBody = body.toLowerCase()
            const rawAppIcon = String(notif.appIcon || "").toLowerCase()

            let icon = ""
            if (lowerBody.indexOf("whatsapp") !== -1 || lowerSender.indexOf("whatsapp") !== -1 || lowerBody.indexOf("wa.me") !== -1 || rawAppIcon.indexOf("whatsapp") !== -1) {
                icon = "file://" + home + "/.config/quickshell/assets/icons/whatsapp.svg"
            } else if (lowerSender.indexOf("zen") !== -1 || lowerBody.indexOf("zen") !== -1 || rawAppIcon.indexOf("zen") !== -1) {
                icon = "file:///etc/profiles/per-user/sho/share/icons/hicolor/128x128/apps/zen-browser.png"
            } else if (notif.image && String(notif.image).trim().length > 0) {
                icon = String(notif.image).trim()
            } else if (notif.appIcon && String(notif.appIcon).trim().length > 0) {
                const ai = String(notif.appIcon).trim()
                if (ai.startsWith("file://") || ai.startsWith("image://") || ai.startsWith("/")) {
                    icon = ai.startsWith("/") ? ("file://" + ai) : ai
                } else {
                    const resolved = Quickshell.iconPath(ai, true)
                    icon = (resolved && String(resolved).length > 0) ? resolved : ai
                }
            }

            if (!icon || icon === "" || (!icon.startsWith("file://") && !icon.startsWith("image://") && !icon.startsWith("/"))) {
                icon = PhantomState.resolveAppIconUrl(sender)
            }

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
