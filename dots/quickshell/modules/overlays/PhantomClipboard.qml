import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config
import qs.components

// S.E.E.S. clipboard history overlay (Super + V)
Scope {
    id: root

    property string searchQuery: ""
    property string activeCategory: "ALL" // "ALL", "TEXT", "IMAGES"
    property var clipEntries: []
    property int selectedIdx: 0

    readonly property int textCount: {
        let c = 0
        for (let i = 0; i < clipEntries.length; i++) {
            if (!clipEntries[i].isImage) c++
        }
        return c
    }

    readonly property int imageCount: {
        let c = 0
        for (let i = 0; i < clipEntries.length; i++) {
            if (clipEntries[i].isImage) c++
        }
        return c
    }

    readonly property var filteredEntries: {
        const q = root.searchQuery.trim().toLowerCase()
        return root.clipEntries.filter(function(item) {
            if (root.activeCategory === "TEXT" && item.isImage) return false
            if (root.activeCategory === "IMAGES" && !item.isImage) return false
            if (q === "") return true
            const inPreview = item.preview.toLowerCase().indexOf(q) !== -1
            const inInfo = item.imageInfo ? item.imageInfo.toLowerCase().indexOf(q) !== -1 : false
            return inPreview || inInfo
        })
    }

    Process {
        id: clipListProc
        command: ["bash", "-c", "cliphist list 2>/dev/null | head -n 80"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                const lines = String(data).split("\n")
                const arr = []
                for (let i = 0; i < lines.length; i++) {
                    const raw = lines[i]
                    if (!raw || !raw.trim()) continue
                    const tabIdx = raw.indexOf("\t")
                    const idStr = tabIdx !== -1 ? raw.slice(0, tabIdx).trim() : String(i + 1)
                    const content = tabIdx !== -1 ? raw.slice(tabIdx + 1).trim() : raw.trim()

                    let isImg = false
                    let imgInfo = ""
                    if (content.startsWith("[[ binary data")) {
                        isImg = true
                        const match = content.match(/\[\[ binary data\s+(.+?)\s+([a-zA-Z0-9]+)\s+([0-9x]+)\s*\]\]/)
                        if (match) {
                            imgInfo = match[2].toUpperCase() + " • " + match[1] + " (" + match[3] + ")"
                        } else {
                            imgInfo = content.replace("[[ binary data", "").replace("]]", "").trim()
                        }
                    }

                    arr.push({
                        id: idStr,
                        raw: raw,
                        preview: content,
                        isImage: isImg,
                        imageInfo: imgInfo
                    })
                }
                root.clipEntries = arr
                root.selectedIdx = 0
            }
        }
    }

    function refreshClips() {
        clipListProc.running = false
        clipListProc.running = true
    }

    function selectEntry(entry) {
        if (!entry) return
        const safeId = String(entry.id).replace(/[^0-9]/g, "")
        if (safeId) {
            Quickshell.execDetached(["bash", "-c", "cliphist decode " + safeId + " | wl-copy"])
        }
        PhantomState.clipboardOpen = false
        PhantomState.playSfx("select")
        const notifTitle = PhantomState.isP3 ? "S.E.E.S. Clipboard" : "Thief Compendium"
        const notifDesc = entry.isImage ? ("Image " + entry.imageInfo + " copied!") : "Item copied to clipboard!"
        PhantomState.pushImNotification(notifTitle, notifDesc, "NORMAL", "")
    }

    function deleteEntry(entry) {
        if (!entry) return
        Quickshell.execDetached(["bash", "-c", "printf '%s\\n' " + JSON.stringify(entry.raw) + " | cliphist delete 2>/dev/null || true"])
        root.clipEntries = root.clipEntries.filter(e => e.id !== entry.id)
        if (root.selectedIdx >= root.filteredEntries.length) {
            root.selectedIdx = Math.max(0, root.filteredEntries.length - 1)
        }
        PhantomState.playSfx("select")
    }

    function wipeHistory() {
        Quickshell.execDetached(["bash", "-c", "cliphist wipe 2>/dev/null || true"])
        root.clipEntries = []
        PhantomState.playSfx("select")
        const notifTitle = PhantomState.isP3 ? "S.E.E.S. Clipboard" : "Thief Compendium"
        PhantomState.pushImNotification(notifTitle, "Clipboard history cleared.", "NORMAL", "")
    }

    PanelWindow {
        id: clipWin
        visible: PhantomState.clipboardOpen

        WlrLayershell.namespace: "phantomshell-clipboard"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: PhantomState.clipboardOpen
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
                root.searchQuery = ""
                root.activeCategory = "ALL"
                clipSearchInput.text = ""
                root.refreshClips()
                clipAnim.restart()
                clipSearchInput.forceActiveFocus()
                PhantomState.playSfx("open")
            } else {
                PhantomState.playSfx("close")
            }
        }

        Rectangle {
            anchors.fill: parent
            color: PhantomState.isP3 ? "#D0020716" : "#AA050508"
            MouseArea {
                anchors.fill: parent
                onClicked: PhantomState.clipboardOpen = false
            }
        }

        Item {
            id: clipCard
            width: Math.min(parent.width - 64, 760)
            height: Math.min(parent.height - 80, 580)
            anchors.centerIn: parent

            ParallelAnimation {
                id: clipAnim
                NumberAnimation { target: clipCard; property: "scale"; from: 0.90; to: 1.0; duration: 220; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
                NumberAnimation { target: clipCard; property: "opacity"; from: 0.0; to: 1.0; duration: 160; easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.fill: parent
                visible: PhantomState.isP3
                color: "#F203091C"
                border.color: "#8000DBFF"
                border.width: 1.8
                radius: 8

                Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 34; height: 3; color: "#00f0ff" }
                Rectangle { anchors.top: parent.top; anchors.left: parent.left; width: 3; height: 34; color: "#00f0ff" }
                Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 34; height: 3; color: "#00f0ff" }
                Rectangle { anchors.bottom: parent.bottom; anchors.right: parent.right; width: 3; height: 34; color: "#00f0ff" }
            }

            P5SkewedCard {
                anchors.fill: parent
                visible: !PhantomState.isP3
                fillColor: "#0B0B10"
                borderColor: "#FFFFFF"
                shadowColor: PhantomState.primary
                borderWidth: 3
                skewPx: 12
                shadowOffsetX: 7
                shadowOffsetY: 7
            }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        visible: PhantomState.isP3
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        radius: 4
                        color: "#0028e0"
                        border.color: "#00f0ff"
                        border.width: 1.4

                        Canvas {
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                var cx = width / 2
                                var cy = height / 2

                                ctx.strokeStyle = "#00f0ff"
                                ctx.lineWidth = 1.4

                                ctx.beginPath()
                                ctx.arc(cx, cy, 8, 0, Math.PI * 2)
                                ctx.stroke()

                                ctx.beginPath()
                                ctx.arc(cx, cy, 3, 0, Math.PI * 2)
                                ctx.fillStyle = "#ffffff"
                                ctx.fill()

                                ctx.beginPath(); ctx.moveTo(cx - 12, cy); ctx.lineTo(cx - 8, cy); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx + 8, cy); ctx.lineTo(cx + 12, cy); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx, cy - 12); ctx.lineTo(cx, cy - 8); ctx.stroke()
                                ctx.beginPath(); ctx.moveTo(cx, cy + 8); ctx.lineTo(cx, cy + 12); ctx.stroke()
                            }
                        }
                    }

                    P5Star {
                        visible: !PhantomState.isP3
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        spinning: true
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: PhantomState.isP3 ? "S.E.E.S. ARCHIVE // CLIPBOARD HISTORY" : "THIEF COMPENDIUM // CLIPBOARD HISTORY"
                            color: "#FFFFFF"
                            font.family: PhantomState.isP3 ? "Rubik" : "JetBrainsMono NFM"
                            font.pixelSize: 13
                            font.weight: Font.Black
                            font.italic: !PhantomState.isP3
                            font.letterSpacing: PhantomState.isP3 ? 0.8 : 0
                        }
                        Text {
                            text: root.filteredEntries.length + " ITEMS • [ENTER] COPY • [ESC] CLOSE"
                            color: PhantomState.isP3 ? "#00dbff" : PhantomState.secondary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: wipeTxt.implicitWidth + 20
                        Layout.preferredHeight: 30
                        radius: 4
                        color: wipeMouse.containsMouse ? "#d60032" : (PhantomState.isP3 ? "#08183C" : "#1A1A26")
                        border.color: wipeMouse.containsMouse ? "#ffffff" : (PhantomState.isP3 ? "#6000DBFF" : "#ffffff")
                        border.width: 1.4

                        Text {
                            id: wipeTxt
                            anchors.centerIn: parent
                            text: "WIPE ALL"
                            color: "#FFFFFF"
                            font.family: PhantomState.isP3 ? "Rubik" : "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                        MouseArea {
                            id: wipeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.wipeHistory()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 4
                        color: closeClipMouse.containsMouse ? "#d60032" : (PhantomState.isP3 ? "#0A183C" : "#1A1A26")
                        border.color: closeClipMouse.containsMouse ? "#ffffff" : (PhantomState.isP3 ? "#6000DBFF" : "#ffffff")
                        border.width: 1.4

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: "#ffffff"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            id: closeClipMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: PhantomState.clipboardOpen = false
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: PhantomState.isP3

                    Repeater {
                        model: [
                            { id: "ALL", label: "ALL", count: root.clipEntries.length },
                            { id: "TEXT", label: "TEXT", count: root.textCount },
                            { id: "IMAGES", label: "IMAGES", count: root.imageCount }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool isSel: root.activeCategory === modelData.id
                            height: 24
                            width: catTxt.implicitWidth + 20
                            radius: 3
                            color: isSel ? "#0028e0" : (catMouse.containsMouse ? "#0C1F48" : "#06122E")
                            border.color: isSel ? "#00f0ff" : (catMouse.containsMouse ? "#6000DBFF" : "#2000DBFF")
                            border.width: isSel ? 1.4 : 1.0

                            Row {
                                id: catTxt
                                anchors.centerIn: parent
                                spacing: 5
                                Text {
                                    text: modelData.label
                                    color: isSel ? "#ffffff" : (catMouse.containsMouse ? "#00f0ff" : "#8AA6CE")
                                    font.family: "Rubik"
                                    font.pixelSize: 10
                                    font.weight: isSel ? Font.Black : Font.Bold
                                }
                                Text {
                                    text: modelData.count
                                    color: isSel ? "#00f0ff" : "#4A6894"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                }
                            }

                            MouseArea {
                                id: catMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeCategory = parent.modelData.id
                                    root.selectedIdx = 0
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 4
                    color: "#07122C"
                    border.color: clipSearchInput.activeFocus ? "#00f0ff" : "#4000DBFF"
                    border.width: 1.4

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Canvas {
                            Layout.preferredWidth: 14
                            Layout.preferredHeight: 14
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.strokeStyle = "#00f0ff"
                                ctx.lineWidth = 1.6
                                ctx.beginPath()
                                ctx.arc(5.5, 5.5, 3.8, 0, Math.PI * 2)
                                ctx.stroke()
                                ctx.beginPath()
                                ctx.moveTo(8.5, 8.5)
                                ctx.lineTo(12.5, 12.5)
                                ctx.stroke()
                            }
                        }

                        TextInput {
                            id: clipSearchInput
                            Layout.fillWidth: true
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 11
                            font.bold: true
                            clip: true
                            selectByMouse: true
                            onTextChanged: {
                                root.searchQuery = text
                                root.selectedIdx = 0
                            }
                            Keys.onEscapePressed: PhantomState.clipboardOpen = false
                            Keys.onDownPressed: {
                                if (root.filteredEntries.length > 0) {
                                    root.selectedIdx = (root.selectedIdx + 1) % root.filteredEntries.length
                                    clipListView.positionViewAtIndex(root.selectedIdx, ListView.Contain)
                                }
                            }
                            Keys.onUpPressed: {
                                if (root.filteredEntries.length > 0) {
                                    root.selectedIdx = (root.selectedIdx - 1 + root.filteredEntries.length) % root.filteredEntries.length
                                    clipListView.positionViewAtIndex(root.selectedIdx, ListView.Contain)
                                }
                            }
                            Keys.onReturnPressed: {
                                if (root.filteredEntries.length > 0 && root.selectedIdx < root.filteredEntries.length) {
                                    root.selectEntry(root.filteredEntries[root.selectedIdx])
                                }
                            }
                            Keys.onTabPressed: {
                                if (root.activeCategory === "ALL") root.activeCategory = "TEXT"
                                else if (root.activeCategory === "TEXT") root.activeCategory = "IMAGES"
                                else root.activeCategory = "ALL"
                                root.selectedIdx = 0
                            }

                            Text {
                                anchors.fill: parent
                                text: "Filter clipboard entries... ([Tab] to switch category)"
                                color: "#4A6894"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 11
                                visible: !clipSearchInput.text && !clipSearchInput.activeFocus
                            }
                        }

                        Text {
                            visible: clipSearchInput.text.length > 0
                            text: "✕"
                            color: "#00f0ff"
                            font.pixelSize: 11
                            font.bold: true
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    clipSearchInput.text = ""
                                    root.searchQuery = ""
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item {
                        anchors.centerIn: parent
                        visible: root.filteredEntries.length === 0
                        width: 300
                        height: 90

                        Column {
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "NO CLIPBOARD ENTRIES"
                                font.family: "Rubik"
                                font.pixelSize: 13
                                font.weight: Font.Black
                                color: "#8AA6CE"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Copy items with Ctrl+C to store them in S.E.E.S. Archive"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                color: "#4A6894"
                            }
                        }
                    }

                    ListView {
                        id: clipListView
                        anchors.fill: parent
                        spacing: 6
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: root.filteredEntries
                        currentIndex: root.selectedIdx

                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: clipListView.width
                            height: 42
                            radius: 4

                            readonly property bool isSel: index === root.selectedIdx

                            color: isSel ? "#0028e0" : (itemMouse.containsMouse ? "#0E2456" : "#071638")
                            border.color: isSel ? "#00f0ff" : (itemMouse.containsMouse ? "#00f0ff" : "#2800DBFF")
                            border.width: isSel || itemMouse.containsMouse ? 1.4 : 1.0

                            Rectangle {
                                visible: parent.isSel
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 4
                                radius: 2
                                color: "#00f0ff"
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: parent.isSel ? 14 : 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Rectangle {
                                    Layout.preferredWidth: idTxt.implicitWidth + 14
                                    Layout.preferredHeight: 22
                                    radius: 3
                                    color: parent.parent.isSel ? "#020B1C" : (itemMouse.containsMouse ? "#0028e0" : "#020B1C")
                                    border.color: parent.parent.isSel ? "#00f0ff" : "#00dbff"
                                    border.width: 1

                                    Text {
                                        id: idTxt
                                        anchors.centerIn: parent
                                        text: "#" + modelData.id
                                        color: "#ffffff"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }
                                }

                                Rectangle {
                                    visible: modelData.isImage
                                    Layout.preferredWidth: imgBadgeTxt.implicitWidth + 10
                                    Layout.preferredHeight: 20
                                    radius: 3
                                    color: parent.parent.isSel ? "#041842" : "#091c44"
                                    border.color: "#00f0ff"
                                    border.width: 1

                                    Text {
                                        id: imgBadgeTxt
                                        anchors.centerIn: parent
                                        text: "IMG"
                                        color: "#00f0ff"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.isImage ? modelData.imageInfo : modelData.preview
                                    color: modelData.isImage
                                        ? (parent.parent.isSel ? "#ffffff" : "#8df6ff")
                                        : (parent.parent.isSel ? "#ffffff" : "#d8e6f8")
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: parent.parent.isSel ? Font.Black : Font.Bold
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    visible: parent.parent.isSel
                                    Layout.preferredWidth: copyHintTxt.implicitWidth + 10
                                    Layout.preferredHeight: 20
                                    radius: 3
                                    color: "#00f0ff"

                                    Text {
                                        id: copyHintTxt
                                        anchors.centerIn: parent
                                        text: "↵ COPY"
                                        color: "#020818"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }
                                }

                                Rectangle {
                                    visible: itemMouse.containsMouse || parent.parent.isSel
                                    Layout.preferredWidth: 22
                                    Layout.preferredHeight: 22
                                    radius: 3
                                    color: delMouse.containsMouse ? "#d60032" : "#0A183C"
                                    border.color: delMouse.containsMouse ? "#ffffff" : "#4000DBFF"
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: "✕"
                                        color: "#ffffff"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: delMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.deleteEntry(modelData)
                                    }
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                z: -1
                                onEntered: root.selectedIdx = index
                                onClicked: root.selectEntry(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
