# Bookspell — project log

A running history of the project's course: what got built, what got
argued over, what changed as a result, and why. Kept for retrospective
analysis — both "how far have we gotten" and "what would we do
differently next time." Entries are dated and appended in order; nothing
here gets rewritten after the fact, only added to.

---

## 2026-08-27 — Starting point

Work began from an existing planning artifact (published separately as
"Bookspell") laying out the concept: a sci-fi/fantasy book recommendation
app built on structured "Book DNA" attributes instead of aggregate star
ratings, with audiobook-native fields as the strategic wedge no
competitor structures. The artifact already contained: the core thesis,
a locked decisions log, a competitive landscape table, a first-draft DNA
taxonomy (five categories, one SFF-locked), the recommendation mechanism
concept (per-user weighted vector, no collaborative filtering for v1),
an AI-assistant concept (single-turn, reuses the tagging pipeline's
extraction pattern), a data-sourcing plan, tech stack picks (Next.js +
Supabase), a cost breakdown, and a 10-step build roadmap.

The working directory was empty. Decision: follow the roadmap's own
step 01 first — lock the DNA schema as a written spec before any code,
since the plan itself flags schema changes as the most expensive thing
to fix after tagging starts.

## 2026-08-27 — Schema v0.1, first draft

Wrote `docs/schema/book-dna.md` and `docs/schema/book-dna.schema.yaml`:
the five categories from the artifact (POV/structure, pacing/tone,
content/shape, audiobook-native, tropes/craft), each field given a
concrete controlled vocabulary, plus the spoiler-gating model and a
starter set of ~28 tropes and 14 content warnings. Flagged five explicit
"open for review" items rather than presenting it as finished.

## 2026-08-27 — Schema review, round 1: structural fixes

User-driven review surfaced several design flaws in the first draft, each
traced to conflating two different questions inside one field:

- **`series_structure`** conflated "does this book's own plot resolve on
  its own" (intrinsic, stable) with "is this book part of a series and is
  that series finished" (relational, mutable — changes when a sequel gets
  written years later, e.g. The Shining → Doctor Sleep). Fixed by
  replacing it with `narrative_closure` (book-level, stable) and moving
  series/universe membership out of `book_dna` entirely into a documented
  data-model note (`universe → series → book` hierarchy, handles cases
  like The First Law's standalones belonging to a shared universe without
  belonging to any one trilogy).
- **`ending_type`** conflated emotional flavor (happy/tragic/ambiguous/
  bittersweet) with structural cliffhanger-ness — a book can land a happy
  character beat while leaving the external plot unresolved. Split into
  `emotional_resolution` and `ends_on_cliffhanger`.
- **Twists**: one field couldn't distinguish a single late reveal (The
  Sixth Sense) from a book that keeps reversing itself throughout (The
  Prestige). Split into `twist_ending` and `twist_filled`.
- **`romance_heat_level` / `violence_gore_level`**: single fields
  couldn't express "rare but intense" vs. "frequent but mild." Split each
  into frequency + intensity pairs.
- Added `sanderlanche` (genre slang, kept as-is rather than sanitized) and
  `scifi_hardness` as the sci-fi analog to `magic_system_hardness` — the
  latter a real, previously-unrepresented gap: fantasy readers had a
  hardness spectrum, sci-fi readers didn't.

**Lesson surfaced here, not yet named as such:** several of these fixes
came from the user asking "wait, doesn't X actually mean two different
things?" — a pattern that recurred through the whole project. Worth
treating that question as a standing checklist item whenever a field
feels like it's trying to answer more than one thing.

## 2026-08-27 — Schema review, round 2: researched vocabulary passes

The `tropes` and `content_warnings` lists were originally brainstormed
from memory. User pushed back specifically on the romance-trope group
feeling disproportionate and asked for real sourcing rather than more
guessing. Two research passes followed (via background agents, to keep
raw search output out of the main conversation):

- **Tropes**: cross-checked against TVTropes, StoryGraph, romantasy trope
  lists, and trope tags on well-known genre books. Result: 30 → 61
  values across 6 groups. Important correction mid-pass: several
  candidate romance tropes were *real terms* but judged too narrow (only
  matter to romantasy-specific taste, not a general SFF reader) and
  moved to a backlog instead of added — establishing "is this a real
  term" as necessary but not sufficient; the actual bar became "does this
  change a recommendation."
- **Content warnings**: cross-checked against StoryGraph's actual
  per-book warning data and real warning lists for The Poppy War and
  ACOTAR. Result: 14 → 23 values, plus a discovered difference in
  models — StoryGraph's severity axis (`Minor/Moderate/Graphic`) measures
  depiction intensity, while this schema's `severity`
  (`brief/moderate/central_theme`) measures narrative centrality. Both
  valid, deliberately different questions.

## 2026-08-27 — The 30-book blind tagging pilot

User's framing, in their own words: schema mistakes get expensive once
real tagging starts at scale, so run a test first. Proposed protocol,
refined together into its final shape:

- 30 books, user-selected, mixed read/unread/liked/disliked, sizing
  discussed explicitly (15 → 30 → considered 60, held at 30 on
  diminishing-returns grounds: this is a qualitative smoke test for
  schema problems, not a statistically rigorous study, and tagging
  quality risked degrading under more volume in one pass).
- **Blind protocol**: all 30 books tagged against the schema *before* any
  read/liked/unread reveal, to avoid unconsciously biasing tags toward a
  good match.
- **Grounded tagging**: each book researched (synopsis + review
  consensus) rather than tagged from memory, matching how the real
  pipeline is designed to work.
- Split across 6 parallel background research/tagging agents (5 books
  each) to keep raw search output out of the main context while
  preserving review quality.
- **Train/test split on the reveal**: of 10 actually-liked books, only 6
  were revealed as the "seed" for a preference vector; the other 4 stayed
  hidden alongside 8 not-liked and 12 unread books, to check whether
  scoring correctly separated liked from disliked without being told in
  advance which was which.

**Findings** (full detail in `docs/pilot/findings.md`,
`docs/pilot/tagged-books.yaml`):
- Genre scope (closed to sci-fi/fantasy) worked as intended — 2 books
  (Bird Box, The Road) correctly read as out-of-scope. One correction on
  reflection: Interview with the Vampire was initially miscalled a poor
  fit; reconsidered as legitimate paranormal fantasy (vampirism as an
  internally-ruled supernatural system), distinct from Bird Box's
  deliberately unexplained horror.
- 13 real trope gaps, most notably two whole subgenres with zero prior
  coverage: LitRPG/progression fantasy and mythological retelling.
- 1 content-warning candidate (cannibalism) proposed, then rejected on
  reflection — unlike the researched additions, it was a single
  in-the-moment inference rather than externally validated, and read as a
  flavor of existing `body_horror`/`violence_intensity` rather than a
  distinct category. Kept out.
- Field-level fixes: `person: mixed` + `timeline: multi_timeline`
  (generalized from `dual_timeline`) for mixed-POV/multi-timeline books
  like The Fifth Season; `drive: worldbuilding_driven` for New
  Weird-style books; `magic_system_hardness`'s undefined `none`-vs-`na`
  distinction, documented; `content_warnings` gained a per-instance
  `reveals_spoiler` flag (a warning's presence can itself be a spoiler on
  one book and not another).
- All fixes applied to both the schema and the tagged corpus, with
  reasoning logged inline rather than silently changed.

## 2026-08-27/28 — Reveal-and-score round

Built a real (if intentionally simple) scoring mechanism rather than
eyeballing similarity: encoded the tagged DNA vectors, computed cosine
similarity per field, averaged into the schema's 5 categories, then
averaged across categories — specifically to stop high-cardinality
categories (96 tropes) or generic genre-convention matches from mechanically
dominating over more specific, taste-differentiating signal. Explicitly
scoped as testing unweighted, cold-start similarity from 6 examples — not
the real per-user learned-weight regression, which needs far more ratings
than a one-off test can provide.

**Result**: real directional signal (held-back liked books scored higher
on average than not-liked ones; a liked book landed at rank 1 of 24), plus
one clear, traceable miss (a liked sci-fi book scored near the bottom,
driven by a genre-skewed 6-book seed and a specific zero-overlap field
collision) — a legible, expected cold-start failure, not a schema defect.

**User's follow-up qualitative analysis was the most valuable part of this
round**, and produced a clean three-way split of findings:

1. **Schema-fixable, applied immediately**: `age_category` (a YA aversion
   unrelated to genre — clean gap) and `message_intensity` (an aversion to
   heavy-handed moral/philosophical argument that generalized across
   different ideologies — pacifism-as-message and religious-redemption-
   as-message both landed the same way). The second is notable: it's a
   genuinely new field that stays inside the schema's existing
   ideological-neutrality principle, tagging *how overt* an argument is
   without ever tagging *which* argument — same trick as not caring
   whether a user likes or dislikes explicit content, just flagging
   presence and letting ratings teach the direction.
2. **Engine-level, not schema fixes** — documented as "Known limitations"
   in `book-dna.md` rather than solved: trope fatigue/satiation (a
   preference that inverts with the reader's own cumulative exposure,
   e.g. magic-school fatigue by the nth book), perceived originality as
   the same phenomenon at a wider scope, and the honest acknowledgment
   that even "low-subjectivity" fields (pace, tone) still carry real
   reader-to-reader variance against review-consensus tagging.
3. **Inherent limits, not gaps to chase**: execution/voice-chemistry
   ("well-written but didn't enjoy it") is exactly what the schema was
   designed to not try to capture — a boundary, not a miss.

Follow-up clarification: confirmed the recommendation engine's weighted-
sum architecture already produces graduated score reduction for a
disliked trope, not disqualification, by construction — The Wheel of
Time keeps scoring well on `chosen_one`-averse ratings because eight
other tropes and every other field still contribute. Extended the
existing content_warnings three-tier model (soft signal / informational
display / explicit opt-in hard filter) to cover tropes too, for the
minority of users who want an absolute exclusion rather than a lowered
score. Also named an open research question for step 10 (dogfood): the
real minimum-data threshold for reliable recommendations likely depends
on *category coverage*, not just raw rating count — directly explaining
why the roadmap's taste-quiz step exists architecturally.

## 2026-08-28 — Roadmap resequenced

User questioned why the original roadmap put "scaffold the app" (step 02:
Next.js, auth, hosting) before any dataset existed. On inspection, the
concern was correct: almost none of that is a real prerequisite for
building or validating the dataset. The tagging pipeline is just a script
against a database; the recommendation engine can be built and tuned as a
standalone module against a solo user's own ratings with no UI at all —
which the 30-book pilot had already demonstrated by hand, informally.
The only genuine prerequisites are the database tables themselves and a
minimal internal tool (not the end-user app) for reviewing tagged output
and logging ratings at scale.

Resequenced from 10 steps to 11: lock schema → **stand up the database**
→ bootstrap seed catalog → build tagging pipeline + minimal internal tool
→ **build the recommendation engine as a standalone module** (tuned
against solo ratings, no API yet) → **then** scaffold the app (wrap the
engine behind an API only now, as its first real consumer) → onboarding/
rating flow → book detail pages → friend graph → dogfood → decide on
native. Rationale: front-load the risky, unproven work (tagging pipeline,
rec engine) and defer the well-understood boilerplate (auth, Next.js,
hosting) until there's real, validated data to build against — the same
principle that motivated running the pilot before writing any code at
all. Published to the artifact with a new decisions-log entry recording
the "why," not just the "what."

## 2026-08-28 — DNA accuracy review (the check the pilot design called for but skipped)

The original pilot design included checking tagged values against
firsthand knowledge for books the user had actually read — not just
checking whether the similarity ranking came out right. That check got
skipped in the rush to score and reveal; the user caught the gap and
asked for it directly, on the 10 books read and liked.

Result: two more real trope gaps (`isekai`, distinct from both
`portal_fantasy` and `litrpg_or_progression_fantasy`;
`renaissance_or_mercantile_setting`, from Lies of Locke Lamora's
Venice-modeled city), a `violence_intensity: brutal` tier added after
direct reader comparison showed The Way of Kings and Kings of
Paradise/Prince of Thorns landing on the same top bucket despite very
different actual intensity, and four concrete per-book corrections: The
Golden Compass gained a missing `parallel_universe_or_multiverse` tag,
The Eye of the World's ending was wrongly tagged `happy` (corrected to
`bittersweet`), Kings of Paradise's `multiple_fantasy_species` was
removed as unsupported by the user's own memory of the book, and Prince
of Thorns' `ends_on_cliffhanger: resolved` was confirmed correct rather
than changed — which also cross-validated the same call on The Eye of
the World using a consistent definition. One proposed field (a
"distinctive magic system" tag for The Way of Kings) was declined as
already covered by the execution-quality boundary named in the previous
round's Known Limitations, rather than special-cased.

**Lesson worth naming on its own:** this check was part of the original
test design and got dropped once the scoring/reveal became the visible,
exciting part of the exercise. Worth remembering that a planned
validation step doesn't get to skip itself just because a later step in
the same plan produced satisfying results first.

## 2026-08-28 — DNA accuracy review, part 2 (the remaining 8 read books)

Extended the same accuracy check to the books read but not loved (Bird
Box, Assassin's Apprentice, We Are Legion, Interview with the Vampire,
The Poppy War, Circe, Dark Matter, He Who Fights with Monsters) —
deliberately not the 12 unread books, since the user can't verify tagging
accuracy against books they haven't read.

Result: one new trope (`vampires`, distinct from
`immortal_or_ageless_character` and `monster_or_fae_romance`), two real
per-book corrections (Interview with the Vampire's `timeline` from
`linear` to `multi_timeline` — a genuine two-timeframe structure in the
novel itself, not just the film adaptation; Assassin's Apprentice's
`pace_shape` from `slow_burn_to_fast_finish` to `consistent`, taking the
user's firsthand read over the original review-consensus tag), and two
reactions (Circe "boring," Dark Matter "unoriginal") reconfirmed as
already-documented execution/engine-level limitations rather than new
schema questions — useful cross-validation that those categorizations
are holding up on a second pass, not just a one-off judgment call.

Also surfaced one rating-flow design note (a DNF is probably a stronger
negative signal than "finished and disliked" — worth the eventual rating
flow distinguishing the two) and two future-feature ideas: a
friend-recommendation weighting scheme (which turned out to already be
specified in the original artifact's rec-engine design — good convergent
validation of the user's own reasoning, not a new requirement) and a new
TBR-list feature idea (tabs for algorithm-recommended / friend-
recommended-with-match / manually-ordered queue), logged for roadmap
steps 08–09 but not yet added to the published artifact.

## 2026-08-28 — Book/series length fields, and an ideas backlog for the artifact

Two more items from the same conversation thread. First: a real,
previously-uncaptured schema gap — a reader avoiding The Wheel of Time
reacts to "14 books," not its tropes; a reader avoiding Stormlight reacts
to ~450,000-word individual volumes, not epic fantasy as a genre. Added
`book_length` (bucketed from page/word count, same bibliographic-fact
shape as `age_category`) for the per-book half, and `book_count` on the
`series` entity (alongside its existing `status` field) for the
series-level half — deliberately two separate fields, since few-huge and
many-normal-sized are both "a lot of commitment" for different reasons.
Both get the three-tier content-warnings-style treatment (soft signal,
display, explicit opt-in cap), with the cap likely mattering more here
than for most fields, since approachability is often a hard threshold.

Second: agreed the published artifact should stay the single reference
document for the project, but the roadmap section itself should stay
clean and sequenced rather than accumulating every feature idea in place.
Added a new "Ideas backlog" section (§12) to the artifact — separate from
both the roadmap and the open-questions section — where feature ideas get
logged with a tag for which roadmap step(s) they'd land in once their
turn comes. Seeded with the TBR-list idea from the previous entry; the
friend-weighting idea didn't need an entry since it was already specified
in the roadmap itself. Also added a decisions-log entry for the length
fields, matching how every other schema decision has been recorded.

Quick follow-up the same day: added `audiobook_length` to
`audiobook_native`, bucketed from listening hours rather than derived
from `book_length` — narration pace means the two can diverge, and for
an audiobook-first product, hours-to-listen is the more relevant
approachability signal for a lot of users than page count.

## 2026-08-28 — Step 02: the database is up

Initialized git (the project had none until now) and a local Supabase
project (`supabase init` + `supabase start`, backed by Docker — no cloud
account needed yet, matching the resequenced roadmap's point that this
step needs no auth/hosting).

Translated `book-dna.schema.yaml` into an actual migration
(`supabase/migrations/20260828000000_book_dna_schema.sql`), generated
programmatically from the schema file rather than hand-transcribed, to
avoid errors across 99 tropes and 33 content warnings. Design calls made:
`tropes` and `content_warnings` got real lookup tables (per-value
metadata, and growth by `INSERT` rather than migration, matching how
often those two vocabularies have actually grown this session) while
every other scalar field (~29 of them) got a `CHECK` constraint instead,
since those are far more stable; `book_dna` is one wide table, one row
per book; `series`/`universe` carry live `status`/`book_count` columns,
not frozen tag data, per the existing data-model note.

Migration applied clean on the first try. Loaded the 30-book pilot corpus
in as real content (not just an empty schema) — this was a genuine
smoke test, not just ceremony, and it caught something real: Bird Box
still had the pre-rename `dual_timeline` value that never got updated
when that field was generalized to `multi_timeline` earlier in the
schema work. Wrote a validation pass (checks every book's every field
against the schema's actual allowed values) before re-seeding, confirmed
clean, then reloaded successfully — 30 books, 30 DNA rows, 130 trope
links, 68 content-warning links, all verified against the corrected
corpus directly in the live database.

**Lesson consistent with the rest of this project:** loading real data
found a real bug that reading the files carefully did not. Same pattern
as the original pilot's whole reason for existing — validate against
real data, don't just trust that a review pass caught everything.

## 2026-08-28 — Step 03: seed catalog bootstrapped from Hardcover

Signed up for a Hardcover account and generated a scoped API token
("Bookspell - seed catalog ingestion", `read:catalog` only, 1-year
expiration) via browser automation once the user authorized doing it
directly. Saved to a gitignored `.env`, never exposed in chat.

Investigated Hardcover's actual GraphQL schema live (introspection, not
assumed from memory) before writing any queries — a Hasura-generated API
over Postgres plus a Typesense-backed `search` field. Found the real
per-page cap (25, not the 110 first assumed) and the real home for
audiobook duration (`default_audio_edition.audio_seconds` — the top-level
`books.audio_seconds` field is unpopulated for every book tried, confirmed
directly against Harry Potter's known audiobook data before trusting it
elsewhere).

Wrote `scripts/ingest-seed-catalog.js`: matches the 30 pilot books by
title+author against Hardcover and updates their existing rows (preserving
`book_id` so DNA tagging stays linked) rather than inserting duplicates,
then pulls top Fantasy + Science Fiction titles by popularity for the rest
of the catalog. `series` rows get created with live `status` (fetched
separately, since the search index doesn't carry `is_completed`) and
`book_count`.

Three real bugs surfaced and fixed while running it against live data —
consistent with this project's whole pattern of real data finding what
research/design review doesn't:
1. **Pilot-matching heuristic** — name-order mismatches ("Liu Cixin" vs.
   Hardcover's "Cixin Liu"), an over-strict exact-title requirement (missed
   "We Are Legion" vs. our "We Are Legion (We Are Bob)"), a missing accent
   in the title normalizer (Circé vs. Circe), and relevance-sorted (rather
   than popularity-sorted) search results letting comic-book adaptations
   outrank the actual Wheel of Time novel. Fixed all four; pilot match rate
   went 26/30 → 30/30.
2. **Duplicate rows** — a popular pilot book can also appear in the general
   genre pull, and the first run created untagged duplicate rows for
   exactly the four books the matching heuristic had failed on (Three-Body
   Problem, Eye of the World, Circe, We Are Legion). Verified zero DNA data
   was attached to the duplicates before deleting them, then fixed the
   script to exclude any hardcover_id already present in the database, not
   just ones matched in the current run.
3. **Audiobook duration** — as above; backfilled all previously-inserted
   rows once the correct field was found (`scripts/backfill-audio-duration.js`).

Final state: 168 books (30 pilot + 138 new), 83 series, all 30 pilot books
now have real page counts/audiobook hours/series links. `universe` stays
unpopulated — deliberately, since no metadata API models curated shared
continuities like "The First Law World"; that's a manual step for later.

## Current status (as of 2026-08-28)

- Schema: locked at v0.1, two research passes, one 30-book blind pilot,
  one prediction-vs-reaction validation round, one DNA accuracy review
  against firsthand reader knowledge, in two rounds (10 liked books, then
  the remaining 8 read-but-not-loved books). 99 tropes, 33 content
  warnings, all changes logged with reasoning in `book-dna.md`.
- Roadmap: resequenced, published to the artifact.
- Database: step 02 done. Local Supabase project running (git
  initialized, `supabase start` via Docker), migration generated
  programmatically from the schema, all 8 tables live.
- Seed catalog: step 03 done. 168 books (30 DNA-tagged pilot books + 138
  new), 83 series, sourced from Hardcover's API. Bibliographic data only —
  no DNA tags on the 138 new books yet.
- Next up: step 04, the tagging pipeline (LLM structured extraction to
  fill `book_dna` for the 138 untagged books, plus a minimal internal tool
  for reviewing tagged output and logging ratings at scale).

## Lessons for future projects

- **A small real-data pilot catches more than research ever will.** Two
  full research passes on the trope/content-warning vocabularies missed
  gaps that a single 30-book blind tagging exercise surfaced immediately,
  because research finds what's documented elsewhere; a pilot finds what
  actually breaks against real examples.
- **"Is this a real term" is a weaker bar than "does this change the
  outcome."** Every vocabulary-growth decision in this project eventually
  got re-tested against the second question, and it caught things the
  first one let through (deferred romance tropes, the rejected cannibalism
  warning).
- **Watch for a field secretly answering two questions at once.** Nearly
  every structural schema fix in round 1 followed the same shape: a field
  conflated an intrinsic fact with a relational/mutable one, or an
  emotional axis with a structural one. Worth checking for explicitly
  whenever a field feels like it's straining to cover an edge case.
- **Not every observed problem is a data-model problem.** Trope fatigue,
  novelty perception, and execution-quality chemistry all surfaced as
  real user concerns, and all three turned out to need a different kind
  of fix (a smarter recommendation algorithm, or an accepted boundary) —
  not a new field. Worth asking "does this belong in the schema or in the
  engine" before reaching for a schema edit by default.
- **Interrogate conventional ordering, not just conventional content.**
  The roadmap's step ordering (app before dataset) went unquestioned
  until it was asked about directly, even though the actual dependency
  structure didn't support it. The same "why does this come first"
  question is worth asking about sequencing, not just about individual
  decisions.
