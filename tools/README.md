# tools/

This folder holds the third-party toolchain (unpacked, portable) and the machine
readable lock file. Binaries live under `tools/bin/` and are **gitignored**.

## Layout

```
tools/
  README.md            this file
  tools.lock.json      every tool: version, official URL, license, sha256, role
  bin/                 extracted binaries (gitignored; never committed)
    toolhashes.json    hashes computed at download time by setup_tools.ps1
    fmodel/            FModel (GUI; browse/export game assets)
    locresutility/     LocResUtilityCli (locres export/import CLI)
    unreallocres/      UnrealLocres.exe (fallback locres CLI)
    uassetgui/         UAssetGUI (cooked uasset inspector; also bundled retoc/repak)
    repak/             repak.exe (PAK list/unpack/pack CLI; primary packer)
```

## How to obtain (reproducibly)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/setup_tools.ps1
```

The script downloads each asset from the **official GitHub release URL** recorded in
`tools/tools.lock.json`, computes SHA256, and compares it with the upstream digest
where one exists. It never installs anything system-wide and never touches the game
folder.

## Redistribution policy

- GPL-3.0 (FModel), MIT (UAssetGUI), Apache-2.0/MIT (repak) are redistributable under
  their terms; related license texts accompany the unpacked tool (e.g.
  `tools/bin/repak/LICENSE-*`).
- **LocResUtility and UnrealLocres have no license file.** They may be used locally for
  this project but MUST NOT be redistributed, copied into `dist/`, or included in any
  release artifact. See `THIRD_PARTY_LICENSES.md`.
- UnrealPak (Epic proprietary) is not vendored; do not commit it if you obtain it
  legitimately. repak is the preferred packer.

## Notes

- `repak` depends on .NET? No — repak is a native Rust binary.
- FModel is .NET (needs the .NET runtime on first run).
- LocResUtility-clis are .NET self-contained (no install needed).
