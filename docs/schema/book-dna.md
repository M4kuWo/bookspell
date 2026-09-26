# Book DNA schema — core reference

Roadmap step 01 in origin; now the living, current reference for the
`book_dna` schema. Companion machine-readable file: `book-dna.schema.yaml`
(the exact, exhaustive controlled vocabulary — see "A note on this
file vs. the YAML" below before trusting any list here as complete).

Every field below is a **finite, controlled vocabulary** — never free text.
That constraint is what makes similarity scoring work at all.

## Schema map — where the rest of this content lives

Split 2026-09-25 from a single ~19,600-word file into this core
reference plus three companion files, per a measured fresh-session
context-load problem and CODX's reviewed split plan
(`docs/codx-reports/2026-09-25-book-dna-split-review.md`,
`docs/project-log.md`'s 2026-09-25 "CODX Task 22 landed" entry). This
file is read in full for the tasks identified by CLAUDE.md's "Startup
reading and task routes" policy. The other three are required when
the task or an applicable skill needs them:

- **`book-dna-vocabulary-gaps.md`** — the active, running tracker of
  flagged single-occurrence vocabulary gaps. Read before
  `tag-catalog-batch` or `catalog-trope-gap-sweep` — both skills
  require it.
- **`book-dna-tables.md`** — current contracts for tables/mechanisms
  that grew out of this schema and are now built and in production:
  `audiobook_editions`, `books.work_type`, Series DNA, the confidence/
  source layer, post-read/DNF feedback, and the omnibus/compilation
  operational rule. Read before touching any of these.
- **`book-dna-decisions.md`** — deferred/open proposals, rejected/
  superseded decisions, and the full dated implementation/review
  history. Read when proposing a new field/trope/content-warning
  (check for a prior rejection first) or revisiting a past design call.

## A note on this file vs. the YAML

**`book-dna.schema.yaml` is the exact, exhaustive current vocabulary —
this file's own field-value tables are NOT guaranteed complete or
perfectly current.** Verified directly 2026-09-25 while splitting this
file: `book-dna.schema.yaml` has 152 trope IDs; this file's prose (the
"Categories" tables below plus the growth-round history that used to
sit inline) predates several of them — 46 of the 152 were, at last
check, absent from the non-chronological reference tables (real
current tropes like `cosmic_horror`, `infiltration_or_undercover_plot`,
`predictive_social_science`, `secret_magical_bureaucracy` among them —
these are real, current, tagged-catalog-wide values, just not
reflected below because they entered the vocabulary via a dated growth
round rather than a table edit). Real per-book tagging and gap-sweep
work should always check the YAML directly, not just skim this file's
tables. This file's own tables are kept as a readable field-distinction
reference (what each field MEANS, how it differs from its neighbors),
not as the source of truth for exactly which values currently exist —
that authority belongs to the YAML alone.

## Scope

- `genre` is a field on every book from day one (`sci_fi`, `fantasy` for
  v1). Four of five categories are genre-agnostic and won't change as the
  catalog expands; only **Tropes & craft** is genre-locked.
- `age_category` (`middle_grade` / `ya` / `new_adult` / `adult`) is also a
  top-level field, added after real user feedback: a bibliographic fact,
  not a taste attribute, but a real axis readers have strong preferences
  on independent of genre or any other DNA field.
- `book_length` (`short` / `standard` / `long` / `epic`) is the same
  shape — bucketed from actual page/word count, a real approachability
  axis distinct from anything else in the schema. Someone avoiding The
  Wheel of Time isn't reacting to its tropes, they're reacting to "14
  books"; someone avoiding Stormlight isn't avoiding epic fantasy, they're
  avoiding ~450,000-word individual volumes — two different axes.
  `book_length` covers the per-book half; series length (`book_count`)
  lives on the `series` entity instead (see "Series & universe"), since
  it's a series-level fact, not a book-level one.
- A field's `spoiler` flag controls *display* only. The recommendation
  engine always reads the true value. See "Spoiler gating" below.

## Categories

### 1. Point of view & structure — core
| Field | Values |
|---|---|
| `pov_count` | single, multiple |
| `person` | first, second, third_limited, third_omniscient, mixed |
| `narrator_reliability` | reliable, unreliable, ambiguous |
| `timeline` | linear, nonlinear, multi_timeline |
| `form` | standard_prose, epistolary, framing_device, verse, embedded_system_text, script_or_stage_play |
| `prose_density` | sparse, moderate, lush |
| `prose_complexity` | accessible, moderate, dense |

**`pov_count`'s table above is stale relative to the live schema —
verified 2026-09-25.** `book-dna.schema.yaml` has 5 values
(`single, dual, few, several, ensemble`), not the 2 shown here
(`single, multiple`) — this file's own table was never updated when
the bucket scale widened. Trust the YAML. `few`=3-4, `several`=5-7,
`ensemble`=8+, counting recurring, page-time-significant viewpoints
(not audiobook cast size, not one-off interlude narrators).

`person: mixed` and `timeline: multi_timeline` (generalized from the old
`dual_timeline`, hard-coded to exactly two) both came from the 30-book
pilot — The Fifth Season mixes 2nd- and 3rd-person across its POV threads
and runs 3+ interwoven, non-chronological timelines. One data point, but
a well-known, Hugo-winning structural technique, not a fluke.

`form: embedded_system_text` closes the LitRPG game-notification-text gap
that recurred 6+ times across three tagging rounds before being added —
see `book-dna-decisions.md`'s vocabulary growth history.

`form: script_or_stage_play` was added 2026-08-30 during a partial-series
batch tagging pass, surfaced by *Harry Potter and the Cursed Child* — a
stage-play script (dialogue + stage directions, no narrative prose at
all) had no vocabulary match; every other `form` value assumes some kind
of prose narration exists, which a script structurally doesn't have.

`prose_density` (how much physical/sensory description the prose
carries) and `prose_complexity` (vocabulary/sentence-structure
difficulty) are a user-sourced pair of fields, added after real-world
comparisons like Lord of the Rings vs. a leaner Sanderson novel, and
Gene Wolfe's Shadow of the Torturer vs. Brent Weeks' The Black Prism.
They're deliberately independent axes: a book can be lushly descriptive
but simply worded, or sparse but syntactically demanding. Both are
distinct from `worldbuilding_density` (how much of the world's lore/rules
get explained, not how the prose itself reads) — a book can have dense
worldbuilding delivered in accessible, sparse prose. `prose_complexity`
in particular matters for an audiobook-native product specifically:
dense prose is harder to follow by ear than by eye.

### 2. Pacing & tone — core
| Field | Values |
|---|---|
| `overall_pace` | slow, medium, fast |
| `pace_shape` | consistent, slow_burn_to_fast_finish, front_loaded, uneven |
| `drive` | character_driven, plot_driven, balanced, worldbuilding_driven, romance_driven |
| `darkness` | light, moderate, dark, grimdark |
| `humor_level` | none, light, moderate, heavy |
| `emotional_register` | comfort_read, bittersweet, tense, gut_punch |
| `message_intensity` | subtle, moderate, heavy_handed |
| `intellectual_weight` | escapist, moderate, cerebral |

`drive: worldbuilding_driven` was added after the 30-book pilot —
Perdido Street Station didn't fit `character_driven`/`plot_driven`/
`balanced`; reviews consistently describe New Weird fiction as driven by
the setting itself rather than a character or plot throughline.

`message_intensity` (`subtle` / `moderate` / `heavy_handed`) measures how
overtly a book pushes a moral or philosophical argument — deliberately
**not** which argument. A reader can be averse to heavy-handedness itself
regardless of the specific message, so the per-user rating history can
learn "this user rates heavy-handed books lower" without the schema ever
tagging which position a book takes.

`intellectual_weight` (`escapist` / `moderate` / `cerebral`) measures how
much the book invites philosophical, ethical, or psychological
reflection versus functioning as plot-forward entertainment — the "John
Wick is fun, but Ender's Game makes you think" distinction. It's
deliberately independent of `message_intensity`: a subtle book can still
be cerebral (it demands thought without stating a thesis), and a
heavy-handed one can still be pure escapism (it states a simple moral
loudly without inviting deeper reflection).

### 3. Content & shape — core
| Field | Values | Spoiler |
|---|---|---|
| `romance_heat_frequency` | none, rare, occasional, frequent | no |
| `romance_heat_intensity` | na, closed_door, low, moderate, explicit | no |
| `romance_tone` | understated, melodramatic, mixed (nullable) | no |
| `violence_frequency` | none, rare, occasional, frequent | no |
| `violence_intensity` | na, mild, moderate, graphic, brutal | no |
| `content_warnings` | multi-select, see schema file | no |
| `worldbuilding_density` | light, moderate, dense | no |
| `worldbuilding_delivery` | woven, exposition_dump, mixed (nullable) | no |
| `stakes_scope` | intimate, regional, global, cosmic | no |
| `personal_stakes` | low, moderate, high, life_threatening | no |
| `narrative_closure` | self_contained, requires_series | no |
| `emotional_resolution` | happy, tragic, ambiguous, bittersweet | **yes** |
| `ends_on_cliffhanger` | resolved, cliffhanger | **yes** |

`content_warnings` stays neutral data, not an editorial judgment — the
field describes what's in the book, not whether that's good or bad. See
`book-dna.schema.yaml` for the exact current count and list (38 as of
the last full sweep — verify fresh, don't trust a hardcoded number),
each tagged per book with a `severity` of `brief` / `moderate` /
`central_theme` — a book where child_abuse is referenced once reads
very differently than one built entirely around it.

Worth noting StoryGraph's own content-warning system uses a different
axis — `Minor` / `Moderate` / `Graphic`, which measures how intensely
something is depicted, not how central it is to the book. Both are valid
questions; this schema deliberately answers the centrality question
instead, since that's the distinction that was actually asked for.

Each selected warning also carries a `reveals_spoiler` flag
(`true`/`false`), added after the 30-book pilot. This is a second
per-instance axis alongside `severity`, and it exists for the same
reason: neither is a fixed property of the warning type. Most instances
of most warnings are apparent from the start (`false`) — but the same
warning type can be a concealed, late plot reveal on a different book.
Perdido Street Station's `sexual_assault` (Yagharek's crime) is hidden
until deep in the book; that specific instance is `reveals_spoiler: true`
even though `sexual_assault` on most other books isn't a spoiler at all.

`stakes_scope` (`intimate` / `regional` / `global` / `cosmic`) is a
user-sourced field measuring the BREADTH of what's at risk — Legends &
Lattes' intimate personal-scale stakes vs. Death's End's cosmic,
universe-ending ones. `global` deliberately includes galaxy-spanning
single-universe empires (Dune, Foundation, Star Wars) — `cosmic` is
reserved for stakes that go beyond one universe/reality (multiverse,
alternate dimensions), not just "very large." It's independent of
`worldbuilding_density` (how much lore gets explained, not how high the
stakes are) and `darkness` (tone, not scale): a cozy book can still be
tonally dark, and a world-ending epic can still read tonally light.

**`personal_stakes` (`low` / `moderate` / `high` / `life_threatening`)**
was added alongside `stakes_scope` after review surfaced that the
original field was quietly conflating two questions: how much of the
*world* is threatened, and how much danger the *protagonist* is
personally in. A story about a boy who might get scolded for losing a
toy and a story about a man forced by the mafia into a deadly heist are
both `intimate` in scope — but obviously not the same kind of read. Now
they split: `low` + `intimate` vs. `life_threatening` + `intimate`. Other
telling pairs: The Time Traveler's Wife and The Green Mile are both
`intimate` scope but `life_threatening` (a fatal condition; an innocent
man's execution). Circe is `intimate` scope and only `high`, not
`life_threatening` — she's an immortal goddess, so her own death was
never really the threat, even though her son's safety is. Good Omens and
The Invisible Life of Addie LaRue are `moderate` for the same reason at
different scope levels: immortal/unkillable protagonists whose real
stakes are something other than dying (losing a comfortable life;
being forgotten).

The UI gates display of spoiler-flagged fields' `true` instances the
same way any other spoiler-flagged field does; the recommendation
engine always reads the real value regardless.

**What content_warnings actually drive — three uses of the same data:**
1. **Soft signal.** Same mechanism as every other DNA field — if a user's
   ratings show they consistently rate books with heavy war_trauma lower,
   the per-user weighted regression learns that automatically. No special
   handling needed.
2. **Informational display.** Shown on the book detail page regardless of
   whether the algorithm has learned anything about a given user's taste
   yet — useful from the first book, not just once enough ratings exist
   for the soft signal to mean anything.
3. **Explicit hard filter.** A user-level setting — "never recommend books
   flagged with X" — applied as a pre-filter *before* scoring runs,
   overriding whatever the vector math would otherwise surface. This is
   different in kind from (1): warnings often function as hard boundaries
   for readers, not graduated preferences, so a soft-learned weight alone
   isn't enough. This is a product feature built on the same tagged data,
   not a new schema field.

`romance_heat_level` and `violence_gore_level` split into frequency +
intensity pairs — "low frequency, high intensity" and "frequent, low
intensity" read very differently to a reader, and one field couldn't
express both.

`violence_intensity` gained a `brutal` tier above `graphic` after direct
reader comparison across the pilot corpus: books as different in actual
violence experience as The Way of Kings and Kings of Paradise / Prince of
Thorns were both landing on `graphic`, the scale's previous ceiling — the
same "top bucket absorbing too wide a range" problem that `darkness`
already solved by adding `grimdark` above `dark`.

`narrative_closure` replaces the old `series_structure` field and answers
one narrower question than it looks like it does: does *this book's own
plot* resolve within itself, or does it require the other installments to.
It deliberately does **not** try to answer "is this book part of a series"
— see "Series & universe" below for why that's a different question,
answered by different (and differently-behaved) data.

`ending_type` split into `emotional_resolution` and `ends_on_cliffhanger`
— they're independent: a book can land a happy character-level beat while
leaving the external plot on a cliffhanger, and `ends_on_cliffhanger` is
also distinct from `narrative_closure` (a series-level "does this book
need future books" fact vs. an ending-craft "do the final pages withhold
resolution" fact — correlated, not identical).

**`romance_tone` (`understated` / `melodramatic` / `mixed`, nullable)**
and **`worldbuilding_delivery` (`woven` / `exposition_dump` / `mixed`,
nullable)** — added 2026-09-11, landed as real scalar `book_dna` columns
after a validated probe (see `docs/scoring-test-protocol.md`'s
2026-09-05 "Execution-DNA validation probes" entry) and are wired into
the scoring engine as content-scoped nominal fields.

`romance_tone` captures emotional PRESENTATION specifically — how
characters express feeling on the page when a romantic scene happens
(restrained/grounded vs. soap-opera declarations, storming off, repeated
identical arguments) — deliberately distinct from `drive: romance_driven`
(narrative centrality), pacing (how fast the relationship develops),
`content_warnings` (whether it's toxic), and `romance_heat_*`
(explicitness). None of those are valid evidence for this field either
way. `worldbuilding_delivery` captures HOW lore is delivered (in-scene
discovery/dialogue vs. narrator/footnote exposition), distinct from
`worldbuilding_density` (how much lore exists) — a book can be `density:
dense` and still be `woven` (Book of the Ancestor, all 3 books).

Both are nullable and stay null when a book has too little
romantic content / worldbuilding-exposition to judge either axis at all
— this is NOT the same as `mixed`, which is a real, evidence-backed tie
(equal-confidence evidence on both sides, or a short-story collection
genuinely showing both tones across different stories). See
`.claude/skills/tag-catalog-batch/SKILL.md`'s evidence standard before
tagging either field — both have a real, already-caught track record of
confident-but-wrong tags from pattern-matching genre reputation instead
of checking the actual text (From Blood and Ash/Fourth Wing assumed
melodramatic from reputation alone, reversed on real research; The Bear
and the Nightingale conflated a slow courtship BUILD-UP with a restrained
emotional PRESENTATION and got the culminating scene's actual tone
backwards).

### 4. Audiobook-native — core, the strategic wedge
| Field | Values |
|---|---|
| `narrator_performance` | poor, average, good, excellent |
| `narrator_cast` | single_narrator, dual_narrator, full_cast, multi_narrator |
| `narration_pace_vs_prose` | matches, slower, faster |
| `accent_authenticity` | na, poor, adequate, excellent |
| `production_quality` | basic, standard, high |
| `audiobook_length` | short, standard, long, epic |

Nobody in the landscape structures this. Genre-agnostic by design —
holds as the wedge even if the genre scope expands later.

`audiobook_length` is bucketed from actual listening hours, not derived
from `book_length` — narration pace means the two can diverge, and for an
audiobook-first product, hours-to-listen is the more relevant
approachability signal than page count for a large share of users.

**Split into two tiers** after realizing this whole module was
100% untagged across the catalog. **Tier A** — `narrator_cast` and
`audiobook_length` — is ordinary publisher/retailer metadata, cheap to
source from `audiobook_editions` (see `book-dna-tables.md` for that
table's real contract), and is filled in as part of normal `book_dna`
tagging going forward (mandatory-when-computable, per
`.claude/skills/tag-catalog-batch/SKILL.md`'s Step 3 — null only when no
`audiobook_editions` row exists yet for that book, or when a `standard`
edition has 3+ narrators with no clean enum value). **Tier B** —
`narrator_performance`, `narration_pace_vs_prose`, `accent_authenticity`,
`production_quality` — is subjective listening judgment with no ordinary
metadata source; deliberately still deferred, genuinely 0% tagged
catalog-wide (see `docs/TODO.md`).

`narrator_cast` gained a 4th value, `multi_narrator`, 2026-09-21, once
real evidence existed for it (a catalog-wide backfill found 56 books
whose `audiobook_editions` data didn't cleanly fit `single_narrator`/
`dual_narrator`/`full_cast` — 21 of those were a genuine 3+-narrator
`standard`-edition fit and got `multi_narrator`; the other 35 have
multiple DIFFERENT standard editions with different narrator counts
each, a genuinely open per-edition-vs-per-book modeling question, left
NULL rather than forced). Full backfill numbers and migration history
preserved in `book-dna-decisions.md`.

### 5. Tropes & craft — SFF extension, v1 only
| Field | Values |
|---|---|
| `magic_system_hardness` | hard, soft, none, na |
| `scifi_hardness` | hard, soft, na |
| `tropes` | multi-select controlled vocabulary, see `book-dna.schema.yaml` for the exact current list and count |

`magic_system_hardness`'s `none` vs. `na` distinction: `none` = a
fantasy-genre book that simply has no magic system in it (the concept
applies to the genre, just isn't present here); `na` = the concept
doesn't apply at all, i.e. a pure sci-fi book with no fantasy element
(use `scifi_hardness` instead).

**A trope aversion should lower a score, not disqualify a book — this is
the engine's default behavior, not something extra to build.** The
recommendation engine is a weighted sum across every DNA dimension, so a
negative learned weight on one trope (e.g. `chosen_one`) only pulls down
that one term; a book carrying eight other tropes that match well still
scores well overall. Graduated degradation, not a filter, falls out of
the architecture automatically.

The one thing that *would* fully disqualify a book is the explicit
hard-filter mechanism described under `content_warnings` above — an
optional, per-user, **opt-in** "never recommend books with this trope"
toggle, off by default. Same three-tier pattern, generalized to a
second field. This is a product feature, not a new schema field.

Whether a trope is executed well or freshly is a separate question the
schema doesn't answer — see "Known limitations" below.

`scifi_hardness` is the sci-fi analog to `magic_system_hardness` — how
rigorously the science/tech is explained and grounded in plausible physics
(`hard`) vs. treated as unexplained narrative furniture, e.g. FTL travel
that just works (`soft`). `na` for books with no significant sci-fi/tech
component.

`tropes` is a multi-select, which makes it structurally cheap to grow —
adding a new value costs nothing for books that don't have it, unlike a
scalar field which needs a value for every book. That's real, but it's not
the whole test: "cheap to add" isn't the same bar as "worth adding."
Grouped for documentation and future filter-UI purposes (the `group` key
in the schema file); all groups are one flat controlled vocabulary for the
similarity math regardless of grouping. See `book-dna.schema.yaml` for
the exact current groups/values — **this file no longer maintains a
duplicate group-by-group listing** (it drifted from the live YAML in the
past; see "A note on this file vs. the YAML" above for why the YAML is
now the sole authority for the exact list).

Two entries worth calling out, since they're conceptual distinctions
rather than simple vocabulary:

- **`twist_ending` vs. `twist_filled`** — these are different shapes, and
  a book can have either, both, or neither. `twist_ending` is a single
  late reveal that recontextualizes what came before (The Sixth Sense).
  `twist_filled` is a book that keeps reversing itself throughout — the
  reader's read on who's winning flips more than once before the end
  (The Prestige).
- **`sanderlanche`** — genre slang (after Brandon Sanderson) for a
  specific craft device: multiple plot threads converging and paying off
  in rapid succession into an intense climax. Distinct from `pace_shape:
  slow_burn_to_fast_finish`, which is a general pacing-curve axis every
  book gets tagged on — `sanderlanche` is a specific, named, opt-in device,
  which is exactly why it belongs in the tropes list rather than as its
  own field. Kept as the actual community term rather than a sanitized
  synonym, in keeping with the product's genre-native voice.

Most tropes are not spoilers. A few are, by nature — `twist_ending`,
`twist_filled`, `redemption_arc`, `villain_turns_ally`,
`major_character_death` — and carry `spoiler: true` per-value in the
schema file rather than gating the whole field.

On why `romance_relationships` is the largest trope group, the full
group-by-group vocabulary listing, and every individual trope's
addition rationale: see `book-dna.schema.yaml` directly (current,
authoritative) and `book-dna-decisions.md` (the dated growth-round
history of how each one was added and why).

### 6. Reader fit — core, powers a separate mechanism
| Field | Values |
|---|---|
| `genre_accessibility` | gateway, accessible, moderate, demanding, veteran_only |

Added 2026-09-03, from a repo-owner design discussion about two distinct
cold-start problems: a reader with too little rating history overall
(any genre), and a reader whose history doesn't demonstrate SFF-specific
experience, even if they have plenty of general reading history. Neither
is fixed by a new DNA field on its own — they need a fallback recommendation
strategy for readers the engine doesn't know well yet, and this field is
what that strategy leans on.

**Deliberately excluded from the normal per-user weighted average**
(`ORDINAL_FIELDS`) — folding it in would risk diluting real signal for
readers who already have a rating history, the same failure mode this
project already hit and fixed once for other fields (see
`docs/scoring-test-protocol.md`'s aggregation-shape design discussion).
Instead it powers a separate blend, active only for readers with too
little demonstrated experience, fading out as real signal accumulates —
see `scripts/scoring/cold_start.py`'s `cold_start_weight()`/
`reader_experience_fraction()` (moved here from `recommend.py` during
this project's Phase A/B scoring-engine refactor; verify the current
location if this matters for a specific task).

"Too little experience" is NOT just a matter of how many books someone's
rated — a reader whose only rating is Gardens of the Moon has demonstrated
real genre readiness a short list doesn't otherwise capture. The
cold-start weight combines rating count (a decaying factor) with the
highest `genre_accessibility` tier the reader has engaged with and not
disliked (a demonstrated-experience factor that can override the count
factor entirely, even at n=1).

Backfilled for every already-tagged book via a formula over
`prose_complexity`, `overall_pace`, `worldbuilding_density`, `pov_count`,
and `intellectual_weight` (see the field's own schema comment for the
exact formula) — free, no new tagging work for already-tagged books.
This captures difficulty of CRAFT only; it deliberately doesn't (can't)
capture premise familiarity. Going forward, a tagger starts from the
computed baseline and adjusts specifically for that, rather than
reassigning from scratch — see `tag-catalog-batch/SKILL.md`.

Related but distinct from the series-length-as-approachability idea
under "Series & universe" below — that's about how much TOTAL reading
commitment a series represents, independent of how much genre fluency
any single book in it assumes. Both are real approachability axes,
deliberately not conflated into one field.

**Future UI idea, not built** — see `book-dna-decisions.md` for the
full self-report-onboarding proposal.

## Vocabulary growth process

`tropes` and `content_warnings` are not meant to be "finished" — they're
meant to keep growing as real books get tagged. This is a standing
practice starting at the tagging pipeline, not a one-time pre-launch
push: whenever a book's defining device or a real warning doesn't fit
the existing vocabulary, that's a candidate addition, reviewed against
the same bar used throughout this schema's review — **does this predict
a different recommendation, not just "is it a real term used
somewhere."** Multi-select vocabulary growth is cheap structurally (no
cost to already-tagged books that don't have the new value), but that's
not the same as automatically worth adding.

**The full, dated chronology of every growth round (7 so far), including
every "real term but not added" rejection and the exact per-book
evidence behind every value that DID land, moved to
`book-dna-decisions.md`** — read it before proposing a new value, both
to see the evidence bar in action and to check whether your candidate
has already been considered and rejected once.

## Known limitations — engine-level, not schema fixes

Surfaced during the 30-book pilot's reveal-and-score round, when the user
checked real predictions against real reactions. These are documented
here because they came from schema work, but the fix (if any) belongs to
the recommendation engine, not to `book_dna` itself.

- **Trope fatigue / satiation.** A trope's effect on enjoyment can invert
  with a reader's own cumulative exposure — e.g. loving `magic_school` in
  childhood (Harry Potter), still fine with it later (A Wizard of
  Earthsea, Book of the Ancestor), fed up with it by the time of The
  Poppy War. This isn't a stable per-book preference; it's a property of
  the reader's history, which `book_dna` (a static per-book tag) can't
  represent. A per-user weighted regression fit once over all ratings
  will, at best, learn a weak/muted weight on an inconsistently-received
  trope — a reasonable outcome given the data, but not the same as
  modeling active satiation. A real fix needs something the schema can't
  provide alone: recency-weighted ratings, an explicit "tropes I'm tired
  of" onboarding question, or exposure-count features tracking how many
  similar books a user has rated recently.
- **Perceived originality is the same phenomenon at a wider scope.** A
  "this felt unoriginal, I've seen these concepts done better elsewhere"
  reaction (surfaced on Dark Matter) isn't an intrinsic property of a
  text — it's relative to what the specific reader has already consumed.
  Same root cause and same fix path as trope fatigue above: this needs
  reading-history-aware scoring in the engine, not a `book_dna` field.
- **Even "low-subjectivity" fields aren't zero-subjectivity.** Leviathan
  Wakes is tagged `overall_pace: fast` from review-consensus research;
  one real user experienced it as slow. Structured fields reduce
  subjectivity relative to a single star rating — they don't eliminate
  it. Worth being honest about this as a permanent property of any
  labeled system, not a gap to chase with more schema precision.
- **Execution/voice chemistry is out of scope by design, and that's
  working as intended.** Assassin's Apprentice ("well-written, but I
  didn't enjoy it") and The Poppy War (high DNA-similarity score despite
  a "mixed" real reaction) are both cases where the DNA schema correctly
  predicts "this should structurally appeal to you" while missing a
  purely subjective reaction to craft/voice that the schema was never
  meant to capture. Not a miss — the schema's whole thesis is trading
  exhaustive subjective judgment for tractable structured signal, and
  this is the boundary of what that signal can promise.
- **Confirmed working**: the user's LitRPG aversion is already captured
  by `litrpg_or_progression_fantasy`, one of the tropes added after
  this same pilot — real validation that the addition carries signal for
  at least one actual reader.
- **Open question worth formalizing: what's the minimum data threshold
  for reliable recommendations, and along which axis?** Old Man's War's
  poor showing in the pilot came from having only one sci-fi example in
  a 6-book seed, not from 6 being too few in some generic sense —
  suggesting the real threshold isn't "N total ratings" but "N ratings
  covering enough diversity across the schema's categories." Once real
  usage exists, this is directly testable: hold out ratings per user and
  check prediction accuracy as a function of both rating count and
  category coverage, to find where the curve actually plateaus.

## Spoiler gating

Decoupled from engine use: the engine always scores against the real
value; only the *UI* hides a `spoiler: true` field behind a reveal
control.

For series, a spoiler field also needs a **spoiler horizon** — the
installment number at which it stops being a spoiler. That's per-book
data, not a schema field. **This design was never actually shipped as
described** (verify against the real UI before assuming it exists —
the actual current spoiler-safety behavior is a simpler collapsed
"Spoilers" disclosure, landed 2026-09-20; see `docs/TODO.md`/
`docs/project-log.md` for the real, current state, not this paragraph).

## Series & universe (data-model note, not a DNA field)

`narrative_closure` answers "does this book's plot resolve on its own."
It deliberately does not answer "is this book part of a series" or "is
that series finished" — those are relational, mutable facts that don't
belong in frozen per-book tag data at all.

- The Shining was `self_contained` the day it published, and stays
  `self_contained` forever — nothing about its own text changed when
  Doctor Sleep came out decades later. Adding that sequel means adding a
  `series` row and linking both books to it, never re-tagging The Shining.
- The First Law's standalones (Best Served Cold, The Heroes, Red Country)
  are each `self_contained` *and* part of the same shared continuity as
  the First Law trilogy — both true at once, which a single `standalone`
  value couldn't express. That needs one more level than "book belongs to
  a series":

  ```
  universe (optional)   — a shared continuity, e.g. "The First Law World"
    └─ series (optional)  — a bounded arc within it, e.g. "The First Law"
          status: ongoing | completed | hiatus
          book_count: how many books it has (nullable/estimated while
          ongoing — e.g. Stormlight's planned 10)
          (both refreshed from metadata sources periodically — never set
          once at tagging time, since they change out from under you)
        └─ book — position_in_series (nullable; may be fractional for
            novellas / interquels)
  ```

  A book can link to a `universe` directly with no `series` at all (a
  First-Law standalone). This is a table-shape decision, not something
  the DNA schema itself needs to encode.

  `book_count` is the series-length half of the length-as-approachability
  idea (see `book_length` in Scope, above) — independent of it, since few
  huge volumes (Stormlight) and many normal-sized ones (Wheel of Time) are
  both "a lot of commitment," for different reasons a single field
  couldn't capture.

  **This First Law example is now actually implemented** — verified
  2026-09-25: `supabase/migrations/20260911200000_first_law_universe.sql`
  built the real "The First Law World" universe row this design called
  for. (An earlier version of this note, preserved in
  `book-dna-decisions.md`, described this as NOT yet built as of
  2026-09-08 — that gap has since closed; don't trust that older note as
  current status.) Real scale problems with `book_count`/`status`
  themselves across the wider catalog (Hardcover's raw, uncurated
  `books_count`/`is_completed` fields) are a separate, larger, ongoing
  fix — see `docs/TODO.md`'s `series.status`/`book_count` item for
  current progress.

## The bar for a new scalar `book_dna` field (not a trope/content-warning)

A whole new SCALAR field — a bigger, rarer decision, closer in weight to
`romance_tone`/`worldbuilding_delivery` landing as real columns than to
one more trope — needs its own written gate, deliberately mirroring the
trope tracker's own discipline (see `book-dna-vocabulary-gaps.md`)
rather than inventing a separate one. **Kept in this core file, not
moved to the decisions file** — it applies before proposing a field,
including when an ordinary tagging task discovers a possible new
dimension, not just declared schema-design work. CLAUDE.md's universal
routing rule requires reading this gate before any scalar proposal,
including one discovered while working on a different task.

1. **A repeated failure class, not one book.** The same standard as a
   trope's second-occurrence rule, applied here too — a single
   recommendation failure that a new field would explain is a real
   finding (log it, e.g. via a CODX-style diagnosis like
   `docs/codx-reviews/2026-09-23-magic-burns-ranking.md`), but isn't by
   itself grounds to propose a new field. Wait for — or actively check
   for — a second, independent case the SAME missing dimension would
   explain before treating it as a field proposal rather than an
   isolated data point.
2. **Confirm no existing field or trope combination already covers it.**
   Check both the scalar fields above and the trope vocabulary — a
   missing CONCEPT and a missing VOCABULARY ENTRY for an already-modeled
   concept are different problems with different fixes.
3. **State what an ablation-style check would need to show, before
   building it.** `run_ablation_study()`/`ABLATION_GROUPS` in
   `scripts/scoring_tests.py` already exist for exactly this (currently
   used to catch regressions in existing fields) — reuse it, don't build
   a parallel mechanism. Write down, in advance, what post-launch
   result would justify the field's added complexity (which metric,
   how much movement) and what result would mean it didn't earn its
   keep.
4. **This is scoring-adjacent, not just a data-tagging decision** — a
   new field changes what `build_profile()`/`score_book()` learn from,
   so it also has to clear `docs/scoring-test-protocol.md`'s 10-question
   gate, not just this one. The two aren't redundant: this section is
   about whether the CONCEPT is real and repeated; that gate is about
   whether adding it is the right ENGINEERING response.
