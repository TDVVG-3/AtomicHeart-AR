<#
.SYNOPSIS
  Applies a batch-2 chunk file to the master (DRAFT) and refreshes the union TM.

.DESCRIPTION
  Input : localization/working/batch2/chunk_<id>.tsv   (english<TAB>arabic<TAB>note)
  Rules :
    - exact, case-sensitive English match (ordinal dictionary, KI-023)
    - only rows whose Arabic cell is EMPTY are filled
    - an existing non-empty different Arabic is reported as a CONFLICT and never overwritten
    - applied rows: Arabic, Status = DRAFT, Notes = the chunk note
  Writes localization/working/batch2/state.tsv so progress is resumable, and refreshes
  localization/working/tm.tsv with every applied pair.
  ASCII-only script; all Arabic lives in the UTF-8 chunk file.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [Parameter(Mandatory = $true)][string]$ChunkId
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$work      = Join-Path $RepoRoot 'localization\working\batch2'
$masterP   = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$tmP       = Join-Path $RepoRoot 'localization\working\tm.tsv'
$chunkP    = Join-Path $work ('chunk_' + $ChunkId + '.tsv')
$stateP    = Join-Path $work 'state.tsv'
$utf8      = New-Object Text.UTF8Encoding($false)

$ar = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
$nt = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
$cl = [IO.File]::ReadAllLines($chunkP, [Text.Encoding]::UTF8)
# chunk_<id>.tsv has NO header line: every line is data (start at 0, cycle 015 fix)
for ($i = 0; $i -lt $cl.Count; $i++) {
    if (-not $cl[$i].Trim()) { continue }
    $f = $cl[$i] -split "`t"
    if ($f.Count -lt 2) { continue }
    if (-not $ar.ContainsKey($f[0])) { $ar[$f[0]] = $f[1] }
    $nt[$f[0]] = ''
    if ($f.Count -ge 3) { $nt[$f[0]] = $f[2] }
}
Write-Output ('[chunk ' + $ChunkId + '] unique english entries: ' + $ar.Count)

$m = [IO.File]::ReadAllLines($masterP, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$out.Add($m[0])
$filled = 0; $same = 0; $conflicts = New-Object System.Collections.Generic.List[string]
$touched = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
for ($i = 1; $i -lt $m.Count; $i++) {
    if (-not $m[$i].Trim()) { $out.Add($m[$i]); continue }
    $f = $m[$i] -split "`t"
    if ($f.Count -ne 13) { $out.Add($m[$i]); continue }
    $en = $f[5]
    if (-not $ar.ContainsKey($en)) { $out.Add($m[$i]); continue }
    [void]$touched.Add($en)
    if ($f[6].Trim()) {
        if ($f[6] -ceq $ar[$en]) { $same++ } else { $conflicts.Add(('EN=[' + $en + '] master=[' + $f[6] + '] chunk=[' + $ar[$en] + ']')) }
        $out.Add($m[$i]); continue
    }
    $f[6] = $ar[$en]; $f[10] = 'DRAFT'; $f[11] = $nt[$en]
    $out.Add(($f -join "`t"))
    $filled++
}
$never = New-Object System.Collections.Generic.List[string]
foreach ($k in $ar.Keys) { if (-not $touched.Contains($k)) { $never.Add($k) } }
Write-Output ('[apply] rows filled: {0} | already identical: {1} | conflicts: {2} | chunk strings with no master row: {3}' -f $filled, $same, $conflicts.Count, $never.Count)
foreach ($c in $conflicts) { Write-Output ('   CONFLICT ' + $c) }
foreach ($n in ($never | Select-Object -First 5)) { Write-Output ('   NO-ROW   [' + $n + ']') }

if ($filled -eq 0 -and $never.Count -gt 0) { throw 'nothing applicable' }
[IO.File]::WriteAllLines($masterP, $out, $utf8)
Write-Output ('[master] written: ' + $masterP)

# union TM
$tm = [IO.File]::ReadAllLines($tmP, [Text.Encoding]::UTF8)
$tmo = New-Object System.Collections.Generic.List[string]
foreach ($l in $tm) { $tmo.Add($l) }
$have = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
for ($i = 1; $i -lt $tm.Count; $i++) { $tf = $tm[$i] -split "`t"; if ($tf.Count -ge 2) { $have[$tf[0]] = $tf[1] } }
$added = 0; $tconf = 0
foreach ($k in $ar.Keys) {
    if ($have.ContainsKey($k)) { if ($have[$k] -cne $ar[$k]) { $tconf++; Write-Output ('   TM CONFLICT: ' + $k) } }
    else { $tmo.Add(($k + "`t" + $ar[$k] + "`t" + ('batch2-' + $ChunkId))); [void]$have.Add($k, $ar[$k]); $added++ }
}
[IO.File]::WriteAllLines($tmP, $tmo, $utf8)
Write-Output ('[tm] entries {0} -> {1} | appended {2} | conflicts {3}' -f ($tm.Count - 1), ($tmo.Count - 1), $added, $tconf)

# resumable state
$st = New-Object System.Collections.Generic.List[string]
if (Test-Path $stateP) { foreach ($l in [IO.File]::ReadAllLines($stateP, [Text.Encoding]::UTF8)) { $st.Add($l) } }
else { $st.Add(('chunk' + "`t" + 'rowsFilled' + "`t" + 'utc')) }
$st.Add((('c' + $ChunkId), $filled, ([DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ'))) -join "`t")
[IO.File]::WriteAllLines($stateP, $st, $utf8)

$written = [IO.File]::ReadAllLines($masterP, [Text.Encoding]::UTF8)
$total = 0; $withAr = 0
for ($i = 1; $i -lt $written.Count; $i++) { $f = $written[$i] -split "`t"; if ($f.Count -ne 13) { continue }; $total++; if ($f[6].Trim()) { $withAr++ } }
Write-Output ('[coverage] rows with Arabic: {0} of {1} ({2}%)' -f $withAr, $total, [Math]::Round(100.0 * $withAr / $total, 2))
