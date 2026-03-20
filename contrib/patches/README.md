# Patches for external `tp-port` checkouts

These files are **not** applied to the `zeldaret/tp` decomp tree. They are meant for a separate clone of **[mbayonal/tp-port](https://github.com/mbayonal/tp-port)** with **[encounter/aurora](https://github.com/encounter/aurora)** in `extern/aurora`, after `scripts/setup-native-port.sh`.

Apply **in order** (the script applies all `tp-port-*.patch` files sorted by name):

```sh
bash scripts/setup-native-port.sh
bash scripts/apply-tp-port-patches.sh
# or: TP_PORT_DIR=/path/to/tp-port bash scripts/apply-tp-port-patches.sh
```

## Requirements (Linux)

- **CMake ≥ 3.30** (Aurora); Ubuntu’s default CMake is often too old — use `pip install --user cmake` and `export PATH="$HOME/.local/bin:$PATH"`, see [docs/native-port-ubuntu.md](../../docs/native-port-ubuntu.md).
- **GCC** as `CXX` if Clang cannot link `libstdc++`: `-DCMAKE_CXX_COMPILER=g++`
- X11 / Wayland / Vulkan **dev** packages for SDL3 (see that doc).

## Patch index

| Patch | Purpose |
|-------|---------|
| `001` | Duplicate `GXMiscToken` / `GXFBClamp` / FIFO getters vs Aurora; `GX_MT_ABORT_WAIT_COPYOUT` define. |
| `002` | Large **aurora_ext.h** sync: drop stubs/types Aurora now provides; add `_GXVtxAttrFmtList` / `_GXFogAdjTable` aliases; remove PS\*→C\* macro block; etc. |
| `003` | **os_stubs.cpp**: `VIConfigure(const …*)`; remove `GXWGFifo` stub; `#include <dolphin/mtx.h>` for math section. |
| `004` | **game_stubs.cpp**: `BOOL` vs `bool` for Link stubs matching `d_a_alink.h`. |
| `007` | **std-stream.cpp**: `std::fpclassify`, `FP_NAN` (GCC vs Metrowerks intrinsics). |
| `008` | **linklist.cpp**: constructor name `TPRIsEqual_pointer_` (GCC parse). |
| `009` | **JKRHeap.cpp**: `operator delete` exception spec vs libstdc++. |
| `010` | **JUTDbPrint.cpp**: `#include <cstdarg>`. |
| `011` | **JUTException.cpp**: `std::isnan` / `std::isinf`. |
| `012` | **d_camera.cpp**: `std::fabsf` → `fabsf` (many sites). |
| `013` | **d_camera.cpp**: `isnan` → `std::isnan`. |
| `014` | **CMakeLists.txt**: add `${CMAKE_SOURCE_DIR}` to `tp_game_code` includes so `#include "assets/..."` resolves to `tp-port/assets/` (populated by `scripts/sync-tp-port-assets.sh` after a decomp `ninja`). |
| `015` | **m_Do_printf.cpp**: `#include <cstdarg>` for `va_start` / `va_end` (GCC). |
| `017` | **os_stubs.cpp** (apply **after `003`**): remove duplicate `GXNtsc480Int` / `C_MTX*` / `C_VEC*` definitions that clash with Aurora; stub missing GX entry points (`GXSetMisc`, `GXAbortFrame`, FIFO, XFB helpers, `GXPeekZ`, etc.). |
| `018` | **game_stubs.cpp** (apply **after `004`**): `daAlink_c::checkAcceptWarp()` stub for the linker. |

## Minimal asset header (no full decomp build)

If you do not yet have `build/<VER>/include/assets/` from a decomp `ninja`, generate a **minimal** `assets/l_mat2DL__d_a_grass.h` so `m_Do_ext.cpp` compiles:

```sh
bash scripts/gen-tp-port-minimal-matdl-stub.sh
```

Replace with `scripts/sync-tp-port-assets.sh` when you have a full asset generation.

## Status

These patches were developed against **current** `mbayonal/tp-port` **main** and **encounter/aurora** **main** on **GCC 13** / **g++**. With **`001`–`018`**, **`cmake --build`** can produce a linked **`tp-game`** on Linux (smoke-tested); runtime still needs legal game assets under the port’s VFS path. Further GCC/portability issues may appear as more TUs or upstream branches change—iterate in your `tp-port` clone or push fixes upstream.

**Goal:** contribute the same changes back to **[tp-port](https://github.com/mbayonal/tp-port)** so this directory can shrink over time.
