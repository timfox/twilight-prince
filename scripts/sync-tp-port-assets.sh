#!/usr/bin/env bash
# Copy generated asset headers from a zeldaret/tp ninja build into mbayonal/tp-port.
# tp-port includes them as #include "assets/..." and expects them under TP_PORT_DIR/assets/.
#
# Prereq: configure + ninja in the decomp so build/${TP_VERSION}/include/assets/*.h exists.
#
# Usage:
#   bash scripts/sync-tp-port-assets.sh
#   ZELDARET_TP_ROOT=/path/to/tp TP_PORT_DIR=/path/to/tp-port TP_VERSION=GZ2E01 bash scripts/sync-tp-port-assets.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZELDARET_TP_ROOT="${ZELDARET_TP_ROOT:-$ROOT}"
TP_VERSION="${TP_VERSION:-GZ2E01}"
TP_PORT="${TP_PORT_DIR:-$ZELDARET_TP_ROOT/../tp-port}"
if [[ "${TP_PORT}" != /* ]]; then
  TP_PORT="$(cd "$ZELDARET_TP_ROOT" && cd "$(dirname "$TP_PORT")" && pwd)/$(basename "$TP_PORT")"
fi

SRC="$ZELDARET_TP_ROOT/build/$TP_VERSION/include/assets"
DST="$TP_PORT/assets"

if [[ ! -d "$SRC" ]]; then
  echo "ERROR: asset headers not found at:" >&2
  echo "  $SRC" >&2
  echo "Build the decompilation first (python3 configure.py && ninja) so dtk generates headers under build/${TP_VERSION}/include/assets/." >&2
  exit 1
fi

mkdir -p "$DST"
# Replace contents so removed upstream headers don't linger
rm -rf "${DST:?}/"*
cp -a "$SRC/." "$DST/"

echo "OK: synced asset headers"
echo "  from: $SRC"
echo "  to:   $DST"
echo "Reconfigure tp-port if CMake was already run without this directory."
