import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// halaman tab pengaturan tema, wallpaper, dan sudut kemiringan poligon
ColumnLayout {
    Layout.fillWidth: true
    spacing: 10

    P5SectionHeader { text: "WALLPAPER ENGINE & PARALLAX" }

    // kartu pratinjau dan kontrol pergantian wallpaper
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 115
        spacing: 12

        P5SkewedCard {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            fillColor: "#08080C"
            borderColor: "#FFFFFF"
            shadowColor: PhantomState.primary
            skewPx: 10

            Image {
                anchors.fill: parent
                anchors.margins: 4
                source: "file://" + PhantomState.wallpaperPath
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 8
                width: wpLbl.implicitWidth + 12
                height: 20
                color: "#CC08080C"
                border.color: PhantomState.primary
                border.width: 1
                Text {
                    id: wpLbl
                    anchors.centerIn: parent
                    text: PhantomState.wallpaperPath.split("/").pop()
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 9
                    font.weight: Font.Black
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            P5ConfigToggleRow {
                label: "Cycle Desktop Wallpaper"
                desc: "Switch between wallpapers in ~/Pictures/Wallpapers"
                valueText: "NEXT WP"
                active: true
                onTriggered: PhantomState.cycleWallpaper()
            }

            P5ConfigToggleRow {
                label: "Workspace Parallax Shift"
                desc: "Smoothly pan desktop wallpaper when switching workspaces (1..6)"
                valueText: PhantomState.wallpaperParallax ? "ON" : "OFF"
                active: PhantomState.wallpaperParallax
                onTriggered: {
                    PhantomState.wallpaperParallax = !PhantomState.wallpaperParallax
                    PhantomState.saveState()
                }
            }
        }
    }

    P5SectionHeader { text: "SELECT METAVERSE PALETTE (9 SCHEMES)" }

    GridLayout {
        Layout.fillWidth: true
        columns: 3
        rowSpacing: 8
        columnSpacing: 10

        Repeater {
            model: [
                { id: "p5-crimson",    title: "P5 CRIMSON",  sub: "Joker Phantom Red",   col: "#E60012" },
                { id: "p3-reload",     title: "P3 RELOAD",   sub: "S.E.E.S. Makoto Blue",col: "#00B4D8" },
                { id: "p4-golden",     title: "P4 GOLDEN",   sub: "Midnight Channel",    col: "#FFB703" },
                { id: "kasumi-violet", title: "VIOLET",      sub: "Kasumi Yoshizawa",    col: "#B829FF" },
                { id: "akechi-crow",   title: "CROW GOLD",   sub: "Goro Akechi Royal",   col: "#D4AF37" },
                { id: "futaba-matrix", title: "ORACLE",      sub: "Futaba Hacker Green", col: "#39FF14" },
                { id: "monochrome",    title: "MONOCHROME",  sub: "Noir Manga Contrast", col: "#E2E2EC" },
                { id: "expressive",    title: "EXPRESSIVE",  sub: "Velvet Cyber Neon",   col: "#7B61FF" },
                { id: "tonal-spot",    title: "GORE MAGALA", sub: "Iceshard Frost Blue", col: "#8AB4F8" }
            ]

            delegate: P5SkewedCard {
                required property var modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                fillColor: PhantomState.themeId === modelData.id ? modelData.col : "#0E0E14"
                borderColor: "#FFFFFF"
                shadowColor: modelData.col
                skewPx: 10

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.topMargin: 6
                    anchors.bottomMargin: 6
                    spacing: 1

                    RowLayout {
                        Layout.fillWidth: true
                        P5Icon {
                            name: PhantomState.themeId === modelData.id ? "star" : "rounded"
                            color: PhantomState.themeId === modelData.id ? "#08080A" : modelData.col
                            size: 12
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.title
                            color: PhantomState.themeId === modelData.id ? "#08080A" : "#FFFFFF"
                            font.family: "JetBrainsMono NFM"
                            font.pixelSize: 13
                            font.weight: Font.Black
                            font.italic: true
                            elide: Text.ElideRight
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.sub
                        color: PhantomState.themeId === modelData.id ? "#08080A" : "#AAAAAA"
                        font.family: "JetBrainsMono NFM"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PhantomState.applyPreset(modelData.id)
                }
            }
        }
    }

    P5SectionHeader { text: "GEOMETRY & SURFACE MODE" }

    P5ConfigChoiceRow {
        label: "Surface Polarity Mode"
        desc: "Switch between Dark Metaverse Onyx and Light High-Contrast"
        currentValue: PhantomState.darkMode ? "dark" : "light"
        options: [
            { id: "dark",  label: "★ DARK" },
            { id: "light", label: "☀ LIGHT" }
        ]
        onSelected: val => PhantomState.setDarkMode(val === "dark")
    }

    P5ConfigToggleRow {
        label: "Polygon Skew Mode"
        desc: "Toggle sharp Persona 5 slanted polygons vs standard cards"
        valueText: PhantomState.polygonMode ? "P5 SKEW" : "ROUNDED"
        active: PhantomState.polygonMode
        onTriggered: {
            PhantomState.polygonMode = !PhantomState.polygonMode
            PhantomState.saveState()
        }
    }

    P5ConfigSliderRow {
        label: "Polygon Skew Angle"
        desc: "Diagonal slant angle for Persona 5 UI cards"
        minVal: 0; maxVal: 18
        currentVal: Math.abs(PhantomState.skewAngle)
        unit: "°"
        onValueModified: newValue => {
            PhantomState.skewAngle = -newValue
            PhantomState.saveState()
        }
    }
}
