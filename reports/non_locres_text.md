# Non-LocRes Text Sources — Initial Categorization

Generated 2026-10-17 (Phase 3 scope: identification, not full extraction).
Categories per MASTER_PROMPT §28: TRANSLATABLE / NOT_USER_VISIBLE / DUPLICATE /
TECHNICAL / UNKNOWN. Detailed per-string extraction is deferred to Phase 5.

## Why this matters

`AtomicHeart/Config/DefaultGame.ini` declares 52 `+LocalizationPaths=` targets, but many
core UI targets have **no `.locres` in any pak**. Their text is served from cooked
`.uasset` assets instead. A `.locres`-only localization would miss the main menu, HUD,
inventory, crafting, skills, quests, weapons, and upgrades text.

## Declared localization targets with NO locres found (CONFIRMED absent)

```
Game, GameTips, Loading Screen, LoreMenu, UI, WBP, Widgets, Quests, Skills,
Weapons_Items, WeaponUpgrades, Academy_Terminal, Charles_hints, NewTarget,
Save rooms names, Terminals additional profiles, Location_dlc2, Mails_Shebetars_dlc2(tbd)
```

Targeted `repak list` search across all 19 paks returned NOT FOUND for each of:
`Localization/Game/`, `Localization/UI/`, `Localization/Widgets/`, `Localization/WBP/`,
`Localization/Quests/`, `Localization/Skills/`, `Localization/Weapons_Items/`,
`Localization/GameTips/`, `Localization/LoreMenu/`, `Localization/Loading Screen/`,
`Localization/Academy_Terminal/`, `Localization/Charles_hints/`.

## Candidate non-locres text assets (by category)

### TRANSLATABLE (likely user-facing FText) — LIKELY

| Asset | Path | Notes |
|-------|------|-------|
| ST_GameTips_Texts | `Core/Data/InputTips/ST_GameTips_Texts.uasset` | StringTable for in-game tips |
| DT_WeaponUpgradesTexts | `Core/GameplayTags/DT_WeaponUpgradesTexts.uasset` | DataTable, weapon upgrade text |
| DA_UpgradesTexts | `Core/Data/Weapons/Upgrades/DA_UpgradesTexts.uasset` | DataAsset, upgrade descriptions |
| NTD_StringTable | `Development/NTD/StringDataBase/NTD_StringTable.uasset` | Notes/terminal base table |
| NTD_StringTable_DLC1..4 | `DLC/NTD/DataTables/DLC*/` | DLC notes tables |
| ST_DLC01_Goose_Sentences | `DLC/DLC01_Narrative/DLC01_Goose/` | DLC narrative sentences |
| ST_DLC02_Gooserunner_Tutorial | `DLC2/Narrative/GooseRunner/` | Tutorial text |
| ST_NTD_DLC3 / ST_NTD_DLC4 | `DLC3/Narrative/Sakhalin/`, `DLC4/Narrative/NarrSubs/` | DLC notes |
| ST_KolobokShell, ST_PickableBoy | DLC2 / DLC4 narrative | Translatable sentences |
| Quest DataAssets (`DA_Q_*`, `DA_*Quest*`) | `Core/Data/Quests/**` | Quest names/objectives likely inline FText |
| Skill DataAssets (`DA_*Skill*`) | `Core/Data/Skills/**` | Skill names/descriptions likely inline FText |
| Item overview DataAssets | `Core/Data/Inventory/` | Item name/description likely inline FText |

`Core/Data` alone contains **3,368 `.uasset`** files. A full sweep is Phase 5 work.

### NOT_USER_VISIBLE (by name) — LIKELY

Animation/attack/shake/FX/curve DataAssets, e.g. `DA_*_Animations.uasset`,
`DA_*Attack.uasset`, `DA_*Shakes.uasset`, `C_*Curve.uasset`, `T_*` textures,
foliage/landscape `ST_*` (StaticMesh/Texture, NOT StringTable). Note: `ST_` prefix is
ambiguous — it means StringTable in some folders and StaticTexture/Mesh in
`Environment/LandscapeProps`. Must be disambiguated by asset class, not filename.

### TECHNICAL — LIKELY

`DT_InputMappingContextTags`, `DT_DebugTextStyle`, `DT_Game_Text_Style` (text style
formatting, not prose), `DT_DefaultGamepadCursorSettings`, UniversalLock settings,
GameplayTags.

### DUPLICATE

Dialogue/lore that also exists as locres may be duplicated in DataAssets. Not yet
verified. UNKNOWN.

### UNKNOWN

Whether the `Game`/`UI`/`Widgets`/`WBP` targets are genuinely empty in this build or
their strings are embedded in Blueprint/Widget assets (`.uasset` of Widget class) rather
than StringTable/DataTable. Requires asset-class-aware extraction (Phase 5, UAssetGUI /
FModel).

## Recommendation for Phase 5 → superseded by Phase 5 results (2026-10-18)

1. Use FModel (GAME_UE4 profile) to open pakchunk0 and inspect the actual asset classes
   of `ST_*` / `DT_*` / `DA_*` under `Core/Data`.
2. Determine whether `Game`/`UI`/`Widgets` targets ship strings via Widget Blueprints
   (harder) or via a master StringTable we have not yet found (easier).
3. Only then size the non-locres extraction effort.

---

# Phase 5 RESULTS (2026-10-18) — mechanism CONFIRMED, landscape mapped

Extraction run: `scripts/extract_uasset_text.ps1` → 828 asset text dumps
(`localization/extracted/uasset_text/`, 29.7 MB) + catalog
(`reports/uasset_strings_catalog.txt`) + coverage cross-check
(`scripts/analyze_stringtable_coverage.ps1` → `reports/stringtable_coverage.csv`).

## CONFIRMED: how "missing-locres" targets deliver their text

1. StringTable/DataAsset uassets carry **RUSSIAN-native inline text** (verified in
   ST_GameTips_Texts, NTD_StringTable, ST_GooseRunner_Hints, ST_PickableBoy dumps;
   keys are Russian-transliterated ASCII, e.g. `zazhmite_i_uderzhivayte`).
2. For cultures whose locres exists, the display text is looked up in the locres by
   `Namespace/Key`, NOT from the inline string. Evidence: the en-US locres of target
   **NewP5** contains literal keys `ST_GameTips_Texts_/protivniki_mogut_ispolzovat`,
   `ST_GameTips_Texts_/chtobi_uklonyatsya` whose English text is the official English UI.
3. Other table namespaces resolve into other locres targets:
   `ST_PickableBoy/...` → Tech_dlc4, `NTD_StringTable_DLC2/...` → NTD,
   `All_Const_dlc2/Kolobok` → Locations_dlc2.
4. Namespace names do NOT always equal asset names (e.g. `All_Const_dlc2`); keying must
   stay verbatim from the locres export (master DB keeps the full combined key string).

## Coverage cross-check (algorithm: key-suffix match of every table's keys vs all en-US locres)

Among 33 StringTable-class assets found: 10 PARTIAL, 13 NOT-COVERED, 10 no-keys
(non-text assets misnamed ST_* such as textures/meshes — expected false positives).
Overall candidate pool: 574 NOT-COVERED / 42 COVERED / 15 PARTIAL / 197 no-keys,
most candidates being non-text assets (materials, vertex animation, meshes).

## CONFIRMED translation-gap set (RU-inline text with NO English locres entries)

- `ST_GooseRunner_Hints` (16 keys — `Main_Hint`, `SlideMode_Hint`, ...): exact key
  search over ALL en-US locres exports → zero matches. English players receive the
  Russian inline strings for these hints (upstream localization gap).
- Coverage-quality caveat: `analyze_stringtable_coverage` verdicts rely on filename
  heuristics; asset-class confirmation for the full gap set is Phase 7 work (DEC-010).

## Consequences for the Arabic pipeline (updates DEC-006)

- The **primary** path for Arabic UI text is the locres mechanism after all:
  translate the en-US locres corpus (incl. NewP5 which serves the "missing" targets)
  and ship an `ar` locres; StringTables resolve keys through it at runtime.
  Phase 7 must VERIFY in-game that (a) an injected `ar/NewP5.locres` loads and
  (b) StringTable keys resolve from it.
- The **secondary** path (true gap): tables with no locres entries at all
  (e.g. ST_GooseRunner_Hints) would need direct StringTable uasset editing
  (UAssetGUI round-trip) — keep as Phase 8 fallback scope, volume TBD.
- The old Phase 5 recommendation 1-2 above is moot for text extraction (locres covers
  the main UI), but asset-class confirmation for the gap set still applies.
