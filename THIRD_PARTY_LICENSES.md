# THIRD_PARTY_LICENSES.md

This project does not claim ownership of any third-party work. Bundled/used third-party
components, their licenses, and redistribution restrictions are documented below.

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

No third-party font is bundled yet. When IBM Plex Sans Arabic (or Noto Sans Arabic)
is downloaded in Phase 6/8, its license file will be placed in `fonts/licenses/` and
checked for redistribution permission before it ships in any release.

## Game content

- All Atomic Heart game content (text, audio, textures, fonts shipped with the game)
  is property of Mundfish and its licensors.
- This repository must not contain any original game archives, PAKs, EXE/DLL, or
  unnecessary proprietary assets (MASTER_PROMPT sections 1, 45, 47).
- Translated text derived from game content is distributed as a localization mod for
  owners of the game; it is not an official product of Mundfish.

## Project code and documentation

The project's own scripts and documentation are MIT licensed (see LICENSE).
