<#
.SYNOPSIS
  Translation validator (DEC-023 step 9). Checks every master row that carries Arabic.

.DESCRIPTION
  Hard failures (exit 2):
    - placeholder multiset differs from the English source ({0}, %s, %d, %f)
    - rich-text tag multiset differs (<h>..</>, <c>..</>, <img .../>, <tag .../>)
    - escape multiset differs (\n, \r, \t as two characters)
    - fragment marker multiset differs (*0.10*, *0.00-0.08*) or speaker marker (&Surgeon&)
    - Arabic is EMPTY while Status is DRAFT / REVIEWED / APPROVED
    - Arabic is identical to the English (untranslated row)
    - Arabic contains U+FFFD, a control character (other than the preserved escapes),
      or no Arabic letter at all
    - Status value is not one of the allowed values
  Warnings (never fail):
    - glossary term present in English, glossary Arabic not found in the Arabic column
    - UI row longer than 1.2 x English
    - number-token multiset differs (numbers legitimately become words in Arabic)

  Files: localization/master/atomic-heart-ar.tsv, glossary/glossary.tsv
  Report: reports/translation_validation.md
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR',
    [switch]$Quiet
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$masterPath = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$glossPath  = Join-Path $RepoRoot 'glossary\glossary.tsv'
$reportPath = Join-Path $RepoRoot 'reports\translation_validation.md'
$allowedStatus = @('UNTRANSLATED','DRAFT','REVIEWED','APPROVED','TECHNICAL','BLOCKED')

function Get-Multiset([string]$s, [string]$pattern) {
    $m = [regex]::Matches($s, $pattern)
    $l = New-Object System.Collections.Generic.List[string]
    foreach ($x in $m) { $l.Add($x.Value) }
    return (($l | Sort-Object) -join '|')
}
function Get-Tags([string]$s) { return Get-Multiset $s '<[^<>]*>' }
function Get-Placeholders([string]$s) { return (Get-Multiset $s '\{[^{}]*\}|%[sdifx]') + '#' + (Get-Multiset $s '\\[nrt]') }
function Get-Markers([string]$s) { return (Get-Multiset $s '\*[0-9][0-9.\-]*\*') + '#' + (Get-Multiset $s '&[^&]{1,30}&') }
function Get-Numbers([string]$s) { return Get-Multiset $s '[0-9]+' }
function Get-Core([string]$s) {
    if (-not $s) { return '' }
    $t = $s -replace '[\u064B-\u0652\u0640]', ''                       # harakat + tatweel
    $t = $t -replace '[\u0622\u0623\u0625]', ([string][char]0x0627)     # alef variants -> alef
    $t = $t -replace '\u0649', ([string][char]0x064A)                   # alef maqsura -> ya
    $t = $t -replace '\u0629', ([string][char]0x0647)                   # ta marbuta -> ha
    $t = [regex]::Replace($t, '(^|\s)\u0627\u0644', '$1')               # definite article at word start only
    return $t
}
# Glossary Arabic cells may list accepted renderings separated by '|'; a morphological stem match
# is accepted as well (plural / feminine / suffixed forms of the sanctioned rendering).
$arSuffixes = @(
    ([string][char]0x0627 + [char]0x062A),
    ([string][char]0x064A + [char]0x0646),
    ([string][char]0x0648 + [char]0x0646),
    ([string][char]0x0647),
    ([string][char]0x064A),
    ([string][char]0x0627),
    ([string][char]0x062A)
)
function Test-GlossaryArabic([string]$coreAr, [string]$termCell) {
    foreach ($v in ($termCell -split '\|')) {
        $c = Get-Core $v
        if (-not $c) { continue }
        if ($coreAr.IndexOf($c, [StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
        foreach ($sfx in $script:arSuffixes) {
            if ($c.EndsWith($sfx) -and (($c.Length - $sfx.Length) -ge 3)) {
                if ($coreAr.IndexOf($c.Substring(0, $c.Length - $sfx.Length), [StringComparison]::OrdinalIgnoreCase) -ge 0) { return $true }
            }
        }
        # word-level tolerance: every content word of the sanctioned rendering must appear in the
        # Arabic text as at least a 4-character prefix (covers case, tanween, plural and feminine
        # endings such as "البوليمر العصبي" vs "بوليمراً عصبياً")
        $okAll = $true; $n = 0
        foreach ($w in ($c -split '\s+')) {
            if ($w.Length -lt 3) { continue }
            $n++
            $pref = $w; if ($w.Length -ge 4) { $pref = $w.Substring(0, 4) }
            if ($coreAr.IndexOf($pref, [StringComparison]::OrdinalIgnoreCase) -lt 0) { $okAll = $false; break }
        }
        if ($n -gt 0 -and $okAll) { return $true }
    }
    return $false
}
function Has-ArabicLetter([string]$s) { return [bool]([regex]::IsMatch($s, '[\u0621-\u064A\u0660-\u0669\u066E-\u06D3\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]')) }

# --- glossary
$glossary = New-Object System.Collections.Generic.List[object]
$gl = [IO.File]::ReadAllLines($glossPath, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $gl.Count; $i++) {
    if (-not $gl[$i].Trim()) { continue }
    $f = $gl[$i] -split "`t"
    if ($f.Count -lt 2) { continue }
    $fl = ''
    if ($f.Count -ge 7) { $fl = $f[6].Trim() }
    $glossary.Add([pscustomobject]@{ term = $f[0]; arabic = $f[1]; flags = $fl })
}
# English compounds that look like a glossary term but are a different sense (data-driven).
$glossExceptions = New-Object System.Collections.Generic.List[object]
$gexPath = Join-Path $RepoRoot 'glossary\glossary_exceptions.tsv'
if (Test-Path $gexPath) {
    $gex = [IO.File]::ReadAllLines($gexPath, [Text.Encoding]::UTF8)
    for ($i = 1; $i -lt $gex.Count; $i++) {
        if (-not $gex[$i].Trim()) { continue }
        $f = $gex[$i] -split "`t"
        if ($f.Count -lt 2) { continue }
        $glossExceptions.Add([pscustomobject]@{ term = $f[0]; pattern = $f[1] })
    }
}

$lines = [IO.File]::ReadAllLines($masterPath, [Text.Encoding]::UTF8)
$nRows = 0; $nTranslated = 0
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$lenWarn = 0; $glossWarn = 0; $numWarn = 0; $glossExc = 0
$byScope = @{}
$statusCount = @{}
$catCount = @{}

for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -ne 13) { $errors.Add(("line {0}: {1} fields (expected 13)" -f ($i + 1), $f.Count)); continue }
    $nRows++
    $id = $f[0]; $file = $f[2]; $key = $f[4]; $en = $f[5]; $ar = $f[6]; $cat = $f[9]; $st = $f[10]
    $scope = 'other'; if ($file -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }

    if (-not $statusCount.ContainsKey($st)) { $statusCount[$st] = 0 }
    $statusCount[$st]++
    if ($allowedStatus -notcontains $st) { $errors.Add(("line {0}: Status '{1}' is not allowed" -f ($i + 1), $st)) }

    if (-not $ar.Trim()) {
        if ($st -in @('DRAFT', 'REVIEWED', 'APPROVED')) { $errors.Add(("line {0}: Status {1} but Arabic is empty" -f ($i + 1), $st)) }
        continue
    }
    $nTranslated++
    if (-not $byScope.ContainsKey($scope)) { $byScope[$scope] = 0 }
    $byScope[$scope]++
    if (-not $catCount.ContainsKey($cat)) { $catCount[$cat] = 0 }
    $catCount[$cat]++

    # hard checks
    if ((Get-Tags $ar) -ne (Get-Tags $en)) { $errors.Add(("line {0}: rich-text tag multiset differs (en=[{1}] ar=[{2}])" -f ($i + 1), (Get-Tags $en), (Get-Tags $ar))) }
    if ((Get-Placeholders $ar) -ne (Get-Placeholders $en)) { $errors.Add(("line {0}: placeholder/escape multiset differs (en=[{1}] ar=[{2}])" -f ($i + 1), (Get-Placeholders $en), (Get-Placeholders $ar))) }
    if ((Get-Markers $ar) -ne (Get-Markers $en)) { $errors.Add(("line {0}: fragment/speaker marker multiset differs (en=[{1}] ar=[{2}])" -f ($i + 1), (Get-Markers $en), (Get-Markers $ar))) }
    if ($ar -ceq $en) { $errors.Add(("line {0}: Arabic is identical to English (untranslated)" -f ($i + 1))) }
    if ($ar.IndexOf([char]0xFFFD) -ge 0) { $errors.Add(("line {0}: Arabic contains U+FFFD" -f ($i + 1))) }
    if ([regex]::IsMatch($ar, '[\u00D8\u00D9][\u0080-\u00BF]')) { $errors.Add(("line {0}: Arabic looks like UTF-8-read-as-Latin-1 mojibake" -f ($i + 1))) }
    if ([regex]::IsMatch($ar, '[\u0000-\u0008\u000B\u000C\u000E-\u001F]')) { $errors.Add(("line {0}: Arabic contains a control character" -f ($i + 1))) }
    if (-not (Has-ArabicLetter $ar)) { $errors.Add(("line {0}: Arabic contains no Arabic letter" -f ($i + 1))) }

    # warnings
    if ((Get-Numbers $ar) -ne (Get-Numbers $en)) { $numWarn++; if ($warnings.Count -lt 400) { $warnings.Add(("line {0}: number multiset differs (en=[{1}] ar=[{2}])" -f ($i + 1), (Get-Numbers $en), (Get-Numbers $ar))) } }
    if ($cat -eq 'UI' -and $en.Trim().Length -ge 12 -and $ar.Length -gt ($en.Length * 1.2)) { $lenWarn++; if ($warnings.Count -lt 400) { $warnings.Add(("line {0}: UI length {1} > 1.2 x {2}" -f ($i + 1), $ar.Length, $en.Length)) } }
    $coreAr = Get-Core $ar
    # the glossary check reads PROSE: markers, tags, bracket labels and channel handles are not words
    $enProse = $en
    $enProse = [regex]::Replace($enProse, '\*[0-9][0-9.\-]*\*', ' ')
    $enProse = [regex]::Replace($enProse, '&[^&]{1,30}&', ' ')
    $enProse = [regex]::Replace($enProse, '<[^<>]*>', ' ')
    $enProse = [regex]::Replace($enProse, '\[[^\]]{1,40}\]', ' ')
    $enProse = [regex]::Replace($enProse, '#[A-Za-z_][A-Za-z0-9_]*', ' ')
    foreach ($g in $glossary) {
        if ($g.term.Length -lt 4) { continue }
        $enPat = '(?i)(^|[^A-Za-z])' + [regex]::Escape($g.term) + '($|[^A-Za-z])'
        if ($g.flags -eq 'cs') { $enPat = [regex]::Replace($enPat, '^\(\?i\)', '') }   # case-sensitive term
        if ([regex]::IsMatch($enProse, $enPat)) {
            $excepted = $false
            foreach ($x in $glossExceptions) {
                if ($x.term -ieq $g.term -and $enProse.IndexOf($x.pattern, [StringComparison]::OrdinalIgnoreCase) -ge 0) { $excepted = $true; break }
            }
            if ($excepted) { $glossExc++; continue }
            if (-not (Test-GlossaryArabic $coreAr $g.arabic)) {
                $glossWarn++
                if ($warnings.Count -lt 400) { $warnings.Add(("line {0}: glossary term '{1}' -> '{2}' not found in Arabic" -f ($i + 1), $g.term, $g.arabic)) }
            }
        }
    }
}

$status = 'PASS'
if ($errors.Count -gt 0) { $status = 'FAIL' }

$r = New-Object System.Collections.Generic.List[string]
$r.Add('# Translation validation report')
$r.Add('')
$r.Add(('Generated: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')))
$r.Add(('Validator: scripts/validate_translation.ps1 (PowerShell twin of scripts/validate_translation.py)'))
$r.Add('')
$r.Add(('RESULT: **{0}**' -f $status))
$r.Add('')
$r.Add('| metric | value |')
$r.Add('|---|---|')
$r.Add(('| master rows | {0} |' -f $nRows))
$r.Add(('| rows with Arabic | {0} |' -f $nTranslated))
$r.Add(('| hard errors | {0} |' -f $errors.Count))
$r.Add(('| warnings (number/length/glossary) | {0} |' -f ($numWarn + $lenWarn + $glossWarn)))
$r.Add(('| - number-multiset warnings | {0} |' -f $numWarn))
$r.Add(('| - UI length warnings | {0} |' -f $lenWarn))
$r.Add(('| - glossary warnings | {0} |' -f $glossWarn))
$r.Add(('| - glossary compound exceptions applied | {0} |' -f $glossExc))
$r.Add('')
$r.Add('## Status distribution (whole master)')
$r.Add('')
$r.Add('| Status | rows |')
$r.Add('|---|---|')
foreach ($k in ($statusCount.Keys | Sort-Object)) { $r.Add(('| {0} | {1} |' -f $k, $statusCount[$k])) }
$r.Add('')
$r.Add('## Translated rows per scope')
$r.Add('')
$r.Add('| scope | rows with Arabic |')
$r.Add('|---|---|')
foreach ($k in ($byScope.Keys | Sort-Object { -$byScope[$_] })) { $r.Add(('| {0} | {1} |' -f $k, $byScope[$k])) }
$r.Add('')
$r.Add('## Translated rows per category')
$r.Add('')
$r.Add('| category | rows with Arabic |')
$r.Add('|---|---|')
foreach ($k in ($catCount.Keys | Sort-Object { -$catCount[$_] })) { $r.Add(('| {0} | {1} |' -f $k, $catCount[$k])) }
$r.Add('')
$r.Add('## Hard errors')
$r.Add('')
if ($errors.Count -eq 0) { $r.Add('None.') } else { foreach ($e in $errors) { $r.Add('- ' + $e) } }
$r.Add('')
$r.Add('## Warnings')
$r.Add('')
if ($warnings.Count -eq 0) { $r.Add('None.') } else { foreach ($w in $warnings) { $r.Add('- ' + $w) } }
$r.Add('')
[IO.File]::WriteAllLines($reportPath, $r, (New-Object Text.UTF8Encoding($false)))

if (-not $Quiet) {
    Write-Output ('VALIDATOR {0}: rows={1} translated={2} errors={3} warnings={4} (number {5} / length {6} / glossary {7}, exceptions {8})' -f $status, $nRows, $nTranslated, $errors.Count, ($numWarn + $lenWarn + $glossWarn), $numWarn, $lenWarn, $glossWarn, $glossExc)
    foreach ($e in ($errors | Select-Object -First 20)) { Write-Output ('  ERROR: ' + $e) }
    foreach ($w in ($warnings | Select-Object -First 15)) { Write-Output ('  warn : ' + $w) }
    Write-Output ('report: ' + $reportPath)
}
if ($errors.Count -gt 0) { exit 2 }
