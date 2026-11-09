import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config

// Persona 3 Reload live wallpaper engine with water ripples, floating particles, and time-of-day phases.
Item {
    id: p3WallpaperRoot
    anchors.fill: parent

    property bool animActive: true
    property bool forceDarkHour: false

    readonly property bool effectiveAnimRunning: animActive && (!PhantomState.p3WallpaperAutoPause || !PhantomState.hasActiveWindows) && !PhantomState.sessionOpen

    // Time phase resolution
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
        if (forceDarkHour) return "darkhour"
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

    // Base atmospheric color by time phase
    readonly property color ambientAtmosphereColor: {
        switch (timePhase) {
            case "darkhour": return "#32003d1c"
            case "latenight": return "#2e010822"
            case "morning": return "#16ffd880"
            case "afterschool": return "#00000000"
            case "evening": return "#28ff6820"
            default: return "#22030f36"
        }
    }

    // Sky gradient color by time phase
    readonly property color ambientSkyTopColor: {
        switch (timePhase) {
            case "darkhour": return "#40005a28"
            case "latenight": return "#20020d30"
            case "morning": return "#1800f0ff"
            case "afterschool": return "#00000000"
            case "evening": return "#2e881060"
            default: return "#1c041440"
        }
    }

    Image {
        id: bgRaw
        source: Qt.resolvedUrl("../../assets/themes/p3/bg/bg.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        visible: false
    }

    Image {
        id: cloudMaskRaw
        source: Qt.resolvedUrl("../../assets/themes/p3/bg/cloud_mask.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        visible: false
    }

    Image {
        id: normalMapRipple
        source: Qt.resolvedUrl("../../assets/themes/p3/bg/water_ripple_normal.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        visible: false
    }

    Image {
        id: barsRaw
        source: Qt.resolvedUrl("../../assets/themes/p3/bg/bars.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        visible: false
    }


    // Stage 0a: water ripple shader
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

    // Stage 0b: floating particle shader
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

    // Stage 1: composite background, light pillars, and character layer
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

        // Dynamic atmosphere overlay
        Rectangle {
            id: timeOfDayOverlay
            anchors.fill: parent
            color: p3WallpaperRoot.ambientAtmosphereColor
            opacity: 0.95

            Behavior on color {
                ColorAnimation { duration: 2400; easing.type: Easing.InOutQuad }
            }
        }

        // Sky gradient overlay
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

        // Dark hour vignette effect
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
