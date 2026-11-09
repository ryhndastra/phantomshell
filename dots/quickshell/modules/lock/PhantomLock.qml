import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config
import qs.components

// Wayland lock screen using PAM authentication and SVG icons.
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

    // Clock update timer
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

    // PAM authentication context
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
                PhantomState.unlockScreen()
            } else {
                lockScope.authError = true
                lockScope.statusText = "AUTHORIZATION REJECTED // SHADOW DETECTED"
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

    // Wayland session lock across active screens
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
                property real cardScale: 0.85
                property real cardOpacity: 0.0

                // Enter animation
                ParallelAnimation {
                    id: lockEnterAnim
                    NumberAnimation { target: lockRoot; property: "bgOpacity"; from: 0.0; to: 1.0; duration: 280; easing.type: Easing.OutCubic }
                    NumberAnimation { target: lockRoot; property: "clockSlideX"; from: -140.0; to: 0.0; duration: 360; easing.type: Easing.OutBack }
                    NumberAnimation { target: lockRoot; property: "clockOpacity"; from: 0.0; to: 1.0; duration: 260; easing.type: Easing.OutCubic }
                    NumberAnimation { target: lockRoot; property: "cardScale"; from: 0.85; to: 1.0; duration: 360; easing.type: Easing.OutBack; easing.overshoot: 1.12 }
                    NumberAnimation { target: lockRoot; property: "cardOpacity"; from: 0.0; to: 1.0; duration: 240; easing.type: Easing.OutCubic }
                }

                // Exit animation on successful unlock
                SequentialAnimation {
                    id: lockExitAnim
                    ParallelAnimation {
                        NumberAnimation { target: lockRoot; property: "cardScale"; to: 1.06; duration: 120; easing.type: Easing.OutQuad }
                        NumberAnimation { target: lockRoot; property: "cardOpacity"; to: 0.0; duration: 240; easing.type: Easing.InCubic }
                        NumberAnimation { target: lockRoot; property: "clockSlideX"; to: -140.0; duration: 260; easing.type: Easing.InBack }
                        NumberAnimation { target: lockRoot; property: "clockOpacity"; to: 0.0; duration: 200; easing.type: Easing.InCubic }
                        NumberAnimation { target: lockRoot; property: "bgOpacity"; to: 0.0; duration: 280; easing.type: Easing.InCubic }
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

                // Background layer
                Item {
                    anchors.fill: parent
                    opacity: lockRoot.bgOpacity

                    Rectangle {
                        anchors.fill: parent
                        color: "#020612"
                    }

                    Canvas {
                        anchors.fill: parent
                        antialiasing: true
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var w = width
                            var h = height

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
                        }
                    }
                }

                // Digital clock card
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 46
                    anchors.leftMargin: 56
                    width: 360
                    height: 150
                    radius: 6
                    color: "#040c26"
                    border.color: "#00dbff"
                    border.width: 1.8
                    opacity: lockRoot.clockOpacity
                    transform: Translate { x: lockRoot.clockSlideX }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 4

                        RowLayout {
                            spacing: 8
                            Rectangle {
                                width: 98
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
                                font.pixelSize: 9
                                font.bold: true
                                font.letterSpacing: 1
                            }
                        }

                        Text {
                            text: lockScope.currentTime
                            color: "#ffffff"
                            font.family: "Rubik"
                            font.pixelSize: 58
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

                // Authentication card
                Item {
                    id: centerCard
                    width: 540
                    height: 360
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

                    Canvas {
                        id: centerCardCanvas
                        anchors.fill: parent
                        antialiasing: true

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var w = width
                            var h = height

                            ctx.fillStyle = "rgba(0, 160, 255, 0.28)"
                            ctx.beginPath()
                            ctx.moveTo(w - 85, -4)
                            ctx.lineTo(w + 6, -4)
                            ctx.lineTo(w - 10, h + 4)
                            ctx.lineTo(w - 100, h + 4)
                            ctx.closePath()
                            ctx.fill()

                            var bx = 16
                            var by = 12
                            var bw = w - 32
                            var bh = h - 20
                            var r = 8

                            ctx.beginPath()
                            ctx.moveTo(bx + r, by)
                            ctx.lineTo(bx + bw - r, by)
                            ctx.quadraticCurveTo(bx + bw, by, bx + bw, by + r)
                            ctx.lineTo(bx + bw, by + bh - r)
                            ctx.quadraticCurveTo(bx + bw, by + bh, bx + bw - r, by + bh)
                            ctx.lineTo(bx + r, by + bh)
                            ctx.quadraticCurveTo(bx, by + bh, bx, by + bh - r)
                            ctx.lineTo(bx, by + r)
                            ctx.quadraticCurveTo(bx, by, bx + r, by)
                            ctx.closePath()

                            ctx.fillStyle = "rgba(4, 12, 38, 0.96)"
                            ctx.fill()

                            ctx.strokeStyle = lockScope.authSuccess ? "#00ffd2" : (lockScope.authError ? "#ff2a55" : "rgba(0, 219, 255, 0.75)")
                            ctx.lineWidth = 1.8
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.moveTo(-2, 22)
                            ctx.lineTo(165, -2)
                            ctx.lineTo(178, 24)
                            ctx.lineTo(38, 36)
                            ctx.closePath()

                            ctx.fillStyle = lockScope.authSuccess ? "#00a080" : (lockScope.authError ? "#d60032" : "#0028e0")
                            ctx.fill()
                            ctx.strokeStyle = lockScope.authSuccess ? "#00ffd2" : (lockScope.authError ? "#ffffff" : "#00f0ff")
                            ctx.lineWidth = 1.3
                            ctx.stroke()
                        }

                        Connections {
                            target: lockScope
                            function onAuthSuccessChanged() { centerCardCanvas.requestPaint() }
                            function onAuthErrorChanged() { centerCardCanvas.requestPaint() }
                        }
                    }

                    Item {
                        x: 8
                        y: -1
                        width: 160
                        height: 32
                        z: 10

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 22
                            anchors.topMargin: 2
                            spacing: 0

                            Text {
                                text: "S.E.E.S. AUTH"
                                color: "#ffffff"
                                font.family: "Rubik"
                                font.pixelSize: 11
                                font.weight: Font.Black
                                font.letterSpacing: 1.0
                            }

                            Text {
                                text: "DARK HOUR PROTOCOL"
                                color: "#00f0ff"
                                font.family: "JetBrainsMono NFM"
                                font.pixelSize: 8
                                font.bold: true
                                font.letterSpacing: 0.5
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 30
                        anchors.rightMargin: 30
                        anchors.topMargin: 38
                        anchors.bottomMargin: 20
                        spacing: 16

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16

                            Rectangle {
                                Layout.preferredWidth: 72
                                Layout.preferredHeight: 72
                                radius: 4
                                color: "#071228"
                                border.color: lockScope.authSuccess ? "#00ffd2" : (lockScope.authError ? "#ff2a55" : "#00dbff")
                                border.width: 1.5
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: Qt.resolvedUrl("../../assets/themes/p3/ui/char_leader.png")
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "OPERATIVE // " + String(PhantomState.sysHost).toUpperCase()
                                    color: "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 18
                                    font.weight: Font.Black
                                    font.letterSpacing: 0.8
                                }

                                Text {
                                    text: "SPECIALIZED EXTRACURRICULAR EXECUTION SQUAD"
                                    color: "#00dbff"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 9
                                    font.bold: true
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

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            radius: 4
                            color: "#06132a"
                            border.color: pwInput.activeFocus ? "#00dbff" : "#1a2c4e"
                            border.width: 1.6

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 12
                                spacing: 10

                                Image {
                                    width: 18
                                    height: 18
                                    source: "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/icons/lock.svg"
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }

                                TextInput {
                                    id: pwInput
                                    Layout.fillWidth: true
                                    color: "#ffffff"
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 15
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
                                        font.pixelSize: 11
                                        font.bold: true
                                        visible: pwInput.text.length === 0
                                    }
                                }

                                Rectangle {
                                    width: 52
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

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Rectangle {
                                height: 38
                                Layout.fillWidth: true
                                radius: 4
                                color: "#061226"
                                border.color: "#182a4c"
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Image {
                                        width: 18
                                        height: 18
                                        source: "file://" + (Quickshell.env("HOME") || "/home/sho") + "/.config/quickshell/assets/icons/battery-bolt.svg"
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                    }

                                    Text {
                                        text: "BATTERY " + PhantomState.batteryPct + "%"
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

                            Rectangle {
                                height: 38
                                Layout.preferredWidth: 150
                                radius: 4
                                color: submitMouse.containsMouse ? "#00e5ff" : "#0028e0"
                                border.color: "#00dbff"
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "DISPATCH"
                                    color: submitMouse.containsMouse ? "#030818" : "#ffffff"
                                    font.family: "Rubik"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                    font.letterSpacing: 1.2
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
