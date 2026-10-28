param(
    [Parameter(Mandatory=$true)][string]$Old,
    [Parameter(Mandatory=$true)][string]$New,
    [Parameter(Mandatory=$true)][string]$Out,
    [string[]]$Volatile = @('SerialSize','SerialOffset','ScriptSerializationStartOffset','ScriptSerializationEndOffset')
)
$ErrorActionPreference = 'Stop'
$script:diffs = New-Object System.Collections.Generic.List[string]
$script:changeCount = 0

function Is-Volatile([string]$name) { return $Volatile -contains $name }

function Compare-Node($a, $b, [string]$path) {
    if ($null -eq $a -and $null -eq $b) { return }
    if ($null -eq $a -or $null -eq $b) {
        if ($script:diffs.Count -lt 200) { $script:diffs.Add($path + ' :: type/null ' + ($a -eq $null) + '/' + ($b -eq $null)) }
        return
    }
    if ($a -is [string] -or $b -is [string] -or $a -is [ValueType] -or $b -is [ValueType]) {
        if ([string]$a -ne [string]$b) {
            $script:changeCount++
            if ($script:diffs.Count -lt 50) { $script:diffs.Add($path + ' :: ' + [string]$a + ' => ' + [string]$b) }
        }
        return
    }
    if ($a -is [System.Collections.IList] -and $b -is [System.Collections.IList]) {
        if ($a.Count -ne $b.Count) {
            $script:changeCount++
            if ($script:diffs.Count -lt 50) { $script:diffs.Add($path + ' :: list count ' + $a.Count + ' => ' + $b.Count) }
            return
        }
        for ($i=0; $i -lt $a.Count; $i++) { Compare-Node $a[$i] $b[$i] ($path + '[' + $i + ']') }
        return
    }
    $ap = $a.PSObject.Properties
    $bp = $b.PSObject.Properties
    $an = @($ap | ForEach-Object { $_.Name })
    $bn = @($bp | ForEach-Object { $_.Name })
    if (($an -join '|') -ne ($bn -join '|')) {
        $script:changeCount++
        if ($script:diffs.Count -lt 50) { $script:diffs.Add($path + ' :: property set differs') }
        return
    }
    foreach ($p in $ap) {
        if (Is-Volatile $p.Name) { continue }
        Compare-Node $p.Value ($b.PSObject.Properties[$p.Name].Value) ($path + '.' + $p.Name)
    }
}

$a = [IO.File]::ReadAllText($Old, [Text.Encoding]::UTF8) | ConvertFrom-Json
$b = [IO.File]::ReadAllText($New, [Text.Encoding]::UTF8) | ConvertFrom-Json
Compare-Node $a $b 'root'
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('semantic changes: ' + $script:changeCount)
$lines.AddRange($script:diffs)
[IO.File]::WriteAllLines($Out, $lines, (New-Object Text.UTF8Encoding($false)))
Write-Output ('semantic changes: ' + $script:changeCount)
