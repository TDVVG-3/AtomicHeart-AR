param(
    [string]$StatusPath = 'build\c6\writeback_exact_status.tsv',
    [string]$OutTsv = 'build\c6\diff_verify.tsv',
    [string]$BadTxt = 'build\c6\diff_bad.txt'
)
$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'

function Read-TsvRaw([string]$path) {
    $lines = [IO.File]::ReadAllLines($path, [Text.Encoding]::UTF8)
    $head = $lines[0] -split "`t"
    $rows = New-Object System.Collections.Generic.List[object]
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Length -eq 0) { continue }
        $c = $lines[$i] -split "`t"
        $o = [ordered]@{}
        for ($j = 0; $j -lt $head.Count; $j++) { $o[$head[$j]] = if ($j -lt $c.Count) { $c[$j] } else { '' } }
        $rows.Add([pscustomobject]$o)
    }
    return $rows
}

$scan = Read-TsvRaw (Join-Path $repo 'reports\dialogue_st_counts.tsv')
$pakByAsset = @{}
foreach ($s in $scan) { $pakByAsset[$s.path] = $s.pak }

$statusLines = [IO.File]::ReadAllLines((Join-Path $repo $StatusPath), [Text.Encoding]::UTF8)
$latest = [ordered]@{}
for ($i = 1; $i -lt $statusLines.Count; $i++) {
    $c = $statusLines[$i] -split "`t"
    if ($c.Count -lt 3) { continue }
    $latest[$c[1]] = [pscustomobject]@{ idx = $c[0]; asset = $c[1]; status = $c[2]; changed = [int]$c[3]; mapRows = [int]$c[4]; missing = [int]$c[5] }
}

$volatile = @('SerialSize','SerialOffset','ScriptSerializationStartOffset','ScriptSerializationEndOffset')
$script:bad = New-Object System.Collections.Generic.List[string]
$script:changedTotal = 0
$assetResults = New-Object System.Collections.Generic.List[string]
$assetResults.Add("idx`tasset`tstatus`tchanged`tmapRows`tsemantic`tallowed`tbad`tmissing")

function Walk($a, $b, [string]$path, [string]$asset) {
    if ($null -eq $a -and $null -eq $b) { return }
    if ($null -eq $a -or $null -eq $b) {
        $script:bad.Add($asset + " :: " + $path + " :: null mismatch")
        return
    }
    if ($a -is [string] -or $b -is [string] -or $a -is [ValueType] -or $b -is [ValueType]) {
        if ([string]$a -ne [string]$b) {
            $script:changedTotal++
            $allowed = $path -match '\.CultureInvariantString$' -or $path -match '\.Table\.Value\[\d+\]\[\d+\]$'
            if (-not $allowed) { $script:bad.Add($asset + " :: " + $path) }
        }
        return
    }
    if ($a -is [System.Collections.IList] -and $b -is [System.Collections.IList]) {
        if ($a.Count -ne $b.Count) { $script:bad.Add($asset + " :: " + $path + " :: count " + $a.Count + " => " + $b.Count); return }
        for ($i = 0; $i -lt $a.Count; $i++) { Walk $a[$i] $b[$i] ($path + '[' + $i + ']') $asset }
        return
    }
    $ap = @($a.PSObject.Properties)
    $bp = @($b.PSObject.Properties)
    $an = @($ap | ForEach-Object { $_.Name })
    $bn = @($bp | ForEach-Object { $_.Name })
    if (($an -join '|') -ne ($bn -join '|')) { $script:bad.Add($asset + " :: " + $path + " :: property set"); return }
    foreach ($p in $ap) {
        if ($volatile -contains $p.Name) { continue }
        Walk $p.Value ($b.PSObject.Properties[$p.Name].Value) ($path + '.' + $p.Name) $asset
    }
}

$ok = 0; $fail = 0
foreach ($k in $latest.Keys) {
    $r = $latest[$k]
    if ($r.status -ne 'OK') { $fail++; continue }
    $pak = $pakByAsset[$r.asset]
    $rel = ($r.asset -replace '/', '\')
    $oldJson = Join-Path $repo ('build\c6\json\' + $pak + '\' + $rel + '.json')
    $newJson = Join-Path $repo ('build\c6\json_out\' + $pak + '\' + $rel + '.json')
    if (-not (Test-Path $oldJson)) { $script:bad.Add($r.asset + ' :: missing old json'); $fail++; continue }
    if (-not (Test-Path $newJson)) { $script:bad.Add($r.asset + ' :: missing new json'); $fail++; continue }
    $before = [IO.File]::ReadAllText($oldJson, [Text.Encoding]::UTF8) | ConvertFrom-Json
    $after = [IO.File]::ReadAllText($newJson, [Text.Encoding]::UTF8) | ConvertFrom-Json
    $startBad = $script:bad.Count
    $startChanged = $script:changedTotal
    Walk $before $after 'root' $r.asset
    $sem = $script:changedTotal - $startChanged
    $badDelta = $script:bad.Count - $startBad
    $assetResults.Add(($r.idx + "`t" + $r.asset + "`tOK`t" + $r.changed + "`t" + $r.mapRows + "`t" + $sem + "`t" + ($sem - $badDelta) + "`t" + $badDelta + "`t" + $r.missing))
    $ok++
}
[IO.File]::WriteAllLines((Join-Path $repo $OutTsv), $assetResults, (New-Object Text.UTF8Encoding($false)))
[IO.File]::WriteAllLines((Join-Path $repo $BadTxt), $script:bad, (New-Object Text.UTF8Encoding($false)))
Write-Output ('assets ok ' + $ok + ' fail ' + $fail + ' bad leaves ' + $script:bad.Count + ' changed total ' + $script:changedTotal)
