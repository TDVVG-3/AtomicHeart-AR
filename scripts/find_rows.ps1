<#
.SYNOPSIS
  Finds rows in the master whose English source contains any pattern from a UTF-8 pattern file,
  and prints full detail (scope, key, category, status, notes, lengths, marker counts, full text).

.DESCRIPTION
  Read-only. Used to locate a scene before translating it. Patterns live in a UTF-8 file so that
  non-ASCII searches are possible without embedding literals in a script (KI-021).
  Optionally writes the full matches to a report file.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [Parameter(Mandatory = $true)][string]$Patterns,
    [string]$Out = '',
    [switch]$ShowFull
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$master = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$utf8 = [Text.Encoding]::UTF8
$pats = @([IO.File]::ReadAllLines($Patterns, $utf8) | Where-Object { $_.Trim() })
$lines = [IO.File]::ReadAllLines($master, $utf8)

$report = New-Object System.Collections.Generic.List[string]
$report.Add('# Scene search')
$report.Add('')
$report.Add(('Patterns: {0}' -f ($pats -join ' ; ')))
$report.Add('')

$total = 0
foreach ($p in $pats) {
    $hits = New-Object System.Collections.Generic.List[object]
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if (-not $lines[$i].Trim()) { continue }
        $f = $lines[$i] -split "`t"
        if ($f.Count -ne 13) { continue }
        if ($f[5].Contains($p)) {
            $scope = 'other'; if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
            $hits.Add([pscustomobject]@{ line = $i + 1; scope = $scope; key = $f[4]; cat = $f[9]; status = $f[10]; notes = $f[11]; len = $f[5].Length; en = $f[5]; ar = $f[6] })
        }
    }
    $total += $hits.Count
    Write-Output ('=== pattern: ' + $p + '  ->  ' + $hits.Count + ' row(s) ===')
    foreach ($x in $hits) {
        Write-Output ('  [scope {0}] key {1}' -f $x.scope, $x.key)
        Write-Output ('    cat={0} status={1} notes={2} line={3} enLen={4} arLen={5}' -f $x.cat, $x.status, $x.notes, $x.line, $x.len, $x.ar.Length)
        Write-Output ('    EN: ' + $x.en)
        if ($x.ar.Trim()) { Write-Output ('    AR: ' + $x.ar) }
    }
    $report.Add(('## pattern: {0} - {1} row(s)' -f $p, $hits.Count))
    $report.Add('')
    foreach ($x in $hits) {
        $report.Add(('### [scope {0}] {1}' -f $x.scope, $x.key))
        $report.Add(('cat={0} | status={1} | notes={2} | master line={3} | enLen={4} | arLen={5}' -f $x.cat, $x.status, $x.notes, $x.line, $x.len, $x.ar.Length))
        $report.Add('')
        $report.Add(('EN: ' + $x.en))
        $report.Add('')
        if ($x.ar.Trim()) { $report.Add(('AR: ' + $x.ar)); $report.Add('') }
    }
    Write-Output ''
}
Write-Output ('TOTAL matching rows: ' + $total)
if ($Out) {
    [IO.File]::WriteAllLines($Out, $report, (New-Object Text.UTF8Encoding($false)))
    Write-Output ('report: ' + $Out)
}
