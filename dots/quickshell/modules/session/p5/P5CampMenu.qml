import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Item {
    id: root

    anchors.fill: parent

    property int selectedIndex: 0
    onSelectedIndexChanged: {
        root.triggerRecoil()
    }
    property string currentSection: "main"
    property int slapIntroFrame: 0 // 0 = settled main menu; 1..8 = authentic 8-frame Ren turn & slap intro!
    property real slapProgress: 0.0
    property real slapImpactScale: 1.0
    property real slapFlashOpacity: 0.0

    onCurrentSectionChanged: {
        if (PhantomState.isP5 && PhantomState.p3SessionSection !== currentSection) {
            PhantomState.p3SessionSection = currentSection
        }
    }

    // 60fps Entrance & Recoil Motion Properties
    property real jokerEnterX: 0.0
    property real jokerEnterY: 0.0
    property real jokerEnterScale: 1.0
    property real jokerEnterRot: 0.0

    property real jokerIdleX: 0.0
    property real jokerIdleY: 0.0
    property real jokerIdleRot: 0.0

    property real jokerRecoilX: 0.0
    property real jokerRecoilY: 0.0
    property real jokerRecoilRot: 0.0

    property real commandScale: 1.0
    property real commandRot: 0.0
    property real commandFloatY: 0.0

    property real badgePopScale: 1.0
    property real badgePopRot: 0.0
    property real badgeFloatY: 0.0
    property real badgeFloatRot: 0.0

    property real starKickRot: 0.0
    property real starKickScale: 1.0
    property real starContinuousRot: 0.0
    property real starPulseScale: 1.0

    property real redSweepPos: -0.35

    FontLoader {
        id: p5HeadlineFont
        source: "../../../assets/themes/p5/fonts/Persona5RoyalHeadlineFont.ttf"
    }

    FontLoader {
        id: p5BodyFont
        source: "../../../assets/themes/p5/fonts/Arsenal-Bold.ttf"
    }

    // The 6 Menu Items positioned directly on Joker's white hand along x_diag(y) = 1142 - 436*(y/1080)
    readonly property var menuItemsData: [
        {
            key: "1",
            normImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_stats_norm.png"),
            selImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_stats_sel1.png"),
            selImg2: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_stats_sel2.png"),
            badgeImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/badge_num_01.png"),
            label: "STATS",
            sub: "View System Vitals",
            section: "stats",
            baseRot: -5.5,
            rightX: 1045,
            targetY: 172
        },
        {
            key: "2",
            normImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_config_norm.png"),
            selImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_config_sel1.png"),
            selImg2: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_config_sel2.png"),
            badgeImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/badge_num_02.png"),
            label: "CONFIG",
            sub: "Configure System & Audio",
            section: "config",
            baseRot: -5.0,
            rightX: 1010,
            targetY: 268
        },
        {
            key: "3",
            normImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_control_norm.png"),
            selImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_control_sel1.png"),
            selImg2: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_control_sel2.png"),
            badgeImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/badge_num_03.png"),
            label: "CONTROL",
            sub: "Tactical Keybinds & Rules",
            section: "control",
            baseRot: -5.2,
            rightX: 975,
            targetY: 364
        },
        {
            key: "4",
            normImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_metaverse_norm.png"),
            selImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_metaverse_sel1.png"),
            selImg2: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_metaverse_sel2.png"),
            badgeImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/badge_num_04.png"),
            label: "METAVERSE",
            sub: "Switch Themes & Eras",
            section: "palette",
            baseRot: -4.8,
            rightX: 940,
            targetY: 460
        },
        {
            key: "5",
            normImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_archive_norm.png"),
            selImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_archive_sel1.png"),
            selImg2: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_archive_sel2.png"),
            badgeImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/badge_num_05.png"),
            label: "ARCHIVE",
            sub: "Phantom Manual & Records",
            section: "archive",
            baseRot: -5.0,
            rightX: 905,
            targetY: 556
        },
        {
            key: "6",
            normImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_dispatch_norm.png"),
            selImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_dispatch_sel1.png"),
            selImg2: Qt.resolvedUrl("../../../assets/themes/p5/menu/item_dispatch_sel2.png"),
            badgeImg: Qt.resolvedUrl("../../../assets/themes/p5/menu/badge_num_06.png"),
            label: "DISPATCH",
            sub: "Session Power Commands",
            section: "dispatch",
            baseRot: -4.8,
            rightX: 870,
            targetY: 652
        }
    ]

    function triggerButtonsEntrance() {
        for (let i = 0; i < menuRepeater.count; i++) {
            const item = menuRepeater.itemAt(i)
            if (item && item.playEntrance) item.playEntrance()
        }
    }

    function openMenu() {
        currentSection = "main"
        selectedIndex = 0
        PhantomState.playSfx("open")
        slapIntroFrame = 1
        slapImpactScale = 1.0
        slapFlashOpacity = 0.0
        slapTimer.restart()
    }

    function returnToMain() {
        currentSection = "main"
        slapIntroFrame = 5
        slapImpactScale = 1.0
        slapFlashOpacity = 0.0
        slapTimer.restart()
    }

    function closeMenu() {
        slapTimer.stop()
        slapIntroFrame = 0
        PhantomState.playSfx("cancel")
        PhantomState.sessionOpen = false
    }

    function triggerRecoil() {
        selectRecoilAnim.restart()
    }

    property real subPoseSlideX: 0.0
    property real subPoseOpacity: 1.0

    ParallelAnimation {
        id: subSectionEnterAnim
        NumberAnimation { target: root; property: "subPoseSlideX"; from: 140.0; to: 0.0; duration: 260; easing.type: Easing.OutBack }
        NumberAnimation { target: root; property: "subPoseOpacity"; from: 0.0; to: 0.38; duration: 220; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "starKickScale"; from: 1.16; to: 1.0; duration: 300; easing.type: Easing.OutBack }
        NumberAnimation { target: root; property: "starKickRot"; from: -14.0; to: 0.0; duration: 300; easing.type: Easing.OutBack }
    }

    function activateIndex(idx) {
        if (idx < 0 || idx >= menuItemsData.length) return
        PhantomState.playSfx("confirm")
        const target = menuItemsData[idx]
        currentSection = target.section
        subSectionEnterAnim.restart()
    }

    function handleKey(event) {
        if (currentSection === "dispatch") {
            dispatchSection.handleKey(event)
            return
        }
        if (currentSection === "palette") {
            metaverseSection.handleKey(event)
            return
        }
        if (currentSection === "stats") {
            statsSection.handleKey(event)
            return
        }
        if (currentSection === "config") {
            configSection.handleKey(event)
            return
        }
        if (currentSection === "control") {
            controlSection.handleKey(event)
            return
        }
        if (currentSection === "archive") {
            archiveSection.handleKey(event)
            return
        }

        if (currentSection !== "main") {
            if (event.key === Qt.Key_Escape) {
                PhantomState.playSfx("cancel")
                returnToMain()
                event.accepted = true
                return
            }
            return
        }

        if (event.key === Qt.Key_Escape) {
            closeMenu()
            event.accepted = true
            return
        }

        if (event.key >= Qt.Key_1 && event.key <= Qt.Key_6) {
            const idx = event.key - Qt.Key_1
            selectedIndex = idx
            triggerRecoil()
            activateIndex(idx)
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_Up || event.key === Qt.Key_Left) {
            selectedIndex = (selectedIndex + 5) % 6
            PhantomState.playSfx("select")
            triggerRecoil()
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_Down || event.key === Qt.Key_Right) {
            selectedIndex = (selectedIndex + 1) % 6
            PhantomState.playSfx("select")
            triggerRecoil()
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            activateIndex(selectedIndex)
            event.accepted = true
            return
        }
    }

    Connections {
        target: PhantomState
        function onSessionOpenChanged() {
            if (PhantomState.sessionOpen && PhantomState.isP5) {
                root.openMenu()
            } else if (!PhantomState.sessionOpen) {
                slapTimer.stop()
                root.slapIntroFrame = 0
            }
        }
        function onP3MenuCardChanged() {
            if (PhantomState.isP5 && PhantomState.sessionOpen) {
                const idx = Math.max(0, Math.min(5, PhantomState.p3MenuCard))
                if (root.selectedIndex !== idx) {
                    root.selectedIndex = idx
                    PhantomState.playSfx("select")
                    root.triggerRecoil()
                }
            }
        }
        function onP3SessionSectionChanged() {
            if (PhantomState.isP5 && PhantomState.p3SessionSection) {
                root.currentSection = PhantomState.p3SessionSection
            }
        }
    }

    // =========================================================================
    // 60FPS HYPNOTIC BACKGROUND STAR ANIMATIONS (Joker stays 100% locked!)
    // =========================================================================
    NumberAnimation on starContinuousRot {
        running: root.visible
        loops: Animation.Infinite
        from: 0.0
        to: 360.0
        duration: 16000
    }

    SequentialAnimation on starPulseScale {
        running: root.visible
        loops: Animation.Infinite
        NumberAnimation { from: 0.90; to: 1.14; duration: 950; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1.14; to: 0.90; duration: 950; easing.type: Easing.InOutSine }
    }

    SequentialAnimation on redSweepPos {
        running: root.visible
        loops: Animation.Infinite
        NumberAnimation { from: -0.35; to: 1.15; duration: 3600; easing.type: Easing.InOutQuad }
        PauseAnimation { duration: 600 }
    }

    // =========================================================================
    // 60FPS SELECTION KICK ON STARS & BADGE (Joker stays still!)
    // =========================================================================
    ParallelAnimation {
        id: selectRecoilAnim
        SequentialAnimation {
            NumberAnimation { target: root; property: "badgePopScale"; from: 1.07; to: 1.0; duration: 160; easing.type: Easing.OutQuad }
        }
        SequentialAnimation {
            NumberAnimation { target: root; property: "starKickScale"; from: 1.10; to: 1.0; duration: 280; easing.type: Easing.OutBack }
        }
        SequentialAnimation {
            NumberAnimation { target: root; property: "starKickRot"; from: -9.0; to: 0.0; duration: 300; easing.type: Easing.OutBack }
        }
    }

    ParallelAnimation {
        id: slapImpactAnim
        NumberAnimation { target: root; property: "slapImpactScale"; from: 1.06; to: 1.0; duration: 250; easing.type: Easing.OutBack }
        NumberAnimation { target: root; property: "starKickScale"; from: 1.25; to: 1.0; duration: 350; easing.type: Easing.OutBack }
        NumberAnimation { target: root; property: "slapFlashOpacity"; from: 0.30; to: 0.0; duration: 180; easing.type: Easing.OutQuad }
    }

    Timer {
        id: slapTimer
        interval: 22
        repeat: true
        running: false
        onTriggered: {
            if (root.slapIntroFrame >= 1 && root.slapIntroFrame < 8) {
                root.slapIntroFrame++
                if (root.slapIntroFrame === 7) {
                    root.slapImpactScale = 1.03
                } else if (root.slapIntroFrame === 8) {
                    root.slapImpactScale = 1.06
                    root.slapFlashOpacity = 0.30
                }
            } else {
                stop()
                root.slapIntroFrame = 0
                slapImpactAnim.restart()
                Qt.callLater(root.triggerButtonsEntrance)
            }
        }
    }

    // Hidden Image Cache Preloader so frames 1..8 are decoded in GPU memory instantly
    Repeater {
        model: [1, 2, 3, 4, 5, 6, 7, 8]
        Image {
            visible: false
            source: Qt.resolvedUrl("../../../assets/themes/p5/menu/p5_slap_intro_" + modelData + ".png")
            asynchronous: false
            cache: true
        }
    }

    // =========================================================================
    // AUTHENTIC 8-FRAME REN TURN & SLAP INTRO OVERLAY (Pure Transparent Foreground)
    // =========================================================================
    Image {
        id: slapIntroOverlay
        anchors.fill: parent
        z: 20
        visible: root.currentSection === "main" && root.slapIntroFrame > 0
        source: root.slapIntroFrame > 0 ? Qt.resolvedUrl("../../../assets/themes/p5/menu/p5_slap_intro_" + root.slapIntroFrame + ".png") : ""
        scale: (root.slapIntroFrame >= 7) ? root.slapImpactScale : 1.0
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: true
        mipmap: false
        smooth: true
    }

    // =========================================================================
    // LAYER 1: Left Translucent Red Diagonal (Shows Live Desktop Underneath, NO Shujin!)
    // =========================================================================
    Image {
        id: leftRedTrans
        anchors.fill: parent
        z: 1
        visible: root.currentSection === "main" && root.slapIntroFrame === 0
        source: Qt.resolvedUrl("../../../assets/themes/p5/menu/p5_left_red_trans.png")
        fillMode: Image.PreserveAspectCrop
        cache: false
        mipmap: true
        smooth: true
    }

    // Subtle 60fps Phantom Diagonal Light Sweep on the Left Side
    Item {
        anchors.fill: parent
        visible: root.currentSection === "main" && root.slapIntroFrame === 0
        clip: true

        Rectangle {
            width: parent.width * 0.14
            height: parent.height * 1.6
            x: parent.width * root.redSweepPos
            y: -parent.height * 0.3
            rotation: 21.9
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.rgba(1.0, 0.15, 0.22, 0.14) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // =========================================================================
    // LAYER 2: Right Opaque Full Concentric Star Field + Live 60fps Hypnotic Stars
    // =========================================================================
    Image {
        id: rightStarsBase
        anchors.fill: parent
        z: 2
        visible: root.currentSection === "main" && root.slapIntroFrame === 0
        source: Qt.resolvedUrl("../../../assets/themes/p5/menu/p5_right_stars_base.png")
        fillMode: Image.PreserveAspectCrop
        cache: false
        mipmap: true
        smooth: true
    }

    // Live 60fps Rotating & Pulsing Concentric Star Clusters on the Right Side
    Item {
        id: liveStarField
        anchors.fill: parent
        z: 3
        visible: root.currentSection === "main" && root.slapIntroFrame === 0
        clip: true

        readonly property real scaleX: width / 1920.0
        readonly property real scaleY: height / 1080.0

        // Primary Giant Concentric Star Cluster (Center-Right behind 01..06 & MeNu: MaiN)
        Image {
            source: Qt.resolvedUrl("../../../assets/themes/p5/menu/p5_star_cluster_big.png")
            width: 1150 * liveStarField.scaleX
            height: 1150 * liveStarField.scaleY
            x: 1160 * liveStarField.scaleX
            y: 70 * liveStarField.scaleY
            rotation: root.starContinuousRot + root.starKickRot
            scale: root.starPulseScale * root.starKickScale
            mipmap: true
            smooth: true
        }

        // Secondary Counter-Rotating Concentric Star Cluster (Upper-Right behind Don't Look at ME)
        Image {
            source: Qt.resolvedUrl("../../../assets/themes/p5/menu/p5_star_cluster_big.png")
            width: 950 * liveStarField.scaleX
            height: 950 * liveStarField.scaleY
            x: 1240 * liveStarField.scaleX
            y: -240 * liveStarField.scaleY
            rotation: -root.starContinuousRot * 0.75 - root.starKickRot
            scale: (2.02 - root.starPulseScale) * root.starKickScale
            mipmap: true
            smooth: true
        }

        // Third Concentric Star Cluster (Bottom-Right Corner)
        Image {
            source: Qt.resolvedUrl("../../../assets/themes/p5/menu/p5_star_cluster_big.png")
            width: 850 * liveStarField.scaleX
            height: 850 * liveStarField.scaleY
            x: 1360 * liveStarField.scaleX
            y: 420 * liveStarField.scaleY
            rotation: root.starContinuousRot * 1.15 + root.starKickRot * 1.2
            scale: root.starPulseScale * root.starKickScale
            mipmap: true
            smooth: true
        }

        // Fourth Concentric Star Cluster (Lower-Mid Right along Joker's back)
        Image {
            source: Qt.resolvedUrl("../../../assets/themes/p5/menu/p5_star_cluster_big.png")
            width: 780 * liveStarField.scaleX
            height: 780 * liveStarField.scaleY
            x: 1040 * liveStarField.scaleX
            y: 620 * liveStarField.scaleY
            rotation: -root.starContinuousRot * 0.9 + root.starKickRot * 0.8
            scale: root.starPulseScale * root.starKickScale
            mipmap: true
            smooth: true
        }
    }

    // =========================================================================
    // LAYER 3: Stationary Crisp Top-Right Comic Badges + Authentic Ripped 01..06
    // =========================================================================
    Item {
        id: rightBadgesLayer
        anchors.fill: parent
        z: 30
        visible: root.currentSection === "main" && root.slapIntroFrame === 0

        readonly property real scaleX: width / 1920.0
        readonly property real scaleY: height / 1080.0

        // Authentic Split-Diagonal Ripped Stencil Number Badge ("01" .. "06")
        Image {
            id: authenticNumBadge
            source: root.menuItemsData[root.selectedIndex] ? root.menuItemsData[root.selectedIndex].badgeImg : ""
            x: 1446 * rightBadgesLayer.scaleX
            y: 420 * rightBadgesLayer.scaleY
            width: 328 * rightBadgesLayer.scaleX
            height: 294 * rightBadgesLayer.scaleY
            scale: root.badgePopScale
            fillMode: Image.PreserveAspectFit
            cache: false
            mipmap: true
            smooth: true
        }

        // Stationary Top-Right Comic Badges ("Don't Look at ME LiKE THAt" + "The Phantoms" + "MeNu: MaiN // SeLEct a CoMMaND")
        Image {
            source: Qt.resolvedUrl("../../../assets/themes/p5/menu/p5_static_top_badges_v3.png")
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: false
            mipmap: true
            smooth: true
        }
    }

    // =========================================================================
    // LAYER 4: Stationary Full-Body Joker (COMMAND Locked to Chest + Slap Impact!)
    // =========================================================================
    Item {
        id: jokerLayer
        anchors.fill: parent
        z: 20
        visible: root.currentSection === "main" && root.slapIntroFrame === 0
        opacity: root.slapIntroFrame === 0 ? 1.0 : 0.0
        scale: root.slapImpactScale

        readonly property real scaleX: width / 1920.0
        readonly property real scaleY: height / 1080.0

        transform: [
            Scale {
                origin.x: jokerLayer.width * 0.58
                origin.y: jokerLayer.height * 0.92
                xScale: root.jokerEnterScale
                yScale: root.jokerEnterScale
            },
            Rotation {
                origin.x: jokerLayer.width * 0.58
                origin.y: jokerLayer.height * 0.95
                angle: root.jokerEnterRot + root.jokerIdleRot + root.jokerRecoilRot
            },
            Translate {
                x: (root.jokerEnterX + root.jokerIdleX + root.jokerRecoilX) * jokerLayer.scaleX
                y: (root.jokerEnterY + root.jokerIdleY + root.jokerRecoilY) * jokerLayer.scaleY
            }
        ]

        Image {
            id: jokerBodySprite
            anchors.fill: parent
            source: Qt.resolvedUrl("../../../assets/themes/p5/menu/joker_body_with_cmd_v2.png")
            fillMode: Image.PreserveAspectCrop
            cache: false
            mipmap: true
            smooth: true
        }

        // Dynamic Sublabel under "COMMAND" on Joker's chest (exact position and style of "Use a Skill" in reference photo!)
        Item {
            id: sublabelBox
            x: parent.width * (1220 / 1920) - width * 0.5
            y: parent.height * (922 / 1080) - height * 0.5
            width: subTextMain.implicitWidth + 24
            height: subTextMain.implicitHeight + 10
            rotation: -5.5

            Repeater {
                model: [
                    { dx: -2.0, dy: 0 }, { dx: 2.0, dy: 0 },
                    { dx: 0, dy: -2.0 }, { dx: 0, dy: 2.0 },
                    { dx: -1.6, dy: -1.6 }, { dx: 1.6, dy: -1.6 },
                    { dx: -1.6, dy: 1.6 }, { dx: 1.6, dy: 1.6 },
                    { dx: -2.5, dy: 0 }, { dx: 2.5, dy: 0 },
                    { dx: 0, dy: -2.5 }, { dx: 0, dy: 2.5 },
                    { dx: -1.0, dy: -2.0 }, { dx: 1.0, dy: -2.0 },
                    { dx: -1.0, dy: 2.0 }, { dx: 1.0, dy: 2.0 }
                ]
                Text {
                    x: (parent.width - width) * 0.5 + modelData.dx
                    y: (parent.height - height) * 0.5 + modelData.dy
                    text: root.menuItemsData[root.selectedIndex] ? root.menuItemsData[root.selectedIndex].sub : ""
                    font.family: p5BodyFont.name
                    font.bold: true
                    font.italic: true
                    font.pixelSize: 23
                    color: "#000000"
                }
            }

            Text {
                id: subTextMain
                anchors.centerIn: parent
                text: root.menuItemsData[root.selectedIndex] ? root.menuItemsData[root.selectedIndex].sub : ""
                font.family: p5BodyFont.name
                font.bold: true
                font.italic: true
                font.pixelSize: 23
                color: "#ffffff"
            }
        }
    }

    // =========================================================================
    // LAYER 5: The 6 Menu Items Directly on Joker's White Hand (Staggered 60fps!)
    // =========================================================================
    Item {
        id: buttonsContainer
        anchors.fill: parent
        z: 25
        visible: root.currentSection === "main" && root.slapIntroFrame === 0
        opacity: root.slapIntroFrame === 0 ? 1.0 : 0.0

        readonly property real scaleX: width / 1920.0
        readonly property real scaleY: height / 1080.0

        Repeater {
            id: menuRepeater
            model: 6

            P5MenuItem {
                readonly property var itemData: root.menuItemsData[index]
                normalSource: itemData.normImg
                selectedSource: itemData.selImg
                selectedSource2: itemData.selImg2
                labelText: itemData.label
                subText: itemData.sub
                itemIndex: index
                isSelected: root.selectedIndex === index
                baseRotation: itemData.baseRot
                rightEdgeX: (itemData.rightX + (root.jokerEnterX + root.jokerIdleX + root.jokerRecoilX) * 0.55) * buttonsContainer.scaleX
                targetY: (itemData.targetY + (root.jokerEnterY + root.jokerIdleY + root.jokerRecoilY) * 0.55) * buttonsContainer.scaleY

                onHovered: {
                    if (root.selectedIndex !== index) {
                        root.selectedIndex = index
                        PhantomState.playSfx("select")
                        root.triggerRecoil()
                    }
                }

                onTriggered: {
                    root.activateIndex(index)
                }
            }
        }
    }

    // Screen-Slap Impact Flash Overlay
    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        opacity: root.slapFlashOpacity
        visible: opacity > 0.005
        z: 25
    }

    // Dynamic Sub-Section Joker Pose Silhouette (Shows Ren's pose when inside STATS/CONFIG/CONTROL/METAVERSE/ARCHIVE/DISPATCH!)
    Image {
        id: subSectionJokerPose
        anchors.fill: parent
        visible: false
        opacity: root.subPoseOpacity
        x: root.subPoseSlideX
        source: {
            if (root.currentSection === "stats") return Qt.resolvedUrl("../../../assets/themes/p5/menu/joker_pose_stats.png")
            if (root.currentSection === "config") return Qt.resolvedUrl("../../../assets/themes/p5/menu/joker_pose_config.png")
            if (root.currentSection === "control") return Qt.resolvedUrl("../../../assets/themes/p5/menu/joker_pose_control.png")
            if (root.currentSection === "palette") return Qt.resolvedUrl("../../../assets/themes/p5/menu/joker_pose_metaverse.png")
            if (root.currentSection === "archive") return Qt.resolvedUrl("../../../assets/themes/p5/menu/joker_pose_archive.png")
            if (root.currentSection === "dispatch") return Qt.resolvedUrl("../../../assets/themes/p5/menu/joker_pose_dispatch.png")
            return ""
        }
        fillMode: Image.PreserveAspectCrop
        mipmap: true
        smooth: true
    }

    // =========================================================================
    // LAYER 6: Sub-sections (DISPATCH, METAVERSE, STATS, CONFIG, CONTROL, ARCHIVE)
    // =========================================================================
    P5DispatchSection {
        id: dispatchSection
        anchors.fill: parent
        visible: root.currentSection === "dispatch"
        onBackToMain: root.returnToMain()
    }

    P5MetaverseSection {
        id: metaverseSection
        anchors.fill: parent
        visible: root.currentSection === "palette"
        onBackToMain: root.returnToMain()
    }

    P5StatsSection {
        id: statsSection
        anchors.fill: parent
        visible: root.currentSection === "stats"
        onBackToMain: root.returnToMain()
    }

    P5ConfigSection {
        id: configSection
        anchors.fill: parent
        visible: root.currentSection === "config"
        onBackToMain: root.returnToMain()
    }

    P5ControlSection {
        id: controlSection
        anchors.fill: parent
        visible: root.currentSection === "control"
        onBackToMain: root.returnToMain()
    }

    P5ArchiveSection {
        id: archiveSection
        anchors.fill: parent
        visible: root.currentSection === "archive"
        onBackToMain: root.returnToMain()
    }
}
