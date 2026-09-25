"""Task 19 evidence: clean run and isolated series-gate mutation.

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
mutations = [
    ('prevalence', 'w_eff *= max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence)',
     'w_eff *= 1.0  # deliberate mutation: no prevalence discount', 2,
     'test_prevalence_discounts_field_and_trope_weights_with_floor'),
    ('cold-start', 'if policy in ("ranking", "audit") and cold_start > 0:',
     'if False:  # deliberate mutation: no cold-start blending', 1,
     'test_cold_start_applies_only_to_ranking_and_audit'),
]
broken_runs = {}
for label, old, new, count, expected_test in mutations:
    with tempfile.TemporaryDirectory(prefix='codx-task19-') as directory:
        tmp = Path(directory)
        shutil.copytree(ROOT / 'scripts/scoring', tmp / 'scripts/scoring',
                        ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))
        path = tmp / 'scripts/scoring/pipeline.py'
        original = path.read_text()
        assert original.count(old) == count
        path.write_text(original.replace(old, new))
        (OUT / f'{label}.diff').write_text('- ' + old + '\n+ ' + new + '\n')
        broken = run(tmp, label)
        assert broken['exit_code'] == 1, broken
        output = (OUT / f'{label}.txt').read_text()
        assert 'FAIL: ' + expected_test in output
        assert 'ERROR:' not in output
        broken_runs[label] = broken

assert hashes() == before, 'The real engine/test files changed during validation'
summary = {'python': sys.version, 'clean': clean, 'broken_copies': broken_runs,
           'real_engine_and_test_files_unchanged': True}
(OUT / 'validation.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=2))
