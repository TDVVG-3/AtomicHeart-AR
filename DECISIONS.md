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
