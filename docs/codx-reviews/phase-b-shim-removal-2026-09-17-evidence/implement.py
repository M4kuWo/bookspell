"""Derive imports from real definitions; preserve source apart from name qualification/docs."""
import ast,json,re
from pathlib import Path
E=Path(__file__).resolve().parent; root=E.parents[2]
homes=json.loads((root/'docs/codx-reviews/phase-b-module-split-2026-09-17-evidence/module-map.json').read_text())['definitions']
paths=['api/main.py','api/catalog_cache.py','scripts/scoring_tests.py','scripts/import_goodreads.py','tools/dogfood/app.py']
info={}
for rel in paths:
    p=root/rel; s=p.read_text(); saved=E/'before'/rel
    saved.parent.mkdir(parents=True,exist_ok=True)
    if saved.exists(): assert saved.read_text()==s
    else: saved.write_text(s)
    tree=ast.parse(s)
    names={n.attr for n in ast.walk(tree) if isinstance(n,ast.Attribute) and isinstance(n.value,ast.Name) and n.value.id=='R'}
    # Include documentation-only complete references, such as the trajectory helper.
    doc_names=set(re.findall(r'\bR\.(\w+)',s)) & homes.keys()
    modules={n:homes[n] for n in sorted(names|doc_names)}
    # Documentation alone does not require a runtime import.
    runtime={homes[n] for n in names}
    for name,mod in modules.items():
        t=ast.parse((root/f'scripts/scoring/{mod}.py').read_text())
        defined={n.name for n in t.body if isinstance(n,ast.FunctionDef)}|{v.id for n in t.body if isinstance(n,ast.Assign) for v in n.targets}
        assert name in defined,(name,mod)
    bound={n.id for n in ast.walk(tree) if isinstance(n,ast.Name) and isinstance(n.ctx,ast.Store)}|{n.arg for n in ast.walk(tree) if isinstance(n,ast.arg)}
    aliases={mod:('scoring_'+mod if mod in bound else mod) for mod in sorted(runtime)}
    imports='from scoring import (\n'+''.join('    '+mod+(' as '+alias if alias!=mod else '')+',\n' for mod,alias in aliases.items())+')'
    if len(aliases)<=3:
        imports='from scoring import '+', '.join(mod+(' as '+alias if alias!=mod else '') for mod,alias in aliases.items())
    s=s.replace('import recommend as R',imports)
    for name,mod in modules.items():
        s=re.sub(r'\bR\.'+re.escape(name)+r'\b',aliases.get(mod,mod)+'.'+name,s)
    # A wrapped documentation reference is not an actual attribute access.
    s=s.replace('R.user_calibrated_poor_', 'pipeline.user_calibrated_poor_')
    # Current documentation should point to the implementation, not the retired shim.
    s=s.replace('scripts/recommend.py','scripts/scoring/').replace("recommend.py's build_profile()", "scoring/profile.py's build_profile()")
    s=s.replace("recommend.py's load_catalog()", "scoring.catalog.load_catalog()")
    s=s.replace("recommend.py's", "the scoring engine's")
    s=s.replace("the scoring engine's scoring engine", 'the scoring engine')
    s=s.replace('recommend.py', 'scoring/api.py' if rel == 'api/main.py' else 'scoring/pipeline.py')
    assert not re.search(r'\bR\.|import recommend',s),rel
    p.write_text(s)
    info[rel]={'names':modules,'aliases':aliases,'runtime_attributes':sorted(names)}
p=root/'scripts/recommend.py'; s=p.read_text(); saved=E/'before/scripts/recommend.py'
if saved.exists(): assert saved.read_text()==s
else: saved.write_text(s)
t=ast.parse(s); doc=ast.get_source_segment(s,t.body[0]); main=ast.get_source_segment(s,t.body[-1])
# catalog is already a data variable in the preserved demo.
main=main.replace('catalog = load_catalog()', 'catalog = scoring_catalog.load_catalog()')
main=re.sub(r'\brecommend\(', 'api.recommend(', main)
main=re.sub(r'\bexplain_match\(', 'api.explain_match(', main)
p.write_text(doc+'\n\nfrom scoring import api, catalog as scoring_catalog\n\n\n'+main+'\n')
(E/'mapping.json').write_text(json.dumps(info,indent=2)+'\n')
print('Updated 5 consumers + CLI; implementation modules untouched')
print(json.dumps({p:v['aliases'] for p,v in info.items()},indent=2))
