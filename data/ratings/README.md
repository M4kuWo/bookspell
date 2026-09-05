# Rater data

One JSON file per person, `{name}.json`, each with a `_meta` block
(who, when, notes), a `ratings` object mapping book title to one of
the 5 labels: `loved`, `liked`, `it_was_okay`, `disliked`, `hated`
(matches `RATING_LABELS` in `scripts/recommend.py`), and two optional
sibling objects: `rated_dates` and `reviews` (see below).

## `rated_dates` (optional, 2026-09-04)

A sibling object to `ratings`, same title keys, mapping to an ISO date
string (`"YYYY-MM-DD"`) or a coarser `"YYYY-MM"`/`"YYYY"` when that's
all the rater can recall -- **never invent or infer a date**. A title
with no known date simply doesn't appear in this object at all (don't
write `null` placeholders). Added to unlock future work on preference
drift/eras (see docs/project-log.md's 2026-09-04 "structural issues"
entry) -- **nothing currently reads this field for scoring**. Purely
additive and always optional: a rater with zero dates is exactly as
usable as one with a full date history, and always will be --
**every scoring change that eventually uses dates must be tested both
with and without them present** (a real user population will always
include raters who can't or won't supply dates), never assumed
available. This is a standing testing requirement once any date-aware
feature is built, the same way this project already requires testing
against >= 2 scenarios before landing any scoring change -- see
docs/scoring-test-protocol.md.

This exists because there's no real user/account system yet (see the
README's roadmap) — until there is, this is the durable, versioned
stand-in for "a user's rating history." `scripts/scoring_tests.py` loads
from here rather than hardcoding ratings inline, specifically so a new
rater's data extends the test suite instead of requiring a rewrite.

## `reviews` (optional, 2026-09-04)

Another sibling object to `ratings`, same title keys, mapping to the
rater's own free-text written review, carried over verbatim (no
summarizing, editing, or invented content) -- a title with no known
review text simply doesn't appear here, same "no placeholder" rule as
`rated_dates`. **Nothing currently reads this field for scoring** --
kept as raw qualitative material for future taste-prediction work
(e.g. sentiment/theme extraction correlated against the DNA fields the
rater loved vs. hated), not wired into anything yet. Populated for the
first time by `scripts/import_goodreads.py`, which pulls both this and
`rated_dates` directly from a Goodreads library export's `My Review`
and `Date Read` columns when present.

## Reconciling a rater's own report against an imported source

**When a rater has directly told this project a rating (in conversation,
via the intake form) and an imported source (e.g. a Goodreads export)
disagrees, the rater's own direct report wins -- an import never
silently overwrites it.** Concretely: Mathias rated King of Thorns and
Emperor of Thorns "loved" when he listed them by memory; his Goodreads
export shows 4 stars (this project's "liked") for both. The rating in
`mathias.json` stays `loved` -- only the `rated_dates`/`reviews` from
the import were added for those two titles, since dates/reviews are
purely additive metadata, not a conflicting judgment. This matters
because a star rating and a remembered verbal report can reflect
genuinely different things (in-the-moment reaction vs. settled
retrospective feeling) -- there's no general rule for which is "more
correct," so the direct report is treated as authoritative rather than
silently reconciled either way.

## Roster

| Name | Status |
|---|---|
| Mathias | Collected — `mathias.json`, 128 ratings (several rounds, plus a 2026-09-04 Goodreads import) |
| Osnat | Collected — `osnat.json`, 30 usable (of ~145 total unique titles) |
| Dandan | Collected — `dandan.json`, 32 ratings, via public intake form |
| Gabriel Lempert | Collected — `gabriel.json`, 7 ratings, via public intake form (not on the original expected list -- an independent friend submission) |
| Omri | Expected |
| Irael | Expected |
| Shahar | Expected |

Add a new person's file here as their list comes in, then add a
corresponding scenario in `scripts/scoring_tests.py` (see its own
comments) so their data runs both independently and alongside every
other rater's. Per `docs/scoring-test-protocol.md`: watch specifically
for a scoring idea marked "deferred" (not "disproven") in that doc's
table turning out to actually help once a second or third rater's
pattern is different from Mathias's.

Dandan's and Gabriel's lists (2026-09-02) came through
`tools/rate-books/`, the public intake form -- see that tool's own
README for the submit -> `rating_submissions` -> export flow. Titles
submitted this way are picked from the catalog's own live autocomplete,
so (unlike hand-typed lists) there's no typo/near-miss reconciliation
needed against `books.title`.
