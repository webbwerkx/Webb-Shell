//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
import "modules"
import "modules/drawers"
import "modules/background"
import "modules/areapicker"
import "modules/lock"
import "modules/keybinds"
import Quickshell
import Quickshell.Io

ShellRoot {
    Background {}
    Drawers {}
    AreaPicker {}
    Lock {
        id: lock
    }
    Shortcuts {}
    BatteryMonitor {}
    IdleMonitors {
        lock: lock
    }

    IpcHandler {
        target: "keybinds"
        function open(): void    { KeybindsWindow.open(); }
        function close(): void   { KeybindsWindow.close(); }
        function toggle(): void  { KeybindsWindow.toggle(); }
    }
}
