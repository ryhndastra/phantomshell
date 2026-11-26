import QtQuick
import Quickshell
import qs.config

Item {
    id: root
    anchors.fill: parent
    z: 999
    visible: active

    property bool active: false
    property real jokerProg: 0.0
    property int jokerFrame: 1 + Math.min(26, Math.floor(jokerProg * 27))

    property real impactProg: 0.0
    property real shatterProg: 0.0
    property int shatterFrame: 1 + Math.min(11, Math.floor(shatterProg * 12))
    property real redSlashProg: 0.0

    readonly property real impactX: width * 0.465
    readonly property real impactY: height * 0.50

    function playTransitionSfx(name) {
        if (!PhantomState.sfxEnabled || PhantomState.sfxVolume <= 0.01) return
        var soundPath = ""
        if (name === "glass_shatter") {
            soundPath = Quickshell.shellPath("assets/themes/p5/transitions/glass_shatter.wav")
        } else if (name === "wire_whoosh") {
            soundPath = Quickshell.shellPath("assets/themes/p5/transitions/wire_whoosh.wav")
        }
        if (soundPath !== "") {
            var vol = Math.max(0.01, Math.min(1.0, PhantomState.sfxVolume)).toFixed(2)
            var ffVol = Math.round(Math.max(1, Math.min(100, PhantomState.sfxVolume * 100)))
            Quickshell.execDetached([
                "bash", "-c",
                "pw-play --volume=" + vol + " '" + soundPath + "' 2>/dev/null || ffplay -nodisp -autoexit -loglevel quiet -volume " + ffVol + " '" + soundPath + "' 2>/dev/null || true"
            ])
        }
    }

    function startTransition() {
        transitionAnim.stop()
        PhantomState.closeAllModals()
        root.jokerProg = 0.0
        root.impactProg = 0.0
        root.shatterProg = 0.0
        root.redSlashProg = 0.0
        root.active = true
        transitionAnim.restart()
    }

    SequentialAnimation {
        id: transitionAnim
        running: false

        // Phase 1: Joker grappling wire swing into view
        ScriptAction {
            script: {
                root.playTransitionSfx("wire_whoosh")
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "jokerProg"
                from: 0.0
                to: 1.0
                duration: 900
                easing.type: Easing.Linear
            }
        }

        // Phase 2: Impact moment (boots hit the screen & shatter)
        ScriptAction {
            script: {
                root.playTransitionSfx("glass_shatter")
            }
        }

        ParallelAnimation {
            // White hot impact flash & theme swap behind the peak flare
            SequentialAnimation {
                NumberAnimation {
                    target: root
                    property: "impactProg"
                    from: 0.0
                    to: 1.0
                    duration: 110
                    easing.type: Easing.OutQuad
                }
                ScriptAction {
                    script: {
                        if (PhantomState.pendingPresetId) {
                            PhantomState.commitPresetApply(PhantomState.pendingPresetId, PhantomState.pendingSkipSave)
                            PhantomState.pendingPresetId = ""
                        }
                    }
                }
                NumberAnimation {
                    target: root
                    property: "impactProg"
                    from: 1.0
                    to: 0.0
                    duration: 280
                    easing.type: Easing.OutQuad
                }
            }

            // Glass shatter progression
            NumberAnimation {
                target: root
                property: "shatterProg"
                from: 0.0
                to: 1.0
                duration: 950
                easing.type: Easing.OutCubic
            }

            // Diagonal crimson energy sweep
            NumberAnimation {
                target: root
                property: "redSlashProg"
                from: 0.0
                to: 1.0
                duration: 850
                easing.type: Easing.OutQuart
            }
        }

        // Phase 3: Finish and cleanup
        ScriptAction {
            script: {
                root.active = false
                root.jokerProg = 0.0
                root.impactProg = 0.0
                root.shatterProg = 0.0
                root.redSlashProg = 0.0
            }
        }
    }

    // Vignette during swing
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.jokerProg > 0.001 && root.jokerProg < 0.95 ? (root.jokerProg * 0.35) : 0.0
    }

    // Joker Swing Sequence (27 Preloaded Frames)
    Item {
        id: jokerLayer
        anchors.fill: parent
        visible: root.jokerProg > 0.001 && root.jokerProg < 0.98
        opacity: root.jokerProg > 0.88 ? Math.max(0.0, (1.0 - root.jokerProg) / 0.12) : 1.0

        Repeater {
            model: 27
            delegate: Image {
                required property int index
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height * 0.065
                width: parent.width * 0.88
                height: parent.height * 0.88
                fillMode: Image.PreserveAspectFit
                asynchronous: false
                visible: (index + 1) === root.jokerFrame
                source: Qt.resolvedUrl("../../assets/themes/p5/transitions/joker_swing/joker_" + (index + 1 < 10 ? "0" : "") + (index + 1) + ".png")

                scale: 1.0 + (root.jokerProg * 0.08)
            }
        }
    }

    // Persona 5 Angular Crimson Slash Ribbon (Dynamic Metaverse Sweep)
    Canvas {
        id: crimsonSlashCanvas
        anchors.fill: parent
        visible: root.redSlashProg > 0.001 && root.redSlashProg < 0.999
        opacity: root.redSlashProg > 0.65 ? Math.max(0.0, (1.0 - root.redSlashProg) / 0.35) : Math.min(1.0, root.redSlashProg * 2.5)

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            if (root.redSlashProg <= 0.001) return

            var p = root.redSlashProg
            var w = width
            var h = height

            // Draw bold dynamic slash bands cutting across the screen
            ctx.fillStyle = "#E32F3B"
            ctx.beginPath()
            ctx.moveTo(w * (p * 1.5 - 0.4), 0)
            ctx.lineTo(w * (p * 1.5 + 0.15), 0)
            ctx.lineTo(w * (p * 1.5 - 0.15), h)
            ctx.lineTo(w * (p * 1.5 - 0.7), h)
            ctx.closePath()
            ctx.fill()

            // Black accent border on slash
            ctx.fillStyle = "#0D0D0D"
            ctx.beginPath()
            ctx.moveTo(w * (p * 1.5 + 0.15), 0)
            ctx.lineTo(w * (p * 1.5 + 0.22), 0)
            ctx.lineTo(w * (p * 1.5 - 0.08), h)
            ctx.lineTo(w * (p * 1.5 - 0.15), h)
            ctx.closePath()
            ctx.fill()
        }

        Connections {
            target: root
            function onRedSlashProgChanged() {
                crimsonSlashCanvas.requestPaint()
            }
        }
    }

    // Pre-rendered Glass Shatter Sequence (12 Frames)
    Item {
        id: shatterFrameLayer
        anchors.fill: parent
        visible: root.shatterProg > 0.001 && root.shatterProg < 0.999
        opacity: root.shatterProg > 0.70 ? Math.max(0.0, (1.0 - root.shatterProg) / 0.30) : 1.0

        Repeater {
            model: 12
            delegate: Image {
                required property int index
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: false
                visible: (index + 1) === root.shatterFrame
                source: Qt.resolvedUrl("../../assets/themes/p5/transitions/glass_shatter/shatter_" + (index + 1 < 10 ? "0" : "") + (index + 1) + ".png")
            }
        }
    }

    // Dynamic Procedural Flying Glass Shards (Physics Particles)
    Item {
        id: proceduralShardsLayer
        anchors.fill: parent
        visible: root.shatterProg > 0.001

        Repeater {
            model: 42
            delegate: Item {
                required property int index

                readonly property real angle: (((index * 137.5) % 360) * Math.PI) / 180.0
                readonly property real speed: 380 + ((index * 89) % 760)
                readonly property real distance: speed * root.shatterProg
                readonly property real gravity: root.shatterProg * root.shatterProg * 850

                x: root.impactX + Math.cos(angle) * distance
                y: root.impactY + Math.sin(angle) * distance + gravity
                rotation: (index * 43) + (root.shatterProg * ((index % 2 === 0 ? 1 : -1) * (360 + (index % 5) * 85)))
                scale: Math.max(0.12, (1.0 - root.shatterProg * 0.35) * (0.85 + (index % 5) * 0.25))
                opacity: Math.max(0.0, 1.0 - Math.pow(root.shatterProg, 1.6))

                // Polygon Shard Shape
                Rectangle {
                    anchors.centerIn: parent
                    width: (index % 4 === 0) ? (24 + (index % 5) * 12) :
                           (index % 4 === 1) ? (18 + (index % 6) * 10) :
                           (index % 4 === 2) ? (32 + (index % 4) * 14) : (14 + (index % 5) * 8)
                    height: (index % 3 === 0) ? (width * 0.55) :
                            (index % 3 === 1) ? (width * 0.85) : (width * 1.35)

                    // P5 Triad: Crimson Red, Phantom Black, and Specular Mirror Glass
                    color: (index % 3 === 0) ? "#E32F3B" :
                           (index % 3 === 1) ? "#121212" : "#F5F5F5"
                    border.color: "#FFFFFF"
                    border.width: (index % 2 === 0) ? 2 : 1
                    radius: (index % 5 === 0) ? 0 : 2
                    rotation: (index * 29) % 45
                }
            }
        }
    }

    // Impact Flash
    Item {
        id: impactStarLayer
        anchors.fill: parent
        visible: root.impactProg > 0.001

        Rectangle {
            anchors.fill: parent
            color: "#FFFFFF"
            opacity: Math.min(1.0, root.impactProg * 1.0)
        }
    }
}
