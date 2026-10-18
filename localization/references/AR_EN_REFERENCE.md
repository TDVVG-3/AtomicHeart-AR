# AR <-> EN reference (rows that already carry Arabic)

Regenerated: 2026-10-18 (cycle 006, after dialogue batch 1 of 4).

Rule: this file lists ONLY master rows whose Arabic column is non-empty. During the
dialogue program the Arabic column stays EMPTY by design (translation comes later), so
the list below is intentionally empty right now.

| Rows with Arabic | Dialogue rows so far |
|---|---|
| 0 | 0 of 10,505 (0%) |

When translation starts, regenerate this file with the same rule (Arabic column
non-empty only) so it can be used as a translation memory seed.

## How to regenerate

    # from C:\AtomicHeart-AR, PowerShell
    $lines = [IO.File]::ReadAllLines('localization\master\atomic-heart-ar.tsv', [Text.Encoding]::UTF8)
    $rows = for ($i=1; $i -lt $lines.Count; $i++) { $f = $lines[$i] -split "`t"; if ($f[6] -and $f[6].Trim()) { [pscustomobject]@{ File=$f[2]; Key=$f[4]; English=$f[5]; Arabic=$f[6]; Category=$f[9] } } }
    $rows | Export-Csv localization\references\AR_EN_REFERENCE.csv -NoTypeInformation -Encoding UTF8
