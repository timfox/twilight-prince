# Graphics pipeline audit: GX (fixed-function TEV) toward Vulkan

This document summarizes how rendering works in this repository, clarifies terminology, and outlines what a **hypothetical** transition to a modern API such as Vulkan would involve. It is **research and architecture notes**, not a commitment to implement a PC port here.

## 1. What this codebase actually is

| Aspect | Reality |
|--------|---------|
| **Project** | Work-in-progress **decompilation** of *The Legend of Zelda: Twilight Princess* (see [README](../README.md)). |
| **Goal** | Byte-for-byte matching object code against retail binaries for supported versions—not a cross-platform engine rewrite. |
| **CPU** | PowerPC (“Gekko” / “Broadway”) via **Metrowerks CodeWarrior**-style toolchains. |
| **Graphics** | **Nintendo GX** (GameCube GPU API in Dolphin SDK; Wii uses the same model via Revolution). |

The upstream project **explicitly does not aim to produce a PC or Vulkan port** from this tree. Any move to Vulkan would be a **separate engine or reimplementation** that might *reuse ideas* from the decomp but would not be “the same” build product.

## 2. “Fixed pipeline” in this context

People often say “fixed-function pipeline” when talking about **OpenGL 1.x** (glBegin/glMatrixMode, etc.). **This code does not use OpenGL.**

On GameCube/Wii, the relevant analogue is **GX’s fixed-configuration pipeline**, especially:

- **TEV** (Texture Environment) stages: a small number of configurable combiner stages (roughly “register combiners” / blend equations), not arbitrary fragment shaders.
- **Fixed vertex attribute layouts** (`GXSetVtxAttrFmt`, `GXSetVtxDesc`) and **texture coordinate generation** (`GXSetTexCoordGen`).
- **Immediate-style geometry submission** via `GXBegin` / `GXEnd` with vertex formats (`GX_VTXFMT0`, …) in many places.
- **Embedded Frame Buffer (EFB)** operations, depth/peek, and **copy-to-texture** paths that are part of the platform’s render-to-texture story—not a generic FBO as in GL.

So the mental model for “transition to Vulkan” is: **emulate or re-express GX semantics** (including TEV graphs and EFB behavior) on top of **pipelines, render passes, and SPIR-V shaders**, not a thin swap of GL calls.

## 3. Where rendering lives in the tree

Rough layers (not exhaustive):

- **`libs/dolphin/`** – Dolphin SDK–style stubs and GX-related definitions for GameCube targets.
- **`libs/revolution/`** – Wii Revolution SDK areas (and libraries such as home-button UI code) with heavy **GXSet\*** usage (TEV, blend, fog, etc.).
- **`src/m_Do/m_Do_graphic.cpp`** – Central graphics / mode setup; very high concentration of GX state and draw setup.
- **`src/d/`** – Gameplay and world drawing: particles, map paths, rain, overlays, etc.—many direct **`GXBegin`** call sites.
- **JSystem** (`libs/JSystem/`) – Nintendo middleware (J3D, J2D, …) is built around GX assumptions (materials, packets, display lists conceptually).

A grep-oriented inventory shows **hundreds** of GX entry points spread across `src/` and `libs/`. There is no single “renderer class” to replace; the API is **pervasive**.

## 4. Why Vulkan is a different project from “finishing the decomp”

| Decompilation milestone | Vulkan-style port milestone |
|-------------------------|-----------------------------|
| Match symbols, layout, and instructions per TU | Define **swapchain**, **render passes**, **pipelines** |
| Link DOL/RELs like retail | Load **SPIR-V**, manage **descriptor sets** |
| Preserve PowerPC calling conventions | Target **x86-64 / ARM64** host ABI |
| Use retail asset pipelines as-is | Possibly **retarget** textures, shaders, and animation |

Porting work touches **every subsystem that touches GX or DMA** (display lists, EFB, pixel processing, possibly VI/video out). The decomp can **inform** a port (accurate behavior, filenames, data layouts) but **cannot** be turned into Vulkan by “replacing headers” alone.

## 5. Technical mapping: GX concepts → Vulkan building blocks

High-level correspondences (each GX feature often splits into **multiple** Vulkan objects and shader code):

| GX area | Vulkan-oriented notes |
|---------|------------------------|
| **TEV stages** (`GXSetTev*`, `GXSetNumTevStages`) | Fragment shader(s) implementing combiner math; may need **uber-shaders** or **pipeline specialization** per material. |
| **Texture formats** (`GX_TF_*`, TLUT, etc.) | **VkFormat**, **conversion passes** or **offline transcode** (many GX formats have no 1:1 desktop equivalent). |
| **Vertex attributes** (`GXSetVtxAttrFmt`, `GXSetVtxDesc`) | **VkVertexInputBindingDescription** / **attribute descriptions**; may require **vertex pulling** or padding for alignment. |
| **`GXBegin` immediate draws** | Build **CPU or GPU vertex buffers**; batch to reduce draw calls; consider **replaying** into static VBs offline. |
| **Transform / matrices** (`GXSetProjection`, `GXLoadPosMtx`) | **Uniform buffers** or **push constants**; vertex shader math. |
| **EFB / copy / peek** | **Render passes**, **attachments**, **resolve** / **compute** for anything mimicking EFB peek behavior. |
| **Fog, alpha compare, blend** | **Dynamic state** or **pipelines**; **VkPipelineColorBlendState**, depth compare in **VkPipelineDepthStencilState**. |

**Indirect stages** (`GXSetIndTex*`) add another layer of complexity in the fragment stage.

## 6. Suggested phased approach (for a hypothetical port)

1. **Instrumentation / documentation** – Catalog draw paths: immediate vs display-list-like, per-scene TEV presets, EFB usage. The decomp source is the best behavioral spec.
2. **GX abstraction layer** – A host-side library that exposes GX-like state and emits **GPU commands** (similar in spirit to **Dolphin’s VideoCommon** or a minimal **HLE** layer), implemented on Vulkan.
3. **Shader strategy** – Either **translate TEV graphs to SPIR-V** (compiler from TEV description) or **hand-author** families of shaders per material class (faster to ship, slower to cover 100% of content).
4. **Asset pipeline** – Extract or convert textures and meshes; validate against original screenshots (pixel-level parity is optional; gameplay parity is the usual bar).
5. **Performance** – Batch `GXBegin` storms, pipeline cache, descriptor indexing—only after correctness.

## 7. Risks and dependencies

- **Scope**: Full title coverage is **large**; graphics code is intertwined with **game logic**, **particles**, and **UI** (nw4r / J2D patterns).
- **Legal / project policy**: This repo is for **decompilation research**. A public Vulkan port would be a **different product** with its own licensing and asset policy.
- **Shield builds**: The tree includes **Shield** (Nvidia Shield, China) version strings in [configure.py](../configure.py). That suggests **historical** console variants; it does **not** imply this repository already contains a drop-in OpenGL/Vulkan backend for desktop—targets are still tied to the original toolchain matrix.

## 8. Conclusion

This codebase is a **faithful PowerPC/GX decompilation**, not a portable renderer. Moving from GX’s **TEV-centric fixed configuration** to **Vulkan** means building a **new rendering layer** that *implements* GX semantics (or a documented subset) on modern GPUs. The decompilation remains valuable as a **reference for behavior and data**, while the Vulkan effort would be a **long-running engine project** with distinct tooling, hosts, and goals.

---

*Document generated for research; align any port plans with [zeldaret](https://github.com/zeldaret/tp) project maintainers and their contribution guidelines.*
