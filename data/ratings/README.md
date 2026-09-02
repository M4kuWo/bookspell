# Rater data

One JSON file per person, `{name}.json`, each with a `_meta` block
(who, when, notes) and a `ratings` object mapping book title to one of
the 5 labels: `loved`, `liked`, `it_was_okay`, `disliked`, `hated`
(matches `RATING_LABELS` in `scripts/recommend.py`).

This exists because there's no real user/account system yet (see the
README's roadmap) — until there is, this is the durable, versioned
stand-in for "a user's rating history." `scripts/scoring_tests.py` loads
from here rather than hardcoding ratings inline, specifically so a new
rater's data extends the test suite instead of requiring a rewrite.

## Roster

| Name | Status |
|---|---|
| Mathias | Collected — `mathias.json`, 53 ratings, 2 rounds |
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
