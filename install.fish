#!/usr/bin/env fish
# Webb dots installer
# Usage: fish install.fish [--no-build] [--no-cli] [--no-shell]

set DOTS (realpath (dirname (status filename)))

set build_plugin true
set install_cli true
set install_shell true

for arg in $argv
    switch $arg
        case --no-build
            set build_plugin false
        case --no-cli
            set install_cli false
        case --no-shell
            set install_shell false
    end
end

function info
    echo (set_color green)"  ✓"(set_color normal)" $argv"
end

function warn
    echo (set_color yellow)"  !"(set_color normal)" $argv"
end

function err
    echo (set_color red)"  ✗"(set_color normal)" $argv"
    exit 1
end

function section
    echo ""
    echo (set_color cyan)"── $argv ──"(set_color normal)
end

function require_pacman
    set pkg $argv[1]
    if not pacman -Q $pkg &>/dev/null
        warn "$pkg not installed — installing..."
        sudo pacman -S --noconfirm $pkg
        or err "Failed to install $pkg"
    end
end

function require_aur
    set pkg $argv[1]
    if not pacman -Q $pkg &>/dev/null
        warn "$pkg not installed — installing via yay..."
        yay -S --noconfirm $pkg
        or err "Failed to install $pkg"
    end
end

echo (set_color --bold)"webb-dots installer"(set_color normal)

# ── 1. CLI ────────────────────────────────────────────────────────────────────
if $install_cli
    section "webb CLI"

    if not command -q python3
        err "python3 not found — install with: sudo pacman -S python"
    end

    # All Python deps installed via pacman/yay — never pip — so pacman keeps
    # full ownership of the system Python environment.
    require_pacman python-build
    require_pacman python-installer
    require_pacman python-hatchling
    require_pacman python-pillow
    require_aur   python-materialyoucolor3
    require_aur   libcava
    require_aur   ttf-rubik-vf
    require_aur   ttf-material-symbols-variable-git
    require_aur   ttf-cascadia-code-nerd
    require_aur   app2unit

    pushd $DOTS/cli
    python3 -m build --wheel --outdir dist/ 2>/dev/null
    or err "Failed to build webb wheel"

    # Remove any previous installation first — python-installer refuses to
    # overwrite existing files, so we clean up before reinstalling.
    # Use find instead of globs: fish errors on unmatched wildcard patterns.
    sudo rm -f /usr/bin/webb /usr/local/bin/webb
    for dir in (find /usr/lib /usr/local/lib -maxdepth 4 \( -name "webb" -o -name "webb-*.dist-info" \) -type d 2>/dev/null)
        sudo rm -rf $dir
    end

    # python-installer just copies wheel files — it does NOT resolve or install
    # dependencies, so it cannot touch any system-managed packages.
    sudo python3 -m installer --destdir=/ dist/webb-*.whl
    or err "Failed to install webb wheel"

    rm -rf dist/
    popd

    info "webb command installed to /usr/bin/webb"

    sudo install -Dm644 $DOTS/cli/completions/webb.fish \
        /usr/share/fish/vendor_completions.d/webb.fish
    info "Fish completions installed"
end

# ── 2. C++ plugin ─────────────────────────────────────────────────────────────
if $build_plugin
    section "webb-shell C++ plugin"

    for dep in cmake ninja pkg-config
        if not command -q $dep
            err "$dep not found — install with: sudo pacman -S cmake ninja pkgconf"
        end
    end

    set build_dir $DOTS/shell/build

    # Always wipe the build directory first.
    # CMakeCache.txt caches CMAKE_INSTALL_PREFIX, so if this repo was ever
    # configured with PREFIX=/usr the wrong value persists across runs.
    rm -rf $build_dir

    # IMPORTANT: PREFIX must be "/" not "/usr".
    # CMakeLists.txt defines install paths as "usr/lib/qt6/qml" (no leading slash),
    # so cmake appends them to the prefix. PREFIX=/usr would produce /usr/usr/lib/...
    # PREFIX=/ produces the correct /usr/lib/qt6/qml.
    cmake -S $DOTS/shell -B $build_dir -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/ \
        --log-level=WARNING
    or err "cmake configure failed — see output above for the missing library"

    cmake --build $build_dir --parallel (nproc)
    or err "cmake build failed"

    sudo cmake --install $build_dir
    or err "cmake install failed"

    info "Plugin installed to /usr/lib/qt6/qml/Webb/"
end

# ── 3. Shell QML ──────────────────────────────────────────────────────────────
if $install_shell
    section "webb-shell QML"

    set qs_dir $HOME/.config/quickshell/webb
    mkdir -p $qs_dir

    for dir in assets components config modules services utils
        ln -sfn $DOTS/shell/$dir $qs_dir/$dir
    end
    ln -sfn $DOTS/shell/shell.qml $qs_dir/shell.qml

    info "Shell QML symlinked → $qs_dir"
end

# ── 4. Config files ───────────────────────────────────────────────────────────
section "Webb config"

set webb_cfg $HOME/.config/webb
mkdir -p $webb_cfg/templates

if not test -f $webb_cfg/shell.json
    echo '{
  "general": {
    "apps": {
      "terminal": ["kitty"],
      "audio": ["pavucontrol"],
      "playback": ["mpv"],
      "explorer": ["thunar"]
    }
  },
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
}' > $webb_cfg/shell.json
    info "Created $webb_cfg/shell.json"
else
    warn "shell.json already exists — not overwritten"
end

if not test -f $webb_cfg/cli.json
    echo '{
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
  "toggles": {}
}' > $webb_cfg/cli.json
    info "Created $webb_cfg/cli.json"
else
    warn "cli.json already exists — not overwritten"
end

# ── 5. Hyprland scheme dir ────────────────────────────────────────────────────
section "Hyprland integration"

set scheme_dir $HOME/.config/hypr/scheme
mkdir -p $scheme_dir

if not test -f $scheme_dir/current.conf
    touch $scheme_dir/current.conf
    info "Created $scheme_dir/current.conf"
end

set hypr_conf $HOME/.config/hypr/hyprland.conf
if test -f $hypr_conf
    if grep -q "scheme/current.conf" $hypr_conf
        info "hyprland.conf already sources scheme/current.conf"
    else
        warn "Add these lines to $hypr_conf:"
        echo "      source = ~/.config/hypr/colors.conf"
        echo "      source = ~/.config/hypr/scheme/current.conf"
        echo "      exec-once = webb shell -d"
    end
else
    warn "$hypr_conf not found — create it and add:"
    echo "      source = ~/.config/hypr/colors.conf"
    echo "      source = ~/.config/hypr/scheme/current.conf"
    echo "      exec-once = webb shell -d"
end

# ── 6. PAM (lock screen auth) ─────────────────────────────────────────────────
section "PAM (lock screen)"

if test -d $DOTS/shell/assets/pam.d
    if not test -f /etc/pam.d/passwd
        sudo install -Dm644 $DOTS/shell/assets/pam.d/passwd /etc/pam.d/passwd
        info "PAM passwd config installed"
    else
        info "PAM passwd config already exists"
    end
    if not test -f /etc/pam.d/fprint
        sudo install -Dm644 $DOTS/shell/assets/pam.d/fprint /etc/pam.d/fprint
        info "PAM fprint config installed"
    end
end

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo (set_color green)(set_color --bold)"Installation complete!"(set_color normal)
echo ""
echo "  Next steps:"
echo "  1. Put wallpapers in ~/Pictures/Wallpapers/"
echo "  2. Set wallpaper + colours:  webb wallpaper -f ~/Pictures/Wallpapers/photo.jpg"
echo "  3. Add to hyprland.conf:     exec-once = webb shell -d"
echo ""
