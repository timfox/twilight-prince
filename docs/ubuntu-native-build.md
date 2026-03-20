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

## 6. Troubleshooting

| Symptom | Likely cause |
|---------|----------------|
| `orig/.../RELS.arc not found` | Missing or wrong `orig/<VERSION>` layout; fix disc extraction path. |
| `ninja: command not found` | Install `ninja-build` (`apt`). |
| Wibo / compiler download failures | Network/firewall; retry; or mirror tools manually and use `--binutils` / `--compilers`. |
| Very slow first build | Normal—large object graph and PowerPC toolchain via wrapper. |

---

For project goals, progress, and contribution rules, see <https://zsrtp.link> and the main README.
