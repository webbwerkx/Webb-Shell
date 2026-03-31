import fcntl
import json
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

from webb.utils.colour import get_dynamic_colours
from webb.utils._webb_logging import log_exception, log_message
from webb.utils.paths import (
    w_state_dir,
    config_dir,
    data_dir,
    templates_dir,
    theme_dir,
    user_config_path,
    user_templates_dir,
)

# ── Matugen ──────────────────────────────────────────────────────────────────
#
# Webb calls `matugen image <path> --type <mode>` on every wallpaper change.
# matugen owns all app theming via its own template system
# (~/.config/matugen/config.toml).  Webb does NOT read matugen's output back —
# it just fires the command and lets matugen do its job.
#
# Webb additionally handles a small set of targets that matugen typically
# doesn't cover.  These are the defaults in ~/.config/webb/cli.json:
#
#   enableMatugen  true   — call matugen on wallpaper change
#   enableHypr     true   — write $colour vars to hypr/scheme/current.conf
#   enableTerm     true   — OSC-recolour every open terminal instantly
#   enableBtop     true   — btop theme file
#   enableHtop     true   — htop theme file
#   enableNvtop    true   — nvtop colour file (NVIDIA)
#   enableCava     true   — cava config
#   enableFuzzel   true   — fuzzel.ini colours
#
# Everything else (kitty, gtk, qt, discord, spicetify, …) should live in your
# matugen templates.  Those flags all default to false.
#
# Disable matugen: set "enableMatugen": false in ~/.config/webb/cli.json.


def matugen_available() -> bool:
    return shutil.which("matugen") is not None


def run_matugen(wallpaper_path: Path | str | None, mode: str) -> bool:
    """Fire `matugen image <path> --type <mode>` and return True on success.

    matugen reads ~/.config/matugen/config.toml and renders every template
    it finds there.  Webb does not touch matugen's output — this call is the
    entire matugen integration.
    """
    if not matugen_available():
        log_message("matugen: not found in PATH — skipping")
        return False

    if wallpaper_path is None:
        try:
            from webb.utils.paths import wallpaper_path_path
            wallpaper_path = Path(wallpaper_path_path.read_text().strip())
        except (IOError, FileNotFoundError):
            log_message("matugen: no current wallpaper path available")
            return False

    wallpaper_path = Path(wallpaper_path)
    if not wallpaper_path.exists():
        log_message(f"matugen: wallpaper not found at {wallpaper_path}")
        return False

    cmd = ["matugen", "image", str(wallpaper_path), "--type", "scheme-tonal-spot", "--mode", mode, "--prefer", "saturation"]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, stdin=subprocess.DEVNULL)
        if result.returncode != 0:
            log_message(f"matugen failed (exit {result.returncode}): {result.stderr.strip()}")
            return False
        log_message(f"matugen: applied from {wallpaper_path.name}")
        return True
    except FileNotFoundError:
        log_message("matugen: binary not found")
        return False
    except Exception as e:
        log_message(f"matugen error: {e}")
        return False


# ── Generic generators ───────────────────────────────────────────────────────

def gen_conf(colours: dict[str, str]) -> str:
    """Hyprland source-able variable declarations: $primary = RRGGBB"""
    return "".join(f"${name} = {colour}\n" for name, colour in colours.items())


def gen_scss(colours: dict[str, str]) -> str:
    return "".join(f"${name}: #{colour};\n" for name, colour in colours.items())


def gen_replace(colours: dict[str, str], template: Path, hash: bool = False) -> str:
    content = template.read_text()
    for name, colour in colours.items():
        content = content.replace(f"{{{{ ${name} }}}}", f"#{colour}" if hash else colour)
    return content


def gen_replace_dynamic(colours: dict[str, str], template: Path, mode: str) -> str:
    def fill_colour(match: re.Match) -> str:
        parts = match.group(1).strip().split(".")
        if len(parts) != 2:
            return match.group()
        col, form = parts
        if col not in colours_dyn or not hasattr(colours_dyn[col], form):
            return match.group()
        return getattr(colours_dyn[col], form)

    colours_dyn = get_dynamic_colours(colours)
    out = re.sub(r"\{\{((?:(?!\{\{|\}\}).)*)\}\}", fill_colour, template.read_text())
    return re.sub(r"\{\{\s*mode\s*\}\}", mode, out)


def c2s(c: str, *i: list[int]) -> str:
    """Hex → ANSI OSC escape for terminal recolouring."""
    return f"\x1b]{';'.join(map(str, i))};rgb:{c[0:2]}/{c[2:4]}/{c[4:6]}\x1b\\"


def gen_sequences(colours: dict[str, str]) -> str:
    return (
        c2s(colours["onSurface"], 10)
        + c2s(colours["surface"], 11)
        + c2s(colours["secondary"], 12)
        + c2s(colours["secondary"], 17)
        + "".join(c2s(colours[f"term{i}"], 4, i) for i in range(16))
        + c2s(colours["primary"], 4, 16)
        + c2s(colours["secondary"], 4, 17)
        + c2s(colours["tertiary"], 4, 18)
    )


def write_file(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", delete=False) as f:
        f.write(content)
        tmp = f.name
    shutil.move(tmp, path)


# ── Apply functions ──────────────────────────────────────────────────────────

@log_exception
def apply_terms(sequences: str) -> None:
    """Write OSC sequences to every open terminal pseudoterminal.

    This recolours all running terminal emulators (kitty, foot, etc.)
    instantly without needing a restart.  Sequences are also saved to
    ~/.local/state/webb/sequences.txt so new terminals can replay them.
    """
    state = w_state_dir / "sequences.txt"
    state.parent.mkdir(parents=True, exist_ok=True)
    state.write_text(sequences)

    for pt in Path("/dev/pts").iterdir():
        if pt.name.isdigit():
            try:
                fd = os.open(str(pt), os.O_WRONLY | os.O_NONBLOCK | os.O_NOCTTY)
                try:
                    os.write(fd, sequences.encode())
                finally:
                    os.close(fd)
            except (PermissionError, OSError, BlockingIOError):
                pass


@log_exception
def apply_hypr(conf: str) -> None:
    """Write colour variables to ~/.config/hypr/scheme/current.conf.

    The shell reads these as $primary, $surface, $onSurface, etc.
    Make sure your hyprland.conf contains:
        source = ~/.config/hypr/scheme/current.conf
    """
    write_file(config_dir / "hypr/scheme/current.conf", conf)


@log_exception
def apply_kitty(colours: dict[str, str], mode: str) -> None:
    """Write ~/.config/kitty/themes/webb.conf and hot-reload kitty.

    Only used if you are NOT theming kitty via matugen templates.
    Default is disabled — set "enableKitty": true in cli.json to enable.
    """
    lines = [
        f"# Webb — {mode}",
        f"foreground              #{colours['onSurface']}",
        f"background              #{colours['surface']}",
        f"selection_foreground    #{colours['surface']}",
        f"selection_background    #{colours['secondary']}",
        f"cursor                  #{colours['secondary']}",
        f"cursor_text_color       #{colours['surface']}",
        f"url_color               #{colours.get('blue', colours['primary'])}",
        "",
        "# Normal",
        *[f"color{i:<4} #{colours[f'term{i}']}" for i in range(8)],
        "",
        "# Bright",
        *[f"color{i:<4} #{colours[f'term{i}']}" for i in range(8, 16)],
    ]
    write_file(config_dir / "kitty/themes/webb.conf", "\n".join(lines) + "\n")

    kitty_conf = config_dir / "kitty/kitty.conf"
    include_line = "include themes/webb.conf"
    if kitty_conf.exists():
        if include_line not in kitty_conf.read_text():
            with open(kitty_conf, "a") as f:
                f.write(f"\n{include_line}\n")
    else:
        write_file(kitty_conf, f"{include_line}\n")

    subprocess.run(["pkill", "-USR1", "kitty"], stderr=subprocess.DEVNULL)


@log_exception
def apply_discord(scss: str) -> None:
    """Theme Discord/Vesktop via CSS injection.

    Only used if you are NOT theming Discord via matugen templates.
    Default is disabled.
    """
    with tempfile.TemporaryDirectory() as tmp_dir:
        (Path(tmp_dir) / "_colours.scss").write_text(scss)
        conf = subprocess.check_output(
            ["sass", "-I", tmp_dir, str(templates_dir / "discord.scss")], text=True
        )
    for client in ("Equicord", "Vencord", "BetterDiscord", "equibop", "vesktop", "legcord"):
        write_file(config_dir / client / "themes/webb.theme.css", conf)


@log_exception
def apply_pandora(colours: dict[str, str], mode: str) -> None:
    tpl = gen_replace(colours, templates_dir / "pandora.json", hash=True)
    write_file(data_dir / "PandoraLauncher/themes/webb.json", tpl.replace("{{ $mode }}", mode))


@log_exception
def apply_spicetify(colours: dict[str, str], mode: str) -> None:
    """Only used if NOT theming Spicetify via matugen. Default disabled."""
    write_file(config_dir / "spicetify/Themes/webb/color.ini",
               gen_replace(colours, templates_dir / f"spicetify-{mode}.ini"))


@log_exception
def apply_fuzzel(colours: dict[str, str]) -> None:
    write_file(config_dir / "fuzzel/fuzzel.ini",
               gen_replace(colours, templates_dir / "fuzzel.ini"))


@log_exception
def apply_btop(colours: dict[str, str]) -> None:
    write_file(config_dir / "btop/themes/webb.theme",
               gen_replace(colours, templates_dir / "btop.theme", hash=True))
    subprocess.run(["killall", "-USR2", "btop"], stderr=subprocess.DEVNULL)


@log_exception
def apply_nvtop(colours: dict[str, str]) -> None:
    """Write nvtop colours for NVIDIA GPU monitor.

    nvtop reads this file on the next launch, so a running instance is
    restarted to pick up the new colours immediately.
    """
    write_file(config_dir / "nvtop/nvtop.colors",
               gen_replace(colours, templates_dir / "nvtop.colors", hash=True))
    subprocess.run(["killall", "nvtop"], stderr=subprocess.DEVNULL)


@log_exception
def apply_htop(colours: dict[str, str]) -> None:
    write_file(config_dir / "htop/htoprc",
               gen_replace(colours, templates_dir / "htop.theme", hash=True))
    subprocess.run(["killall", "-USR2", "htop"], stderr=subprocess.DEVNULL)


def sync_papirus_colors(hex_color: str) -> None:
    try:
        if subprocess.run(["which", "papirus-folders"], capture_output=True).returncode != 0:
            return
    except Exception:
        return

    if not any(p.exists() for p in [
        Path("/usr/share/icons/Papirus"),
        Path("/usr/share/icons/Papirus-Dark"),
        Path.home() / ".local/share/icons/Papirus",
        Path.home() / ".icons/Papirus",
    ]):
        return

    r, g, b = int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16)
    mx, mn = max(r, g, b), min(r, g, b)
    brightness = mx
    saturation = 0 if mx == 0 else ((mx - mn) * 100) // mx

    if saturation < 20:
        color = "black" if brightness < 85 else ("grey" if brightness < 170 else "white")
    elif saturation < 60 and brightness > 180:
        color = _hue_color(r, g, b, brightness, use_pale=True)
    else:
        color = _hue_color(r, g, b, brightness, use_pale=False)

    try:
        subprocess.Popen(["sudo", "-n", "papirus-folders", "-C", color, "-u"],
                         stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                         start_new_session=True)
    except Exception:
        pass


def _hue_color(r: int, g: int, b: int, brightness: int, use_pale: bool) -> str:
    if b > r and b > g:
        r_r = (r * 100) // b if b else 0
        g_r = (g * 100) // b if b else 0
        if r_r > 70 and g_r > 70:
            return "blue" if abs(r - g) < 15 else ("violet" if r > g else "cyan")
        return "violet" if r_r > 60 and r > g else ("cyan" if g_r > 60 and g > r else "blue")
    elif r > g and r > b:
        if g > b + 30:
            rg = (g * 100) // r if r else 0
            if use_pale:
                return "palebrown" if rg > 70 and brightness < 220 else "paleorange"
            return "brown" if rg > 70 and brightness < 180 else "orange"
        return "pink" if b > g + 20 else ("pink" if use_pale else "red")
    elif g > r and g > b:
        return "yellow" if r > b + 30 else "green"
    return "grey"


@log_exception
def apply_gtk(colours: dict[str, str], mode: str) -> None:
    """Only used if NOT theming GTK via matugen. Default disabled."""
    gtk_css = gen_replace(colours, templates_dir / "gtk.css", hash=True)
    thunar_css = gen_replace(colours, templates_dir / "thunar.css", hash=True)
    for ver in ("gtk-3.0", "gtk-4.0"):
        write_file(config_dir / ver / "gtk.css", gtk_css)
        write_file(config_dir / ver / "thunar.css", thunar_css)
    subprocess.run(["dconf", "write", "/org/gnome/desktop/interface/gtk-theme", "'adw-gtk3-dark'"])
    subprocess.run(["dconf", "write", "/org/gnome/desktop/interface/color-scheme", f"'prefer-{mode}'"])
    subprocess.run(["dconf", "write", "/org/gnome/desktop/interface/icon-theme",
                    f"'Papirus-{mode.capitalize()}'"])
    sync_papirus_colors(colours["primary"])


@log_exception
def apply_qt(colours: dict[str, str], mode: str) -> None:
    """Only used if NOT theming Qt via matugen. Default disabled."""
    tpl = gen_replace(colours, templates_dir / f"qt{mode}.colors", hash=True)
    write_file(config_dir / "qt5ct/colors/webb.colors", tpl)
    write_file(config_dir / "qt6ct/colors/webb.colors", tpl)

    qtct = (templates_dir / "qtct.conf").read_text().replace("{{ $mode }}", mode.capitalize())
    fonts = {
        5: '\n[Fonts]\nfixed="Monospace,12,-1,5,50,0,0,0,0,0"\ngeneral="Sans Serif,12,-1,5,50,0,0,0,0,0"\n',
        6: '\n[Fonts]\nfixed="Monospace,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"\ngeneral="Sans Serif,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"\n',
    }
    for ver in (5, 6):
        write_file(config_dir / f"qt{ver}ct/qt{ver}ct.conf",
                   qtct.replace("{{ $config }}", str(config_dir / f"qt{ver}ct")) + fonts[ver])


@log_exception
def apply_cava(colours: dict[str, str]) -> None:
    write_file(config_dir / "cava/config",
               gen_replace(colours, templates_dir / "cava.conf", hash=True))
    subprocess.run(["killall", "-USR2", "cava"], stderr=subprocess.DEVNULL)


@log_exception
def apply_user_templates(colours: dict[str, str], mode: str) -> None:
    """Render your own templates from ~/.config/webb/templates/.

    Supports {{ $colourName.hex }}, {{ $colourName.rgb }}, and {{ mode }}.
    Rendered files land in ~/.local/state/webb/theme/.
    These are separate from your matugen templates — use them for anything
    matugen doesn't support.
    """
    if not user_templates_dir.is_dir():
        return
    for file in user_templates_dir.iterdir():
        if file.is_file():
            write_file(theme_dir / file.name, gen_replace_dynamic(colours, file, mode))


# ── Main entry point ─────────────────────────────────────────────────────────

def apply_colours(colours: dict[str, str], mode: str,
                  wallpaper_path: Path | str | None = None) -> None:
    """Apply all enabled theming targets.

    Since you use matugen for all app theming, the pipeline is:

      1. matugen image <path> --type <mode>
         → matugen renders your ~/.config/matugen/config.toml templates.
         → Webb does not touch those outputs.

      2. Webb handles everything matugen doesn't cover:
         hypr colour vars, terminal OSC recolour, btop/htop/nvtop/cava/fuzzel.

    To add more targets, add a matugen template for anything matugen supports,
    or drop a file in ~/.config/webb/templates/ for custom apps.
    """
    lock_file = w_state_dir / "theme.lock"
    w_state_dir.mkdir(parents=True, exist_ok=True)

    try:
        with open(lock_file, "w") as lock_fd:
            try:
                fcntl.flock(lock_fd.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                return

            try:
                cfg = json.loads(user_config_path.read_text()).get("theme", {})
            except (FileNotFoundError, json.JSONDecodeError):
                cfg = {}

            def enabled(key: str, default: bool = True) -> bool:
                return bool(cfg.get(key, default))

            # ── matugen ───────────────────────────────────────────────────────
            # Runs first — handles all your app templates before webb touches
            # anything, so matugen always wins on apps it covers.
            if enabled("enableMatugen"):
                run_matugen(wallpaper_path, mode)

            # ── webb targets (non-matugen apps) ───────────────────────────────
            if enabled("enableTerm"):
                apply_terms(gen_sequences(colours))
            if enabled("enableHypr"):
                apply_hypr(gen_conf(colours))

            # These default false — matugen should cover them via templates.
            # Flip to true in cli.json only if you DON'T have a matugen template.
            if enabled("enableKitty", default=False):
                apply_kitty(colours, mode)
            if enabled("enableGtk", default=False):
                apply_gtk(colours, mode)
            if enabled("enableQt", default=False):
                apply_qt(colours, mode)
            if enabled("enableDiscord", default=False):
                apply_discord(gen_scss(colours))
            if enabled("enableSpicetify", default=False):
                apply_spicetify(colours, mode)
            if enabled("enablePandora", default=False):
                apply_pandora(colours, mode)

            # These default true — matugen typically doesn't cover them.
            if enabled("enableFuzzel"):
                apply_fuzzel(colours)
            if enabled("enableBtop"):
                apply_btop(colours)
            if enabled("enableNvtop"):
                apply_nvtop(colours)
            if enabled("enableHtop"):
                apply_htop(colours)
            if enabled("enableCava"):
                apply_cava(colours)

            # Always runs — your own custom templates in ~/.config/webb/templates/
            apply_user_templates(colours, mode)

    finally:
        try:
            lock_file.unlink()
        except FileNotFoundError:
            pass
