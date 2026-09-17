"""Preserve the proposal, restore exactly the six task files, verify all HEAD bytes."""
import hashlib,json,subprocess
from pathlib import Path
E=Path(__file__).resolve().parent;root=E.parents[2]
def git(*args):return subprocess.check_output(['git',*args],cwd=root)
def sha(data):return hashlib.sha256(data).hexdigest()
paths=list(json.loads((E/'mapping.json').read_text()))+['scripts/recommend.py']
assert set(git('diff','--name-only').decode().splitlines())==set(paths)
patch=git('diff','--',*paths)
(E/'proposal.patch').write_bytes(patch)
proposed={p:sha((root/p).read_bytes()) for p in paths}
(E/'proposed-sha256.json').write_text(json.dumps(proposed,indent=2)+'\n')
for rel in paths:
    expected=git('show','HEAD:'+rel)
    assert expected==(E/'before'/rel).read_bytes(),rel
    (root/rel).write_bytes(expected)
subprocess.run(['git','apply','--check',str(E/'proposal.patch')],cwd=root,check=True)
assert not git('diff') and not git('diff','--cached')
count=0
for entry in git('ls-tree','-r','-z','HEAD').split(b'\0'):
    if not entry:continue
    meta,name=entry.split(b'\t',1);mode,kind,oid=meta.split()
    if kind!=b'blob':continue
    assert sha((root/name.decode()).read_bytes())==sha(git('cat-file','blob',oid.decode())),name
    count+=1
facts={'HEAD':git('rev-parse','HEAD').decode().strip(),'tracked_files_verified':count,'files_changed':paths,'patch_sha256':sha(patch),'hook':git('config','--get','core.hooksPath').decode().strip()}
(E/'facts.json').write_text(json.dumps(facts,indent=2)+'\n')
output=f'HEAD {facts["HEAD"]}\nPASS six task files restored; working tree/index contain no tracked changes\nPASS SHA-256 of all {count} tracked files equals HEAD\nPASS proposal.patch applies cleanly (git apply --check)\nPASS core.hooksPath = {facts["hook"]}\n'
(E/'restoration.txt').write_text(output);print(output)
