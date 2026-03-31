#!/usr/bin/env bash
# Webb dots installer — Arch Linux + Hyprland
set -euo pipefail

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

info()  { echo -e "${GREEN}[webb]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[webb]${RESET} $*"; }
error() { echo -e "${RED}[webb]${RESET} $*"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")"

info "Webb dots installer"
echo ""

# ── CLI install ────────────────────────────────────────────────────────────────
info "Installing webb-cli Python package..."
if command -v pip &>/dev/null; then
    pip install --user -e "$SCRIPT_DIR/cli" --quiet
    info "webb-cli installed via pip"
elif command -v python3 &>/dev/null; then
    python3 -m pip install --user -e "$SCRIPT_DIR/cli" --quiet
    info "webb-cli installed via python3 -m pip"
else
    error "Python/pip not found. Install python first: sudo pacman -S python"
fi

# Make sure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    warn "~/.local/bin not in PATH. Add this to your shell config:"
    echo '    export PATH="$HOME/.local/bin:$PATH"'
fi

# ── Fish completions ───────────────────────────────────────────────────────────
if command -v fish &>/dev/null; then
    FISH_COMP_DIR="$HOME/.config/fish/completions"
    mkdir -p "$FISH_COMP_DIR"
    cp "$SCRIPT_DIR/cli/completions/webb.fish" "$FISH_COMP_DIR/"
    info "Fish completions installed"
fi

# ── Shell (Quickshell QML) install ────────────────────────────────────────────
info "Installing webb-shell (Quickshell config)..."
QS_CONF_DIR="$HOME/.config/quickshell/webb"
mkdir -p "$QS_CONF_DIR"

if [[ -d "$SCRIPT_DIR/shell" ]]; then
    # Link or copy shell files
    for dir in assets components config modules services utils; do
        if [[ -d "$SCRIPT_DIR/shell/$dir" ]]; then
            ln -sfn "$SCRIPT_DIR/shell/$dir" "$QS_CONF_DIR/$dir"
        fi
    done
    for file in shell.qml CMakeLists.txt; do
        if [[ -f "$SCRIPT_DIR/shell/$file" ]]; then
            ln -sfn "$SCRIPT_DIR/shell/$file" "$QS_CONF_DIR/$file"
        fi
    done
    info "Shell QML files linked to $QS_CONF_DIR"
fi

# ── Config directory setup ────────────────────────────────────────────────────
WEBB_CONFIG="$HOME/.config/webb"
mkdir -p "$WEBB_CONFIG/templates"

if [[ ! -f "$WEBB_CONFIG/shell.json" ]]; then
    info "Creating default shell.json config..."
    cat > "$WEBB_CONFIG/shell.json" << 'EOF'
{
  "services": {
    "weatherLocation": "",
    "useFahrenheit": false,
    "useTwelveHourClock": false,
    "gpuType": "",
    "visualiserBars": 45,
    "audioIncrement": 0.1,
    "brightnessIncrement": 0.1,
    "maxVolume": 1.0,
    "smartScheme": true,
    "defaultPlayer": "Spotify"
  },
  "paths": {
    "wallpaperDir": "~/Pictures/Wallpapers"
  },
  "bar": {
    "persistent": true,
    "showOnHover": true
  }
}
EOF
fi

if [[ ! -f "$WEBB_CONFIG/cli.json" ]]; then
    info "Creating default cli.json config..."
    cat > "$WEBB_CONFIG/cli.json" << 'EOF'
{
  "theme": {
    "enableTerm": true,
    "enableHypr": true,
    "enableKitty": true,
    "enableGtk": true,
    "enableQt": true,
    "enableDiscord": true,
    "enableSpicetify": true,
    "enableBtop": true,
    "enableHtop": true,
    "enableNvtop": true,
    "enableFuzzel": true,
    "enableCava": true,
    "enableMatugen": true
  },
  "wallpaper": {
    "postHook": ""
  },
  "toggles": {}
}
EOF
fi

# ── Hyprland config snippet ───────────────────────────────────────────────────
HYPR_DIR="$HOME/.config/hypr"
SCHEME_DIR="$HYPR_DIR/scheme"
mkdir -p "$SCHEME_DIR"

if [[ ! -f "$SCHEME_DIR/current.conf" ]]; then
    touch "$SCHEME_DIR/current.conf"
fi

if [[ ! -f "$HYPR_DIR/hyprland.conf" ]]; then
    warn "No hyprland.conf found at $HYPR_DIR/hyprland.conf"
    warn "Create it and add: source = ~/.config/hypr/scheme/current.conf"
else
    if ! grep -q "scheme/current.conf" "$HYPR_DIR/hyprland.conf" 2>/dev/null; then
        warn "Add this to your hyprland.conf to enable dynamic theming:"
        echo "    source = ~/.config/hypr/scheme/current.conf"
    fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
info "Installation complete!"
echo ""
echo -e "  ${BOLD}Start the shell:${RESET}     webb shell -d"
echo -e "  ${BOLD}Set a wallpaper:${RESET}     webb wallpaper -f ~/Pictures/Wallpapers/something.jpg"
echo -e "  ${BOLD}Set a scheme:${RESET}        webb scheme set -n catppuccin -f mocha"
echo -e "  ${BOLD}Dynamic scheme:${RESET}      webb scheme set -n dynamic"
echo ""
