<#
.SYNOPSIS
  Cycle 015 one-off repairs for four batch-2 rows (chunks 0039/0040) plus a
  re-normalisation pass over the cycle-015 chunk files.

.DESCRIPTION
  Defects found by the gates after applying chunks 0039..0043:
    (1) key 72E0B90F... ("Some pipes carry gas...") invented two
        <tag id="InputAction.Gameplay.SwitchAbility*"/> tags that the en-US source
        does not have -> validator ERROR "rich-text tag multiset differs".
    (2) three rows used the bare transliteration of the "chirper" term instead of the
        glossary rendering (glossary.tsv: Chirper) -> glossary warnings.
  The two remaining findings were reviewer deprecated spellings already covered by
  existing tm_fixups.tsv rules; apply_text_fixups.ps1 fixes those.

  ASCII-only script (KI-021): every Arabic payload is built from [char] codepoints and
  the term is derived from the master rows themselves. Idempotent.

  Touches: localization/master/atomic-heart-ar.tsv, localization/working/tm.tsv and the
  batch-2 chunk files of chunks 0039..0043 (kept consistent with the master).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$utf8 = New-Object System.Text.UTF8Encoding($false)

function Get-Text([string]$p) {
    $b = [IO.File]::ReadAllBytes($p)
    if ($b.Length -ge 3 -and $b[0] -eq 229 -and $b[1] -eq 187 -and $b[2] -eq 191) { $b = $b[3..($b.Length - 1)] }
    return $utf8.GetString($b)
}
function Save-Text([string]$p, [string]$text) {
    if ($DryRun) { Write-Output ('[dry-run] would write ' + $p); return }
    [IO.File]::WriteAllText($p, $text, $utf8)
}
function A([int[]]$codes) { return (-join ($codes | ForEach-Object { [char]$_ })) }

# ---- Arabic payloads, built from codepoints ----
$TA    = [char]0x62A                                                   # letter ta
$word  = A @(0x634, 0x64A, 0x631, 0x628, 0x631)                        # bare chirper
$findA = (A @(0x625, 0x646, 0x647, 0x20)) + $word                      # "inna chirper"
$replA = (A @(0x625, 0x646, 0x647, 0x20)) + $TA + $word
$findB = (A @(0x627, 0x644, 0x62C, 0x62D, 0x64A, 0x645, 0x20)) + $word + (A @(0x643, 0x20, 0x64A, 0x639, 0x645, 0x644))
$replB = (A @(0x627, 0x644, 0x62C, 0x62D, 0x64A, 0x645, 0x20)) + $TA + $word + (A @(0x643, 0x20, 0x64A, 0x639, 0x645, 0x644))

$tagRowKey = '72E0B90FCE8ED8F9B4935AE08B4230421EE87A29'
$tagMarker = 'Some pipes carry gas'

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$tmPath     = Join-Path $RepoRoot 'localization\working\tm.tsv'
$work       = Join-Path $RepoRoot 'localization\working\batch2'

# ---- 1. master ----
$masterText = Get-Text $masterPath
$nl = "`n"
if ($masterText.IndexOf("`r`n") -ge 0) { $nl = "`r`n" }
$endsWithNl = $masterText.EndsWith($nl)
$lines = $masterText -split [regex]::Escape($nl)
$changed = 0
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq '') { continue }
    $r = $lines[$i] -split "`t"
    if ($r.Count -lt 7) { continue }
    $ar = $r[6]
    $new = $ar
    if ($r[0] -eq $tagRowKey -and $new -match '<tag') {
        $new = [regex]::Replace($new, ' ?<tag[^>]*>', '')
    }
    if ($new.Contains($findA)) { $new = $new.Replace($findA, $replA) }
    if ($new.Contains($findB)) { $new = $new.Replace($findB, $replB) }
    if ($new -ne $ar) {
        $changed++
        Write-Output ('[master] line ' + ($i + 1) + ' fixed (id ' + $r[0] + ')')
        $r[6] = $new
        $lines[$i] = ($r -join "`t")
    }
}
$out = ($lines -join $nl)
if (-not $endsWithNl -and $out.EndsWith($nl)) { $out = $out.Substring(0, $out.Length - $nl.Length) }
Save-Text $masterPath $out
Write-Output ('[master] rows changed: ' + $changed)

# ---- 2. translation memory ----
$tmText = Get-Text $tmPath
$tmBefore = $tmText
$tmText = $tmText.Replace($findA, $replA).Replace($findB, $replB)
$tmLines = $tmText -split [regex]::Escape($nl)
for ($i = 0; $i -lt $tmLines.Count; $i++) {
    if ($tmLines[$i].Contains($tagMarker)) {
        $tmLines[$i] = [regex]::Replace($tmLines[$i], ' ?<tag[^>]*>', '')
    }
}
$tmText = $tmLines -join $nl
if ($tmText -eq $tmBefore) { Write-Output '[tm] no change needed' } else { Write-Output '[tm] entries updated' }
Save-Text $tmPath $tmText

# ---- 3. batch-2 chunk files of cycle 015 (kept consistent with the master) ----
$rules = @()
foreach ($l in (Get-Text (Join-Path $RepoRoot 'localization\working\tm_fixups.tsv') -split "`r?`n")) {
    if ($l -eq '' -or $l.StartsWith('find' + [char]9)) { continue }
    $f = $l -split "`t"
    if ($f.Count -ge 2 -and $f[0] -ne '' -and $f[1] -ne '') { $rules += , @($f[0], $f[1]) }
}
Write-Output ('[chunks] fixup rules loaded: ' + $rules.Count)
foreach ($name in 'ar_0039.tsv', 'chunk_0039.tsv', 'ar_0040.tsv', 'chunk_0040.tsv', 'ar_0041.tsv', 'chunk_0041.tsv', 'ar_0042.tsv', 'chunk_0042.tsv', 'ar_0043.tsv', 'chunk_0043.tsv') {
    $p = Join-Path $work $name
    if (-not (Test-Path $p)) { continue }
    $txt = Get-Text $p
    $before = $txt
    foreach ($rule in $rules) { $txt = $txt.Replace($rule[0], $rule[1]) }
    $txt = $txt.Replace($findA, $replA).Replace($findB, $replB)
    $ls = $txt -split [regex]::Escape($nl)
    for ($i = 0; $i -lt $ls.Count; $i++) {
        if ($ls[$i].Contains($tagMarker)) { $ls[$i] = [regex]::Replace($ls[$i], ' ?<tag[^>]*>', '') }
    }
    $txt = $ls -join $nl
    if ($txt -ne $before) { Write-Output ('[chunks] ' + $name + ' updated'); Save-Text $p $txt } else { Write-Output ('[chunks] ' + $name + ' unchanged') }
}
Write-Output 'DONE'
