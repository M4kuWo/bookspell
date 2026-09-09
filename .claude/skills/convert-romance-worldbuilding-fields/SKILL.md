---
name: convert-romance-worldbuilding-fields
description: One-time migration converting Bookspell's romance_tone and worldbuilding_delivery trope pairs (understated_romance/melodramatic_romance_subplot, worldbuilding_woven_into_narrative/worldbuilding_via_exposition_dump) into real book_dna scalar fields, and backfilling every existing tag.
---

# Convert romance_tone/worldbuilding_delivery from trope pairs to scalar fields

Bookspell is a sci-fi/fantasy book recommendation app built on structured
"Book DNA" attributes. Two execution-craft signals — how a book's romance
is toned (restrained vs. melodramatic) and how its worldbuilding is
delivered (woven into the narrative vs. exposition-dumped) — were
deliberately tagged as **trope pairs** first, as a cheap validation probe
using existing trope machinery, before committing to real schema (see
`docs/schema/book-dna.md`'s "Romance TONE/execution-quality" entry and
`docs/scoring-test-protocol.md`'s 2026-09-05 "Execution-DNA validation
probes" entry). The probe validated — correctly-signed weights, confirmed
in production scoring — and a multi-week tagging sweep has since built up
real data. This skill converts that data into proper scalar fields.

**Scope boundary, read this first**: this is a **schema + data migration
only**. It does NOT touch `scripts/recommend.py` or
`scripts/scoring_tests.py` — those changes (making the new fields actually
participate in scoring, replacing the old trope-based signal) are handled
separately, in the main conversation with the repo owner, not by this
skill. If you find yourself about to edit either of those files, stop —
that's out of scope here.

**This is a genuinely different shape of task than `tag-catalog-batch` or
`tag-audiobook-editions`** — it's a one-time structural migration, not a
repeatable batch process. Still follow the same bounded-step discipline:
do ONE step below, verify it, stop and report. Don't chain steps together
in one sitting even though the total row counts are small enough that you
technically could.

## Setup (one-time)

Same as every other skill in this project: `DATABASE_URL` set to the
**hosted** Bookspell Postgres connection string via an exported shell
variable in your own terminal session (never edit the shared `.env`,
never commit or paste the connection string anywhere). Ask the repo owner
directly if you don't have it.

## The schema decision (already made, don't re-litigate)

Two new nullable `book_dna` columns:

```sql
alter table book_dna add column romance_tone text
  check (romance_tone = any (array['understated', 'melodramatic', 'mixed']));
alter table book_dna add column worldbuilding_delivery text
  check (worldbuilding_delivery = any (array['woven', 'exposition_dump', 'mixed']));
```

**Why 3 values, not the clean 2 you might expect**: as of 2026-09-09,
book_tropes has a handful of books tagged with BOTH tropes in a pair —
not a bug, real evidence found both ways during tagging (see "The overlap
cases" below). `mixed` is a real, honest third value for those, not
scope creep — dropping one side's evidence to force a binary choice would
be less accurate than the data actually supports. `NULL` (the default for
every other untagged book) means "no clear evidence either way," same
semantics as every other optional field in this schema — it is NOT the
same thing as `mixed` (evidence found on both sides vs. no evidence
found at all).

**Why these specific value names**: `understated`/`melodramatic` and
`woven`/`exposition_dump` are shortened versions of the existing trope
IDs (`understated_romance` → `understated`, etc.) — kept close to the
original vocabulary on purpose, for traceability back to the trope-era
data and the existing prose that already describes these values
throughout `docs/schema/book-dna.md` and `docs/scoring-test-protocol.md`.

## Step 1: add the columns, verify, stop

Run the two `alter table` statements above (test in a rolled-back
transaction first, per this project's standing convention). Both are
purely additive (new nullable columns) — zero risk to existing data.
Save as its own migration file
(`supabase/migrations/<timestamp>_add_romance_worldbuilding_fields.sql`),
apply to both local and hosted, verify the columns exist on both with a
schema query. **Stop here and report before starting Step 2** — confirm
the columns exist and are genuinely nullable/unconstrained-until-backfill
before anything tries to write to them.

## Step 2: find the current overlap cases FRESH, don't trust this doc's snapshot

The tagging sweep is still ongoing — more books may have been dual-tagged
since this was written. Before backfilling anything, re-run this query
yourself:

```sql
-- romance overlap
select b.title, b.author, t.trope_id, t.confidence from books b
join book_tropes t on t.book_id = b.id
where t.trope_id in ('understated_romance', 'melodramatic_romance_subplot')
and b.id in (
  select book_id from book_tropes where trope_id = 'understated_romance'
  intersect
  select book_id from book_tropes where trope_id = 'melodramatic_romance_subplot'
)
order by b.title, t.trope_id;

-- worldbuilding overlap (same shape)
select b.title, b.author, t.trope_id, t.confidence from books b
join book_tropes t on t.book_id = b.id
where t.trope_id in ('worldbuilding_woven_into_narrative', 'worldbuilding_via_exposition_dump')
and b.id in (
  select book_id from book_tropes where trope_id = 'worldbuilding_woven_into_narrative'
  intersect
  select book_id from book_tropes where trope_id = 'worldbuilding_via_exposition_dump'
)
order by b.title, t.trope_id;
```

**As of 2026-09-09, 5 books had this** (recheck before trusting these are
still current, or the only ones):

| Book | Pair | Confidences | Resolution |
|---|---|---|---|
| Sword of Destiny | romance | 0.6 / 0.6 (tied) | `mixed` -- a short-story collection, genuinely has both tones across different stories |
| Mistborn: The Final Empire | worldbuilding | 0.2 / 0.2 (tied) | `mixed` -- both weak/disputed, no clear winner |
| A Master of Djinn | worldbuilding | woven 0.6 / exposition_dump 0.2 | `woven` -- higher-confidence side wins |
| Gideon the Ninth | worldbuilding | woven 0.6 / exposition_dump 0.2 | `woven` -- higher-confidence side wins |
| Homeland | worldbuilding | woven 0.6 / exposition_dump 0.2 | `woven` -- higher-confidence side wins |

**The resolution RULE, apply it to whatever the fresh query actually
returns, not just this table**:
- Confidences differ -> the higher-confidence trope's value wins, its
  confidence carries over, the lower-confidence side is dropped (treated
  as noise/minor dispute that doesn't override a clear signal).
- Confidences are equal (a genuine tie) -> value is `mixed`, confidence
  is that shared value.
- If you find a NEW overlap case this doc doesn't list, apply the same
  rule -- don't stop and ask unless the confidences are equal AND you
  have a real reason to doubt the tie is genuine (e.g. one looks like a
  copy-paste duplicate rather than two independent judgment calls).

## Step 3: backfill, verify counts match exactly, stop

For every book with exactly ONE of a pair's two tropes, direct 1:1
mapping. For the overlap cases, apply Step 2's resolution rule. Example
shape (adjust for the real overlap list from your fresh Step 2 query):

```sql
-- single-tag books, romance_tone
update book_dna set romance_tone = 'understated'
where book_id in (
  select book_id from book_tropes where trope_id = 'understated_romance'
  except select book_id from book_tropes where trope_id = 'melodramatic_romance_subplot'
);
update book_dna set romance_tone = 'melodramatic'
where book_id in (
  select book_id from book_tropes where trope_id = 'melodramatic_romance_subplot'
  except select book_id from book_tropes where trope_id = 'understated_romance'
);
-- overlap cases, resolved per Step 2 (one statement per book, title/author-scoped, never a raw UUID)
update book_dna set romance_tone = 'mixed'
where book_id = (select id from books where title = 'Sword of Destiny' and author = 'Andrzej Sapkowski');
-- ... same pattern for worldbuilding_delivery (values: 'woven', 'exposition_dump', 'mixed')
```

Also backfill `book_field_confidence` for every book you just set a value
for (confidence = the value described in Step 2's table/rule, `source =
'ai_inferred'`), same idempotent `on conflict (book_id, field_name) do
nothing` pattern used everywhere else in this project.

**Verify before moving on, don't just trust the UPDATE ran**:
```sql
select count(*) from book_dna where romance_tone is not null;
select count(*) from book_dna where worldbuilding_delivery is not null;
```
These must equal the number of DISTINCT books that had at least one of
each pair's tropes (i.e. union, not sum -- a dual-tagged book counts
once). Also spot-check a handful of individual books (including all the
overlap cases) match what you intended.

Test the whole backfill in a rolled-back transaction first, same as
always. Save as its own migration file, apply to both local and hosted,
re-verify the counts on hosted via REST or a direct query. **Stop and
report before Step 4** -- this is the step most likely to have a subtle
bug (an off-by-one in the overlap handling, a title that doesn't match
due to a Unicode-apostrophe mismatch like this project has hit before),
so give it a real, separate verification pass rather than rolling
straight into cleanup.

## Step 4: remove the old trope data, only after Step 3 is verified correct

Once you're confident the backfill is complete and correct (not just
"the UPDATE didn't error" -- the count-verification above passed):

```sql
delete from book_tropes where trope_id in (
  'understated_romance', 'melodramatic_romance_subplot',
  'worldbuilding_woven_into_narrative', 'worldbuilding_via_exposition_dump'
);
```

Verify zero rows remain for these 4 trope IDs before proceeding. Then
remove the trope vocabulary entries themselves (they should never be
tagged again once the scalar fields exist):

```sql
delete from tropes where id in (
  'understated_romance', 'melodramatic_romance_subplot',
  'worldbuilding_woven_into_narrative', 'worldbuilding_via_exposition_dump'
);
```

Per CLAUDE.md's standing rule, check dependent rows first (should be
zero in `book_tropes` after the delete above -- confirm before deleting
from `tropes` itself, not just assumed). Save as its own migration file,
apply to both, verify.

## Report back

For each step: what ran, the before/after row counts, and confirmation
the verification query passed. For Step 2/3 specifically: the FULL list
of overlap cases you actually found (not just confirming this doc's
5 still apply) and exactly how each was resolved. Confirm whether
migration files were pushed directly or handed back for the repo owner
to commit, same as every other skill in this project.

**When this is fully done, flag it back to the repo owner directly** (not
just in a log entry) -- the `recommend.py`/`scoring_tests.py` changes
that make these new fields actually participate in scoring are a
separate, deliberately-not-included piece of work that needs to happen
next, in the main conversation, not here.
