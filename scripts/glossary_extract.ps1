<#
.SYNOPSIS
  Phase 0 (translation program): extracts repeated name/term candidates from the master
  English source column into reports/glossary_candidates.tsv, for human review.

.DESCRIPTION
  Heuristic (evidence only, no language model):
   - ACRONYM: an ALL-CAPS token of 2+ letters (NORA, NTD, HUD, ...).
   - PROPER: a run of 1..3 Capitalised words ("Vavilov Complex"), allowing inner
     apostrophes/hyphens (CHAR-les, Poly-3).
  Every occurrence is counted per row (a term counted once per row it appears in) and
  the number of distinct scopes. Ordinary English words that merely start a sentence are
  filtered with a stop list, and terms appearing only once are dropped unless they are
  ALL-CAPS. Output is sorted by count desc.

  This file only proposes candidates; the curated glossary lives in glossary/glossary.tsv.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}
trap { Write-Output ('ERROR at line ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.Exception.Message); exit 1 }

$master = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$outPath = Join-Path $RepoRoot 'reports\glossary_candidates.tsv'

# words that are ordinary English (or engine/UI noise) and must not become glossary terms
$stop = @{}
foreach ($w in @(
    'The','This','A','An','And','Or','But','If','In','On','At','To','From','For','With','Without','By','Of','Is','Are','Was','Were','Be','Been','Being',
    'It','Its','He','She','They','We','You','I','His','Her','Their','Our','Your','My','That','These','Those','There','Here','When','Where','Which','Who','What','Why','How',
    'Not','No','Yes','All','Any','Some','Every','Each','Both','More','Most','Less','Least','Other','Another','Such','Then','Than','Now','New','Old','Next','Last','First','Second','Third',
    'Left','Right','Up','Down','Top','Bottom','Back','Front','Open','Close','Closed','Start','End','Stop','Go','Come','Take','Put','Get','Set','Use','Used','Press','Hold','Release','Click','Select',
    'Enter','Exit','Menu','Options','Settings','Save','Load','Game','Games','Continue','Cancel','Apply','Ok','Okay','Done','Yes','No','None','Level','Levels','Item','Items','Skill','Skills','Weapon','Weapons',
    'Mission','Missions','Quest','Quests','Objective','Objectives','Player','Enemy','Enemies','Damage','Health','Energy','Time','Day','Night','Year','Years','Hour','Hours','Minute','Minutes','Second','Seconds',
    'You','Your','Their','They','Them','This','That','These','Those','Who','What','When','Where','Why','How','Because','Before','After','During','While','Until','Since','About','Above','Below','Under','Over',
    'One','Two','Three','Four','Five','Six','Seven','Eight','Nine','Ten','Hundred','Thousand','Million','Billion','Percent','Please','Sorry','Thanks','Thank','Hello','Hey','Hi','Goodbye','Good','Bad','Best','Worst',
    'Also','Even','Just','Only','Very','Much','Many','Few','Little','Big','Small','Large','Long','Short','High','Low','Fast','Slow','Hard','Easy','Soft','Strong','Weak',
    'Can','Could','Will','Would','Shall','Should','May','Might','Must','Do','Does','Did','Have','Has','Had','Make','Made','Let','Say','Said','See','Saw','Know','Knew','Think','Thought',
    'Man','Men','Woman','Women','Boy','Girl','People','Person','Thing','Things','Way','Ways','Place','Places','World','Life','Death','War','Peace','Love','Hate','God','Hell','Damn',
    'Name','Names','Text','Texts','Note','Notes','Data','Type','Types','Value','Values','Number','Numbers','List','Lists','Field','Fields','True','False','Null','None','Empty'
)) { $stop[$w] = $true }

$lines = [IO.File]::ReadAllLines($master, [Text.Encoding]::UTF8)
$termRows = @{}     # term -> row count
$termScopes = @{}   # term -> hashset of scopes
$termSample = @{}   # term -> first sample (trimmed, <= 90 chars)

for ($i = 1; $i -lt $lines.Count; $i++) {
    if (-not $lines[$i].Trim()) { continue }
    $f = $lines[$i] -split "`t"
    if ($f.Count -lt 13) { continue }
    $en = $f[5]
    if (-not $en) { continue }
    $file = $f[2]
    $scope = 'other'
    if ($file -match '/Localization/(.+?)/en-US/') { $scope = $Matches[1] }

    $found = New-Object 'System.Collections.Generic.HashSet[string]'
    # ALL-CAPS tokens (2..12 letters, optional digits/&)
    foreach ($m in [regex]::Matches($en, '\b[A-Z][A-Z0-9&]{1,11}\b')) { [void]$found.Add($m.Value) }
    # Proper-name runs (1..3 capitalised words, allow hyphen/apostrophe inside a word)
    foreach ($m in [regex]::Matches($en, "\b[A-Z][a-z]+(?:['\-][A-Za-z]+)?(?:\s+[A-Z][a-z]+(?:['\-][A-Za-z]+)?){0,2}\b")) {
        $t = $m.Value
        $first = ($t -split '\s+')[0]
        if ($stop.ContainsKey($first) -and -not ($t -match '\s')) { continue }
        if ($stop.ContainsKey($t)) { continue }
        [void]$found.Add($t)
    }
    foreach ($t in $found) {
        if (-not $termRows.ContainsKey($t)) { $termRows[$t] = 0; $termScopes[$t] = New-Object 'System.Collections.Generic.HashSet[string]' }
        $termRows[$t]++
        [void]$termScopes[$t].Add($scope)
        if (-not $termSample.ContainsKey($t)) {
            $s = $en.Trim()
            if ($s.Length -gt 90) { $s = $s.Substring(0, 90) + '...' }
            $termSample[$t] = $s
        }
    }
}

$rows = New-Object System.Collections.Generic.List[object]
foreach ($t in $termRows.Keys) {
    $c = $termRows[$t]
    $isCaps = ($t -cmatch '^[A-Z0-9&]+$')
    if ($c -lt 2 -and -not $isCaps) { continue }
    $rows.Add([pscustomobject]@{ term = $t; count = $c; scopes = $termScopes[$t].Count; sample = $termSample[$t] })
}
$sorted = $rows | Sort-Object @{ Expression = { -$_.count } }, term

$out = New-Object System.Collections.Generic.List[string]
$out.Add('term' + "`t" + 'rows' + "`t" + 'scopes' + "`t" + 'sample')
foreach ($r in $sorted) { $out.Add($r.term + "`t" + $r.count + "`t" + $r.scopes + "`t" + $r.sample) }
[IO.File]::WriteAllLines($outPath, $out, (New-Object Text.UTF8Encoding($false)))
Write-Output ('[glossary] candidates: {0}  ->  {1}' -f $sorted.Count, $outPath)
Write-Output '--- top 80 candidates'
$sorted | Select-Object -First 80 | ForEach-Object { '  ' + $_.count.ToString().PadLeft(5) + '  [' + $_.scopes.ToString().PadLeft(2) + ' scopes]  ' + $_.term }
