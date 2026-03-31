pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    function close(): void {}

    property var programs: []
    property int currentTab: 0
    property string searchText: ""

    readonly property string keybindsDir: `${Paths.config}/keybinds`
    readonly property string sourceDir:   `${Paths.config}/keybinds/source`
    readonly property string jsonDir:     `${Paths.config}/keybinds/converted`

    property var pendingFiles: []
    property var loadedPrograms: []

    Component.onCompleted: mkdirProc.running = true

    Process {
        id: mkdirProc
        command: ["bash", "-c", `mkdir -p "${root.sourceDir}" "${root.jsonDir}"`]
        onExited: convertProc.running = true
    }

    Process {
        id: convertProc
        command: ["python3", `${Paths.home}/.local/bin/webb-keybinds-convert`,
                  root.sourceDir, root.jsonDir]
        stdout: StdioCollector { onStreamFinished: {} }
        stderr: StdioCollector { onStreamFinished: {} }
        onExited: listProc.running = true
    }

    Process {
        id: listProc
        running: false
        command: ["bash", "-c",
            `{ ls "${root.jsonDir}"/*.json 2>/dev/null; ls "${root.keybindsDir}"/*.json 2>/dev/null; } | sort -u`]
        stdout: StdioCollector {
            onStreamFinished: {
                const files = text.trim().split("\n").filter(f => f.length > 0);
                if (files.length === 0) {
                    root.programs = [];
                    return;
                }
                root.pendingFiles = files;
                root.loadedPrograms = [];
                fileLoader.index = 0;
                fileLoader.loadNext();
            }
        }
    }

    QtObject {
        id: fileLoader
        property int index: 0
        function loadNext(): void {
            if (index >= root.pendingFiles.length) {
                root.programs = root.loadedPrograms.slice();
                if (root.currentTab >= root.programs.length)
                    root.currentTab = 0;
                return;
            }
            const path = root.pendingFiles[index];
            fileViewComp.createObject(root, { filePath: path });
            index++;
        }
    }

    Component {
        id: fileViewComp
        QtObject {
            id: fvObj
            property string filePath: ""
            property FileView fv: FileView {
                path: fvObj.filePath
                onLoaded: {
                    try {
                        const data = JSON.parse(text());
                        root.loadedPrograms.push(data);
                    } catch (e) {
                        console.warn("[Keybinds] parse error", fvObj.filePath, e);
                    }
                    fileLoader.loadNext();
                    fvObj.destroy();
                }
            }
        }
    }

    readonly property var currentProgram: programs[currentTab] ?? null
    readonly property var filteredBinds: {
        if (!currentProgram) return [];
        const q = root.searchText.toLowerCase().trim();
        if (q.length === 0) return currentProgram.binds ?? [];
        return (currentProgram.binds ?? []).filter(b =>
            (b.desc ?? "").toLowerCase().includes(q) ||
            (b.keys ?? "").toLowerCase().includes(q)
        );
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Title bar
        StyledRect {
            Layout.fillWidth: true
            implicitHeight: titleRow.implicitHeight + Appearance.padding.normal * 2
            color: Colours.tPalette.m3surfaceContainerHigh

            RowLayout {
                id: titleRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Appearance.padding.large

                MaterialIcon {
                    text: "keyboard"
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.large
                }
                StyledText {
                    text: qsTr("Keybinds")
                    font.pointSize: Appearance.font.size.large
                    font.bold: true
                    color: Colours.palette.m3onSurface
                    Layout.fillWidth: true
                }
                StyledRect {
                    implicitWidth: 220
                    implicitHeight: searchField.implicitHeight + Appearance.padding.small * 2
                    radius: Appearance.rounding.full
                    color: Colours.tPalette.m3surfaceContainer
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Appearance.padding.small
                        spacing: Appearance.spacing.smaller
                        MaterialIcon {
                            text: "search"
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.normal
                        }
                        StyledTextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: qsTr("Search…")
                            onTextChanged: root.searchText = text
                            color: Colours.palette.m3onSurface
                        }
                        MaterialIcon {
                            text: "close"
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.normal
                            visible: searchField.text.length > 0
                            opacity: visible ? 1 : 0
                            StateLayer {
                                radius: Appearance.rounding.full
                                function onClicked(): void { searchField.text = ""; }
                            }
                            Behavior on opacity { Anim {} }
                        }
                    }
                }
                Item {
                    implicitWidth:  closeIcon.implicitWidth  + Appearance.padding.normal * 2
                    implicitHeight: closeIcon.implicitHeight + Appearance.padding.normal * 2
                    StateLayer {
                        radius: Appearance.rounding.full
                        function onClicked(): void { root.close(); }
                    }
                    MaterialIcon {
                        id: closeIcon
                        anchors.centerIn: parent
                        text: "close"
                        color: Colours.palette.m3onSurface
                        font.pointSize: Appearance.font.size.large
                    }
                }
            }
        }

        // No files state
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.programs.length === 0
            ColumnLayout {
                anchors.centerIn: parent
                spacing: Appearance.spacing.normal
                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "folder_open"
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.extraLarge * 2
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("No keybind files found")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.large
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Drop .conf .lua .toml .json .txt files into\n~/.config/webb/keybinds/source/")
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.normal
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // Main body
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            visible: root.programs.length > 0

            // Sidebar
            StyledRect {
                Layout.preferredWidth: 180
                Layout.fillHeight: true
                color: Colours.tPalette.m3surfaceContainerLow

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.normal
                    spacing: Appearance.spacing.smaller

                    Repeater {
                        model: ScriptModel { values: root.programs }
                        delegate: StyledRect {
                            id: tabBtn
                            required property var modelData
                            required property int index
                            Layout.fillWidth: true
                            implicitHeight: tabRow.implicitHeight + Appearance.padding.normal * 2
                            radius: Appearance.rounding.small
                            color: root.currentTab === index
                                ? Colours.palette.m3secondaryContainer
                                : "transparent"
                            StateLayer {
                                radius: parent.radius
                                color: root.currentTab === tabBtn.index
                                    ? Colours.palette.m3onSecondaryContainer
                                    : Colours.palette.m3onSurface
                                function onClicked(): void {
                                    root.currentTab = tabBtn.index;
                                    searchField.text = "";
                                }
                            }
                            RowLayout {
                                id: tabRow
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: Appearance.padding.normal
                                spacing: Appearance.spacing.normal
                                MaterialIcon {
                                    text: tabBtn.modelData.icon ?? "keyboard"
                                    color: root.currentTab === tabBtn.index
                                        ? Colours.palette.m3onSecondaryContainer
                                        : Colours.palette.m3onSurface
                                    font.pointSize: Appearance.font.size.normal
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    text: tabBtn.modelData.label ?? tabBtn.modelData.id ?? ""
                                    color: root.currentTab === tabBtn.index
                                        ? Colours.palette.m3onSecondaryContainer
                                        : Colours.palette.m3onSurface
                                    font.pointSize: Appearance.font.size.normal
                                    elide: Text.ElideRight
                                }
                                StyledRect {
                                    implicitWidth: Math.max(implicitHeight, countText.implicitWidth + Appearance.padding.small * 2)
                                    implicitHeight: countText.implicitHeight + 2
                                    radius: Appearance.rounding.full
                                    color: root.currentTab === tabBtn.index
                                        ? Colours.palette.m3secondary
                                        : Colours.tPalette.m3surfaceContainerHighest
                                    StyledText {
                                        id: countText
                                        anchors.centerIn: parent
                                        text: (tabBtn.modelData.binds ?? []).length
                                        font.pointSize: Appearance.font.size.smaller * 0.85
                                        color: root.currentTab === tabBtn.index
                                            ? Colours.palette.m3onSecondary
                                            : Colours.palette.m3onSurfaceVariant
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    StyledText {
                        Layout.fillWidth: true
                        Layout.bottomMargin: Appearance.padding.small
                        text: qsTr("Drop files into\n~/.config/webb/keybinds/source/")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.smaller * 0.85
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            StyledRect {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: Colours.palette.m3outlineVariant
            }

            // Content
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.large
                    spacing: Appearance.spacing.normal

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.normal
                        MaterialIcon {
                            text: root.currentProgram?.icon ?? "keyboard"
                            color: Colours.palette.m3primary
                            font.pointSize: Appearance.font.size.extraLarge
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            StyledText {
                                text: root.currentProgram?.label ?? ""
                                font.pointSize: Appearance.font.size.large
                                font.bold: true
                                color: Colours.palette.m3onSurface
                            }
                            StyledText {
                                text: root.searchText.length > 0
                                    ? qsTr("%1 of %2 binds").arg(root.filteredBinds.length).arg((root.currentProgram?.binds ?? []).length)
                                    : qsTr("%1 keybinds").arg((root.currentProgram?.binds ?? []).length)
                                font.pointSize: Appearance.font.size.small
                                color: Colours.palette.m3onSurfaceVariant
                            }
                        }
                    }

                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colours.palette.m3outlineVariant
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.filteredBinds.length === 0 && root.searchText.length > 0
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Appearance.spacing.normal
                            MaterialIcon {
                                Layout.alignment: Qt.AlignHCenter
                                text: "search_off"
                                color: Colours.palette.m3outline
                                font.pointSize: Appearance.font.size.extraLarge * 1.5
                            }
                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: qsTr("No results for \"%1\"").arg(root.searchText)
                                color: Colours.palette.m3onSurfaceVariant
                                font.pointSize: Appearance.font.size.normal
                            }
                        }
                    }

                    Flickable {
                        id: bindFlickable
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.filteredBinds.length > 0
                        clip: true
                        contentHeight: bindsColumn.implicitHeight
                        ScrollBar.vertical: StyledScrollBar { flickable: bindFlickable }

                        ColumnLayout {
                            id: bindsColumn
                            width: bindFlickable.width
                            spacing: 2

                            Repeater {
                                model: ScriptModel { values: root.filteredBinds }
                                delegate: StyledRect {
                                    id: bindRow
                                    required property var modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    implicitHeight: innerRow.implicitHeight + Appearance.padding.small * 2
                                    radius: Appearance.rounding.smaller
                                    color: index % 2 === 0
                                        ? Colours.tPalette.m3surfaceContainerLow
                                        : Colours.tPalette.m3surfaceContainer

                                    RowLayout {
                                        id: innerRow
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.margins: Appearance.padding.normal
                                        spacing: Appearance.spacing.large

                                        StyledText {
                                            Layout.fillWidth: true
                                            text: bindRow.modelData.desc ?? ""
                                            color: Colours.palette.m3onSurface
                                            font.pointSize: Appearance.font.size.small
                                            elide: Text.ElideRight
                                        }

                                        RowLayout {
                                            spacing: Appearance.spacing.smaller / 2
                                            Repeater {
                                                model: (bindRow.modelData.keys ?? "").split("+")
                                                delegate: StyledRect {
                                                    id: keyChip
                                                    required property string modelData
                                                    required property int index
                                                    implicitWidth: Math.max(implicitHeight, chipText.implicitWidth + Appearance.padding.normal * 2)
                                                    implicitHeight: chipText.implicitHeight + Appearance.padding.smaller * 2
                                                    radius: Appearance.rounding.smaller
                                                    color: Colours.palette.m3secondaryContainer
                                                    StyledText {
                                                        id: chipText
                                                        anchors.centerIn: parent
                                                        text: keyChip.modelData.trim()
                                                        color: Colours.palette.m3onSecondaryContainer
                                                        font.pointSize: Appearance.font.size.smaller
                                                        font.family: Appearance.font.family.mono
                                                        font.bold: true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Item { implicitHeight: Appearance.padding.large }
                        }
                    }
                }
            }
        }
    }
}
