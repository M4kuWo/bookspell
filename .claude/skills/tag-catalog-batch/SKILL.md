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

## Step 1.5: verify this skill still matches the live schema -- mandatory, every invocation

**Don't skip this because "the schema probably hasn't changed."** Real,
already-happened example (2026-09-12): this skill's own mandatory
`book_dna` column list (Step 3 below) silently fell a full column pair
behind the real schema for a full day after `romance_tone`/
`worldbuilding_delivery` landed, and its Step 0 described a mechanism
(inserting into `book_tropes`) that had been deleted the same day the
fields landed -- following the skill as-written would have either
silently under-tagged every book in the batch or failed outright. This
is now a standing CLAUDE.md rule ("Data quality / tagging"), and this
step is the mechanical enforcement of it.

Run this once, before tagging anything:

```sql
select column_name from information_schema.columns
where table_name = 'book_dna'
order by column_name;
```

Compare the result against Step 3's mandatory column list below (plus
`book_id`, `genre`, and the 5 excluded Tier B audiobook columns). If a
live column isn't on that list, or a listed column no longer exists:
**stop and fix Step 3's list (and this skill's other affected sections,
and the example INSERT) before tagging a single book** -- don't tag a
batch against a list you already know is stale, and don't silently work
around the mismatch by improvising what to do with the new column.
Flag it to the repo owner in your report either way, even after fixing
it yourself, since a live schema/skill mismatch this large usually means
`docs/schema/book-dna.schema.yaml`/`book-dna.md` need the same fix (see
the CLAUDE.md rule above).

## Step 0: PRIORITY BATCH -- romance_tone/worldbuilding_delivery backfill sweep (updated 2026-09-12 -- now scalar book_dna columns, not tropes)

**This takes priority over everything below, including the romance_driven
audit reference section right after it (that one is fully DONE now --
kept only for its calibration-anchor pattern and judgment-call
methodology, which this new batch reuses).**

### What this is

**These are no longer tropes.** Originally added as 4 tropes
(`understated_romance`/`melodramatic_romance_subplot`/
`worldbuilding_woven_into_narrative`/`worldbuilding_via_exposition_dump`,
2026-09-05/06) and validated on a small real-evidence-backed set, they
were converted 2026-09-11 into two real `book_dna` scalar columns --
`romance_tone` (`understated`/`melodramatic`/`mixed`) and
`worldbuilding_delivery` (`woven`/`exposition_dump`/`mixed`) -- and the
old trope IDs were permanently deleted from the vocabulary the same day
(see `docs/project-log.md`'s 2026-09-11 "Step 4" entry and
`docs/schema/book-dna.md` section 3 for the real field docs). **Do not
insert into `book_tropes` for any of the 4 old trope IDs -- they no
longer exist and the insert will fail a foreign-key check.** Every book
you tag from now on (in the normal Step 3 flow, not just this section)
gets `romance_tone`/`worldbuilding_delivery` filled in as part of its
regular `book_dna` INSERT -- see Step 3's mandatory-column note on this.

This section exists because ~700 books were already tagged BEFORE
2026-09-11 and only got these two fields via a mechanical backfill from
their old trope tags (if they had one) -- most didn't, since the
original trope sweep never finished. As of 2026-09-11: 160/867 tagged
books have a real `romance_tone`, 117/867 have `worldbuilding_delivery`
(query fresh, don't trust this snapshot -- it drifts as new batches land
both through this section and through ordinary Step 3 tagging). This is
genuinely harder tagging work than most of this skill's normal fields --
these are SUBJECTIVE EXECUTION/CRAFT judgments (how something is
written), not plot-event facts (whether something happened), and this
project already caught itself guessing wrong twice on exactly this kind
of call (see "The evidence standard" below for why that matters and what
to do about it).

`romance_tone` values:
- `understated` -- the romantic relationship is written with restraint:
  grounded, low on contrived misunderstandings/toxic push-pull, quiet in
  how affection is actually shown on the page.
- `melodramatic` -- repetitive "will they/won't they" tension,
  soap-opera-style romantic drama, heightened declarations and
  confrontations, played for extended emotional intensity rather than
  restraint.
- `mixed` -- a genuine tie (equal-confidence evidence on both sides), or
  a short-story collection/anthology that genuinely shows both tones
  across different stories (e.g. Sword of Destiny). Not a default/unsure
  bucket -- see "Confidence conventions" below for the real distinction
  between a genuine tie and low-confidence uncertainty.

`worldbuilding_delivery` values:
- `woven` -- lore/rules delivered through character discovery and
  dialogue rather than narrator exposition. Distinct from
  `worldbuilding_density` (how MUCH lore exists, not how it's delivered)
  -- a book can be `worldbuilding_density: dense` and still be `woven`
  (Book of the Ancestor is tagged dense on all 3 books and still the
  cleanest example of woven delivery).
- `exposition_dump` -- lore delivered primarily through narrator
  exposition, footnotes, or in-text lecture rather than in-scene
  discovery.
- `mixed` -- same genuine-tie standard as `romance_tone` above.

Leave the column NULL (not a value at all) when the book has too little
romantic content / worldbuilding-exposition to judge either axis -- see
Step 3's note on this above.

### The evidence standard -- read this before tagging a single book

This is the single most important thing in this section. The repo
owner set an explicit, precise boundary for `romance_tone` after this
project's own research caught itself guessing wrong twice (From Blood
and Ash and Fourth Wing were initially assumed melodramatic from genre
reputation alone -- real research showed the opposite; The Bear and
the Nightingale was initially tagged understated by conflating a slow
courtship BUILD-UP with a restrained EMOTIONAL PRESENTATION -- the
actual culminating scene turned out to be "quick and fierce," not
restrained at all):

**`romance_tone` evidence must describe emotional PRESENTATION/
EXPRESSION specifically -- how the feeling is shown on the page when a
romantic scene happens. The following do NOT count as evidence for
EITHER value, no matter how strongly worded:**
- how much romance there is, or how central it is to the plot (that's
  `drive`, a completely different, already-existing field -- do NOT
  infer tone from drive; a low-drive romance can be melodramatic OR
  understated in the exact same small amount of page time, and so can
  a high-drive one)
- how fast or slow the relationship develops ("slow burn" is a pacing
  fact, not a tone fact -- a slow-burn romance can still explode into
  melodrama once it lands, and a fast-developing one can stay quiet)
- whether the relationship is toxic, healthy, or has a power imbalance
  (that's a relationship-dynamic/content fact, closer to
  `content_warnings`, not a presentation-style fact)
- whether the romance is well-written, "expertly woven," or feels
  contrived (that's a craft-quality judgment, orthogonal to tone -- a
  badly-written romance can still be attempting either restraint or
  melodrama)
- explicitness/heat level (that's `romance_heat_intensity`, already a
  separate field -- a closed-door romance can be melodramatic in its
  emotional beats, and an explicit one can be emotionally restrained)

The only valid evidence is a real, findable description of HOW
characters express emotion in actual scenes: dramatic declarations,
storming off, tearful confrontations, repeated identical arguments
(melodramatic) vs. quiet gestures, understatement, restrained internal
narration, unshowy affection (understated). Ground every tag in real
research (web search for reader reviews/discourse quoting or
describing actual scenes), never pattern-matched from genre or a
book's general reputation -- both of tonight's caught mistakes came
from skipping this step.

### Confidence conventions

Recorded via `book_field_confidence` (`field_name = 'romance_tone'` or
`'worldbuilding_delivery'`), the same mechanism as any other uncertain
scalar field -- NOT `book_tropes.confidence` (that column doesn't apply
here anymore, these aren't tropes).

- Real, clear, presentation-specific evidence found -> tag at
  confidence 0.6 (`ai_inferred`).
- Genuinely disputed in real discourse, or you can only find
  drive/pacing/toxicity/quality evidence and nothing presentation-
  specific -> tag at confidence 0.2, NOT full confidence, and NOT
  skipped either -- `MIN_CONFIDENCE_TO_COUNT` (0.3) means this gets
  recorded and stays excluded from scoring/weight-learning until real
  validation raises it, which is exactly what it's for. Don't use 0.2
  as a shortcut to skip research, though -- it's for evidence you
  genuinely found and it genuinely came out mixed, not for "I didn't
  look."
- If the repo owner (or another rater) has personally read the book
  and confirms the tag directly -> confidence 1.0, `source:
  manual_review`.
- A genuine tie between both values (see "What this is" above) -> the
  value itself is `mixed`; confidence reflects how solid the evidence
  for BOTH sides was (0.6 if both sides are well-attested, 0.2 if both
  are weak/disputed), not a special "tie confidence."

### Calibration anchors -- already applied, do NOT re-tag these

**These already carry their `book_dna.romance_tone`/
`worldbuilding_delivery` value from the 2026-09-11 backfill migration --
confirmed live in the database, not just planned.** Listed here for the
judgment-call reasoning only, in case a similar book comes up during your
own research.

`romance_tone = 'melodramatic'`: A Court of Thorns and Roses, Twilight,
Shatter Me, Throne of Glass, The Wise Man's Fear, The Well of Ascension,
From Blood and Ash (confidence 0.2, was disputed).
`romance_tone = 'understated'`: Warbreaker, Six of Crows, Shadows of
Self, The Bands of Mourning, The Lost Metal, The Goblin Emperor, The
Traitor Baru Cormorant, The Priory of the Orange Tree, Spinning Silver,
The Bear and the Nightingale (confidence 0.2, was disputed).
`worldbuilding_delivery = 'woven'`: Red Sister, Grey Sister, Holy Sister
(all 3 Book of the Ancestor books, from one direct quote about the whole
trilogy), The Goblin Emperor, The Priory of the Orange Tree.
`worldbuilding_delivery = 'exposition_dump'`: Foundation, The Fellowship
of the Ring, The Lies of Locke Lamora, The Traitor Baru Cormorant.

A book that's confusing because NOTHING is explained (Gideon the Ninth,
Gardens of the Moon) is a `woven` candidate (or left null if genuinely
untagged), not `exposition_dump` -- the two failure modes look similar
in reader complaints ("I was lost") but come from opposite delivery
mechanisms, so read the actual complaint before assuming which axis it's
about.

### Candidate pool -- don't scan the whole catalog blindly

Both queries below are scoped to `book_dna` rows that ALREADY EXIST but
are missing the field (the backfill this section covers) -- a brand new
untagged book gets `romance_tone`/`worldbuilding_delivery` filled in
during its normal Step 3 tagging instead, not through this query.

```sql
-- romance_tone backfill candidates: already-tagged books with existing
-- romance signal but no romance_tone value yet
select distinct b.title, b.author, d.drive, d.romance_heat_frequency
from books b join book_dna d on d.book_id = b.id
left join book_tropes t on t.book_id = b.id
where d.romance_tone is null
  and (
    d.drive = 'romance_driven'
    or d.romance_heat_frequency in ('occasional', 'frequent')
    or t.trope_id in (
      'enemies_to_lovers','friends_to_lovers','forbidden_love','love_triangle',
      'fated_mates','soulmate_bond','arranged_marriage','marriage_of_convenience',
      'fake_dating','forced_proximity','only_one_bed','age_gap_romance',
      'second_chance_romance','grumpy_sunshine','slow_burn_romance',
      'monster_or_fae_romance','insta_love','hidden_identity_romance',
      'reverse_harem_or_why_choose','sapphic_romance','mlm_romance'
    )
  )
order by b.title;

-- worldbuilding_delivery backfill candidates: already-tagged, dense
-- worldbuilding (where this axis actually matters -- a light-
-- worldbuilding book has little exposition either way to judge the
-- delivery of), no worldbuilding_delivery value yet
select b.title, b.author
from books b join book_dna d on d.book_id = b.id
where d.worldbuilding_density = 'dense'
  and d.worldbuilding_delivery is null
order by b.title;
```

Both pools are large (likely 150-300+ books combined, and will keep
shrinking as ordinary Step 3 tagging of new books also fills these
fields in going forward) -- work through them in reasonably-sized
batches like any other pass this skill describes, prioritizing
well-known books with real, findable discourse first (an obscure book
with no reviews to check against isn't tractable for this kind of
tagging yet). Don't force a tag on a book where you can't find real
presentation-specific evidence either way -- leaving the column null is
the correct, honest outcome when the evidence isn't there, exactly like
this skill's existing "don't force-tag" policy for every other field.

### Before you finish this batch

Sanity-check your own batch before reporting done: are you tagging
BOTH directions (melodramatic AND understated, not just whichever
came to mind first), and does your low-confidence-tag rate look like
genuine research turning up mixed evidence rather than an excuse to
skip real research on the harder calls? If every single tag you
produced is confidence 0.6 with none at 0.2, either you got
consistently clean evidence (possible) or you're not finding/reporting
the genuinely disputed cases (more likely at any real scale) -- be
honest about which.

### Migration conventions for this batch

**You're writing UPDATEs on existing `book_dna` rows here, not INSERTs**
-- `on conflict do nothing` doesn't apply to an UPDATE. Idempotency
instead comes from guarding the WHERE clause with `is null`, so a re-run
of the same migration file is a safe no-op rather than clobbering a
value someone else already set in the meantime:

```sql
update book_dna set romance_tone = 'understated'
where book_id = (select id from books where title = 'Example Title')
  and romance_tone is null;

-- only when genuinely uncertain (see "Confidence conventions" above):
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Example Title'
on conflict (book_id, field_name) do nothing;
```

Same other conventions as everywhere else in this project (see
CLAUDE.md): title+author-scoped (never a raw UUID), tested in a
rolled-back transaction first. Check for same-day migration-timestamp
collisions before you push -- this project has hit real ones before (see
CLAUDE.md's own documented incidents) -- via `ls supabase/migrations/ |
sort | uniq -d`. Since you're working directly against hosted (see
"Setup" above), you don't need a separate local-apply step -- just
test-in-transaction, apply to hosted, then commit the migration file so
it's part of the tracked history (the repo owner's own local Postgres
will pick it up next time he re-syncs).

Log what you did to `docs/project-log.md` when you're done, same as
every other change in this project -- how many books reviewed, how
many tagged at each confidence level, and specifically flag any book
where the evidence was genuinely difficult to find or interpret, the
same way this project's own research flagged Caraval/The Bear and the
Nightingale as real judgment calls rather than clean yeses.

---

## Step 0 (previous, DONE) -- `romance_driven` catalog audit -- reference only

Kept for its judgment-call methodology and calibration-anchor pattern,
which the batch above reuses -- not something to redo. **All three
tiers are complete** -- see `docs/project-log.md`'s "romance_driven
catalog audit, Tier 1 + Tier 3 complete" and "romance_driven Tier 2
audit complete" entries. Tier 1 (20 candidates): 12 reclassified, 8
confirmed correctly unchanged. Tier 3 (19 candidates): zero
reclassifications, a legitimate "nothing to do here" result. Tier 2
(214 candidates): 19 reclassified, 195 confirmed correctly unchanged.
`book_dna.drive` has 45 `romance_driven` rows total. Don't re-review
any of this.

### What changed

`drive` (in the `pacing_tone` category) gained
a new value, `romance_driven`, alongside the existing
`character_driven`/`plot_driven`/`balanced`/`worldbuilding_driven`
(`20260904000000_add_romance_driven_to_drive_field.sql`). It captures
NARRATIVE CENTRALITY specifically -- when the central relationship(s),
not the external plot or a character's individual arc, is what a book
is actually about. This is different from `romance_heat_frequency`/
`romance_heat_intensity`, which measure explicitness, not centrality --
a book can be `frequent`/`explicit` and still have romance as a strong
supporting thread (not `romance_driven`), or have romance as the real
engine at a much lower heat level (a "clean"/closed-door romantasy).

No existing book was tagged with this value at the time it was added --
every already-tagged book's `drive` reflects the OLD 4-value vocabulary,
even books that should obviously be `romance_driven` now. **This audit
is what makes the new value actually mean anything** for scoring --
until real books carry it, it changes nothing (verified directly, see
docs/project-log.md's 2026-09-04 entry).

### Already resolved, use as calibration anchors -- do NOT re-review these

Confirmed `romance_driven` (unambiguous, already retagged):
**From Blood and Ash** (Jennifer L. Armentrout), **Daughter of No
Worlds** (Carissa Broadbent), **House of Earth and Blood** (Sarah J.
Maas).

Confirmed explicitly NOT `romance_driven` despite matching a naive
"frequent+explicit heat" filter -- real explicit content, but neither
is remotely romance-genre: **Gravity's Rainbow** (Thomas Pynchon,
`worldbuilding_driven` is correct), **Stranger in a Strange Land**
(Robert A. Heinlein, `worldbuilding_driven` is correct). This is the
exact reason a blanket reclassification of every matching book would be
wrong -- every candidate below needs a real per-book judgment call, not
a filter-and-replace.

### The judgment call

Ask: is the central relationship what this book is ABOUT -- the actual
plot engine -- or a strong supporting thread inside a plot/character-
driven story? If you can summarize the book's main conflict without
mentioning the romance at all and the summary still captures what the
book is actually about, it's probably NOT `romance_driven`. If the
romance IS the summary, it probably is.

Genuinely ambiguous cases (a mostly-plot-driven book with a very
strong, page-time-dominant romance subplot) -- use your judgment and
move on; this is closer to `message_intensity`'s own subjectivity than
a plot-event fact, not worth agonizing over any single title.

### Candidate pool, tiered by confidence -- work Tier 1 fully, Tier 2/3 as budget allows

Query (adjust `<threshold>` filters as shown per tier):

```sql
-- Tier 1 (21 books, HIGHEST confidence -- review all of these):
select b.title, b.author, d.drive, d.romance_heat_frequency, d.romance_heat_intensity
from books b join book_dna d on d.book_id = b.id
where d.drive != 'romance_driven'
  and d.romance_heat_frequency = 'frequent' and d.romance_heat_intensity = 'explicit'
order by b.title;

-- Tier 2 (~173 books, occasional heat -- most will correctly stay as-is,
-- review as budget allows):
select b.title, b.author, d.drive
from books b join book_dna d on d.book_id = b.id
where d.drive != 'romance_driven' and d.romance_heat_frequency = 'occasional'
order by b.title;

-- Tier 3 (~19 books, a romance-structural trope present but low/no heat
-- tagged -- catches closed-door/"clean" romantasy the heat filters miss):
select distinct b.title, b.author, d.drive
from books b join book_dna d on d.book_id = b.id
join book_tropes t on t.book_id = b.id
where d.drive != 'romance_driven'
  and t.trope_id = any(array['enemies_to_lovers','friends_to_lovers','forbidden_love',
    'love_triangle','fated_mates','soulmate_bond','arranged_marriage','marriage_of_convenience',
    'fake_dating','forced_proximity','only_one_bed','age_gap_romance','second_chance_romance',
    'grumpy_sunshine','slow_burn_romance','monster_or_fae_romance','insta_love',
    'hidden_identity_romance','reverse_harem_or_why_choose'])
  and coalesce(d.romance_heat_frequency, 'none') not in ('occasional', 'frequent')
order by b.title;
```

Tier 1's 21 titles as of 2026-09-04 (re-run the query above for the
current live list, this may drift as more books get tagged): A Court
of Frost and Starlight, A Court of Mist and Fury, A Court of Silver
Flames, A Court of Thorns and Roses, A Court of Wings and Ruin, Bride,
Empire of Storms, Fourth Wing, Gravity's Rainbow (already resolved --
NOT romance_driven), House of Flame and Shadow, House of Sky and
Breath, Iron Flame, Kingdom of Ash, One Last Stop, Onyx Storm,
Outlander, Quicksilver, Stranger in a Strange Land (already resolved --
NOT romance_driven), The Serpent and the Wings of Night, The Time
Traveler's Wife, When the Moon Hatched.

Real expected outcome for several of these, so you're calibrated before
starting: later books in an ongoing plot-heavy series (Empire of
Storms/House of Flame and Shadow/House of Sky and Breath/Kingdom of
Ash -- all Sarah J. Maas, already `plot_driven`; Onyx Storm -- Rebecca
Yarros, already `plot_driven`) are plausibly CORRECT as-is even with
frequent/explicit heat, since by that point in their respective series
the external plot (war, political conflict) has often become the real
engine -- don't assume "later book in a romantasy series" automatically
means leave it alone OR automatically means reclassify; check each one.

### Writing the migration

Same conventions as everywhere else in this project (CLAUDE.md): one
`update book_dna set drive = 'romance_driven' where book_id = (select
id from books where title = '...')` per confirmed book, title-scoped
never a blanket UPDATE, tested in a rolled-back transaction first,
timestamped migration file with your reasoning in the comment (why this
specific book, not just "matched the filter"), applied to local via the
raw psycopg2 script then hosted via `supabase db push`, verified
matching (row count and a spot-check) on both sides. Log the batch to
docs/project-log.md when done (how many reviewed, how many actually
reclassified, any genuinely uncertain calls flagged for the repo owner)
-- this project's standing practice, not optional.

**No other new fields/values from this session need a catalog-wide
pass** -- everything else added recently (the protagonist-competence/
narrative-favoritism/romance-tone backlog ideas) is logged as a
proposal only, not a real schema field yet, so there's nothing to
retag for those.

---

## Step 0 (original, DONE) -- reference only

**UPDATE (2026-09-03, later still): both priority items below are now
DONE.** The original 23/25-book batch was tagged, density-audited, and
verified (see docs/project-log.md's independent-audit entry). "City"
(Clifford D. Simak) was also tagged directly (see docs/project-log.md's
own entry) -- HIGH_RISK_FIELDS checked against the actual text,
`genre_accessibility` computed via the documented formula, 6 tropes
individually justified, no content warnings forced. Not something to
redo.

---

The original priority batch (DONE, reference only): before running
Step 2's normal partial-series-first query, these 23 specific books
were tagged first, regardless of what that query would otherwise
surface. They were bibliographically ingested 2026-09-03
(`supabase/migrations/20260903170000_targeted_ingestion_mathias_priority_list.sql`)
specifically because the repo owner (Mathias) named and rated every one
of them from memory -- tagging them unlocks real, already-collected
enjoyment signal immediately (`data/ratings/mathias.json`), rather than
sitting untagged and invisible to the recommendation engine while the
normal batch order works through less-verified titles first.

- Kings of Ash, Kings of Heaven (Richard Nell, Ash and Sand #2-3)
- Valor (John Gwynne, Faithful and the Fallen #2)
- The Grey Bastards, The True Bastards (Jonathan French, The Lot Lands #1-2)
- An Echo of Things to Come, The Light of All That Falls (James Islington,
  The Licanius Trilogy #2-3 -- #1, The Shadow of What Was Lost, is
  already tagged)
- The Pariah, The Martyr, The Traitor (Anthony Ryan, Covenant of Steel #1-3)
- Aching God (Mike Shel, Iconoclasts #1)
- The Vagrant, The Malice (Peter Newman, The Vagrant #1-2 -- note this
  "The Malice" is a different book from John Gwynne's "Malice", already
  tagged, in the Faithful and the Fallen series; don't conflate the two
  when tagging)
- The Justice of Kings (Richard Swan, Empire of the Wolf #1)
- I'm Afraid You've Got Dragons (Peter S. Beagle -- named by the repo
  owner as Peter McLean's, but no such title exists under that author;
  this is the actual book found and ingested, flagged for him to
  confirm it's the one he meant)
- The Wandering Inn (pirateaba -- ingested as one representative entry
  for this very long ongoing web serial, not the whole thing)
- Prince of Fools, The Liar's Key, The Wheel of Osheim (Mark Lawrence,
  The Red Queen's War #1-3)
- Blackwing (Ed McDonald, Raven's Mark #1)
- Firestarter (Stephen King, standalone)
- The Initiate, The Outcast, The Master (Louise Cooper, Time Master #1-3)
- One Word Kill (Mark Lawrence, Impossible Times #1) -- ingested but
  deliberately has NO rating on file yet (repo owner's reaction was
  ambiguous between disliked/it_was_okay); tag it normally, the missing
  rating doesn't block tagging.

Ender's Shadow (Orson Scott Card) was also on the repo owner's list but
is already tagged -- not part of this priority batch.

Within this list, prioritize completing the partial series first (the
Licanius and Vagrant entries above, since book 1 of each is already
tagged) -- same reasoning as Step 2 below.

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

**Skip and flag any graphic novel/comic that surfaces in this query --
they're out of v1 scope** (decided 2026-09-04, CLAUDE.md's Catalog
scope section). Don't treat an already-tagged comic (if one somehow
still exists) as precedent that they're fine to tag -- that's exactly
how this gap grew from one book to three before it was caught.

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
  book-dna.md's backlog, and need real listening/performance-review
  evidence we don't have. **Not the same gap as `audiobook_editions`**
  (a separate table, not `book_dna`) -- that table DOES have real
  narrator-identity data now for most books with a `hardcover_id`
  (1026+ standard-edition rows across 786+ books, bulk-populated via
  `scripts/backfill-standard-narrators.js`, see
  `docs/project-log.md`'s 2026-09-11 entries). Knowing WHO narrates a
  book is a different, already-solved question from judging HOW WELL
  they perform it -- Tier B needs the latter, which narrator identity
  alone can't answer. Nothing for you to do here per-book either way:
  `audiobook_editions` is populated by that separate bulk script against
  Hardcover's API, not by hand during tagging -- if you notice a newly
  ingested book has no `audiobook_editions` row yet, that's expected
  until the next bulk run, not something to research and insert
  yourself).
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
romance_heat_frequency, romance_heat_intensity, romance_tone,
violence_frequency, violence_intensity, worldbuilding_density,
worldbuilding_delivery, narrative_closure, emotional_resolution,
ends_on_cliffhanger, audiobook_length, magic_system_hardness,
scifi_hardness, prose_density, prose_complexity, intellectual_weight,
stakes_scope, personal_stakes, genre_accessibility` -- plus `genre`.
(Leave out the 5 Tier B audiobook columns mentioned above -- those stay
null on purpose.) If a field genuinely doesn't apply to a book (e.g.
`romance_heat_frequency` on a book with zero romance), use its `none`
value if the schema defines one for that field -- don't just omit the
column.

**`romance_tone` and `worldbuilding_delivery` are the two genuine
exceptions to "always fill every column"** -- unlike every other field
above, they have no `none` value on their enum (`understated`/
`melodramatic`/`mixed` and `woven`/`exposition_dump`/`mixed`
respectively) because "not applicable" and "a real tagged value" aren't
the same thing here. Leave them NULL when the book has too little
romantic content (`romance_tone`) or too little worldbuilding/exposition
to judge the delivery of either way (`worldbuilding_delivery`) -- don't
force a value onto a book where the axis doesn't meaningfully apply. See
"Tagging romance_tone and worldbuilding_delivery" below for the real
evidence standard before assigning either one; it's substantially
stricter than this skill's other fields, for a documented reason.

**`genre_accessibility` (added 2026-09-03) works differently from every
other field above -- start from a computed baseline, then adjust, don't
assign from scratch.** Once you've settled on this book's
`prose_complexity`, `overall_pace`, `worldbuilding_density`, `pov_count`,
and `intellectual_weight`, compute a 0-1 "demand" score by averaging
their positions (`prose_complexity`: accessible=0/moderate=0.5/dense=1;
`overall_pace` INVERTED, since fast=accessible: slow=1/medium=0.5/fast=0;
`worldbuilding_density`: light=0/moderate=0.5/dense=1; `pov_count`:
single=0/dual=0.25/few=0.5/several=0.75/ensemble=1; `intellectual_weight`:
escapist=0/moderate=0.5/cerebral=1), then bucket it: <0.2 gateway, <0.4
accessible, <0.6 moderate, <0.8 demanding, else veteran_only. THEN
adjust that computed baseline up or down one tier if the book's actual
premise familiarity differs from what those 5 craft fields alone would
suggest -- a mainstream, culturally-familiar premise (superheroes, a
school setting) can make a structurally demanding book land more
welcoming than the formula alone implies; conversely a book with simple
prose but a dense invented pantheon and no glossary can be less welcoming
than its craft fields alone suggest. This adjustment is the one thing
about this field a formula can't do, and the actual reason it's a real
tagged field instead of something computed silently at query time.

Write every insert as a SCOPED statement tied to a specific book, using a
`select id from books where title = '...'` subselect for the book_id --
**not a raw UUID pasted from a query result.** This matters specifically
because you're working against the hosted database, which has different
row UUIDs than anyone else's local database for the same logical books
-- a title-keyed subselect is portable across both, a hardcoded UUID
only works in the one database you copied it from. This is the same
pattern every migration in this project already uses. Never a blanket
UPDATE or DELETE across multiple rows.

**If you build a title -> book_id lookup in a script for a whole batch
(rather than one subselect per statement), don't key it on title alone
without checking for duplicates first.** Real, already-happened example
(2026-09-04): the catalog has two entirely different books both titled
"The One" (Kiera Cass's Selection #3, John Marrs's unrelated sci-fi
thriller); a plain `{title: book_id}` dict let the second row silently
overwrite the first, so one book's Book DNA got applied to the other
book's `book_id` and the intended book was left completely untagged --
while the script's own success output still listed it as committed. No
error, no warning, just a silently wrong book_id. Query `select title,
count(*) from books group by title having count(*) > 1` before trusting
a title-keyed dict, or key it on `(title, author)` instead, or make
duplicate-key construction raise loudly rather than silently picking a
winner. (As of 2026-09-04 this is the only duplicate title in the whole
catalog and it's now fixed -- but a future ingestion could introduce
another one, so keep checking rather than assuming it stays unique.)
Complete example, every real column filled in (not abbreviated -- copy
this shape exactly):

```sql
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven',
  'dark', 'light', 'tense', 'moderate',
  'none', 'closed_door', null,
  'occasional', 'graphic', 'moderate',
  null, 'requires_series',
  'bittersweet', 'cliffhanger', 'standard',
  'soft', 'na', 'moderate', 'moderate',
  'moderate', 'regional', 'high', 'moderate'
  -- romance_tone/worldbuilding_delivery left null here since this is a
  -- generic placeholder with no real romance/worldbuilding content to
  -- judge -- a real book with either axis present would carry a real
  -- value ('understated'/'melodramatic'/'mixed',
  -- 'woven'/'exposition_dump'/'mixed'), never guessed from genre alone.
  -- genre_accessibility: prose_complexity=moderate(0.5), overall_pace=fast
  -- (inverted: 0), worldbuilding_density=moderate(0.5), pov_count=few(0.5),
  -- intellectual_weight=moderate(0.5) -> average 0.4 -> 'moderate' tier.
  -- Adjust from this computed baseline for premise-familiarity if
  -- warranted (see the paragraph above) -- not done here, since this is
  -- a generic placeholder example, not a real book with a real premise.
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

**Before you move on to Step 4, check your batch's own trope/content-
warning density against the catalog average -- this is a required gate,
not an optional nice-to-have.** This exact failure has already happened
twice on this project: a full batch shipped meaningfully thinner than
the rest of the catalog (tropes/book visibly declining across
sub-batches WITHIN the same tagging session -- a real rushing/fatigue
pattern as a big batch drags on, not random variance), and it wasn't
caught until a separate session audited it afterward and had to run a
whole second enrichment pass to fix trope and content-warning counts.
Catching it now, before you report the batch done, is far cheaper than
someone else catching it later. Run this once you've tagged the whole
batch (substitute your batch's actual titles):

```sql
with batch as (
  select b.id from books b
  where b.title in ('Title One', 'Title Two', '...')  -- your batch's titles
),
catalog_avg as (
  select
    (select count(*) from book_tropes)::float
      / nullif((select count(*) from book_dna), 0) as tropes_per_book,
    (select count(*) from book_content_warnings)::float
      / nullif((select count(*) from book_dna), 0) as cws_per_book
),
batch_avg as (
  select
    (select count(*) from book_tropes where book_id in (select id from batch))::float
      / nullif((select count(*) from batch), 0) as tropes_per_book,
    (select count(*) from book_content_warnings where book_id in (select id from batch))::float
      / nullif((select count(*) from batch), 0) as cws_per_book
)
select catalog_avg.tropes_per_book as catalog_tropes_per_book,
       batch_avg.tropes_per_book as your_batch_tropes_per_book,
       catalog_avg.cws_per_book as catalog_cws_per_book,
       batch_avg.cws_per_book as your_batch_cws_per_book
from catalog_avg, batch_avg;
```

Query the catalog average fresh every time -- don't reuse a remembered
number from a previous session or from this doc, it drifts as the
catalog grows. If your batch's tropes/book or CW/book comes out
meaningfully below the catalog's (as a rough rule of thumb, more than
~20% below on either number), don't finish and report yet -- go back
through the batch's thinner books specifically and add more tropes/
content warnings before moving to Step 4. A book landing below average
isn't automatically wrong (some books really are sparser than others),
but a whole BATCH sitting well below average is the under-tagging
signal this check exists to catch.

If you genuinely don't know a book well enough to tag it confidently
even after thinking it through, do a quick check (a web search is fine)
before guessing -- and if you're still not confident, skip that book and
say so in your report rather than fabricating tags for a book you don't
actually know.

**The more common and more dangerous failure isn't "I don't know this
book" -- it's being confidently WRONG on one specific mechanical
detail while genuinely knowing the book well overall.** Every real
tagging error caught by external readers so far came from exactly this:
over-pattern-matching to genre convention instead of checking the
actual book. Two real examples, already fixed: Dungeon Crawler Carl was
tagged `person: third_limited` because LitRPG "usually reads that way,"
when it's actually first-person throughout (one of the series' defining
stylistic choices); Empire of Silence was tagged with the `first_contact`
trope because space-opera-with-aliens "is usually" a first-contact
story, when the war in it has been going on for a long time before the
narrative even starts. Neither of these felt uncertain to tag -- that's
exactly the problem, and "if uncertain, check" doesn't catch it.

**For these specific fields -- `person`, `pov_count`,
`narrator_reliability`, `magic_system_hardness`, `overall_pace`,
`romance_heat_intensity`, `drive`, `stakes_scope`, `narrative_closure`,
`humor_level` -- do a quick check (a synopsis, a web search) even when
you feel confident**, not just when you feel unsure. This list has a
confirmed real-error track record and is expected to keep growing, not
shrink -- treat any field on it as worth the extra 30 seconds. The same
applies to any trope asserting a specific plot beat actually happens in
the book (not just a general theme or setting) -- verify the beat
itself occurs, don't infer it from the setting being the kind of place
where it commonly would.

**Check the book's `author` field before trusting it, if it looks like
`"Name, Name, Name"`.** A real, widespread data-quality issue (65 of 606
books, from Hardcover's ingestion pulling in every "contributor" credit,
not just the author) means a second or third name is very often an
illustrator, translator, or narrator, not a co-author -- distinguish
genuine multi-author books (which are real and common) before assuming
either way, and flag it in your report if you spot a contaminated one
rather than silently working around it.

**Two schema values were added recently (2026-09-01) that are easy to
default past out of habit** if you're recalling the schema from memory
rather than reading it fresh: `narrator_reliability` now has a third
value, `ambiguous` (distinct from `unreliable` -- use it when the text
deliberately withholds what's needed to judge the narrator's honesty
either way, not just because the narrator has a strong voice), and two
new craft_devices tropes exist (`retrospective_memoir_narration` for a
protagonist recounting their own past from a later vantage point, and
`multiple_alien_species`, the sci-fi analog to `multiple_fantasy_species`).
Re-read `docs/schema/book-dna.schema.yaml` fresh rather than relying on
a previous session's memory of it.

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
series moved closer to (or reached) full completion, your batch's
tropes/book and content-warnings/book from the density self-check above
alongside the catalog average you compared against (not just "I did the
check" -- the actual numbers), and confirm whether the migration file
was pushed or handed back for the repo owner to commit.
