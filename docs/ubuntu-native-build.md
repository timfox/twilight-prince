# Building natively on Ubuntu

This guide walks through a **native Linux (Ubuntu)** developer setup for the same **configure + ninja** workflow described in the [README](../README.md). CI uses a prebuilt container; locally you install dependencies and let the build download PowerPC toolchains.

## 1. System packages

Install at minimum:

```sh
sudo apt-get update
sudo apt-get install -y git python3 ninja-build curl ca-certificates
```

Optional but useful:

- `clang-format` – formatting (see README).
- `wget` – if you prefer it over `curl` for manual downloads.

**Note:** The build downloads **prebuilt** [gc-wii-binutils](https://github.com/encounter/gc-wii-binutils), [compilers from decomp.dev](https://files.decomp.dev/), [decomp-toolkit](https://github.com/encounter/decomp-toolkit), and on Linux/macOS **[wibo](https://github.com/decompals/wibo)** to run Windows compiler binaries. You do **not** install Metrowerks from Ubuntu packages.

### Bootstrap script

From the repo root (installs the same `apt` packages as above):

```sh
bash scripts/setup-ubuntu-native.sh
```

## 2. Game assets (required)

You must supply a **legal copy** of the game. Place the disc image under:

```text
orig/GZ2E01/
```

Supported formats are listed in the README (ISO/GCM, RVZ, WIA, etc.). The extractor expects files such as `orig/GZ2E01/files/RELS.arc` after tooling runs—**without this, `ninja` fails early** with a missing `orig/...` path.

## 3. Configure and build

From the repository root:

```sh
git clone https://github.com/zeldaret/tp.git
cd tp
python3 configure.py
# or: python3 configure.py --version GZ2P01
ninja
```

Optional wrappers (repo root):

```sh
make check-env
make rebuild
# or: make configure CONFIGURE_ARGS="--map --version GZ2E01" && make build
```

First run will:

- Download **dtk**, **binutils**, **compilers**, and **wibo** (versions pinned in `configure.py`).
- Split/extract using `config/<VERSION>/config.yml`.

To match CI more closely (map files, specific version):

```sh
python3 configure.py --map --version GZ2E01
ninja all_source progress "build/GZ2E01/report.json"
```

## 4. Optional: custom tool paths

If you already have tools on disk:

```text
python3 configure.py --binutils /path/to/binutils --compilers /path/to/compilers
```

On Linux you can pass **`--wrapper`** to use **Wine** instead of the auto-downloaded **wibo** (see `tools/project.py`).

## 5. Parity with GitHub Actions

The workflow in `.github/workflows/build.yml` uses image `ghcr.io/zeldaret/tp-build:main` with **`/orig`** and **`/binutils`**, **`/compilers`** preinstalled. For identical behavior without Docker, you need the same **orig** layout and either downloaded tools (default) or the same paths passed to `configure.py`.

### Dev Container (VS Code / Cursor)

The repo includes **`.devcontainer/devcontainer.json`**, which uses the same **`ghcr.io/zeldaret/tp-build:main`** image as CI. Reopen the folder in a dev container, then copy or mount your **`orig/`** tree into the workspace (same layout as a native build). Configure using CI-style paths if you want to skip downloading toolchains into `build/`:

```sh
cp -a /orig .
python3 configure.py --binutils /binutils --compilers /compilers --version GZ2E01
ninja all_source progress "build/GZ2E01/report.json"
```

If you use the default `configure.py` (no `--binutils` / `--compilers`), the first **`ninja`** run downloads tools into `build/` as on bare Ubuntu.

### Docker (CLI, no editor)

Rough equivalent of the CI job (adjust the host path to your extracted **`orig`**):

```sh
docker run --rm -it \
  -v "$(pwd)":/work -w /work \
  -v /path/to/orig-parent:/orig:ro \
  ghcr.io/zeldaret/tp-build:main \
  bash -lc 'cp -a /orig . && python3 configure.py --binutils /binutils --compilers /compilers --map --version GZ2E01 && ninja all_source progress build/GZ2E01/report.json'
```

Mount the directory that **contains** the version folder (e.g. if the full path is `/media/tp/orig/GZ2E01`, mount `/media/tp/orig` so that **`orig/GZ2E01`** exists under `/work` after `cp -a /orig .`—match how CI’s `/orig` is laid out).

## 6. Troubleshooting

| Symptom | Likely cause |
|---------|----------------|
| `orig/.../RELS.arc not found` | Missing or wrong `orig/<VERSION>` layout; fix disc extraction path. |
| `ninja: command not found` | Install `ninja-build` (`apt`). |
| Wibo / compiler download failures | Network/firewall; retry; or mirror tools manually and use `--binutils` / `--compilers`. |
| Very slow first build | Normal—large object graph and PowerPC toolchain via wrapper. |

---

For **playing on a PC** at high resolution and widescreen (Dolphin, not a native binary from this repo), see [pc-widescreen-and-resolution.md](pc-widescreen-and-resolution.md).

For project goals, progress, and contribution rules, see <https://zsrtp.link> and the main README.
