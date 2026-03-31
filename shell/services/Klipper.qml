pragma Singleton

import qs.config
import Webb
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string host: Config.services.klipperHost
    readonly property int port: Config.services.klipperPort
    readonly property string baseUrl: `http://${host}:${port}`
    readonly property bool configured: host !== undefined && host !== null && host.toString().length > 0

    // Connection
    property bool connected: false
    property string errorMessage: ""

    // Print state
    property string printState: "standby"
    property string filename: ""
    property real printProgress: 0
    property real printDuration: 0
    property real estimatedTotal: 0

    // Toolhead
    property real posZ: 0

    // Extruder
    property real extruderTemp: 0
    property real extruderTarget: 0
    property real extruderPower: 0

    // Bed
    property real bedTemp: 0
    property real bedTarget: 0
    property real bedPower: 0

    // Fan
    property real fanSpeed: 0

    // Layers
    property int currentLayer: 0
    property int totalLayers: 0

    // Derived
    readonly property bool isPrinting: printState === "printing"
    readonly property bool isPaused: printState === "paused"
    readonly property bool isActive: isPrinting || isPaused

    readonly property string timeElapsed: formatTime(printDuration)
    readonly property string timeRemaining: {
        if (estimatedTotal <= 0 || printProgress <= 0)
            return "--:--"
        return formatTime(Math.max(0, estimatedTotal - printDuration))
    }
    readonly property string timeETA: {
        if (estimatedTotal <= 0 || printProgress <= 0)
            return "--"
        const remaining = estimatedTotal - printDuration
        const eta = new Date(Date.now() + remaining * 1000)
        return Qt.formatDateTime(eta, Config.services.useTwelveHourClock ? "h:mm AP" : "hh:mm")
    }

    function formatTime(seconds) {
        if (seconds < 0 || isNaN(seconds))
            return "--:--"
        const h = Math.floor(seconds / 3600)
        const m = Math.floor((seconds % 3600) / 60)
        const s = Math.floor(seconds % 60)
        const mm = m.toString().padStart(2, "0")
        const ss = s.toString().padStart(2, "0")
        return h > 0 ? `${h}:${mm}:${ss}` : `${mm}:${ss}`
    }

    function poll() {
        if (!configured)
            return

        const url = `${baseUrl}/printer/objects/query?print_stats&toolhead&extruder&heater_bed&fan&display_status`

        Requests.get(url, text => {
            connected = true
            errorMessage = ""

            try {
                const data = JSON.parse(text).result.status

                const ps = data.print_stats
                if (ps) {
                    printState = ps.state ?? "standby"
                    filename = ps.filename ?? ""
                    printDuration = ps.print_duration ?? 0
                    currentLayer = ps.current_layer ?? 0
                    totalLayers = ps.total_layer ?? 0
                }

                const ds = data.display_status
                if (ds)
                    printProgress = ds.progress ?? 0

                const th = data.toolhead
                if (th) {
                    const pos = th.position ?? [0, 0, 0, 0]
                    posZ = pos[2] ?? 0
                }

                const ex = data.extruder
                if (ex) {
                    extruderTemp = ex.temperature ?? 0
                    extruderTarget = ex.target ?? 0
                    extruderPower = ex.power ?? 0
                }

                const bed = data.heater_bed
                if (bed) {
                    bedTemp = bed.temperature ?? 0
                    bedTarget = bed.target ?? 0
                    bedPower = bed.power ?? 0
                }

                const fan = data.fan
                if (fan)
                    fanSpeed = fan.speed ?? 0

                if (filename.length > 0 && estimatedTotal <= 0 && isActive)
                    fetchMetadata(filename)

            } catch (e) {
                console.warn("[Klipper] Parse error:", e)
            }
        }, err => {
            connected = false
            errorMessage = err ?? "Connection failed"
        })
    }

    function fetchMetadata(file) {
        Requests.get(`${baseUrl}/server/files/metadata?filename=${encodeURIComponent(file)}`, text => {
            try {
                const meta = JSON.parse(text).result
                if (meta.estimated_time)
                    estimatedTotal = meta.estimated_time
                if (meta.layer_count)
                    totalLayers = meta.layer_count
            } catch (e) {}
        }, () => {})
    }

    function pause() {
        Requests.get(`${baseUrl}/printer/print/pause`, () => {}, () => {})
    }
    function resume() {
        Requests.get(`${baseUrl}/printer/print/resume`, () => {}, () => {})
    }
    function cancel() {
        Requests.get(`${baseUrl}/printer/print/cancel`, () => {}, () => {})
    }

    Timer {
        running: root.configured
        repeat: true
        interval: root.isActive ? 2000 : 5000
        onTriggered: root.poll()
    }

    onHostChanged: {
        connected = false
        estimatedTotal = 0
        root.poll()
    }

    Component.onCompleted: root.poll()
}
