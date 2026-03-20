#!/usr/bin/env bash
# Clone the community Twilight Princess PC port (mbayonal/tp-port) and vendor Aurora into extern/aurora.
# This repo (zeldaret/tp) does not build the port; run CMake in TP_PORT_DIR after this script.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TP_PORT_URL="${TP_PORT_URL:-https://github.com/mbayonal/tp-port.git}"
AURORA_URL="${AURORA_URL:-https://github.com/encounter/aurora.git}"

# Default: sibling directory ../tp-port (relative to this decomp checkout)
TP_PORT_DIR="${TP_PORT_DIR:-$ROOT/../tp-port}"
if [[ "${TP_PORT_DIR}" != /* ]]; then
  TP_PORT_DIR="$(cd "$ROOT" && cd "$(dirname "$TP_PORT_DIR")" && pwd)/$(basename "$TP_PORT_DIR")"
fi

echo "TP port URL:    $TP_PORT_URL"
echo "Target dir:     $TP_PORT_DIR"
echo "Aurora URL:     $AURORA_URL"
echo ""

if [[ -d "$TP_PORT_DIR/.git" ]]; then
  echo "Updating existing clone: $TP_PORT_DIR"
  git -C "$TP_PORT_DIR" pull --ff-only
else
  if [[ -e "$TP_PORT_DIR" ]]; then
    echo "ERROR: $TP_PORT_DIR exists and is not a git repo. Remove it or set TP_PORT_DIR." >&2
    exit 1
  fi
  echo "Cloning tp-port..."
  git clone "$TP_PORT_URL" "$TP_PORT_DIR"
fi

AURORA_DIR="$TP_PORT_DIR/extern/aurora"
mkdir -p "$(dirname "$AURORA_DIR")"

if [[ -d "$AURORA_DIR/.git" ]]; then
  echo "Updating Aurora: $AURORA_DIR"
  git -C "$AURORA_DIR" pull --ff-only
elif [[ -z "$(ls -A "$AURORA_DIR" 2>/dev/null || true)" ]]; then
  echo "Cloning Aurora into $AURORA_DIR ..."
  rmdir "$AURORA_DIR" 2>/dev/null || true
  git clone "$AURORA_URL" "$AURORA_DIR"
else
  echo "WARNING: $AURORA_DIR is non-empty and not a git repo; not overwriting." >&2
fi

echo ""
echo "Next (see tp-port README and docs/native-port-resources.md):"
echo "  cd \"$TP_PORT_DIR\""
echo "  cmake -B build -DCMAKE_BUILD_TYPE=Release"
echo "  cmake --build build"
echo "  # Provide legal game assets under assets/ as documented by tp-port."
