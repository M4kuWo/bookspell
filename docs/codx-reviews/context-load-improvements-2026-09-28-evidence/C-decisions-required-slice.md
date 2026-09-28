# Book DNA — decisions, history & deferred proposals

Companion to `book-dna.md` (the core schema reference), split out
2026-09-25 as part of the fresh-session context-load reduction effort
(`docs/codx-reports/2026-09-25-book-dna-split-review.md`,
`docs/project-log.md`'s 2026-09-25 "CODX Task 22 landed" entry). Read
this when proposing a new field/trope/content-warning (check for a
prior rejection first), revisiting a past design decision, or tracing
why a current field looks the way it does — NOT part of the mandatory
every-session read. For the two other split-out pieces, see
`book-dna-vocabulary-gaps.md` (the active tagging-gap tracker) and
`book-dna-tables.md` (current contracts for tables built out of this
backlog — `audiobook_editions`, `work_type`, Series DNA, confidence/
source, post-read/DNF feedback). All original text below is preserved
verbatim from the pre-split `book-dna.md`; only relative "above"/
"below" navigation has been repaired to point at real destinations.

This file has three parts: **Deferred / open proposals** (genuinely
still-speculative ideas, not built), **Rejected / superseded
decisions** (considered and explicitly turned down, or reopened and
still pending), and **Dated implementation/review history** (a
chronological record of how the schema got to its current shape).

## Rejected / superseded decisions

- **`cannibalism`** (content_warnings) — considered during the 30-book
  pilot (The Road), rejected on reflection. Unlike the researched
  content_warnings additions elsewhere (cross-checked against StoryGraph/
  real book lists before adding), this was only a single in-the-moment
  inference while tagging one book — weaker evidence, and on the same
  "does this change the recommendation, not just is it upsetting" bar, it
  reads as a specific flavor of `body_horror` + `violence_intensity:
  graphic` rather than a distinct category, same reasoning that excluded
  gore/blood/injury earlier. Not added.
  **UPDATE (2026-09-13, sweep #3)**: re-surfaced independently by a
  different reviewing agent, with real cross-author evidence this time
  (Tender Is the Flesh's entire legalized-human-meat-industry premise,
  not just incidental content; The Road's marauder gangs and
  captive-harvesting basement scene) — stronger than the single in-the-
  moment inference that led to the original rejection. Deliberately NOT
  added this round either: reopening an explicit, already-reasoned prior
  decision is a different kind of call than filling a previously-
  unexamined gap, and isn't something to flip unilaterally mid-sweep.
  **STILL PENDING repo-owner decision as of the 2026-09-25 split** —
  not resolved by this reorganization, just relocated. Whoever picks
  this up next should confirm it's still genuinely unresolved (check
  for a more recent decision first) before treating this status as
  current.
- **`fragmented_nonlinear_structure`** (a deliberately
  out-of-chronological-order/digression-heavy narrative structure —
  Infinite Jest, Gravity's Rainbow) — seriously investigated during
  sweep #3 (2026-09-13) and deliberately rejected as redundant: direct
  DB check confirmed both evidence books already carry `timeline:
  nonlinear` — the exact same redundancy trap sweep #1 caught with
  `non_linear_timeline_narrative` (Vicious/Vengeful/Six of Crows/Crooked
  Kingdom, also already captured by the `timeline` scalar). Not added.

