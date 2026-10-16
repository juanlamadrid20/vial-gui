#!/usr/bin/env bash
# Stop any running Vial GUI (fbs run / main.py) so the HID device is released.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Match the GUI child and the fbs launcher. Keep patterns tight so we don't
# kill unrelated Python processes.
PATTERNS=(
  "src/main/python/main.py"
  "fbs run"
)

found=0
for pat in "${PATTERNS[@]}"; do
  if pgrep -f "$pat" >/dev/null 2>&1; then
    found=1
    echo "Killing processes matching: $pat"
    pgrep -lf "$pat" || true
    pkill -f "$pat" || true
  fi
done

if [[ "$found" -eq 0 ]]; then
  echo "No Vial GUI instance found."
  exit 0
fi

# Give processes a moment, then force-kill stragglers.
sleep 0.3
for pat in "${PATTERNS[@]}"; do
  if pgrep -f "$pat" >/dev/null 2>&1; then
    echo "Force-killing leftover: $pat"
    pkill -9 -f "$pat" || true
  fi
done

echo "Done."
