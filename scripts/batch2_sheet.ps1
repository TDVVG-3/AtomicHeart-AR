<#
.SYNOPSIS
  Builds one authoring sheet for a batch-2 chunk (DEC-037 contract).

.DESCRIPTION
  Input : localization/working/batch2/plan_unique.tsv        (frozen work order)
          localization/extracted/ru_csv/<Scope>.csv          (ru-RU reference, key level)
          localization/master/atomic-heart-ar.tsv            (existing Arabic, TM hint)
  Output: localization/working/batch2/sheet_<nnnn>.tsv

  Columns: id <TAB> scope <TAB> category <TAB> english <TAB> ru <TAB> tm
    ru = ru-RU text of the SAME key ("-" when the scope or key has no Russian)
    tm = Arabic already shipped for the SAME English string ("-" when none)

  The ru files mix locres keys ("/HASH") and readable string-table keys
  ("NTD_StringTable/row"), both are indexed. Values may be quoted and may contain
  embedded newlines, so the reader is a real (small) CSV record parser.

  ASCII-only script; every non-ASCII string comes from a UTF-8 data file.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [Parameter(Mandatory = $true)][string]$ChunkId,
    [Parameter(Mandatory = $true)][string]$StartId,
    [int]$Count = 300
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$utf8  = New-Object Text.UTF8Encoding($false)
$work  = Join-Path $RepoRoot 'localization\working\batch2'
$plan  = Join-Path $work 'plan_unique.tsv'
$ruDir = Join-Path $RepoRoot 'localization\extracted\ru_csv'
$master = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$outP  = Join-Path $work ('sheet_' + $ChunkId + '.tsv')

# key -> value for the first two columns of a "key,source,target" CSV
function Read-RuMap([string]$path) {
    $map = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
    $txt = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
    $len = $txt.Length
    $i = 0
    while ($i -lt $len) {
        while ($i -lt $len -and ($txt[$i] -eq "`r" -or $txt[$i] -eq "`n")) { $i++ }
        if ($i -ge $len) { break }
        $start = $i
        while ($i -lt $len -and $txt[$i] -ne ',' -and $txt[$i] -ne "`r" -and $txt[$i] -ne "`n") { $i++ }
        $key = $txt.Substring($start, $i - $start)
        if ($key -eq 'key' -or $key -eq '') {
            while ($i -lt $len -and $txt[$i] -ne "`n") { $i++ }
            continue
        }
        if ($i -ge $len -or $txt[$i] -ne ',') { continue }
        $i++
        $sb = New-Object Text.StringBuilder
        if ($i -lt $len -and $txt[$i] -eq '"') {
            $i++
            while ($i -lt $len) {
                if ($txt[$i] -eq '"') {
                    if ((($i + 1) -lt $len) -and ($txt[$i + 1] -eq '"')) { [void]$sb.Append('"'); $i += 2; continue }
                    $i++
                    break
                }
                [void]$sb.Append($txt[$i]); $i++
            }
            while ($i -lt $len -and $txt[$i] -ne "`r" -and $txt[$i] -ne "`n") { $i++ }
            $val = $sb.ToString()
        } else {
            while ($i -lt $len -and $txt[$i] -ne "`r" -and $txt[$i] -ne "`n") { [void]$sb.Append($txt[$i]); $i++ }
            $val = $sb.ToString()
            if ($val.EndsWith(',')) { $val = $val.Substring(0, $val.Length - 1) }
        }
        if (-not $map.ContainsKey($key)) { $map[$key] = $val }
    }
    return $map
}

$pl = [IO.File]::ReadAllLines($plan, [Text.Encoding]::UTF8)

# TM hint: exact English -> first Arabic shipped for that English
$tm = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
$ml = [IO.File]::ReadAllLines($master, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $ml.Count; $i++) {
    $f = $ml[$i] -split "`t"
    if ($f.Count -lt 7) { continue }
    if (-not $f[6]) { continue }
    if (-not $tm.ContainsKey($f[5])) { $tm[$f[5]] = $f[6] }
}

# locate the range
$startIdx = -1
for ($i = 1; $i -lt $pl.Count; $i++) {
    $f = $pl[$i] -split "`t"
    if ($f.Count -ge 2 -and $f[0] -ceq $StartId) { $startIdx = $i; break }
}
if ($startIdx -lt 0) { throw ('StartId not found in plan: ' + $StartId) }
$endIdx = [Math]::Min($startIdx + $Count - 1, $pl.Count - 1)

$rows = New-Object System.Collections.Generic.List[object]
$scopes = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
for ($i = $startIdx; $i -le $endIdx; $i++) {
    $f = $pl[$i] -split "`t"
    if ($f.Count -lt 6 -or -not $f[0]) { continue }
    $rows.Add([pscustomobject]@{ id = $f[0]; scope = $f[3]; key = $f[4]; cat = $f[5]; en = $f[1] })
    [void]$scopes.Add($f[3])
}

$ruCache = New-Object 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.Dictionary[string,string]]' ([StringComparer]::Ordinal)
foreach ($s in $scopes) {
    $p = Join-Path $ruDir ($s + '.csv')
    if (Test-Path $p) { $ruCache[$s] = Read-RuMap $p }
}

$sb2 = New-Object Text.StringBuilder
[void]$sb2.AppendLine("id`tscope`tcategory`tenglish`tru`ttm")
$nRu = 0; $nTm = 0
foreach ($r in $rows) {
    $ru = '-'; $tmv = '-'
    $d = $null
    if ($ruCache.ContainsKey($r.scope)) { $d = $ruCache[$r.scope] }
    if ($d -and $d.ContainsKey($r.key) -and $d[$r.key]) { $ru = $d[$r.key]; $nRu++ }
    if ($tm.ContainsKey($r.en) -and $tm[$r.en]) { $tmv = $tm[$r.en]; $nTm++ }
    $en = $r.en -replace "`r", ' ' -replace "`n", ' '
    $ru2 = $ru -replace "`r", ' ' -replace "`n", ' '
    $tm2 = $tmv -replace "`r", ' ' -replace "`n", ' '
    [void]$sb2.AppendLine($r.id + "`t" + $r.scope + "`t" + $r.cat + "`t" + $en + "`t" + $ru2 + "`t" + $tm2)
}
[IO.File]::WriteAllText($outP, $sb2.ToString(), $utf8)
Write-Output ('[sheet ' + $ChunkId + '] ids ' + $rows.Count + ' (' + $rows[0].id + ' .. ' + $rows[$rows.Count - 1].id + ') ru ' + $nRu + ' tm ' + $nTm + ' -> ' + $outP)
