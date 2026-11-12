#!/usr/bin/env bash
set -Eeuo pipefail

python -m pip install --upgrade pip
python -m pip install --no-cache-dir -r requirements.txt

# Find a usable FFmpeg, not merely an executable named `ffmpeg`.
# Some hosts ship FFmpeg without the libopus encoder required by this bot.
if ! python - <<'PY'
import shutil, subprocess, sys
ffmpeg = shutil.which("ffmpeg")
if not ffmpeg:
    sys.exit(1)
r = subprocess.run([ffmpeg, "-hide_banner", "-encoders"], capture_output=True, text=True, timeout=20)
sys.exit(0 if r.returncode == 0 and "libopus" in r.stdout else 1)
PY
then
  echo "System FFmpeg with libopus was not found; installing portable Linux FFmpeg..."
  python -m pip install --no-cache-dir "imageio-ffmpeg>=0.6,<0.7"
fi

# YouTube currently needs yt-dlp EJS and a supported JS runtime.
if ! command -v deno >/dev/null 2>&1; then
  if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required to install Deno. Use the Dockerfile on this host."
    exit 1
  fi
  curl -fsSL https://deno.land/install.sh | sh
fi
export PATH="$HOME/.deno/bin:$PATH"

python - <<'PY'
import importlib
for name in ("aiohttp", "Crypto", "google.protobuf", "yt_dlp"):
    importlib.import_module(name)
    print(f"OK: {name}")
import subprocess
try:
    import main
    ffmpeg = main._verify_ffmpeg_opus()
except Exception as exc:
    raise SystemExit(f"ERROR: media preflight failed: {exc}")
print("OK: FFmpeg + libopus", ffmpeg)
PY

if command -v deno >/dev/null 2>&1; then deno --version; else node --version; fi
python -m yt_dlp --version
