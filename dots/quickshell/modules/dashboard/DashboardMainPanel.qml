import QtQuick
import QtQuick.Layouts
import qs.config
import "main"

// composer tipis control center: menyusun blok header, slider, aksi, preset, statistik, dan settings
ColumnLayout {
    id: mainPanel
    anchors.fill: parent
    anchors.margins: 16
    spacing: 12

    required property var dashWin

    function openSubPanel(name) {
        if (name !== "wifi" && name !== "bluetooth") return
        dashWin.subPanel = name
        dashWin.selectedWifiIdx = -1
        dashWin.selectedBtIdx = -1
        dashWin.showWifiInfo = false
        dashWin.showBtInfo = false
        if (name === "wifi") PhantomState.refreshWifi()
        else PhantomState.refreshBluetooth()
    }

    DashboardHeader {
        onCloseRequested: PhantomState.dashboardOpen = false
    }

    DashboardSliderStack {
        dashWin: mainPanel.dashWin
    }

    DashboardActionGrid {
        dashWin: mainPanel.dashWin
        onRequestSubPanel: name => mainPanel.openSubPanel(name)
    }

    DashboardPresetRow {
        onPresetChosen: id => PhantomState.applyPreset(id)
    }

    DashboardStatsSection {
        onStatsStyleToggled: style => {
            PhantomState.statsStyle = style
            PhantomState.saveState()
        }
    }

    DashboardSettingsButton {}
}
