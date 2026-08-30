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
that gets committed to git.

**Set it as an exported shell variable in your own terminal session,
not by editing a `.env` file** -- especially important if you're working
from the same physical machine and the same repo directory as whoever
owns this project, since their existing `.env` already points
`DATABASE_URL` at their *local* database. Editing that shared file to
point at hosted risks a silent collision if both of you are working at
the same time. An exported variable takes precedence for anything
reading it from the environment, without ever touching the file on
disk:

```bash
export DATABASE_URL=postgresql://...
```

(If you're instead working from your own separate clone on a different
machine, a `.env` file at the repo root -- already gitignored -- works
fine too. Either way, never commit it.)

You don't need to clone a separate copy of this repo if you're on the
same machine as whoever owns it -- just work from their existing local
directory. `CLAUDE_CONFIG_DIR` (see the main conversation this skill
came from) only controls which Claude account is authenticated in your
terminal; it has nothing to do with which directory you're in.
Everything below assumes `docs/schema/book-dna.md` and
`docs/schema/book-dna.schema.yaml` are available to read (true either
way) and that you have `python3` + `psycopg2` (see
`scripts/requirements.txt`) or `psql` available.

If you are sharing a working directory with someone else actively using
it: avoid running `git commit`/`git push` at the exact same moment they
might be -- low risk here since your only local-file write is one new
migration file (see Step 4), but worth not doing simultaneously.

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

If someone else might be running this same skill around the same time
(against the same hosted database), check with them on timing first --
two concurrent runs picking overlapping untagged books won't corrupt
anything (book_dna's primary key just rejects a duplicate), but it does
waste real, paid effort on books someone else already tagged in the
few minutes since you picked your batch.

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

**Critical: `book_dna` only requires `book_id` and `genre` to be NOT NULL
-- every other column is nullable.** This means a partial INSERT (only a
few fields filled in) will succeed silently, with no error, and produce
a book_dna row that LOOKS tagged (it passes Step 2's `d.book_id is null`
filter, so it permanently disappears from every future "find untagged
books" query) but is mostly empty and useless to the scoring engine.
This is worse than not tagging the book at all -- it's a silent failure
mode, not a loud one. Your `book_dna` INSERT must include every one of
these columns (all nullable, but all real signal -- don't skip any just
because you can): `age_category, book_length, pov_count, person,
narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
darkness, humor_level, emotional_register, message_intensity,
romance_heat_frequency, romance_heat_intensity, violence_frequency,
violence_intensity, worldbuilding_density, narrative_closure,
emotional_resolution, ends_on_cliffhanger, audiobook_length,
magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
intellectual_weight, stakes_scope, personal_stakes` -- plus `genre`.
(Leave out the 5 Tier B audiobook columns mentioned above -- those stay
null on purpose.) If a field genuinely doesn't apply to a book (e.g.
`romance_heat_frequency` on a book with zero romance), use its `none`
value if the schema defines one for that field -- don't just omit the
column.

Write every insert as a SCOPED statement tied to a specific book, using a
`select id from books where title = '...'` subselect for the book_id --
**not a raw UUID pasted from a query result.** This matters specifically
because you're working against the hosted database, which has different
row UUIDs than anyone else's local database for the same logical books
-- a title-keyed subselect is portable across both, a hardcoded UUID
only works in the one database you copied it from. This is the same
pattern every migration in this project already uses. Never a blanket
UPDATE or DELETE across multiple rows. Complete example, every real
column filled in (not abbreviated -- copy this shape exactly):

```sql
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, violence_frequency,
  violence_intensity, worldbuilding_density, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes
)
select
  id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'dark', 'light', 'tense', 'moderate',
  'none', 'closed_door', 'occasional',
  'graphic', 'moderate', 'requires_series',
  'bittersweet', 'cliffhanger', 'standard',
  'soft', 'na', 'moderate', 'moderate',
  'moderate', 'regional', 'high'
from books where title = 'Example Title';

insert into book_tropes (book_id, trope_id)
select id, 'revenge' from books where title = 'Example Title';

-- book_content_warnings.warning_id is a foreign key -- only the exact
-- ids in content_warning_types are valid (check that table, or
-- book-dna.md's content-warnings list; "graphic violence" itself is
-- NOT one -- that's covered by the violence_intensity/violence_frequency
-- book_dna fields instead, content_warning_types covers more specific
-- things like war_trauma, torture, body_horror, genocide, etc.).
-- severity is also REQUIRED (values: brief, moderate, central_theme) --
-- this insert will fail without it, it's not optional the way it might
-- look from a 2-column example elsewhere:
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Example Title';

-- only when genuinely uncertain about a specific field (see above):
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'Example Title';
```

Verify each book's inserts by re-querying afterward -- specifically
check that the book_dna row actually has values in most columns, not
just a few, given the silent-partial-insert risk above.

If you genuinely don't know a book well enough to tag it confidently
even after thinking it through, do a quick check (a web search is fine)
before guessing -- and if you're still not confident, skip that book and
say so in your report rather than fabricating tags for a book you don't
actually know.

## Step 4: save your batch as a migration file, and hand it back

Your inserts already went live against the hosted database the moment
you ran them -- there's no separate "push" needed for that. But two more
things still need to happen so your work is properly recorded and
reaches whoever's local development database:

1. Save every statement from this batch into one new file at
   `supabase/migrations/<YYYYMMDDHHMMSS>_<short_description>.sql` (match
   the timestamp-prefixed naming already used by every other migration
   in `supabase/migrations/`), with a short comment at the top noting
   what was tagged and by whom.
2. Get that file back to whoever owns this repo, so it lands in git
   history and can be applied to their local database (the same file,
   unmodified -- it's portable by construction, see Step 3 above):
   - If you've been added as a GitHub collaborator with push access,
     just `git add`/`git commit`/`git push` it yourself.
   - If not (the default -- this repo is public to clone but that
     doesn't grant push access), don't try to push. Instead, hand the
     `.sql` file's contents back directly (paste it, share the file) --
     the repo owner will commit it on their end.

Do NOT skip this step because "the data's already in the hosted
database" -- an untracked change with no corresponding migration file
means the next person to look at `supabase/migrations/` has no record
of what happened or why, and their own local database silently drifts
out of sync with hosted.

## Step 5: report back

For each book tagged, note anything genuinely uncertain or any
vocabulary gap you noticed. Report the total tagged, how many partial
series moved closer to (or reached) full completion, and confirm
whether the migration file was pushed or handed back for the repo owner
to commit.
