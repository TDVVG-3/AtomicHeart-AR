<#
  Shared filter for the dialogue program: a dump string counts as DIALOGUE/CUTSCENE
  TEXT only if it looks like prose, not a cooked-name/binary fragment. The SAME
  function is used by dialogue_finalize.ps1 (inventory counts) and
  dialogue_batch_apply.ps1 (master rows), so the coverage arithmetic is consistent.

  Rule (documented in DECISIONS DEC-019):
   - taken from the dump's UTF-16 section only (the ASCII section is names/keys),
   - trimmed length 8..1000,
   - must contain at least one space,
   - must contain >= 2 alphabetic words (runs of 3+ letters, Latin/Cyrillic/Arabic),
   - must NOT look like a path/name (no '/', '\', ':', '.uasset', '::', 'Property',
     'StructProperty', 'ObjectProperty', 'Function', 'DC_', 'BP_', 'ST_', 'LS_' alone),
   - duplicates within one asset collapse to one string (raw scans repeat).
  Rich-text tags (<tag .../>, <h>...</>, </>) are kept EXACTLY as part of the string.
#>
function Get-DialogueStrings([string]$dumpText) {
    $m = [regex]::Match($dumpText, '(?s)## UTF-16 strings\r?\n(.*?)(\r?\n\s*## ASCII strings|$)')
    if (-not $m.Success) { return @() }
    $raw = $m.Groups[1].Value -split "`r?`n"
    $words = [regex]'[A-Za-z\u0400-\u04FF\u0600-\u06FF\u0590-\u05FF]{3,}'
    $seen = @{}
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($s in $raw) {
        $t = $s.Trim()
        if ($t.Length -lt 8 -or $t.Length -gt 1000) { continue }
        if (-not $t.Contains(' ')) { continue }
        if ($t.Contains('/') -or $t.Contains('\') -or $t.Contains('::')) { continue }
        if ($t -match '\.(uasset|uexp|locres|png|wav|ogg|umap)$') { continue }
        if ($t -match '^(DC_|BP_|ST_|LS_|SK_|M_|T_|SM_)') { continue }
        if ($t -match 'Property|Function|Blueprint|Struct|Enum|Class|Asset|Package|Level|Component|Actor') { continue }
        if ($t.Contains(':')) { continue }
        if ($words.Matches($t).Count -lt 2) { continue }
        if ($seen.ContainsKey($t)) { continue }
        $seen[$t] = $true
        $out.Add($t)
    }
    return $out
}
