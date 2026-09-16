# Task 4 — A2 canonical scorer proposal

Date: 2026-09-16. Author: CODX. Status: implemented and locally validated, then reverted; the complete proposed patch is preserved below for CLDO to independently verify and apply. No commit, push, or hosted write.

## Baseline and scope

`git pull --ff-only` fast-forwarded this clone from f93dbde to
00f72c7143629f5c0b2c56177db311ed2f4e9815. `git merge-base --is-ancestor
21389e3 HEAD` exited 0. The production `_iter_book_factors()` prerequisite
is present. `core.hooksPath` remains `.githooks`.

The implementation follows Task 2 Proposal 3 and its section 3 call-site
inventory. The A2 prerequisite protocol entry and updated CODX TODO were
re-read, along with the repository conventions, recent project history,
schema context, and available skill inventory. The catalog-tagging and
schema-migration skills do not implement this engine task. The TODO's
shorthand “next A3” does not replace the user's explicit Task 4 scope:
finish the additive canonical orchestrator before migrating any caller.

Only one function, `score_candidate()`, is added to `scripts/recommend.py`.
Every pre-existing byte outside that insertion is unchanged; the harness
checks this, as well as AST equality for every existing function/class.
`recommend()`, `explain_match()`, `audit_book_score()`, and the complete
`scripts/scoring_tests.py` remain unchanged. No existing code calls the new
function. No file movement, scoring design, new weight, threshold change,
calibration change, aggregate confidence score, or caller migration is proposed.

## Result and context contract

`score_candidate(catalog, book_id, centroid, weights, id_to_magnitude, *,
policy, validated_fields, series_dna, field_prevalence, trope_prevalence,
poor_threshold, cold_start=None, matches_genre=None, discovery_only=False,
recent_books=(), diversity=0.0, normalized_rules=None, top_n=None)` returns
an explicit dictionary, consistent with existing explanation/audit APIs.

The caller owns context preparation. All required inputs must describe the
same catalog/profile. `_resolve_profile()` remains responsible for ratings,
genre, format, and fatigue. Validation, series DNA, prevalence, and cold-start
weight are calculated by their existing helpers outside the candidate loop.
The threshold is a REQUIRED argument, computed separately by the unchanged,
base-only `user_calibrated_poor_threshold()`. The orchestrator neither calls
that function nor uses the evaluation module's caches. Evaluation tests set
those caches explicitly to the same catalog/context before calling the old
`_full_score()`; they do not let a prior profile supply accidental state.

The returned fields are:

- `book_id`, `title`, `author`, `policy`, and `stage_sequence`.
- `scores`: unrounded `base`, `after_series_repeat`, `after_veto`,
  `after_trajectory`, `after_diversity`, `after_cold_start`, and `final`.
- `poor_threshold` and `match_label`, evaluated from the selected policy's
  final score (except pre-scoring exclusions).
- `factors`: the existing evaluator's ordered five-element tuples
  `(label, similarity, raw_weight, effective_weight, is_trope)`.
- `contributions`: exactly `score_book()`'s existing rounded, sorted,
  top-five contribution display. Base scoring calls `score_book()` directly;
  it does not reimplement the evaluator's math or weighted accumulation.
- `matches`, `mismatches`, and `dealbreaker_flags`: unrounded existing
  `(label, magnitude)` pairs. Existing phrase formatting and audit attribution
  remain separate presentation views. Default explanation depth is 5,
  audit depth 100; an explicit `top_n` changes evidence depth, not flag depth.
- `exclusions`, `excluded_by_user_rule`, and `series_note`.

| Policy | Stages after base | Candidate eligibility | Notes |
|---|---|---|---|
| `ranking` | repeat → veto → trajectory → diversity → cold start → rules | Same ordered early exits as recommend | Sorting/truncation remains outside the scorer |
| `explanation` | repeat → veto → trajectory | None | Same score/evidence as explain_match; supports rated/ineligible books |
| `evaluation` | repeat → veto → trajectory | None | Same float as _full_score with explicit matching context |
| `audit` | repeat → veto → trajectory → cold start → rules | None | Rule-excluded books retain auditable scores |

Ranking requires the `matches_genre` predicate from `_resolve_profile()`.
Ranking and audit require an explicit cold-start weight, including zero.
Unknown policies and missing required context raise `ValueError`; they do
not silently select a different pipeline. Recent titles and raw rules are
resolved/normalized once by the caller. Non-ranking policies ignore diversity,
recent history, and discovery inputs. Explanation/evaluation also ignore
cold start and rules, even when supplied: this was tested deliberately.

Optional skipped stages carry their incoming value through unchanged in the
`scores` map; `stage_sequence` explicitly distinguishes a skipped stage from
an enabled stage whose arithmetic happened to be a no-op. Ranking's early
eligibility exits return the FIRST exclusion in the existing order:
`already_rated`, `genre`, `discovery_only`, or `series_position`. All scores
and the label are `None`, and evidence is empty, because recommend did not
score that candidate either. User-rule exclusions happen last, retain the
computed score, return `user_rule`, and use audit's existing “Excluded by
user rule” label. They do not run later reductions after an exclusion.

Ranking currently returns no match label. The new, unused ranking label is
explicitly based on its final ranked score and the supplied calibrated
threshold, as the decided result contract requires. This does not change
the API's current label behavior; that remains A3/A4 work. The series note
uses `describe_series_trajectory()` exactly as `explain_match()` does.
A documentation detail verified in source: audit's docstring lists
`series_note`, but its current returned dictionary omits it. The new result
supplies the existing explanation view without editing or claiming to fix audit.

The helper retains the exact operation order of the originals, including
veto before trajectory, diversity before cold start, and rules last. All
score stages call existing production helpers. The two blend expressions
are transcribed in their original arithmetic order. Evidence calls
`_iter_book_factors()`, `explain_book()`, and `dealbreaker_flags()` directly;
there is no dependency from those lower-level helpers back to the new scorer.
The scorer intentionally does more evidence work than today's ranking loop;
this task validates behavior, not a latency claim or performance optimization.

## Validation approach and results

The original source was saved before editing, then verified byte-for-byte
against HEAD. It is imported as a separate module beside the proposal.
`sys.settrace` observes direct original stage-helper returns and original
caller locals. Ranking's diversity, cold-start, and final values are captured
at the next original executable line; explanation/audit/evaluation locals
are captured before their frames return. Expected stage scores are not
reimplemented in the harness. Floats are compared by `struct.pack('!d', value)`
hex bytes, including signed zero; comparisons are recursive for complete
results. There is no tolerance and no rounding before stage comparison.

The live catalog was loaded once using only `codx_readonly` through the
unchanged SELECT-only `load_catalog()` path, then reused in memory by both
modules. The local snapshot has 978 books; its SHA-256 is
`ee48604797cbb4f56ab22a65e3bea3aac96078b7f67fceacc13c42ec7332cee9`.
Snapshot file: `/private/tmp/codx-task4/catalog.pickle`. It contains catalog
data only, not credentials or hosted user tables. The final parity run reads
this snapshot and requires no network/database connection. Re-running against
a newer live catalog is useful validation but need not produce the same
catalog hash or coverage counts.

The battery includes all four real rater files plus the separate
`mathias_goodreads.json` fixture. Each is tested with genres None/fantasy/
sci_fi and explicit format cases None/audiobook/mixed (45 combinations).
These format cases are named validation variants, not guesses or edits to
any rater's actual metadata. Three additional profiles cover empty history,
one rating, and negative fatigue with explicit print format: 48 total.
Every catalog candidate is compared in every ranking configuration, including
all early exclusions. Entire stable-sorted recommendation lists and top-10
lists, including contribution displays, are compared, not just aggregate metrics.

The final harness removes catalog-missing rating titles from each local
fixture before passing IDENTICAL ratings to both implementations. This avoids
reprinting Osnat's long missing-title warning in every repeated detail call;
fixture totals and missing counts are printed. It does not change resolved
profiles, and the earlier unfiltered run also passed its score comparisons.
Canonical suite output is never filtered or normalized.

Detail candidates include actual observed repeat/trajectory changes, a
deterministic spread of the catalog, and excluded books. For each, explanation
is checked at `top_n` 0/1/5/100, including the entire rendered result, summaries,
flags, series note, and label. Audit raw intermediates/evidence/flags are
checked against locals; its complete display result is reconstructed using
the existing captured `build_rows` attribution closure, then compared. That
checks compatibility without proposing a second audit-attribution implementation.
Evaluation scores are compared to the unchanged `_full_score()` with its
module reference explicitly directed to the original module and restored after
use; `T.R is N` is asserted at initialization. No canonical-suite monkeypatching
is used. Catalog and prepared context are checked for mutation.

The exact 378-case Task 3 battery is reused from its committed report:
18 named boundaries and 360 combinatorial cases, each through all four new
policies and the corresponding original callers. These cover missing scalar/
centroid/trope evidence, confidence below/at/above 0.3, partial nominal credit,
both redundancy triggers, prevalence discount/floor, zero evidence, negative
fatigue, ties, signed zero, and strict display boundaries. A small test adapter
supplies identical prepared boundary profiles/prevalence/cold-start weight to
original callers; it does not replace score math or modifier functions.

A targeted eight-book synthetic catalog adds three independently liked and
three disliked training books, plus two series installments with a divergent
trajectory. Its profile, validated dealbreakers, calibration, prevalence,
series DNA, and cold-start weight come from the REAL preparation helpers,
without mocks. Its first candidate has base score above the veto cap and is
then actually capped, trajectory-discounted, diversified, cold-start-blended,
and reduced or excluded by rules. Explanation/evaluation skip the ranking-only
stages; audit skips diversity. Exact numerical output is recorded below.
This covers noncommuting stage interactions, stacked reductions, and exclusion
before reduction. Missing-context/invalid-policy errors are also exercised.

The canonical suite passed before and after (exit 0 each), including the
format-aware scenario and permanent confidence-floor regressions. Both complete
outputs are 29,591 bytes with SHA-256:

`8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea`

Full byte equality is asserted as well as hash equality. stdout and stderr
are captured together without filtering. Both full outputs are embedded below.
This is behavioral validation on the named boundaries and current catalog,
not proof for arbitrary malformed input or a performance benchmark.

## Validation iterations (not hidden)

The first sandbox attempts to run the suite and load the parity catalog failed
with database-host DNS resolution errors (`psycopg2.OperationalError: could not
translate host name ... nodename nor servname provided, or not known`). They
were retried with the tool's required network escalation, still using only the
same codx_readonly role. No credential/CLI-access workaround was used.

The first full parity pass passed its score comparisons but FAILED its coverage
gate: none of its selected live profiles actually changed score at the veto
stage. That was a test-coverage gap, not evidence to change a scoring policy.
The failure was explicitly `AssertionError: ('veto_changed', Counter(...))`.
The targeted independently learned synthetic profile above closes that gap.
An initial rule fixture also used `trope:quest`, which the real parser warned
about and ignored; it was corrected to the accepted bare key `quest` before
the final run. Missing-title warnings were reduced through the explicit input
filter described above. An intermediate interaction fixture exercised the
unknown-accessibility fallback; the final fixture uses the valid `gateway`
value to exercise a known cold-start blend. The final harness also adds complete
audit-dictionary projection checks and references the committed Task 3 report
so CLDO can reproduce it in another checkout. None of these iterations changed
the proposed scorer: its initial implementation passed all score comparisons.
The final authoritative harness and output below include all corrections.

The verbose initial coverage-failure output remains available at
`/private/tmp/codx-task4/first-coverage-failure.txt` (1,248,159 bytes,
SHA-256 `466fc20d13804f568ef8d4c17f2f3a0f3fc003af75f88bf9016cafe3029562b4`).
It consists mainly of repeated missing-title warnings. The intermediate
successful output is `/private/tmp/codx-task4/validate.txt`; the final,
expanded authoritative output is `/private/tmp/codx-task4/final-parity.txt`.

## Exact execution and reproduction commands

Initial sync:

```sh
git status --short
git pull --ff-only
git rev-parse HEAD
git merge-base --is-ancestor 21389e3 HEAD
git config core.hooksPath
```

Actual pull result:

```text
From https://github.com/M4kuWo/bookspell
   f93dbde..00f72c7  main       -> origin/main
Updating f93dbde..00f72c7
Fast-forward
 AGENTS.md                                          |   39 +-
 docs/TODO.md                                       |   28 +-
 ...codx-a2-factor-evaluator-proposal-2026-09-16.md | 1367 ++++++++++++++++++++
 docs/project-log.md                                |  191 +++
 docs/scoring-test-protocol.md                      |   54 +
 scripts/recommend.py                               |  146 +--
 6 files changed, 1739 insertions(+), 86 deletions(-)
 create mode 100644 docs/codx-reviews/codx-a2-factor-evaluator-proposal-2026-09-16.md
00f72c7143629f5c0b2c56177db311ed2f4e9815
.githooks
```

The ancestor check exited 0 without output. Two untracked report locations
existed before work: `docs/codx-recommend-review-2026-09-14.md` and
`docs/codx-reports/`. Those are preserved; “clean” below means no tracked
working-tree or index change, not deleting required or pre-existing reports.

The launcher below was saved to `/private/tmp/codx-task4/run.py`. Commands:

```sh
python3 /private/tmp/codx-task4/run.py before
# Insert the proposed function locally, with no production caller edits.
python3 /private/tmp/codx-task4/run.py validate
python3 /private/tmp/codx-task4/run.py after
# After extending the parity harness, reuse its local catalog snapshot:
python3 -B /private/tmp/codx-task4/validate.py > /private/tmp/codx-task4/final-parity.txt 2>&1
git diff --check
git diff -- scripts/recommend.py > /private/tmp/codx-task4/proposal.patch
```

The successful before/after launcher summaries were:

```text
before: exit=0 bytes=29591 sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
after: exit=0 bytes=29591 sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
```

`git diff --check` exited 0 with no output. The only tracked diff was
144 inserted lines in `scripts/recommend.py`. The canonical suite file's
HEAD and working hashes were both
`d34f99e8d08f2e6bdc540353b65d3f7464b8c5c9bce39089745e3d518282b23a`.
The original recommendation source hash was
`6590c9208f7f910688c4f03c78ab1590a12c5a8b61e87310eeffd40e9ac1e835`;
the proposed source hash was
`38fd015912a6e89f99130d6309104ccc65bbefd6f9bad073dc11456e8c752cf6`.

For independent reproduction, use an isolated checkout at the baseline above;
save the following launcher and harness under the indicated temporary paths.
Save `git show 00f72c7143629f5c0b2c56177db311ed2f4e9815:scripts/recommend.py`
as `/private/tmp/codx-task4/original.py`. Run the before suite before applying
the single diff below, then the after suite. On a fresh machine without the
catalog snapshot, run the parity harness through the read-only launcher once
to load it; subsequent runs can use the offline command. The committed Task 3
report supplies the exact boundary fixture definitions. Existing production
callers must remain unchanged throughout the comparison.

## Final parity result

Final command exit status: 0. Captured output: 8009 bytes, SHA-256 `480bf0c328496b78a512d2492e28bbb70be72ddfec72b209b0160b40e2088567`. All 308,658 bit-exact assertions passed; the counts below include explicit non-noop veto, repeat, trajectory, diversity, cold-start, and rule effects.

```text
PASS: exactly one additive function; every original byte outside insertion unchanged
Catalog books: 978 snapshot sha256: ee48604797cbb4f56ab22a65e3bea3aac96078b7f67fceacc13c42ec7332cee9
Fixture dandan ratings= 32 catalog-missing= 0
Fixture gabriel ratings= 7 catalog-missing= 0
Fixture mathias ratings= 143 catalog-missing= 0
Fixture mathias_goodreads ratings= 82 catalog-missing= 0
Fixture osnat ratings= 153 catalog-missing= 122
PASS profile dandan genre=None format=None ranked=516 detail_candidates=8
PASS profile dandan genre=None format=audiobook ranked=535 detail_candidates=9
PASS profile dandan genre=None format=mixed ranked=464 detail_candidates=9
PASS profile dandan genre=fantasy format=None ranked=325 detail_candidates=9
PASS profile dandan genre=fantasy format=audiobook ranked=325 detail_candidates=9
PASS profile dandan genre=fantasy format=mixed ranked=262 detail_candidates=8
PASS profile dandan genre=sci_fi format=None ranked=235 detail_candidates=8
PASS profile dandan genre=sci_fi format=audiobook ranked=235 detail_candidates=8
PASS profile dandan genre=sci_fi format=mixed ranked=212 detail_candidates=8
PASS profile gabriel genre=None format=None ranked=536 detail_candidates=9
PASS profile gabriel genre=None format=audiobook ranked=525 detail_candidates=8
PASS profile gabriel genre=None format=mixed ranked=464 detail_candidates=9
PASS profile gabriel genre=fantasy format=None ranked=326 detail_candidates=9
PASS profile gabriel genre=fantasy format=audiobook ranked=326 detail_candidates=9
PASS profile gabriel genre=fantasy format=mixed ranked=277 detail_candidates=9
PASS profile gabriel genre=sci_fi format=None ranked=234 detail_candidates=8
PASS profile gabriel genre=sci_fi format=audiobook ranked=235 detail_candidates=9
PASS profile gabriel genre=sci_fi format=mixed ranked=211 detail_candidates=9
PASS profile mathias genre=None format=None ranked=494 detail_candidates=9
PASS profile mathias genre=None format=audiobook ranked=494 detail_candidates=9
PASS profile mathias genre=None format=mixed ranked=348 detail_candidates=8
PASS profile mathias genre=fantasy format=None ranked=292 detail_candidates=9
PASS profile mathias genre=fantasy format=audiobook ranked=292 detail_candidates=9
PASS profile mathias genre=fantasy format=mixed ranked=243 detail_candidates=9
PASS profile mathias genre=sci_fi format=None ranked=224 detail_candidates=9
PASS profile mathias genre=sci_fi format=audiobook ranked=192 detail_candidates=8
PASS profile mathias genre=sci_fi format=mixed ranked=202 detail_candidates=9
PASS profile mathias_goodreads genre=None format=None ranked=512 detail_candidates=10
PASS profile mathias_goodreads genre=None format=audiobook ranked=512 detail_candidates=10
PASS profile mathias_goodreads genre=None format=mixed ranked=441 detail_candidates=10
PASS profile mathias_goodreads genre=fantasy format=None ranked=269 detail_candidates=9
PASS profile mathias_goodreads genre=fantasy format=audiobook ranked=308 detail_candidates=10
PASS profile mathias_goodreads genre=fantasy format=mixed ranked=258 detail_candidates=10
PASS profile mathias_goodreads genre=sci_fi format=None ranked=228 detail_candidates=8
PASS profile mathias_goodreads genre=sci_fi format=audiobook ranked=228 detail_candidates=8
PASS profile mathias_goodreads genre=sci_fi format=mixed ranked=183 detail_candidates=8
PASS profile osnat genre=None format=None ranked=525 detail_candidates=9
PASS profile osnat genre=None format=audiobook ranked=525 detail_candidates=9
PASS profile osnat genre=None format=mixed ranked=454 detail_candidates=9
PASS profile osnat genre=fantasy format=None ranked=316 detail_candidates=9
PASS profile osnat genre=fantasy format=audiobook ranked=309 detail_candidates=9
PASS profile osnat genre=fantasy format=mixed ranked=267 detail_candidates=9
PASS profile osnat genre=sci_fi format=None ranked=232 detail_candidates=8
PASS profile osnat genre=sci_fi format=audiobook ranked=232 detail_candidates=8
PASS profile osnat genre=sci_fi format=mixed ranked=209 detail_candidates=8
PASS profile cold-empty genre=None format=None ranked=536 detail_candidates=8
PASS profile cold-one genre=None format=None ranked=536 detail_candidates=8
PASS profile fatigue genre=fantasy format=print ranked=276 detail_candidates=9
PASS interaction ranking rules=None stages={'base': 0.8421052631578947, 'after_series_repeat': 0.8421052631578947, 'after_veto': 0.549, 'after_trajectory': 0.38430000000000003, 'after_diversity': 0.47410666666666673, 'after_cold_start': 0.7370533333333333, 'final': 0.7370533333333333}
PASS interaction explanation rules=None stages={'base': 0.8421052631578947, 'after_series_repeat': 0.8421052631578947, 'after_veto': 0.549, 'after_trajectory': 0.38430000000000003, 'after_diversity': 0.38430000000000003, 'after_cold_start': 0.38430000000000003, 'final': 0.38430000000000003}
PASS interaction audit rules=None stages={'base': 0.8421052631578947, 'after_series_repeat': 0.8421052631578947, 'after_veto': 0.549, 'after_trajectory': 0.38430000000000003, 'after_diversity': 0.38430000000000003, 'after_cold_start': 0.69215, 'final': 0.69215}
PASS interaction ranking rules={'reduce': [{'key': 'person:first', 'strength': 0.2}, {'key': 'overall_pace:fast', 'strength': 0.3}]} stages={'base': 0.8421052631578947, 'after_series_repeat': 0.8421052631578947, 'after_veto': 0.549, 'after_trajectory': 0.38430000000000003, 'after_diversity': 0.47410666666666673, 'after_cold_start': 0.7370533333333333, 'final': 0.41274986666666663}
PASS interaction explanation rules={'reduce': [{'key': 'person:first', 'strength': 0.2}, {'key': 'overall_pace:fast', 'strength': 0.3}]} stages={'base': 0.8421052631578947, 'after_series_repeat': 0.8421052631578947, 'after_veto': 0.549, 'after_trajectory': 0.38430000000000003, 'after_diversity': 0.38430000000000003, 'after_cold_start': 0.38430000000000003, 'final': 0.38430000000000003}
PASS interaction audit rules={'reduce': [{'key': 'person:first', 'strength': 0.2}, {'key': 'overall_pace:fast', 'strength': 0.3}]} stages={'base': 0.8421052631578947, 'after_series_repeat': 0.8421052631578947, 'after_veto': 0.549, 'after_trajectory': 0.38430000000000003, 'after_diversity': 0.38430000000000003, 'after_cold_start': 0.69215, 'final': 0.38760400000000006}
PASS interaction ranking rules={'exclude': ['person:first'], 'reduce': [{'key': 'overall_pace:fast', 'strength': 1.0}]} stages={'base': 0.8421052631578947, 'after_series_repeat': 0.8421052631578947, 'after_veto': 0.549, 'after_trajectory': 0.38430000000000003, 'after_diversity': 0.47410666666666673, 'after_cold_start': 0.7370533333333333, 'final': 0.7370533333333333}
PASS interaction explanation rules={'exclude': ['person:first'], 'reduce': [{'key': 'overall_pace:fast', 'strength': 1.0}]} stages={'base': 0.8421052631578947, 'after_series_repeat': 0.8421052631578947, 'after_veto': 0.549, 'after_trajectory': 0.38430000000000003, 'after_diversity': 0.38430000000000003, 'after_cold_start': 0.38430000000000003, 'final': 0.38430000000000003}
PASS interaction audit rules={'exclude': ['person:first'], 'reduce': [{'key': 'overall_pace:fast', 'strength': 1.0}]} stages={'base': 0.8421052631578947, 'after_series_repeat': 0.8421052631578947, 'after_veto': 0.549, 'after_trajectory': 0.38430000000000003, 'after_diversity': 0.38430000000000003, 'after_cold_start': 0.69215, 'final': 0.69215}
PASS invalid policy and missing prepared context rejected
PASS Task 3 battery: 378 cases x four policies; named cases: 18
PASS coverage: {"cold_start_changed": 5205, "diversity_changed": 9036, "excluded_already_rated": 2688, "excluded_discovery_only": 485, "excluded_genre": 13553, "excluded_series_position": 13085, "excluded_user_rule": 753, "explanation_audit_evaluation_candidates": 420, "flags": 4059, "ranking_candidates": 46944, "repeat_changed": 201, "rules_changed": 1096, "trajectory_changed": 1678, "veto_changed": 12}
PASS bit-exact assertions: 308658
PASS all original functions untouched, no input catalog mutation, no production caller migration
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
command = 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 scripts/scoring_tests.py' if mode in ('before', 'after') else 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 /private/tmp/codx-task4/validate.py'
p = subprocess.run(['zsh', '-f', '-c', command], env=e, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
if parts[0].encode() in p.stdout: raise SystemExit('Credential appeared in output; not saved')
path = Path('/private/tmp/codx-task4') / (mode + '.txt')
path.write_bytes(p.stdout)
print(f'{mode}: exit={p.returncode} bytes={len(p.stdout)} sha256={hashlib.sha256(p.stdout).hexdigest()}')
if p.returncode: print(p.stdout.decode())
sys.exit(p.returncode)
```

## Complete final parity harness

```python
import ast, copy, hashlib, importlib.util, itertools, json, math, pickle, struct, sys
from collections import Counter
from pathlib import Path
ROOT = Path.cwd()
sys.path.insert(0, str(ROOT / 'scripts'))
import recommend as N
import scoring_tests as T
assert T.R is N
spec = importlib.util.spec_from_file_location('original_recommend', '/private/tmp/codx-task4/original.py')
O = importlib.util.module_from_spec(spec); spec.loader.exec_module(O)
original = Path('/private/tmp/codx-task4/original.py').read_text()
proposed = Path('scripts/recommend.py').read_text()
oldtree, newtree = ast.parse(original), ast.parse(proposed)
oldnodes = {n.name: ast.dump(n) for n in oldtree.body if isinstance(n, (ast.FunctionDef, ast.ClassDef))}
newnodes = {n.name: ast.dump(n) for n in newtree.body if isinstance(n, (ast.FunctionDef, ast.ClassDef))}
assert newnodes.keys() - oldnodes.keys() == {'score_candidate'}
assert all(newnodes[k] == v for k,v in oldnodes.items())
addition = proposed[proposed.index('def score_candidate('):proposed.index('def recommend(')]
assert proposed.replace(addition, '', 1) == original
print('PASS: exactly one additive function; every original byte outside insertion unchanged')

def bits(x):
    if isinstance(x, float): return ('float64', struct.pack('!d', x).hex())
    if isinstance(x, dict): return {k: bits(v) for k,v in x.items()}
    if isinstance(x, (list, tuple)): return tuple(bits(v) for v in x)
    if isinstance(x, set): return frozenset(bits(v) for v in x)
    return x
checks = 0
coverage = Counter()
def eq(a,b,where):
    global checks
    assert bits(a) == bits(b), (where, a, b)
    checks += 1

# Observe original helper returns AND caller locals; no expected-stage arithmetic.
helper_stages = {'score_book':'base', '_apply_series_repeat':'after_series_repeat',
                 '_apply_dealbreaker_veto':'after_veto', '_apply_series_trajectory_penalty':'after_trajectory'}
lines = original.splitlines()

def observe(fn, *args, **kwargs):
    stages, snapshots, skipped = {}, {}, {}
    def trace(frame, event, arg):
        if frame.f_code is fn.__code__:
            v = frame.f_locals
            if event == 'line' and fn is O.recommend:
                bid = v.get('bid')
                line = lines[frame.f_lineno-1].strip()
                if line == 'continue':
                    prev = lines[frame.f_lineno-2].strip()
                    if 'bid in excluded' in prev:
                        skipped[bid] = 'already_rated' if bid in v['excluded'] else 'genre'
                    elif 'series_position_ready' in prev: skipped[bid] = 'series_position'
                    elif 'excluded_by_rule' in prev: skipped[bid] = 'user_rule'
                    else: skipped[bid] = 'discovery_only'
                if line == 'if csw > 0:':
                    stages.setdefault(bid,{})['after_diversity'] = v['relevance']
                if line.startswith('final, excluded_by_rule ='):
                    stages.setdefault(bid,{})['after_cold_start'] = v['final']
                if line == 'if excluded_by_rule:':
                    stages.setdefault(bid,{})['final'] = v['final']
            if event == 'return': snapshots.update(v.copy())
            return trace
        parent = frame.f_back
        if parent and parent.f_code is fn.__code__ and frame.f_code.co_name in helper_stages:
            if event == 'return':
                bid = frame.f_locals['book']['id']
                stage = helper_stages[frame.f_code.co_name]
                stages.setdefault(bid,{})[stage] = arg[0] if stage == 'base' else arg
                if stage == 'base': stages[bid]['contributions'] = arg[1]
            return trace
        return None
    sys.settrace(trace)
    try: out = fn(*args, **kwargs)
    finally: sys.settrace(None)
    return out, stages, snapshots, skipped

def context(catalog, ratings, genre=None, fmt=None, fatigue=None):
    c,w,ids,mg = O._resolve_profile(catalog, ratings, genre, fatigue, fmt)
    fp,tp = O.build_prevalence_lookup(catalog, genre)
    return dict(centroid=c, weights=w, id_to_magnitude=ids,
                validated_fields=O.validated_dealbreaker_fields(catalog,ids),
                series_dna=O.compute_series_dna(catalog), field_prevalence=fp, trope_prevalence=tp,
                poor_threshold=O.user_calibrated_poor_threshold(catalog,ids,c,w,field_prevalence=fp,trope_prevalence=tp),
                cold_start=O.cold_start_weight(catalog,ids), matches_genre=mg)

def compare_stages(result, expected, where):
    for key,value in expected.items():
        eq(result['contributions'] if key == 'contributions' else result['scores'][key], value, (where,key))
    for a,b,name in [('base','after_series_repeat','repeat_changed'), ('after_series_repeat','after_veto','veto_changed'),
                     ('after_veto','after_trajectory','trajectory_changed'), ('after_trajectory','after_diversity','diversity_changed'),
                     ('after_diversity','after_cold_start','cold_start_changed'), ('after_cold_start','final','rules_changed')]:
        if result['scores'][a] != result['scores'][b]: coverage[name] += 1

def compare_evidence(result, book, ctx, top_n):
    c,w=ctx['centroid'],ctx['weights']; fp,tp=ctx['field_prevalence'],ctx['trope_prevalence']
    eq(result['factors'], list(O._iter_book_factors(book,c,w,fp,tp)), 'factors')
    eq((result['matches'],result['mismatches']), O.explain_book(book,c,w,top_n,fp,tp), 'evidence')
    eq(result['dealbreaker_flags'], O.dealbreaker_flags(book,c,w,validated_fields=ctx['validated_fields'],field_prevalence=fp,trope_prevalence=tp), 'flags')
    if result['dealbreaker_flags']: coverage['flags'] += 1

snapshot = Path('/private/tmp/codx-task4/catalog.pickle')
if snapshot.exists(): catalog = pickle.loads(snapshot.read_bytes())
else:
    catalog = O.load_catalog()
    snapshot.write_bytes(pickle.dumps(catalog))
print('Catalog books:', len(catalog), 'snapshot sha256:', hashlib.sha256(snapshot.read_bytes()).hexdigest(), flush=True)
initial_catalog = pickle.dumps(catalog)
raters = [(p.stem,json.loads(p.read_text())) for p in sorted(Path('data/ratings').glob('*.json'))]
titles = {b['title'] for b in catalog.values()}
for name,data in raters:
    missing = set(data['ratings']) - titles
    print('Fixture', name, 'ratings=', len(data['ratings']), 'catalog-missing=',len(missing))
    data['ratings'] = {t:r for t,r in data['ratings'].items() if t in titles}
configs=[]
for name,data in raters:
    for genre,fmt in itertools.product([None,'fantasy','sci_fi'],[None,'audiobook','mixed']):
        configs.append((name, data['ratings'], genre, fmt, None))
configs += [('cold-empty',{},None,None,None), ('cold-one',{next(iter(catalog.values()))['title']:'liked'},None,None,None),
            ('fatigue',raters[0][1]['ratings'],'fantasy','print',{'person':-0.6,'quest':-1.0})]
for index,(name,ratings,genre,fmt,fatigue) in enumerate(configs):
    ctx = context(catalog,ratings,genre,fmt,fatigue)
    input_snapshot = pickle.dumps({k:v for k,v in ctx.items() if k != 'matches_genre'})
    diversity = [0.0,0.17,1.0,-0.2][index%4]
    history = [b['title'] for b in list(catalog.values())[:3]] + ['not a catalog title']
    rules = [None, {'reduce':[{'key':'age_category:ya','strength':0.37},{'key':'drive:romance_driven'}]},
             {'exclude':['age_category:ya'], 'reduce':[{'key':'quest','strength':0.2}]}][index%3]
    discovery = index%5 == 0
    out,stages,locals_,skips = observe(O.recommend,catalog,ratings,top_n=len(catalog),genre=genre,
             recent_history=history,diversity=diversity,fatigue_overrides=fatigue,discovery_only=discovery,user_rules=rules,format_preference=fmt)
    for key,oldkey in [('centroid','centroid'),('weights','weights'),('id_to_magnitude','id_to_magnitude'),
                       ('validated_fields','validated_fields'),('series_dna','series_dna'),('cold_start','csw'),
                       ('field_prevalence','field_prevalence'),('trope_prevalence','trope_prevalence')]:
        eq(ctx[key],locals_[oldkey],('prepared context',key))
    reconstructed=[]; picked=set(); result_by_id={}
    for bid,book in catalog.items():
        result=N.score_candidate(catalog,bid,policy='ranking',**ctx,diversity=diversity,
            recent_books=locals_['recent_books'],normalized_rules=locals_['normalized_rules'],discovery_only=discovery)
        result_by_id[bid]=result
        eq(result['exclusions'], [skips[bid]] if bid in skips else [], 'ranking exclusions')
        if bid not in stages:
            eq(list(result['scores'].values()),[None]*7,'pre-score exclusion')
            assert not result['factors'] and result['match_label'] is None
            coverage['excluded_'+skips[bid]]+=1
            continue
        compare_stages(result,stages[bid],(name,genre,fmt,bid))
        compare_evidence(result,book,ctx,5)
        if not result['exclusions']:
            reconstructed.append((result['scores']['final'],book['title'],book['author'],result['contributions']))
        else: coverage['excluded_user_rule']+=1
        # Pick actual non-noop interactions as well as a deterministic spread.
        for a,b in [('base','after_series_repeat'),('after_series_repeat','after_veto'),('after_veto','after_trajectory')]:
            if result['scores'][a] != result['scores'][b] and not any(x[0]==b for x in picked): picked.add((b,bid))
    reconstructed.sort(key=lambda x:-x[0])
    eq(reconstructed,out,'complete ordered ranking')
    eq(reconstructed[:10],O.recommend(catalog,ratings,top_n=10,genre=genre,recent_history=history,diversity=diversity,
        fatigue_overrides=fatigue,discovery_only=discovery,user_rules=rules,format_preference=fmt),'top 10')
    candidates=list(dict.fromkeys([bid for _,bid in sorted(picked)]+list(catalog)[::max(1,len(catalog)//6)]+list(skips)[:2]))
    T._SERIES_DNA_CACHE=ctx['series_dna']; T._PREVALENCE_CACHE=(ctx['field_prevalence'],ctx['trope_prevalence'])
    for bid in candidates:
        book=catalog[bid]; title=book['title']
        for top_n in [0,1,5,100]:
            out,stage,loc,_=observe(O.explain_match,catalog,ratings,title,genre=genre,fatigue_overrides=fatigue,top_n=top_n,format_preference=fmt)
            res=N.score_candidate(catalog,bid,policy='explanation',**ctx,top_n=top_n,
                diversity=diversity,recent_books=locals_['recent_books'],normalized_rules=locals_['normalized_rules'],discovery_only=True)
            compare_stages(res,stage[bid], 'explanation stages')
            eq(res['scores']['final'],loc['score'],'explanation original local')
            eq(res['poor_threshold'],loc['poor_threshold'],'calibration threshold')
            eq(res['matches'],loc['matches'],'explanation matches locals'); eq(res['mismatches'],loc['mismatches'],'explanation mismatch locals')
            eq(res['dealbreaker_flags'],loc['flags'],'explanation flags locals')
            labeled=[[ (f,p) for f,_ in res[k] if (p:=O.describe(f,book)) ] for k in ['matches','mismatches','dealbreaker_flags']]
            rendered=dict(title=title,score=round(res['scores']['final'],3),match_label=res['match_label'],
                matches=[p for _,p in labeled[0]],mismatches=[p for _,p in labeled[1]],dealbreaker_flags=[p for _,p in labeled[2]],
                summary=O.natural_sentence(labeled[0],True),mismatch_summary=O.natural_sentence(labeled[1],False),
                dealbreaker_summary=O.dealbreaker_sentence(labeled[2]),series_note=res['series_note'])
            eq(rendered,out,'complete explanation result')
        out,stage,loc,_=observe(O.audit_book_score,catalog,ratings,title,genre=genre,fatigue_overrides=fatigue,user_rules=rules,format_preference=fmt)
        res=N.score_candidate(catalog,bid,policy='audit',**ctx,normalized_rules=locals_['normalized_rules'],diversity=1.0,recent_books=locals_['recent_books'],discovery_only=True)
        compare_stages(res,stage[bid],'audit stages')
        for key,oldkey in [('base','raw_score'),('after_series_repeat','after_series'),('after_veto','after_veto'),
                           ('after_trajectory','after_trajectory'),('after_cold_start','after_cold_start'),('final','final')]:
            eq(res['scores'][key],loc[oldkey],('audit original local',key))
        eq(res['matches'],loc['matches'],'audit raw matches');eq(res['mismatches'],loc['mismatches'],'audit raw mismatches')
        eq(res['dealbreaker_flags'],loc['dealbreaker'],'audit raw flags')
        eq(res['match_label'],out['match_label'],'audit label');eq(res['excluded_by_user_rule'],out['excluded_by_user_rule'],'audit exclusion')
        eq(round(res['scores']['final'],4),out['final_score'],'audit final display')
        # Existing build_rows closure provides independent attribution formatting.
        eq(loc['build_rows'](res['matches']),out['matches'],'complete audit match rows')
        eq(loc['build_rows'](res['mismatches'],negate=True),out['mismatches'],'complete audit mismatch rows')
        stage_keys=['base','after_series_repeat','after_veto','after_trajectory','after_cold_start','final']
        pipeline=[]
        for i,(key,oldrow) in enumerate(zip(stage_keys,out['pipeline'])):
            score=res['scores'][key]
            row=dict(stage=oldrow['stage'],score=round(score,4),changed=None if i==0 else abs(score-res['scores'][stage_keys[i-1]])>1e-9)
            if key=='after_cold_start':row['cold_start_weight']=round(ctx['cold_start'],3)
            if key=='final':row.update(changed=row['changed'] or res['excluded_by_user_rule'],excluded=res['excluded_by_user_rule'])
            pipeline.append(row)
        sim=O.series_repeat_worst_similarity(catalog,ctx['id_to_magnitude'],book)
        projected=dict(title=title,author=book['author'],final_score=round(res['scores']['final'],4),match_label=res['match_label'],
            excluded_by_user_rule=res['excluded_by_user_rule'],pipeline=pipeline,
            matches=loc['build_rows'](res['matches']),mismatches=loc['build_rows'](res['mismatches'],negate=True),
            dealbreaker_flags=[(f,round(m,3)) for f,m in res['dealbreaker_flags']],validated_fields=sorted(ctx['validated_fields']),
            series_repeat_worst_similarity=round(sim,3) if sim is not None else None)
        eq(projected,out,'complete audit result')
        oldR=T.R;T.R=O
        try: out,stage,loc,_=observe(T._full_score,catalog,ctx['id_to_magnitude'],ctx['validated_fields'],ctx['centroid'],ctx['weights'],book)
        finally:T.R=oldR
        res=N.score_candidate(catalog,bid,policy='evaluation',**ctx,normalized_rules=locals_['normalized_rules'],diversity=1.0,recent_books=locals_['recent_books'])
        compare_stages(res,stage[bid],'evaluation stages');eq(res['scores']['final'],out,'evaluation full score');eq(res['scores']['final'],loc['score'],'evaluation local')
        compare_evidence(res,book,ctx,5)
        coverage['explanation_audit_evaluation_candidates']+=1
    eq(pickle.dumps({k:v for k,v in ctx.items() if k != 'matches_genre'}), input_snapshot, 'context inputs unmodified')
    coverage['ranking_candidates']+=len(catalog)
    print('PASS profile',name,'genre='+str(genre),'format='+str(fmt),'ranked='+str(len(reconstructed)),'detail_candidates='+str(len(candidates)),flush=True)
eq(pickle.dumps(catalog),initial_catalog,'catalog unmodified')

# Genuine profile learning/validation (no helper mocks): force a veto above cap,
# then a trajectory reduction, diversity, cold start, and last-stage user rules.
fixture={};ratings={}
for sign in ['positive','negative']:
    for i in range(3):
        bid=f'{sign}-{i}'
        b=dict(id=bid,title=bid,author=bid,genre=['fantasy'],tropes=[],
               genre_accessibility='gateway',narrative_closure='requires_series',
               person='third_limited' if sign=='positive' else 'first',
               overall_pace='fast' if sign=='positive' else 'slow',
               darkness='light' if sign=='positive' else 'grimdark',
               timeline='linear' if sign=='positive' else 'nonlinear',
               form='standard_prose' if sign=='positive' else 'epistolary')
        b['_field_confidence']={f:1.0 for f in b}
        fixture[bid]=b;ratings[bid]='loved' if sign=='positive' else 'hated'
for i in [1,2]:
    bid=f'candidate-{i}'
    b=copy.deepcopy(fixture['positive-0' if i==1 else 'negative-0'])
    b.update(id=bid,title=bid,author='Series author',person='first',series_id='shift',series_name='Shift',position_in_series=i)
    fixture[bid]=b
ctx=context(fixture,ratings)
assert ctx['validated_fields']
for rules in [None, {'reduce':[{'key':'person:first','strength':.2},{'key':'overall_pace:fast','strength':.3}]},
              {'exclude':['person:first'],'reduce':[{'key':'overall_pace:fast','strength':1.0}]}]:
    normalized=O.normalize_user_rules(rules)
    for policy,fn in [('ranking',O.recommend),('explanation',O.explain_match),('audit',O.audit_book_score)]:
        args=(fixture,ratings) if policy=='ranking' else (fixture,ratings,'candidate-1')
        kw=dict(diversity=.2,recent_history=['negative-0'],user_rules=rules) if policy=='ranking' else dict(user_rules=rules) if policy=='audit' else {}
        out,stage,loc,skip=observe(fn,*args,**kw)
        res=N.score_candidate(fixture,'candidate-1',policy=policy,**ctx,diversity=.2,recent_books=[fixture['negative-0']],normalized_rules=normalized)
        compare_stages(res,stage['candidate-1'],('interaction',policy))
        compare_evidence(res,fixture['candidate-1'],ctx,100 if policy=='audit' else 5)
        assert res['scores']['after_veto'] < res['scores']['after_series_repeat']
        assert res['scores']['after_trajectory'] < res['scores']['after_veto']
        if policy=='ranking':
            eq(res['scores']['final'],stage['candidate-1']['final'],'interaction final')
            eq(res['exclusions'],[skip['candidate-1']] if 'candidate-1' in skip else [],'interaction exclusion')
            if not res['exclusions']:
                eq(out,[(res['scores']['final'],'candidate-1','Series author',res['contributions'])],'interaction complete ranking')
        elif policy=='audit':eq(res['scores']['final'],loc['final'],'interaction audit final')
        else:eq(res['scores']['final'],loc['score'],'interaction explanation final')
        print('PASS interaction',policy,'rules='+repr(rules),'stages='+repr(res['scores']))
    oldR=T.R;T.R=O;T._SERIES_DNA_CACHE=ctx['series_dna'];T._PREVALENCE_CACHE=(ctx['field_prevalence'],ctx['trope_prevalence'])
    try:out,stage,loc,_=observe(T._full_score,fixture,ctx['id_to_magnitude'],ctx['validated_fields'],ctx['centroid'],ctx['weights'],fixture['candidate-1'])
    finally:T.R=oldR
    res=N.score_candidate(fixture,'candidate-1',policy='evaluation',**ctx,normalized_rules=normalized)
    compare_stages(res,stage['candidate-1'],'interaction evaluation');eq(res['scores']['final'],out,'interaction evaluation final')

# Unknown policy/missing required context must not silently choose a scoring mode.
for remove,policy in [(None,'unknown'),('matches_genre','ranking'),('cold_start','ranking'),('cold_start','audit')]:
    kw=dict(ctx)
    if remove:kw.pop(remove)
    try:N.score_candidate(fixture,'candidate-1',policy=policy,**kw)
    except ValueError:pass
    else:raise AssertionError(('missing validation',remove,policy))
print('PASS invalid policy and missing prepared context rejected')

# Reuse Task 3's 378-case battery verbatim, but route it through all four policies.
report=Path('docs/codx-reviews/codx-a2-factor-evaluator-proposal-2026-09-16.md').read_text()
case_source=report[report.index('cases = []\n'):report.index('factor_count = 0\n')]
exec(case_source)
for case_index,(name,rawbook,c,w,fp,tp) in enumerate(cases):
    book=dict(rawbook,id='candidate',title=name,author='Fixture',genre=['fantasy'])
    small={'candidate':book}
    ctx=dict(centroid=c,weights=w,id_to_magnitude={},validated_fields=set(),series_dna={},
             field_prevalence=fp,trope_prevalence=tp,poor_threshold=O.DEFAULT_POOR_THRESHOLD,cold_start=0.37,matches_genre=lambda bid:True)
    # Supply precisely the same prepared boundary context to real original callers.
    # Scoring/stage functions and caller bodies themselves are never patched.
    overrides={'_resolve_profile':lambda *a,**k:(c,w,{},ctx['matches_genre']),
               'build_prevalence_lookup':lambda *a,**k:(fp,tp),
               'cold_start_weight':lambda *a,**k:0.37}
    saved={k:getattr(O,k) for k in overrides}
    for k,v in overrides.items():setattr(O,k,v)
    try:
        for policy,fn in [('ranking',O.recommend),('explanation',O.explain_match),('audit',O.audit_book_score)]:
            args=(small,{}) if policy=='ranking' else (small,{},name)
            kwargs=dict(diversity=.2,recent_history=[name]) if policy=='ranking' else {}
            out,stages,loc,_=observe(fn,*args,**kwargs)
            res=N.score_candidate(small,'candidate',policy=policy,**ctx,diversity=.2,recent_books=[book])
            compare_stages(res,stages['candidate'],(name,policy))
            compare_evidence(res,book,ctx,100 if policy=='audit' else 5)
            if policy=='ranking':eq(res['scores']['final'],out[0][0],(name,'ranking final'))
            elif policy=='explanation':eq(res['scores']['final'],loc['score'],(name,'explanation final'))
            else:eq(res['scores']['final'],loc['final'],(name,'audit final'))
        T._SERIES_DNA_CACHE={};T._PREVALENCE_CACHE=(fp,tp);oldR=T.R;T.R=O
        try:out,stage,loc,_=observe(T._full_score,small,{},set(),c,w,book)
        finally:T.R=oldR
        res=N.score_candidate(small,'candidate',policy='evaluation',**ctx)
        eq(res['scores']['final'],out,(name,'evaluation'))
    finally:
        for k,v in saved.items():setattr(O,k,v)
print('PASS Task 3 battery:',len(cases),'cases x four policies; named cases:',fixed_count,flush=True)
for key in ['repeat_changed','veto_changed','trajectory_changed','diversity_changed','cold_start_changed','rules_changed',
            'excluded_already_rated','excluded_genre','excluded_discovery_only','excluded_series_position','excluded_user_rule','flags']:
    assert coverage[key]>0,(key,coverage)
print('PASS coverage:',json.dumps(dict(coverage),sort_keys=True))
print('PASS bit-exact assertions:',checks)
print('PASS all original functions untouched, no input catalog mutation, no production caller migration')
```

## Canonical suite: before (full output, exit 0)

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

## Canonical suite: after (full output, exit 0)

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
index 72d2aa8..0427249 100644
--- a/scripts/recommend.py
+++ b/scripts/recommend.py
@@ -3256,6 +3256,150 @@ def list_user_rule_targets(catalog):
     return targets
 
 
+def score_candidate(catalog, book_id, centroid, weights, id_to_magnitude, *,
+                    policy, validated_fields, series_dna, field_prevalence,
+                    trope_prevalence, poor_threshold, cold_start=None,
+                    matches_genre=None, discovery_only=False, recent_books=(),
+                    diversity=0.0, normalized_rules=None, top_n=None):
+    """Assemble an explicit score result; existing callers are not migrated yet.
+
+    Prepared inputs belong to ONE caller-owned catalog/profile context:
+    _resolve_profile() supplies centroid/weights/id_to_magnitude/matches_genre;
+    validated_dealbreaker_fields(), compute_series_dna(), and
+    build_prevalence_lookup() supply the other required context. Pass the
+    independently computed user_calibrated_poor_threshold() result: calibration
+    stays base-only and is never a stage of this candidate's pipeline. No
+    module-global cache or implicit profile/genre/format choice is used here.
+
+    Policies preserve the current callers' intentionally different contracts:
+      ranking: eligibility -> base -> repeat -> veto -> trajectory -> diversity
+               -> cold start -> rules (recommend)
+      explanation / evaluation: base -> repeat -> veto -> trajectory
+               (explain_match / scoring_tests._full_score)
+      audit: base -> repeat -> veto -> trajectory -> cold start -> rules
+               (audit_book_score; rule-excluded books still have a score)
+
+    ranking requires matches_genre from _resolve_profile(). ranking/audit
+    require cold_start from cold_start_weight(). Normalize rules and resolve
+    recent titles to catalog books once OUTSIDE this function. Other policies
+    ignore these ranking/audit-only inputs, just as their current callers do.
+    Sorting and top-K selection remain the ranking caller's responsibility.
+
+    Scores and factor tuples are unrounded. factors uses _iter_book_factors's
+    (label, similarity, raw_weight, effective_weight, is_trope) contract;
+    contributions retains score_book's rounded top-five display contract.
+    matches/mismatches and dealbreaker_flags are raw (label, magnitude) pairs,
+    not phrases or the audit's separately attributed/rounded display rows.
+    top_n defaults to 100 for audit and 5 otherwise; flag count remains the
+    existing dealbreaker_flags default, independent of top_n.
+
+    stage_sequence names enabled score stages. A skipped optional stage carries
+    forward its input unchanged in scores; it does NOT mean it was applied.
+    Ranking eligibility short-circuits in recommend's order: the first exclusion
+    is returned, all scores/label are None, and no scoring/evidence stage runs.
+    Rule exclusions retain their final score and use the audit's existing
+    'Excluded by user rule' label. Ranking currently exposes no label; its new
+    label is a view of its final score, not a change to any production caller.
+    series_note is the existing explanation view, supplied for every scored
+    policy (audit currently documents it but does not actually return it).
+    """
+    sequences = {
+        "ranking": ("base", "series_repeat", "veto", "trajectory", "diversity",
+                    "cold_start", "user_rules"),
+        "explanation": ("base", "series_repeat", "veto", "trajectory"),
+        "evaluation": ("base", "series_repeat", "veto", "trajectory"),
+        "audit": ("base", "series_repeat", "veto", "trajectory", "cold_start",
+                  "user_rules"),
+    }
+    if policy not in sequences:
+        raise ValueError(f"Unknown scoring policy: {policy!r}")
+    if policy == "ranking" and matches_genre is None:
+        raise ValueError("ranking requires matches_genre from _resolve_profile()")
+    if policy in ("ranking", "audit") and cold_start is None:
+        raise ValueError("ranking/audit require cold_start from cold_start_weight()")
+    book = catalog[book_id]
+    result = {
+        "book_id": book_id, "title": book["title"], "author": book["author"],
+        "policy": policy, "stage_sequence": sequences[policy],
+        "scores": dict.fromkeys(("base", "after_series_repeat", "after_veto",
+                                 "after_trajectory", "after_diversity",
+                                 "after_cold_start", "final")),
+        "poor_threshold": poor_threshold, "match_label": None,
+        "factors": [], "contributions": [], "matches": [], "mismatches": [],
+        "dealbreaker_flags": [], "exclusions": [],
+        "excluded_by_user_rule": False, "series_note": "",
+    }
+    if policy == "ranking":
+        if book_id in id_to_magnitude:
+            result["exclusions"] = ["already_rated"]
+        elif not matches_genre(book_id):
+            result["exclusions"] = ["genre"]
+        elif discovery_only and (
+            book.get("series_id") in {
+                s for bid in id_to_magnitude
+                if (s := catalog[bid].get("series_id")) is not None
+            } or book["author"] in {catalog[bid]["author"] for bid in id_to_magnitude}
+        ):
+            result["exclusions"] = ["discovery_only"]
+        elif not series_position_ready(catalog, id_to_magnitude, book):
+            result["exclusions"] = ["series_position"]
+        if result["exclusions"]:
+            return result
+
+    scores = result["scores"]
+    scores["base"], result["contributions"] = score_book(
+        book, centroid, weights, field_prevalence, trope_prevalence
+    )
+    scores["after_series_repeat"] = _apply_series_repeat(
+        catalog, id_to_magnitude, book, scores["base"]
+    )
+    scores["after_veto"] = _apply_dealbreaker_veto(
+        catalog, id_to_magnitude, validated_fields, book, centroid, weights,
+        scores["after_series_repeat"], field_prevalence, trope_prevalence
+    )
+    scores["after_trajectory"] = _apply_series_trajectory_penalty(
+        series_dna, book, centroid, weights, scores["after_veto"],
+        field_prevalence, trope_prevalence
+    )
+    relevance = scores["after_trajectory"]
+    if policy == "ranking":
+        diversity = max(0.0, min(diversity, MAX_DIVERSITY))
+        if diversity > 0 and recent_books:
+            novelty = 1 - max(book_similarity(book, h) for h in recent_books)
+            relevance = (1 - diversity) * relevance + diversity * novelty
+    scores["after_diversity"] = relevance
+    if policy in ("ranking", "audit") and cold_start > 0:
+        demand = GENRE_ACCESSIBILITY_DEMAND.get(book.get("genre_accessibility"), 0.5)
+        relevance = (1 - cold_start) * relevance + cold_start * (1.0 - demand)
+    scores["after_cold_start"] = relevance
+    excluded_by_rule = False
+    if policy in ("ranking", "audit"):
+        relevance, excluded_by_rule = apply_user_rules(book, relevance, normalized_rules)
+    scores["final"] = relevance
+    result["excluded_by_user_rule"] = excluded_by_rule
+    if excluded_by_rule:
+        result["exclusions"] = ["user_rule"]
+    result["match_label"] = (
+        "Excluded by user rule" if excluded_by_rule else match_label(relevance, poor_threshold)
+    )
+    result["factors"] = list(_iter_book_factors(
+        book, centroid, weights, field_prevalence, trope_prevalence
+    ))
+    result["matches"], result["mismatches"] = explain_book(
+        book, centroid, weights, top_n=(100 if policy == "audit" else 5) if top_n is None else top_n,
+        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence
+    )
+    result["dealbreaker_flags"] = dealbreaker_flags(
+        book, centroid, weights, validated_fields=validated_fields,
+        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence
+    )
+    if book.get("series_id"):
+        series_entry = series_dna.get(book["series_id"])
+        if series_entry:
+            result["series_note"] = describe_series_trajectory(series_entry)
+    return result
+
+
 def recommend(catalog, ratings, top_n=10, genre=None,
               recent_history=None, diversity=0.0, fatigue_overrides=None,
               discovery_only=False, user_rules=None, format_preference=None):
```

## Handoff and restoration

The proposed source was restored to exact HEAD bytes, and the patch extracted from THIS report passed `git apply --check` against that restored tree. No commit, push, hosted write, or application of the proposal was performed by CODX.

Exact restoration command: `python3 /private/tmp/codx-task4/restore.py > /private/tmp/codx-task4/restoration.txt`. Script:

```python
import hashlib, re, subprocess
from pathlib import Path
report=Path('docs/codx-reports/2026-09-16-a2-canonical-scorer-proposal.md')
text=report.read_text()
patches=re.findall(r'^```diff\n(.*?)^```$',text,re.M|re.S)
assert len(patches)==1
patch=patches[0].encode()
assert patch==Path('/private/tmp/codx-task4/proposal.patch').read_bytes()
extracted=Path('/private/tmp/codx-task4/report-extracted.patch')
extracted.write_bytes(patch)
p=Path('scripts/recommend.py')
assert hashlib.sha256(p.read_bytes()).hexdigest()=='38fd015912a6e89f99130d6309104ccc65bbefd6f9bad073dc11456e8c752cf6'
base=subprocess.check_output(['git','show','HEAD:scripts/recommend.py'])
assert base==Path('/private/tmp/codx-task4/original.py').read_bytes()
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
for heading,name in [('Canonical suite: before (full output, exit 0)','before.txt'),('Canonical suite: after (full output, exit 0)','after.txt')]:
    section=text.split('## '+heading+'\n\n```text\n',1)[1].split('```\n',1)[0].encode()
    assert section==Path('/private/tmp/codx-task4',name).read_bytes()
print('PASS: embedded patch and both embedded suite outputs verified byte-for-byte')
print('PASS: tracked working tree and index clean; existing untracked reports preserved')
```

Actual output (exit 0):

```text
Restored scripts/recommend.py SHA-256: 6590c9208f7f910688c4f03c78ab1590a12c5a8b61e87310eeffd40e9ac1e835
$ git diff --exit-code
exit: 0
$ git diff --cached --exit-code
exit: 0
$ git diff --check
exit: 0
$ git apply --check /private/tmp/codx-task4/report-extracted.patch
exit: 0
$ git status --short
exit: 0
?? docs/codx-recommend-review-2026-09-14.md
?? docs/codx-reports/
PASS: embedded patch and both embedded suite outputs verified byte-for-byte
PASS: tracked working tree and index clean; existing untracked reports preserved
```

The report is the durable handoff, including the complete patch and harness. CLDO can independently re-verify and apply this additive proposal. A3 caller migration remains a separate task. No unresolved parity failure or scoring-policy decision remains in this proposal.
