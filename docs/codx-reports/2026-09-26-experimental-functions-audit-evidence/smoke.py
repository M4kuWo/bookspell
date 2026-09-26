"""Task 24: synthetic import/contract checks; no DB, ratings files or benchmarks."""
import ast
import inspect
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))
from scripts.scoring import experimental as e, profile as p, pipeline as q

names = [n.name for n in ast.parse(inspect.getsource(e)).body if isinstance(n, ast.FunctionDef)]
builders = [getattr(e, n) for n in names if n.startswith('build_profile')]
book = dict(id='a', series_id='s', overall_pace='fast', person='first',
            book_length='long', audiobook_length='epic', tropes=['revenge'])
other = dict(book, id='b', overall_pace='slow', person='third_limited', tropes=[])
catalog = {'a': book, 'b': other}
ratings = {'a': 1, 'b': -1}
print('Imported all', len(names), 'functions')
for fn in builders:
    fn({}, {})
    c, w = fn(catalog, ratings)
    print(fn.__name__, 'empty/populated OK; length keys:', sorted(k for k in c if 'length' in k))
    try:
        fn(catalog, ratings, ratings, 'print')
    except TypeError as exc:
        print('  current positional contract:', str(exc))
    try:
        fn(catalog, ratings, format_preference='print')
    except TypeError as exc:
        print('  keyword contract:', str(exc))

pool = [(book, 1), (other, 1)]
assert e._dedup_factor_for_field([], 'person') == {}
assert e._dedup_factor_plain([]) == {}
print('field divisors:', e._dedup_factor_for_field(pool, 'person'))
print('plain divisors:', e._dedup_factor_plain(pool))
c, w = e.build_profile_per_value(catalog, ratings)
print('per-value score/explain populated:', e.score_book_per_value(book, c, w), e.explain_book_per_value(book, c, w))
print('per-value score/explain empty:', e.score_book_per_value({}, {}, {}), e.explain_book_per_value({}, {}, {}))
print('production default length keys:', sorted(k for k in p.build_profile(catalog, ratings)[0] if 'length' in k))

for fn in builders[:4]:
    for zero_side in ('a', 'b'):
        small = {k: dict(v, _field_confidence={'person': 0.2} if k == zero_side else {}) for k, v in catalog.items()}
        c, w = fn(small, ratings)
        assert ('person' not in c) if zero_side == 'a' else w['person'] == 0.3
print('Four confidence-aware builders: all 8 zero-confidence nominal checks passed')

low = dict(book, _field_confidence={'overall_pace': .2, 'person': .2}, _trope_confidence={'revenge': .2})
small = {'a': low}
print('low-confidence learned keys production:', p.build_profile(small, {'a': 1}))
print('low-confidence learned keys per-value:', e.build_profile_per_value(small, {'a': 1}))
c, w = {'overall_pace': 1}, {'overall_pace': 1}
print('low-confidence candidate production:', q.score_book(low, c, w), q.explain_book(low, c, w))
print('low-confidence candidate per-value:', e.score_book_per_value(low, c, w), e.explain_book_per_value(low, c, w))
for fn in (e.score_book_per_value, e.explain_book_per_value):
    try:
        fn(book, c, w, field_prevalence={})
    except TypeError as exc:
        print('prevalence contract:', str(exc))

# Static references across tracked executable sources, including imports and internal calls.
files = subprocess.check_output(['git', 'ls-files', 'scripts', 'api', 'app', 'tools'], cwd=ROOT, text=True).splitlines()
external = []
internal = []
module_imports = []
for rel in files:
    path = ROOT / rel
    if path.suffix != '.py':
        continue
    tree = ast.parse(path.read_text(), filename=rel)
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and ('experimental' in (node.module or '') or any(a.name in names or a.name == 'experimental' for a in node.names)):
            module_imports.append((rel, node.lineno, ast.unparse(node)))
        if isinstance(node, ast.Import) and any('experimental' in a.name for a in node.names):
            module_imports.append((rel, node.lineno, ast.unparse(node)))
        name = node.id if isinstance(node, ast.Name) else node.attr if isinstance(node, ast.Attribute) else None
        if name in names:
            (internal if rel == 'scripts/scoring/experimental.py' else external).append((rel, node.lineno, name))
print('External executable references:', external)
print('Experimental module/named imports:', module_imports)
print('Internal executable references:', internal)
assert not external and not module_imports
print('PASS: nine functions run; contract drift reproduced; external dormancy confirmed statically')
