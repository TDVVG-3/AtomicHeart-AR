$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$repo = 'C:\AtomicHeart-AR'
$repak = Join-Path $repo 'tools\bin\repak\repak.exe'
$tool = Join-Path $repo 'tools\bin\uasettool\uasettool.exe'
$cand = Join-Path $repo 'build\p4\item_asset_candidates.tsv'
$paksDir = 'C:\Program Files (x86)\Steam\steamapps\common\Atomic Heart\AtomicHeart\Content\Paks'
$srcRoot = Join-Path $repo 'build\p4\item_assets'
$masterPath = Join-Path $repo 'localization\master\atomic-heart-ar.tsv'

# Only item definition assets (DA_Item*, DA_Consumable*, DA_Cassette*) and the upgrade text table.
$wanted = @()
foreach ($line in [IO.File]::ReadAllLines($cand, [Text.Encoding]::UTF8)) {
    if (-not $line.Trim()) { continue }
    $f = $line -split "`t"
    if ($f.Count -lt 2) { continue }
    $pak = $f[0]; $entry = $f[1]
    if ($entry -notmatch '^AtomicHeart/Content/.+\.uasset$') { continue }
    if ($entry -notmatch '/(DA_Item[^/]*|DA_Consumable[^/]*|DA_Cassette[^/]*|DA_UpgradesTexts)\.uasset$') { continue }
    $wanted += [pscustomobject]@{ Pak = $pak; Entry = $entry }
}
Write-Host ("[probe] item definition assets: " + $wanted.Count)

if (Test-Path $srcRoot) { Remove-Item $srcRoot -Recurse -Force }
New-Item -ItemType Directory -Force -Path $srcRoot | Out-Null
$dumpRows = New-Object System.Collections.Generic.List[string]
$dumpRows.Add("pak`tentry`tname_key`tline`tscope`tenglish`tarabic`tcategory`tnotes")

# master key -> rows
$master = @{}
$mlines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $mlines.Count; $i++) {
    if (-not $mlines[$i].Trim()) { continue }
    $mf = $mlines[$i] -split "`t"
    if ($mf.Count -ne 13) { continue }
    $k = $mf[4]
    if (-not $master.ContainsKey($k)) { $master[$k] = New-Object System.Collections.Generic.List[object] }
    $scope = 'other'; if ($mf[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $master[$k].Add([pscustomobject]@{ line = $i + 1; scope = $scope; english = $mf[5]; arabic = $mf[6]; category = $mf[9]; notes = $mf[11] })
}

$ok = 0; $fail = 0; $nameRows = 0
foreach ($w in $wanted) {
    $pakPath = Join-Path $paksDir $w.Pak
    if (-not (Test-Path $pakPath)) { $fail++; continue }
    $safePak = $w.Pak -replace '\.pak$', ''
    $rel = $w.Entry -replace '/', '\'
    $assetPath = Join-Path (Join-Path $srcRoot $safePak) $rel
    $expPath = $assetPath -replace '\.uasset$', '.uexp'
    New-Item -ItemType Directory -Force -Path (Split-Path $assetPath -Parent) | Out-Null
    cmd /c ('"' + $repak + '" get "' + $pakPath + '" "' + $w.Entry + '" > "' + $assetPath + '" 2>nul') | Out-Null
    $expEntry = $w.Entry -replace '\.uasset$', '.uexp'
    cmd /c ('"' + $repak + '" get "' + $pakPath + '" "' + $expEntry + '" > "' + $expPath + '" 2>nul') | Out-Null
    if (-not (Test-Path $assetPath) -or (Get-Item $assetPath).Length -eq 0) { $fail++; continue }
    $jsonPath = $assetPath + '.json'
    & $tool dump $assetPath $jsonPath 2>$null | Out-Null
    if (-not (Test-Path $jsonPath)) { $fail++; continue }
    $ok++
    try { $j = Get-Content $jsonPath -Raw | ConvertFrom-Json } catch { continue }
    foreach ($e in @($j.Exports)) {
        if (-not $e.Data) { continue }
        foreach ($p in @($e.Data)) {
            if ($p.Name -notin @('Name','DisplayName','ItemName','Title')) { continue }
            $v = $p.Value
            if ($v -isnot [string]) { continue }
            if ($v -notmatch '^[0-9A-Fa-f]{32}$') { continue }
            $nameRows++
            $key = '/' + $v
            if ($master.ContainsKey($key)) {
                foreach ($mr in $master[$key]) {
                    $dumpRows.Add(($w.Pak + "`t" + $w.Entry + "`t" + $key + "`t" + $mr.line + "`t" + $mr.scope + "`t" + $mr.english + "`t" + $mr.arabic + "`t" + $mr.category + "`t" + $mr.notes))
                }
            } else {
                $dumpRows.Add(($w.Pak + "`t" + $w.Entry + "`t" + $key + "`t`t`t`t`t`tNOT-IN-MASTER"))
            }
        }
    }
}
$out = Join-Path $repo 'build\p4\item_name_keys.tsv'
[IO.File]::WriteAllLines($out, $dumpRows, (New-Object Text.UTF8Encoding($false)))
Write-Host ("[probe] dumped: {0} | failed: {1} | name keys: {2} -> {3}" -f $ok, $fail, $nameRows, $out)
