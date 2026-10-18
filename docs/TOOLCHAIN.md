# Toolchain

All tools are downloaded from their **official GitHub release pages** only, verified by
SHA256, and installed **portably** under `tools/bin/` (gitignored). Nothing is installed
system-wide. The game folder is never touched.

Machine-readable lock file: `tools/tools.lock.json`.
Download/verify script: `scripts/setup_tools.ps1`.
Per-download computed hashes: `tools/bin/toolhashes.json`.

## Resolved versions (as of 2026-10-17)

| Tool | Version | License | Upstream digest verified | Role |
|------|---------|---------|--------------------------|------|
| FModel | aug-2026 | GPL-3.0 | YES (`ce1995fb...`) | Archive browser, asset inspection/export |
| LocResUtility | v2.1.1 | NO LICENSE FILE | YES (`ab0b8a4b...`) | LocRes export/import/merge CLI |
| UnrealLocres | 1.1.1 | NO LICENSE FILE | N/A (no upstream digest; local `b961927f...`) | Fallback LocRes CLI (unmaintained since 2021) |
| UAssetGUI | v1.1.0 | MIT | YES (`b7d75c08...`) | Cooked .uasset/.uexp inspect/modify |
| repak | v0.2.3 | Apache-2.0 | YES (`6720d602...`) | PAK pack/unpack CLI (preferred) |
| UnrealPak | n/a | Epic proprietary | n/a | NOT OBTAINED; fallback only if repak incompatible |

## Install locations (all under tools/bin, portable)

```
tools/bin/fmodel/FModel/...            (extracted from FModel.zip)
tools/bin/locresutility/...            (extracted from LocResUtilityCli-v2.1.1-win-x64.7z)
tools/bin/unreallocres/UnrealLocres.exe
tools/bin/uassetgui/UAssetGUI.exe
tools/bin/repak/repak.exe              (+ LICENSE-APACHE, LICENSE-MIT, README.md)
tools/bin/toolhashes.json              (computed hashes after download)
```

## License caveats (must be respected)

- **LocResUtility** and **UnrealLocres** publish **no license file**. Under default
  copyright they are all-rights-reserved. They are fine to *use locally* for this
  personal localization effort, but they must **not be redistributed** by this project,
  and we must not claim them as ours. This is recorded in THIRD_PARTY_LICENSES.md.
- **UnrealLocres** has been unmaintained since 2021 (release 1.1.1). Treat as fallback;
  prefer LocResUtility v2.1.1 as the primary LocRes CLI.
- **UnrealPak** is Epic proprietary (UE EULA) and must never be committed. It has not
  been obtained; repak is the preferred candidate and is expected to suffice.

## Runtime installs (user-approved, 2026-10-18)

| Component | Package (winget id) | Version | Source | License |
|-----------|--------------------:|---------|--------|---------|
| .NET Windows Desktop Runtime 8 | `Microsoft.DotNet.DesktopRuntime.8` | 8.0.32 | winget; installer hash verified against official Microsoft download (download.microsoft.com/windowsdesktop-runtime-8.0.32-win-x64.exe) | MIT (dotnet runtime) |
| .NET Runtime 8 (base) | `Microsoft.DotNet.Runtime.8` | 8.0.32 | winget; installer hash verified (download.microsoft.com/dotnet-runtime-8.0.32-win-x64.exe) | MIT (dotnet runtime) |
| Git for Windows | `Git.Git` | 2.55.0.5 | winget; installer hash verified (git-for-windows GitHub release) | GPL-2.0 |

Needed by: LocResUtility CLI (runtime 8; verified running after install — KI-008
resolved 2026-10-18) and FModel (desktop runtime 8, for GUI use).
UnrealLocres needs no install (runs on built-in .NET Framework).

`dotnet --list-runtimes` (2026-10-18):
```
Microsoft.NETCore.App 8.0.32        [C:\Program Files\dotnet\shared\Microsoft.NETCore.App]
Microsoft.WindowsDesktop.App 8.0.32 [C:\Program Files\dotnet\shared\Microsoft.WindowsDesktop.App]
```

## Verification status

- All five downloadable tools were fetched and their SHA256 matched the upstream GitHub
  release digest (where one is published). Status: **PASS**.
- UnrealLocres has no upstream digest, so its integrity is local-record-only (weaker
  guarantee). Flagged in tools.lock.json.
- repak pack/list/unpack/informat exercised on a V11 round-trip (Phase 7): **PASS**.
- UnrealLocres export/import exercised on LocRes v3 (Phase 5/7): **PASS**.
