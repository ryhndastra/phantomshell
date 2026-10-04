import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components

// modul pusat kontrol dan grafik statistik sistem phantomshell
Scope {
    Variants {
        model: Quickshell.screens

        // jendela panel control center dan pengaturan cepat jaringan
        PanelWindow {
            id: dashWin
            required property ShellScreen modelData
            screen: modelData
            visible: PhantomState.dashboardOpen

            HyprlandFocusGrab {
                active: PhantomState.dashboardOpen
                windows: [dashWin]
                onCleared: PhantomState.dashboardOpen = false
            }

            readonly property bool isBottom: PhantomState.barPosition === "bottom"
            property int brightnessPct: 80

            // state navigasi sub-panel dan item jaringan atau perangkat terpilih
            property string subPanel: "main"
            property int selectedWifiIdx: -1
            property bool showWifiInfo: false
            property bool showWifiPasswordBox: false
            property string wifiPasswordInput: ""

            property int selectedBtIdx: -1
            property bool showBtInfo: false
            property real clickedCardCenterY: 195
            property bool animateRadialY: false

            readonly property bool wifiRadialOpen: subPanel === "wifi" && selectedWifiIdx >= 0 && selectedWifiIdx < PhantomState.wifiNetworks.length
            readonly property bool btRadialOpen: subPanel === "bluetooth" && selectedBtIdx >= 0 && selectedBtIdx < PhantomState.btDevices.length
            readonly property bool radialOpen: wifiRadialOpen || btRadialOpen

            // fungsi pemilihan kartu jaringan wi-fi dan pemosisian menu radial
            function selectWifiCard(idx, cardItem) {
                if (selectedWifiIdx === idx) {
                    selectedWifiIdx = -1
                    showWifiInfo = false
                    showWifiPasswordBox = false
                    return
                }
                const wasOpen = radialOpen
                const cy = cardItem.mapToItem(dashCard, 0, cardItem.height / 2).y
                animateRadialY = wasOpen
                clickedCardCenterY = cy
                showWifiPasswordBox = false
                selectedWifiIdx = idx
                if (wasOpen) {
                    leftRadialMenu.restartSwitchPulse()
                }
            }

            function selectBtCard(idx, cardItem) {
                if (selectedBtIdx === idx) {
                    selectedBtIdx = -1
                    showBtInfo = false
                    return
                }
                const wasOpen = radialOpen
                const cy = cardItem.mapToItem(dashCard, 0, cardItem.height / 2).y
                animateRadialY = wasOpen
                clickedCardCenterY = cy
                selectedBtIdx = idx
                if (wasOpen) {
                    leftRadialMenu.restartSwitchPulse()
                }
            }

            WlrLayershell.namespace: "phantomshell-dashboard"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: (PhantomState.dashboardOpen && dashWin.showWifiPasswordBox)
                ? WlrKeyboardFocus.OnDemand
                : WlrKeyboardFocus.None
            exclusiveZone: 0

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            margins {
                top: dashWin.isBottom ? 0 : 38
                bottom: dashWin.isBottom ? 38 : 0
            }

            color: "transparent"

            onVisibleChanged: {
                if (visible) {
                    dashEntryAnim.restart()
                    PhantomState.refreshWifi()
                    PhantomState.refreshBluetooth()
                } else {
                    animateRadialY = false
                    subPanel = "main"
                    selectedWifiIdx = -1
                    selectedBtIdx = -1
                    showWifiInfo = false
                    showBtInfo = false
                    showWifiPasswordBox = false
                }
            }

            // area klik luar untuk menutup control center saat klik di tempat kosong
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (dashWin.radialOpen) {
                        dashWin.closeRadialMenu()
                    } else {
                        PhantomState.dashboardOpen = false
                    }
                }
            }

            Item {
                id: dashCard
                width: Math.min(450, parent.width - 20)
                height: Math.min(640, parent.height - 14)
                anchors.top: !dashWin.isBottom ? parent.top : undefined
                anchors.bottom: dashWin.isBottom ? parent.bottom : undefined
                anchors.right: parent.right
                anchors.topMargin: 4
                anchors.bottomMargin: 4
                anchors.rightMargin: 10
                transformOrigin: dashWin.isBottom ? Item.BottomRight : Item.TopRight

                // penahan klik agar klik di dalam kartu tidak menutup panel
                MouseArea {
                    anchors.fill: parent
                }

                ParallelAnimation {
                    id: dashEntryAnim
                    NumberAnimation {
                        target: dashCard
                        property: "scale"
                        from: 0.85
                        to: 1.0
                        duration: 240
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.35
                    }
                    NumberAnimation {
                        target: dashCard
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                P5SkewedCard {
                    anchors.fill: parent
                    fillColor: PhantomState.background
                    borderColor: PhantomState.borderLight
                    shadowColor: PhantomState.primary
                    borderWidth: 2
                    skewPx: PhantomState.polygonMode ? 8 : 0
                    shadowOffsetX: 4
                    shadowOffsetY: 4
                }

                // tampilan utama control center
                DashboardMainPanel {
                    visible: dashWin.subPanel === "main"
                    dashWin: dashWin
                }

                // sub-panel daftar jaringan wi-fi
                DashboardWifiPanel {
                    id: wifiSubPanel
                    visible: dashWin.subPanel === "wifi"
                    dashWin: dashWin
                    dashCard: dashCard
                }

                // sub-panel daftar perangkat bluetooth
                DashboardBluetoothPanel {
                    id: btSubPanel
                    visible: dashWin.subPanel === "bluetooth"
                    dashWin: dashWin
                    dashCard: dashCard
                }
            }

            // menu aksi radial melayang di sisi kiri kartu jaringan atau perangkat terpilih
            DashboardRadialMenu {
                id: leftRadialMenu
                anchors.right: dashCard.left
                anchors.rightMargin: -6 - (1.0 - openProgress) * 28
                dashWin: dashWin
                dashCard: dashCard
                wifiPanel: wifiSubPanel
                btPanel: btSubPanel
            }
        }
    }
}
