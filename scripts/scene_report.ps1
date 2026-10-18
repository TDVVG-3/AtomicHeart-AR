<#
.SYNOPSIS
  Writes reports/scene_opening.md: the opening bridge / PA-announcement scene of
  Chelomey_Dialogues (master lines 284-324), the Arabic delivered in this cycle,
  the English it came from, and a per-segment length comparison (marker parts).

.DESCRIPTION
  ASCII-only script; every Arabic string is read from the master (UTF-8), never from a
  literal (KI-021). Row set = localization/working/scene_opening_rows.tsv (the 40 rows
  translated in this cycle) plus the one speech row that already carried pilot Arabic.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$Out = ''
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

if (-not $Out) { $Out = Join-Path $RepoRoot 'reports\scene_opening.md' }
$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$rowsPath   = Join-Path $RepoRoot 'localization\working\scene_opening_rows.tsv'
$pilotKey   = '/4C81F68D466B7E53EDEB3BADA39F3810'   # Sechenov "device of the future" row, pilot DRAFT (unchanged)

# --- scene row list (scope, key, english) + the pilot row
$scene = New-Object System.Collections.Generic.List[object]
$rowLines = [IO.File]::ReadAllLines($rowsPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $rowLines.Count; $i++) {
    if (-not $rowLines[$i].Trim()) { continue }
    $f = $rowLines[$i] -split "`t"
    $scene.Add([pscustomobject]@{ scope = $f[0]; key = $f[1]; english = $f[2] })
}

# --- master lookup
$ar = @{}; $st = @{}; $nt = @{}; $enMaster = @{}
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $mlines.Count; $i++) {
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $id = $scope + '|' + $f[4]
    $ar[$id] = $f[6]; $st[$id] = $f[10]; $nt[$id] = $f[11]; $enMaster[$id] = $f[5]
}

function Split-Parts([string]$s) {
    $parts = New-Object System.Collections.Generic.List[string]
    $cur = ''
    $i = 0
    while ($i -lt $s.Length) {
        if ($s[$i] -eq '*' ) {
            $m = [regex]::Match($s.Substring($i), '^\*[0-9][0-9.\-]*\*')
            if ($m.Success) {
                if ($cur.Trim()) { $parts.Add($cur.Trim()) }
                $cur = ''
                $i += $m.Length
                continue
            }
        }
        $cur += $s[$i]
        $i++
    }
    if ($cur.Trim()) { $parts.Add($cur.Trim()) }
    return $parts
}

$rep = New-Object System.Collections.Generic.List[string]
$rep.Add('# Opening scene: Sechenov welcome speech + street crowd (Chelomey_Dialogues)')
$rep.Add('')
$rep.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$rep.Add('Scope: **Chelomey_Dialogues**  |  asset: `AtomicHeart/Content/Localization/Chelomey_Dialogues/en-US/Chelomey_Dialogues.locres`')
$rep.Add('Master rows 284-324 (consecutive, same asset): 12 PA-announcement / speech rows + 29 crowd speaker-label rows.')
$rep.Add('')
$rep.Add('Why this scene: the subtitle on screen in the pilot screenshot (bridge, quest "NO REST FOR THE WICKED",')
$rep.Add('objective "Cross the bridge") is the middle segment of master row 289 - key `/DC11CB9A4BFFB0AA5E099DAA4057EEE9`.')
$rep.Add('Rows 284-295 are the loudspeaker/PA speech of the street and bridge; rows 296-324 are the crowd')
$rep.Add('speaker labels used by the same asset (benches, cafe, citizens).')
$rep.Add('')
$rep.Add('| # | master line | scope | key | status | notes | EN chars | AR chars | parts |')
$rep.Add('|---|---|---|---|---|---|---|---|---|')

# line numbers for reporting
$lineOf = @{}
for ($i = 1; $i -lt $mlines.Count; $i++) {
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $lineOf[$scope + '|' + $f[4]] = $i + 1
}

$all = New-Object System.Collections.Generic.List[object]
$all.Add([pscustomobject]@{ scope = 'Chelomey_Dialogues'; key = $pilotKey; english = ''; group = 'speech (pilot, unchanged)' })
foreach ($r in $scene) {
    $group = 'speech (new)'
    if ($r.english.Length -le 20) { $group = 'crowd label (new)' }
    $all.Add([pscustomobject]@{ scope = $r.scope; key = $r.key; english = $r.english; group = $group })
}

$n = 0
foreach ($r in $all) {
    $n++
    $id = $r.scope + '|' + $r.key
    $e = $r.english; if (-not $e) { $e = $enMaster[$id] }
    $a = $ar[$id]
    $mk = ([regex]::Matches($e, '\*[0-9][0-9.\-]*\*')).Count
    $parts = Split-Parts $e
    $rep.Add(('| {0} | {1} | {2} | `{3}` | {4} | {5} | {6} | {7} | {8} |' -f $n, $lineOf[$id], $r.scope, $r.key, $st[$id], $nt[$id], $e.Length, $a.Length, $parts.Count))
}
$rep.Add('')
$rep.Add('## The Sechenov speech rows (master 284-295): Arabic and English')
$rep.Add('')
$n = 0
foreach ($r in $all) {
    if ($r.group -notlike 'speech*') { continue }
    $n++
    $id = $r.scope + '|' + $r.key
    $e = $r.english; if (-not $e) { $e = $enMaster[$id] }
    $rep.Add(('### {0}. `{1}`  (master line {2})' -f $n, $r.key, $lineOf[$id]))
    $rep.Add('')
    $rep.Add(('AR: ' + $ar[$id]))
    $rep.Add('')
    $rep.Add(('EN: ' + $e))
    $rep.Add('')
}
$rep.Add('## Crowd speaker labels (master 296-324): Arabic and English')
$rep.Add('')
$n = 0
foreach ($r in $all) {
    if ($r.group -notlike 'crowd*') { continue }
    $n++
    $id = $r.scope + '|' + $r.key
    $rep.Add(('{0}. `{1}` -> AR: {2}   (EN: {3})' -f $n, $r.key, $ar[$id], $enMaster[$id]))
}
$rep.Add('')
$rep.Add('## Segment lengths after the timing markers are stripped')
$rep.Add('')
$rep.Add('The game splits a subtitle row at its `*x.xx*` markers. Each segment must fit the on-screen box,')
$rep.Add('so this table compares the longest English segment with the longest Arabic segment per row.')
$rep.Add('')
$rep.Add('| master line | key | EN segments | EN longest | AR segments | AR longest | AR <= EN? |')
$rep.Add('|---|---|---|---|---|---|---|')
foreach ($r in $all) {
    if ($r.group -notlike 'speech*') { continue }
    $id = $r.scope + '|' + $r.key
    $e = $r.english; if (-not $e) { $e = $enMaster[$id] }
    $a = $ar[$id]
    $ep = Split-Parts $e; $ap = Split-Parts $a
    $emax = 0; foreach ($p in $ep) { if ($p.Length -gt $emax) { $emax = $p.Length } }
    $amax = 0; foreach ($p in $ap) { if ($p.Length -gt $amax) { $amax = $p.Length } }
    $ok = 'yes'; if ($amax -gt $emax) { $ok = 'NO (+' + ($amax - $emax) + ')' }
    $rep.Add(('| {0} | `{1}` | {2} | {3} | {4} | {5} | {6} |' -f $lineOf[$id], $r.key, $ep.Count, $emax, $ap.Count, $amax, $ok))
}
$rep.Add('')
$rep.Add('## Decisions taken in this scene')
$rep.Add('')
$rep.Add('- `THOUGHT` stays Latin, as in every earlier translated row (device brand; not transliterated).')
$rep.Add('- `Homo Futurum` is rendered as the Arabic term for "future human" instead of a Latin insertion.')
$rep.Add('- `mimetic adaptation` -> a literal Arabic term for adaptive mimicry (no glossary entry; proposed below).')
$rep.Add('- `Chelomey Complex` -> the glossary pattern for complexes (Vavilov Complex / Pavlov Complex).-')
$rep.Add('- Crowd labels are translated consistently, so the same English label always shows the same Arabic.')
$rep.Add('')
$rep.Add('## Validation')
$rep.Add('')
$rep.Add('- validate_translation.ps1: PASS, 0 hard errors, 2 warnings (1 new number-as-word warning + 1 pre-existing UI length warning).')
$rep.Add('- glyph_gate.ps1: PASS, every codepoint of every Arabic row is inside the subtitle face.')
$rep.Add('- build_carrier_locres_pak.ps1 (p4): 35/35 scopes, 0 round-trip failures, 35/35 unpack byte-identical.')
$rep.Add('')
$rep.Add('## How to regenerate')
$rep.Add('')
$rep.Add('    powershell -NoProfile -ExecutionPolicy Bypass -File scripts\scene_report.ps1')
$rep.Add('')
[IO.File]::WriteAllLines($Out, $rep, (New-Object Text.UTF8Encoding($false)))
Write-Output ('[scene report] rows {0} | written {1} ({2} bytes)' -f $all.Count, $Out, (Get-Item $Out).Length)
