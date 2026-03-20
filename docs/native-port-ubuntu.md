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

Patch **`tp-port-001-aurora_ext-gxenum`** (applied by `scripts/apply-tp-port-patches.sh`) addresses the **first** duplicate `GXMiscToken` / `GXFBClamp` / FIFO getter conflicts. You may still see **additional** errors in `aurora_ext.h` vs newer Aurora headers (e.g. `GXVtxAttrFmtList`, `GXTlutSize`, fog helpers). Those are **port ↔ Aurora alignment** issues: fix in **tp-port** or **pin Aurora** to a matching revision; track upstream in **[mbayonal/tp-port](https://github.com/mbayonal/tp-port)**.

The **decomp** repository (`zeldaret/tp`) does not control those files—only documents how to clone, patch, and build.

## 7. Assets

Follow **`tp-port`’s README** for extracting your **legally obtained** game files into `assets/`. No copyrighted assets are stored in Git.

---

See also [native-port-resources.md](native-port-resources.md).
