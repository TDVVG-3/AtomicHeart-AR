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
  packaging, and the font pak v2 is a separate approval