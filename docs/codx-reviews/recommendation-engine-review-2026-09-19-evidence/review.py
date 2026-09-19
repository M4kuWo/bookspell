"""Independent Task 13 comparison; catalog-only snapshot, fixture-backed HTTP routes."""
import ast,collections,contextlib,copy,hashlib,importlib.util,io,json,os,pickle,re,struct,subprocess,sys,types
from pathlib import Path
from unittest.mock import patch
from fastapi.testclient import TestClient
E=Path(__file__).resolve().parent;root=E.parents[2]
sys.path[:0]=[str(root/'scripts'),str(root/'api'),str(root)]
from scoring import api as N, profile, pipeline, series, prevalence
import scoring
books=pickle.loads((E/'catalog.pickle').read_bytes())
def git(*args):return subprocess.check_output(['git',*args],cwd=root)
def old_module(name,rel,rev):
    source=git('show',rev+':'+rel).decode()
    (E/(name.replace('.','_')+'.py')).write_text(source)
    m=types.ModuleType(name);m.__file__=str(root/rel);m.__package__='scoring' if rel.startswith('scripts/scoring/') else ''
    exec(compile(source,m.__file__,'exec'),m.__dict__);return m
O=old_module('scoring.task13_old','scripts/scoring/api.py','fcf8f65^')
assert O is not N and O._resolve_profile is N._resolve_profile is profile._resolve_profile
assert O.score_candidate is N.score_candidate is pipeline.score_candidate
log=[];stats=collections.Counter();digest=hashlib.sha256();mismatches=[]
def record(text):log.append(text);print(text,flush=True)
def exact(x):
    if isinstance(x,float):return ['float',struct.pack('!d',x).hex()]
    if isinstance(x,dict):return ['dict',[[exact(k),exact(v)] for k,v in x.items()]]
    if isinstance(x,(list,tuple)):return [type(x).__name__,[exact(v) for v in x]]
    if isinstance(x,set):return ['set',sorted((exact(v) for v in x),key=repr)]
    return x
def encode(x):return json.dumps(exact(x),ensure_ascii=False,default=str).encode()
def compare(label,a,b):
    stats[label]+=1
    if encode(a)!=encode(b): mismatches.append({'label':label,'case':current_case,'old':repr(a),'new':repr(b)})
    digest.update(encode((label,a,b)))
def call(fn,*args,**kw):
    stream=io.StringIO()
    with contextlib.redirect_stdout(stream):
        try: result=('ok',fn(*args,**kw))
        except Exception as exc:result=('error',type(exc).__name__,str(exc))
    return result,stream.getvalue()
def manual(ratings,genre,fmt,fatigue=None,catalog=books):
    c,w,ids,_=profile._resolve_profile(catalog,ratings,genre,fatigue,fmt)
    fp,tp=prevalence.build_prevalence_lookup(catalog,genre)
    return dict(centroid=c,weights=w,id_to_magnitude=ids,validated=pipeline.validated_dealbreaker_fields(catalog,ids),series_dna=series.compute_series_dna(catalog),field_prevalence=fp,trope_prevalence=tp,poor_threshold=pipeline.user_calibrated_poor_threshold(catalog,ids,c,w,field_prevalence=fp,trope_prevalence=tp))
raters={name:json.loads((root/f'data/ratings/{name}.json').read_text())['ratings'] for name in ('gabriel','dandan','mathias_goodreads')}
# SHA-sorted titles avoid the conventional first 40 rows; guarantee special shapes as well.
titles=sorted({b['title'] for b in books.values()},key=lambda t:hashlib.sha256(('task13:'+t).encode()).hexdigest())[:12]
for title in ('The Traitor God','Cursed Bunny','Quidditch Through the Ages'):
    if title not in titles:titles.append(title)
assert all(t in {b['title'] for b in books.values()} for t in titles)
contexts=[(None,None,None),('fantasy','audiobook',None),('sci_fi','print',None),(None,'mixed',{'found_family':-0.8,'overall_pace':0.7}),('fantasy','print',{'romance_tone':-0.4}),('sci_fi','mixed',{'space_opera':0.5})]
(E/'sample.json').write_text(json.dumps({'raters':list(raters),'titles':titles,'contexts':contexts,'top_n':[-1,0,1,7,None]},indent=2)+'\n')
for name,ratings in raters.items():
    for genre,fmt,fatigue in contexts:
        bundle=manual(ratings,genre,fmt,fatigue)
        snap=copy.deepcopy(bundle)
        for top in (-1,0,1,7,None):
            for title in titles:
                current_case=(name,genre,fmt,fatigue,top,title)
                a,aw=call(O.explain_match,books,ratings,title,genre,fatigue,top,fmt)
                b,bw=call(N.explain_match,books,ratings,title,genre,fatigue,top,fmt)
                compare('wrapper_results',a,b);compare('wrapper_stdout',aw,bw)
                c,_=call(N.explain_match_with_profile,books,title,top_n=top,**bundle)
                compare('manual_bundle_no_map',a,c)
                d,_=call(N.explain_match_with_profile,books,title,top_n=top,title_to_id={v['title']:k for k,v in books.items()},**bundle)
                compare('manual_bundle_with_map',a,d)
        compare('bundle_not_mutated',snap,bundle)
    record(f'PASS completed explanation grid: {name}')
# Supported thin/cold profiles, no-candidate catalogs and explicit absent-genre scope.
first=next(iter(books.values()))['title']
edge_profiles=[{}, {first:'it_was_okay'}, {first:'loved'}, {first:'hated'}, {'Missing reader title':'liked',first:'bogus'}]
for index,ratings in enumerate(edge_profiles):
    for genre in (None,'fantasy','sci_fi','absent_genre'):
        for catalog in (books,{}):
            current_case=('edge',index,genre,len(catalog))
            title=first if catalog else 'Missing target'
            a,_=call(O.explain_match,catalog,ratings,title,genre=genre,top_n=None)
            b,_=call(N.explain_match,catalog,ratings,title,genre=genre,top_n=None)
            compare('edge_result',a,b)
# Observe changed validation ordering separately; it is a finding, not normalized away.
findings=[]
for ratings in ({},{'Missing reader title':'liked'},None):
    a,aw=call(O.explain_match,books,ratings,'Missing target')
    b,bw=call(N.explain_match,books,ratings,'Missing target')
    findings.append({'ratings':ratings,'old':a,'new':b,'old_stdout':aw,'new_stdout':bw})
(E/'validation-order.json').write_text(json.dumps(findings,indent=2)+'\n')
record('Observed missing-title validation ordering; see validation-order.json')
# Prove unchanged source boundaries, independent of runtime comparisons.
oldtree=ast.parse(git('show','fcf8f65^:scripts/scoring/api.py'));newtree=ast.parse((root/'scripts/scoring/api.py').read_text())
a={n.name:n for n in oldtree.body if isinstance(n,ast.FunctionDef)};b={n.name:n for n in newtree.body if isinstance(n,ast.FunctionDef)}
for name in ('recommend','series_dnf_outlook'):assert ast.dump(a[name],include_attributes=False)==ast.dump(b[name],include_attributes=False)
for path in (root/'scripts/scoring').glob('*.py'):
    if path.name=='api.py':continue
    assert path.read_bytes()==git('show','d6cd2db:'+str(path.relative_to(root)))
record('PASS all scoring math modules unchanged since Task 12; recommend and series outlook AST unchanged')
# Real HTTP requests against old, intermediate and current route modules.
shared=(root/'app/shared.js').read_text();url=re.search(r"const SUPABASE_URL\s*=\s*['\"]([^'\"]+)",shared).group(1)
os.environ['SUPABASE_JWKS_URL']=url+'/auth/v1/.well-known/jwks.json'
B=old_module('task13_old_routes','api/main.py','fcf8f65^');B.api=O
I=old_module('task13_intermediate_routes','api/main.py','e8281c2^');I.api=N
import main as A
assert A.api is I.api is N
clients={m:TestClient(m.app,raise_server_exceptions=False) for m in (B,I,A)}
counts={}
@contextlib.contextmanager
def inputs(module,ratings,rules,fmt,catalog=books):
    with contextlib.ExitStack() as stack:
        mocks={}
        for name,value in [('require_user_id','fixture-user'),('get_catalog',catalog),('_load_user_ratings',ratings),('_load_user_rules',rules),('_load_format_preference',fmt)]:
            mocks[name]=stack.enter_context(patch.object(module,name,return_value=value))
        yield mocks
rule_cases=[{}, {'exclude':['age_category:ya'],'reduce':[{'key':'found_family','strength':0.7}]}, {'exclude':['genre:fantasy','genre:sci_fi']}]
for index,(name,ratings) in enumerate(raters.items()):
    fmt=('mixed','audiobook','print')[index];rules=rule_cases[index]
    with contextlib.ExitStack() as stack:
        for m in clients:stack.enter_context(inputs(m,ratings,rules,fmt))
        for top in (-5,1,7,101):
            singles={}
            for genre in (None,'fantasy','sci_fi'):
                current_case=('HTTP',name,genre,top)
                params={'top_n':top}
                if genre:params['genre']=genre
                responses=[clients[m].get('/recommendations',params=params) for m in (B,I,A)]
                assert all(r.status_code==200 for r in responses),current_case
                compare('http_old_intermediate',responses[0].content,responses[1].content)
                compare('http_old_current',responses[0].content,responses[2].content)
                singles[genre or '']=responses[2].json()['results']
            response=clients[A].get('/recommendations/all',params={'top_n':top})
            assert response.status_code==200
            compare('http_all_vs_singles',singles,response.json())
    record(f'PASS endpoint HTTP grid: {name}')
# Empty/thin profiles and catalog fallback do not produce a natural genre-only failure.
for index,ratings in enumerate(edge_profiles):
    for catalog in (books,{}):
        current_case=('thin HTTP',index,len(catalog))
        with inputs(A,ratings,{},None,catalog):
            r=clients[A].get('/recommendations/all?top_n=2')
            assert r.status_code==200,current_case
            stats['thin_http_success']+=1
with inputs(A,raters['gabriel'],{},None) as mocks:
    clients[A].get('/recommendations/all?top_n=3')
    counts['all']={k:v.call_count for k,v in mocks.items()}
with inputs(A,raters['gabriel'],{},None) as mocks:
    for genre in ('','fantasy','sci_fi'):
        clients[A].get('/recommendations',params=({'genre':genre} if genre else {}))
    counts['three_singles']={k:v.call_count for k,v in mocks.items()}
with inputs(A,raters['gabriel'],{},None),patch.object(N,'_resolve_profile',wraps=N._resolve_profile) as resolver:
    clients[A].get('/recommendations?top_n=7');counts['single_profile_resolves']=resolver.call_count
with inputs(A,raters['gabriel'],{},None),patch.object(N,'_resolve_profile',wraps=N._resolve_profile) as resolver:
    clients[A].get('/recommendations/all?top_n=7');counts['all_profile_resolves']=resolver.call_count
(E/'call-counts.json').write_text(json.dumps(counts,indent=2)+'\n')
# Validation/auth remain actual HTTP-path checks, without calling JWT network verification.
for path,expected in [('/recommendations?genre=bogus',400),('/recommendations?genre=',400),('/recommendations?top_n=no',422),('/recommendations/all?top_n=no',422)]:
    with inputs(A,{}, {},None):assert clients[A].get(path).status_code==expected
    stats['http_validation']+=1
for path in ('/recommendations','/recommendations/all'):
    assert clients[A].get(path).status_code==401
    stats['http_auth_missing']+=1
# Fault injection isolates one genre: real routes and other genres still execute normally.
real_recommend=N.recommend
faults={}
for failed in (None,'fantasy','sci_fi'):
    def fail_one(*args,**kwargs):
        if kwargs.get('genre')==failed:raise RuntimeError('injected genre-only failure')
        return real_recommend(*args,**kwargs)
    with inputs(A,raters['gabriel'],{},None),patch.object(N,'recommend',side_effect=fail_one):
        statuses={g:clients[A].get('/recommendations',params=({'genre':g} if g else {})).status_code for g in ('','fantasy','sci_fi')}
        all_response=clients[A].get('/recommendations/all')
        assert list(statuses.values()).count(200)==2 and all_response.status_code==500
        faults[failed or '']={'single_statuses':statuses,'all_status':all_response.status_code,'all_body':all_response.text}
(E/'partial-failure.json').write_text(json.dumps(faults,indent=2)+'\n')
record('PASS fault isolation reproduction: each individual genre failure leaves 2 singles usable but makes all endpoint return 500')
# CLI preserved: execute its real source with only catalog acquisition frozen.
cli=(root/'scripts/recommend.py').read_text()
assert cli.encode()==git('show','d6cd2db:scripts/recommend.py')
from scoring import catalog as C
for label,engine in [('before',O),('after',N)]:
    stream=io.StringIO()
    with patch.object(scoring,'api',engine),patch.object(C,'load_catalog',return_value=books),contextlib.redirect_stdout(stream):
        exec(compile(cli,str(root/'scripts/recommend.py'),'exec'),{'__name__':'__main__','__file__':str(root/'scripts/recommend.py')})
    (E/f'cli-{label}.txt').write_text(stream.getvalue())
assert (E/'cli-before.txt').read_bytes()==(E/'cli-after.txt').read_bytes()
record('PASS real CLI demo: full stdout byte-identical')
import scoring_tests as T
for label,engine in [('before',O),('after',N)]:
    stream=io.StringIO()
    with patch.object(T,'api',engine),patch.object(C,'load_catalog',return_value=books),contextlib.redirect_stdout(stream):
        T._PREVALENCE_CACHE=None;T._SERIES_DNA_CACHE=None;T.run_all()
    (E/f'suite-{label}.txt').write_text(stream.getvalue())
assert (E/'suite-before.txt').read_bytes()==(E/'suite-after.txt').read_bytes()==(E/'canonical.txt').read_bytes()
record('PASS canonical suite baseline/current/live byte-identical (collateral evidence; no direct explain_match coverage)')
(E/'mismatches.json').write_text(json.dumps(mismatches,indent=2)+'\n')
(E/'stats.json').write_text(json.dumps({'counts':stats,'mismatches':len(mismatches),'comparison_sha256':digest.hexdigest()},indent=2)+'\n')
record('COUNTS '+json.dumps(stats));record('MISMATCHES '+str(len(mismatches)))
(E/'review-output.txt').write_text('\n'.join(log)+'\n')
assert not mismatches,mismatches[:2]
