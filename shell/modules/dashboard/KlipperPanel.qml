import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    implicitWidth: Math.max(840, layout.implicitWidth)
    implicitHeight: layout.implicitHeight

    Component.onCompleted: Klipper.poll()

    // ── Not configured ────────────────────────────────────────────────────────
    Loader {
        active: !Klipper.configured
        anchors.fill: parent

        sourceComponent: Item {
            implicitWidth: 840
            implicitHeight: 300

            StyledRect {
                anchors.centerIn: parent
                implicitWidth: 400
                implicitHeight: 200
                radius: Appearance.rounding.large
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Appearance.spacing.normal

                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        text: "print_disabled"
                        font.pointSize: Appearance.font.size.extraLarge * 2
                        color: Colours.palette.m3onSurfaceVariant
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("No printer configured")
                        font.pointSize: Appearance.font.size.large
                        font.weight: Font.Medium
                        color: Colours.palette.m3onSurface
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Add klipperHost to shell.json under services")
                        font.pointSize: Appearance.font.size.small
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
            }
        }
    }

    // ── Main layout (when configured) ─────────────────────────────────────────
    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: Appearance.spacing.smaller

        visible: Klipper.configured

        // ── Header row ────────────────────────────────────────────────────────
        RowLayout {
            Layout.leftMargin: Appearance.padding.large
            Layout.rightMargin: Appearance.padding.large
            Layout.fillWidth: true

            // Left: printer name / state
            Column {
                spacing: Appearance.spacing.small / 2

                StyledText {
                    text: Klipper.connected ? {
                        "printing":  qsTr("Printing"),
                        "paused":    qsTr("Paused"),
                        "complete":  qsTr("Complete"),
                        "error":     qsTr("Error"),
                        "cancelled": qsTr("Cancelled"),
                    }[Klipper.printState] ?? qsTr("Standby")
                    : qsTr("Connecting...")
                    font.pointSize: Appearance.font.size.extraLarge
                    font.weight: 600
                    color: Colours.palette.m3onSurface
                }

                StyledText {
                    text: Klipper.filename.length > 0
                        ? Klipper.filename
                        : Klipper.host
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3onSurfaceVariant
                    elide: Text.ElideRight
                    width: 300
                }
            }

            Item { Layout.fillWidth: true }

            // Right: time stats (only when active)
            Row {
                spacing: Appearance.spacing.large
                visible: Klipper.isActive

                PrintStat {
                    icon: "schedule"
                    label: qsTr("Elapsed")
                    value: Klipper.timeElapsed
                    colour: Colours.palette.m3tertiary
                }

                PrintStat {
                    icon: "timer"
                    label: qsTr("ETA")
                    value: Klipper.timeETA
                    colour: Colours.palette.m3tertiary
                }
            }

            // Connection dot (always visible)
            Item {
                implicitWidth: dot.implicitWidth + Appearance.spacing.small
                implicitHeight: dot.implicitHeight

                StyledRect {
                    id: dot
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    implicitWidth: Appearance.spacing.small + 2
                    implicitHeight: Appearance.spacing.small + 2
                    radius: Appearance.rounding.full
                    color: Klipper.connected
                        ? Colours.palette.m3success ?? Colours.palette.m3primary
                        : Colours.palette.m3error

                    ToolTip.visible: dotHover.containsMouse
                    ToolTip.text: Klipper.connected
                        ? qsTr("Connected to %1:%2").arg(Klipper.host).arg(Klipper.port)
                        : (Klipper.errorMessage.length > 0 ? Klipper.errorMessage : qsTr("Disconnected"))

                    HoverHandler { id: dotHover }

                    Behavior on color { CAnim {} }
                }
            }
        }

        // ── Hero card: progress + Z height ────────────────────────────────────
        StyledRect {
            Layout.fillWidth: true
            implicitHeight: heroContent.implicitHeight + Appearance.padding.small * 2

            radius: Appearance.rounding.large * 2
            color: Colours.tPalette.m3surfaceContainer

            RowLayout {
                id: heroContent

                anchors.centerIn: parent
                width: parent.width - Appearance.padding.large * 2
                spacing: Appearance.spacing.large

                // Big state icon
                MaterialIcon {
                    Layout.alignment: Qt.AlignVCenter
                    text: {
                        switch (Klipper.printState) {
                        case "printing":  return "print"
                        case "paused":    return "pause_circle"
                        case "complete":  return "check_circle"
                        case "error":     return "error"
                        case "cancelled": return "cancel"
                        default:          return "print"
                        }
                    }
                    font.pointSize: Appearance.font.size.extraLarge * 3
                    color: {
                        switch (Klipper.printState) {
                        case "printing":  return Colours.palette.m3primary
                        case "paused":    return Colours.palette.m3tertiary
                        case "complete":  return Colours.palette.m3secondary
                        case "error":     return Colours.palette.m3error
                        default:          return Colours.palette.m3onSurfaceVariant
                        }
                    }
                    animate: true

                    Behavior on color { CAnim {} }
                }

                // Progress % and bar
                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    // Percentage
                    StyledText {
                        text: Klipper.isActive
                            ? qsTr("%1%").arg(Math.round(Klipper.printProgress * 100))
                            : Klipper.printState === "complete"
                            ? qsTr("Done")
                            : qsTr("—")
                        font.pointSize: Appearance.font.size.extraLarge * 2
                        font.weight: 500
                        color: Colours.palette.m3primary
                    }

                    // Progress bar (only when active)
                    Item {
                        visible: Klipper.isActive
                        Layout.fillWidth: true
                        implicitHeight: 8

                        StyledRect {
                            anchors.fill: parent
                            radius: Appearance.rounding.full
                            color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
                        }

                        StyledRect {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: parent.width * Klipper.printProgress
                            radius: Appearance.rounding.full
                            color: Klipper.isPaused
                                ? Colours.palette.m3tertiary
                                : Colours.palette.m3primary

                            Behavior on width {
                                Anim { duration: Appearance.anim.durations.normal }
                            }
                            Behavior on color { CAnim {} }
                        }
                    }

                    // Layer info
                    StyledText {
                        visible: Klipper.totalLayers > 0
                        text: qsTr("Layer %1 of %2  ·  Z %3 mm")
                            .arg(Klipper.currentLayer)
                            .arg(Klipper.totalLayers)
                            .arg(Klipper.posZ.toFixed(2))
                        font.pointSize: Appearance.font.size.normal
                        color: Colours.palette.m3onSurfaceVariant
                    }

                    StyledText {
                        visible: Klipper.totalLayers <= 0 && Klipper.posZ > 0
                        text: qsTr("Z %1 mm").arg(Klipper.posZ.toFixed(2))
                        font.pointSize: Appearance.font.size.normal
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
            }
        }

        // ── Temperature + fan cards ───────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.smaller

            TempCard {
                icon: "mode_heat"
                label: qsTr("Hotend")
                current: Klipper.extruderTemp
                target: Klipper.extruderTarget
                power: Klipper.extruderPower
                colour: Colours.palette.m3error
            }

            TempCard {
                icon: "bed"
                label: qsTr("Bed")
                current: Klipper.bedTemp
                target: Klipper.bedTarget
                power: Klipper.bedPower
                colour: Colours.palette.m3tertiary
            }

            // Fan card
            DetailCard {
                icon: "mode_fan"
                label: qsTr("Part Fan")
                value: Klipper.fanSpeed > 0
                    ? qsTr("%1%").arg(Math.round(Klipper.fanSpeed * 100))
                    : qsTr("Off")
                colour: Klipper.fanSpeed > 0
                    ? Colours.palette.m3secondary
                    : Colours.palette.m3onSurfaceVariant

                // Spin animation when fan is on
                iconRotation: 0
                RotationAnimator {
                    target: null  // set dynamically below
                    from: 0; to: 360
                    loops: Animation.Infinite
                    running: Klipper.fanSpeed > 0
                    duration: Klipper.fanSpeed > 0
                        ? Math.max(300, Math.round(1500 / Klipper.fanSpeed))
                        : 2000
                }
            }
        }

        // ── Controls (only when active) ───────────────────────────────────────
        Loader {
            active: Klipper.isActive
            Layout.fillWidth: true

            sourceComponent: RowLayout {
                spacing: Appearance.spacing.smaller

                // Pause / Resume
                ControlButton {
                    Layout.fillWidth: true
                    icon: Klipper.isPaused ? "play_arrow" : "pause"
                    label: Klipper.isPaused ? qsTr("Resume") : qsTr("Pause")
                    bgColor: Colours.tPalette.m3secondaryContainer
                    fgColor: Colours.palette.m3onSecondaryContainer
                    onActivated: Klipper.isPaused ? Klipper.resume() : Klipper.pause()
                }

                // Cancel (with confirmation)
                Item {
                    Layout.fillWidth: true
                    implicitHeight: cancelBtn.implicitHeight

                    ControlButton {
                        id: cancelBtn
                        anchors.fill: parent
                        icon: "stop"
                        label: qsTr("Cancel")
                        bgColor: Colours.tPalette.m3errorContainer
                        fgColor: Colours.palette.m3onErrorContainer
                        onActivated: confirmOverlay.visible = true
                    }

                    // Confirmation overlay
                    StyledRect {
                        id: confirmOverlay

                        anchors.fill: parent
                        visible: false
                        radius: Appearance.rounding.normal
                        color: Colours.palette.m3errorContainer

                        Timer {
                            running: confirmOverlay.visible
                            interval: 4000
                            onTriggered: confirmOverlay.visible = false
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Appearance.spacing.normal

                            StyledText {
                                text: qsTr("Cancel print?")
                                color: Colours.palette.m3onErrorContainer
                                font.pointSize: Appearance.font.size.small
                            }

                            ControlButton {
                                icon: "check"
                                label: qsTr("Yes")
                                bgColor: Colours.palette.m3error
                                fgColor: Colours.palette.m3onError
                                onActivated: {
                                    Klipper.cancel()
                                    confirmOverlay.visible = false
                                }
                            }

                            ControlButton {
                                icon: "close"
                                label: qsTr("No")
                                bgColor: Colours.tPalette.m3surfaceContainerHigh
                                fgColor: Colours.palette.m3onSurface
                                onActivated: confirmOverlay.visible = false
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Reusable sub-components ───────────────────────────────────────────────

    component TempCard: StyledRect {
        id: tempCard

        property string icon
        property string label
        property real current
        property real target
        property real power
        property color colour: Colours.palette.m3primary

        Layout.fillWidth: true
        Layout.preferredHeight: 80
        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        // Active heating: fill background proportional to heater power
        StyledRect {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * tempCard.power
            radius: Appearance.rounding.normal
            color: Qt.alpha(tempCard.colour, 0.12)

            Behavior on width {
                Anim { duration: Appearance.anim.durations.large }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: Appearance.spacing.normal

            // Icon — pulses while heating
            MaterialIcon {
                id: tempIcon
                text: tempCard.icon
                color: tempCard.power > 0.02 ? tempCard.colour : Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.large
                anchors.verticalCenter: parent.verticalCenter

                SequentialAnimation {
                    running: tempCard.power > 0.02
                    loops: Animation.Infinite
                    NumberAnimation { target: tempIcon; property: "opacity"; to: 0.4; duration: 700 }
                    NumberAnimation { target: tempIcon; property: "opacity"; to: 1.0; duration: 700 }
                    onRunningChanged: if (!running) tempIcon.opacity = 1.0
                }

                Behavior on color { CAnim {} }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                StyledText {
                    text: tempCard.label
                    font.pointSize: Appearance.font.size.smaller
                    opacity: 0.7
                }

                Row {
                    spacing: Appearance.spacing.small / 2

                    StyledText {
                        text: qsTr("%1°").arg(Math.round(tempCard.current))
                        font.pointSize: Appearance.font.size.large
                        font.weight: 600
                        color: tempCard.power > 0.02 ? tempCard.colour : Colours.palette.m3onSurface

                        Behavior on color { CAnim {} }
                    }

                    StyledText {
                        visible: tempCard.target > 0
                        text: qsTr("/ %1°").arg(Math.round(tempCard.target))
                        font.pointSize: Appearance.font.size.small
                        color: Colours.palette.m3onSurfaceVariant
                        anchors.baseline: parent.children[0]?.baseline ?? undefined
                    }
                }
            }
        }
    }

    component DetailCard: StyledRect {
        id: detailCard

        property string icon
        property string label
        property string value
        property color colour: Colours.palette.m3primary
        property real iconRotation: 0

        Layout.fillWidth: true
        Layout.preferredHeight: 80
        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        Row {
            anchors.centerIn: parent
            spacing: Appearance.spacing.normal

            MaterialIcon {
                text: detailCard.icon
                color: detailCard.colour
                font.pointSize: Appearance.font.size.large
                anchors.verticalCenter: parent.verticalCenter
                rotation: detailCard.iconRotation

                Behavior on color { CAnim {} }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                StyledText {
                    text: detailCard.label
                    font.pointSize: Appearance.font.size.smaller
                    opacity: 0.7
                }

                StyledText {
                    text: detailCard.value
                    font.pointSize: Appearance.font.size.large
                    font.weight: 600
                    color: detailCard.colour

                    Behavior on color { CAnim {} }
                }
            }
        }
    }

    component PrintStat: Row {
        id: printStat

        property string icon
        property string label
        property string value
        property color colour: Colours.palette.m3tertiary

        spacing: Appearance.spacing.small

        MaterialIcon {
            text: printStat.icon
            font.pointSize: Appearance.font.size.extraLarge
            color: printStat.colour
        }

        Column {
            StyledText {
                text: printStat.label
                font.pointSize: Appearance.font.size.smaller
                color: Colours.palette.m3onSurfaceVariant
            }
            StyledText {
                text: printStat.value
                font.pointSize: Appearance.font.size.small
                font.weight: 600
                color: Colours.palette.m3onSurface
            }
        }
    }

    component ControlButton: StyledRect {
        id: ctrlBtn

        property string icon
        property string label
        property color bgColor: Colours.tPalette.m3primaryContainer
        property color fgColor: Colours.palette.m3onPrimaryContainer
        signal activated

        implicitHeight: btnContent.implicitHeight + Appearance.padding.normal * 2
        radius: Appearance.rounding.normal
        color: bgColor

        StateLayer {
            radius: parent.radius
            color: ctrlBtn.fgColor
            function onClicked() { ctrlBtn.activated() }
        }

        Row {
            id: btnContent
            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            MaterialIcon {
                text: ctrlBtn.icon
                color: ctrlBtn.fgColor
                font.pointSize: Appearance.font.size.normal
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: ctrlBtn.label
                color: ctrlBtn.fgColor
                font.pointSize: Appearance.font.size.small
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
