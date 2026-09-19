import ast,contextlib,hashlib,io,itertools,json,logging,os,pickle,re,sys,types
from pathlib import Path
from unittest.mock import patch
from fastapi.testclient import TestClient
E=Path(__file__).resolve().parent;root=E.parents[2]
sys.path[:0]=[str(root/'scripts'),str(root/'api')]
url=re.search(r"const SUPABASE_URL\s*=\s*['\"]([^'\"]+)",(root/'app/shared.js').read_text()).group(1)
os.environ['SUPABASE_JWKS_URL']=url+'/auth/v1/.well-known/jwks.json'
import main as N
O=types.ModuleType('old_routes');O.__file__=str(root/'api/main.py')
exec(compile((E/'before/api/main.py').read_text(),O.__file__,'exec'),O.__dict__)
books=pickle.loads((root/'docs/codx-reports/2026-09-19-recommendation-engine-review-evidence/catalog.pickle').read_bytes())
raters={n:json.loads((root/f'data/ratings/{n}.json').read_text())['ratings'] for n in ('gabriel','dandan','mathias_goodreads')}
clients={m:TestClient(m.app,raise_server_exceptions=False) for m in (O,N)}
@contextlib.contextmanager
def inputs(m,ratings,rules=None,fmt=None):
 with contextlib.ExitStack() as stack:
  mocks={}
  for name,value in [('require_user_id','fixture'),('get_catalog',books),('_load_user_ratings',ratings),('_load_user_rules',rules or {}),('_load_format_preference',fmt)]:mocks[name]=stack.enter_context(patch.object(m,name,return_value=value))
  yield mocks
count=0;digest=hashlib.sha256();summary=[]
for index,(name,ratings) in enumerate(raters.items()):
 rules={'exclude':['age_category:ya'],'reduce':[{'key':'found_family','strength':0.7}]} if index==1 else {}
 fmt=('print','mixed','audiobook')[index]
 with inputs(O,ratings,rules,fmt),inputs(N,ratings,rules,fmt):
  for top in (-5,1,7,101):
   for genre in ('','fantasy','sci_fi'):
    params={'top_n':top}
    if genre:params['genre']=genre
    a=clients[O].get('/recommendations',params=params);b=clients[N].get('/recommendations',params=params)
    assert a.status_code==b.status_code==200 and a.content==b.content
    count+=1;digest.update(b.content)
  a=clients[O].get('/recommendations/all?top_n=7');b=clients[N].get('/recommendations/all?top_n=7')
  assert b.status_code==200 and b.json()=={'results_by_genre':a.json(),'errors_by_genre':{}}
summary.append(f'PASS {count} single-genre HTTP responses byte-identical; SHA256 {digest.hexdigest()}; 3 all-success envelopes preserve original lists')
# All eight failure subsets; remaining lists use actual scoring, not canned results.
ratings=raters['gabriel'];actual=N._score_genre
with inputs(N,ratings):baseline=clients[N].get('/recommendations/all?top_n=3').json()['results_by_genre']
faults=[]
for mask in itertools.product((False,True),repeat=3):
 failed={k for k,yes in zip(('', 'fantasy','sci_fi'),mask) if yes}
 def score(*args):
  if (args[4] or '') in failed:raise RuntimeError('SENSITIVE_DETAIL_MUST_NOT_LEAK')
  return actual(*args)
 stream=io.StringIO();handler=logging.StreamHandler(stream);logger=logging.getLogger(N.__name__);logger.addHandler(handler)
 try:
  with inputs(N,ratings) as mocks,patch.object(N,'_score_genre',side_effect=score) as scorer:
   response=clients[N].get('/recommendations/all?top_n=3');body=response.json()
   assert response.status_code==(500 if len(failed)==3 else 200)
   assert body=={'results_by_genre':{k:v for k,v in baseline.items() if k not in failed},'errors_by_genre':{k:'temporarily_unavailable' for k in baseline if k in failed}}
   assert 'SENSITIVE_DETAIL' not in response.text
   assert scorer.call_count==3 and all(m.call_count==1 for m in mocks.values())
   assert stream.getvalue().count('Recommendation scoring failed for genre')==len(failed)
   faults.append({'failed':list(failed),'status':response.status_code,'results_keys':list(body['results_by_genre']),'errors':body['errors_by_genre']})
 finally:logger.removeHandler(handler)
summary.append('PASS all 8 genre-failure subsets: surviving real lists exact, status 200/500 correct, shared inputs loaded once, one server log per failure, no exception text in responses')
# Empty success is still successful, even if both other genres fail.
with inputs(N,{}),patch.object(N,'_score_genre',side_effect=[[],RuntimeError('private'),RuntimeError('private')]):
 r=clients[N].get('/recommendations/all');assert r.status_code==200 and r.json()['results_by_genre']=={'':[]}
summary.append('PASS empty successful list plus two failures returns HTTP 200')
# Shared acquisition exceptions bypass isolation and never invoke the scorer.
for loader in ('get_catalog','_load_user_ratings','_load_user_rules','_load_format_preference'):
 with inputs(N,ratings),patch.object(N,loader,side_effect=RuntimeError('private')),patch.object(N,'_score_genre') as scorer:
  r=clients[N].get('/recommendations/all');assert r.status_code==500 and not scorer.called and 'private' not in r.text
for m in (O,N):
 assert clients[m].get('/recommendations/all').status_code==401
 with inputs(m,ratings):
  assert clients[m].get('/recommendations?genre=bogus').status_code==400
  assert clients[m].get('/recommendations?top_n=no').status_code==422
with inputs(N,ratings),patch.object(N,'_score_genre',side_effect=RuntimeError('private')):
 assert clients[N].get('/recommendations').status_code==500
summary.append('PASS shared-load failures remain HTTP 500 before scoring; auth 401, bad genre 400, invalid limit 422 and single-genre error propagation preserved')
old=ast.parse((E/'before/api/main.py').read_text());new=ast.parse((root/'api/main.py').read_text())
for node in old.body:
 if isinstance(node,(ast.FunctionDef,ast.AsyncFunctionDef)) and node.name!='recommendations_all':
  other=next(n for n in new.body if isinstance(n,type(node)) and n.name==node.name)
  assert ast.dump(node,include_attributes=False)==ast.dump(other,include_attributes=False),node.name
summary.append('PASS every other API function AST unchanged, including single-genre route and scoring helper')
(E/'api-faults.json').write_text(json.dumps(faults,indent=2)+'\n')
(E/'api-results.txt').write_text('\n'.join(summary)+'\n');print('\n'.join(summary))
