# Native PC port (no emulator): resources and this repository

This document ties together **public projects** that aim to run *Twilight Princess* as a **native desktop** binary (x86/arm64), and how that relates to **`zeldaret/tp`** (this tree).

## 1. What “integration” means

- **`zeldaret/tp`** (this repo) produces **PowerPC** GameCube/Wii objects for **matching** retail builds. It does **not** ship a PC executable.
- A **native port** is a **separate codebase** that typically:
  - Reuses **decomp-derived** C++ (JSystem, game code),
  - Adds **host** OS + **PC graphics** (e.g. GX compatibility layer),
  - Uses **CMake** / Clang targeting your machine—not Metrowerks + wibo.

You do **not** run `ninja` here and get a `.exe` / Linux binary. You **clone the port project**, satisfy its dependencies (see below), and build **there**.

## 2. Public PC port project (WIP)

| Resource | Role |
|----------|------|
| **[mbayonal/tp-port](https://github.com/mbayonal/tp-port)** | Community **Twilight Princess PC port** (early development): CMake, C++20, `TARGET_PC`, integrates **Aurora** for GX. README describes JSystem, fapGm, input, and planned GX→Aurora bridge. |
| **[encounter/aurora](https://github.com/encounter/aurora)** | **GX / VI / pad**-style compatibility layer (“source-level GameCube & Wii compatibility layer”) used as `extern/aurora` in that port. |

**Status (as described upstream):** initialization and subsystems are partly working; full gameplay rendering is still **in progress**. Treat this as **experimental**, not a drop-in replacement for Dolphin.

**Related (different platform / scope):**

- **[Zelda64Recomp](https://github.com/Zelda64Recomp/Zelda64Recomp)** — N64 **static recompilation**; **not** applicable to GameCube binaries directly.
- **[zsrtp](https://github.com/zsrtp)** org — tools, randomizer, older decomp experiments; not the main PC port above.

## 3. Automated clone + Aurora (`scripts/setup-native-port.sh`)

From the **root of this repository**, run:

```sh
bash scripts/setup-native-port.sh
```

By default this clones **`tp-port`** next to this repo (e.g. `../tp-port`), and if **`extern/aurora`** is empty, clones **encounter/aurora** into it (required for CMake’s `add_subdirectory(extern/aurora)`).

Environment overrides:

| Variable | Default | Meaning |
|----------|---------|--------|
| `TP_PORT_DIR` | `../tp-port` | Where to put the port checkout (absolute or relative to this repo). |
| `TP_PORT_URL` | `https://github.com/mbayonal/tp-port.git` | Port git URL (use your fork if you mirror). |
| `AURORA_URL` | `https://github.com/encounter/aurora.git` | Aurora git URL. |

Then follow the port’s **README** (CMake, assets under `assets/`, legal dump of the game).

Optional: apply **compatibility patches** maintained in this repo: `bash scripts/apply-tp-port-patches.sh` (see `contrib/patches/README.md`). These track **known** header clashes between `tp-port` and current Aurora; full alignment may still require upstream changes.

After a successful **`ninja`** in this decomp (so `build/<VERSION>/include/assets/` exists), sync **generated asset headers** into the port: `bash scripts/sync-tp-port-assets.sh` (see [native-port-ubuntu.md](native-port-ubuntu.md) §7). Without a full decomp build, `bash scripts/gen-tp-port-minimal-matdl-stub.sh` can create a tiny placeholder `assets/l_mat2DL__d_a_grass.h` for compile-only checks (see `contrib/patches/README.md`).

On **Ubuntu**, use [native-port-ubuntu.md](native-port-ubuntu.md) for a concrete package list (X11/Wayland/SDL build deps, **CMake ≥ 3.30** for Aurora, and `gcc`/`g++` flags). Quick apt helper: `bash scripts/setup-tp-port-ubuntu-deps.sh`.

## 4. Keeping this decomp and the port aligned

The port **vendors** a slice of decomp-style sources under its own `src/` layout; it is **not** a submodule of `zeldaret/tp`. Workflow in practice:

1. Land fixes and matching work **here** (or on [zeldaret/tp](https://github.com/zeldaret/tp) upstream).
2. **Cherry-pick / sync** relevant TUs into the port fork when maintainers accept them, **or** maintain a **fork of tp-port** that tracks your decomp branch.

There is no supported one-command “merge decomp into port” — expect **manual** integration.

## 5. Legal

Port projects **do not** ship Nintendo assets. You must supply your own **legally obtained** disc/ROM contents per each project’s instructions.

---

For emulation-based play (Dolphin), see [pc-widescreen-and-resolution.md](pc-widescreen-and-resolution.md). For graphics research (GX vs Vulkan), see [vulkan-transition-audit.md](vulkan-transition-audit.md).
