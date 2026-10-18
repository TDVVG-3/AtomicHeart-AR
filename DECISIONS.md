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