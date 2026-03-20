#!/usr/bin/env bash
# Install typical apt dependencies to *configure* tp-port + Aurora on Ubuntu/Debian.
# You still need CMake >= 3.30 (e.g. pip install --user cmake) — see docs/native-port-ubuntu.md

set -euo pipefail

if [[ "${EUID:-}" -eq 0 ]]; then
  APT=(apt-get)
else
  APT=(sudo apt-get)
fi

"${APT[@]}" update
"${APT[@]}" install -y \
  build-essential \
  cmake \
  ninja-build \
  pkg-config \
  libx11-dev \
  libwayland-dev \
  libxext-dev \
  libxrandr-dev \
  libxcursor-dev \
  libxi-dev \
  libxinerama-dev \
  libgl1-mesa-dev \
  libvulkan-dev \
  libxkbcommon-dev \
  libxss-dev \
  libxtst-dev

echo ""
echo "OK: apt packages installed."
echo "Aurora requires CMake 3.30+. If \`cmake --version\` is below that, run:"
echo "  pip3 install --user cmake"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Then configure tp-port with GCC if needed:"
echo "  cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Release \\\\"
echo "    -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++"
echo ""
echo "Full notes: docs/native-port-ubuntu.md"
