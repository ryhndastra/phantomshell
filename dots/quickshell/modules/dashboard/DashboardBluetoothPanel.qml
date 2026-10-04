import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// sub-panel daftar perangkat bluetooth
ColumnLayout {
    id: btSubPanel
    anchors.fill: parent
    anchors.margins: 16
    spacing: 10

    required property var dashWin
    required property Item dashCard

    readonly property var currentBt: (dashWin.selectedBtIdx >= 0 && dashWin.selectedBtIdx < PhantomState.btDevices.length)
        ? PhantomState.btDevices[dashWin.selectedBtIdx]
        : null

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Item {
            Layout.preferredWidth: 68
            Layout.preferredHeight: 28

            P5SkewedCard {
                anchors.fill: parent
                fillColor: PhantomState.surfaceAlt
                borderColor: "#FFFFFF"
                shadowColor: PhantomState.primary
                borderWidth: 1.5
                skewPx: 5
            }

            Row {
                anchors.centerIn: parent
                spacing: 4
                P5Icon { name: "chevron-left"; size: 11; color: PhantomState.secondary; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: "BACK"
                    color: "#FFFFFF"
                    font.pixelSize: 10
                    font.weight: Font.Black
                    font.italic: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    btSubPanel.dashWin.selectedBtIdx = -1
                    btSubPanel.dashWin.showBtInfo = false
                    btSubPanel.dashWin.subPanel = "main"
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: "BLUETOOTH TACTICS // SELECT TARGET"
                color: PhantomState.primary
                font.pixelSize: 12
                font.weight: Font.Black
                font.italic: true
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: PhantomState.btStatusMsg !== ""
                    ? PhantomState.btStatusMsg
                    : ("STATUS: " + PhantomState.btDeviceName)
                color: PhantomState.secondary
                font.pixelSize: 9
                font.weight: Font.Bold
                elide: Text.ElideRight
            }
        }

        Item {
            Layout.preferredWidth: 62
            Layout.preferredHeight: 26

            P5SkewedCard {
                anchors.fill: parent
                fillColor: PhantomState.btScanning ? PhantomState.primary : "#14151F"
                borderColor: "#FFD700"
                shadowColor: PhantomState.primary
                borderWidth: 1.5
                skewPx: 5
            }

            Row {
                anchors.centerIn: parent
                spacing: 4
                P5Icon { name: "scan"; size: 11; color: "#FFD700"; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: PhantomState.btScanning ? "..." : "SCAN"
                    color: "#FFFFFF"
                    font.pixelSize: 9
                    font.weight: Font.Black
                    font.italic: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: PhantomState.scanBluetooth()
            }
        }

        Item {
            Layout.preferredWidth: 58
            Layout.preferredHeight: 26

            P5SkewedCard {
                anchors.fill: parent
                fillColor: PhantomState.btConnected ? "#0E2920" : "#221015"
                borderColor: PhantomState.btConnected ? "#00F59B" : "#FF1E2E"
                shadowColor: "#050508"
                borderWidth: 1.5
                skewPx: 5
            }

            Row {
                anchors.centerIn: parent
                spacing: 4
                P5Icon {
                    name: "power"
                    size: 11
                    color: PhantomState.btConnected ? "#00F59B" : "#FF1E2E"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: PhantomState.btConnected ? "ON" : "OFF"
                    color: "#FFFFFF"
                    font.pixelSize: 9
                    font.weight: Font.Black
                    font.italic: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: PhantomState.setBluetoothPower(!PhantomState.btConnected)
            }
        }
    }

    // kartu ringkasan status perangkat bluetooth
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 68

        P5SkewedCard {
            anchors.fill: parent
            fillColor: "#12131C"
            borderColor: btSubPanel.dashWin.showBtInfo ? "#48CAE4" : "#353548"
            shadowColor: PhantomState.primary
            borderWidth: 1.5
            skewPx: 6
        }

        GridLayout {
            anchors.fill: parent
            anchors.margins: 10
            columns: 2
            rowSpacing: 2
            columnSpacing: 14

            readonly property var inspectBt: (btSubPanel.dashWin.showBtInfo && btSubPanel.currentBt)
                ? btSubPanel.currentBt
                : null

            Text {
                text: "DEVICE : " + (parent.inspectBt ? parent.inspectBt.name : PhantomState.btDeviceName)
                color: "#FFFFFF"; font.pixelSize: 10; font.weight: Font.Black; elide: Text.ElideRight; Layout.fillWidth: true
            }
            Text {
                text: "ADAPTER: " + (PhantomState.btConnected ? "POWERED ON" : "POWERED OFF")
                color: PhantomState.secondary; font.pixelSize: 10; font.weight: Font.Black
            }
            Text {
                text: "MAC    : " + (parent.inspectBt ? parent.inspectBt.mac : (PhantomState.btDeviceMac !== "" ? PhantomState.btDeviceMac : "N/A"))
                color: "#48CAE4"; font.pixelSize: 10; font.weight: Font.Bold; Layout.columnSpan: 2
            }
        }
    }

    Text {
        text: btSubPanel.currentBt !== null
            ? ("◂ COMMAND MENU OPEN ON THE LEFT FOR: " + btSubPanel.currentBt.name.toUpperCase())
            : ("BLUETOOTH DEVICES (" + PhantomState.btDevices.length + ") — CLICK A CARD TO POP OUT MENU ON THE LEFT")
        color: btSubPanel.currentBt !== null ? PhantomState.secondary : PhantomState.muted
        font.pixelSize: 9
        font.weight: Font.Black
        elide: Text.ElideRight
        Layout.fillWidth: true
    }

    Item {
        id: btListContainer
        Layout.fillWidth: true
        Layout.fillHeight: true

        Column {
            anchors.centerIn: parent
            spacing: 6
            visible: PhantomState.btDevices.length === 0

            P5Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: "bluetooth"
                size: 28
                color: PhantomState.primary
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: PhantomState.btScanning ? "SCANNING FOR DEVICES..." : "NO BLUETOOTH DEVICES FOUND"
                color: "#FFFFFF"
                font.pixelSize: 12
                font.weight: Font.Black
                font.italic: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Click 'SCAN' in the top right to search nearby devices."
                color: PhantomState.muted
                font.pixelSize: 9
                font.weight: Font.Bold
            }
        }

        ListView {
            id: btListView
            anchors.fill: parent
            clip: true
            spacing: 8
            visible: PhantomState.btDevices.length > 0
            model: PhantomState.btDevices

            delegate: Item {
                required property var modelData
                required property int index
                width: btListView.width
                height: 50
                readonly property bool isSel: btSubPanel.dashWin.selectedBtIdx === index

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: parent.isSel ? PhantomState.primary : (modelData.connected ? "#1A2228" : "#12131A")
                    borderColor: parent.isSel ? "#FFFFFF" : (modelData.connected ? "#00F59B" : "#353545")
                    shadowColor: parent.isSel ? PhantomState.secondary : "#050508"
                    borderWidth: (parent.isSel || modelData.connected) ? 2 : 1
                    skewPx: 6
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Rectangle {
                        visible: parent.parent.isSel
                        width: 24
                        height: 22
                        color: "#08090D"
                        border.color: PhantomState.secondary
                        border.width: 1.5
                        rotation: 6

                        P5Icon {
                            anchors.centerIn: parent
                            name: "chevron-left"
                            size: 12
                            color: PhantomState.secondary
                        }
                    }

                    P5Icon {
                        name: "bluetooth"
                        size: 15
                        color: modelData.connected ? "#00F59B" : (parent.parent.isSel ? "#FFFFFF" : "#48CAE4")
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.weight: Font.Black
                            font.italic: true
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.mac + (modelData.paired ? " • PAIRED" : " • DISCOVERED")
                            color: parent.parent.parent.isSel ? "#08090D" : PhantomState.muted
                            font.pixelSize: 9
                            font.weight: Font.Black
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        visible: modelData.connected
                        width: 72
                        height: 20
                        color: "#00F59B"
                        border.color: "#08090D"
                        border.width: 1.5
                        rotation: -3

                        Text {
                            anchors.centerIn: parent
                            text: "★ LINKED"
                            color: "#08090D"
                            font.pixelSize: 8
                            font.weight: Font.Black
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: btSubPanel.dashWin.selectBtCard(index, parent)
                    onDoubleClicked: {
                        btSubPanel.dashWin.animateRadialY = btSubPanel.dashWin.radialOpen
                        btSubPanel.dashWin.clickedCardCenterY = parent.mapToItem(btSubPanel.dashCard, 0, parent.height / 2).y
                        btSubPanel.dashWin.selectedBtIdx = index
                        if (modelData.connected) PhantomState.disconnectBluetooth(modelData.mac, modelData.name)
                        else PhantomState.connectBluetooth(modelData.mac, modelData.name)
                    }
                }
            }
        }
    }
}
