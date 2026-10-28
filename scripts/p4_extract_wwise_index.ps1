$ErrorActionPreference = 'Stop'
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

# P4.3 - extract English(US) Wwise event durations from already-unpacked bank metadata.
# Read-only: writes only under build/p4.
$root = 'C:\AtomicHeart-AR'
$jsonRoot = Join-Path $root 'build\p4\wwise_json'
$out = Join-Path $root 'build\p4\wwise_events.tsv'
$files = Get-ChildItem $jsonRoot -Recurse -Filter '*.json' -File
$rows = New-Object System.Collections.Generic.List[string]
$rows.Add("event`tbank`tlanguage`tduration_min`tduration_max`tmedia_path`tbank_json")

foreach ($f in $files) {
    try { $j = Get-Content $f.FullName -Raw | ConvertFrom-Json } catch { continue }
    foreach ($sb in $j.SoundBanksInfo.SoundBanks) {
        foreach ($e in $sb.IncludedEvents) {
            $media = ''
            $mf = $null
            if ($e.IncludedMemoryFiles) { $mf = $e.IncludedMemoryFiles | Select-Object -First 1 }
            if (-not $mf -and $e.ReferencedStreamedFiles) { $mf = $e.ReferencedStreamedFiles | Select-Object -First 1 }
            if ($mf) { $media = [string]$mf.Path }
            $rows.Add(([string]$e.Name) + "`t" + [string]$sb.ShortName + "`t" + [string]$sb.Language + "`t" + [string]$e.DurationMin + "`t" + [string]$e.DurationMax + "`t" + $media + "`t" + $f.FullName)
        }
    }
}

[IO.File]::WriteAllLines($out, $rows, (New-Object Text.UTF8Encoding($false)))
Write-Output ("WROTE $out rows=" + ($rows.Count - 1) + " files=" + $files.Count)
