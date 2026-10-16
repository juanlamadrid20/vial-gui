#!/usr/bin/env bash
# Launch the Vial GUI from source (fbs run).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ ! -d "$ROOT/venv" ]]; then
  echo "No venv at $ROOT/venv." >&2
  echo "Create one first (see README.md or dbrx-setup.md)." >&2
  exit 1
fi

# shellcheck disable=SC1091
source "$ROOT/venv/bin/activate"

if ! command -v fbs >/dev/null 2>&1; then
  echo "fbs not found in venv. Install deps first:" >&2
  echo "  source venv/bin/activate && pip install -r requirements-modern.txt" >&2
  exit 1
fi

# A leftover main.py from a crashed run holds the raw-HID interface exclusive.
"$ROOT/kill-gui.sh" >/dev/null || true

exec fbs run "$@"
