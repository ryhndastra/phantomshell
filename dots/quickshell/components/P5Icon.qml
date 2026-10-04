import QtQuick
import qs.config

// komponen ikon vektor berbasis canvas
Item {
    id: root
    property string name: "star"
    property string icon: ""
    property int size: 14
    property color color: PhantomState.foreground

    readonly property string resolvedName: icon !== "" ? icon : name

    implicitWidth: size + 2
    implicitHeight: size + 2
    width: size + 2
    height: size + 2

    onResolvedNameChanged: iconCanvas.requestPaint()
    onColorChanged: iconCanvas.requestPaint()
    onSizeChanged: iconCanvas.requestPaint()

    Canvas {
        id: iconCanvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var w = width
            var h = height
            var cx = w / 2
            var cy = h / 2
            var r = Math.min(w, h) * 0.44
            var lw = Math.max(1.6, Math.min(w, h) * 0.13)

            ctx.fillStyle = root.color
            ctx.strokeStyle = root.color
            ctx.lineWidth = lw
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            var n = root.resolvedName

            if (n === "wifi" || n === "wifi-off") {
                // titik bawah wifi
                ctx.beginPath()
                ctx.arc(cx, cy + r * 0.62, lw * 0.75, 0, Math.PI * 2)
                ctx.fill()

                // 3 lengkungan sinyal wifi
                var radii = [r * 0.45, r * 0.82, r * 1.18]
                for (var wi = 0; wi < radii.length; wi++) {
                    ctx.beginPath()
                    ctx.arc(cx, cy + r * 0.62, radii[wi], Math.PI * 1.22, Math.PI * 1.78)
                    ctx.stroke()
                }
                if (n === "wifi-off") {
                    ctx.beginPath()
                    ctx.moveTo(cx - r * 0.85, cy - r * 0.85)
                    ctx.lineTo(cx + r * 0.85, cy + r * 0.85)
                    ctx.stroke()
                }
            } else if (n === "bluetooth") {
                // simbol rune bluetooth tajam
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.48, cy - r * 0.48)
                ctx.lineTo(cx + r * 0.52, cy + r * 0.48)
                ctx.lineTo(cx, cy + r * 0.96)
                ctx.lineTo(cx, cy - r * 0.96)
                ctx.lineTo(cx + r * 0.52, cy - r * 0.48)
                ctx.lineTo(cx - r * 0.48, cy + r * 0.48)
                ctx.stroke()
            } else if (n === "snip" || n === "crop") {
                // ikon reticle crop / screenshot siku tajam
                var cr = r * 0.85
                ctx.beginPath()
                ctx.moveTo(cx - cr, cy - cr * 0.4)
                ctx.lineTo(cx - cr, cy - cr)
                ctx.lineTo(cx - cr * 0.4, cy - cr)

                ctx.moveTo(cx + cr * 0.4, cy - cr)
                ctx.lineTo(cx + cr, cy - cr)
                ctx.lineTo(cx + cr, cy - cr * 0.4)

                ctx.moveTo(cx + cr, cy + cr * 0.4)
                ctx.lineTo(cx + cr, cy + cr)
                ctx.lineTo(cx + cr * 0.4, cy + cr)

                ctx.moveTo(cx - cr * 0.4, cy + cr)
                ctx.lineTo(cx - cr, cy + cr)
                ctx.lineTo(cx - cr, cy + cr * 0.4)
                ctx.stroke()

                // titik tengah bidikan
                ctx.beginPath()
                ctx.arc(cx, cy, lw * 0.7, 0, Math.PI * 2)
                ctx.fill()
            } else if (n === "picker" || n === "palette") {
                // ikon pipet eyedropper / berlian warna
                ctx.beginPath()
                ctx.moveTo(cx + r * 0.75, cy - r * 0.75)
                ctx.lineTo(cx - r * 0.25, cy + r * 0.25)
                ctx.lineTo(cx - r * 0.78, cy + r * 0.78)
                ctx.stroke()

                // gagang pipet miring
                ctx.lineWidth = lw * 1.45
                ctx.beginPath()
                ctx.moveTo(cx + r * 0.25, cy - r * 0.25)
                ctx.lineTo(cx + r * 0.78, cy - r * 0.78)
                ctx.stroke()

                ctx.lineWidth = lw
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.05, cy - r * 0.35)
                ctx.lineTo(cx + r * 0.35, cy + r * 0.05)
                ctx.stroke()
            } else if (n === "phantom") {
                // topeng / bintang sabit phantom thieves
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.95, cy - r * 0.25)
                ctx.quadraticCurveTo(cx - r * 0.4, cy - r * 0.9, cx, cy - r * 0.25)
                ctx.quadraticCurveTo(cx + r * 0.4, cy - r * 0.9, cx + r * 0.95, cy - r * 0.25)
                ctx.quadraticCurveTo(cx + r * 0.55, cy + r * 0.75, cx, cy + r * 0.45)
                ctx.quadraticCurveTo(cx - r * 0.55, cy + r * 0.75, cx - r * 0.95, cy - r * 0.25)
                ctx.closePath()
                ctx.fill()

                // lubang mata miring
                ctx.globalCompositeOperation = "destination-out"
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.62, cy - r * 0.08)
                ctx.lineTo(cx - r * 0.18, cy + r * 0.06)
                ctx.lineTo(cx - r * 0.42, cy + r * 0.24)
                ctx.closePath()
                ctx.fill()

                ctx.beginPath()
                ctx.moveTo(cx + r * 0.62, cy - r * 0.08)
                ctx.lineTo(cx + r * 0.18, cy + r * 0.06)
                ctx.lineTo(cx + r * 0.42, cy + r * 0.24)
                ctx.closePath()
                ctx.fill()
                ctx.globalCompositeOperation = "source-over"
            } else if (n === "star") {
                // bintang 5 sudut persona 5
                ctx.beginPath()
                for (var si = 0; si < 10; si++) {
                    var sa = -Math.PI / 2 + (si * Math.PI / 5)
                    var sr = (si % 2 === 0) ? r * 1.05 : r * 0.42
                    var sx = cx + Math.cos(sa) * sr
                    var sy = cy + Math.sin(sa) * sr
                    if (si === 0) ctx.moveTo(sx, sy)
                    else ctx.lineTo(sx, sy)
                }
                ctx.closePath()
                ctx.fill()
            } else if (n === "sparkles") {
                // bintang 4 sudut tajam
                ctx.beginPath()
                for (var ki = 0; ki < 8; ki++) {
                    var ka = -Math.PI / 2 + (ki * Math.PI / 4)
                    var kr = (ki % 2 === 0) ? r * 1.05 : r * 0.28
                    var kx = cx + Math.cos(ka) * kr
                    var ky = cy + Math.sin(ka) * kr
                    if (ki === 0) ctx.moveTo(kx, ky)
                    else ctx.lineTo(kx, ky)
                }
                ctx.closePath()
                ctx.fill()
            } else if (n === "moon") {
                // bulan sabit
                ctx.beginPath()
                ctx.arc(cx, cy, r * 0.88, 0.35, Math.PI * 1.82)
                ctx.arc(cx + r * 0.38, cy - r * 0.26, r * 0.72, Math.PI * 1.72, 0.48, true)
                ctx.closePath()
                ctx.fill()
            } else if (n === "tv") {
                // televisi p4 golden dengan antena
                ctx.strokeRect(cx - r * 0.82, cy - r * 0.42, r * 1.64, r * 1.22)
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.45, cy - r * 0.92)
                ctx.lineTo(cx, cy - r * 0.42)
                ctx.lineTo(cx + r * 0.45, cy - r * 0.92)
                ctx.stroke()
            } else if (n === "sun" || n === "brightness") {
                ctx.beginPath()
                ctx.arc(cx, cy, r * 0.44, 0, Math.PI * 2)
                ctx.fill()
                for (var bi = 0; bi < 8; bi++) {
                    var ba = bi * Math.PI / 4
                    ctx.beginPath()
                    ctx.moveTo(cx + Math.cos(ba) * r * 0.66, cy + Math.sin(ba) * r * 0.66)
                    ctx.lineTo(cx + Math.cos(ba) * r * 0.98, cy + Math.sin(ba) * r * 0.98)
                    ctx.stroke()
                }
            } else if (n === "message") {
                // balon chat komik
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.85, cy - r * 0.68)
                ctx.lineTo(cx + r * 0.88, cy - r * 0.75)
                ctx.lineTo(cx + r * 0.78, cy + r * 0.35)
                ctx.lineTo(cx - r * 0.12, cy + r * 0.38)
                ctx.lineTo(cx - r * 0.68, cy + r * 0.92)
                ctx.lineTo(cx - r * 0.52, cy + r * 0.38)
                ctx.lineTo(cx - r * 0.85, cy + r * 0.35)
                ctx.closePath()
                ctx.fill()
            } else if (n === "bell" || n === "bell-off") {
                ctx.beginPath()
                ctx.arc(cx, cy - r * 0.15, r * 0.56, Math.PI, 0)
                ctx.lineTo(cx + r * 0.76, cy + r * 0.48)
                ctx.lineTo(cx - r * 0.76, cy + r * 0.48)
                ctx.closePath()
                ctx.fill()
                ctx.beginPath()
                ctx.arc(cx, cy + r * 0.72, r * 0.22, 0, Math.PI)
                ctx.fill()
                if (n === "bell-off") {
                    ctx.lineWidth = lw * 1.25
                    ctx.beginPath()
                    ctx.moveTo(cx - r * 0.88, cy - r * 0.82)
                    ctx.lineTo(cx + r * 0.88, cy + r * 0.82)
                    ctx.stroke()
                }
            } else if (n === "volume" || n === "mute") {
                // corong speaker
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.85, cy - r * 0.32)
                ctx.lineTo(cx - r * 0.42, cy - r * 0.32)
                ctx.lineTo(cx + r * 0.08, cy - r * 0.78)
                ctx.lineTo(cx + r * 0.08, cy + r * 0.78)
                ctx.lineTo(cx - r * 0.42, cy + r * 0.32)
                ctx.lineTo(cx - r * 0.85, cy + r * 0.32)
                ctx.closePath()
                ctx.fill()

                if (n === "mute") {
                    ctx.beginPath()
                    ctx.moveTo(cx + r * 0.35, cy - r * 0.35)
                    ctx.lineTo(cx + r * 0.88, cy + r * 0.35)
                    ctx.moveTo(cx + r * 0.88, cy - r * 0.35)
                    ctx.lineTo(cx + r * 0.35, cy + r * 0.35)
                    ctx.stroke()
                } else {
                    ctx.beginPath()
                    ctx.arc(cx + r * 0.12, cy, r * 0.42, -0.65, 0.65)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(cx + r * 0.12, cy, r * 0.76, -0.75, 0.75)
                    ctx.stroke()
                }
            } else if (n === "settings") {
                // roda gigi 6 gerigi
                for (var gi = 0; gi < 6; gi++) {
                    var ga = gi * Math.PI / 3
                    ctx.beginPath()
                    ctx.moveTo(cx + Math.cos(ga) * r * 0.45, cy + Math.sin(ga) * r * 0.45)
                    ctx.lineTo(cx + Math.cos(ga) * r * 0.92, cy + Math.sin(ga) * r * 0.92)
                    ctx.lineWidth = lw * 1.4
                    ctx.stroke()
                }
                ctx.lineWidth = lw
                ctx.beginPath()
                ctx.arc(cx, cy, r * 0.62, 0, Math.PI * 2)
                ctx.fill()
                ctx.globalCompositeOperation = "destination-out"
                ctx.beginPath()
                ctx.arc(cx, cy, r * 0.28, 0, Math.PI * 2)
                ctx.fill()
                ctx.globalCompositeOperation = "source-over"
            } else if (n === "power") {
                ctx.beginPath()
                ctx.arc(cx, cy + r * 0.08, r * 0.74, -Math.PI * 0.25, Math.PI * 1.25)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(cx, cy - r * 0.92)
                ctx.lineTo(cx, cy + r * 0.05)
                ctx.stroke()
            } else if (n === "lock") {
                ctx.fillRect(cx - r * 0.68, cy - r * 0.12, r * 1.36, r * 1.02)
                ctx.beginPath()
                ctx.arc(cx, cy - r * 0.15, r * 0.44, Math.PI, 0)
                ctx.stroke()
            } else if (n === "logout") {
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.1, cy - r * 0.78)
                ctx.lineTo(cx - r * 0.78, cy - r * 0.78)
                ctx.lineTo(cx - r * 0.78, cy + r * 0.78)
                ctx.lineTo(cx - r * 0.1, cy + r * 0.78)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.25, cy)
                ctx.lineTo(cx + r * 0.82, cy)
                ctx.moveTo(cx + r * 0.42, cy - r * 0.4)
                ctx.lineTo(cx + r * 0.82, cy)
                ctx.lineTo(cx + r * 0.42, cy + r * 0.4)
                ctx.stroke()
            } else if (n === "reboot" || n === "refresh" || n === "scan") {
                ctx.beginPath()
                ctx.arc(cx, cy, r * 0.74, 0.4, Math.PI * 1.75)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(cx + r * 0.22, cy - r * 0.78)
                ctx.lineTo(cx + r * 0.76, cy - r * 0.62)
                ctx.lineTo(cx + r * 0.56, cy - r * 0.12)
                ctx.fill()
            } else if (n === "search") {
                ctx.beginPath()
                ctx.arc(cx - r * 0.15, cy - r * 0.15, r * 0.58, 0, Math.PI * 2)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(cx + r * 0.28, cy + r * 0.28)
                ctx.lineTo(cx + r * 0.85, cy + r * 0.85)
                ctx.stroke()
            } else if (n === "chevron-right") {
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.35, cy - r * 0.68)
                ctx.lineTo(cx + r * 0.38, cy)
                ctx.lineTo(cx - r * 0.35, cy + r * 0.68)
                ctx.stroke()
            } else if (n === "chevron-left") {
                ctx.beginPath()
                ctx.moveTo(cx + r * 0.35, cy - r * 0.68)
                ctx.lineTo(cx - r * 0.38, cy)
                ctx.lineTo(cx + r * 0.35, cy + r * 0.68)
                ctx.stroke()
            } else if (n === "close") {
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.62, cy - r * 0.62)
                ctx.lineTo(cx + r * 0.62, cy + r * 0.62)
                ctx.moveTo(cx + r * 0.62, cy - r * 0.62)
                ctx.lineTo(cx - r * 0.62, cy + r * 0.62)
                ctx.stroke()
            } else if (n === "plus") {
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.68, cy)
                ctx.lineTo(cx + r * 0.68, cy)
                ctx.moveTo(cx, cy - r * 0.68)
                ctx.lineTo(cx, cy + r * 0.68)
                ctx.stroke()
            } else if (n === "minus") {
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.68, cy)
                ctx.lineTo(cx + r * 0.68, cy)
                ctx.stroke()
            } else if (n === "polygon") {
                // poligon berlian miring khas p5
                ctx.beginPath()
                ctx.moveTo(cx + r * 0.15, cy - r * 0.88)
                ctx.lineTo(cx + r * 0.88, cy - r * 0.12)
                ctx.lineTo(cx - r * 0.15, cy + r * 0.88)
                ctx.lineTo(cx - r * 0.88, cy + r * 0.12)
                ctx.closePath()
                ctx.stroke()
            } else if (n === "frame") {
                ctx.strokeRect(cx - r * 0.82, cy - r * 0.62, r * 1.64, r * 1.24)
            } else if (n === "check") {
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.68, cy + r * 0.05)
                ctx.lineTo(cx - r * 0.15, cy + r * 0.58)
                ctx.lineTo(cx + r * 0.75, cy - r * 0.52)
                ctx.stroke()
            } else if (n === "bars") {
                var by = [-r * 0.55, 0, r * 0.55]
                for (var mbi = 0; mbi < 3; mbi++) {
                    ctx.beginPath()
                    ctx.moveTo(cx - r * 0.75, cy + by[mbi])
                    ctx.lineTo(cx + r * 0.75, cy + by[mbi])
                    ctx.stroke()
                }
            } else if (n === "info") {
                ctx.beginPath()
                ctx.arc(cx, cy, r * 0.82, 0, Math.PI * 2)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(cx, cy - r * 0.35, lw * 0.6, 0, Math.PI * 2)
                ctx.fill()
                ctx.beginPath()
                ctx.moveTo(cx, cy - r * 0.05)
                ctx.lineTo(cx, cy + r * 0.45)
                ctx.stroke()
            } else if (n === "stats") {
                ctx.fillRect(cx - r * 0.75, cy + r * 0.05, r * 0.36, r * 0.7)
                ctx.fillRect(cx - r * 0.18, cy - r * 0.65, r * 0.36, r * 1.4)
                ctx.fillRect(cx + r * 0.39, cy - r * 0.25, r * 0.36, r * 1.0)
            } else if (n === "wallpaper" || n === "image") {
                // bingkai foto dengan matahari dan siluet gunung
                var fw = r * 1.72
                var fh = r * 1.44
                ctx.strokeRect(cx - fw / 2, cy - fh / 2, fw, fh)
                // titik matahari kiri atas
                ctx.beginPath()
                ctx.arc(cx - r * 0.34, cy - r * 0.22, r * 0.18, 0, Math.PI * 2)
                ctx.fill()
                // siluet 2 puncak gunung di bawah
                ctx.beginPath()
                ctx.moveTo(cx - fw * 0.42, cy + fh * 0.38)
                ctx.lineTo(cx - r * 0.22, cy + r * 0.04)
                ctx.lineTo(cx + r * 0.02, cy + r * 0.26)
                ctx.lineTo(cx + r * 0.32, cy - r * 0.14)
                ctx.lineTo(cx + fw * 0.42, cy + fh * 0.38)
                ctx.closePath()
                ctx.fill()
            } else if (n === "home") {
                // atap rumah + dinding
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.9, cy - r * 0.05)
                ctx.lineTo(cx, cy - r * 0.85)
                ctx.lineTo(cx + r * 0.9, cy - r * 0.05)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.62, cy - r * 0.12)
                ctx.lineTo(cx - r * 0.62, cy + r * 0.78)
                ctx.lineTo(cx + r * 0.62, cy + r * 0.78)
                ctx.lineTo(cx + r * 0.62, cy - r * 0.12)
                ctx.stroke()
            } else if (n === "folder") {
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.86, cy - r * 0.62)
                ctx.lineTo(cx - r * 0.2, cy - r * 0.62)
                ctx.lineTo(cx - r * 0.02, cy - r * 0.36)
                ctx.lineTo(cx + r * 0.86, cy - r * 0.36)
                ctx.lineTo(cx + r * 0.86, cy + r * 0.68)
                ctx.lineTo(cx - r * 0.86, cy + r * 0.68)
                ctx.closePath()
                ctx.stroke()
            } else if (n === "random" || n === "dice") {
                // kotak dadu 5 titik
                var dw = r * 1.64
                ctx.strokeRect(cx - dw / 2, cy - dw / 2, dw, dw)
                var dr = Math.max(1.1, r * 0.15)
                var pts = [
                    [cx - r * 0.38, cy - r * 0.38],
                    [cx + r * 0.38, cy - r * 0.38],
                    [cx, cy],
                    [cx - r * 0.38, cy + r * 0.38],
                    [cx + r * 0.38, cy + r * 0.38]
                ]
                for (var di = 0; di < pts.length; di++) {
                    ctx.beginPath()
                    ctx.arc(pts[di][0], pts[di][1], dr, 0, Math.PI * 2)
                    ctx.fill()
                }
            } else if (n === "music" || n === "note") {
                // not balok musik ganda
                ctx.beginPath()
                ctx.arc(cx - r * 0.42, cy + r * 0.48, r * 0.28, 0, Math.PI * 2)
                ctx.arc(cx + r * 0.36, cy + r * 0.32, r * 0.28, 0, Math.PI * 2)
                ctx.fill()
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.16, cy + r * 0.48)
                ctx.lineTo(cx - r * 0.16, cy - r * 0.62)
                ctx.lineTo(cx + r * 0.62, cy - r * 0.78)
                ctx.lineTo(cx + r * 0.62, cy + r * 0.32)
                ctx.stroke()
            } else if (n === "play") {
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.52, cy - r * 0.78)
                ctx.lineTo(cx + r * 0.78, cy)
                ctx.lineTo(cx - r * 0.52, cy + r * 0.78)
                ctx.closePath()
                ctx.fill()
            } else if (n === "pause") {
                var pw = r * 0.42
                var ph = r * 1.48
                ctx.fillRect(cx - r * 0.64, cy - ph / 2, pw, ph)
                ctx.fillRect(cx + r * 0.22, cy - ph / 2, pw, ph)
            } else if (n === "next" || n === "skip-forward") {
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.72, cy - r * 0.68)
                ctx.lineTo(cx + r * 0.32, cy)
                ctx.lineTo(cx - r * 0.72, cy + r * 0.68)
                ctx.closePath()
                ctx.fill()
                ctx.fillRect(cx + r * 0.42, cy - r * 0.68, Math.max(2, lw * 1.15), r * 1.36)
            } else if (n === "prev" || n === "skip-back") {
                ctx.fillRect(cx - r * 0.68, cy - r * 0.68, Math.max(2, lw * 1.15), r * 1.36)
                ctx.beginPath()
                ctx.moveTo(cx + r * 0.72, cy - r * 0.68)
                ctx.lineTo(cx - r * 0.32, cy)
                ctx.lineTo(cx + r * 0.72, cy + r * 0.68)
                ctx.closePath()
                ctx.fill()
            } else if (n === "shuffle") {
                ctx.beginPath()
                ctx.moveTo(cx - r * 0.78, cy - r * 0.48)
                ctx.lineTo(cx + r * 0.68, cy + r * 0.48)
                ctx.moveTo(cx - r * 0.78, cy + r * 0.48)
                ctx.lineTo(cx + r * 0.68, cy - r * 0.48)
                ctx.stroke()
            } else if (n === "repeat" || n === "loop") {
                ctx.strokeRect(cx - r * 0.72, cy - r * 0.48, r * 1.44, r * 0.96)
            } else {
                // fallback bintang
                ctx.beginPath()
                for (var fi = 0; fi < 10; fi++) {
                    var fa = -Math.PI / 2 + (fi * Math.PI / 5)
                    var fr = (fi % 2 === 0) ? r * 1.02 : r * 0.42
                    var fx = cx + Math.cos(fa) * fr
                    var fy = cy + Math.sin(fa) * fr
                    if (fi === 0) ctx.moveTo(fx, fy)
                    else ctx.lineTo(fx, fy)
                }
                ctx.closePath()
                ctx.fill()
            }
        }
    }
}
