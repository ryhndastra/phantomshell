import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config

// Engine Wallpaper persona 3 reload lengkap: riak gelombang air mengalir, partikel cahaya mengapung, pergerakan pilar cahaya ambient, dan parallax 3d raymarching
Item {
    id: p3WallpaperRoot
    anchors.fill: parent

    property bool animActive: true

    readonly property bool effectiveAnimRunning: animActive && (!PhantomState.p3WallpaperAutoPause || !PhantomState.hasActiveWindows) && !PhantomState.sessionOpen

    // ── Jam & Periode Waktu Realistis Persona 3 Reload ──
    property int currentHour: new Date().getHours()

    Timer {
        interval: 20000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            p3WallpaperRoot.currentHour = new Date().getHours()
        }
    }

    readonly property string timePhase: {
        if (PhantomState.p3TimePhaseOverride && PhantomState.p3TimePhaseOverride !== "auto") {
            return PhantomState.p3TimePhaseOverride
        }
        const h = currentHour
        if (h >= 0 && h < 1) return "darkhour"      // 00:00 - 01:00 The Dark Hour
        if (h >= 1 && h < 6) return "latenight"     // 01:00 - 06:00 Midnight Ocean
        if (h >= 6 && h < 12) return "morning"      // 06:00 - 12:00 Crisp Morning Dawn
        if (h >= 12 && h < 17) return "afterschool" // 12:00 - 17:00 P3R Azure Daylight
        if (h >= 17 && h < 20) return "evening"     // 17:00 - 20:00 Sunset Twilight
        return "night"                              // 20:00 - 24:00 Deep Night
    }

    // Warna atmosfer dasar berdasarkan fase waktu
    readonly property color ambientAtmosphereColor: {
        switch (timePhase) {
            case "darkhour": return "#32003d1c"  // Hijau Emerald Supernatural Dark Hour
            case "latenight": return "#2e010822" // Indigo Pekat Tengah Malam
            case "morning": return "#16ffd880"   // Kilau Hangat Fajar Pagi
            case "afterschool": return "#00000000" // Azure Murni P3R
            case "evening": return "#28ff6820"   // Senja Keemasan Sunset
            default: return "#22030f36"          // Biru Samudra Malam
        }
    }

    // Warna gradasi pencahayaan langit atas
    readonly property color ambientSkyTopColor: {
        switch (timePhase) {
            case "darkhour": return "#40005a28"  // Cahaya Bulan Hijau Tartarus
            case "latenight": return "#20020d30"
            case "morning": return "#1800f0ff"   // Biru Langit Pagi
            case "afterschool": return "#00000000"
            case "evening": return "#2e881060"   // Magenta Twilight Dusk
            default: return "#1c041440"
        }
    }

    // Gambar latar dasar samudra / langit malam p3 reload
    Image {
        id: bgRaw
        source: Qt.resolvedUrl("../../assets/themes/p3/bg/bg.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        visible: false
    }

    // Masker kedalaman awan / permukaan air
    Image {
        id: cloudMaskRaw
        source: Qt.resolvedUrl("../../assets/themes/p3/bg/cloud_mask.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        visible: false
    }

    // Normal map untuk distorsi gelombang air realistis
    Image {
        id: normalMapRipple
        source: Qt.resolvedUrl("../../assets/themes/p3/bg/water_ripple_normal.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        visible: false
    }

    // Bilah pilar cahaya ambient mengapung khas p3 reload
    Image {
        id: barsRaw
        source: Qt.resolvedUrl("../../assets/themes/p3/bg/bars.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        visible: false
    }


    // ── Tahap 0a: Shader efek riak gelombang air pada background ──
    ShaderEffect {
        id: s0_bg_clouds
        anchors.fill: parent

        property var source: bgRaw
        property var normalMap: normalMapRipple
        property var depthMask: cloudMaskRaw
        property real time: 0
        property real flowStrength: 0.006
        property real speed: 0.8
        property real frequency: 1.0

        NumberAnimation on time {
            from: 0
            to: 1000
            duration: 450000
            loops: Animation.Infinite
            running: p3WallpaperRoot.effectiveAnimRunning
        }

        vertexShader: Qt.resolvedUrl("../../assets/themes/p3/shaders/ripple.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../../assets/themes/p3/shaders/ripple.frag.qsb")
    }

    ShaderEffectSource {
        id: s0_clouds_out
        sourceItem: s0_bg_clouds
        anchors.fill: parent
        hideSource: true
        live: p3WallpaperRoot.effectiveAnimRunning
    }

    // ── Tahap 0b: Shader partikel bintang / tetesan cahaya air melayang ──
    ShaderEffect {
        id: s0_bg_stars
        anchors.fill: parent

        property var source: s0_clouds_out
        property real time: 0
        property real strength: 40.0
        property real speed: 1.8
        property real frequency: 8.0

        NumberAnimation on time {
            from: 0
            to: 1000
            duration: 360000
            loops: Animation.Infinite
            running: p3WallpaperRoot.effectiveAnimRunning
        }

        vertexShader: Qt.resolvedUrl("../../assets/themes/p3/shaders/stars/stars.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../../assets/themes/p3/shaders/stars/stars.frag.qsb")
    }

    // ── Tahap 1: Komposit background + pergerakan pilar cahaya + karakter Makoto Yuki ──
    Item {
        id: s1_composite
        anchors.fill: parent

        ShaderEffectSource {
            id: s0_bg_out
            sourceItem: s0_bg_stars
            anchors.fill: parent
            hideSource: true
            live: p3WallpaperRoot.effectiveAnimRunning
        }

        ShaderEffect {
            id: s1_bars_motion
            anchors.fill: parent
            opacity: 0.45

            property var source: barsRaw
            property real time: 0
            property real speed: 0.006

            NumberAnimation on time {
                from: 0
                to: 10000
                duration: 500000
                loops: Animation.Infinite
                running: p3WallpaperRoot.effectiveAnimRunning
            }

            vertexShader: Qt.resolvedUrl("../../assets/themes/p3/shaders/motion/motion.vert.qsb")
            fragmentShader: Qt.resolvedUrl("../../assets/themes/p3/shaders/motion/motion.frag.qsb")
        }

        Image {
            id: s1_fg
            source: Qt.resolvedUrl("../../assets/themes/p3/bg/makoto_fg.png")
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
        }

        // Lapisan Pencahayaan Dinamis Atmosfer Berdasarkan Waktu Jam Nyata (Time-of-Day)
        Rectangle {
            id: timeOfDayOverlay
            anchors.fill: parent
            color: p3WallpaperRoot.ambientAtmosphereColor
            opacity: 0.95

            Behavior on color {
                ColorAnimation { duration: 2400; easing.type: Easing.InOutQuad }
            }
        }

        // Lapisan Gradasi Langit & Suasana Malam / Senja / Dark Hour
        Rectangle {
            id: timeOfDayGradient
            anchors.fill: parent
            opacity: p3WallpaperRoot.timePhase === "afterschool" ? 0.0 : 0.85
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: p3WallpaperRoot.ambientSkyTopColor
                }
                GradientStop {
                    position: 0.65
                    color: "transparent"
                }
                GradientStop {
                    position: 1.0
                    color: p3WallpaperRoot.timePhase === "darkhour" ? "#4000200c" : (p3WallpaperRoot.timePhase === "evening" ? "#24200518" : "#20020614")
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 2400; easing.type: Easing.InOutQuad }
            }
        }

        // Efek Vignette Khusus Dark Hour (00:00 - 01:00)
        Rectangle {
            anchors.fill: parent
            visible: p3WallpaperRoot.timePhase === "darkhour"
            opacity: 0.85
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#55001808" }
                GradientStop { position: 0.25; color: "transparent" }
                GradientStop { position: 0.75; color: "transparent" }
                GradientStop { position: 1.0; color: "#55001808" }
            }
        }
    }
}
