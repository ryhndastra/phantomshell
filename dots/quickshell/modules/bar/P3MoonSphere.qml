import QtQuick
import QtQuick.Effects

// Bola Fase Bulan 3D Persona 3 Reload - Proyeksi Kosinus Halus & Warna Slate Otentik
Item {
    id: moonSphereRoot
    implicitWidth: 34
    implicitHeight: 34

    property real moonDegree: 0 // Derajat fase lunar 0 - 360
    property color litColor: "#ffffff"
    property color darkColor: "#526074" // Slate silver-gray khas Atlus P3R
    property color borderColor: "#88ffffff"
    property real borderWidth: 1.0

    readonly property bool isWaxing: moonDegree < 180
    readonly property real cosFactor: Math.cos(moonDegree * Math.PI / 180)

    // Bayangan halus di bawah bola bulan
    Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 2.5
        width: parent.width - 2
        height: width
        radius: width / 2
        color: "#60000000"
    }

    // Area masked berbentuk lingkaran sempurna
    Item {
        id: maskedArea
        anchors.fill: parent
        clip: true

        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: ShaderEffectSource {
                sourceItem: Rectangle {
                    width: moonSphereRoot.width
                    height: moonSphereRoot.height
                    radius: moonSphereRoot.width / 2
                    color: "white"
                }
            }
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }

        // Belahan kiri bola
        Rectangle {
            x: 0
            y: 0
            width: parent.width / 2
            height: parent.height
            color: moonSphereRoot.isWaxing ? moonSphereRoot.darkColor : moonSphereRoot.litColor
        }

        // Belahan kanan bola
        Rectangle {
            x: parent.width / 2
            y: 0
            width: parent.width / 2
            height: parent.height
            color: moonSphereRoot.isWaxing ? moonSphereRoot.litColor : moonSphereRoot.darkColor
        }

        // Terminator elips kosinus penentu fase lengkung
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: width / 2
            transform: Scale {
                origin.x: moonSphereRoot.width / 2
                origin.y: moonSphereRoot.height / 2
                xScale: Math.max(0.001, Math.abs(moonSphereRoot.cosFactor))
                yScale: 1.0
            }
            color: moonSphereRoot.cosFactor >= 0 ? moonSphereRoot.darkColor : moonSphereRoot.litColor
        }
    }

    // Cincin luar bercahaya halus khas SEES HUD
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: moonSphereRoot.borderColor
        border.width: moonSphereRoot.borderWidth
    }
}
