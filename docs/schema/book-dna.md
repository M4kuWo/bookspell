# Book DNA schema — v0.1 draft

Roadmap step 01. This is the spec to lock before any code, per the plan:
schema changes are the most expensive thing to change once books are tagged
against it. Companion machine-readable file: `book-dna.schema.yaml`.

Every field below is a **finite, controlled vocabulary** — never free text.
That constraint is what makes similarity scoring work at all (roadmap §05).

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
| `narrator_reliability` | reliable, unreliable |
| `timeline` | linear, nonlinear, multi_timeline |
| `form` | standard_prose, epistolary, framing_device, verse, embedded_system_text |
| `prose_density` | sparse, moderate, lush |
| `prose_complexity` | accessible, moderate, dense |

`person: mixed` and `timeline: multi_timeline` (generalized from the old
`dual_timeline`, hard-coded to exactly two) both came from the 30-book
pilot — The Fifth Season mixes 2nd- and 3rd-person across its POV threads
and runs 3+ interwoven, non-chronological timelines. One data point, but
a well-known, Hugo-winning structural technique, not a fluke.

`form: embedded_system_text` closes the LitRPG game-notification-text gap
that recurred 6+ times across three tagging rounds before being added —
see the vocabulary growth section below.

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
| `drive` | character_driven, plot_driven, balanced, worldbuilding_driven |
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
**not** which argument. This stays inside the schema's ideological-
neutrality decision (see the thesis): a reader can be averse to
heavy-handedness itself regardless of the specific message, so the
per-user rating history can learn "this user rates heavy-handed books
lower" without the schema ever tagging which position a book takes.

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
| `violence_frequency` | none, rare, occasional, frequent | no |
| `violence_intensity` | na, mild, moderate, graphic, brutal | no |
| `content_warnings` | multi-select, see schema file | no |
| `worldbuilding_density` | light, moderate, dense | no |
| `stakes_scope` | intimate, regional, global, cosmic | no |
| `personal_stakes` | low, moderate, high, life_threatening | no |
| `narrative_closure` | self_contained, requires_series | no |
| `emotional_resolution` | happy, tragic, ambiguous, bittersweet | **yes** |
| `ends_on_cliffhanger` | resolved, cliffhanger | **yes** |

`content_warnings` stays neutral data, not an editorial judgment — the
field describes what's in the book, not whether that's good or bad. 33
values (see schema file), each tagged per book with a `severity` of
`brief` / `moderate` / `central_theme` — a book where child_abuse is
referenced once reads very differently than one built entirely around it,
and this is what lets that distinction exist without doubling the whole
category the way heat/violence did (a shared severity axis per warning,
not a full frequency+intensity split — see "Resolved during review").

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
   isn't enough. This is a step 05/06 product feature built on the same
   tagged data, not a new schema field.

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

### 4. Audiobook-native — core, the strategic wedge
| Field | Values |
|---|---|
| `narrator_performance` | poor, average, good, excellent |
| `narrator_cast` | single_narrator, dual_narrator, full_cast |
| `narration_pace_vs_prose` | matches, slower, faster |
| `accent_authenticity` | na, poor, adequate, excellent |
| `production_quality` | basic, standard, high |
| `audiobook_length` | short, standard, long, epic |

Nobody in the landscape (§03) structures this. Genre-agnostic by design —
holds as the wedge even if the genre scope expands later.

`audiobook_length` is bucketed from actual listening hours, not derived
from `book_length` — narration pace means the two can diverge, and for an
audiobook-first product, hours-to-listen is the more relevant
approachability signal than page count for a large share of users.
Skipped for the pilot corpus along with every other `audiobook_native`
field.

### 5. Tropes & craft — SFF extension, v1 only
| Field | Values |
|---|---|
| `magic_system_hardness` | hard, soft, none, na |
| `scifi_hardness` | hard, soft, na |
| `tropes` | multi-select controlled vocabulary, 99 values across 6 groups, see schema file |

`magic_system_hardness`'s `none` vs. `na` distinction was never actually
defined until the pilot forced an inference: `none` = a fantasy-genre book
that simply has no magic system in it (the concept applies to the genre,
just isn't present here); `na` = the concept doesn't apply at all, i.e. a
pure sci-fi book with no fantasy element (use `scifi_hardness` instead).

**A trope aversion should lower a score, not disqualify a book — this is
the engine's default behavior, not something extra to build.** The
recommendation engine is a weighted sum across every DNA dimension, so a
negative learned weight on one trope (e.g. `chosen_one`) only pulls down
that one term; a book carrying eight other tropes that match well (The
Wheel of Time also has `prophecy`, `epic_quest`, `found_family`,
`wise_mentor`, and more) still scores well overall. Graduated
degradation, not a filter, falls out of the architecture automatically.

The one thing that *would* fully disqualify a book is the explicit
hard-filter mechanism described under `content_warnings` above (soft
signal / informational display / explicit hard filter). That mechanism
should extend to `tropes` too: an optional, per-user, **opt-in** "never
recommend books with this trope" toggle, off by default, for the reader
who wants an absolute exclusion rather than a lowered score. Same
three-tier pattern, same reasoning, just generalized to a second field.
This is a step 05/06 product feature, not a new schema field.

Whether a trope is executed well or freshly ("this chosen-one arc did
something interesting with it") is a separate question the schema
doesn't answer — that's the execution/voice-chemistry boundary already
named in "Known limitations" below, not a new gap.

`scifi_hardness` is the sci-fi analog to `magic_system_hardness` — how
rigorously the science/tech is explained and grounded in plausible physics
(`hard`) vs. treated as unexplained narrative furniture, e.g. FTL travel
that just works (`soft`). `na` for books with no significant sci-fi/tech
component. This is a well-established reader-facing axis that had no
equivalent field until schema review flagged the gap — fantasy readers had
a hardness spectrum, sci-fi readers didn't.

`tropes` is a multi-select, which makes it structurally cheap to grow —
adding a new value costs nothing for books that don't have it, unlike a
scalar field which needs a value for every book. That's real, but it's not
the whole test: "cheap to add" isn't the same bar as "worth adding" — see
the romance_relationships note below, where that distinction mattered.
Grouped for documentation and future filter-UI purposes (the `group` key
in the schema file); all groups are one flat controlled vocabulary for the
similarity math regardless of grouping.

- **Character archetypes** (13) — chosen_one, reluctant_hero, anti_hero,
  villain_protagonist, cursed_protagonist, morally_grey_protagonist,
  secret_royalty, immortal_or_ageless_character, reincarnated_protagonist,
  hidden_talent_prodigy, wise_mentor, underdog_rising,
  dark_lord_or_evil_overlord. Renamed from "protagonist_archetypes" — the
  last entry is an antagonist archetype, so the group covers both rather
  than adding a 7th group for one value.
- **Romance & relationships** (21) — enemies_to_lovers, friends_to_lovers,
  forbidden_love, love_triangle, fated_mates, soulmate_bond,
  arranged_marriage, marriage_of_convenience, fake_dating,
  forced_proximity, only_one_bed, age_gap_romance, second_chance_romance,
  grumpy_sunshine, slow_burn_romance, found_family, monster_or_fae_romance,
  insta_love, hidden_identity_romance, reverse_harem_or_why_choose,
  telepathic_animal_bond (non-romantic bond, grouped here alongside
  found_family — e.g. Robin Hobb's Wit, His Dark Materials' daemons).
  This is the largest group, deliberately — see below.
- **Setting & worldbuilding** (20) — magic_school, portal_fantasy,
  medieval_european_setting, non_european_inspired_setting,
  lost_civilizations, fae_courts, high_fantasy_setting,
  urban_fantasy_setting, post_apocalyptic, dystopia, space_opera,
  cyberpunk, multiple_fantasy_species, dark_academia_setting, steampunk,
  litrpg_or_progression_fantasy, new_weird_setting, isekai,
  renaissance_or_mercantile_setting, vampires
- **Plot devices & structure** (15) — epic_quest, court_intrigue, heist,
  rebellion_against_empire, time_loop, time_travel,
  parallel_universe_or_multiverse, prophecy, war_story,
  ancient_evil_awakens, powerful_artifact_macguffin, last_minute_rescue,
  black_and_white_morality, child_soldiers_in_warfare, noir_detective_structure
- **Sci-fi specific** (21) — first_contact, generation_ship, dying_earth,
  alien_invasion, ai_consciousness, cloning,
  terraforming_or_space_colonization, cryosleep,
  mind_uploading_or_digital_immortality, virtual_reality_or_simulated_world,
  ai_uprising_or_rebellion, android_or_replicant_rights,
  cybernetic_enhancement, hive_mind, mecha_or_giant_robots,
  self_replicating_consciousness, species_divergence,
  relativistic_time_dilation, mutual_human_alien_war,
  aging_reversal_or_rejuvenation, satirical_or_comedic_scifi
- **Craft & narrative devices** (9) — twist_ending, twist_filled,
  sanderlanche, redemption_arc, villain_turns_ally, major_character_death,
  mentor_death, mythological_retelling, shadow_self_confrontation

The 13 entries added across these groups all came from the 30-book blind
tagging pilot — real books whose defining device had no vocabulary match,
not abstract brainstorming. See "Vocabulary growth process" below.

**On romance_relationships being the largest group:** worth pressure-
testing rather than assuming "real term" is a high enough bar. Some
distinctions clearly change the reading experience for any SFF reader
regardless of how much they care about the romance specifically —
`slow_burn_romance` vs. `insta_love` is a pacing axis, `enemies_to_lovers`
vs. `friends_to_lovers` is a starting-dynamic axis, `reverse_harem_or_why_choose`
is a relationship *structure*. Those earned their place. Others floated
during trope research were narrower distinctions that mostly matter to
readers already deep in romantasy-specific taxonomy rather than
predicting a different recommendation for a general SFF reader —
deferred to the future-fields backlog below instead of added.

Most tropes are not spoilers (`chosen_one`, `enemies_to_lovers`,
`magic_school`, ...). A few are, by nature — `twist_ending`,
`twist_filled`, `redemption_arc`, `villain_turns_ally`,
`major_character_death` — and carry `spoiler: true` per-value in the
schema file rather than gating the whole field.

Two entries worth calling out:

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

## Vocabulary growth process

`tropes` and `content_warnings` are not meant to be "finished" at v1
launch — they're meant to keep growing as real books get tagged. This is
a standing practice starting at step 04 (the tagging pipeline), not a
one-time pre-launch push: whenever a book's defining device or a real
warning doesn't fit the existing vocabulary, that's a candidate addition,
reviewed against the same bar used throughout this schema's review —
**does this predict a different recommendation, not just "is it a real
term used somewhere."** Multi-select vocabulary growth is cheap
structurally (no cost to already-tagged books that don't have the new
value), but that's not the same as automatically worth adding — see the
romance_relationships discussion above and the cannibalism
content-warning rejection in the future-fields backlog below, both cases
where "real term" wasn't treated as a high enough bar on its own.

The 30-book pilot (`docs/pilot/tagged-books.yaml`,
`docs/pilot/findings.md`) is the first real instance of this process, not
a special one-off — it's the shape future additions during step 04 should
take: a specific book, a specific gap, a specific "distinct from X"
justification, checked against the bar above before it goes in.

**Second growth round (2026-08-28, after the 108-book remaining-catalog
pass)**: 11 tropes, 4 content warnings, and one `form` value
(`embedded_system_text`) added, each sourced from a specific gap hit
during real tagging — full list and per-book rationale in
`docs/remaining-catalog-tagging/findings.md`. `embedded_system_text` in
particular had recurred 6+ times across three separate tagging rounds
(pilot, step04, remaining-catalog) before being added — the clearest
case yet of the "does this predict a different recommendation" bar being
met through repetition rather than a single instance.

**Third growth round (2026-08-28, user-sourced field ideas)**: the user
brought a list of candidate fields from outside feedback (friends'
suggestions). Reviewed against the existing schema and the same bar as
every prior addition — several were already covered (gore level by
`violence_intensity`, progression fantasy by the pre-existing
`litrpg_or_progression_fantasy`, politics-heavy substantially by
`court_intrigue`) and left out; four genuinely new, independent axes were
added (`prose_density`, `prose_complexity`, `intellectual_weight`,
`stakes_scope`) plus two new tropes (`dragons`, `coming_of_age`). Unlike
tropes/content warnings, the four new scalar fields require every book
in the catalog to get a value (not just an optional retroactive tag on
the specific books that surfaced the gap) — see the project log for the
retagging pass this triggered.

## Known limitations — engine-level, not schema fixes

Surfaced during the 30-book pilot's reveal-and-score round, when the user
checked real predictions against real reactions. These are documented
here because they came from schema work, but the fix (if any) belongs to
the recommendation engine (roadmap step 05/06), not to `book_dna` itself.

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
  by `litrpg_or_progression_fantasy`, one of the 13 tropes added after
  this same pilot — real validation that the addition carries signal for
  at least one actual reader.
- **Open question worth formalizing for step 09 (dogfood): what's the
  minimum data threshold for reliable recommendations, and along which
  axis?** Old Man's War's poor showing in the pilot came from having only
  one sci-fi example in a 6-book seed, not from 6 being too few in some
  generic sense — suggesting the real threshold isn't "N total ratings"
  but "N ratings covering enough diversity across the schema's
  categories" (enough sci-fi *and* fantasy, not just enough books
  overall). Once real usage exists, this is directly testable: hold out
  ratings per user and check prediction accuracy as a function of both
  rating count and category coverage, to find where the curve actually
  plateaus. This is also why step 05's taste quiz matters architecturally
  — it's the mechanism for getting some signal across all categories
  before enough organic ratings accumulate to do it from history alone.

## Spoiler gating

Decoupled from engine use, per the decisions log: the engine always scores
against the real value; only the *UI* hides a `spoiler: true` field behind
a reveal control.

For series, a spoiler field also needs a **spoiler horizon** — the
installment number at which it stops being a spoiler. That's per-book data,
not a schema field: e.g. a book record carries
`ending_type_spoiler_horizon: 3`, and the UI gates the reveal against the
reader's tracked reading progress. Reach book 3 and it unlocks on its own;
"reveal anyway" is the only way to see it early. This is a data-model note
for step 02, not something the schema file itself encodes.

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
  First-Law standalone). This is a table-shape decision for step 02, not
  something the DNA schema itself needs to encode.

  `book_count` is the series-length half of the length-as-approachability
  idea (see `book_length` in Scope, above) — independent of it, since few
  huge volumes (Stormlight) and many normal-sized ones (Wheel of Time) are
  both "a lot of commitment," for different reasons a single field
  couldn't capture.

## Resolved during review

- **`darkness` / `humor_level` granularity** — keeping both as 4-point
  enums. They're independent axes (a grimdark book can still be heavily
  funny) — that's *why* they're separate fields, not one combined "tone"
  scale.
- **`magic_system_hardness`** — stays a separate field, not folded into
  `tropes`. Reads as a spectrum property of the worldbuilding, not a
  discrete narrative beat.
- **`romance_heat_level` / `violence_gore_level`** — split into frequency
  + intensity pairs (see §3 above).
- **`series_structure`** — replaced by `narrative_closure`; series
  membership and completion status moved out of `book_dna` entirely (see
  "Series & universe" above).
- **Twists** — split `twist_ending` (single late reveal) from
  `twist_filled` (repeated reversals throughout), added to `tropes`.
- **Added `sanderlanche`** to `tropes` — see §5 above.
- **`content_warnings`** — expanded 14 → 23, renamed `graphic_torture` →
  `torture` and `animal_death` → `animal_harm` for consistency with the
  "neutral fact, severity is separate" principle, and added a shared
  `severity` axis (`brief` / `moderate` / `central_theme`) per selected
  warning rather than a full frequency+intensity split.
- **`tropes`** — expanded ~30 → ~61, organized into 6 groups (see §5).
  Reasoning: multi-select vocabulary growth is cheap (no per-book cost for
  values that don't apply), unlike scalar fields.
- **`ending_type` split** — `emotional_resolution` (happy/tragic/
  ambiguous/bittersweet) and `ends_on_cliffhanger` (resolved/cliffhanger)
  are independent axes; a single field couldn't express both being true
  at once.
- **`tropes` list, researched pass** — cross-checked against TVTropes,
  StoryGraph, romantasy trope lists, and trope tags on well-known genre
  books (Mistborn, Fourth Wing, Project Hail Mary, The Expanse, Dune, and
  others), rather than continuing from memory. 61 → 83 values, plus the
  `protagonist_archetypes` → `character_archetypes` rename.
- **Added `scifi_hardness`** — direct sci-fi analog to
  `magic_system_hardness`; confirmed real, well-established axis with no
  prior equivalent field.
- **`content_warnings` list, researched pass** — cross-checked against
  StoryGraph's actual per-book content-warning data and real warning
  lists for The Poppy War and A Court of Thorns and Roses. 23 → 33
  values: `sexual_harassment`, `emotional_abuse`, `child_sexual_abuse`
  (renamed from the research's "pedophilia" — that names an attraction,
  not the abuse being warned about), `stalking`, `trafficking`,
  `classism`, `sexism_or_misogyny_depicted`, `infertility`, `abortion`,
  `bullying`. Each confirmed distinct from an existing entry, not a
  near-duplicate — see the schema file for the specific "distinct from X"
  reasoning per value.
- **30-book blind tagging pilot** — the schema's first contact with real
  books instead of brainstormed or researched examples. Surfaced: 13 real
  trope gaps (added, see §5), `person: mixed` + `timeline:
  multi_timeline` (The Fifth Season's mixed-person, 3+-timeline
  structure), `drive: worldbuilding_driven` (Perdido Street Station), the
  `magic_system_hardness` none/na definition, and the `content_warnings`
  per-instance `reveals_spoiler` axis. Full detail in
  `docs/pilot/findings.md`; the tagged corpus itself is
  `docs/pilot/tagged-books.yaml`.
- **Pilot reveal-and-score round** — after scoring the 30-book corpus and
  checking predictions against real reactions, the user's own reasoning
  for specific likes/dislikes surfaced two more real gaps: `age_category`
  (a YA aversion unrelated to genre) and `message_intensity` (an aversion
  to heavy-handed moral/philosophical argument, generalizing across
  different ideologies — kept ideologically neutral per the thesis, same
  as every other field). Three more findings from this round were
  correctly diagnosed as engine-level, not schema gaps — see "Known
  limitations" above. Neither new field was retroactively backfilled onto
  the 30-book pilot corpus.
- **DNA accuracy review, on the 10 pilot books the user actually read and
  liked** — a check the original pilot design called for but hadn't been
  done until asked for directly: checking tagged values against firsthand
  knowledge of the source material, not just checking whether the
  similarity ranking came out right. Found: `isekai` and
  `renaissance_or_mercantile_setting` as two more real trope gaps (The
  Golden Compass, The Lies of Locke Lamora), a `violence_intensity: brutal`
  tier (see above), and three real per-book tagging corrections applied
  directly — The Golden Compass gained `parallel_universe_or_multiverse`
  (a mistagging, not a missing trope: the schema already had this value,
  it just wasn't applied), The Eye of the World's `emotional_resolution`
  corrected from `happy` to `bittersweet`, and Kings of Paradise's
  `multiple_fantasy_species` removed (unsupported by the user's own
  memory of the book, deferred to their firsthand knowledge over a
  synopsis-sourced tag). One field question raised and declined:
  whether The Way of Kings' magic system needed a dedicated
  "distinctive/inventive" tag beyond `magic_system_hardness` +
  `worldbuilding_density` — judged to fall inside the already-documented
  execution-quality boundary (Known Limitations), not a new gap.
- **DNA accuracy review, part 2 (the remaining 8 read books)** — extended
  to books read but not loved. Added `vampires` (distinct from
  `immortal_or_ageless_character` and `monster_or_fae_romance`); corrected
  Interview with the Vampire's `timeline` (`linear` → `multi_timeline` —
  the novel's actual present-day-interview framing, not just the film's)
  and Assassin's Apprentice's `pace_shape` (`slow_burn_to_fast_finish` →
  `consistent`, taking the user's firsthand read over the original
  review-consensus tag). Two reactions (Circe "boring," Dark Matter
  "unoriginal") reconfirmed as already-documented engine-level
  limitations rather than new schema questions on a second pass.
- **`book_length` and series `book_count` added** — a reader avoiding The
  Wheel of Time reacts to "14 books," not its tropes; a reader avoiding
  Stormlight reacts to ~450,000-word individual volumes, not epic fantasy
  as a genre. Two different, previously uncaptured approachability axes;
  see Scope and "Series & universe" above.

## Future fields backlog

Deliberately deferred, not in v0.1:

- **`humor_flavor`** — witty_banter, slapstick, dark_comedy, satire,
  dry_wit. Raised during schema review: `humor_level` captures *how much*
  comedic material a book has; this would capture *what kind*. Holding
  off until it's clear this is load-bearing for recommendation quality
  rather than adding a field on spec.
- **Tropes deferred as too narrow for v1** — `touch_her_and_die`,
  `captive_or_captor_romance`, `teacher_or_mentor_romance`. Real terms,
  surfaced during the researched trope pass, but judged as mostly
  mattering to readers already deep in romantasy-specific taxonomy rather
  than changing recommendations for a general SFF reader. Revisit if
  tagging real books shows they're needed.
- **A real `audiobook_editions` table (one-to-many), not the current
  single-audiobook-per-book assumption.** Surfaced 2026-08-29 alongside
  the author/narrator field-contamination bug (`books.author` had
  narrator names mixed in — e.g. Words of Radiance read "Brandon
  Sanderson, Michael Kramer, Kate Reading"; fixed with a minimal
  `narrators text[]` column for that one case). The bigger, deferred
  idea: many books have more than one audiobook edition worth
  distinguishing — different narrators/casts, and notably **GraphicAudio
  full-cast dramatized productions**, which exist for a meaningful slice
  of this catalog's SFF titles and are a distinct listening experience
  from a standard single/dual-narrator audiobook. A real fix needs a
  `book_id, edition_type (standard/graphicaudio/etc.), narrator(s),
  runtime_minutes, production_company` table, not another single-value
  column — and real per-book sourcing work (Hardcover's API likely
  doesn't carry GraphicAudio editions at all; would need separate
  research). Deliberately not built in the same pass as the field-value
  audit below — it's a real schema addition plus a new data-sourcing
  effort, not a quick fix, and deserves its own scoped pass.
- **`solarpunk`** (setting_worldbuilding) — flagged during trope research
  as real but weaker/niche; not added.
- **Retroactive tagging of `elves`/`dwarves`/`fae_or_fairies`/`orcs`/
  `werewolves`/`shapeshifters` across the catalog — done 2026-08-29**
  (82 book_tropes rows across all 7 creature tropes, via 8 parallel
  batch agents + one manual consistency fix for kandra shapeshifters
  across the whole Mistborn saga). Still open: a broader deferred item,
  a real per-book romance-relationship and fantastical-creature
  specificity pass (Rhythm of War's Dalinar/Navani and Adolin/Shallan
  threads still flatten to `found_family`; spren/chasm fiends have no
  vocabulary distinct from `multiple_fantasy_species`) — a real residual
  gap even after the 2026-08-29 full-catalog audit, needs a dedicated
  pass rather than a quick fix.
- **`werewolves_or_shapeshifters` split into `werewolves` + `shapeshifters`
  — 2026-08-29.** User feedback: the original combined trope conflated
  two genuinely different reader signals — classic lycanthropy (full
  moon, silver vulnerability, involuntary wolf-monster transformation,
  e.g. Twilight's Jacob pack by pop-culture reputation, Lupin in Harry
  Potter, City of Bones' Downworlder werewolves) vs. general
  voluntary/skill-based shapeshifting (Animagi, kandra, dopplers,
  Beauty-and-the-Beast-style curses like Tamlin in ACOTAR or Nivellen in
  The Last Wish). Reclassified all 19 previously-tagged books by which
  specific mechanic actually appears — one book (Prisoner of Azkaban, for
  Lupin's condition *and* the Sirius/Pettigrew Animagi reveal) got both.
  One deliberate surprise: by the books' own internal mythology, Twilight's
  wolf pack are canonically shapeshifters, not lycanthropes (no moon-tie,
  no silver vulnerability, transform at will) — tagged `shapeshifters`
  despite the pop-culture "werewolf" label.
- **Content warnings deferred as too marginal for v1** —
  `religious_bigotry` (distinct from `religious_trauma_or_cults` —
  persecution *for* faith vs. harm *from* a religion/cult), `physical_abuse`
  non-domestic (risks real overlap with `domestic_abuse` + `child_abuse`
  combined), `forced_institutionalization` (niche). Real, weaker case than
  what was added — revisit if tagging shows they're needed.
- **`cannibalism`** (content_warnings) — considered during the 30-book
  pilot (The Road), rejected on reflection. Unlike the researched
  content_warnings additions above (cross-checked against StoryGraph/real
  book lists before adding), this was only a single in-the-moment
  inference while tagging one book — weaker evidence, and on the same
  "does this change the recommendation, not just is it upsetting" bar, it
  reads as a specific flavor of `body_horror` + `violence_intensity:
  graphic` rather than a distinct category, same reasoning that excluded
  gore/blood/injury earlier. Not added.
- **`work_type` (novella/novel) on `books` — built 2026-08-29.** User's
  idea, prompted by decimal `position_in_series` values (e.g. 2.5) not
  clearly signaling "this is a short-form entry" to a newcomer, plus
  audiobook-credit economics (a novella may not be "worth" a full Audible
  credit). No `novelette` value — this catalog is published SFF books,
  not magazine-length short fiction, so that category doesn't
  realistically occur as its own entry here. Deliberately NOT computed
  from `page_count` — checked the actual catalog data first and
  page_count turned out to be an unreliable discriminator (Tor.com's
  novella imprint uses a large trim/font, so *Edgedancer* at 272pp reads
  longer on the page than full novels like *Fahrenheit 451* at 227pp or
  *Piranesi* at 245pp; conversely *The Time Machine* at 144pp is a full
  novel, shorter than every Murderbot novella). Set manually instead,
  from real-world publishing classification: the four Murderbot Diaries
  novellas (*All Systems Red*, *Artificial Condition*, *Rogue Protocol*,
  *Exit Strategy* — *Network Effect* is the first full-length Murderbot
  novel), *Edgedancer*, and *This Is How You Lose the Time War* (won the
  2020 Hugo Award for Best Novella).
- **`crucial_to_arc` (or similar) flag on interstitial series entries**
  — future roadmap idea, raised 2026-08-29. Some novellas/standalones
  slotted between numbered series entries (via a decimal
  `position_in_series`) are skippable side stories, while others carry
  plot-critical material — e.g. *Edgedancer* (Stormlight Archive)
  deepens Nale the Herald's lore in a way some readers report skipping
  and missing, while *Dawnshard* bridges Stormlight books 3 and 4 across
  an in-story time jump. A flag distinguishing "skip freely" from
  "actually matters for the main arc" would help readers (and could
  factor into recommendation/reading-order logic) decide whether to
  spend time/an audiobook credit on an interstitial entry. Not built —
  logged for later.
- **Exact POV count (main POVs only) instead of the `pov_count` bucket
  scale** — future upgrade idea, raised 2026-08-29 alongside the
  single/multiple → 5-bucket widening (see `pov_count` above). Even
  `few`/`several`/`ensemble` buckets are still a compression of the real
  number, and a "main POV" count needs its own judgment call — excluding
  one-off/interlude chapters from a POV that otherwise never recurs
  (e.g. a single prologue chapter from a minor character), not just a
  raw count of every chapter's narrator. Deferred — real per-book
  editorial judgment call, larger effort than the bucket scale, revisit
  if the bucket scale proves too coarse in practice.
- **Rhythm-aware TBR / reading queue, not just a flat match-probability
  ranking** — future roadmap idea, raised 2026-08-29. Rather than only
  ranking candidates by score, a TBR generator could sequence them:
  insert a lighter or standalone book after a heavy book/series run
  before returning to the next series entry, user-calibratable (e.g.
  "give me a break book every N series entries," or a lightness/heaviness
  alternation preference). User's example: a reader working through The
  Wheel of Time who deliberately breaks up the series with standalone
  reads in between. Mostly buildable from fields that already exist
  (`darkness`, `emotional_register`, `violence_intensity`, `work_type`,
  `book_length`) — a new sequencing/UX layer on top of existing Book DNA
  rather than a new tagging pass. Not built — logged for later.
- **Diversity/anti-echo-chamber controls on recommendations** — future
  roadmap idea, raised 2026-08-29. Pure best-match scoring risks
  narrowing a user into an echo chamber (liked one werewolf book → only
  ever recommended more werewolf books). Two related but distinct
  mechanisms proposed: (1) a "summon something different" mode that
  trades some profile-match for deliberate novelty (RecSys precedent:
  Maximal Marginal Relevance — balance relevance against distance from
  recently-shown/rated books, on a user-tunable dial); (2) an explicit
  "less of X" fatigue control — a manual override that temporarily
  suppresses a specific trope/field even though the user's rating
  history says they usually like it (a deliberate exception to their own
  average, not a re-estimate of it). Real architectural implication:
  both require some memory of recent recommendation/reading history,
  which the current engine doesn't have — `recommend.py` is fully
  stateless today (a fresh profile computed per call from the full
  liked/disliked lists, no notion of "what have I already shown/served
  this user recently"). Not built — logged for later, real design work
  needed before it's buildable.

  Refinement 2026-08-29: "summon something different" needs a bounded
  *level* of different, not an unbounded toggle — a grimdark reader
  asking for variety wants adjacent-but-fresh, not the diametrical
  opposite (a cozy romantasy YA). This falls out of the diversity-dial
  formula by construction as long as the dial is capped well below 1.0:
  `final_score = (1 − diversity) × relevance + diversity × novelty` never
  drops the relevance term to zero, so a book that doesn't match the
  user's taste at all stays capped low regardless of how novel it is,
  while a book that's genuinely different-but-plausible scores on both
  terms and wins. UI should expose 2 labeled levels ("a bit different" /
  "surprise me"), not a raw slider up to 100% — same reasoning as
  rejecting raw star ratings for the ratings-precision discussion:
  labeled tiers avoid calibration ambiguity, and the ceiling must never
  reach pure-novelty (diversity = 1.0).
- **Book vs. audiobook recommendation mode** — future roadmap idea,
  raised 2026-08-29. Recommending a text read vs. an audio listen may
  need different weighting, not just a different length field:
  `prose_density`/`prose_complexity` plausibly matter more for text
  readers, while narration quality/pace (the currently-untagged
  `narrator_performance`/`narration_pace_vs_prose`/etc. fields) matter
  for listeners. Proposed as a `medium` parameter on `recommend()`,
  analogous to the `genre` parameter already built — chosen per "summon"
  request (like genre), not locked in at onboarding, since a reader may
  want a text pick one day and an audio pick another. Not built —
  confirmed 2026-08-29 that this is blocked on real data, not just
  deferred by choice: `audiobook_length` is only 59% populated (98/167)
  and `books.narrators` is populated for 1 book out of 167 — even the
  "easy tier" this would lean on doesn't exist yet. Backfill that first;
  revisit medium-mode only once it's real.
- **Post-read/listen ratings feeding narrator collaborative filtering**
  — future roadmap idea, raised 2026-08-29. Once users can log and rate
  a recommended book after finishing it (including, if they took the
  audiobook, a separate rating for the audiobook/narration itself), that
  per-narrator rating data could drive real collaborative filtering
  between users: "listeners who rated narrator A highly also rated
  narrator B highly" → recommend narrator B's books to someone who liked
  A, without needing any structured narrator-quality tags at all. This
  neatly sidesteps the Tier-B audiobook-field sourcing problem (see
  `audiobook_native` module notes above) by inferring narrator quality
  from correlated listener behavior instead of needing to source or
  judge it ourselves. Two real caveats: it needs an actual per-user
  ratings table to exist first (the same missing piece the
  diversity/fatigue mechanism above depends on), and it has a cold-start
  problem — useless until a critical mass of users have rated
  audiobooks by overlapping narrators. Also a different paradigm from
  the rest of the app: this is real collaborative filtering, which the
  original v1 design explicitly chose to skip — would be a deliberate
  hybrid addition later, not a v1 feature. Not built — logged for later.

- **2026-08-30 batch — feedback gathered from external contacts, 13
  ideas triaged.** Agreed build sequence: **rating-magnitude scoring
  system → revenge trope → explanation layer → Series DNA → the rest**.
  Two items turned out to already exist and needed no new work:
  description-detail-level is already `prose_density`
  (`sparse`/`moderate`/`lush` — its own definition already uses *The
  Fellowship of the Ring* as the "lush" example); "Reader DNA" already
  exists conceptually as `build_profile()`'s centroid+weights output, in
  the same feature space as Book DNA — just never named/productized as
  a user-facing concept.

- **Rating-magnitude scoring system (build first)** — `recommend.py`
  currently only accepts flat `liked_titles`/`disliked_titles` lists,
  no graduated scale at all, despite the 5-tier labeled scale
  (hated/disliked/it was okay/liked/loved) proposed earlier in the
  ratings-precision discussion. This was caught as a real, blocking gap
  2026-08-30: without a real score to predict, the held-out validation
  test idea (below) isn't meaningful yet — there's nothing for the
  system to predict *as* a rating, only a ranking. Needs to exist before
  several other items on this list are buildable for real.

- **Held-out validation test (blocked on the scoring system above)** —
  external suggestion: once a user has logged real ratings, ask them for
  ~10 more books they've read but haven't entered, get their honest
  opinion first (blind), then have the engine predict and compare
  against ground truth. Correctly identified 2026-08-30 as *not*
  actionable yet, unlike originally proposed — needs the rating-magnitude
  system first, otherwise there's no real predicted score to validate
  against, only a relative ranking.

- **Explanation layer ("this book is a strong match because of X, Y, Z"
  + the reverse for poor matches + a technical debugger view)** —
  bundles three external suggestions that all turn out to be the same
  underlying capability at different levels of polish: a natural-language
  "why this matches" surfaced to users, the same mechanism run in
  reverse to explain a poor match when a user searches a specific book,
  and a raw "recommendation debugger" view of the same data for our own
  QA/tuning. All three are UX/wording work on data the engine already
  computes — `score_book()` already returns a `contributions` list (top
  weighted factors) every call. Deliberately avoid framing this as a
  precise "90% match" — the score is a relative ranking, not a
  calibrated probability; use qualitative labels ("strong match") plus
  the reasons instead.

- **Series DNA** — external suggestion, judged the strongest idea in the
  batch. A series can change dramatically across its own run (The Wheel
  of Time: book 1 is single-POV, fast-paced, journey-structured; book 6+
  is multi-POV, slow, political, journey mostly absent) — recommending
  or scoring against only the first entry's Book DNA can misrepresent
  the whole commitment, including cases where a series gets darker/more
  violent as it progresses. Key insight: this is likely NOT a fresh
  tagging pass — it can probably be computed as an aggregation/rollup
  over `book_dna` rows already tagged per book, grouped by `series_id`
  and ordered by `position_in_series` (range/trajectory of `pov_count`,
  `darkness`, `violence_intensity`, pace, etc.), rather than requiring
  new per-book data. Directly strengthens the already-logged
  series-position-aware recommendation idea. Not built — real design
  work, but promising and comparatively cheap.

- **Confidence + source layer on field/trope values** — external
  suggestion, e.g. "slow pace" tagged with a 0.8 confidence level, plus
  which source produced it. Two real uses beyond just discounting
  uncertain tags in scoring: (1) a confidence score doubles as a triage
  signal for us — low-confidence books are exactly the ones that need a
  deeper research/re-tagging pass, since this session's own batch agents
  constantly flagged real uncertainty ("borderline," "genuinely
  uncertain") that today gets silently treated as equally-certain ground
  truth; (2) once community self-tagging (below) exists, confidence
  could rise specifically when community tags correlate with our
  existing tags, and a mismatch becomes a signal worth investigating
  rather than just noise. Real schema work (a companion confidence
  column per field/trope), moderate effort, sequenced after Series DNA.

- **Optional self-tagging + community validation + dispute flagging** —
  external suggestion: let users optionally tag books themselves via the
  same slider/dropdown Book DNA UI, aggregate across users as a
  community-validated signal, and let users flag a specific tag they
  disagree with for review (weight matters if many users flag the same
  thing). Valuable long-term, correctly scoped as optional/non-intrusive
  by the suggester, but needs real user accounts and a real tagging UI,
  neither of which exist yet (no `users` table at all). Clearly post-v1.

- **Post-read/DNF "why didn't it work" / "what did you love" dropdown**
  — external suggestion, worth distinguishing from what this doc already
  rejected elsewhere (asking users to explain field-by-field on every
  single rating, which defeats the point of structured Book DNA
  inference). This is different: optional, triggered only after a clear
  miss (a low rating or a DNF), and using pre-set common reasons ("too
  slow," "too much romance," "wasn't my mood," "DNF — couldn't get into
  it") rather than open-ended justification — targeted error-correction
  signal, not routine friction. Sequenced alongside the confidence layer,
  once real usage exists to generate this signal from.

- **"Recommend books with similar characters to X"** — external
  suggestion, self-identified by the suggester as not for this early
  stage. Correct: today's tropes describe the *book*, not individual
  *characters* with enough granularity to match character-to-character
  (e.g. "morally grey mentor" as its own tagged entity, not just "this
  book contains a morally grey character somewhere"). Needs a new
  `characters`-level data model — meaningfully bigger effort than
  anything else on this list. Deferred.

- **Hierarchical tropes** — external suggestion, term unclear to the
  person relaying it. Likely meaning: organize the flat trope vocabulary
  into a parent/child taxonomy (e.g. a `creature_presence` parent over
  `elves`/`dwarves`/`orcs`/`vampires`/`werewolves`/`shapeshifters`/
  `fae_or_fairies`) rather than unrelated flat tags. A shallow one-level
  version already exists (`group_name` on `tropes`). A real hierarchy
  would let scoring generalize for sparse data — someone who's liked
  several "any fantasy race present" books but never specifically an elf
  book could still get a sensible partial signal instead of zero.
  Legitimate technique, real modeling work touching the whole trope
  vocabulary and scoring code. Deferred — revisit if trope-sparsity for
  narrower tags becomes an observed real problem, not before.

## Open for review

Nothing outstanding. Both controlled vocabularies (`tropes` at 99 values,
`content_warnings` at 33) have had both a researched pass against real
external sources and a real-books pilot pass (30 books blind-tagged, see
`docs/pilot/`), and both are still expected to keep growing as an ongoing
practice once real books get tagged in step 04 — see "Vocabulary growth
process" above.

## Next step

Roadmap step 02: scaffold the app (Next.js + Supabase — auth, and core
tables for `books`, `users`, `ratings`, `book_dna`). This schema file is
the direct input for the `book_dna` table shape once the open-review items
above are settled.
