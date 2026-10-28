# AtomicHeart-AR Windows installer · 1.0.1

Arabic desktop installer for the approved `p12 + font v3 + tips_x150` set.
The full release ZIP includes the approved p12 localization PAKs in `payload/`.
A source build and the optional AppOnly ZIP require a separate payload download.
The application never includes the game itself.

## Use

1. Extract the application ZIP and run `AtomicHeartAR.exe` on Windows x64.
2. Close Atomic Heart. Select the game root containing `AtomicHeart.exe`.
3. The full ZIP selects its adjacent `payload/` folder automatically. For an
   AppOnly/source build, select the extracted approved localization package. The expected hashes are fixed in `ModInstaller.cs`
   and match `docs/releases/v1.0.0-SHA256SUMS.txt`.
4. Check the files and install. Select **Korean** for the game's text language.

The app writes its fixed PAK set and its own manifest only under `Paks/~mods`.
Unrelated mods and the older scripts' manifest are preserved. Exact matching
existing PAKs can be adopted by installing them through the application.
Modified same-name files and invalid manifests block changes. Caught failures
roll back; if rollback itself fails, recovery files are retained and their path
is shown in the activity log. Power-loss recovery is not automatic: reopen the
application and verify/repair before launching the game.

The application runs with the current user's permissions. The portable EXE is
not code-signed. No network request is made by the installer; GitHub links open
the user's browser. It does not execute the legacy PowerShell installers.

## Build and verify

Requires Windows and the .NET 8 SDK. There are no third-party application packages.

```powershell
dotnet run --project app/AtomicHeartAR.Tests -c Release -- C:\temp\atomicheart-tests
dotnet publish app/AtomicHeartAR.Installer -c Release -r win-x64 --self-contained true -o build/app-1.0.1
```

Run tests with a disposable output directory. Test fixtures use fake payloads
and fake game folders; they do not require the game. The production app always
uses the approved PAK hashes. Real game rendering is a separate manual check.
