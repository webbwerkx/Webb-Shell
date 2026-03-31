# webb-cli

The CLI companion for the Webb dotfiles setup. Provides a `webb` command for managing your
Hyprland shell, wallpapers, colour schemes, screenshots, recordings, and more.

## Installation (Arch Linux)

### Dependencies

Install from the AUR or pacman:

```sh
# Core
sudo pacman -S python python-pillow git

# Python deps (via pip or AUR)
pip install --user materialyoucolor

# Runtime tools
sudo pacman -S grim slurp swappy wl-clipboard cliphist fuzzel notify-send \
               gpu-screen-recorder app2unit hyprland
```

### Install

```sh
git clone https://github.com/YOU/webb-dots.git ~/.config/webb-dots
cd ~/.config/webb-dots/cli

pip install --user -e .

# Or install the bin directly
sudo cp bin/webb /usr/local/bin/webb
sudo chmod +x /usr/local/bin/webb

# Fish completions
cp completions/webb.fish ~/.config/fish/completions/
```

## Usage

```
usage: webb [-h] [-v] COMMAND ...

Main control script for the Webb dotfiles

subcommands:
  shell       Start or message the shell
  toggle      Toggle a special workspace
  scheme      Manage the colour scheme
  screenshot  Take a screenshot
  record      Start a screen recording
  clipboard   Open clipboard history
  emoji       Emoji/glyph utilities
  wallpaper   Manage the wallpaper
  resizer     Window resizer daemon
```

### Shell

```sh
webb shell -d          # Start shell detached
webb shell -s          # Show all IPC commands
webb shell -k          # Kill the shell
webb shell -l          # Print shell log
```

### Wallpaper

```sh
webb wallpaper -f ~/Pictures/Wallpapers/my_wall.jpg   # Set specific wallpaper
webb wallpaper -r                                      # Random wallpaper
webb wallpaper                                         # Print current wallpaper path
```

### Scheme

```sh
webb scheme list                        # List all schemes
webb scheme get                         # Print current scheme
webb scheme set -n catppuccin -f mocha  # Set catppuccin mocha
webb scheme set -m light                # Switch to light mode
webb scheme set -r                      # Random scheme
webb scheme set -n dynamic              # Dynamic scheme from wallpaper
```

### Screenshot

```sh
webb screenshot          # Fullscreen screenshot, copied to clipboard
webb screenshot -r       # Region screenshot with slurp
webb screenshot -r -f    # Region screenshot with screen freeze
```

### Record

```sh
webb record              # Start/stop full screen recording
webb record -s           # With audio
webb record -r           # Region recording
webb record -p           # Pause/resume
```

### Toggle

```sh
webb toggle sysmon       # Toggle btop special workspace
```

You can add your own apps to `~/.config/webb/cli.json`:

```json
{
  "toggles": {
    "music": {
      "spotify": {
        "enable": true,
        "match": [{"class": "Spotify"}],
        "command": ["spotify"],
        "move": true
      }
    }
  }
}
```

## Configuration

All configuration goes in `~/.config/webb/cli.json`. Example:

```json
{
  "theme": {
    "enableTerm": true,
    "enableHypr": true,
    "enableKitty": true,
    "enableGtk": true,
    "enableQt": true,
    "enableDiscord": false,
    "enableSpicetify": false,
    "enableBtop": true,
    "enableHtop": true,
    "enableCava": false
  },
  "wallpaper": {
    "postHook": "swww img \"$WALLPAPER_PATH\""
  },
  "toggles": {}
}
```

### Custom Templates

Place template files in `~/.config/webb/templates/`. They support `{{ $colourName }}` substitution
with any colour from the current scheme, plus `{{ mode }}` for dark/light. Rendered files are
written to `~/.local/state/webb/theme/`.
