---
name: tag-catalog-batch
description: Tag a batch of untagged Bookspell catalog books with full Book DNA (schema fields, tropes, content warnings), prioritizing books from series that are already partly tagged.
---

# Tag a batch of Bookspell catalog books

Bookspell is a sci-fi/fantasy book recommendation app built on structured
"Book DNA" attributes instead of star ratings. The catalog has real
books with bibliographic data (title, author, series, etc.) already
loaded, but a book only becomes usable by the recommendation engine once
it has a full Book DNA row -- an untagged book is silently invisible to
the app (the engine's catalog query inner-joins `books` to `book_dna`),
so tagging is real, load-bearing work, not just data entry.

This skill tags ONE bounded batch (see "How many books" below), then
stops and reports back. It does not try to tag the whole remaining
catalog in one run.

## Setup (one-time)

You need `DATABASE_URL` set to the **hosted** Bookspell Postgres
connection string, not a local one. Ask whoever shared this project
with you for that connection string directly (a message, a password
manager, etc.) -- **never** paste it into chat, a commit, or any file
that gets committed to git. Put it in your own local `.env` file at the
repo root (already gitignored) as:

```
DATABASE_URL=postgresql://...
```

Everything below assumes you're running from a clone of this repo (so
`docs/schema/book-dna.md` and `docs/schema/book-dna.schema.yaml` are
available to read) and have `python3` + `psycopg2` (see
`scripts/requirements.txt`) or `psql` available.

## Step 1: read the schema

Read `docs/schema/book-dna.md` (human-readable, has rationale for every
field/trope) and `docs/schema/book-dna.schema.yaml` (the exact
machine-readable field list and controlled vocabularies) before tagging
anything. Every field is a closed, controlled vocabulary -- never invent
a value not listed there. If you think a real gap exists in the
vocabulary (a trope or value that should exist but doesn't), don't
silently work around it -- note it in your final report instead.

## Step 2: pick the next batch, prioritizing partial series

Untagged books belonging to a series that's ALREADY partly tagged
should be tagged before untagged books from brand-new series or
standalones. Reasoning: Series DNA (an aggregation feature already
built) needs at least 2 tagged books per series to compute anything
useful, and a series where a reader might have already read some
already-tagged entries but not others feels broken if recommendations
can't see the rest. Run this query to get a prioritized list:

```sql
select b.id, b.title, b.author, s.name as series_name,
       b.position_in_series,
       (select count(*) from books b2 join book_dna d2 on d2.book_id = b2.id where b2.series_id = b.series_id) as series_tagged_count,
       (select count(*) from books b2 where b2.series_id = b.series_id) as series_total_count
from books b
left join book_dna d on d.book_id = b.id
left join series s on s.id = b.series_id
where d.book_id is null
order by
  -- partial series first, ordered by how close to complete they are
  (case when b.series_id is not null and exists (
     select 1 from books b2 join book_dna d2 on d2.book_id = b2.id where b2.series_id = b.series_id
   ) then 0 else 1 end),
  series_tagged_count desc nulls last,
  b.title
limit 20;
```

This surfaces untagged books from series like "Dungeon Crawler Carl"
(7/8 tagged) or "Harry Potter" (7/8 tagged) before untagged books from
series with zero existing tagged entries, and before pure standalones.

## How many books

Tag **15-20 books per invocation** of this skill, then stop and report.
Don't try to clear the whole backlog in one run -- smaller, verifiable
batches with real per-book judgment beat a rushed large one. If you
finish the batch and want to continue, just invoke this skill again --
it will naturally pick up wherever partial-series prioritization left
off.

## Step 3: tag each book

For each book in your batch, using your own knowledge of the actual
book:

- Assign every scalar field from `book-dna.schema.yaml` that applies
  (POV/structure, pacing/tone, content/shape, tropes & craft categories
  -- skip the `audiobook_native` module's Tier B fields, i.e.
  `narrator_performance`/`narration_pace_vs_prose`/`accent_authenticity`/
  `production_quality` -- those are deliberately deferred, see
  book-dna.md's backlog, and need external listening data we don't have).
- Assign `genre` (`sci_fi`/`fantasy`, can be both).
- Assign every trope from the controlled vocabulary that's a real,
  meaningful, defining element of the book -- not a passing reference.
  Most books apply to well under half the trope list; that's normal.
- Assign any content warnings that genuinely apply.
- If you're genuinely uncertain about a specific field or trope value
  (not just "any judgment call has some uncertainty" -- genuinely
  unsure between two plausible values), still make your best call, but
  also record it in `book_field_confidence` (for scalar fields) or as
  `confidence` directly on the `book_tropes` row (for tropes), with
  `source = 'ai_inferred'` and a confidence below 1.0 (e.g. 0.5-0.6 for
  a real coin-flip, lower for less certain still). See the
  `book_field_confidence` table and `book_tropes.confidence`/`.source`
  columns -- don't skip this when it's warranted, it's a real, used
  part of the scoring system, not decorative.

Write every insert as a SCOPED statement tied to a specific book_id --
never a blanket UPDATE or DELETE across multiple rows. Example shape:

```sql
insert into book_dna (book_id, overall_pace, darkness, pov_count, ..., genre)
values ('<uuid>', 'fast', 'dark', 'few', ..., array['fantasy']);

insert into book_tropes (book_id, trope_id) values ('<uuid>', 'revenge');

insert into book_content_warnings (book_id, warning_id) values ('<uuid>', 'graphic_violence');
```

Verify each book's inserts by re-querying afterward.

## Step 4: report back

For each book tagged, note anything genuinely uncertain or any
vocabulary gap you noticed. Report the total tagged, and how many
partial series moved closer to (or reached) full completion.
