import json, re, subprocess, sys, collections, statistics as st
SP=sys.argv[1]; MAP=json.load(open(f'{SP}/e2_map.json')); RES=json.load(open(f'{SP}/e2_results.json'))
def tool_text(f):
    out=[]
    for l in open(f):
        if not l.strip(): continue
        r=json.loads(l); msg=r.get('message')
        if r.get('type')=='user' and isinstance(msg,dict) and isinstance(msg.get('content'),list):
            for c in msg['content']:
                if c.get('type')=='tool_result':
                    x=c.get('content'); out.append(x if isinstance(x,str) else '\n'.join(i.get('text','') for i in x if isinstance(i,dict)))
    t='\n'.join(out)
    t=re.sub(r'(?m)^\s*\d+[\t→]', '', t)          # Read tool line-number prefixes
    return t
def norm(s): return re.sub(r'\s+',' ',s).strip()
def distinct(lines, lo, hi):
    cnt=collections.Counter(norm(x) for x in lines)
    return {norm(lines[i]) for i in range(lo,hi) if len(norm(lines[i]))>=25 and cnt[norm(lines[i])]==1}
cache={}
def src(wt,rev,p):
    k=(wt,rev,p)
    if k not in cache: cache[k]=subprocess.run(['git','-C',wt,'show',f'{rev}:{p}'],capture_output=True,text=True).stdout.split('\n')
    return cache[k]
def rng(lines,key):
    if key=='front': return 0,next(i for i,l in enumerate(lines) if 'End of the always-read front section' in l)
    if key=='rejected':
        a=next(i for i,l in enumerate(lines) if l.startswith('## Rejected / superseded'))
        b=next(i for i,l in enumerate(lines) if i>a and l.startswith('## '))
        d=next(i for i,l in enumerate(lines) if l.startswith('## Deferred'))
        return ('multi',[(0,d),(a,b)])
    return 0,len(lines)
byaid={}
for arm in ('1','2'):
    for run,label,aid,f in MAP[arm]: byaid[aid]=f
for r in RES:
    wt=f"/Users/mathiaskurin/Documents/bookspell-copy-{r['arm']}"
    rev=subprocess.run(['git','-C',wt,'rev-parse','HEAD'],capture_output=True,text=True).stdout.strip()
    got=set(norm(x) for x in tool_text(byaid[r['aid']]).split('\n'))
    cov={}
    for key in r['coverage']:
        p,_,sect=key.partition('#'); L=src(wt,rev,p); lo,hi=rng(L,sect or 'all')
        need=distinct(L,lo,hi) if lo!='multi' else set().union(*[distinct(L,x,y) for x,y in hi]); cov[key]=len(need&got)/len(need) if need else 1.0
    r['coverage_content']=cov
json.dump(RES,open(f'{SP}/e2_results.json','w'),indent=1)
for a in '12':
    tot=ok=0; per=collections.defaultdict(list); full=0
    for r in RES:
        if r['arm']!=a: continue
        allok=True
        for k,c in r['coverage_content'].items():
            tot+=1; g=c>=0.95; ok+=g; allok&=g; per[k.split('/')[-1]].append(c)
        full+=allok
    print(f"arm{a} ({'with' if a=='1' else 'without'} read_full): {ok}/{tot} required full reads complete (>=95%); fully compliant agents {full}/21")
    for k,v in sorted(per.items()): print(f"    {k:38} mean {st.mean(v):4.0%}   complete {sum(x>=0.95 for x in v)}/{len(v)}")
