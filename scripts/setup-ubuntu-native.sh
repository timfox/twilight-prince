#!/usr/bin/env bash
# Install packages needed to build this project on Debian/Ubuntu (native host, not Docker).
# Toolchains (binutils, compilers, wibo, dtk) are downloaded by configure.py / ninja on first build.

set -euo pipefail

if [[ "${EUID:-}" -eq 0 ]]; then
  APT=(apt-get)
else
  APT=(sudo apt-get)
fi

"${APT[@]}" update
"${APT[@]}" install -y git python3 ninja-build curl ca-certificates

echo ""
echo "OK: run from repo root:"
echo "  python3 configure.py"
echo "  ninja"
echo ""
echo "You still need game files under orig/<VERSION>/ (see README and docs/ubuntu-native-build.md)."
