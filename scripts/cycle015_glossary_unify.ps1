<#
.SYNOPSIS
  Cycle 015: append three glossary-unification rules to tm_fixups.tsv.

.DESCRIPTION
  Found by the validator after batch 4: the DLC4 mails rendered the location
  "Crystal Complex" as a transliteration instead of the glossary translation, and
  two rarer spellings (Sakhalin, Kollektiv) drifted from the glossary.
  Glossary authority: glossary.tsv (Crystal Complex -> translated; Sakhalin and
  Kollektiv -> transliterated).

  ASCII-only script (KI-021): the Arabic payloads are built from [char] codepoints,
  no Arabic literal appears in this file.
  Appends (find, replace, note) rows; apply_text_fixups.ps1 then updates the master,
  the TM and the seed CSV. Idempotent: it refuses to append a rule that already exists.
#>
[CmdletBinding()]
param([string]$RepoRoot = 'C:\AtomicHeart-AR')
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

function A([int[]]$codes) { return (-join ($codes | ForEach-Object { [char]$_ })) }

# 1) Crystal Complex: "majma' kristal" (transliteration) -> "al-majma' al-buluri" (glossary translation)
$find1 = A @(0x645, 0x62C, 0x645, 0x651, 0x639, 0x20, 0x643, 0x631, 0x64A, 0x633, 0x62A, 0x627, 0x644)
$repl1 = A @(0x627, 0x644, 0x645, 0x62C, 0x645, 0x651, 0x639, 0x20, 0x627, 0x644, 0x628, 0x644, 0x648, 0x631, 0x64A)
# 2) Sakhalin: "sakhalin" (short spelling) -> "sakhalin" (glossary spelling)
$find2 = A @(0x633, 0x62E, 0x627, 0x644, 0x64A, 0x646)
$repl2 = A @(0x633, 0x627, 0x62E, 0x627, 0x644, 0x64A, 0x646)
# 3) Kollektiv: "kolktif" -> "koliktif" (glossary transliteration)
$find3 = A @(0x643, 0x648, 0x644, 0x643, 0x62A, 0x64A, 0x641)
$repl3 = A @(0x643, 0x648, 0x644, 0x64A, 0x643, 0x62A, 0x64A, 0x641)

$rules = @(
    @( $find1, $repl1, 'cycle015 glossary: Crystal Complex -> glossary translation, not the transliteration' ),
    @( $find2, $repl2, 'cycle015 glossary: Sakhalin -> glossary transliteration' ),
    @( $find3, $repl3, 'cycle015 glossary: Kollektiv -> glossary transliteration' )
)

$fixups = Join-Path $RepoRoot 'localization\working\tm_fixups.tsv'
$utf8 = New-Object Text.UTF8Encoding($false)
$text = [IO.File]::ReadAllText($fixups, $utf8)
$tab = [char]9
$added = 0
foreach ($r in $rules) {
    $line = ($r[0] + $tab + $r[1] + $tab + $r[2])
    $probe = ($tab + $r[0] + $tab)
    if ($text.Contains($probe)) { Write-Output ('[skip] rule already present: ' + $r[2]); continue }
    if (-not $text.EndsWith([string][char]10)) { $text += ([string][char]13 + [string][char]10) }
    $text += ($line + [string][char]13 + [string][char]10)
    $added++
    Write-Output ('[add] ' + $r[2] + ' | find chars ' + $r[0].Length + ' -> replace chars ' + $r[1].Length)
}
if ($added -gt 0) { [IO.File]::WriteAllText($fixups, $text, $utf8) }
Write-Output ('[fixups] rules appended: ' + $added + ' | total lines: ' + ([IO.File]::ReadAllLines($fixups, $utf8).Count))
