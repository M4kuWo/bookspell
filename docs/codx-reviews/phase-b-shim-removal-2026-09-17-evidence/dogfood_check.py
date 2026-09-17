"""Real Streamlit AppTest executes top-level tool and its recommendation/audit loop."""
import builtins, hashlib, io, json, pickle, sys, types
from pathlib import Path
from unittest.mock import patch
from streamlit.testing.v1 import AppTest
E=Path(__file__).resolve().parent; root=E.parents[2]
mode=sys.argv[1]; assert mode in ('before','after')
sys.path[:0]=[str(root/'scripts'),str(root)]
books=pickle.loads((root/'docs/codx-reviews/phase-b-module-split-2026-09-17-evidence/catalog.pickle').read_bytes())
from scoring import catalog as C
if mode=='before':
    O=types.ModuleType('recommend'); O.__file__=str(root/'scripts/recommend.py');O.__package__=''
    sys.modules['recommend']=O
    exec(compile((E/'before/scripts/recommend.py').read_text(),O.__file__,'exec'),O.__dict__)
else:
    class NoShim:
        def find_spec(self,fullname,path=None,target=None):
            assert fullname not in ('recommend','scripts.recommend'),fullname
    sys.meta_path.insert(0,NoShim())
class Cursor:
    def execute(self,sql): assert sql=='select id, cover_url from books where cover_url is not null',sql
    def fetchall(self): return []
    def close(self): pass
class Connection:
    def cursor(self): return Cursor()
    def close(self): pass
original_open=builtins.open
def guarded_open(file,mode='r',*args,**kwargs):
    if any(flag in mode for flag in 'wax+') and isinstance(file,(str,Path)):
        assert not Path(file).resolve().is_relative_to(root/'data/ratings'), 'Unexpected rater data write'
    return original_open(file,mode,*args,**kwargs)
rel='tools/dogfood/app.py'
source=(E/'before'/rel if mode=='before' else root/rel).read_text()
# Preserve the real source filename so DATA_DIR and sys.path resolve normally.
wrapper='__file__ = '+repr(str(root/rel))+'\nexec(compile('+repr(source)+', __file__, "exec"), globals())\n'
with patch.object(O if mode=='before' else C,'load_catalog',return_value=books),patch('psycopg2.connect',return_value=Connection()),patch('builtins.open',guarded_open):
    app=AppTest.from_string(wrapper,default_timeout=60).run()
    assert not app.exception,[(e.message,e.stack_trace) for e in app.exception]
    buttons=[b for b in app.button if b.label=='Get recommendations']; assert len(buttons)==1
    buttons[0].click().run()
    assert not app.exception,[(e.message,e.stack_trace) for e in app.exception]
    result={'expanders':[e.label for e in app.expander], 'markdown':[m.value for m in app.markdown], 'tables':[t.value.to_json(orient='split') for t in app.table]}
    assert len(result['tables'])==20, len(result['tables'])
    assert len(result['expanders'])==21,len(result['expanders'])
data=json.dumps(result,ensure_ascii=False).encode()
(E/f'dogfood-{mode}.json').write_bytes(data)
print('PASS real Streamlit top-level execution + Get recommendations click; 20 audit tables; no rater writes;',len(data),'bytes; sha256',hashlib.sha256(data).hexdigest())
