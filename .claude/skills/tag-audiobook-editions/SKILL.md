---
name: tag-audiobook-editions
description: Research and record audiobook edition data for Bookspell -- dramatized full-cast editions (GraphicAudio, BBC Audio) of existing catalog books, and audio-only Audible Originals that need to be ingested as new catalog entries.
---

# Audiobook edition data: dramatized editions + audio-only originals

Bookspell is a sci-fi/fantasy book recommendation app built on structured
"Book DNA" attributes instead of star ratings. This skill covers a
genuinely different kind of work than the main `tag-catalog-batch`
skill: not tagging Book DNA fields on books everyone already agrees are
in scope, but finding and recording **audiobook-specific data** that
doesn't come from Hardcover (the normal ingestion source) at all.

There are two real sub-tasks here, run as separate passes -- see "Why
this isn't combined with the romance_tone/worldbuilding batches" below
for why they don't share a batch with each other, or with those.

## Setup (one-time)

Same as `tag-catalog-batch`: `DATABASE_URL` set to the **hosted**
Bookspell Postgres connection string via an exported shell variable in
your own terminal session (never edit the shared `.env`), never commit
it or paste it into chat. Ask the repo owner for it directly if you
don't have it.

## Why this isn't combined with the romance_tone/worldbuilding batches

The repo owner asked this directly -- worth being explicit about the
reasoning, not just asserting it:

Those two tropes are tagged by **reading existing reviews/discourse
about a book already in the catalog** and extracting a craft-execution
judgment (is the romance restrained or melodramatic, is worldbuilding
woven in or exposition-dumped) -- the SAME evidence-gathering (reading
reviews) serves both fields, which is exactly why combining them saves
real time.

Both sub-tasks here start from a **completely different source**: a
third-party producer's own catalog listing (GraphicAudio, BBC Audio),
or Audible's own originals catalog -- not our books, not reviews of
our books. There's no shared evidence-gathering to exploit by combining
with the romance/worldbuilding pass, and the per-candidate economics are
totally different: most books you check will have NO dramatized edition
at all (a fast, low-effort "no" that doesn't warrant also having a book
already loaded in context for a romance_tone judgment call that book
was never going to need), while an audio original needs FULL fresh
tagging work, not a two-trope add-on. Bundling them would dilute focus
on both without saving the thing combining is supposed to save.

**The one legitimate combine**: if a romance_tone/worldbuilding
reviewer happens to notice a GraphicAudio/BBC mention while reading
reviews for that book anyway (this does happen -- reviews sometimes
say "the audiobook is incredible" or name the producer), it's fine and
cheap to jot that down as a side note for this skill to follow up on
later. That's opportunistic, not a required per-book step -- don't turn
it into a second mandatory check on every romance_tone/worldbuilding
book, that reintroduces the dilution problem this section just argued
against.

## Sub-task A: dramatized full-cast editions on EXISTING catalog books

Populates `audiobook_editions` (one-to-many on `book_id`; see
`docs/schema/book-dna.md`'s "audiobook_editions" backlog entry for the
full design rationale, and `tools/catalog-review/index.html` for where
this surfaces). Two known producers as of 2026-09-07 -- both do genuine
full-cast dramatizations of existing SFF novels, not just standard
narration:

- **GraphicAudio** (graphicaudio.net) -- the larger, SFF-focused one.
- **BBC Audio / BBC Radio drama** -- smaller but real overlap (has done
  Discworld, Neverwhere, Dune, Foundation, His Dark Materials).

There may be others (Big Finish leans licensed-IP/tie-in rather than
novel adaptations, less likely to overlap much; note anything else you
find credible evidence of in your report, don't just silently skip it).

### Step A1: build the candidate list FIRST, cheaply -- don't check book-by-book

Most of our 825 books have no dramatized edition at all. Checking each
one individually would be hugely wasteful. Instead:

1. Pull GraphicAudio's SFF/fantasy catalog listing (their site is
   browsable by genre) -- get a list of titles+authors they've
   produced.
2. Pull BBC Audio's drama catalog similarly (their site and general
   audio-drama reference sources both work).
3. Cross-reference both lists against our actual catalog:
   ```sql
   select title, author from books order by title;
   ```
   (or export this once and match locally/in your own working memory --
   whichever is more reliable for you). A fuzzy title+author match is
   fine; note anything ambiguous rather than guessing.
4. Only the INTERSECTION needs deep research. Expect this to be a small
   number (tens, not hundreds) -- report the actual count you find, so
   future sessions know whether this pool is exhausted or still growing
   as the catalog grows.

This step can be done in ONE larger pass across the whole catalog --
it's a lookup/cross-reference operation, not per-book judgment work, so
the usual 15-20-books-per-batch discipline doesn't apply here. Report
back with the full candidate list before moving to Step A2.

### Step A2: research each real match, then insert

For each confirmed match, find: `edition_type` (`dramatized_full_cast`
for these two producers, `standard`/`abridged`/`other` if you find a
different kind of edition worth recording), `narrators` (array -- full
cast list if reasonably findable, otherwise leave null rather than
guess), `production_company`, `runtime_minutes` (convert from stated
hours if that's what's given), `release_status`
(`fully_released`/`in_progress`/`announced`), `parts_released`/
`parts_total` (episodic dramatized releases -- e.g. GraphicAudio's Wind
and Truth released across 5 parts over ~4 months; check whether the
match you're researching is fully out yet, don't assume), `source_url`,
`last_verified_date` (today's date -- this column exists specifically
so a future session can tell whether a row needs re-checking rather
than trusting a stale status indefinitely, same pattern as
`series.status`).

```sql
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast', array['Narrator One','Narrator Two'],
  'GraphicAudio', 720, 'fully_released', null, null,
  'https://...', current_date
from books b
where (b.title, b.author) = ('Exact Title', 'Exact Author')
on conflict do nothing;
```

Work in batches of however many real matches Step A1 turned up per
session -- this is genuinely faster per-book than romance_tone-style
tagging (existence + metadata, not a craft judgment call), so don't
artificially cap at 15-20 if you have more confirmed matches ready and
verified.

## Sub-task B: Audible Originals (audio-only, no print counterpart)

These are NOT edition data on an existing book -- they're **entirely
new catalog entries** with no page-count/print form at all (a full-cast
audio drama commissioned as an Audible Original). Structurally this is
closer to `tag-catalog-batch`'s original ingestion+tagging work than to
Sub-task A above -- treat it with the SAME batch-size discipline as that
skill (15-20 per batch), not the faster existence-check pace of
Sub-task A.

### Schema

`books.work_type` now allows `'audio_original'` alongside the existing
`'novella'`/`'novel'` (migration `20260907140000_work_type_audio_
original.sql`) -- use this instead of a separate flag, since work_type
is already the controlled-vocabulary field for "what kind of work is
this."

For Book DNA on an audio_original entry:
- `book_length`/`page_count`: leave NULL. There is no page count --
  don't force a value, don't estimate one from runtime.
- `audiobook_length`: the one real length signal, tag it normally.
- `prose_density`/`prose_complexity`: only tag if it genuinely maps to
  the drama's actual narration/dialogue style -- many full-cast audio
  dramas are almost entirely dialogue with minimal narration, which
  may make these concepts not meaningfully apply. Leave NULL rather
  than force a value that doesn't fit.
- Every other Book DNA field (pacing, tone, tropes, content warnings,
  genre) applies exactly as normal -- an audio original still has a
  real story with real pacing/tone/tropes, this isn't a lesser or
  partial tagging pass.
- Populate its OWN `audiobook_editions` row too (edition_type
  `'audio_original'`, unless it's better described as
  `dramatized_full_cast` if that's the more informative distinction --
  use judgment, note which you picked and why in your report).

### Candidate discovery

Browse Audible's own "Audible Originals" SFF/fantasy catalog listing.
For each one, check it's genuinely audio-only (no print/ebook edition
exists anywhere -- if it turns out to have a print counterpart you
find, it's a normal book, ingest it the regular way via
`tag-catalog-batch`, not this path) and genuinely in scope (sci-fi/
fantasy, per this catalog's v1 scope -- see CLAUDE.md's "Catalog scope"
section, same bar as any other book).

### Ingestion + tagging

Same conventions as `tag-catalog-batch`'s Step 3 (full Book DNA fields,
genre, tropes, content warnings, confidence layer for genuine
uncertainty) and its migration conventions (idempotent SQL, title+author
subselects never raw UUIDs, tested in a rolled-back transaction first).
Read that skill's Step 3 in full before starting this sub-task if you
haven't tagged books in this project before -- this reuses all of it,
just with a new `books` row to insert first (with `work_type =
'audio_original'`) instead of finding an existing untagged one.

## Migration conventions (both sub-tasks)

Same as everywhere else in this project (see CLAUDE.md): idempotent SQL
(`on conflict do nothing`), title+author-scoped (never a raw UUID),
tested in a rolled-back transaction first. Reserve migration timestamps
starting after whatever's latest in `supabase/migrations/` when you
start (`ls supabase/migrations/ | sort | tail -3` to check) -- this
project has hit real same-day timestamp collisions before when two
sessions work concurrently; run
`ls supabase/migrations/ | cut -c1-14 | sort | uniq -d` before you push
to confirm nothing collides with whatever else has landed since you
started.

## Report back

For Sub-task A: how many candidates GraphicAudio/BBC's own catalogs
produced before cross-referencing, how many real matches after
cross-referencing, how many you completed full research+insert for
this session, and anything genuinely ambiguous (a title match you
weren't confident about, a producer's site that was hard to search).

For Sub-task B: how many Audible Originals you found in-scope, how many
you fully ingested+tagged this session, and flag anything that turned
out to actually have a print counterpart (so it can be redirected to
normal ingestion instead) or anything you judged out of scope (and why).

Confirm whether migration files were pushed directly or handed back for
the repo owner to commit, same as `tag-catalog-batch`.
