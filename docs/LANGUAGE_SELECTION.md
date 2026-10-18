# Language selection mechanism (cycle 004 evidence)

Question: why did a native `ar` slot (locmeta + NewP5-ar.locres in the locres pak) NOT
appear in the in-game Options > Language list?

## Answer (evidence-graded)

The Options > Language list is **NOT** derived from LocMeta culture staging. It is a
**hardcoded record list inside a cooked DataAsset**:

`AtomicHeart/Content/Core/Data/Settings/DA_Audio.uasset` (+ `.uexp`)
(class `DA_GameSettingsConfig`, setting type Language, an `OptionSelect` whose
`LanguageMap` array couples, per entry: display name string, engine culture code,
and Wwise/audio culture alias).

### Evidence chain

1. Extracted (read-only, pakchunk0) and string-dumped `DA_Audio.uexp`. The language
   records are plain in-file strings:
   `English(US)/en-US`, `Russian(...)/ru-RU`, `French(FR)/fr-FR`, `Italian(IT)/it-IT`,
   `German(DE)/de-DE`, `Spanish(ES)/es-ES`, `Portuguese(BR)/pt-BR`, `Polish(PL)/pl-PL`,
   `Chinese(CN)/zh-CN (+zh-hans)`, `English(US)/zh-TW (+zh-hant)`,
   `English(US)/ko-KR`, `English(US)/ja-JP`, `English(US)/uk-UA`.
   = **13 entries; `be-BY` is staged (locmeta/config) but NOT listed in the UI** -
   proving that "staged culture" alone never populates this menu. This explains
   cycle-004 Test-1 outcome B (Arabic missing despite the modified LocMeta).
2. The record serialization is standard UE4 tagged-property data (int32 length +
   string + NUL per FString; repeated `49/3A/4F` tag pattern kinds).
3. Consumption chain: cooked `AtomicHeart/Config/DefaultGame.ini` (also inside the pak)
   lists the options-page sources:
   `+ConfigurableSettings=/Game/Core/Data/Settings/DA_Audio.DA_Audio` (+ Display,
   Gameplay, Controls, Quality, Input, GamepadMapping, DlcOptions).
   The Options widget (`WBP_Options`) uses the native `AHGameSettingsSubsystem`
   (asset-printed import names: `GetAHGameSettingsSubsystem`, `SettingID`,
   `SettingsBlockTitle`), which reads these DataAssets.
4. Both `DA_Audio.uasset/.uexp` and `DefaultGame.ini` live in pakchunk0 as ordinary
   pak files: they are **overridable from a `~mods` pak without any EXE change**
   (the mount-priority override mechanism is already proven by our font pak test).
5. Voice side (user question 4a/4c): `DA_Audio_VoiceBanks.uexp` couples each language
   to its Wwise voice bank and per-language audio culture. Retail budgets VO only for
   `en-US` and `ru-RU`; **every other language's voice/subtitle mapping falls back to
   `en-US`** (records: Polish->en-US, Italian->en-US, French->en-US, Chinese->en-US,
   German->en-US, Spanish->en-US, Japanese->en-US). Wwise media is language-agnostic
   (single `WwiseAudio/Windows/` folder; 287 banks select per-language media).
   => Selecting a non-en/rnon-ru language keeps the (English) voice = the game's own
   designed behavior; there is no separate text-vs-voice selector found in the assets.

## Consequence for the project

- Native-`ar` (DEC program outcome A) becomes REACHABLE without EXE changes by
  overriding `DA_Audio` in a mod pak with a 14th record (`ar`, display "العربية",
  audio alias = en-US fallback). This is binary surgery on one cooked asset
  (append-driven: duplicate a record, patch display/culture, bump the array count,
  extend ExportMap SerialSize/SerialOffset in the .uasset). Feasibility: LIKELY;
  build offline + self-parse validation; install only after user approval.

### Cycle 004 amendment (blocking discovery, evidence-based)

The DA_Audio asset is cooked **UNVERSIONED (tagless)**: `FileVersionUE4 = 0`, the
.uexp opens directly with schema-ordered values (`12 00 00 00 ... int64s`) and closes
with the UE4 package magic at its tail. Property names/types are NOT serialized;
they must be reconstructed from the class schema (DA_GameSettingsConfig + engine
classes). A generic tagged-property walker therefore cannot edit this asset safely
in the same cycle. Status of the DEC-015 primary route: REQUIRES schema tooling
(Phase 8 work item; candidate approach: UAssetAPI-schema reconstruction or headless
cook). The parser/inspector script from this cycle
(scripts/inspect_da_audio.ps1) codifies what was decoded (summary, name table with
entry stride calibrated at +4 bytes, single export @ 2765/13089, 13-record string
evidence) for that future work.

The user approved (cycle 004, digital answers):
- "Yes, build only" for the DA_Audio route (and no install), and
- ko-KR as the carrier slot for the fallback variant.

Therefore the ACTUAL build of cycle 004 is the DEC-007 carrier pak:
`build/package/zzz_atomicheart-ar_carrier_koKR_p1_P.pak`
sha256 `146f9c5f50744eed0b3ed614cf9e84f177efb35049c46d59c8948ea4857596ab` (489,923 B) -
NewP5 ko-KR locres with the 25 Arabic seed strings imported in place of the Korean
text (UnrealLocres import; round-trip 25/25 exact-match validation; non-seed keys
re-export verified unchanged Korean; pak unpack byte-identical). No LocMeta surgery,
no fonts, keeps English voice unselected by design (ko-KR falls back to en-US audio).

What to expect from the carrier test when installed with the font pak v2: select
Korean in Options > Language; NewP5-scope strings (upgrade/Gametips etc. keys)
display Arabic (with the v2 font), while ALL OTHER untranslated text in the game
stays Korean locres text; English voice unchanged.
- Fallback (DEC-007 carrier slot, Strategy C) remains prepared but becomes only the
  PLAN B: deliver Arabic as an existing slot's locres. Candidate slots (menu-listed,
  rare, VO-invariant): `ko-KR` (recommended), `zh-TW`, `uk-UA`.
  Slots that would ALTER the voice if the user selects them: `ru-RU` (ru VO) and
  any slot the user actually plays; `en-US` is not a candidate ever.

## Caveats recorded for honesty

- The exact record-boundary/serialization byte map is only partially decoded (enough
  for sizing and plausibility; a dedicated parser+patcher with round-trip validation
  precedes any build).
- Text/voice selectivity: assets show ONE language selector; no separate VO selector
  was found in DA_Audio/DA_Display/DA_Gameplay or WBP_Options (LEVEL: CONFIRMED for
  the asset side; the runtime subsystem code is native/unreadable -> LIKELY overall).
- `-log` steam launch option produced NO log file even with the flag (KI-012 update):
  evidence = absence of any .log in %LOCALAPPDATA%\AtomicHeart\Saved\Logs and the
  game tree after a boot with the flag active (only the emptyinged NGX folder remains).
