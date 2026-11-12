# Linux deployment

## Render native Python Background Worker

1. Push this project folder to a Git repository and create a Render **Background Worker** using the Python runtime.
2. Use `bash build.sh` as the Build Command and `bash start.sh` as the Start Command. The included `render.yaml` contains these settings.
3. Add a Secret File named `accs.txt`, one `UID:PASSWORD` account per line. Set `ACCOUNTS_FILE=/etc/secrets/accs.txt` (already present in `render.yaml`).
4. Add `TELEGRAM_BOT_TOKEN` as an environment variable.
5. Deploy and inspect the startup log. It must report the Python media dependencies and `FFmpeg + libopus` as ready.

Render's native runtimes are Debian 12 based and list FFmpeg as available both during builds and at runtime. The build script still verifies the `libopus` encoder and installs the portable `imageio-ffmpeg` wheel only if no usable system FFmpeg exists.

## Other Linux hosting

The most reproducible option is Docker. Build from the included `Dockerfile`; it installs Linux FFmpeg, verifies `libopus`, installs Python dependencies and Deno, then starts the bot. Mount/provide `accs.txt` securely and set `ACCOUNTS_FILE` to its runtime path. Set `TELEGRAM_BOT_TOKEN` as an environment variable.

For a native Python host, run `bash build.sh` at build time and `bash start.sh` at startup. It needs Python 3.12, pip, curl if Deno must be installed, persistent environment variables/secrets, a long-running worker process, and permission for the bot's outbound TCP/UDP connections. A platform that blocks outbound UDP or terminates background processes cannot host the game voice relay reliably, regardless of the Python source.

## Credentials

The archive intentionally excludes `accs.txt` and `config.json`. Do not upload account passwords or bot tokens into a public Git repository. Existing private files should remain outside the source archive. The app reads `TELEGRAM_BOT_TOKEN` from the environment first and reads game accounts from `ACCOUNTS_FILE` (or `accs.txt` by default).

## FFmpeg note

The separately supplied `ffmpeg-9.0.2-essentials_build.zip` is a Windows build and is not executable on Render's Linux runtime. This source does not ship that Windows executable. It provisions/uses a Linux FFmpeg binary and refuses to start if the selected binary lacks `libopus`.
