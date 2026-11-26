import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config

// Jendela popup kalender taktis Persona (P3 Reload / P5 Royal)
PanelWindow {
    id: calPopupWin
    visible: PhantomState.calendarOpen

    HyprlandFocusGrab {
        active: calPopupWin.visible
        windows: [calPopupWin]
        onCleared: PhantomState.calendarOpen = false
    }

    WlrLayershell.namespace: "phantomshell-calendar"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: calPopupWin.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusiveZone: 0

    // Key catcher untuk memastikan ESC selalu menutup kalender
    Item {
        id: calKeyCatcher
        anchors.fill: parent
        focus: true
        z: 999

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                PhantomState.calendarOpen = false
                event.accepted = true
            }
        }
    }

    Timer {
        interval: 40
        running: calPopupWin.visible
        repeat: false
        onTriggered: {
            calKeyCatcher.forceActiveFocus()
            if (PhantomState.isP3 && p3CalendarScreen) {
                p3CalendarScreen.forceActiveFocus()
            } else if (p5CalendarScreen) {
                p5CalendarScreen.forceActiveFocus()
            }
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Layar transisi kalender otentik Persona 3 Reload
    P3CalendarScreen {
        id: p3CalendarScreen
        anchors.fill: parent
        visible: PhantomState.isP3
        active: calPopupWin.visible && PhantomState.isP3
    }

    // Layar transisi kalender otentik Persona 5 Royal
    P5CalendarScreen {
        id: p5CalendarScreen
        anchors.fill: parent
        visible: !PhantomState.isP3
        active: calPopupWin.visible && !PhantomState.isP3
    }
}
