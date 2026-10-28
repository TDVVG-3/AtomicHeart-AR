# Read-only probe for the subtitle widget constants that were located in the cooked
# blueprints. It also performs a copy-only property edit/read-back experiment:
# HorizontalFreeSpace 40.0 -> 80.0 in a COPY of the extracted JSON. No .uasset is
# re-serialized, no pak is built, and nothing is installed.
#
# Outputs:
#   build/blueprint_probe/subtitle_constants.json
#   build/blueprint_probe/experiment/WBP_NPCSubtitle.uasset.property80.json
#   build/blueprint_probe/experiment/readback.json
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$sub = Join-Path $RepoRoot 'build\extracted\subsys\AtomicHeart\Content\Core\UI\Subtitles'
$typing = Join-Path $RepoRoot 'build\extracted\typing\AtomicHeart\Content\Core\UI\Dialogue\WBP_TypingTextBox.uasset.json'
$subsystem = Join-Path $RepoRoot 'build\extracted\subsys\AtomicHeart\Content\Core\Subsystems\BP_SubtitlesSubsystem.uasset.json'
$one = Join-Path $sub 'WBP_OneSubtitle.uasset.json'
$npc = Join-Path $sub 'WBP_NPCSubtitle.uasset.json'
$subtitle = Join-Path $sub 'WBP_Subtitle.uasset.json'
foreach ($p in @($one, $npc, $subtitle, $typing, $subsystem)) {
    if (-not (Test-Path $p)) { throw "missing extracted JSON: $p" }
}

function Read-Json([string]$path) {
    return (Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json)
}
function Find-Node($node, [string]$name) {
    if ($null -eq $node) { return $null }
    if ($node -is [System.Management.Automation.PSCustomObject]) {
        if (($node.PSObject.Properties.Name -contains 'Name') -and ([string]$node.Name -eq $name)) {
            return $node
        }
        foreach ($p in $node.PSObject.Properties) {
            $r = Find-Node $p.Value $name
            if ($null -ne $r) { return $r }
        }
    } elseif ($node -is [array]) {
        foreach ($x in $node) {
            $r = Find-Node $x $name
            if ($null -ne $r) { return $r }
        }
    }
    return $null
}
function Find-NodeWithProps($node, [string]$p1, [string]$p2) {
    if ($null -eq $node) { return $null }
    if ($node -is [System.Management.Automation.PSCustomObject]) {
        $names = $node.PSObject.Properties.Name
        if (($names -contains $p1) -and ($names -contains $p2)) { return $node }
        foreach ($p in $node.PSObject.Properties) {
            $r = Find-NodeWithProps $p.Value $p1 $p2
            if ($null -ne $r) { return $r }
        }
    } elseif ($node -is [array]) {
        foreach ($x in $node) {
            $r = Find-NodeWithProps $x $p1 $p2
            if ($null -ne $r) { return $r }
        }
    }
    return $null
}
function Scalar-Value($node, [string]$name) {
    $n = Find-Node $node $name
    if ($null -eq $n) { return $null }
    if ($n.PSObject.Properties.Name -contains 'Value') { return $n.Value }
    return $null
}
function Get-FloatCurve($exportData) {
    $ch = Find-NodeWithProps $exportData 'Times' 'Values'
    if ($null -eq $ch) { return $null }
    $times = @()
    foreach ($t in @($ch.Times)) {
        if ($null -ne $t -and $t.PSObject.Properties.Name -contains 'Value') { $times += [double]$t.Value }
    }
    $values = @()
    foreach ($v in @($ch.Values)) {
        if ($null -ne $v -and $v.PSObject.Properties.Name -contains 'Value') { $values += [double]$v.Value }
    }
    return [pscustomobject]@{ Times = $times; Values = $values }
}
function Get-ExportByName($j, [string]$name) {
    for ($i = 0; $i -lt $j.Exports.Count; $i++) {
        if ([string]$j.Exports[$i].ObjectName -eq $name) { return $j.Exports[$i] }
    }
    return $null
}

$oneJ = Read-Json $one
$npcJ = Read-Json $npc
$subtitleJ = Read-Json $subtitle
$typingJ = Read-Json $typing
$subsystemJ = Read-Json $subsystem

# WBP_NPCSubtitle HideBack: section 20 is RenderOpacity, section 21 is WidthOverride.
$hideBack = Get-ExportByName $npcJ 'HideBack'
$npcSections = @()
for ($i = 0; $i -lt $npcJ.Exports.Count; $i++) {
    $e = $npcJ.Exports[$i]
    if ([string]$e.ObjectName -eq 'MovieSceneFloatSection_0') {
        $npcSections += [pscustomobject]@{ Index = $i; Curve = (Get-FloatCurve $e.Data) }
    }
}
# WBP_TypingTextBox Hide: one RenderOpacity section.
$typingHide = Get-ExportByName $typingJ 'Hide'
$typingSections = @()
for ($i = 0; $i -lt $typingJ.Exports.Count; $i++) {
    $e = $typingJ.Exports[$i]
    if ([string]$e.ObjectName -eq 'MovieSceneFloatSection_0') {
        $typingSections += [pscustomobject]@{ Index = $i; Curve = (Get-FloatCurve $e.Data) }
    }
}

$constants = [ordered]@{
    generated = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')
    source = [ordered]@{
        WBP_Subtitle = $subtitle
        WBP_OneSubtitle = $one
        WBP_NPCSubtitle = $npc
        WBP_TypingTextBox = $typing
        BP_SubtitlesSubsystem = $subsystem
    }
    values = [ordered]@{
        SubtitleSizeScale = Scalar-Value $subsystemJ.Exports[1].Data 'SubtitleSizeScale'
        HorizontalFreeSpace = Scalar-Value $npcJ.Exports[10].Data 'HorizontalFreeSpace'
        bEnableShow = Scalar-Value $npcJ.Exports[10].Data 'bEnableShow'
        TimeBetweenChars = Scalar-Value $typingJ.Exports[18].Data 'TimeBetweenChars'
        CharPerTick = Scalar-Value $typingJ.Exports[18].Data 'CharPerTick'
        WidgetTemplate = 'WBP_Subtitle'
        HideBackSectionCount = $npcSections.Count
        TypingHideSectionCount = $typingSections.Count
    }
    animations = [ordered]@{
        WBP_NPCSubtitle_HideBack = @($npcSections | ForEach-Object {
            [ordered]@{ export_index = $_.Index; times_ticks = $_.Curve.Times; values = $_.Curve.Values; seconds = ($_.Curve.Times | ForEach-Object { [double]$_ / 60000.0 }) }
        })
        WBP_TypingTextBox_Hide = @($typingSections | ForEach-Object {
            [ordered]@{ export_index = $_.Index; times_ticks = $_.Curve.Times; values = $_.Curve.Values; seconds = ($_.Curve.Times | ForEach-Object { [double]$_ / 60000.0 }) }
        })
    }
}
$probeDir = Join-Path $RepoRoot 'build\blueprint_probe'
New-Item -ItemType Directory -Force -Path $probeDir | Out-Null
$constantsPath = Join-Path $probeDir 'subtitle_constants.json'
$constants | ConvertTo-Json -Depth 12 | Set-Content -Path $constantsPath -Encoding UTF8

# --- copy-only property experiment -------------------------------------------------
$expDir = Join-Path $probeDir 'experiment'
New-Item -ItemType Directory -Force -Path $expDir | Out-Null
$copyPath = Join-Path $expDir 'WBP_NPCSubtitle.uasset.property80.json'
$origRaw = Get-Content $npc -Raw -Encoding UTF8
$origHash = (Get-FileHash $npc -Algorithm SHA256).Hash.ToLower()
$origJ = Read-Json $npc
$origNode = Find-Node $origJ.Exports[10].Data 'HorizontalFreeSpace'
if ($null -eq $origNode) { throw 'HorizontalFreeSpace property not found in default object' }
$before = [double]$origNode.Value
if ($before -ne 40.0) { throw ('unexpected HorizontalFreeSpace before value: ' + $before) }
$origNode.Value = 80.0
$origJ | ConvertTo-Json -Depth 100 | Set-Content -Path $copyPath -Encoding UTF8
$newHash = (Get-FileHash $copyPath -Algorithm SHA256).Hash.ToLower()
$newJ = Read-Json $copyPath
$newNode = Find-Node $newJ.Exports[10].Data 'HorizontalFreeSpace'
$after = [double]$newNode.Value

# Prove the bytecode blobs did not change in the copy.
$origBc = (($origJ.Exports | ForEach-Object { if ($_.PSObject.Properties.Name -contains 'ScriptBytecode' -and $_.ScriptBytecode.Count -gt 0) { $_.ScriptBytecode | ConvertTo-Json -Depth 100 -Compress } }) -join "`n")
$newBc = (($newJ.Exports | ForEach-Object { if ($_.PSObject.Properties.Name -contains 'ScriptBytecode' -and $_.ScriptBytecode.Count -gt 0) { $_.ScriptBytecode | ConvertTo-Json -Depth 100 -Compress } }) -join "`n")
$origBcHash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($origBc))).Replace('-', '').ToLower()
$newBcHash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($newBc))).Replace('-', '').ToLower()

# Count scalar property differences between original and copy (Name + scalar Value).
function Flatten-Scalars($node, [string]$prefix, $list) {
    if ($null -eq $node) { return }
    if ($node -is [System.Management.Automation.PSCustomObject]) {
        $name = ''
        if ($node.PSObject.Properties.Name -contains 'Name') { $name = [string]$node.Name }
        if ($name -and ($node.PSObject.Properties.Name -contains 'Value') -and
            ($node.Value -isnot [System.Management.Automation.PSCustomObject]) -and
            ($node.Value -isnot [array])) {
            $list.Add([pscustomobject]@{ Path = ($prefix + '/' + $name); Value = [string]$node.Value })
        }
        foreach ($p in $node.PSObject.Properties) {
            if ($p.Name -in @('$type','Name','Value')) { continue }
            Flatten-Scalars $p.Value ($prefix + $(if ($name) { '/' + $name } else { '' })) $list
        }
    } elseif ($node -is [array]) {
        $i = 0
        foreach ($x in $node) { Flatten-Scalars $x ($prefix + '[' + $i + ']') $list; $i++ }
    }
}
$origForDiff = Read-Json $npc
$beforeList = New-Object System.Collections.Generic.List[object]
$afterList = New-Object System.Collections.Generic.List[object]
Flatten-Scalars $origForDiff.Exports[10].Data '' $beforeList
Flatten-Scalars $newJ.Exports[10].Data '' $afterList
$diffs = New-Object System.Collections.Generic.List[object]
$max = [Math]::Max($beforeList.Count, $afterList.Count)
for ($i = 0; $i -lt $max; $i++) {
    $b = if ($i -lt $beforeList.Count) { $beforeList[$i] } else { $null }
    $a = if ($i -lt $afterList.Count) { $afterList[$i] } else { $null }
    if ($null -eq $b -or $null -eq $a -or $b.Path -ne $a.Path -or $b.Value -ne $a.Value) {
        $diffs.Add([pscustomobject]@{ Path = if ($b) { $b.Path } else { $a.Path }; Before = if ($b) { $b.Value } else { '<missing>' }; After = if ($a) { $a.Value } else { '<missing>' } })
    }
}
$readback = [ordered]@{
    generated = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')
    mode = 'copy-only JSON property edit; no .uasset re-serialization; no pak; NOT INSTALLED'
    source_json = $npc
    copy_json = $copyPath
    property = 'WBP_NPCSubtitle.Default__WBP_NPCSubtitle_C.HorizontalFreeSpace'
    before = $before
    after = $after
    source_sha256 = $origHash
    copy_sha256 = $newHash
    source_scriptbytecode_sha256 = $origBcHash
    copy_scriptbytecode_sha256 = $newBcHash
    bytecode_unchanged = ($origBcHash -eq $newBcHash)
    changed_scalar_properties = $diffs
    changed_scalar_property_count = $diffs.Count
    note = 'The changed property only controls backdrop width (TextDesiredSize.X + HorizontalFreeSpace); it is not a subtitle hold/duration constant.'
}
$readbackPath = Join-Path $expDir 'readback.json'
$readback | ConvertTo-Json -Depth 8 | Set-Content -Path $readbackPath -Encoding UTF8

Write-Output ('constants: ' + $constantsPath)
Write-Output ('readback : ' + $readbackPath)
Write-Output ('copy     : ' + $copyPath)
Write-Output ('HorizontalFreeSpace: {0} -> {1}; changed scalars={2}; bytecode_unchanged={3}' -f $before, $after, $diffs.Count, ($origBcHash -eq $newBcHash))
Write-Output ('HideBack sections: ' + ($npcSections.Count) + '; Typing Hide sections: ' + ($typingSections.Count))
foreach ($s in $npcSections) { Write-Output ('  NPC section ' + $s.Index + ' times=' + ($s.Curve.Times -join ',') + ' values=' + ($s.Curve.Values -join ',')) }
foreach ($s in $typingSections) { Write-Output ('  Typing section ' + $s.Index + ' times=' + ($s.Curve.Times -join ',') + ' values=' + ($s.Curve.Values -join ',')) }
if ($diffs.Count -ne 1) { throw ('expected exactly one changed scalar property, got ' + $diffs.Count) }
if ($origBcHash -ne $newBcHash) { throw 'ScriptBytecodeRaw changed in the copy' }
