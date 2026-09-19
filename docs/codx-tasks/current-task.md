# CODX current task

**Assigned**: 2026-09-20, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` for how this file works if you haven't
read it yet — short version: this is your one current assignment,
refreshed by CLDO after each task lands. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 13 — independent review + test pass on everything that's touched the recommendation/explanation engine since your Task 12

`main` is at commit `e8281c2`. Your Task 12 (`d6cd2db`, 2026-09-17) is
the baseline — Phase B's split of `scripts/recommend.py` into
`scripts/scoring/` submodules, which you already know well. Exactly
two commits have touched the recommendation/explanation engine since
then, both by CLDO, both already landed and pushed (this is a REVIEW
task, not a build task — nothing here is waiting on you to land, it's
asking whether what already landed was done right):

- `fcf8f65` — **`/recommendations` redundant profile-resolution fix.**
  `explain_match()` (`scripts/scoring/api.py`) recomputed its entire
  profile bundle (`_resolve_profile`, `validated_dealbreaker_fields`,
  `compute_series_dna`, `build_prevalence_lookup`,
  `user_calibrated_poor_threshold`) from scratch on every call, and
  `api/main.py`'s `/recommendations` called it once per result (up to
  `top_n=100`). Fix: extracted `explain_match_with_profile()` (takes a
  pre-resolved bundle) and `resolve_explain_profile()` (computes it
  once) out of `explain_match()`, which is now a 2-line wrapper over
  both with its own behavior/cost-per-call unchanged.
  `api/main.py` now resolves the bundle once before its result loop.
- `e8281c2` — **dashboard-side consolidation.** `app/dashboard.html`'s
  "Get recommendations" click fired 3 parallel `/recommendations`
  requests (one per genre tab: `''`/`fantasy`/`sci_fi`), each
  redundantly re-querying `ratings`/`user_rules`/`profiles` over its
  own DB connection. Fix: `/recommendations`' own body extracted
  verbatim into a shared `_score_genre()` helper; new
  `GET /recommendations/all` endpoint loads
  catalog/ratings/rules/format-preference once and calls
  `_score_genre()` per genre; dashboard now makes one fetch instead of
  three.

Read `docs/scoring-test-protocol.md`'s two matching entries (search for
"redundant profile-resolution fix" and "dashboard-side speed fix
landed") for CLDO's own stated reasoning and verification claims —
**don't take those claims on faith**, that's exactly what this task is
for. Also skim `docs/TODO.md`'s matching updates and
`docs/project-log.md`'s two 2026-09-20 entries for the same context
from a different angle.

## What's decided, not open for re-litigation

- The diagnosis itself (redundant per-call profile resolution was the
  real cost) is correct and re-confirm-able directly from the code —
  don't spend time arguing whether this was worth fixing at all.
- The general shape of both fixes (extract-a-function-with-the-
  expensive-part-hoisted-out, compute-once-and-reuse) is the right
  kind of fix for this problem. You're reviewing the EXECUTION, not
  proposing a fundamentally different architecture.
- Nothing here touches the actual scoring MATH (`score_book`,
  `score_candidate`, weights, calibration) — both changes are pure
  call-wiring/caching. If your review finds a scoring-math difference
  anywhere, that's a serious finding, not a stylistic one — flag it at
  the top of your report, not buried in a list.

## What's genuinely open — this is what CLDO wants your opinion on

1. **Independent correctness verification, not a re-run of CLDO's own
   harness.** Write your own comparison: load the real catalog via
   `CODX_READONLY_DATABASE_URL` (see "Data access" below), load a
   couple of real raters from `data/ratings/*.json`, and confirm
   `explain_match()`'s output is unchanged before/after `fcf8f65` for a
   meaningfully different sample than whatever CLDO's report describes
   (different raters, different genres, different `top_n` values,
   different sample of titles — the point of a second reviewer is
   catching what the first one's specific choices happened to miss).
   Do the same for `explain_match_with_profile()` given a manually
   resolved bundle, and for the `/recommendations` vs
   `/recommendations/all` output-shape comparison.
2. **A real, specific concern CLDO noticed late and wants your read
   on, not CLDO's own conclusion**: the old dashboard code fetched 3
   genres independently and rendered whichever ones succeeded (a
   per-genre `response.ok` check; if the currently-viewed genre's
   request happened to fail but the other two didn't, the page still
   partially worked). The new `/recommendations/all` is one request —
   if `_score_genre()` throws for even ONE genre server-side (e.g. a
   genre-scoped edge case like too little data for `sci_fi`'s own
   `build_prevalence_lookup()`/`user_calibrated_poor_threshold()` on a
   thin profile), the whole endpoint fails and the dashboard shows
   nothing for any genre, where before it might have shown 2 of 3.
   **Is this a real regression worth fixing** (e.g. catching each
   genre's `_score_genre()` call individually inside
   `/recommendations/all` and returning partial results with an
   error marker for whichever genre failed, instead of one all-or-
   nothing response), or is it an acceptable trade-off (all 3 genres
   score against the same underlying ratings/rules, so a failure
   isolated to one genre specifically, rather than something systemic
   that would have failed all 3 old requests anyway, seems like it
   should be rare)? Give a real opinion, not just "worth considering."
3. **Missed callers or edge cases.** `scripts/recommend.py`'s CLI demo
   also calls `explain_match()` (unaffected by design, but confirm
   that's actually true rather than assumed) — is there any other real
   caller of `explain_match()`, `recommend()`, or anything in
   `scripts/scoring/api.py` that CLDO's search might have missed?
   (`rg` for `explain_match\(` and `\.recommend\(` across the whole
   repo, not just the files CLDO's report mentions checking.)
4. **Simplification/code-quality pass** on the actual diff (`git show
   fcf8f65` and `git show e8281c2`) — naming, whether
   `resolve_explain_profile()`'s returned-dict-of-9-keys design is the
   right shape vs. a small dataclass/namedtuple, whether `_score_genre()`
   belongs where it landed in `api/main.py`, anything that reads as
   awkward or over/under-engineered to a fresh reader who didn't write
   it.
5. **Is there a THIRD redundancy left on the table?** `recommend()`
   itself still resolves its own profile bundle internally (once per
   request, unavoidable given its own contract) — `/recommendations`
   now resolves the bundle a second time via
   `resolve_explain_profile()` for the explain-loop. That's 2 resolves
   per request now (down from ~N+1), not 1. CLDO judged collapsing
   this to a true single resolve as a bigger, riskier change (would
   mean changing `recommend()`'s return contract, touching more
   callers) and out of scope for this fix. Do you agree that's the
   right call, or is there a cheap way to get to a true single resolve
   without that blast radius?

## Data access — read this before you hit a permission wall

- **Catalog + scoring math**: `DATABASE_URL="$CODX_READONLY_DATABASE_URL"`
  covers everything `load_catalog()` needs. Use this for the
  `explain_match()`/`explain_match_with_profile()` comparisons in
  item 1 above.
- **`/recommendations` and `/recommendations/all` endpoint-level
  testing needs `ratings`/`user_rules`/`profiles`, which
  `codx_readonly` deliberately does NOT have access to (per
  `AGENTS.md`).** Don't try to query those tables directly — you'll
  hit a real permission-denied, as designed. Instead, monkeypatch
  `_load_user_ratings`/`_load_user_rules`/`_load_format_preference` in
  your test harness to return synthetic data (a `data/ratings/*.json`
  rater's `ratings` dict works fine as the synthetic input — see how
  `scripts/scoring_tests.py` already loads these) rather than hitting
  the real tables at all. This is actually a *better* test than a live
  DB read for this specific purpose: deterministic, reproducible, and
  it isolates exactly the code path under review.
- **FastAPI's `TestClient`/`httpx` aren't in this repo's own
  environment** — you'll need a throwaway venv with `api/requirements.txt`
  installed (same as any isolated-venv endpoint test you've done
  before). `require_user_id` is a plain function call inside each
  route body, not a `Depends()` — `app.dependency_overrides` won't
  intercept it; monkeypatch the module attribute directly (e.g.
  `import main; main.require_user_id = lambda authorization=None:
  FAKE_USER_ID`) the same way CLDO's own verification did.

## Deliverable

A report at `docs/codx-reports/2026-09-20-recommendation-engine-review.md`
(or same-day-dated equivalent). This is a review, not an implementation
task, so the core deliverable is your **verdict**: do you agree with
what landed, or is there room for improvement — with the specific,
concrete backing for whichever answer (your own independent test
numbers/mismatch counts, not just "looks fine"). If you find something
small and clearly correct to fix (e.g. item 2's partial-failure
handling, if you conclude it's worth fixing), you may implement and
validate it in your own clone, uncommitted, per your standing scope —
propose it in the report either way; don't commit or push regardless
of how confident you are.
