# Task 24 — experimental scoring functions audit

Date: 2026-09-26. Reviewed synced commit `d5bbb32` (fast-forward from
`cdb6c55`). Review/proposal only: no tracked code changes, commits, pushes,
hosted access, real rater data, or benchmark runs. In particular,
`scripts/scoring_tests.py` was read, never executed or imported.

## Result

All nine functions import and run with the current module layout on empty
and populated synthetic inputs. There are **no external executable callers
or imports** in the checked production/test/app/tool sources. Two helpers
do have internal callers in this dormant module; “none called anywhere”
would therefore be too broad.

None of the five profile builders is currently a clean drop-in alternative
to production. All lack format gating and the current calling convention.
The per-value family has additional confidence, prevalence, and integration
drift. These are dormant-experiment maintenance issues, not live scoring
bugs. Much of the drift predates the September 17 split.

Recommendation: **fix two retained deferred experiments; remove seven
functions belonging to tested unsuccessful implementations**, preserving
their rationale and results in the protocol/git history. These are
recommendations for CLDO, not changes applied here. Removing an implementation
does not establish that its underlying research question is solved or invalid.

## Per-function verdicts

Line references below are in `scripts/scoring/experimental.py` at the reviewed commit.

| Function | Verdict | Reason and comparison with current equivalent |
|---|---|---|
| `build_profile_trope_shrinkage` (50) | **Fix** | Retain as the explicitly deferred trope sample-size experiment. Its intended difference is the raw trope-weight multiplier `n/(n+k)` before the cap. Scalar learning still uses current confidence flooring and nominal zero-weight filtering, but format gating/signature drift prevents an isolated comparison. Fix those and update “UNDER TEST” status to deferred with a protocol link. |
| `build_profile_trope_backoff` (154) | **Fix** | Retain as the unresolved cross-genre pooling experiment, not a validated replacement. It blends scoped and full-history trope frequencies using scoped support; scalar learning is confidence-aware. Same format/interface repair needed. Historical sign-flip/independence concerns remain research questions, not authorization to redesign `n` here. |
| `_dedup_factor_for_field` (293) | **Remove with its two consumers** | Correctly returns per-book divisors by `(series, field value)` rather than production's series-only grouping. Empty and populated calls work. No independent defect found; removing the rejected builder family makes this helper unused. Keep it if CLDO instead retains that family as a research control. |
| `build_profile_series_field_dedup` (354) | **Remove** | This is the same field-conditional dedup mechanism whose real regressions were investigated in the protocol. Scalar fields group by series AND value; tropes retain plain series dedup. Not superseded by a successful implementation, but already an unsuccessful tested version. It also lacks format support. |
| `_dedup_factor_plain` (463) | **Remove with protected builder** | Correctly supplies production-style series-only divisors as the protected builder's fallback. No independent bug found; it has no consumer outside that builder. |
| `build_profile_series_field_dedup_protected` (499) | **Remove** | Implements exactly the documented attempted fix: use plain dedup on validated dealbreaker fields, conditional dedup otherwise. The historical failing field did not validate, so protection never activated and results were identical to the unprotected experiment. This is NOT the separately suggested, unbuilt minority-subgroup protection idea. Also lacks format support. |
| `build_profile_per_value` (635) | **Remove** | Same per-value nominal architecture discussed in the schema, actually built and reverted in the protocol; not a new/superseding attempt. Training ignores metadata confidence on ordinal, nominal, and trope evidence, and lacks format gating. Dictionary nominal weights deliberately differ from production's scalar/mode contract. |
| `score_book_per_value` (729) | **Remove with builder** | Runs with the experimental profile shape, but uses raw confidence instead of the floor, has no prevalence inputs/discount, and has stale contribution selection/tie ordering. Conditional redundancy discounts ARE present. It cannot replace the current five-argument scorer directly. |
| `explain_book_per_value` (788) | **Remove with builder** | Runs with experimental weights and intentionally buckets nominal evidence by sign. Same raw-confidence and missing-prevalence drift; no alphabetical tie-breaker. Cannot accept current explanation keywords or describe production's shared factors faithfully. |

If CLDO wants historical executable controls instead of deletion, label these
seven explicitly archival and non-comparable until repaired. Their existence
alone is not a reason to undertake new benchmark/design work. No function's
family lacks historical coverage; the two private helpers are documented as
parts of their experiments rather than separate hypotheses.

## Concrete drift and proposed repairs

### 1. All five profile builders lack format gating and current interface

Production `profile.py:111–145` accepts `format_preference` and excludes
`audiobook_length` for print/default, excludes `book_length` for audiobook,
and retains both for mixed. Each experimental builder always processes both.
A two-book synthetic input yields both length keys in every experimental
centroid versus only `book_length` in production's default centroid.

This is also a call failure, not just a difference in learned fields:
`profile.py:356` passes four positional arguments. The dedup and per-value
builders reject the fourth. Shrinkage/backoff bind it to **`k`**, then fail
when the populated trope calculation adds an integer to `'print'`. The
default fourth argument `None` is also not a valid pseudo-count. All five
reject the `format_preference` keyword outright.

For the two retained builders, mirror production's format exclusions and
provide an adapter-compatible signature. A concrete candidate is
`(catalog, ratings, full_ratings=None, format_preference=None, *, k=...)`.
Making `k` keyword-only changes the old experimental positional API, so any
future harness must deliberately update its call, not silently reinterpret
an old fourth positional pseudo-count. Current tracked sources have no such
external callers. Add bounded checks for default/print/audiobook/mixed and
keyword pseudo-count use if CLDO applies this repair.

The first four builders retain `scoring_confidence()` across scalar/trope
learning and the September 14 nominal zero-weight filtering fix. All eight
synthetic liked-zeroed/disliked-zeroed cases passed: no liked evidence means
no nominal centroid; only disliked evidence zeroed gives fallback weight
0.3. There is no recurrence of that earlier division-by-zero bug.

### 2. Per-value training and candidate confidence are stale

Production learns using `m * scoring_confidence(...)`. Per-value ordinal
means and nominal/trope frequencies instead use raw rating magnitudes.
This loses both confidence weighting above the threshold and exclusion
below it. Its scorer/explainer use `get_confidence()` rather than
`scoring_confidence()`, so confidence 0.2 still affects candidates despite
the current 0.3 floor.

Synthetic evidence: a liked book whose pace/person/revenge confidence is
0.2 contributes none of those scalar fields and a zero revenge weight in
production; per-value learns pace weight 0.3, person/first weight 0.5, and
revenge weight 0.5. A candidate with pace confidence 0.2, centroid 1 and
an isolated weight 1 scores **0.0** in production versus **1.0** in the
per-value scorer; only the latter emits a pace match of 0.2. The weight-1
case is a synthetic isolation check, not a claim about learned caps or real
ranking quality. Production's contribution list still includes a zero-valued
pace entry due to its raw-weight display gate; the saved output shows this.

These are maintenance differences separate from the intended per-value
nominal representation. Repair, if retained, would require carrying the
existing confidence policy through every training and candidate loop.

### 3. Per-value scoring is not integrated with today's factor pipeline

Current `pipeline.py:103–267` shares `_iter_book_factors()` between score and
explanation, applying conditional redundancy, confidence floor and optional
field/trope prevalence discounts. Per-value score/explain duplicate the
loops, do apply conditional redundancy, but have neither prevalence inputs
nor the discount math. Both reject `field_prevalence` in the smoke check.

Current `score_candidate()` (`pipeline.py:753–798`) calls the scorer with
five arguments, calls the explainer with prevalence keywords, and separately
builds the factors list. Merely swapping three per-value entry points would
not repair that factors path: production expects scalar nominal weights,
whereas per-value supplies dictionaries. The current `_resolve_profile()`
fatigue override also assigns a scalar to a field (`profile.py:358–365`),
which per-value nominal scoring skips because it requires a dictionary.
Any future investigation needs an explicit integration review, not the old
bottom-of-file alias trick described by the stale docstrings.

Additional presentation differences: per-value scalar contribution display
tests `abs(contribution) > 0.15`; production tests raw scalar weight `> 0.15`.
Per-value contribution/explanation sorting has only a magnitude key; current
production adds alphabetical tie-breakers. These affect diagnostic output,
not necessarily score values. Dictionary nominal weights, negative
per-value preferences, no mode fallback for unseen values, and lack of
nominal partial-similarity scoring are deliberate features of the experiment,
not independent newly discovered bugs.

The new `confidence.py` instrumentation is explicitly **display-only**
(module preamble) and runs downstream of canonical factors through
`scoring/api.py`. Its absence inside experimental builders is not a missing
scoring multiplier and must not be “fixed” by changing ranking policy.
Also, the current numeric `explain_book()` lives in `pipeline.py`;
`explanations.py` contains presentation helpers.

## Historical reconciliation

References are to `docs/scoring-test-protocol.md` unless stated otherwise.

* **Shrinkage**, table at line 119, September 6: mixed results across four
  raters, with Mathias sparse hated rejection regressing at every tested
  `k` from 1 through 12. Explicitly deferred, not universally disproven.
  Current raw distinct-book support and pre-cap shrinkage match the described
  mechanism; series-deduped magnitudes do not turn its raw book count into
  an independent-cluster count.
* **Backoff**, lines 2074–2112 and 2187–2212, September 6: no aggregate
  held-out movement, negligible effect on the motivating fantasy example,
  but a sci-fi revenge sign flip. Follow-up explained pooling arithmetic
  and left transfer across genres unresolved. Current code implements that
  same scoped/full blend, including the concern that raw count does not
  measure independence. No landed resolution was found.
* **Conditional dedup**, lines 2337–2407: real regressions traced to
  minority evidence diluted by expanded majority evidence. The protective
  variant at 2408–2446, September 7, tested validated-field fallback and
  was identical on the failing data because the relevant field's separation
  was below the validation threshold. Current code matches that protection
  rule. This historical observation does not imply protection can never
  activate on other data. The distinct minority-protection suggestion was
  not implemented by this function.
* **Per-value**, lines 1456–1599, September 4: the initial “safe” result
  was invalidated by monkeypatching the wrong imported module. The real
  run regressed and was reverted (including Mathias bucket 91% to 73% and
  Dandan 71% to 29%, as recorded then). These are historical figures,
  not measurements taken in this audit. Current code has the same defining
  `liked_freq - disliked_freq` nominal dictionaries. No later successful
  replacement makes the idea moot.

There are two contradictory status descriptions to repair alongside any
disposition:

1. `docs/schema/book-dna-decisions.md:398–422` says the per-value idea was
   “not built”/“not attempted yet.” It describes this same implementation's
   architecture and predates its actual experiment. Proposed replacement
   status: **“Built and tested 2026-09-04; reverted after the corrected
   benchmark regressed. The architectural limitation remains unresolved;
   see the protocol's ‘tried for real, REVERTED’ entry.”**
2. All three per-value docstrings falsely say **LANDED** and refer to
   assignments at the bottom of this module which do not exist. Delete
   with the functions, or mark reverted/archival if retained. Similarly,
   replace the older “UNDER TEST” comments with the recorded outcomes.

Drift timeline is supported directly by the history: confidence learning
and flooring landed September 5 (1872–1940 explicitly leaves per-value
untouched); prevalence landed September 6 (2263); format gating September
7 (2520); four experimental nominal guards fixed September 14 (2683);
production tie-breakers September 15 (2744 explicitly leaves the dormant
per-value scorer untouched); shared factors/canonical orchestrator September
16 (2792 onward). `git log -- scripts/scoring/experimental.py` shows only
its Phase B creation commit `d9a0c6a`. The split did not introduce a stale
import, and this review does not attribute these older differences to the
new confidence instrumentation or fixture suite.

## Verification and reproducibility

Evidence directory:
`docs/codx-reports/2026-09-26-experimental-functions-audit-evidence/`.
`smoke.py` is an uncommitted audit artifact, not a production test addition.
`output.txt` preserves its complete real output. It reads no `.env`, opens
no network/DB connection, and uses only its two inline synthetic books.

Executed:

```sh
python3 -B docs/codx-reports/2026-09-26-experimental-functions-audit-evidence/smoke.py > docs/codx-reports/2026-09-26-experimental-functions-audit-evidence/output.txt
```

Exit 0; output ends:

```text
External executable references: []
Experimental module/named imports: []
PASS: nine functions run; contract drift reproduced; external dormancy confirmed statically
```

The script enumerates tracked Python files under `scripts`, `api`, `app`,
and `tools`, checks AST name/attribute references and imports, and reports
the 12 internal helper references separately. It checks all nine functions
on empty/populated inputs, current profile/prevalence calling contracts,
format drift, the eight prior nominal-guard cases, and confidence examples.
This is bounded smoke verification authorized by task point 1, not a
benchmark or recommendation-quality A/B test.

Also executed the textual cross-language check:

```sh
rg -n 'build_profile_trope_shrinkage|build_profile_trope_backoff|_dedup_factor_for_field|build_profile_series_field_dedup|_dedup_factor_plain|build_profile_per_value|score_book_per_value|explain_book_per_value|scoring\.experimental|from \.experimental' scripts api app tools --glob '!experimental.py'
```

Only hits: the seven public entry-point **strings** in the existing dormancy
guard at `scripts/scoring_tests.py:1262–1264`, and two comments in
`scripts/scoring/constants.py:164,435`. No actual fixture/API/app calls.
Static absence is not proof against an arbitrary externally supplied
dynamic import, but there is no such caller in the inspected source.

Other review work used `sed`/`rg` to read the complete experimental module,
production profile and relevant pipeline/calibration/constants code,
the assignment, relevant protocol history, schema decision entry, diagnostic
module preamble and test dormancy guard. `git diff --stat` returned no tracked
changes. Existing untracked reports were preserved. The initial sandboxed
pull failed to write `.git/FETCH_HEAD`; the approved escalated
`git pull --ff-only` completed the fast-forward stated above.

No benchmark, fixture-suite run or live-data validation is claimed. CLDO
can independently review this report, choose the maintenance disposition,
and apply any agreed code/documentation changes through the normal process.
