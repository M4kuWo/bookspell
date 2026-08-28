# Schema stress-test findings — 30-book blind tagging pilot

Source: `tagged-books.yaml`, produced by 6 parallel research batches (5
books each), each grounded in real synopsis/review research, tagged
**before** any read/liked/unread reveal. This is the first time the
schema met real books instead of brainstormed examples, and it surfaced
concrete gaps a pure vocabulary review couldn't have.

## 1. Genre scope — working as intended, one real edge case

2 of 30 books are genuinely out-of-scope genres, correctly flagged as
poor fits rather than silently forced in: **Bird Box** (horror —
deliberately unexplained entities, no established lore/rules) and
**The Road** (literary post-apocalyptic, no SF/F furniture at all). This
isn't a schema failure — it's the sci-fi/fantasy v1 scope decision doing
exactly its job. These books shouldn't be in a real v1 catalog anyway.

**Corrected on user review: Interview with the Vampire is NOT a poor
fit.** The initial tagging flagged it as out-of-scope gothic/paranormal
horror, but vampirism is classic supernatural fantasy genre furniture
with internally-consistent rules (turning, blood-bond, aging-halt) — a
legitimate, if darker-toned, fantasy subtype, not a compromise tag. The
real distinguishing test turned out to be "does the book supply an
established supernatural framework with rules," not "does it read as
dark/horror-adjacent in tone" — Bird Box and The Road both fail that
test; Interview with the Vampire passes it.

Two books blend sci-fi and fantasy within scope — **Perdido Street
Station** (New Weird) and **The Gunslinger** (dark fantasy/western/sci-fi)
— and the existing multi-select `genre: [sci_fi, fantasy]` already handled
both correctly. No fix needed there.

One real edge case: **Prince of Thorns** only reveals its far-future
post-apocalyptic setting deep into its series — book 1 alone reads as
pure fantasy. Worth a note for later (does genre tagging need to account
for a book whose true genre only becomes clear mid-series?), not an
urgent fix.

## 2. Missing tropes — the most actionable finding

14 concrete gaps surfaced from real books, not brainstorming — roughly 1
in 2 books in this sample flagged at least one. Two are entire subgenres,
not edge cases:

- **LitRPG / progression fantasy** (He Who Fights with Monsters) — "died
  and reincarnated into a game-ruled world" has no vocabulary home despite
  being a large, active subgenre. Related: no `form` value exists for
  embedded stat-block/level-up text.
- **Mythological retelling** (Circe) — a currently large, booming category
  (Circe, Song of Achilles, and similar) with zero coverage.

Plus 12 more specific, well-defined device gaps: weaponized
children/child soldiers (Ender's Game), self-replicating consciousness
(We Are Legion), species-divergence/evolutionary split (The Time
Machine), relativistic time dilation as a hard-SF device (The Forever
War), shadow-self integration arc (A Wizard of Earthsea), noir-detective
plot structure (Leviathan Wakes), New Weird setting-blend (Perdido Street
Station), telepathic/empathic animal bond (Assassin's Apprentice),
mutual human-alien war distinct from one-sided invasion + aging-reversal
premise (Old Man's War, two gaps), unseen/unknowable horror entity +
sensory-deprivation survival (Bird Box — informational only, out of
v1 scope), comedic/satirical sci-fi as a device (Hitchhiker's Guide).

**Recommendation:** add the two subgenre-scale gaps and the specific
device gaps now — these are validated by real failure cases, which is
stronger evidence than either prior research pass (which searched for
gaps in the abstract). Bird Box's horror-specific gaps stay out per the
genre-scope decision above.

## 3. Missing content warning

**Cannibalism** (The Road) — central to the book's horror, no vocabulary
match; approximated imperfectly with `torture`+`body_horror`. Clear add.

Weaker, single-data-point case: **disfigurement-based discrimination**,
distinct from `ableism_depicted` (Kings of Paradise's Ruka is ostracized
for disfigurement, not disability) — flagging, not recommending outright
on one example.

## 4. Field-level gaps

- **`magic_system_hardness`: `none` vs. `na` was never actually defined**
  — the fork had to infer a convention (na = non-magic genre entirely;
  none = fantasy book with no magic system). Cheap fix: just document the
  distinction, no structural change needed.
- **`drive` has no "worldbuilding-driven" option** — Perdido Street
  Station didn't fit `character_driven`/`plot_driven`/`balanced`; reviews
  consistently frame New Weird as driven by the setting itself. Worth
  adding as a 4th value.
- **`person` and `timeline` are single-value per book, but The Fifth
  Season mixes person across POV threads (2nd person for one thread, 3rd
  for others) and runs 3+ interwoven, non-chronological timelines** — the
  existing `dual_timeline` value only covers two. One data point, but a
  Hugo-winning, well-known structural technique, not a fluke. Proposed
  fix: generalize `dual_timeline` → `multi_timeline`, add `person: mixed`.
- **`narrator_reliability`'s reliable/unreliable binary doesn't capture
  "deliberately disorienting narration style"** distinct from
  untrustworthiness (Neuromancer's jargon-dense prose). Real, but needs
  more design thought than a quick patch — candidate for the future-fields
  backlog rather than an immediate fix.
- **`content_warnings` is schema-flagged `spoiler: false` globally, but a
  specific warning's presence can itself be a spoiler on a specific book**
  (Perdido Street Station's `sexual_assault` is a late-revealed plot
  point, not foreshadowed). This mirrors exactly how `severity` already
  works — per (book, warning), not fixed to the vocabulary item. Proposed
  fix: add a per-instance `reveals_spoiler` flag alongside `severity`,
  same mechanism, not a new concept.

## 5. Tagging-process observations (not schema bugs)

Several books (Kings of Paradise, parts of Prince of Thorns, He Who Fights
with Monsters, Interview with the Vampire) had explicitly low-confidence
fields where synopsis + review research gave tone/structure but not
plot-specific or system-specific detail. This matches a risk the
project's own data-sourcing plan already named: synopsis+reviews are a
reliable source for tone and structure, less reliable for spoiler-adjacent
plot specifics — worth expecting this at real tagging scale (step 04),
not a flaw in this pilot's method.

## Summary — what was actually done (applied)

Reviewed with the user and applied to both the schema and the tagged
corpus:

- **13 new tropes added**, all traced to the specific book that surfaced
  the gap: `litrpg_or_progression_fantasy`, `mythological_retelling`,
  `child_soldiers_in_warfare`, `self_replicating_consciousness`,
  `species_divergence`, `relativistic_time_dilation`,
  `shadow_self_confrontation`, `noir_detective_structure`,
  `new_weird_setting`, `telepathic_animal_bond`, `mutual_human_alien_war`,
  `aging_reversal_or_rejuvenation`, `satirical_or_comedic_scifi`.
- **`drive: worldbuilding_driven`** added; Perdido Street Station retagged.
- **`magic_system_hardness` none/na** distinction documented.
- **`content_warnings` gets a per-instance `reveals_spoiler` flag**
  alongside `severity` — same mechanism, not a new concept. Applied to
  Perdido Street Station's `sexual_assault` (the concealed-crime case
  that surfaced the gap); not exhaustively backfilled across all 30 books.
- **`person: mixed` + `timeline: multi_timeline`** (renamed from
  `dual_timeline`) added; The Fifth Season retagged as the motivating
  case.
- **`cannibalism` content warning — considered, rejected.** User pushback
  on this one was correct: unlike the researched additions, this was a
  single in-the-moment inference, not externally validated, and on the
  established "does this change the recommendation" bar it's better
  understood as a flavor of `body_horror` + `violence_intensity:graphic`
  than a distinct category.
- **Interview with the Vampire's genre_fit corrected** — reconsidered as
  a good fit (paranormal/gothic fantasy; vampirism is legitimate
  supernatural genre furniture with internally-consistent rules),
  distinct from Bird Box (deliberately unexplained entities, no
  established lore) and The Road (no fantastical element at all), both of
  which remain flagged as poor fits.
- **Vocabulary growth formalized as an ongoing practice** — documented in
  `book-dna.md` under "Vocabulary growth process": future gaps surfaced
  during real tagging (step 04) get added the same way these 13 were, not
  batched into occasional research passes.

**Deferred, not fixed this round** (still in the schema's future-fields
backlog): the narrator-reliability-vs-disorienting-style distinction
(Neuromancer), a possible disfigurement-based-discrimination content
warning (one data point, Kings of Paradise), a `form` value for LitRPG's
embedded stat-block text (He Who Fights with Monsters), and Prince of
Thorns' mid-series genre reveal as a data-model question.

**No fix needed**: genre scope is working as intended (3 correctly-flagged
out-of-scope books), and the existing multi-select `genre` field already
handles in-scope sci-fi/fantasy blends without changes.

## DNA accuracy review — the 10 books the user actually read and liked

The original pilot design called for this — checking tagged field values
against firsthand knowledge of the source material, not just checking
whether the similarity ranking came out right — but it hadn't actually
been done until asked for directly. Findings, applied to both the schema
and the corpus:

- **Two more real trope gaps**: `isekai` (distinct from both
  `portal_fantasy` — no reincarnation/game-system implication — and
  `litrpg_or_progression_fantasy` — about game mechanics specifically,
  not the transportation premise) and `renaissance_or_mercantile_setting`
  (The Lies of Locke Lamora's Camorr, modeled on Renaissance Venice —
  distinct from `medieval_european_setting`'s feudal-kingdom default).
- **`violence_intensity` gained a `brutal` tier above `graphic`** — direct
  reader comparison showed The Way of Kings and Kings of Paradise /
  Prince of Thorns landing on the same top bucket despite meaningfully
  different intensity (detailed dismemberment/torture vs. violent but not
  lingering on extremity). Same shape as `darkness` adding `grimdark`
  above `dark`.
- **The Golden Compass**: added `parallel_universe_or_multiverse`
  alongside the existing `portal_fantasy` — a real mistagging, not a
  missing vocabulary value (the schema already had this trope from the
  sci-fi research pass; it just wasn't applied to a fantasy book, even
  though group labels don't restrict which genre can use a trope). His
  Dark Materials' cosmology is genuinely multiverse, not a single
  other-world like Oz or Narnia.
- **The Eye of the World**: `emotional_resolution` corrected from `happy`
  to `bittersweet` — a real tagging error. `ends_on_cliffhanger: resolved`
  confirmed correct on review, using the user's own clarified test (a
  literal unresolved danger, not just "the story continues") — the
  book's physical threat concludes even though the emotional/relational
  thread stays loaded with dread.
- **Kings of Paradise**: `multiple_fantasy_species` removed — unsupported
  by the user's own memory of the book (no specific creature recalled
  beyond a singular godlike antagonist), and this book had markedly
  thinner source material available at original tagging time than the
  better-known titles in the corpus. Deferred to firsthand knowledge over
  an unconfirmed research-sourced tag rather than defending it.
- **Prince of Thorns**: `ends_on_cliffhanger: resolved` confirmed correct
  — Jorg's arc concludes its immediate action with no literal unresolved
  danger, which also cross-validated the Eye of the World call above
  using the same definition consistently.
- **One field addition considered and declined**: whether The Way of
  Kings' magic system needed a dedicated "distinctive/inventive" tag
  beyond `magic_system_hardness` + `worldbuilding_density`. Judged to
  fall inside the already-documented execution-quality boundary (see
  "Known limitations" in book-dna.md) rather than a structural gap — the
  schema tags that a hard, foregrounded magic system is present, not how
  creative or well-loved it is, and that boundary should stay consistent
  rather than special-cased.

## DNA accuracy review, part 2 — the remaining 8 read books

Same exercise, extended to the books the user read but didn't love
(Bird Box, Assassin's Apprentice, We Are Legion, Interview with the
Vampire, The Poppy War, Circe, Dark Matter, He Who Fights with Monsters).
Findings:

- **New trope: `vampires`** — the specific creature mythology (turning,
  bloodlines, sunlight vulnerability), distinct from
  `immortal_or_ageless_character` (a character trait any long-lived being
  could have) and `monster_or_fae_romance` (a romantic pairing, not a
  general setting element). Added from Interview with the Vampire.
- **Interview with the Vampire's `timeline` corrected** from `linear` to
  `multi_timeline` — the novel is genuinely framed as Louis recounting
  his life to a present-day reporter, a real two-timeframe structure, not
  an artifact of the film adaptation.
- **Assassin's Apprentice's `pace_shape` corrected** from
  `slow_burn_to_fast_finish` to `consistent` — the user's firsthand read
  (steady throughout, no escalating finish) taken over the original
  review-consensus tag.
- **Three books confirmed accurate as tagged**: Bird Box, The Poppy War,
  and (with caveats already logged) the rest of the corpus.
- **Two reactions confirmed as execution/engine-level, not schema
  gaps** — Circe ("boring, went nowhere," acknowledged by the user as
  opinion rather than a DNA correction) and Dark Matter ("unoriginal,"
  recurring from the earlier reveal-and-score round, reinforcing that
  it's correctly filed under the novelty/fatigue engine-level limitation
  rather than something to keep re-litigating as a schema question).
- **One rating-flow design note, not a schema item**: He Who Fights with
  Monsters was a DNF (did-not-finish), not just a dislike. Worth having
  the eventual rating flow (step 07) distinguish "finished and disliked"
  from "abandoned partway" — likely a stronger negative signal, not the
  same rating.

## Two future-feature ideas raised alongside this review (not schema, logged for later)

- **Friend-recommendation boosting** — the user independently proposed
  raising a book's match score when a friend with a similar taste profile
  recommends it, weighted further by that friend's track record of
  successful past recommendations. This isn't new: it's exactly what the
  original artifact's rec-engine section already specifies for roadmap
  step 09 (friend graph) — good convergent confirmation, not a new
  requirement.
- **TBR (to-be-read) list feature** — a user-facing list ordered by match
  score, with tabs for algorithm-recommended / friend-recommended (with
  match rating) / manually-ordered personal queue. New idea, not
  previously specified. Fits roadmap steps 08 (book detail pages, for the
  match-% display) and 09 (friend graph, for the friend tab). Logged here
  and in the project log; not yet added to the published artifact.
