import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config

// Engine Wallpaper persona 3 reload lengkap: riak gelombang air mengalir, partikel cahaya mengapung, pergerakan pilar cahaya ambient, dan parallax 3d raymarching
Item {
    id: p3WallpaperRoot
    anchors.fill: parent

    property bool animActive: true

    readonly property bool effectiveAnimRunning: animActive && (!PhantomState.p3WallpaperAutoPause || !PhantomState.hasActiveWindows)

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
    }
}
