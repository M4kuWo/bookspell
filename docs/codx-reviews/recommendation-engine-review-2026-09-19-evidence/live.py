import hashlib,os,re,shlex,subprocess
from pathlib import Path
E=Path(__file__).resolve().parent;root=E.parents[2]
m=re.search(r'(?m)^\s*(?:export\s+)?CODX_READONLY_DATABASE_URL\s*=\s*(.*)$',(root/'.env').read_text())
if not m:raise SystemExit('Missing read-only credential; stop')
parts=shlex.split(m.group(1),comments=True);assert len(parts)==1
env=dict(os.environ,CODX_READONLY_DATABASE_URL=parts[0],PYTHONHASHSEED='0')
for label,path in [('snapshot',E.relative_to(root)/'read_catalog.py'),('canonical',Path('scripts/scoring_tests.py'))]:
 p=subprocess.run(['zsh','-f','-c','DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 '+str(path)],cwd=root,env=env,capture_output=True)
 for suffix,data in [('txt',p.stdout),('stderr',p.stderr)]: (E/f'{label}.{suffix}').write_bytes(data.replace(parts[0].encode(),b'<redacted>'))
 print(label,'exit',p.returncode,'bytes',len(p.stdout),'sha256',hashlib.sha256(p.stdout).hexdigest(),flush=True)
 if p.returncode:raise SystemExit('Read-only run failed; see redacted stderr')
