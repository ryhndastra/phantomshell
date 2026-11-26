import QtQuick
import QtQuick.Effects
import qs.config

// Layar kalender otentik Persona 5 Royal (Tokyo Fisheye Skyline + Dagger + Tanggal Merah)
Item {
    id: root
    anchors.fill: parent

    property bool active: false
    property bool contentVisible: false

    // Navigasi hari & sinkronisasi waktu nyata
    property var realToday: new Date()
    property int dayOffset: 0

    readonly property var centerDate: {
        var d = new Date(realToday)
        d.setDate(d.getDate() + dayOffset)
        return d
    }

    // Font khusus Persona 5 Royal
    FontLoader {
        id: p5HeadlineFont
        source: Qt.resolvedUrl("../../assets/themes/p5/fonts/Persona5RoyalHeadlineFont.ttf")
    }
    FontLoader {
        id: p5RegularFont
        source: Qt.resolvedUrl("../../assets/themes/p5/fonts/Persona5RoyalRegulerFont.ttf")
    }
    FontLoader {
        id: arsenalBoldFont
        source: Qt.resolvedUrl("../../assets/themes/p5/fonts/Arsenal-Bold.ttf")
    }

    focus: true

    // Key navigation
    Item {
        id: screenKeyCatcher
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                PhantomState.calendarOpen = false
                event.accepted = true
            } else if (event.key === Qt.Key_Left) {
                root.shiftDay(-1)
                event.accepted = true
            } else if (event.key === Qt.Key_Right) {
                root.shiftDay(1)
                event.accepted = true
            } else if (event.key === Qt.Key_Space) {
                root.resetToToday()
                event.accepted = true
            }
        }
    }

    function shiftDay(delta) {
        dayOffset += delta
        PhantomState.playSfx("cursor")
    }

    function resetToToday() {
        dayOffset = 0
        PhantomState.playSfx("open")
    }

    // Database hari libur nasional Indonesia + Minggu (Tanggal Merah)
    function getHolidayInfo(d) {
        var dow = d.getDay() // 0 = Minggu / Sunday
        var isSunday = (dow === 0)

        var y = d.getFullYear()
        var m = d.getMonth() + 1
        var dateNum = d.getDate()
        var mm = (m < 10 ? "0" + m : "" + m)
        var dd = (dateNum < 10 ? "0" + dateNum : "" + dateNum)
        var key = mm + "-" + dd
        var yKey = y + "-" + key

        // Libur Nasional Tetap Indonesia
        var fixedHolidays = {
            "01-01": "Tahun Baru Masehi",
            "05-01": "Hari Buruh Internasional",
            "06-01": "Hari Lahir Pancasila",
            "08-17": "Hari Kemerdekaan RI",
            "12-25": "Hari Raya Natal"
        }

        // Libur Nasional Bergerak (2025, 2026, 2027)
        var movableHolidays = {
            // 2026
            "2026-01-16": "Isra Mi'raj",
            "2026-02-17": "Tahun Baru Imlek 2577",
            "2026-03-20": "Hari Suci Nyepi 1948",
            "2026-03-21": "Hari Raya Idul Fitri 1447 H",
            "2026-03-22": "Hari Raya Idul Fitri 1447 H",
            "2026-04-03": "Wafat Yesus Kristus",
            "2026-05-14": "Kenaikan Yesus Kristus",
            "2026-05-27": "Hari Raya Idul Adha 1447 H",
            "2026-05-31": "Hari Raya Waisak 2570",
            "2026-06-16": "Tahun Baru Islam 1448 H",
            "2026-08-25": "Maulid Nabi Muhammad SAW",
            // 2025
            "2025-01-27": "Isra Mi'raj",
            "2025-01-29": "Tahun Baru Imlek",
            "2025-03-29": "Hari Suci Nyepi",
            "2025-03-31": "Hari Raya Idul Fitri",
            "2025-04-01": "Hari Raya Idul Fitri",
            "2025-04-18": "Wafat Yesus Kristus",
            "2025-05-12": "Hari Raya Waisak",
            "2025-05-29": "Kenaikan Yesus Kristus",
            "2025-06-06": "Hari Raya Idul Adha",
            "2025-06-27": "Tahun Baru Islam",
            "2025-09-05": "Maulid Nabi Muhammad"
        }

        if (fixedHolidays[key]) {
            return { isHoliday: true, name: fixedHolidays[key], isSunday: isSunday }
        }
        if (movableHolidays[yKey]) {
            return { isHoliday: true, name: movableHolidays[yKey], isSunday: isSunday }
        }
        if (isSunday) {
            return { isHoliday: true, name: "SUNDAY", isSunday: true }
        }

        return { isHoliday: false, name: "", isSunday: false }
    }

    // Entrance Animation
    property real animProgress: 0.0

    ParallelAnimation {
        id: enterAnim
        NumberAnimation {
            target: root
            property: "animProgress"
            from: 0.0
            to: 1.0
            duration: 280
            easing.type: Easing.OutCubic
        }
    }

    onActiveChanged: {
        if (active) {
            realToday = new Date()
            dayOffset = 0
            contentVisible = true
            animProgress = 0.0
            enterAnim.restart()
            screenKeyCatcher.forceActiveFocus()
            PhantomState.playSfx("open")
        } else {
            contentVisible = false
            animProgress = 0.0
            PhantomState.playSfx("close")
        }
    }

    // Tangkap klik luar untuk menutup
    MouseArea {
        anchors.fill: parent
        onClicked: PhantomState.calendarOpen = false
    }

    // 1. Panoramic Tokyo Fisheye Cityscape Background
    Item {
        anchors.fill: parent
        visible: root.contentVisible
        opacity: root.animProgress
        scale: 0.96 + 0.04 * root.animProgress

        Image {
            id: bgCity
            anchors.fill: parent
            source: Qt.resolvedUrl("../../assets/themes/p5/calendar/p5_calendar_bg.jpg")
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: false
        }

        // Halftone / vignette edges
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#26000000" }
                GradientStop { position: 0.7; color: "transparent" }
                GradientStop { position: 1.0; color: "#66000000" }
            }
        }
    }

    // 2. Persona 5 Year & Month Sticker Stamp (Top-Left)
    Item {
        id: p5YearMonthHud
        visible: root.contentVisible
        anchors.left: parent.left
        anchors.leftMargin: 64
        anchors.top: parent.top
        anchors.topMargin: 48
        width: 380
        height: 110
        opacity: root.animProgress
        transform: [
            Translate {
                x: (1.0 - root.animProgress) * -80
            },
            Rotation {
                angle: -3.5
                origin.x: 0
                origin.y: 0
            }
        ]

        readonly property string yearStr: "20XX"
        readonly property string monthStr: (root.centerDate.getMonth() + 1).toString()

        // 3D Drop Shadow hitam tebal untuk Year & Month
        Repeater {
            model: [
                { dx: 4, dy: 5 }, { dx: 6, dy: 8 }, { dx: 8, dy: 11 }
            ]
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12 + modelData.dx
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: modelData.dy
                spacing: 6
                Text {
                    text: p5YearMonthHud.yearStr
                    font.family: p5RegularFont.name !== "" ? p5RegularFont.name : "p5hatty"
                    font.pixelSize: 68
                    font.weight: Font.Black
                    color: "#000000"
                    style: Text.Outline
                    styleColor: "#000000"
                }
                Text {
                    text: p5YearMonthHud.monthStr
                    font.family: p5RegularFont.name !== "" ? p5RegularFont.name : "p5hatty"
                    font.pixelSize: 68
                    font.weight: Font.Black
                    color: "#000000"
                    style: Text.Outline
                    styleColor: "#000000"
                }
            }
        }

        // Contour putih tebal die-cut sticker
        Repeater {
            model: [
                { dx: -5, dy: 0 }, { dx: 5, dy: 0 }, { dx: 0, dy: -5 }, { dx: 0, dy: 5 },
                { dx: -4, dy: -4 }, { dx: 4, dy: -4 }, { dx: -4, dy: 4 }, { dx: 4, dy: 4 },
                { dx: -6, dy: -2 }, { dx: 6, dy: -2 }, { dx: -2, dy: -6 }, { dx: 2, dy: -6 },
                { dx: -6, dy: 2 }, { dx: 6, dy: 2 }, { dx: -2, dy: 6 }, { dx: 2, dy: 6 }
            ]
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12 + modelData.dx
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: modelData.dy
                spacing: 6
                Text {
                    text: p5YearMonthHud.yearStr
                    font.family: p5RegularFont.name !== "" ? p5RegularFont.name : "p5hatty"
                    font.pixelSize: 68
                    font.weight: Font.Black
                    color: "#FFFFFF"
                    style: Text.Outline
                    styleColor: "#FFFFFF"
                }
                Text {
                    text: p5YearMonthHud.monthStr
                    font.family: p5RegularFont.name !== "" ? p5RegularFont.name : "p5hatty"
                    font.pixelSize: 68
                    font.weight: Font.Black
                    color: "#FFFFFF"
                    style: Text.Outline
                    styleColor: "#FFFFFF"
                }
            }
        }

        // Foreground Glyph Tahun (Hitam Solid) dan Bulan (Putih Outline Hitam)
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            Text {
                text: p5YearMonthHud.yearStr
                font.family: p5RegularFont.name !== "" ? p5RegularFont.name : "p5hatty"
                font.pixelSize: 68
                font.weight: Font.Black
                color: "#000000"
            }
            Text {
                text: p5YearMonthHud.monthStr
                font.family: p5RegularFont.name !== "" ? p5RegularFont.name : "p5hatty"
                font.pixelSize: 68
                font.weight: Font.Black
                color: "#FFFFFF"
                style: Text.Outline
                styleColor: "#000000"
            }
        }
    }

    // 3. The Curved Calendar Timeline Arc (7 Days Carousel)
    Item {
        id: calendarArc
        anchors.fill: parent
        visible: root.contentVisible
        opacity: root.animProgress

        // Handle Mouse Wheel untuk scroll tanggal dan klik area kosong untuk tutup
        MouseArea {
            anchors.fill: parent
            onClicked: PhantomState.calendarOpen = false
            onWheel: wheel => {
                if (wheel.angleDelta.y > 0 || wheel.angleDelta.x < 0) {
                    root.shiftDay(-1)
                } else if (wheel.angleDelta.y < 0 || wheel.angleDelta.x > 0) {
                    root.shiftDay(1)
                }
            }
        }

        Repeater {
            model: 7 // Index 0..6, center = 3 (offset -3..+3)
            delegate: Item {
                id: dayNode
                property int relOffset: index - 3 // -3, -2, -1, 0, 1, 2, 3
                
                readonly property var dayDate: {
                    var d = new Date(root.centerDate)
                    d.setDate(d.getDate() + relOffset)
                    return d
                }

                readonly property bool isToday: {
                    var rt = root.realToday
                    var dd = dayDate
                    return (dd.getFullYear() === rt.getFullYear() &&
                            dd.getMonth() === rt.getMonth() &&
                            dd.getDate() === rt.getDate())
                }

                readonly property var holInfo: root.getHolidayInfo(dayDate)
                readonly property bool isHolidayDate: holInfo.isHoliday
                readonly property bool isCenterNode: (relOffset === 0)

                // Posisi geometris kurva melengkung (Spherical Arc)
                readonly property real curveSpacing: root.width * 0.135
                readonly property real baseX: root.width * 0.5 + relOffset * curveSpacing
                readonly property real baseY: root.height * 0.52 + (relOffset * relOffset) * 14.5
                readonly property real baseRotation: relOffset * 6.5
                readonly property real baseScale: isCenterNode ? 1.15 : Math.max(0.75, 1.0 - Math.abs(relOffset) * 0.08)

                x: baseX - width / 2
                y: baseY - height / 2
                width: 170
                height: 220
                z: 20 - Math.abs(relOffset)
                rotation: baseRotation
                scale: baseScale

                Behavior on x { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                Behavior on y { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                Behavior on rotation { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if (dayNode.relOffset !== 0) {
                            root.shiftDay(dayNode.relOffset)
                        }
                    }
                }

                // Banner Label Libur Nasional (jika ada hari libur resmi)
                Item {
                    id: holidayBadge
                    visible: dayNode.isHolidayDate && dayNode.holInfo.name !== "SUNDAY"
                    anchors.bottom: dateNumberCard.top
                    anchors.bottomMargin: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(200, holidayText.implicitWidth + 20)
                    height: 24
                    rotation: -3

                    Rectangle {
                        anchors.fill: parent
                        color: "#E60012"
                        border.color: "#000000"
                        border.width: 2
                    }

                    Text {
                        id: holidayText
                        anchors.centerIn: parent
                        text: dayNode.holInfo.name
                        font.family: p5HeadlineFont.name !== "" ? p5HeadlineFont.name : "Rubik"
                        font.pixelSize: 10
                        font.weight: Font.Black
                        color: "#FFFFFF"
                        elide: Text.ElideRight
                        width: parent.width - 8
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Wadah Utama Stiker Angka Tanggal Persona 5 (Die-Cut Typography)
                Item {
                    id: dateNumberCard
                    anchors.centerIn: parent
                    width: 200
                    height: 200

                    readonly property string dayNumStr: dayNode.dayDate.getDate().toString()
                    readonly property string dayNameStr: Qt.formatDateTime(dayNode.dayDate, "dddd").toUpperCase()
                    readonly property color dayColor: dayNode.isToday ? "#38A9FF" : (dayNode.isHolidayDate ? "#E60012" : "#000000")

                    // 1. Black 3D Drop Shadow untuk angka tanggal
                    Repeater {
                        model: [
                            { dx: 4, dy: 5 }, { dx: 6, dy: 8 }, { dx: 8, dy: 11 }, { dx: 10, dy: 14 }
                        ]
                        Text {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: modelData.dx
                            anchors.verticalCenterOffset: modelData.dy - 20
                            text: dateNumberCard.dayNumStr
                            font.family: p5RegularFont.name !== "" ? p5RegularFont.name : "p5hatty"
                            font.pixelSize: 115
                            font.weight: Font.Black
                            color: "#000000"
                            style: Text.Outline
                            styleColor: "#000000"
                        }
                    }

                    // 2. Thick White Die-Cut Contour untuk angka tanggal
                    Repeater {
                        model: [
                            { dx: -6, dy: 0 }, { dx: 6, dy: 0 }, { dx: 0, dy: -6 }, { dx: 0, dy: 6 },
                            { dx: -5, dy: -5 }, { dx: 5, dy: -5 }, { dx: -5, dy: 5 }, { dx: 5, dy: 5 },
                            { dx: -7, dy: -3 }, { dx: 7, dy: -3 }, { dx: -3, dy: -7 }, { dx: 3, dy: -7 },
                            { dx: -7, dy: 3 }, { dx: 7, dy: 3 }, { dx: -3, dy: 7 }, { dx: 3, dy: 7 }
                        ]
                        Text {
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: modelData.dx
                            anchors.verticalCenterOffset: modelData.dy - 20
                            text: dateNumberCard.dayNumStr
                            font.family: p5RegularFont.name !== "" ? p5RegularFont.name : "p5hatty"
                            font.pixelSize: 115
                            font.weight: Font.Black
                            color: "#FFFFFF"
                            style: Text.Outline
                            styleColor: "#FFFFFF"
                        }
                    }

                    // 3. Foreground Colored Glyph angka tanggal (Solid, tanpa card box)
                    Text {
                        id: dateNumberText
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -20
                        text: dateNumberCard.dayNumStr
                        font.family: p5RegularFont.name !== "" ? p5RegularFont.name : "p5hatty"
                        font.pixelSize: 115
                        font.weight: Font.Black
                        color: dateNumberCard.dayColor
                        style: Text.Normal
                    }

                    // 4. Stiker Nama Hari (SATURDAY, SUNDAY, MONDAY)
                    Item {
                        id: dayOfWeekBadge
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 10
                        width: dayOfWeekText.implicitWidth + 20
                        height: 38
                        rotation: -2.5

                        // Black Shadow untuk nama hari
                        Repeater {
                            model: [
                                { dx: 3, dy: 4 }, { dx: 5, dy: 6 }
                            ]
                            Text {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: modelData.dx
                                anchors.verticalCenterOffset: modelData.dy
                                text: dateNumberCard.dayNameStr
                                font.family: p5HeadlineFont.name !== "" ? p5HeadlineFont.name : "Rubik"
                                font.pixelSize: 32
                                font.weight: Font.Black
                                color: "#000000"
                                style: Text.Outline
                                styleColor: "#000000"
                            }
                        }

                        // Thick White Contour untuk nama hari
                        Repeater {
                            model: [
                                { dx: -4, dy: 0 }, { dx: 4, dy: 0 }, { dx: 0, dy: -4 }, { dx: 0, dy: 4 },
                                { dx: -3, dy: -3 }, { dx: 3, dy: -3 }, { dx: -3, dy: 3 }, { dx: 3, dy: 3 }
                            ]
                            Text {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: modelData.dx
                                anchors.verticalCenterOffset: modelData.dy
                                text: dateNumberCard.dayNameStr
                                font.family: p5HeadlineFont.name !== "" ? p5HeadlineFont.name : "Rubik"
                                font.pixelSize: 32
                                font.weight: Font.Black
                                color: "#FFFFFF"
                                style: Text.Outline
                                styleColor: "#FFFFFF"
                            }
                        }

                        // Foreground Text Nama Hari
                        Text {
                            id: dayOfWeekText
                            anchors.centerIn: parent
                            text: dateNumberCard.dayNameStr
                            font.family: p5HeadlineFont.name !== "" ? p5HeadlineFont.name : "Rubik"
                            font.pixelSize: 32
                            font.weight: Font.Black
                            color: "#000000"
                        }
                    }
                }

                // 4. Pisau / Dagger Joker Otentik (HANYA MUNCUL DI ATAS HARI INI / TODAY)
                Item {
                    id: daggerWrapper
                    visible: dayNode.isToday
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 82
                    anchors.verticalCenterOffset: -105
                    width: 175
                    height: 175
                    z: 50

                    Image {
                        id: daggerImg
                        anchors.fill: parent
                        source: Qt.resolvedUrl("../../assets/themes/p5/calendar/p5_dagger.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true

                        // Efek Slam / Tancap saat kalender pertama terbuka
                        transform: [
                            Translate {
                                id: daggerSlamTranslate
                                y: (1.0 - root.animProgress) * -120
                            },
                            Rotation {
                                angle: -10
                                origin.x: 35
                                origin.y: 145
                            }
                        ]
                    }
                }
            }
        }
    }

    // 5. Persona 5 Controller & Helper Bar (Bottom Center)
    Item {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28
        anchors.horizontalCenter: parent.horizontalCenter
        width: 580
        height: 48
        visible: root.contentVisible
        opacity: root.animProgress
        transform: Translate { y: (1.0 - root.animProgress) * 40 }

        Row {
            anchors.centerIn: parent
            spacing: 24

            // Tombol Navigasi Kiri / Kanan
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: 38
                    height: 26
                    color: "#000000"
                    border.color: "#FFFFFF"
                    border.width: 1.5
                    radius: 3
                    Text {
                        anchors.centerIn: parent
                        text: "← / →"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "NAVIGATE DAYS"
                    font.family: p5HeadlineFont.name !== "" ? p5HeadlineFont.name : "Rubik"
                    font.pixelSize: 13
                    font.weight: Font.Black
                    color: "#FFFFFF"
                    style: Text.Outline
                    styleColor: "#000000"
                }
            }

            // Tombol Space Kembali ke Hari Ini
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: 54
                    height: 26
                    color: "#38A9FF"
                    border.color: "#000000"
                    border.width: 1.5
                    radius: 3
                    Text {
                        anchors.centerIn: parent
                        text: "SPACE"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 11
                        font.weight: Font.Black
                        color: "#000000"
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "TODAY"
                    font.family: p5HeadlineFont.name !== "" ? p5HeadlineFont.name : "Rubik"
                    font.pixelSize: 13
                    font.weight: Font.Black
                    color: "#FFFFFF"
                    style: Text.Outline
                    styleColor: "#000000"
                }
            }

            // Tombol ESC Close
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    width: 40
                    height: 26
                    color: "#E60012"
                    border.color: "#000000"
                    border.width: 1.5
                    radius: 3
                    Text {
                        anchors.centerIn: parent
                        text: "ESC"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 11
                        font.weight: Font.Black
                        color: "#FFFFFF"
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "CLOSE"
                    font.family: p5HeadlineFont.name !== "" ? p5HeadlineFont.name : "Rubik"
                    font.pixelSize: 13
                    font.weight: Font.Black
                    color: "#FFFFFF"
                    style: Text.Outline
                    styleColor: "#000000"
                }
            }
        }
    }
}
