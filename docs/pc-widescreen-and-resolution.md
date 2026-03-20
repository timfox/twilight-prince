# Playing on PC: widescreen and full resolution

This repository **does not produce a native Windows/Linux game executable** (x86/arm64). It builds **PowerPC** binaries for GameCube/Wii that match retail. Running those on a PC means **emulation** or a **separate port project**—not something this decomp turns into with a few build flags.

That said, you can absolutely play on a **PC at high resolution and widescreen** using a **native PC emulator** and the right settings.

## 1. What “native on PC” can mean here

| Approach | Widescreen / resolution | Notes |
|----------|-------------------------|--------|
| **[Dolphin Emulator](https://dolphin-emu.org/)** on Windows/Linux/macOS | Yes: internal resolution, aspect ratio, hacks | **Practical** path; runs a native PC app (Dolphin); game is JIT/emulated. |
| **This repo’s build output** (DOL/REL) on real GC/Wii hardware | Hardware limits | Not “PC”; no arbitrary desktop resolution. |
| **Hypothetical Vulkan/OpenGL port** | Full control | **Not** this project’s goal; would be a new engine (see [vulkan-transition-audit.md](vulkan-transition-audit.md)). |

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

Enabling **`WIDESCREEN_SUPPORT`** for **GameCube** would be an **experimental, non-matching** change (it is not how retail GCN builds were compiled). That would require a deliberate fork, extensive testing, and is **out of scope** for upstream matching goals. The maintainable approach for “play on PC in widescreen” remains **emulator configuration** (and/or targeting **Wii** builds in this repo if you are developing against that configuration).

## 6. Summary

- **PC + fullscreen + high resolution**: use **Dolphin** (or another emulator), not a “PC build” of this repo.
- **In-source widescreen paths**: enabled for **Wii/Shield**-style framework flags in `configure.py`, not for standard **GCN** matching builds.
- **True native PC port**: a different project (new renderer, host toolchain, assets pipeline).

For building this decomp on Linux, see [ubuntu-native-build.md](ubuntu-native-build.md).
