# Playing on PC: widescreen and full resolution

**This repository (`zeldaret/tp`)** is a **matching decompilation**: it builds **PowerPC** GameCube/Wii binaries (DOL/REL) intended to match retail. It **does not ship** a Windows/Linux/macOS game executable from this tree—see the [README](../README.md). That is a policy and scope choice for this project, not a claim about what is technically possible elsewhere.

Separately, **community native ports** (recomp / custom renderers / host toolchains) are a **known pattern** after classic decomps (e.g. Super Mario 64, Ocarina of Time). People work on **forks and sibling projects** that retarget the game to PC-class CPUs and modern APIs. Those efforts are **not** produced by `configure.py` + `ninja` here; they are their own repositories, builds, and release channels. If you are using one, follow **that** project’s instructions for assets, widescreen, and resolution.

This page still covers two common paths:

- **Emulation** (Dolphin): very common, no separate port project required.
- **Native desktop build** (experimental community port + Aurora): see [native-port-resources.md](native-port-resources.md) and `scripts/setup-native-port.sh`.
- **Widescreen-related code** in *this* source tree (e.g. `WIDESCREEN_SUPPORT`): how it lines up with **Wii vs GameCube** retail-style builds.

## 1. What “native on PC” can mean here

| Approach | Widescreen / resolution | Notes |
|----------|-------------------------|--------|
| **[Dolphin Emulator](https://dolphin-emu.org/)** on Windows/Linux/macOS | Yes: internal resolution, aspect ratio, hacks | **Widely used**; Dolphin is a native PC app; the game runs **inside** emulation. |
| **Community native port** (recomp / custom backend) | Depends on project | **Not** shipped from this repo; may exist or evolve as **separate** community work. |
| **This repo’s build output** (DOL/REL) on real GC/Wii hardware | Hardware limits | PowerPC binaries; not a desktop executable. |
| **Research: modern API** | Vulkan, etc. | See [vulkan-transition-audit.md](vulkan-transition-audit.md)—host-side reimplementation is a large undertaking. |

## 2. Widescreen in *this* codebase vs retail builds

The decompilation includes optional **`WIDESCREEN_SUPPORT`** paths (see `include/m_Do/m_Do_graphic.h`, `src/m_Do/m_Do_graphic.cpp`: `setTvSize()`, 608×448 vs 808×448, aspect scaling).

In [configure.py](../configure.py), **`-DWIDESCREEN_SUPPORT=1`** is applied to **Wii** and **Shield** framework builds—not to **GameCube** (`GZ2E01` / `GZ2P01` / `GZ2J01`) matching configurations.

So:

- **Wii builds** in this tree compile with the same widescreen-related defines used for those platforms.
- **GameCube** retail-style builds keep the classic framebuffer defines (`FB_WIDTH` / `FB_HEIGHT` without widescreen support).

For **emulated play**, many people use **Dolphin’s graphics options** (and optional AR/Gecko codes) to get 16:9 and HD output **regardless** of which disc version you use.

## 3. Dolphin: full resolution (and then some)

Install [Dolphin](https://dolphin-emu.org/docs/guides/getting-started/), add your **legally dumped** ISO (from a disc you own).

1. **Graphics → Enhancements**
   - **Internal Resolution**: e.g. 1080p, 1440p, 4K (or “Auto (Window Size)”).
   - Optional: **Anti-Aliasing**, **Anisotropic Filtering**, **Texture filtering**.

2. **Graphics → General**
   - **Aspect Ratio**: e.g. **Force 16:9** for pillarboxed widescreen on a monitor, or **Stretch to Window** if you accept distortion.
   - **V-Sync**, fullscreen, etc., per taste.

3. **Advanced / Hacks** (names vary by Dolphin version)
   - **Widescreen Hack** (may help some games; test per title—can cause HUD/glitch issues).

Dolphin upsamples **3D**; **2D** elements (menus, some UI) may still be low-res or need per-game workarounds. That’s normal.

## 4. Widescreen beyond “force 16:9”

- Community **Gecko/Action Replay** codes exist for many games to widen the **3D** view; quality varies by scene. Search trusted communities for your **region** (e.g. GZ2E01) and Dolphin’s **Properties → Gecko Codes** tab.
- **Wii** versions often had official 16:9 display modes on real hardware; emulation can combine that with higher internal resolution.

Always use codes from reputable sources and verify they match your **exact** game ID.

## 5. If you wanted widescreen *inside* a GameCube-targeted build

Enabling **`WIDESCREEN_SUPPORT`** for **GameCube** would be an **experimental, non-matching** change (it is not how retail GCN builds were compiled). That would require a deliberate fork and extensive testing, and is **out of scope** for upstream matching goals. For **play on PC**, many people use **Dolphin’s graphics settings**; a **native port** is a **different codebase and release** than this repository.

## 6. Summary

- **`zeldaret/tp`**: builds **matching console** binaries; **does not** publish a PC executable from this repo.
- **Native PC**: may be pursued by **other community projects** (recomp / ports); use their docs and builds.
- **Emulation**: **Dolphin** remains the usual way to get HD resolution and widescreen options **without** a port project.
- **In-source widescreen paths**: enabled for **Wii/Shield**-style framework flags in `configure.py`, not for standard **GCN** matching builds.

For building this decomp on Linux, see [ubuntu-native-build.md](ubuntu-native-build.md).
