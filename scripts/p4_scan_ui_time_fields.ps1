$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
$patterns = '(?i)(waittime|duration|delay|lifetime|holdtime|showtime|displaytime|fadetime|lingertime|minshowtime|hidetime|autohidetime|notificationtime|maxtime|mintime|timebetween)'
$results = New-Object System.Collections.Generic.List[string]
function Walk($o, $asset, $path) {
    if ($null -eq $o) { return }
    if ($o -is [System.Collections.IEnumerable] -and -not ($o -is [string])) {
        foreach ($i in $o) { Walk $i $asset $path }
        return
    }
    if ($o -is [PSCustomObject]) {
        $n = $null
        try { $n = $o.Name } catch {}
        if ($n -and ($n -match $script:patterns) -and $null -ne $o.Value) {
            $v = $o.Value
            if ($v -is [double] -or $v -is [int] -or $v -is [long] -or $v -is [single] -or $v -is [decimal]) {
                $script:results.Add($asset + "`t" + $n + "`t" + $v)
            }
        }
        foreach ($p in $o.PSObject.Properties) { Walk $p.Value $asset $path }
    }
}
foreach ($f in (Get-ChildItem 'C:\AtomicHeart-AR\build\p4\ui_src' -Recurse -Filter *.uasset.json)) {
    try { $j = Get-Content $f.FullName -Raw | ConvertFrom-Json } catch { continue }
    Walk $j $f.BaseName ''
}
$uniq = $results | Sort-Object -Unique
$out = 'C:\AtomicHeart-AR\build\p4\ui_time_fields.tsv'
[IO.File]::WriteAllLines($out, $uniq, (New-Object Text.UTF8Encoding($false)))
Write-Output ('rows: ' + $uniq.Count)
$uniq | ForEach-Object { $_ }
