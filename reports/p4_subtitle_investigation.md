# P4.2 - dialogue subtitle duration investigation

**Date:** 2026-10-24 16:24 (+03:00)
**Question:** subtitles disappear before the Arabic line can be read. Is there a data-side
hold / fade / minimum-display setting, and what do the `*a-b*` markers actually control?

## (a) Marker semantics - CONFIRMED

- Marker numbers are **absolute times in minutes** into the voice clip. Proof: ru-RU
  `Academy_Dialogues` key `/5434B01849407463CAA10B822CDA51A8` is
  `*0.00-0.08* ... *0.09-0.25*`, i.e. the second page runs from 5.4 s to 15 s of the clip.
- Two forms exist:
  - `*t*` - a **page start**. The previous page ends when the next start is reached.
  - `*a-b*` - an **explicit range**: the page is visible from `a` to `b`.
- The last page of a row has no explicit end when only starts are used: `DT_Subtitles_*`
  has `Duration = 0` on all **8,853** rows, so the last page's lifetime is the VO audio end.
  There is no `Duration` fallback to exploit (all zero) and `Priority` is also 0 everywhere.
- Census of the 539 master rows that contain markers (`build/p4/subtitle_markers.tsv`):
  - EN: **685 ranges + 923 singletons**; AR: **683 ranges + 923 singletons**;
  - **537 rows have an identical marker sequence**; 2 rows have no Arabic markers.
- Official-culture evidence (`build/p4/locres_src`, same Academy key):
  - en-US: `*0.10* ... *0.10*` - duplicate timestamp in the English source itself (defect);
  - ru-RU: proper ranges `*0.00-0.08* ... *0.09-0.25*`;
  - de-DE: singletons `*0.09* ... *0.11*`; ja-JP and ko-KR: markers dropped entirely.

## (b) Minimum hold / fade / hide delay - UNKNOWN (none found)

Full float-property scan of the subtitle assets already dumped in `build/extracted/subsys`:

| asset | time-like fields found |
| --- | --- |
| `BP_SubtitlesSubsystem` | `SubtitleSizeScale = 0.75` only |
| `WBP_Subtitle` | layout only (Top/Bottom/Width/Height) |
| `WBP_OneSubtitle` | layout only (margins) |
| `WBP_NPCSubtitle` | layout only (margins / width / draw distance) |

- No `WaitTime`, `HoldTime`, `LingerTime`, `FadeTime`, `MinDisplayTime`, `HideDelay` or
  `ExtraTime` field exists in any of them.
- No subtitle settings DataAsset exists in `pakchunk0` (pak scan for `*Subtitle*` returns
  only these widgets, `BP_AHWwiseActorWithSubtitleWidget`, and unrelated subsystem assets).
- `DT_Subtitles` columns are `Duration`, `Marker`, `Priority`, `Sentences`, `Speaker`,
  `Subtitle`; only `Duration` is a float and it is 0 on every row.

**Verdict:** no data-side global hold, fade or hide-delay lever exists. This part is UNKNOWN.

## (c) Stock behaviour for long Arabic vs English - CONFIRMED by data

- The page clock is audio/absolute-time driven. Arabic text length does not influence it.
- **404 of 537** marker rows are singleton-only: their pages end at the next start, and the
  last page at the VO end. Nothing in data can extend those without retiming the audio.
- **133 rows** carry **683 explicit ranges**; those ends are data and can be extended.
- The English source itself is inconsistent (duplicate `*0.10*` on the Academy key), so the
  Arabic inherited a timing track that is not always meaningful; ru-RU shows the intended
  range form.

## p11c - explicit-end hold variant (built, NOT INSTALLED)

Rule applied to the Arabic cell only:

```
new_end = max(end + 0.005 min (= 0.3 s), start + 1.15 * span)   # 1.15 only for long rows
new_end = min(new_end, next_page_start - 0.005 min)              # never overlap
new_end = max(new_end, end)                                     # never shrink
```

- "Long row" = visible Arabic text >= 100 characters after removing `*...*` and `&...&`
  (121 rows).
- Marker count, order, type and every START stay byte-identical; 12 non-Arabic columns are
  byte-identical; visible Arabic text is byte-identical; no end shrinks; no end reaches the
  next start.
- Result: **632 of 683 range ends extended** (415 capped by the next start, 51 already
  touching it, 133 last ranges uncapped); mean delta **0.007 min (~0.42 s)**, max
  **0.096 min (~5.8 s)** on long pages; mean span ratio **1.140**.
- Singleton-only rows (404) are untouched by design.

| artifact | value |
| --- | --- |
| variant master | `build/variants/atomic-heart-ar_p11c.tsv` |
| carrier pak | `build/package/zzz_atomicheart-ar_carrier_koKR_p11c_P.pak` |
| size | 4,474,004 bytes |
| SHA256 | `cfb590e87e6e14e17a07e704d7d6065c5392ea98b70cf6702231746d3c4b8815` |
| entries / round-trip | 35 / **35 byte-identical** |
| text round-trip | 27,618 keys, 26,022 Arabic, 1,596 English fill, 0 Korean, 0 fail |

Gates:

- adapted audit `scripts/p4_subtitle_audit_p11c.ps1`: **0 violations** (`reports/p11c_audit.md`);
- stock audit on the untouched canonical master: **537/537 identical** (`reports/subtitle_timing_audit.md`);
- validator on canonical master: **PASS**, 0 errors / 230 warnings;
- glyph gate on the p11c master: **PASS**, 0 newly required codepoints.

## Verdict

- **CONFIRMED lever:** explicit range ends (`*a-b*`) can hold a page longer; p11c does this.
- **UNKNOWN:** a global minimum-hold/fade/hide-delay for singleton pages. Those pages end
  with the voice clip; extending them requires audio-side retiming or an engine change, both
  out of scope for a data-only mod.
- p11c is therefore a **partial** answer to "subtitles too fast": it helps the cinematic
  rows that use explicit ranges (133 rows, 683 ranges) and leaves singleton dialogue
  untouched.

## What to look at in game

- A cinematic conversation with explicit ranges (Academy / Verbitsky-style report): pages
  should stay on screen slightly longer, especially the last page of each line.
- Ordinary NPC dialogue (singleton markers): expected unchanged.
- If p11c causes visible desync or overlap, switch back to p11 (rollback command in HANDOFF).
