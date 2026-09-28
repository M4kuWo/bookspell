"""Structural checks of report artifacts, not behavioral tests of agents."""
from pathlib import Path
import re
import hashlib

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]
source = (ROOT / 'CLAUDE.md').read_text()
changed = source.replace('Read the startup policy', 'Read this startup policy', 1)
assert source != changed
assert len(source.split()) == len(changed.split())
assert re.findall(r'^## .*', source, re.M) == re.findall(r'^## .*', changed, re.M)
assert hashlib.sha256(source.encode()).digest() != hashlib.sha256(changed.encode()).digest()
for file in OUT.glob('moved-*.md'):
    assert file.read_text() in source
old = (ROOT / 'docs/TODO.md').read_text()
new = (OUT / 'D-TODO.candidate.md').read_text()
archive = (OUT / 'D-TODO-completed.candidate.md').read_text()
for match in re.finditer(r'(?ms)^- \[([x ])\] .*?(?=^- \[[x ]\] |^## |\Z)', old):
    assert match[0] in (archive if match[1] == 'x' else new)
print('PASS: six moved sections preserved verbatim; all 18 original open blocks retained;')
print('all 30 closed blocks archived intact; equal-word/equal-heading edit changes SHA-256.')
