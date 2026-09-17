# CODX current task

**Assigned**: 2026-09-17, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` for how this file works if you haven't
read it yet — short version: this is your one current assignment,
refreshed by CLDO after each task lands. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

**Note on scope for this task specifically**: the repo owner asked to
be deliberate about token usage right now, so this task is scoped to
be bounded and mechanical rather than open-ended research. Take the
planning below as real prep work already done for you (a proposed
module map and the exact required re-export surface, both computed by
grepping the actual consumers, not guessed) — you shouldn't need heavy
web research for this one, just careful reading of `scripts/recommend.py`
itself and rigorous verification.

---

## Task 11 — Phase B, step 1: split `scripts/recommend.py` into `scripts/scoring/` submodules

`main` is at commit `c706262`. This is Phase B of the `recommend.py`
refactor plan in `docs/TODO.md` — **pure code movement, zero logic
changes**, only possible now that Phase A (A1-A5 plus the
`audit_book_score()` follow-up) landed every scoring caller onto one
canonical `score_candidate()`. Read that section of `docs/TODO.md` and
`docs/scoring-test-protocol.md`'s Phase A entries for context if you
haven't already worked on this codebase before.

The confidence QA pass (Tasks 9-10) is deliberately paused, not
abandoned — see `docs/TODO.md`. This is the next real task instead.

## The hard constraint, stated up front

**`api/main.py` and `scripts/scoring_tests.py` — the only 2 real
consumers of this module — must need ZERO changes when you're done.**
Both do `import recommend as R` and then reach for names on `R.`. Every
one of the following MUST still resolve exactly as it does today,
whether that means the name still lives in `scripts/recommend.py`
directly or `scripts/recommend.py` re-exports it from wherever it
actually moved to:

```
R.recommend, R.explain_match, R.explain_book, R.score_candidate,
R.load_catalog, R.build_profile, R._resolve_profile,
R.compute_series_dna, R.book_similarity,
R.validated_dealbreaker_fields, R.dealbreaker_flags,
R.apply_user_rules, R.normalize_user_rules, R.parse_user_rule_key,
R.list_user_rule_targets, R.describe, R.match_label,
R.user_calibrated_poor_threshold, R.build_prevalence_lookup,
R._nominal_field_separation, R._trope_separation,
R._audit_attribute_ordinal, R._series_trajectory_penalty_factor,
R.DATABASE_URL, R.RATING_LABELS, R.NOMINAL_FIELDS, R.ORDINAL_FIELDS,
R.STAT_SEPARATION_THRESHOLD, R.DEFAULT_REDUCE_STRENGTH
```

This list was computed by grepping every `R.\w+` access in both files
directly (not guessed as "the public API") — treat it as authoritative
and re-derive it yourself as a check, don't just trust it blindly
either. If your own grep finds anything this list missed, that's a
real gap — fix the shim, don't just note it.

## Proposed module map (a starting point, not a mandate)

`docs/TODO.md`'s original Phase B sketch named 8 files
(`prevalence.py`, `dealbreakers.py`, `series.py`, `cold_start.py`,
`tropes.py`, `calibration.py`, `explanations.py`, `pipeline.py`) before
anyone had actually mapped every function to one. Having now read the
real function list, that undercounts what's actually there (no content
naturally fits `tropes.py`; several groups — user rules, post-read
feedback, the audit tool, profile-building, the dormant experimental
builders — weren't anticipated). Adjust file boundaries to match the
real code; document your final mapping and reasoning in the report.

A concrete starting proposal:

- `pipeline.py` — the actual scoring core, kept together on purpose:
  `_redundancy_adjusted_weight`, `_iter_book_factors`, `score_book`,
  `explain_book`, `_ordinal_field_separation`,
  `_nominal_field_separation`, `_trope_separation`,
  `field_or_trope_separation`, `validated_dealbreaker_fields`,
  `dealbreaker_flags`, `_apply_series_repeat`,
  `_series_trajectory_penalty_factor`, `_apply_series_trajectory_penalty`,
  `_apply_dealbreaker_veto`, `_apply_dealbreaker_veto_graduated`,
  `score_candidate`.

  **Read this reasoning, then verify it yourself against the real call
  graph — don't just accept it**: `score_candidate()` calls
  `dealbreaker_flags()` and the `_apply_*` stage functions directly;
  `_apply_dealbreaker_veto()`/`_apply_series_trajectory_penalty()` call
  `explain_book()` directly; `dealbreaker_flags()`/`validated_dealbreaker_fields()`
  likely go through `_iter_book_factors()` too. Splitting these across
  separate files (e.g. a standalone `dealbreakers.py`) creates a real
  circular import — `pipeline.py` would need `dealbreakers.py` for the
  veto function, and `dealbreakers.py` would need `pipeline.py` for the
  evaluator. That's why this proposal keeps them together. **If you find
  a genuine circular-import requirement anywhere else, that's a signal
  those functions are more tightly coupled than this proposal assumed —
  consolidate them into one file rather than fighting the cycle with
  local/deferred imports.** Report your actual final boundaries and why.

- `series.py` — pure series-data functions with no coupling to the
  scoring internals above: `compute_series_dna`,
  `describe_series_trajectory`, `series_dnf_outlook`, `book_similarity`,
  `series_repeat_worst_similarity`, `series_position_ready`,
  `_series_deduped`, `_series_deduped_id_to_magnitude`.
- `cold_start.py` — `reader_experience_fraction`, `cold_start_weight`.
- `calibration.py` — `get_confidence`, `scoring_confidence`,
  `user_calibrated_poor_threshold`, `match_label`.
- `explanations.py` — `phrase_field`, `phrase_trope`, `describe`,
  `_join_list`, `natural_sentence`, `dealbreaker_sentence`.
- `prevalence.py` — `build_prevalence_lookup`,
  `build_prevalence_lookup_grouped`.
- `profile.py` — `_split_by_sign`, `_n_independent_clusters`,
  `build_profile`, `_resolve_profile`.
- `rules.py` — `parse_user_rule_key`, `normalize_user_rules`,
  `_matches_rule_target`, `apply_user_rules`, `list_user_rule_targets`.
- `feedback.py` — `book_feedback_options`, `feedback_to_fatigue_overrides`,
  `log_feedback`.
- `audit.py` — `_audit_attribute_nominal_or_trope`,
  `_audit_attribute_ordinal`, `audit_book_score`, `print_score_audit`.
- `experimental.py` — every dormant/unlanded builder, moved verbatim,
  zero logic changes, not audited or evaluated as part of this task:
  `build_profile_trope_shrinkage`, `build_profile_trope_backoff`,
  `_dedup_factor_for_field`, `build_profile_series_field_dedup`,
  `_dedup_factor_plain`, `build_profile_series_field_dedup_protected`,
  `build_profile_per_value`, `score_book_per_value`,
  `explain_book_per_value`. (A separate, later task may audit whether
  these are worth keeping — not this one. Moving them, unchanged, keeps
  `scripts/recommend.py` genuinely thin without deciding their fate.)
- `catalog.py` — `load_catalog`.
- `api.py` — `recommend`, `explain_match` — the top-level public
  orchestrators.
- `scripts/recommend.py` becomes the thin shim: imports everything in
  the required-re-export list above from its new home and re-exports
  it, plus the module-level constants (`DATABASE_URL`,
  `RATING_LABELS`, `NOMINAL_FIELDS`, `ORDINAL_FIELDS`,
  `STAT_SEPARATION_THRESHOLD`, `DEFAULT_REDUCE_STRENGTH`, and any
  others a fresh grep finds — `HIGH_RISK_FIELDS`,
  `DEFAULT_POOR_THRESHOLD`, `MAX_DIVERSITY`, and others like it stay
  wherever makes sense, re-exported only if something outside this
  module actually needs them — check `app/`, `tools/`, and any other
  script that might import `recommend`, not just the 2 known
  consumers).

## Validation bar

Since this is pure movement, the validation is about proving nothing
changed, not about behavior:

1. **AST-diff every moved function**: its body must be byte-identical
   before and after — only which file it lives in, and its new file's
   import statements, may differ. Confirm this individually per
   function, not just "the module still imports."
2. **Full canonical suite (`scripts/scoring_tests.py`) byte-identical
   before/after** — this is now genuinely comprehensive evidence, since
   the whole point is that the suite's own import path must keep
   working unchanged.
3. **Exercise `api/main.py`'s actual import and at least one real call
   path** (e.g. `R.recommend(...)`, `R.explain_match(...)`) directly,
   not just confirm the module imports without error — an import
   succeeding doesn't prove every name the app actually calls still
   resolves correctly.
4. **No circular imports**: `python3 -c "import recommend"` and
   `python3 -c "import scripts.scoring.pipeline"` (etc., for every new
   file) must all succeed cleanly from a fresh interpreter.
5. Confirm `git mv` was used where the tooling allows it (preserves
   file history for moved code), falling back to a plain move if a
   file's contents get split across multiple new destinations.

## Deliverable

A report at `docs/codx-reports/2026-09-17-phase-b-module-split.md` (or
same-day-dated equivalent): your final module map and why it differs
from the proposal above (if it does), the complete diff or a
description of every file added/changed, the AST-diff verification
output, the before/after canonical suite output and hashes, and the
real-consumer exercise output. Proposal only — implement and validate
in your own clone, uncommitted; revert to exact HEAD bytes and
hash-verify afterward; no commit, push, or hosted write (this task
touches no data, so the hosted-write question doesn't really arise,
but the no-commit/push rule still applies as always).
