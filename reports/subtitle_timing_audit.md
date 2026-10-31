# Subtitle timing audit (Workstream A)

Generated: 2026-10-31 11:10:44

## Method (what the markers are)

A subtitle line carries inline markers `*t*` (time point) and `*t1-t2*` (start-end range), with `t` in minutes into the voice clip. Evidence that they are timing and not decoration:

- the same key carries DIFFERENT marker values per culture. Academy key `/5434B01849407463CAA10B822CDA51A8` has `*0.10*` twice in English and Arabic, no marker at all in Korean, while Academy key `/4B8C709A40B531D70C2A31B74C49E372` has `*0.10*` in English but `*0.19*` / `*0.21*` in Korean - a per-language retime of the same voice clip.
- the Russian subtitle DataTables (`DT_Subtitles_*`) carry the explicit range form (`*0.00-0.08*`, `*0.09-0.25*`), i.e. start-end times for the same Russian voice clip.
- the locres text itself is the only string the game receives for these keys (no duration column in the locres schema).

Therefore a translated row must keep the English marker multiset AND order byte-exact, and each Arabic segment must carry the meaning of the English segment at the same index. A lost or reordered marker shifts the text against the voice (P1) and leaves the last part on screen after the voice ends (P2).

## Result

| metric | value |
| --- | --- |
| translated rows audited | 26022 |
| rows that carry markers (EN or AR) | 537 |
| marker sequence identical (values + order) | **537 of 537 (100%)** |
| AR missing markers that EN has (lingering risk) | **0** |
| AR has extra markers that EN lacks | **0** |
| same markers, different values (timing drift) | **0** |
| same markers, different order | **0** |
| rows with at least one segment-ratio outlier | 0 |
| segment outliers (< 0.6 or > 1.6 Arabic/English words) | 0 |

## Defects that explain the user report

**P2 - lingering subtitles: NOT explained by lost markers (0 rows).** See the segment-ratio analysis below.

**P1 - timing: marker values themselves are byte-exact in every row**, so the perceived "too early / too fast" comes from the segment content balance (below), not from marker drift.

**Segment balance: 0 rows have at least one part outside 0.6-1.6.** A part far too long means the Arabic packed the meaning of the following English part into it (so the viewer reads ahead and the last part is empty when the voice arrives); a part far too short means the meaning moved later. Those rows are rebalanced in Workstream A step 2, keeping the markers byte-exact.

## Worst rows

| line | scope | verdict | EN markers | AR markers |
| --- | --- | --- | --- | --- |
| - | - | none | - | - |

## Files

- `reports/subtitle_timing_rows.tsv` - every audited row with its verdict and ratio range.
- `reports/subtitle_timing_outliers.tsv` - every outlier segment with English and Arabic text for triage.
