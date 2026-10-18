<#
.SYNOPSIS
  Pilot selection (DEC-023 step 5): deterministically picks the pilot rows from the
  master TSV and writes reports/pilot_selection.tsv.

.DESCRIPTION
  Groups (user order):
    UI      : 20 rows, scopes NewP5 / Misc / PearTerminals, English length 4..90,
              at least 5 rows containing a rich-text tag or placeholder.
    SHORT   : 20 rows, dialogue scopes, Category Dialogue, English length 12..70.
    LONG    : 20 rows, English length >= 200, preferring rows with tags/escapes/numbers.

  Selection is deterministic: candidates are sorted by the master ID string, then the
  first N matching the group's extra condition are taken. Nothing is modified here.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [int]$UiCount = 20,
    [int]$ShortCount = 20,
    [int]$LongCount = 20
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$master = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$outPath = Join-Path $RepoRoot 'reports\pilot_selection.tsv'

$lines = [IO.File]::ReadAllLines($master, [Text.Encoding]::UTF8)
$rows = New-Object System.Collections.Generic.List[object]
for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -lt 13) { continue }
    $scope = 'other'
    if ($f[2] -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }
    $rows.Add([pscustomobject]@{
        id    = $f[0]
        scope = $scope
        key   = $f[4]
        en    = $f[5]
        cat   = $f[9]
        ar    = $f[6]
        st    = $f[10]
    })
}

$uiScopes = @('NewP5', 'Misc', 'PearTerminals')
$dlgScopes = @('Academy_Dialogues','Chelomey_Dialogues','ChelomeyFinal_Dialogues','CUTSCENES','DIALOGUES FOR LQA','OpenWorldVDNKh_Dialogues','Pavlov_Dialogues','Polygon_Dialogues','Schebetar_Subs','Theatre_Dialogues','Vavilov_Dialogues','VDNKh_Dialogues')

$picked = New-Object System.Collections.Generic.List[object]

# --- UI: 20, of which >= 5 must carry a tag/placeholder
# Excluded: pure template/format strings that must NOT be translated (they are not prose).
$uiBlock = @('ItemName', 'ItemDescription', 'Name', 'Description', 'Text', 'String')
$uiPool = @($rows | Where-Object {
        $uiScopes -contains $_.scope -and
        $_.en.Trim().Length -ge 4 -and $_.en.Trim().Length -le 90 -and
        ($uiBlock -notcontains $_.en.Trim()) -and
        ($_.en -notmatch '^[xX]\{[0-9]\}$')
    } | Sort-Object id)
$tagged = @($uiPool | Where-Object { $_.en -match '<(h|tag|img|c)\b|\{0\}|%s' })
$plain  = @($uiPool | Where-Object { $_.en -notmatch '<(h|tag|img|c)\b|\{0\}|%s' })
$uiPick = New-Object System.Collections.Generic.List[object]
$takeTagged = [Math]::Min(6, $tagged.Count)
for ($i = 0; $i -lt $takeTagged; $i++) { $uiPick.Add($tagged[$i]) }
for ($i = 0; $uiPick.Count -lt $UiCount -and $i -lt $plain.Count; $i++) { $uiPick.Add($plain[$i]) }
foreach ($r in $uiPick) { $r | Add-Member -NotePropertyName grp -NotePropertyValue 'UI' -Force; $picked.Add($r) }

# --- SHORT dialogue: 20, length 12..70
$shortPool = @($rows | Where-Object { $dlgScopes -contains $_.scope -and $_.cat -eq 'Dialogue' -and $_.en.Trim().Length -ge 12 -and $_.en.Trim().Length -le 70 } | Sort-Object id)
for ($i = 0; $i -lt $ShortCount -and $i -lt $shortPool.Count; $i++) { $shortPool[$i] | Add-Member -NotePropertyName grp -NotePropertyValue 'SHORT' -Force; $picked.Add($shortPool[$i]) }

# --- LONG subtitles: 20, length >= 200, biased to rows with markers/tags/numbers
$longPool = @($rows | Where-Object { $dlgScopes -contains $_.scope -and $_.en.Trim().Length -ge 200 } |
    ForEach-Object { $_ | Add-Member -NotePropertyName rich -NotePropertyValue ([int]($_.en -match '<(h|tag|img|c)\b|\{0\}|%s|\\n|\d|&\w+&|\*0\.')) -Force; $_ } |
    Sort-Object @{ Expression = { -$_.rich } }, id)
for ($i = 0; $i -lt $LongCount -and $i -lt $longPool.Count; $i++) { $longPool[$i] | Add-Member -NotePropertyName grp -NotePropertyValue 'LONG' -Force; $picked.Add($longPool[$i]) }

$out = New-Object System.Collections.Generic.List[string]
$out.Add(('group' + "`t" + 'id' + "`t" + 'scope' + "`t" + 'key' + "`t" + 'cat' + "`t" + 'enlen' + "`t" + 'hasTag' + "`t" + 'english'))
foreach ($r in $picked) {
    $hasTag = [int]($r.en -match '<(h|tag|img|c)\b|\{0\}|%s')
    $out.Add(($r.grp + "`t" + $r.id + "`t" + $r.scope + "`t" + $r.key + "`t" + $r.cat + "`t" + $r.en.Trim().Length + "`t" + $hasTag + "`t" + $r.en))
}
[IO.File]::WriteAllLines($outPath, $out, (New-Object Text.UTF8Encoding($false)))

Write-Output ('picked total: {0}  (UI {1} / SHORT {2} / LONG {3})' -f $picked.Count, @($picked | Where-Object grp -eq 'UI').Count, @($picked | Where-Object grp -eq 'SHORT').Count, @($picked | Where-Object grp -eq 'LONG').Count)
Write-Output ('written: {0}' -f $outPath)
Write-Output ''
foreach ($g in @('UI','SHORT','LONG')) {
    Write-Output ('===== ' + $g + ' =====')
    foreach ($r in ($picked | Where-Object grp -eq $g)) {
        Write-Output ($r.id + '  [' + $r.scope + ']  len=' + $r.en.Trim().Length)
        Write-Output ('   EN: ' + $r.en)
    }
}
