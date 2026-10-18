<#
.SYNOPSIS
  Splices the 40-row AR/EN review sample (reports/review_sample.md, block format) into a target
  markdown file as a table, between the marker pair:
      <!-- BEGIN REVIEW SAMPLE -->  ...  <!-- END REVIEW SAMPLE -->

.DESCRIPTION
  Keeps HANDOFF.md's review table consistent with reports/review_sample.md without hand-copying
  Arabic text. Any '|' inside a cell is escaped as '\|'. ASCII logic only (KI-021): the Arabic
  comes from the UTF-8 sample file, never from this script.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [string]$Sample = '',
    [string]$Target = '',
    [string]$BeginMarker = '<!-- BEGIN REVIEW SAMPLE -->',
    [string]$EndMarker = '<!-- END REVIEW SAMPLE -->'
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

if (-not $Sample) { $Sample = Join-Path $RepoRoot 'reports\review_sample.md' }
if (-not $Target) { $Target = Join-Path $RepoRoot 'HANDOFF.md' }
$utf8 = [Text.Encoding]::UTF8

function Esc([string]$s) { return ($s -replace '\|', '\|') }

$lines = [IO.File]::ReadAllLines($Sample, $utf8)
$rows = New-Object System.Collections.Generic.List[object]
$cur = $null
for ($i = 0; $i -lt $lines.Count; $i++) {
    $ln = $lines[$i]
    if ($ln -match '^###\s+(\d+)\.\s+\[(.+?)\]\s+(\S+)') {
        if ($cur) { $rows.Add($cur) }
        $cur = [ordered]@{ n = $Matches[1]; scope = $Matches[2]; cat = $Matches[3]; why = ''; key = ''; ar = ''; en = '' }
        continue
    }
    if (-not $cur) { continue }
    if ($ln -match '^reason:\s*(.+)$') {
        $meta = $Matches[1]
        $parts = $meta -split '\s*\|\s*'
        if ($parts.Count -gt 0) { $cur.why = $parts[0] }
        foreach ($p in $parts) {
            if ($p -match '^(\S+):\s*(.*)$') {
                $k = $Matches[1]; $v = $Matches[2]
                if ($k -eq 'reason') { $cur.why = $v }
                elseif ($k -eq 'key') { $cur.key = $v }
            }
        }
        continue
    }
    if ($ln -match '^AR:\s*(.*)$') { $cur.ar = $Matches[1]; continue }
    if ($ln -match '^EN:\s*(.*)$') { $cur.en = $Matches[1]; continue }
}
if ($cur) { $rows.Add($cur) }

$table = New-Object System.Collections.Generic.List[string]
$table.Add('| # | scope | cat | why | key | Arabic (what the player sees) | English source |')
$table.Add('|---|---|---|---|---|---|---|')
foreach ($r in $rows) {
    $table.Add(('| {0} | {1} | {2} | {3} | `{4}` | {5} | {6} |' -f $r.n, (Esc $r.scope), (Esc $r.cat), (Esc $r.why), (Esc $r.key), (Esc $r.ar), (Esc $r.en)))
}

# NOTE: never name the line array '$target': PowerShell is case-insensitive, so it would be the
# [string]$Target parameter and the array would be coerced into one space-joined string.
$targetLines = [IO.File]::ReadAllLines($Target, $utf8)
$beginIdx = [Array]::IndexOf($targetLines, $BeginMarker)
$endIdx = [Array]::IndexOf($targetLines, $EndMarker)
if ($beginIdx -lt 0 -or $endIdx -le $beginIdx) {
    throw ('review-sample markers not found in ' + $Target + ' (begin ' + $beginIdx + ', end ' + $endIdx + ')')
}
$out = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -lt $targetLines.Count; $i++) {
    if ($i -eq $beginIdx) {
        $out.Add($targetLines[$i])
        $out.Add('')
        foreach ($t in $table) { $out.Add($t) }
        $out.Add('')
        continue
    }
    if ($i -gt $beginIdx -and $i -lt $endIdx) { continue }   # drop the previous sample only
    $out.Add($targetLines[$i])
}
[IO.File]::WriteAllLines($Target, $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('[splice] sample rows: {0} | table lines: {1} -> {2} ({3} bytes)' -f $rows.Count, $table.Count, $Target, (Get-Item $Target).Length)
