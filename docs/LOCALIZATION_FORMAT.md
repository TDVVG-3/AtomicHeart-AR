# Localization Format — Atomic Heart (Steam, build 24534183)

Research state labels: CONFIRMED / LIKELY / UNKNOWN / REJECTED (MASTER_PROMPT §52).
Evidence: 2026-10-17, via `repak list`, `repak get`, and direct byte inspection.

## Summary

Atomic Heart uses the standard Unreal Engine **`.locres` / `.locmeta`** localization
system for **dialogue, cutscenes, mail, notes, terminals, and lore** — but the **main
game UI text is NOT in `.locres`**. It lives in `StringTable` / `DataTable` `.uasset`
assets. This split is the single most important finding for the project plan.

## 1. LocRes files (CONFIRMED)

- **Location pattern:** `AtomicHeart/Content/Localization/<Target>/<culture>/<Target>.locres`
  plus a sibling `<Target>.locmeta`.
- **565 locres/locmeta files** found across all 19 paks (see
  `reports/localization_candidates.txt`).
- **Format:** Unreal LocRes **version 3**. The first byte of every sampled `.locres`
  is `0x0E`, which is the LocRes v3 magic. Example: `SettingAppliers/ru-RU.locres`
  (37 bytes) and `Engine/en/Engine.locres` both begin `0x0E`.
- The `.locmeta` header carries a 16-byte hash and the native-culture string
  (e.g. `ru-RU`), confirming the culture staging.

### LocRes targets that actually ship files (from pak listing)

```
Academy_Dialogues, Chelomey_Dialogues, ChelomeyFinal_Dialogues, Chelomey_dlc3,
CrystalComplex_dlc4, CUTSCENES, Cutscenes_dlc1, DIALOGUES FOR LQA,
LebedevLab_dlc4, Locations_dlc2, Mails_01, Mails_Shebetars_dlc2,
Mails_Shebetars_dlc4, Mails_Shebetars_Tech_dlc3, Marshes_dlc1, Mendeleev_dlc1,
Misc, NewP5, NTD, OpenWorldVDNKh_Dialogues, Pavlov_Dialogues, PearTerminals,
Phasatron_dlc4, Polygon_Dialogues, Sakhalin_dlc3, Schebetar_Subs, Schebetars_dlc1,
SettingAppliers, Tech_dlc2, Tech_dlc3, Tech_dlc4, Theatre_Dialogues, Triton_dlc3,
Vavilov_Dialogues, VDNKh_Dialogues, WavePlatform_dlc4
```

Plus engine-level: `Engine/Content/Localization/Engine`, and
`OnlineSubsystem`, `OnlineSubsystemSteam`, `OnlineSubsystemUtils`.

### Cultures present per LocRes target (CONFIRMED)

Most targets ship 14 cultures:
`be-BY, de-DE, en-US, es-ES, fr-FR, it-IT, ja-JP, ko-KR, pl-PL, pt-BR, ru-RU, uk-UA, zh-CN, zh-TW`.
Engine locres use short forms (`en`, `es`, `ja`, `ko`, `pt-BR`, `fr`, `it`, `pl`, `ru`, `de`).
`SettingAppliers` ships **only `ru-RU`** (partial target).

**There is no `ar` / `ar-SA` culture anywhere.** This is CONFIRMED and central to the
carrier-culture decision (see §5).

## 2. Non-LocRes strings (CONFIRMED — main UI text lives here)

`AtomicHeart/Config/DefaultGame.ini` declares **52 `+LocalizationPaths=` targets**.
Many of the most important UI targets have **NO `.locres` in any pak**:

```
Game, GameTips, Loading Screen, LoreMenu, UI, WBP, Widgets, Quests, Skills,
Weapons_Items, WeaponUpgrades, Academy_Terminal, Charles_hints, NewTarget,
Save rooms names, Terminals additional profiles
```

A targeted search of all 19 paks for `Localization/Game/`, `Localization/UI/`,
`Localization/Widgets/`, `Localization/WBP/`, `Localization/Quests/`,
`Localization/Skills/`, `Localization/Weapons_Items/`, `Localization/GameTips/`,
`Localization/LoreMenu/`, `Localization/Loading Screen/`, `Localization/Academy_Terminal/`,
and `Localization/Charles_hints/` returned **NOT FOUND in any pak**.

This means these targets are either (a) empty/unused in this build, or (b) their text is
served from cooked `StringTable`/`DataTable` assets instead. Evidence strongly supports (b):

- `AtomicHeart/Content/Core/Data/InputTips/ST_GameTips_Texts.uasset` (StringTable for GameTips)
- `AtomicHeart/Content/Core/GameplayTags/DT_WeaponUpgradesTexts.uasset`
- `AtomicHeart/Content/Core/Data/Weapons/Upgrades/DA_UpgradesTexts.uasset`
- `AtomicHeart/Content/Development/NTD/StringDataBase/NTD_StringTable.uasset`
- `AtomicHeart/Content/DLC/NTD/DataTables/DLC*/NTD_StringTable_DLC*.uasset`
- Various `ST_*_Sentences.uasset` under DLC narrative folders
- `AtomicHeart/Content/Core/UI/Fonts/DT_Game_Text_Style.uasset` (text style DataTable)

`Core/Data` alone holds **3,368 `.uasset`** files (many are DataAssets for quests,
skills, weapons). Some of these DataAssets carry user-facing FText (names/descriptions).

**Conclusion (CONFIRMED):** a complete Arabic localization cannot be `.locres`-only.
The pipeline must also plan for `StringTable` / `DataTable` / DataAsset FText extraction
and repack. This is exactly the MASTER_PROMPT §28 "non-locres strings" scenario.
Full categorization is deferred to Phase 5 (`reports/non_locres_text.md`).

## 3. Where subtitle / dialogue text lives

- **Dialogue and cutscene** text is in the LocRes targets above (`CUTSCENES`,
  `*_Dialogues`, `*_dlc*`, `Schebetar_Subs` for subtitles).
- Voice-over subtitle widgets exist as Blueprints
  (`BP_AHWwiseActorWithSubtitleWidget`, etc.) but the actual strings are LocRes-driven.
- **CONFIRMED:** audio is Wwise-based (`DefaultWwise.ini`, `AkAudio` module) and FMOD
  DataAssets also appear (`Core/Data/FMOD/...`). Audio is out of scope for text
  localization; text culture and voice culture must remain separable (see §5).

## 4. Culture staging (CONFIRMED)

From `AtomicHeart/Config/DefaultGame.ini`:

```
-CulturesToStage=en
+CulturesToStage=en-US, ru-RU, be-BY, de-DE, es-ES, fr-FR, it-IT,
                 ja-JP, pl-PL, pt-BR, zh-CN, zh-TW, ko-KR, uk-UA
LocalizationTargetCatchAllChunkId=0
```

14 staged cultures, none Arabic. `LocalizationTargetCatchAllChunkId=0` means un-staged
culture strings fall back to the catch-all chunk (chunk 0). This is relevant to whether
an injected `ar` culture would load without config changes — **UNKNOWN** until tested.

## 5. Which text culture should carry Arabic (OPEN — Phase 7/8 decision)

- **Strategy A (native `ar` / `ar-SA`):** the game stages cultures explicitly and has a
  catch-all chunk. Whether adding an `ar` folder is picked up without editing
  `CulturesToStage` (which lives inside a pak we would not want to override wholesale) is
  **UNKNOWN**. Must be tested in the prototype.
- **Strategy C (reuse an existing text slot):** lower risk; the user picks an existing
  language in-game and sees Arabic text. The sacrificed language must be stated clearly.
  **LIKELY** to work but no less invasive until A is disproven.
- Decision deferred per ROADMAP.md. Do not choose yet.

## 6. Fonts (summary; full detail in FONT_RESEARCH.md)

- **CONFIRMED:** a `MultiLanguage` font system already exists at
  `AtomicHeart/Content/Development/UI/Fonts/MultiLanguage/` containing
  `AnekBangla-Bold` (Bengali), `Sarpanch-Bold` (Devanagari/Latin), `Srisakdi-Bold` (Thai),
  plus `MultiLanguage_Font.uasset`. The game therefore already ships **non-Latin script
  font fallback infrastructure** — a strong positive signal for Arabic feasibility.
- Base Latin fonts: Gotham, BlenderPro (Book/Medium/Bold/Heavy/Italic), BrutalType,
  `AH_Pixel_digits`. Japanese: Noto Sans JP (multiple weights).
- **UNKNOWN:** whether any existing font covers Arabic, and whether Slate/UMG in this
  build performs Arabic shaping and BiDi. Requires Phase 6/8 in-game test.
