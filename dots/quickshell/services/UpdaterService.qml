import QtQuick
import Quickshell
import Quickshell.Io

// layanan pembaruan git dan sinkronisasi konfigurasi phantomshell
Scope {
    id: root

    readonly property string syncScriptPath: "/mnt/data/Projects/rice/phantomshell/scripts/phantom-sync"

    property string syncStatus: "IDLE"
    property string syncLog: ""
    property var syncLogLines: []
    property string gitBranch: "main"
    property string gitLocalHash: "-------"
    property string gitRemoteHash: "-------"
    property int gitAhead: 0
    property int gitBehind: 0
    property string gitLastMsg: "Ready"
    property string gitLastDate: ""
    property bool syncUpdateAvailable: false
    property bool syncBusy: false

    function appendSyncLog(line) {
        const lines = root.syncLogLines.slice()
        lines.push(line)
        if (lines.length > 60) lines.splice(0, lines.length - 60)
        root.syncLogLines = lines
        root.syncLog = lines.join("\n")
    }

    function clearSyncLog() {
        root.syncLogLines = []
        root.syncLog = ""
    }

    function refreshGitStatus() {
        syncStatusProc.running = false
        syncStatusProc.running = true
    }

    // proses cek status git lokal saat shell dimulai
    Process {
        id: syncStatusProc
        running: true
        command: ["bash", root.syncScriptPath, "status"]
        stdout: SplitParser {
            onRead: data => {
                const line = String(data).trim()
                if (!line) return
                if (line.indexOf("STATUS|") === 0) {
                    const p = line.split("|")
                    if (p.length >= 6) {
                        root.gitBranch = p[1] || "main"
                        root.gitLocalHash = p[2] || "-------"
                        root.gitLastMsg = p[4] || ""
                        root.gitLastDate = p[5] || ""
                        if (root.syncStatus === "IDLE") {
                            root.syncStatus = "UP_TO_DATE"
                        }
                    }
                }
            }
        }
    }

    // proses cek update dari remote github
    Process {
        id: syncCheckProc
        command: ["bash", root.syncScriptPath, "check-remote"]
        stdout: SplitParser {
            onRead: data => {
                const line = String(data).trim()
                if (!line) return
                if (line.indexOf("REMOTE_CHECK|") === 0) {
                    const p = line.split("|")
                    if (p.length >= 8) {
                        root.gitBranch = p[1] || "main"
                        root.gitLocalHash = p[2] || "-------"
                        root.gitRemoteHash = p[3] || "-------"
                        root.gitAhead = parseInt(p[4], 10) || 0
                        root.gitBehind = parseInt(p[5], 10) || 0
                        root.gitLastMsg = p[6] || ""
                        root.gitLastDate = p[7] || ""
                        root.syncUpdateAvailable = root.gitBehind > 0

                        if (root.gitBehind > 0) {
                            root.syncStatus = "UPDATE_AVAILABLE"
                            root.appendSyncLog("★ Update tersedia! " + root.gitBehind + " commit baru di origin/" + root.gitBranch + " (" + root.gitRemoteHash + ")")
                            root.appendSyncLog("  Commit terbaru: " + root.gitLastMsg)
                        } else if (root.gitAhead > 0) {
                            root.syncStatus = "UP_TO_DATE"
                            root.appendSyncLog("✓ Sudah paling update! Repo lokal " + root.gitAhead + " commit lebih maju dari origin/" + root.gitBranch + " (" + root.gitLocalHash + ")")
                        } else {
                            root.syncStatus = "UP_TO_DATE"
                            root.appendSyncLog("✓ Sudah paling update! (" + root.gitBranch + " @ " + root.gitLocalHash + ")")
                        }
                    }
                } else if (line.indexOf("ERR|") === 0) {
                    root.syncStatus = "OFFLINE"
                    root.appendSyncLog("✗ " + line.slice(4))
                }
                root.syncBusy = false
            }
        }
        onExited: root.syncBusy = false
    }

    // proses pull + sync + reload lengkap
    Process {
        id: syncPullSyncProc
        command: ["bash", root.syncScriptPath, "pull-sync"]
        stdout: SplitParser {
            onRead: data => {
                const line = String(data).trim()
                if (!line) return
                if (line.indexOf("PULL_START|") === 0) {
                    root.syncStatus = "PULLING"
                    root.appendSyncLog("↓ " + line.slice(11))
                } else if (line.indexOf("PULL_LOG|") === 0) {
                    root.appendSyncLog("  " + line.slice(9))
                } else if (line.indexOf("PULL_DONE|") === 0) {
                    const p = line.split("|")
                    const kind = p[1] || ""
                    const msg = p[2] || ""
                    if (kind === "UPDATED") {
                        root.syncStatus = "SYNCING"
                        root.appendSyncLog("✓ " + msg)
                    } else {
                        root.appendSyncLog("✓ " + msg)
                    }
                } else if (line.indexOf("SYNC_START|") === 0) {
                    root.syncStatus = "SYNCING"
                    root.appendSyncLog("↗ " + line.slice(11))
                } else if (line.indexOf("SYNC_LOG|") === 0) {
                    root.appendSyncLog("  " + line.slice(9))
                } else if (line.indexOf("SYNC_OK|") === 0) {
                    root.appendSyncLog("✓ synced " + line.slice(8))
                } else if (line.indexOf("SYNC_WARN|") === 0) {
                    root.appendSyncLog("⚠ " + line.slice(10))
                } else if (line.indexOf("SYNC_DONE|") === 0) {
                    root.syncStatus = "RELOADING"
                    root.appendSyncLog("✓ " + line.slice(10))
                } else if (line.indexOf("RELOAD_START|") === 0) {
                    root.appendSyncLog("↺ " + line.slice(13))
                } else if (line.indexOf("RELOAD_DONE|") === 0) {
                    root.syncStatus = "DONE"
                    root.syncUpdateAvailable = false
                    root.appendSyncLog("★ " + line.slice(12))
                    syncDoneTimer.restart()
                } else if (line.indexOf("ERR|") === 0) {
                    root.syncStatus = "ERROR"
                    root.appendSyncLog("✗ " + line.slice(4))
                    syncDoneTimer.restart()
                }
            }
        }
        onExited: {
            root.syncBusy = false
            if (root.syncStatus !== "DONE" && root.syncStatus !== "ERROR") {
                root.syncStatus = "DONE"
                syncDoneTimer.restart()
            }
            syncStatusProc.running = false
            syncStatusProc.running = true
        }
    }

    // proses sync saja (tanpa pull), buat penerapan ke sistem lokal
    Process {
        id: syncOnlyProc
        command: ["bash", root.syncScriptPath, "sync"]
        stdout: SplitParser {
            onRead: data => {
                const line = String(data).trim()
                if (!line) return
                if (line.indexOf("SYNC_START|") === 0) {
                    root.syncStatus = "SYNCING"
                    root.appendSyncLog("↗ " + line.slice(11))
                } else if (line.indexOf("SYNC_LOG|") === 0) {
                    root.appendSyncLog("  " + line.slice(9))
                } else if (line.indexOf("SYNC_OK|") === 0) {
                    root.appendSyncLog("✓ synced " + line.slice(8))
                } else if (line.indexOf("SYNC_WARN|") === 0) {
                    root.appendSyncLog("⚠ " + line.slice(10))
                } else if (line.indexOf("SYNC_DONE|") === 0) {
                    root.syncStatus = "DONE"
                    root.appendSyncLog("★ " + line.slice(10))
                    syncDoneTimer.restart()
                } else if (line.indexOf("ERR|") === 0) {
                    root.syncStatus = "ERROR"
                    root.appendSyncLog("✗ " + line.slice(4))
                    syncDoneTimer.restart()
                }
            }
        }
        onExited: {
            root.syncBusy = false
            if (root.syncStatus !== "DONE" && root.syncStatus !== "ERROR") {
                root.syncStatus = "DONE"
                syncDoneTimer.restart()
            }
        }
    }

    Timer {
        id: syncDoneTimer
        interval: 4000
        repeat: false
        onTriggered: {
            if (root.syncStatus === "DONE" || root.syncStatus === "ERROR") {
                root.syncStatus = "UP_TO_DATE"
            }
        }
    }

    function checkSyncUpdate() {
        if (root.syncBusy) return
        root.syncBusy = true
        root.syncStatus = "CHECKING"
        root.clearSyncLog()
        root.appendSyncLog("★ Checking remote origin/main...")
        syncCheckProc.running = false
        syncCheckProc.running = true
    }

    function syncToSystem() {
        if (root.syncBusy) return
        root.syncBusy = true
        root.clearSyncLog()
        root.appendSyncLog("★ Applying local dev changes to system config...")
        syncOnlyProc.running = false
        syncOnlyProc.running = true
    }

    function pullAndSync() {
        if (root.syncBusy) return
        root.syncBusy = true
        root.clearSyncLog()
        root.appendSyncLog("★ Initiating full phantom sync operation...")
        syncPullSyncProc.running = false
        syncPullSyncProc.running = true
    }
}
