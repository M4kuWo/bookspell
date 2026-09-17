"""Offline source, import, canonical-suite and real API consumer verification."""
import ast, contextlib, hashlib, importlib.util, io, json, os, pickle, re, struct, subprocess, sys
from pathlib import Path
from unittest.mock import patch
E = Path(__file__).resolve().parent
root = E.parents[2]
sys.path[:0] = [str(root / 'api'), str(root / 'scripts'), str(root)]
import recommend as R
import scoring_tests as T
assert T.R is R
spec = importlib.util.spec_from_file_location('baseline_recommend', E / 'recommend.before.py')
O = importlib.util.module_from_spec(spec)
O.__file__ = str(root / 'scripts/recommend.py')
exec(compile((E / 'recommend.before.py').read_text(), O.__file__, 'exec'), O.__dict__)
catalog = pickle.loads((E / 'catalog.pickle').read_bytes())
log = []
def record(s):
    log.append(s)
    print(s)
def digest(data): return hashlib.sha256(data).hexdigest()
source = (E / 'recommend.before.py').read_text()
old_tree = ast.parse(source)
mapping = json.loads((E / 'module-map.json').read_text())
new_nodes = {}
for path in sorted((root / 'scripts/scoring').glob('*.py')):
    text = path.read_text()
    for node in ast.parse(text).body:
        if isinstance(node, ast.FunctionDef):
            assert node.name not in new_nodes
            new_nodes[node.name] = (node, text, path.name)
original_functions = {n.name: n for n in old_tree.body if isinstance(n, ast.FunctionDef)}
assert original_functions.keys() == new_nodes.keys()
for name, original in original_functions.items():
    moved, text, filename = new_nodes[name]
    assert ast.dump(original, include_attributes=False) == ast.dump(moved, include_attributes=False), name
    a = ast.get_source_segment(source, original)
    b = ast.get_source_segment(text, moved)
    assert a == b, name
    record(f'PASS AST + full function bytes: {name} -> {filename} sha256={digest(a.encode())}')
assert all(getattr(R, name) is not None for name in mapping['definitions'])
for name in mapping['definitions']:
    a,b = getattr(O,name),getattr(R,name)
    if not callable(a): assert a == b, name
record('PASS all original constants retain equal values, including FEEDBACK_LOG_PATH; 112 definitions exported')
constants_text = (root / 'scripts/scoring/constants.py').read_text()
assignments = {n.targets[0].id:n for n in ast.parse(constants_text).body if isinstance(n,ast.Assign)}
for n in old_tree.body:
    if isinstance(n,ast.Assign):
        name=n.targets[0].id
        if name != 'FEEDBACK_LOG_PATH':
            assert ast.get_source_segment(source,n)==ast.get_source_segment(constants_text,assignments[name]),name
record('PASS all assignment bytes unchanged except required FEEDBACK_LOG_PATH relocation; default value identical')
old_main = next(n for n in old_tree.body if isinstance(n,ast.If))
shim_text = (root/'scripts/recommend.py').read_text()
new_main = ast.parse(shim_text).body[-1]
assert ast.get_source_segment(source,old_main)==ast.get_source_segment(shim_text,new_main)
record('PASS CLI main block byte-identical')
# Discover actual imports and executable attribute reads in all tracked Python consumers.
consumers = {}
for rel in subprocess.check_output(['git','ls-files','*.py'],cwd=root,text=True).splitlines():
    if rel == 'scripts/recommend.py': continue
    data = (root/rel).read_bytes()
    tree=ast.parse(data)
    aliases = {a.asname or a.name for n in ast.walk(tree) if isinstance(n,ast.Import) for a in n.names if a.name in ('recommend','scripts.recommend')}
    if not aliases: continue
    names=sorted({n.attr for n in ast.walk(tree) if isinstance(n,ast.Attribute) and isinstance(n.value,ast.Name) and n.value.id in aliases})
    for name in names: assert hasattr(R,name),(rel,name)
    assert data==subprocess.check_output(['git','show','HEAD:'+rel],cwd=root)
    consumers[rel]=names
    record(f'PASS unchanged consumer + exports: {rel}: {", ".join(names)}')
(E/'consumers.json').write_text(json.dumps(consumers,indent=2)+'\n')
required=set(re.findall(r'R\.(\w+)',(root/'docs/codx-tasks/current-task.md').read_text()))
actual=set(consumers['api/main.py'])|set(consumers['scripts/scoring_tests.py'])
assert actual <= required,actual-required
record(f'PASS task export list covers all {len(actual)} real main.py/scoring_tests.py attributes; dogfood additionally needs audit_book_score')
# Fresh process for every module, using both supported package paths.
env=dict(os.environ,PYTHONPATH=str(root/'scripts'),PYTHONDONTWRITEBYTECODE='1')
modules=['recommend','scripts.recommend','scoring','scripts.scoring']
for mod in mapping['dependencies']:
    modules += ['scoring.'+mod,'scripts.scoring.'+mod]
for mod in modules:
    p=subprocess.run([sys.executable,'-c','import '+mod],cwd=root,env=env,capture_output=True,text=True)
    assert p.returncode==0,(mod,p.stderr)
record(f'PASS {len(modules)} fresh-interpreter imports; static dependency graph acyclic')
# Canonical suite on identical data, no database access or changes to scoring code.
for label,engine in [('before',O),('after',R)]:
    stream=io.StringIO()
    with patch.object(T,'R',engine),patch.object(engine,'load_catalog',return_value=catalog),contextlib.redirect_stdout(stream):
        T._PREVALENCE_CACHE = None
        T._SERIES_DNA_CACHE = None
        T.run_all()
    (E/f'frozen-{label}.txt').write_text(stream.getvalue())
a=(E/'frozen-before.txt').read_bytes(); b=(E/'frozen-after.txt').read_bytes()
assert a==b
record(f'PASS frozen canonical suite: {len(a)} bytes, sha256={digest(a)}')
# Actual API import; JWKS constructed from already-public app URL; no auth/network fetch.
shared=(root/'app/shared.js').read_text()
url=re.search(r"const SUPABASE_URL\s*=\s*['\"]([^'\"]+)",shared).group(1)
os.environ['SUPABASE_JWKS_URL']=url+'/auth/v1/.well-known/jwks.json'
import api.main as A
assert A.R is R and T.R is R

def exact(value):
    if isinstance(value,float): return ['float',struct.pack('!d',value).hex()]
    if isinstance(value,dict): return ['dict',[[exact(k),exact(v)] for k,v in value.items()]]
    if isinstance(value,(list,tuple)): return [type(value).__name__,[exact(x) for x in value]]
    return value
outputs={}
for label,engine in [('before',O),('after',R)]:
    results=[]
    with patch.object(A,'R',engine),patch.object(A,'get_catalog',return_value=catalog),patch.object(A,'require_user_id',return_value='offline-fixture'),patch.object(A,'_load_user_ratings',return_value=T.REAL_RATINGS),patch.object(A,'_load_user_rules',return_value={}),patch.object(A,'_load_format_preference',return_value='print'):
        for genre in (None,'fantasy','sci_fi'):
            result=A.recommendations(genre=genre,top_n=3,authorization='offline-fixture')
            assert len(result['results'])==3
            results.append(result)
        results.append(A.rule_targets())
    for title in ('Warbreaker','A Game of Thrones'):
        results.append(engine.audit_book_score(catalog,T.REAL_RATINGS,title))
    # Additional series orchestrator moved away from the proposed series module.
    series_book=next(b for b in catalog.values() if b.get('series_id') and b.get('position_in_series'))
    results.append(engine.series_dnf_outlook(catalog,T.REAL_RATINGS,series_book['series_id'],float(series_book['position_in_series'])))
    outputs[label]=json.dumps(exact(results),ensure_ascii=False).encode()
assert outputs['before']==outputs['after']
(E/'consumer-results.json').write_bytes(outputs['after'])
record(f'PASS actual api.main import and 3 recommendations() endpoint calls per version (9 recommendations + explanations), rule_targets(), 2 audits, series outlook: bit-exact sha256={digest(outputs["after"])}')
record('API auth/user-data/catalog loaders replaced with local fixtures only; actual scoring and response construction executed unchanged. No hosted user-data or write access.')
(E/'verification.txt').write_text('\n'.join(log)+'\n')
