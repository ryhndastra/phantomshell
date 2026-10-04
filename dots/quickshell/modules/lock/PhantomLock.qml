import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config
import qs.components

// modul layar kunci wayland dengan autentikasi pam dan animasi transisi
Scope {
    id: lockScope

    property string currentTime: "23:45"
    property string currentDay: "SATURDAY"
    property string currentDate: "OCT 04"
    property string statusText: "ENTER PASSCODE TO INFILTRATE"
    property bool authError: false
    property bool authBusy: false
    property bool authSuccess: false
    property bool showPassword: false
    property string pendingPassword: ""

    // timer pembaruan jam dan tanggal saat layar terkunci
    Timer {
        interval: 1000
        running: PhantomState.lockOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const now = new Date()
            lockScope.currentTime = Qt.formatTime(now, "HH:mm")
            const days = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
            lockScope.currentDay = days[now.getDay()]
            const months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
            const d = now.getDate() < 10 ? "0" + now.getDate() : String(now.getDate())
            lockScope.currentDate = months[now.getMonth()] + " " + d
        }
    }

    // konteks pam untuk verifikasi kata sandi pengguna sistem
    PamContext {
        id: pam
        config: "swaylock"

        onResponseRequiredChanged: {
            if (responseRequired && lockScope.pendingPassword !== "") {
                pam.respond(lockScope.pendingPassword)
                lockScope.pendingPassword = ""
            }
        }

        onCompleted: result => {
            lockScope.authBusy = false
            if (result === PamResult.Success) {
                lockScope.authError = false
                lockScope.authSuccess = true
                lockScope.statusText = "IDENTITY VERIFIED // WELCOME BACK, JOKER"
                PhantomState.playSfx("select")
                PhantomState.unlockScreen()
            } else {
                lockScope.authError = true
                lockScope.statusText = "ACCESS DENIED // WRONG PASSCODE"
                PhantomState.playSfx("notif")
            }
        }

        onError: err => {
            lockScope.authBusy = false
            lockScope.authError = true
            lockScope.statusText = "PAM ERROR // TRY AGAIN"
        }
    }

    function submitPassword(pw) {
        if (PhantomState.lockClosing) return
        const clean = String(pw || "")
        if (clean.length === 0) {
            lockScope.authError = true
            lockScope.statusText = "PASSCODE REQUIRED"
            return
        }
        lockScope.authError = false
        lockScope.authBusy = true
        lockScope.statusText = "VERIFYING IDENTITY..."
        lockScope.pendingPassword = clean
        if (pam.active) {
            pam.abort()
        }
        const ok = pam.start()
        if (!ok) {
            lockScope.authBusy = false
            lockScope.authError = true
            lockScope.statusText = "PAM ERROR // TRY AGAIN"
            return
        }
        if (pam.responseRequired && lockScope.pendingPassword !== "") {
            pam.respond(lockScope.pendingPassword)
            lockScope.pendingPassword = ""
        }
    }

    // pengunci sesi wayland pada seluruh layar aktif
    WlSessionLock {
        id: sessionLock
        locked: PhantomState.lockOpen

        WlSessionLockSurface {
            id: lockSurface

            Item {
                id: lockRoot
                anchors.fill: parent

                property real bgOpacity: 0.0
                property real clockSlideX: -140.0
                property real clockOpacity: 0.0
                property real cardScale: 0.78
                property real cardRot: -6.5
                property real cardOpacity: 0.0
                property real shutterProgress: 1.0
                property real unlockSlashProgress: 0.0

                onShutterProgressChanged: shutterCanvas.requestPaint()
                onUnlockSlashProgressChanged: shutterCanvas.requestPaint()

                // animasi saat layar kunci dibuka
                ParallelAnimation {
                    id: lockEnterAnim
                    NumberAnimation { target: lockRoot; property: "bgOpacity"; from: 0.0; to: 1.0; duration: 340; easing.type: Easing.OutCubic }
                    NumberAnimation { target: lockRoot; property: "shutterProgress"; from: 1.0; to: 0.0; duration: 560; easing.type: Easing.OutCubic }
                    SequentialAnimation {
                        PauseAnimation { duration: 90 }
                        ParallelAnimation {
                            NumberAnimation { target: lockRoot; property: "clockSlideX"; from: -140.0; to: 0.0; duration: 460; easing.type: Easing.OutBack }
                            NumberAnimation { target: lockRoot; property: "clockOpacity"; from: 0.0; to: 1.0; duration: 340; easing.type: Easing.OutCubic }
                            NumberAnimation { target: lockRoot; property: "cardScale"; from: 0.78; to: 1.0; duration: 480; easing.type: Easing.OutBack }
                            NumberAnimation { target: lockRoot; property: "cardRot"; from: -6.5; to: 0.0; duration: 480; easing.type: Easing.OutBack }
                            NumberAnimation { target: lockRoot; property: "cardOpacity"; from: 0.0; to: 1.0; duration: 320; easing.type: Easing.OutCubic }
                        }
                    }
                }

                // animasi saat layar kunci berhasil dibuka kembali
                SequentialAnimation {
                    id: lockExitAnim
                    ParallelAnimation {
                        NumberAnimation { target: lockRoot; property: "unlockSlashProgress"; from: 0.0; to: 1.0; duration: 520; easing.type: Easing.InOutCubic }
                        SequentialAnimation {
                            NumberAnimation { target: lockRoot; property: "cardScale"; to: 1.05; duration: 130; easing.type: Easing.OutQuad }
                            ParallelAnimation {
                                NumberAnimation { target: lockRoot; property: "cardScale"; to: 0.76; duration: 360; easing.type: Easing.InBack }
                                NumberAnimation { target: lockRoot; property: "cardRot"; to: 5.5; duration: 360; easing.type: Easing.InCubic }
                                NumberAnimation { target: lockRoot; property: "cardOpacity"; to: 0.0; duration: 310; easing.type: Easing.InCubic }
                            }
                        }
                        NumberAnimation { target: lockRoot; property: "clockSlideX"; to: -160.0; duration: 380; easing.type: Easing.InBack }
                        NumberAnimation { target: lockRoot; property: "clockOpacity"; to: 0.0; duration: 300; easing.type: Easing.InCubic }
                        SequentialAnimation {
                            PauseAnimation { duration: 150 }
                            NumberAnimation { target: lockRoot; property: "bgOpacity"; to: 0.0; duration: 360; easing.type: Easing.InCubic }
                        }
                    }
                    ScriptAction {
                        script: {
                            PhantomState.lockClosing = false
                            PhantomState.lockOpen = false
                            lockScope.authSuccess = false
                            lockScope.authError = false
                            lockScope.statusText = "ENTER PASSCODE TO INFILTRATE"
                        }
                    }
                }

                Connections {
                    target: PhantomState
                    function onLockClosingChanged() {
                        if (PhantomState.lockClosing && !lockExitAnim.running) {
                            lockEnterAnim.stop()
                            lockExitAnim.restart()
                        }
                    }
                }

                // inisialisasi fokus dan mulai animasi masuk
                Component.onCompleted: {
                    lockScope.authSuccess = false
                    lockScope.authError = false
                    lockScope.statusText = "ENTER PASSCODE TO INFILTRATE"
                    pwInput.forceActiveFocus()
                    lockEnterAnim.restart()
                }

                // lapisan latar belakang wallpaper dan redup gelap
                Item {
                    anchors.fill: parent
                    opacity: lockRoot.bgOpacity

                    Rectangle {
                        anchors.fill: parent
                        color: "#07070B"
                    }

                    Image {
                        anchors.fill: parent
                        source: PhantomState.wallpaperPath ? ("file://" + PhantomState.wallpaperPath) : ""
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        opacity: 0.38
                        scale: 1.0 + (1.0 - lockRoot.bgOpacity) * 0.06
                    }

                    Rectangle {
                        id: darkOverlay
                        anchors.fill: parent
                        color: "#B807070C"
                    }

                    // aksen garis diagonal pada latar layar kunci
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var w = width
                            var h = height

                            ctx.fillStyle = Qt.rgba(PhantomState.primary.r, PhantomState.primary.g, PhantomState.primary.b, 0.16)
                            ctx.beginPath()
                            ctx.moveTo(0, h * 0.18)
                            ctx.lineTo(w, h * 0.04)
                            ctx.lineTo(w, h * 0.22)
                            ctx.lineTo(0, h * 0.42)
                            ctx.closePath()
                            ctx.fill()

                            ctx.fillStyle = Qt.rgba(PhantomState.primary.r, PhantomState.primary.g, PhantomState.primary.b, 0.11)
                            ctx.beginPath()
                            ctx.moveTo(0, h * 0.78)
                            ctx.lineTo(w, h * 0.62)
                            ctx.lineTo(w, h * 0.74)
                            ctx.lineTo(0, h * 0.92)
                            ctx.closePath()
                            ctx.fill()
                        }
                    }
                }

                // kartu jam dan tanggal di pojok kiri atas
                Item {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 42
                    anchors.leftMargin: 52
                    width: 360
                    height: 150
                    opacity: lockRoot.clockOpacity
                    transform: Translate { x: lockRoot.clockSlideX }

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: "#0B0B10"
                        borderColor: "#FFFFFF"
                        shadowColor: PhantomState.primary
                        borderWidth: 3
                        skewPx: 14
                        shadowOffsetX: 6
                        shadowOffsetY: 6
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 28
                        anchors.rightMargin: 24
                        anchors.topMargin: 14
                        anchors.bottomMargin: 14
                        spacing: 2

                        RowLayout {
                            spacing: 10
                            Rectangle {
                                width: 92
                                height: 22
                                color: PhantomState.primary
                                border.color: "#FFFFFF"
                                border.width: 1
                                rotation: -3
                                Text {
                                    anchors.centerIn: parent
                                    text: lockScope.currentDate
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                }
                            }
                            Text {
                                text: lockScope.currentDay
                                color: PhantomState.secondary
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 14
                                font.weight: Font.Black
                                font.italic: true
                            }
                        }

                        Text {
                            text: lockScope.currentTime
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 64
                            font.weight: Font.Black
                            font.italic: true
                        }
                    }
                }

                // kartu autentikasi utama di tengah layar
                Item {
                    id: centerCard
                    width: 520
                    height: 330
                    anchors.centerIn: parent
                    opacity: lockRoot.cardOpacity
                    scale: lockRoot.cardScale
                    rotation: lockRoot.cardRot

                    property real shakeOffset: 0
                    transform: Translate { x: centerCard.shakeOffset }

                    SequentialAnimation {
                        id: errorShakeAnim
                        NumberAnimation { target: centerCard; property: "shakeOffset"; to: -16; duration: 45 }
                        NumberAnimation { target: centerCard; property: "shakeOffset"; to: 16; duration: 45 }
                        NumberAnimation { target: centerCard; property: "shakeOffset"; to: -10; duration: 45 }
                        NumberAnimation { target: centerCard; property: "shakeOffset"; to: 10; duration: 45 }
                        NumberAnimation { target: centerCard; property: "shakeOffset"; to: 0; duration: 45 }
                    }

                    Connections {
                        target: lockScope
                        function onAuthErrorChanged() {
                            if (lockScope.authError) {
                                errorShakeAnim.restart()
                            }
                        }
                    }

                    P5SkewedCard {
                        anchors.fill: parent
                        fillColor: "#0D0D14"
                        borderColor: lockScope.authSuccess
                            ? PhantomState.secondary
                            : (lockScope.authError ? PhantomState.primary : "#FFFFFF")
                        shadowColor: lockScope.authSuccess
                            ? PhantomState.secondary
                            : (lockScope.authError ? "#FF0022" : PhantomState.primary)
                        borderWidth: 3
                        skewPx: 14
                        shadowOffsetX: 8
                        shadowOffsetY: 8
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 28
                        spacing: 16

                        // informasi profil pengguna dan status autentikasi
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 18

                            // bingkai foto profil pengguna
                            Item {
                                Layout.preferredWidth: 84
                                Layout.preferredHeight: 84
                                rotation: -6

                                Rectangle {
                                    x: 5; y: 6
                                    width: parent.width; height: parent.height
                                    color: lockScope.authSuccess ? PhantomState.secondary : PhantomState.primary
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: "#09090D"
                                    border.color: "#FFFFFF"
                                    border.width: 3
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: Qt.resolvedUrl("../../assets/ren.png")
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        mipmap: true
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                RowLayout {
                                    spacing: 8
                                    Rectangle {
                                        width: 118
                                        height: 22
                                        color: lockScope.authSuccess ? PhantomState.secondary : "#FFFFFF"
                                        rotation: -2
                                        Text {
                                            anchors.centerIn: parent
                                            text: lockScope.authSuccess ? "ACCESS GRANTED" : "CALLING CARD LOCK"
                                            color: "#09090D"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 10
                                            font.weight: Font.Black
                                        }
                                    }
                                    Text {
                                        text: "// VELVET SECURITY"
                                        color: PhantomState.secondary
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                        font.weight: Font.Black
                                    }
                                }

                                Text {
                                    text: PhantomState.sysHost
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 24
                                    font.weight: Font.Black
                                    font.italic: true
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: lockScope.statusText
                                    color: lockScope.authSuccess
                                        ? PhantomState.secondary
                                        : (lockScope.authError ? PhantomState.primary : PhantomState.muted)
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        // kotak input kata sandi
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 54

                            P5SkewedCard {
                                anchors.fill: parent
                                fillColor: "#161622"
                                borderColor: pwInput.activeFocus ? PhantomState.secondary : "#FFFFFF"
                                shadowColor: PhantomState.primary
                                borderWidth: 2
                                skewPx: 8
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 18
                                anchors.rightMargin: 14
                                spacing: 10

                                P5Icon {
                                    name: "lock"
                                    size: 16
                                    color: PhantomState.secondary
                                }

                                TextInput {
                                    id: pwInput
                                    Layout.fillWidth: true
                                    color: "#FFFFFF"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 16
                                    font.weight: Font.Black
                                    echoMode: lockScope.showPassword ? TextInput.Normal : TextInput.Password
                                    passwordCharacter: "★"
                                    focus: true
                                    clip: true
                                    verticalAlignment: TextInput.AlignVCenter

                                    Keys.onReturnPressed: {
                                        lockScope.submitPassword(pwInput.text)
                                        pwInput.text = ""
                                    }
                                    Keys.onEnterPressed: {
                                        lockScope.submitPassword(pwInput.text)
                                        pwInput.text = ""
                                    }
                                    Keys.onEscapePressed: {
                                        pwInput.text = ""
                                        lockScope.authError = false
                                        lockScope.statusText = "ENTER PASSCODE TO INFILTRATE"
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Type Linux password & press Enter..."
                                        color: "#6E6E82"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 12
                                        font.weight: Font.Bold
                                        visible: pwInput.text.length === 0
                                    }
                                }

                                // tombol penampil atau penyembunyi karakter kata sandi
                                Rectangle {
                                    width: 52
                                    height: 26
                                    color: showPwMouse.containsMouse ? PhantomState.primary : "#232334"
                                    border.color: "#FFFFFF"
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: lockScope.showPassword ? "HIDE" : "SHOW"
                                        color: "#FFFFFF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.weight: Font.Black
                                    }

                                    MouseArea {
                                        id: showPwMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            lockScope.showPassword = !lockScope.showPassword
                                            pwInput.forceActiveFocus()
                                        }
                                    }
                                }
                            }
                        }

                        // baris indikator baterai, volume, serta tombol suspend dan unlock
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                height: 36
                                width: 130
                                color: "#14141E"
                                border.color: "#343446"
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Text {
                                        text: "BAT " + PhantomState.batteryPct + "%"
                                        color: PhantomState.secondary
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.weight: Font.Black
                                    }
                                    Text {
                                        text: "• VOL " + PhantomState.volumePct + "%"
                                        color: "#FFFFFF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // tombol suspend langsung dari lock screen
                            Item {
                                width: 108
                                height: 40

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: suspendMouse.containsMouse ? "#252538" : "#151520"
                                    borderColor: "#FFFFFF"
                                    shadowColor: "#08080C"
                                    borderWidth: 2
                                    skewPx: 6
                                }

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    P5Icon { name: "moon"; size: 13; color: PhantomState.secondary }
                                    Text {
                                        text: "SUSPEND"
                                        color: "#FFFFFF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.weight: Font.Black
                                    }
                                }

                                MouseArea {
                                    id: suspendMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["systemctl", "suspend"])
                                }
                            }

                            // tombol submit unlock
                            Item {
                                width: 138
                                height: 42

                                P5SkewedCard {
                                    anchors.fill: parent
                                    fillColor: unlockMouse.containsMouse ? PhantomState.secondary : PhantomState.primary
                                    borderColor: "#FFFFFF"
                                    shadowColor: "#08080C"
                                    borderWidth: 2
                                    skewPx: 8
                                }

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    P5Icon {
                                        name: "star"
                                        size: 14
                                        color: unlockMouse.containsMouse ? "#09090D" : "#FFFFFF"
                                    }
                                    Text {
                                        text: lockScope.authBusy ? "WAIT..." : "UNLOCK"
                                        color: unlockMouse.containsMouse ? "#09090D" : "#FFFFFF"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 13
                                        font.weight: Font.Black
                                        font.italic: true
                                    }
                                }

                                MouseArea {
                                    id: unlockMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        lockScope.submitPassword(pwInput.text)
                                        pwInput.text = ""
                                        pwInput.forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }
                }

                // lapisan bilah tebasan diagonal saat mengunci dan membuka kunci layar
                Canvas {
                    id: shutterCanvas
                    anchors.fill: parent
                    visible: lockRoot.shutterProgress > 0.001 || lockRoot.unlockSlashProgress > 0.001

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var h = height

                        // animasi tirai diagonal saat mengunci layar
                        if (lockRoot.shutterProgress > 0.001) {
                            var sp = lockRoot.shutterProgress
                            var reach = h * 0.65 * sp

                            ctx.fillStyle = String(PhantomState.primary)
                            ctx.beginPath()
                            ctx.moveTo(0, 0)
                            ctx.lineTo(w, 0)
                            ctx.lineTo(w, reach * 0.72)
                            ctx.lineTo(0, reach * 1.15)
                            ctx.closePath()
                            ctx.fill()

                            ctx.fillStyle = "#08080C"
                            ctx.beginPath()
                            ctx.moveTo(0, 0)
                            ctx.lineTo(w, 0)
                            ctx.lineTo(w, reach * 0.54)
                            ctx.lineTo(0, reach * 0.92)
                            ctx.closePath()
                            ctx.fill()

                            ctx.fillStyle = String(PhantomState.primary)
                            ctx.beginPath()
                            ctx.moveTo(0, h - reach * 0.72)
                            ctx.lineTo(w, h - reach * 1.15)
                            ctx.lineTo(w, h)
                            ctx.lineTo(0, h)
                            ctx.closePath()
                            ctx.fill()

                            ctx.fillStyle = "#08080C"
                            ctx.beginPath()
                            ctx.moveTo(0, h - reach * 0.54)
                            ctx.lineTo(w, h - reach * 0.92)
                            ctx.lineTo(w, h)
                            ctx.lineTo(0, h)
                            ctx.closePath()
                            ctx.fill()
                        }

                        // animasi tebasan diagonal saat membuka kunci layar
                        if (lockRoot.unlockSlashProgress > 0.001) {
                            var up = lockRoot.unlockSlashProgress
                            var alpha = up < 0.5 ? (up * 2.0) : ((1.0 - up) * 2.0)
                            var bandH = Math.max(12, h * 0.16 * alpha)
                            var cy = h * 0.5

                            ctx.save()
                            ctx.globalAlpha = Math.max(0.0, Math.min(1.0, alpha))

                            ctx.fillStyle = String(PhantomState.primary)
                            ctx.beginPath()
                            ctx.moveTo(0, cy - bandH * 0.6 + h * 0.12)
                            ctx.lineTo(w * Math.min(1.0, up * 1.5), cy - bandH * 0.6 - h * 0.14)
                            ctx.lineTo(w * Math.min(1.0, up * 1.5), cy + bandH * 0.6 - h * 0.14)
                            ctx.lineTo(0, cy + bandH * 0.6 + h * 0.12)
                            ctx.closePath()
                            ctx.fill()

                            ctx.fillStyle = "#FFFFFF"
                            ctx.beginPath()
                            ctx.moveTo(0, cy - bandH * 0.18 + h * 0.12)
                            ctx.lineTo(w * Math.min(1.0, up * 1.6), cy - bandH * 0.18 - h * 0.14)
                            ctx.lineTo(w * Math.min(1.0, up * 1.6), cy + bandH * 0.18 - h * 0.14)
                            ctx.lineTo(0, cy + bandH * 0.18 + h * 0.12)
                            ctx.closePath()
                            ctx.fill()

                            ctx.restore()
                        }
                    }
                }
            }
        }
    }
}
