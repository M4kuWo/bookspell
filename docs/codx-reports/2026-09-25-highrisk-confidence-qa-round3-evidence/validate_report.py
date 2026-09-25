"""Validate report coverage and proposal preservation against saved hosted data."""
import json
import re
import subprocess
from collections import Counter
from pathlib import Path

here = Path(__file__).resolve().parent
root = here.parents[2]
data = json.loads((here / 'hosted.json').read_text())
rows = json.loads((here / 'recommendations.json').read_text())
report = (here.parent / '2026-09-25-highrisk-confidence-qa-round3.md').read_text()
assert len(rows) == len(data['pairs']) == 22
assert len({r['book_id'] for r in rows}) == len(data['books']) == 16
assert len({(r['book_id'], r['field']) for r in rows}) == 22
assert all(not b['archived'] for b in data['books'])
assert re.findall(r'^### (\d+)\.', report, re.M) == [str(i) for i in range(1, 23)]
for pair, row in zip(data['pairs'], rows):
    assert all(row[k] == v for k, v in pair.items())
    assert pair['value'] == pair['assigned_value']
    assert pair['confidence'] == pair['assigned_confidence'] == .4
    assert pair['source'] == 'ai_inferred'
    if row['outcome'] == 'genuinely-inconclusive':
        assert (row['proposed_value'], row['proposed_confidence']) == (pair['value'], pair['confidence'])
    elif row['outcome'] == 'confirmed-correct':
        assert row['proposed_value'] == pair['value']
        assert row['proposed_confidence'] > pair['confidence']
    else:
        assert row['outcome'] == 'likely-wrong'
        assert row['proposed_value'] != pair['value']
        assert row['proposed_confidence'] > pair['confidence']
counts = Counter(r['outcome'] for r in rows)
assert counts == {'genuinely-inconclusive': 14, 'confirmed-correct': 5, 'likely-wrong': 3}
for link in re.findall(r'\]\((2026-09-25-highrisk-confidence-qa-round3-evidence/[^)]+)\)', report):
    assert (here.parent / link).exists(), link
diff = subprocess.run(['git', 'diff', '--exit-code', 'HEAD', '--'], cwd=root, capture_output=True, text=True)
assert diff.returncode == 0, diff.stdout + diff.stderr
output = '\n'.join([
    'PASS: 22 unique assigned pairs; 16 distinct unarchived books.',
    'PASS: all hosted values/confidences match assignment; all sources ai_inferred.',
    'PASS: 3 value corrections, 5 confidence-only increases, 14 unchanged inconclusive pairs.',
    'PASS: every inconclusive value and confidence preserved exactly.',
    'PASS: 22 sequential finding headings and all local evidence links exist.',
    'PASS: git diff --exit-code HEAD -- returned 0 (no tracked-file changes).',
    'No scoring tests, hosted writes, commits or pushes performed.',
]) + '\n'
(here / 'validation.txt').write_text(output)
print(output, end='')
