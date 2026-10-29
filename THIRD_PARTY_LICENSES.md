# THIRD_PARTY_LICENSES.md

## Windows application runtime

The self-contained Windows installer includes the .NET 8 runtime and Windows Desktop
runtime. The packaging script copies their license files and available
third-party notices from the exact restored runtime packages into the release's
`licenses/` directory. These notices accompany the application's own MIT license.
The desktop application uses WPF and has no third-party UI packages.

This project does not claim ownership of any third-party work. Bundled/used third-party
components, their licenses, and redistribution restrictions are documented below.

## Linux application runtime

The self-contained AppImage includes .NET 8, Avalonia 11.3.22, SkiaSharp,
HarfBuzzSharp, MicroCom and Tmds.DBus dependencies. Their notices and restored
version list are packaged under `usr/share/doc/atomicheart-ar/`. Avalonia,
MicroCom and Tmds notices are retained in `app/AtomicHeartAR.Linux/Packaging/licenses/`;
the packager also copies notices from the exact NuGet/runtime packages.

AppImage's unmodified type-2 runtime (release 20251108, SHA256 pinned in the
packaging script) is MIT with the listed statically linked components under
their own terms, including libfuse LGPL. The bundled runtime notice links those
components. Source and build scripts:
https://github.com/AppImage/type2-runtime/tree/dd6cebedcbddde9c82f89b011e8e1d40b6e43868
Users can extract the AppDir and repackage it with a modified compatible runtime.
DejaVu Sans is obtained from the Linux system, not redistributed in the AppImage.

## Tools

| Tool | Version | License | Fischer status | Source |
|------|---------|---------|----------------|--------|
| FModel | aug-2026 | GPL-3.0 | Bundled in tools/bin (gitignored) | https://github.com/4sval/FModel |
| LocResUtility | v2.1.1 | NO LICENSE FILE (default copyright) | Bundled locally; NEVER redistribute | https://github.com/anubi47/LocResUtility |
| UnrealLocres | 1.1.1 | NO LICENSE FILE (default copyright) | Bundled locally; NEVER redistribute | https://github.com/akintos/UnrealLocres |
| UAssetGUI | v1.1.0 | MIT | Bundled in tools/bin (gitignored) | https://github.com/atenfyr/UAssetGUI |
| repak | v0.2.3 | Apache-2.0 / MIT (dual) | Bundled in tools/bin (gitignored) | https://github.com/trumank/repak |
| Git | (current stable) | GPL-2.0 | Installed system-wide via winget (Git.Git), user-approved | https://git-scm.com |

## STRICT RULE — unlicensed tools

The following tools publish **no license file** and are therefore all-rights-reserved by
default. They are used **locally** for this personal localization effort only:

- **LocResUtility** (anubi47)
- **UnrealLocres** (akintos)

Therefore:

1. They are **NEVER redistributed** by this project, in the repository, releases,
   archives, or any distribution channel.
2. They are **NEVER copied into `dist/`** or any release/package folder.
3. Reproducible builds must not embed them. Builds that depend on them must
   describe obtaining them from the official releases (documented in
   `docs/TOOLCHAIN.md`) and verify SHA256 (`tools/tools.lock.json`).
4. Their calculated SHA256 for local integrity checks is recorded in
   `tools/tools.lock.json` and `tools/bin/toolhashes.json`.

## Fonts

| Font | Version | License | Used as | Source |
|------|---------|---------|---------|--------|
| IBM Plex Sans Arabic | release @ibm/plex-sans-arabic@1.1.0 (SHA256 of zip: f03915581aea37d82792c188b08064023a73494d679b8e19f85f5971db714013) | SIL OFL 1.1 (redistributable) | Prototype UI font payload (v2 font pak, DEC-014) | https://github.com/IBM/plex/releases/tag/%40ibm/plex-sans-arabic%401.1.0 |

License files live in `fonts/licenses/` (IBM-Plex-Sans-Arabic-OFL-1.1.txt). OFL fonts may
be redistributed; they are NOT committed to this repository (only the license text is).

Former game-font payloads (BlenderPro/Gotham/BrutalType, commercial) and the downloaded
original font binaries under `source/original/fonts/` are gitignored and never
committed or redistributed.

## Game content

- All Atomic Heart game content (text, audio, textures, fonts shipped with the game)
  is property of Mundfish and its licensors.
- This repository must not contain any original game archives, PAKs, EXE/DLL, or
  unnecessary proprietary assets (MASTER_PROMPT sections 1, 45, 47).
- Translated text derived from game content is distributed as a localization mod for
  owners of the game; it is not an official product of Mundfish.

## Project code and documentation

The project's own scripts and documentation are MIT licensed (see LICENSE).
