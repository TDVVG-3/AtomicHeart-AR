"""Build the 1.0.2 language patch from the verified public p12 payload, without a game install."""
import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import uuid
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BASE_HASH = '813ac0e3b6c51034de33ae08109567a44bb3655e5d1aff39420999a0e94f00dd'
REP_HASH = 'b961927f92a8bca928d378a8430e5ea36fed300500b228b184b8d6b61ebb22a1'


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def run(*args):
    # repak otherwise writes data in parallel completion order, changing the PAK hash.
    subprocess.run(list(map(str, args)), check=True, env={**os.environ, "RAYON_NUM_THREADS": "1"})


def export(tool, source, output):
    run(tool, 'export', '-o', output, source)
    with output.open(encoding='utf-8-sig', newline='') as stream:
        rows = list(csv.DictReader(stream))
    values = {r['key']: r['source'] for r in rows}
    if len(values) != len(rows):
        raise ValueError('Duplicate localization keys')
    return values


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('base_zip', type=Path)
    args = parser.parse_args()
    if sha(args.base_zip) != BASE_HASH:
        raise ValueError('Not the approved upstream v1.0.0 p12 ZIP')
    tool = ROOT / 'tools/bin/unreallocres/UnrealLocres.exe'
    repak = ROOT / 'tools/bin/repak/repak.exe'
    if sha(repak) != 'fcd538e5994b9bb833622d425ae346f4e0692f02d4b0025114a559f9b6286022':
        raise ValueError('repak binary hash mismatch')
    if sha(tool) != REP_HASH:
        raise ValueError('UnrealLocres executable differs from the recorded official 1.1.1 asset')
    work = ROOT / 'build' / ('payload-1.0.2-' + uuid.uuid4().hex)
    payload = work / 'payload'
    payload.mkdir(parents=True)
    expected = {}
    for line in (ROOT / 'docs/releases/v1.0.0-SHA256SUMS.txt').read_text().splitlines():
        digest, name = line.split(maxsplit=1)
        expected[name.strip()] = digest
    with zipfile.ZipFile(args.base_zip) as archive:
        for name, digest in expected.items():
            matches = [i for i in archive.infolist() if i.filename.split('/')[-1] == name]
            if len(matches) != 1 or matches[0].file_size > 10_000_000:
                raise ValueError('Missing/duplicate/oversized payload entry: ' + name)
            target = payload / name
            target.write_bytes(archive.read(matches[0]))
            if sha(target) != digest:
                raise ValueError('Payload digest mismatch: ' + name)
    carrier = next(payload.glob('*carrier*.pak'))
    tree = work / 'tree'
    run(repak, 'unpack', '-o', tree, '-f', carrier)
    originals = {p.relative_to(tree): sha(p) for p in tree.rglob('*') if p.is_file()}
    fixes = json.loads((ROOT / 'docs/releases/translation-fixes-1.0.2.json').read_text(encoding='utf-8'))
    changed_files = set()
    for scope in sorted({f['scope'] for f in fixes}):
        relative = Path(f'AtomicHeart/Content/Localization/{scope}/ko-KR/{scope}.locres')
        source = tree / relative
        before = export(tool, source, work / (scope + '-before.csv'))
        after = dict(before)
        for fix in [f for f in fixes if f['scope'] == scope]:
            if before.get(fix['key']) != fix['before']:
                raise ValueError('Unexpected released translation: ' + fix['key'])
            after[fix['key']] = fix['after']
        data = work / (scope + '-import.csv')
        with data.open('w', encoding='utf-8', newline='') as stream:
            writer = csv.writer(stream)
            writer.writerow(['key', 'source', 'target'])
            writer.writerows((k, v, after[k]) for k, v in before.items())
        rewritten = work / (scope + '.locres')
        run(tool, 'import', '-o', rewritten, source, data)
        if export(tool, rewritten, work / (scope + '-after.csv')) != after:
            raise ValueError('Localization round-trip mismatch')
        shutil.copyfile(rewritten, source)
        changed_files.add(relative)
    for relative, digest in originals.items():
        if relative not in changed_files and sha(tree / relative) != digest:
            raise ValueError('Unrelated asset changed')
    carrier.unlink()  # Exact file in this run's private build directory.
    run(repak, 'pack', '--version', 'V11', '--mount-point', '../../../', tree, carrier)
    unpacked = work / 'roundtrip'
    run(repak, 'unpack', '-o', unpacked, '-f', carrier)
    actual = {p.relative_to(unpacked): sha(p) for p in unpacked.rglob('*') if p.is_file()}
    wanted = {p.relative_to(tree): sha(p) for p in tree.rglob('*') if p.is_file()}
    if actual != wanted:
        raise ValueError('PAK round-trip mismatch')
    catalog = [{'Name': p.name, 'Size': p.stat().st_size, 'Sha256': sha(p)} for p in sorted(payload.glob('*.pak'))]
    (payload / 'SHA256SUMS.txt').write_text(''.join(f"{f['Sha256']}  {f['Name']}\n" for f in catalog))
    dist = ROOT / 'dist'
    dist.mkdir(exist_ok=True)
    out = dist / 'AtomicHeart-AR-1.0.2-payload.zip'
    with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for p in sorted(payload.iterdir()):
            entry = zipfile.ZipInfo('payload/' + p.name, (2026, 10, 29, 0, 0, 0))
            archive.writestr(entry, p.read_bytes(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    (dist / (out.name + '.sha256')).write_text(sha(out) + '  ' + out.name + '\n')
    (dist / 'payload-1.0.2-catalog.json').write_text(json.dumps(catalog, indent=2))
    print(json.dumps({'zip': str(out), 'sha256': sha(out), 'catalog': catalog, 'changed_texts': len(fixes), 'verified_assets': len(actual)}, indent=2))


if __name__ == '__main__':
    main()
