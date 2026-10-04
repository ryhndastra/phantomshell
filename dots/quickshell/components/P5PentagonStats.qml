import QtQuick
import QtQuick.Layouts
import qs.config

Item {
    id: root
    implicitWidth: 360
    implicitHeight: 175

    property real animCpu: PhantomState.cpuPct
    property real animRam: PhantomState.ramPct
    property real animGpu: PhantomState.gpuPct
    property real animDisk: PhantomState.diskPct
    property real animTemp: PhantomState.tempPct

    Behavior on animCpu  { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
    Behavior on animRam  { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
    Behavior on animGpu  { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
    Behavior on animDisk { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
    Behavior on animTemp { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

    onAnimCpuChanged:  radarCanvas.requestPaint()
    onAnimRamChanged:  radarCanvas.requestPaint()
    onAnimGpuChanged:  radarCanvas.requestPaint()
    onAnimDiskChanged: radarCanvas.requestPaint()
    onAnimTempChanged: radarCanvas.requestPaint()

    readonly property var statsModel: [
        { label: "KNOWLEDGE", sys: "CPU",  pct: PhantomState.cpuPct },
        { label: "GUTS",      sys: "RAM",  pct: PhantomState.ramPct },
        { label: "PROFIC.",   sys: "GPU",  pct: PhantomState.gpuPct },
        { label: "KINDNESS",  sys: "DISK", pct: PhantomState.diskPct },
        { label: "CHARM",     sys: "TEMP", pct: PhantomState.tempPct }
    ]

    Connections {
        target: PhantomState
        function onPrimaryChanged() { radarCanvas.requestPaint() }
        function onSecondaryChanged() { radarCanvas.requestPaint() }
    }

    // tampilan grafik radar bintang 5 sudut (social stats)
    Item {
        anchors.fill: parent
        visible: PhantomState.statsStyle === "pentagon"
        clip: true

        Canvas {
            id: radarCanvas
            anchors.fill: parent
            antialiasing: true

            function traceStar(ctx, cx, cy, outerRadius, innerRatio, angleOffset) {
                ctx.beginPath()
                for (var i = 0; i < 10; i++) {
                    var a = -Math.PI / 2 + angleOffset + (i * Math.PI / 5)
                    var r = (i % 2 === 0) ? outerRadius : (outerRadius * innerRatio)
                    var px = cx + Math.cos(a) * r
                    var py = cy + Math.sin(a) * r
                    if (i === 0) ctx.moveTo(px, py)
                    else ctx.lineTo(px, py)
                }
                ctx.closePath()
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var cx = width / 2
                var cy = height / 2 + 6
                var maxR = Math.min(width, height) * 0.44
                var vals = [
                    Math.max(0.32, Math.min(1.0, root.animCpu / 100.0)),
                    Math.max(0.32, Math.min(1.0, root.animRam / 100.0)),
                    Math.max(0.32, Math.min(1.0, root.animGpu / 100.0)),
                    Math.max(0.32, Math.min(1.0, root.animDisk / 100.0)),
                    Math.max(0.32, Math.min(1.0, root.animTemp / 100.0))
                ]

                // bayangan bintang aksen di belakang
                traceStar(ctx, cx + 4, cy + 4, maxR * 1.04, 0.44, -0.04)
                ctx.fillStyle = PhantomState.primary
                ctx.fill()

                // bidang dasar bintang gelap dengan garis tepi terang
                traceStar(ctx, cx, cy, maxR, 0.44, 0)
                ctx.fillStyle = "#08090D"
                ctx.fill()
                ctx.strokeStyle = PhantomState.borderLight
                ctx.lineWidth = 2.6
                ctx.stroke()

                // garis bantu skala bintang bagian dalam
                var starRings = [0.72, 0.44]
                for (var rIdx = 0; rIdx < starRings.length; rIdx++) {
                    traceStar(ctx, cx, cy, maxR * starRings[rIdx], 0.44, 0)
                    ctx.strokeStyle = (rIdx === 0) ? "rgba(255, 255, 255, 0.35)" : "rgba(255, 255, 255, 0.22)"
                    ctx.lineWidth = 1.4
                    ctx.stroke()
                }

                // garis sumbu radial dari titik pusat ke tiap sudut bintang
                ctx.strokeStyle = "rgba(255, 255, 255, 0.25)"
                ctx.lineWidth = 1.1
                for (var j = 0; j < 10; j++) {
                    var a = -Math.PI / 2 + (j * Math.PI / 5)
                    var len = (j % 2 === 0) ? maxR : (maxR * 0.44)
                    ctx.beginPath()
                    ctx.moveTo(cx, cy)
                    ctx.lineTo(cx + Math.cos(a) * len, cy + Math.sin(a) * len)
                    ctx.stroke()
                }

                // poligon nilai statistik aktif
                ctx.beginPath()
                for (var k = 0; k < 10; k++) {
                    var sa = -Math.PI / 2 + (k * Math.PI / 5)
                    var sr = 0
                    if (k % 2 === 0) {
                        var statIdx = Math.floor(k / 2)
                        sr = maxR * vals[statIdx]
                    } else {
                        var prevIdx = Math.floor((k - 1) / 2)
                        var nextIdx = (prevIdx + 1) % 5
                        var avgTip = (vals[prevIdx] + vals[nextIdx]) * 0.5
                        sr = maxR * Math.max(0.20, avgTip * 0.38)
                    }
                    var sx = cx + Math.cos(sa) * sr
                    var sy = cy + Math.sin(sa) * sr
                    if (k === 0) ctx.moveTo(sx, sy)
                    else ctx.lineTo(sx, sy)
                }
                ctx.closePath()
                ctx.fillStyle = PhantomState.secondary
                ctx.globalAlpha = 0.85
                ctx.fill()
                ctx.globalAlpha = 1.0
                ctx.strokeStyle = "#FFFFFF"
                ctx.lineWidth = 2.4
                ctx.stroke()

                // bintang inti di titik pusat
                traceStar(ctx, cx, cy, maxR * 0.18, 0.44, 0)
                ctx.fillStyle = PhantomState.primary
                ctx.fill()
                ctx.strokeStyle = "#FFFFFF"
                ctx.lineWidth = 1.4
                ctx.stroke()

                // titik indikator di ujung tiap nilai statistik
                for (var n = 0; n < 5; n++) {
                    var na = -Math.PI / 2 + (n * 2 * Math.PI / 5)
                    var nx = cx + Math.cos(na) * (maxR * vals[n])
                    var ny = cy + Math.sin(na) * (maxR * vals[n])
                    ctx.beginPath()
                    ctx.arc(nx, ny, 4.2, 0, Math.PI * 2)
                    ctx.fillStyle = PhantomState.primary
                    ctx.fill()
                    ctx.strokeStyle = "#FFFFFF"
                    ctx.lineWidth = 1.6
                    ctx.stroke()
                }
            }
        }

        // label persentase & nama metrik di keliling sudut bintang
        Repeater {
            model: root.statsModel
            delegate: Item {
                id: badgeItem
                required property var modelData
                required property int index

                readonly property real angle: -Math.PI / 2 + (index * 2 * Math.PI / 5)
                readonly property real labelR: Math.min(root.width, root.height) * 0.46
                readonly property real rawX: (root.width / 2) + Math.cos(angle) * labelR - width / 2
                readonly property real rawY: (root.height / 2 + 6) + Math.sin(angle) * labelR - height / 2

                width: Math.max(76, statBadgeText.implicitWidth + 16)
                height: 30
                x: Math.max(4, Math.min(root.width - width - 4, rawX))
                y: Math.max(2, Math.min(root.height - height - 2, rawY))

                Column {
                    anchors.centerIn: parent
                    spacing: 1

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: statBadgeText.implicitWidth + 12
                        height: 16
                        color: PhantomState.primary
                        border.color: "#FFFFFF"
                        border.width: 1.5
                        rotation: -4

                        Text {
                            id: statBadgeText
                            anchors.centerIn: parent
                            text: modelData.sys + " " + Math.round(modelData.pct) + "%"
                            color: PhantomState.foreground
                            font.pixelSize: 10
                            font.weight: Font.Black
                        }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: subLabel.implicitWidth + 8
                        height: 13
                        color: "#08090D"
                        border.color: PhantomState.secondary
                        border.width: 1
                        rotation: 2

                        Text {
                            id: subLabel
                            anchors.centerIn: parent
                            text: modelData.label
                            color: PhantomState.secondary
                            font.pixelSize: 8
                            font.weight: Font.Black
                        }
                    }
                }
            }
        }
    }

    // tampilan bar indikator horizontal miring
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        visible: PhantomState.statsStyle !== "pentagon"
        spacing: 6

        Repeater {
            model: root.statsModel
            delegate: Item {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 32

                RowLayout {
                    anchors.fill: parent
                    spacing: 8

                    Item {
                        Layout.preferredWidth: 108
                        Layout.fillHeight: true

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: PhantomState.primary
                            borderColor: PhantomState.borderLight
                            shadowColor: PhantomState.borderDark
                            borderWidth: 1
                            skewPx: 4
                            shadowOffsetX: 2
                            shadowOffsetY: 2
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.sys + " // " + modelData.label.slice(0, 5)
                            color: PhantomState.foreground
                            font.pixelSize: 10
                            font.weight: Font.Black
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16

                        P5SkewedCard {
                            anchors.fill: parent
                            fillColor: PhantomState.surfaceAlt
                            borderColor: PhantomState.borderLight
                            showShadowOffset: false
                            borderWidth: 1
                            skewPx: 4
                        }

                        P5SkewedCard {
                            width: Math.max(14, parent.width * (modelData.pct / 100.0))
                            height: parent.height
                            fillColor: PhantomState.secondary
                            borderColor: "transparent"
                            showShadowOffset: false
                            borderWidth: 0
                            skewPx: 4

                            Behavior on width {
                                NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    Text {
                        Layout.preferredWidth: 42
                        text: Math.round(modelData.pct) + "%"
                        color: PhantomState.foreground
                        font.pixelSize: 12
                        font.weight: Font.Black
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
