pragma Singleton
pragma ComponentBehavior: Bound

import qs.components
import qs.services
import Quickshell
import QtQuick

// KeybindsWindow.qml
// Manages the lifecycle of the floating keybind viewer.
// Call KeybindsWindow.open() or KeybindsWindow.toggle() to show/hide.
Singleton {
    id: root

    property var instance: null

    function open(): void {
        if (root.instance) {
            root.instance.requestActivate();
            return;
        }
        root.instance = windowComp.createObject(null);
    }

    function close(): void {
        if (root.instance) {
            root.instance.destroy();
            root.instance = null;
        }
    }

    function toggle(): void {
        if (root.instance)
            root.close();
        else
            root.open();
    }

    Component {
        id: windowComp

        FloatingWindow {
            id: win

            readonly property int baseWidth:  860
            readonly property int baseHeight: 600

            implicitWidth:  baseWidth
            implicitHeight: baseHeight
            minimumSize.width:  baseWidth
            minimumSize.height: baseHeight
            maximumSize.width:  baseWidth  * 2
            maximumSize.height: baseHeight * 2

            color: Colours.tPalette.m3surface
            title: qsTr("Keybinds")

            onVisibleChanged: {
                if (!visible) {
                    root.instance = null;
                    destroy();
                }
            }

            KeybindsContent {
                anchors.fill: parent

                function close(): void {
                    win.destroy();
                    root.instance = null;
                }
            }

            Behavior on color { CAnim {} }
        }
    }
}
