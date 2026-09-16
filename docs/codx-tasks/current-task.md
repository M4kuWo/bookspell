# CODX current task

**Assigned**: 2026-09-17, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` for how this file works if you haven't
read it yet — short version: this is your one current assignment,
refreshed by CLDO after each task lands. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

---

## Task 9 — independent QA pass on low-confidence HIGH_RISK_FIELDS tags from 2026-09-16's two CLDA batches

This is a review/verification task, not a tagging task — you're
independently researching whether an EXISTING tag is correct, not
deciding a new one from scratch. This is the same kind of work as your
Task 2 structural audit and Task 1 code review: independent judgment
CLDO then verifies, not something you apply yourself.

## Why this task exists

Two `tag-catalog-batch` runs landed 2026-09-16 (`docs/project-log.md`'s
"catalog tagging batch" entries for that date, first and second
batches — 40 books total), both under an explicitly disclosed tight
WebSearch budget. Both batches show real process discipline (mandatory
schema checks, 3 real author-contamination catches verified against
Hardcover, honest confidence-scoring instead of false certainty,
density self-checks passing) — this is NOT a "the work looks sloppy"
audit. It's targeting a specific, structural blind spot: this project's
own documented failure pattern (`HIGH_RISK_FIELDS` in
`scripts/recommend.py`, see `CLAUDE.md`'s "Data quality/tagging"
section) is being *confidently wrong* on a specific mechanical detail —
by definition, something self-review under time/resource pressure
can't reliably catch, because the tagger doesn't feel uncertain when it
happens. An independent model doing fresh verification is one of the
only real defenses against that specific class of error.

## Scope: exactly these 20 (book, field, current confidence) pairs

Pulled directly from `book_field_confidence` for the 40 books tagged in
2026-09-16's two batches, filtered to `HIGH_RISK_FIELDS` only
(excluding `romance_tone`/`worldbuilding_delivery` — those are
deliberately deferred pending real user/tester data, not in scope for
research-based verification; see `docs/schema/book-dna.md`). **Verify
each current value against hosted yourself before researching it** —
don't trust these numbers as still-current without checking; a live
`select field_name, confidence from book_field_confidence where
book_id = (select id from books where title = '...')` first.

| Book | Field | Confidence |
|---|---|---|
| Shroud | pov_count | 0.4 |
| Shroud | person | 0.5 |
| Shroud | humor_level | 0.5 |
| Gateway | narrator_reliability | 0.4 |
| Soulless | drive | 0.4 |
| Congo | person | 0.5 |
| Dreamcatcher | person | 0.5 |
| Fall; or, Dodge in Hell | person | 0.5 |
| Gods of Jade and Shadow | pov_count | 0.5 |
| Legion | narrator_reliability | 0.5 |
| Lord of Light | person | 0.5 |
| Pushing Ice | pov_count | 0.5 |
| Shards of Honour | drive | 0.5 |
| Six Wakes | narrator_reliability | 0.5 |
| The Bright Sword | pov_count | 0.5 |
| The Bright Sword | humor_level | 0.5 |
| The Deep Sky | drive | 0.5 |
| Accelerando | humor_level | 0.5 |
| Annie Bot | humor_level | 0.5 |
| The Echo Wife | humor_level | 0.5 |

Also specifically verify these two, self-flagged by CLDA in the
project-log entry as real judgment calls even though one scored above
the 0.6 cutoff above — worth a second opinion precisely because they
were flagged, not because of the raw number:
- **Shroud** (Adrian Tchaikovsky, 2025) specifically — CLDA flagged
  that every attempted web source either 404'd or returned the WRONG
  "Shroud" (John Banville's 2003 novel). Confirm you're researching the
  right book before touching `person`/`pov_count`/`humor_level` at all
  — verify the correct Tchaikovsky/2025/hardcover_id match first,
  explicitly, and say so in your report.
- **Ilium** (Dan Simmons) — `person` tagged `mixed` at confidence 0.6
  (Hockenberry's sections first-person, Earth/Jovian-moon threads
  third-person). Confirm this structural claim independently.

Note the `humor_level` cluster: 9 books across both batches all landed
at exactly 0.5 — worth explicitly checking whether these reflect real,
differentiated per-book uncertainty or a batch-wide "0.5 when
uncertain" default that happens to look the same across unrelated
books. Say which you find; don't just confirm each individually without
noting the pattern either way.

## What to actually do, per (book, field) pair

1. Confirm the book's identity precisely (correct edition/hardcover_id,
   not a same-titled different work — Shroud above is the concrete
   example of why this matters).
2. Research the specific mechanical claim the field encodes (not genre
   pattern-matching — same evidentiary bar `tag-catalog-batch/SKILL.md`
   already requires for `HIGH_RISK_FIELDS`). Use WebSearch/WebFetch;
   plot summaries, reviews, sample chapters, author interviews are all
   fair game.
3. Report one of:
   - **Confirmed correct** — cite the specific evidence found, recommend
     raising confidence to a specific new value.
   - **Likely wrong** — cite the specific evidence, recommend the
     correct value.
   - **Genuinely inconclusive** — you looked and didn't find anything
     more definitive than what's already recorded; recommend leaving as
     is. This is a legitimate, expected outcome for some of these, not
     a failure to find something.

## Deliverable

A report at `docs/codx-reports/2026-09-17-highrisk-confidence-qa-pass.md`
(or same-day-dated equivalent) with one section per (book, field) pair:
current value/confidence, your research, your finding, your specific
recommendation (including an exact proposed confidence value or field
value where applicable). This is a proposal only — you don't touch
`book_field_confidence`/`book_dna` yourself, hosted or local. CLDO
reviews and applies anything worth changing as its own small, real
migration file, same pattern as `20260913250000_backfill_2_incomplete_trope_inserts.sql`.

## This is establishing a recurring task type, not a one-off

If this goes well, the same shape (pick the lowest-confidence
`HIGH_RISK_FIELDS` rows catalog-wide, a batch of 15-20 at a time,
verify or correct them) is the plan for periodic future tasks — CLDO
decided this is worth doing incrementally over time, not as one
catalog-wide sweep (there are ~161 `HIGH_RISK_FIELDS` rows below 0.6
catalog-wide as of 2026-09-17; today's 20 are the freshest and
highest-value first batch, not the whole backlog). Note anything in
your process here that would make a future round of this more
efficient — that's useful feedback for how this recurring task type
should be scoped going forward.
