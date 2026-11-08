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

        // bingkai layar opsional + efek transisi tebasan diagonal ala persona 5 waktu ganti tema / wallpaper
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
                // Tahap 1: Semburan air menerjang ke depan hingga mentok (Forward: Frame 0 -> 11, ~320ms)
                NumberAnimation {
                    target: frameWin
                    property: "p3SplashProg"
                    from: 0.0
                    to: 11.0
                    duration: 320
                    easing.type: Easing.InQuad
                }
                // Titik Puncak: Layar tertutup air 100% penuh -> Ganti tema di balik tirai air
                ScriptAction {
                    script: {
                        if (PhantomState.pendingPresetId) {
                            PhantomState.commitPresetApply(PhantomState.pendingPresetId, PhantomState.pendingSkipSave)
                            PhantomState.pendingPresetId = ""
                        }
                    }
                }
                PauseAnimation { duration: 50 } // Tahan 50ms saat deburan ombak membentur mentok
                // Tahap 2: Air surut / di-reverse kembali secara mulus (Reverse: Frame 11 -> 0, ~360ms)
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

            // ==========================================
            // P3 RELOAD AMBUSH / DUAL KATANA SLASH & CRYSTAL SHATTER
            // ==========================================
            property bool p3AmbushActive: false
            property real p3SlashTrail1: 0.0
            property real p3SlashTrail2: 0.0
            property real p3ImpactFlare: 0.0
            property real p3ShardProg: 0.0
            property real p3FlashAlpha: 0.0
            property real p3RippleScale: 0.0

            SequentialAnimation {
                id: p3AmbushAnim

                // Tahap 1: Tebasan Ganda Menyilang (Katana Dual Cross-Slash, 220ms)
                ParallelAnimation {
                    // Sabetan 1 (Kiri-Atas ke Kanan-Bawah)
                    NumberAnimation {
                        target: frameWin
                        property: "p3SlashTrail1"
                        from: 0.0
                        to: 1.0
                        duration: 190
                        easing.type: Easing.OutQuad
                    }
                    // Sabetan 2 (Kanan-Atas ke Kiri-Bawah, sedikit offset)
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

                // Titik Tabrakan / Impact Silang: Wallpaper berganti di balik kilatan cahaya putih & cyan!
                ScriptAction {
                    script: {
                        frameWin.p3FlashAlpha = 0.90
                        PhantomState.commitPendingWallpaper()
                    }
                }

                // Tahap 2: Ledakan Kristal Es & Kaca, Bintang Flare, dan Semburan Air (~700ms)
                ParallelAnimation {
                    // Flash menyala lalu melarut lembut
                    NumberAnimation {
                        target: frameWin
                        property: "p3FlashAlpha"
                        from: 0.90
                        to: 0.0
                        duration: 320
                        easing.type: Easing.OutQuad
                    }
                    // Flare bintang di titik potong memuai dan memudar
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
                    // 54 Shards kristal kaca & es meledak ke segala penjuru
                    NumberAnimation {
                        target: frameWin
                        property: "p3ShardProg"
                        from: 0.0
                        to: 1.0
                        duration: 680
                        easing.type: Easing.OutCubic
                    }
                    // Cincin gelombang kejut air meluas
                    NumberAnimation {
                        target: frameWin
                        property: "p3RippleScale"
                        from: 0.0
                        to: 1.0
                        duration: 600
                        easing.type: Easing.OutQuad
                    }
                    // Ekor energi kedua tebasan memudar dan melarut
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

                // Selesai: Reset state
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

            // ==========================================
            // P3 RELOAD SHADOW DEATH / APP CLOSE (MELELEH & HANGUS)
            // ==========================================
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

                // Tahap 1: Hangus terbakar seketika (Char & Sizzle windup, 60ms)
                ParallelAnimation {
                    NumberAnimation {
                        target: frameWin
                        property: "deathBurn"
                        from: 0.0
                        to: 1.0
                        duration: 60
                        easing.type: Easing.OutQuad
                    }
                }

                // Sfx desis hangus
                ScriptAction {
                    script: {
                        PhantomState.playSfx("select")
                    }
                }

                // Tahap 2: Meleleh runtuh ke bawah, tetesan cairan jatuh, asap tebal & abu membubung (~720ms)
                ParallelAnimation {
                    // Tubuh jendela mencair dan runtuh ke bawah
                    NumberAnimation {
                        target: frameWin
                        property: "deathMelt"
                        from: 0.0
                        to: 1.0
                        duration: 480
                        easing.type: Easing.InQuad
                    }
                    // Efek bara api dan nyala desis perlahan mereda
                    NumberAnimation {
                        target: frameWin
                        property: "deathBurn"
                        from: 1.0
                        to: 0.0
                        duration: 420
                        easing.type: Easing.OutQuad
                    }
                    // Genangan cairan hitam di lantai memuai lalu mendidih & menguap
                    SequentialAnimation {
                        PauseAnimation { duration: 100 }
                        NumberAnimation {
                            target: frameWin
                            property: "deathPuddle"
                            from: 0.0
                            to: 1.0
                            duration: 460
                            easing.type: Easing.OutQuad
                        }
                    }
                    // Asap hangus tebal & uap jiwa membubung tinggi, bergulung, lalu memudar perlahan
                    NumberAnimation {
                        target: frameWin
                        property: "deathSmoke"
                        from: 0.0
                        to: 1.0
                        duration: 720
                        easing.type: Easing.OutCubic
                    }
                }

                // Selesai
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
                frameWin.deathBurn = 0.0
                frameWin.deathPuddle = 0.0
                frameWin.deathSmoke = 0.0
                frameWin.p3DeathActive = true
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

                    // strip garis batas tepi luar layar
                    ctx.fillRect(0, 0, w, t)
                    ctx.fillRect(0, h - t, w, t)
                    ctx.fillRect(0, t, t, h - t * 2)
                    ctx.fillRect(w - t, t, t, h - t * 2)

                    // potongan segitiga di keempat sudut dalam
                    ctx.beginPath()
                    ctx.moveTo(t, t); ctx.lineTo(t + c, t); ctx.lineTo(t, t + c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(w - t, t); ctx.lineTo(w - t - c, t); ctx.lineTo(w - t, t + c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(w - t, h - t); ctx.lineTo(w - t - c, h - t); ctx.lineTo(w - t, h - t - c); ctx.closePath(); ctx.fill()

                    ctx.beginPath()
                    ctx.moveTo(t, h - t); ctx.lineTo(t + c, h - t); ctx.lineTo(t, h - t - c); ctx.closePath(); ctx.fill()

                    // garis aksen di sepanjang tepi dalam bingkai
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

            // atmosfer dan indikator pasif saat berada di dalam velvet room (special workspace)
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

                // Garis aksen biru laut velvet di sudut kanan atas
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

                // Kartu panduan di tengah layar apabila belum ada jendela di dalam special workspace
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

                        // Dial Velvet Room
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

                // Lencana status velvet room di sudut kanan bawah layar
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

            // overlay transisi velvet room (special workspace) ala Persona 3 Reload Sea of Soul
            Item {
                id: velvetSlashOverlay
                anchors.fill: parent
                visible: frameWin.velvetSlashProg < 0.995
                clip: true

                // Latar belakang sapphire / velvet navy
                Rectangle {
                    anchors.fill: parent
                    color: "#030A1E"
                    opacity: Math.sin(frameWin.velvetSlashProg * Math.PI) * 0.75
                }

                // Efek tirai cahaya horizontal sapphire & cyan
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

                // Ring aperture / dial elevator velvet room
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

                // Kartu status banner velvet room di tengah layar
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

                        // Dial emblem velvet room berputar
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

            // overlay animasi tebasan diagonal & banner waktu ganti tema (Persona 5 & tema lainnya)
            Item {
                id: slashOverlay
                anchors.fill: parent
                visible: frameWin.slashProg < 0.995 && PhantomState.themeId !== "p3-reload"
                clip: true

                // kilatan tipis warna tema di awal transisi
                Rectangle {
                    anchors.fill: parent
                    color: PhantomState.primary
                    opacity: Math.max(0.0, (1.0 - frameWin.slashProg) * 0.16)
                }

                // pita tebasan diagonal miring dari kiri ke kanan
                Item {
                    anchors.centerIn: parent
                    width: parent.width * 1.6
                    height: 220
                    rotation: -13

                    // pita aksen warna sekunder
                    Rectangle {
                        width: parent.width * 0.55
                        height: 28
                        y: 16
                        x: -width + (parent.width + width) * frameWin.slashProg
                        color: PhantomState.secondary
                        border.color: "#05060A"
                        border.width: 2
                    }

                    // pita tebasan utama warna primer
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

                    // pita tebasan putih di bagian bawah
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

                // kartu banner indikator transisi di tengah layar
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

            // Efek transisi semburan air / water splash cel-shaded Persona 3 Reload (12 frame PNG)
            Item {
                id: p3SplashOverlay
                anchors.fill: parent
                visible: frameWin.p3SplashActive
                z: 100

                // 1. Lapisan samudra biru pekat P3R (Sea of Soul) menutup 100% layar tanpa celah
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

                // 2. Berkas cahaya matahari dan caustics bawah air
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

                // 3. Gelembung udara spekular berombak naik dari bawah
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

                // 4. Hero Semburan Air Autentik P3R (Scaled 1.25x agar semburan dan buih melebar menembus sisi)
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

                // 5. Percikan air sekunder kiri & kanan (mirrored) untuk mengisi sudut samping secara organik
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

            // ==========================================
            // OVERLAY AMBUSH KATANA SLASH & KRISTAL AIR PERSONA 3 RELOAD
            // ==========================================
            Item {
                id: p3AmbushOverlay
                anchors.fill: parent
                visible: frameWin.p3AmbushActive
                z: 110

                // 1. Kilatan Cahaya Cyan-Putih Saat Benturan
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

                // 2. Riak Gelombang Kejut Air Melingkar & Diamond P3R
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

                // Cincin Diamond Kejut Konsentris P3R
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

                // 3. Garis Busur Tebasan Ganda Silang (Dual Cross Katana Slash) & Central Starburst Flare
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

                        // Layer 1: Outer Neon Cyan Aura Glow
                        ctx.strokeStyle = "rgba(0, 240, 255, " + (alpha * 0.65).toFixed(2) + ")"
                        ctx.lineWidth = 32 * (1.0 - tStart * 0.5)
                        buildBladePath()
                        ctx.stroke()

                        // Layer 2: Mid Ocean Cyan Blade Edge
                        ctx.strokeStyle = "rgba(0, 180, 216, " + (alpha * 0.88).toFixed(2) + ")"
                        ctx.lineWidth = 16 * (1.0 - tStart * 0.5)
                        buildBladePath()
                        ctx.stroke()

                        // Layer 3: Piercing White Core Edge
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

                        // Sabetan 1: Kiri-Atas ke Kanan-Bawah
                        drawBlade(ctx, frameWin.p3SlashTrail1, -100, height * 0.12, width * 0.50, height * 0.50, width + 100, height * 0.88)

                        // Sabetan 2: Kanan-Atas ke Kiri-Bawah (Menyilang X)
                        drawBlade(ctx, frameWin.p3SlashTrail2, width + 100, height * 0.14, width * 0.50, height * 0.50, -100, height * 0.86)

                        // Kilau Bintang Starburst Flare di Titik Tabrakan Tengah
                        var flare = frameWin.p3ImpactFlare
                        if (flare > 0.01) {
                            // Radial core halo
                            var radGrd = ctx.createRadialGradient(midX, midY, 0, midX, midY, 160 * flare)
                            radGrd.addColorStop(0.0, "rgba(255, 255, 255, " + (flare * 0.98).toFixed(2) + ")")
                            radGrd.addColorStop(0.35, "rgba(0, 240, 255, " + (flare * 0.75).toFixed(2) + ")")
                            radGrd.addColorStop(1.0, "rgba(0, 240, 255, 0.0)")
                            ctx.fillStyle = radGrd
                            ctx.beginPath()
                            ctx.arc(midX, midY, 160 * flare, 0, Math.PI * 2)
                            ctx.fill()

                            // Horizontal beam diamond
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

                            // Vertical beam diamond
                            var vLen = height * 0.48 * flare
                            var vW = 15 * flare
                            ctx.beginPath()
                            ctx.moveTo(midX, midY - vLen)
                            ctx.lineTo(midX + vW, midY)
                            ctx.lineTo(midX, midY + vLen)
                            ctx.lineTo(midX - vW, midY)
                            ctx.closePath()
                            ctx.fill()

                            // Diagonal cross spikes (45 derajat)
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

                // 4. Serpihan Kristal Kaca & Es Biru Laut (54 High-Fidelity Crystalline Shards)
                // Hanya muncul setelah titik tabrakan / impact (p3ShardProg > 0)
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

                            // Variasi Bentuk Kristal:
                            // index%5: 0=Needle Sliver, 1=Diamond Rhombus, 2=Sharp Wedge, 3=Crystal Chip, 4=Giant Impact Chunk
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

                                // Facet spekular kristal es
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

                // 5. Gelembung & Cipratan Air (36 Specular Bubbles)
                // Hanya muncul setelah titik tabrakan / impact
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

                // 1. Kanvas Meleleh (Dripping Fluid Mass)
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

                        // Tubuh bayangan hitam pekat
                        ctx.fillStyle = "#020712"
                        ctx.strokeStyle = "rgba(0, 240, 255, " + (Math.max(0.15, burn) * 0.95).toFixed(2) + ")"
                        ctx.lineWidth = 3

                        ctx.beginPath()
                        ctx.moveTo(0, height)
                        ctx.lineTo(0, topY)

                        // Gelombang lelehan cairan kental (viscous dripping waves)
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

                        // Lapisan bara putih membara di garis tepi lelehan
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

                // 2. Kanvas Asap Tebal Bergulung & Sulur Uap Jiwa (Cascading Volumetric Smoke Canvas)
                Canvas {
                    id: smokeCanvas
                    x: -160
                    y: -320
                    width: parent.width + 320
                    height: parent.height + 360
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
                        if (p <= 0.005 || p >= 0.995) return

                        var pMelt = frameWin.deathMelt
                        var offsetX = 160
                        var offsetY = 320

                        // A. Sulur-sulur asap hangus & uap tajam meliuk ke atas (Searing Smoke Wisps)
                        var tendrilCount = 24
                        var tendrilAlpha = Math.sin(Math.min(1.0, p * 1.3) * Math.PI) * (1.0 - p * 0.3)
                        if (tendrilAlpha > 0.02) {
                            for (var t = 0; t < tendrilCount; t++) {
                                var tx = offsetX + (parent.width * ((t + 0.5) / tendrilCount))
                                var meltLevel = Math.min(1.0, pMelt * 1.25)
                                var ty = offsetY + (parent.height * meltLevel)
                                var tLen = (140 + ((t * 43) % 180)) * (0.8 + p * 1.5)
                                var tCurl = Math.sin(p * 5.0 + t * 1.5) * 55

                                ctx.strokeStyle = "rgba(0, 240, 255, " + (tendrilAlpha * 0.85).toFixed(2) + ")"
                                ctx.lineWidth = 4.8
                                ctx.beginPath()
                                ctx.moveTo(tx, ty)
                                ctx.bezierCurveTo(tx + tCurl, ty - tLen * 0.4, tx - tCurl * 1.2, ty - tLen * 0.75, tx + tCurl * 0.7, ty - tLen)
                                ctx.stroke()

                                ctx.strokeStyle = "rgba(255, 255, 255, " + (tendrilAlpha * 0.95).toFixed(2) + ")"
                                ctx.lineWidth = 2.2
                                ctx.beginPath()
                                ctx.moveTo(tx, ty)
                                ctx.bezierCurveTo(tx + tCurl * 0.8, ty - tLen * 0.4, tx - tCurl, ty - tLen * 0.75, tx + tCurl * 0.5, ty - tLen)
                                ctx.stroke()
                            }
                        }

                        // B. Gumpalan Asap Tebal Bergulung Bersusun (Cascading Volumetric Smoke Clouds)
                        // Asap lahir seiring garis lelehan turun dari atas ke bawah (Dynamic Wavefront Emission)
                        var plumeCount = 48
                        for (var i = 0; i < plumeCount; i++) {
                            var spawnProg = (i % 30) / 30.0 * 0.65
                            if (p < spawnProg) continue

                            var age = (p - spawnProg) / (1.0 - spawnProg)
                            if (age >= 1.0) continue

                            var originX = offsetX + parent.width * (((i * 47) % 100) / 100.0)
                            var birthY = offsetY + parent.height * (spawnProg / 0.65)
                            var rise = age * (220 + ((i * 37) % 260))
                            var drift = Math.sin(age * 4.2 + i * 1.3) * (50 + (i % 35))
                            var cx = originX + drift
                            var cy = birthY - rise

                            // Radius awan memuai besar seiring membubung (starts 90px -> expands to 280px+)
                            var rad = (85 + ((i * 31) % 75)) * (0.85 + age * 2.2)

                            // Kepekatan tinggi: cepat pekat (0.95), tahan lama, lalu menguap halus
                            var plumeAlpha = (age < 0.14) ? (age / 0.14) : ((age <= 0.62) ? 0.95 : Math.max(0.0, (1.0 - age) / 0.38 * 0.95))

                            var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, rad)
                            var variant = i % 3
                            if (variant === 0) {
                                // Tartarus Cyan & Searing White Core (Jiwa Bayangan Terbakar)
                                grad.addColorStop(0.0, "rgba(255, 255, 255, " + (plumeAlpha * 0.95).toFixed(2) + ")")
                                grad.addColorStop(0.32, "rgba(0, 240, 255, " + (plumeAlpha * 0.85).toFixed(2) + ")")
                                grad.addColorStop(0.70, "rgba(15, 38, 65, " + (plumeAlpha * 0.65).toFixed(2) + ")")
                                grad.addColorStop(1.0, "rgba(8, 20, 35, 0.0)")
                            } else if (variant === 1) {
                                // Searing Silver-Ash Smoke (Awan Asap Abu Panas)
                                grad.addColorStop(0.0, "rgba(255, 255, 255, " + (plumeAlpha * 0.95).toFixed(2) + ")")
                                grad.addColorStop(0.36, "rgba(195, 220, 245, " + (plumeAlpha * 0.80).toFixed(2) + ")")
                                grad.addColorStop(0.72, "rgba(30, 50, 75, " + (plumeAlpha * 0.60).toFixed(2) + ")")
                                grad.addColorStop(1.0, "rgba(12, 22, 35, 0.0)")
                            } else {
                                // Scorched Charcoal Volumetric Billow (Gumpalan Arang Hangus Pekat)
                                grad.addColorStop(0.0, "rgba(180, 215, 245, " + (plumeAlpha * 0.88).toFixed(2) + ")")
                                grad.addColorStop(0.40, "rgba(38, 62, 92, " + (plumeAlpha * 0.85).toFixed(2) + ")")
                                grad.addColorStop(0.76, "rgba(12, 20, 32, " + (plumeAlpha * 0.60).toFixed(2) + ")")
                                grad.addColorStop(1.0, "rgba(5, 10, 18, 0.0)")
                            }

                            ctx.fillStyle = grad
                            ctx.beginPath()
                            ctx.arc(cx, cy, rad, 0, Math.PI * 2)
                            ctx.fill()
                        }

                        // C. Kepulan Uap Panas Mendidih dari Genangan Lantai (Boiling Floor Puddle Steam Plumes)
                        var puddleSteamCount = 20
                        for (var s = 0; s < puddleSteamCount; s++) {
                            var pSpawn = 0.15 + (s / puddleSteamCount) * 0.55
                            if (p < pSpawn) continue

                            var pAge = (p - pSpawn) / (1.0 - pSpawn)
                            if (pAge >= 1.0) continue

                            var px = offsetX + parent.width * (0.08 + 0.84 * (s / puddleSteamCount))
                            var py = offsetY + parent.height - 15 - (pAge * (180 + ((s * 33) % 200)))
                            var pDrift = Math.sin(pAge * 4.8 + s) * 35
                            var pRad = (90 + (s % 5) * 22) * (0.75 + pAge * 2.0)
                            var pAlpha = (pAge < 0.12) ? (pAge / 0.12) : ((pAge <= 0.60) ? 0.96 : Math.max(0.0, (1.0 - pAge) / 0.40 * 0.96))

                            var pGrad = ctx.createRadialGradient(px + pDrift, py, 0, px + pDrift, py, pRad)
                            pGrad.addColorStop(0.0, "rgba(255, 255, 255, " + (pAlpha * 0.98).toFixed(2) + ")")
                            pGrad.addColorStop(0.35, "rgba(125, 211, 252, " + (pAlpha * 0.88).toFixed(2) + ")")
                            pGrad.addColorStop(0.70, "rgba(14, 116, 144, " + (pAlpha * 0.60).toFixed(2) + ")")
                            pGrad.addColorStop(1.0, "rgba(8, 47, 73, 0.0)")

                            ctx.fillStyle = pGrad
                            ctx.beginPath()
                            ctx.arc(px + pDrift, py, pRad, 0, Math.PI * 2)
                            ctx.fill()
                        }
                    }
                }

                // 3. Tetesan Cairan Hitam Kental yang Jatuh ke Bawah (Dripping Fluid Droplets)
                Item {
                    id: dripsContainer
                    anchors.fill: parent

                    Repeater {
                        model: 24
                        delegate: Item {
                            required property int index

                            readonly property real p: frameWin.deathMelt
                            readonly property real segX: parent.width * ((index + 0.5) / 24.0)
                            readonly property real originY: parent.height * (0.15 + (index % 5) * 0.16)
                            readonly property real fallSpeed: 180 + ((index * 53) % 260)
                            readonly property real gravityDist: p * fallSpeed + (p * p * 350)

                            x: segX + Math.sin(index + p * 4) * 6
                            y: Math.min(parent.height - 8, originY + gravityDist)
                            visible: p > 0.05 && y < parent.height - 4
                            opacity: Math.max(0.0, (1.0 - p) * 0.95)

                            Rectangle {
                                anchors.centerIn: parent
                                width: 5 + (index % 4)
                                height: 10 + (index % 8)
                                radius: width / 2
                                color: "#020712"
                                border.color: "#00F0FF"
                                border.width: 1

                                Rectangle {
                                    width: Math.max(2, parent.width * 0.4)
                                    height: width
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    y: 2
                                    radius: width / 2
                                    color: "#FFFFFF"
                                    opacity: 0.8
                                }
                            }
                        }
                    }
                }

                // 4. Serpihan Abu Gosong Melayang (32 Drifting Charred Ash Flakes)
                Item {
                    id: ashFlakesContainer
                    anchors.fill: parent

                    Repeater {
                        model: 32
                        delegate: Item {
                            required property int index

                            readonly property real p: frameWin.deathSmoke
                            readonly property real ox: parent.width * ((index * 41) % 100) / 100.0
                            readonly property real oy: parent.height * (0.25 + (index % 5) * 0.16)
                            readonly property real riseDist: p * (260 + ((index * 47) % 280))
                            readonly property real flutter: Math.sin(p * 6 + index * 1.7) * (38 + (index % 22))

                            x: ox + flutter
                            y: oy - riseDist
                            rotation: (index * 45) + (p * 480)
                            scale: 1.0 - p * 0.35
                            opacity: Math.max(0.0, (1.0 - p * 0.9) * 0.95)

                            Rectangle {
                                width: 5 + (index % 5)
                                height: 4 + (index % 4)
                                radius: 1
                                color: "#0B1220"
                                border.color: (index % 3 === 0) ? "#00F0FF" : ((index % 3 === 1) ? "#F59E0B" : "#94A3B8")
                                border.width: 1
                            }
                        }
                    }
                }

                // 5. Bara Api Hangus Sizzling Embers (Percikan Bara Api yang Menguap)
                Item {
                    id: embersContainer
                    anchors.fill: parent

                    Repeater {
                        model: 30
                        delegate: Item {
                            required property int index

                            readonly property real p: frameWin.deathSmoke
                            readonly property real ox: parent.width * ((index * 47) % 100) / 100.0
                            readonly property real oy: parent.height * (p * 0.7 + 0.15)

                            x: ox + Math.cos(index * 2 + p * 7) * (25 + (index % 15))
                            y: oy - (p * (220 + ((index * 53) % 190)))
                            opacity: Math.max(0.0, (1.0 - p) * 0.95)

                            Rectangle {
                                anchors.centerIn: parent
                                width: 4 + (index % 4)
                                height: width
                                radius: width / 2
                                color: (index % 3 === 0) ? "#00F0FF" : ((index % 3 === 1) ? "#FFD700" : "#FF6B6B")
                                border.color: "#FFFFFF"
                                border.width: 1

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 2
                                    height: 2
                                    color: "#FFFFFF"
                                }
                            }
                        }
                    }
                }

                // 6. Genangan Hitam di Lantai yang Mendidih & Menguap (Boiling & Evaporating Puddle)
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * (0.35 + frameWin.deathMelt * 0.6)
                    height: 22 * (1.0 - frameWin.deathPuddle * 0.75)
                    radius: height / 2
                    color: "#01050F"
                    border.color: "#00F0FF"
                    border.width: Math.max(1, 2 * (1.0 - frameWin.deathPuddle))
                    opacity: Math.sin(Math.min(1.0, frameWin.deathPuddle) * Math.PI) * 0.95

                    // Gelembung desis cairan di genangan (sizzling bubble)
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.75
                        height: parent.height * 0.55
                        radius: height / 2
                        color: "transparent"
                        border.color: "#6600F0FF"
                        border.width: 1
                    }
                }
            }
        }
    }
}
