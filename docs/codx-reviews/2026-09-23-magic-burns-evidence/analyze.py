import sys,json,collections
from pathlib import Path
P=Path(__file__).resolve().parent
sys.path.insert(0,str(P.parents[2]/'scripts'))
import scoring_tests as t
from scoring import profile,pipeline,api,audit,constants
B=json.loads((P/'catalog.json').read_text()); R=json.loads((P/'results.json').read_text())
from decimal import Decimal
for book in B.values():
    if book.get('position_in_series') is not None:
        book['position_in_series']=Decimal(book['position_in_series'])
bytitle={b['title']:b for b in B.values()}
O=R['Osnat']; factors=O['detail']['Magic Burns']['trace']['factors']
num=sum(e if trope else s*e for f,s,w,e,trope in factors);den=sum(abs(e) for f,s,w,e,trope in factors)
print('RECONSTRUCTION',num,den,num/den)
for trope in [False,True]:
    fs=[x for x in factors if x[4]==trope];n=sum(e if tr else s*e for f,s,w,e,tr in fs);d=sum(abs(e) for f,s,w,e,tr in fs)
    print('TROPES' if trope else 'SCALARS',len(fs),'numerator',n,'denominator',d,'component_mean',n/d,'normalized numerator',n/den)
print('ALL FACTORS: field | book value | centroid | raw w | eff w | similarity | numerator | normalized numerator | lost potential')
for f,s,w,e,tr in sorted(factors,key=lambda x:-(x[3] if x[4] else x[1]*x[3])):
    print(f,bytitle['Magic Burns'].get(f,'present' if tr else None),O['centroid'].get(f),*[round(v,6) for v in (w,e,s,e if tr else s*e,(e if tr else s*e)/den,abs(e)-(e if tr else s*e))],sep=' | ')
print('NEGATIVE LEARNED TROPES',sorted([(f,round(w,6)) for f,w in O['weights']['tropes'].items() if w<0],key=lambda x:x[1]))
print('TAG COMPARISON')
for title in ['Magic Burns','Magic Bites','A Questionable Client','Daughter of No Worlds','When the Moon Hatched','The Midnight Library']:
    print(title,json.dumps(bytitle[title],sort_keys=True,default=str))
for name in R:
    rr=R[name];train={x['title']:x['rating'] for x in rr['train']};c,w,ids,_=profile._resolve_profile(B,train)
    print('STRUCTURE',name)
    for sign in [1,-1,0]:
        subset={i:m for i,m in ids.items() if (m>0)-(m<0)==sign}
        print('sign',sign,'n',len(subset),'clusters',profile._n_independent_clusters(B,subset),'genres',dict(collections.Counter(tuple(B[i]['genre']) for i in subset)))
    dd=profile._series_deduped_id_to_magnitude(B,ids)
    keys=list(constants.ORDINAL_FIELDS)+list(constants.NOMINAL_FIELDS)+['trope:'+k for k in w['tropes']]
    sep={k:pipeline.field_or_trope_separation(B,dd,k) for k in keys}
    print('SEPARATIONS',sorted([(k,v) for k,v in sep.items() if v is not None],key=lambda x:-abs(x[1]))[:8],'sample_ineligible',sum(v is None for v in sep.values()),'total',len(sep))
    eligible={row[1]:row[0] for row in rr['ranked']};pos=[x for x in rr['ranks'] if x['label'] in t.EXPECT_GOOD];neg=[x for x in rr['ranks'] if x['label'] in t.EXPECT_POOR]
    print('ELIGIBLE POS-NEG PAIRS',sum(eligible[p['title']]>eligible[n['title']] for p in pos for n in neg),'/',len(pos)*len(neg))
print('OSNAT RAW DATA',len(t.OSNAT_RATINGS),'curated',len(t.OSNAT_USABLE),'catalog matched',sum(k in bytitle for k in t.OSNAT_RATINGS))
print('OSNAT CATALOG-MATCHED OUTSIDE CURATED',[(k,v) for k,v in t.OSNAT_RATINGS.items() if k in bytitle and k not in t.OSNAT_USABLE])
# Broader negative check: each of the four negatives is withheld separately.
# These are sensitivity probes, not the original seven-title split.
print('OSNAT SINGLE NEGATIVE LEAVE-ONE-OUT')
for title,rating in t.OSNAT_USABLE.items():
    if rating not in t.EXPECT_POOR:continue
    train={k:v for k,v in t.OSNAT_USABLE.items() if k!=title}
    ranked=api.recommend(B,train,top_n=len(B));found=[(i+1,row[0]) for i,row in enumerate(ranked) if row[1]==title]
    a=audit.audit_book_score(B,train,title)
    print(title,'rank/score',found,'pool',len(ranked),'audit_score',a['final_score'],'validated',sorted(a['validated_fields']),'flags',a['dealbreaker_flags'])
