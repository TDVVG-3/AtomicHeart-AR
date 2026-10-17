<#
.SYNOPSIS
  Phase 5: converts every en-US .locres to CSV (via UnrealLocres) and builds the
  master translation database skeleton (MASTER_PROMPT sections 10, 26).

.DESCRIPTION
  - Finds all en-US locres under localization/extracted.
  - Exports each to localization/generated/locres_csv/<Target>_en-US.csv.
  - Aggregates into localization/master/atomic-heart-ar.tsv with columns per
    section 10: ID, Container, File, Namespace, Key, SourceEnglish, Arabic,
    Context, Speaker, Category, Status, Notes, SourceHash.
  - ID = SHA1(namespace + "|" + key). Status = UNTRANSLATED. Arabic blank.
  - NEVER overwrites an existing non-empty master TSV's Arabic/Status content:
    if the file exists, the script aborts (translation work protection).

  Note on this build's format quirk: UnrealLocres reports namespace as empty and
  the "key" field as a slash-prefixed 32-hex id ("/6FE63907..."). We keep those
  exact strings as namespace="" and key as-is so the final locres rebuild stays
  byte-consistent. Never alter Namespace/Key (section 10).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'

$extractRoot = Join-Path $RepoRoot 'localization\extracted'
$csvRoot = Join-Path $RepoRoot 'localization\generated\locres_csv'
$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$ul = Join-Path $RepoRoot 'tools\bin\unreallocres\UnrealLocres.exe'

$existing = Get-ChildItem $extractRoot -Recurse -Filter '*.locres' |
    Where-Object { $_.FullName -match '\\(en-US|[a-z]{2})\\[^\\]+\.locres$' }
Write-Host ("[OK] {0} locres files" -f $existing.Count)

if (Test-Path $masterPath) {
    if ((Get-Item $masterPath).Length -gt 0) {
        throw "master TSV already exists and is non-empty: $masterPath (translation protection)"
    }
}
if (-not (Test-Path $csvRoot)) { New-Item -ItemType Directory -Force -Path $csvRoot | Out-Null }
$header = 'ID`tContainer`tFile`tNamespace`tKey`tSourceEnglish`tArabic`tContext`tSpeaker`tCategory`tStatus`tNotes`tSourceHash'
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add($header)
$perTarget = New-Object System.Collections.Generic.List[string]
$perTarget.Add('Target`tn-us-strings')

$sha1 = New-Object System.Security.Cryptography.SHA1Managed
$total = 0
foreach ($f in ($existing | Sort-Object FullName)) {
    $rel = $f.FullName.Substring($extractRoot.Length + 1).Replace('\', '/')
    if ($rel -match 'Localization/([^/]+)/') { $target = $Matches[1] } else { $target = 'UNKNOWN' }
    $culture = if ($rel -match '/([a-z]{2}-[A-Z]{2}|[a-z]{2})/[^/]+\.locres$') { $Matches[1] } else { '(native)' }
    if ($rel -match '^Engine/') { continue }  # engine locres recorded in manifest, not the master db

    $csvPath = Join-Path $csvRoot ("{0}-{1}.csv" -f $target, $culture)
    & $ul export -f csv -o $csvPath $f.FullName 2>$null | Out-Null
    if (-not (Test-Path $csvPath)) {
        Write-Host ("[WARN] no csv for {0}" -f $rel)
        continue
    }
    # NOTE: UnrealLocres csv has header 'key,source,target'; -Header replabels it,
    # so drop the physical first record (header-as-data) explicitly.
    $rows = @(Import-Csv -Path $csvPath -Header 'key','source','target' | Where-Object { $_.key -ne 'key' -and $_.key -notmatch '^/Key$' })
    $lines | Where-Object { $_ -ne $lines[0] } | Out-Null
    $n = $rows.Count
    $perTarget.Add(('{0}`t{1}' -f $target, $n))
    foreach ($r in $rows) {
        # UnrealLocres csv 'key' column = "<namespace>/<key>" (namespace may be empty).
        # Key column of the DB keeps the FULL exported string verbatim (rebuild fidelity).
        # Namespace column gets the parsed namespace for human matching.
        $fullKey = $r.key
        $ns = ''
        if ($fullKey -match '^([^/]/?.*)') { }
        if ($fullKey.StartsWith('/')) {
            $ns = ''
        } else {
            $slash = $fullKey.IndexOf('/')
            if ($slash -gt 0) { $ns = $fullKey.Substring(0, $slash) }
        }
        $key = $r.key
        $src = $r.source
        if ([string]::IsNullOrWhiteSpace($src)) { continue }
        $sha1.Initialize()
        $bytes = $sha1.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($ns + '|' + $key))
        $id = ($bytes | ForEach-Object { $_.ToString('X2') }) -join ''
        # deterministic SourceHash of the English source
        $sha1.Initialize()
        $shbytes = $sha1.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($src))
        $srchash = ($shbytes | ForEach-Object { $_.ToString('x2') }) -join ''
        $category = switch -Wildcard ($target) {
            'NewP5'       { 'UI' }
            'SettingAppliers' { 'UI' }
            'Misc'        { 'UI' }
            '*Terminal*'  { 'UI' }
            'CUTSCENES'   { 'Subtitles' }
            'Cutscenes*'  { 'Subtitles' }
            'Locations*'  { 'Dialogue' }
            '*Dialogues*' { 'Dialogue' }
            '*DIALOGUES*' { 'Dialogue' }
            'Mails*'      { 'Lore' }
            'NTD*'        { 'Lore' }
            default       { 'Unknown' }
        }
        # escape tabs in English (should not exist; defense) and keep 1 line
        $srcFlat = ($src -replace "`t", ' ') -replace "`r|`n", ' '
        $lines.Add(($id + "`t" + $rel.Substring(0, $rel.IndexOf('/Content/Localization/') + 0) + "`t" + $rel + "`t" + $ns + "`t" + $key + "`t" + $srcFlat + "`t`t`t`t" + $category + "`tUNTRANSLATED`t`t" + $srchash))
        $total++
    }
    Write-Host ("[OK ] {0,-40} {1,6} strings" -f $target, $n)
}

Write-Host ''
Set-Content -Path $masterPath -Value $lines -Encoding UTF8
Set-Content -Path (Join-Path $RepoRoot 'reports\strings_by_target.csv') -Value $perTarget -Encoding UTF8
Write-Host ("[DONE] master TSV rows: {0} -> {1}" -f $total, $masterPath)
