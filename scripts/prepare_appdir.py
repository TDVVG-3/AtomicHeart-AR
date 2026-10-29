"""Stage the verified payload and redistribution notices in a freshly published AppDir."""
import hashlib
import json
from pathlib import Path
import shutil
import sys
import zipfile

repo = Path(__file__).resolve().parents[1]
archive, appdir = map(Path, sys.argv[1:])
with archive.open('rb') as stream:
    if hashlib.file_digest(stream, 'sha256').hexdigest() != '078bd3a295a7947d8deec249250608b3bb52cfbfcfc258b86ae33a5f74cc0eb5':
        raise ValueError('Unapproved translation archive')
payload = appdir / 'usr/bin/payload'
payload.mkdir()
checksums = repo / 'docs/releases/v1.0.2-payload-SHA256SUMS.txt'
with zipfile.ZipFile(archive) as source:
    for line in checksums.read_text().splitlines():
        digest, name = line.split()
        entries = [e for e in source.infolist() if e.filename == 'payload/' + name]
        if len(entries) != 1 or entries[0].file_size > 10_000_000 or Path(name).name != name:
            raise ValueError('Invalid archive entry: ' + name)
        data = source.read(entries[0])
        if hashlib.sha256(data).hexdigest() != digest:
            raise ValueError('Invalid payload hash: ' + name)
        (payload / name).write_bytes(data)
shutil.copy2(checksums, payload / 'SHA256SUMS.txt')
notices = appdir / 'usr/share/doc/atomicheart-ar'
notices.mkdir(parents=True)
for name in ('LICENSE', 'THIRD_PARTY_LICENSES.md', 'app/README.md', 'fonts/licenses/IBM-Plex-Sans-Arabic-OFL-1.1.txt'):
    shutil.copy2(repo / name, notices / Path(name).name)
shutil.copytree(repo / 'app/AtomicHeartAR.Linux/Packaging/licenses', notices / 'licenses')
assets = json.loads((repo / 'app/AtomicHeartAR.Linux/obj/project.assets.json').read_text())
package_paths = {lib['path'] for lib in assets['libraries'].values() if lib['type'] == 'package'}
for framework in assets['project']['frameworks'].values():
    for dependency in framework.get('downloadDependencies', []):
        version = dependency['version'].strip('[]').split(',')[0]
        package_paths.add(dependency['name'].lower() + '/' + version)
for package_path in sorted(package_paths):
    package = next((Path(root) / package_path for root in assets['packageFolders'] if (Path(root) / package_path).is_dir()), None)
    if package is None:
        raise FileNotFoundError(package_path)
    for file in package.iterdir():
        if file.is_file() and any(word in file.name.upper() for word in ('LICENSE', 'NOTICE', 'COPYING')):
            target = notices / 'licenses' / package_path.replace('/', '-')
            target.mkdir(exist_ok=True)
            shutil.copy2(file, target / file.name)
(notices / 'dependency-versions.txt').write_text('\n'.join(sorted(package_paths)) + '\n')
