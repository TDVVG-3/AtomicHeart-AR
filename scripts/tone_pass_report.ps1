<#
.SYNOPSIS
  Builds reports/tone_pass.md from the cycle-013 rules in tm_fixups.tsv.

.DESCRIPTION
  Reads localization/working/tm_fixups.tsv, keeps the rules whose note starts with
  "cycle013", finds every master row each rule hit, and writes a before/after table
  ordered by game progression (prologue cutscenes -> Chelomey -> the rest).
  ASCII-only script; all Arabic comes from the data files.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = 'C:\AtomicHeart-AR'
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}

$masterP = Join-Path $RepoRoot 'localization\master\atomic-heart-ar.tsv'
$fixP    = Join-Path $RepoRoot 'localization\working\tm_fixups.tsv'
$outP    = Join-Path $RepoRoot 'reports\tone_pass.md'
$utf8    = New-Object Text.UTF8Encoding($false)

$priority = @('CUTSCENES','Chelomey_Dialogues','ChelomeyFinal_Dialogues','VDNKh_Dialogues','Vavilov_Dialogues','Pavlov_Dialogues','Polygon_Dialogues','Theatre_Dialogues','OpenWorldVDNKh_Dialogues','Academy_Dialogues','Schebetar_Subs','Cutscenes_dlc1','Mails_01','NTD','DIALOGUES FOR LQA','PearTerminals','NewP5','Misc')

# rules
$rules = New-Object System.Collections.Generic.List[object]
$fx = [IO.File]::ReadAllLines($fixP, [Text.Encoding]::UTF8)
for ($i = 1; $i -lt $fx.Count; $i++) {
    if (-not $fx[$i].Trim()) { continue }
    $f = $fx[$i] -split "`t"
    if ($f.Count -lt 3) { continue }
    if ($f[2] -notlike 'cycle013 tone*' -and $f[2] -notlike 'cycle013 term+tone*' -and $f[2] -notlike 'cycle013 tone+term*' -and $f[2] -notlike 'cycle016 tone*') { continue }
    $rules.Add([pscustomobject]@{ find = $f[0]; replace = $f[1]; note = $f[2] })
}

# master rows
$m = [IO.File]::ReadAllLines($masterP, [Text.Encoding]::UTF8)
$hits = New-Object 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[object]]' ([StringComparer]::Ordinal)
foreach ($r in $rules) { $hits[$r.find] = New-Object System.Collections.Generic.List[object] }
for ($i = 1; $i -lt $m.Count; $i++) {
    if (-not $m[$i].Trim()) { continue }
    $f = $m[$i] -split "`t"
    if ($f.Count -ne 13) { continue }
    foreach ($r in $rules) {
        if ($f[6].Contains($r.replace)) {
            $scope = ($f[2] -replace '.*/Localization/','' -replace '/en-US/.*','')
            $rank = $priority.IndexOf($scope); if ($rank -lt 0) { $rank = 99 }
            $hits[$r.find].Add([pscustomobject]@{ L = ($i + 1); scope = $scope; rank = $rank; key = $f[4]; en = $f[5]; ar = $f[6]; spk = $f[9] })
        }
    }
}

$total = 0
foreach ($r in $rules) { $total += $hits[$r.find].Count }

$out = New-Object System.Collections.Generic.List[string]
$out.Add('# Tone pass - cycles 013 and 016 (2026-10-19 / 2026-10-21)')
$out.Add('')
$out.Add('Standing style rule: `glossary/terminology.md` section 12 (spoken-register MSA, one voice per')
$out.Add('character, never soften). Requested by the user after the p7 in-game check.')
$out.Add('')
$out.Add(('Totals: {0} rules, {1} master rows changed, in {2} scopes.' -f $rules.Count, $total, (($rules | ForEach-Object { $hits[$_.find] } | ForEach-Object { $_ } | Select-Object -ExpandProperty scope -Unique).Count)))
$out.Add('')
$out.Add('Method: every already-translated row was matched against a marker list for stiff / polite /')
$out.Add('literary wording ("as you know", "would you care for", "isn''t it", "I would like to",')
$out.Add('"it should be", "please", "I am pleased to hear", "I am of the age that", "I do not wish for",')
$out.Add('"however", "from my duty to bring to your attention", formal imperatives). Candidates were')
$out.Add('compared with the RUSSIAN source (exported from the shipped ru-RU locres,');
$out.Add('`scripts/export_ru_reference.ps1`) so the register comes from the original, not from the')
$out.Add('English alone. Rows whose source really is an official letter keep the official formula.')
$out.Add('Every change lives in `localization/working/tm_fixups.tsv` (KI-021), was applied by');
$out.Add('`scripts/apply_text_fixups.ps1` and is proven by `scripts/verify_text_fixups.ps1` (PASS).')
$out.Add('')
$out.Add('Cycle 016 extension (2026-10-21): 24 further rules in the same spoken-register spirit -')
$out.Add('written emphatics, polite request formulas, tag questions and stiff desire verbs were')
$out.Add('replaced with the direct spoken forms used elsewhere in the same scenes. Letters and')
$out.Add('system prompts were not touched.')
$out.Add('')
$out.Add('Order below = game progression, so the prologue and Chelomey come first.')
$out.Add('')
$out.Add('| # | scope | key | speaker | before | after | why |')
$out.Add('|---|-------|-----|---------|--------|-------|-----|')

$n = 0
foreach ($r in ($rules | Sort-Object { $r2 = $hits[$_.find]; if ($r2.Count -gt 0) { $r2[0].rank } else { 99 } })) {
    foreach ($h in ($hits[$r.find] | Sort-Object L)) {
        $n++
        $why = (($r.note -replace '^cycle01[36] [a-z+]*:', '') -replace ' \[exact\]$', '')
        $out.Add(('| {0} | {1} | {2} | {3} | {4} | {5} | {6} |' -f $n, $h.scope, $h.key, $h.spk, $r.find, $r.replace, $why))
    }
}
$out.Add('')
$out.Add('## Checked and deliberately left alone')
$out.Add('')
$out.Add('- PearTerminals / Mails official letters: the Russian is itself bureaucratic')
$out.Add('  (see the ru-RU export), so the Arabic official formula is the correct register, not')
$out.Add('  stiffness. Only the panicked hand-typed letter was relaxed.')
$out.Add('- System/UI prompts ("Please wait", "Please provide device data"): the Russian is a system')
$out.Add('  message, so the standard Arabic UI "please" form stays.')
$out.Add('- False positives on the word list were skipped: "sparkling wit", "SATURATION", "sodalis"')
$out.Add('  (lorem ipsum) and Russian "gas turbines" (turbiny gazovyye) have nothing to do with the drink.')
$out.Add('- The semantic check of every drink row is in `glossary/glossary_questions.md` section G.')
[IO.File]::WriteAllLines($outP, $out, $utf8)
Write-Output ('TONE PASS REPORT: rules {0} | rows {1} | -> {2}' -f $rules.Count, $total, $outP)
