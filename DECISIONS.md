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

Date: 2026-10-18
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
