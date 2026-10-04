import QtQuick
import qs.config

// kontainer bawah untuk visualizer audio cava dan lirik lagu tersinkronisasi
Item {
    id: bottomAudioBar
    z: 10
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.leftMargin: 18
    anchors.rightMargin: 18
    anchors.bottomMargin: PhantomState.barPosition === "bottom" ? 42 : 6
    height: Math.max(128, PhantomState.cavaMaxHeight)
    visible: PhantomState.showDesktopCava || PhantomState.showDesktopLyrics

    property bool musicPlaying: false
    property string past2Lyric: ""
    property string past1Lyric: ""
    property string currentLyric: ""
    property string next1Lyric: ""
    property string next2Lyric: ""

    property bool hasLiveAudio: false
    property var leftBars: []
    property var rightBars: []
    property int cavaTick: 0

    // slot tengah untuk tampilan lirik lima baris
    Item {
        id: centerLyricsSlot
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        width: PhantomState.showDesktopLyrics ? Math.min(640, parent.width * 0.46) : 24
        height: 122
        visible: PhantomState.showDesktopLyrics

        Column {
            anchors.centerIn: parent
            width: parent.width
            spacing: 2
            visible: bottomAudioBar.musicPlaying && bottomAudioBar.currentLyric !== ""

            // baris lirik dua langkah sebelumnya
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: bottomAudioBar.past2Lyric
                visible: text !== ""
                color: "#FFFFFF"
                opacity: 0.24
                font.family: "JetBrainsMono NFM"
                font.pixelSize: 11
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            // baris lirik satu langkah sebelumnya
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: bottomAudioBar.past1Lyric
                visible: text !== ""
                color: "#FFFFFF"
                opacity: 0.48
                font.family: "JetBrainsMono NFM"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                style: Text.Outline
                styleColor: "#66000000"
                elide: Text.ElideRight
            }

            // baris lirik yang sedang dinyanyikan saat ini
            Text {
                id: activeLyricText
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: bottomAudioBar.currentLyric
                color: "#FFFFFF"
                opacity: 1.0
                font.family: "JetBrainsMono NFM"
                font.pixelSize: 20
                font.weight: Font.Black
                style: Text.Outline
                styleColor: "#CC050508"
                elide: Text.ElideRight
            }

            // baris lirik satu langkah berikutnya
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: bottomAudioBar.next1Lyric
                visible: text !== ""
                color: "#FFFFFF"
                opacity: 0.50
                font.family: "JetBrainsMono NFM"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                style: Text.Outline
                styleColor: "#66000000"
                elide: Text.ElideRight
            }

            // baris lirik dua langkah berikutnya
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: bottomAudioBar.next2Lyric
                visible: text !== ""
                color: "#FFFFFF"
                opacity: 0.26
                font.family: "JetBrainsMono NFM"
                font.pixelSize: 11
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
        }
    }

    // kanvas spektrum audio cava sisi kiri
    Canvas {
        id: leftCavaCanvas
        visible: PhantomState.showDesktopCava && bottomAudioBar.hasLiveAudio
        anchors.left: parent.left
        anchors.right: centerLyricsSlot.visible ? centerLyricsSlot.left : parent.horizontalCenter
        anchors.rightMargin: centerLyricsSlot.visible ? 18 : 6
        anchors.bottom: parent.bottom
        height: PhantomState.cavaMaxHeight

        property int tick: bottomAudioBar.cavaTick
        property color cPrimary: PhantomState.primary
        property color cSecondary: PhantomState.secondary
        onTickChanged: requestPaint()
        onCPrimaryChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var bars = bottomAudioBar.leftBars
            var n = bars.length
            if (n === 0 || width <= 0 || !bottomAudioBar.hasLiveAudio) return
            var barW = 4
            var step = width / n
            var maxH = height
            for (var i = 0; i < n; i++) {
                var pct = (bars[i] || 0) / 100.0
                if (pct <= 0.01) continue
                var bh = Math.max(3, maxH * pct)
                var bx = i * step
                var by = maxH - bh
                ctx.fillStyle = pct > 0.65 ? cSecondary : cPrimary
                ctx.globalAlpha = 0.85
                ctx.fillRect(bx, by, barW, bh)
            }
        }
    }

    // kanvas spektrum audio cava sisi kanan
    Canvas {
        id: rightCavaCanvas
        visible: PhantomState.showDesktopCava && bottomAudioBar.hasLiveAudio
        anchors.left: centerLyricsSlot.visible ? centerLyricsSlot.right : parent.horizontalCenter
        anchors.leftMargin: centerLyricsSlot.visible ? 18 : 6
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: PhantomState.cavaMaxHeight

        property int tick: bottomAudioBar.cavaTick
        property color cPrimary: PhantomState.primary
        property color cSecondary: PhantomState.secondary
        onTickChanged: requestPaint()
        onCPrimaryChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var bars = bottomAudioBar.rightBars
            var n = bars.length
            if (n === 0 || width <= 0 || !bottomAudioBar.hasLiveAudio) return
            var barW = 4
            var step = width / n
            var maxH = height
            for (var i = 0; i < n; i++) {
                var pct = (bars[i] || 0) / 100.0
                if (pct <= 0.01) continue
                var bh = Math.max(3, maxH * pct)
                var bx = i * step
                var by = maxH - bh
                ctx.fillStyle = pct > 0.65 ? cSecondary : cPrimary
                ctx.globalAlpha = 0.85
                ctx.fillRect(bx, by, barW, bh)
            }
        }
    }
}
