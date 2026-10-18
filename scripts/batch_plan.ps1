<#
.SYNOPSIS
  Batch-1 planner (DEC-023 step 5, cumulative 25%): builds the ordered batch-1 row set
  (6,905 rows: NewP5 + Misc + PearTerminals + Academy_Dialogues + the first 460 rows of
  Chelomey_Dialogues), the unique-English worklist (U = 4,562 target), and ~300-string
  chunk files for translation.

.DESCRIPTION
  Reads : localization/master/atomic-heart-ar.tsv
  Writes: localization/working/batch1/rows.tsv        (idx, scope, key, english, category, status, arabic?)
          localization/working/batch1/unique.tsv      (english, occurrences, scope, key, category, en_len, done)
          localization/working/batch1/chunk_NN_en.tsv (english, scope, key, category, en_len)
          localization/working/batch1/batch_state.json (resumable progress)
  ASCII-only script (KI-021). No master writes here.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [int]$RowCutoff = 6905,
    [int]$ChunkSize = 300
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$work = Join-Path $RepoRoot 'localization\working\batch1'
New-Item -ItemType Directory -Force -Path $work | Out-Null
$utf8 = New-Object Text.UTF8Encoding($false)

# plan scope order (reports/translation_plan.md), only the scopes batch 1 touches
$order = @('NewP5', 'Misc', 'PearTerminals', 'Academy_Dialogues', 'Chelomey_Dialogues')

# --- read master, group by scope in file order
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$byScope = @{}
foreach ($s in $order) { $byScope[$s] = New-Object System.Collections.Generic.List[object] }
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { continue }
    $f = $mlines[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    $scope = 'other'
    if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    if (-not $byScope.ContainsKey($scope)) { continue }
    $byScope[$scope].Add([pscustomobject]@{ line = $i + 1; key = $f[4]; english = $f[5]; category = $f[9]; status = $f[10]; arabic = $f[6] })
}

# --- ordered batch-1 rows up to the cutoff
$rows = New-Object System.Collections.Generic.List[object]
foreach ($s in $order) {
    foreach ($r in $byScope[$s]) {
        if ($rows.Count -ge $RowCutoff) { break }
        $rows.Add([pscustomobject]@{ idx = $rows.Count + 1; scope = $s; key = $r.key; english = $r.english; category = $r.category; status = $r.status; arabic = $r.arabic; line = $r.line })
    }
    if ($rows.Count -ge $RowCutoff) { break }
}
Write-Output ('[rows] batch-1 rows: {0}' -f $rows.Count)
$perScope = @{}
foreach ($r in $rows) { if (-not $perScope.ContainsKey($r.scope)) { $perScope[$r.scope] = 0 }; $perScope[$r.scope]++ }
foreach ($s in $order) { Write-Output ('   {0,-22} {1}' -f $s, $perScope[$s]) }

# --- unique english in first-appearance order
$seen = New-Object 'System.Collections.Generic.HashSet[string]'
$unique = New-Object System.Collections.Generic.List[object]
foreach ($r in $rows) {
    if ($seen.Contains($r.english)) { continue }
    [void]$seen.Add($r.english)
    $unique.Add([pscustomobject]@{ english = $r.english; occurrences = 0; scope = $r.scope; key = $r.key; category = $r.category; en_len = $r.english.Length; done = $false; arabic = '' })
}
$idx = @{}
for ($i = 0; $i -lt $unique.Count; $i++) { $idx[$unique[$i].english] = $i }
foreach ($r in $rows) { $unique[$idx[$r.english]].occurrences++ }
foreach ($r in $rows) {
    if ($r.arabic.Trim()) { $unique[$idx[$r.english]].done = $true; $unique[$idx[$r.english]].arabic = $r.arabic }
}
$todo = @($unique | Where-Object { -not $_.done })
Write-Output ('[unique] unique strings in batch 1: {0} | already translated: {1} | to translate: {2}' -f $unique.Count, ($unique.Count - $todo.Count), $todo.Count)
$chars = 0; foreach ($u in $todo) { $chars += $u.en_len }
Write-Output ('[unique] characters of English to translate: {0}' -f $chars)

# --- write rows.tsv
$out = New-Object System.Collections.Generic.List[string]
$out.Add('idx' + "`t" + 'scope' + "`t" + 'key' + "`t" + 'category' + "`t" + 'status' + "`t" + 'en_len' + "`t" + 'english')
foreach ($r in $rows) {
    $rowline = $r.idx, $r.scope, $r.key, $r.category, $r.status, $r.english.Length, $r.english -join "`t"
    $out.Add($rowline)
}
[IO.File]::WriteAllLines((Join-Path $work 'rows.tsv'), $out, $utf8)

# --- write unique.tsv + chunk files (stable ids u0001.. so no English re-typing is needed)
for ($i = 0; $i -lt $unique.Count; $i++) { $unique[$i] | Add-Member -NotePropertyName id -NotePropertyValue ('u{0:D4}' -f ($i + 1)) -Force }
$uout = New-Object System.Collections.Generic.List[string]
$uout.Add('id' + "`t" + 'english' + "`t" + 'occurrences' + "`t" + 'scope' + "`t" + 'key' + "`t" + 'category' + "`t" + 'en_len' + "`t" + 'done')
foreach ($u in $unique) { $uout.Add(($u.id + "`t" + $u.english + "`t" + $u.occurrences + "`t" + $u.scope + "`t" + $u.key + "`t" + $u.category + "`t" + $u.en_len + "`t" + $(if ($u.done) { 'yes' } else { 'no' }))) }
[IO.File]::WriteAllLines((Join-Path $work 'unique.tsv'), $uout, $utf8)

$chunk = 0
$count = 0
$cout = New-Object System.Collections.Generic.List[string]
foreach ($u in $todo) {
    if ($count -eq 0) {
        $chunk++
        $cout = New-Object System.Collections.Generic.List[string]
        $cout.Add('id' + "`t" + 'english' + "`t" + 'scope' + "`t" + 'key' + "`t" + 'category' + "`t" + 'en_len')
    }
    $cout.Add($u.id + "`t" + $u.english + "`t" + $u.scope + "`t" + $u.key + "`t" + $u.category + "`t" + $u.en_len)
    $count++
    if ($count -ge $ChunkSize) {
        [IO.File]::WriteAllLines((Join-Path $work ('chunk_{0:D2}_en.tsv' -f $chunk)), $cout, $utf8)
        $count = 0
    }
}
if ($count -gt 0) { [IO.File]::WriteAllLines((Join-Path $work ('chunk_{0:D2}_en.tsv' -f $chunk)), $cout, $utf8) }
Write-Output ('[chunks] chunk files written: {0} (size {1})' -f $chunk, $ChunkSize)
$cats = @{}
foreach ($u in $todo) { if (-not $cats.ContainsKey($u.category)) { $cats[$u.category] = 0 }; $cats[$u.category]++ }
Write-Output '[categories to translate]'
foreach ($k in ($cats.Keys | Sort-Object)) { Write-Output ('   {0,-14} {1}' -f $k, $cats[$k]) }

# --- resumable state
$state = [ordered]@{
    generated_utc = (Get-Date).ToUniversalTime().ToString('o')
    row_cutoff = $RowCutoff
    rows = $rows.Count
    unique_total = $unique.Count
    unique_done = $unique.Count - $todo.Count
    unique_todo = $todo.Count
    unique_target_plan = 4562
    chunks = $chunk
    chunk_size = $ChunkSize
    scopes = $perScope
    english_chars_todo = $chars
}
($state | ConvertTo-Json -Depth 5) | Set-Content -Path (Join-Path $work 'batch_state.json') -Encoding UTF8
Write-Output ('[state] ' + (Join-Path $work 'batch_state.json'))
