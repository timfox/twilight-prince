# Building `tp-port` on Ubuntu (Linux)

These steps were validated on **Ubuntu 24.04**–style environments for **[mbayonal/tp-port](https://github.com/mbayonal/tp-port)** with **[encounter/aurora](https://github.com/encounter/aurora)** in `extern/aurora`. Your exact package names may differ slightly on Debian or other releases.

## 1. Clone the port and Aurora

From the **zeldaret/tp** (decomp) repository root:

```sh
bash scripts/setup-native-port.sh
cd ../tp-port
```

Or set `TP_PORT_DIR` to another path (see [native-port-resources.md](native-port-resources.md)).

## 2. Toolchain and generators

```sh
sudo apt-get update
sudo apt-get install -y build-essential cmake ninja-build pkg-config \
  libx11-dev libwayland-dev libxext-dev libxrandr-dev libxcursor-dev \
  libxi-dev libxinerama-dev libgl1-mesa-dev libvulkan-dev libxkbcommon-dev \
  libxss-dev libxtst-dev
```

- **`build-essential`** — `gcc` / `g++` and **libstdc++** development files (required for linking C++ programs).
- **`ninja-build`** — optional but matches many CMake tutorials.

### CMake 3.30+ (required by Aurora)

Ubuntu’s default **CMake 3.28** is **too old** for current Aurora. Install a newer CMake, for example:

```sh
pip3 install --user cmake
export PATH="$HOME/.local/bin:$PATH"
cmake --version   # should show 3.30 or newer
```

Alternatively use [Kitware’s official binaries](https://cmake.org/download/) or another supported install method.

## 3. Configure with GCC (recommended)

If `/usr/bin/c++` points at **Clang** but the linker cannot find **`-lstdc++`**, force GCC:

```sh
export PATH="$HOME/.local/bin:$PATH"
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++
```

## 4. Apply compatibility patches (from this repo)

This decomp fork may ship **small patches** for `tp-port` under `contrib/patches/` (see `contrib/patches/README.md`). After cloning `tp-port` + Aurora:

```sh
bash scripts/apply-tp-port-patches.sh
```

## 5. Build

```sh
cmake --build build --parallel "$(nproc)"
```

Successful configuration does **not** guarantee the tree builds: **`tp-port` and `Aurora` move independently** and may temporarily break each other on `main`.

## 6. Known upstream friction (check before reporting here)

The patch series under **`contrib/patches/`** (applied by `scripts/apply-tp-port-patches.sh`, currently **`tp-port-001` … `tp-port-018`**) aligns **`aurora_ext.h`**, **`CMakeLists.txt`** (include path for generated **`assets/*.h`** headers), and several **GCC/Clang portability** fixes (`os_stubs`, JGadget, JKernel, `d_camera.cpp`, etc.) with **current Aurora** and a typical Linux toolchain. See **`contrib/patches/README.md`** for the full list and status. Further errors may appear as more TUs compile—iterate in your **`tp-port`** checkout or push fixes upstream.

The **decomp** repository (`zeldaret/tp`) does not control those files—only documents how to clone, patch, and build.

## 7. Assets (runtime files + **generated headers** for the build)

1. **Runtime:** follow **`tp-port`’s README** for placing your **legally obtained** game data where the port expects it. No copyrighted assets are stored in Git.

2. **Compile-time headers:** `tp-port` includes paths like `#include "assets/l_mat2DL__d_a_grass.h"`. Those `.h` files are **not** hand-written; the **decomp build** generates them under **`build/<VERSION>/include/assets/`** (from extracted REL/DOL data). After **`python3 configure.py`** and **`ninja`** succeed in **this** (`zeldaret/tp`) tree, copy them into the port:

```sh
# From zeldaret/tp repo root; default TP_VERSION is GZ2E01
bash scripts/sync-tp-port-assets.sh
# or: ZELDARET_TP_ROOT=/path/to/tp TP_PORT_DIR=/path/to/tp-port TP_VERSION=GZ2E01 bash scripts/sync-tp-port-assets.sh
```

Then **re-run CMake** in `tp-port` if you already configured before the headers existed.

Patch **`tp-port-014`** adds `${CMAKE_SOURCE_DIR}` to `tp_game_code`’s include path so `assets/*.h` resolves next to the port checkout.

---

See also [native-port-resources.md](native-port-resources.md).
