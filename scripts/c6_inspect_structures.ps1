$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$out = New-Object System.Collections.Generic.List[string]

function Show-Props($props, [string]$indent, $lines) {
    foreach ($p in $props) {
        $t = $p.'$type'
        $v = $p.Value
        if ($t -like '*TextPropertyData*') {
            $lines.Add($indent + $p.Name + ' [Text] = ' + $p.CultureInvariantString)
        } elseif ($t -like '*StrPropertyData*') {
            $lines.Add($indent + $p.Name + ' [Str] = ' + $v)
        } elseif ($t -like '*NamePropertyData*') {
            $lines.Add($indent + $p.Name + ' [Name] = ' + $v)
        } elseif ($t -like '*StructPropertyData*') {
            $lines.Add($indent + $p.Name + ' [Struct ' + $p.StructType + ']')
            Show-Props $p.Value ($indent + '  ') $lines
        } elseif ($t -like '*ArrayPropertyData*') {
            $lines.Add($indent + $p.Name + ' [Array] count=' + @($p.Value).Count)
            $i = 0
            foreach ($item in $p.Value) {
                $lines.Add($indent + '  [' + $i + '] ' + $item.'$type')
                if ($item.PSObject.Properties.Name -contains 'Value') { Show-Props @($item) ($indent + '    ') $lines }
                $i++
            }
        } elseif ($t -like '*BoolPropertyData*') {
            $lines.Add($indent + $p.Name + ' [Bool] = ' + $v)
        } elseif ($t -like '*FloatPropertyData*' -or $t -like '*IntPropertyData*') {
            $lines.Add($indent + $p.Name + ' = ' + $v)
        }
    }
}

$targets = @(
  'D_DLC01_Lebedev01',
  'ST_GooseRunner_Hints',
  'BP_GooseRunner_UnloadStartCutsceneTrigger',
  'LS_DLC2_GooseEscape',
  'DT_Intro',
  'NarrSubs'
)
foreach ($t in $targets) {
    $f = Get-ChildItem (Join-Path $repo 'build\c6\json') -Recurse -Filter ('*' + $t + '*.json') | Select-Object -First 1
    if (-not $f) { $out.Add('### MISSING ' + $t); continue }
    $out.Add('### ' + $f.FullName.Substring((Join-Path $repo 'build\c6\json').Length + 1))
    $j = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::UTF8) | ConvertFrom-Json
    $out.Add('exports: ' + @($j.Exports).Count)
    foreach ($e in $j.Exports) {
        $out.Add('EXPORT ' + $e.ObjectName + ' :: ' + $e.'$type')
        if ($e.Table) {
            $out.Add('  table rows: ' + @($e.Table.Data).Count)
            $k = 0
            foreach ($row in $e.Table.Data) {
                $out.Add('  ROW ' + $row.Name)
                Show-Props $row.Value '    ' $out
                $k++
                if ($k -ge 2) { break }
            }
        } else {
            Show-Props $e.Data '  ' $out
        }
    }
    $out.Add('')
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\inspect.txt'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('lines: ' + $out.Count)
