# CODX current task

**Assigned**: 2026-09-25, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` if you haven't read it yet. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 19 — fixture-testing the mechanics Task 18 deliberately deferred

Task 18 (`scripts/scoring/tests/test_fixtures.py`, landed by CLDO
2026-09-25 after independent re-verification -- see
`docs/project-log.md`'s 2026-09-25 "CODX Task 18 landed" entry and
`docs/codx-reports/2026-09-25-scoring-fixture-tests.md`) covered
ordinal/nominal similarity, `build_profile()`'s learned-sign
correctness, the 4 `score_candidate()` policies' stage-sequence
agreement, and series-position gating. It explicitly deferred six
other real mechanics to this task. Same file, same conventions --
extend `scripts/scoring/tests/test_fixtures.py` (add new test methods
and new fixture books as needed) rather than starting a second file;
this is one coherent fixture-test suite, not two.

**Same ground rules as Task 18**: this is a NEW/extended test file only
-- do not modify `scripts/recommend.py` or `scripts/scoring_tests.py`
(CLDO-exclusive, per this project's persona rules). No DB access, no
network, stdlib `unittest` only, synthetic fixture data only. Read
`scripts/scoring/pipeline.py`'s real implementation for each mechanic
before writing an assertion -- assert against what the code actually
does, not a guess about what it "should" do (Task 18's own discipline).

### What to test in this slice

1. **Redundancy/prevalence discounts** -- `_redundancy_adjusted_weight()`
   and the `field_prevalence`/`trope_prevalence` discount in
   `_iter_book_factors()` (`w_eff *= max(PREVALENCE_DISCOUNT_FLOOR, 1 -
   prevalence)`). Build a fixture pair: two otherwise-identical
   candidates where one shares a value with a catalog-wide-common
   field (high prevalence) and one with a rare one (low prevalence) --
   confirm the common one's effective weight is discounted relative to
   the rare one's, given equal raw weight. Separately, confirm the
   redundancy discount actually reduces a correlated field's effective
   weight per `REDUNDANCY_DISCOUNTS` (`scripts/scoring/constants.py`)
   for a candidate where it applies, and does NOT discount an unrelated
   candidate lacking that correlation (this project's own real
   regression, documented in CLAUDE.md's recommendation-engine section:
   "a discount must be conditional on the specific book being scored,
   never a blanket adjustment").
2. **Series-repeat blending** -- `_apply_series_repeat()` /
   `series_repeat_worst_similarity()`. A synthetic series where the
   rater already liked/disliked an earlier installment: confirm the
   blended score moves the right direction and stays a no-op for a
   standalone with no series-mates in `id_to_magnitude`.
3. **Series-trajectory penalty** -- `_apply_series_trajectory_penalty()`
   / `_series_trajectory_penalty_factor()` / `compute_series_dna()`. A
   synthetic 2+ book series whose DNA shifts across installments in a
   way the rater's profile disfavors: confirm the penalty factor is
   `< 1.0` and moves score down; confirm a series with no meaningful
   shift is a no-op (factor `== 1.0`).
4. **Cold-start blending** -- `cold_start_weight()` (already partly
   exercised indirectly by `scripts/scoring/confidence.py`, landed by
   CLDO the same day -- read its docstring for the two components:
   count-based fade and `reader_experience_fraction()`) and its actual
   application inside `score_candidate()`'s `policy="ranking"`/`"audit"`
   branch (blends toward `1.0 - genre_accessibility_demand`). Confirm a
   fully-cold profile (`cold_start=1.0`) blends the score toward the
   accessibility-implied value regardless of the base score, and
   `cold_start=0.0` is a byte-identical no-op.
5. **User-rules filtering** -- `apply_user_rules()`/
   `normalize_user_rules()` (`scripts/scoring/rules.py`). A synthetic
   "none of X" rule that matches vs. doesn't match a candidate: confirm
   exclusion + the `user_rule` exclusion label fires correctly, and a
   "less of X" rule applies its multiplicative discount without fully
   excluding. Task 18's own Scenario 13 in `scripts/scoring_tests.py`
   is the real-data analog to read for the expected shape -- don't
   copy it, this is a from-scratch synthetic-fixture version.
6. **Explanation-text generation** -- `explain_book()`/`describe()`/
   `natural_sentence()`/`dealbreaker_sentence()`
   (`scripts/scoring/explanations.py`). Confirm a known match/mismatch
   pair produces a real, non-empty, correctly-signed phrase (matches
   read as positive, mismatches as negative) -- not exact string
   matching against English wording (too brittle), but structural
   assertions (which list a given label lands in, correct sign/
   direction).
7. **Dealbreaker/veto firing** -- `_apply_dealbreaker_veto()` and
   `dealbreaker_flags()`. A synthetic dealbreaker-magnitude mismatch:
   confirm the veto actually suppresses the score when triggered, and
   confirm the two documented modes (validated_fields non-empty vs.
   empty -- see `dealbreaker_flags()`'s own docstring for the fixed-
   threshold fallback vs. validated-set-only behavior) each produce the
   behavior their own docstrings describe.

### Validation bar (same as Task 18)

- Actually run every new assertion locally against current
  `scripts/scoring/` and confirm it passes before reporting.
- Deliberately break at least 2 of the 7 mechanics above (a throwaway
  copy, never the real file) and confirm the corresponding new test(s)
  actually fail -- prove each check can fail, not just that it can pass.
- Confirm the whole extended file still runs in well under a second.

### Deliverable

The extended `scripts/scoring/tests/test_fixtures.py`, plus a report at
`docs/codx-reports/<date>-scoring-fixture-tests-2.md` with what each
new test asserts and why, and the pass/fail evidence for both the clean
run and at least 2 deliberately-broken runs. No `.github/workflows/
ci.yml` edit needed -- the existing 4th CI check
(`python3 -S scripts/scoring/tests/test_fixtures.py`) already runs the
whole file, extended or not.
