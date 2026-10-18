# Report 004 - Cycle 004 (2026-10-18)

Input: user Test 1 report (locres-only pak). Outcome B - game boots normally, no Arabic
option in Options > Language. The user's message left three placeholders unfilled
(FPS stability, list contents, voice language); I flag them below in the questions to
the user, they do not change the diagnosis.

## Step 0 - Standing checks

- Spec hash re-verified at cycle start: VERIFIED OK (no restore needed).
- `git remote -v`: zero remotes (checked before commit, standing rule).
- Game folder: read-only this cycle (repak list/get operations only; all extracted
  analysis files live in the project's gitignored analysis area).

## Step 1 - AtomicHeart.log: NOT AVAILABLE (tested negative)

Order was to read AtomicHeart.log ("the -log option is active"). Searched:

- `%LOCALAPPDATA%\AtomicHeart\Saved\Logs\` - no `AtomicHeart.log`; contains ONLY the
  `NGX` folder (and its inner file is now GONE - the folder is empty; its content was
  cleaned up by the latest boot).
- The game tree - no `.log` files anywhere.
- Verdict: the `-log` launch option produced NO log file on this build
  (CONFIRMED by absence after a boot with the option active). KI-012 updated to
  CONFIRMED-negative: log capture is not viable in this build; do not spend cycles on it.
- Per-cause verdicts from asset-level evidence instead (see step 2): nothing to report
  from log lines; NOT AVAILABLE applies to all log-based claims in this cycle.

## Step 2 - WHY is native `ar` not listed? (the core investigation)

Root cause found and documented in full in `docs/LANGUAGE_SELECTION.md`:

**The Options > Language list is hardcoded inside the cooked DataAsset
`AtomicHeart/Content/Core/Data/Settings/DA_Audio.uasset` (+`.uexp`).**

Which file defines it (user's direct question): DA_Audio, a `DA_GameSettingsConfig`
instance; its LanguageMap OptionSelect carries per-language records. The page source
list in the cooked `AtomicHeart/Config/DefaultGame.ini` adds it as
`+ConfigurableSettings=/Game/Core/Data/Settings/DA_Audio.DA_Audio`
(consumed by the native `AHGameSettingsSubsystem` through `WBP_Options`).

Evidence:
1. DA_Audio.uexp string dump shows 13 records verbatim (display name + culture code):
   en-US, ru-RU, fr-FR, it-IT, de-DE, es-ES, pt-BR, pl-PL, zh-CN (+zh-hans),
   zh-TW (+zh-hant), ko-KR, ja-JP, uk-UA.
2. It is NOT derived from LocMeta: `be-BY` is staged (present in locmeta/config) yet
   NOT listed in the menu. That is why our modified locmeta (+ar) could never add a
   menu entry - Test-1 outcome B is fully explained by mechanism. Our pak did nothing
   wrong; locres contents were never even reached.
3. Standard UE4 tagged-property serialization confirmed by hex layout
   (int32 length + string + NUL per FString; repeating tag kinds).
4. No other options-list asset exists across all 19 paks (all indexes searched for
   language/culture-bearing names; only DA_Audio matches).

## Step 3 - Strategy decision (DECISIONS.md: DEC-015)

- The list IS data-driven (a cooked asset + a cooked ini, both ordinary pak files) and
  it IS editable by a mod pak without EXE changes (override mechanism already proven
  by our font-pak test). **Per your rule, strategy (a) applies and is logged:** add
  Arabic as a REAL 14th menu record via a DA_Audio override (display name "العربية"
  as an in-asset UTF-16 FString, culture `ar`, audio culture = en-US fallback).
  Our existing locmeta+NewP5-ar.locres work stays valid as-is; the missing piece was
  always this list entry.
- Type of work: binary surgery (append one record, bump count, extend the export's
  SerialSize/SerialOffset), implemented as scripts/patch_language_map.ps1 with a
  round-trip self-validation parser before packaging. BUILD ONLY until you approve
  installation (your step 5) - nothing is installed; the game folder is stock
  (test-1 pak was already removed last cycle and I did not reinstall anything).

## Step 4 - Fallback checks (prepared for DEC-007, not chosen)

**a. Are text and audio cultures selectable separately? (evidence)**

- The assets show ONE language selector. The LanguageMap entries couple
  display name + engine culture + Wwise audio culture per record; no separate VO
  selector exists in DA_Audio/DA_Display/DA_Gameplay, and WBP_Options has no second
  language widget. Verdict: no separate VO choice exists in the UI (CONFIRMED at asset
  level; the consuming code is native, so LIKELY overall).
- HOWEVER the practical outcome is voice-invariant: see (c).

**b. Slot candidates (3, with pros/cons) - approval required, none chosen silently**

IMPORTANT: whichever slot is chosen is only what shows in the menu; the slot's TEXT is
replaced by our Arabic locres. The user must never need that language as a language.

| Slot (shown in menu as) | Pros | Cons |
|---|---|---|
| **ko-KR (Korean)** - recommended | Officially TEXT-ONLY in retail (no Korean VO exists); enumerated in the menu already; rare target need; VO mapping falls back to en-US per DA_Audio_VoiceBanks (no voice change). | Wholesale replacement of Korean text; if Mundfish ever adds KO VO, the slot loses meaning; string-list details differ (menu still shows "Korean"). |
| **zh-TW (Chinese Traditional)** | Also text-only officially (VO falls back en-US); distinct Wwise alias zh-hant proves the slot is text-shaped by design; well-isolated reading area (mostly unused by the user). | Same replacement-of-language concern; zh display name would remain (cosmetic). |
| **uk-UA (Ukrainian)** | Fresh localization; VO mapping also en-US fallback; staged in locmeta; plausible the user never plays it. | Ukrainian HAS an official text localization used by UA players - ethically/ethnically sensitive to replace; if the UA VO patch exists in your build, selecting the slot may attempt UA audio banks (unverified). |

NOT candidates: en-US (your own language), ru-RU (has real Russian VO - would change
your voice when selected), any slot you actually play, and be-BY (staged but NOT in
the menu list - could never be selected without the same DA_Audio surgery needed by
strategy (a), which would defeat the point).

**c. Voice language stays untouched? (evidence)**

- DA_Audio_VoiceBanks.uexp: retail voice banks exist ONLY for English (en-US) and
  Russian (ru-RU). Polish/Italian/French/Chinese/German/Spanish/Japanese/Portuguese
  records map their audio/subs to `en-US` (verbatim in asset). Wwise media is shared
  (`WwiseAudio/Windows/`, no per-language folders).
- Therefore: selecting a non-en/non-ru slot (ko-KR / zh-TW / uk-UA / or our new `ar`
  record with audio=en-US) leaves the actual VO = whatever the mapping says =
  English when you play in English. Your voice stays untouched (CONFIRMED at asset
  level for this build) as long as you do not switch to ru-RU.

## Step 5 - Status of builds (per your order: NOTHING installed)

- Game folder: stock (19 paks, no ~mods). The test-1 pak stays available at
  `build/package/zzz_atomicheart-ar_locres_p1_P.pak` (not installed).
- Font pak v2 exists, untouched, NOT installed (separate later approval).
- New build tasks queued (never installed without your approval):
  1. scripts/patch_language_map.ps1 - DA_Audio override with the 14th `ar` record
     (build to build/, self-validate re-parse, verify round-trip, no install).
  2. (only if that fails) carrier-slot locres variant for your approved slot.

## Step 6 - Standing rules

No EXE/DLL changes; game folder untouched this cycle (read-only pak indexing +
extraction to the project area); nothing uploaded anywhere (`git remote -v` = zero
remotes verified before commit); spec hash verified at cycle start.

## Step 7 - Documentation updated and committed

- docs/LANGUAGE_SELECTION.md (new, full evidence dossier).
- DECISIONS.md: DEC-015 (strategy a locked as primary; DEC-007 fallback prepared).
- KNOWN_ISSUES.md: KI-012 closed as CONFIRMED-negative; KI-013 added (DA_Audio
  language list override = the new plan).
- STATUS.md + CHANGELOG.md cycle-004 sections; commits local-only.
- This report: lastreport.md + reports/history/report_004.md.

## Cycle 004 addendum (same report file, after the user's digital answers)

User answered:
1. BUILD approval = "Yes, build only" for the DA_Audio native-ar route.
2. Fallback slot pick = **ko-KR approved**.
3. Test 1 details: FPS = NORMAL. (List contents / voice language remain unknown.)

Engineering outcome on (1): the DA_Audio route is a REAL but heavier work item -
the asset is cooked UNVERSIONED (tagless property serialization; FileVersionUE4=0;
the .uexp data has no property tags and must be re-derived from the class schema).
Safe in-place extension therefore needs schema-reconstruction tooling. Logged as
KI-013 + DEC-015 amendment: Phase 8 tooling work (parser skeleton in
scripts/inspect_da_audio.ps1). Nothing unsafe was attempted in-place.

Engineering outcome on (2): the ko-KR carrier pak was BUILT and validated this cycle:
- builder: scripts/build_carrier_locres_pak.ps1
- output: build/package/zzz_atomicheart-ar_carrier_koKR_p1_P.pak (489,923 bytes)
- sha256: 146f9c5f50744eed0b3ed614cf9e84f177efb35049c46d59c8948ea4857596ab
- contents: ONE entry - AtomicHeart/Content/Localization/NewP5/ko-KR/NewP5.locres,
  the game's own ko-KR NewP5 locres with the 25 Arabic seed strings imported
  (UnrealLocres import; no LocMeta change needed; no fonts inside).
- validations: round-trip re-export 25/25 seed keys = Arabic byte-for-byte;
  control keys (Korean) unchanged (e.g. 신경폴리머 unchanged); pak unpack
  byte-identical to the staged locres.
- NOT INSTALLED (your step-5 order kept). The locres-only test-1 pak remains
  uninstalled as well.

## Next - your action (manual); I stop here

Nothing is installed; the game folder is stock. Test 2 (recommended, pending your go):
1. Say "install test 2" - I will install TWO paks ONLY:
   - zzz_atomicheart-ar_carrier_koKR_p1_P.pak (Arabic text over the ko-KR slot)
   - zzz_atomicheart-ar_font_p2_plex_P.pak (font v2 for Latin+Arabic rendering)
2. Launch normally; expect NORMAL FPS (no Naskh incidents; Latin is Word-readable).
3. Options > Language: select KOREAN.
4. Verify and screenshot: menus (remaining Korean visual difference expected);
   NewP5-scope strings (GameTips popups in game, upgrade text, AHGameSettings
   option captions) should display Arabic; report shaping/RTL quality.
5. Do NOT select ru-RU (it would switch the voice to Russian).
6. Report outcome classes: A = Arabic renders correctly (plus shaping quality);
   B = Arabic renders but broken (boxes/disconnected letters); C = Korean shows
   everywhere incl. our 25 strings; D = anything else (hang/crash/missing paks).
   If D: run scripts/uninstall_mod.ps1 immediately (proven working).
