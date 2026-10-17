# Archive Layout — Atomic Heart (Steam, build 24534183)

Research state labels follow MASTER_PROMPT §52: CONFIRMED / LIKELY / UNKNOWN / REJECTED.
Evidence gathered 2026-10-17 via direct byte inspection and `repak` v0.2.3.

## Install

- Path: `C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart`
- Steam App ID 668580, Depot 668581, build ID 24534183.
- `AtomicHeart.exe` present at install root. `AtomicHeart\` and `Engine\` subfolders present.
- Total PAK size ~155,303 MB across 19 files.

## Container type

- **CONFIRMED:** classic Unreal Engine 4 `.pak` archives (legacy format), version **11**
  (repak reports `version major: Fnv64BugFix`). There are **no** `.utoc`/`.ucas`/`.sig`
  files, so this is **not** an IO Store (Zen) build.
- **CONFIRMED:** the PAK index is **not encrypted** (`encrypted index: false`, encryption
  GUID all-zero). No AES key is needed to read or write these archives.
- **CONFIRMED:** compression method reported as `None` by repak at the container level
  (individual entries may still use per-entry compression; not yet audited).

## Mundfish custom PAK pre-header (important, non-standard)

- **CONFIRMED:** every `.pak` in this install is prefixed with a **custom JSON block**
  before the standard UE4 payload. For `pakchunk0` this pre-header is 11,412 bytes:
  a 53-byte binary prefix followed by a 11,359-byte UTF-8 JSON document.
- The JSON is an embedded **`.uproject`-style descriptor** for the game module
  `AtomicHeart` (FileVersion 3, EngineAssociation GUID
  `{1F97DF37-4B8D-0553-46E7-D0ABCD6B3024}`, module list, plugin list, target platforms).
- **CONFIRMED:** the standard UE4 pak magic `0x5A6F12E1` is located at the **tail** of
  the file (footer layout), not the head. This is normal for pak version >= 8, but the
  JSON pre-header shifts all absolute offsets by the pre-header length.
- `repak` v0.2.3 parses all 19 archives correctly despite the pre-header (it seeks to
  the footer magic). This is why repak is the preferred pack/unpack tool here.
- **Implication for packaging:** when we build our mod PAK we must decide whether the
  game expects the same JSON pre-header. This is an open prototype question (Phase 7).
  See DECISIONS.md once resolved.

## Mount points

- **CONFIRMED** via `repak info`:
  - `pakchunk0` (base game) and most chunks: mount point `../../../`
  - `pakchunk10`, `pakchunk11`: mount point `../../../AtomicHeart/Content/`
  - `pakchunk12`–`pakchunk16`: mount point `../../../`
- Files inside are stored with paths like `AtomicHeart/Content/...` and `Engine/Content/...`
  relative to the mount point. A full example real path:
  `AtomicHeart/Content/Localization/Game/en-US/Game.locres` (illustrative; see
  LOCALIZATION_FORMAT.md for which targets actually ship locres).

## Chunk inventory (19 files)

| File | Size (approx) | Entries | Role (heuristic) |
|------|---------------|---------|------------------|
| pakchunk0-WindowsNoEditor.pak | 33.16 GB | 139,033 | Base game (largest; holds most Core content + Engine) |
| pakchunk0optional-... | 51.6 MB | 3 | Optional texture streaming |
| pakchunk1 | 6.68 GB | 22,174 | Base game |
| pakchunk2 | 488 MB | 1,153 | Base game |
| pakchunk3 | 2.90 GB | 10,840 | Base game |
| pakchunk4 | 517 MB | 536 | Base game |
| pakchunk5 | 5.53 GB | 6,973 | Base game |
| pakchunk6 | 1.29 GB | 2,103 | Base game |
| pakchunk7 | 6.02 GB | 6,951 | Base game |
| pakchunk8 | 4.80 GB | 3,561 | Base game |
| pakchunk9 | 2.11 GB | 2,453 | Base game |
| pakchunk10 | 176 MB | 333 | DLC-ish (mount `.../Content/`) |
| pakchunk11 | 1.69 GB | 1,563 | DLC-ish (mount `.../Content/`) |
| pakchunk12 | 18.9 GB | 42,784 | DLC |
| pakchunk13 | 20.7 GB | 81,784 | DLC |
| pakchunk14 | 2.79 GB | 1,700 | DLC |
| pakchunk15 | 21.8 GB | 17,952 | DLC |
| pakchunk15optional | 33.6 MB | 1 | Optional texture streaming |
| pakchunk16 | 33.2 GB | 39,361 | DLC |

Note: the exact DLC-to-chunk mapping is heuristic (from `dlc1`/`dlc2`/`dlc3`/`dlc4`
naming inside paths). See `reports/dlc_inventory.txt` and `reports/content_coverage.md`.

## Per-file SHA256

Full hashes for all 19 PAKs and `AtomicHeart.exe` are recorded in
`reports/game_scan.json` and `reports/archive_inventory.txt`.
