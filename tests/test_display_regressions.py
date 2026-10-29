"""Run with Python 3 + Windows PowerShell; no game files or extra packages needed."""
import csv
import os
from pathlib import Path
import re
import struct
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
PS = os.environ.get('POWERSHELL_EXE', 'powershell')
HEADER = 'ID Container File Namespace Key SourceEnglish Arabic Context Speaker Category Status Notes SourceHash'.split()
MARKER = re.compile(r'\*([\d.]+)(?:-([\d.]+))?\*')


def row(en, ar, index=1):
    return [str(index), 'locres', '/Localization/test/en-US/test.locres', '',
            f'/key{index}', en, ar, '', '', 'Dialogue', 'DRAFT', '', 'hash']


def write_tsv(path, rows):
    path.write_text('\n'.join('\t'.join(r) for r in [HEADER] + rows) + '\n', encoding='utf-8')


def run_script(name, *args):
    return subprocess.run([PS, '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
                           str(ROOT / 'scripts' / name), *map(str, args)],
                          capture_output=True, encoding='utf-8', errors='replace')


class DisplayRegressionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='atomic-heart-display-')
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)

    def caps(self, ar, clip=2, mode='H1H2H3', h3=1, audit_extra=''):
        source, output = self.base / 'in.tsv', self.base / 'out.tsv'
        write_tsv(source, [row('original', ar)])
        audit = self.base / 'audit.tsv'
        audit.write_text(f'line\tclip_seconds\th3_final_following\n2\t{clip}\t{h3}\n' + audit_extra)
        args = ('-InTsV', source, '-OutTsV', output, '-Mode', mode, '-AuditRows', audit)
        result = run_script('apply_subtitle_caps.ps1', *args)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        fields = output.read_text(encoding='utf-8-sig').splitlines()[1].split('\t')
        self.assertEqual(fields[:6] + fields[7:], row('original', ar)[:6] + row('original', ar)[7:])
        self.assertEqual(MARKER.sub('', fields[6]), MARKER.sub('', ar))
        # A second run must not keep shifting pages or rewrite visible text.
        again = self.base / 'again.tsv'
        result = run_script('apply_subtitle_caps.ps1', '-InTsV', output, '-OutTsV', again,
                            '-Mode', mode, '-AuditRows', audit)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(output.read_bytes(), again.read_bytes())
        return fields[6]

    def assert_clip_bound(self, text, clip):
        start, end = MARKER.findall(text)[-1]
        self.assertGreater(float(end), float(start))
        self.assertLess(float(end) * 60, clip)

    def test_markerless_long_text_caps_at_two_seconds(self):
        self.assert_clip_bound(self.caps('ب' * 300), 2)

    def test_repeated_audit_rows_keep_longest_clip(self):
        result = self.caps('ب' * 300, audit_extra='2\t1\t1\n')
        end = float(MARKER.findall(result)[-1][1]) * 60
        self.assertGreater(end, 1.99)
        self.assertLess(end, 2)

    def test_final_singleton_caps_at_two_seconds(self):
        self.assert_clip_bound(self.caps('*0.01*' + 'ب' * 300), 2)

    def test_existing_end_caps_at_two_seconds(self):
        self.assert_clip_bound(self.caps('*0-0.5*نص'), 2)

    def test_short_clip_does_not_round_past_end(self):
        self.assert_clip_bound(self.caps('نص', clip=0.01), 0.01)

    def test_start_after_clip_retained_for_review(self):
        text = '*0.1*نص'
        self.assertEqual(self.caps(text), text)

    def test_missing_duration_leaves_markerless_text(self):
        self.assertEqual(self.caps('نص', clip=0), 'نص')

    def test_duplicate_group_is_strictly_ordered(self):
        result = self.caps('*0.1*أ*0.1*ب*0.1*ت*0.101*ث', clip=20)
        starts = [float(start) for start, _ in MARKER.findall(result)]
        self.assertTrue(all(a < b for a, b in zip(starts, starts[1:])), result)

    def test_overlap_between_close_starts(self):
        result = self.caps('*0.1-0.2*أ*0.1006*ب', clip=20, mode='H2')
        first, second = MARKER.findall(result)
        self.assertLess(float(first[0]), float(first[1]))
        self.assertLess(float(first[1]), float(second[0]))

    def test_malformed_numeric_marker_is_not_partially_repaired(self):
        text = '*0.01-0.03*ب*0.-39.50*ب*0.51-1.2*ب'
        self.assertEqual(self.caps(text, clip=59.2), text)

    def test_descending_track_is_not_guessed(self):
        text = '*0.2*أ*0.1*ب'
        self.assertEqual(self.caps(text, clip=20), text)

    def test_full_master_preserves_text_and_bounds_every_changed_row(self):
        source = ROOT / 'localization/master/atomic-heart-ar.tsv'
        audit = ROOT / 'reports/subtitle_stack_rows_p12.tsv'
        output, again = self.base / 'candidate.tsv', self.base / 'again.tsv'
        for before, after in [(source, output), (output, again)]:
            result = run_script('apply_subtitle_caps.ps1', '-InTsV', before, '-OutTsV', after,
                                '-Mode', 'H1H2H3', '-AuditRows', audit)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(output.read_bytes(), again.read_bytes())
        self.assertIn('rows changed 0', result.stdout)
        clips = {}
        with audit.open(encoding='utf-8-sig') as stream:
            for record in csv.DictReader(stream, delimiter='\t'):
                number = int(record['line'] or 0)
                clips[number] = max(clips.get(number, 0), float(record['clip_seconds'] or 0))
        old_rows = source.read_text(encoding='utf-8-sig').splitlines()
        new_rows = output.read_text(encoding='utf-8-sig').splitlines()
        self.assertEqual(len(old_rows), len(new_rows))
        changed = 0
        for number, (old, new) in enumerate(zip(old_rows, new_rows), 1):
            if old == new:
                continue
            changed += 1
            x, y = old.split('\t'), new.split('\t')
            self.assertEqual(x[:6] + x[7:], y[:6] + y[7:], number)
            self.assertEqual(MARKER.sub('', x[6]), MARKER.sub('', y[6]), number)
            markers = MARKER.findall(y[6])
            for a, b in zip(markers, markers[1:]):
                self.assertLess(float(a[0]), float(b[0]), number)
                if a[1]:
                    self.assertLess(float(a[0]), float(a[1]), number)
                    self.assertLess(float(a[1]), float(b[0]), number)
            if markers and markers[-1][1] and clips.get(number, 0) > 0:
                self.assertLess(float(markers[-1][1]) * 60, clips[number], number)
        self.assertGreater(changed, 0)

    def glyph(self, rows, exempt=True, missing_face=None, missing_ascii=False, extra=()):
        source = self.base / 'master.tsv'
        write_tsv(source, [row(en, ar, i) for i, (en, ar) in enumerate(rows)])
        fontroot = self.base / 'fonts'
        faces = [('UI', n) for n in ('BlenderPro-Medium', 'BlenderPro-Book', 'BlenderPro-Bold', 'BrutalType')]
        faces += [('NTD', n) for n in ('Gotham-Black', 'Gotham-BookItalic')]
        for folder, name in faces:
            points = set(range(0x20, 0x7F)) | {ord('ب')} | set(extra)
            if name == missing_face:
                points.remove(ord('ب'))
            if missing_ascii:
                points.remove(ord('Z'))
            # Minimal format-12 cmap fixture. It is parser input, not a renderable game font.
            groups = b''.join(struct.pack('>III', cp, cp, 1) for cp in sorted(points))
            sub = struct.pack('>HHIII', 12, 0, 16 + len(groups), 0, len(points)) + groups
            cmap = struct.pack('>HHHHI', 0, 1, 3, 10, 12) + sub
            sfnt = struct.pack('>IHHHH', 0x10000, 1, 0, 0, 0)
            sfnt += struct.pack('>4sIII', b'cmap', 0, 28, len(cmap)) + cmap
            path = fontroot / 'AtomicHeart' / 'Content' / 'Development' / folder / 'Fonts' / (name + '.ufont')
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(sfnt)
        report = self.base / 'glyph.md'
        args = ['-MasterTsV', source, '-PayloadRoot', fontroot, '-ReportPath', report]
        if exempt:
            args += ['-AllowSourceInheritedNonLatin']
        result = run_script('glyph_gate.ps1', *args)
        self.assertIn(result.returncode, (0, 2), result.stdout + result.stderr)
        return result.returncode, report.read_text(encoding='utf-8-sig')

    def test_cross_row_source_does_not_exempt_missing_glyph(self):
        code, report = self.glyph([('Ж', 'ب'), ('plain', 'بЖ')])
        self.assertEqual(code, 2)
        self.assertIn('/key1', report)

    def test_inherited_in_every_row_requires_opt_in(self):
        self.assertEqual(self.glyph([('Ж', 'بЖ')])[0], 0)
        self.assertEqual(self.glyph([('Ж', 'بЖ')], exempt=False)[0], 2)

    def test_one_new_occurrence_blocks_inherited_exemption(self):
        self.assertEqual(self.glyph([('Ж', 'بЖ'), ('plain', 'بЖ')])[0], 2)

    def test_hud_face_missing_glyph_fails_even_when_union_covers(self):
        self.assertEqual(self.glyph([('plain', 'ب')], missing_face='Gotham-Black')[0], 2)

    def test_unused_basic_latin_glyph_must_be_available(self):
        self.assertEqual(self.glyph([('plain', 'ب')], missing_ascii=True)[0], 2)

    def test_supplementary_character_is_one_codepoint(self):
        self.assertEqual(self.glyph([('plain', 'ب😀')], extra=(0x1F600,))[0], 0)


if __name__ == '__main__':
    unittest.main(verbosity=2)
