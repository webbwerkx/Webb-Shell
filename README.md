<div align="center">

```
██╗    ██╗███████╗██████╗ ██████╗       ██████╗  ██████╗ ████████╗███████╗
██║    ██║██╔════╝██╔══██╗██╔══██╗      ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
██║ █╗ ██║█████╗  ██████╔╝██████╔╝█████╗██║  ██║██║   ██║   ██║   ███████╗
██║███╗██║██╔══╝  ██╔══██╗██╔══██╗╚════╝██║  ██║██║   ██║   ██║   ╚════██║
╚███╔███╔╝███████╗██████╔╝██████╔╝      ██████╔╝╚██████╔╝   ██║   ███████║
 ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═════╝       ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
```

**A fully custom Hyprland desktop environment built on Quickshell and Material You**

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=wayland&logoColor=black)
![Python](https://img.shields.io/badge/Python_3-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Qt6](https://img.shields.io/badge/Qt_6-41CD52?style=for-the-badge&logo=qt&logoColor=white)

</div>

---

## What is this?

**webb-dots** is a personal Arch Linux desktop configuration built around two components:

**`webb` CLI** — A Python command-line tool that manages wallpapers, generates Material You color schemes from your wallpaper, controls the shell via IPC, takes screenshots, records the screen, handles clipboard history, provides an emoji/glyph picker, and manages special scratchpad workspaces.

**Quickshell QML shell** — The visual layer running on Hyprland: a configurable bar, app launcher, dashboard, notification sidebar, session menu, OSD for volume/brightness, lock screen, control center settings panel, and a floating keybind viewer that reads your actual config files.

The entire desktop (shell, terminal, neovim, tmux, gtk, qt, hyprland borders, starship prompt) recolors automatically whenever the wallpaper changes using Google's Material You color algorithm.

---

## Features

| Feature | Description |
|---------|-------------|
| 🎨 **Dynamic theming** | Shell, kitty, nvim, tmux, gtk, qt, hyprland all recolor from wallpaper |
| 📊 **Material You** | Google's M3 color system generates harmonious palettes |
| 📍 **Configurable bar** | Left, top, right, or bottom — set in shell.json |
| ⌨️ **Keybind viewer** | Floating window reading your actual config files, with search |
| 🎬 **Screen recording** | GPU-accelerated via gpu-screen-recorder with audio support |
| 🖨️ **Klipper dashboard** | Live 3D printer status panel in the dashboard |
| 📋 **Clipboard history** | Searchable history via cliphist + fuzzel |
| 😀 **Emoji/glyph picker** | Full emoji + nerd font glyph search |
| 🪟 **Window resizer** | Auto-floats and resizes popups, OAuth windows, PiP |
| 🗂️ **Special workspaces** | Toggle Discord, Spotify, btop, Todoist as scratchpads |
| 🔔 **Notification center** | Built-in notifications — no dunst/mako required |

---

## Repository Structure

```
webb-dots/
├── INSTALL.md                    Step-by-step new machine setup guide
├── KEYBINDS.md                   Complete keybind reference
├── WEBB-COMMANDS.txt             Full CLI + IPC command reference
├── README.md                     This file
├── install.fish                  Main installer script
│
├── cli/                          Python CLI source
│   ├── src/webb/
│   │   ├── subcommands/          wallpaper, scheme, screenshot, record,
│   │   │                         clipboard, emoji, toggle, resizer, shell
│   │   └── utils/                theming, paths, hyprland IPC, material you
│   └── completions/webb.fish     Fish shell tab completions
│
├── shell/                        Quickshell QML source
│   ├── shell.qml                 Entry point + IPC handler registration
│   ├── modules/
│   │   ├── bar/                  Bar, workspace indicators, clock, tray
│   │   ├── dashboard/            Info, media, performance, weather, Klipper
│   │   ├── launcher/             App launcher + wallpaper picker
│   │   ├── sidebar/              Notification sidebar
│   │   ├── session/              Logout / shutdown / reboot / sleep menu
│   │   ├── lock/                 Lock screen (password + fingerprint)
│   │   ├── osd/                  Volume and brightness overlay
│   │   ├── notifications/        Notification popups
│   │   ├── utilities/            Toast notifications, quick toggles
│   │   ├── controlcenter/        Settings panel
│   │   └── keybinds/             Floating keybind viewer
│   ├── scripts/
│   │   └── webb-keybinds-convert Converts config files → keybind JSON
│   ├── config/                   QML config objects (BarConfig, etc.)
│   ├── services/                 QML singletons (audio, network, Hyprland IPC)
│   ├── components/               Reusable QML components
│   ├── utils/                    Paths, icons, color utilities
│   ├── assets/                   GIFs, icons, PAM config
│   └── plugin/                   C++ plugin (Qalculate, cava, audio)
│
└── dotfiles/                     Personal configuration files
    ├── hypr/                     Hyprland config split into modules
    ├── kitty/                    Terminal + matugen color template
    ├── fish/                     Fish config + color hooks
    ├── nvim/                     Full Neovim config (lazy.nvim)
    ├── tmux/                     Tmux + Material You theme
    ├── matugen/                  Templates for every app
    ├── starship/                 Prompt config
    ├── btop/                     System monitor theme
    ├── yazi/                     File manager config
    └── webb/                     shell.json, cli.json, keybind files
```

---

## Dependencies

### Install yay first

```fish
sudo pacman -S --needed base-devel git
cd /tmp && git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

### Pacman packages

```fish
sudo pacman -S --needed \
  adw-gtk-theme aubio base base-devel bluez bluez-utils btop chromium \
  cliphist cmake ddcutil efibootmgr eza fastfetch fish font-manager \
  fuzzel gimp git glm grim gst-plugin-pipewire gvfs htop hyprland \
  inkscape inotify-tools intel-media-driver intel-ucode iptables-nft \
  kitty kvantum kvantum-qt5 less libcava libpulse libqalculate \
  libva-intel-driver linux linux-firmware nano neovim networkmanager \
  ninja nodejs npm nwg-look openssh pacman-contrib papirus-icon-theme \
  pavucontrol pavucontrol-qt pipewire pipewire-alsa pipewire-jack \
  pipewire-pulse polkit-kde-agent power-profiles-daemon python \
  python-build python-hatchling python-installer python-pillow \
  python-pyqt6-webengine qt5-graphicaleffects qt5-quickcontrols2 \
  qt5-wayland qt5ct qt6-wayland qt6ct sddm slurp smartmontools \
  sof-firmware starship sudo swappy swww thunar thunar-archive-plugin \
  thunar-media-tags-plugin thunar-volman tmux trash-cli tree \
  ttf-fira-code tumbler ufw unzip uwsm vim vulkan-intel vulkan-nouveau \
  vulkan-radeon wget wireless_tools wireplumber \
  xdg-desktop-portal-hyprland xdg-utils xf86-video-amdgpu \
  xf86-video-ati xf86-video-nouveau xfce4-panel xorg-server \
  xorg-xinit yazi zram-generator
```

### AUR packages

```fish
yay -S --needed \
  app2unit cava gpu-screen-recorder localsend-bin matugen-git \
  papirus-folders python-materialyoucolor3 qtengine-git quickshell-git \
  sddm-theme-corners-git snixembed ttf-cascadia-code-nerd \
  ttf-jetbrains-mono-nerd ttf-material-symbols-variable-git \
  ttf-rubik-vf yay yay-debug
```

> **⚠️ Critical:** Use `python-materialyoucolor3` — **not** `python-materialyoucolor` (v2). They conflict and will silently break all theming.

### Required fonts

All three must be present or the shell will show blank boxes for icons:

| Font | AUR Package | Used For |
|------|------------|---------|
| **Rubik** | `ttf-rubik-vf` | All UI text |
| **CaskaydiaCove NF** | `ttf-cascadia-code-nerd` | Monospace, clock |
| **Material Symbols Rounded** | `ttf-material-symbols-variable-git` | Every shell icon |

```fish
# Verify all three are installed
fc-list | grep -E "Rubik|Caskaydia|Material Symbols"
```

### GPU notes

| Hardware | Action |
|----------|--------|
| Intel | Keep `intel-ucode`, `intel-media-driver`, `libva-intel-driver`, `vulkan-intel` |
| AMD | Keep `vulkan-radeon`, `xf86-video-amdgpu` |
| NVIDIA | Install `nvidia` driver; set `"gpuType": "nvidia"` in shell.json |
| None / VM | Set `"gpuType": "none"` to stop nvidia-smi log spam |

Installing all `vulkan-*` and `xf86-video-*` packages is harmless.

---

## Installation

Full guide with troubleshooting in **INSTALL.md**. Summary:

```fish
# 1. Install packages (see Dependencies above)

# 2. Run the installer — handles CLI, C++ plugin, and Quickshell symlinks
cd ~/webb-dots
fish install.fish

# 3. Apply your dotfiles
cp -r ~/webb-dots/dotfiles/hypr      ~/.config/hypr
cp -r ~/webb-dots/dotfiles/kitty     ~/.config/kitty
cp -r ~/webb-dots/dotfiles/nvim      ~/.config/nvim
cp -r ~/webb-dots/dotfiles/matugen   ~/.config/matugen
cp    ~/webb-dots/dotfiles/tmux/tmux.conf ~/.tmux.conf
cp    ~/webb-dots/dotfiles/starship/starship.toml ~/.config/starship.toml
cp -r ~/webb-dots/dotfiles/yazi      ~/.config/yazi
cp    ~/webb-dots/dotfiles/webb/shell.json ~/.config/webb/shell.json
cp -r ~/webb-dots/dotfiles/webb/keybinds ~/.config/webb/keybinds

# 4. Install keybind converter
cp ~/webb-dots/shell/scripts/webb-keybinds-convert ~/.local/bin/
chmod +x ~/.local/bin/webb-keybinds-convert
fish_add_path ~/.local/bin

# 5. Set dynamic color scheme
mkdir -p ~/.local/state/webb
echo '{"name":"dynamic","flavour":"default","mode":"dark","variant":"tonalspot","colours":{}}' \
  > ~/.local/state/webb/scheme.json

# 6. Edit shell.json — update YOUR_USERNAME and gpuType
nvim ~/.config/webb/shell.json

# 7. Start
mkdir -p ~/Pictures/Wallpapers
webb shell -d
webb wallpaper -r
webb emoji --fetch
```

---

## Configuration

The shell is configured entirely via `~/.config/webb/shell.json`. Changes are detected and applied live.

### Key settings

```jsonc
{
  "bar": {
    "position": "left"        // "left" | "top" | "right" | "bottom"
  },
  "services": {
    "gpuType": "none",        // "none" | "nvidia" | "amd"
    "useTwelveHourClock": true,
    "weatherLocation": ""     // city name for weather widget
  },
  "general": {
    "idle": {
      "timeouts": []          // [] = never lock
    }
  },
  "session": {
    "commands": {
      "logout": ["loginctl", "terminate-user", "YOUR_USERNAME"]
    }
  },
  "paths": {
    "wallpaperDir": "~/Pictures/Wallpapers"
  }
}
```

### Klipper 3D printer

```json
"services": {
  "klipperHost": "192.168.1.100",
  "klipperPort": 7125
}
```

---

## Theming Pipeline

```
wallpaper image
      │
      ▼
materialyoucolor  →  extract dominant color
      │
      ▼
matugen color hex  →  generate full M3 palette
      │
      ├──→ kitty, hyprland, gtk3/4, qt/kvantum
      ├──→ neovim, tmux, starship, fish, btop, cava
      │
      └──→ scheme.json  →  Quickshell FileView watcher
                                    │
                                    ▼
                           shell colors update live
```

Templates live in `~/webb-dots/dotfiles/matugen/templates/`. Add any app by creating a template and registering it in `~/.config/matugen/config.toml`.

---

## Keybind Viewer

The floating keybind viewer reads your actual config files and shows all keybinds with tabbed programs and search. Open with `SUPER+CTRL+K`.

**Drop any config file into** `~/.config/webb/keybinds/source/` and it converts automatically when the viewer opens:

| Extension | Parsed as |
|-----------|-----------|
| `.conf` | Hyprland `bind = ...` or Kitty `map ...` |
| `.lua` | Neovim `vim.keymap.set(...)` |
| `.toml` | Tmux TOML config |
| `.json` | Direct format (passed through) |
| `.txt` | Plain text (tab / space / dash / colon / `C-a` prefix) |

To add a custom keybind tab, see **KEYBINDS.md → Adding Keybinds to the Viewer**.

---

## After a Qt Update

Quickshell must be rebuilt whenever Qt has a version bump:

```fish
yay -S quickshell-git
webb shell -k && webb shell -d
```

---

## Common Issues

| Problem | Fix |
|---------|-----|
| Colors don't update with wallpaper | `scheme.json` must have `"name":"dynamic"` |
| Icons are blank boxes | `yay -S ttf-material-symbols-variable-git` then `fc-cache -fv` |
| Logout does nothing | Wrong username in shell.json session commands |
| `nvidia-smi` spam in log | Set `"gpuType": "none"` in shell.json |
| Screen locks unexpectedly | Set `"timeouts": []` in shell.json idle block |
| Keybind viewer blank | Run converter manually to debug |
| Shell crashes after system update | `yay -S quickshell-git` to rebuild against new Qt |
| Launcher doesn't open apps | `yay -S app2unit` |

---

## Key Paths

| Path | Purpose |
|------|---------|
| `~/.config/webb/shell.json` | Main shell configuration |
| `~/.config/webb/cli.json` | CLI configuration (theming toggles) |
| `~/.local/state/webb/scheme.json` | Current color scheme |
| `~/.config/quickshell/webb/` | Quickshell config (symlinks to `~/webb-dots/shell/`) |
| `~/.config/matugen/` | Matugen config + app templates |
| `~/.config/webb/keybinds/source/` | Drop config files here for keybind viewer |
| `~/.config/webb/keybinds/converted/` | Auto-generated keybind JSON (do not edit) |
| `~/.local/bin/webb-keybinds-convert` | Keybind converter script |
| `~/Pictures/Wallpapers/` | Wallpaper directory |
| `~/Pictures/Screenshots/` | Screenshots saved here |
| `~/Videos/Recordings/` | Screen recordings saved here |

---

<div align="center">

Built on [Quickshell](https://quickshell.outfoxxed.me/) · Themed with [matugen](https://github.com/InioX/matugen) · Runs on [Hyprland](https://hyprland.org/)

</div>
