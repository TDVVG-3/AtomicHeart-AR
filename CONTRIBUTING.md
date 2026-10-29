# Contributing

AtomicHeart-AR is open source. Contributions to the code, documentation, validation
scripts, and translation workflow are welcome.

## Baseline rules

1. The game installation is read-only. Never write to, move, or delete game files outside
   `Paks\~mods`.
2. Never modify or distribute EXE, DLL, DRM, Steam, or stock pak files.
3. Never commit game PAKs, original archives, decrypted game assets, or unlicensed tool
   binaries. Third-party tools are fetched from their official upstream releases; see
   `tools/tools.lock.json` and `THIRD_PARTY_LICENSES.md`.
4. Never remove the English source text from the master database or reference files.
5. All code, comments, filenames, and script output are in English. Arabic belongs in
   UTF-8 data files and documentation examples.
6. Do not hard-code Arabic or Cyrillic literals in PowerShell 5.1 scripts; load them from
   UTF-8 data files.
7. Record major technical decisions in `DECISIONS.md`.
8. Never claim a feature works without test evidence: use `PASS`, `FAIL`, `PARTIAL`,
   `BLOCKED`, or `NOT TESTED`.
9. A change to translation data goes through the TM/fixup workflow; do not hand-edit
   generated master rows to hide a gate failure.
10. Every behavior change must include the relevant validator, glyph, audit, or
    install/rollback evidence.

## Translation contributions

The master database is `localization/master/atomic-heart-ar.tsv`. It is a UTF-8 TSV with
the English source preserved. Translation changes should be proposed as rules in
`localization/working/tm_fixups_p12.tsv` (or a new versioned fixup file) and applied with
the repository scripts. Do not reorder or delete rows.

Before opening a pull request:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate_translation.ps1 -Master build\variants\atomic-heart-ar_p12.tsv
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\p12_gate_all.ps1
```

Attach or link the relevant report from `reports/`.

## Code contributions

The Windows and Linux desktop applications live under `app/`. Run their shared filesystem
safety checks before changing installation behavior:

```powershell
dotnet run --project app/AtomicHeartAR.Tests -c Release -- C:\temp\ah-ar-tests
```

Keep production payload hashes tied to the approved versioned release catalog. Never add PAKs or
application build outputs to Git. See `app/README.md` for build and packaging details.

- Keep changes consistent with the existing PowerShell/Python style.
- Prefer small, reproducible scripts over manual edits.
- Never put credentials, tokens, local usernames, or machine-specific secrets in the
  repository. `config/game.json` contains a local install path and is not a secret.
- Do not add large binary files to Git. Build outputs live under `build/` and are ignored.

## Reporting issues

Include the game build, the installed variant, the relevant report, and the exact command
that reproduces the problem. For subtitle timing issues, use the template in
`reports/stack_test_guide.md`.

## License

By contributing, you agree that your code and documentation contributions are licensed
under the repository's MIT license. Game content remains the property of Mundfish and its
licensors.
