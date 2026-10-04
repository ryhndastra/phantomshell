import QtQuick
import Quickshell
import qs.config

Item {
    id: root
    width: 430
    height: Math.max(106, msgText.implicitHeight + 62)

    property string sender: "Ren"
    property string message: "It's showtime. Let's infiltrate the Palace."
    property string timeText: "20:30"
    property string urgency: "NORMAL"
    property string appIcon: ""
    signal dismissed()

    // resolusi path ikon aplikasi notifikasi, fallback ke avatar default ren.png
    readonly property string resolvedIconUrl: {
        if (appIcon && appIcon.trim() !== "") {
            var raw = appIcon.trim()
            if (raw.startsWith("file://") || raw.startsWith("image://") || raw.startsWith("qrc:")) {
                return raw
            }
            if (raw.startsWith("/")) {
                return "file://" + raw
            }
            var lookup = Quickshell.iconPath(raw, true)
            if (lookup && lookup !== "") {
                return lookup
            }
        }
        return Qt.resolvedUrl("../assets/ren.png")
    }

    // pecah nama pengirim jadi array per karakter buat efek huruf kotak selang-seling
    readonly property var ransomChars: {
        var clean = (sender || "Joker").split("(")[0].trim()
        if (clean.length === 0) clean = "Joker"
        var arr = []
        for (var i = 0; i < clean.length; i++) {
            var ch = clean[i]
            var boxed = (i === 2 || (clean.length > 5 && i === 5) || (clean.length <= 2 && i === 1))
            arr.push({ charStr: ch, boxed: boxed })
        }
        return arr
    }

    // animasi masuk balon notifikasi
    transformOrigin: Item.BottomLeft
    scale: 0.78
    opacity: 0.0
    x: 24

    Component.onCompleted: {
        entryAnim.start()
    }

    ParallelAnimation {
        id: entryAnim
        NumberAnimation {
            target: root
            property: "scale"
            from: 0.78
            to: 1.0
            duration: 240
            easing.type: Easing.OutBack
            easing.overshoot: 1.45
        }
        NumberAnimation {
            target: root
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 160
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root
            property: "x"
            from: 24
            to: 0
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    onWidthChanged: bubbleCanvas.requestPaint()
    onHeightChanged: bubbleCanvas.requestPaint()

    Connections {
        target: PhantomState
        function onPrimaryChanged() { bubbleCanvas.requestPaint() }
        function onBorderLightChanged() { bubbleCanvas.requestPaint() }
        function onBackgroundChanged() { bubbleCanvas.requestPaint() }
    }

    // kotak avatar pengirim di sebelah kiri
    Item {
        id: portraitBox
        x: 12
        y: root.height - 76
        width: 62
        height: 62
        rotation: -7
        z: 1

        // bayangan kotak avatar
        Rectangle {
            x: 4
            y: 5
            width: parent.width
            height: parent.height
            color: PhantomState.primary
        }

        // bingkai luar putih
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            color: "#FFFFFF"
            border.color: "#080A0F"
            border.width: 2
        }

        // kontainer gambar avatar / ikon aplikasi
        Rectangle {
            anchors.fill: parent
            color: "#080A0F"
            clip: true

            Image {
                id: fallbackRenImg
                anchors.fill: parent
                source: Qt.resolvedUrl("../assets/ren.png")
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
                visible: customAppIconImg.status !== Image.Ready || root.appIcon === ""
            }

            Image {
                id: customAppIconImg
                anchors.fill: parent
                anchors.margins: 4
                source: root.appIcon !== "" ? root.resolvedIconUrl : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                visible: root.appIcon !== "" && status === Image.Ready
            }
        }
    }

    // balon chat komik hitam + ekor zig-zag ke kotak avatar
    Canvas {
        id: bubbleCanvas
        anchors.fill: parent
        antialiasing: true
        z: 2

        function traceUnifiedBubblePath(ctx, ox, oy, w, h) {
            var bx = 100 + ox
            var by = 22 + oy
            var bw = w - 122
            var bh = h - 30

            ctx.beginPath()
            ctx.moveTo(bx + 10, by + 4)
            ctx.lineTo(bx + bw - 8, by)
            ctx.lineTo(bx + bw + 6, by + bh - 4)
            ctx.lineTo(bx + 16, by + bh)

            // segmen ekor zig-zag kiri bawah
            ctx.lineTo(bx + 8, by + bh - 15)
            ctx.lineTo(bx - 10, by + bh - 4)
            ctx.lineTo(bx - 15, by + bh - 17)
            ctx.lineTo(62 + ox, h - 8 + oy)
            ctx.lineTo(bx - 18, by + bh - 33)
            ctx.lineTo(bx - 5, by + bh - 25)
            ctx.lineTo(bx - 2, by + bh - 40)

            ctx.closePath()
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var w = width
            var h = height

            // bayangan balon
            traceUnifiedBubblePath(ctx, 5, 7, w, h)
            ctx.fillStyle = "rgba(0, 0, 0, 0.45)"
            ctx.fill()

            // bidang utama balon + garis tepi
            traceUnifiedBubblePath(ctx, 0, 0, w, h)
            ctx.fillStyle = "#080A0F"
            ctx.fill()
            ctx.lineWidth = 2.2
            ctx.strokeStyle = root.urgency === "CRITICAL" ? PhantomState.primary : "#FFFFFF"
            ctx.stroke()

            // aksen segitiga putih di sisi kanan balon
            var wx = w - 44
            var wy = h * 0.68
            ctx.beginPath()
            ctx.moveTo(wx + 3, wy + 5)
            ctx.lineTo(w - 12 + 3, 22 + 5)
            ctx.lineTo(w - 2 + 3, 44 + 5)
            ctx.closePath()
            ctx.fillStyle = "rgba(0, 0, 0, 0.35)"
            ctx.fill()

            ctx.beginPath()
            ctx.moveTo(wx, wy)
            ctx.lineTo(w - 12, 22)
            ctx.lineTo(w - 2, 44)
            ctx.closePath()
            ctx.fillStyle = "#FFFFFF"
            ctx.fill()
            ctx.lineWidth = 2.4
            ctx.strokeStyle = "#080A0F"
            ctx.stroke()
        }
    }

    // pita nama pengirim di kiri atas balon
    Item {
        id: nameTagContainer
        x: 58
        y: 3
        width: Math.max(112, ransomRow.implicitWidth + 46)
        height: 44
        rotation: -14
        z: 4

        Canvas {
            id: nameTagCanvas
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var w = width
                var h = height

                ctx.beginPath()
                ctx.moveTo(22, 6)
                ctx.lineTo(w - 10, 2)
                ctx.lineTo(w - 2, h - 10)
                ctx.lineTo(28, h - 8)
                // lekukan lancip di ujung kiri pita nama
                ctx.lineTo(22, h - 2)
                ctx.lineTo(14, h - 10)
                ctx.lineTo(2, h + 2)
                ctx.lineTo(10, h - 18)
                ctx.lineTo(18, h - 14)
                ctx.lineTo(16, 16)
                ctx.closePath()

                ctx.fillStyle = "#FFFFFF"
                ctx.fill()
                ctx.lineWidth = 2.4
                ctx.strokeStyle = "#080A0F"
                ctx.stroke()
            }
        }

        Row {
            id: ransomRow
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 6
            anchors.verticalCenterOffset: -2
            spacing: 1

            Repeater {
                model: root.ransomChars
                delegate: Item {
                    required property var modelData
                    required property int index

                    width: charText.implicitWidth + (modelData.boxed ? 6 : 1)
                    height: 20

                    Rectangle {
                        anchors.fill: parent
                        visible: modelData.boxed
                        color: index % 2 === 0 ? "#080A0F" : PhantomState.primary
                        rotation: (index % 2 === 0) ? 6 : -5
                    }

                    Text {
                        id: charText
                        anchors.centerIn: parent
                        text: modelData.charStr
                        color: modelData.boxed ? "#FFFFFF" : "#080A0F"
                        font.pixelSize: 14
                        font.weight: Font.Black
                    }
                }
            }
        }
    }

    // isi teks pesan & tombol close di dalam balon hitam
    Text {
        id: msgText
        x: 120
        y: 38
        width: root.width - 170
        text: root.message
        color: "#FFFFFF"
        font.pixelSize: 13
        font.weight: Font.Black
        rotation: -2
        wrapMode: Text.WordWrap
        lineHeight: 1.12
        z: 5
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 44
        anchors.top: parent.top
        anchors.topMargin: 24
        spacing: 6
        z: 6

        Text {
            text: root.timeText
            color: PhantomState.muted
            font.pixelSize: 9
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 18
            height: 18
            color: closeMouse.containsMouse ? PhantomState.primary : "transparent"
            radius: 3

            P5Icon {
                anchors.centerIn: parent
                name: "close"
                size: 10
                color: closeMouse.containsMouse ? "#FFFFFF" : PhantomState.muted
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dismissed()
            }
        }
    }
}
