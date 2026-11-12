#!/usr/bin/env bash
set -Eeuo pipefail
export PATH="$HOME/.deno/bin:$PATH"
exec python -u main.py
