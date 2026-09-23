import os, sys, json, collections
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'scripts'))
if '--fetch' in sys.argv:
    # Only the explicitly authorized read-only role; never print credentials.
    import shlex
    values = {}
    for line in (ROOT / '.env').read_text().splitlines():
        if line.strip().startswith('CODX_READONLY_DATABASE_URL='):
            values['url'] = shlex.split(line.split('=', 1)[1])[0]
    assert values.get('url'), 'Missing read-only credential'
    os.environ['DATABASE_URL'] = values['url']

import scoring_tests as tests
from scoring import api, audit, profile, pipeline, prevalence, series, cold_start, rules, catalog

if '--fetch' in sys.argv:
    try:
        books = catalog.load_catalog()
    except Exception as exc:
        print('Read-only catalog load failed:', type(exc).__name__)
        sys.exit(1)
    (OUT / 'catalog.json').write_text(json.dumps(books, default=str, indent=2))
else:
    books = json.loads((OUT / 'catalog.json').read_text())
    from decimal import Decimal
    for book in books.values():
        if book.get('position_in_series') is not None:
            book['position_in_series'] = Decimal(book['position_in_series'])
print('Catalog books:', len(books))
result = {}
for name, ratings, held in [('Osnat', tests.OSNAT_USABLE, tests.OSNAT_HELD_OUT), ('Mathias', tests.REAL_RATINGS, tests.REAL_HELD_OUT)]:
    train = {t:r for t,r in ratings.items() if t not in held}
    print('\nRATER', name)
    metrics = tests.ranking_metrics(books, ratings, held, name)
    ranks, excluded = tests.rank_percentile_report(books, ratings, held, name)
    c,w,ids,mg = profile._resolve_profile(books, train)
    vf = pipeline.validated_dealbreaker_fields(books, ids)
    fp,tp = prevalence.build_prevalence_lookup(books, None)
    sd = series.compute_series_dna(books)
    cs = cold_start.cold_start_weight(books, ids)
    poor = pipeline.user_calibrated_poor_threshold(books, ids, c,w,field_prevalence=fp,trope_prevalence=tp)
    ranked = api.recommend(books, train, top_n=len(books))
    training = [dict(title=books[i]['title'], rating=train[books[i]['title']], magnitude=m, series=books[i]['series_name'], genre=books[i].get('genre')) for i,m in ids.items()]
    print('Training labels:', dict(collections.Counter(train.values())), 'clusters:', profile._n_independent_clusters(books,ids), 'validated:', sorted(vf), 'cold_start:', cs)
    detail = {}
    for title in held + (['Magic Bites', 'A Questionable Client', 'When the Moon Hatched', 'The Midnight Library'] if name == 'Osnat' else []):
        bid = next(i for i,b in books.items() if b['title']==title)
        trace = pipeline.score_candidate(books,bid,c,w,ids,policy='ranking',validated_fields=vf,series_dna=sd,field_prevalence=fp,trope_prevalence=tp,poor_threshold=poor,cold_start=cs,matches_genre=mg,normalized_rules=rules.normalize_user_rules(None),top_n=100)
        # In-training probes use audit (no eligibility exclusion), never reported as held out.
        detail[title] = dict(trace=trace,audit=audit.audit_book_score(books,train,title))
        print(title, 'score', detail[title]['audit']['final_score'], 'flags', trace['dealbreaker_flags'])
    result[name] = dict(metrics=metrics,ranks=ranks,excluded=excluded,train=training,centroid=c,weights=w,validated=sorted(vf),cold_start=cs,poor_threshold=poor,ranked=ranked,detail=detail)
(OUT / 'results.json').write_text(json.dumps(result,default=lambda x: sorted(x) if isinstance(x,set) else str(x),indent=2))
