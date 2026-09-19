# CODX current task

**Assigned**: 2026-09-19, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` for how this file works if you haven't
read it yet — short version: this is your one current assignment,
refreshed by CLDO after each task lands. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

**This is the follow-up to your own Task 13 review**
(`docs/codx-reviews/codx-recommendation-engine-review-2026-09-19.md`) —
the repo owner decided to have you implement the fix you already
scoped there, since nobody knows its exact shape better than you do
right now.

---

## Task 14 — fix `/recommendations/all`'s all-or-nothing failure mode

`main` is at commit `d112a96` (your Task 13 review, landed, plus
CLDO's fix for the title-validation-order regression your report
found). Re-sync and re-read your own Task 13 report fresh before
starting — don't work from memory of writing it.

**The problem, as you already found it**: `GET /recommendations/all`
(`api/main.py`) calls `_score_genre()` for `''`/`fantasy`/`sci_fi`
sequentially inside one dict-literal response. If any ONE of those
three raises, the whole endpoint 500s and the dashboard shows nothing
for any genre — where the old (pre-your-Task-13-review) 3-independent-
`/recommendations`-requests code would still render whichever genres
succeeded. You proved this is real via fault injection through both
the HTTP routes and the actual `app/dashboard.html` click handler
(executed in Node's VM), and also proved no naturally-occurring
genre-only failure exists today (empty/thin/invalid profiles all
still succeed) — so this is a real latent gap, not something currently
visibly broken.

## What's decided (per the repo owner directly, not your call to
re-litigate)

- **Fix it, in the shape your own report proposed**, not a different
  design. Quoting your report's own proposed follow-up back to you as
  the spec:
  - Keep authentication and shared data acquisition (catalog/ratings/
    rules/format-preference loading) OUTSIDE the per-genre exception
    boundary — those failures should still fail the whole request
    normally (there's nothing partial to salvage if loading the user's
    own ratings fails).
  - Score each genre independently inside `/recommendations/all`; log
    the exception server-side (a plain `print`/logging call is fine,
    matching this project's existing error-visibility conventions —
    check what `api/main.py` already does elsewhere for consistency);
    preserve whichever genres' lists succeed.
  - Return partial success when at least one genre succeeds; return a
    real error response only if ALL THREE fail (decide the exact
    status code/shape for the all-fail case — 500 is probably right
    but justify it, don't just default to it).
  - Response envelope: `{"results_by_genre": {"": [...], "fantasy":
    [...], "sci_fi": [...]}, "errors_by_genre": {"sci_fi":
    "temporarily_unavailable"}}` — a genre only appears in ONE of the
    two sub-objects, never both. No exception details/stack traces
    exposed to the client, ever (this is your own report's own
    constraint — keep it).
  - `/recommendations` (the single-genre endpoint) is UNCHANGED — this
    envelope shape is specific to `/recommendations/all`. Don't touch
    `/recommendations`'s existing response shape or behavior.

## What you're actually building (both sides — this is a real
API+frontend change, not just a backend patch)

1. **`api/main.py`**: wrap each of the 3 `_score_genre()` calls inside
   `recommendations_all()` in its own try/except; build the
   `results_by_genre`/`errors_by_genre` envelope as specified above.
   Decide and justify the all-3-fail response (status code + body
   shape).
2. **`app/dashboard.html`**: update the `/recommendations/all` consumer
   to read the new envelope shape (`resultsByGenre` should end up
   holding ONLY the lists dictionary — your own report's explicit
   warning: do NOT let `errors_by_genre` leak into `resultsByGenre`,
   since `attachThumbnails()` does `Object.values(byGenre).flat()` and
   would treat error-metadata as recommendation data). Keep healthy
   tabs fully usable when only one genre failed — don't blank the
   whole results area for a single-genre failure the way it does
   today. Show a real error/retry state for the specific tab(s) that
   failed (a simple "Couldn't load Sci-Fi recommendations — try
   again" empty-state message in that tab's render slot is enough;
   this doesn't need to be fancy). Don't cache a failed genre as an
   empty successful list in `saveRecsCache()`/`loadRecsCache()` — a
   later page load shouldn't treat "we couldn't score this" the same
   as "there's nothing here."

## Validation bar

- **`/recommendations`'s existing behavior is completely untouched** —
  re-run (or re-derive fresh) the same old-vs-new comparison your
  Task 13 report already did for it; it must still be byte-identical.
- **Fault-injection re-test, all 3 failure positions** (unfiltered/
  fantasy/sci-fi each failing alone) — confirm the 2 healthy genres'
  real lists still come back correctly in `results_by_genre`, the
  failed one appears in `errors_by_genre` only, and the HTTP status is
  whatever you decided for "at least one succeeded" (200, presumably,
  since the client needs to actually read the partial body — a 5xx
  usually means "don't bother parsing the body," so double check
  whatever status you pick doesn't fight normal fetch/error-handling
  conventions in `apiFetch()`).
- **All-3-fail case** — confirm your decided status/shape.
- **Dashboard-side**: re-run the same Node-VM-executed-real-handler
  technique your Task 13 report already built
  (`dashboard_check.cjs`/`dashboard-results.json` in your own evidence
  — reuse and extend it, don't start from scratch) for: all-succeed
  (unchanged), one-genre-fails-not-currently-selected (other tabs
  still populate, failed tab shows its error state, no blank page),
  one-genre-fails-IS-currently-selected (that tab shows its error
  state, switching to a healthy tab still works), all-3-fail (a real
  top-level error state, not a silent blank page).
- Confirm `saveRecsCache()`/`loadRecsCache()` genuinely don't persist a
  failed genre as an empty success — a real round-trip test (save with
  one genre missing/errored, reload, confirm it's still marked as
  errored rather than silently becoming "0 recommendations").

## Deliverable

Same process as always: implement and validate in your own clone,
uncommitted. A report at
`docs/codx-reports/<date>-recommendations-all-partial-failure-fix.md`
with the real diff (both files), full validation evidence per the bar
above, and anything you had to deviate from the spec on (with
reasoning) — this is more prescribed than your usual review work, but
if something in this spec turns out to be wrong or awkward once you're
actually implementing it, say so and propose the adjustment rather than
forcing a bad fit silently. No commit, push, or hosted write, same as
always.
