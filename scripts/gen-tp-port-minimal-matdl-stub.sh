#!/usr/bin/env bash
# Generate a minimal assets/l_mat2DL__d_a_grass.h for mbayonal/tp-port when a full
# zeldaret/tp ninja build (and sync-tp-port-assets.sh) is not available.
# Uses tools/converters/matDL_dis.py with an empty binary — enough for the linker;
# replace with synced headers from build/<VER>/include/assets/ for real gameplay data.
#
# Usage:
#   TP_PORT_DIR=/path/to/tp-port bash scripts/gen-tp-port-minimal-matdl-stub.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TP_PORT="${TP_PORT_DIR:-$ROOT/../tp-port}"
if [[ "${TP_PORT}" != /* ]]; then
  TP_PORT="$(cd "$ROOT" && cd "$(dirname "$TP_PORT")" && pwd)/$(basename "$TP_PORT")"
fi

mkdir -p "$TP_PORT/assets"
TMPBIN="$(mktemp /tmp/l_mat2DL__d_a_grass.bin.XXXXXX)"
:>"$TMPBIN"
python3 "$ROOT/tools/converters/matDL_dis.py" "$TMPBIN" "$TP_PORT/assets/l_mat2DL__d_a_grass.h" \
  --symbol l_mat2DL --scope local
rm -f "$TMPBIN"
echo "OK: wrote $TP_PORT/assets/l_mat2DL__d_a_grass.h"
