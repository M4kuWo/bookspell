# Task 19 — deferred scoring mechanics fixture tests

CODX, 2026-09-25. Synced to `b45f01f`. Extended `scripts/scoring/tests/test_fixtures.py` from six to **15 passing test methods**. Standard-library-only, synthetic inputs, no DB or network access for the tests. No production engine or CI workflow changes, commits, or pushes.

Sync preserved the overlapping Task 18 local files and log append under `/private/tmp/codx-task18-before-sync/` before fast-forwarding; Task 18's test/report/evidence and CI wiring are now tracked upstream. Read the fresh assignment, log, changed backlog, confidence instrumentation docstring, actual scoring implementations, and Scenario 13's rule examples. CLAUDE/schema conventions were already read in the immediately preceding task and are unchanged. No tagging skill or scoring-design change applies.

## New coverage

The original six tests remain. Nine additional methods cover the assignment's seven mechanics; most reuse the original factory, with explicit per-test records or field overrides to isolate the new behavior. Fixtures are fresh for each test, so mutations of fixture dictionaries cannot leak between tests. The candidate helper now accepts explicit keyword overrides for nonzero pipeline settings.

| New test | What it proves |
|---|---|
| `test_prevalence_discounts_field_and_trope_weights_with_floor` | Otherwise-identical pace candidates with prevalences .8 and .1 keep equal raw weight but effective weights .2 and .9. Separately exercises both scalar and trope prevalence paths, including prevalence 1.0 stopping at the configured floor rather than zero. |
| `test_redundancy_discount_is_candidate_conditional` | Both configured redundancy relationships reduce the dependent field only when that candidate has the triggering value. Tests both `_redundancy_adjusted_weight()` and its application in `_iter_book_factors()`; an unrelated field stays unchanged. Explicit confidence 1 isolates redundancy from confidence discounting. |
| `test_series_repeat_penalizes_disliked_not_liked_mates` | Identical series-mates with a shared trope have similarity 1; a disliked predecessor blends .8 down to `(1-SERIES_REPEAT_WEIGHT)*.8`. Liked-only history, empty history, and a standalone candidate are no-ops. There is no assumed liked-series bonus. |
| `test_trajectory_penalizes_divergent_entry_only` | `compute_series_dna()` orders a deliberately reversed two-book input and detects a slow-to-fast shift. A slow-preferring profile receives a factor below 1 and a lower score for a requires-series entry. A stable series, later installment, and self-contained entry remain unpenalized. The wrapper's output agrees with the computed multiplier. |
| `test_cold_start_count_and_experience_components` | Empty history is fully cold; one gateway rating gives 11/12, 12 independent gateway ratings give zero. A nonnegative veteran-only rating establishes full experience; a disliked one does not. Three rated installments still count as one series cluster. |
| `test_cold_start_applies_only_to_ranking_and_audit` | With base scores 0 and 1, fully cold ranking/audit both end at .75 for an accessible candidate. Half-cold values interpolate; zero is bit-identical to base via float hex comparison. Explanation/evaluation ignore cold-start blending even when passed a nonzero value. |
| `test_user_rules_exclude_reduce_and_leave_nonmatches_unchanged` | Both field-value and trope targets normalize and match correctly. Exclude retains the score but marks exclusion; reduce strength .25 multiplies a nonzero score by .75 without excluding. Nonmatches remain unchanged. Real candidate calls check `user_rule`, exclusion boolean, and `Excluded by user rule` label for ranking/audit, and verify explanation/evaluation ignore these rules. |
| `test_explanations_preserve_match_and_mismatch_direction` | Positive found-family weight appears only in matches, negative revenge weight only in mismatches. Both lists correctly contain positive magnitudes—the list, not the numeric sign, carries direction. `describe()` returns real phrases, sentences contain those phrases, polarity changes rendering, and the dealbreaker warning is distinct. Empty input yields empty text. No exact English sentence is frozen. |
| `test_dealbreaker_modes_and_veto` | With mismatch magnitudes .2 and .4, empty validation uses the .3 fallback and flags only the larger mismatch. Nonempty validation uses the .15 threshold and excludes unvalidated fields even when larger. The veto caps a high score for a validated flag, never raises an already-low score, and remains a no-op for empty validation or no validated mismatch. |

These are engine-contract checks, not a test of recommendation quality. Constants specifying discount/cap magnitudes are consulted where appropriate; directional and no-op assertions independently guard against inert or overbroad behavior. This does not cover every combination, threshold boundary, phrase template, or rule normalization error.

## Validation

Commands run:

```sh
python3.12 -S scripts/scoring/tests/test_fixtures.py
python3.12 docs/codx-reports/2026-09-25-scoring-fixture-evidence-2/validate.py
git diff --check
```

The initial direct run surfaced a fixture assumption: `book_similarity()` assigns two empty trope sets Jaccard similarity 0, so identical scalar records alone score 2/3, not 1. The series-repeat fixture was corrected to supply the same nonempty trope set to both records, as its intended identical-component case requires. No engine code was changed to satisfy the test. The corrected direct run passes all 15 methods in 0.003 seconds.

Final evidence-run results (Python 3.12.9, with `-S` disabling site-package initialization):

| Run | Exit | Full subprocess wall time | Result |
|---|---:|---:|---|
| Clean real checkout | 0 | 0.061416 s | All 15 methods pass |
| Throwaway copy: prevalence disabled | 1 | 0.063720 s | Prevalence test fails: effective weight 1 instead of .2 |
| Separate throwaway copy: cold-start blending disabled | 1 | 0.065235 s | Cold-start application test fails for ranking/audit: base retained instead of .75 |

These timings include interpreter startup and imports, comfortably below one second locally. CI's hosted runner timing has not been measured.

The first mutation replaces **both** occurrences of `w_eff *= max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence)` with `w_eff *= 1.0`. The second replaces `if policy in ("ranking", "audit") and cold_start > 0:` with `if False:`. Each mutation starts from a separate fresh copy, so failures cannot be attributed to the other mutation. Both produce assertion failures in the corresponding new method, not import errors. No assertion is monkeypatched.

The evidence runner copies only `scripts/scoring/`, excludes cached bytecode, and invokes the copied test in a separate process. The test's path-relative import resolves the copied engine. Temporary copies are cleaned up automatically; SHA-256 comparisons verify the actual engine and test files did not change during validation. This meets the required two-mechanic negative-control bar; mutation sensitivity was not tested for every other mechanic.

Full reproducible evidence is in `docs/codx-reports/2026-09-25-scoring-fixture-evidence-2/`: `validate.py`, `clean.txt`, `prevalence.txt`, `cold-start.txt`, the two mutation `.diff` files, and `validation.json`. `git diff --check` passes.

## Handoff

The existing fourth CI step already runs the extended suite:

```sh
python3 -S scripts/scoring/tests/test_fixtures.py
```

No CI edit or dependency installation is needed. Production code, `scripts/recommend.py`, and `scripts/scoring_tests.py` remain unchanged. The implementation diff is only the existing fixture-test file; the report/evidence and append-only log entry document the proposal for CLDO's independent review.
