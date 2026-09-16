# Task 6 — A4 explain_match migration proposal

Date: 2026-09-16. Author: CODX. Status: implemented and locally validated;
full proposed diff preserved below, source restored afterward. No commit,
push, hosted write, or production deployment.

## Baseline and scope

Synced from `d7258b4` to `4c264374bd5eb0bde30fddb75023e53211b7770d`.
Commit `0863719` is an ancestor; A3's `recommend()` migration is present.
The protocol's “A3: recommend() migrated onto score_candidate()” entry,
updated CODX TODO, and recent project log were read. The existing repository
conventions and schema/skill context remain applicable. This is execution of
the user's specified caller migration, not a new scoring-design decision.

Only `explain_match()` changes. The broader TODO shorthand mentioning
`explain_book()` does not override Task 6's explicit boundary: that helper
is a dependency of the canonical scorer and MUST NOT be routed back into it.
No change is made to `audit_book_score()`, `scoring_tests._full_score()`,
`recommend()`, `score_candidate()`, weights, scoring stages, calibration,
format/genre policy, or presentation helpers.

The source check confirms `explain_match` is the ONLY top-level function
whose AST changes, with no function/class added or removed. It also compares
all bytes before/after that function. In particular, all six named helpers
are explicitly confirmed byte-for-byte unchanged:

- `explain_book`
- `dealbreaker_flags`
- `describe_series_trajectory`
- `natural_sentence`
- `dealbreaker_sentence`
- `describe`

Their exact individual source hashes are printed by the harness below.
`score_candidate`, `recommend`, and `audit_book_score` are also checked and
named in that output. The entire `scripts/scoring_tests.py` file retains its
HEAD hash. No dependency cycle is introduced.

## Implementation and preserved contract

The missing-title lookup and its `ValueError` remain before all profile/scoring
work. A local `book_id = title_to_id[title]` is retained for the canonical call,
and `book` still refers to that same catalog row for presentation.

Profile resolution, validated fields, series DNA, prevalence, and base-only
calibration still use their unchanged helpers with identical inputs. Calibration
is prepared before the canonical call so its required threshold can be passed
in; it is not folded into any candidate stage. The canonical call uses only
`policy="explanation"`, with the specified context and explicit `top_n=top_n`.
No ranking eligibility, diversity, cold start, discovery filtering, or user
rules are added to explanations of arbitrary catalog books.

The inline base/repeat/veto/trajectory computation, direct `explain_book()` and
`dealbreaker_flags()` calls, and local series-note derivation are replaced by
the corresponding result fields. `score` receives the unrounded final float;
`matches`, `mismatches`, `flags`, and `series_note` receive the existing raw
pairs/string. The return dictionary gets `result["match_label"]` directly.
The public score remains `round(score, 3)`.

All three labeled-phrase comprehensions, `describe()` filtering, summaries,
dealbreaker sentence, returned keys/key order, list shapes, and rounding remain
unchanged. This is a change in where their raw inputs come from, not a rewrite
of the presentation layer. The final diff has 18 insertions and 18 deletions
inside the one function.

### Required compatibility detail: explicit top_n=None

A literal `top_n=top_n` migration exposed a real edge discrepancy in the new
caller: old `explain_book()` uses `rows[:top_n]`, so explicit None means
unlimited. The canonical scorer uses None as its default-limit sentinel (5
for explanation). The old public `explain_match(..., top_n=None)` therefore
accepts a valid input that would silently be truncated by a literal migration.
The direct pre-fix probe on Mathias/Warbreaker produced:

```text
top_n=None probe: Warbreaker
Original lengths: 6 1
Literal migration lengths: 5 1
Full result equality: False
```

This is corrected solely in `explain_match()`: for an explicit None, set the
local limit to `len(weights) + len(weights.get("tropes", {}))`, then pass
`top_n=top_n` explicitly as requested. Every scalar factor and present trope
can supply at most one item to each evidence list, so this is a sufficient
upper bound for an unlimited view. It does not change which factors exist,
weights, thresholds, sorting, or any helper. Non-None limits pass through
unaltered, including 1, 20, zero, and negative slicing semantics. Default
omission still uses explain_match's existing default 5.

This is a caller compatibility adapter required by the task's “every valid
input” contract, not a change to the canonical scorer's decided API. The
full-catalog matrix tests 1 and 20, while the supplementary grid tests None,
0, 5, and -1, plus the omitted default. The unlimited case is explicitly
required to exercise a result with more than five raw evidence entries.

A documentation handoff detail remains deliberately outside the AST scope:
`score_candidate()`'s existing docstring lists explain_match among its
unmigrated callers. CLDO can update that historical wording when recording A4
as landed, as it did for A3. This proposal leaves that function untouched.

## The canonical suite does NOT cover this migration

This was verified before relying on any suite result. Command:

```sh
rg -n 'explain_match' scripts/scoring_tests.py
```

Actual output:

```text
220:    same order recommend()/explain_match() apply them. Centralized here
228:    explain_match()/audit_book_score() now compute and pass by default
305:    now real production behavior (explain_match() uses the same
755:# explain_match() and, via run_held_out_test()/run_ablation_held_out()
```

These are docstrings/comments. A separate AST traversal found ZERO executable
Name/Attribute references to `explain_match`. `_full_score()` remains its
separate stage sequence; `recommend()` calls the canonical scorer, not
`explain_match()`. The before/after canonical suite is therefore only a
requested collateral check. Byte-identical output is NOT meaningful direct
regression evidence for this function and is not presented as such. The
entire behavior-preservation claim rests on the dedicated harness below.

## Direct-comparison validation approach

The original source was copied before editing and verified against exact HEAD
bytes. The harness loads original and migrated modules side-by-side and invokes
the REAL public `explain_match()` functions on both. No profile-preparation
helper, calibration function, scoring function, or context is mocked or memoized.
Each pair independently executes the full caller with the same catalog,
ratings, title, and options.

A fresh 978-row catalog snapshot was read using the existing codx_readonly role
and unchanged SELECT-only `load_catalog()`. Both sides share the same in-memory
catalog. Snapshot SHA-256:
`ee48604797cbb4f56ab22a65e3bea3aac96078b7f67fceacc13c42ec7332cee9`.
Local snapshot: `/private/tmp/codx-task6/catalog.pickle`. It happens to match
the previous task's catalog hash but was fetched anew. The direct harness
itself runs offline. It reads local repository ratings, not hosted user data.

`sys.settrace` captures the original caller's actual locals at return, its
direct stage-helper returns, the migrated caller's locals, and the actual
canonical result. Line events are disabled because return/call events supply
all required evidence. Expected stage arithmetic is not reimplemented. Float
comparison uses IEEE-754 double hex bytes (`struct.pack('!d', value).hex()`),
with no tolerance or prior rounding. Tuple/list types receive different tags,
and dict key order is retained in the comparison representation.

For EVERY successful pair the harness compares:

- the entire returned dictionary and each of its ten keys separately:
  title, score, match_label, matches, mismatches, summary, mismatch_summary,
  dealbreaker_flags, dealbreaker_summary, series_note;
- the rounded public score's exact float bits AND the original unrounded final
  score, calibrated threshold, base, repeat, veto, and trajectory stages;
- raw matches/mismatches/flags, series note, and all labeled phrase pairs;
- stdout warnings without filtering;
- one actual canonical call with policy explanation, explicit limit forwarding,
  and no exclusions.

Input ratings and the shared catalog are checked for mutation. Exceptions are
compared by class name, args, and text, and missing-title calls must perform
ZERO canonical scorer calls.

### Every physical book row × every rater × both limits

The exhaustive matrix contains 978 physical catalog rows × five rater files ×
two explicit limits (1 and 20): 9,780 paired calls. The named context choices
cover all three genre modes and all three format modes without an unnecessary
full 3×3 cross on every row:

| Rater fixture | Genre | Format | Reason |
|---|---|---|---|
| Dandan | None | None | Unscoped/default-format baseline |
| Gabriel | sci_fi | mixed | Genre scope and mixed-format input on a sparse profile |
| Mathias | fantasy | audiobook | Established fantasy/audiobook use case |
| Osnat | fantasy | None | Fantasy-scoped profile with the default format |
| Mathias Goodreads | None | None | Unscoped imported-rating fixture baseline |

These are named validation cases, not edits or assumptions about each reader's
personal preferences. All local rating values, including catalog-missing titles,
are passed unchanged to both implementations. Coverage is checked by actual
resolved book ID, separately for each rater and each limit; each set must equal
all 978 catalog IDs. It is not inferred from loop iteration count.

**Duplicate-title coverage:** the catalog contains two rows named `The One`.
The public API is title-addressed and the existing title map picks its last
occurrence. Simply looping every row's title would query the same winning row
twice and silently leave the other row untested. For the otherwise-shadowed
row, the harness creates a catalog view with only that row moved to the end,
then invokes BOTH public callers on that same view. This makes that physical
row addressable without changing its data or the production lookup contract.
Every other primary case uses the original catalog order, including the usual
duplicate winner. Both resolved IDs are asserted. Five such extra catalog
views (one per rater, each used at both limits) provide true physical-row
coverage, not a false “978 loop iterations” claim.

Explanations include already-rated and wrong-genre books, rather than limiting
the battery to recommendations. Required positive coverage checks ensure real
dealbreaker flags, an actual series-repeat score change, and an actual
trajectory-penalty score change occur. Example books and exact stage values
are printed in the final output.

### Supplementary limits, context combinations, and exceptions

A small set of actual observed interaction books plus a deterministic spread
of catalog titles is additionally crossed with all five raters, all nine
genre/format combinations, and limits 0, 5, -1, and None. This tests more context
and slice combinations while preserving exhaustive coverage in the primary
matrix. Default omission is separately tested for every rater. Edge cases
include empty ratings, negative fatigue, and invalid-rating/missing-title
warnings. The targeted eight-book Task 4 fixture is also reused with real
profile learning/validation to force veto and trajectory interactions at
limits 1, 20, and None.

Missing-title cases use a title containing quotes, a newline, and Unicode,
for each rater; an empty-catalog missing-title case is added. All six must
raise the same ValueError, with identical args/message, before any canonical
call. The existing missing-title branch itself is unchanged.

## Direct-comparison results

The final dedicated harness exited 0: 10,538 original/migrated call pairs, including 10,532 successful complete-dictionary comparisons and 6 exact ValueError comparisons. All 335,398 bit-exact equality assertions passed.

The primary coverage assertion independently confirmed all 978 physical IDs at BOTH limits for EACH of the five raters. It did not merely count title requests. Required exercised paths and additional edge coverage:

| Coverage | Observations |
|---|---:|
| already_rated_explained | 719 |
| dealbreaker_flags | 2,375 |
| repeat_changed | 180 |
| series_note | 6,786 |
| top_n_none | 188 |
| trajectory_changed | 377 |
| unlimited_more_than_five | 87 |
| veto_changed | 3 |
| wrong_genre_explained | 2,774 |

These counts span paired calls, not distinct books. The complete output below names concrete books for dealbreaker, repeat, and trajectory coverage.

The full type-preserving, float-bit-encoded output/exception digest is identical on both sides: `2b0dab1eec3486d24e22a4993ce33295d6552d142c53a929036bfe309249ed21`. The final parity log is 6,377 bytes, SHA-256 `6e938fd4bbcd456f7b259bf73ff6243b923afe4b9a6626a5566848e3d91dc6d1`.

No unresolved mismatch remains. The literal-migration None-limit mismatch was fixed in the caller before this final exhaustive run; no helper or scoring policy was changed. This proves the named current-catalog and edge-case comparisons, not every hypothetical malformed input or future data state.

## Execution commands and integrity checks

Initial sync/checks:

```sh
git status --short
git pull --ff-only
git rev-parse HEAD
git merge-base --is-ancestor 0863719 HEAD
git config core.hooksPath
```

The first sandbox pull failed with:

```text
error: cannot open '.git/FETCH_HEAD': Operation not permitted
```

The execution tool's required escalation was then used for the same
`git pull --ff-only`; it succeeded, without any auth workaround:

```text
From https://github.com/M4kuWo/bookspell
   d7258b4..4c26437  main       -> origin/main
Updating d7258b4..4c26437
Fast-forward
 docs/TODO.md                                       |   27 +-
 ...x-a3-recommend-migration-proposal-2026-09-16.md | 1856 ++++++++++++++++++++
 docs/project-log.md                                |   66 +
 docs/scoring-test-protocol.md                      |   72 +
 scripts/recommend.py                               |   53 +-
 5 files changed, 2038 insertions(+), 36 deletions(-)
 create mode 100644 docs/codx-reviews/codx-a3-recommend-migration-proposal-2026-09-16.md
```

HEAD was `4c264374bd5eb0bde30fddb75023e53211b7770d`; the ancestor check exited
0 with no output; the hooks path remained `.githooks`. Existing untracked
report paths were preserved. The source copy under `original.py` was taken
before editing. The scripts below were saved under `/private/tmp/codx-task6/`.

```sh
python3 /private/tmp/codx-task6/run.py before
# Apply the local caller migration; probe/fix the explicit-None adapter.
python3 /private/tmp/codx-task6/run.py snapshot
python3 -B /private/tmp/codx-task6/validate.py > /private/tmp/codx-task6/parity.txt 2>&1
python3 /private/tmp/codx-task6/run.py after
git diff --check
git diff -- scripts/recommend.py
```

The before/after suite and fresh snapshot read were run via explicit network
escalation, always using only the existing codx_readonly role. The launcher
reads only that named variable from `.env`; it never prints its value. It
captures complete combined stdout/stderr without normalization. Launcher output:

```text
before: exit=0 bytes=29591 sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
snapshot: exit=0 bytes=101 sha256=8c204c16493ac55694fd369dff4ff22c54c912f0971b765a03a1651621728f1b
after: exit=0 bytes=29591 sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
```

Full canonical output equality is asserted in addition to the matching hashes.
Both complete outputs are included below as requested, with the explicit
limitation above that neither executes explain_match. `git diff --check`
exited 0 without output. Source/diff integrity:

```text
original.py bytes=205634 sha256=aa9caae4a715b811395e14edecab49fdac8efbdd3fb2bd4826dae066bb75ccf0
scripts/recommend.py HEAD=aa9caae4a715b811395e14edecab49fdac8efbdd3fb2bd4826dae066bb75ccf0 working=783992303dfc3c34f30c07f84a5296e9d7b8dc8a896814e128386988f9826ab0
scripts/scoring_tests.py HEAD=d34f99e8d08f2e6bdc540353b65d3f7464b8c5c9bce39089745e3d518282b23a working=d34f99e8d08f2e6bdc540353b65d3f7464b8c5c9bce39089745e3d518282b23a
proposal.patch sha256=fd1b9a5b191d8f48be6f913d61ce7cbfa7c0d89d38dc08d799ed9afcb1ea5e79
```

For independent reproduction, use an isolated checkout at the baseline above,
create the temporary directory, and save the following scripts there. Save
`git show 4c264374bd5eb0bde30fddb75023e53211b7770d:scripts/recommend.py`
as `original.py` in that directory. Run the before suite before applying the
single proposed diff. Fetch/reuse the snapshot, run the dedicated harness, and
run the after suite. The targeted interaction fixture is extracted from the
committed Task 4 report. A newer catalog can produce different coverage counts,
but both sides of an independent comparison must use identical input data.

## Final direct-comparison output (complete, exit 0)

```text
UNCHANGED explain_book sha256=4aec947a35df2d58148c4a11e3b2e850d97e23f5b88cb628b9b29bd9e16b6b7f
UNCHANGED dealbreaker_flags sha256=5c9a06dadc68f5ef7bd54cc728b656f2dcfa0ec169aa34b6cab7463a461ea838
UNCHANGED describe_series_trajectory sha256=6f7b35b7b56ef99d01f5758a8d16d016cbe72f813257079875b1c1bdf35a9832
UNCHANGED natural_sentence sha256=3ccf1b5f6c15abd49f0afc2963e54d9fea812b2b26a7574fa1abe44c2fb1b1bd
UNCHANGED dealbreaker_sentence sha256=928da0036308450304ccb6449749fe6694fe91b3ff85e4e6800eee68176ecfc2
UNCHANGED describe sha256=ac270a5bc6d1457711699019d5f59cfd7951cced19e6073d87f8164754e6d341
UNCHANGED score_candidate sha256=97192dc4fce1533481c25518d9d1d811985f2427a5ad62508daa3a4fc04436c4
UNCHANGED recommend sha256=7dc9d77bb2097ed286be01cd067b2a87651ffa26c865c03f4b8264a818f33a0e
UNCHANGED audit_book_score sha256=0a1b83aae006915babb589d920e10e1efdb6a325847fd14ae5c7e393b6013697
PASS scope: explain_match is the ONLY changed top-level function; every byte outside it unchanged
PASS canonical-suite AST references to explain_match: 0; canonical suite is NOT regression coverage for this path
Catalog books: 978 sha256: ee48604797cbb4f56ab22a65e3bea3aac96078b7f67fceacc13c42ec7332cee9
PROGRESS dandan books=100/978 elapsed_seconds=14.56
PROGRESS dandan books=200/978 elapsed_seconds=28.51
PROGRESS dandan books=300/978 elapsed_seconds=42.47
PROGRESS dandan books=400/978 elapsed_seconds=56.48
PROGRESS dandan books=500/978 elapsed_seconds=70.48
PROGRESS dandan books=600/978 elapsed_seconds=84.5
PROGRESS dandan books=700/978 elapsed_seconds=98.44
PROGRESS dandan books=800/978 elapsed_seconds=112.57
PROGRESS dandan books=900/978 elapsed_seconds=126.55
PROGRESS dandan books=978/978 elapsed_seconds=137.42
PASS full catalog dandan genre=None format=None rows_per_top_n=978
PROGRESS gabriel books=100/978 elapsed_seconds=148.09
PROGRESS gabriel books=200/978 elapsed_seconds=159.0
PROGRESS gabriel books=300/978 elapsed_seconds=169.75
PROGRESS gabriel books=400/978 elapsed_seconds=180.46
PROGRESS gabriel books=500/978 elapsed_seconds=191.18
PROGRESS gabriel books=600/978 elapsed_seconds=201.9
PROGRESS gabriel books=700/978 elapsed_seconds=212.56
PROGRESS gabriel books=800/978 elapsed_seconds=223.47
PROGRESS gabriel books=900/978 elapsed_seconds=234.25
PROGRESS gabriel books=978/978 elapsed_seconds=242.59
PASS full catalog gabriel genre=sci_fi format=mixed rows_per_top_n=978
PROGRESS mathias books=100/978 elapsed_seconds=269.18
PROGRESS mathias books=200/978 elapsed_seconds=296.34
PROGRESS mathias books=300/978 elapsed_seconds=323.08
PROGRESS mathias books=400/978 elapsed_seconds=349.6
PROGRESS mathias books=500/978 elapsed_seconds=376.85
PROGRESS mathias books=600/978 elapsed_seconds=403.79
PROGRESS mathias books=700/978 elapsed_seconds=432.08
PROGRESS mathias books=800/978 elapsed_seconds=460.12
PROGRESS mathias books=900/978 elapsed_seconds=488.22
PROGRESS mathias books=978/978 elapsed_seconds=510.07
PASS full catalog mathias genre=fantasy format=audiobook rows_per_top_n=978
PROGRESS osnat books=100/978 elapsed_seconds=524.25
PROGRESS osnat books=200/978 elapsed_seconds=538.45
PROGRESS osnat books=300/978 elapsed_seconds=552.6
PROGRESS osnat books=400/978 elapsed_seconds=566.73
PROGRESS osnat books=500/978 elapsed_seconds=581.12
PROGRESS osnat books=600/978 elapsed_seconds=595.34
PROGRESS osnat books=700/978 elapsed_seconds=609.53
PROGRESS osnat books=800/978 elapsed_seconds=623.7
PROGRESS osnat books=900/978 elapsed_seconds=637.86
PROGRESS osnat books=978/978 elapsed_seconds=648.95
PASS full catalog osnat genre=fantasy format=None rows_per_top_n=978
PROGRESS mathias_goodreads books=100/978 elapsed_seconds=670.0
PROGRESS mathias_goodreads books=200/978 elapsed_seconds=690.86
PROGRESS mathias_goodreads books=300/978 elapsed_seconds=711.82
PROGRESS mathias_goodreads books=400/978 elapsed_seconds=732.69
PROGRESS mathias_goodreads books=500/978 elapsed_seconds=753.58
PROGRESS mathias_goodreads books=600/978 elapsed_seconds=774.76
PROGRESS mathias_goodreads books=700/978 elapsed_seconds=796.33
PROGRESS mathias_goodreads books=800/978 elapsed_seconds=817.75
PROGRESS mathias_goodreads books=900/978 elapsed_seconds=838.91
PROGRESS mathias_goodreads books=978/978 elapsed_seconds=855.2
PASS full catalog mathias_goodreads genre=None format=None rows_per_top_n=978
PASS supplementary context/limit grid: 4 titles; None/0/5/-1 plus default omission and missing titles
PASS physical-row coverage by rater and limit: {"dandan": {"1": 978, "20": 978}, "gabriel": {"1": 978, "20": 978}, "mathias": {"1": 978, "20": 978}, "mathias_goodreads": {"1": 978, "20": 978}, "osnat": {"1": 978, "20": 978}}
PASS coverage: {"already_rated_explained": 719, "dealbreaker_flags": 2375, "repeat_changed": 180, "series_note": 6786, "top_n_none": 188, "trajectory_changed": 377, "unlimited_more_than_five": 87, "veto_changed": 3, "wrong_genre_explained": 2774}
PASS examples: {"dealbreaker_flags": {"case": "full/dandan/genre=None/format=None/row=d67034b9-1305-4a6a-89d4-d56b504fc44c/top_n=1", "flags": ["chosen one", "epic quest", "prophecy"], "title": "The Golden Compass"}, "repeat_changed": {"after": 0.2763067390677516, "before": 0.27091038833923553, "book_id": "f2250e75-ee7f-4ba7-ac02-8a7663133ad9", "case": "full/dandan/genre=None/format=None/row=f2250e75-ee7f-4ba7-ac02-8a7663133ad9/top_n=1", "title": "Shadows of Self"}, "trajectory_changed": {"after": 0.08255151422382667, "before": 0.11793073460546669, "book_id": "d67034b9-1305-4a6a-89d4-d56b504fc44c", "case": "full/dandan/genre=None/format=None/row=d67034b9-1305-4a6a-89d4-d56b504fc44c/top_n=1", "title": "The Golden Compass"}, "veto_changed": {"after": 0.549, "before": 0.8421052631578947, "book_id": "candidate-1", "case": "interaction/candidate-1/1", "title": "candidate-1"}}
PASS counts: {"duplicate_row_views": 5, "paired_calls": 10538, "successful_pairs": 10532, "value_error_pairs": 6, "warning_pairs": 2102}
PASS bit-exact assertions: 335398
PASS original complete output digest: 2b0dab1eec3486d24e22a4993ce33295d6552d142c53a929036bfe309249ed21
PASS migrated complete output digest: 2b0dab1eec3486d24e22a4993ce33295d6552d142c53a929036bfe309249ed21
Total elapsed seconds: 919.7264982080087
PASS final: all catalog rows for all five raters at both top_n values; all returned keys and types, rounded and unrounded scores, raw evidence, stages, exceptions, warnings, and untouched helpers
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
command = 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 scripts/scoring_tests.py' if mode in ('before', 'after') else 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 /private/tmp/codx-task6/snapshot.py'
p = subprocess.run(['zsh', '-f', '-c', command], env=e, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
if parts[0].encode() in p.stdout: raise SystemExit('Credential appeared in output; not saved')
path = Path('/private/tmp/codx-task6') / (mode + '.txt')
path.write_bytes(p.stdout)
print(f'{mode}: exit={p.returncode} bytes={len(p.stdout)} sha256={hashlib.sha256(p.stdout).hexdigest()}')
if p.returncode: print(p.stdout.decode())
sys.exit(p.returncode)
```

## Snapshot script

```python
import sys,pickle,hashlib
from pathlib import Path
sys.path.insert(0,str(Path.cwd()/'scripts'))
import recommend as R
catalog=R.load_catalog()
data=pickle.dumps(catalog)
Path('/private/tmp/codx-task6/catalog.pickle').write_bytes(data)
print('Catalog books:',len(catalog),'snapshot sha256:',hashlib.sha256(data).hexdigest())
```

## Complete direct-comparison harness

```python
import ast,contextlib,copy,hashlib,importlib.util,io,itertools,json,pickle,struct,sys,time
from collections import Counter
from pathlib import Path
ROOT=Path.cwd();WORK=Path('/private/tmp/codx-task6')
sys.path.insert(0,str(ROOT/'scripts'))
import recommend as N
spec=importlib.util.spec_from_file_location('task6_original',WORK/'original.py')
O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
old_source=(WORK/'original.py').read_text();new_source=Path('scripts/recommend.py').read_text()
a={n.name:n for n in ast.parse(old_source).body if isinstance(n,(ast.FunctionDef,ast.ClassDef))}
b={n.name:n for n in ast.parse(new_source).body if isinstance(n,(ast.FunctionDef,ast.ClassDef))}
assert a.keys()==b.keys()
assert {k for k in a if ast.dump(a[k])!=ast.dump(b[k])}=={'explain_match'}
old_lines=old_source.splitlines(keepends=True);new_lines=new_source.splitlines(keepends=True)
assert old_lines[:a['explain_match'].lineno-1]==new_lines[:b['explain_match'].lineno-1]
assert old_lines[a['explain_match'].end_lineno:]==new_lines[b['explain_match'].end_lineno:]
for name in ['explain_book','dealbreaker_flags','describe_series_trajectory','natural_sentence','dealbreaker_sentence','describe',
             'score_candidate','recommend','audit_book_score']:
    old=''.join(old_lines[a[name].lineno-1:a[name].end_lineno]).encode()
    new=''.join(new_lines[b[name].lineno-1:b[name].end_lineno]).encode()
    assert old==new
    print('UNCHANGED',name,'sha256='+hashlib.sha256(old).hexdigest(),flush=True)
print('PASS scope: explain_match is the ONLY changed top-level function; every byte outside it unchanged',flush=True)
test_source=Path('scripts/scoring_tests.py').read_text()
refs=[n for n in ast.walk(ast.parse(test_source)) if (isinstance(n,ast.Name) and n.id=='explain_match') or (isinstance(n,ast.Attribute) and n.attr=='explain_match')]
assert not refs
print('PASS canonical-suite AST references to explain_match: 0; canonical suite is NOT regression coverage for this path',flush=True)

stats=Counter();checks=0;coverage=Counter();examples={};old_digest=hashlib.sha256();new_digest=hashlib.sha256()
keys=['title','score','match_label','matches','mismatches','summary','mismatch_summary','dealbreaker_flags','dealbreaker_summary','series_note']

def encode(x):
    if isinstance(x,float):return ['float64',struct.pack('!d',x).hex()]
    if isinstance(x,tuple):return ['tuple',[encode(v) for v in x]]
    if isinstance(x,list):return ['list',[encode(v) for v in x]]
    if isinstance(x,dict):return ['dict',[(k,encode(v)) for k,v in x.items()]]
    return x

def packed(x):return json.dumps(encode(x),ensure_ascii=False,separators=(',',':')).encode()
def eq(x,y,label):
    global checks
    assert packed(x)==packed(y),(label,x,y)
    checks+=1

# Disable line events. Capture actual original caller locals at return and its
# direct scoring-helper returns; capture the real canonical result on migration.
# No function, context helper, or scoring math is mocked or memoized.
helper_stages={'score_book':'base','_apply_series_repeat':'after_series_repeat',
               '_apply_dealbreaker_veto':'after_veto','_apply_series_trajectory_penalty':'after_trajectory'}

def observe(module,cat,ratings,title,options):
    fn=module.explain_match;state={};stages={};calls=Counter();output=io.StringIO()
    def trace(frame,event,arg):
        code=frame.f_code
        if code is fn.__code__:
            frame.f_trace_lines=False
            if event=='return':state['locals']=frame.f_locals.copy()
            return trace
        if module is N and code is N.score_candidate.__code__:
            frame.f_trace_lines=False
            if event=='call':
                calls['candidate']+=1
                assert frame.f_locals['policy']=='explanation'
                state['candidate_top_n']=frame.f_locals['top_n']
            if event=='return':state['result']=arg
            return trace
        parent=frame.f_back
        if parent and parent.f_code is fn.__code__ and code.co_name in helper_stages:
            frame.f_trace_lines=False
            if event=='return':stages[helper_stages[code.co_name]]=arg[0] if code.co_name=='score_book' else arg
            return trace
        return None
    sys.settrace(trace)
    try:
        with contextlib.redirect_stdout(output):value=fn(cat,ratings,title,**options)
        error=None
    except Exception as exc:
        value=None;error=(type(exc).__name__,exc.args,str(exc))
    finally:sys.settrace(None)
    return value,error,output.getvalue(),state,stages,calls

def pair(case,cat,ratings,title,options,expected_id=None):
    original,error_old,warn_old,lo,stages,_=observe(O,cat,ratings,title,options)
    migrated,error_new,warn_new,ln,_,calls=observe(N,cat,ratings,title,options)
    eq(error_new,error_old,(case,'exception'));eq(warn_new,warn_old,(case,'stdout'))
    eq(migrated,original,(case,'entire returned dictionary'))
    old_digest.update(case.encode()+b'\0'+packed(original)+packed(error_old));new_digest.update(case.encode()+b'\0'+packed(migrated)+packed(error_new))
    stats['paired_calls']+=1
    if warn_old:stats['warning_pairs']+=1
    if error_old:
        assert error_old[0]=='ValueError' and calls['candidate']==0,(case,error_old,calls)
        stats['value_error_pairs']+=1
        return None
    assert list(original)==keys and list(migrated)==keys
    for key in keys:eq(migrated[key],original[key],(case,'returned key',key))
    assert calls['candidate']==1,(case,calls)
    oldloc,newloc=lo['locals'],ln['locals'];result=ln['result']
    if expected_id is not None:
        eq(oldloc['book']['id'],expected_id,(case,'original resolved book'))
        eq(newloc['book']['id'],expected_id,(case,'migrated resolved book'))
    eq(newloc['score'],oldloc['score'],(case,'unrounded final score'))
    eq(newloc['poor_threshold'],oldloc['poor_threshold'],(case,'calibration'))
    for name in ['matches','mismatches','flags','series_note','matches_labeled','mismatches_labeled','flags_labeled']:
        eq(newloc[name],oldloc[name],(case,'original local',name))
    for name,value in stages.items():eq(result['scores'][name],value,(case,'original stage',name))
    eq(result['scores']['final'],oldloc['score'],(case,'canonical final'))
    eq(migrated['score'],round(oldloc['score'],3),(case,'rounded public score'))
    eq(result['exclusions'],[],(case,'explanation never filters'))
    requested=options.get('top_n',5)
    if requested is not None:eq(ln['candidate_top_n'],requested,(case,'explicit top_n forwarding'))
    else:
        assert ln['candidate_top_n']==len(oldloc['weights'])+len(oldloc['weights'].get('tropes',{}))
        coverage['top_n_none']+=1
        if len(oldloc['matches'])>5 or len(oldloc['mismatches'])>5:coverage['unlimited_more_than_five']+=1
    for first,last,name in [('base','after_series_repeat','repeat_changed'),('after_series_repeat','after_veto','veto_changed'),
                            ('after_veto','after_trajectory','trajectory_changed')]:
        if stages[first]!=stages[last]:
            coverage[name]+=1
            examples.setdefault(name,dict(case=case,title=title,book_id=oldloc['book']['id'],before=stages[first],after=stages[last]))
    if original['dealbreaker_flags']:
        coverage['dealbreaker_flags']+=1;examples.setdefault('dealbreaker_flags',dict(case=case,title=title,flags=original['dealbreaker_flags']))
    if original['series_note']:coverage['series_note']+=1
    if oldloc['book']['id'] in oldloc['id_to_magnitude']:coverage['already_rated_explained']+=1
    if options.get('genre') and options['genre'] not in (oldloc['book'].get('genre') or []):coverage['wrong_genre_explained']+=1
    stats['successful_pairs']+=1
    return oldloc['book']['id']

snapshot=(WORK/'catalog.pickle').read_bytes();catalog=pickle.loads(snapshot);catalog_before=pickle.dumps(catalog)
print('Catalog books:',len(catalog),'sha256:',hashlib.sha256(snapshot).hexdigest(),flush=True)
title_to_id={book['title']:bid for bid,book in catalog.items()}
raters={p.stem:json.loads(p.read_text())['ratings'] for p in sorted(Path('data/ratings').glob('*.json'))}
# Named test variants, not edits or guesses about a reader's personal settings.
# Cover all 3 genres and all 3 format modes without an unnecessary 3x3 cross
# on EVERY book. Every rater still covers every physical row at BOTH limits.
profiles=[('dandan',None,None),('gabriel','sci_fi','mixed'),('mathias','fantasy','audiobook'),
          ('osnat','fantasy',None),('mathias_goodreads',None,None)]
start=time.perf_counter();row_coverage={}
for rater,genre,fmt in profiles:
    seen={1:set(),20:set()};ratings=raters[rater];input_before=pickle.dumps(ratings)
    for i,(bid,book) in enumerate(catalog.items(),1):
        cat=catalog
        if title_to_id[book['title']]!=bid:
            # API is title-addressed and last duplicate wins. Exercise the
            # otherwise-shadowed physical row by moving only it to the end.
            cat={k:v for k,v in catalog.items() if k!=bid};cat[bid]=book
            stats['duplicate_row_views']+=1
        for top_n in [1,20]:
            case=f'full/{rater}/genre={genre}/format={fmt}/row={bid}/top_n={top_n}'
            resolved=pair(case,cat,ratings,book['title'],dict(genre=genre,format_preference=fmt,top_n=top_n),bid)
            assert resolved is not None;seen[top_n].add(resolved)
        if i%100==0 or i==len(catalog):print('PROGRESS',rater,'books='+str(i)+'/'+str(len(catalog)),'elapsed_seconds='+str(round(time.perf_counter()-start,2)),flush=True)
    assert seen[1]==seen[20]==set(catalog)
    assert pickle.dumps(ratings)==input_before
    row_coverage[rater]={str(n):len(ids) for n,ids in seen.items()}
    print('PASS full catalog',rater,'genre='+str(genre),'format='+str(fmt),'rows_per_top_n='+str(len(catalog)),flush=True)

# Supplementary small cross checks more context combinations and slice modes.
# Include observed interaction books and a deterministic catalog spread.
titles=list(dict.fromkeys([x['title'] for x in examples.values() if 'title' in x]+[b['title'] for b in list(catalog.values())[::max(1,len(catalog)//3)]]))
for rater,ratings in raters.items():
    for genre,fmt in itertools.product([None,'fantasy','sci_fi'],[None,'audiobook','mixed']):
        for title in titles:
            for top_n in [0,5,-1,None]:
                pair(f'extra/{rater}/{genre}/{fmt}/{title}/{top_n}',catalog,ratings,title,dict(genre=genre,format_preference=fmt,top_n=top_n))
    # Default omitted, plus explicit negative fatigue and cold profile below.
    pair('omitted/'+rater,catalog,ratings,'Warbreaker',{})
    pair('missing/'+rater,catalog,ratings,"Missing 'book'\n☃",dict(top_n=20))
print('PASS supplementary context/limit grid:',len(titles),'titles; None/0/5/-1 plus default omission and missing titles',flush=True)
for name,ratings,options in [('empty',{},{}),('fatigue',raters['mathias'],dict(fatigue_overrides={'person':-.6,'quest':-1.0})),
                             ('invalid-rating',{'missing':'loved','Warbreaker':'invalid'},dict(top_n=20))]:
    pair('edge/'+name,catalog,ratings,'Warbreaker',options)
pair('missing/empty-catalog',{}, {},'No book',{})

# Reuse the genuine profile-learning fixture to force actual veto + trajectory.
report=Path('docs/codx-reviews/codx-a2-canonical-scorer-proposal-2026-09-16.md').read_text()
fixture_source=report.split('fixture={};ratings={}\n',1)[1].split('ctx=context(fixture,ratings)',1)[0]
fixture={};ratings={};exec(fixture_source)
for bid,book in fixture.items():
    for top_n in [1,20,None]:pair(f'interaction/{bid}/{top_n}',fixture,ratings,book['title'],dict(top_n=top_n),bid)

assert pickle.dumps(catalog)==catalog_before
for key in ['dealbreaker_flags','trajectory_changed','repeat_changed','veto_changed','series_note','already_rated_explained','wrong_genre_explained','top_n_none','unlimited_more_than_five']:
    assert coverage[key]>0,(key,coverage)
assert stats['value_error_pairs']==6
assert old_digest.hexdigest()==new_digest.hexdigest()
print('PASS physical-row coverage by rater and limit:',json.dumps(row_coverage,sort_keys=True))
print('PASS coverage:',json.dumps(dict(coverage),sort_keys=True))
print('PASS examples:',json.dumps(examples,sort_keys=True,ensure_ascii=False,default=str))
print('PASS counts:',json.dumps(dict(stats),sort_keys=True))
print('PASS bit-exact assertions:',checks)
print('PASS original complete output digest:',old_digest.hexdigest())
print('PASS migrated complete output digest:',new_digest.hexdigest())
print('Total elapsed seconds:',time.perf_counter()-start)
print('PASS final: all catalog rows for all five raters at both top_n values; all returned keys and types, rounded and unrounded scores, raw evidence, stages, exceptions, warnings, and untouched helpers')
```

## Canonical suite before (complete output, exit 0; does not cover explain_match)

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

## Canonical suite after (complete output, exit 0; does not cover explain_match)

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

## Complete proposed diff (`git diff -- scripts/recommend.py`)

```diff
diff --git a/scripts/recommend.py b/scripts/recommend.py
index 20cb6f3..4150c76 100644
--- a/scripts/recommend.py
+++ b/scripts/recommend.py
@@ -3524,39 +3524,39 @@ def explain_match(catalog, ratings, title, genre=None, fatigue_overrides=None, t
     title_to_id = {b["title"]: bid for bid, b in catalog.items()}
     if title not in title_to_id:
         raise ValueError(f"{title!r} not found in catalog")
-    book = catalog[title_to_id[title]]
+    book_id = title_to_id[title]
+    book = catalog[book_id]
 
     centroid, weights, id_to_magnitude, _ = _resolve_profile(catalog, ratings, genre, fatigue_overrides, format_preference)
     validated = validated_dealbreaker_fields(catalog, id_to_magnitude)
     series_dna = compute_series_dna(catalog)
     field_prevalence, trope_prevalence = build_prevalence_lookup(catalog, genre)
-    score, _ = score_book(book, centroid, weights, field_prevalence, trope_prevalence)
-    score = _apply_series_repeat(catalog, id_to_magnitude, book, score)
-    score = _apply_dealbreaker_veto(catalog, id_to_magnitude, validated, book, centroid, weights, score,
-                                     field_prevalence, trope_prevalence)
-    score = _apply_series_trajectory_penalty(series_dna, book, centroid, weights, score,
-                                              field_prevalence, trope_prevalence)
     poor_threshold = user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights,
                                                      field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)
-    matches, mismatches = explain_book(book, centroid, weights, top_n=top_n,
-                                        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)
-    flags = dealbreaker_flags(book, centroid, weights, validated_fields=validated,
-                               field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)
+    if top_n is None:
+        # explain_book() treats [:None] as unlimited; score_candidate() uses
+        # None for its default limit. Each scalar/trope supplies at most one
+        # row per evidence list, so this bound preserves the unlimited view.
+        top_n = len(weights) + len(weights.get("tropes", {}))
+    result = score_candidate(
+        catalog, book_id, centroid, weights, id_to_magnitude,
+        policy="explanation", validated_fields=validated, series_dna=series_dna,
+        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence,
+        poor_threshold=poor_threshold, top_n=top_n
+    )
+    score = result["scores"]["final"]
+    matches, mismatches = result["matches"], result["mismatches"]
+    flags = result["dealbreaker_flags"]
+    series_note = result["series_note"]
 
     matches_labeled = [(label, p) for label, _ in matches if (p := describe(label, book))]
     mismatches_labeled = [(label, p) for label, _ in mismatches if (p := describe(label, book))]
     flags_labeled = [(label, p) for label, _ in flags if (p := describe(label, book))]
 
-    series_note = ""
-    if book.get("series_id"):
-        series_entry = series_dna.get(book["series_id"])
-        if series_entry:
-            series_note = describe_series_trajectory(series_entry)
-
     return {
         "title": title,
         "score": round(score, 3),
-        "match_label": match_label(score, poor_threshold),
+        "match_label": result["match_label"],
         "matches": [p for _, p in matches_labeled],
         "mismatches": [p for _, p in mismatches_labeled],
         "summary": natural_sentence(matches_labeled, positive=True),
```

## Handoff and restoration

The source was restored to exact HEAD bytes only after saving the full report and patch. The patch extracted from THIS report passes `git apply --check` on the restored tree. Both embedded canonical outputs were checked against the captured files byte-for-byte. The tracked working tree and index are clean; existing and required untracked reports are retained. No commit, push, hosted write, or deployment occurred.

Exact restoration command:

```sh
python3 /private/tmp/codx-task6/restore.py > /private/tmp/codx-task6/restoration.txt
```

Restoration/report-integrity script:

```python
import hashlib, re, subprocess
from pathlib import Path
report=Path('docs/codx-reports/2026-09-16-a4-explain-match-migration-proposal.md')
text=report.read_text()
patches=re.findall(r'^```diff\n(.*?)^```$',text,re.M|re.S)
assert len(patches)==1
patch=patches[0].encode()
assert patch==Path('/private/tmp/codx-task6/proposal.patch').read_bytes()
extracted=Path('/private/tmp/codx-task6/report-extracted.patch')
extracted.write_bytes(patch)
p=Path('scripts/recommend.py')
assert hashlib.sha256(p.read_bytes()).hexdigest()=='783992303dfc3c34f30c07f84a5296e9d7b8dc8a896814e128386988f9826ab0'
base=subprocess.check_output(['git','show','HEAD:scripts/recommend.py'])
assert base==Path('/private/tmp/codx-task6/original.py').read_bytes()
p.write_bytes(base)
assert p.read_bytes()==base
print('Restored scripts/recommend.py SHA-256:',hashlib.sha256(base).hexdigest())
for cmd in [ ['git','diff','--exit-code'], ['git','diff','--cached','--exit-code'],
             ['git','diff','--check'], ['git','apply','--check',str(extracted)], ['git','status','--short'] ]:
    result=subprocess.run(cmd,capture_output=True,text=True)
    print('$ '+' '.join(cmd));print('exit:',result.returncode)
    print(result.stdout+result.stderr,end='')
    assert result.returncode==0
# Verify the embedded suite outputs are still exactly the captured bytes.
for heading,name in [('Canonical suite before (complete output, exit 0; does not cover explain_match)','before.txt'),('Canonical suite after (complete output, exit 0; does not cover explain_match)','after.txt')]:
    section=text.split('## '+heading+'\n\n```text\n',1)[1].split('```\n',1)[0].encode()
    assert section==Path('/private/tmp/codx-task6',name).read_bytes()
print('PASS: embedded patch and both embedded suite outputs verified byte-for-byte')
print('PASS: tracked working tree and index clean; existing untracked reports preserved')
```

Actual output (exit 0):

```text
Restored scripts/recommend.py SHA-256: aa9caae4a715b811395e14edecab49fdac8efbdd3fb2bd4826dae066bb75ccf0
$ git diff --exit-code
exit: 0
$ git diff --cached --exit-code
exit: 0
$ git diff --check
exit: 0
$ git apply --check /private/tmp/codx-task6/report-extracted.patch
exit: 0
$ git status --short
exit: 0
?? docs/codx-recommend-review-2026-09-14.md
?? docs/codx-reports/
PASS: embedded patch and both embedded suite outputs verified byte-for-byte
PASS: tracked working tree and index clean; existing untracked reports preserved
```

CLDO can independently re-verify and apply this caller-only proposal. The report preserves the complete diff, harness, full outputs, None-limit compatibility finding, helper hashes, and restoration evidence. No unresolved mismatch remains. Audit migration and the evaluation _full_score migration remain separate tasks.
