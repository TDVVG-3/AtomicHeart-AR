# DECISIONS

Every major technical decision is recorded here (per MASTER_PROMPT.md §51).

---

## DEC-001 — Repository layout follows MASTER_PROMPT.md §8

Date: 2026-10-17

Decision:
Use the directory structure defined in MASTER_PROMPT.md section 8 without modification
(source / localization / glossary / fonts / build / dist / reports / qa / docs / scripts / tools).

Reason:
The spec is authoritative; no game-specific constraint requires a change yet.

Consequence:
Future extraction and build scripts have fixed, documented output locations.

---

## DEC-002 — Game installation is strictly read-only

Date: 2026-10-17

Decision:
`C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart` is treated as read-only.
All hashing/scanning is read-only. No files are written, moved, or deleted there.
The `~mods` folder will only be created (when it does not exist) at the install step,
which has not happened yet and requires user approval of the prototype.

Reason:
Hard rule from user brief and MASTER_PROMPT.md §0/§1 (never destroy source data).

Consequence:
Nothing in the game folder changes during Phases 1–4. Steam verification remains intact.

---

## DEC-003 — Do not install Git system-wide without approval

Date: 2026-10-17

Decision:
Git is not installed on this machine. Version control is a spec requirement (§45),
but installing software system-wide requires telling the user first. The project runs
fine without Git for now; the question is deferred to the user.

Reason:
User hard rule 4: "Install nothing system-wide without telling the user first."

Consequence:
`git init` is pending. All files are ready to be committed once Git is available.
The user will be asked to approve a Git for Windows install (winget) at the end of this cycle.

---

## DEC-004 — Project license: MIT (code/documentation only)

Date: 2026-10-17

Decision:
Project-owned code and documentation use the MIT license. No game content is included,
so no game license is affected. Third-party tools/fonts keep their own licenses
(recorded later in THIRD_PARTY_LICENSES.md).

Reason:
Spec requires a LICENSE file; MIT is the least restrictive standard choice for
scripts and docs, and does not conflict with anything.

Consequence:
Contributors know the terms; game assets remain untouched and unlicensed by this project.

---

## DEC-005 — repak is the primary PAK tool; UnrealPak deferred

Date: 2026-10-17

Decision:
Use repak v0.2.3 (Apache-2.0) as the primary PAK pack/unpack tool. Defer UnrealPak
(Epic proprietary) unless repak proves incompatible.

Reason:
The game's PAKs are UE4 legacy v11 with an UNENCRYPTED index. repak parsed all 19
archives successfully, including the custom Mundfish JSON pre-header (it seeks the
footer magic). No AES key is needed. repak is open-source, auditable, and does not
require an Unreal Engine install.

Consequence:
No Epic binaries in the repo. Toolchain stays open-source and redistributable for the
pack/unpack path. UnrealPak remains a documented fallback only.

---

## DEC-006 — Localization is split: locres + non-locres UI assets

Date: 2026-10-17

Decision:
Treat the project as covering TWO text systems, not one:
  (A) Unreal LocRes v3 for dialogue/cutscene/notes/terminal/lore.
  (B) Cooked StringTable/DataTable/DataAsset FText for main UI
      (GameTips, weapon upgrades, skills, quests, items, DLC notes).
Plan and size the pipeline for both. Do not declare the translation complete on locres
alone (per MASTER_PROMPT section 28).

Reason:
`DefaultGame.ini` declares 52 localization targets, but core UI targets (Game, UI,
Widgets, WBP, Quests, Skills, Weapons_Items, GameTips, LoreMenu, Loading Screen) have
NO locres in any pak. Their text is served from cooked assets
(e.g. ST_GameTips_Texts, DT_WeaponUpgradesTexts, DA_UpgradesTexts, NTD_StringTable).

Consequence:
Phase 5 must include an asset-class-aware extraction pass (FModel/UAssetGUI) in addition
to locres extraction. Non-locres work is likely the larger effort. This is recorded as a
scope risk in reports/non_locres_text.md.

---

## DEC-007 — Defer carrier-culture choice (Strategy A vs C) until prototype

Date: 2026-10-17

Decision:
Do NOT choose between adding a native `ar` culture (Strategy A) and reusing an existing
text slot (Strategy C) yet. Both remain open. Decide only after the Phase 7/8 prototype
proves which the game will actually load.

Reason:
14 cultures are staged via `CulturesToStage` inside a pak; `LocalizationTargetCatchAll
ChunkId=0` exists, so an injected `ar` folder *might* load, but this is UNKNOWN until
tested. Choosing now would be inventing a value (violates section 5).

Consequence:
Prototype must test native `ar` first (least invasive). If it fails, fall back to Strategy
C and clearly tell the user which language slot Arabic replaces.

---

## DEC-008 — Spec integrity guard (backup + hash + auto-restore)

Date: 2026-10-17
Status: ACTIVE (permanent, per user decision)

Decision:
`MASTER_PROMPT.md` is the authoritative spec. A byte-identical read-only backup lives at
`docs/spec/MASTER_PROMPT.backup.md`; its SHA256 is recorded in `docs/spec/MASTER_PROMPT.sha256`
and `docs/spec/SPEC_INTEGRITY.md`. At the start of every work cycle the hash is re-verified;
on mismatch the file is restored from the backup automatically and the incident is noted in
that cycle's `lastreport.md` (no cycle stop).

Reason:
The spec file was found empty twice during Phase 1-4; the user (2026-10-17/18) mandated
protection. Reference hash: 579f581e5bb8caae2aff6ef60326f1f461688f1b1392391a56a97a6148a61c35
(34,293 bytes).

Consequence:
Spec tampering/corruption can no longer silently affect the work.

---

## DEC-009 — Git for Windows installed via winget; repo-local identity

Date: 2026-10-18
Status: ACTIVE

Decision:
Following user approval, Git.Git 2.55.0.5 was installed system-wide with winget (official
package, verified installer hash). The repository was initialized with `git init` and a
repo-local identity (`AtomicHeart-AR <atomicheart-ar@localhost>`), no global config changes.
History follows conventional commits per MASTER_PROMPT section 45.

Reason:
Version control is mandatory (section 45) and the user explicitly approved the install.

Consequence:
All Phase 1-4 outputs were committed retroactively as logically grouped history.

---

## DEC-010 — Master DB seeded from en-US locres; non-locres strings catalogued only

Date: 2026-10-18
Status: ACTIVE

Decision:
`localization/master/atomic-heart-ar.tsv` is generated from all en-US locres (27,618 rows,
columns exactly per section 10, Status=UNTRANSLATED, Arabic empty). Non-locres
StringTable/DataTable text is NOT yet merged: Phase 5 only produces scripted string dumps
per asset (`localization/extracted/uasset_text/`) plus a catalog
(`reports/uasset_strings_catalog.txt`), because a stable keying scheme (StringTable key vs
DataTable row/property) must be decided during the Phase 7 prototype before those strings
enter the master DB.

Reason:
The master DB must only carry rows with verifiable identity (namespace/key or an
asset-anchored key to be defined). Inventing keys before the prototype would corrupt
round-trip fidelity.

Consequence:
Non-locres text is first-class within Phase 7 scope, with a keying decision to be recorded
(DEC pending) after an actual uasset rebuild is proven.

---

## DEC-011 — UnrealLocres adopted as the working locres exporter

Date: 2026-10-18
Status: ACTIVE (open question deferred to user)

Decision:
The locres -> CSV pipeline uses UnrealLocres 1.1.0 (`tools/bin/unreallocres`), which runs
on the built-in .NET Framework. LocResUtility CLI v2.1.1 could not run: it requires the
.NET 8 runtime (not installed). Installing .NET 8 is system-wide and requires user
approval, so it is deferred.

Reason:
UnrealLocres is functionally sufficient (export/import/merge on LocRes v3). Only if we
adopt LocResUtility for advanced features would .NET 8 be needed.

Consequence:
UnrealLocres has no license file (all-rights-reserved) - used locally only, never
redistributed (recorded in THIRD_PARTY_LICENSES.md). User to decide whether .NET 8 should
be installed to enable LocResUtility/GUI workflows (FModel also needs .NET 8 when its
GUI is used).

---

## DEC-012 — No online publishing, permanent

Date: 2026-10-18
Status: ACTIVE (permanent, per user decision)

Decision:
Downloading from GitHub is allowed (official project pages and official release assets
only, with SHA256 verification). Uploading to GitHub or any remote is FORBIDDEN,
permanently:
- never run `git push`; never add a git remote;
- never create a GitHub repository, issue, pull request, gist or release;
- never log in to GitHub, and never use any token or credentials;
- never upload any project file anywhere online.
If a future task seems to require publishing anything online: STOP and ask the user first.
Local Git stays active for version control.

Reason:
User directive (2026-10-18, standing rule 9). The project stays entirely local.

Consequence:
Verification duty: `git remote -v` must print nothing (verified 2026-10-18: zero remotes,
exit 0, output empty). Recorded in the cycle report.


---


---

## DEC-014 - Font strategy for UI Arabic (v1 rejected, v2 interim, composite fallback production)

Date: 2026-10-18
Status: ACTIVE

Decision:
v1 (Noto Naskh Arabic UI replacing all UI FontFace payloads) is REJECTED as a UI path:
confirmed evidence from the user's in-game test (cycle 003) - every Latin string in the
main menu rendered blank, only digits and '!' visible, matching Naskh's Latin-Basic
coverage of only 15 codepoints (render-output analysis; the game writes no log to
confirm the hang mechanism). The FPS collapse / hang is LIKELY the missing-glyph
fallback storm over Latin lookups (UNCONFIRMED: no engine log exists in this build).

v2 (interim, test-grade): all replaced UI FontFace payloads use IBM Plex Sans Arabic
(OFL 1.1; official release @ibm/plex-sans-arabic@1.1.0, sha256
f03915581aea37d82792c188b08064023a73494d679b8e19f85f5971db714013), whose verified
cmap coverage is Latin-Basic 95/95 + Arabic 42/42 core letters + presentation forms.
Latin stays readable, Arabic renderable, single self-contained family.

Production requirement (user decision): the original game fonts (BlenderPro/Gotham/
BrutalType) must NOT be replaced in the final mod. That demands composite-font
fallback editing (adding Arabic faces as fallback entries on the original Font
objects). This needs a headless Font-asset editor (candidate: UAssetAPI-based script
or UAssetGUI hand-edit); NOT attempted in cycle 003. Recorded as the Phase 8 work item.

Reason:
v1 proved by experiment that single-script Arabic-only payloads are unusable for UI.
The engine resolves missing glyphs through face fallbacks which, for these Font
objects, cannot be configured without asset edits.

Consequence:
- Prototype (cycle 003+): sidecar swap with dual-script Plex payloads (v2 pak;
  this still changes the Latin typeface LOOK during tests; acceptable only for
  prototyping).
- Production (Phase 8): implement composite fallback; verify Latin look unchanged.

---

## DEC-015 - Options language list: engine-side finding and strategy decision

Date: 2026-10-18
Status: ACTIVE (primary route locked; any pak install still needs user approval)

Evidence (cycle 004, docs/LANGUAGE_SELECTION.md):
The Options > Language list is NOT generated from LocMeta staging. It is a hardcoded
13-record list inside the cooked DataAsset
AtomicHeart/Content/Core/Data/Settings/DA_Audio.uasset (+.uexp), consumed by the native
AHGameSettingsSubsystem via +ConfigurableSettings in the cooked DefaultGame.ini.
Staging a culture in LocMeta (cycle 003/004 test-1 setup) therefore can never add a
menu entry - this explains Test-1 outcome B with certainty of mechanism.
Both DA_Audio and DefaultGame.ini are ordinary pak contents (pakchunk0) -> overridable
from ~mods with no EXE change (override mechanism itself already proven by the font pak).

Decision (per the user's rule, cycle 004 step 3):
PRIMARY (strategy a): the list is data-driven and pak-editable -> add Arabic as a real
14th record: override DA_Audio in the mod pak with an appended record
(display name "العربية" as UTF-16 FString, engine culture `ar`, audio culture = en-US
fallback), with length/count/ExportMap surgery and a self-validation parser.
The frontier culture `ar` keeps the existing locmeta+locres work valid as-is.
FALLBACK (strategy b, DEC-007 carrier, prepared but NOT chosen): only if the DA_Audio
override fails validation or the in-game test is blocked. Candidates prepared:
ko-KR (recommended: officially text-only in retail, VO falls back to en-US, not a
listed VO language), zh-TW, uk-UA. User approval REQUIRED before any slot is used;
the user's played language and voice must not be sacrificed anywhere.

Voice invariance (user rule 4c): confirmed with asset evidence. Retail VO exists ONLY
for en-US and ru-RU (DA_Audio_VoiceBanks); all other slots' audio mapping falls back to
en-US, so both routes keep the user's English voice intact as long as they do not
select ru-RU. No separate text/voice selector exists in the assets (single OptionSelect).

Constraints:
- No install until the user approves the specific candidate (their order, cycle 004 step 5).
- The DA_Audio patcher must round-trip validate (re-parse the output asset) before any
  packaging, and the font pak v2 is a separate approval.

Amendment (same cycle, evidence-based):
- The DA_Audio asset is cooked UNVERSIONED (tagless schema serialization). Safe editing
  needs schema-reconstruction tooling -> the direct record-append becomes a Phase 8
  work item (parser skeleton recorded in scripts/inspect_da_audio.ps1).
- User-approved (cycle 004 questions): build-only approval given; ko-KR chosen as the
  approved carrier slot. Therefore the interim build for the next in-game test is the
  DEC-007 carrier pak using the ko-KR slot (Arabic text imported over the ko-KR
  NewP5 locres): build/package/zzz_atomicheart-ar_carrier_koKR_p1_P.pak
  (sha256 146f9c5f50744eed0b3ed614cf9e84f177efb35049c46d59c8948ea4857596ab),
  NOT INSTALLED. The user's own voice stays English by design; the replaced TEXT is
  Korean (a language the user is not reading).
---

## DEC-016 - Carrier fill policy: English for untranslated ko-KR keys

Date: 2026-10-18
Status: ACTIVE (built p2 carrier; install needs user go)

In cycle 005 the user reported Test-2 outcome D (partial): 258 FPS normal, no hang,
font problem resolved; most labels blank - Korean locres text rendered through the
replacement font faces, which lack Hangul. The visible Russian labels prove the game
renders some strings through faces this project does NOT replace (BlenderPro family
Cyrillic 94, Gotham 170, BrutalType 94, Roboto 255, DroidSansFallback; evidence:
reports/font_glyph_coverage.txt). Plex Sans Arabic itself covers Latin 95/95 and
Arabic 42/42 but ZERO Cyrillic and ZERO Hangul (reports/font_block_probe.txt).

Decision (user order, cycle 005 step 3):
- The ko-KR carrier now fills EVERY untranslated key with the en-US English text of
  the SAME namespace/key; the 25 seed keys keep their Arabic; keys with neither
  (none in NewP5) would stay Korean. Result: of 5,597 ko-KR keys - 25 Arabic,
  5,572 English-filled, 0 skipped.
- Validation: 5,541 values byte-exact; 56 multiline values differ ONLY by \r\n vs
  \n (UnrealLocres v1.1.0 import normalizes embedded LF to CRLF). Newline-equivalent
  comparison accepted with the delta counted and recorded; real mismatches hard-fail.
  The engine demonstrably tolerates \r\n: the game's own ko locres ships one.
- Glyph gate upgraded (cycle 005 step 5): scripts/build_fontpak_p2_plex.ps1 now
  parses explicit block counts from scripts/probe_font_blocks.ps1 output
  (reports/font_block_probe.txt) - Latin-Basic >= 95 and Arabic-core >= 42 required,
  and Cyrillic == 0 or Hangul == 0 fails the build unless -AllowMissingCyrillicHangul
  is passed after human review (v2 currently built under that flag because the
  Russian labels are proven to use faces outside this pak).
- Nothing installed without the user's explicit go (Test 3 = carrier p2 + font v2).
---

## DEC

### DEC-018 (new): Count-pass generations and dump-folder validity

Three earlier count-pass generations (v1a --output failure, v1-broken-cmd quoting, v2 pre-fix)
left a mixed dump folder: localization/extracted/dialogue/ contained 393 stale dumps from
superseded runs while reports/dialogue_st_counts.tsv had 235-792 rows depending on the
generation (per-run ring-rewrite would truncate or append TSV rows; dump folder accumulates).
Cause: each run writes dumps without cleaning, while rewriting the TSV; runs were killed
mid-flight. Resolution: all stale dumps + part TSVs PURGED (validity of old-generation dumps
unproven: at least one earlier generation ran with a decoder that had a 2-byte alignment bug).
The 4-worker parallel pass (scripts/dialogue_count_worker.ps1, chunked, resumable by
dump-file existence) reruns 2026-10-18 from a clean slate; only dumps from the verified
decoder are trusted (decoder verified byte-exact against ST_GameTips_Texts.uexp: char
0x0427 0x0442 ... = "Чтобы", no mojibake).

### DEC-017 - Prototype menu milestone + dialogue/cutscene batch program

Date: 2026-10-18
Status: ACTIVE

**Part 1 - Test 3 main menu (CONFIRMED by user screenshot):** outcome A. Arabic renders
correctly (connected letters, correct RTL order, Latin readable). Prototype text+wiring
is proven for locres-scope strings rendered through face-mapped UI. Test 3 fully closes
only after the user checks settings pages and GameTips popups (this file/STATUS/io will
be updated then).

**Part 2 - Dialogue and cutscene text program (user order, 4 cumulative batches).**
Rules (all evidence-based, no guessing):
1. Scope (locres): the game has EXACTLY 35 en-US locres scopes (all in pakchunk0; full
   list in reports/dialogue_inventory.md). Dialogue/cutscene-scope by FILE NAME +
   evidence-backed master categories:
   - *_Dialogues + DIALOGUES FOR LQA (Category 'Dialogue Dialogue' in master):
     10 scopes = 7,956 strings.
   - Locations_dlc2 (Category 'Dialogue' in master): 816 strings.
   - CUTSCENES (Category 'Subtitles Subtitles'): 840; Cutscenes_dlc1 (Category
     'Subtitles'): 421; Schebetar_Subs (scope name *_Subs): 361.
   - locres dialogue-scope subtotal: 10,394 strings (NOTE: Schebetar_Subs category is
     'Unknown' in master and will be classed as Subtitles at extraction).
2. Scope (non-locres): dialogue-bearing cooked assets under
   Maps/Development/Dialogue_Test/ (Narrative_LS, Localisation_LS, OpenWorldCorpses,
   Schebetars_Subs/DT_Subtitles_Schebetars), the DLC Narrative folders, and other
   StringTable/dialogue assets that the string scan proves carry dialogue text.
   Per-culture duplicate trees (Localisation_LS/<language>/) collapse to ONE logical
   source per base name; English text is used when an En/US variant exists, otherwise
   the asset is RU-only and goes to reports/dialogue_ru_only.md (never into the English
   column). RU text of non-RU-only tables is NOT extracted (translation sources only).
3. The 100% TOTAL = every dialogue/cutscene STRING with an English source (locres rows
   already in the master TSV + English-string counts of in-scope cooked assets).
   RU-only strings are tracked and reported separately and do NOT count into TOTAL.
4. Batch split: cumulative 25/50/75/100% of TOTAL. Order rule (documented since game
   progression order is NOT determinable from asset names alone): base-game sources
   alphabetically, then DLC1, DLC2, DLC3, DLC4, then non-locres cooked assets in
   container order. Each batch covers everything before it (cumulative).
5. Master rows: Namespace/Key kept exactly as extracted; Category = Dialogue,
   Subtitles or Cutscene; Speaker/Context only with evidence, else empty; placeholders
   and rich-text tags preserved exactly; no duplicates; existing rows are never
   content-overwritten (a same-key existing row counts as 'already present').
   LQA/UI rows already in the master keep their categories (anchor rows re-labelled
   by this program only for master rows in the dialogue scope).
6. Validator must PASS per batch (duplicates, empty sources, placeholders/UTF-8).
   Every percentage is quoted against TOTAL as 'N of TOTAL (X%)'.

## DEC-019: String selection rule for cooked assets (prose filter) - 2026-10-18

Context: the first count pass extracted every printable UTF-16 run from each `.uexp`.
That over-extracted massively (5,005,978 "strings" - asset names, property names,
binary fragments, duplicates), which is not dialogue text. An inventory TOTAL built on
raw runs would be meaningless, and the batch rows would be noise.

Decision: a dumped string counts as DIALOGUE/CUTSCENE TEXT only if it passes the prose
filter, implemented once in `scripts/dialogue_strings_lib.ps1` (`Get-DialogueStrings`)
and used IDENTICALLY by the inventory finalizer and the batch tool, so coverage
arithmetic is consistent:
  - taken from the UTF-16 section only (the ASCII section is cooked names/keys);
  - trimmed length 8..1000;
  - contains at least one space;
  - at least 2 alphabetic words (runs of 3+ letters: Latin / Cyrillic / Arabic / Hebrew);
  - does not look like a path/name/engine token (no '/', '\', ':', '::', '.uasset',
    '.uexp', '.locres', '.png', '.wav', '.ogg', '.umap', no leading DC_/BP_/ST_/LS_/SK_/
    M_/T_/SM_, no Property/Function/Blueprint/Struct/Enum/Class/Asset/Package/Level/
    Component/Actor);
  - duplicates within one asset collapse to one string (raw scans repeat).
Rich-text tags (`<tag .../>`, `<h>...</>`) are preserved EXACTLY inside the string.

Consequence (evidence, reports/dialogue_inventory.md): the cooked non-locres dialogue
assets are almost entirely RUSSIAN-only (KI-010 class). Out of 4,033 in-scope assets,
only 4 carry English prose (111 strings); 246 are RU-only (5,903 prose strings). So the
English-source dialogue universe is effectively the en-US locres.

## DEC-020: Dialogue 100% TOTAL, RU-only split and batch coverage arithmetic - 2026-10-18

Definition of the exact 100% total (written to `reports/dialogue_inventory.md`):

  TOTAL = 10,505 dialogue/cutscene strings that HAVE an English source
        = 10,394 en-US locres strings (14 scopes, already present in the master TSV)
        +    111 cooked-asset English-prose strings (4 assets, DEC-019 filter).

  RU-only strings (246 assets, 5,903 prose strings) are listed in
  `reports/dialogue_ru_only.md` (same class as KI-010), are NEVER written into the
  English source column and do NOT count into TOTAL.

Batch split: cumulative 25/50/75/100% of TOTAL, cutoffs 2,626 / 5,253 / 7,879 / 10,505.
Order = DEC-017 (locres base alphabetical, then DLC, then cooked assets by DLC; kind; path).
Because the cooked English-prose assets are the last 4 sources in that order, batches
1-3 are locre coverage and batch 4 adds the 4 cooked assets.

Boundary rule (explicit): Category retagging is applied per SOURCE, so a source that
straddles a batch boundary is fully retagged by the batch that first touches it, while
its CONTRIBUTION TO COVERAGE is capped at the exact string cutoff. Content columns
(source English, Arabic, keys, namespace) are never touched by a retag. Evidence: batch 1
covered 2,626 strings but retagged 3,286 rows (the straddling DIALOGUES FOR LQA source).

Duplicate rule: the master TSV already contained 728 duplicate IDs before this program
(recorded as KI-016). The validator therefore compares duplicates against that baseline
and FAILS only if this program introduces NEW duplicates.

Reporting rule: every percentage is quoted as 'N of TOTAL (X%)', per category and per DLC.

## DEC-021: Cooked-asset language classification corrected; TOTAL = 10,394 - 2026-10-18

Context: DEC-020 set TOTAL = 10,505 = 10,394 locre + 111 'English-prose' cooked strings
(4 assets). Applied as batch 4, those 111 rows turned out NOT to be English: they are
Russian subtitle tracks with timecode markers (DT_Subtitles_Schebetars 41,
DT_Subtitles_DLC02_Schebetars 49, D_DLC04_10 20 - Cyrillic text that merely CONTAINS a
Latin phrase, e.g. "non penis canis est!") plus one encoded payload (NotLifted_17).

Root cause: the DEC-019 EN test was 'contains any 3+ Latin letters', which passes as soon
as a Russian line embeds a Latin word.

Fix (implemented in scripts/dialogue_finalize.ps1, `Get-AssetClass`):
  - ru-only    : Cyrillic letters >= 10 AND Cyrillic >= Latin (checked FIRST)
  - english    : Latin >= 10, Cyrillic == 0, vowel ratio (AEIOUaeiou / Latin) >= 0.15
  - obfuscated : Latin >= 10, Cyrillic == 0, vowel ratio < 0.15 (encoded/binary noise)
  - mixed      : Latin and Cyrillic both substantial, Latin dominant (not clean English)
  - skip       : no usable text
Corrected result: EN-source cooked assets 0; RU-only 248 assets / 6,012 strings;
obfuscated 1 asset (diag evidence: "LKKELLMKLM\"!..."); mixed 0; skipped 3,082.

Therefore the exact 100% TOTAL is 10,394 (the 14 en-US locre scopes only). The 111
misclassified rows were removed from the master (rows 27,729 -> 27,618) by deleting
exactly the rows with Status NEW + Notes 'cooked asset scan' (all other changes kept).

Effect on the batch plan: cutoffs recomputed as 2,599 / 5,197 / 7,796 / 10,394. Batches
1-3 had already been cut against the old 10,505 and delivered 2,626 / 5,253 / 7,879
strings - each at or above the corrected mark - so no re-delivery was needed; batch 4
completed coverage at 10,394 of 10,394 (100%).

Consequence for the program: there is no cooked English dialogue text to add. Every
non-locres dialogue asset is either Russian-only (reports/dialogue_ru_only.md, KI-010
class) or obfuscated (reports/dialogue_obfuscated.md, BLOCKED, KI-017).

## DEC-022 - Test 3 results; subtitle font resolution; translation program approved

Date: 2026-10-18. Status: ACTIVE.

Part 1 - Test 3 user results (carrier p2 + font v2, ko-KR selected):
- Settings page: outcome A. "Window mode" renders correct Arabic "ملء الشاشة",
  letters connected, RTL correct, Latin text readable. No blank labels on the page.
- Dialogue/subtitles: outcome A for rendering. Subtitles are visible and readable
  but in KOREAN (dialogue is not translated yet - expected). Quest title and objective
  show the English fill; no blanks anywhere.
- Game Tips popup: NOT TESTED (user could not reach one in this pass). Stays open.

Part 2 - Subtitle font question (user observation vs evidence):
- User observation: the subtitle text rendered Hangul, so the subtitle font cannot be
  one of the 6 faces replaced by the v2 font pak; Arabic support there = UNKNOWN.
- Evidence gathered this cycle (asset-level, not guessed):
  * AtomicHeart/Content/Core/UI/Dialogue/WBP_TypingTextBox.uasset (parent widget of
    WBP_OneSubtitle and WBP_NPCSubtitle) carries FontObject =
    /Game/Development/UI/Fonts/BlenderPro-Medium_Font.
  * WBP_OneSubtitle.uasset additionally references BlenderPro-Book_Font.
  * AtomicHeart/Content/Core/UI/Fonts/DT_Game_Text_Style.uasset (global text-style table)
    also points its Font at BlenderPro-Medium_Font.
  * BlenderPro-Medium.ufont IS in the v2 replace map (-> IBMPlexSansArabic-Medium,
    Latin 95/95 + Arabic 42/42, per reports/font_block_probe.txt).
- Therefore: the SUBTITLE FACE itself is a replaced face and already carries Arabic. The
  Hangul the user saw is the engine GLYPH FALLBACK, not the subtitle face: Plex has no
  Hangul, so Slate fell back to engine fallbacks (DroidSansFallback and NotoSansKR-*,
  both Hangul-Syllables = 11172; evidence reports/font_glyph_coverage.txt lines 113-135
  and 167-171).
- Consequence: no font-pak extension is required for the pilot; Arabic subtitles are
  EXPECTED to render through the existing v2 pak. Recorded as LIKELY; must be PROVEN by
  the pilot in-game check. The user UNKNOWN verdict is kept in KI-009 as the pre-pilot
  state.
- Phase 8 note: the production route stays the composite-font fallback on the ORIGINAL
  Font objects, which removes the Cyrillic/Hangul trade-off entirely.

Part 3 - New program approved: Arabic translation in 4 cumulative batches (25/50/75/100),
starting with Phase 0 (TOTAL, plan/cutoffs, glossary, style guide) and a single PILOT gate
(60 rows + font/carrier verification + in-game checklist). Rules recorded in DEC-023.


## DEC-023 - Arabic translation program (4 cumulative batches) + Phase 0 outputs

Date: 2026-10-18. Status: ACTIVE.

Part 1 - TOTAL definition (user rule): all master rows with a NON-EMPTY English source,
excluding Status TECHNICAL and BLOCKED.
- TOTAL = 27,618 rows. U = 19,996 unique English strings (translation memory size).
- TECHNICAL = 0 rows, BLOCKED = 0 rows today.
- 7,622 rows repeat an English string already counted (reuse, not new work).
- Master header row was malformed (literal backtick-t, not tabs) - fixed to real tabs
  this cycle (data rows were always tab-separated; no data change).

Part 2 - Work order and cutoffs (reports/translation_plan.md, generated by
scripts/translation_plan.ps1 - deterministic, re-runnable):
- Tier 1 = system UI, menus, HUD, tutorials, items, weapons, skills, objectives:
  NewP5 (5,597), Misc (21), PearTerminals (545) = 6,163 rows.
- Tier 2 = base-game dialogue, subtitles, cutscenes = 9,157 rows.
- Tier 3 = base lore (NTD, Mails_01) then DLC1..DLC4 then credits = 12,298 rows.
- Cumulative cutoffs: batch 1 = 6,905 rows (25%), batch 2 = 13,809 (50%),
  batch 3 = 20,714 (75%), batch 4 = 27,618 (100%).
- Cumulative unique strings at the cutoffs: 4,562 / 8,648 / 14,037 / 19,996.

Part 3 - Glossary (built BEFORE translating, as ordered):
- scripts/glossary_extract.ps1 scans the English column and proposes repeated
  capitals/acronyms -> reports/glossary_candidates.tsv (4,820 candidates, evidence).
- glossary/glossary.tsv = 136 curated entries (term, arabic, category, reason, status,
  notes), all marked DRAFT, reason in {transliterated, translated, preserved}.
- Verified: 136/136 terms occur in the master English corpus (case-insensitive check).
- glossary/glossary_questions.md = 26 decisions for the user (model codes, robot
  nicknames, science/Soviet terms, tone, formatting). Defaults = recommended options.
- glossary/terminology.md = style guide (MSA, tone/register map, Western digits,
  Arabic question mark/comma, byte-exact tags/placeholders/markers, length rules,
  translation-memory rule, Status workflow, validation gates).

Part 4 - Batching rules: 4 CUMULATIVE batches (25/50/75/100). Each batch: translate,
set Status DRAFT, fill Arabic, update the translation memory, run the validator,
regenerate localization/references/AR_EN_REFERENCE.md, rebuild the carrier pak
variant, report "N of TOTAL (X%)", add a 40-row AR/EN review sample to HANDOFF.md,
then STOP. Never install without explicit user approval; install/uninstall only with
the existing scripts.

Part 5 - Pilot gate (single stop before batch 1): ~60 translated rows (20 UI, 20 short
dialogue, 20 long subtitle incl. tags and numbers) + the 25 phase-7 seed rows carried
over, a new carrier pak variant covering ALL 35 ko-KR locres scopes, subtitle-font
evidence, a non-developer in-game checklist, and HANDOFF.md rewritten. Then STOP.

Part 6 - Subtitle font (from DEC-022): the subtitle/dialogue typing widget resolves to
BlenderPro-Medium_Font, which the v2 font pak already replaces with IBM Plex Sans
Arabic (Latin 95/95 + Arabic 42/42). No font-pak extension is required for the pilot;
Arabic subtitle rendering is LIKELY and will be PROVEN in-game at the pilot gate.
## DEC-024 - Pilot build (cycle 007): program scope, carrier p3, and three defects found

Date: 2026-10-18. Status: ACTIVE.

Part 1 - Translation unit and pilot shape (records what was built, per DEC-023):
- Phase 0 produced TOTAL = 27,618 rows / 19,996 unique English strings; TECHNICAL 0, BLOCKED 0.
- Glossary built BEFORE translating: 136 entries (all DRAFT), every entry verified to occur
  in the English corpus; 26 judgement calls listed for the user in glossary_questions.md.
- Style guide: glossary/terminology.md.
- Pilot = 60 rows (20 UI, 20 short dialogue, 20 long subtitle with markers/numbers/tags)
  covering 57 unique strings, PLUS the 25 phase-7 seed rows carried forward = 85 rows
  with Arabic. All new rows Status DRAFT. Validator: 0 errors.
- Master TSV header had been a literal backtick-t string instead of real tabs; rewritten
  with real 13-column tabs. Data rows untouched.

Part 2 - Carrier builder (DEC-007 extension): scripts/build_carrier_locres_pak.ps1 now covers
ALL 35 ko-KR locres scopes that carry user-visible text (was NewP5 only), including the
dialogue/subtitle/cutscene scopes and all DLC scopes. Fill order per key: Arabic (master
non-empty) > English (en-US text for the same key) > keep Korean. Result for p3:
35 scopes, 27,618 keys (exactly the master row count), 85 Arabic, 27,533 English-filled,
0 kept Korean, 0 round-trip failures, 35/35 pak entries byte-identical after unpack.

Part 3 - Subtitle font (closes the DEC-022 LIKELY): the glyph gate proves that every one
of the 113 distinct codepoints used by the translated pilot rows is present in the subtitle
face that the v2 font pak installs (BlenderPro-Medium -> IBM Plex Sans Arabic Medium), and
in the union of all six replaced faces. Latin-Basic is complete. Cyrillic/Hangul are absent
from the Plex payloads by design and are served by the engine fallback face (unchanged;
Test 3 proved Korean renders). No font-pak extension is required for the pilot; the pilot
in-game check is the final proof.

Part 4 - Defects found by the new tooling (all recorded in KNOWN_ISSUES.md):
- KI-019: carrier p2 shipped malformed rich-text tags in the 7 seeded game tips (CSV-escaped
  quotes never unescaped: id=""Button...""). Found by the validator's tag check, confirmed
  by unpacking the installed p2 pak. Fixed in the master and in p3; in-game proof is part of
  the pilot check (Area E). The affected rows were exactly the GameTips rows Test 3 never
  reached.
- KI-020: Python is not installed (Store alias only), so the requested
  scripts/validate_translation.py is a delivered-but-unexecuted artefact; the identical
  checks run via scripts/validate_translation.ps1. Needs user approval to install Python.
- KI-021: PowerShell 5.1 reads .ps1 as ANSI without a BOM, mangling Arabic literals inside
  scripts. Rule adopted: Arabic only in UTF-8 data files; scripts stay ASCII. The validator
  now hard-fails mojibake and U+FFFD, so this class of error cannot reach a pak again.

Part 5 - Install policy unchanged: p3 is built and validated but NOT installed. Installation
happens only on explicit user approval and only through the existing install/uninstall
scripts. The pilot gate stops here until the user reports the in-game result.
## DEC-025 - Pilot install (p3), reviewer fixes, Python declined, speaker-marker rule

Date: 2026-10-18. Status: ACTIVE.

Part 1 - Install APPROVED and executed (user order 2026-10-18). scripts/install_mod.ps1 was
rewritten from a fixed two-file installer into a RECONCILING installer: it removes only files it
previously installed (verified against the old manifest hash) and installs the requested set.
Result in Paks\~mods:
   - removed (hash-verified against the old manifest): carrier p2, sha256 3d4b0ea65c5dc789be98b46aa18c7c27959445b7d36454616b91be2ae55fa9e1
   - installed: carrier p3, sha256 b58029662e5acf775087426ed85721905a5846127d6af5c209a482514f7b41df
   - kept: font v2 (Plex), sha256 02b17f31e61a46ddba20bea8c4da5be44164173df608d52697f68d27d8269747
   - manifest rewritten: sha256 346abd7f291f36d7aa033785c4e16d8dc9272e24d5d59443477130bc215298bd
Verification (scripts/snapshot_game_folder.ps1 before/after + scripts/verify_install.ps1):
PASS - no file added/removed/changed anywhere in the game folder outside ~mods; AtomicHeart.exe
unchanged; 19/19 stock paks unchanged; ~mods contains exactly the three files above.
Evidence: reports/install_verification.md, reports/install_verify/before_p3.json.

Part 2 - Python DECLINED by the user. scripts/validate_translation.ps1 is the primary validator;
scripts/validate_translation.py remains a delivered artefact for a machine that has Python.
KI-020 closed.

Part 3 - Glossary decisions: the user ACCEPTED all 26 recommended defaults
(glossary/glossary_questions.md). Sensitive terms (robot nicknames, science/Soviet terms, tone)
will be reviewed after batch 1, and any change goes through the reviewer-fix workflow.

Part 4 - Reviewer fixes applied (three, from the pilot review) WITHOUT rebuilding the pak (they
ship in p4 with the pilot results):
   (a) grammar: "to puff your chest" phrase - "tanfukh" not "tantafikh" (Theatre_Dialogues and
       its identical DIALOGUES FOR LQA sibling, same key /962A2FA3462F1CE524EB09B650D0C297)
   (b) stealth-kill game tip: wording replaced; the <tag id="InputAction.Gameplay.StealthKill"/>
       is byte-unchanged
   (c) surgeon scene: "Swab" rendered as the cotton-swab word
Applied by scripts/apply_text_fixups.ps1 (rules in localization/working/tm_fixups.tsv, a UTF-8
data file per KI-021) to the master Arabic column, localization/working/tm.tsv and the seed CSV;
proved by scripts/verify_text_fixups.ps1 (old text gone, master/memory match 85/85) and by the
validator (0 errors). Log: reports/text_fixups_log.md.

Part 5 - Speaker markers. Evidence: 130 master rows carry an inline &Speaker& marker, ALL of them
inside three DLC2 "Schebetars" scopes (Schebetar_Subs 90, Schebetars_dlc1 39, Locations_dlc2 1);
the base game has none; 145 distinct tokens. Standing rule: byte-exact copy (validator-enforced).
Conditional rule (terminology.md section 10) activates ONLY if the user's in-game check shows the
names are displayed: characters transliterated, roles translated, non-verbal cues translated,
unit names from the glossary - delimiters always stay Latin '&'. Check sheet:
reports/speaker_marker_check.md. Answer pending (expected with the pilot report).

## DEC-026 - Pilot result recorded, opening-scene Arabic proof (p4), subtitle-display rule

Date: 2026-10-18. Status: ACTIVE.

Part 1 - Pilot result (user, 2026-10-18). On the bridge, quest "NO REST FOR THE WICKED",
objective "Cross the bridge", the subtitle showed the carrier's ENGLISH text where Korean had
been before. CONFIRMED: the carrier ko-KR locres is read at runtime for dialogue/subtitle scopes,
not only for menu/settings text (KI-009 updated). The screenshot shows no `*x.xx*` marker on
screen, so the engine interprets the markers rather than printing them.

Part 2 - Opening scene chosen for the Arabic proof. Scope `Chelomey_Dialogues`, asset
`AtomicHeart/Content/Localization/Chelomey_Dialogues/en-US/Chelomey_Dialogues.locres`, master
lines 284-324 (consecutive): 12 loudspeaker/PA speech rows of the street+bridge (including the
exact row seen on screen, `/DC11CB9A4BFFB0AA5E099DAA4057EEE9`) and 29 crowd speaker-label rows of
the same asset (benches / cafe / citizens). 41 rows; 40 are new in this cycle, 1 already carried
pilot Arabic. Row list: localization/working/scene_opening_rows.tsv.

Part 3 - Translation conventions for this scene: `THOUGHT` stays Latin (as in every earlier row);
`Homo Futurum` is rendered as the Arabic phrase for "future human"; `mimetic adaptation` gets a
literal Arabic term (proposed glossary addition); `Chelomey Complex` follows the glossary pattern
for complexes; crowd labels are translated once and reused, so identical English always shows
identical Arabic. Markers, tags and placeholders stay byte-exact (validator-enforced).
Arabic lives only in UTF-8 data files (KI-021); `scripts/scene_apply.ps1` is ASCII-only and
verifies the English of every row before writing.

Part 4 - Build and install. Carrier p4 = p3 + the three cycle-008 reviewer fixes + the 40 scene
rows. Built by the unchanged carrier builder: 35/35 scopes, 27,618 keys, 125 Arabic, 27,493
English-filled, 0 kept Korean, 0 round-trip failures, 35/35 unpack byte-identical,
sha256 aa894b4468888ac22a3fd3e58619d4cdb70ae24a895c35f286b002b2f4132f22. Installed with the
reconciling installer (user APPROVED): carrier p3 removed hash-verified, font v2 untouched,
manifest rewritten; before/after snapshot PASS (nothing else in the game folder changed).

Part 5 - Subtitle display rule (KI-022). A subtitle row is played in marker-defined parts, and
the parts are what must fit the panel. Standing rules for translation: (a) never change the
marker multiset; (b) keep each segment at or below the English segment's character count where
possible (every Arabic segment in this scene is shorter than its English counterpart). Evidence
and the one remaining NOT TESTED point (clip vs scroll) are in reports/subtitle_display_finding.md;
the check is item 4 of reports/scene_bridge_ingame_check.md.

## DEC-027 - Batch 1 complete (15 chunks): authoring contract, copy-class policy, glyph exemption, whitespace normalisation, carrier p5 built and NOT installed

Date: 2026-10-18. Status: ACTIVE.

Part 1 - Batch 1 result. Scope set = NewP5 (5,597) + Misc (21) + PearTerminals (545) +
Academy_Dialogues (282) + the first 460 rows of Chelomey_Dialogues = 6,905 rows (the 25% row
cutoff of reports/translation_plan.md, confirmed). Of those, 6,527 rows carry Arabic and 378 rows
are copy-class and intentionally left byte-identical to the English. Distinct English authored in
this batch: 4,426. Master totals after the batch: 6,564 of 27,618 rows (23.77%) and 4,426 of
19,996 unique strings (22.13%), every one Status=DRAFT. The batch was authored in 15 chunks of 300
unique strings (last 294) following the plan's work order.

Part 2 - Authoring contract (reusable for batches 2-4). `scripts/batch_plan.ps1` writes
`localization/working/batch1/rows.tsv` (batch row set), `unique.tsv` and `chunk_NN_en.tsv` with
STABLE ids `u0001..`; Arabic is authored per chunk into `chunk_NN_ar.tsv` as `id<TAB>arabic`, so an
English string is never retyped and can never be mis-matched. The style contract is
`localization/working/batch1/BRIEF.md` (glossary-first, byte-exact tags/placeholders/markers,
MSA register, no sanitising, UI length discipline). `scripts/batch_check.ps1` gates every chunk
before the master (id set and order, empty cells, U+FFFD, ordered tag/placeholder/speaker/timing
token equality, `%` and `||` counts, length warnings) and `scripts/batch_apply.ps1` then fills only
rows inside the batch row set that do not already carry Arabic, sets Status=DRAFT, note `batch1`,
and appends to the union TM. `validate_translation.ps1` runs after each chunk; no error was carried
forward.

Part 3 - Copy-class policy. The validator hard-fails Arabic == English and Arabic with no Arabic
letter, so rows whose correct Arabic is byte-identical to the English (bare numbers, resolutions,
symbols, lone tags, key names, model/tech codes, language endonyms, gibberish, pure-format strings)
are NOT translated and NOT marked DRAFT: they stay UNTRANSLATED with an empty Arabic cell, and the
carrier fills them from the en-US locres - which is exactly the English the row shows today.
Evidence: `localization/working/batch1/copy_keep.tsv` (170 distinct strings / 378 rows). The
checker and the applier use the validator's Arabic-letter class so a value whose only "Arabic"
character is punctuation can never be applied (it happened once, 17 rows, and was repaired).

Part 4 - Glyph-gate exemption. `scripts/glyph_gate.ps1` gained `-AllowSourceInheritedNonLatin`.
It splits missing codepoints into those the ENGLISH SOURCE of the same row already needs (Cyrillic
in designations, invisible format characters in an obfuscated string) and those the Arabic
introduced. The gate passes only when the Arabic introduced none; the five inherited codepoints are
listed in the report with their provenance. Rationale: the engine already renders them through its
fallback face for the original text, so the Arabic does not add a glyph requirement.

Part 5 - Whitespace normalisation. Trailing whitespace in a locres value is stripped by the
UnrealLocres round-trip, so it cannot survive the carrier build. `scripts/trim_trailing_ws.ps1`
trims the master Arabic column (15 rows in batch 1) and the TM. Every future batch must do the same
before the build (KI-024).

Part 6 - Carrier p5. Built with the unchanged builder: 3,775,007 bytes, sha256
087f6b640a0f649d605148316a80cb3f51baf94994b4c317c5bd0e910f025a9f, 35/35 scopes, 27,618 keys,
6,564 Arabic + 21,054 English-filled + 0 kept Korean, 0 round-trip failures, 35/35 unpack
byte-identical. NOT installed: p4 + font v2 stay installed until the user approves. Install:
`install_mod.ps1 -Carrier p5 -Font p2_plex` (reconciling; removes p4 only after its hash matches
the manifest; font v2 untouched). Rollback: `install_mod.ps1 -Carrier p4 -Font p2_plex`.

Part 7 - Batch-2 preparation. `scripts/batch_plan.ps1` still uses a case-insensitive `@{}` index
for its occurrence counter, which produced the `Off`/`OFF` mis-attribution (KI-023). It never
changes the stable ids, but it must be switched to a `Dictionary[string,int]` before batch 2 is
planned, and the batch-2 planner must run with a fresh state file rather than reusing batch-1 ids.

## DEC-028 - Speaker-name labels are locres rows and ARE player-visible (2026-10-19, cycle 011)

Finding. The bracketed speaker names in subtitles are NOT `&Speaker&` markers and NOT a separate name
table: each dialogue asset references the speaker's display name as an FText of its own, i.e. an ordinary
locres row in the same scope whose English text is exactly the speaker name. Evidence: the cooked dump of
`D_0072_Sipuha_BringSoda` lists the key `6EE193DF4F471FAB99A8779B0531AEFA` together with the ASCII string
`Computer`, and the master row for that key has English `Computer`; the five dialogue lines of that scene
contain no speaker markup. The `[ ]` brackets are drawn by the subtitle widget (`WBP_TypingTextBox` ->
`WBP_OneSubtitle` / `WBP_NPCSubtitle`). In game the labels are DISPLAYED to the player (user screenshot of
the Chelomey canal boat scene, 2026-10-19). This answers the open speaker-marker question for this scene:
shown. `&Speaker&` stays a DLC2-only mechanism (DEC-025, unchanged).

Policy adopted. Speaker-name rows are player-visible text and are translated through the glossary, with ONE
Arabic per speaker name used in every scope (never a per-scene variant). `Computer` -> `الحاسوب` (added to
`glossary/glossary.tsv`), `Char-les`/`CHARLES` -> `تشارلز` (already present). Names whose correct display
IS the Latin form are copy-class: `P-3` stays `P-3` (Arabic == English would hard-fail the validator), so
those 1,140 rows stay UNTRANSLATED with an empty Arabic cell and the carrier fills them from the en-US
locres. Applied this cycle: 818 label rows filled (125 `Computer` + 693 `Char-les`), 65 already identical,
0 conflicts. `scripts/apply_scene_labels.ps1` hard-fails when an existing non-empty Arabic differs from the
sanctioned form, so a future run can never fork one speaker name into two spellings.

Scene decision. The boat scene is translated as the whole row set of its owning asset: the 5 text rows of
`D_0072_Sipuha_BringSoda` (Status DRAFT, note `scene:chelomey-soda`) plus the two labels the asset uses.
Arabic authored in UTF-8 data files only (`localization/working/scene_chelomey_soda_rows.tsv`,
`localization/working/speaker_labels.tsv`); no Arabic literal in any script (KI-021).

Build decision. Carrier p6 = p5 + this scene: 3,775,256 bytes, sha256
b7dbb14e80a926c06d0255919a454747488778de98a1778645d117ef1dc4c321, 35/35 scopes, 7,387 Arabic + 20,231
English-filled + 0 kept Korean, 0 round-trip failures, 35/35 unpack byte-identical. INSTALLED with explicit
user approval through the reconciling installer (`p4` removed only after its hash matched the manifest,
font v2 untouched); before/after snapshot PASS with 0 changes outside `~mods`. Rollback:
`install_mod.ps1 -Carrier p4 -Font p2_plex` (the previously installed build) or `-Carrier p5` (the batch-1
build).

## DEC-029 (cycle 012, 2026-10-19): batch-2 order follows GAME PROGRESSION, not the tier grid

Ruling. Batch 2 translates DIALOGUE in story order; UI strings are pushed to the end of the batch.
The order is written down in `scripts/batch2_plan.ps1` and materialised in
`localization/working/batch2/plan.tsv` / `plan_unique.tsv`.

Order rule (rank 0 first):
   1. `CUTSCENES` and `Chelomey_Dialogues` - the prologue (boat narration, arrival, first quests),
   2. the remaining base-game dialogue/subtitle scopes in story order: `VDNKh_Dialogues`,
      `Vavilov_Dialogues`, `Pavlov_Dialogues`, `Polygon_Dialogues`, `Theatre_Dialogues`,
      `OpenWorldVDNKh_Dialogues`, `ChelomeyFinal_Dialogues`, `Academy_Dialogues`, `Schebetar_Subs`,
   3. side content of those areas: `Mails_01`, `NTD`, then the `DIALOGUES FOR LQA` mirror (last among
      base-game scopes so that it reuses the finished TM),
   4. DLC1 -> DLC2 -> DLC3 -> DLC4 dialogue scopes, in release order,
   5. UI scopes LAST: `PearTerminals`, `NewP5`, `Misc`.

Within a scope the order is DATA-DRIVEN, not guessed: the game's own subtitle DataTable dumps
(`localization/extracted/dialogue/pakchunk0-WindowsNoEditor__DT_Subtitles_*.txt` and the pakchunk13/14/15/16
equivalents) list the FText keys in the table's own row order, which is the order the game plays them. The
planner assigns each key the index of its first appearance in its dump, so the work order equals playback
order. DLC scopes whose dumps use readable keys (not hex) get no playback index and fall back to master
line/key order - a documented limitation, not an approximation of story order.

Why `Chelomey_Dialogues` before `CUTSCENES` in practice: the prologue's opening narration and the first
playable dialogue live in `Chelomey_Dialogues` (verified: the user's screenshot line
`/A1D6A1694DDB4C4918A9BDA652A16300` is playback index 3 of that scope). Both scopes are rank 0/1 and are
translated together as the opening.

Chunking rule unchanged (DEC-027): ~300 unique strings per chunk in plan order, per-chunk gate
(`scripts/batch2_chunk.ps1`), apply to master as DRAFT (`scripts/batch2_apply.ps1`), validate, append to
`localization/working/batch2/state.tsv`, resume.

Id contract: batch 2 uses a FRESH id space (`b0001...`, `localization/working/batch2/plan_unique.tsv`);
batch-1 ids are not reused. Chunk authoring is keyed by that id (`ar_<chunk>.tsv` = `id<TAB>arabic`) and the
English column is copied from the plan by id, so an English cell can never drift from the master; the chunk
builder hard-fails on an unknown/duplicate id, an empty Arabic cell, a cell without Arabic letters
(copy-class rows must be omitted) or a placeholder/timing-marker/tag multiset mismatch.

Copy-class still applies: `P-3` (1,140 rows) and `VOV-A6` stay Latin; their rows are deliberately omitted
from chunks, so they remain UNTRANSLATED with an empty Arabic cell (validator hard-fails both a Latin-only
Arabic and a translated copy-class row).

## DEC-030 (cycle 012, 2026-10-19): speaker names are a single curated dictionary; existing batch-1 wording wins

Ruling. `localization/working/labels/speaker_names.tsv` (english / arabic / note) is the single authority
for speaker-name labels and is applied by `scripts/apply_speaker_names.ps1`.

Rules:
   - one Arabic per speaker name, applied to EVERY scope (DEC-028),
   - exact, case-sensitive English match (ordinal `Dictionary[string,string]`, KI-023); `Char-les` and
     `CHAR-les` are distinct source strings and both map to the same Arabic,
   - only rows with an EMPTY Arabic cell are filled; a non-empty different Arabic is reported as a conflict
     and never overwritten,
   - an entry with an EMPTY Arabic is a documented copy-class keep (`P-3`, `Char-les`, `Computer`,
     `VOV-A6`) and is skipped,
   - the glossary is the higher authority: the dictionary adopts the glossary's Arabic for every term the
     glossary already defines (`Doctor`, `Ballerina`, `Korolyov`, `Polymorph` family, `Nechaev`,
     `Sergey Nechaev`, `Kollektiv Neural Network`, `Soviet`), and the glossary's own batch-1 wording wins
     over a new draft (116 entries adopted the existing master wording, so no shipped row was churned),
   - names the dictionary could not confidently render stay out and are listed in
     `glossary/glossary_questions.md` section 9 (technical ids such as `Start`, `NoText`, `SaidSecond`,
     `FinalDialog`, `RadioReroute` and a residual set of one-off label strings).

Result (cycle 012): 1,264 rows filled across 292 distinct names, 0 conflicts, validator warnings unchanged
at 197 (no new glossary/number/length warning), glyph gate PASS with `-AllowSourceInheritedNonLatin`.

Build decision. Carrier p7 = p6 + labels + chunk 1: 3,790,472 bytes, sha256
d7cddff41ac346d7a28c79646e702bb34c1672d1c3e32f8187fa77983b177d9c, 8,981 Arabic + 18,637 English-filled +
0 kept Korean, 35/35 scopes, 0 round-trip failures, 35/35 unpack byte-identical. INSTALLED with explicit
user approval through the reconciling installer (p6 removed only after its hash matched the manifest, font
v2 untouched, `~mods` holds exactly the 3 expected files). Rollback: `install_mod.ps1 -Carrier p6 -Font
p2_plex` (build in `build\package\`) or `-Carrier p5` for the batch-1 build.

## DEC-031 (cycle 013, 2026-10-19): carrier p7 is CONFIRMED in game - bracketed speaker labels, Arabic dialogue, choices and prompts all render

Ruling. The user's in-game report on p7 (screenshot, 2026-10-19) confirms the whole visible surface of the
Chelomey canal boat scene (`D_0072_Sipuha_BringSoda`) renders Arabic: the speaker label `[ الحاسوب ]`, the
dialogue line, BOTH dialogue choices, and the `تطبيق` (Apply) prompt.

Consequences:
   - DEC-028/DEC-030 speaker-name policy is validated end to end: the bracketed names are ordinary locres
     rows, they ARE player-visible, and one dictionary Arabic per name reaches the screen (KI-027 CONFIRMED).
   - KI-009 (subtitle/dialogue font) moves from LIKELY to CONFIRMED for the subtitle path; only GameTips
     popups stay NOT TESTED.
   - KI-022 (subtitle marker parts) moves to partially confirmed: a marker-carrying row plays correctly and
     prints no marker text; the very-long-part clip-vs-scroll question stays NOT TESTED.
   - No data change is required by this report.

## DEC-032 (cycle 013, 2026-10-19): choice number/separator placement is a Phase 8 cosmetic item

Observation (same p7 screenshot): in a dialogue choice the number and its separator (`1 //`) are drawn to
the LEFT of the Arabic choice text, because the choice widget lays out its row LTR while the text run
itself is correct RTL Arabic.

Ruling. KEEP AS IS for the current cycles. It is a widget-layout matter, not a text defect: the master rows
and the locres values are correct, and every other checked string renders right. Logged as KI-028
(COSMETIC / Phase 8) and in ROADMAP.md under "Deferred / parked". Revisit together with the Phase 8 widget
work (mirroring the choice row so the index sits at the right edge in Arabic).

## DEC-033 (cycle 013, 2026-10-19): standing spoken-register style rule + retroactive tone pass on shipped content

Ruling (user decision, after the p7 in-game check - the Arabic read "too soft, polite and stiff" in places,
e.g. `هل ترغب بمزيد من ...`). The standing style rule is now `glossary/terminology.md` section 12:
   - natural spoken-register MSA - how a native speaker really says it, not a word-for-word rendering and
     not a formal literary register; short English = short Arabic; common everyday words over rare ones,
   - one voice per character (Char-les cheerful/sarcastic, Sechenov pompous, soldiers/workers blunt,
     robots mechanical and polite-formal only when the source is, P-3 sarcastic, NORA cheerful);
     the RUSSIAN source decides when the English tone is ambiguous,
   - never soften: insults, swearing, threats, sarcasm and dark humour keep their strength,
   - official-letter register is preserved where the Russian is itself an official letter (that is
     register, not stiffness).

Retroactive application: the already-shipped content (prologue, Chelomey, Academy, PearTerminals, NewP5) was
swept with a stiffness-marker list, compared against the ru-RU source, and 40 rows were rewritten through
`localization/working/tm_fixups.tsv` (KI-021) - 31 rules, 0 errors, validator warnings unchanged at 197,
glyph gate unchanged (introduced-by-Arabic 0). Before/after: `reports/tone_pass.md`, log:
`reports/text_fixups_log.md`. New batches follow the rule from the start.

## DEC-034 (cycle 013, 2026-10-19): Russian "газировка" is rendered "صودا"; the previous "الغازية" is retired

Finding (ru-RU locres export of the shipped game, `scripts/export_ru_reference.ps1` -> `localization/extracted/ru_csv/`):
the boat-scene line is `Дорогой товарищ, газировки не желаете?` and the museum order list says
`Газировка - 200 литров`; the VDNH vending sign is `ГАЗИРОВАННАЯ ВОДА` and the buffet sign sells lemonades
`Тархун`, `Крем-сода`, `Дюшес`. So "газировка" is the everyday Soviet fizzy drink, not sparkling water.

Ruling (DRAFT, reviewer may override - `glossary/glossary_questions.md` section G):
   - `газировка` / `soda` (the drink) -> `صودا` (glossary row added, category item, DRAFT),
   - `ГАЗИРОВАННАЯ ВОДА` (the vending-machine sign) -> `مياه غازية` (precise sense: sparkling water),
   - flavour names are transliterated: `Крем-сода` -> `كريم صودا`, `Тархун` -> `طارخون`, `Дюшес` -> `ديوشيس`.
   - the previous `الغازية` is retired; the boat line now reads `تريد صودا يا رفيقي العزيز؟` and the museum
     order list `صودا، 200 لتر`.
   - TOOLING LESSON: `الغازية` also occurs as a substring inside `التوربينات الغازية` ("gas turbines",
     NewP5), so a bare-substring fixup would have corrupted that row. Every tone/term fix therefore uses a
     full-row (or unique-phrase) `find` string, and the affected row counts are verified in
     `reports/text_fixups_log.md`.
   - rows still untranslated at this point (`NTD_StringTable/gazirovka`, `diaphilm_limonad_1`, `vdnh_bufet2`,
     the "popping soda bottle caps" metaphor in Vavilov/LQA) carry the same glossary term when their chunk
     is authored - they cannot be fixed through `tm_fixups.tsv` because their Arabic cell is empty.

## DEC-035 (cycle 013, 2026-10-19): the neuro-connector device is quoted as «الفكرة», not the Latin THOUGHT

- The master held both forms: 17 rows kept the Latin `THOUGHT` (batch 1) and 5 rows already used the
  translated `«الفكرة»` (batch-2 chunk 1). The Russian original translates the name (`Мысль`), and the
  project already quotes translated names/sayings (`«سبارك»`, `«راديو المستقبل»`, `«بيلياش»`), so the
  translated form wins.
- Applied through `tm_fixups.tsv` (1 global rule, 17 master rows + 17 TM values); glossary row
  `THOUGHT device -> الفكرة` added so future chunks reuse it. The glossary term is deliberately written
  as `THOUGHT device` (not bare `THOUGHT`) because bare `thought` is a common English word and would
  flood the validator with false glossary warnings.

## DEC-036 (cycle 013, 2026-10-19): validator glossary warnings are morphological false positives - triaged, no master change

- 141 glossary warnings were raised at the 13,989-row mark. 10 terms across 20 rows were sampled and
  every one is a false positive of the naive substring match: plural vs adjective (`السوفييت` vs
  `سوفييتي`), feminine forms (`طبيبة` = a female doctor), definite/indefinite titles (`بروفيسور` vs
  `البروفيسور`), word-embedded hits (`majority` matching `Major`) and byte-exact Latin speaker tags
  (`&Petrov&`).
- Consequence: no master edits; the matcher itself is the follow-up item (needs stemming or an accepted
  inflected-forms list). The 24 number-multiset warnings were triaged the same way (Arabic word-numbers
  such as `خمسين`, `طلقتين`, unseparated 2500/3000, identifier digits) - no defect.

## DEC-037 (cycle 013, 2026-10-19): batch authoring contract - one chunk per independent authoring workstream

- The authoring work is the expensive part (4,189 hand-written lines this cycle). The contract
  `localization/working/batch2/AUTHORING_BRIEF.md` is written once (format, hard rules, style rule,
  terminology table, self-verification) and each chunk is authored independently against the frozen
  plan (DEC-029).
- Acceptance is automated and non-negotiable: `scripts/batch2_chunk.ps1 -ChunkId NNNN` must PASS
  (unknown/duplicate id, empty Arabic, Arabic without an Arabic letter, marker/tag multiset). Only the
  lead session runs `batch2_apply.ps1`, so the master stays consistent and the run is resumable at any
  point. Result this cycle: 14 chunks, 0 token mismatches, 0 master conflicts.

## DEC-038 (cycle 013, 2026-10-19): `verify_text_fixups.ps1` runs after EVERY batch apply

- `verify_text_fixups.ps1` failed at cycle close on 2 batch-1 shorten rules: new batch-2 rows had
  reintroduced `الذراع اليسرى` and `تم حفظ البيانات` where the reviewer had approved `ذراع يسرى` and
  `حُفظت البيانات`. New content can always re-create a phrasing that a reviewer already shortened.
- Rule: re-run the fixups (global, idempotent) and the verifier after every batch apply. If they change
  the master, the carrier must be rebuilt/reinstalled - that is why p8 was rebuilt once this cycle.

## DEC-039 (cycle 014, 2026-10-19): bracket-label gate exception (closes KI-029)

- `scripts/batch2_chunk.ps1` now compares NON-bracket tokens byte-exact (markers `*0.00*`, `{...}`,
  `<tag ...>`, `&Speaker&`, `\n`) and treats `[...]` bracket tokens as a separate class: the bracket
  count must still match and every Arabic bracket token must either be byte-identical to the English
  one or contain an Arabic letter. `[Leave]` -> `[مغادرة]` is therefore accepted, `[E]` -> `[E]` is
  unchanged, and changing/dropping/adding a Latin bracket token is still a hard failure.
- Verified: positive case (chunk 0016) PASS; three negative cases fail with explicit messages
  (Latin bracket token changed while Arabic letters are present, bracket injected where English has
  none, bracket dropped where English has one).
- `localization/working/batch2/ar_0016.tsv` is a 1-id "label chunk" that carries `b1627` `[Leave]` ->
  `[مغادرة]` through the normal TM path: 5 master rows filled, coverage 13,989 -> 13,994.
- Scope note: 7 of the 8 ids named in KI-029 (`FinalDialog`, `FirstDialog`, `RANDOM`, `RadioDialog`,
  `RadioReroute`, `SaidFirst`, `SaidSecond`; 42 master rows) stay untranslated on purpose. The ru-RU
  locres of the SAME keys carries the same Latin internal names, i.e. they are asset/state identifiers,
  not player-facing text (evidence `localization/extracted/ru_csv/VDNKh_Dialogues.csv`).

## DEC-040 (cycle 014, 2026-10-19): glossary matcher - accepted forms, morphology, prose-only English (closes the DEC-036 follow-up)

- Root causes of the 141 glossary warnings: (a) the Arabic side used a raw `Contains` of the sanctioned
  rendering, so every inflection (plural/feminine/definite) warned; (b) the English side was matched
  against raw cells, so speaker tags (`&Petrov&`), bracket labels and channel handles (`#cold_workshop`)
  matched as if they were prose; (c) a real bug: `-replace '\u0629','\u0647'` inserts the LITERAL
  escape text, because replacement operands do not expand `\uXXXX` - the normalisation inserted junk.
- Fixes: (1) normalisation strips harakat/tatweel, unifies alef/ya forms, maps ta-marbuta to ha, and
  strips a WORD-INITIAL definite article only (replacements now use literal characters); (2) a glossary
  row may list accepted renderings separated by `|` (`Cartridge -> خرطوشة|خراطيش`); (3) matching also
  accepts a suffix-stem match and a word-prefix match (every content word of the rendering must appear
  as a >=4-character prefix); (4) the English side is matched against PROSE, with markers, tags, bracket
  labels and channel handles blanked out; (5) the 7th glossary column may hold `cs` (case-sensitive
  English match) - set on `Major` so `major damage` / `major reconstruction` stop warning.
- Result: glossary warnings 141 -> 2 (validator totals: warnings 277 -> 138, errors 0). The 2 residual
  warnings are verified benign (see KI-030). No real violation is hidden: a term whose sanctioned and
  accepted renderings are all absent from the Arabic still warns.
- Matcher is deliberately conservative: accepted renderings are explicit per glossary row, auditable in
  `glossary/glossary.tsv`, and recorded here rather than as loose heuristics in the script.

## DEC-041 (cycle 014, 2026-10-19): batch-3 authoring contract, gate/validator alignment, carrier-path fix

- Workstream input contract: `scripts/batch2_sheet.ps1 -ChunkId NNNN -StartId bNNNN -Count 300` writes
  `localization/working/batch2/sheet_NNNN.tsv` with columns `id, scope, category, english, ru, tm`.
  `ru` is the official ru-RU text of the SAME key: the reader is a real CSV record parser because the
  ru exports mix hashed locres keys (`/HASH`) and readable string-table keys (`NTD_StringTable/row`),
  and values may be quoted and contain embedded newlines. `tm` is an existing Arabic rendering of the
  exact same English. The plan remains the only authority for English; a workstream never retypes it.
- Chunk gate: the timing-marker token now uses the VALIDATOR's pattern `\*[0-9][0-9.\-]*\*`, so RANGE
  markers (`*0.01-0.28*`) are enforced. The old pattern only matched single markers (`*0.05*`) and let
  one row (master L19766) ship without its range marker; the row and the authoring file were corrected.
- `build_carrier_locres_pak.ps1`: `-VariantLabel` now derives the default output path. It used to be
  hardcoded to the p3 file, so the first p9 build overwrote the p3 artefact (p3 was an intermediate
  build; p7/p8 are the documented rollback targets; the stray file was removed and p9 rebuilt cleanly).
  An edge-whitespace-only round-trip difference is now tolerated and logged as `EDGE-WS`: the locres
  container cannot store leading/trailing whitespace, so that difference is container normalisation,
  not content loss. One master row carried a leading space and was trimmed.
- Result: 22 authoring chunks (0017-0038) plus the 1-id label chunk 0016, 6,530 ids authored, 7,226 rows
  filled, coverage 13,994 -> 21,220 of 27,618 (76.83%), validator 0 errors, glyph gate 0 glyphs
  introduced by Arabic, TM 9,132 -> 15,410 entries.
- Defects found by the gates and fixed in this cycle: 1 missing range marker; 1 date transcribed from
  the RU asset while the master English says another date (policy: the ENGLISH master is the anchor);
  3 content reductions (dropped polymer expansion, dropped "a doctor", dropped "on Soviet soil");
  2 route-terminal labels; 3 rows with a literal mistranslation of the recurring expletive; 1 edge
  space. Reviewer fixes go through `tm_fixups.tsv` (one new rule this cycle), authoring artefacts are
  patched in place, and the fixup verifier runs after every chunk (DEC-038 held).
