"""Actual consumer paths on a frozen catalog; no network or user-data writes."""
import contextlib, hashlib, importlib.util, io, json, os, pickle, re, struct, sys, types
from pathlib import Path
from unittest.mock import patch
E=Path(__file__).resolve().parent; root=E.parents[2]
mode=sys.argv[1]; assert mode in ('before','after')
sys.path[:0]=[str(root/'api'),str(root/'scripts'),str(root)]
prior=root/'docs/codx-reviews/phase-b-module-split-2026-09-17-evidence'
books=pickle.loads((prior/'catalog.pickle').read_bytes())
url=re.search(r"const SUPABASE_URL\s*=\s*['\"]([^'\"]+)",(root/'app/shared.js').read_text()).group(1)
os.environ['SUPABASE_JWKS_URL']=url+'/auth/v1/.well-known/jwks.json'
def load(name,rel,main=False):
    source=(E/'before'/rel if mode=='before' else root/rel).read_text()
    module=types.ModuleType(name)
    module.__file__=str(root/rel)
    module.__package__=''
    sys.modules[name]=module
    exec(compile(source,str(root/rel),'exec'),module.__dict__)
    return module
if mode=='before': O=load('recommend','scripts/recommend.py')
else:
    # Prove none of the tested consumers falls back to the old import surface.
    class NoShim:
        def find_spec(self,fullname,path=None,target=None):
            assert fullname not in ('recommend','scripts.recommend'),fullname
    sys.meta_path.insert(0,NoShim())
from scoring import api as engine, audit, catalog as C, pipeline, profile
if len(sys.argv)>2 and sys.argv[2]=='import':
    rel=sys.argv[3]
    load('_fresh_consumer',rel)
    print('PASS fresh import',rel)
    raise SystemExit
G=load('import_goodreads','scripts/import_goodreads.py')
K=load('catalog_cache','api/catalog_cache.py')
T=load('scoring_tests','scripts/scoring_tests.py')
A=load('_actual_api_main','api/main.py')
if mode=='after':
    assert A.api is T.api is engine
    assert T.pipeline is pipeline and T.profile is profile and T.scoring_catalog is C
    assert G.scoring_catalog is C and K.catalog is C
else: assert A.R is T.R is G.R is K.R is O

def exact(x):
    if isinstance(x,float): return ['float',struct.pack('!d',x).hex()]
    if isinstance(x,dict): return ['dict',[[exact(k),exact(v)] for k,v in x.items()]]
    if isinstance(x,(list,tuple)): return [type(x).__name__,[exact(v) for v in x]]
    return x
results=[]
with patch.object(A,'get_catalog',return_value=books),patch.object(A,'require_user_id',return_value='offline-fixture'),patch.object(A,'_load_user_ratings',return_value=T.REAL_RATINGS),patch.object(A,'_load_user_rules',return_value={}),patch.object(A,'_load_format_preference',return_value='print'):
    for genre in (None,'fantasy','sci_fi'):
        result=A.recommendations(genre=genre,top_n=3,authorization='offline-fixture')
        assert len(result['results'])==3
        results.append(result)
    results.append(A.rule_targets())
for title in ('Warbreaker','A Game of Thrones'):
    results.append(audit.audit_book_score(books,T.REAL_RATINGS,title))
b=next(b for b in books.values() if b.get('series_id') and b.get('position_in_series'))
results.append(engine.series_dnf_outlook(books,T.REAL_RATINGS,b['series_id'],float(b['position_in_series'])))
data=json.dumps(exact(results),ensure_ascii=False).encode()
assert data==(prior/'consumer-results.json').read_bytes(), 'Different from Task 11 bit-exact consumer baseline'
(E/f'api-{mode}.json').write_bytes(data)
print('PASS actual API endpoints match Task 11 baseline;',len(data),'bytes; sha256',hashlib.sha256(data).hexdigest())
loader=O if mode=='before' else C
with patch.object(loader,'load_catalog',return_value=books) as mock:
    assert K.get_catalog() is books
    assert K.get_catalog() is books
    assert mock.call_count==1
    assert K.force_refresh() is books
    assert mock.call_count==2
print('PASS cache miss, cache hit, force_refresh; real cache functions, fixture catalog acquisition')
# Exercise existing importer synthetic self-check without real CSV or rater-file writes.
stream=io.StringIO()
with patch.object(sys,'argv',['scripts/import_goodreads.py']),contextlib.redirect_stdout(stream):
    load('__main__','scripts/import_goodreads.py')
(E/f'goodreads-{mode}.txt').write_text(stream.getvalue())
print('PASS Goodreads actual import and existing synthetic __main__ self-check')
# Frozen complete suite using unchanged scoring modules, no database connection.
stream=io.StringIO()
with patch.object(loader,'load_catalog',return_value=books),contextlib.redirect_stdout(stream): T.run_all()
(E/f'frozen-suite-{mode}.txt').write_text(stream.getvalue())
print('PASS frozen canonical suite;',len(stream.getvalue().encode()),'bytes')
