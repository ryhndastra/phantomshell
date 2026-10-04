import QtQuick
import Quickshell
import Quickshell.Io

// layanan manajemen monitor, resolusi, refresh rate, dan mode proyektor hyprland
Scope {
    id: root

    signal sfxRequested(string kind)

    property var monitorList: ([{
        name: "eDP-1",
        description: "Chimei Innolux Corporation 0x1521",
        width: 1920,
        height: 1080,
        refreshRate: 144.0,
        x: 0,
        y: 0,
        scale: 1.0,
        transform: 0,
        disabled: false,
        mirrorOf: "none",
        availableModes: ["1920x1080@144.00Hz", "1920x1080@60.02Hz"]
    }])
    property int selectedMonitorIdx: 0
    property string displayName: "eDP-1"
    property string displayDesc: "Chimei Innolux Corporation 0x1521"
    property bool displayEnabled: true
    property string displayMode: "1920x1080@144.00Hz"
    property var displayAvailableModes: ["1920x1080@144.00Hz", "1920x1080@60.02Hz"]
    property int displayTransform: 0
    property int displayScalePct: 100
    property int displayPosX: 0
    property int displayPosY: 0
    property string displayMirrorOf: "none"
    property string presentationMode: "extend"
    property bool _displayAutoOptimized: false

    Process {
        id: monitorsProc
        command: ["hyprctl", "monitors", "all", "-j"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    const arr = JSON.parse(data)
                    if (Array.isArray(arr) && arr.length > 0) {
                        root.monitorList = arr
                        if (root.selectedMonitorIdx >= arr.length) {
                            root.selectedMonitorIdx = 0
                        }
                        root.loadMonitorIntoState(root.selectedMonitorIdx)
                    }
                } catch (e) {}
            }
        }
    }

    function refreshMonitors() {
        monitorsProc.running = true
    }

    function parseModeScore(modeStr) {
        const m = String(modeStr).match(/(\d+)x(\d+)@([\d.]+)/)
        if (!m) return { pixels: 0, rate: 0 }
        return {
            pixels: Number(m[1]) * Number(m[2]),
            rate: Number(m[3])
        }
    }

    function sortDisplayModes(rawModes) {
        const seen = {}
        const unique = []
        for (let i = 0; i < rawModes.length; i++) {
            const s = String(rawModes[i]).trim()
            if (s && !seen[s]) {
                seen[s] = true
                unique.push(s)
            }
        }
        unique.sort(function(a, b) {
            const sa = root.parseModeScore(a)
            const sb = root.parseModeScore(b)
            if (sb.pixels !== sa.pixels) return sb.pixels - sa.pixels
            return sb.rate - sa.rate
        })
        return unique
    }

    function loadMonitorIntoState(idx) {
        if (!root.monitorList || idx < 0 || idx >= root.monitorList.length) return
        root.selectedMonitorIdx = idx
        const m = root.monitorList[idx]
        root.displayName = m.name || "eDP-1"
        root.displayDesc = m.description || m.model || "Display"
        root.displayEnabled = !m.disabled

        let rawModes = (m.availableModes && m.availableModes.length > 0)
            ? m.availableModes.slice()
            : [(m.width || 1920) + "x" + (m.height || 1080) + "@" + Number(m.refreshRate || 144).toFixed(2) + "Hz"]

        // daftar mode fallback saat berjalan di sesi nested wayland
        if (String(root.displayName).indexOf("WAYLAND") === 0 || rawModes.length <= 1) {
            const fallbackModes = [
                "1920x1080@144.00Hz",
                "1920x1080@120.00Hz",
                "1920x1080@60.02Hz",
                "1920x1080@60.00Hz",
                "1600x900@60.00Hz",
                "1280x720@60.00Hz"
            ]
            for (let i = 0; i < fallbackModes.length; i++) {
                rawModes.push(fallbackModes[i])
            }
        }

        const modes = root.sortDisplayModes(rawModes)
        root.displayAvailableModes = modes

        // pilih mode resolusi dan refresh rate tertinggi sebagai default
        const bestMode = modes[0] || "1920x1080@144.00Hz"
        const curRate = Number(m.refreshRate || 144).toFixed(2)
        const curModeGuess = (m.width || 1920) + "x" + (m.height || 1080) + "@" + curRate + "Hz"

        if (!root._displayAutoOptimized) {
            root._displayAutoOptimized = true
            root.displayMode = bestMode
            if (String(root.displayName).indexOf("WAYLAND") !== 0 && curModeGuess !== bestMode) {
                Qt.callLater(function() { root.applyDisplayConfig() })
            }
        } else {
            root.displayMode = modes.indexOf(curModeGuess) !== -1 ? curModeGuess : bestMode
        }

        root.displayTransform = Number(m.transform || 0)
        root.displayScalePct = Math.round(Number(m.scale || 1.0) * 100)
        root.displayPosX = Number(m.x || 0)
        root.displayPosY = Number(m.y || 0)
        root.displayMirrorOf = (m.mirrorOf && m.mirrorOf !== "none") ? m.mirrorOf : "none"
    }

    function cycleSelectedMonitor() {
        if (!root.monitorList || root.monitorList.length <= 1) {
            refreshMonitors()
            return
        }
        const nextIdx = (root.selectedMonitorIdx + 1) % root.monitorList.length
        loadMonitorIntoState(nextIdx)
    }

    function setDisplayMode(modeStr) {
        if (!modeStr) return
        root.displayMode = modeStr
        applyDisplayConfig()
        root.sfxRequested("select")
    }

    function cycleDisplayMode() {
        if (!root.displayAvailableModes || root.displayAvailableModes.length === 0) return
        const idx = root.displayAvailableModes.indexOf(root.displayMode)
        const nextIdx = (idx + 1) % root.displayAvailableModes.length
        setDisplayMode(root.displayAvailableModes[nextIdx])
    }

    function setDisplayTransform(t) {
        root.displayTransform = t
        applyDisplayConfig()
    }

    function applyDisplayConfig() {
        if (!root.displayEnabled && root.monitorList.length > 1) {
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", root.displayName + ",disable"])
            return
        }
        const cleanMode = root.displayMode.replace("Hz", "")
        const scaleVal = (Math.max(50, Math.min(300, root.displayScalePct)) / 100.0).toFixed(2)
        let rule = root.displayName + "," + cleanMode + "," + root.displayPosX + "x" + root.displayPosY + "," + scaleVal + ",transform," + root.displayTransform
        if (root.displayMirrorOf !== "none" && root.displayMirrorOf !== root.displayName) {
            rule += ",mirror," + root.displayMirrorOf
        }
        Quickshell.execDetached(["hyprctl", "keyword", "monitor", rule])
    }

    function setPresentationMode(mode) {
        root.presentationMode = mode
        const primaryMon = (root.monitorList && root.monitorList.length > 0) ? root.monitorList[0].name : "eDP-1"
        if (mode === "extend") {
            Quickshell.execDetached(["bash", "-c",
                "hyprctl keyword monitor ',preferred,auto,1'; " +
                "for m in $(hyprctl monitors all -j | grep -o '\"name\": *\"[^\"]*\"' | cut -d'\"' -f4); do " +
                "  if [ \"$m\" != \"" + primaryMon + "\" ]; then hyprctl keyword monitor \"$m,preferred,auto,1\"; fi; " +
                "done"
            ])
        } else if (mode === "mirror-auto") {
            Quickshell.execDetached(["bash", "-c",
                "hyprctl keyword monitor ',preferred,auto,1,mirror," + primaryMon + "'; " +
                "for m in $(hyprctl monitors all -j | grep -o '\"name\": *\"[^\"]*\"' | cut -d'\"' -f4); do " +
                "  if [ \"$m\" != \"" + primaryMon + "\" ]; then hyprctl keyword monitor \"$m,preferred,auto,1,mirror," + primaryMon + "\"; fi; " +
                "done"
            ])
        } else if (mode === "mirror-1080p") {
            Quickshell.execDetached(["bash", "-c",
                "hyprctl keyword monitor ',1920x1080@60,auto,1,mirror," + primaryMon + "'; " +
                "for m in $(hyprctl monitors all -j | grep -o '\"name\": *\"[^\"]*\"' | cut -d'\"' -f4); do " +
                "  if [ \"$m\" != \"" + primaryMon + "\" ]; then hyprctl keyword monitor \"$m,1920x1080@60,auto,1,mirror," + primaryMon + "\"; fi; " +
                "done"
            ])
        } else if (mode === "mirror-720p") {
            Quickshell.execDetached(["bash", "-c",
                "hyprctl keyword monitor ',1280x720@60,auto,1,mirror," + primaryMon + "'; " +
                "for m in $(hyprctl monitors all -j | grep -o '\"name\": *\"[^\"]*\"' | cut -d'\"' -f4); do " +
                "  if [ \"$m\" != \"" + primaryMon + "\" ]; then hyprctl keyword monitor \"$m,1280x720@60,auto,1,mirror," + primaryMon + "\"; fi; " +
                "done"
            ])
        }
        refreshMonitors()
    }
}
