$ErrorActionPreference = 'Stop'
$repo = 'C:\AtomicHeart-AR'
$rows = Import-Csv (Join-Path $repo 'localization\master\atomic-heart-ar.tsv') -Delimiter "`t"
$names = @('Zinaida','Muravyova','Petrov','Burav','Secateur','Terentiy','Granny Zina','Voskhod','Mendeleev','Chelomey','Filatova','Charles','Char-les','Nechaev','Sechenov','Lebedev','Vavilov','Pavlov','Stockhausen','Kollektiv','P-3','Computer','NORA','VOV-A6','BEA-D','HOG-7','PEAR','SHZ-5','BUS-A')
$out = New-Object System.Collections.Generic.List[string]
$out.Add("english`tcount`tarabic_samples")
foreach ($n in $names) {
    $m = @($rows | Where-Object { $_.SourceEnglish -match ('(?i)(?<![A-Za-z0-9])' + [regex]::Escape($n) + '(?![A-Za-z0-9])') -and $_.Arabic.Trim().Length -gt 0 })
    $samples = @($m | Group-Object Arabic | Sort-Object Count -Descending | Select-Object -First 3 | ForEach-Object { $_.Name })
    $out.Add(($n + "`t" + $m.Count + "`t" + (($samples -join ' || '))))
}
[IO.File]::WriteAllLines((Join-Path $repo 'build\c6\style_names.tsv'), $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('lines ' + $out.Count)
