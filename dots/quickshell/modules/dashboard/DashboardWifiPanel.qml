import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

// sub-panel daftar jaringan wi-fi dan input kata sandi
ColumnLayout {
    id: wifiSubPanel
    anchors.fill: parent
    anchors.margins: 16
    spacing: 10

    required property var dashWin
    required property Item dashCard

    readonly property var currentNet: (dashWin.selectedWifiIdx >= 0 && dashWin.selectedWifiIdx < PhantomState.wifiNetworks.length)
        ? PhantomState.wifiNetworks[dashWin.selectedWifiIdx]
        : null

    // posisi titik tengah vertikal kartu wi-fi yang sedang dipilih
    readonly property real selectedCardCenterY: wifiSubPanel.y + wifiListView.y
        + (Math.max(0, dashWin.selectedWifiIdx) * (50 + wifiListView.spacing))
        - wifiListView.contentY + 25

    function submitOrFocusPasskey(ssid) {
        if (dashWin.showWifiPasswordBox && wifiPassField.text.length > 0) {
            PhantomState.connectWifi(ssid, wifiPassField.text)
            dashWin.showWifiPasswordBox = false
            wifiPassField.text = ""
        } else {
            dashWin.showWifiPasswordBox = true
            PhantomState.wifiStatusMsg = "TYPE PASSKEY ABOVE & PRESS ENTER"
            wifiPassField.forceActiveFocus()
        }
    }

    // header sub-panel wi-fi beserta tombol kembali, scan, dan power radio
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
                    wifiSubPanel.dashWin.selectedWifiIdx = -1
                    wifiSubPanel.dashWin.showWifiInfo = false
                    wifiSubPanel.dashWin.showWifiPasswordBox = false
                    wifiSubPanel.dashWin.subPanel = "main"
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: "WI-FI TACTICS // SELECT TARGET"
                color: PhantomState.primary
                font.pixelSize: 12
                font.weight: Font.Black
                font.italic: true
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: PhantomState.wifiStatusMsg !== ""
                    ? PhantomState.wifiStatusMsg
                    : ("ACTIVE: " + PhantomState.wifiSsid + " • IP " + PhantomState.wifiIp)
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
                fillColor: PhantomState.wifiScanning ? PhantomState.primary : "#14151F"
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
                    text: PhantomState.wifiScanning ? "..." : "SCAN"
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
                onClicked: PhantomState.scanWifi()
            }
        }

        Item {
            Layout.preferredWidth: 58
            Layout.preferredHeight: 26

            P5SkewedCard {
                anchors.fill: parent
                fillColor: PhantomState.wifiConnected ? "#0E2920" : "#221015"
                borderColor: PhantomState.wifiConnected ? "#00F59B" : "#FF1E2E"
                shadowColor: "#050508"
                borderWidth: 1.5
                skewPx: 5
            }

            Row {
                anchors.centerIn: parent
                spacing: 4
                P5Icon {
                    name: PhantomState.wifiConnected ? "wifi" : "wifi-off"
                    size: 11
                    color: PhantomState.wifiConnected ? "#00F59B" : "#FF1E2E"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: PhantomState.wifiConnected ? "ON" : "OFF"
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
                onClicked: PhantomState.setWifiPower(!PhantomState.wifiConnected)
            }
        }
    }

    // kartu informasi jaringan wi-fi dan kolom input password
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 68

        P5SkewedCard {
            anchors.fill: parent
            fillColor: wifiSubPanel.dashWin.showWifiPasswordBox ? "#0D0E15" : "#12131C"
            borderColor: wifiSubPanel.dashWin.showWifiPasswordBox
                ? PhantomState.secondary
                : (wifiSubPanel.dashWin.showWifiInfo ? "#00F0FF" : "#353548")
            shadowColor: PhantomState.primary
            borderWidth: 1.5
            skewPx: 6
        }

        // tampilan input password jaringan wi-fi
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 12
            spacing: 8
            visible: wifiSubPanel.dashWin.showWifiPasswordBox && wifiSubPanel.currentNet !== null

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: "PASSKEY FOR // " + (wifiSubPanel.currentNet ? wifiSubPanel.currentNet.ssid.toUpperCase() : "")
                    color: PhantomState.secondary
                    font.pixelSize: 9
                    font.weight: Font.Black
                    font.italic: true
                }

                TextInput {
                    id: wifiPassField
                    Layout.fillWidth: true
                    color: "#FFFFFF"
                    font.family: "JetBrainsMono NFM"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    echoMode: TextInput.Password
                    passwordCharacter: "★"
                    clip: true
                    onTextChanged: wifiSubPanel.dashWin.wifiPasswordInput = text
                    onVisibleChanged: {
                        if (visible) {
                            wifiPassField.forceActiveFocus()
                        }
                    }
                    Keys.onReturnPressed: {
                        if (wifiSubPanel.currentNet) {
                            PhantomState.connectWifi(wifiSubPanel.currentNet.ssid, text)
                            wifiSubPanel.dashWin.showWifiPasswordBox = false
                            text = ""
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Type Wi-Fi password & press Enter..."
                        color: "#777788"
                        font.pixelSize: 10
                        visible: wifiPassField.text.length === 0
                    }
                }
            }

            Rectangle {
                width: 58
                height: 28
                color: PhantomState.primary
                border.color: "#FFFFFF"
                border.width: 1.5

                Text {
                    anchors.centerIn: parent
                    text: "JOIN"
                    color: "#FFFFFF"
                    font.pixelSize: 10
                    font.weight: Font.Black
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (wifiSubPanel.currentNet) {
                            PhantomState.connectWifi(wifiSubPanel.currentNet.ssid, wifiPassField.text)
                            wifiSubPanel.dashWin.showWifiPasswordBox = false
                            wifiPassField.text = ""
                        }
                    }
                }
            }
        }

        // tampilan ringkasan informasi jaringan wi-fi aktif
        GridLayout {
            anchors.fill: parent
            anchors.margins: 10
            columns: 2
            rowSpacing: 2
            columnSpacing: 14
            visible: !wifiSubPanel.dashWin.showWifiPasswordBox

            readonly property var inspectNet: (wifiSubPanel.dashWin.showWifiInfo && wifiSubPanel.currentNet)
                ? wifiSubPanel.currentNet
                : null

            Text {
                text: "SSID     : " + (parent.inspectNet ? parent.inspectNet.ssid : PhantomState.wifiSsid)
                color: "#FFFFFF"; font.pixelSize: 10; font.weight: Font.Black; elide: Text.ElideRight; Layout.fillWidth: true
            }
            Text {
                text: "SIGNAL   : " + (parent.inspectNet ? (parent.inspectNet.signal + "%") : (PhantomState.wifiSignal + "%"))
                color: PhantomState.secondary; font.pixelSize: 10; font.weight: Font.Black
            }
            Text {
                text: "SECURITY : " + (parent.inspectNet ? parent.inspectNet.security : PhantomState.wifiSecurity)
                color: "#00F0FF"; font.pixelSize: 10; font.weight: Font.Black
            }
            Text {
                text: "IPV4     : " + PhantomState.wifiIp
                color: "#00F59B"; font.pixelSize: 10; font.weight: Font.Bold
            }
        }
    }

    Text {
        text: wifiSubPanel.currentNet !== null
            ? ("◂ COMMAND MENU OPEN ON THE LEFT FOR: " + wifiSubPanel.currentNet.ssid.toUpperCase())
            : ("AVAILABLE NETWORKS (" + PhantomState.wifiNetworks.length + ") — CLICK A CARD TO POP OUT MENU ON THE LEFT")
        color: wifiSubPanel.currentNet !== null ? PhantomState.secondary : PhantomState.muted
        font.pixelSize: 9
        font.weight: Font.Black
        elide: Text.ElideRight
        Layout.fillWidth: true
    }

    ListView {
        id: wifiListView
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 8
        model: PhantomState.wifiNetworks

        delegate: Item {
            required property var modelData
            required property int index
            width: wifiListView.width
            height: 50
            readonly property bool isSel: wifiSubPanel.dashWin.selectedWifiIdx === index

            P5SkewedCard {
                anchors.fill: parent
                fillColor: parent.isSel ? PhantomState.primary : (modelData.inUse ? "#1A2228" : "#12131A")
                borderColor: parent.isSel ? "#FFFFFF" : (modelData.inUse ? "#00F59B" : "#353545")
                shadowColor: parent.isSel ? PhantomState.secondary : "#050508"
                borderWidth: (parent.isSel || modelData.inUse) ? 2 : 1
                skewPx: 6
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                // indikator panah kiri saat kartu jaringan dipilih
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
                    name: "wifi"
                    size: 15
                    color: modelData.inUse ? "#00F59B" : (parent.parent.isSel ? "#FFFFFF" : PhantomState.secondary)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        Layout.fillWidth: true
                        text: modelData.ssid
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.weight: Font.Black
                        font.italic: true
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "SIGNAL " + modelData.signal + "% • " + modelData.security + ((modelData.saved && !modelData.inUse) ? " • SAVED" : "")
                        color: parent.parent.parent.isSel ? "#08090D" : PhantomState.muted
                        font.pixelSize: 9
                        font.weight: Font.Black
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    visible: modelData.inUse
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
                onClicked: wifiSubPanel.dashWin.selectWifiCard(index, parent)
                onDoubleClicked: {
                    wifiSubPanel.dashWin.animateRadialY = wifiSubPanel.dashWin.radialOpen
                    wifiSubPanel.dashWin.clickedCardCenterY = parent.mapToItem(wifiSubPanel.dashCard, 0, parent.height / 2).y
                    wifiSubPanel.dashWin.selectedWifiIdx = index
                    if (!modelData.inUse) {
                        PhantomState.connectWifi(modelData.ssid, "")
                    }
                }
            }
        }
    }
}
