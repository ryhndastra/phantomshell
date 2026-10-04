import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

// jendela popup kalender bulanan dan buku catatan daily log ala persona 5
PanelWindow {
    id: calPopupWin
    visible: PhantomState.calendarOpen

    property string periodStr: "EVENING"
    property string timeStr: "22:25"

    readonly property bool isBottom: PhantomState.barPosition === "bottom"

    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()
    property int selectedDay: new Date().getDate()
    property int todayYear: new Date().getFullYear()
    property int todayMonth: new Date().getMonth()
    property int todayDate: new Date().getDate()

    readonly property var monthNames: ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    readonly property var dowShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    readonly property var calendarCells: {
        const firstDow = new Date(viewYear, viewMonth, 1).getDay()
        const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate()
        const arr = []
        for (let i = 0; i < 42; i++) {
            const d = i - firstDow + 1
            if (d >= 1 && d <= daysInMonth) {
                arr.push({
                    day: d,
                    valid: true,
                    dow: i % 7,
                    isToday: (viewYear === todayYear && viewMonth === todayMonth && d === todayDate),
                    isSelected: (d === selectedDay)
                })
            } else {
                arr.push({
                    day: 0,
                    valid: false,
                    dow: i % 7,
                    isToday: false,
                    isSelected: false
                })
            }
        }
        return arr
    }

    function prevMonth() {
        if (viewMonth === 0) {
            viewMonth = 11
            viewYear -= 1
        } else {
            viewMonth -= 1
        }
        const maxD = new Date(viewYear, viewMonth + 1, 0).getDate()
        if (selectedDay > maxD) selectedDay = maxD
    }

    function nextMonth() {
        if (viewMonth === 11) {
            viewMonth = 0
            viewYear += 1
        } else {
            viewMonth += 1
        }
        const maxD = new Date(viewYear, viewMonth + 1, 0).getDate()
        if (selectedDay > maxD) selectedDay = maxD
    }

    function resetToToday() {
        const now = new Date()
        todayYear = now.getFullYear()
        todayMonth = now.getMonth()
        todayDate = now.getDate()
        viewYear = todayYear
        viewMonth = todayMonth
        selectedDay = todayDate
    }

    WlrLayershell.namespace: "phantomshell-calendar"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusiveZone: 0

    anchors {
        top: !calPopupWin.isBottom
        bottom: calPopupWin.isBottom
        left: true
    }
    margins {
        top: 42
        bottom: 42
        left: 8
    }

    implicitWidth: 640
    implicitHeight: 390
    color: "transparent"

    onVisibleChanged: {
        if (visible) {
            resetToToday()
            calEntryAnim.restart()
        }
    }

    Item {
        id: calCard
        anchors.fill: parent
        transformOrigin: calPopupWin.isBottom ? Item.BottomLeft : Item.TopLeft

        ParallelAnimation {
            id: calEntryAnim
            NumberAnimation {
                target: calCard
                property: "scale"
                from: 0.86
                to: 1.0
                duration: 230
                easing.type: Easing.OutBack
                easing.overshoot: 1.28
            }
            NumberAnimation {
                target: calCard
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        // kanvas latar belakang komik terbelah diagonal hitam dan abu-putih ala persona 5
        Canvas {
            anchors.fill: parent
            property color accentCol: PhantomState.primary
            onAccentColChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var w = width
                var h = height

                // bayangan merah miring di belakang kartu
                ctx.fillStyle = accentCol
                ctx.beginPath()
                ctx.moveTo(14, 10)
                ctx.lineTo(w, 6)
                ctx.lineTo(w - 8, h)
                ctx.lineTo(6, h - 4)
                ctx.closePath()
                ctx.fill()

                // dasar hitam pekat sisi kiri kalender
                ctx.fillStyle = "#0B0B0F"
                ctx.beginPath()
                ctx.moveTo(6, 4)
                ctx.lineTo(w - 8, 0)
                ctx.lineTo(w - 16, h - 8)
                ctx.lineTo(0, h - 10)
                ctx.closePath()
                ctx.fill()

                // potongan diagonal putih-abu di sisi kanan buat area daily log
                ctx.fillStyle = "#DCDCE2"
                ctx.beginPath()
                ctx.moveTo(w * 0.56, 2)
                ctx.lineTo(w - 8, 0)
                ctx.lineTo(w - 16, h - 8)
                ctx.lineTo(w * 0.46, h - 9)
                ctx.closePath()
                ctx.fill()

                // aksen segitiga putih tajam di bagian atas kanan
                ctx.fillStyle = "#16161D"
                ctx.beginPath()
                ctx.moveTo(w * 0.66, 1)
                ctx.lineTo(w * 0.72, 1)
                ctx.lineTo(w * 0.69, 32)
                ctx.closePath()
                ctx.fill()

                // garis tepi luar putih tegas
                ctx.strokeStyle = "#FFFFFF"
                ctx.lineWidth = 2.5
                ctx.beginPath()
                ctx.moveTo(6, 4)
                ctx.lineTo(w - 8, 0)
                ctx.lineTo(w - 16, h - 8)
                ctx.lineTo(0, h - 10)
                ctx.closePath()
                ctx.stroke()
            }
        }

        // teks watermark command besar di latar belakang bawah kiri
        Text {
            x: 44
            y: parent.height - 68
            rotation: -8
            text: "COMMAND"
            color: "#1B1B24"
            font.family: "JetBrainsMono NFM"
            font.pixelSize: 44
            font.weight: Font.Black
            font.italic: true
        }

        // bagian kiri: kisi angka kalender bulanan miring
        Item {
            id: leftCalendarArea
            x: 24
            y: 20
            width: 345
            height: 325
            rotation: -4.5

            // baris nama hari (sun..sat)
            Row {
                id: dowHeaderRow
                x: 4
                y: 0
                spacing: 4

                Repeater {
                    model: ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
                    delegate: Item {
                        required property string modelData
                        required property int index
                        width: 45
                        height: 26

                        Text {
                            anchors.centerIn: parent
                            rotation: (parent.index % 2 === 0) ? -3 : 2
                            text: parent.modelData
                            color: "#ECECF2"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 15
                            font.weight: Font.Black
                            font.italic: true
                        }
                    }
                }
            }

            // garis dekoratif dengan titik di tengah kalender
            Rectangle {
                x: 92
                y: 146
                width: 242
                height: 2
                color: "#B8BBC6"
                opacity: 0.75
                Rectangle {
                    x: -3
                    y: -3
                    width: 8
                    height: 8
                    radius: 4
                    color: "#B8BBC6"
                }
            }

            // kisi 6 minggu x 7 hari
            Grid {
                x: 4
                y: 30
                columns: 7
                rowSpacing: 2
                columnSpacing: 4

                Repeater {
                    model: calPopupWin.calendarCells

                    delegate: Item {
                        required property var modelData
                        width: 45
                        height: 46

                        // kotak merah miring penanda tanggal terpilih / hari ini
                        Rectangle {
                            anchors.centerIn: parent
                            width: 42
                            height: 36
                            rotation: -14
                            visible: parent.modelData.valid && parent.modelData.isSelected
                            color: PhantomState.primary
                            border.color: parent.modelData.isToday ? PhantomState.secondary : "transparent"
                            border.width: parent.modelData.isToday ? 2 : 0
                        }

                        // titik kecil di atas tanggal hari ini jika sedang memilih tanggal lain
                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 1
                            visible: parent.modelData.valid && parent.modelData.isToday && !parent.modelData.isSelected
                            color: PhantomState.secondary
                        }

                        // angka tanggal berukuran besar
                        Text {
                            anchors.centerIn: parent
                            visible: parent.modelData.valid
                            text: parent.modelData.valid ? String(parent.modelData.day) : ""
                            color: {
                                if (parent.modelData.isSelected) return "#09090D"
                                if (parent.modelData.dow === 0) return PhantomState.primary
                                if (parent.modelData.dow === 6) return "#00A8E8"
                                return "#B8BBC6"
                            }
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 30
                            font.weight: Font.Black
                            font.italic: true
                            scale: dayCellMouse.containsMouse ? 1.12 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                        }

                        MouseArea {
                            id: dayCellMouse
                            anchors.fill: parent
                            enabled: parent.modelData.valid
                            hoverEnabled: parent.modelData.valid
                            cursorShape: parent.modelData.valid ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (parent.modelData.valid) {
                                    calPopupWin.selectedDay = parent.modelData.day
                                }
                            }
                        }
                    }
                }
            }
        }

        // bagian kanan atas: navigasi bulan < / > dan pita tanggal aktif
        Item {
            x: 368
            y: 18
            width: 250
            height: 76

            // baris pemilih bulan [<] OCT [>]
            Row {
                x: 6
                y: 4
                spacing: 12

                // tombol bulan sebelumnya (<)
                Rectangle {
                    width: 26
                    height: 22
                    radius: 3
                    color: prevMonMouse.containsMouse ? PhantomState.primary : "#0D0D12"
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: "<"
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 13
                        font.weight: Font.Black
                    }
                    MouseArea {
                        id: prevMonMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calPopupWin.prevMonth()
                    }
                }

                // nama bulan aktif (klik untuk kembali ke hari ini)
                Text {
                    text: calPopupWin.monthNames[calPopupWin.viewMonth] + (calPopupWin.viewYear !== calPopupWin.todayYear ? (" '" + String(calPopupWin.viewYear).slice(2)) : "")
                    color: "#0D0D12"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 22
                    font.weight: Font.Black
                    font.italic: true
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calPopupWin.resetToToday()
                    }
                }

                // tombol bulan berikutnya (>)
                Rectangle {
                    width: 26
                    height: 22
                    radius: 3
                    color: nextMonMouse.containsMouse ? PhantomState.primary : "#0D0D12"
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: ">"
                        color: "#FFFFFF"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 13
                        font.weight: Font.Black
                    }
                    MouseArea {
                        id: nextMonMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calPopupWin.nextMonth()
                    }
                }
            }

            // pita hitam miring penunjuk tanggal terpilih (misal 10/04 (Sun))
            Rectangle {
                x: 56
                y: 38
                width: 146
                height: 28
                rotation: -2
                color: "#09090D"

                Text {
                    anchors.centerIn: parent
                    text: {
                        const m = calPopupWin.viewMonth + 1
                        const d = calPopupWin.selectedDay
                        const dowIdx = new Date(calPopupWin.viewYear, calPopupWin.viewMonth, d).getDay()
                        return m + "/" + (d < 10 ? "0" + d : d) + " (" + calPopupWin.dowShort[dowIdx] + ")"
                    }
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 13
                    font.weight: Font.Black
                }
            }
        }

        // bagian kanan bawah: buku catatan miring daily log
        Item {
            id: notebookArea
            x: 368
            y: 112
            width: 236
            height: 242
            rotation: -6

            // lembaran kertas bayangan di belakang
            Rectangle {
                x: 8
                y: 12
                width: parent.width - 10
                height: parent.height - 6
                rotation: 5
                color: "#D8D8E0"
                border.color: "#08080C"
                border.width: 3
            }

            // lembaran buku catatan utama
            Rectangle {
                id: mainSheet
                anchors.fill: parent
                color: "#F4F4F8"
                border.color: "#08080C"
                border.width: 3.5

                // lubang jilid spiral di sisi kanan buku catatan
                Column {
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.top: parent.top
                    anchors.topMargin: 14
                    spacing: 14

                    Repeater {
                        model: 7
                        delegate: Rectangle {
                            required property int index
                            width: 10
                            height: 14
                            rotation: (index % 2 === 0) ? -6 : 4
                            color: "#08080C"
                        }
                    }
                }

                // judul ransom-note: Daily [L]og
                Row {
                    x: 14
                    y: 10
                    spacing: 2

                    Text {
                        text: "Daily "
                        color: "#09090D"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 22
                        font.weight: Font.Black
                        font.italic: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 24
                        height: 30
                        rotation: -8
                        color: "#484852"
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: "L"
                            color: "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 22
                            font.weight: Font.Black
                        }
                    }

                    Text {
                        text: "og"
                        color: "#09090D"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 22
                        font.weight: Font.Black
                        font.italic: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // baris-baris isi catatan harian
                Column {
                    x: 16
                    y: 54
                    width: parent.width - 42
                    spacing: 12

                    // baris 1: waktu & status dengan garis bawah merah tebal
                    Column {
                        width: parent.width
                        spacing: 3

                        Text {
                            width: parent.width
                            text: calPopupWin.periodStr + " • " + calPopupWin.timeStr
                            color: PhantomState.primary
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 12
                            font.weight: Font.Black
                            font.italic: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            width: parent.width
                            height: 3
                            radius: 1.5
                            color: PhantomState.primary
                        }
                    }

                    // baris 2: tema aktif
                    Column {
                        width: parent.width
                        spacing: 4
                        Text {
                            width: parent.width
                            text: PhantomState.themeName
                            color: "#09090D"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 11
                            font.weight: Font.Black
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                        Rectangle { width: parent.width; height: 1; color: "#C4C4CE" }
                    }

                    // baris 3: lagu yang sedang diputar atau status metaverse
                    Column {
                        width: parent.width
                        spacing: 4
                        Text {
                            width: parent.width
                            text: PhantomState.mediaAvailable ? ("♪ " + PhantomState.mediaTitle) : "♪ Beneath the Mask"
                            color: "#22222A"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                        Rectangle { width: parent.width; height: 1; color: "#C4C4CE" }
                    }

                    // baris 4: informasi sistem & uptime
                    Column {
                        width: parent.width
                        spacing: 4
                        Text {
                            width: parent.width
                            text: "Uptime: " + PhantomState.sysUptime + " • CPU " + Math.round(PhantomState.cpuPct) + "%"
                            color: "#3A3A46"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                        Rectangle { width: parent.width; height: 1; color: "#C4C4CE" }
                    }

                    // baris 5: pintasan cepat
                    Column {
                        width: parent.width
                        spacing: 4
                        Text {
                            width: parent.width
                            text: "[SUPER+/] Tactics • [SUPER+I] Config"
                            color: "#555564"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                        Rectangle { width: parent.width; height: 1; color: "#C4C4CE" }
                    }
                }
            }
        }

        // tombol aksi bawah kanan untuk kembali atau lompat ke hari ini
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 22
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            spacing: 10

            // tombol kembali / tutup kalender
            Rectangle {
                width: backBtnTxt.implicitWidth + 22
                height: 24
                radius: 4
                color: backCalMouse.containsMouse ? PhantomState.primary : "#09090D"
                border.color: "#FFFFFF"
                border.width: 1.5

                Text {
                    id: backBtnTxt
                    anchors.centerIn: parent
                    text: "BACK"
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 10
                    font.weight: Font.Black
                    font.italic: true
                }

                MouseArea {
                    id: backCalMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PhantomState.calendarOpen = false
                }
            }

            // tombol lompat ke hari ini
            Rectangle {
                width: todayBtnTxt.implicitWidth + 22
                height: 24
                radius: 4
                color: todayCalMouse.containsMouse ? "#00A8E8" : "#09090D"
                border.color: "#FFFFFF"
                border.width: 1.5

                Text {
                    id: todayBtnTxt
                    anchors.centerIn: parent
                    text: "TODAY"
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 10
                    font.weight: Font.Black
                    font.italic: true
                }

                MouseArea {
                    id: todayCalMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: calPopupWin.resetToToday()
                }
            }
        }
    }
}
