"""Assert the comparison grid actually returns explanations; measure remaining preparation cost."""
import contextlib,io,json,pickle,sys,time
from pathlib import Path
from unittest.mock import patch
E=Path(__file__).resolve().parent;root=E.parents[2];sys.path.insert(0,str(root/'scripts'))
from scoring import api as A
books=pickle.loads((E/'catalog.pickle').read_bytes());sample=json.loads((E/'sample.json').read_text())
n=0
with contextlib.redirect_stdout(io.StringIO()):
 for name in sample['raters']:
  ratings=json.loads((root/f'data/ratings/{name}.json').read_text())['ratings']
  for genre,fmt,fatigue in sample['contexts']:
   for top in sample['top_n']:
    for title in sample['titles']:
     result=A.explain_match(books,ratings,title,genre,fatigue,top,fmt)
     assert isinstance(result,dict) and result['title']==title
     n+=1
print('PASS',n,'successful explanation returns (no matching-exception false positives)')
measure=[]
ratings=json.loads((root/'data/ratings/gabriel.json').read_text())['ratings']
for genre in (None,'fantasy','sci_fi'):
 for top in (7,100):
  times={};calls={}
  # Time prepare-explanation as a whole alongside the existing ranking path, not sum nested timings.
  start=time.perf_counter();rank=A.recommend(books,ratings,genre=genre,top_n=top);rank_elapsed=time.perf_counter()-start
  start=time.perf_counter();bundle=A.resolve_explain_profile(books,ratings,genre=genre);prepare_elapsed=time.perf_counter()-start
  start=time.perf_counter()
  for _,title,_,_ in rank:A.explain_match_with_profile(books,title,**bundle)
  explain_elapsed=time.perf_counter()-start
  measure.append({'genre':genre,'top_n':top,'returned':len(rank),'ranking_seconds':rank_elapsed,'second_bundle_seconds':prepare_elapsed,'explain_loop_seconds':explain_elapsed})
(E/'remaining-cost.json').write_text(json.dumps(measure,indent=2)+'\n')
print('Recorded 6 illustrative CPU-side timings; no deployment/network latency claim')
