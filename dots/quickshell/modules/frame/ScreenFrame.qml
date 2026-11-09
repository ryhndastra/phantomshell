import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

Scope {
    Variants {
        model: Quickshell.screens

        // Optional screen frame and theme transition overlay.
        PanelWindow {
            id: frameWin
            required property ShellScreen modelData
            screen: modelData
            visible: true

            WlrLayershell.namespace: "phantomshell-frame"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"
            mask: Region {}

            property bool p3SplashActive: false
            property real p3SplashProg: 0.0
            property int p3SplashFrame: Math.min(11, Math.max(0, Math.floor(p3SplashProg)))
            property real p3OceanCoverage: Math.max(0.0, Math.min(1.0, (p3SplashProg - 0.4) / 4.6))

            SequentialAnimation {
                id: p3SplashSequence
                // Forward splash sweep (frames 0 -> 11)
                NumberAnimation {
                    target: frameWin
                    property: "p3SplashProg"
                    from: 0.0
                    to: 11.0
                    duration: 320
                    easing.type: Easing.InQuad
                }
                // Swap theme at full cover
                ScriptAction {
                    script: {
                        if (PhantomState.pendingPresetId) {
                            PhantomState.commitPresetApply(PhantomState.pendingPresetId, PhantomState.pendingSkipSave)
                            PhantomState.pendingPresetId = ""
                        }
                    }
                }
                PauseAnimation { duration: 50 }
                // Reverse splash sweep (frames 11 -> 0)
                NumberAnimation {
                    target: frameWin
                    property: "p3SplashProg"
                    from: 11.0
                    to: 0.0
                    duration: 360
                    easing.type: Easing.OutQuad
                }
                ScriptAction {
                    script: {
                        frameWin.p3SplashActive = false
                        frameWin.p3SplashProg = 0.0
                    }
                }
            }

            function triggerP3Splash() {
                p3SplashSequence.stop()
                frameWin.p3SplashProg = 0.0
                frameWin.p3SplashActive = true
                PhantomState.playSfx("splash")
                p3SplashSequence.restart()
            }

            property real slashProg: 1.0
            property real bannerOpacity: 0.0
            property real bannerScale: 0.8

            ParallelAnimation {
                id: p5TransitionAnim
                NumberAnimation {
                    target: frameWin
                    property: "slashProg"
                    from: 0.0
                    to: 1.0
                    duration: 1150
                    easing.type: Easing.OutCubic
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "bannerOpacity"
                        from: 0.0
                        to: 1.0
                        duration: 180
                        easing.type: Easing.OutQuad
                    }
                    PauseAnimation { duration: 640 }
                    NumberAnimation {
                        target: frameWin
                        property: "bannerOpacity"
                        from: 1.0
                        to: 0.0
                        duration: 320
                        easing.type: Easing.InCubic
                    }
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "bannerScale"
                        from: 0.78
                        to: 1.0
                        duration: 260
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.35
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "bannerScale"
                        from: 1.0
                        to: 1.06
                        duration: 880
                        easing.type: Easing.OutQuad
                    }
                }
            }

            property real velvetSlashProg: 1.0
            property real velvetBannerOpacity: 0.0
            property real velvetBannerScale: 0.8

            ParallelAnimation {
                id: velvetTransitionAnim
                NumberAnimation {
                    target: frameWin
                    property: "velvetSlashProg"
                    from: 0.0
                    to: 1.0
                    duration: PhantomState.specialWorkspaceActive ? 920 : 620
                    easing.type: Easing.OutCubic
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "velvetBannerOpacity"
                        from: 0.0
                        to: 1.0
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                    PauseAnimation { duration: PhantomState.specialWorkspaceActive ? 480 : 240 }
                    NumberAnimation {
                        target: frameWin
                        property: "velvetBannerOpacity"
                        from: 1.0
                        to: 0.0
                        duration: 260
                        easing.type: Easing.InCubic
                    }
                }
                SequentialAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "velvetBannerScale"
                        from: 0.80
                        to: 1.0
                        duration: 220
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.32
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "velvetBannerScale"
                        from: 1.0
                        to: 1.04
                        duration: 650
                        easing.type: Easing.OutQuad
                    }
                }
            }

            // Katana slash & crystal shatter transition sequence
            property bool p3AmbushActive: false
            property real p3SlashTrail1: 0.0
            property real p3SlashTrail2: 0.0
            property real p3ImpactFlare: 0.0
            property real p3ShardProg: 0.0
            property real p3FlashAlpha: 0.0
            property real p3RippleScale: 0.0

            SequentialAnimation {
                id: p3AmbushAnim

                // Phase 1: dual cross-slash (220ms)
                ParallelAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "p3SlashTrail1"
                        from: 0.0
                        to: 1.0
                        duration: 190
                        easing.type: Easing.OutQuad
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 30 }
                        NumberAnimation {
                            target: frameWin
                            property: "p3SlashTrail2"
                            from: 0.0
                            to: 1.0
                            duration: 190
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                // Midpoint impact: switch wallpaper behind the flash
                ScriptAction {
                    script: {
                        frameWin.p3FlashAlpha = 0.90
                        PhantomState.commitPendingWallpaper()
                    }
                }

                // Phase 2: glass shatter & particle burst (~700ms)
                ParallelAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "p3FlashAlpha"
                        from: 0.90
                        to: 0.0
                        duration: 320
                        easing.type: Easing.OutQuad
                    }
                    SequentialAnimation {
                        NumberAnimation {
                            target: frameWin
                            property: "p3ImpactFlare"
                            from: 0.0
                            to: 1.0
                            duration: 160
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.8
                        }
                        NumberAnimation {
                            target: frameWin
                            property: "p3ImpactFlare"
                            from: 1.0
                            to: 0.0
                            duration: 380
                            easing.type: Easing.OutQuad
                        }
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "p3ShardProg"
                        from: 0.0
                        to: 1.0
                        duration: 680
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "p3RippleScale"
                        from: 0.0
                        to: 1.0
                        duration: 600
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "p3SlashTrail1"
                        from: 1.0
                        to: 1.4
                        duration: 480
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "p3SlashTrail2"
                        from: 1.0
                        to: 1.4
                        duration: 480
                        easing.type: Easing.OutQuad
                    }
                }

                ScriptAction {
                    script: {
                        frameWin.p3AmbushActive = false
                        frameWin.p3SlashTrail1 = 0.0
                        frameWin.p3SlashTrail2 = 0.0
                        frameWin.p3ImpactFlare = 0.0
                        frameWin.p3ShardProg = 0.0
                        frameWin.p3FlashAlpha = 0.0
                        frameWin.p3RippleScale = 0.0
                    }
                }
            }

            function triggerP3AmbushSlash() {
                p3AmbushAnim.stop()
                frameWin.p3SlashTrail1 = 0.0
                frameWin.p3SlashTrail2 = 0.0
                frameWin.p3ImpactFlare = 0.0
                frameWin.p3ShardProg = 0.0
                frameWin.p3FlashAlpha = 0.0
                frameWin.p3RippleScale = 0.0
                frameWin.p3AmbushActive = true
                PhantomState.playSfx("into_game")
                p3AmbushAnim.restart()
            }

            // Shadow dissolve window-close sequence
            property bool p3DeathActive: false
            property real deathX: 50
            property real deathY: 50
            property real deathW: 800
            property real deathH: 600
            property real deathMelt: 0.0     // 0.0 (intact charred) -> 1.0 (fully melted down)
            property real deathBurn: 0.0     // 1.0 (searing burn) -> 0.0 (cools/evaporates)
            property real deathSmoke: 0.0    // 0.0 (billowing start) -> 1.0 (fully dispersed)
            property real deathPuddle: 0.0   // 0.0 -> 1.0 (puddle pool & evaporation)

            property real lastWinX: 50
            property real lastWinY: 50
            property real lastWinW: 800
            property real lastWinH: 600
            property var windowMap: ({})

            Process {
                id: getClientsProc
                running: false
                command: ["sh", "-c", "hyprctl clients -j | jq -c . 2>/dev/null || true"]
                stdout: SplitParser {
                    onRead: data => {
                        const line = String(data).trim()
                        if (!line || line.indexOf("[") !== 0) return
                        try {
                            const list = JSON.parse(line)
                            if (Array.isArray(list)) {
                                for (var i = 0; i < list.length; i++) {
                                    var c = list[i]
                                    if (c.address && c.at && c.size && c.size[0] > 40 && c.size[1] > 40) {
                                        var cleanKey = String(c.address).replace(/^0x/, "").toLowerCase()
                                        frameWin.windowMap[cleanKey] = {
                                            x: c.at[0],
                                            y: c.at[1],
                                            width: c.size[0],
                                            height: c.size[1]
                                        }
                                        if (c.focusHistoryID === 0) {
                                            frameWin.lastWinX = c.at[0]
                                            frameWin.lastWinY = c.at[1]
                                            frameWin.lastWinW = c.size[0]
                                            frameWin.lastWinH = c.size[1]
                                        }
                                    }
                                }
                            }
                        } catch (e) {}
                    }
                }
            }

            Timer {
                id: winPollTimer
                interval: 1500
                running: true
                repeat: true
                onTriggered: {
                    if (!getClientsProc.running) getClientsProc.running = true
                }
            }

            Timer {
                id: closePollTimer
                interval: 60
                repeat: false
                onTriggered: {
                    if (!getClientsProc.running) getClientsProc.running = true
                }
            }

            SequentialAnimation {
                id: p3ShadowDeathAnim

                // Dissolve animation sequence
                ParallelAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "deathMelt"
                        from: 0.0
                        to: 1.0
                        duration: 380
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "deathBurn"
                        from: 1.0
                        to: 0.0
                        duration: 320
                        easing.type: Easing.OutQuad
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 40 }
                        NumberAnimation {
                            target: frameWin
                            property: "deathPuddle"
                            from: 0.0
                            to: 1.0
                            duration: 340
                            easing.type: Easing.OutQuad
                        }
                    }
                    NumberAnimation {
                        target: frameWin
                        property: "deathSmoke"
                        from: 0.0
                        to: 1.0
                        duration: 420
                        easing.type: Easing.OutQuad
                    }
                }

                ScriptAction {
                    script: {
                        frameWin.p3DeathActive = false
                        frameWin.deathMelt = 0.0
                        frameWin.deathBurn = 0.0
                        frameWin.deathPuddle = 0.0
                        frameWin.deathSmoke = 0.0
                    }
                }
            }

            function triggerP3ShadowDeath(wx, wy, ww, wh) {
                var scrX = frameWin.modelData ? (frameWin.modelData.x || 0) : 0
                var scrY = frameWin.modelData ? (frameWin.modelData.y || 0) : 0
                var scrW = frameWin.modelData ? (frameWin.modelData.width || 1920) : 1920
                var scrH = frameWin.modelData ? (frameWin.modelData.height || 1080) : 1080

                var relX = wx - scrX
                var relY = wy - scrY
                if (relX + ww <= 0 || relX >= scrW || relY + wh <= 0 || relY >= scrH) return

                frameWin.deathX = Math.max(0, relX)
                frameWin.deathY = Math.max(0, relY)
                frameWin.deathW = Math.min(ww, scrW - frameWin.deathX)
                frameWin.deathH = Math.min(wh, scrH - frameWin.deathY)

                p3ShadowDeathAnim.stop()
                frameWin.deathMelt = 0.0
                frameWin.deathBurn = 1.0
                frameWin.deathPuddle = 0.0
                frameWin.deathSmoke = 0.0
                frameWin.p3DeathActive = true
                PhantomState.playSfx("select")
                p3ShadowDeathAnim.restart()
            }

            Connections {
                target: Hyprland
                function onRawEvent(event) {
                    const evName = String(event.name || "")
                    if (evName === "activewindow" || evName === "activewindowv2" || evName === "movewindow" || evName === "movewindowv2" || evName === "openwindow") {
                        if (!getClientsProc.running) {
                            getClientsProc.running = true
                        }
                    } else if (evName === "closewindow") {
                        if (PhantomState.isP3) {
                            const rawAddr = String(event.data || "").trim().replace(/^0x/, "").toLowerCase()
                            var targetGeom = frameWin.windowMap[rawAddr]
                            if (targetGeom) {
                                frameWin.triggerP3ShadowDeath(targetGeom.x, targetGeom.y, targetGeom.width, targetGeom.height)
                                delete frameWin.windowMap[rawAddr]
                            } else {
                                frameWin.triggerP3ShadowDeath(frameWin.lastWinX, frameWin.lastWinY, frameWin.lastWinW, frameWin.lastWinH)
                            }
                        }
                        closePollTimer.restart()
                    }
                }
            }

            Connections {
                target: PhantomState
                function onPrimaryChanged() { frameCanvas.requestPaint() }
                function onBackgroundChanged() { frameCanvas.requestPaint() }
                function onFrameThicknessChanged() { frameCanvas.requestPaint() }
                function onCornerRadiusChanged() { frameCanvas.requestPaint() }
                function onPolygonModeChanged() { frameCanvas.requestPaint() }
                function onScreenFrameChanged() { frameCanvas.requestPaint() }
                function onSpecialWorkspaceActiveChanged() { frameCanvas.requestPaint() }
                function onTransitionTickChanged() {
                    console.log("[SCREEN FRAME] onTransitionTickChanged: targetThemeId=" + PhantomState.targetThemeId)
                    if (PhantomState.targetThemeId === "p3-reload") {
                        frameWin.triggerP3Splash()
                    } else {
                        p5TransitionAnim.restart()
                    }
                }
                function onVelvetTransitionTickChanged() {
                    velvetTransitionAnim.restart()
                }
                function onWallpaperTransitionTickChanged() {
                    if (PhantomState.isP3) {
                        frameWin.triggerP3AmbushSlash()
                    }
                }
            }

            Canvas {
                id: frameCanvas
                anchors.fill: parent
                visible: PhantomState.screenFrame || PhantomState.specialWorkspaceActive
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.clearRect(0, 0, width, height)

                    var isVelvet = PhantomState.specialWorkspaceActive
                    var t = isVelvet ? Math.max(3, PhantomState.frameThickness) : PhantomState.frameThickness
                    var c = PhantomState.polygonMode ? 14 : PhantomState.cornerRadius
                    var w = width
                    var h = height

                    ctx.fillStyle = isVelvet ? "#060B1E" : PhantomState.background

                    ctx.fillRect(0, 0, w, t)
                    ctx.fillRect(0, h - t, w, t)
                    ctx.fillRect(0, t, t, h - t * 2)
                    ctx.fillRect(w - t, t, t, h - t * 2)

                    ctx.beginPath()
                    ctx.moveTo(t, t); ctx.lineTo(t + c, t); ctx.lineTo(t, t + c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(w - t, t); ctx.lineTo(w - t - c, t); ctx.lineTo(w - t, t + c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(w - t, h - t); ctx.lineTo(w - t - c, h - t); ctx.lineTo(w - t, h - t - c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(t, h - t); ctx.lineTo(t + c, h - t); ctx.lineTo(t, h - t - c); ctx.closePath(); ctx.fill()

                    ctx.strokeStyle = isVelvet ? "#60A5FA" : PhantomState.primary
                    ctx.lineWidth = isVelvet ? 2.0 : 1.5
                    ctx.beginPath()
                    ctx.moveTo(t + c, t)
                    ctx.lineTo(w - t - c, t)
                    ctx.lineTo(w - t, t + c)
                    ctx.lineTo(w - t, h - t - c)
                    ctx.lineTo(w - t - c, h - t)
                    ctx.lineTo(t + c, h - t)
                    ctx.lineTo(t, h - t - c)
                    ctx.lineTo(t, t + c)
                    ctx.closePath()
                    ctx.stroke()
                }
            }

            // Velvet room indicator overlay
            Item {
                id: velvetAtmosphere
                anchors.fill: parent
                visible: opacity > 0.01
                opacity: PhantomState.specialWorkspaceActive ? 1.0 : 0.0

                readonly property var specialApps: (PhantomState.workspaceApps && PhantomState.workspaceApps["special"])
                    ? PhantomState.workspaceApps["special"]
                    : []
                readonly property int specialCount: specialApps.length

                Behavior on opacity {
                    NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                }

                Rectangle {
                    width: 240
                    height: 3
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 56
                    anchors.rightMargin: -30
                    rotation: 18
                    color: "#0077B6"
                    opacity: 0.65
                }

                Rectangle {
                    width: 180
                    height: 2
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 66
                    anchors.rightMargin: -20
                    rotation: 18
                    color: "#00F0FF"
                    opacity: 0.55
                }

                Item {
                    anchors.centerIn: parent
                    width: 480
                    height: 104
                    visible: velvetAtmosphere.specialCount === 0 && frameWin.velvetSlashProg >= 0.85
                    opacity: visible ? 0.95 : 0.0

                    Behavior on opacity {
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#EE040D26"
                        border.color: "#00F0FF"
                        border.width: 1.5

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 5
                            color: "transparent"
                            border.color: "#4D0077B6"
                            border.width: 1
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 16

                        Item {
                            width: 40
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: 38
                                height: 38
                                radius: 19
                                color: "transparent"
                                border.color: "#00F0FF"
                                border.width: 1.5
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 26
                                height: 26
                                radius: 13
                                color: "#2200F0FF"
                                border.color: "#93C5FD"
                                border.width: 1
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "V"
                                color: "#00F0FF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 14
                                font.weight: Font.Black
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                text: "THE VELVET ROOM // EMPTY CHAMBER"
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 15
                                font.weight: Font.Black
                                font.letterSpacing: 1.2
                            }

                            Text {
                                text: "NO ACTIVE WINDOWS IN SPECIAL WORKSPACE"
                                color: "#7DD3FC"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }

                            Rectangle {
                                width: emptyHintTxt.implicitWidth + 16
                                height: 22
                                radius: 3
                                color: "#0A255C"
                                border.color: "#00F0FF"
                                border.width: 1

                                Text {
                                    id: emptyHintTxt
                                    anchors.centerIn: parent
                                    text: "[SUPER + ALT + S] MOVE WINDOW HERE   •   [SUPER + S] EXIT"
                                    color: "#F0F9FF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.letterSpacing: 0.5
                                }
                            }
                        }
                    }
                }

                Item {
                    width: velvetCornerRow.implicitWidth + 24
                    height: 32
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.bottomMargin: PhantomState.barPosition === "bottom" ? 48 : 16
                    anchors.rightMargin: 18

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: "#EE040D26"
                        border.color: "#00F0FF"
                        border.width: 1.5
                    }

                    Row {
                        id: velvetCornerRow
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#00F0FF"
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "VELVET ROOM"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Black
                            font.letterSpacing: 1.0
                        }

                        Rectangle {
                            width: contractTxt.implicitWidth + 10
                            height: 18
                            radius: 3
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#0A255C"
                            border.color: "#38BDF8"
                            border.width: 1

                            Text {
                                id: contractTxt
                                anchors.centerIn: parent
                                text: velvetAtmosphere.specialCount + (velvetAtmosphere.specialCount === 1 ? " WINDOW" : " WINDOWS")
                                color: "#38BDF8"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 9
                                font.weight: Font.Black
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "[SUPER+S] EXIT"
                            color: "#7DD3FC"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // Velvet room transition animation
            Item {
                id: velvetSlashOverlay
                anchors.fill: parent
                visible: frameWin.velvetSlashProg < 0.995
                clip: true

                Rectangle {
                    anchors.fill: parent
                    color: "#030A1E"
                    opacity: Math.sin(frameWin.velvetSlashProg * Math.PI) * 0.75
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * (1.0 - frameWin.velvetSlashProg) * 0.85
                    opacity: Math.sin(frameWin.velvetSlashProg * Math.PI) * 0.45
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.3; color: "#4D0077B6" }
                        GradientStop { position: 0.5; color: "#8000F0FF" }
                        GradientStop { position: 0.7; color: "#4D0077B6" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.height * (0.3 + frameWin.velvetSlashProg * 0.9)
                    height: width
                    radius: width / 2
                    color: "transparent"
                    border.color: "#00F0FF"
                    border.width: Math.max(1, (1.0 - frameWin.velvetSlashProg) * 3)
                    opacity: Math.sin(frameWin.velvetSlashProg * Math.PI) * 0.6
                }

                Item {
                    anchors.centerIn: parent
                    width: 480
                    height: 80
                    scale: frameWin.velvetBannerScale
                    opacity: frameWin.velvetBannerOpacity

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#EE030B22"
                        border.color: "#00F0FF"
                        border.width: 2

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 5
                            color: "transparent"
                            border.color: "#4D00B4D8"
                            border.width: 1
                        }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 16

                        Item {
                            width: 40
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: 38
                                height: 38
                                radius: 19
                                color: "transparent"
                                border.color: "#00F0FF"
                                border.width: 1.5
                                rotation: frameWin.velvetSlashProg * 360
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 26
                                height: 26
                                radius: 13
                                color: "#2200F0FF"
                                border.color: "#93C5FD"
                                border.width: 1
                                rotation: -frameWin.velvetSlashProg * 240
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "V"
                                color: "#00F0FF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 14
                                font.weight: Font.Black
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3

                            Text {
                                text: PhantomState.specialWorkspaceActive
                                    ? "WELCOME TO THE VELVET ROOM"
                                    : "LEAVING THE VELVET ROOM"
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 16
                                font.weight: Font.Black
                                font.letterSpacing: 1.2
                            }

                            Row {
                                spacing: 6
                                Rectangle {
                                    height: 18
                                    width: velvetSubLbl.implicitWidth + 12
                                    radius: 3
                                    color: "#0A255C"
                                    border.color: "#00F0FF"
                                    border.width: 1

                                    Text {
                                        id: velvetSubLbl
                                        anchors.centerIn: parent
                                        text: PhantomState.specialWorkspaceActive
                                            ? "SEA OF SOUL // SPECIAL WORKSPACE"
                                            : "METAVERSE SHIFT // CONTRACT SUSPENDED"
                                        color: "#00F0FF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                        font.letterSpacing: 0.8
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Diagonal ribbon theme transition
            Item {
                id: slashOverlay
                anchors.fill: parent
                visible: frameWin.slashProg < 0.995 && PhantomState.themeId !== "p3-reload"
                clip: true

                Rectangle {
                    anchors.fill: parent
                    color: PhantomState.primary
                    opacity: Math.max(0.0, (1.0 - frameWin.slashProg) * 0.16)
                }

                Item {
                    anchors.centerIn: parent
                    width: parent.width * 1.6
                    height: 220
                    rotation: -13

                    Rectangle {
                        width: parent.width * 0.55
                        height: 28
                        y: 16
                        x: -width + (parent.width + width) * frameWin.slashProg
                        color: PhantomState.secondary
                        border.color: "#05060A"
                        border.width: 2
                    }

                    Rectangle {
                        width: parent.width * 0.72
                        height: 82
                        y: 48
                        x: -width + (parent.width + width) * Math.min(1.0, frameWin.slashProg * 1.08)
                        color: PhantomState.primary
                        border.color: "#FFFFFF"
                        border.width: 3

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 16
                            anchors.bottomMargin: 16
                            color: "#05060A"
                        }
                    }

                    Rectangle {
                        width: parent.width * 0.48
                        height: 14
                        y: 142
                        x: parent.width - (parent.width + width) * frameWin.slashProg
                        color: "#FFFFFF"
                        border.color: "#05060A"
                        border.width: 2
                    }
                }

                Item {
                    anchors.centerIn: parent
                    width: 440
                    height: 76
                    rotation: -5
                    scale: frameWin.bannerScale
                    opacity: frameWin.bannerOpacity

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: "#06070B"
                        borderColor: "#FFFFFF"
                        shadowColor: PhantomState.primary
                        borderWidth: 2.5
                        skewPx: 14
                        shadowOffsetX: 6
                        shadowOffsetY: 6
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 14

                        P5Star {
                            width: 34
                            height: 34
                            anchors.verticalCenter: parent.verticalCenter
                            spinning: slashOverlay.visible
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: PhantomState.transitionTitle
                                color: "#FFFFFF"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 18
                                font.weight: Font.Black
                                font.italic: true
                            }

                            Rectangle {
                                width: subLbl.implicitWidth + 14
                                height: 18
                                color: PhantomState.primary
                                border.color: "#FFFFFF"
                                border.width: 1

                                Text {
                                    id: subLbl
                                    anchors.centerIn: parent
                                    text: PhantomState.transitionSub
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.weight: Font.Black
                                    font.italic: true
                                }
                            }
                        }
                    }
                }
            }

            // Water splash transition overlay (12-frame sequence)
            Item {
                id: p3SplashOverlay
                anchors.fill: parent
                visible: frameWin.p3SplashActive
                z: 100

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -20
                    opacity: Math.max(0.0, Math.min(1.0, Math.pow(frameWin.p3SplashProg / 6.0, 1.8)))
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#010A1A" }
                        GradientStop { position: 0.28; color: "#021C42" }
                        GradientStop { position: 0.58; color: "#003A75" }
                        GradientStop { position: 0.85; color: "#0077B6" }
                        GradientStop { position: 1.0; color: "#00B4D8" }
                    }
                }

                Repeater {
                    model: 6
                    delegate: Rectangle {
                        required property int index
                        width: parent.width * 0.22 + (index * 25)
                        height: parent.height * 1.4
                        x: (parent.width * (0.04 + index * 0.17)) + Math.sin(frameWin.p3SplashFrame * 0.6 + index) * 24
                        y: -parent.height * 0.2
                        rotation: -14 + index * 4.5
                        opacity: Math.min(1.0, frameWin.p3SplashProg / 4.0) * (0.14 + (index % 3) * 0.08)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#9900F0FF" }
                            GradientStop { position: 0.65; color: "#400077B6" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }
                }

                Repeater {
                    model: 28
                    delegate: Item {
                        required property int index
                        readonly property real baseX: ((index * 67 + 31) % 100) / 100.0 * parent.width
                        readonly property real startY: parent.height * (0.5 + ((index * 37) % 50) / 100.0)
                        readonly property real speed: 0.75 + ((index * 13) % 10) / 10.0
                        readonly property real bSize: 8 + ((index * 11) % 22)
                        readonly property real wobble: Math.sin(frameWin.p3SplashFrame * 0.8 + index) * (12 + (index % 4) * 6)
                        readonly property real currentY: startY - (parent.height * 0.85 * (frameWin.p3SplashProg / 11.0) * speed)
                        x: baseX + wobble
                        y: currentY
                        width: bSize
                        height: bSize
                        opacity: Math.min(1.0, frameWin.p3SplashProg / 3.0) * (0.4 + (index % 4) * 0.15)
                        visible: currentY > -30 && currentY < parent.height + 30

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "#2600F0FF"
                            border.color: "#E6FFFFFF"
                            border.width: 1.2

                            Rectangle {
                                x: parent.width * 0.22
                                y: parent.height * 0.2
                                width: Math.max(2, parent.width * 0.28)
                                height: Math.max(2, parent.height * 0.28)
                                radius: width / 2
                                color: "#FFFFFF"
                                opacity: 0.9
                            }
                        }
                    }
                }

                Item {
                    anchors.fill: parent
                    scale: 1.25
                    transformOrigin: Item.Center

                    Repeater {
                        model: 12
                        delegate: Image {
                            required property int index
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            visible: frameWin.p3SplashFrame === index
                            asynchronous: false
                            cache: true
                            source: Qt.resolvedUrl("../../assets/themes/p3/menu/png/pngseq" + (index < 10 ? "0" + index : "" + index) + ".png")
                        }
                    }
                }

                Item {
                    anchors.fill: parent
                    scale: 1.22
                    opacity: 0.85
                    transformOrigin: Item.Center

                    Repeater {
                        model: 12
                        delegate: Image {
                            required property int index
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            visible: frameWin.p3SplashFrame === index
                            mirror: true
                            asynchronous: false
                            cache: true
                            source: Qt.resolvedUrl("../../assets/themes/p3/menu/png/pngseq" + (index < 10 ? "0" + index : "" + index) + ".png")
                        }
                    }
                }
            }

            // Katana slash & crystal particle overlay
            Item {
                id: p3AmbushOverlay
                anchors.fill: parent
                visible: frameWin.p3AmbushActive
                z: 110

                Rectangle {
                    anchors.fill: parent
                    color: "#FFFFFF"
                    opacity: frameWin.p3FlashAlpha * 0.45
                }
                Rectangle {
                    anchors.fill: parent
                    color: "#00F0FF"
                    opacity: frameWin.p3FlashAlpha * 0.35
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 1.6 * frameWin.p3RippleScale
                    height: parent.height * 1.3 * frameWin.p3RippleScale
                    radius: width / 2
                    color: "transparent"
                    border.color: "#00F0FF"
                    border.width: Math.max(1.0, 4.0 * (1.0 - frameWin.p3RippleScale))
                    opacity: Math.max(0.0, (1.0 - frameWin.p3RippleScale) * 0.85)

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 16
                        radius: width / 2
                        color: "transparent"
                        border.color: "#FFFFFF"
                        border.width: Math.max(1.0, 2.0 * (1.0 - frameWin.p3RippleScale))
                        opacity: 0.65
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.85 * frameWin.p3RippleScale
                    height: width
                    rotation: 45
                    color: "transparent"
                    border.color: "#3300F0FF"
                    border.width: Math.max(1.0, 2.5 * (1.0 - frameWin.p3RippleScale))
                    opacity: Math.max(0.0, (1.0 - frameWin.p3RippleScale) * 0.7)
                }

                Canvas {
                    id: slashCanvas
                    anchors.fill: parent
                    antialiasing: true

                    Connections {
                        target: frameWin
                        function onP3SlashTrail1Changed() { slashCanvas.requestPaint() }
                        function onP3SlashTrail2Changed() { slashCanvas.requestPaint() }
                        function onP3ImpactFlareChanged() { slashCanvas.requestPaint() }
                    }

                    function drawBlade(ctx, trail, x0, y0, cx, cy, x1, y1) {
                        if (trail <= 0.001 || trail >= 1.39) return

                        var t = Math.min(1.0, trail)
                        var tStart = (trail <= 1.0) ? 0.0 : Math.min(1.0, Math.max(0.0, (trail - 1.0) * 2.5))
                        var alpha = Math.max(0.0, 1.0 - Math.max(0.0, trail - 1.0) * 2.5)

                        if (tStart >= t) return

                        ctx.lineCap = "round"
                        ctx.lineJoin = "round"

                        function buildBladePath() {
                            ctx.beginPath()
                            var first = true
                            var step = 0.02
                            for (var s = tStart; s < t; s += step) {
                                var inv = 1 - s
                                var px = inv * inv * x0 + 2 * inv * s * cx + s * s * x1
                                var py = inv * inv * y0 + 2 * inv * s * cy + s * s * y1
                                if (first) {
                                    ctx.moveTo(px, py)
                                    first = false
                                } else {
                                    ctx.lineTo(px, py)
                                }
                            }
                            var invT = 1 - t
                            var endX = invT * invT * x0 + 2 * invT * t * cx + t * t * x1
                            var endY = invT * invT * y0 + 2 * invT * t * cy + t * t * y1
                            if (first) ctx.moveTo(endX, endY)
                            else ctx.lineTo(endX, endY)
                        }

                        ctx.strokeStyle = "rgba(0, 240, 255, " + (alpha * 0.65).toFixed(2) + ")"
                        ctx.lineWidth = 32 * (1.0 - tStart * 0.5)
                        buildBladePath()
                        ctx.stroke()

                        ctx.strokeStyle = "rgba(0, 180, 216, " + (alpha * 0.88).toFixed(2) + ")"
                        ctx.lineWidth = 16 * (1.0 - tStart * 0.5)
                        buildBladePath()
                        ctx.stroke()

                        ctx.strokeStyle = "rgba(255, 255, 255, " + (alpha * 0.98).toFixed(2) + ")"
                        ctx.lineWidth = 6 * (1.0 - tStart * 0.4)
                        buildBladePath()
                        ctx.stroke()
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.clearRect(0, 0, width, height)

                        var midX = width * 0.50
                        var midY = height * 0.50

                        drawBlade(ctx, frameWin.p3SlashTrail1, -100, height * 0.12, width * 0.50, height * 0.50, width + 100, height * 0.88)

                        drawBlade(ctx, frameWin.p3SlashTrail2, width + 100, height * 0.14, width * 0.50, height * 0.50, -100, height * 0.86)

                        var flare = frameWin.p3ImpactFlare
                        if (flare > 0.01) {
                            var radGrd = ctx.createRadialGradient(midX, midY, 0, midX, midY, 160 * flare)
                            radGrd.addColorStop(0.0, "rgba(255, 255, 255, " + (flare * 0.98).toFixed(2) + ")")
                            radGrd.addColorStop(0.35, "rgba(0, 240, 255, " + (flare * 0.75).toFixed(2) + ")")
                            radGrd.addColorStop(1.0, "rgba(0, 240, 255, 0.0)")
                            ctx.fillStyle = radGrd
                            ctx.beginPath()
                            ctx.arc(midX, midY, 160 * flare, 0, Math.PI * 2)
                            ctx.fill()

                            var hLen = width * 0.45 * flare
                            var hW = 15 * flare
                            ctx.fillStyle = "rgba(255, 255, 255, " + (flare * 0.95).toFixed(2) + ")"
                            ctx.beginPath()
                            ctx.moveTo(midX - hLen, midY)
                            ctx.lineTo(midX, midY - hW)
                            ctx.lineTo(midX + hLen, midY)
                            ctx.lineTo(midX, midY + hW)
                            ctx.closePath()
                            ctx.fill()

                            var vLen = height * 0.48 * flare
                            var vW = 15 * flare
                            ctx.beginPath()
                            ctx.moveTo(midX, midY - vLen)
                            ctx.lineTo(midX + vW, midY)
                            ctx.lineTo(midX, midY + vLen)
                            ctx.lineTo(midX - vW, midY)
                            ctx.closePath()
                            ctx.fill()

                            var dLen = width * 0.24 * flare
                            var dW = 9 * flare
                            ctx.fillStyle = "rgba(0, 240, 255, " + (flare * 0.85).toFixed(2) + ")"
                            ctx.save()
                            ctx.translate(midX, midY)
                            ctx.rotate(Math.PI / 4)
                            ctx.beginPath()
                            ctx.moveTo(-dLen, 0)
                            ctx.lineTo(0, -dW)
                            ctx.lineTo(dLen, 0)
                            ctx.lineTo(0, dW)
                            ctx.closePath()
                            ctx.fill()
                            ctx.beginPath()
                            ctx.moveTo(0, -dLen)
                            ctx.lineTo(dW, 0)
                            ctx.lineTo(0, dLen)
                            ctx.lineTo(-dW, 0)
                            ctx.closePath()
                            ctx.fill()
                            ctx.restore()
                        }
                    }
                }

                Item {
                    id: shardsContainer
                    anchors.fill: parent
                    visible: frameWin.p3ShardProg > 0.001

                    Repeater {
                        model: 54
                        delegate: Item {
                            required property int index

                            readonly property real ratio: index / 54.0
                            readonly property bool isSlash1: (index % 2 === 0)
                            readonly property real originX: isSlash1 ? (ratio * parent.width) : ((1.0 - ratio) * parent.width)
                            readonly property real originY: isSlash1 ? ((parent.height * 0.12) + ratio * (parent.height * 0.76)) : ((parent.height * 0.14) + ratio * (parent.height * 0.72))

                            readonly property real angleBase: (index % 4 < 2 ? -1.15 : 0.95) * (Math.PI / 2)
                            readonly property real angleSpread: (((index * 67) % 80) - 40) * (Math.PI / 180)
                            readonly property real angle: (index % 6 === 0) ? ((((index * 137.5) % 360) * Math.PI) / 180.0) : (angleBase + angleSpread)

                            readonly property real speed: 240 + ((index * 97) % 680)
                            readonly property real distance: speed * frameWin.p3ShardProg
                            readonly property real gravity: frameWin.p3ShardProg * frameWin.p3ShardProg * 150

                            x: originX + Math.cos(angle) * distance
                            y: originY + Math.sin(angle) * distance + gravity
                            rotation: (index * 47) + (frameWin.p3ShardProg * ((index % 2 === 0 ? 1 : -1) * (240 + (index % 7) * 45)))
                            scale: Math.max(0.10, (1.0 - frameWin.p3ShardProg * 0.45) * (0.85 + ((index % 5) * 0.25)))
                            opacity: Math.max(0.0, 1.0 - Math.pow(frameWin.p3ShardProg, 1.5))

                            // Crystal shapes: 0=sliver, 1=rhombus, 2=wedge, 3=chip, 4=impact chunk
                            Rectangle {
                                anchors.centerIn: parent
                                width: (index % 5 === 0) ? (5 + (index % 4)) :
                                       ((index % 5 === 1) ? (18 + (index % 10)) :
                                       ((index % 5 === 2) ? (14 + (index % 8)) :
                                       ((index % 5 === 3) ? (10 + (index % 6)) : (32 + (index % 16)))))
                                height: (index % 5 === 0) ? (46 + (index % 26)) :
                                        ((index % 5 === 1) ? (18 + (index % 10)) :
                                        ((index % 5 === 2) ? (28 + (index % 14)) :
                                        ((index % 5 === 3) ? (14 + (index % 8)) : (36 + (index % 16)))))
                                radius: (index % 5 === 3) ? 2 : 0
                                rotation: (index % 5 === 1) ? 45 : ((index % 5 === 2) ? -26 : 0)
                                color: (index % 4 === 0) ? "#E6011A42" :
                                       ((index % 4 === 1) ? "#D9003A75" :
                                       ((index % 4 === 2) ? "#CC0077B6" : "#E60A2540"))
                                border.color: (index % 3 === 0) ? "#00F0FF" : ((index % 3 === 1) ? "#FFFFFF" : "#70E0FF")
                                border.width: (index % 5 === 4) ? 2.0 : 1.4

                                Rectangle {
                                    width: Math.max(2, parent.width * 0.45)
                                    height: Math.max(2, parent.height * 0.45)
                                    x: 1
                                    y: 1
                                    color: "#FFFFFF"
                                    opacity: 0.85
                                }
                            }
                        }
                    }
                }

                Item {
                    id: bubblesContainer
                    anchors.fill: parent
                    visible: frameWin.p3ShardProg > 0.001

                    Repeater {
                        model: 36
                        delegate: Item {
                            required property int index

                            readonly property real ratio: index / 36.0
                            readonly property real originX: ratio * parent.width
                            readonly property real originY: (parent.height * 0.18) + ratio * (parent.height * 0.68)

                            readonly property real angle: (((index * 137.5) % 360) * Math.PI) / 180.0
                            readonly property real speed: 140 + ((index * 61) % 440)
                            readonly property real distance: speed * frameWin.p3ShardProg

                            x: originX + Math.cos(angle) * distance
                            y: originY + Math.sin(angle) * distance - (frameWin.p3ShardProg * 50)
                            opacity: Math.max(0.0, (1.0 - frameWin.p3ShardProg) * 0.9)

                            Rectangle {
                                anchors.centerIn: parent
                                width: 6 + ((index * 9) % 20)
                                height: width
                                radius: width / 2
                                color: "#3300F0FF"
                                border.color: "#E6FFFFFF"
                                border.width: 1.2

                                Rectangle {
                                    width: Math.max(2, parent.width * 0.28)
                                    height: width
                                    x: parent.width * 0.22
                                    y: parent.height * 0.22
                                    radius: width / 2
                                    color: "#FFFFFF"
                                    opacity: 0.95
                                }
                            }
                        }
                    }
                }
            }

            Item {
                id: p3ShadowDeathOverlay
                x: frameWin.deathX
                y: frameWin.deathY
                width: frameWin.deathW
                height: frameWin.deathH
                visible: frameWin.p3DeathActive
                z: 120

                Canvas {
                    id: meltCanvas
                    anchors.fill: parent
                    antialiasing: true

                    Connections {
                        target: frameWin
                        function onDeathMeltChanged() { meltCanvas.requestPaint() }
                        function onDeathBurnChanged() { meltCanvas.requestPaint() }
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.clearRect(0, 0, width, height)

                        var pMelt = frameWin.deathMelt
                        if (pMelt >= 0.99) return

                        var burn = frameWin.deathBurn
                        var topY = height * pMelt

                        ctx.fillStyle = "#020712"
                        ctx.strokeStyle = "rgba(0, 240, 255, " + (Math.max(0.15, burn) * 0.95).toFixed(2) + ")"
                        ctx.lineWidth = 3

                        ctx.beginPath()
                        ctx.moveTo(0, height)
                        ctx.lineTo(0, topY)

                        var dripsCount = 12
                        var segW = width / dripsCount
                        for (var i = 0; i < dripsCount; i++) {
                            var x0 = i * segW
                            var xMid = x0 + segW * 0.5
                            var x1 = (i + 1) * segW

                            var droopFactor = ((i * 47) % 60) + 15
                            var droopY = topY + droopFactor * Math.sin(pMelt * Math.PI) * (1.0 - pMelt * 0.6)

                            ctx.bezierCurveTo(x0 + segW * 0.2, topY, xMid - segW * 0.2, droopY, xMid, droopY)
                            ctx.bezierCurveTo(xMid + segW * 0.2, droopY, x1 - segW * 0.2, topY, x1, topY)
                        }

                        ctx.lineTo(width, height)
                        ctx.closePath()
                        ctx.fill()
                        ctx.stroke()

                        if (burn > 0.05) {
                            ctx.strokeStyle = "rgba(255, 255, 255, " + (burn * 0.9).toFixed(2) + ")"
                            ctx.lineWidth = 1.8
                            ctx.beginPath()
                            ctx.moveTo(0, topY)
                            for (var j = 0; j < dripsCount; j++) {
                                var x0b = j * segW
                                var xMidb = x0b + segW * 0.5
                                var x1b = (j + 1) * segW
                                var droopFactorB = ((j * 47) % 60) + 15
                                var droopYB = topY + droopFactorB * Math.sin(pMelt * Math.PI) * (1.0 - pMelt * 0.6)
                                ctx.bezierCurveTo(x0b + segW * 0.2, topY, xMidb - segW * 0.2, droopYB, xMidb, droopYB)
                                ctx.bezierCurveTo(xMidb + segW * 0.2, droopYB, x1b - segW * 0.2, topY, x1b, topY)
                            }
                            ctx.stroke()
                        }
                    }
                }

                Canvas {
                    id: smokeCanvas
                    x: -30
                    y: -80
                    width: parent.width + 60
                    height: parent.height + 90
                    antialiasing: true

                    Connections {
                        target: frameWin
                        function onDeathSmokeChanged() { smokeCanvas.requestPaint() }
                        function onDeathMeltChanged() { smokeCanvas.requestPaint() }
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.clearRect(0, 0, width, height)

                        var p = frameWin.deathSmoke
                        if (p <= 0.01 || p >= 0.99) return

                        var pMelt = frameWin.deathMelt
                        var offsetX = 30
                        var offsetY = 80

                        var tendrilCount = 10
                        var tendrilAlpha = Math.sin(p * Math.PI) * 0.45
                        if (tendrilAlpha > 0.01) {
                            for (var t = 0; t < tendrilCount; t++) {
                                var tx = offsetX + (parent.width * ((t + 0.5) / tendrilCount))
                                var meltLevel = Math.min(1.0, pMelt * 1.15)
                                var ty = offsetY + (parent.height * meltLevel)
                                var tLen = (45 + ((t * 23) % 40)) * (0.8 + p * 0.6)
                                var tCurl = Math.sin(p * 5.0 + t * 1.8) * 22

                                ctx.strokeStyle = "rgba(0, 240, 255, " + (tendrilAlpha * 0.55).toFixed(2) + ")"
                                ctx.lineWidth = 2.0
                                ctx.beginPath()
                                ctx.moveTo(tx, ty)
                                ctx.bezierCurveTo(tx + tCurl, ty - tLen * 0.4, tx - tCurl * 1.1, ty - tLen * 0.75, tx + tCurl * 0.6, ty - tLen)
                                ctx.stroke()

                                ctx.strokeStyle = "rgba(255, 255, 255, " + (tendrilAlpha * 0.70).toFixed(2) + ")"
                                ctx.lineWidth = 1.0
                                ctx.beginPath()
                                ctx.moveTo(tx, ty)
                                ctx.bezierCurveTo(tx + tCurl * 0.8, ty - tLen * 0.4, tx - tCurl * 0.9, ty - tLen * 0.75, tx + tCurl * 0.4, ty - tLen)
                                ctx.stroke()
                            }
                        }

                        var plumeCount = 16
                        for (var i = 0; i < plumeCount; i++) {
                            var spawnProg = (i % 12) / 12.0 * 0.7
                            if (p < spawnProg) continue

                            var age = (p - spawnProg) / (1.0 - spawnProg)
                            if (age >= 1.0) continue

                            var originX = offsetX + parent.width * (((i * 59) % 100) / 100.0)
                            var birthY = offsetY + parent.height * (spawnProg / 0.7)
                            var rise = age * (45 + ((i * 17) % 35))
                            var drift = Math.sin(age * 4.0 + i) * 18
                            var cx = originX + drift
                            var cy = birthY - rise

                            var rad = (20 + ((i * 13) % 18)) * (0.8 + age * 0.7)

                            var plumeAlpha = (age < 0.2) ? (age / 0.2 * 0.42) : Math.max(0.0, (1.0 - age) / 0.8 * 0.42)

                            var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, rad)
                            if (i % 2 === 0) {
                                grad.addColorStop(0.0, "rgba(255, 255, 255, " + (plumeAlpha * 0.85).toFixed(2) + ")")
                                grad.addColorStop(0.35, "rgba(0, 240, 255, " + (plumeAlpha * 0.60).toFixed(2) + ")")
                                grad.addColorStop(0.75, "rgba(20, 45, 75, " + (plumeAlpha * 0.30).toFixed(2) + ")")
                                grad.addColorStop(1.0, "rgba(10, 20, 35, 0.0)")
                            } else {
                                grad.addColorStop(0.0, "rgba(240, 248, 255, " + (plumeAlpha * 0.75).toFixed(2) + ")")
                                grad.addColorStop(0.40, "rgba(180, 215, 240, " + (plumeAlpha * 0.50).toFixed(2) + ")")
                                grad.addColorStop(0.80, "rgba(30, 45, 65, " + (plumeAlpha * 0.20).toFixed(2) + ")")
                                grad.addColorStop(1.0, "rgba(15, 25, 40, 0.0)")
                            }

                            ctx.fillStyle = grad
                            ctx.beginPath()
                            ctx.arc(cx, cy, rad, 0, Math.PI * 2)
                            ctx.fill()
                        }

                        var puddleSteamCount = 8
                        for (var s = 0; s < puddleSteamCount; s++) {
                            var pSpawn = 0.25 + (s / puddleSteamCount) * 0.5
                            if (p < pSpawn) continue

                            var pAge = (p - pSpawn) / (1.0 - pSpawn)
                            if (pAge >= 1.0) continue

                            var px = offsetX + parent.width * (0.2 + 0.6 * (s / puddleSteamCount))
                            var py = offsetY + parent.height - 10 - (pAge * 45)
                            var pDrift = Math.sin(pAge * 4.0 + s) * 12
                            var pRad = (18 + (s % 3) * 8) * (0.8 + pAge * 0.6)
                            var pAlpha = (pAge < 0.2) ? (pAge / 0.2 * 0.38) : Math.max(0.0, (1.0 - pAge) / 0.8 * 0.38)

                            var pGrad = ctx.createRadialGradient(px + pDrift, py, 0, px + pDrift, py, pRad)
                            pGrad.addColorStop(0.0, "rgba(255, 255, 255, " + (pAlpha * 0.90).toFixed(2) + ")")
                            pGrad.addColorStop(0.4, "rgba(125, 211, 252, " + (pAlpha * 0.60).toFixed(2) + ")")
                            pGrad.addColorStop(0.8, "rgba(14, 116, 144, " + (pAlpha * 0.25).toFixed(2) + ")")
                            pGrad.addColorStop(1.0, "rgba(8, 47, 73, 0.0)")

                            ctx.fillStyle = pGrad
                            ctx.beginPath()
                            ctx.arc(px + pDrift, py, pRad, 0, Math.PI * 2)
                            ctx.fill()
                        }
                    }
                }

                Item {
                    id: dripsContainer
                    anchors.fill: parent

                    Repeater {
                        model: 18
                        delegate: Item {
                            required property int index

                            readonly property real p: frameWin.deathMelt
                            readonly property real segX: parent.width * ((index + 0.5) / 18.0)
                            readonly property real originY: parent.height * (0.15 + (index % 5) * 0.16)
                            readonly property real fallSpeed: 180 + ((index * 53) % 260)
                            readonly property real gravityDist: p * fallSpeed + (p * p * 350)

                            x: segX + Math.sin(index + p * 4) * 5
                            y: Math.min(parent.height - 8, originY + gravityDist)
                            visible: y < parent.height - 4
                            opacity: Math.max(0.0, (1.0 - p) * 0.95)

                            Rectangle {
                                anchors.centerIn: parent
                                width: 4 + (index % 3)
                                height: 8 + (index % 6)
                                radius: width / 2
                                color: "#020712"
                                border.color: "#00F0FF"
                                border.width: 1

                                Rectangle {
                                    width: Math.max(2, parent.width * 0.4)
                                    height: width
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    y: 1.5
                                    radius: width / 2
                                    color: "#FFFFFF"
                                    opacity: 0.8
                                }
                            }
                        }
                    }
                }

                Item {
                    id: ashFlakesContainer
                    anchors.fill: parent

                    Repeater {
                        model: 12
                        delegate: Item {
                            required property int index

                            readonly property real p: frameWin.deathSmoke
                            readonly property real ox: parent.width * ((index * 61) % 100) / 100.0
                            readonly property real oy: parent.height * (0.25 + (index % 4) * 0.18)
                            readonly property real riseDist: p * (80 + ((index * 31) % 70))
                            readonly property real flutter: Math.sin(p * 5 + index * 1.5) * 16

                            x: ox + flutter
                            y: oy - riseDist
                            rotation: (index * 45) + (p * 360)
                            scale: 1.0 - p * 0.3
                            opacity: Math.max(0.0, (1.0 - p) * 0.70)

                            Rectangle {
                                width: 3 + (index % 3)
                                height: 3 + (index % 2)
                                radius: 1
                                color: "#0B1220"
                                border.color: (index % 2 === 0) ? "#00F0FF" : "#94A3B8"
                                border.width: 0.8
                            }
                        }
                    }
                }

                Item {
                    id: embersContainer
                    anchors.fill: parent

                    Repeater {
                        model: 12
                        delegate: Item {
                            required property int index

                            readonly property real p: frameWin.deathSmoke
                            readonly property real ox: parent.width * ((index * 53) % 100) / 100.0
                            readonly property real oy: parent.height * (p * 0.7 + 0.15)

                            x: ox + Math.cos(index * 2 + p * 6) * 15
                            y: oy - (p * (70 + ((index * 37) % 60)))
                            opacity: Math.max(0.0, (1.0 - p) * 0.85)

                            Rectangle {
                                anchors.centerIn: parent
                                width: 3 + (index % 2)
                                height: width
                                radius: width / 2
                                color: (index % 2 === 0) ? "#00F0FF" : "#FFD700"
                                border.color: "#FFFFFF"
                                border.width: 0.8
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * (0.3 + frameWin.deathMelt * 0.5)
                    height: 14 * (1.0 - frameWin.deathPuddle * 0.75)
                    radius: height / 2
                    color: "#01050F"
                    border.color: "#00F0FF"
                    border.width: Math.max(1, 1.5 * (1.0 - frameWin.deathPuddle))
                    opacity: Math.sin(Math.min(1.0, frameWin.deathPuddle) * Math.PI) * 0.90

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.7
                        height: parent.height * 0.5
                        radius: height / 2
                        color: "transparent"
                        border.color: "#4400F0FF"
                        border.width: 1
                    }
                }
            }
        }
    }
}
