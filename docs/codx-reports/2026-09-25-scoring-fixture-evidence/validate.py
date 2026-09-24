"""Task 18 evidence: clean run and isolated series-gate mutation.

Run with Python 3.12. No databases, credentials, installed packages, or network.
"""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
TEST = Path('scripts/scoring/tests/test_fixtures.py')


def hashes():
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in (ROOT / 'scripts/scoring').rglob('*.py')}


def run(root, label):
    command = [sys.executable, '-S', str(TEST)]
    start = time.perf_counter()
    result = subprocess.run(command, cwd=root, capture_output=True, text=True)
    elapsed = time.perf_counter() - start
    (OUT / f'{label}.txt').write_text(result.stdout + result.stderr)
    return {'command': command, 'exit_code': result.returncode, 'wall_seconds': elapsed}


before = hashes()
clean = run(ROOT, 'clean')
assert clean['exit_code'] == 0, clean
assert clean['wall_seconds'] < 1, clean
with tempfile.TemporaryDirectory(prefix='codx-task18-') as directory:
    tmp = Path(directory)
    shutil.copytree(ROOT / 'scripts/scoring', tmp / 'scripts/scoring',
                    ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))
    path = tmp / 'scripts/scoring/pipeline.py'
    original = path.read_text()
    old = 'elif not series_position_ready(catalog, id_to_magnitude, book):'
    new = 'elif False:  # deliberate Task 18 mutation: bypass series-position gate'
    assert original.count(old) == 1
    path.write_text(original.replace(old, new))
    (OUT / 'mutation.diff').write_text('- ' + old + '\n+ ' + new + '\n')
    broken = run(tmp, 'broken')
    assert broken['exit_code'] == 1, broken
    output = (OUT / 'broken.txt').read_text()
    assert 'FAIL: test_only_ranking_short_circuits_series_ineligibility' in output
    assert 'FAIL: test_series_position_requires_every_earlier_installment' in output
    assert 'ERROR:' not in output

assert hashes() == before, 'The real engine/test files changed during validation'
summary = {'python': sys.version, 'clean': clean, 'broken_copy': broken,
           'real_engine_and_test_files_unchanged': True}
(OUT / 'validation.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=2))
