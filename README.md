# webb-dots

Rebuilt Caeliestia cli/shell to use with my own configs and set up. 

## Components

- **`cli/`** — Python CLI tool (`webb` command) for wallpaper, theming, screenshots, recordings, IPC
- **`shell/`** — QML desktop shell (Quickshell) — bar, launcher, lock screen, dashboard, sidebar, control center

## Quick Install (Arch Linux + Hyprland)

```sh
git clone https://github.com/YOU/webb-dots.git ~/.config/webb-dots
cd ~/.config/webb-dots
bash install.sh
```

## Starting the shell

```sh
webb shell -d
# or directly:
qs -c webb
```

## Key paths

| Path | Purpose |
|------|---------|
| `~/.config/webb/shell.json` | Shell configuration |
| `~/.config/webb/cli.json` | CLI/theming configuration |
| `~/.config/webb/templates/` | Custom theme templates |
| `~/.local/state/webb/scheme.json` | Current active scheme |
| `~/.local/state/webb/wallpaper/` | Wallpaper state |
| `~/.local/state/webb/theme/` | Rendered custom templates |
| `~/.config/hypr/scheme/current.conf` | Hyprland colour variables |

## CLI reference

```sh
webb wallpaper -f /path/to/image.jpg    # Set wallpaper + apply theme
webb wallpaper -r                        # Random wallpaper
webb scheme set -n dynamic              # Dynamic scheme from wallpaper
webb scheme set -r                      # Random scheme
webb screenshot                          # Fullscreen screenshot
webb screenshot -r                      # Region screenshot
webb record                             # Start/stop recording
webb toggle sysmon                      # Toggle btop workspace
webb shell -s                           # Show IPC commands
```
# Webb-Shell
