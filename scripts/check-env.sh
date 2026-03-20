#!/usr/bin/env bash
# Sanity-check host tools and game asset layout before configure / ninja.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ERR=0

have() {
  if command -v "$1" >/dev/null 2>&1; then
    local ver
    ver="$("$1" --version 2>/dev/null | head -1 || true)"
    echo "OK: $1 ${ver:+($ver)}"
  else
    echo "MISSING: $1"
    ERR=1
  fi
}

have git
have python3
have ninja

if [[ -f build.ninja ]]; then
  echo "OK: build.ninja (run configure if configure.py changed)"
else
  echo "NOTE: no build.ninja yet — run: python3 configure.py (or: make configure)"
fi

VERSION="${TP_VERSION:-GZ2E01}"
ARC="orig/${VERSION}/files/RELS.arc"
if [[ -f "$ARC" ]]; then
  echo "OK: $ARC"
else
  echo "MISSING: $ARC"
  echo "      Set TP_VERSION if your tree uses another version id (default: GZ2E01)."
  ERR=1
fi

exit "$ERR"
