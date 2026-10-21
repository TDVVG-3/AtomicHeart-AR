# A/B test guide - p11 / p11b / font v3 / font v3b

Date: 2026-10-21 (cycle 016). Installed set right now: **carrier p11 + font v3 (unhinted)**.

The three combinations below isolate the two remaining hypotheses:

| # | Carrier | Font | What it tests |
|---|---------|------|---------------|
| **A** (installed now) | p11 (English subtitle markers kept byte-exact) | v3 (Plex, hinting program removed) | Baseline: text passes only; timing untouched. Does P3 shimmer disappear? |
| **B** | p11b (every subtitle cue slowed by 15%) | v3 | P1/P2: are the Arabic pages too short-lived? If B fixes "finishes before the voice" and does not make lines linger, the cue length is the lever. |
| **C** | p11 (same text, same markers) | v3b (Plex + original BlenderPro vertical metrics: 1.20 em line box) | H5: is the shimmer caused by the taller Plex line box? Does C change line spacing/subtitle size? |

Rollback to the last known-good delivered set at any time:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p10
```

## Copy-paste commands (close the game, run one line, start the game)

```powershell
# A - default (p11 + font v3)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11

# B - timing experiment (p11b: subtitle cues 15% longer)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11b

# C - line-metrics experiment (p11 + font v3b)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11_3b

# B+C together (p11b + font v3b), only if you want to see the two effects at once
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p11b3b

# rollback to the previously delivered set (p10 + Plex v2 font)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\AtomicHeart-AR\scripts\switch_variant.ps1 -Variant p10
```

Every command takes a read-only snapshot, verifies the SHA256 of the files it replaces,
installs only inside `Paks\~mods`, and finishes with `VERIFY INSTALL PASS`.

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
