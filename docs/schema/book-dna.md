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
| `form` | standard_prose, epistolary, framing_device, verse |

`person: mixed` and `timeline: multi_timeline` (generalized from the old
`dual_timeline`, hard-coded to exactly two) both came from the 30-book
pilot — The Fifth Season mixes 2nd- and 3rd-person across its POV threads
and runs 3+ interwoven, non-chronological timelines. One data point, but
a well-known, Hugo-winning structural technique, not a fluke.

### 2. Pacing & tone — core
| Field | Values |
|---|---|
| `overall_pace` | slow, medium, fast |
| `pace_shape` | consistent, slow_burn_to_fast_finish, front_loaded, uneven |
| `drive` | character_driven, plot_driven, balanced, worldbuilding_driven |
| `darkness` | light, moderate, dark, grimdark |
| `humor_level` | none, light, moderate, heavy |
| `emotional_register` | comfort_read, bittersweet, tense, gut_punch |

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

### 3. Content & shape — core
| Field | Values | Spoiler |
|---|---|---|
| `romance_heat_frequency` | none, rare, occasional, frequent | no |
| `romance_heat_intensity` | na, closed_door, low, moderate, explicit | no |
| `violence_frequency` | none, rare, occasional, frequent | no |
| `violence_intensity` | na, mild, moderate, graphic, brutal | no |
| `content_warnings` | multi-select, see schema file | no |
| `worldbuilding_density` | light, moderate, dense | no |
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
The UI gates display of `true` instances the same way any other
spoiler-flagged field does; the recommendation engine always reads the
real value regardless.

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
- **`solarpunk`** (setting_worldbuilding) — flagged during trope research
  as real but weaker/niche; not added.
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
