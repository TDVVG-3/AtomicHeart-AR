# Investigation Answers — The 10 Questions

Answers to the immediate objective in MASTER_PROMPT.md "START NOW".
Evidence date: 2026-10-17. Labels: CONFIRMED / LIKELY / UNKNOWN / REJECTED (§52).

---

## Q1. Where are Atomic Heart's translatable strings?

**ANSWER: SPLIT — CONFIRMED (two locations).**

1. **`.locres` files** for dialogue, cutscenes, mail, notes (NTD), terminals (Pear),
   lore, and most location/quest dialogue. Path pattern:
   `AtomicHeart/Content/Localization/<Target>/<culture>/<Target>.locres`.
   565 locres/locmeta files across all paks.
2. **Cooked `StringTable` / `DataTable` / DataAsset `.uasset` files** for the main UI
   (GameTips, weapon upgrades, skills, quests, items, DLC notes). These are NOT in locres.

The main menu / HUD / inventory / crafting / skills / quests / weapons text is served
from non-locres assets. This is the critical planning fact.
Evidence: `reports/localization_candidates.txt`, `reports/non_locres_text.md`,
`docs/LOCALIZATION_FORMAT.md`.

---

## Q2. Which files contain them?

**ANSWER: CONFIRMED.**

- LocRes targets that ship files (36 game + 3 engine):
  `Academy_Dialogues, Chelomey_Dialogues, ChelomeyFinal_Dialogues, Chelomey_dlc3,
  CrystalComplex_dlc4, CUTSCENES, Cutscenes_dlc1, DIALOGUES FOR LQA, LebedevLab_dlc4,
  Locations_dlc2, Mails_01, Mails_Shebetars_dlc2, Mails_Shebetars_dlc4,
  Mails_Shebetars_Tech_dlc3, Marshes_dlc1, Mendeleev_dlc1, Misc, NewP5, NTD,
  OpenWorldVDNKh_Dialogues, Pavlov_Dialogues, PearTerminals, Phasatron_dlc4,
  Polygon_Dialogues, Sakhalin_dlc3, Schebetar_Subs, Schebetars_dlc1, SettingAppliers,
  Tech_dlc2, Tech_dlc3, Tech_dlc4, Theatre_Dialogues, Triton_dlc3, Vavilov_Dialogues,
  VDNKh_Dialogues, WavePlatform_dlc4`, plus `Engine`, `OnlineSubsystem`,
  `OnlineSubsystemSteam`, `OnlineSubsystemUtils`.
- Non-locres key assets: `ST_GameTips_Texts`, `DT_WeaponUpgradesTexts`,
  `DA_UpgradesTexts`, `NTD_StringTable(+DLC1..4)`, `ST_DLC0x_*`, quest/skill/item
  DataAssets under `Core/Data/**` (3,368 uasset in Core/Data alone).

---

## Q3. Which archive/container contains them?

**ANSWER: CONFIRMED — `pakchunk0-WindowsNoEditor.pak` is the primary container.**

- All base-game locres and the core `Core/Data` UI assets live in `pakchunk0`
  (mount point `../../../`, 139,033 entries).
- DLC locres/assets live in `pakchunk12`–`pakchunk16` (and `pakchunk10`/`pakchunk11`
  which mount at `../../../AtomicHeart/Content/`).
- Container is a **UE4 legacy PAK, version 11, index NOT encrypted**. No IO Store
  (.utoc/.ucas/.sig) present.
Evidence: `reports/pak_index_summary.txt`, `docs/ARCHIVE_LAYOUT.md`.

---

## Q4. What localization format is used?

**ANSWER: CONFIRMED — Unreal LocRes version 3 (magic `0x0E`), plus cooked
StringTable/DataTable for non-locres UI.**

- Every sampled `.locres` begins with byte `0x0E` = LocRes v3.
- `.locmeta` accompanies each target (carries native-culture string, e.g. `ru-RU`).
- Non-locres UI text is standard UE4 `UStringTable` / `UDataTable` / DataAsset FText.
- Tooling: LocResUtility v2.1.1 / UnrealLocres for locres; UAssetGUI / FModel for uasset.
Evidence: byte inspection in `docs/LOCALIZATION_FORMAT.md`.

---

## Q5. Which font assets render UI and subtitles?

**ANSWER: LIKELY (asset locations CONFIRMED, exact UI-to-font wiring UNKNOWN).**

- Font assets are under `AtomicHeart/Content/Development/UI/Fonts/` and
  `.../Development/NTD/Fonts/`.
- Latin base: `Gotham-BookItalic`, `BlenderPro-{Book,Medium,Bold,Heavy,Italic}`,
  `BrutalType`, `AH_Pixel_digits`. Japanese: `Noto_Sans_JP/NotoSansJP-*`.
- **A `MultiLanguage/` folder already exists** with `AnekBangla-Bold` (Bengali),
  `Sarpanch-Bold` (Devanagari), `Srisakdi-Bold` (Thai), and `MultiLanguage_Font.uasset`.
  The game already ships non-Latin script font fallback infrastructure.
- Text styles: `Core/UI/Fonts/DT_Game_Text_Style.uasset`.
- **UNKNOWN:** which specific font the HUD/subtitles use, and whether any existing font
  covers Arabic. Requires Phase 6 mapping. Full notes: `docs/FONT_RESEARCH.md`.

---

## Q6. Can normal Unicode Arabic render correctly?

**ANSWER: UNKNOWN. Not tested.**

- No Arabic culture and no Arabic font asset has been found. The `MultiLanguage` folder
  proves the engine *can* be extended to non-Latin scripts, which is a positive signal,
  but it is not evidence that Arabic specifically works.
- Shaping, BiDi, ligatures, and glyph selection in this UE4 build are unverified.
- Requires the Phase 8 in-game prototype with a test string. Do not assume success.
- No pre-shaping/reversing will be done until the renderer is proven (§20/§22).

---

## Q7. Can a small Arabic mod be built without EXE/DLL modification?

**ANSWER: LIKELY — but not yet proven.**

- The data path is favorable: the PAK index is **not encrypted**, repak can pack/unpack
  all archives, and locres is a standard, repackable format. No EXE/DLL/DRM change is
  required to inject a data-only mod.
- The open technical risks that must be de-risked in the Phase 7 prototype:
  1. Whether the game loads a `~mods` PAK at all (mount point / chunk naming).
  2. Whether our rebuilt PAK needs the same Mundfish JSON pre-header.
  3. Whether an injected `ar` culture loads without editing `CulturesToStage` (which is
     inside a pak we would rather not override wholesale).
- None of these are proven yet. Status: NOT TESTED. Do not claim it works.

---

## Q8. What is the correct internal mount path for the final PAK?

**ANSWER: CONFIRMED for the *original* archives; the *mod* PAK path is LIKELY, unproven.**

- Original mount points (repak `info`):
  - `pakchunk0` and most chunks: `../../../`
  - `pakchunk10`, `pakchunk11`: `../../../AtomicHeart/Content/`
- Files are addressed as `AtomicHeart/Content/...` and `Engine/Content/...` under the
  mount point. Therefore our locres must be packed to paths like
  `AtomicHeart/Content/Localization/<Target>/<culture>/<Target>.locres` with a mount
  point of `../../../` (mirroring pakchunk0) to override correctly.
- **LIKELY:** a `~mods/AtomicHeart_Arabic_P.pak` with mount `../../../` will be picked
  up (standard UE4 mod convention). **Proving this is the first goal of Phase 7.**
  Do not finalize the package name/mount until the in-game load test passes.

---

## Q9. Which text culture should carry Arabic?

**ANSWER: UNKNOWN — decision deliberately deferred (correctly, per §23).**

- Staged cultures (DefaultGame.ini): `en-US, ru-RU, be-BY, de-DE, es-ES, fr-FR, it-IT,
  ja-JP, pl-PL, pt-BR, zh-CN, zh-TW, ko-KR, uk-UA`. No Arabic.
- `LocalizationTargetCatchAllChunkId=0` exists, which *might* let an added `ar` culture
  load — but whether the game exposes/loads a new culture without config edits is
  UNKNOWN until the prototype tests it.
- Strategy A (native `ar`) vs Strategy C (reuse an existing text slot) cannot be chosen
  without the Phase 7/8 test. Both remain open. Recorded in ROADMAP.md as deferred.
- If Strategy C is eventually required, the user will be told explicitly which language
  slot Arabic replaces (§23), and audio will be kept separable from text (§24).

---

## Q10. Which installed DLC contain separate localization resources?

**ANSWER: CONFIRMED — all four DLC have separate localization, split locres + assets.**

- **DLC 1:** `Cutscenes_dlc1, Marshes_dlc1, Mendeleev_dlc1, Schebetars_dlc1`
- **DLC 2:** `Locations_dlc2, Mails_Shebetars_dlc2, Tech_dlc2`
- **DLC 3:** `Chelomey_dlc3, Mails_Shebetars_Tech_dlc3, Sakhalin_dlc3, Tech_dlc3, Triton_dlc3`
- **DLC 4:** `CrystalComplex_dlc4, LebedevLab_dlc4, Mails_Shebetars_dlc4,
  Phasatron_dlc4, Tech_dlc4, WavePlatform_dlc4`
- Plus DLC non-locres: `ST_DLC01_Goose_Sentences`, `ST_DLC02_Gooserunner_Tutorial`,
  `ST_NTD_DLC3`, `ST_NTD_DLC4`, `NTD_StringTable_DLC1..4`.
- DLC content ships inside the shared paks (`pakchunk12`–`16`); Steam uses a single
  depot (668581), so DLC presence in-paks is CONFIRMED, but which DLC are *owned/active*
  is UNKNOWN until verified in-game.
Evidence: `reports/content_coverage.md`.

---

## Summary of what remains UNKNOWN (must be resolved by the prototype, Phase 7–8)

1. Does a `~mods` PAK load at all? (Q7, Q8)
2. Does the rebuilt PAK need the Mundfish JSON pre-header? (Q7)
3. Can normal Unicode Arabic render (shaping/BiDi/glyphs)? (Q6)
4. Which culture carries Arabic — native `ar` or a reused slot? (Q9)
5. Where exactly does `Game`/`UI`/`Widgets` text live (StringTable vs Widget BP)? (Q2)
6. Which fonts render HUD/subtitles, and do any cover Arabic? (Q5)
