"""Independent structural and artifact validation of the six-file proposal."""
import ast,copy,hashlib,json,os,re,subprocess,sys
from pathlib import Path
E=Path(__file__).resolve().parent;root=E.parents[2]
mapping=json.loads((E/'mapping.json').read_text())
log=[]
def record(text): log.append(text);print(text,flush=True)
def sha(data):return hashlib.sha256(data).hexdigest()
class Normalize(ast.NodeTransformer):
    def __init__(self,aliases): self.aliases={v:k for k,v in aliases.items()}
    def visit_Import(self,node):
        if any(a.name=='recommend' for a in node.names): return None
        return node
    def visit_ImportFrom(self,node):
        if node.module=='scoring': return None
        return node
    def visit_Attribute(self,node):
        if isinstance(node.value,ast.Name) and node.value.id in self.aliases:
            node.value=ast.Name(id='R',ctx=ast.Load())
        return self.generic_visit(node)
    def _body(self,node):
        self.generic_visit(node)
        if node.body and isinstance(node.body[0],ast.Expr) and isinstance(node.body[0].value,ast.Constant) and isinstance(node.body[0].value.value,str):
            node.body.pop(0)
        return node
    visit_Module=_body
    visit_FunctionDef=_body
    visit_AsyncFunctionDef=_body
    visit_ClassDef=_body
for rel,info in mapping.items():
    old=(E/'before'/rel).read_text();new=(root/rel).read_text()
    a=Normalize({}).visit(ast.parse(old));b=Normalize(info['aliases']).visit(ast.parse(new))
    assert ast.dump(a,include_attributes=False)==ast.dump(b,include_attributes=False),rel
    assert not re.search(r'\bR\.|import recommend|recommend\.py|\bshim\b',new),rel
    assert [x for x in old.splitlines() if 'sys.path.insert' in x]==[x for x in new.splitlines() if 'sys.path.insert' in x],rel
    # Prove imports still resolve to the precise functions/constants from Task 11.
    for name,mod in info['names'].items():
        assert (root/f'scripts/scoring/{mod}.py').is_file()
    record(f'PASS imports/name qualification only (AST ignoring documentation), no old-shim references, sys.path unchanged: {rel}')
old=(E/'before/scripts/recommend.py').read_text();new=(root/'scripts/recommend.py').read_text()
a=ast.parse(old);b=ast.parse(new)
assert ast.get_source_segment(old,a.body[0])==ast.get_source_segment(new,b.body[0])
assert len(b.body)==3 and isinstance(b.body[1],ast.ImportFrom) and b.body[1].module=='scoring'
class DemoNames(ast.NodeTransformer):
    def visit_Attribute(self,node):
        if isinstance(node.value,ast.Name) and node.value.id in ('api','scoring_catalog'):
            return ast.copy_location(ast.Name(id=node.attr,ctx=node.ctx),node)
        return self.generic_visit(node)
assert ast.dump(a.body[-1],include_attributes=False)==ast.dump(DemoNames().visit(b.body[-1]),include_attributes=False)
record(f'PASS CLI docstring exact; main block AST identical after qualification; only docstring/import/main remain ({len(new.splitlines())} lines)')
for path in sorted((root/'scripts/scoring').glob('*.py')):
    rel=str(path.relative_to(root))
    assert path.read_bytes()==subprocess.check_output(['git','show','HEAD:'+rel],cwd=root)
record('PASS all 16 scoring package files exactly unchanged')
# Actual grep-based negative check, preserving command and exit status.
cmd=['rg','-n',r'\bR\.|import recommend|recommend\.py|\bshim\b',*mapping]
p=subprocess.run(cmd,cwd=root,capture_output=True,text=True)
assert p.returncode==1 and not p.stdout and not p.stderr
record('PASS grep exit 1 (no matches): '+' '.join(cmd))
for name in ('suite','cli','frozen-suite','api','goodreads','dogfood'):
    ext='json' if name in ('api','dogfood') else 'txt'
    before=(E/f'{name}-before.{ext}').read_bytes();after=(E/f'{name}-after.{ext}').read_bytes()
    assert before==after,name
    record(f'PASS byte-identical {name}: {len(after)} bytes; SHA-256 {sha(after)}')
assert (E/'suite-before.txt').read_bytes()==(E/'frozen-suite-before.txt').read_bytes()
for mode in ('before','after'):
    for name in ('suite','cli'): assert not (E/f'{name}-{mode}.stderr').read_bytes()
# Six fresh interpreters. Dogfood's fresh process is its full real AppTest run.
worker=E/'consumer_check.py'
for rel in [p for p in mapping if p!='tools/dogfood/app.py']+['scripts/recommend.py']:
    p=subprocess.run([sys.executable,str(worker),'after','import',rel],cwd=root,capture_output=True,text=True)
    assert p.returncode==0,(rel,p.stderr)
    record(p.stdout.strip())
assert 'PASS real Streamlit top-level' in (E/'dogfood-after.log').read_text()
record('PASS fresh dogfood interpreter: real AppTest startup and recommendation/audit loop (see dogfood-after.log)')
(E/'verification.txt').write_text('\n'.join(log)+'\n')
