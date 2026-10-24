# p11c - subtitle page hold variant

Generated: 2026-10-24 16:22:00 +03:00

Built from `localization/master/atomic-heart-ar.tsv`. Only the Arabic cell (column 6)
changes, and only the END of an explicit range marker:

```
new_end = max(end + 0.005 min (= 0.3 s), start + 1.15 * span)   # 1.15 only for long rows
new_end = min(new_end, next_page_start - 0.005 min)              # never overlap
new_end = max(new_end, end)                                     # never shrink
```

Units are minutes into the voice clip (ru-RU `0.00-0.25` = 15 s). Singleton-only pages
carry no end marker; their lifetime is the audio end and they are untouched.

Rows with Arabic markers: 537 | with ranges: 133 | singleton-only: 404 | changed rows: 133
Explicit ranges: 683 | ends extended: 632 | capped by next start: 415 | last-range (no cap): 133
Long rows (visible Arabic >= 100 chars): 121
End delta (min): mean 0.007 | min 0.000 | max 0.096
Span ratio after edit: mean 1.140 (x1.15 target for long ranges)

## Structural gate

- all 12 non-Arabic columns byte-identical to the master
- every row keeps its marker count and order; every range stays a range
- every marker START value byte-identical; no end shrinks; no end reaches the next start
- violations: 0 (checked rows: 27618)

## Examples

- L6408  *0.00-0.02* -> *0.00-0.025*  (span 0.020 -> 0.025 min)
- L6408  *0.10-0.12* -> *0.10-0.125*  (span 0.020 -> 0.025 min)
- L19679  *0.00-0.02* -> *0.00-0.025*  (span 0.020 -> 0.025 min)
- L19679  *0.03-0.12* -> *0.03-0.125*  (span 0.090 -> 0.095 min)
- L19679  *0.13-0.19* -> *0.13-0.195*  (span 0.060 -> 0.065 min)
- L19679  *0.20-0.24* -> *0.20-0.245*  (span 0.040 -> 0.045 min)
- L19679  *0.25-0.27* -> *0.25-0.275*  (span 0.020 -> 0.025 min)
- L19680  *0.00-0.02* -> *0.00-0.025*  (span 0.020 -> 0.025 min)
- L19680  *0.03-0.07* -> *0.03-0.075*  (span 0.040 -> 0.045 min)
- L19680  *0.08-0.13* -> *0.08-0.135*  (span 0.050 -> 0.055 min)

The stock `subtitle_timing_audit.ps1` compares AR markers to EN byte-exact; by design it
reports this variant as different (intended end-only change). The adapted audit
`scripts/p4_subtitle_audit_p11c.ps1` is the gate for this file.
