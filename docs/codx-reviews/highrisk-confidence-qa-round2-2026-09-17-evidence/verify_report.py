"""Read-only verification of task output and tracked tree; writes evidence only."""
import hashlib
import json
import re
import subprocess
from collections import Counter
from pathlib import Path

base = Path(__file__).resolve().parent
root = base.parents[2]
report = base.with_name('2026-09-17-highrisk-confidence-qa-round2.md')
snapshot = json.loads((base / 'hosted.json').read_text())
rows = json.loads((base / 'recommendations.json').read_text())
text = report.read_text()
sections = re.findall(r'^### (\d+)\. (.*?)\n(.*?)(?=^### |^## |\Z)', text, re.M | re.S)
assert len(rows) == len(snapshot['pairs']) == len(sections) == 20
assert len(snapshot['books']) == 14
for row, pair, section in zip(rows, snapshot['pairs'], sections, strict=True):
    assert all(row[k] == v for k, v in pair.items())
    number, heading, body = section
    assert int(number) == row['number']
    assert heading == f"{row['title']} — {row['field']}"
    assert f"**Current: `{row['value']}` / {row['confidence']}." in body
    assert row['finding'] in body
    assert pair['assigned_confidence'] == pair['confidence']
    if row['finding'] in {'Genuinely inconclusive', 'Schema/format mismatch'}:
        assert row['proposed_value'] == row['value']
        assert row['proposed_confidence'] == row['confidence']
    else:
        assert f"{row['proposed_confidence']:.2f}" in body
        if row['finding'] == 'Confirmed correct':
            assert row['proposed_value'] == row['value']
        else:
            assert row['proposed_value'] != row['value']
    assert 'https://' in body

log = [f"HEAD: {subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()}",
       f"Hosted snapshot UTC: {snapshot['fetched_utc']}",
       'Report pair sections and JSON recommendations: 20 / 20',
       'Section current values/confidences match hosted snapshot: 20 / 20',
       'Assigned confidences match hosted snapshot: 20 / 20',
       'Unique exact title + author identities: 14 / 14',
       'Unchanged inconclusive/mismatch recommendations verified: 11 / 11',
       'Outcome counts: ' + json.dumps(dict(Counter(r['finding'] for r in rows)))]
for cmd in (['git', 'diff', '--exit-code'], ['git', 'diff', '--cached', '--exit-code']):
    result = subprocess.run(cmd, cwd=root, capture_output=True, text=True)
    assert result.returncode == 0 and not result.stdout, result.stdout
    log.append(' '.join(cmd) + ': exit 0; no output')

entries = subprocess.check_output(['git', 'ls-tree', '-r', '-z', 'HEAD'], cwd=root).split(b'\0')
mismatches = []
count = 0
for entry in entries:
    if not entry:
        continue
    metadata, name = entry.split(b'\t', 1)
    mode, kind, oid = metadata.split()
    assert kind == b'blob'
    path = root / name.decode()
    expected = subprocess.check_output(['git', 'cat-file', 'blob', oid.decode()], cwd=root)
    actual = path.read_bytes()
    count += 1
    if hashlib.sha256(expected).digest() != hashlib.sha256(actual).digest():
        mismatches.append(str(path))
assert not mismatches, mismatches
log.append(f'SHA-256 comparison of tracked files to HEAD: {count} files, 0 mismatches')
block = '```text\n' + '\n'.join(log) + '\n```'
if '<!-- FINAL_VERIFICATION -->' in text:
    report.write_text(text.replace('<!-- FINAL_VERIFICATION -->', block))
assert '<!--' not in report.read_text()
(base / 'execution.txt').write_text('\n'.join(log) + '\n')
files = sorted(p for p in base.iterdir() if p.is_file() and p.name != 'SHA256SUMS')
(base / 'SHA256SUMS').write_text(''.join(hashlib.sha256(p.read_bytes()).hexdigest() + '  ' + p.name + '\n' for p in files))
print('\n'.join(log))
