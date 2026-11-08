import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config
import qs.components

// =============================================================================
// PERSONA 3 RELOAD: S.E.E.S. DARK HOUR PROTOCOL LOCK SCREEN
// Layar Kunci Wayland Sesi Sistem bertema S.E.E.S. Evoker Authenticator P3R
// =============================================================================
Scope {
    id: lockScope

    property string currentTime: "23:45"
    property string currentDay: "SATURDAY"
    property string currentDate: "OCT 04"
    property string statusText: "DARK HOUR DETECTED // AUTHORIZE EVOKER"
    property bool authError: false
    property bool authBusy: false
    property bool authSuccess: false
    property bool showPassword: false
    property string pendingPassword: ""

    // Timer pembaruan jam dan tanggal saat layar terkunci
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

    // Konteks PAM untuk verifikasi kata sandi pengguna sistem
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
                lockScope.statusText = "AUTHORIZATION GRANTED // PERSONA DISPATCHED"
                PhantomState.playSfx("select")
                PhantomState.unlockScreen()
            } else {
                lockScope.authError = true
                lockScope.statusText = "AUTHORIZATION REJECTED // SHADOW DETECTED"
                PhantomState.playSfx("notif")
            }
        }

        onError: err => {
            lockScope.authBusy = false
            lockScope.authError = true
            lockScope.statusText = "PAM ERROR // EVOKER OFFLINE"
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
        lockScope.statusText = "AUTHENTICATING EVOKER REGISTRATION..."
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

    // Pengunci Sesi Wayland pada Seluruh Layar Aktif
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
                property real cardScale: 0.82
                property real cardOpacity: 0.0

                // Animasi Masuk
                ParallelAnimation {
                    id: lockEnterAnim
                    NumberAnimation { target: lockRoot; property: "bgOpacity"; from: 0.0; to: 1.0; duration: 280; easing.type: Easing.OutCubic }
                    NumberAnimation { target: lockRoot; property: "clockSlideX"; from: -140.0; to: 0.0; duration: 380; easing.type: Easing.OutBack }
                    NumberAnimation { target: lockRoot; property: "clockOpacity"; from: 0.0; to: 1.0; duration: 260; easing.type: Easing.OutCubic }
                    NumberAnimation { target: lockRoot; property: "cardScale"; from: 0.82; to: 1.0; duration: 380; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
                    NumberAnimation { target: lockRoot; property: "cardOpacity"; from: 0.0; to: 1.0; duration: 240; easing.type: Easing.OutCubic }
                }

                // Animasi Keluar Saat Berhasil Terbuka
                SequentialAnimation {
                    id: lockExitAnim
                    ParallelAnimation {
                        NumberAnimation { target: lockRoot; property: "cardScale"; to: 1.08; duration: 120; easing.type: Easing.OutQuad }
                        NumberAnimation { target: lockRoot; property: "cardOpacity"; to: 0.0; duration: 260; easing.type: Easing.InCubic }
                        NumberAnimation { target: lockRoot; property: "clockSlideX"; to: -140.0; duration: 280; easing.type: Easing.InBack }
                        NumberAnimation { target: lockRoot; property: "clockOpacity"; to: 0.0; duration: 220; easing.type: Easing.InCubic }
                        NumberAnimation { target: lockRoot; property: "bgOpacity"; to: 0.0; duration: 300; easing.type: Easing.InCubic }
                    }
                    ScriptAction {
                        script: {
                            PhantomState.lockClosing = false
                            PhantomState.lockOpen = false
                            lockScope.authSuccess = false
                            lockScope.authError = false
                            lockScope.statusText = "DARK HOUR DETECTED // AUTHORIZE EVOKER"
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

                Component.onCompleted: {
                    lockScope.authSuccess = false
                    lockScope.authError = false
                    lockScope.statusText = "DARK HOUR DETECTED // AUTHORIZE EVOKER"
                    pwInput.forceActiveFocus()
                    lockEnterAnim.restart()
                }

                // 1. Lapisan Latar Belakang Dark Hour P3R
                Item {
                    anchors.fill: parent
                    opacity: lockRoot.bgOpacity

                    // Dasar Hitam Malam / Dark Hour
                    Rectangle {
                        anchors.fill: parent
                        color: "#020612"
                    }

                    // Kisi Garis Koordinat Taktikal (S.E.E.S. Operational Grid & Moon Aura)
                    Canvas {
                        anchors.fill: parent
                        antialiasing: true
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var w = width
                            var h = height

                            // Cahaya Bulan Cyan P3R (Radial Moon Aura)
                            var radGrad = ctx.createRadialGradient(w / 2, h / 2, 20, w / 2, h / 2, Math.max(w, h) * 0.65)
                            radGrad.addColorStop(0.0, "rgba(0, 219, 255, 0.16)")
                            radGrad.addColorStop(0.45, "rgba(0, 56, 168, 0.10)")
                            radGrad.addColorStop(1.0, "transparent")
                            ctx.fillStyle = radGrad
                            ctx.fillRect(0, 0, w, h)

                            ctx.strokeStyle = "rgba(0, 219, 255, 0.08)"
                            ctx.lineWidth = 1.0

                            for (var x = 80; x < w; x += 120) {
                                ctx.beginPath()
                                ctx.moveTo(x, 0)
                                ctx.lineTo(x, h)
                                ctx.stroke()
                            }
                            for (var y = 60; y < h; y += 120) {
                                ctx.beginPath()
                                ctx.moveTo(0, y)
                                ctx.lineTo(w, y)
                                ctx.stroke()
                            }

                            // Garis Miring Diagonal Dark Hour
                            ctx.strokeStyle = "rgba(0, 219, 255, 0.15)"
                            ctx.lineWidth = 2.0
                            ctx.beginPath()
                            ctx.moveTo(0, h * 0.28)
                            ctx.lineTo(w, h * 0.12)
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.moveTo(0, h * 0.88)
                            ctx.lineTo(w, h * 0.72)
                            ctx.stroke()
                        }
                    }
                }

                // 2. Kartu Jam Digital Dark Hour di Pojok Kiri Atas
                Item {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 46
                    anchors.leftMargin: 56
                    width: 380
                    height: 160
                    opacity: lockRoot.clockOpacity
                    transform: Translate { x: lockRoot.clockSlideX }

                    // Backplate Slanted Cyan
                    Canvas {
                        anchors.fill: parent
                        antialiasing: true
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var w = width
                            var h = height
                            var sk = 16.0

                            ctx.beginPath()
                            ctx.moveTo(sk, 0)
                            ctx.lineTo(w, 0)
                            ctx.lineTo(w - sk, h)
                            ctx.lineTo(0, h)
                            ctx.closePath()
                            ctx.fillStyle = "#030a1c"
                            ctx.fill()
                            ctx.strokeStyle = "#00dbff"
                            ctx.lineWidth = 2.0
                            ctx.stroke()
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 4

                        RowLayout {
                            spacing: 8
                            Rectangle {
                                width: 108
                                height: 22
                                radius: 2
                                color: "#0038a8"
                                border.color: "#00dbff"
                                border.width: 1.2
                                Text {
                                    anchors.centerIn: parent
                                    text: "DARK HOUR"
                                    color: "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 10
                                    font.weight: Font.Black
                                    font.letterSpacing: 1.2
                                }
                            }

                            Text {
                                text: "S.E.E.S. OPERATIONAL TIME"
                                color: "#00dbff"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 10
                                font.bold: true
                                font.letterSpacing: 1
                            }
                        }

                        Text {
                            text: lockScope.currentTime
                            color: "#ffffff"
                            font.family: "Rubik"
                            font.pixelSize: 64
                            font.weight: Font.Black
                            font.italic: true
                        }

                        Text {
                            text: lockScope.currentDay + " // " + lockScope.currentDate
                            color: "#7fa8d8"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }

                // 3. Kartu Autentikasi Utama S.E.E.S. di Tengah Layar
                Item {
                    id: centerCard
                    width: 540
                    height: 350
                    anchors.centerIn: parent
                    opacity: lockRoot.cardOpacity
                    scale: lockRoot.cardScale

                    property real shakeOffset: 0
                    transform: Translate { x: centerCard.shakeOffset }

                    SequentialAnimation {
                        id: errorShakeAnim
                        NumberAnimation { target: centerCard; property: "shakeOffset"; to: -16; duration: 40 }
                        NumberAnimation { target: centerCard; property: "shakeOffset"; to: 16; duration: 40 }
                        NumberAnimation { target: centerCard; property: "shakeOffset"; to: -10; duration: 40 }
                        NumberAnimation { target: centerCard; property: "shakeOffset"; to: 10; duration: 40 }
                        NumberAnimation { target: centerCard; property: "shakeOffset"; to: 0; duration: 40 }
                    }

                    Connections {
                        target: lockScope
                        function onAuthErrorChanged() {
                            if (lockScope.authError) errorShakeAnim.restart()
                        }
                    }

                    // Backplate Slanted P3R dengan Garis Neon Cyan
                    Canvas {
                        id: centerCardCanvas
                        anchors.fill: parent
                        antialiasing: true
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var w = width
                            var h = height
                            var sk = 18.0

                            // Bayangan Luar Safir
                            ctx.beginPath()
                            ctx.moveTo(sk + 5, 5)
                            ctx.lineTo(w + 5, 5)
                            ctx.lineTo(w - sk + 5, h + 5)
                            ctx.lineTo(5, h + 5)
                            ctx.closePath()
                            ctx.fillStyle = "rgba(0, 20, 60, 0.85)"
                            ctx.fill()

                            // Dasar Kartu Navy
                            ctx.beginPath()
                            ctx.moveTo(sk, 0)
                            ctx.lineTo(w, 0)
                            ctx.lineTo(w - sk, h)
                            ctx.lineTo(0, h)
                            ctx.closePath()
                            ctx.fillStyle = "#030a1c"
                            ctx.fill()

                            // Garis Tepi Neon (Hijau/Cyan Sukses, Merah Error, Biru Normal)
                            ctx.strokeStyle = lockScope.authSuccess ? "#00ffd2" : (lockScope.authError ? "#ff2a55" : "#00dbff")
                            ctx.lineWidth = 2.5
                            ctx.stroke()
                        }

                        Connections {
                            target: lockScope
                            function onAuthSuccessChanged() { centerCardCanvas.requestPaint() }
                            function onAuthErrorChanged() { centerCardCanvas.requestPaint() }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 26
                        spacing: 16

                        // Profil Operatif S.E.E.S.
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16

                            // Foto Profil Karakter Persona 3 (Makoto Yuki)
                            Item {
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 80

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: "#071228"
                                    border.color: lockScope.authSuccess ? "#00ffd2" : (lockScope.authError ? "#ff2a55" : "#00dbff")
                                    border.width: 2
                                    clip: true

                                    Image {
                                        anchors.fill: parent
                                        source: Qt.resolvedUrl("../../assets/themes/p3/ui/char_leader.png")
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                    }
                                }
                            }

                            // Identitas dan Status Operatif
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                RowLayout {
                                    spacing: 8
                                    Rectangle {
                                        width: 82
                                        height: 20
                                        radius: 2
                                        color: lockScope.authSuccess ? "#00ffd2" : (lockScope.authError ? "#ff2a55" : "#0038a8")
                                        Text {
                                            anchors.centerIn: parent
                                            text: "S.E.E.S."
                                            color: lockScope.authSuccess ? "#030818" : "#ffffff"
                                            font.family: "Rubik"
                                            font.pixelSize: 10
                                            font.weight: Font.Black
                                            font.letterSpacing: 1.5
                                        }
                                    }

                                    Text {
                                        text: "// SPECIALIZED EXECUTION SQUAD"
                                        color: "#00dbff"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }

                                Text {
                                    text: "OPERATIVE // " + String(PhantomState.sysHost).toUpperCase()
                                    color: "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 20
                                    font.weight: Font.Black
                                    font.letterSpacing: 1
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: lockScope.statusText
                                    color: lockScope.authSuccess
                                        ? "#00ffd2"
                                        : (lockScope.authError ? "#ff2a55" : "#7fa8d8")
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        // Kotak Input Kata Sandi Slanted P3R
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: "#07132c"
                                border.color: pwInput.activeFocus ? "#00dbff" : "#1a2c4e"
                                border.width: 1.8

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 12
                                    spacing: 10

                                    Text {
                                        text: "🗝"
                                        font.pixelSize: 15
                                    }

                                    TextInput {
                                        id: pwInput
                                        Layout.fillWidth: true
                                        color: "#ffffff"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        echoMode: lockScope.showPassword ? TextInput.Normal : TextInput.Password
                                        passwordCharacter: "●"
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
                                            lockScope.statusText = "DARK HOUR DETECTED // AUTHORIZE EVOKER"
                                        }

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "Enter Evoker Authorization Passcode..."
                                            color: "#3f5c84"
                                            font.family: "JetBrainsMono NFM"
                                            font.pixelSize: 12
                                            font.bold: true
                                            visible: pwInput.text.length === 0
                                        }
                                    }

                                    // Tombol Show/Hide Passcode
                                    Rectangle {
                                        width: 54
                                        height: 26
                                        radius: 3
                                        color: showPwMouse.containsMouse ? "#0038a8" : "#0d1f42"
                                        border.color: "#00dbff"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: lockScope.showPassword ? "HIDE" : "SHOW"
                                            color: "#ffffff"
                                            font.family: "Rubik"
                                            font.pixelSize: 9
                                            font.bold: true
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
                        }

                        // Baris Informasi Baterai & Tombol Aksi
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                height: 36
                                Layout.fillWidth: true
                                radius: 3
                                color: "#061226"
                                border.color: "#182a4c"
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Text {
                                        text: "⚡ BAT " + PhantomState.batteryPct + "%"
                                        color: "#00dbff"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                    Text {
                                        text: "• " + PhantomState.sysHost
                                        color: "#54749f"
                                        font.family: "JetBrainsMono NFM"
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            // Tombol DISPATCH / AUTHORIZE
                            Rectangle {
                                height: 36
                                Layout.preferredWidth: 150
                                radius: 3
                                color: submitMouse.containsMouse ? "#00e5ff" : "#0038a8"
                                border.color: "#00dbff"
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "DISPATCH ➔"
                                    color: submitMouse.containsMouse ? "#030818" : "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                    font.letterSpacing: 1
                                }

                                MouseArea {
                                    id: submitMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        lockScope.submitPassword(pwInput.text)
                                        pwInput.text = ""
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
