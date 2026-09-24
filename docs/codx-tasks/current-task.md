# CODX current task

**Assigned**: 2026-09-24, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` if you haven't read it yet. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 18 — a real CI-integrated scoring-mechanics fixture test (first slice)

`main` is at commit `1c92666`. From the 2026-09-23 external AI review
(`docs/external-reviews/2026-09-23-gpt-review.md`, its R3) and confirmed
as a real gap 2026-09-24: current CI (`.github/workflows/ci.yml`, your
own Task 15) only checks syntax and migration timestamps -- nothing
exercises `scripts/scoring/` at all. This task builds the first real
slice of that.

**This is a NEW, separate file — do not modify `scripts/recommend.py`
or `scripts/scoring_tests.py`.** Both stay CLDO-exclusive territory per
this project's persona rules, same as always; a new, independent
fixture-test file doesn't touch either.

### Why fixtures, not the live database

`scripts/scoring_tests.py`'s own benchmark (real raters, real catalog)
answers "do these rules produce GOOD recommendations" — genuinely can't
run in CI (needs a live Postgres + real tagged data). This task answers
a different, narrower question: "does the engine obey its OWN rules,"
which a small hand-built synthetic catalog can test deterministically,
fast, with zero external dependencies. Keep both purposes distinct —
don't try to make this new file a smaller version of the real benchmark.

### The fixture catalog shape

`scripts/scoring/catalog.py`'s `load_catalog()` returns
`{book_id: {...}}` where each book dict has: `id`, `title`, `author`,
`series_id`, `series_name`, `position_in_series`, every `book_dna`
column (read `docs/schema/book-dna.schema.yaml` for the full field
list and controlled vocabularies), plus `tropes` (a list of trope id
strings), `_trope_confidence` (dict, trope_id -> float, only for tropes
with a recorded confidence), `_field_confidence` (dict, field_name ->
float, only for fields with a recorded confidence). Build a small,
fully synthetic version of this shape by hand — 12-15 fake books is
enough, with `series_id`/`position_in_series` set on at least 2-3 of
them (forming 1-2 fake short series) since several of the mechanics
below specifically need series structure to test. Real UUIDs aren't
required — any unique string id is fine for a fixture that never
touches a real database.

Design the fixture books DELIBERATELY, not randomly — each one should
exist to isolate a specific mechanic being tested (e.g. two books
identical except for one ordinal field's value, at a known distance
apart, so the expected similarity score is computable by hand and
assertable exactly).

### What to test in this first slice (scope it to exactly this — a
### second task will cover the rest, see "What NOT to do")

1. **Ordinal field similarity** — a field like `overall_pace`
   (slow/medium/fast) or `darkness`: confirm similarity at distance 0
   (identical), 1 (adjacent), and max distance (opposite ends) match
   the formula's actual documented behavior, not an assumption about
   it — read `scripts/scoring/pipeline.py`'s own similarity functions
   first, assert against what they actually compute, not against your
   prior expectation of what they "should" compute.
2. **Nominal field similarity** — same idea for a nominal field (e.g.
   `person`, `magic_system_hardness`): match vs. mismatch, confirm the
   actual similarity values used.
3. **Basic field weighting via `build_profile()`** — a tiny synthetic
   rating set (a few loved, a few hated books differing cleanly on one
   field) produces a learned weight on that field with the correct
   SIGN and a non-trivial magnitude. Not testing exact weight values
   (too sensitive to the real formula's tuning) — testing that the
   mechanism directs weight the right way given clean synthetic
   evidence.
4. **`score_candidate()`'s 4 policies are internally consistent** —
   ranking/explanation/evaluation/audit agree on base score where
   their stage sequences overlap, and differ only in the documented
   ways (see `score_candidate()`'s own docstring in `pipeline.py` for
   the exact stage sequence per policy — assert against that, not
   against a guess).
5. **Series-position gating** — a synthetic 3-book fake series: confirm
   book 2 is ineligible (`policy="ranking"`) when book 1 isn't in the
   training ratings, and eligible once it is. Cheap to construct, real
   mechanic, currently completely untested anywhere in CI.

### What NOT to do in this task (real, deliberately deferred to a
### follow-up — do not try to cover these now)

Redundancy/prevalence discounts, trajectory adjustment, cold-start
blending, user-rules filtering, explanation-text generation, and
dealbreaker/veto firing are all real, valuable things to fixture-test
eventually, but adding all of them in one pass risks exactly what this
project's own "deliberately small batches" convention exists to avoid.
Leave them for Task 19 once this slice lands and is reviewed.

No changes to `.github/workflows/ci.yml` itself, no commits, no
pushes, no DB access needed at all for this task (it's 100% synthetic
data) — propose the new file's path and the exact CI step that would
run it (a fourth check alongside the existing three) in your report;
CLDO wires it in after independent review, same as every other CODX
proposal.

### Validation bar

- Actually run the fixture test file locally and confirm every
  assertion passes against the current, real `scripts/scoring/` code
  — don't write assertions you haven't verified pass.
- Deliberately break one thing (e.g. temporarily comment out the
  series-position gate in a throwaway copy of `pipeline.py`, never the
  real file) and confirm your test actually catches it — same
  "prove the check can fail" discipline your Task 15/16 work already
  used.
- Confirm the whole file runs in well under a second (it's tiny
  synthetic data, no DB) — if it's slow, something's wrong with the
  fixture design, not expected behavior.

### Deliverable

The new test file itself (e.g. `scripts/scoring/tests/test_fixtures.py`
or a path of your own choosing — say what you picked and why), plus a
report at `docs/codx-reports/<date>-scoring-fixture-tests.md` with:
what each test actually asserts and why, the pass/fail evidence from
both the clean run and the deliberately-broken run, and your proposed
CI step (the exact command CI would run).
