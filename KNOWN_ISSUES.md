# KNOWN ISSUES

Tracking current technical blockers and caveats (per MASTER_PROMPT.md).

| ID      | State     | Area        | Description |
|---------|-----------|-------------|-------------|
| KI-001  | BLOCKED   | Versioning  | Git is not installed on this machine, so the repository cannot be initialized yet (see DEC-003). Waiting for user approval to install Git for Windows. |
| KI-002  | OPEN      | Scope       | `MASTER_PROMPT.md` was accidentally created empty on first setup (2026-10-17, 0 bytes) and had to be re-provided by the user. No work was done against the empty file. |
| KI-003  | RESOLVED  | Disk I/O    | Game install is ~155 GB of PAKs. Full-archive hashing completed successfully (19/19 files). |
| KI-004  | OPEN      | Scope       | Main UI text (Game, UI, Widgets, WBP, Quests, Skills, Weapons_Items, GameTips, LoreMenu, Loading Screen) is NOT in locres. It lives in cooked StringTable/DataTable/DataAsset .uasset files. A locres-only localization would miss the entire main menu/HUD/inventory/crafting/skills/quests/weapons text. Requires Phase 5 asset-class-aware extraction (see DEC-006, reports/non_locres_text.md). |
| KI-005  | OPEN      | Licensing   | LocResUtility and UnrealLocres publish NO license file (all-rights-reserved by default). They are used locally only and must NOT be redistributed by this project. UnrealLocres is also unmaintained since 2021. See docs/TOOLCHAIN.md. |
| KI-006  | OPEN      | Packaging   | Every game PAK has a custom Mundfish JSON pre-header (.uproject descriptor) before the standard UE4 payload. Whether a rebuilt mod PAK must replicate this pre-header is unproven and must be tested in the Phase 7 prototype. See docs/ARCHIVE_LAYOUT.md. |
| KI-007  | NOTED     | Versioning  | `AtomicHeart.exe` (276,832 bytes) has EMPTY FileVersion/ProductVersion/ProductName resources (likely a Denuvo-protected launcher stub). Game version is therefore identified by Steam build ID 24534183 and PAK SHA256 hashes, not by exe version metadata. SHA256 of exe is recorded in reports/game_scan.json. |
