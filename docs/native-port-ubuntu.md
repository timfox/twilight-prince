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

## 4. Build

```sh
cmake --build build --parallel "$(nproc)"
```

Successful configuration does **not** guarantee the tree builds: **`tp-port` and `Aurora` move independently** and may temporarily break each other on `main`.

## 5. Known upstream friction (check before reporting here)

As of recent `main` snapshots, the build can fail with **duplicate GX enum / stub declarations** between `tp-port`’s `include/tp/aurora_ext.h` and Aurora’s `include/dolphin/gx/GXEnum.h` (and related headers). That is a **port ↔ Aurora alignment** issue to fix in **those** repositories (pin a known-good Aurora commit, or update `aurora_ext.h`).

The **decomp** repository (`zeldaret/tp`) does not control those files—only documents how to clone and build.

## 6. Assets

Follow **`tp-port`’s README** for extracting your **legally obtained** game files into `assets/`. No copyrighted assets are stored in Git.

---

See also [native-port-resources.md](native-port-resources.md).
