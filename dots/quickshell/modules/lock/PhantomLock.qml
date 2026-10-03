import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config
import qs.components

// lock screen utama dengan autentikasi PAM + tampilan ala calling card persona 5
// panggil lewat keybind SUPER+L (atau ALT+L di nested), menu session, atau perintah: phantomshell lock
Scope {
    id: lockScope

    property string currentTime: "23:45"
    property string currentDay: "SATURDAY"
    property string currentDate: "OCT 04"
    property string statusText: "ENTER PASSCODE TO INFILTRATE"
    property bool authError: false
    property bool authBusy: false
    property bool showPassword: false
    property string pendingPassword: ""

    // timer update jam di lock screen (jalan cuma pas layar terkunci)
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

    // pam context buat verifikasi password user linux asli
    // ganti config ke "login" kalau sistem lu ga punya /etc/pam.d/hyprlock
    PamContext {
        id: pam
        config: "hyprlock"

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
                lockScope.statusText = "IDENTITY VERIFIED // WELCOME BACK, JOKER"
                PhantomState.playSfx("select")
                PhantomState.lockOpen = false
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
        pam.start()
    }

    // wayland session lock surface (mengunci seluruh monitor aktif)
    WlSessionLock {
        id: sessionLock
        locked: PhantomState.lockOpen

        WlSessionLockSurface {
            id: lockSurface

            Item {
                id: lockRoot
                anchors.fill: parent

                // fokus otomatis ke input password pas lock screen kebuka
                Component.onCompleted: {
                    pwInput.forceActiveFocus()
                }

                // wallpaper background + efek gelap diagonal
                // ganti opacity di darkOverlay kalau mau background lebih terang/gelap
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
                }

                Rectangle {
                    id: darkOverlay
                    anchors.fill: parent
                    color: "#B807070C"
                }

                // dekorasi garis slash merah khas persona 5 di background lock screen
                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var w = width
                        var h = height

                        ctx.fillStyle = "rgba(230, 0, 18, 0.14)"
                        ctx.beginPath()
                        ctx.moveTo(0, h * 0.18)
                        ctx.lineTo(w, h * 0.04)
                        ctx.lineTo(w, h * 0.22)
                        ctx.lineTo(0, h * 0.42)
                        ctx.closePath()
                        ctx.fill()

                        ctx.fillStyle = "rgba(230, 0, 18, 0.10)"
                        ctx.beginPath()
                        ctx.moveTo(0, h * 0.78)
                        ctx.lineTo(w, h * 0.62)
                        ctx.lineTo(w, h * 0.74)
                        ctx.lineTo(0, h * 0.92)
                        ctx.closePath()
                        ctx.fill()
                    }
                }

                // widget jam & tanggal kiri atas
                // ubah anchors.topMargin / leftMargin buat geser posisi jam di lock screen
                Item {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 42
                    anchors.leftMargin: 52
                    width: 360
                    height: 150

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

                // kartu utama lock screen di tengah layar
                // ubah width & height di bawah buat atur ukuran kartu input password
                Item {
                    id: centerCard
                    width: 520
                    height: 330
                    anchors.centerIn: parent

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
                        borderColor: lockScope.authError ? PhantomState.primary : "#FFFFFF"
                        shadowColor: lockScope.authError ? "#FF0022" : PhantomState.primary
                        borderWidth: 3
                        skewPx: 14
                        shadowOffsetX: 8
                        shadowOffsetY: 8
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 28
                        spacing: 16

                        // bagian atas: foto profil ren + nama user & status
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 18

                            // frame avatar miring
                            // ganti source "../assets/ren.png" kalau mau pakai foto profil lain
                            Item {
                                Layout.preferredWidth: 84
                                Layout.preferredHeight: 84
                                rotation: -6

                                Rectangle {
                                    x: 5; y: 6
                                    width: parent.width; height: parent.height
                                    color: PhantomState.primary
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
                                        color: "#FFFFFF"
                                        rotation: -2
                                        Text {
                                            anchors.centerIn: parent
                                            text: "CALLING CARD LOCK"
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
                                    color: lockScope.authError ? PhantomState.primary : PhantomState.muted
                                    font.family: "JetBrainsMono NFM"
                                    font.pixelSize: 11
                                    font.weight: Font.Black
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        // kolom input password
                        // tekan Enter buat langsung unlock, atau Escape buat hapus teks
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

                                // tombol intip password (SHOW/HIDE)
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

                        // baris bawah: indikator baterai/volume + tombol UNLOCK & SUSPEND
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
            }
        }
    }
}
