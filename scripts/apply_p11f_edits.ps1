# Apply the validated p11f page replacements to a master TSV.
# Only the exact page segment after the selected Arabic marker is replaced.
param(
    [Parameter(Mandatory=$true)][string]$BaseTsV,
    [Parameter(Mandatory=$true)][string]$OutTsV,
    [string]$EditsTsV = 'C:\AtomicHeart-AR\build\p4\p11f_applied.tsv',
    [string]$ReportPath = ''
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$TAB = [char]9
$rx = [regex]'\*([0-9]+(?:\.[0-9]+)?)(?:-([0-9]+(?:\.[0-9]+)?))?\*'
$edits = [IO.File]::ReadAllLines($EditsTsV, [Text.Encoding]::UTF8)
$byLine = @{}
foreach ($line in ($edits | Select-Object -Skip 1)) {
    if (-not $line.Trim()) { continue }
    $f = $line -split $TAB
    if ($f.Count -lt 10) { continue }
    $ln = [int]$f[0]
    if (-not $byLine.ContainsKey($ln)) { $byLine[$ln] = New-Object System.Collections.Generic.List[object] }
    $byLine[$ln].Add([pscustomobject]@{ Page = [int]$f[1]; Old = $f[8]; New = $f[9]; Status = $f[7] })
}

$base = [IO.File]::ReadAllLines($BaseTsV, [Text.Encoding]::UTF8)
$out = New-Object System.Collections.Generic.List[string]
$changedRows = 0; $changedPages = 0; $mismatch = 0
foreach ($line in $base) {
    $out.Add($line)
}
foreach ($ln in $byLine.Keys) {
    if ($ln -lt 1 -or $ln -gt $base.Count) { throw ('line out of range: ' + $ln) }
    $f = $base[$ln - 1] -split $TAB
    if ($f.Count -ne 13) { throw ('line ' + $ln + ' has ' + $f.Count + ' columns') }
    $ar = $f[6]
    $matches = $rx.Matches($ar)
    if ($matches.Count -eq 0) { throw ('line ' + $ln + ' has no Arabic markers') }
    $pages = @($byLine[$ln] | Sort-Object Page -Descending)
    foreach ($edit in $pages) {
        if ($edit.Page -lt 1 -or $edit.Page -gt $matches.Count) { throw ('line ' + $ln + ' page ' + $edit.Page + ' out of range') }
        $m = $matches[$edit.Page - 1]
        $start = $m.Index + $m.Length
        $end = if ($edit.Page -lt $matches.Count) { $matches[$edit.Page].Index } else { $ar.Length }
        $oldSegment = $ar.Substring($start, $end - $start)
        if ($oldSegment -cne $edit.Old) {
            $mismatch++
            Write-Output ('SEGMENT MISMATCH L' + $ln + ' p' + $edit.Page)
            Write-Output ('  expected: [' + $edit.Old + ']')
            Write-Output ('  actual  : [' + $oldSegment + ']')
            continue
        }
        $ar = $ar.Substring(0, $start) + $edit.New + $ar.Substring($end)
        $changedPages++
    }
    $f[6] = $ar
    $out[$ln - 1] = ($f -join $TAB)
    $changedRows++
}
[IO.File]::WriteAllLines($OutTsV, $out, (New-Object Text.UTF8Encoding($false)))

if ($ReportPath) {
    $r = New-Object System.Collections.Generic.List[string]
    $r.Add('# p11f variant build')
    $r.Add('')
    $r.Add(('Generated: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')))
    $r.Add('')
    $r.Add(('Base: `' + $BaseTsV + '`'))
    $r.Add(('Output: `' + $OutTsV + '`'))
    $r.Add(('Changed rows: {0} | changed pages: {1} | segment mismatches: {2}' -f $changedRows, $changedPages, $mismatch))
    $r.Add('')
    $r.Add('Only the selected page segment after the Nth Arabic marker is replaced. All other columns, all markers, and all non-target page segments are copied byte-for-byte from the base master.')
    [IO.File]::WriteAllLines($ReportPath, $r, (New-Object Text.UTF8Encoding($false)))
}
Write-Output ('p11f apply: rows={0} pages={1} mismatches={2}' -f $changedRows, $changedPages, $mismatch)
if ($mismatch -gt 0) { exit 1 }
