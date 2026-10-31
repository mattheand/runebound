#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -n "${GODOT:-}" ]]; then
  ENGINE="$GODOT"
elif command -v godot >/dev/null 2>&1; then
  ENGINE="$(command -v godot)"
elif command -v godot4 >/dev/null 2>&1; then
  ENGINE="$(command -v godot4)"
elif [[ -x "$HOME/Applications/Godot.app/Contents/MacOS/Godot" ]]; then
  ENGINE="$HOME/Applications/Godot.app/Contents/MacOS/Godot"
elif [[ -x /Applications/Godot.app/Contents/MacOS/Godot ]]; then
  ENGINE=/Applications/Godot.app/Contents/MacOS/Godot
else
  echo "Install Godot 4.7+ or set GODOT to the engine executable." >&2
  exit 1
fi
exec "$ENGINE" --path "$ROOT" "$@"
