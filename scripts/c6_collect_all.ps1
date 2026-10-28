$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'
$jsonRoot = Join-Path $repo 'build\c6\json'
$outTsv = Join-Path $repo 'build\c6\all_strings.tsv'

function Escape-Text([string]$t) {
    if ($null -eq $t) { return '' }
    return $t.Replace('\', '\\').Replace("`r", '\r').Replace("`n", '\n').Replace("`t", '\t')
}
function Get-Markers([string]$t) {
    $m = [regex]::Matches($t, '\*[0-9][0-9.\-]*\*')
    return (($m | ForEach-Object { $_.Value }) -join ' ')
}
function Get-Category([string]$asset, [string]$name) {
    if ($name -like 'DT_Subtitles_*' -or $asset -match '/Cut_Scenes/|/Cutscenes/') { return 'Subtitle' }
    if ($name -like 'ST_*') { return 'StringTable' }
    if ($name -like 'DA_*Terminal*' -or $asset -match 'Terminal') { return 'Terminal' }
    if ($name -like 'D_*') { return 'Dialogue' }
    if ($name -like 'DT_*') { return 'Subtitle' }
    if ($name -like 'BP_*' -or $name -like 'LS_*') { return 'Scripted' }
    return 'Other'
}
function Get-SpeakerFromUid([string]$uid) {
    if (-not $uid) { return '' }
    $u = $uid -replace '^(D_|DLC\d+_|DA_)[^_]+_', ''
    $u = $u -replace '_[0-9]+$', ''
    $u = $u -replace '_(Begin|End|Start|Loop)$', ''
    return $u
}

$out = New-Object System.Collections.Generic.List[string]
$out.Add("asset`tkind`tkey`tfield`tspeaker`tcategory`tmarkers`ttext_escaped`ttext_b64")
$total = 0
$unique = @{}

$files = Get-ChildItem $jsonRoot -Recurse -Filter '*.json'
foreach ($f in $files) {
    $rel = $f.FullName.Substring($jsonRoot.Length + 1)
    $rel = $rel.Substring(0, $rel.Length - 5)
    $asset = ($rel -replace '\\', '/') -replace '^pakchunk\d+-WindowsNoEditor/', ''
    $j = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::UTF8) | ConvertFrom-Json
    $name = [IO.Path]::GetFileNameWithoutExtension($asset)
    $category = Get-Category $asset $name
    $seen = @{}
    $got = 0

    function Add-Text([string]$kind, [string]$key, [string]$field, [string]$speaker, [string]$t) {
        if ($null -eq $t) { return }
        if ($t.Trim().Length -eq 0) { return }
        $sig = $kind + "\u0001" + $field + "\u0001" + $t
        if ($seen.ContainsKey($sig)) { return }
        $seen[$sig] = $true
        $script:total++
        if (-not $script:unique.ContainsKey($t)) { $script:unique[$t] = 0 }
        $script:unique[$t]++
        $b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($t))
        $out.Add(($asset + "`t" + $kind + "`t" + $key + "`t" + $field + "`t" + $speaker + "`t" + $category + "`t" + (Get-Markers $t) + "`t" + (Escape-Text $t) + "`t" + $b64))
        $script:got++
    }

    foreach ($e in $j.Exports) {
        $etype = [string]$e.'$type'
        if ($etype -like '*StringTableExport*') {
            if ($e.Table -and $e.Table.Value) {
                foreach ($pair in $e.Table.Value) { Add-Text 'StringTable' ([string]$pair[0]) 'Table' '' ([string]$pair[1]) }
            }
        } elseif ($etype -like '*DataTableExport*') {
            if ($e.Table -and $e.Table.Data) {
                foreach ($row in $e.Table.Data) {
                    $rn = [string]$row.Name
                    $speaker = ''
                    $sp = $row.Value | Where-Object { $_.Name -eq 'Speaker' } | Select-Object -First 1
                    if ($sp -and $sp.CultureInvariantString) { $speaker = ([string]$sp.CultureInvariantString).Trim() }
                    if (-not $speaker) {
                        $mk = $row.Value | Where-Object { $_.Name -eq 'Marker' } | Select-Object -First 1
                        if ($mk) { $speaker = [string]$mk.Value }
                    }
                    foreach ($p in $row.Value) {
                        if ($p.'$type' -like '*TextPropertyData*' -and $p.Name -ne 'Speaker') {
                            Add-Text 'DataTable' $rn ([string]$p.Name) $speaker ([string]$p.CultureInvariantString)
                        }
                    }
                }
            }
        } elseif ($etype -like '*NormalExport*') {
            if ($e.Data) {
                $stack = New-Object System.Collections.Stack
                $stack.Push(@($e.Data, '', ''))
                while ($stack.Count -gt 0) {
                    $item = $stack.Pop()
                    $props = $item[0]; $ctxKey = $item[1]; $ctxSpeaker = $item[2]
                    $rowKey = $ctxKey
                    if ($props | Where-Object { $_.Name -eq 'UniqueId' }) {
                        $u = ($props | Where-Object { $_.Name -eq 'UniqueId' } | Select-Object -First 1).Value
                        if ($u -and [string]$u -ne 'None') { if (-not $rowKey) { $rowKey = [string]$u }; if (-not $ctxSpeaker) { $ctxSpeaker = Get-SpeakerFromUid ([string]$u) } }
                    }
                    $localTexts = @($props | Where-Object { $_.'$type' -like '*TextPropertyData*' })
                    foreach ($p in $props) {
                        if ($p.'$type' -like '*TextPropertyData*') {
                            $sp = $ctxSpeaker
                            if ($p.Name -eq 'Speaker' -and $p.CultureInvariantString -and ([string]$p.CultureInvariantString).Trim()) { $sp = ([string]$p.CultureInvariantString).Trim() }
                            if (-not $rowKey) { $rowKey = $name }
                            Add-Text 'Normal' $rowKey ([string]$p.Name) $sp ([string]$p.CultureInvariantString)
                        } elseif ($p.'$type' -like '*StructPropertyData*') {
                            if ($p.Value) { $stack.Push(@($p.Value, $rowKey, $ctxSpeaker)) }
                        } elseif ($p.'$type' -like '*ArrayPropertyData*') {
                            $i = 0
                            foreach ($item2 in $p.Value) {
                                if ($item2.'$type' -like '*StructPropertyData*' -and $item2.Value) { $stack.Push(@($item2.Value, ($rowKey + '#' + $i), $ctxSpeaker)) }
                                $i++
                            }
                        }
                    }
                }
            }
        }
    }
}
[IO.File]::WriteAllLines($outTsv, $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('all text rows ' + $total + ' | unique ' + $unique.Count + ' | unique chars ' + (($unique.Keys | ForEach-Object { $_.Length } | Measure-Object -Sum).Sum))
