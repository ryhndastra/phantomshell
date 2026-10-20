import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

// tiga slider kontrol utama: audio, kecerahan layar, dan efek suara notifikasi
ColumnLayout {
    id: root

    required property var dashWin

    Layout.fillWidth: true
    spacing: 12

    P5SliderControl {
        label: "audio"
        value: PhantomState.volumePct / 100.0
        valueText: PhantomState.volumePct + "%"
        activeColor: PhantomState.primary
        leftTag: "min"
        rightTag: "max"

        onValuePicked: pct => PhantomState.setSystemVolume(pct)
        onCommitted: PhantomState.saveState()
    }

    P5SliderControl {
        label: "light"
        value: root.dashWin.brightnessPct / 100.0
        valueText: root.dashWin.brightnessPct + "%"
        activeColor: PhantomState.primary
        leftTag: "dim"
        rightTag: "brt"

        onValuePicked: pct => {
            var clamped = pct < 5 ? 5 : pct
            root.dashWin.brightnessPct = clamped
            Quickshell.execDetached(["brightnessctl", "set", clamped + "%"])
        }
        onCommitted: PhantomState.saveState()
    }

    P5SliderControl {
        label: "notif"
        value: PhantomState.sfxEnabled ? PhantomState.sfxVolume : 0.0
        valueText: PhantomState.sfxEnabled ? Math.round(PhantomState.sfxVolume * 100) + "%" : "OFF"
        activeColor: PhantomState.primary
        dimmer: !PhantomState.sfxEnabled
        leftTag: "mute"
        rightTag: "max"

        onValuePicked: pct => {
            PhantomState.sfxVolume = pct / 100.0
            PhantomState.sfxEnabled = pct > 0
        }
        onCommitted: PhantomState.saveState()
    }
}
