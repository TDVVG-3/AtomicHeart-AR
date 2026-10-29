# AtomicHeart-AR · 1.0.2

Arabic installer for Windows x64 and Linux x86_64 (Steam / Proton).
Full packages include the corrected translation, font v3, tips x150 and .NET.
The game itself is not included.

## Windows

Extract `AtomicHeart-AR-1.0.2-win-x64.zip` and launch `AtomicHeartAR.exe`.
Keep the adjacent `payload/` folder.

## Linux / AppImage

Ubuntu 22.04 or compatible glibc 2.35+ desktop, x86_64, X11/XWayland,
Fontconfig and an Arabic-capable font (DejaVu Sans) are required.

```sh
chmod +x AtomicHeart-AR-1.0.2-linux-x86_64.AppImage
./AtomicHeart-AR-1.0.2-linux-x86_64.AppImage
```

Launch in desktop mode. The app runs natively; the game uses Steam / Proton.
Steam Deck hardware has not been tested. No separate .NET installation is needed.
If FUSE mounting is unavailable, add `--appimage-extract-and-run`.
Extraction uses additional temporary disk space and starts more slowly.
The pinned static runtime does not require a separate libfuse2 installation.

## Install / update / remove

1. Close Atomic Heart and choose its folder containing `AtomicHeart.exe`.
2. Full packages automatically select their bundled `payload/`.
3. Check files, then install/update. Select **Korean** for the game's text language.
4. To remove, close the game and use the removal button.

Eight Arabic text values are corrected in the new payload. Expected hashes are
fixed in `ModInstaller.cs` and `docs/releases/v1.0.2-payload-SHA256SUMS.txt`.
The carrier keeps its p12 filename for updates; its hash distinguishes versions.
Approved p12 installs can be upgraded, including manual installs. Old files are
backed up before replacement; unknown files and competing carriers block updates.
Experimental p12g is not included.

Only the fixed PAK set and app manifest under `Paks/~mods` are managed.
Other mods and legacy manifests are preserved. Caught failures roll back;
failed rollback keeps a recovery directory and reports its path. Power loss
recovery is not automatic: verify/repair before starting the game.
Linux Steam root symlinks are resolved; internal mods/payload symlinks are refused.

No root/admin elevation, service, telemetry or automatic updater is used.
The app makes no network requests; project links open the browser.
The Windows binary is unsigned. Hashing and copying run off the UI thread.
Windows WPF and Linux Avalonia share the same installation engine.

## Build and verify

Requires .NET 8 SDK; Linux packaging also needs Python 3, curl and
desktop-file-utils. The Windows payload builder obtains repak 0.2.3 and
UnrealLocres 1.1.1 from their official releases and checks the inputs.
Build tools are not redistributed in the application.

```powershell
python scripts/build_payload_1_0_2.py C:\downloads\AtomicHeart-AR-1.0.0-p12.zip
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/package_installer.ps1 -PayloadZip dist/AtomicHeart-AR-1.0.2-payload.zip
```

```sh
mkdir -p build
bash scripts/package_appimage.sh dist/AtomicHeart-AR-1.0.2-payload.zip
dotnet run --project app/AtomicHeartAR.Tests -c Release -- build/test-fixtures
```

The [CI workflow](../.github/workflows/release-1.0.2.yml) builds both packages,
tests safe installation in fake game folders with the real payload, checks
subtitle/glyph regressions and renders the packaged Linux window.
Real game rendering requires a separate manual test.

Linux notices and dependency versions are under `usr/share/doc/atomicheart-ar/`.
Inspect with `--appimage-extract`. Runtime source and build instructions:
[AppImage/type2-runtime 20251108](https://github.com/AppImage/type2-runtime/tree/dd6cebedcbddde9c82f89b011e8e1d40b6e43868).
The runtime is unmodified and replaceable by repackaging the extracted AppDir.
