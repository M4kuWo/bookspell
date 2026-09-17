"""Canonical suite and CLI with command-scoped authorized read-only connection."""
import hashlib, os, re, shlex, subprocess, sys
from pathlib import Path
E=Path(__file__).resolve().parent
root=E.parents[2]
m=re.search(r'(?m)^\s*(?:export\s+)?CODX_READONLY_DATABASE_URL\s*=\s*(.*)$',(root/'.env').read_text())
if not m: raise SystemExit('Missing read-only credential; stop')
parts=shlex.split(m.group(1),comments=True)
assert len(parts)==1
mode=sys.argv[1]; assert mode in ('before','after')
env=dict(os.environ,CODX_READONLY_DATABASE_URL=parts[0],PYTHONHASHSEED='0')
for name,script in [('suite','scripts/scoring_tests.py'),('cli','scripts/recommend.py')]:
    cmd='DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 '+script
    p=subprocess.run(['zsh','-f','-c',cmd],cwd=root,env=env,capture_output=True)
    out=p.stdout.replace(parts[0].encode(),b'<redacted>')
    err=p.stderr.replace(parts[0].encode(),b'<redacted>')
    (E/f'{name}-{mode}.txt').write_bytes(out)
    (E/f'{name}-{mode}.stderr').write_bytes(err)
    print(name,mode,'exit',p.returncode,'bytes',len(out),'sha256',hashlib.sha256(out).hexdigest(),flush=True)
    if p.returncode:
        print(err.decode(errors='replace')[-1500:]); raise SystemExit(p.returncode)
