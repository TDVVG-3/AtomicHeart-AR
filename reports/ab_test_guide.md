# A/B test guide - p11 / p11b / font v3 / font v3b / P4 timing variants

Date: 2026-10-26 (cycle 016 + P4 + C6). Installed set right now: **carrier p11c + font v3
(unhinted) + tips x1.5** (`p11c_tips_x150`). The C6 RU-only add-on and the p11e / p11f /
p11ef carriers are built and verified but **NOT installed**; the A/B/C font/timing variants
remain available as one-line switches. Switching to any set is one command, and every
command auto-restores the previous verified set if install or verification fails.

## P4 timing variants - one-line comparison

| variant | what it changes | command to switch | what to look at | rollback |
| --- | --- | --- | --- | --- |
| `p11c` | subtitle **explicit range ends** +0.3 s (0.005 min); long lines x1.15 span; capped before the next page start; singleton pages untouched | `switch_variant.ps1 -Variant p11c` | a cinematic dialogue with explicit ranges (Academy / Verbitsky report): does the last page of each line stay a bit longer? | `-Variant p11` |
| `tips_x125` | 20 timed input tips `DurationTime` x1.25 + item notification `WaitTime` 3.5 -> 4.375 s (spacing unchanged) | `switch_variant.ps1 -Variant tips_x125` | a short tutorial hint and an item pickup notification | `-Variant p11` |
| `tips_x150` | same x1.5 (notification 5.25 s) | `switch_variant.ps1 -Variant tips_x150` | same as above; is it now too long? | `-Variant p11` |
| `p11c_tips_x125` | both p11c and tips x1.25 | `switch_variant.ps1 -Variant p11c_tips_x125` | cinematic line + short hint + pickup | `-Variant p11` |
| `p11c_tips_x150` | both p11c and tips x1.5 | `switch_variant.ps1 -Variant p11c_tips_x150` | cinematic line + short hint + pickup | `-Variant p11` |
| `p11e` | final singleton page becomes an explicit `*t-e*` range (140 pages; 264 ambiguous rows left unchanged) | `switch_variant.ps1 -Variant p11e` | the **last page of a dialogue line** in a cinematic/scripted conversation: does it stay a little longer instead of vanishing at the audio end? | `-Variant p11c` |
| `p11f` | 153 long pages shortened to <=21 Arabic chars/s (117 rows; meaning/tags/numbers/markers preserved) | `switch_variant.ps1 -Variant p11f` | long NPC/cinematic lines: is the Arabic now readable in the same window, without a cut-off or changed meaning? | `-Variant p11c` |
| `p11ef` | p11e + p11f | `switch_variant.ps1 -Variant p11ef` | long line + its last page: shortest total reading time case | `-Variant p11c` |
| `p11e_tips_x150` | p11e + tips x1.5 | `switch_variant.ps1 -Variant p11e_tips_x150` | last page + short hint + pickup | `-Variant p11c_tips_x150` |
| `p11f_tips_x150` | p11f + tips x1.5 | `switch_variant.ps1 -Variant p11f_tips_x150` | long line + short hint + pickup | `-Variant p11c_tips_x150` |
| `p11ef_tips_x150` | p11ef + tips x1.5 | `switch_variant.ps1 -Variant p11ef_tips_x150` | long line + last page + short hint + pickup | `-Variant p11c_tips_x150` |

Notes: `tips_*` adds one extra pak and removes it again when you switch back; the carrier
variants replace only the carrier. `-RuOnly` can be appended to any command above to add the
RU-only cooked-dialogue pak; switch to the same variant **without** `-RuOnly` to remove it.
Quest / new-place banners are expected to stay unchanged. p11e only touches the final page
of a line; all 264 non-monotonic/ambiguous marker rows are listed in
`reports/p11e_last_page_ranges.md` and were left byte-identical. The widget/native scheduler
still owns the ordinary singleton-page end - see `reports/p4_subtitle_hide_blueprint.md`.

The three combinations below isolate the two remaining hypotheses:

| # | Carrier | Font | What it tests |
|---|---------|------|---------------|
| **A** | p11 (English subtitle markers kept byte-exact) | v3 (Plex, hinting program removed) | Baseline: text passes only; timing untouched. Does P3 shimmer disappear? |
| **B** | p11b (every subtitle cue slowed by 15%) | v3 | P1/P2: are the Arabic pages too short-lived? If B fixes "finishes before the voice" and does not make lines linger, the cue length is the lever. |
| **C** | p11 (same text, same markers) | v3b (Plex + original BlenderPro vertical metrics: 1.20 em line box) | H5: is the shimmer caused by the taller Plex line box? Does C change line spacing/subtitle size? |

Rollback to the last known-good delivered set at any time:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p10
```

## C6 add-on - RU-only cooked dialogue (`zzz_atomicheart-ar_ruonly_p1_P.pak`)

**Status: built and verified, NOT installed.** It is an optional add-on; add it on top of
the current installed set (`p11c_tips_x150`) or on top of plain p11.

| item | value |
| --- | --- |
| pak | `build\package\zzz_atomicheart-ar_ruonly_p1_P.pak` |
| size | 7,998,115 bytes |
| SHA256 | `BECEB894BCAAEAC546DA8D847AF815B42493A971ED45DC8D8B2693332EAA1CC3` |
| contents | 248 data assets (248 `.uasset` + 248 `.uexp`), 496 pak entries |
| changes | 13,994 text fields; 13,802 source strings; 0 missing targets |
| mount | `../../../` (data-only; no EXE/DLL, no game-folder write during build) |

What it changes: the RU-only cooked dialogue assets that the normal carrier does not cover
(`DT_Subtitles_*`, `D_DLC*`, terminal dossiers/mail, GooseRunner hint StringTables, NPC
names/positions). It writes Arabic into the existing `CultureInvariantString` fields and
StringTable values, so the game's own subtitle/terminal widgets render it.

How to see it:

```powershell
# close the game first; adds the RU-only add-on on top of the current p11c_tips_x150 set
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11c_tips_x150 -RuOnly
```

Check: the Chelomey/Academy test dialogue; a terminal mail/dossier (Subject/MailBody); a
GooseRunner tutorial hint; an NPC name in a world-space subtitle. Compare against the same
scene without `-RuOnly` (current set) - the add-on affects only those RU-only assets.

Remove the add-on (returns to the current `p11c_tips_x150` set; no game files outside `~mods`
are touched):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11c_tips_x150
```

## Copy-paste commands (close the game, run one line, start the game)

```powershell
# current installed set (p11c + font v3 + tips x1.5)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11c_tips_x150

# plain p11 baseline (p11 + font v3)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11

# current set + C6 add-on - p11c + font v3 + tips x1.5 + Arabic for the RU-only assets
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11c_tips_x150 -RuOnly

# B - timing experiment (p11b: subtitle cues 15% longer)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11b

# C - line-metrics experiment (p11 + font v3b)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11_3b

# B+C together (p11b + font v3b), only if you want to see the two effects at once
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11b3b

# rollback to the previously delivered set (p10 + Plex v2 font)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p10

# --- P4 timing variants (p11c + tips x1.5 are the current installed set) ---
# p11c - subtitle explicit-range end hold (+0.3 s, long lines x1.15)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11c

# tips x1.25 / x1.5 - longer input tips + item notifications
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant tips_x125
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant tips_x150

# combined
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11c_tips_x125
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11c_tips_x150

# P4.3 subtitle variants (BUILT, NOT YET INSTALLED)
# p11e = final singleton page explicit range; p11f = 153 long pages shortened; p11ef = both
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11e
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11f
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11ef
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11ef_tips_x150

# add / remove the RU-only cooked-dialogue pak on any variant
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11ef -RuOnly
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11ef

# back to the current installed set (also removes the tips pak)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11c_tips_x150
```

Every command takes a read-only snapshot, backs up the current `~mods` set, verifies the
SHA256 of the files it replaces, installs only inside `Paks\~mods`, and finishes with
`VERIFY INSTALL PASS`. If install or verification fails, it restores the backup and prints
`ROLLED BACK TO <previous set>`.

## Scene to test (same scene for all three runs)

1. **Opening cutscene** (the long Sechenov / Chelomey speech): long subtitle rows with
   several `*0.xx*` pages - the best place to judge P1 (does each page appear/disappear
   with the voice?) and P2 (does the previous page stay on screen too long?).
2. **Canal boat dialogue** (the scene used for the earlier checks): NPC subtitle + the
   `1 //` choice widget - checks RTL alignment, font size and the lingering line.
3. **One open-world NPC** with a world-space subtitle (walk up to a talking NPC): this path
   uses a different widget (`BP_AHWwiseActorWithSubtitleWidget`), so check it separately.
4. **Weapon upgrade menu** (NORA): the longest UI labels and the font line spacing.

Do the same route in A, then B, then C (the save can be reused; subtitles are not saved).

## What to report for each run

Please answer with a short note per run (A/B/C), even "same as before" is useful:

- **P1 early/fast**: does the Arabic page disappear before the voice finishes? Before the
  page is readable? Give the scene and the line if you can.
- **P2 lingering**: does the previous line stay on screen after the voice moved on? Does the
  new line wait too long to appear?
- **P3 shimmer**: while the camera moves, does the subtitle text ripple/vibrate? Compare A
  (v3) against the old p10+Plex set, and C (v3b) against A.
- **Line spacing / size**: are the subtitles taller or closer to the bottom edge than before?
  Is any line clipped?
- **Missing glyphs**: any empty box or blank character (a Cyrillic letter inside a weapon
  name or the Japanese quote in one DLC4 mail are known source-inherited cases).

## What each result means

- A removes the shimmer but B does not change timing -> ship A; P1/P2 are engine-side
  (audio-driven cue timing, `USubtitlesSubsystem`), documented as such.
- B fixes the "finishes too early" and does not introduce lingering -> the cue length is the
  lever; p11b becomes the new default after review.
- C changes spacing/shimmer -> adopt the v3b vertical metrics in the default font.
- B makes subtitles desync progressively -> markers are absolute audio cues; p11 (exact
  English markers) is the correct default and P1/P2 are not marker-related.

## Evidence backing this guide

- `reports/subtitle_timing_audit.md` - 537 marker rows, 537 byte-identical to the English
  marker multiset, 0 value/order mismatches, 0 balance outliers.
- `reports/p11b_marker_retime.md` - exactly what p11b changes (537 rows, x1.15).
- `reports/font_ab_evidence.md` - original vs Plex table/metric comparison and the v3/v3b
  build proofs.
- `reports/install_verification.md` - the current install proof (nothing outside ~mods moved).
- `reports/p4_timing_sources.md` - CONFIRMED/LIKELY/UNKNOWN sources for tip and notification time.
- `reports/p4_subtitle_investigation.md` - marker semantics, absent hold setting, p11c rules.
- `reports/p4_subtitle_hide_blueprint.md` - CONFIRMED hide/fade path (0.15 s), no widget timer.
- `reports/p11e_last_page_ranges.md` / `reports/p11e_audit.md` - 140 final singleton ranges, 264 ambiguous rows.
- `reports/p11f_shortened.md` - 153 before/after pages (117 rows), 9,990 -> 6,503 Arabic chars.
- `reports/variant_test_matrix.md` - dry-run + temp install + forced-failure rollback for all variants.
- `reports/p11c_marker_hold.md` / `reports/p11c_audit.md` - p11c build stats and adapted gate.
