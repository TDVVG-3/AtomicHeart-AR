#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo"
payload="${1:?Usage: bash scripts/package_appimage.sh dist/AtomicHeart-AR-1.0.2-payload.zip}"
stage="$(mktemp -d "$repo/build/appimage-XXXXXX")"
appdir="$stage/AtomicHeartAR.AppDir"
mkdir -p "$appdir/usr/bin" "$repo/dist"
export MSBuildEnableWorkloadResolver=false
dotnet publish app/AtomicHeartAR.Linux -c Release -r linux-x64 --self-contained true \
  -p:RestoreLockedMode=true -p:PublishReadyToRun=true -o "$appdir/usr/bin"
python3 scripts/prepare_appdir.py "$payload" "$appdir"
dotnet run --project app/AtomicHeartAR.Tests -c Release -- "$stage/tests" "$appdir/usr/bin/payload"
cp app/AtomicHeartAR.Linux/Packaging/AppRun "$appdir/AppRun"
cp app/AtomicHeartAR.Linux/Packaging/atomicheart-ar.desktop "$appdir/"
cp app/AtomicHeartAR.Linux/Packaging/atomicheart-ar.svg "$appdir/"
chmod +x "$appdir/AppRun" "$appdir/usr/bin/AtomicHeartAR"
curl -fL --retry 3 https://github.com/AppImage/appimagetool/releases/download/1.9.1/appimagetool-x86_64.AppImage -o "$stage/appimagetool"
curl -fL --retry 3 https://github.com/AppImage/type2-runtime/releases/download/20251108/runtime-x86_64 -o "$stage/runtime"
echo "ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0  $stage/appimagetool" | sha256sum -c -
echo "2fca8b443c92510f1483a883f60061ad09b46b978b2631c807cd873a47ec260d  $stage/runtime" | sha256sum -c -
chmod +x "$stage/appimagetool"
export ARCH=x86_64
"$stage/appimagetool" --appimage-extract-and-run --runtime-file "$stage/runtime" --comp zstd "$appdir" dist/AtomicHeart-AR-1.0.2-linux-x86_64.AppImage
chmod +x dist/AtomicHeart-AR-1.0.2-linux-x86_64.AppImage
(cd dist && sha256sum AtomicHeart-AR-1.0.2-linux-x86_64.AppImage > AtomicHeart-AR-1.0.2-linux-x86_64.AppImage.sha256)
