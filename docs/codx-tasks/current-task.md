# CODX current task

**Assigned**: 2026-09-26, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` if you haven't read it yet. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 24 — audit the experimental/deferred scoring functions in `scripts/scoring/experimental.py`

This is your own established task type from `AGENTS.md`'s "Concrete
tasks" list ("Auditing the pile of deferred/experimental functions...
for whether they're still accurate or worth keeping") — not a new
authorization, and not something that needs the structural-change
review gate (this task IS a review, of code, not a proposal to change
a convention). Review/propose only, same posture as always: findings
and any proposed fix go in your report, nothing gets applied by you.

### What's actually there (confirmed 2026-09-26, so you don't have to
### re-derive this)

`scripts/scoring/experimental.py` is 834 lines, 9 functions, all
confirmed uncalled by any production code path (per Task 9/CLDO's own
prior confirmation, re-verify this still holds):

- `build_profile_trope_shrinkage()` / `build_profile_trope_backoff()`
  — alternative trope-weighting schemes.
- `_dedup_factor_for_field()` / `build_profile_series_field_dedup()` /
  `_dedup_factor_plain()` / `build_profile_series_field_dedup_protected()`
  — alternative series-dedup approaches (the "protected" variant sounds
  like it was meant to address a specific gap in the plain version —
  confirm what that gap was and whether it's the same one
  `docs/scoring-test-protocol.md`'s dedup entries already discuss).
- `build_profile_per_value()` / `score_book_per_value()` /
  `explain_book_per_value()` — an alternative per-value nominal-field
  weight-learning scheme, matched in the `docs/schema/book-dna-decisions.md`
  "Per-value nominal-field weight learning" entry (a real architectural
  idea logged there — check whether this file's implementation is what
  that entry describes, or a different/older attempt).

**Real reason this needs re-auditing now, not just "eventually"**:
these functions haven't been touched since the Phase B `scripts/scoring/`
submodule split (2026-09-17) — CLDO's own prior QA pass on them
(Tasks 9/10-era) predates that split, this session's redundancy/
prevalence-discount work, the confidence-instrumentation module
(`scripts/scoring/confidence.py`), and the fixture-test suite
(`scripts/scoring/tests/test_fixtures.py`, Tasks 18-19). An experimental
alternative that was a faithful variant of `build_profile()`/`score_book()`
on 2026-09-17 may now be silently out of sync with what the REAL
functions actually do today — worth confirming either way, not assumed.

### What to actually do

1. **For each function/pair, confirm it still imports/runs cleanly**
   against the current `scripts/scoring/` module layout — a stale
   import path or removed dependency would be a real, concrete finding
   on its own (this file predates and postdates several real refactors).
2. **Compare each experimental variant against the CURRENT real
   equivalent** (`build_profile()`/`score_book()`/`explain_book()` in
   `scripts/scoring/profile.py`/`pipeline.py`/`explanations.py`) —
   is the experimental version still doing the SAME thing as the real
   one, plus its one deliberate variation, or has it drifted (e.g. the
   real function gained a redundancy/prevalence discount or a
   confidence-floor check the experimental one never got, making it not
   a fair A/B variant anymore even if someone did test it today)?
3. **Check `docs/scoring-test-protocol.md`'s own history** for each of
   these — several were apparently tested once already (the file's
   dated entries should say what happened: landed, rejected, or
   inconclusive). Confirm the current code matches what the log says
   was actually tested, and flag any function whose fate isn't recorded
   there at all.
4. **Recommend, per function/pair**: keep as-is (still a live, correctly
   isolated experiment worth someone eventually re-testing), fix (drifted
   from the real pipeline in a way that would invalidate a future test —
   say exactly what changed), or remove (already tested and rejected,
   or superseded by something that actually landed, e.g. check whether
   `build_profile_per_value()` is now moot given whatever
   `docs/schema/book-dna-decisions.md`'s "Per-value nominal-field weight
   learning" entry's real status is).
5. **Confirm none of these 9 functions are actually called anywhere**
   in the real pipeline, tests, or app/API code — re-verify Task 9's
   old finding rather than trust it's still true after 9 days of changes
   (`grep -rn` for each function name across `scripts/`, `api/`, `app/`
   is enough; this file existing and being imported by nothing outside
   itself is exactly the kind of thing that's easy to get wrong by
   assumption).

### What NOT to do

Don't run `scripts/scoring_tests.py` against any of these (that's a
real benchmark run, CLDO's own exclusive territory per CLAUDE.md's
persona rules) and don't touch `scripts/recommend.py`. This is a static
code/documentation-consistency review, not a live A/B test — if you
find something worth actually testing, say so as a recommendation for
CLDO to run, not something to execute yourself.

### Deliverable

A report at `docs/codx-reports/<date>-experimental-functions-audit.md`:
per-function verdict (keep/fix/remove) with reasoning, confirmation of
the "uncalled anywhere" check, and any real drift found between an
experimental variant and its current real counterpart. CLDO reviews,
independently re-verifies, and applies whatever's agreed (likely a
mix of deleting some functions and leaving others, logged either way).
