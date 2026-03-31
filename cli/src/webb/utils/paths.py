import contextlib
import hashlib
import json
import os
import tempfile
from pathlib import Path

config_dir = Path(os.getenv("XDG_CONFIG_HOME", Path.home() / ".config"))
data_dir = Path(os.getenv("XDG_DATA_HOME", Path.home() / ".local/share"))
state_dir = Path(os.getenv("XDG_STATE_HOME", Path.home() / ".local/state"))
cache_dir = Path(os.getenv("XDG_CACHE_HOME", Path.home() / ".cache"))
pictures_dir = Path(os.getenv("XDG_PICTURES_DIR", Path.home() / "Pictures"))
videos_dir = Path(os.getenv("XDG_VIDEOS_DIR", Path.home() / "Videos"))

w_config_dir = config_dir / "webb"
w_data_dir = data_dir / "webb"
w_state_dir = state_dir / "webb"
w_cache_dir = cache_dir / "webb"

user_config_path = w_config_dir / "cli.json"
cli_data_dir = Path(__file__).parent.parent / "data"
templates_dir = cli_data_dir / "templates"
user_templates_dir = w_config_dir / "templates"
theme_dir = w_state_dir / "theme"

scheme_path = w_state_dir / "scheme.json"
scheme_data_dir = cli_data_dir / "schemes"
scheme_cache_dir = w_cache_dir / "schemes"

wallpapers_dir = os.getenv("WEBB_WALLPAPERS_DIR", pictures_dir / "Wallpapers")
wallpaper_path_path = w_state_dir / "wallpaper/path.txt"
wallpaper_link_path = w_state_dir / "wallpaper/current"
wallpaper_thumbnail_path = w_state_dir / "wallpaper/thumbnail.jpg"
wallpapers_cache_dir = w_cache_dir / "wallpapers"

screenshots_dir = os.getenv("WEBB_SCREENSHOTS_DIR", pictures_dir / "Screenshots")
screenshots_cache_dir = w_cache_dir / "screenshots"

recordings_dir = os.getenv("WEBB_RECORDINGS_DIR", videos_dir / "Recordings")
recording_path = w_state_dir / "record/recording.mp4"
recording_notif_path = w_state_dir / "record/notifid.txt"


def compute_hash(path: Path | str) -> str:
    sha = hashlib.sha256()

    with open(path, "rb") as f:
        while chunk := f.read(8192):
            sha.update(chunk)

    return sha.hexdigest()


def atomic_dump(path: Path, content: dict) -> None:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(dir=path.parent, suffix=".tmp")
    try:
        with os.fdopen(fd, "w") as f:
            json.dump(content, f)
        os.replace(tmp_path, path)
    except Exception:
        with contextlib.suppress(OSError):
            os.unlink(tmp_path)
        raise
