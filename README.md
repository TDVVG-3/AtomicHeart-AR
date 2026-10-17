# AtomicHeart-AR — Atomic Heart Arabic Localization

A reproducible, script-driven Arabic localization pipeline for the PC (Steam) version of
**Atomic Heart** (App ID 668580).

## What this project does

- Discover how the installed version of Atomic Heart stores localization.
- Extract all translatable text safely (game files are always read-only).
- Preserve the original English source permanently, next to the Arabic translation.
- Build and validate an Arabic translation database.
- Research Arabic font support, shaping, and RTL rendering in the game's UI.
- Rebuild modified localization resources and package them as a data-only game mod.
- Install/uninstall the mod safely without touching other mods or game files.

## Supported game version

| Item            | Value                              |
|-----------------|------------------------------------|
| Game            | Atomic Heart (Steam)               |
| App ID          | 668580                             |
| Install path    | `C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart` |
| Steam build ID  | 24534183 (detected 2026-10-17)     |
| Depot           | 668581                             |
| Status          | Investigation in progress          |

## Current status

See [STATUS.md](STATUS.md). Short version: **research phase — no mod exists yet, nothing is translated yet.**

## Installation / Uninstallation

Not applicable yet. Mod packaging and installers will be added after the technical
prototype is proven (see [PLAN.md](PLAN.md)).

## Building from source

All build steps are PowerShell/Python scripts in `scripts/`. Tool binaries are
fetched and verified via `scripts/setup_tools.ps1` (see `tools/tools.lock.json`).

## Contributing translations

Not open yet. The master translation database will live in
`localization/master/atomic-heart-ar.tsv` (English source is never removed).

## Legal

- This project does **not** contain or distribute any original game files, PAKs, EXEs, or proprietary assets.
- This project does not bypass or modify DRM (Denuvo), Steam authentication, or licensing code.
- All game content, names, and trademarks belong to Mundfish / publishing rights holders.
- Project code and documentation: see [LICENSE](LICENSE). Third-party tool and font licenses: see `THIRD_PARTY_LICENSES.md` (created later).
