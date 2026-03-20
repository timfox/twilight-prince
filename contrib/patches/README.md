# Patches for external `tp-port` checkouts

These files are **not** applied to the `zeldaret/tp` decomp tree. They are meant for a separate clone of **[mbayonal/tp-port](https://github.com/mbayonal/tp-port)** after you run `scripts/setup-native-port.sh`.

## Applying

From the **decomp** repo root:

```sh
bash scripts/setup-native-port.sh
bash scripts/apply-tp-port-patches.sh
# or: TP_PORT_DIR=/path/to/tp-port bash scripts/apply-tp-port-patches.sh
```

## Patch index

| File | Purpose |
|------|--------|
| `tp-port-001-aurora_ext-gxenum.patch` | Removes duplicate `GXMiscToken`, `GXFBClamp`, and FIFO getter **inline** definitions that clash with **current** [encounter/aurora](https://github.com/encounter/aurora) headers; adds `#define GX_MT_ABORT_WAIT_COPYOUT` for the retail-only token. |

## Limitations

**Aurora and `tp-port` move independently.** After `001`, the compiler may still report other conflicts in `include/tp/aurora_ext.h` (e.g. `GXVtxAttrFmtList`, `GXTlutSize`, fog helpers) that need **upstream** changes in `tp-port` or a **pinned Aurora commit** that matched the port when those stubs were written.

**If you fix more**, add `002-...patch` and contribute the same fix to **tp-port** so this folder can shrink.
