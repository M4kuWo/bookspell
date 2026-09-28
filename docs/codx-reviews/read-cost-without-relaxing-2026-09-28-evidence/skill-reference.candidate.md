# Completed batch references

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

