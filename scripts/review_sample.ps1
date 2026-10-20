<#
.SYNOPSIS
  Builds the AR/EN review sample (DEC-023 step 10, cycle-015 stratified form).

.DESCRIPTION
  Cycle 015 requirement: a 40-row sample made of
    10 long dialogue rows   (dialogue/cutscene/Lore category, Arabic and English >= 150 chars)
    10 short UI labels      (category UI, Arabic <= 30 chars)
    10 tagged rows          (rich-text tag, placeholder, escape or timing marker in the Arabic)
    10 edge cases           (bracket labels, &Speaker& tags, \n escapes, timing markers)
  Every section is filled deterministically (SHA1 of scope|key|english, then take N);
  short sections are topped up from the same pools so the file always has 40 unique rows.
  Output: reports/review_sample.md  (Arabic first, English below)

  ASCII-only script; all text comes from the UTF-8 master.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [int]$PerSection = 10
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$outPath = Join-Path $RepoRoot 'reports\review_sample.md'

$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$rows = New-Object System.Collections.Generic.List[object]
$sha1 = [System.Security.Cryptography.SHA1]::Create()
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    if (-not $f[6].Trim()) { continue }
    $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $seedBytes = [Text.Encoding]::UTF8.GetBytes($scope + '|' + $f[4] + '|' + $f[5])
    $hashHex = -join ($sha1.ComputeHash($seedBytes) | ForEach-Object { $_.ToString('x2') })
    $ar = $f[6]
    $rows.Add([pscustomobject]@{
        line = $i + 1; id = $f[0]; scope = $scope; key = $f[4]; en = $f[5]; ar = $ar
        cat = $f[9]; notes = $f[11]; arlen = $ar.Length; hash = $hashHex
        tagged  = [bool]($ar -match '<[^>]+>|\{[^}]+\}|%[sdif]|\\n|\*[0-9]')
        edge    = [bool]($ar -match '&[A-Za-z]|\\n|\*[0-9]|^\[|\]')
        dialogue = [bool]($f[9] -match 'Subtitles|Lore|Cutscene|Dialogue')
    })
}

$chosen = New-Object System.Collections.Generic.List[object]
$seen = New-Object 'System.Collections.Generic.HashSet[string]'
function Add-Row($row, $reason) {
    if ($null -eq $row) { return $false }
    $id = $row.scope + [char]1 + $row.key + [char]1 + $row.en
    if ($seen.Contains($id)) { return $false }
    [void]$seen.Add($id)
    $chosen.Add([pscustomobject]@{
        reason = $reason; line = $row.line; scope = $row.scope; key = $row.key; cat = $row.cat
        en = $row.en; ar = $row.ar; notes = $row.notes
    })
    return $true
}

$longPool   = @($rows | Where-Object { $_.dialogue -and $_.arlen -ge 150 -and $_.en.Length -ge 150 } | Sort-Object hash)
$uiPool     = @($rows | Where-Object { $_.cat -eq 'UI' -and $_.arlen -le 30 } | Sort-Object hash)
$tagPool    = @($rows | Where-Object { $_.tagged } | Sort-Object hash)
$edgePool   = @($rows | Where-Object { $_.edge } | Sort-Object hash)
$spreadPool = @($rows | Sort-Object hash)

$sections = @(
    @{ name = 'Long dialogue'; pool = $longPool },
    @{ name = 'Short UI label'; pool = $uiPool },
    @{ name = 'Tagged / placeholder'; pool = $tagPool },
    @{ name = 'Edge case (bracket / speaker / escape / timing)'; pool = $edgePool }
)

$out = New-Object System.Collections.Generic.List[string]
$out.Add('# AR/EN review sample - cycle 015 (p10 carrier)')
$out.Add('')
$out.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$out.Add(('Rows with Arabic available: {0} | sample size: {1}' -f $rows.Count, ($PerSection * $sections.Count)))
$out.Add('')
$out.Add('Read each block as: Arabic (what the player sees) then the English source it came from.')

$n = 0
foreach ($s in $sections) {
    $out.Add('')
    $out.Add('## ' + $s.name)
    $taken = 0
    foreach ($r in $s.pool) {
        if ($taken -ge $PerSection) { break }
        if (Add-Row $r $s.name) { $taken++ }
    }
    foreach ($r in $spreadPool) {
        if ($taken -ge $PerSection) { break }
        if (Add-Row $r ($s.name + ' (top-up)')) { $taken++ }
    }
    $out.Add('')
    $out.Add(('rows in this section: {0}' -f $taken))
}

foreach ($c in $chosen) {
    $n++
    $out.Add('')
    $out.Add(('### {0}. [{1}] {2}' -f $n, $c.scope, $c.cat))
    $out.Add(('reason: {0} | line: {1} | key: {2} | notes: {3}' -f $c.reason, $c.line, $c.key, $c.notes))
    $out.Add('')
    $out.Add(('AR: {0}' -f $c.ar))
    $out.Add('')
    $out.Add(('EN: {0}' -f $c.en))
}

[IO.File]::WriteAllLines($outPath, $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('[sample] rows with Arabic {0} | sample {1} | written {2}' -f $rows.Count, $chosen.Count, $outPath)
foreach ($s in $sections) {
    $cnt = @($chosen | Where-Object { $_.reason -eq $s.name -or $_.reason -eq ($s.name + ' (top-up)') }).Count
    Write-Output ('  section: {0} -> {1}' -f $s.name, $cnt)
}
