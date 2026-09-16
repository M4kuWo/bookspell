# Task 5 — A3 recommend migration proposal

Date: 2026-09-16. Author: CODX. Status: implemented and locally validated;
proposed diff preserved below, with source restored afterward. No commit,
push, hosted write, or production deployment.

## Baseline and scope

Synced to `d7258b4e6f79d0a33acae8dae38239ffc99dde13`. The clone was actually
at `44599e4` when this task began (the previous task ended at `00f72c7`).
`git pull --ff-only` advanced it to the requested baseline. Commit
`25411d9` is an ancestor, and its canonical `score_candidate()` is present.
The protocol's “A2: canonical score_candidate() orchestrator” entry, updated
CODX TODO, and recent project log were re-read; the repository conventions
and schema/skill context from Task 4 still apply. No catalog-tagging or
schema-migration skill is applicable to this caller-only migration.

The only source change is inside `recommend()`. Its existing per-candidate
eligibility and scoring sequence now delegates to the landed
`score_candidate(..., policy="ranking")`. The helper itself is unchanged,
as are `explain_match()`, `audit_book_score()`, calibration and all stage
helpers, and the whole `scripts/scoring_tests.py` file. There is no scoring
design change, optimization, evidence suppression, package movement, or
migration of another caller. The test checks AST differences and exact
source bytes outside `recommend()`, not just the visible diff.

## Implementation and preserved contract

`user_calibrated_poor_threshold()` is called once immediately after prevalence
preparation. Its full existing catalog/profile/prevalence inputs are passed
unchanged. Its result is reused for every candidate. Calibration remains
base-only, outside candidate scoring. The existing profile, validated fields,
cold-start weight, series DNA, normalized rules, diversity clamp, and resolved
recent books remain caller-owned preparation.

The candidate loop still iterates `catalog.items()` in its existing order.
It passes exactly the specified ranking context into `score_candidate()`.
Candidates with a nonempty `result["exclusions"]` OR a true
`result["excluded_by_user_rule"]` are skipped. Accepted candidates map to:

```python
(result["scores"]["final"], book["title"], book["author"], result["contributions"])
```

No label or other result field is appended. The match label and extra evidence
computed by the canonical scorer are discarded by this caller. The existing
`scored.sort(key=lambda x: -x[0])` and `return scored[:top_n]` are unchanged.
The now-unused `excluded`, `known_series`, and `known_authors` preparation is
removed because the orchestrator owns those eligibility decisions. None of
the eligibility rules is changed or moved outside the orchestrator.

The diff is 18 inserted lines and 31 deleted lines in one function. The two
new comments explain why calibration is outside the loop and why no label is
returned. The accepted extra evidence computation is retained for every scored
candidate. No fast path, shortcut, or optional evidence switch is introduced.

Documentation handoff detail: the untouched `score_candidate()` docstring still
says existing callers have not been migrated yet. When CLDO records this A3
migration as landed, that introductory historical wording will need updating
for `recommend()`; it does not affect the proposed implementation or behavior.
Label rollout remains separate from Task 5, as the user's scope requires.

## Validation approach

The exact original source was copied before editing, then hash-checked against
HEAD. Original and migrated modules are loaded side-by-side in the harness.
The catalog was freshly loaded once using `codx_readonly` and the unchanged
SELECT-only `load_catalog()` path. Both implementations use the SAME in-memory
catalog for every comparison. The snapshot has 978 rows, SHA-256
`ee48604797cbb4f56ab22a65e3bea3aac96078b7f67fceacc13c42ec7332cee9`.
It happens to match Task 4's snapshot, but was fetched anew, not assumed current.
The local snapshot path is `/private/tmp/codx-task5/catalog.pickle`.

Every float is encoded with `struct.pack('!d', value).hex()` before comparison,
including signed zero. Lists and tuples receive distinct type tags, so a list
substituted for a return tuple cannot pass unnoticed. Entire returned lists,
all four tuple fields, contribution pairs and floats, and warnings written to
stdout are compared. No rounding/tolerance or warning filtering is used.
Input catalog, ratings, and call options are checked for mutation.

### Full-list matrix and truncation

Five repository rating files are used: Dandan, Gabriel, Mathias, Osnat, and
the separate Mathias Goodreads fixture. All ratings are passed unchanged,
including titles absent from the catalog, so warning behavior is tested too.
Each file is crossed with:

- genre None / fantasy / sci_fi;
- format None / audiobook / mixed;
- baseline, diversity 0.23 with known and unknown recent-history titles,
  discovery_only=True, a real exclude rule, real reduction rules, and a
  combined diversity/discovery/exclude/reduce case.

That is 270 primary full-list cases (5 × 3 × 3 × 6). Each requests
`top_n=len(catalog)` and compares the ENTIRE list, not just the top 10.
The rule cases use `age_category:ya`, `drive:romance_driven`, and bare trope
key `quest`, with explicit reduction strengths. The combined case uses
diversity 0.5, the existing maximum.

Eight additional edge cases cover empty history, one rating, negative fatigue
with explicit print format, diversity above the ceiling, negative diversity,
no known recent titles, invalid rating/title/rule warnings, and an empty catalog.
Three targeted interaction cases and three deliberately tied catalogs bring
the total to 284 full-list comparisons and 92,825 returned tuples.

95 additional truncation checks invoke BOTH original and migrated callers at
`top_n` 0, 1, 10, -1, and None across the five unscoped/default-format baseline
raters and the edge/interaction/tie fixtures. These also check original slicing
against the corresponding complete list. This preserves current Python slicing
semantics rather than adding new input validation.

### Actual call tracing, exclusions, and noncommuting stages

Fourteen paired calls use `sys.settrace`. For the original ranking loop,
`continue` locations identify the actual exclusion reason, direct helper returns
provide base/repeat/veto/trajectory scores, and the next executable source lines
provide actual diversity/cold-start/final locals. For the migrated function,
tracing captures each real `score_candidate()` result and every calibration
call/return. Expected scores are not reimplemented in the harness.

All 14 traces confirm exactly ONE `user_calibrated_poor_threshold()` call per
recommend invocation, including the empty catalog. The canonical scorer is
called once per catalog row (978 for live traces, zero for the empty catalog).
Every candidate receives the identical once-computed threshold. Every original
exclusion reason matches the new result exactly, including the explicit user
rule boolean. Non-excluded score stages and contribution displays match
bit-for-bit.

Observed trace coverage (counts span the traced cases, not distinct books):

| Branch/effect | Count |
|---|---:|
| Already rated exclusion | 876 |
| Genre exclusion | 2,052 |
| Discovery exclusion | 208 |
| Series-position exclusion | 1,553 |
| User-rule exclusion | 164 |
| Series-repeat score change | 28 |
| Veto score change | 3 |
| Trajectory score change | 97 |
| Diversity score change | 1,065 |
| Cold-start score change | 563 |
| Rule reduction score change | 125 |

The Task 4 eight-book interaction fixture is reused from its committed report,
with its profile/validation/calibration/series-DNA computed by real helpers,
not mocked. It forces a base of 0.8421052631578947, veto at 0.549, trajectory
at 0.38430000000000003, then diversity, cold start, and last-stage rules.
The unmodified original and migrated callers agree exactly. Exclusion wins
over reduction and produces no returned tuple; stacked reductions preserve
order. The complete observed values are in the harness output below.

### Tie-order proof

There are 28 tied-score groups containing 1,120 returned rows across 17 cases.
Every complete original/migrated list is identical, including these tie groups.
Each group's observable title/author sequence is also checked against catalog
insertion order. A live example is Gabriel / sci_fi / default format / baseline:
`Seveneves`, then `A Fire Upon the Deep`, tied at IEEE-754 bytes
`3fdeb61423dbadbe`.

A synthetic eight-book catalog deliberately uses nonalphabetical titles and
two different tied score groups. Forward, reversed, and rotated catalog
insertion orders are each tested, including truncation and actual call tracing.
The returned tie order follows the corresponding insertion order, never an
accidental alphabetical secondary key. No sorting key or catalog iteration
change is introduced by the patch. A1's contribution-display ordering is also
preserved because those contributions are compared exactly and its helper code
is untouched.

One initial harness assumption failed BEFORE scoring: titles were assumed
unique, but the real catalog has two rows titled `The One`. That is not a scorer
failure or a catalog-change request. The harness was corrected to check observable
title/author sequences as a subsequence of catalog order, allowing duplicate
rows without deduplicating or modifying the input. Identical duplicate output
tuples cannot expose a hidden row identity because recommend does not return IDs;
full observable tuple order and the distinct-title synthetic tie cases are both
verified. The original failed output is recorded below for transparency.

### Summary and canonical suite

All 39,203 primary equality assertions passed, followed by three more complete
output comparisons during timing. All source-scope, coverage, call-count,
return-shape, tie-order, and mutation assertions also passed. 55 matrix/edge
cases emitted warnings; those warnings were equal in both implementations.
A digest over case names and complete type-preserving, float-bit-encoded results
matches on both sides:

`06d7893ad3c351d7290c48737073068e6960114d6387517a3a60c63ea85cfb91`

The full canonical suite ran before editing and after migration via the same
read-only launcher. Both exited 0, with exactly 29,591 output bytes and SHA-256:

`8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea`

Full byte equality is asserted in addition to matching hashes. stdout and
stderr are captured together without filtering or normalization. The suite
includes its existing format-aware scenario and confidence-floor regression
checks. Both complete outputs appear below. No canonical-suite function or
module was monkeypatched; it executes the actual edited source in a subprocess.

This is evidence on the current catalog and named edge cases, not a proof for
every possible malformed catalog object. No behavior mismatch was found, and
no production-code correction was needed after the initial migration.

## Accepted wall-clock cost

Timing excludes database/network loading and tracing. It includes one complete
recommend call over the 978-book in-memory catalog, full preparation, sorting,
and the entire returned list. Profile: Mathias, fantasy, audiobook, no extra
rules/diversity; 292 eligible results. Three samples per implementation alternate
execution order. These are local wall-clock observations, not a Render latency
claim or a statistical performance study.

| Implementation | Seconds (three samples) | Median |
|---|---|---:|
| Original | 0.05885704094544053, 0.058269249740988016, 0.0607916247099638 | 0.05885704094544053 |
| Migrated | 0.09440237516537309, 0.09333708276972175, 0.09452091623097658 | 0.09440237516537309 |

The observed median ratio is 1.6039266271113166 (about 1.60×; about 35.5 ms
additional local work). The new calibration and full evidence computation are
retained exactly as required. No optimization was attempted.

## Exact commands and execution notes

Initial sync and baseline checks:

```sh
git status --short
git pull --ff-only
git rev-parse HEAD
git merge-base --is-ancestor 25411d9 HEAD
git config core.hooksPath
```

The sandbox's first pull failed with:

```text
error: cannot open '.git/FETCH_HEAD': Operation not permitted
```

It was rerun using the execution tool's required escalation for protected Git
metadata/network access. This succeeded; no authentication workaround was used.
Successful pull output:

```text
From https://github.com/M4kuWo/bookspell
   44599e4..d7258b4  main       -> origin/main
Updating 44599e4..d7258b4
Fast-forward
 docs/TODO.md                                       |   23 +-
 ...codx-a2-canonical-scorer-proposal-2026-09-16.md | 1720 ++++++++++++++++++++
 docs/project-log.md                                |   57 +
 docs/scoring-test-protocol.md                      |   74 +
 scripts/recommend.py                               |  144 ++
 5 files changed, 2015 insertions(+), 3 deletions(-)
 create mode 100644 docs/codx-reviews/codx-a2-canonical-scorer-proposal-2026-09-16.md
```

HEAD was `d7258b4e6f79d0a33acae8dae38239ffc99dde13`; the ancestor check exited
0 with no output; hooks path was `.githooks`. Existing untracked report paths
were left alone throughout. “Clean” on handoff means no tracked/index changes,
not deleting required reports or older untracked output.

The launcher/snapshot script/harness below were saved under
`/private/tmp/codx-task5/`. The before suite ran before the source edit; the
snapshot and after suite used the same existing read-only role via explicit
network escalation. The parity harness itself runs offline from the snapshot.

```sh
python3 /private/tmp/codx-task5/run.py before
# Apply only the proposal diff below to the working copy, uncommitted.
python3 /private/tmp/codx-task5/run.py snapshot
python3 -B /private/tmp/codx-task5/validate.py > /private/tmp/codx-task5/parity.txt 2>&1
python3 /private/tmp/codx-task5/run.py after
git diff --check
git diff -- scripts/recommend.py
```

Launcher output:

```text
before: exit=0 bytes=29591 sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
snapshot: exit=0 bytes=101 sha256=8c204c16493ac55694fd369dff4ff22c54c912f0971b765a03a1651621728f1b
after: exit=0 bytes=29591 sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
```

Snapshot command's complete captured output:

```text
Catalog books: 978 snapshot sha256: ee48604797cbb4f56ab22a65e3bea3aac96078b7f67fceacc13c42ec7332cee9
```

The initial parity command exited 1 because of the duplicate-title assertion;
the corrected, final command exited 0. Its complete output is embedded below.
`git diff --check` exited 0 without output. Source/output integrity checks:

```text
before.txt bytes=29591 sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
after.txt bytes=29591 sha256=8d5391c15a95ada51bcce8b78fd562ba9c23bc44e9c4996d38bf4027093f97ea
parity.txt bytes=28148 sha256=0062ba808f3f1b16b43d50388ffcb7fdbafff0c8d20ad83cddc7e2145b8e3998
original.py bytes=206219 sha256=38fd015912a6e89f99130d6309104ccc65bbefd6f9bad073dc11456e8c752cf6
scripts/recommend.py HEAD=38fd015912a6e89f99130d6309104ccc65bbefd6f9bad073dc11456e8c752cf6 working=8fd0d6894a2d0fdd2a52ab84d28e37805c8369e1002539f46ccbdc09b5200fbc
scripts/scoring_tests.py HEAD=d34f99e8d08f2e6bdc540353b65d3f7464b8c5c9bce39089745e3d518282b23a working=d34f99e8d08f2e6bdc540353b65d3f7464b8c5c9bce39089745e3d518282b23a
proposal.patch sha256=65983df352ceacbb0234b6c81bb804e47aa98a6c7e7a5eb2364178a12f71fc43
```

For independent reproduction, use an isolated checkout at the baseline above,
create `/private/tmp/codx-task5/`, and save the following scripts there. Save
`git show d7258b4e6f79d0a33acae8dae38239ffc99dde13:scripts/recommend.py`
as `original.py` in that directory before applying the patch. Run the before
suite, apply the single diff, fetch/reuse the snapshot, run parity and the after
suite. The fixture is extracted from the committed Task 4 report. A newer live
catalog may naturally produce different coverage/timing/output hashes; both
sides of any independent comparison must still use identical catalog data.

## Initial harness failure (complete output, exit 1)

```text
PASS scope: only recommend changed; every byte outside that function unchanged
Traceback (most recent call last):
  File "/private/tmp/codx-task5/validate.py", line 39, in <module>
    assert len({b['title'] for b in catalog.values()})==len(catalog)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError
```

## Final parity output (complete output, exit 0)

```text
PASS scope: only recommend changed; every byte outside that function unchanged
Duplicate title rows: 1
Catalog books: 978 snapshot sha256: ee48604797cbb4f56ab22a65e3bea3aac96078b7f67fceacc13c42ec7332cee9
PASS dandan/genre=None/format=None/baseline rows=535 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=None/diversity rows=535 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=None/discovery rows=516 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=None/exclude rows=464 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=None/reduce rows=535 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=None/combined rows=447 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=audiobook/baseline rows=535 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=audiobook/diversity rows=535 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=audiobook/discovery rows=516 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=audiobook/exclude rows=464 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=audiobook/reduce rows=535 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=audiobook/combined rows=447 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=mixed/baseline rows=535 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=mixed/diversity rows=535 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=mixed/discovery rows=516 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=mixed/exclude rows=464 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=mixed/reduce rows=535 tie_groups=0 warnings_bytes=0
PASS dandan/genre=None/format=mixed/combined rows=447 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=None/baseline rows=325 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=None/diversity rows=325 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=None/discovery rows=311 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=None/exclude rows=276 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=None/reduce rows=325 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=None/combined rows=262 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=audiobook/baseline rows=325 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=audiobook/diversity rows=325 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=audiobook/discovery rows=311 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=audiobook/exclude rows=276 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=audiobook/reduce rows=325 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=audiobook/combined rows=262 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=mixed/baseline rows=325 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=mixed/diversity rows=325 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=mixed/discovery rows=311 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=mixed/exclude rows=276 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=mixed/reduce rows=325 tie_groups=0 warnings_bytes=0
PASS dandan/genre=fantasy/format=mixed/combined rows=262 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=None/baseline rows=235 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=None/diversity rows=235 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=None/discovery rows=226 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=None/exclude rows=212 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=None/reduce rows=235 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=None/combined rows=205 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=audiobook/baseline rows=235 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=audiobook/diversity rows=235 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=audiobook/discovery rows=226 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=audiobook/exclude rows=212 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=audiobook/reduce rows=235 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=audiobook/combined rows=205 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=mixed/baseline rows=235 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=mixed/diversity rows=235 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=mixed/discovery rows=226 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=mixed/exclude rows=212 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=mixed/reduce rows=235 tie_groups=0 warnings_bytes=0
PASS dandan/genre=sci_fi/format=mixed/combined rows=205 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=None/baseline rows=536 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=None/diversity rows=536 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=None/discovery rows=525 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=None/exclude rows=464 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=None/reduce rows=536 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=None/combined rows=455 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=audiobook/baseline rows=536 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=audiobook/diversity rows=536 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=audiobook/discovery rows=525 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=audiobook/exclude rows=464 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=audiobook/reduce rows=536 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=audiobook/combined rows=455 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=mixed/baseline rows=536 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=mixed/diversity rows=536 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=mixed/discovery rows=525 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=mixed/exclude rows=464 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=mixed/reduce rows=536 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=None/format=mixed/combined rows=455 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=None/baseline rows=326 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=None/diversity rows=326 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=None/discovery rows=316 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=None/exclude rows=277 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=None/reduce rows=326 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=None/combined rows=269 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=audiobook/baseline rows=326 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=audiobook/diversity rows=326 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=audiobook/discovery rows=316 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=audiobook/exclude rows=277 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=audiobook/reduce rows=326 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=audiobook/combined rows=269 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=mixed/baseline rows=326 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=mixed/diversity rows=326 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=mixed/discovery rows=316 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=mixed/exclude rows=277 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=mixed/reduce rows=326 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=fantasy/format=mixed/combined rows=269 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=None/baseline rows=235 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=None/diversity rows=235 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=None/discovery rows=234 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=None/exclude rows=211 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=None/reduce rows=235 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=None/combined rows=210 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=audiobook/baseline rows=235 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=audiobook/diversity rows=235 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=audiobook/discovery rows=234 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=audiobook/exclude rows=211 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=audiobook/reduce rows=235 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=audiobook/combined rows=210 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=mixed/baseline rows=235 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=mixed/diversity rows=235 tie_groups=0 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=mixed/discovery rows=234 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=mixed/exclude rows=211 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=mixed/reduce rows=235 tie_groups=1 warnings_bytes=0
PASS gabriel/genre=sci_fi/format=mixed/combined rows=210 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=None/baseline rows=494 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=None/diversity rows=494 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=None/discovery rows=409 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=None/exclude rows=424 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=None/reduce rows=494 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=None/combined rows=348 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=audiobook/baseline rows=494 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=audiobook/diversity rows=494 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=audiobook/discovery rows=409 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=audiobook/exclude rows=424 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=audiobook/reduce rows=494 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=audiobook/combined rows=348 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=mixed/baseline rows=494 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=mixed/diversity rows=494 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=mixed/discovery rows=409 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=mixed/exclude rows=424 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=mixed/reduce rows=494 tie_groups=0 warnings_bytes=0
PASS mathias/genre=None/format=mixed/combined rows=348 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=None/baseline rows=292 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=None/diversity rows=292 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=None/discovery rows=237 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=None/exclude rows=243 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=None/reduce rows=292 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=None/combined rows=195 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=audiobook/baseline rows=292 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=audiobook/diversity rows=292 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=audiobook/discovery rows=237 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=audiobook/exclude rows=243 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=audiobook/reduce rows=292 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=audiobook/combined rows=195 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=mixed/baseline rows=292 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=mixed/diversity rows=292 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=mixed/discovery rows=237 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=mixed/exclude rows=243 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=mixed/reduce rows=292 tie_groups=0 warnings_bytes=0
PASS mathias/genre=fantasy/format=mixed/combined rows=195 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=None/baseline rows=224 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=None/diversity rows=224 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=None/discovery rows=192 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=None/exclude rows=202 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=None/reduce rows=224 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=None/combined rows=172 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=audiobook/baseline rows=224 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=audiobook/diversity rows=224 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=audiobook/discovery rows=192 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=audiobook/exclude rows=202 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=audiobook/reduce rows=224 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=audiobook/combined rows=172 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=mixed/baseline rows=224 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=mixed/diversity rows=224 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=mixed/discovery rows=192 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=mixed/exclude rows=202 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=mixed/reduce rows=224 tie_groups=0 warnings_bytes=0
PASS mathias/genre=sci_fi/format=mixed/combined rows=172 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=None/baseline rows=512 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=None/diversity rows=512 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=None/discovery rows=451 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=None/exclude rows=441 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=None/reduce rows=512 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=None/combined rows=385 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=audiobook/baseline rows=512 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=audiobook/diversity rows=512 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=audiobook/discovery rows=451 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=audiobook/exclude rows=441 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=audiobook/reduce rows=512 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=audiobook/combined rows=385 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=mixed/baseline rows=512 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=mixed/diversity rows=512 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=mixed/discovery rows=451 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=mixed/exclude rows=441 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=mixed/reduce rows=512 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=None/format=mixed/combined rows=385 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=None/baseline rows=308 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=None/diversity rows=308 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=None/discovery rows=269 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=None/exclude rows=258 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=None/reduce rows=308 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=None/combined rows=222 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=audiobook/baseline rows=308 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=audiobook/diversity rows=308 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=audiobook/discovery rows=269 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=audiobook/exclude rows=258 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=audiobook/reduce rows=308 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=audiobook/combined rows=222 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=mixed/baseline rows=308 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=mixed/diversity rows=308 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=mixed/discovery rows=269 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=mixed/exclude rows=258 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=mixed/reduce rows=308 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=fantasy/format=mixed/combined rows=222 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=None/baseline rows=228 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=None/diversity rows=228 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=None/discovery rows=203 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=None/exclude rows=206 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=None/reduce rows=228 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=None/combined rows=183 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=audiobook/baseline rows=228 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=audiobook/diversity rows=228 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=audiobook/discovery rows=203 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=audiobook/exclude rows=206 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=audiobook/reduce rows=228 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=audiobook/combined rows=183 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=mixed/baseline rows=228 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=mixed/diversity rows=228 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=mixed/discovery rows=203 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=mixed/exclude rows=206 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=mixed/reduce rows=228 tie_groups=0 warnings_bytes=0
PASS mathias_goodreads/genre=sci_fi/format=mixed/combined rows=183 tie_groups=0 warnings_bytes=0
PASS osnat/genre=None/format=None/baseline rows=525 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=None/diversity rows=525 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=None/discovery rows=512 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=None/exclude rows=454 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=None/reduce rows=525 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=None/combined rows=445 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=audiobook/baseline rows=525 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=audiobook/diversity rows=525 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=audiobook/discovery rows=512 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=audiobook/exclude rows=454 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=audiobook/reduce rows=525 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=audiobook/combined rows=445 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=mixed/baseline rows=525 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=mixed/diversity rows=525 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=mixed/discovery rows=512 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=mixed/exclude rows=454 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=mixed/reduce rows=525 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=None/format=mixed/combined rows=445 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=None/baseline rows=316 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=None/diversity rows=316 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=None/discovery rows=309 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=None/exclude rows=267 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=None/reduce rows=316 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=None/combined rows=263 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=audiobook/baseline rows=316 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=audiobook/diversity rows=316 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=audiobook/discovery rows=309 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=audiobook/exclude rows=267 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=audiobook/reduce rows=316 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=audiobook/combined rows=263 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=mixed/baseline rows=316 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=mixed/diversity rows=316 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=mixed/discovery rows=309 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=mixed/exclude rows=267 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=mixed/reduce rows=316 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=fantasy/format=mixed/combined rows=263 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=None/baseline rows=232 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=None/diversity rows=232 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=None/discovery rows=226 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=None/exclude rows=209 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=None/reduce rows=232 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=None/combined rows=204 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=audiobook/baseline rows=232 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=audiobook/diversity rows=232 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=audiobook/discovery rows=226 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=audiobook/exclude rows=209 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=audiobook/reduce rows=232 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=audiobook/combined rows=204 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=mixed/baseline rows=232 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=mixed/diversity rows=232 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=mixed/discovery rows=226 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=mixed/exclude rows=209 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=mixed/reduce rows=232 tie_groups=0 warnings_bytes=2955
PASS osnat/genre=sci_fi/format=mixed/combined rows=204 tie_groups=0 warnings_bytes=2955
PASS cold-empty rows=536 tie_groups=5 warnings_bytes=0
PASS cold-one rows=463 tie_groups=0 warnings_bytes=0
PASS fatigue rows=325 tie_groups=0 warnings_bytes=0
PASS diversity-high rows=535 tie_groups=0 warnings_bytes=0
PASS diversity-negative rows=535 tie_groups=0 warnings_bytes=0
PASS no-known-history rows=535 tie_groups=0 warnings_bytes=0
PASS invalid-input-warnings rows=536 tie_groups=5 warnings_bytes=264
PASS empty-catalog rows=0 tie_groups=0 warnings_bytes=0
PASS traced live/baseline calibration_calls=1 candidate_calls=978
PASS traced live/diversity calibration_calls=1 candidate_calls=978
PASS traced live/discovery calibration_calls=1 candidate_calls=978
PASS traced live/exclude calibration_calls=1 candidate_calls=978
PASS traced live/reduce calibration_calls=1 candidate_calls=978
PASS traced live/combined calibration_calls=1 candidate_calls=978
PASS traced live/cold-empty calibration_calls=1 candidate_calls=978
PASS traced empty-catalog calibration_calls=1 candidate_calls=0
PASS interaction/none rows=1 tie_groups=0 warnings_bytes=0
PASS traced interaction/none calibration_calls=1 candidate_calls=8
INTERACTION none {"base": 0.8421052631578947, "after_series_repeat": 0.8421052631578947, "after_veto": 0.549, "after_trajectory": 0.38430000000000003, "after_diversity": 0.47410666666666673, "after_cold_start": 0.7370533333333333, "final": 0.7370533333333333}
PASS interaction/reduce rows=1 tie_groups=0 warnings_bytes=0
PASS traced interaction/reduce calibration_calls=1 candidate_calls=8
INTERACTION reduce {"base": 0.8421052631578947, "after_series_repeat": 0.8421052631578947, "after_veto": 0.549, "after_trajectory": 0.38430000000000003, "after_diversity": 0.47410666666666673, "after_cold_start": 0.7370533333333333, "final": 0.41274986666666663}
PASS interaction/exclude rows=0 tie_groups=0 warnings_bytes=0
PASS traced interaction/exclude calibration_calls=1 candidate_calls=8
INTERACTION exclude {"base": 0.8421052631578947, "after_series_repeat": 0.8421052631578947, "after_veto": 0.549, "after_trajectory": 0.38430000000000003, "after_diversity": 0.47410666666666673, "after_cold_start": 0.7370533333333333, "final": 0.7370533333333333}
PASS tie/forward rows=8 tie_groups=2 warnings_bytes=0
PASS traced tie/forward calibration_calls=1 candidate_calls=8
PASS tie/reverse rows=8 tie_groups=2 warnings_bytes=0
PASS traced tie/reverse calibration_calls=1 candidate_calls=8
PASS tie/rotated rows=8 tie_groups=2 warnings_bytes=0
PASS traced tie/rotated calibration_calls=1 candidate_calls=8
PASS coverage: {"already_rated": 876, "cold_start": 563, "discovery_only": 208, "diversity": 1065, "genre": 2052, "repeat": 28, "rules": 125, "series_position": 1553, "trajectory": 97, "user_rule": 164, "veto": 3}
PASS counts: {"cases": 284, "cases_with_ties": 17, "cases_with_warnings": 55, "returned_rows": 92825, "tie_groups": 28, "tied_rows": 1120, "traced_calls": 14, "truncation_checks": 95}
PASS assertions: 39203
PASS complete result digest original: 06d7893ad3c351d7290c48737073068e6960114d6387517a3a60c63ea85cfb91
PASS complete result digest migrated: 06d7893ad3c351d7290c48737073068e6960114d6387517a3a60c63ea85cfb91
First real tie example: {"case": "gabriel/genre=sci_fi/format=None/baseline", "score_hex": "3fdeb61423dbadbe", "titles": ["Seveneves", "A Fire Upon the Deep"]}
TIMING full catalog candidates: 978 returned: 292
TIMING original seconds: [0.05885704094544053, 0.058269249740988016, 0.0607916247099638] median: 0.05885704094544053
TIMING migrated seconds: [0.09440237516537309, 0.09333708276972175, 0.09452091623097658] median: 0.09440237516537309
TIMING median ratio: 1.6039266271113166
PASS final: exact tuples, complete lists, warnings, all exclusion reasons, stage values, calibration once, stable ties, truncation, no input mutations
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
command = 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 scripts/scoring_tests.py' if mode in ('before', 'after') else 'DATABASE_URL="$CODX_READONLY_DATABASE_URL" python3 /private/tmp/codx-task5/snapshot.py'
p = subprocess.run(['zsh', '-f', '-c', command], env=e, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
if parts[0].encode() in p.stdout: raise SystemExit('Credential appeared in output; not saved')
path = Path('/private/tmp/codx-task5') / (mode + '.txt')
path.write_bytes(p.stdout)
print(f'{mode}: exit={p.returncode} bytes={len(p.stdout)} sha256={hashlib.sha256(p.stdout).hexdigest()}')
if p.returncode: print(p.stdout.decode())
sys.exit(p.returncode)
```

## Catalog snapshot script

```python
import sys,pickle,hashlib
from pathlib import Path
sys.path.insert(0,str(Path.cwd()/'scripts'))
import recommend as R
catalog=R.load_catalog()
data=pickle.dumps(catalog)
Path('/private/tmp/codx-task5/catalog.pickle').write_bytes(data)
print('Catalog books:',len(catalog),'snapshot sha256:',hashlib.sha256(data).hexdigest())
```

## Complete validation harness

```python
import ast, contextlib, copy, hashlib, importlib.util, io, itertools, json, pickle, struct, sys, time
from collections import Counter
from pathlib import Path
ROOT=Path.cwd(); WORK=Path('/private/tmp/codx-task5')
sys.path.insert(0,str(ROOT/'scripts'))
import recommend as N
spec=importlib.util.spec_from_file_location('task5_original',WORK/'original.py')
O=importlib.util.module_from_spec(spec);spec.loader.exec_module(O)
old_source=(WORK/'original.py').read_text(); new_source=Path('scripts/recommend.py').read_text()
a={n.name:n for n in ast.parse(old_source).body if isinstance(n,(ast.FunctionDef,ast.ClassDef))}
b={n.name:n for n in ast.parse(new_source).body if isinstance(n,(ast.FunctionDef,ast.ClassDef))}
assert a.keys()==b.keys()
assert {k for k in a if ast.dump(a[k])!=ast.dump(b[k])}=={'recommend'}
old_lines=old_source.splitlines(keepends=True);new_lines=new_source.splitlines(keepends=True)
assert old_lines[:a['recommend'].lineno-1]==new_lines[:b['recommend'].lineno-1]
assert old_lines[a['recommend'].end_lineno:]==new_lines[b['recommend'].end_lineno:]
print('PASS scope: only recommend changed; every byte outside that function unchanged',flush=True)

checks=0;stats=Counter();old_digest=hashlib.sha256();new_digest=hashlib.sha256();timings=[]
def encode(x):
    if isinstance(x,float):return ['float64',struct.pack('!d',x).hex()]
    if isinstance(x,tuple):return ['tuple',[encode(v) for v in x]]
    if isinstance(x,list):return ['list',[encode(v) for v in x]]
    if isinstance(x,dict):return ['dict',[(k,encode(v)) for k,v in x.items()]]
    return x

def encoded(x):return json.dumps(encode(x),ensure_ascii=False,separators=(',',':')).encode()
def eq(x,y,label):
    global checks
    assert encoded(x)==encoded(y),(label,x,y)
    checks+=1

def run(module,catalog,ratings,kw):
    output=io.StringIO();start=time.perf_counter()
    with contextlib.redirect_stdout(output):result=module.recommend(catalog,ratings,**kw)
    return result,output.getvalue(),time.perf_counter()-start

snapshot=(WORK/'catalog.pickle').read_bytes();catalog=pickle.loads(snapshot)
print('Duplicate title rows:',len(catalog)-len({b['title'] for b in catalog.values()}),flush=True)
catalog_before=pickle.dumps(catalog)
print('Catalog books:',len(catalog),'snapshot sha256:',hashlib.sha256(snapshot).hexdigest(),flush=True)

first_tie_example=None

def compare_case(name,cat,ratings,kw,check_slices=False):
    global first_tie_example
    before=pickle.dumps((cat,ratings,kw))
    args=dict(kw,top_n=len(cat))
    out_old,warn_old,t_old=run(O,cat,ratings,args)
    out_new,warn_new,t_new=run(N,cat,ratings,args)
    eq(out_new,out_old,(name,'entire ranked list'))
    eq(warn_new,warn_old,(name,'stdout warnings'))
    assert all(type(row) is tuple and len(row)==4 for row in out_new)
    assert pickle.dumps((cat,ratings,kw))==before,(name,'input mutation')
    old_digest.update(name.encode()+b'\0'+encoded(out_old));new_digest.update(name.encode()+b'\0'+encoded(out_new))
    catalog_order=[(book['title'],book['author']) for book in cat.values()]
    ties=0
    for score,items in itertools.groupby(out_new,key=lambda r:r[0]):
        group=list(items)
        if len(group)>1:
            # Duplicate catalog titles are valid inputs; verify the observable
            # title/author sequence is a subsequence of catalog insertion order.
            cursor=0
            for row in group:
                key=(row[1],row[2])
                while cursor<len(catalog_order) and catalog_order[cursor]!=key:cursor+=1
                assert cursor<len(catalog_order),(name,'tie-order',group)
                cursor+=1
            ties+=1;stats['tied_rows']+=len(group)
            if first_tie_example is None:
                first_tie_example=dict(case=name,score_hex=struct.pack('!d',score).hex(),titles=[r[1] for r in group])
    stats['cases']+=1;stats['returned_rows']+=len(out_new);stats['tie_groups']+=ties
    if ties:stats['cases_with_ties']+=1
    if warn_old:stats['cases_with_warnings']+=1
    timings.append((name,t_old,t_new))
    if check_slices:
        for n in [0,1,10,-1,None]:
            # Original caller is also invoked for each slice, not just inferred.
            x,wx,_=run(O,cat,ratings,dict(kw,top_n=n));y,wy,_=run(N,cat,ratings,dict(kw,top_n=n))
            eq(x,out_old[:n],(name,'original slice',n));eq(y,x,(name,'migrated slice',n));eq(wy,wx,(name,'slice warnings',n))
            stats['truncation_checks']+=1
    print('PASS',name,'rows='+str(len(out_new)),'tie_groups='+str(ties),'warnings_bytes='+str(len(warn_old.encode())),flush=True)
    return out_old,out_new

raters=[(p.stem,json.loads(p.read_text())['ratings']) for p in sorted(Path('data/ratings').glob('*.json'))]
history=[v['title'] for v in list(catalog.values())[:3]]+['not a catalog title']
exclude={'exclude':['age_category:ya']}
reduce={'reduce':[{'key':'age_category:ya','strength':.37},{'key':'drive:romance_driven','strength':.6},{'key':'quest','strength':.2}]}
combined={'exclude':['age_category:ya'], 'reduce':[{'key':'drive:romance_driven','strength':.6},{'key':'quest','strength':.2}]}
scenarios=[('baseline',{}),('diversity',dict(diversity=.23,recent_history=history)),
           ('discovery',dict(discovery_only=True)),('exclude',dict(user_rules=exclude)),
           ('reduce',dict(user_rules=reduce)),
           ('combined',dict(diversity=.5,recent_history=history,discovery_only=True,user_rules=combined))]
for rater,ratings in raters:
    for genre,fmt in itertools.product([None,'fantasy','sci_fi'],[None,'audiobook','mixed']):
        for scenario,options in scenarios:
            kw=dict(genre=genre,format_preference=fmt,**options)
            compare_case(f'{rater}/genre={genre}/format={fmt}/{scenario}',catalog,ratings,kw,
                         check_slices=scenario=='baseline' and genre is None and fmt is None)

# Edge profiles and caller options. Keep actual warning behavior observable.
for name,ratings,kw in [
    ('cold-empty',{},{}),
    ('cold-one',{history[0]:'liked'},dict(diversity=.23,recent_history=history,user_rules=combined)),
    ('fatigue',raters[0][1],dict(fatigue_overrides={'person':-.6,'quest':-1.0},genre='fantasy',format_preference='print')),
    ('diversity-high',raters[0][1],dict(diversity=2.0,recent_history=history)),
    ('diversity-negative',raters[0][1],dict(diversity=-1.0,recent_history=history)),
    ('no-known-history',raters[0][1],dict(diversity=.4,recent_history=['not a catalog title'])),
    ('invalid-input-warnings',{'missing title':'loved',history[0]:'invalid-rating'},dict(user_rules={'exclude':['invalid_field:x']})),
    ('empty-catalog',{},{}),
]:
    compare_case(name,{} if name=='empty-catalog' else catalog,ratings,kw,check_slices=True)

# Actual caller tracing: ensure calibration once, canonical call for each
# candidate, matching old continue reasons and exact original stage values.
helper_stages={'score_book':'base','_apply_series_repeat':'after_series_repeat',
               '_apply_dealbreaker_veto':'after_veto','_apply_series_trajectory_penalty':'after_trajectory'}
coverage=Counter()
def trace_pair(name,cat,ratings,kw):
    exclusions={};stages={};new_results={};counts=Counter();thresholds=[];passed_thresholds=[]
    def tracer(frame,event,arg):
        code=frame.f_code;v=frame.f_locals
        if code is O.recommend.__code__:
            if event=='line' and 'bid' in v:
                bid=v['bid'];line=old_lines[frame.f_lineno-1].strip()
                if line=='continue':
                    previous=old_lines[frame.f_lineno-2].strip()
                    if 'bid in excluded' in previous:reason='already_rated' if bid in v['excluded'] else 'genre'
                    elif 'series_position_ready' in previous:reason='series_position'
                    elif 'excluded_by_rule' in previous:reason='user_rule'
                    else:reason='discovery_only'
                    exclusions[bid]=reason
                if line=='if csw > 0:':stages.setdefault(bid,{})['after_diversity']=v['relevance']
                if line.startswith('final, excluded_by_rule ='):stages.setdefault(bid,{})['after_cold_start']=v['final']
                if line=='if excluded_by_rule:':stages.setdefault(bid,{})['final']=v['final']
            return tracer
        if code is N.user_calibrated_poor_threshold.__code__:
            if event=='call':counts['calibration']+=1
            if event=='return':thresholds.append(arg)
            return tracer
        if code is N.score_candidate.__code__:
            if event=='call':
                counts['candidate']+=1;passed_thresholds.append(v['poor_threshold'])
                assert v['policy']=='ranking'
            if event=='return':new_results[v['book_id']]=arg
            return tracer
        parent=frame.f_back
        if parent and parent.f_code is O.recommend.__code__ and code.co_name in helper_stages:
            if event=='return':
                bid=v['book']['id'];key=helper_stages[code.co_name]
                stages.setdefault(bid,{})[key]=arg[0] if key=='base' else arg
                if key=='base':stages[bid]['contributions']=arg[1]
            return tracer
        return None
    sys.settrace(tracer)
    try:
        old,wo,_=run(O,cat,ratings,dict(kw,top_n=len(cat)))
        new,wn,_=run(N,cat,ratings,dict(kw,top_n=len(cat)))
    finally:sys.settrace(None)
    eq(new,old,(name,'traced complete output'));eq(wn,wo,(name,'traced stdout'))
    assert counts['calibration']==1 and counts['candidate']==len(cat),(name,counts)
    assert len(thresholds)==1
    for threshold in passed_thresholds:eq(threshold,thresholds[0],'same once-calibrated threshold')
    assert set(new_results)==set(cat)
    for bid,res in new_results.items():
        eq(res['exclusions'],[exclusions[bid]] if bid in exclusions else [],(name,bid,'continue reason'))
        eq(res['excluded_by_user_rule'],exclusions.get(bid)=='user_rule','user rule flag')
        if bid in exclusions:coverage[exclusions[bid]]+=1
        for key,value in stages.get(bid,{}).items():
            eq(res['contributions'] if key=='contributions' else res['scores'][key],value,(name,bid,key))
        if res['scores']['base'] is not None:
            for first,last,label in [('base','after_series_repeat','repeat'),('after_series_repeat','after_veto','veto'),
                                    ('after_veto','after_trajectory','trajectory'),('after_trajectory','after_diversity','diversity'),
                                    ('after_diversity','after_cold_start','cold_start'),('after_cold_start','final','rules')]:
                if res['scores'][first]!=res['scores'][last]:coverage[label]+=1
    stats['traced_calls']+=1
    print('PASS traced',name,'calibration_calls='+str(counts['calibration']),'candidate_calls='+str(counts['candidate']),flush=True)
    return new_results

ratings=dict(raters)['mathias']
for scenario,kw in scenarios:
    trace_pair('live/'+scenario,catalog,ratings,dict(genre='fantasy',format_preference='audiobook',**kw))
trace_pair('live/cold-empty',catalog,{},dict(diversity=.23,recent_history=history,user_rules=combined))
trace_pair('empty-catalog',{}, {}, {})

# The Task 4 targeted catalog forces a genuine veto/trajectory interaction.
# Extract only its fixture construction, then learn all preparation normally.
report=Path('docs/codx-reviews/codx-a2-canonical-scorer-proposal-2026-09-16.md').read_text()
fixture_source=report.split("fixture={};ratings={}\n",1)[1].split('ctx=context(fixture,ratings)',1)[0]
fixture={};ratings={};exec(fixture_source)
for kind,rules in [('none',None),('reduce',{'reduce':[{'key':'person:first','strength':.2},{'key':'overall_pace:fast','strength':.3}]}),
                   ('exclude',{'exclude':['person:first'],'reduce':[{'key':'overall_pace:fast','strength':1.0}]})]:
    kw=dict(diversity=.2,recent_history=['negative-0'],user_rules=rules)
    compare_case('interaction/'+kind,fixture,ratings,kw,check_slices=True)
    results=trace_pair('interaction/'+kind,fixture,ratings,kw)
    scores=results['candidate-1']['scores']
    assert scores['after_veto']<scores['after_series_repeat'] and scores['after_trajectory']<scores['after_veto']
    print('INTERACTION',kind,json.dumps(scores),flush=True)

# Ties deliberately contradict title order and include multiple distinct scores.
# Reverse and rotate catalog insertion order and check stable tie behavior anew.
ties={}
for i,title in enumerate(['Zulu','Alpha','Omega','Beta','X-ray','Delta','Victor','Charlie']):
    ties[title]=dict(id=title,title=title,author='Tie fixture',genre=['fantasy'],tropes=[],genre_accessibility='gateway' if i%2 else 'moderate')
for variant,items in [('forward',list(ties.items())),('reverse',list(ties.items())[::-1]),('rotated',list(ties.items())[3:]+list(ties.items())[:3])]:
    tie_catalog=dict(items)
    _,result=compare_case('tie/'+variant,tie_catalog,{}, {},check_slices=True)
    assert [r[1] for r in result]!=sorted(r[1] for r in result)
    trace_pair('tie/'+variant,tie_catalog,{}, {})

assert pickle.dumps(catalog)==catalog_before
assert stats['tie_groups']>0 and stats['cases_with_ties']>0
for key in ['already_rated','genre','discovery_only','series_position','user_rule','repeat','veto','trajectory','diversity','cold_start','rules']:
    assert coverage[key]>0,(key,coverage)
assert old_digest.hexdigest()==new_digest.hexdigest()
print('PASS coverage:',json.dumps(dict(coverage),sort_keys=True))
print('PASS counts:',json.dumps(dict(stats),sort_keys=True))
print('PASS assertions:',checks)
print('PASS complete result digest original:',old_digest.hexdigest())
print('PASS complete result digest migrated:',new_digest.hexdigest())
print('First real tie example:',json.dumps(first_tie_example,ensure_ascii=False))

# Wall-clock measurement without tracing, including full profile preparation,
# calibration/evidence overhead, sorting, and the entire output. No DB/network.
# Alternate order to reduce a simple warmup/order bias; three samples per side.
bench_ratings=dict(raters)['mathias'];bench_kw=dict(top_n=len(catalog),genre='fantasy',format_preference='audiobook')
old_times=[];new_times=[]
for i in range(3):
    for mod,bucket in ([(O,old_times),(N,new_times)] if i%2==0 else [(N,new_times),(O,old_times)]):
        output,warnings,elapsed=run(mod,catalog,bench_ratings,bench_kw);bucket.append(elapsed)
        if mod is O:bench_old=output
        else:bench_new=output
    eq(bench_old,bench_new,'timing complete output')
import statistics
print('TIMING full catalog candidates:',len(catalog),'returned:',len(bench_new))
print('TIMING original seconds:',old_times,'median:',statistics.median(old_times))
print('TIMING migrated seconds:',new_times,'median:',statistics.median(new_times))
print('TIMING median ratio:',statistics.median(new_times)/statistics.median(old_times))
print('PASS final: exact tuples, complete lists, warnings, all exclusion reasons, stage values, calibration once, stable ties, truncation, no input mutations')
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

## Complete proposed diff (`git diff -- scripts/recommend.py`)

```diff
diff --git a/scripts/recommend.py b/scripts/recommend.py
index 0427249..5cd9e32 100644
--- a/scripts/recommend.py
+++ b/scripts/recommend.py
@@ -3451,46 +3451,33 @@ def recommend(catalog, ratings, top_n=10, genre=None,
     series_dna = compute_series_dna(catalog)
     normalized_rules = normalize_user_rules(user_rules)
     field_prevalence, trope_prevalence = build_prevalence_lookup(catalog, genre)
+    # Calibration is base-only and shared by every candidate in this call.
+    # Ranking still returns only scores/contributions, not match labels.
+    poor_threshold = user_calibrated_poor_threshold(
+        catalog, id_to_magnitude, centroid, weights,
+        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence
+    )
 
     diversity = max(0.0, min(diversity, MAX_DIVERSITY))
     recent_books = [
         catalog[title_to_id[t]] for t in (recent_history or []) if t in title_to_id
     ]
 
-    excluded = set(id_to_magnitude.keys())
-    known_series = {
-        s for bid in excluded if (s := catalog[bid].get("series_id")) is not None
-    }
-    known_authors = {catalog[bid]["author"] for bid in excluded}
     scored = []
     for bid, book in catalog.items():
-        if bid in excluded or not matches_genre(bid):
-            continue
-        if discovery_only and (
-            book.get("series_id") in known_series or book["author"] in known_authors
-        ):
-            continue
-        if not series_position_ready(catalog, id_to_magnitude, book):
-            continue
-        relevance, contributions = score_book(book, centroid, weights, field_prevalence, trope_prevalence)
-        relevance = _apply_series_repeat(catalog, id_to_magnitude, book, relevance)
-        relevance = _apply_dealbreaker_veto(catalog, id_to_magnitude, validated_fields, book, centroid, weights, relevance,
-                                             field_prevalence, trope_prevalence)
-        relevance = _apply_series_trajectory_penalty(series_dna, book, centroid, weights, relevance,
-                                                      field_prevalence, trope_prevalence)
-        if diversity > 0 and recent_books:
-            novelty = 1 - max(book_similarity(book, h) for h in recent_books)
-            relevance = (1 - diversity) * relevance + diversity * novelty
-        if csw > 0:
-            demand = GENRE_ACCESSIBILITY_DEMAND.get(book.get("genre_accessibility"), 0.5)
-            accessibility = 1.0 - demand
-            final = (1 - csw) * relevance + csw * accessibility
-        else:
-            final = relevance
-        final, excluded_by_rule = apply_user_rules(book, final, normalized_rules)
-        if excluded_by_rule:
+        result = score_candidate(
+            catalog, bid, centroid, weights, id_to_magnitude,
+            policy="ranking", validated_fields=validated_fields,
+            series_dna=series_dna, field_prevalence=field_prevalence,
+            trope_prevalence=trope_prevalence, poor_threshold=poor_threshold,
+            cold_start=csw, matches_genre=matches_genre,
+            discovery_only=discovery_only, recent_books=recent_books,
+            diversity=diversity, normalized_rules=normalized_rules
+        )
+        if result["exclusions"] or result["excluded_by_user_rule"]:
             continue
-        scored.append((final, book["title"], book["author"], contributions))
+        scored.append((result["scores"]["final"], book["title"], book["author"],
+                       result["contributions"]))
 
     scored.sort(key=lambda x: -x[0])
     return scored[:top_n]
```

## Handoff and restoration

The proposed source was restored to exact HEAD bytes after the report and diff were saved. The patch extracted from THIS report passes `git apply --check` on the restored tree. Both embedded canonical outputs were independently checked against the captured files byte-for-byte. No commit, push, or hosted write occurred. The tracked working tree and index are clean; existing and required untracked reports are retained.

Exact restoration command:

```sh
python3 /private/tmp/codx-task5/restore.py > /private/tmp/codx-task5/restoration.txt
```

Restoration and report-integrity script:

```python
import hashlib, re, subprocess
from pathlib import Path
report=Path('docs/codx-reports/2026-09-16-a3-recommend-migration-proposal.md')
text=report.read_text()
patches=re.findall(r'^```diff\n(.*?)^```$',text,re.M|re.S)
assert len(patches)==1
patch=patches[0].encode()
assert patch==Path('/private/tmp/codx-task5/proposal.patch').read_bytes()
extracted=Path('/private/tmp/codx-task5/report-extracted.patch')
extracted.write_bytes(patch)
p=Path('scripts/recommend.py')
assert hashlib.sha256(p.read_bytes()).hexdigest()=='8fd0d6894a2d0fdd2a52ab84d28e37805c8369e1002539f46ccbdc09b5200fbc'
base=subprocess.check_output(['git','show','HEAD:scripts/recommend.py'])
assert base==Path('/private/tmp/codx-task5/original.py').read_bytes()
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
for heading,name in [('Canonical suite before (complete output, exit 0)','before.txt'),('Canonical suite after (complete output, exit 0)','after.txt')]:
    section=text.split('## '+heading+'\n\n```text\n',1)[1].split('```\n',1)[0].encode()
    assert section==Path('/private/tmp/codx-task5',name).read_bytes()
print('PASS: embedded patch and both embedded suite outputs verified byte-for-byte')
print('PASS: tracked working tree and index clean; existing untracked reports preserved')
```

Actual output (exit 0):

```text
Restored scripts/recommend.py SHA-256: 38fd015912a6e89f99130d6309104ccc65bbefd6f9bad073dc11456e8c752cf6
$ git diff --exit-code
exit: 0
$ git diff --cached --exit-code
exit: 0
$ git diff --check
exit: 0
$ git apply --check /private/tmp/codx-task5/report-extracted.patch
exit: 0
$ git status --short
exit: 0
?? docs/codx-recommend-review-2026-09-14.md
?? docs/codx-reports/
PASS: embedded patch and both embedded suite outputs verified byte-for-byte
PASS: tracked working tree and index clean; existing untracked reports preserved
```

This report is the durable proposal: the full diff, reproducible harness, exact outputs, cost observation, and restoration evidence are all included. CLDO can independently re-verify and apply A3. No unresolved scoring mismatch remains; explanation/evaluation migrations and label rollout are outside this task.
