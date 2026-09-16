# Task 7 — A5 _full_score migration proposal

Date: 2026-09-16. Author: CODX. Status: implemented and validated locally;
complete proposed diff preserved below, source restored afterward. No commit,
push, hosted write, or deployment.

## Baseline and scope

Synced from `4c26437` (the actual end of Task 6, rather than the older d7258b4
mentioned in the prompt) to `96f3bb7b998ca7d29841ef2a81bcd69b99d53707`.
`git merge-base --is-ancestor 06e1e6c HEAD` exited 0. A4 is present.
The protocol's “A4: explain_match() migrated onto score_candidate()” entry,
updated CODX TODO, and recent project log were read. Existing repository
conventions apply; this task requires no catalog-tagging or schema skill.

Only `_full_score()` in `scripts/scoring_tests.py` changes. Its six-argument
signature and bare-float return contract remain unchanged. All six existing
call sites remain byte-for-byte unchanged. The module's cache declarations,
`_get_prevalence_cache()`, and `_full_score()`'s cache initialization block
remain byte-for-byte unchanged. Every byte outside this function remains
unchanged. Its original historical docstring is retained as an exact prefix,
including BOTH reverted-experiment narratives; only a short A5 delegation note
is appended.

**`scripts/recommend.py` is completely byte-identical to HEAD**, not merely
AST-equal. This includes the canonical scorer, recommend(), explain_match(),
and all their helpers. Audit migration is outside this task. Even the scorer's
historical docstring listing `_full_score()` as not yet migrated is left alone;
CLDO can update that wording when recording this step as landed.

## Verified prerequisites and implementation

The original source search:

```sh
rg -n 'R\.(score_book|_apply_series_repeat|_apply_dealbreaker_veto|_apply_series_trajectory_penalty)\(' scripts/scoring_tests.py
```

found exactly these four calls, all inside `_full_score()`:

```text
263:    score, _ = R.score_book(book, centroid, weights, field_prevalence, trope_prevalence)
264:    score = R._apply_series_repeat(catalog, id_to_magnitude, book, score)
265:    score = R._apply_dealbreaker_veto(catalog, id_to_magnitude, validated_fields, book, centroid, weights, score,
267:    score = R._apply_series_trajectory_penalty(_SERIES_DNA_CACHE, book, centroid, weights, score,
```

There is no other test-side direct implementation of that chain in this file.
The replacement passes the same catalog, profile, validated fields, cached
series DNA, and cached prevalence to `R.score_candidate(..., policy="evaluation")`,
then returns only `result["scores"]["final"]`.

`load_catalog()` was inspected: it selects `b.id`, builds the book dictionaries,
and returns `{b["id"]: b for b in books}`. The fresh catalog was also checked
empirically: for ALL 978 rows, `book["id"] == catalog_key` and
`catalog[book["id"]] is book`. Thus the canonical lookup uses the same object,
not a title lookup or a copied/ambiguous row.

`poor_threshold=0.0` is explicitly a placeholder. Reading score_candidate's
source confirms that threshold is only copied into result metadata and passed
to `match_label(relevance, poor_threshold)` after the final score is assigned.
It does not enter base scoring or any modifier. `_full_score()` discards both
metadata and label, so no calibration is needed. The argument has the requested
one-line comment explaining this. Tracing confirms zero calibration calls in
the migrated helper. Targeted numerical checks also pass thresholds 0.2 and
0.54 to the same canonical context and verify identical final float bits.
Existing caller-side calibration (including recalibration after ablation) is
untouched.

No evidence optimization is attempted: factors, matches, mismatches,
dealbreaker flags, series note, and label are still computed by score_candidate
and discarded by `_full_score()`. The score path and operation order are the
already-landed evaluation policy. The diff is 12 insertions / 8 deletions,
inside `_full_score()` only, including the appended docstring note.

## Why the canonical suite IS meaningful here

Unlike Task 6, `_full_score()` is on real execution paths in `run_all()`.
An AST-derived local-function call graph independently confirmed all six call
sites (five calling functions, with two calls in contrastive-pair ranking):

```text
line 185: run_all -> run_leave_one_out_diagnostic -> _full_score
line 323: run_all -> run_held_out_test -> _full_score
line 694: run_all -> run_ablation_study -> run_ablation_held_out -> _full_score
line 803: run_all -> print_threshold_diagnostic -> run_threshold_diagnostic -> _full_score
line 1576: run_all -> run_contrastive_pairs_diagnostic -> check_contrastive_pair_ranking -> _full_score
line 1577: run_all -> run_contrastive_pairs_diagnostic -> check_contrastive_pair_ranking -> _full_score
```

Those run_all scenarios execute real held-out, leave-one-out, ablation,
threshold, and contrastive diagnostics whose scores/labels/metrics contribute
to the suite output. The printed suite includes those scenarios; this is not
an analogy to Task 5 or merely a mention in a comment. The complete canonical
suite is therefore the primary regression evidence for this migration, backed
by the smaller direct-return comparison below.

## Validation results

The original scoring-tests source and original recommendation source were
saved before editing and subsequently checked against HEAD bytes. The test
AST comparison finds `_full_score` as the ONLY changed top-level function,
with no functions/classes added or removed. Signature ASTs match. Original
docstring text is an exact prefix of the new docstring. Cache initialization
source text matches exactly, as does every byte outside the function, which
also proves the six caller bodies and cache definitions were not edited.

### Full canonical before/after runs

Both full `run_all()` invocations passed (exit 0), with all 29,591 output bytes
identical and matching SHA-256:

`8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea`

Full byte equality was asserted, not just a visual diff or rounded scorecard
comparison. Combined stdout/stderr is captured without normalization. The
suite includes all its current scenarios, including format-aware held-out
validation and permanent confidence-floor regressions. Both complete outputs
are embedded below. These two primary runs use the real unchanged loader and
the existing codx_readonly role; no module/scoring function is monkeypatched.

### Targeted bit-exact supplement

Twelve original/migrated helper-return comparisons span three real profiles
(Mathias, Osnat, Gabriel), two real candidates each, and baseline versus
ablated weights. Candidate titles are removed from each training profile.
Ablation uses the existing `_apply_ablation(weights, ["person", "tropes"])`,
zeroing the scalar and emptying trope weights exactly as the real ablation
caller does. All six ablated results actually differ from their corresponding
baseline, so the ablation cases are not inert fixtures.

Every result must be a bare Python float and match via IEEE-754 double bytes
(`struct.pack('!d', score)`), without rounding or tolerance. The complete hex
encodings are printed below. The original and migrated test modules share the
SAME recommendation module (`O.R is N.R is R`, asserted), avoiding the known
split-import pitfall. Both sides use the SAME fresh in-memory catalog snapshot.

The migrated calls are traced without replacing any helper. The first call
starts with empty module caches, then subsequent calls use the warm caches:
exactly one series-DNA build, exactly one prevalence build, twelve canonical
calls, and zero calibration calls. Cache object identities remain stable,
and original/migrated cache contents agree. Input arguments and the catalog
are checked for mutation. The placeholder is checked in actual call locals,
not merely assumed from source.

All twelve comparisons passed. No code correction was needed after the initial
migration. This supplement intentionally remains small; unlike Task 6, the
canonical suite itself provides the broad scenario coverage. This demonstrates
current-suite and named-input equivalence, not all malformed catalogs or every
possible future caller that violates the existing book-from-catalog contract.

## Full run_all wall-clock cost (not a single-call estimate)

A small launcher imports the real suite, starts `time.perf_counter()` immediately
before `T.run_all()`, and records elapsed time in a separate JSON file afterward.
It does not contaminate the suite output with timings. These first measurements
include live database catalog loading and every run_all scenario; module import
and process startup are excluded.

| Full run_all with real database loading | Wall-clock seconds |
|---|---:|
| Before | 5.790525208227336 |
| After | 4.989866833202541 |

That single live pair was about 0.801 seconds faster after migration, despite
the additional evidence work. It is NOT evidence of a scoring speedup: live
connection/query variability is included and can mask a comparatively small
CPU cost. This uncertainty justified the following controlled measurement,
not a change or optimization to the proposal.

Three more COMPLETE run_all invocations per implementation use the same frozen
catalog, alternating original/migrated execution order. Only `R.load_catalog`
is substituted to return that snapshot; both test modules are verified to
share that SAME R object. No score, profile, calibration, scenario, or loop is
replaced. Both module caches are reset to None before each complete run,
matching a fresh suite process. The real loader is restored in a finally block.
Every output is also checked byte-for-byte against the original canonical run,
and the catalog is checked for mutation.

| Full run_all, database I/O excluded | Three samples (seconds) | Median |
|---|---|---:|
| Original | 1.7142190411686897, 1.706408082973212, 1.6895950827747583 | 1.706408082973212 |
| Migrated | 1.9010663339868188, 1.9099896252155304, 1.9035927499644458 | 1.9035927499644458 |

The controlled median increase is 0.19718466699123383 seconds, ratio
1.115555399062376 (about **11.6% slower** for the full suite's computation on
this machine/catalog). All six full outputs still have the same SHA-256 as the
primary canonical runs. This is an observed local cost with a small sample,
not a universal latency estimate. Both the noisy live wall-clock figures and
the controlled whole-suite cost are retained here honestly. No optimization,
cache redesign, evidence suppression, or delayed label computation was attempted.

## Exact commands and captured execution evidence

Sync and baseline checks:

```sh
git pull --ff-only
git rev-parse HEAD
git status --short
git merge-base --is-ancestor 06e1e6c HEAD
git config core.hooksPath
```

The pull used the already-established execution-tool escalation for protected
Git metadata/network access. Actual output:

```text
From https://github.com/M4kuWo/bookspell
   4c26437..96f3bb7  main       -> origin/main
Updating 4c26437..96f3bb7
Fast-forward
 docs/TODO.md                                       |   33 +-
 ...-explain-match-migration-proposal-2026-09-16.md | 1569 ++++++++++++++++++++
 docs/project-log.md                                |   65 +
 docs/scoring-test-protocol.md                      |   88 ++
 scripts/recommend.py                               |   39 +-
 5 files changed, 1771 insertions(+), 23 deletions(-)
 create mode 100644 docs/codx-reviews/codx-a4-explain-match-migration-proposal-2026-09-16.md
```

HEAD: `96f3bb7b998ca7d29841ef2a81bcd69b99d53707`. Ancestor check exit 0,
no output. Hooks path: `.githooks`. Existing untracked report locations were
preserved. This task created no commit.

Scripts below were saved in `/private/tmp/codx-task7/`. Commands:

```sh
python3 /private/tmp/codx-task7/run.py before
# Insert the proposed _full_score-only migration, uncommitted.
python3 /private/tmp/codx-task7/run.py snapshot
python3 -B /private/tmp/codx-task7/validate.py > /private/tmp/codx-task7/targeted.txt 2>&1
python3 /private/tmp/codx-task7/run.py after
python3 -B /private/tmp/codx-task7/benchmark.py > /private/tmp/codx-task7/benchmark.txt 2>&1
git diff --check
git diff -- scripts/scoring_tests.py
```

The primary suite and snapshot commands use explicit network escalation and
only CODX_READONLY_DATABASE_URL. The launcher reads only that variable from
.env and never prints its value. Targeted checks and controlled benchmarks are
offline. All commands above exited 0. `git diff --check` produced no output.
Launcher summaries:

```text
before: exit=0 bytes=29591 sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
snapshot: exit=0 bytes=101 sha256=8c204c16493ac55694fd369dff4ff22c54c912f0971b765a03a1651621728f1b
after: exit=0 bytes=29591 sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
```

Fresh snapshot output:

```text
Catalog books: 978 snapshot sha256: ee48604797cbb4f56ab22a65e3bea3aac96078b7f67fceacc13c42ec7332cee9
```

It happens to match prior tasks' snapshot hashes, but was fetched anew.
Timing JSON files (`before-timing.json`, `after-timing.json`):

```json
{"run_all_wall_seconds": 5.790525208227336, "includes_live_catalog_load": true}
```

```json
{"run_all_wall_seconds": 4.989866833202541, "includes_live_catalog_load": true}
```

Source/diff integrity checks:

```text
original_tests.py bytes=86431 sha256=d34f99e8d08f2e6bdc540353b65d3f7464b8c5c9bce39089745e3d518282b23a
original_recommend.py bytes=205417 sha256=595ab8907f50029394bffa28b5dd1bed45915da32c52794e9dcb7aa2a8ebb861
targeted.txt bytes=1741 sha256=77062f70ecc06dee51e8e6a0e751221f9810582d130659feaa6bca4461cc02f7
scripts/scoring_tests.py HEAD=d34f99e8d08f2e6bdc540353b65d3f7464b8c5c9bce39089745e3d518282b23a working=4dc979831db39effd58db880172b0744c1621792434d8a7dcdc3a362c6f743b7
scripts/recommend.py HEAD=595ab8907f50029394bffa28b5dd1bed45915da32c52794e9dcb7aa2a8ebb861 working=595ab8907f50029394bffa28b5dd1bed45915da32c52794e9dcb7aa2a8ebb861
patch sha256=9e098fb9b5eac58c815a7a910f62ebe407547ea8533e5582f75e30cec8b74f22
```

For independent reproduction, use an isolated checkout at the baseline above,
create the temporary directory, and save the following scripts there. Save
HEAD's scoring_tests.py as `original_tests.py` and recommend.py as
`original_recommend.py` before applying the patch. Run before, apply only the
single proposed diff, fetch/reuse the catalog snapshot, then run targeted,
after, and controlled whole-suite timing. The original test module is loaded
with its real repository `__file__` so local rater paths resolve correctly.
A newer catalog may change values/timings; both sides must use the same data.

## Targeted validation output (complete, exit 0)

```text
PASS only _full_score AST changed; signature, historical docstring prefix, cache setup, six callers and all outside bytes unchanged
PASS scripts/recommend.py byte-identical; shared module identity O.R is N.R is R
PASS book[id] equals catalog key and resolves identical object for all 978 rows
PASS Mathias base 'Warbreaker' float64=3fe8bf9ac1333ca9 score=0.773389222473175
PASS Mathias base 'Royal Assassin' float64=3fd4e22b6696dd9c score=0.32630429285515006
PASS Mathias ablated-person-and-tropes 'Warbreaker' float64=3fe79325f63209a5 score=0.7367124374871322
PASS Mathias ablated-person-and-tropes 'Royal Assassin' float64=3fd7e0149249eb7c score=0.3730517796135968
PASS Osnat base 'Iron Flame' float64=3fe82352804856e1 score=0.75431180052939
PASS Osnat base 'Divergent' float64=3fe52d0ee4dd8c09 score=0.6617502660777755
PASS Osnat ablated-person-and-tropes 'Iron Flame' float64=3fe5edd0f4f19d3f score=0.6852803024347977
PASS Osnat ablated-person-and-tropes 'Divergent' float64=3fe488e89eb1b5d4 score=0.6417124843116491
PASS Gabriel base 'Light Bringer' float64=3fd3ae0bb47bbe1f score=0.3074979078801067
PASS Gabriel base 'Harry Potter and the Chamber of Secrets' float64=3fe4c977ec738794 score=0.6495933168591699
PASS Gabriel ablated-person-and-tropes 'Light Bringer' float64=3fde8f961bcbeaf2 score=0.4775138160181732
PASS Gabriel ablated-person-and-tropes 'Harry Potter and the Chamber of Secrets' float64=3fe5404bd622a85b score=0.6640986616450947
PASS targeted return comparisons: 12 ablations changing score: 6
PASS migrated-call trace: {"canonical_calls": 12, "prevalence_builds": 1, "series_builds": 1} calibration_calls=0
PASS cold initialization once, warm cache objects reused, placeholder does not affect score, no input mutation
```

## Controlled full-suite timing output (complete, exit 0)

```text
PASS full run_all original trial=1 seconds=1.7142190411686897 output_sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
PASS full run_all migrated trial=1 seconds=1.9010663339868188 output_sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
PASS full run_all migrated trial=2 seconds=1.9099896252155304 output_sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
PASS full run_all original trial=2 seconds=1.706408082973212 output_sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
PASS full run_all original trial=3 seconds=1.6895950827747583 output_sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
PASS full run_all migrated trial=3 seconds=1.9035927499644458 output_sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
FULL SUITE controlled measurements: {"original": [1.7142190411686897, 1.706408082973212, 1.6895950827747583], "migrated": [1.9010663339868188, 1.9099896252155304, 1.9035927499644458]}
FULL SUITE medians original=1.706408082973212 migrated=1.9035927499644458 delta=0.19718466699123383 ratio=1.115555399062376
PASS: all six COMPLETE run_all outputs byte-identical; only loader substituted, both module caches reset before each invocation; catalog unchanged
```

## Read-only launcher

```python
import os, re, shlex, subprocess, sys, hashlib
from pathlib import Path
root = Path.cwd()
s = (root / '.env').read_text()
m = re.search(r'(?m)^\s*(?:export\s+)?CODX_READONLY_DATABASE_URL\s*=\s*(.*)$', s)
if not m: raise SystemExit('Missing CODX_READONLY_DATABASE_URL')
parts = shlex.split(m.group(1), comments=True)
if len(parts) != 1 or not parts[0]: raise SystemExit('Invalid read-only variable')
e = os.environ.copy()
e['CODX_READONLY_DATABASE_URL'] = parts[0]
e['PYTHONDONTWRITEBYTECODE'] = '1'
mode = sys.argv[1]
e['TASK7_RUN_LABEL'] = mode
command = 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 /private/tmp/codx-task7/timed_suite.py' if mode in ('before', 'after') else 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 /private/tmp/codx-task7/snapshot.py'
p = subprocess.run(['zsh', '-f', '-c', command], env=e, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
if parts[0].encode() in p.stdout: raise SystemExit('Credential appeared in output; not saved')
path = Path('/private/tmp/codx-task7') / (mode + '.txt')
path.write_bytes(p.stdout)
print(f'{mode}: exit={p.returncode} bytes={len(p.stdout)} sha256={hashlib.sha256(p.stdout).hexdigest()}')
if p.returncode: print(p.stdout.decode())
sys.exit(p.returncode)
```

## Full run_all timing entry point

```python
import json,os,sys,time
from pathlib import Path
sys.path.insert(0,str(Path.cwd()/'scripts'))
import scoring_tests as T
start=time.perf_counter()
try:
    T.run_all()
finally:
    elapsed=time.perf_counter()-start
    Path('/private/tmp/codx-task7',os.environ['TASK7_RUN_LABEL']+'-timing.json').write_text(json.dumps({'run_all_wall_seconds':elapsed,'includes_live_catalog_load':True}))
```

## Snapshot script

```python
import sys,pickle,hashlib
from pathlib import Path
sys.path.insert(0,str(Path.cwd()/'scripts'))
import recommend as R
catalog=R.load_catalog()
data=pickle.dumps(catalog)
Path('/private/tmp/codx-task7/catalog.pickle').write_bytes(data)
print('Catalog books:',len(catalog),'snapshot sha256:',hashlib.sha256(data).hexdigest())
```

## Targeted validation harness

```python
import ast,contextlib,copy,hashlib,io,json,pickle,struct,sys,types
from collections import Counter
from pathlib import Path
ROOT=Path.cwd();WORK=Path('/private/tmp/codx-task7')
sys.path.insert(0,str(ROOT/'scripts'))
import scoring_tests as N
import recommend as R
source=(WORK/'original_tests.py').read_text();new=Path('scripts/scoring_tests.py').read_text()
O=types.ModuleType('original_scoring_tests');O.__file__=str(ROOT/'scripts/scoring_tests.py')
exec(compile(source,'<original-scoring-tests>','exec'),O.__dict__)
assert O.R is N.R is R
old_nodes={n.name:n for n in ast.parse(source).body if isinstance(n,(ast.FunctionDef,ast.ClassDef))}
new_nodes={n.name:n for n in ast.parse(new).body if isinstance(n,(ast.FunctionDef,ast.ClassDef))}
assert old_nodes.keys()==new_nodes.keys()
assert {name for name in old_nodes if ast.dump(old_nodes[name])!=ast.dump(new_nodes[name])}=={'_full_score'}
a,b=old_nodes['_full_score'],new_nodes['_full_score']
assert ast.dump(a.args)==ast.dump(b.args)
oldlines,newlines=source.splitlines(keepends=True),new.splitlines(keepends=True)
assert oldlines[:a.lineno-1]==newlines[:b.lineno-1] and oldlines[a.end_lineno:]==newlines[b.end_lineno:]
assert ast.get_docstring(b,clean=False).startswith(ast.get_docstring(a,clean=False))
oldbody=''.join(oldlines[a.lineno-1:a.end_lineno]);newbody=''.join(newlines[b.lineno-1:b.end_lineno])
assert oldbody[oldbody.index('    global _SERIES_DNA_CACHE'):oldbody.index('    score, _ =')]==newbody[newbody.index('    global _SERIES_DNA_CACHE'):newbody.index('    result =')]
assert Path('scripts/recommend.py').read_bytes()==(WORK/'original_recommend.py').read_bytes()
print('PASS only _full_score AST changed; signature, historical docstring prefix, cache setup, six callers and all outside bytes unchanged')
print('PASS scripts/recommend.py byte-identical; shared module identity O.R is N.R is R')
cat=pickle.loads((WORK/'catalog.pickle').read_bytes());before=pickle.dumps(cat)
assert all(book['id']==bid and cat[book['id']] is book for bid,book in cat.items())
print('PASS book[id] equals catalog key and resolves identical object for all',len(cat),'rows')
titles={b['title']:bid for bid,b in cat.items()}
counts=Counter();calls=0

def trace(frame,event,arg):
    if event=='call':
        if frame.f_code is R.compute_series_dna.__code__:counts['series_builds']+=1
        if frame.f_code is R.build_prevalence_lookup.__code__:counts['prevalence_builds']+=1
        if frame.f_code is R.user_calibrated_poor_threshold.__code__:counts['calibration_calls']+=1
        if frame.f_code is R.score_candidate.__code__:
            counts['canonical_calls']+=1
            assert frame.f_locals['poor_threshold']==0.0
            assert frame.f_locals['policy']=='evaluation'
    return None

profiles=[('Mathias',N.REAL_RATINGS,['Warbreaker','Royal Assassin']),
          ('Osnat',N.OSNAT_USABLE,['Iron Flame','Divergent']),
          ('Gabriel',N.GABRIEL_RATINGS,[t for t in N.GABRIEL_RATINGS if t in titles][:2])]
O._SERIES_DNA_CACHE=O._PREVALENCE_CACHE=None
N._SERIES_DNA_CACHE=N._PREVALENCE_CACHE=None
cache_ids=None;changed_by_ablation=0
for name,ratings,candidates in profiles:
    train={t:r for t,r in ratings.items() if t not in candidates}
    with contextlib.redirect_stdout(io.StringIO()):c,w,ids,_=R._resolve_profile(cat,train)
    validated=R.validated_dealbreaker_fields(cat,ids)
    ablated=N._apply_ablation(w,['person','tropes'])
    assert not ablated.get('tropes')
    if 'person' in ablated:assert ablated['person']==0.0
    base_scores={}
    for variant,weights in [('base',w),('ablated-person-and-tropes',ablated)]:
        for title in candidates:
            book=cat[titles[title]];args=(cat,ids,validated,c,weights,book)
            args_before=pickle.dumps(args)
            old=O._full_score(*args)
            sys.settrace(trace)
            try:result=N._full_score(*args)
            finally:sys.settrace(None)
            assert type(old) is type(result) is float
            assert struct.pack('!d',old)==struct.pack('!d',result),(name,variant,title,old,result)
            assert pickle.dumps(args)==args_before
            new_cache_ids=(id(N._SERIES_DNA_CACHE),id(N._PREVALENCE_CACHE))
            if cache_ids is None:cache_ids=new_cache_ids
            else:assert cache_ids==new_cache_ids
            assert O._SERIES_DNA_CACHE==N._SERIES_DNA_CACHE and O._PREVALENCE_CACHE==N._PREVALENCE_CACHE
            if variant=='base':base_scores[title]=old
            elif old!=base_scores[title]:changed_by_ablation+=1
            # The threshold is metadata + label-only, also verified numerically.
            fp,tp=N._PREVALENCE_CACHE
            alternatives=[R.score_candidate(cat,book['id'],c,weights,ids,policy='evaluation',validated_fields=validated,
                series_dna=N._SERIES_DNA_CACHE,field_prevalence=fp,trope_prevalence=tp,poor_threshold=t)['scores']['final'] for t in [0.2,0.54]]
            assert all(struct.pack('!d',v)==struct.pack('!d',result) for v in alternatives)
            calls+=1
            print('PASS',name,variant,repr(title),'float64='+struct.pack('!d',result).hex(),'score='+repr(result))
assert calls==12 and changed_by_ablation>0
assert counts==Counter(series_builds=1,prevalence_builds=1,canonical_calls=12),counts
assert pickle.dumps(cat)==before
print('PASS targeted return comparisons:',calls,'ablations changing score:',changed_by_ablation)
print('PASS migrated-call trace:',json.dumps(dict(counts),sort_keys=True),'calibration_calls=0')
print('PASS cold initialization once, warm cache objects reused, placeholder does not affect score, no input mutation')
```

## Controlled whole-suite benchmark

```python
import contextlib,hashlib,io,json,pickle,statistics,sys,time,types
from pathlib import Path
ROOT=Path.cwd();WORK=Path('/private/tmp/codx-task7')
sys.path.insert(0,str(ROOT/'scripts'))
import scoring_tests as N
import recommend as R
O=types.ModuleType('original_tests_benchmark');O.__file__=str(ROOT/'scripts/scoring_tests.py')
exec(compile((WORK/'original_tests.py').read_text(),'<original-tests-benchmark>','exec'),O.__dict__)
assert O.R is N.R is R
catalog=pickle.loads((WORK/'catalog.pickle').read_bytes());catalog_before=pickle.dumps(catalog)
expected=(WORK/'before.txt').read_bytes()
real_loader=R.load_catalog;R.load_catalog=lambda:catalog
measurements={'original':[],'migrated':[]}
try:
    for trial in range(3):
        order=[('original',O),('migrated',N)] if trial%2==0 else [('migrated',N),('original',O)]
        for name,module in order:
            module._SERIES_DNA_CACHE=module._PREVALENCE_CACHE=None
            out=io.StringIO()
            start=time.perf_counter()
            with contextlib.redirect_stdout(out):module.run_all()
            elapsed=time.perf_counter()-start
            data=out.getvalue().encode()
            assert data==expected
            assert pickle.dumps(catalog)==catalog_before
            measurements[name].append(elapsed)
            print('PASS full run_all',name,'trial='+str(trial+1),'seconds='+repr(elapsed),'output_sha256='+hashlib.sha256(data).hexdigest(),flush=True)
finally:R.load_catalog=real_loader
old=statistics.median(measurements['original']);new=statistics.median(measurements['migrated'])
print('FULL SUITE controlled measurements:',json.dumps(measurements))
print('FULL SUITE medians original='+repr(old)+' migrated='+repr(new)+' delta='+repr(new-old)+' ratio='+repr(new/old))
print('PASS: all six COMPLETE run_all outputs byte-identical; only loader substituted, both module caches reset before each invocation; catalog unchanged')
```

## Canonical suite before (complete output, exit 0)

```text
=== Scenario 1: real-rater held-out validation ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.607 Good match     OK
    Rhythm of War                loved        0.664 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.454 Poor match     OK
    Eragon                       it_was_okay  0.539 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.551 Good match     MISS
    The Last Wish                liked        0.718 Good match     OK
    Old Man's War                liked        0.460 Poor match     MISS
    Assassin's Quest             disliked     0.528 Poor match     OK
  held-out: 8/11 correct, 2 wrong, 1 soft-miss

=== Scenario 1b: real-rater held-out validation, REAL format_preference (2026-09-15, F3 fix) ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.608 Good match     OK
    Rhythm of War                loved        0.665 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.452 Poor match     OK
    Eragon                       it_was_okay  0.532 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.548 Mixed match    MISS
    The Last Wish                liked        0.717 Good match     OK
    Old Man's War                liked        0.463 Poor match     MISS
    Assassin's Quest             disliked     0.528 Poor match     OK
  held-out, format_preference=audiobook: 8/11 correct, 2 wrong, 1 soft-miss

=== Scenario 2: WEIGHT_CAP domination check ===
  current formula: person mismatch=0.299  pov_count mismatch=0.000  max_trope weight=0.429

=== Scenario 3: sparse-data check (original 16-book list) ===
    Warbreaker                   loved        0.684 Good match     OK
    A Clash of Kings             loved        0.713 Good match     OK
    Rhythm of War                loved        0.670 Good match     OK
    The Wise Man's Fear          hated        0.510 Poor match     OK
    Royal Assassin               disliked     0.486 Poor match     OK
    Skyward                      disliked     0.370 Poor match     OK
    Eragon                       it_was_okay  0.488 Poor match     SOFT-MISS
    The Last Wish                liked        0.420 Poor match     MISS
    Assassin's Quest             disliked     0.605 Good match     MISS
  sparse (16 ratings): 6/9 correct, 2 wrong, 1 soft-miss

=== Scenario 4: second rater (Osnat) -- held-out validation (30 usable ratings) ===
    A Court of Wings and Ruin    loved        0.838 Strong match   OK
    Harry Potter and the Half-Blood Prince loved        0.857 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.748 Good match     SOFT-MISS
    Divergent                    liked        0.721 Good match     OK
    Iron Flame                   it_was_okay  0.725 Good match     SOFT-MISS
    Daughter of No Worlds        hated        0.602 Good match     MISS
    Magic Burns                  hated        0.884 Strong match   MISS
  Osnat held-out: 3/7 correct, 2 wrong, 2 soft-miss

=== Scenario 4b: third rater (Dandan) -- held-out validation (32 ratings) ===
    The Path of Daggers          hated        0.061 Poor match     OK
    The Way of Kings             it_was_okay  0.376 Mixed match    OK
    Words of Radiance            loved        0.471 Mixed match    MISS
    Mistborn: The Final Empire   it_was_okay  0.439 Mixed match    OK
    The Hero of Ages             it_was_okay  0.230 Mixed match    OK
    Ender's Shadow               loved        0.728 Good match     OK
    Shadows of Self              loved        0.216 Mixed match    MISS
  Dandan held-out: 5/7 correct, 2 wrong, 0 soft-miss

=== Scenario 4c: fourth rater (Gabriel) -- leave-one-out (7 ratings, too few for held-out) ===
  Gabriel leave-one-out:
    Light Bringer                       true=it_was_okay  0.274 (Mixed match) OK
    Harry Potter and the Chamber of Secrets true=liked        0.650 (Good match) OK
    Before They Are Hanged              true=liked        0.647 (Good match) OK
    Red Rising                          true=disliked     0.688 (Good match) MISS
    Golden Son                          true=loved        0.154 (Poor match) MISS
    Morning Star                        true=liked        0.265 (Mixed match) MISS
    The Dragon Reborn                   true=liked        0.516 (Mixed match) MISS

=== Scenario 5: series/author-isolated held-out (no series or author memory) ===
    Warbreaker                   loved        0.750 Good match     OK
    A Clash of Kings             loved        0.600 Good match     OK
    Rhythm of War                loved        0.617 Good match     OK
    The Wise Man's Fear          hated        0.480 Poor match     OK
    Royal Assassin               disliked     0.556 Good match     MISS
    Skyward                      disliked     0.446 Poor match     OK
    Eragon                       it_was_okay  0.569 Good match     SOFT-MISS
    Interview with the Vampire   disliked     0.561 Good match     MISS
    The Last Wish                liked        0.719 Good match     OK
    Old Man's War                liked        0.443 Poor match     MISS
    Assassin's Quest             disliked     0.738 Good match     MISS
  Mathias, series-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    Warbreaker                   loved        0.593 Good match     OK
    A Clash of Kings             loved        0.553 Good match     OK
    Rhythm of War                loved        0.455 Poor match     MISS
    The Wise Man's Fear          hated        0.490 Poor match     OK
    Royal Assassin               disliked     0.579 Good match     MISS
    Skyward                      disliked     0.378 Poor match     OK
    Eragon                       it_was_okay  0.515 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.493 Poor match     OK
    The Last Wish                liked        0.651 Good match     OK
    Old Man's War                liked        0.404 Poor match     MISS
    Assassin's Quest             disliked     0.688 Good match     MISS
  Mathias, author-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    A Court of Wings and Ruin    loved        0.737 Good match     OK
    Harry Potter and the Half-Blood Prince loved        0.811 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.593 Good match     SOFT-MISS
    Divergent                    liked        0.653 Good match     OK
    Iron Flame                   it_was_okay  0.550 Mixed match    OK
    Daughter of No Worlds        hated        0.575 Good match     MISS
    Magic Burns                  hated        0.855 Strong match   MISS
  Osnat, series-isolated: 4/7 correct, 2 wrong, 1 soft-miss

=== Benchmark scorecard ===
  Test                              n    Bucket acc.        Pairwise acc.      Loved recall       Hated reject.    
  -----------------------------------------------------------------------------------------------------------------
  Mathias -- full (132 ratings)     11   73% OK             84% OK             80% OK             80% OK           
  Mathias -- sparse (16 ratings)    9    67% OK             73% OK             75% OK             75% OK           
  Mathias -- series-isolated        11   55% OK             71% OK             80% OK             40% OK           
  Mathias -- author-isolated        11   55% OK             56% OK             60% (target 65%)   60% OK           
  Osnat -- full (30 ratings)        7    43% (target 55%)   61% (target 70%)   100% OK            0% (target 40%)  
  Osnat -- series-isolated          7    57% OK             67% OK             100% OK            0% (target 25%)  
  Dandan -- full (32 ratings)       7    71% OK             80% OK             33% (target 75%)   100% OK          
  Gabriel -- LOO (7 ratings)        7    43% (target 45%)   20% (target 60%)   40% (target 65%)   0% (target 30%)  

=== Scenario 6: DNA ablation (post-hoc field-group zeroing) ===
  Baseline (nothing removed):
    Mathias, full    bucket_accuracy=73%  pairwise_accuracy=84%  loved_recall=80%  hated_rejection=80%
    Mathias, sparse  bucket_accuracy=67%  pairwise_accuracy=73%  loved_recall=75%  hated_rejection=75%
    Osnat, full      bucket_accuracy=43%  pairwise_accuracy=61%  loved_recall=100%  hated_rejection=0%

  Group removed       Base              Bucket acc.      Pairwise acc.    Loved recall     Hated reject.  
  --------------------------------------------------------------------------------------------------------
  tropes              Mathias, full     73% (+0pp)       82% (-2pp)       80% (+0pp)       80% (+0pp)     
  tropes              Mathias, sparse   67% (+0pp)       83% (+10pp)      100% (+25pp)     50% (-25pp)    
  tropes              Osnat, full       43% (+0pp)       22% (-39pp)      100% (+0pp)      0% (+0pp)      
  pace                Mathias, full     73% (+0pp)       82% (-2pp)       80% (+0pp)       80% (+0pp)     
  pace                Mathias, sparse   67% (+0pp)       70% (-3pp)       75% (+0pp)       75% (+0pp)     
  pace                Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  tone                Mathias, full     82% (+9pp)       87% (+2pp)       80% (+0pp)       100% (+20pp)   
  tone                Mathias, sparse   67% (+0pp)       80% (+7pp)       75% (+0pp)       75% (+0pp)     
  tone                Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  pov_structure       Mathias, full     64% (-9pp)       82% (-2pp)       80% (+0pp)       60% (-20pp)    
  pov_structure       Mathias, sparse   56% (-11pp)      67% (-7pp)       75% (+0pp)       50% (-25pp)    
  pov_structure       Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  stakes_drive        Mathias, full     73% (+0pp)       87% (+2pp)       80% (+0pp)       80% (+0pp)     
  stakes_drive        Mathias, sparse   67% (+0pp)       77% (+3pp)       75% (+0pp)       75% (+0pp)     
  stakes_drive        Osnat, full       43% (+0pp)       72% (+11pp)      100% (+0pp)      0% (+0pp)      
  content_intensity   Mathias, full     82% (+9pp)       80% (-4pp)       80% (+0pp)       100% (+20pp)   
  content_intensity   Mathias, sparse   67% (+0pp)       73% (+0pp)       75% (+0pp)       75% (+0pp)     
  content_intensity   Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  craft_density       Mathias, full     73% (+0pp)       84% (+0pp)       80% (+0pp)       80% (+0pp)     
  craft_density       Mathias, sparse   67% (+0pp)       77% (+3pp)       75% (+0pp)       75% (+0pp)     
  craft_density       Osnat, full       43% (+0pp)       67% (+6pp)       100% (+0pp)      0% (+0pp)      
  magic_scifi         Mathias, full     73% (+0pp)       89% (+4pp)       80% (+0pp)       80% (+0pp)     
  magic_scifi         Mathias, sparse   67% (+0pp)       70% (-3pp)       75% (+0pp)       75% (+0pp)     
  magic_scifi         Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      

=== Scenario 7: Poor-match threshold diagnostic ===
  Base              Threshold variant             Bucket acc.    Pairwise acc.  Loved recall   Hated reject.
  ----------------------------------------------------------------------------------------------------------
  Mathias, full     fixed 0.35 (old default)      45%            84%            80%            0%           
  Mathias, full     fixed 0.40                    45%            84%            80%            0%           
  Mathias, full     fixed 0.45                    64%            84%            80%            40%          
  Mathias, full     fixed 0.50                    73%            84%            80%            60%          
  Mathias, full     fixed 0.54                    73%            84%            80%            80%          
  Mathias, full     calibrated (0.540) -- LANDED  73%            84%            80%            80%          

  Mathias, sparse   fixed 0.35 (old default)      44%            73%            75%            0%           
  Mathias, sparse   fixed 0.40                    56%            73%            75%            25%          
  Mathias, sparse   fixed 0.45                    56%            73%            75%            25%          
  Mathias, sparse   fixed 0.50                    56%            73%            75%            50%          
  Mathias, sparse   fixed 0.54                    67%            73%            75%            75%          
  Mathias, sparse   calibrated (0.540) -- LANDED  67%            73%            75%            75%          

  Osnat, full       fixed 0.35 (old default)      43%            61%            100%           0%           
  Osnat, full       fixed 0.40                    43%            61%            100%           0%           
  Osnat, full       fixed 0.45                    43%            61%            100%           0%           
  Osnat, full       fixed 0.50                    43%            61%            100%           0%           
  Osnat, full       fixed 0.54                    43%            61%            100%           0%           
  Osnat, full       calibrated (0.385) -- LANDED  43%            61%            100%           0%           

  No-negative-signal fallback check (repo owner's caveat):
    119 all-positive ratings (no disliked/hated) -> calibrated threshold = 0.350 (falls back to default, as intended)

=== Scenario 8: dealbreaker-flag sanity check (fixed threshold, all 4 raters) ===
  Mathias: false-positive rate 0/5 (flagged on a liked/loved book) -- true-positive rate 0/5 (flagged on a disliked/hated book)
  Osnat: false-positive rate 1/3 (flagged on a liked/loved book) -- true-positive rate 0/2 (flagged on a disliked/hated book)
    Harry Potter and the Goblet of Fire true=it_was_okay  -> dragons
    Divergent                           true=liked        -> slow burn romance
    Iron Flame                          true=it_was_okay  -> dragons
  Dandan: false-positive rate 3/3 (flagged on a liked/loved book) -- true-positive rate 1/1 (flagged on a disliked/hated book)
    The Path of Daggers                 true=hated        -> court intrigue; an uneven pace
    The Way of Kings                    true=it_was_okay  -> court intrigue
    Words of Radiance                   true=loved        -> court intrigue
    Mistborn: The Final Empire          true=it_was_okay  -> heist; shapeshifters
    The Hero of Ages                    true=it_was_okay  -> shapeshifters
    Ender's Shadow                      true=loved        -> an uneven pace
    Shadows of Self                     true=loved        -> flintlock fantasy setting; court intrigue; shapeshifters; a consistent pace throughout; noir detective structure
  Gabriel (LOO): false-positive rate 4/5 (flagged on a liked/loved book) -- true-positive rate 0/1 (flagged on a disliked/hated book)
    Light Bringer                       true=it_was_okay  -> space opera; rebellion against empire; revenge; mixed narrative person; soft science fiction
    Before They Are Hanged              true=liked        -> a cliffhanger ending
    Golden Son                          true=loved        -> space opera; dystopia; rebellion against empire; major character death; underdog rising
    Morning Star                        true=liked        -> space opera; rebellion against empire; major character death; hard science-fiction rigor
    The Dragon Reborn                   true=liked        -> a hard, rules-based magic system

=== Scenario 9: dealbreaker-flag sanity check (statistically validated, all 4 raters) ===
  Mathias: false-positive rate 0/5 (flagged on a liked/loved book) -- true-positive rate 0/5 (flagged on a disliked/hated book)
  Osnat: false-positive rate 1/3 (flagged on a liked/loved book) -- true-positive rate 0/2 (flagged on a disliked/hated book)
    Harry Potter and the Goblet of Fire true=it_was_okay  -> dragons
    Divergent                           true=liked        -> slow burn romance
    Iron Flame                          true=it_was_okay  -> dragons
  Dandan: false-positive rate 3/3 (flagged on a liked/loved book) -- true-positive rate 1/1 (flagged on a disliked/hated book)
    The Path of Daggers                 true=hated        -> court intrigue; an uneven pace
    The Way of Kings                    true=it_was_okay  -> court intrigue
    Words of Radiance                   true=loved        -> court intrigue
    Mistborn: The Final Empire          true=it_was_okay  -> heist; shapeshifters
    The Hero of Ages                    true=it_was_okay  -> shapeshifters
    Ender's Shadow                      true=loved        -> an uneven pace
    Shadows of Self                     true=loved        -> flintlock fantasy setting; court intrigue; shapeshifters; a consistent pace throughout; noir detective structure
  Gabriel (LOO): false-positive rate 4/5 (flagged on a liked/loved book) -- true-positive rate 0/1 (flagged on a disliked/hated book)
    Light Bringer                       true=it_was_okay  -> space opera; rebellion against empire; revenge; mixed narrative person; soft science fiction
    Before They Are Hanged              true=liked        -> a cliffhanger ending
    Golden Son                          true=loved        -> space opera; dystopia; rebellion against empire; major character death; underdog rising
    Morning Star                        true=liked        -> space opera; rebellion against empire; major character death; hard science-fiction rigor
    The Dragon Reborn                   true=liked        -> a hard, rules-based magic system

=== Scenario 10: learning curve (accuracy vs. rating-history size) ===
  Mathias (held-out set fixed at 11 books, up to 15 random samples per size):
    Train size   Pairwise acc.    Bucket acc.    Repeats
    10           69%              36%            15
    32           69%              41%            15
    54           75%              58%            15
    76           75%              63%            15
    98           80%              68%            15
    120          81%              70%            15
    132          84%              73%            1

=== Scenario 11: diversity curve (accuracy vs. author variety, size held fixed) ===
  Mathias (fixed train size=40, 40 random samples, varying only in how many distinct authors happen to appear):
    Pearson r (distinct authors vs. pairwise accuracy): +0.085
    Pearson r (distinct authors vs. bucket accuracy):   +0.055
    Author-diversity tercile     n_authors range    Pairwise acc.    Bucket acc.
    Low                          18-23              69%              48%
    Mid                          23-25              72%              53%
    High                         25-29              72%              54%

=== Scenario 12: contrastive pairs (near-identical DNA, opposite ratings) ===
  Mathias: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    The Grey Bastards (loved, held-out score 0.6789) vs The True Bastards (hated, held-out score 0.6938)  [MISS -- model can't distinguish these]
      DNA similarity: 0.859
      Field differences: {'drive': ('plot_driven', 'character_driven')}
      Tropes only in 'The Grey Bastards': ['multiple_fantasy_species']
      Tropes only in 'The True Bastards': ['court_intrigue']

  Mathias summary: model correctly ranked 0/1 contrastive pairs.
  Osnat: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    Magic Bites (liked, held-out score 0.8226) vs Magic Burns (hated, held-out score 0.8487)  [MISS -- model can't distinguish these]
      DNA similarity: 0.917
      Field differences: NONE -- fully identical on every measured field
      Tropes only in 'Magic Burns': ['found_family', 'war_story']

  Osnat summary: model correctly ranked 0/1 contrastive pairs.
  Dandan: 17 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    A Crown of Swords (it_was_okay, held-out score 0.0354) vs The Path of Daggers (hated, held-out score 0.0245)  [OK]
      DNA similarity: 0.957
      Field differences: {'book_length': ('epic', 'long')}
      Tropes only in 'A Crown of Swords': ['found_family']

    The Shadow Rising (loved, held-out score -0.0165) vs A Crown of Swords (it_was_okay, held-out score -0.0625)  [OK]
      DNA similarity: 0.952
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional')}
      Tropes only in 'The Shadow Rising': ['coming_of_age']

    The Great Hunt (loved, held-out score 0.0445) vs The Dragon Reborn (it_was_okay, held-out score -0.0219)  [OK]
      DNA similarity: 0.927
      Field differences: {'darkness': ('moderate', 'dark'), 'pace_shape': ('consistent', 'uneven')}
      Tropes only in 'The Great Hunt': ['powerful_artifact_macguffin']

    The Fires of Heaven (disliked, held-out score -0.0547) vs Lord of Chaos (loved, held-out score -0.007)  [OK]
      DNA similarity: 0.925
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Lord of Chaos': ['found_family']

    The Shadow Rising (loved, held-out score 0.0597) vs The Path of Daggers (hated, held-out score 0.0224)  [OK]
      DNA similarity: 0.913
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'book_length': ('epic', 'long')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']

    Lord of Chaos (loved, held-out score -0.0368) vs A Crown of Swords (it_was_okay, held-out score -0.0632)  [OK]
      DNA similarity: 0.91
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['major_character_death']

    The Shadow Rising (loved, held-out score -0.0363) vs The Fires of Heaven (disliked, held-out score -0.0525)  [OK]
      DNA similarity: 0.897
      Field differences: {'emotional_register': ('tense', 'gut_punch'), 'personal_stakes': ('high', 'life_threatening')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']
      Tropes only in 'The Fires of Heaven': ['major_character_death']

    The Dragon Reborn (it_was_okay, held-out score -0.0227) vs The Shadow Rising (loved, held-out score -0.0165)  [OK]
      DNA similarity: 0.891
      Field differences: {'violence_frequency': ('occasional', 'frequent'), 'book_length': ('long', 'epic'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'war_story']

    The Fires of Heaven (disliked, held-out score -0.055) vs Knife of Dreams (loved, held-out score 0.0159)  [OK]
      DNA similarity: 0.889
      Field differences: {'overall_pace': ('medium', 'fast'), 'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['found_family', 'last_minute_rescue']

    The Dragon Reborn (it_was_okay, held-out score 0.0655) vs The Path of Daggers (hated, held-out score 0.0245)  [OK]
      DNA similarity: 0.887
      Field differences: {'overall_pace': ('medium', 'slow'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Dragon Reborn': ['found_family']
      Tropes only in 'The Path of Daggers': ['war_story']

    The Fires of Heaven (disliked, held-out score -0.0552) vs The Gathering Storm (loved, held-out score 0.0547)  [OK]
      DNA similarity: 0.881
      Field differences: {'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['found_family', 'redemption_arc', 'shadow_self_confrontation']

    The Path of Daggers (hated, held-out score 0.0278) vs Winter's Heart (liked, held-out score 0.089)  [OK]
      DNA similarity: 0.876
      Field differences: {'overall_pace': ('slow', 'medium'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.0635) vs Knife of Dreams (loved, held-out score -0.0127)  [OK]
      DNA similarity: 0.874
      Field differences: {'overall_pace': ('slow', 'fast'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['last_minute_rescue', 'major_character_death']

    Lord of Chaos (loved, held-out score 0.0072) vs The Path of Daggers (hated, held-out score 0.023)  [MISS -- model can't distinguish these]
      DNA similarity: 0.871
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'book_length': ('epic', 'long'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['found_family', 'major_character_death']

    The Fires of Heaven (disliked, held-out score -0.0499) vs Winter's Heart (liked, held-out score -0.0115)  [OK]
      DNA similarity: 0.855
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'book_length': ('epic', 'long'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'The Fires of Heaven': ['major_character_death']
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.0636) vs The Gathering Storm (loved, held-out score 0.0253)  [OK]
      DNA similarity: 0.854
      Field differences: {'overall_pace': ('slow', 'medium'), 'emotional_register': ('tense', 'gut_punch'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['major_character_death', 'redemption_arc', 'shadow_self_confrontation']

    The Great Hunt (loved, held-out score 0.0445) vs A Crown of Swords (it_was_okay, held-out score -0.0609)  [OK]
      DNA similarity: 0.852
      Field differences: {'overall_pace': ('medium', 'slow'), 'darkness': ('moderate', 'dark'), 'book_length': ('long', 'epic'), 'pace_shape': ('consistent', 'uneven'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Great Hunt': ['powerful_artifact_macguffin']
      Tropes only in 'A Crown of Swords': ['war_story']

  Dandan summary: model correctly ranked 16/17 contrastive pairs.
  Gabriel: 0 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

=== Scenario 13: user-adjustable rules (none of X / less of X) ===
  parse trope key: OK
  parse valid ordinal field:value: OK
  parse valid nominal field:value: OK
  reject invalid ordinal value: OK
  reject unknown field: OK
  normalize None is empty: OK
  normalize {} is empty: OK
WARNING: unrecognized user rule key(s), ignored: ['not_a_real_field:x']
  normalize drops bad keys, keeps good ones: OK
  normalize applies default strength: OK
  normalize respects explicit strength: OK
  no rules is a guaranteed no-op: OK
  no rules is a no-op even with {}: OK
  exclude exact-matches and flags excluded: OK
  exclude leaves non-matching book untouched: OK
  reduce applies correct multiplicative discount: OK
  reduce leaves non-matching book untouched: OK
  multiple matching reduce rules stack multiplicatively: OK
  target list non-empty: OK
  target list includes a known field_value: OK
  target list includes a known trope: OK
  target list never invents unused values: OK
  sanity: baseline top-20 fantasy contains at least one YA book: OK
  exclude age_category:ya removes all YA from real recommend() output: OK
  reduce drive:romance_driven lowers its representation in top-20 (2 -> 0): OK
  All user-rules tests passed.

=== Scenario 14: confidence-floor regression checks (CODX Task 1/2 findings, 2026-09-14/15) ===
  audit_attribute_ordinal: neutral-only evidence doesn't crash: OK
  audit_attribute_ordinal: neutral rating excluded from both sides: OK
  nominal_field_separation: confidence-zeroed tags don't satisfy the sample gate: OK
  trope_separation: confidence-zeroed hits don't count as evidence either way: OK
  compute_series_dna: confidence-zeroed endpoint excluded from trajectory: OK
  experimental profile/scoring builders remain uncalled outside their own definitions: OK
  All confidence-floor regression checks passed.
```

## Canonical suite after (complete output, exit 0)

```text
=== Scenario 1: real-rater held-out validation ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.607 Good match     OK
    Rhythm of War                loved        0.664 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.454 Poor match     OK
    Eragon                       it_was_okay  0.539 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.551 Good match     MISS
    The Last Wish                liked        0.718 Good match     OK
    Old Man's War                liked        0.460 Poor match     MISS
    Assassin's Quest             disliked     0.528 Poor match     OK
  held-out: 8/11 correct, 2 wrong, 1 soft-miss

=== Scenario 1b: real-rater held-out validation, REAL format_preference (2026-09-15, F3 fix) ===
    Warbreaker                   loved        0.772 Strong match   OK
    A Clash of Kings             loved        0.608 Good match     OK
    Rhythm of War                loved        0.665 Good match     OK
    The Wise Man's Fear          hated        0.431 Poor match     OK
    Royal Assassin               disliked     0.418 Poor match     OK
    Skyward                      disliked     0.452 Poor match     OK
    Eragon                       it_was_okay  0.532 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.548 Mixed match    MISS
    The Last Wish                liked        0.717 Good match     OK
    Old Man's War                liked        0.463 Poor match     MISS
    Assassin's Quest             disliked     0.528 Poor match     OK
  held-out, format_preference=audiobook: 8/11 correct, 2 wrong, 1 soft-miss

=== Scenario 2: WEIGHT_CAP domination check ===
  current formula: person mismatch=0.299  pov_count mismatch=0.000  max_trope weight=0.429

=== Scenario 3: sparse-data check (original 16-book list) ===
    Warbreaker                   loved        0.684 Good match     OK
    A Clash of Kings             loved        0.713 Good match     OK
    Rhythm of War                loved        0.670 Good match     OK
    The Wise Man's Fear          hated        0.510 Poor match     OK
    Royal Assassin               disliked     0.486 Poor match     OK
    Skyward                      disliked     0.370 Poor match     OK
    Eragon                       it_was_okay  0.488 Poor match     SOFT-MISS
    The Last Wish                liked        0.420 Poor match     MISS
    Assassin's Quest             disliked     0.605 Good match     MISS
  sparse (16 ratings): 6/9 correct, 2 wrong, 1 soft-miss

=== Scenario 4: second rater (Osnat) -- held-out validation (30 usable ratings) ===
    A Court of Wings and Ruin    loved        0.838 Strong match   OK
    Harry Potter and the Half-Blood Prince loved        0.857 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.748 Good match     SOFT-MISS
    Divergent                    liked        0.721 Good match     OK
    Iron Flame                   it_was_okay  0.725 Good match     SOFT-MISS
    Daughter of No Worlds        hated        0.602 Good match     MISS
    Magic Burns                  hated        0.884 Strong match   MISS
  Osnat held-out: 3/7 correct, 2 wrong, 2 soft-miss

=== Scenario 4b: third rater (Dandan) -- held-out validation (32 ratings) ===
    The Path of Daggers          hated        0.061 Poor match     OK
    The Way of Kings             it_was_okay  0.376 Mixed match    OK
    Words of Radiance            loved        0.471 Mixed match    MISS
    Mistborn: The Final Empire   it_was_okay  0.439 Mixed match    OK
    The Hero of Ages             it_was_okay  0.230 Mixed match    OK
    Ender's Shadow               loved        0.728 Good match     OK
    Shadows of Self              loved        0.216 Mixed match    MISS
  Dandan held-out: 5/7 correct, 2 wrong, 0 soft-miss

=== Scenario 4c: fourth rater (Gabriel) -- leave-one-out (7 ratings, too few for held-out) ===
  Gabriel leave-one-out:
    Light Bringer                       true=it_was_okay  0.274 (Mixed match) OK
    Harry Potter and the Chamber of Secrets true=liked        0.650 (Good match) OK
    Before They Are Hanged              true=liked        0.647 (Good match) OK
    Red Rising                          true=disliked     0.688 (Good match) MISS
    Golden Son                          true=loved        0.154 (Poor match) MISS
    Morning Star                        true=liked        0.265 (Mixed match) MISS
    The Dragon Reborn                   true=liked        0.516 (Mixed match) MISS

=== Scenario 5: series/author-isolated held-out (no series or author memory) ===
    Warbreaker                   loved        0.750 Good match     OK
    A Clash of Kings             loved        0.600 Good match     OK
    Rhythm of War                loved        0.617 Good match     OK
    The Wise Man's Fear          hated        0.480 Poor match     OK
    Royal Assassin               disliked     0.556 Good match     MISS
    Skyward                      disliked     0.446 Poor match     OK
    Eragon                       it_was_okay  0.569 Good match     SOFT-MISS
    Interview with the Vampire   disliked     0.561 Good match     MISS
    The Last Wish                liked        0.719 Good match     OK
    Old Man's War                liked        0.443 Poor match     MISS
    Assassin's Quest             disliked     0.738 Good match     MISS
  Mathias, series-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    Warbreaker                   loved        0.593 Good match     OK
    A Clash of Kings             loved        0.553 Good match     OK
    Rhythm of War                loved        0.455 Poor match     MISS
    The Wise Man's Fear          hated        0.490 Poor match     OK
    Royal Assassin               disliked     0.579 Good match     MISS
    Skyward                      disliked     0.378 Poor match     OK
    Eragon                       it_was_okay  0.515 Poor match     SOFT-MISS
    Interview with the Vampire   disliked     0.493 Poor match     OK
    The Last Wish                liked        0.651 Good match     OK
    Old Man's War                liked        0.404 Poor match     MISS
    Assassin's Quest             disliked     0.688 Good match     MISS
  Mathias, author-isolated: 6/11 correct, 4 wrong, 1 soft-miss
    A Court of Wings and Ruin    loved        0.737 Good match     OK
    Harry Potter and the Half-Blood Prince loved        0.811 Strong match   OK
    Harry Potter and the Goblet of Fire it_was_okay  0.593 Good match     SOFT-MISS
    Divergent                    liked        0.653 Good match     OK
    Iron Flame                   it_was_okay  0.550 Mixed match    OK
    Daughter of No Worlds        hated        0.575 Good match     MISS
    Magic Burns                  hated        0.855 Strong match   MISS
  Osnat, series-isolated: 4/7 correct, 2 wrong, 1 soft-miss

=== Benchmark scorecard ===
  Test                              n    Bucket acc.        Pairwise acc.      Loved recall       Hated reject.    
  -----------------------------------------------------------------------------------------------------------------
  Mathias -- full (132 ratings)     11   73% OK             84% OK             80% OK             80% OK           
  Mathias -- sparse (16 ratings)    9    67% OK             73% OK             75% OK             75% OK           
  Mathias -- series-isolated        11   55% OK             71% OK             80% OK             40% OK           
  Mathias -- author-isolated        11   55% OK             56% OK             60% (target 65%)   60% OK           
  Osnat -- full (30 ratings)        7    43% (target 55%)   61% (target 70%)   100% OK            0% (target 40%)  
  Osnat -- series-isolated          7    57% OK             67% OK             100% OK            0% (target 25%)  
  Dandan -- full (32 ratings)       7    71% OK             80% OK             33% (target 75%)   100% OK          
  Gabriel -- LOO (7 ratings)        7    43% (target 45%)   20% (target 60%)   40% (target 65%)   0% (target 30%)  

=== Scenario 6: DNA ablation (post-hoc field-group zeroing) ===
  Baseline (nothing removed):
    Mathias, full    bucket_accuracy=73%  pairwise_accuracy=84%  loved_recall=80%  hated_rejection=80%
    Mathias, sparse  bucket_accuracy=67%  pairwise_accuracy=73%  loved_recall=75%  hated_rejection=75%
    Osnat, full      bucket_accuracy=43%  pairwise_accuracy=61%  loved_recall=100%  hated_rejection=0%

  Group removed       Base              Bucket acc.      Pairwise acc.    Loved recall     Hated reject.  
  --------------------------------------------------------------------------------------------------------
  tropes              Mathias, full     73% (+0pp)       82% (-2pp)       80% (+0pp)       80% (+0pp)     
  tropes              Mathias, sparse   67% (+0pp)       83% (+10pp)      100% (+25pp)     50% (-25pp)    
  tropes              Osnat, full       43% (+0pp)       22% (-39pp)      100% (+0pp)      0% (+0pp)      
  pace                Mathias, full     73% (+0pp)       82% (-2pp)       80% (+0pp)       80% (+0pp)     
  pace                Mathias, sparse   67% (+0pp)       70% (-3pp)       75% (+0pp)       75% (+0pp)     
  pace                Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  tone                Mathias, full     82% (+9pp)       87% (+2pp)       80% (+0pp)       100% (+20pp)   
  tone                Mathias, sparse   67% (+0pp)       80% (+7pp)       75% (+0pp)       75% (+0pp)     
  tone                Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  pov_structure       Mathias, full     64% (-9pp)       82% (-2pp)       80% (+0pp)       60% (-20pp)    
  pov_structure       Mathias, sparse   56% (-11pp)      67% (-7pp)       75% (+0pp)       50% (-25pp)    
  pov_structure       Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  stakes_drive        Mathias, full     73% (+0pp)       87% (+2pp)       80% (+0pp)       80% (+0pp)     
  stakes_drive        Mathias, sparse   67% (+0pp)       77% (+3pp)       75% (+0pp)       75% (+0pp)     
  stakes_drive        Osnat, full       43% (+0pp)       72% (+11pp)      100% (+0pp)      0% (+0pp)      
  content_intensity   Mathias, full     82% (+9pp)       80% (-4pp)       80% (+0pp)       100% (+20pp)   
  content_intensity   Mathias, sparse   67% (+0pp)       73% (+0pp)       75% (+0pp)       75% (+0pp)     
  content_intensity   Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      
  craft_density       Mathias, full     73% (+0pp)       84% (+0pp)       80% (+0pp)       80% (+0pp)     
  craft_density       Mathias, sparse   67% (+0pp)       77% (+3pp)       75% (+0pp)       75% (+0pp)     
  craft_density       Osnat, full       43% (+0pp)       67% (+6pp)       100% (+0pp)      0% (+0pp)      
  magic_scifi         Mathias, full     73% (+0pp)       89% (+4pp)       80% (+0pp)       80% (+0pp)     
  magic_scifi         Mathias, sparse   67% (+0pp)       70% (-3pp)       75% (+0pp)       75% (+0pp)     
  magic_scifi         Osnat, full       43% (+0pp)       61% (+0pp)       100% (+0pp)      0% (+0pp)      

=== Scenario 7: Poor-match threshold diagnostic ===
  Base              Threshold variant             Bucket acc.    Pairwise acc.  Loved recall   Hated reject.
  ----------------------------------------------------------------------------------------------------------
  Mathias, full     fixed 0.35 (old default)      45%            84%            80%            0%           
  Mathias, full     fixed 0.40                    45%            84%            80%            0%           
  Mathias, full     fixed 0.45                    64%            84%            80%            40%          
  Mathias, full     fixed 0.50                    73%            84%            80%            60%          
  Mathias, full     fixed 0.54                    73%            84%            80%            80%          
  Mathias, full     calibrated (0.540) -- LANDED  73%            84%            80%            80%          

  Mathias, sparse   fixed 0.35 (old default)      44%            73%            75%            0%           
  Mathias, sparse   fixed 0.40                    56%            73%            75%            25%          
  Mathias, sparse   fixed 0.45                    56%            73%            75%            25%          
  Mathias, sparse   fixed 0.50                    56%            73%            75%            50%          
  Mathias, sparse   fixed 0.54                    67%            73%            75%            75%          
  Mathias, sparse   calibrated (0.540) -- LANDED  67%            73%            75%            75%          

  Osnat, full       fixed 0.35 (old default)      43%            61%            100%           0%           
  Osnat, full       fixed 0.40                    43%            61%            100%           0%           
  Osnat, full       fixed 0.45                    43%            61%            100%           0%           
  Osnat, full       fixed 0.50                    43%            61%            100%           0%           
  Osnat, full       fixed 0.54                    43%            61%            100%           0%           
  Osnat, full       calibrated (0.385) -- LANDED  43%            61%            100%           0%           

  No-negative-signal fallback check (repo owner's caveat):
    119 all-positive ratings (no disliked/hated) -> calibrated threshold = 0.350 (falls back to default, as intended)

=== Scenario 8: dealbreaker-flag sanity check (fixed threshold, all 4 raters) ===
  Mathias: false-positive rate 0/5 (flagged on a liked/loved book) -- true-positive rate 0/5 (flagged on a disliked/hated book)
  Osnat: false-positive rate 1/3 (flagged on a liked/loved book) -- true-positive rate 0/2 (flagged on a disliked/hated book)
    Harry Potter and the Goblet of Fire true=it_was_okay  -> dragons
    Divergent                           true=liked        -> slow burn romance
    Iron Flame                          true=it_was_okay  -> dragons
  Dandan: false-positive rate 3/3 (flagged on a liked/loved book) -- true-positive rate 1/1 (flagged on a disliked/hated book)
    The Path of Daggers                 true=hated        -> court intrigue; an uneven pace
    The Way of Kings                    true=it_was_okay  -> court intrigue
    Words of Radiance                   true=loved        -> court intrigue
    Mistborn: The Final Empire          true=it_was_okay  -> heist; shapeshifters
    The Hero of Ages                    true=it_was_okay  -> shapeshifters
    Ender's Shadow                      true=loved        -> an uneven pace
    Shadows of Self                     true=loved        -> flintlock fantasy setting; court intrigue; shapeshifters; a consistent pace throughout; noir detective structure
  Gabriel (LOO): false-positive rate 4/5 (flagged on a liked/loved book) -- true-positive rate 0/1 (flagged on a disliked/hated book)
    Light Bringer                       true=it_was_okay  -> space opera; rebellion against empire; revenge; mixed narrative person; soft science fiction
    Before They Are Hanged              true=liked        -> a cliffhanger ending
    Golden Son                          true=loved        -> space opera; dystopia; rebellion against empire; major character death; underdog rising
    Morning Star                        true=liked        -> space opera; rebellion against empire; major character death; hard science-fiction rigor
    The Dragon Reborn                   true=liked        -> a hard, rules-based magic system

=== Scenario 9: dealbreaker-flag sanity check (statistically validated, all 4 raters) ===
  Mathias: false-positive rate 0/5 (flagged on a liked/loved book) -- true-positive rate 0/5 (flagged on a disliked/hated book)
  Osnat: false-positive rate 1/3 (flagged on a liked/loved book) -- true-positive rate 0/2 (flagged on a disliked/hated book)
    Harry Potter and the Goblet of Fire true=it_was_okay  -> dragons
    Divergent                           true=liked        -> slow burn romance
    Iron Flame                          true=it_was_okay  -> dragons
  Dandan: false-positive rate 3/3 (flagged on a liked/loved book) -- true-positive rate 1/1 (flagged on a disliked/hated book)
    The Path of Daggers                 true=hated        -> court intrigue; an uneven pace
    The Way of Kings                    true=it_was_okay  -> court intrigue
    Words of Radiance                   true=loved        -> court intrigue
    Mistborn: The Final Empire          true=it_was_okay  -> heist; shapeshifters
    The Hero of Ages                    true=it_was_okay  -> shapeshifters
    Ender's Shadow                      true=loved        -> an uneven pace
    Shadows of Self                     true=loved        -> flintlock fantasy setting; court intrigue; shapeshifters; a consistent pace throughout; noir detective structure
  Gabriel (LOO): false-positive rate 4/5 (flagged on a liked/loved book) -- true-positive rate 0/1 (flagged on a disliked/hated book)
    Light Bringer                       true=it_was_okay  -> space opera; rebellion against empire; revenge; mixed narrative person; soft science fiction
    Before They Are Hanged              true=liked        -> a cliffhanger ending
    Golden Son                          true=loved        -> space opera; dystopia; rebellion against empire; major character death; underdog rising
    Morning Star                        true=liked        -> space opera; rebellion against empire; major character death; hard science-fiction rigor
    The Dragon Reborn                   true=liked        -> a hard, rules-based magic system

=== Scenario 10: learning curve (accuracy vs. rating-history size) ===
  Mathias (held-out set fixed at 11 books, up to 15 random samples per size):
    Train size   Pairwise acc.    Bucket acc.    Repeats
    10           69%              36%            15
    32           69%              41%            15
    54           75%              58%            15
    76           75%              63%            15
    98           80%              68%            15
    120          81%              70%            15
    132          84%              73%            1

=== Scenario 11: diversity curve (accuracy vs. author variety, size held fixed) ===
  Mathias (fixed train size=40, 40 random samples, varying only in how many distinct authors happen to appear):
    Pearson r (distinct authors vs. pairwise accuracy): +0.085
    Pearson r (distinct authors vs. bucket accuracy):   +0.055
    Author-diversity tercile     n_authors range    Pairwise acc.    Bucket acc.
    Low                          18-23              69%              48%
    Mid                          23-25              72%              53%
    High                         25-29              72%              54%

=== Scenario 12: contrastive pairs (near-identical DNA, opposite ratings) ===
  Mathias: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    The Grey Bastards (loved, held-out score 0.6789) vs The True Bastards (hated, held-out score 0.6938)  [MISS -- model can't distinguish these]
      DNA similarity: 0.859
      Field differences: {'drive': ('plot_driven', 'character_driven')}
      Tropes only in 'The Grey Bastards': ['multiple_fantasy_species']
      Tropes only in 'The True Bastards': ['court_intrigue']

  Mathias summary: model correctly ranked 0/1 contrastive pairs.
  Osnat: 1 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    Magic Bites (liked, held-out score 0.8226) vs Magic Burns (hated, held-out score 0.8487)  [MISS -- model can't distinguish these]
      DNA similarity: 0.917
      Field differences: NONE -- fully identical on every measured field
      Tropes only in 'Magic Burns': ['found_family', 'war_story']

  Osnat summary: model correctly ranked 0/1 contrastive pairs.
  Dandan: 17 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

    A Crown of Swords (it_was_okay, held-out score 0.0354) vs The Path of Daggers (hated, held-out score 0.0245)  [OK]
      DNA similarity: 0.957
      Field differences: {'book_length': ('epic', 'long')}
      Tropes only in 'A Crown of Swords': ['found_family']

    The Shadow Rising (loved, held-out score -0.0165) vs A Crown of Swords (it_was_okay, held-out score -0.0625)  [OK]
      DNA similarity: 0.952
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional')}
      Tropes only in 'The Shadow Rising': ['coming_of_age']

    The Great Hunt (loved, held-out score 0.0445) vs The Dragon Reborn (it_was_okay, held-out score -0.0219)  [OK]
      DNA similarity: 0.927
      Field differences: {'darkness': ('moderate', 'dark'), 'pace_shape': ('consistent', 'uneven')}
      Tropes only in 'The Great Hunt': ['powerful_artifact_macguffin']

    The Fires of Heaven (disliked, held-out score -0.0547) vs Lord of Chaos (loved, held-out score -0.007)  [OK]
      DNA similarity: 0.925
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Lord of Chaos': ['found_family']

    The Shadow Rising (loved, held-out score 0.0597) vs The Path of Daggers (hated, held-out score 0.0224)  [OK]
      DNA similarity: 0.913
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'book_length': ('epic', 'long')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']

    Lord of Chaos (loved, held-out score -0.0368) vs A Crown of Swords (it_was_okay, held-out score -0.0632)  [OK]
      DNA similarity: 0.91
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['major_character_death']

    The Shadow Rising (loved, held-out score -0.0363) vs The Fires of Heaven (disliked, held-out score -0.0525)  [OK]
      DNA similarity: 0.897
      Field differences: {'emotional_register': ('tense', 'gut_punch'), 'personal_stakes': ('high', 'life_threatening')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'found_family']
      Tropes only in 'The Fires of Heaven': ['major_character_death']

    The Dragon Reborn (it_was_okay, held-out score -0.0227) vs The Shadow Rising (loved, held-out score -0.0165)  [OK]
      DNA similarity: 0.891
      Field differences: {'violence_frequency': ('occasional', 'frequent'), 'book_length': ('long', 'epic'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Shadow Rising': ['coming_of_age', 'war_story']

    The Fires of Heaven (disliked, held-out score -0.055) vs Knife of Dreams (loved, held-out score 0.0159)  [OK]
      DNA similarity: 0.889
      Field differences: {'overall_pace': ('medium', 'fast'), 'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['found_family', 'last_minute_rescue']

    The Dragon Reborn (it_was_okay, held-out score 0.0655) vs The Path of Daggers (hated, held-out score 0.0245)  [OK]
      DNA similarity: 0.887
      Field differences: {'overall_pace': ('medium', 'slow'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Dragon Reborn': ['found_family']
      Tropes only in 'The Path of Daggers': ['war_story']

    The Fires of Heaven (disliked, held-out score -0.0552) vs The Gathering Storm (loved, held-out score 0.0547)  [OK]
      DNA similarity: 0.881
      Field differences: {'violence_intensity': ('moderate', 'graphic'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['found_family', 'redemption_arc', 'shadow_self_confrontation']

    The Path of Daggers (hated, held-out score 0.0278) vs Winter's Heart (liked, held-out score 0.089)  [OK]
      DNA similarity: 0.876
      Field differences: {'overall_pace': ('slow', 'medium'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.0635) vs Knife of Dreams (loved, held-out score -0.0127)  [OK]
      DNA similarity: 0.874
      Field differences: {'overall_pace': ('slow', 'fast'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'Knife of Dreams': ['last_minute_rescue', 'major_character_death']

    Lord of Chaos (loved, held-out score 0.0072) vs The Path of Daggers (hated, held-out score 0.023)  [MISS -- model can't distinguish these]
      DNA similarity: 0.871
      Field differences: {'overall_pace': ('medium', 'slow'), 'violence_frequency': ('frequent', 'occasional'), 'violence_intensity': ('graphic', 'moderate'), 'personal_stakes': ('life_threatening', 'high'), 'book_length': ('epic', 'long'), 'pace_shape': ('slow_burn_to_fast_finish', 'uneven')}
      Tropes only in 'Lord of Chaos': ['found_family', 'major_character_death']

    The Fires of Heaven (disliked, held-out score -0.0499) vs Winter's Heart (liked, held-out score -0.0115)  [OK]
      DNA similarity: 0.855
      Field differences: {'emotional_register': ('gut_punch', 'tense'), 'violence_intensity': ('moderate', 'graphic'), 'book_length': ('epic', 'long'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish'), 'emotional_resolution': ('bittersweet', 'happy')}
      Tropes only in 'The Fires of Heaven': ['major_character_death']
      Tropes only in 'Winter's Heart': ['redemption_arc']

    A Crown of Swords (it_was_okay, held-out score -0.0636) vs The Gathering Storm (loved, held-out score 0.0253)  [OK]
      DNA similarity: 0.854
      Field differences: {'overall_pace': ('slow', 'medium'), 'emotional_register': ('tense', 'gut_punch'), 'violence_frequency': ('occasional', 'frequent'), 'violence_intensity': ('moderate', 'graphic'), 'personal_stakes': ('high', 'life_threatening'), 'pace_shape': ('uneven', 'slow_burn_to_fast_finish')}
      Tropes only in 'The Gathering Storm': ['major_character_death', 'redemption_arc', 'shadow_self_confrontation']

    The Great Hunt (loved, held-out score 0.0445) vs A Crown of Swords (it_was_okay, held-out score -0.0609)  [OK]
      DNA similarity: 0.852
      Field differences: {'overall_pace': ('medium', 'slow'), 'darkness': ('moderate', 'dark'), 'book_length': ('long', 'epic'), 'pace_shape': ('consistent', 'uneven'), 'drive': ('plot_driven', 'balanced')}
      Tropes only in 'The Great Hunt': ['powerful_artifact_macguffin']
      Tropes only in 'A Crown of Swords': ['war_story']

  Dandan summary: model correctly ranked 16/17 contrastive pairs.
  Gabriel: 0 contrastive pair(s) found (DNA similarity >= 0.85, rating gap >= 1.0)

=== Scenario 13: user-adjustable rules (none of X / less of X) ===
  parse trope key: OK
  parse valid ordinal field:value: OK
  parse valid nominal field:value: OK
  reject invalid ordinal value: OK
  reject unknown field: OK
  normalize None is empty: OK
  normalize {} is empty: OK
WARNING: unrecognized user rule key(s), ignored: ['not_a_real_field:x']
  normalize drops bad keys, keeps good ones: OK
  normalize applies default strength: OK
  normalize respects explicit strength: OK
  no rules is a guaranteed no-op: OK
  no rules is a no-op even with {}: OK
  exclude exact-matches and flags excluded: OK
  exclude leaves non-matching book untouched: OK
  reduce applies correct multiplicative discount: OK
  reduce leaves non-matching book untouched: OK
  multiple matching reduce rules stack multiplicatively: OK
  target list non-empty: OK
  target list includes a known field_value: OK
  target list includes a known trope: OK
  target list never invents unused values: OK
  sanity: baseline top-20 fantasy contains at least one YA book: OK
  exclude age_category:ya removes all YA from real recommend() output: OK
  reduce drive:romance_driven lowers its representation in top-20 (2 -> 0): OK
  All user-rules tests passed.

=== Scenario 14: confidence-floor regression checks (CODX Task 1/2 findings, 2026-09-14/15) ===
  audit_attribute_ordinal: neutral-only evidence doesn't crash: OK
  audit_attribute_ordinal: neutral rating excluded from both sides: OK
  nominal_field_separation: confidence-zeroed tags don't satisfy the sample gate: OK
  trope_separation: confidence-zeroed hits don't count as evidence either way: OK
  compute_series_dna: confidence-zeroed endpoint excluded from trajectory: OK
  experimental profile/scoring builders remain uncalled outside their own definitions: OK
  All confidence-floor regression checks passed.
```

## Complete proposed diff (`git diff -- scripts/scoring_tests.py`)

```diff
diff --git a/scripts/scoring_tests.py b/scripts/scoring_tests.py
index cfc3179..ef8e191 100644
--- a/scripts/scoring_tests.py
+++ b/scripts/scoring_tests.py
@@ -255,18 +255,22 @@ def _full_score(catalog, id_to_magnitude, validated_fields, centroid, weights, b
     Found a real regression in the author-isolated scenario, traced to
     a genuine conceptual flaw (population-level field correlation
     doesn't imply a specific candidate's simultaneous match on both is
-    redundant evidence) rather than a parameter to retune -- removed."""
+    redundant evidence) rather than a parameter to retune -- removed.
+
+    A5 (2026-09-16): delegate this same stage sequence to score_candidate()
+    with policy="evaluation"; retain the caches and bare-float contract."""
     global _SERIES_DNA_CACHE
     if _SERIES_DNA_CACHE is None:
         _SERIES_DNA_CACHE = R.compute_series_dna(catalog)
     field_prevalence, trope_prevalence = _get_prevalence_cache(catalog)
-    score, _ = R.score_book(book, centroid, weights, field_prevalence, trope_prevalence)
-    score = R._apply_series_repeat(catalog, id_to_magnitude, book, score)
-    score = R._apply_dealbreaker_veto(catalog, id_to_magnitude, validated_fields, book, centroid, weights, score,
-                                       field_prevalence, trope_prevalence)
-    score = R._apply_series_trajectory_penalty(_SERIES_DNA_CACHE, book, centroid, weights, score,
-                                                field_prevalence, trope_prevalence)
-    return score
+    result = R.score_candidate(
+        catalog, book["id"], centroid, weights, id_to_magnitude,
+        policy="evaluation", validated_fields=validated_fields,
+        series_dna=_SERIES_DNA_CACHE, field_prevalence=field_prevalence,
+        trope_prevalence=trope_prevalence,
+        poor_threshold=0.0,  # Placeholder: only affects the discarded match label.
+    )
+    return result["scores"]["final"]
 
 
 def verdict(true_label, predicted_label):
```

## Handoff and restoration

After saving this report and its complete diff, scoring_tests.py was restored to exact HEAD bytes and hash-verified. recommend.py was never edited and also matches HEAD byte-for-byte. The patch extracted from THIS report passes `git apply --check` against the restored tree. Both embedded canonical outputs were checked against the captured files. The tracked working tree and index are clean; required and pre-existing untracked reports are retained. No commit, push, or hosted write occurred.

Exact restoration command:

```sh
python3 /private/tmp/codx-task7/restore.py > /private/tmp/codx-task7/restoration.txt
```

Restoration/report-integrity script:

```python
import hashlib,re,subprocess
from pathlib import Path
work=Path('/private/tmp/codx-task7')
report=Path('docs/codx-reports/2026-09-16-a5-full-score-migration-proposal.md')
s=report.read_text();patches=re.findall(r'^```diff\n(.*?)^```$',s,re.M|re.S)
assert len(patches)==1 and patches[0].encode()==(work/'proposal.patch').read_bytes()
extracted=work/'report-extracted.patch';extracted.write_text(patches[0])
p=Path('scripts/scoring_tests.py')
assert hashlib.sha256(p.read_bytes()).hexdigest()=='4dc979831db39effd58db880172b0744c1621792434d8a7dcdc3a362c6f743b7'
base=subprocess.check_output(['git','show','HEAD:scripts/scoring_tests.py'])
assert base==(work/'original_tests.py').read_bytes()
p.write_bytes(base);assert p.read_bytes()==base
print('Restored scripts/scoring_tests.py SHA-256:',hashlib.sha256(base).hexdigest())
r=Path('scripts/recommend.py').read_bytes()
assert r==subprocess.check_output(['git','show','HEAD:scripts/recommend.py'])==(work/'original_recommend.py').read_bytes()
print('Untouched scripts/recommend.py SHA-256:',hashlib.sha256(r).hexdigest())
for cmd in [['git','diff','--exit-code'],['git','diff','--cached','--exit-code'],['git','diff','--check'],['git','apply','--check',str(extracted)],['git','status','--short']]:
    result=subprocess.run(cmd,capture_output=True,text=True)
    print('$ '+' '.join(cmd));print('exit:',result.returncode);print(result.stdout+result.stderr,end='')
    assert result.returncode==0
for name in ['before','after']:
    embedded=s.split('## Canonical suite '+name+' (complete output, exit 0)\n\n```text\n',1)[1].split('```\n',1)[0].encode()
    assert embedded==(work/(name+'.txt')).read_bytes()
print('PASS embedded patch and both suite outputs verified byte-for-byte')
print('PASS tracked working tree and index clean; untracked reports preserved')
```

Actual output (exit 0):

```text
Restored scripts/scoring_tests.py SHA-256: d34f99e8d08f2e6bdc540353b65d3f7464b8c5c9bce39089745e3d518282b23a
Untouched scripts/recommend.py SHA-256: 595ab8907f50029394bffa28b5dd1bed45915da32c52794e9dcb7aa2a8ebb861
$ git diff --exit-code
exit: 0
$ git diff --cached --exit-code
exit: 0
$ git diff --check
exit: 0
$ git apply --check /private/tmp/codx-task7/report-extracted.patch
exit: 0
$ git status --short
exit: 0
?? docs/codx-recommend-review-2026-09-14.md
?? docs/codx-reports/
PASS embedded patch and both suite outputs verified byte-for-byte
PASS tracked working tree and index clean; untracked reports preserved
```

CLDO can independently re-verify and apply this narrowly scoped migration. No unresolved behavior mismatch remains. The additional full-suite computation cost is recorded, not optimized; performance work and audit migration are separate tasks.
