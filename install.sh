#!/usr/bin/env bash
# webb-dots installer
# Usage: bash install.sh [--no-build] [--no-cli] [--no-shell]
set -euo pipefail

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

info()    { echo -e "${GREEN}  ✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}  !${RESET} $*"; }
error()   { echo -e "${RED}  ✗${RESET} $*"; exit 1; }
section() { echo -e "\n${CYAN}${BOLD}── $* ──${RESET}"; }

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_PLUGIN=true
INSTALL_CLI=true
INSTALL_SHELL=true

for arg in "$@"; do
    case "$arg" in
        --no-build) BUILD_PLUGIN=false ;;
        --no-cli)   INSTALL_CLI=false ;;
        --no-shell) INSTALL_SHELL=false ;;
    esac
done

echo -e "${BOLD}webb-dots installer${RESET}"

# ── 1. CLI ────────────────────────────────────────────────────────────────────
if $INSTALL_CLI; then
    section "webb-cli"

    if ! command -v python3 &>/dev/null; then
        error "python3 not found. Install with: sudo pacman -S python"
    fi

    pip install --user -e "$DOTS/cli" --quiet \
        || python3 -m pip install --user -e "$DOTS/cli" --quiet \
        || error "pip install failed"
    info "webb command installed (editable, from $DOTS/cli)"

    # Verify ~/.local/bin in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        warn "~/.local/bin not in PATH — add to your shell config:"
        echo '        fish_add_path ~/.local/bin   # fish'
        echo '        export PATH="$HOME/.local/bin:$PATH"  # bash/zsh'
    fi

    # Fish completions
    if command -v fish &>/dev/null; then
        mkdir -p "$HOME/.config/fish/completions"
        cp "$DOTS/cli/completions/webb.fish" "$HOME/.config/fish/completions/"
        info "Fish completions installed"
    fi
fi

# ── 2. C++ plugin ─────────────────────────────────────────────────────────────
if $BUILD_PLUGIN; then
    section "webb-shell C++ plugin"

    for dep in cmake ninja gcc; do
        command -v "$dep" &>/dev/null || error "$dep not found. sudo pacman -S cmake ninja gcc"
    done

    # qt6-base provides qmake6 / Qt6Config.cmake
    if ! pkg-config --exists Qt6Core 2>/dev/null && ! cmake --find-package -DNAME=Qt6 -DCOMPILER_ID=GNU -DLANGUAGE=CXX -DMODE=EXIST &>/dev/null; then
        warn "Qt6 not detected via pkg-config — proceeding anyway (cmake will verify)"
    fi

    BUILD_DIR="$DOTS/shell/build"
    mkdir -p "$BUILD_DIR"

    cmake -S "$DOTS/shell" -B "$BUILD_DIR" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DVERSION=1.0.0 \
        -DGIT_REVISION=local \
        --log-level=WARNING

    cmake --build "$BUILD_DIR" --parallel "$(nproc)"
    sudo cmake --install "$BUILD_DIR"
    info "Plugin installed to /usr/lib/qt6/qml/Webb/"
fi

# ── 3. Shell QML ──────────────────────────────────────────────────────────────
if $INSTALL_SHELL; then
    section "webb-shell QML config"

    QS_DIR="$HOME/.config/quickshell/webb"
    mkdir -p "$QS_DIR"

    # Symlink each directory and the entry-point QML so edits to the repo
    # are reflected immediately without re-running install.
    for dir in assets components config modules services utils; do
        ln -sfn "$DOTS/shell/$dir" "$QS_DIR/$dir"
    done
    ln -sfn "$DOTS/shell/shell.qml" "$QS_DIR/shell.qml"
    info "Shell QML symlinked → $QS_DIR"
fi

# ── 4. webb config files ──────────────────────────────────────────────────────
section "Webb config"

WEBB_CFG="$HOME/.config/webb"
mkdir -p "$WEBB_CFG/templates"

if [[ ! -f "$WEBB_CFG/shell.json" ]]; then
    cat > "$WEBB_CFG/shell.json" << 'EOF'
{
  "services": {
    "weatherLocation": "",
    "useFahrenheit": false,
    "useTwelveHourClock": false,
    "gpuType": "nvidia",
    "visualiserBars": 45,
    "audioIncrement": 0.1,
    "brightnessIncrement": 0.1,
    "maxVolume": 1.0,
    "smartScheme": true,
    "defaultPlayer": "Spotify",
    "playerAliases": [
      { "from": "com.github.th_ch.youtube_music", "to": "YT Music" }
    ]
  },
  "paths": {
    "wallpaperDir": "~/Pictures/Wallpapers"
  }
}
EOF
    info "Created $WEBB_CFG/shell.json"
else
    warn "shell.json already exists — not overwritten"
fi

if [[ ! -f "$WEBB_CFG/cli.json" ]]; then
    cat > "$WEBB_CFG/cli.json" << 'EOF'
{
  "theme": {
    "enableMatugen": true,
    "enableTerm": true,
    "enableHypr": true,
    "enableFuzzel": true,
    "enableBtop": true,
    "enableHtop": true,
    "enableNvtop": true,
    "enableCava": false,
    "enableKitty": false,
    "enableGtk": false,
    "enableQt": false,
    "enableDiscord": false,
    "enableSpicetify": false,
    "enablePandora": false
  },
  "wallpaper": {
    "postHook": ""
  },
  "toggles": {
    "communication": {
      "discord": {
        "enable": false,
        "match": [{"class": "discord"}],
        "command": ["discord"],
        "move": true
      }
    },
    "music": {
      "spotify": {
        "enable": false,
        "match": [{"class": "Spotify"}, {"initialTitle": "Spotify"}],
        "command": ["spotify"],
        "move": true
      }
    },
    "todo": {
      "todoist": {
        "enable": false,
        "match": [{"class": "Todoist"}],
        "command": ["todoist"],
        "move": true
      }
    }
  }
}
EOF
    info "Created $WEBB_CFG/cli.json"
else
    warn "cli.json already exists — not overwritten"
fi

# ── 5. Hyprland scheme dir ────────────────────────────────────────────────────
section "Hyprland integration"

SCHEME_DIR="$HOME/.config/hypr/scheme"
mkdir -p "$SCHEME_DIR"
if [[ ! -f "$SCHEME_DIR/current.conf" ]]; then
    touch "$SCHEME_DIR/current.conf"
    info "Created $SCHEME_DIR/current.conf"
fi

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
if [[ -f "$HYPR_CONF" ]]; then
    if grep -q "scheme/current.conf" "$HYPR_CONF"; then
        info "hyprland.conf already sources scheme/current.conf"
    else
        warn "Add this line to $HYPR_CONF:"
        echo "        source = ~/.config/hypr/scheme/current.conf"
    fi
else
    warn "No hyprland.conf found at $HYPR_CONF — create it and add:"
    echo "        source = ~/.config/hypr/scheme/current.conf"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}Installation complete!${RESET}"
echo ""
echo -e "  ${BOLD}Set first wallpaper:${RESET}  webb wallpaper -f ~/Pictures/Wallpapers/photo.jpg"
echo -e "  ${BOLD}Start the shell:${RESET}      webb shell -d   (or: qs -c webb)"
echo -e "  ${BOLD}Add to Hyprland:${RESET}      exec-once = webb shell -d"
echo ""
