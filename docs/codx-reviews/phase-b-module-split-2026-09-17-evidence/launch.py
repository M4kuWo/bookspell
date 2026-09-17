"""Run the canonical suite with the authorized read-only credential, never print it."""
import hashlib, os, re, shlex, subprocess, sys
from pathlib import Path
E = Path(__file__).resolve().parent
root = E.parents[2]
m = re.search(r'(?m)^\s*(?:export\s+)?CODX_READONLY_DATABASE_URL\s*=\s*(.*)$', (root / '.env').read_text())
if not m: raise SystemExit('Missing CODX_READONLY_DATABASE_URL; stop')
parts = shlex.split(m.group(1), comments=True)
assert len(parts) == 1
mode = sys.argv[1]
assert mode in ('before', 'after', 'snapshot')
env = dict(os.environ, CODX_READONLY_DATABASE_URL=parts[0], PYTHONHASHSEED='0')
cmd = 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 ' + ('scripts/scoring_tests.py' if mode != 'snapshot' else str(E.relative_to(root) / 'snapshot.py'))
p = subprocess.run(['zsh', '-f', '-c', cmd], cwd=root, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
# Redact credentials even if an unexpected dependency error includes them.
out = p.stdout.replace(parts[0].encode(), b'<redacted-readonly-url>')
(E / (mode + '.txt')).write_bytes(out)
print(mode, 'exit', p.returncode, 'bytes', len(out), 'sha256', hashlib.sha256(out).hexdigest())
if p.returncode: print(out.decode(errors='replace')[-1800:])
raise SystemExit(p.returncode)
