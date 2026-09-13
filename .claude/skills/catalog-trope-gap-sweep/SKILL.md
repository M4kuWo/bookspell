---
name: catalog-trope-gap-sweep
description: A deliberate, catalog-wide sweep for missing trope/content-warning vocabulary -- distinct from ordinary per-book tagging, which only catches a gap when it happens to hit one book at a time. Run this as a dedicated pass, not routine per-batch work.
---

# Catalog-wide trope/content-warning vocabulary gap sweep

## Why this exists, and why it's not just "tag more books"

Ordinary tagging (`tag-catalog-batch`) already flags a real vocabulary
gap when one comes up -- but only reactively, one book at a time, and
(until 2026-09-13) with nowhere central to track a flagged gap across
batches. `docs/schema/book-dna.md`'s new "Flagged single-occurrence
vocabulary gaps" tracker (top of its "Future fields backlog" section)
fixes the tracking half of that. This skill is the other half: a
deliberate, proactive pass looking for gaps that per-book tagging is
structurally unlikely to surface on its own, because they only become
visible when you look at many books at once (a recurring pattern with
no shared trope signal; a cluster of low-confidence "closest available
fit" tags that all share the same real, missing concept).

This is genuinely a "spend a real chunk of budget" task, not a quick
check -- the 2026-09-05 precedent (the last time this was done, see
`docs/project-log.md`'s "5 new tropes from tonight's catalog-wide gap
sweep" entry) found 5 real new tropes against a ~700-book catalog.
The catalog is over 1250 books now, ~960+ already tagged -- there's
real reason to expect this pass finds more, not less, this time.

## Before you start

Read, in order: `CLAUDE.md` (all of it -- especially "Data quality /
tagging"'s vocabulary rules and the closed-vocabulary bar), then
`docs/schema/book-dna.md` in full (not just the backlog section --
you need to know the ENTIRE existing trope/content-warning vocabulary
cold before you can tell a real gap from something already covered) and
`docs/schema/book-dna.schema.yaml` (the exact machine-readable list --
cross-check against this, not memory, before proposing anything as
"missing"). Then read the tail of `docs/project-log.md` for whatever's
landed since this file was written, and `docs/TODO.md` for current
priorities (this sweep should be logged there as a P1 item -- check
whether it's still queued or already claimed by another session before
starting).

**The bar for a real addition, unchanged from every other vocabulary
decision in this project**: "does this change what gets recommended,"
not "is this a real term." A trope that's accurate but doesn't
discriminate between books a reader would and wouldn't want isn't
worth adding, no matter how many books you find it on. See
`docs/schema/book-dna.md`'s existing deferred-tropes entries
(`touch_her_and_die`, etc.) for what "real but too narrow" looks like.

**Every proposed addition needs real per-book verification against
actual literary knowledge (re-read a synopsis, check reviews/plot
summaries), never assigned from genre pattern-matching alone.** This is
the same standing policy `tag-catalog-batch` documents for `HIGH_RISK_FIELDS`
and any trope asserting a specific plot beat -- it applies with equal
force here, arguably more, since a whole new vocabulary term riding on
a mis-read plot point is a much bigger mistake than one mistagged book.

## Step 1: check the two already-flagged, already-partially-scoped gaps first

`docs/schema/book-dna.md`'s tracker currently has two "Open" entries,
each already naming a specific real second-occurrence candidate to
check -- this is the cheapest, highest-confidence part of this whole
sweep, do it before the broader search below:

1. **Climate/natural-disaster mass-casualty content warning** (no
   existing `content_warning_types` value cleanly covers it, distinct
   from `war_trauma`). First seen on *The Ministry for the Future*.
   Look for other climate-disaster-driven SFF already in the catalog
   (query `book_content_warnings`/`book_tropes` for anything
   thematically close, or just recall/search for genre-adjacent titles
   -- cli-fi, ecological-collapse SF) as a second occurrence.
2. **First-contact-with-a-non-human-non-alien-intelligence-via-natural-
   evolution trope** (distinct from `first_contact` and `uplift`).
   First seen on *The Mountain in the Sea*. The tracker names two
   specific candidates worth checking directly: *Alien Clay* (Adrian
   Tchaikovsky) and *Blindsight* (Peter Watts) -- check whether either
   is even in the catalog yet (`select id, title from books where title
   ilike '%alien clay%' or title ilike '%blindsight%'`), and if so
   whether it's already tagged and whether it genuinely hits this same
   gap (not just "also sci-fi with aliens" -- re-read the actual
   mechanism before deciding it's the same pattern).

If either resolves to a real second occurrence: that's confirmation to
act, following the same process as any other schema change (see Step 4
below) -- update the tracker's "Promoted / resolved" list either way
(whether you added the vocabulary, or checked and it's still only one
real occurrence).

## Step 2: mine existing low-confidence tags for a recurring "imperfect fit" pattern

A `book_tropes`/`book_field_confidence` row tagged well below full
confidence often means "closest available vocabulary, not a clean
match" -- exactly the signal this sweep is looking for, and one that's
cheap to query for (no need to re-read hundreds of books to find these
candidates, they're already flagged in the data):

```sql
select b.title, b.author, t.trope_id, t.confidence
from book_tropes t join books b on b.id = t.book_id
where t.confidence is not null and t.confidence < 0.6
order by t.trope_id, t.confidence;

select b.title, b.author, c.field_name, c.confidence
from book_field_confidence c join books b on b.id = c.book_id
where c.confidence < 0.6
order by c.field_name, c.confidence;
```

Group the results by `trope_id`/`field_name`. If **2 or more different
books** share the same low-confidence tag AND, on real re-reading, the
reason they're both a weak fit is the SAME underlying missing concept
(not just "this book is generally hard to tag") -- that's a real
candidate, same bar as Step 3 below. A single book with a low-confidence
tag for an idiosyncratic reason isn't a pattern; don't force one.

## Step 3: the broader qualitative sweep

This is the part that most resembles 2026-09-05's original method:
look for a **recognizable subgenre or narrative mechanism that shows up
across multiple catalog books with ZERO shared trope signal** -- i.e.
you can name the pattern in one sentence and multiple real books
clearly have it, but querying `book_tropes` for those books turns up no
common tag that captures it. Concretely:

- Pick a cluster to examine (an author with several books, an existing
  `genre`/`drive` combination, a set of books you already know share a
  real structural pattern) and pull their tagged tropes:
  ```sql
  select b.title, array_agg(t.trope_id order by t.trope_id) as tropes
  from books b left join book_tropes t on t.book_id = b.id
  where b.id in (/* your candidate book_ids */)
  group by b.title;
  ```
- Look for books you know share a real pattern (not a vague vibe --
  something you could describe precisely enough to write a trope
  definition for) but whose tag lists have no overlap on anything
  capturing it.
- **Every candidate needs 2+ real, specific catalog books verified by
  actual knowledge of the text** -- the 2026-09-05 precedent's own
  standard. That sweep also deliberately EXCLUDED plausible-looking
  candidates on reflection where the mechanism didn't cleanly fit (see
  its log entry: Babel dropped from `infiltration_or_undercover_plot`,
  Perdido Street Station dropped from `cosmic_horror`) -- being willing
  to talk yourself out of a candidate is part of doing this correctly,
  not a failure of the sweep.
- You don't have to review the entire catalog cover-to-cover. A
  reasonable scope for one sweep: work through it by author/series
  cluster (this project's tagging batches already group work this way),
  prioritizing authors/subgenres with several already-tagged books
  (more shared signal to compare against) over isolated standalones.
  Stop and report when you've covered a meaningful cross-section (aim
  for at least a few hundred of the ~960+ tagged books) rather than
  trying to force full coverage in one pass -- this can be a recurring
  skill invocation, the same way `tag-catalog-batch` is, not a
  one-shot completionist task.

## Step 4: landing a real addition

Same conventions as every other schema/vocabulary change in this
project (see CLAUDE.md's "Database & migrations" and "Data quality /
tagging" sections) -- nothing special here, but all of it applies:

- A new `tropes`/`content_warning_types` row plus catalog-wide
  `book_tropes`/`book_content_warnings` backfill inserts, in one
  migration file per logical addition (or one file covering a whole
  batch of related additions, like 2026-09-05's 5-trope migration --
  your call based on how the additions group).
- `insert ... on conflict do nothing` for idempotency.
- Title-scoped subselects for `book_id`, never a raw UUID; doubled
  single-quotes for any apostrophe in a title, never `E'...'`.
- Test in a rolled-back transaction first (`BEGIN; ...; ROLLBACK;` via
  whatever DB-access method your environment actually has -- see your
  own setup notes, this skill doesn't prescribe one specific method).
  Apply for real via `supabase db push` (never a raw direct Postgres
  connection against hosted -- see CLAUDE.md's explicit warning on why).
- **A `book_dna` schema change is not done until
  `docs/schema/book-dna.schema.yaml`, `docs/schema/book-dna.md`, AND
  `.claude/skills/tag-catalog-batch/SKILL.md` are all updated in the
  same session** -- this rule already exists in CLAUDE.md for exactly
  this reason (a real, already-happened miss cost a full day last time
  it was skipped). A new trope/content-warning is a smaller change than
  a new column, but the same discipline applies: add it to the
  schema.yaml vocabulary list and to book-dna.md's trope/CW
  documentation before calling the migration done.
- If you're CLDA: this counts as "already spelled out step-by-step in
  the skill you're following" for the destructive-action gate's
  purposes (the inserts themselves aren't destructive at all) -- no
  fresh `docs/PENDING_APPROVALS.md` entry needed for the mechanical
  insert/backfill work itself. If you're CODX: per your review-only
  starting scope, this whole skill produces a PROPOSAL (a draft
  migration file, a written case for each addition) for CLDO or the
  repo owner to actually apply, not something you run against hosted
  yourself.

## Step 5: update the tracker and report

- Move anything resolved this sweep from `docs/schema/book-dna.md`'s
  tracker's "Open" list to "Promoted / resolved," noting what it became
  and which migration landed it.
- Add anything genuinely new you found but didn't act on (a real
  pattern seen on exactly one book, or a candidate you talked yourself
  out of but want on record) to the tracker's "Open" list, same as any
  other batch would.
- Log the sweep itself to `docs/project-log.md` (append-only, same as
  every other real change): what you checked, what you found, what
  landed, what's still open and why, and how much of the catalog you
  actually covered (be specific -- "checked N authors/M books" or
  similar, not just "did a sweep") so the next person picking this back
  up knows what's already been looked at.
- Update `docs/TODO.md`'s entry for this sweep with the outcome and
  what a follow-up pass should pick up next (which authors/clusters are
  still uncovered), the same running-pointer pattern every other
  P1/P2 item in that file already uses.
