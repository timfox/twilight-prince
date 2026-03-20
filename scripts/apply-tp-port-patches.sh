#!/usr/bin/env bash
# Apply local patches under contrib/patches/ to a mbayonal/tp-port checkout.
# Run after: bash scripts/setup-native-port.sh
#
# Usage:
#   TP_PORT_DIR=/path/to/tp-port bash scripts/apply-tp-port-patches.sh
#
# Patches are maintained here because they are not yet upstream in tp-port;
# contribute fixes back to https://github.com/mbayonal/tp-port when possible.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TP_PORT="${TP_PORT_DIR:-$ROOT/../tp-port}"
if [[ "${TP_PORT}" != /* ]]; then
  TP_PORT="$(cd "$ROOT" && cd "$(dirname "$TP_PORT")" && pwd)/$(basename "$TP_PORT")"
fi

if [[ ! -f "$TP_PORT/include/tp/aurora_ext.h" ]]; then
  echo "ERROR: tp-port checkout not found at: $TP_PORT" >&2
  echo "Clone first: bash scripts/setup-native-port.sh" >&2
  exit 1
fi

PATCH_DIR="$ROOT/contrib/patches"
shopt -s nullglob
for p in "$PATCH_DIR"/*.patch; do
  echo "Applying $(basename "$p") -> $TP_PORT"
  # -N: skip if already applied (GNU patch)
  patch -d "$TP_PORT" -p1 -N <"$p"
done

echo "OK: patches applied."
