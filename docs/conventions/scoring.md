# Recommendation engine (`scripts/recommend.py`)

*Moved verbatim from `CLAUDE.md` on 2026-09-28 (CODX Task 25, lever A), so it is read
only when a task needs it instead of being auto-loaded into every session. It is
required reading, in full, whenever `CLAUDE.md`'s "Startup reading and task routes"
table routes you here. Where this text says "this file", "CLAUDE.md" or points
"above"/"below" outside this section, read it as referring to the whole
convention set (`CLAUDE.md` plus `docs/conventions/`).*


- **Read `docs/scoring-test-protocol.md` before changing any scoring
  logic** (`build_profile`, `score_book`, `explain_book`, or anything
  that computes a weight). It has a running table of every idea tried
  so far — landed, rejected, and deferred — and why. Several ideas that
  looked like clear wins under an incomplete test turned out not to be;
  don't re-litigate a rejected idea, or claim a win, without checking
  that table first. **Answer its "Before proposing any scoring change:
  the 10-question gate" section before writing any code** — a real,
  binding pre-check (adopted 2026-09-24), not optional framing.
- **Every scoring change must be checked against at least two failure
  scenarios before landing**, not just the one that motivated it: a
  fix that helps a real signal from getting diluted by many unrelated
  agreeing fields has repeatedly turned out to reopen a different,
  previously-fixed bug where one field dominates everything else
  (or vice versa). `scripts/scoring_tests.py` has both scenarios ready
  to run.
- **A discount/adjustment must be conditional on the specific book
  being scored, never a blanket adjustment applied regardless of
  context.** A real bug shipped briefly because of this: a redundancy
  discount between two correlated fields was applied as a flat
  per-profile weight reduction, which wrongly discounted a field for
  candidate books where the correlation didn't actually apply. Fixed by
  moving the discount into `score_book()`/`explain_book()`, applied
  per-book. See `REDUNDANCY_DISCOUNTS` for the pattern.
- **Rater data lives in `data/ratings/{name}.json`**, not hardcoded in
  test scripts — there's no real user/account system yet, so this is
  the durable stand-in. See `data/ratings/README.md` for the current
  roster. Add a new person's file there, then a new scenario in
  `scripts/scoring_tests.py`, rather than replacing existing data.
- **A/B testing an experimental scoring variant via monkeypatch must
  verify the patch lands on the SAME module object
  `scripts/scoring_tests.py` actually calls — don't just trust that the
  before/after numbers look different (or the same).** Real,
  already-happened example: an experimental variant was A/B tested by
  doing `import scripts.recommend as R; R.build_profile =
  R.build_profile_per_value` and rerunning the suite, which reported
  "byte-identical, zero regressions" — but `scripts/scoring_tests.py`
  internally does `sys.path.insert(...); import recommend as R`, a
  SEPARATE import of the same file under a different `sys.modules` key,
  hence a genuinely different module object with its own independent
  copy of every name. The monkeypatch silently never touched the module
  the benchmark actually calls (`scripts.recommend is not
  (path-inserted) recommend`), so the "safe" finding was measuring
  unmodified scoring against itself. Once actually landed (by editing
  the real file's own module-level names, which both import paths
  execute), the true benchmark showed a severe regression that had
  looked completely invisible under the flawed test.

  **Updated 2026-09-17 after Phase B (the `scripts/recommend.py` ->
  `scripts/scoring/` submodule split, see `docs/scoring-test-protocol.md`'s
  "Phase B" entries) — the exact verification command above no longer
  applies.** `scripts/scoring_tests.py` no longer has a single `R`
  object to compare; it imports several `scripts/scoring/` submodules
  directly (`pipeline`, `profile`, `series`, etc.). The underlying risk
  is identical, just spread across more names — **verify the specific
  submodule's identity, then the specific function's actual global
  lookup**, not just "some module resolved the same":
  ```python
  import scripts.scoring_tests as T
  from scoring import pipeline
  assert T.pipeline is pipeline
  assert T.pipeline.score_candidate.__globals__ is vars(pipeline)
  # after installing a variant on pipeline.score_book:
  assert T.pipeline.score_candidate.__globals__["score_book"] is variant
  ```
  The `__globals__` check matters because it's the actual binding a
  function looks up at call time — module identity alone doesn't prove
  a specific rebound name is what a specific function will actually
  use. (Proposed by CODX, Task 12, after correctly flagging that the
  original command was now stale — see
  `docs/codx-reviews/codx-phase-b-shim-removal-2026-09-17.md`.) Or
  avoid the whole class of bug by editing `scoring_tests.py`'s own
  `_full_score()` directly to call the experimental variant, the way
  the series-trajectory-penalty experiment (tested successfully) did
  it — still the simplest, most reliable option regardless of module
  structure.
