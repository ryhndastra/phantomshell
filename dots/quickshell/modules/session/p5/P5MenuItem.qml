import QtQuick
import Quickshell
import qs.config

Item {
    id: root

    property string normalSource: ""
    property string selectedSource: ""
    property string selectedSource2: ""
    property string labelText: ""
    property string subText: ""
    property int itemIndex: 0
    property bool isSelected: false
    property real baseRotation: -1.5
    property real rightEdgeX: 900
    property real targetY: 200

    signal triggered()
    signal hovered()

    property real selectOffsetX: isSelected ? -16 : 0
    property real selectOffsetY: isSelected ? -4 : 0

    Behavior on selectOffsetX { NumberAnimation { duration: 120; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
    Behavior on selectOffsetY { NumberAnimation { duration: 120; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }

    function playEntrance() {
        // Buttons appear instantly on slap impact without delayed lag!
    }

    width: itemImage.implicitWidth > 0 ? itemImage.implicitWidth : 320
    height: itemImage.implicitHeight > 0 ? itemImage.implicitHeight : 90

    // Align right edge along Joker's hand diagonal split line
    x: rightEdgeX - width + selectOffsetX
    y: targetY + selectOffsetY
    opacity: 1.0

    scale: isSelected ? 1.04 : 1.0
    rotation: isSelected ? (baseRotation - 1.2) : baseRotation

    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
    Behavior on rotation { NumberAnimation { duration: 120; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }

    Image {
        id: itemImage
        anchors.fill: parent
        source: root.isSelected ? root.selectedSource : root.normalSource
        fillMode: Image.PreserveAspectFit
        cache: false
        mipmap: true
        smooth: true
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered()
        onClicked: root.triggered()
    }
}
