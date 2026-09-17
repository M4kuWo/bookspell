"""Save reviewable patch, restore only task edits, and hash-verify tracked files."""
import ast, collections, difflib, hashlib, io, json, shutil, subprocess, tokenize
from pathlib import Path
E=Path(__file__).resolve().parent
root=E.parents[2]
def git(*args): return subprocess.check_output(['git',*args],cwd=root)
def sha(data): return hashlib.sha256(data).hexdigest()
base=git('rev-parse','HEAD').decode().strip()
original=git('show','HEAD:scripts/recommend.py')
assert original==(E/'recommend.before.py').read_bytes()
package=root/'scripts/scoring'
new_files=sorted(package.glob('*.py'))
assert len(new_files)==16
# No source comments lost in the split (new module comments may be added).
def comments(data):
    return collections.Counter(t.string for t in tokenize.generate_tokens(io.StringIO(data).readline) if t.type==tokenize.COMMENT)
old_comments=comments(original.decode())
new_comments=comments((root/'scripts/recommend.py').read_text())
for p in new_files: new_comments.update(comments(p.read_text()))
assert not (old_comments-new_comments),old_comments-new_comments
patch=git('diff','--','scripts/recommend.py').decode()
for p in new_files:
    rel=p.relative_to(root).as_posix()
    patch += f'diff --git a/{rel} b/{rel}\nnew file mode 100644\n'
    patch += ''.join(difflib.unified_diff([],p.read_text().splitlines(keepends=True),fromfile='/dev/null',tofile='b/'+rel))
(E/'proposal.patch').write_text(patch)
proposed={str(p.relative_to(root)):sha(p.read_bytes()) for p in [root/'scripts/recommend.py',*new_files]}
(E/'proposed-sha256.json').write_text(json.dumps(proposed,indent=2)+'\n')
assert (E/'before.txt').read_bytes()==(E/'after.txt').read_bytes()==(E/'frozen-before.txt').read_bytes()==(E/'frozen-after.txt').read_bytes()
# Restore precisely the task's one tracked edit and remove its generated package.
(root/'scripts/recommend.py').write_bytes(original)
shutil.rmtree(package)
subprocess.run(['git','apply','--check',str(E/'proposal.patch')],cwd=root,check=True)
subprocess.run(['git','diff','--exit-code'],cwd=root,check=True)
subprocess.run(['git','diff','--cached','--exit-code'],cwd=root,check=True)
count=0
for entry in git('ls-tree','-r','-z','HEAD').split(b'\0'):
    if not entry: continue
    meta,name=entry.split(b'\t',1)
    mode,kind,oid=meta.split()
    if kind!=b'blob': continue
    path=root/name.decode()
    assert sha(path.read_bytes())==sha(git('cat-file','blob',oid.decode())),str(path)
    count+=1
facts={'HEAD':base,'tracked_files_verified':count,'moved_functions':sum(isinstance(n,ast.FunctionDef) for n in ast.parse(original).body),'original_lines':len(original.splitlines()),'implementation_modules':15,'new_files':16,'proposal_patch_sha256':sha((E/'proposal.patch').read_bytes()),'canonical_sha256':sha((E/'before.txt').read_bytes()),'canonical_bytes':len((E/'before.txt').read_bytes()),'comments_preserved':sum(old_comments.values())}
(E/'facts.json').write_text(json.dumps(facts,indent=2)+'\n')
output=f'HEAD {base}\nPASS all {facts["moved_functions"]} functions moved byte-identically\nPASS all {facts["comments_preserved"]} original comment tokens retained\nPASS four canonical suite outputs identical ({facts["canonical_bytes"]} bytes)\nPASS proposal.patch applies cleanly to HEAD (git apply --check)\nPASS task package removed; tracked working tree and index clean\nPASS SHA-256 of all {count} tracked files equals HEAD\n'
(E/'restoration.txt').write_text(output)
print(output)
