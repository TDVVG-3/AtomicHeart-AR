$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
$repo = 'C:\AtomicHeart-AR'
$jsonRoot = Join-Path $repo 'build\c6\json'
$outTsv = Join-Path $repo 'build\c6\collected.tsv'
$mismatch = Join-Path $repo 'build\c6\count_mismatch.tsv'

$words = [regex]'[A-Za-z\u0400-\u04FF\u0600-\u06FF\u0590-\u05FF]{3,}'
function Test-Prose([string]$t) {
    if ($null -eq $t) { return $false }
    $t = $t.Trim()
    if ($t.Length -lt 8 -or $t.Length -gt 1000) { return $false }
    if (-not $t.Contains(' ')) { return $false }
    if ($t.Contains('/') -or $t.Contains('\') -or $t.Contains('::')) { return $false }
    if ($t -match '\.(uasset|uexp|locres|png|wav|ogg|umap)$') { return $false }
    if ($t -match '^(DC_|BP_|ST_|LS_|SK_|M_|T_|SM_)') { return $false }
    if ($t -match 'Property|Function|Blueprint|Struct|Enum|Class|Asset|Package|Level|Component|Actor') { return $false }
    if ($t.Contains(':')) { return $false }
    if ($words.Matches($t).Count -lt 2) { return $false }
    return $true
}
function Get-Markers([string]$t) {
    $m = [regex]::Matches($t, '\*[0-9][0-9.\-]*\*')
    return (($m | ForEach-Object { $_.Value }) -join ' ')
}
function Get-SpeakerFromMarker([string]$s) {
    if (-not $s) { return '' }
    $m = [regex]::Match($s, '(?i)(?:VO|SP|VA|DLC\d*)[_\-](?:[A-Za-z0-9]+[_\-])*?(P3|P_3|Sechenov|Lebedev|BabaZina|Baba_Zina|Zina|Eleanor|Eleanora|Charles|Char_les|Petrov|Muravyova|Filatova|Stockhausen|Zakharov|Kuznetsov|Larisa|Svetlana|Victor|Viktor|Dmitry|Dmitri|Sergey|Sergei)(?:[_\-]|$)')
    if ($m.Success) { return $m.Groups[1].Value }
    return ''
}
function Get-Category([string]$asset, [string]$name) {
    $n = $name
    if ($asset -match 'DLC01_Cutscenes|/Cut_Scenes/|/Cutscenes/' -or $n -like 'DT_Subtitles_*') { return 'Subtitle' }
    if ($n -like 'ST_*') { return 'StringTable' }
    if ($n -like 'DA_*Terminal*' -or $asset -match 'Terminal') { return 'Terminal' }
    if ($n -like 'D_*') { return 'Dialogue' }
    if ($n -like 'DT_*') { return 'Subtitle' }
    if ($n -like 'BP_*' -or $n -like 'LS_*') { return 'Scripted' }
    return 'Other'
}
function Get-SpeakerFromUid([string]$uid) {
    if (-not $uid) { return '' }
    $u = $uid -replace '^(D_|DLC\d+_|DA_)[^_]+_', ''
    $u = $u -replace '_[0-9]+$', ''
    $u = $u -replace '_(Begin|End|Start|Loop)$', ''
    return $u
}

$expected = @{}
foreach ($r in (Import-Csv (Join-Path $repo 'build\c6_ru_assets.csv'))) { $expected[$r.asset] = [int]$r.n }

$out = New-Object System.Collections.Generic.List[string]
$out.Add("asset`tkind`tkey`tfield`tspeaker`tcategory`tmarkers`ttext")
$mis = New-Object System.Collections.Generic.List[string]
$mis.Add("asset`texpected`tcollected")
$total = 0

$files = Get-ChildItem $jsonRoot -Recurse -Filter '*.json'
foreach ($f in $files) {
    $rel = $f.FullName.Substring($jsonRoot.Length + 1)
    $rel = $rel.Substring(0, $rel.Length - 5)  # strip .json
    $asset = ($rel -replace '\\', '/') -replace '^pakchunk\d+-WindowsNoEditor/', ''
    $j = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::UTF8) | ConvertFrom-Json
    $name = [IO.Path]::GetFileNameWithoutExtension($asset)
    $category = Get-Category $asset $name
    $seen = @{}
    $got = 0

    foreach ($e in $j.Exports) {
        $etype = [string]$e.'$type'
        if ($etype -like '*StringTableExport*') {
            if ($e.Table -and $e.Table.Value) {
                foreach ($pair in $e.Table.Value) {
                    $k = [string]$pair[0]; $t = [string]$pair[1]
                    if (Test-Prose $t) {
                        if (-not $seen.ContainsKey($t)) {
                            $seen[$t] = $true; $got++
                            $out.Add(($asset + "`tStringTable`t" + $k + "`tTable`t`t" + $category + "`t" + (Get-Markers $t) + "`t" + ($t -replace "`t", ' ') -replace "`r?`n", ' '))
                        }
                    }
                }
            }
        } elseif ($etype -like '*DataTableExport*') {
            if ($e.Table -and $e.Table.Data) {
                foreach ($row in $e.Table.Data) {
                    $rn = [string]$row.Name
                    $speaker = ''
                    $props = $row.Value
                    $sp = $props | Where-Object { $_.Name -eq 'Speaker' } | Select-Object -First 1
                    if ($sp -and $sp.CultureInvariantString) { $speaker = ([string]$sp.CultureInvariantString).Trim() }
                    if (-not $speaker) {
                        $mk = $props | Where-Object { $_.Name -eq 'Marker' } | Select-Object -First 1
                        if ($mk) { $speaker = Get-SpeakerFromMarker ([string]$mk.Value) }
                    }
                    $texts = @($props | Where-Object { $_.'$type' -like '*TextPropertyData*' -and $_.Name -ne 'Speaker' })
                    foreach ($p in $texts) {
                        $t = [string]$p.CultureInvariantString
                        if (Test-Prose $t) {
                            if (-not $seen.ContainsKey($t)) {
                                $seen[$t] = $true; $got++
                                $out.Add(($asset + "`tDataTable`t" + $rn + "`t" + $p.Name + "`t" + $speaker + "`t" + $category + "`t" + (Get-Markers $t) + "`t" + ($t -replace "`t", ' ') -replace "`r?`n", ' '))
                            }
                        }
                    }
                }
            }
        } elseif ($etype -like '*NormalExport*') {
            if ($e.Data) {
                # walk properties recursively; capture DialogueNode text/uniqueid and any Text property
                $stack = New-Object System.Collections.Stack
                $stack.Push(@($e.Data, '', ''))
                while ($stack.Count -gt 0) {
                    $item = $stack.Pop()
                    $props = $item[0]; $ctxKey = $item[1]; $ctxSpeaker = $item[2]
                    $uid = ''
                    $rowKey = $ctxKey
                    if ($props | Where-Object { $_.Name -eq 'UniqueId' }) {
                        $u = ($props | Where-Object { $_.Name -eq 'UniqueId' } | Select-Object -First 1).Value
                        if ($u -and [string]$u -ne 'None') { $uid = [string]$u; if (-not $rowKey) { $rowKey = $uid }; if (-not $ctxSpeaker) { $ctxSpeaker = Get-SpeakerFromUid $uid } }
                    }
                    foreach ($p in $props) {
                        $pt = [string]$p.'$type'
                        if ($pt -like '*TextPropertyData*') {
                            $t = [string]$p.CultureInvariantString
                            if (Test-Prose $t) {
                                if (-not $seen.ContainsKey($t)) {
                                    $seen[$t] = $true; $got++
                                    if (-not $rowKey) { $rowKey = $name }
                                    $sp = $ctxSpeaker
                                    if ($p.Name -eq 'Speaker' -and $t.Trim()) { $sp = $t.Trim() }
                                    $out.Add(($asset + "`tNormal`t" + $rowKey + "`t" + $p.Name + "`t" + $sp + "`t" + $category + "`t" + (Get-Markers $t) + "`t" + ($t -replace "`t", ' ') -replace "`r?`n", ' '))
                                }
                            }
                        } elseif ($pt -like '*StructPropertyData*') {
                            if ($p.Value) { $stack.Push(@($p.Value, $rowKey, $ctxSpeaker)) }
                        } elseif ($pt -like '*ArrayPropertyData*') {
                            $i = 0
                            foreach ($item2 in $p.Value) {
                                if ($item2.'$type' -like '*StructPropertyData*' -and $item2.Value) {
                                    $stack.Push(@($item2.Value, ($rowKey + '#' + $i), $ctxSpeaker))
                                }
                                $i++
                            }
                        }
                    }
                }
            }
        }
    }

    $exp = 0
    if ($expected.ContainsKey($asset)) { $exp = $expected[$asset] }
    if ($got -ne $exp) { $mis.Add(($asset + "`t" + $exp + "`t" + $got)) }
    $total += $got
}
[IO.File]::WriteAllLines($outTsv, $out, (New-Object Text.UTF8Encoding($false)))
[IO.File]::WriteAllLines($mismatch, $mis, (New-Object Text.UTF8Encoding($false)))
Write-Output ('collected strings: ' + ($out.Count - 1) + ' | expected 6012 | assets with mismatch: ' + ($mis.Count - 1))
