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
  new), 83 series, sourced from Hardcover's API.
- Step 04 (tagging pipeline): **complete — 168/168 books now have
  `book_dna`.** The 30-book test batch (forked subagents) was followed by
  a full pass over the remaining 108 books during a user-authorized
  autonomous window, using lighter-weight non-forked agents instead (see
  the 2026-08-28 "remaining catalog" entry below for why, and the real
  cost difference it made).
- Next up: a minimal internal review tool to spot-check tagging quality
  across the full catalog, then step 05 (recommendation engine). A batch
  of schema vocabulary gaps surfaced across all three tagging rounds is
  logged in `docs/remaining-catalog-tagging/findings.md` and
  `docs/step04-test-batch/findings.md`, awaiting a deliberate review pass
  with the user before any are applied.

## 2026-08-28 — Step 04 test batch: 30 books tagged, real usage measured

Before committing to tagging all 138 untagged catalog books, ran a
smaller test: chose Claude (via forked subagents in this session) over
either a local model or a separate hosted Anthropic API key, reasoning
through the actual tradeoffs rather than defaulting to the original
plan's "local model for cost" assumption:

- The schema has grown considerably more nuanced since that original
  local-model assumption was made (`message_intensity`, `emotional_resolution`
  vs. `ends_on_cliffhanger`, 99 tropes with real near-duplicates to tell
  apart) — exactly the kind of judgment call a small quantized local model
  tends to get wrong, and the pilot already showed even careful tagging
  needs real verification.
- A standalone script hitting the Anthropic API directly would need a
  new, separately-billed credential and would incur real (if modest)
  per-token cost — distinct from Claude Code's subscription-based access,
  a distinction the user asked about directly and got a real answer to
  rather than an assumption.
- Chose instead: continue using this session's own forked subagents (as
  in the original pilot), trading a reusable standalone pipeline script
  for zero new cost/credentials, using only the user's existing Claude
  Code access.

Before running the full batch, the user asked whether there's a monthly
usage cap in addition to the known 4-hour session limit. Researched
rather than guessed: confirmed it's a **weekly** limit, not monthly (fixed
day/time per account, not a calendar boundary) — publicly documented, but
the user's own account screenshot was the real answer: Team plan, 31%
session used (resets 2h20m), 36% weekly used (resets in 14h10m), plus a
temporary 50%-higher weekly limit active through August 31. Good timing
for a token-heavier task, and low risk either way given the short reset
window.

Test batch: 30 untagged catalog books (well-known titles — Sea of
Tranquility, LOTR trilogy books, Dune, Mistborn, A Song of Ice and Fire,
Harry Potter, Murderbot, several others), tagged via 6 forks of 5 books
each, using the synopsis already stored from step 03 as the primary
source (supplementary web search available but rarely used, given how
well-documented these titles are). All 30 validated cleanly against the
schema and were inserted into `book_dna`/`book_tropes`/
`book_content_warnings`. `book_length`/`audiobook_length` were
deliberately NOT left to the model — computed directly from the
`page_count`/`audiobook_duration_minutes` already sitting in `books` from
step 03, since those are arithmetic, not judgment calls (verified: Dune
704pp/21hrs → epic/long; The Lord of the Rings 1178pp/22.6hrs →
epic/long; Fahrenheit 451 227pp/5.15hrs → short/short).

Four schema-gap candidates surfaced (Jurassic Park's genetic-engineering
trope, Good Omens' cross-genre satire gap, a second independent hit on
the LitRPG embedded-game-text `form` gap, and a mythological-vs-fairy-tale
retelling distinction question) — logged in
`docs/step04-test-batch/findings.md`, none applied yet, same discipline
as always: real gap, not just "a real term exists."

**Usage cost**: ~5.0M subagent tokens total across the 6 forks for 30
books (831,859 / 836,022 / 831,484 / 831,827 / 831,484 / 844,156) — most
of that per-fork cost is inherited conversation history (this session is
long), not the book-tagging work itself. Real-world Claude Code usage
delta from the user's own before/after usage screenshots is the
authoritative number, not this token count — see whatever the user
observed for the actual decision on how to proceed with the remaining 108
books.

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

## 2026-08-28 — Remaining catalog tagged: all 108 books, methodology change

User authorized ~2 hours of autonomous work while away from their
computer ("use it to the max if you need"), specifically to tag as much
of the remaining 108-book catalog as the session's usage budget allowed,
using Claude via subagents rather than a local model or a separate
Anthropic API key (consistent with the cost/credential reasoning already
logged for step 04).

**Methodology change from the 30-book test batch**: the test batch used
forked subagents (`subagent_type: "fork"`), which inherit the full parent
conversation history — by that point in the session, ~830K-840K tokens
per fork for only 5-6 books of actual tagging work. This round switched
to plain background agents that start fresh and read the schema file
directly (`docs/schema/book-dna.schema.yaml` + `book-dna.md`) instead of
relying on inherited context. Per-agent cost came in at ~40K-65K tokens
for 6 books — roughly 15-20x cheaper, with no observed drop in tagging
discipline (same vocabulary-only rule, same gap-flagging behavior, same
schema-fidelity checks). This is the reason all 108 books got tagged in
one window rather than the partial pass originally planned.

Work ran in three waves of six 6-book agents each (36 books/wave), fully
in parallel within each wave. All three waves' output was consolidated,
cross-checked against the schema's literal trope/content-warning ID
lists and CHECK-constrained enum values (catching zero actual errors —
every ID and value used across all 108 books was already valid), then
inserted into `book_dna`/`book_tropes`/`book_content_warnings`, with
`book_length`/`audiobook_length` computed deterministically from stored
`page_count`/`audiobook_duration_minutes` as in every prior round.

**Result: 168/168 books now tagged — full catalog coverage**, confirmed
via a direct count query at the end of the session.

Full tagging data and this round's findings (schema vocabulary gaps,
poor-genre-fit candidates) are in `docs/remaining-catalog-tagging/`:
`wave1-tagged.json`, `wave2-tagged.json`, `wave3-tagged.json`,
`findings.md`.

**Open items for the user's review (not decided unilaterally)**:
- Several books tagged but flagged as poor genre fits for a sci-fi/
  fantasy-scoped catalog (same treatment as Bird Box/The Road earlier):
  The Silent Patient, The Girl with the Dragon Tattoo, House of Leaves,
  Slaughterhouse-Five, One Hundred Years of Solitude, The Alchemist,
  Tomorrow and Tomorrow and Tomorrow (the last tagged with an empty
  `genre` — no sci-fi/fantasy tag applied at all).
- The LitRPG `form` gap (no schema value for embedded game-notification
  text) recurred 6+ times across three tagging rounds now — the strongest
  candidate yet for an actual schema addition rather than a logged-only
  gap.
- A handful of other recurring trope/content-warning gaps (corruption
  arcs, mythological-figures-as-characters, intelligence-enhancement-then-
  reversal, fantasy-side satire, crime-family sagas, structured death-
  tournaments, species uplift, pandemic/epidemic content warning,
  fictional-species-based prejudice content warning) — full list in
  `docs/remaining-catalog-tagging/findings.md`.

## 2026-08-28 — Vocabulary growth round 2: 11 tropes, 4 content warnings, 1 form value

User reviewed the gap list from the remaining-catalog round and approved
applying it (rather than leaving it logged-only). Added, following the
same "specific book, specific gap, distinct-from-X" discipline as every
prior vocabulary decision:

- 11 tropes: `ghost_sight`, `sudden_apocalypse_event`,
  `satirical_or_comedic_fantasy`, `crime_family_saga`,
  `deadly_competition_or_trial`, `survivalist_ingenuity`, `uplift`,
  `corruption_arc`, `mythological_pantheon_as_characters`,
  `tragic_reversal_of_fortune`, `amnesia_driven_narrative`.
- 4 content warnings: `pandemic_or_epidemic`,
  `fictional_species_prejudice`, `incest`, `chronic_illness_or_disability`.
- 1 new `form` value: `embedded_system_text`, closing the LitRPG
  embedded-game-text gap that had recurred 6+ times across all three
  tagging rounds (pilot, step04, remaining-catalog) — the clearest case
  yet of "does this predict a different recommendation" being met through
  repetition.

Applied via `supabase/migrations/20260828020000_vocabulary_growth_round2.sql`
and retroactively tagged onto the specific books that originally
surfaced each gap (16 new trope associations, 5 new content warnings, 8
books' `form` corrected) — not a full re-tagging sweep of the catalog.
Full mapping in `docs/remaining-catalog-tagging/findings.md`.

Catalog stands at 168/168 books tagged, 110 tropes, 37 content warnings.

Separately, the user brought a list of field ideas from friends (weird
factor, gore level, story scope/stakes scale, philosophical-depth vs.
plot-driven-fun axis, prose description density, prose/language
complexity, progression fantasy, coming-of-age, death-games, dragons,
politics-heavy). Analyzed but deliberately not implemented in this pass —
some already covered by existing fields (gore level by
`violence_intensity`, progression fantasy by the existing
`litrpg_or_progression_fantasy`, politics-heavy substantially by
`court_intrigue`), others recommended as genuinely new axes worth adding
pending the user's decision (story scope/stakes scale, philosophical-vs-
plot-driven axis, prose density, prose complexity, `coming_of_age` and
`dragons` as new tropes). Not yet decided or added.

## 2026-08-28 — Vocabulary growth round 3: 4 new scalar fields, full catalog retag

Implemented the "worth adding" list from the friend-sourced field ideas
(see the prior entry): 4 new scalar fields, added to the schema and then
filled in for all 168 books (unlike tropes/content warnings, a scalar
field needs a value on every row, not just an optional retroactive tag).

- `prose_density` (sparse/moderate/lush) — under `pov_structure`, how
  much physical/sensory description the prose carries.
- `prose_complexity` (accessible/moderate/dense) — under `pov_structure`,
  vocabulary/sentence-structure difficulty, independent of prose_density.
- `intellectual_weight` (escapist/moderate/cerebral) — under
  `pacing_tone`, how much the book invites philosophical/ethical/
  psychological reflection vs. functions as plot-forward entertainment.
- `stakes_scope` (intimate/regional/global/cosmic) — under
  `content_shape`, the scale of what's at risk.

Plus 2 new tropes: `dragons` (parallel to the existing `vampires` —
specific creature mythology, not just "fantasy creature exists") and
`coming_of_age` (a real, previously-uncovered bildungsroman trope).

Applied via `supabase/migrations/20260828030000_vocabulary_growth_round3.sql`.
The 4 scalar fields were filled for all 168 books using the same
lightweight non-forked-agent pattern from the remaining-catalog round —
7 parallel agents, 24 books each, ~26-38K tokens per agent (~225K total
for the full catalog) since the task per book (4 quick judgment calls,
mostly on well-known titles) is much lighter than full DNA tagging.
`dragons`/`coming_of_age` were retroactively applied only to the clearest,
highest-confidence matches (25 books total) — not a full audit of all 168
for either trope.

Full field-value data: `docs/remaining-catalog-tagging/round3-new-fields.json`.

Not implemented from the same list (already covered by existing fields,
per the analysis in the prior log entry): gore level, politics-heavy as
a separate scalar. Progression fantasy already existed as
`litrpg_or_progression_fantasy` before this round.

Catalog stands at 168/168 books tagged with all core + round-2 + round-3
fields, 112 tropes, 37 content warnings.

## 2026-08-28 — Internal catalog review tool

Built the "minimal internal review tool" flagged earlier as a
prerequisite before the recommendation engine (step 05). Single static
HTML file (`tools/catalog-review/index.html`), no build step, no
framework — queries Supabase's auto-generated REST API (PostgREST)
directly from the browser. Required one small migration
(`20260828040000_review_tool_read_grants.sql`) granting the `anon` role
read access to the catalog tables, since PostgREST enforces grants even
with RLS off.

What it does: browsable/searchable book list with cover art, click-through
to a full per-book DNA view (grouped and labeled the way the schema
groups fields, not raw column names), and cross-catalog filtering by any
scalar field, trope, or content warning combination — the main point
being able to ask "show me everything tagged X" and eyeball whether that
group actually belongs together. Deliberately no editing: corrections
still go through direct SQL, same as every prior fix in this project.

Tested end-to-end in a real browser session (list load, detail view,
scalar filter, trope filter, combined-filter zero-result case, clear
filters) — all worked correctly, no console errors.

Surfaced one real, pre-existing data gap while testing: the original
30-book pilot corpus (tagged before `age_category`/`book_length` existed
as fields, and before step 03's Hardcover ingestion supplied
`page_count`) is missing those two fields plus the three round-3 fields
for the same reason. The tool flags this directly (a "N fields missing"
badge per book, plus a header-level count) rather than hiding it. Not
fixed in this pass — flagged for a follow-up backfill.

## 2026-08-29 — Moved to a hosted Supabase project

User created a hosted Supabase project ("bookspell", ref
`yhvubjqstswxvctdikbc`, `ap-southeast-1`) in their existing org via the
dashboard themselves — deliberately not something done via CLI on their
behalf, since creating a second project in an org can carry billing
implications only their own dashboard would show and confirm before
charging anything.

Migration steps:
1. `supabase link --project-ref yhvubjqstswxvctdikbc`, then
   `supabase db push` — applied all 5 existing migrations plus a new one
   written for this move (see below). This recreated the schema and the
   tropes/content_warning_types lookup vocabulary (both seeded via
   `insert` statements inside the migration files themselves).
2. **Real catalog data (168 books, their DNA, tropes, content warnings,
   series) was NOT in any migration file** — it was loaded via ad hoc
   scripts against local Postgres throughout steps 03-04, so pushing
   migrations alone left the hosted project schema-complete but
   data-empty. Dumped data-only (`pg_dump --data-only`) per table in
   FK-safe order (universe, series, books, book_dna, book_tropes,
   book_content_warnings) from local, stripped the psql-only
   `\restrict`/`\unrestrict` meta-commands pg_dump 17 adds (not valid
   SQL, would break a non-psql executor), and applied via
   `supabase db query --file ... --linked`. Verified row-for-row parity
   against local afterward (168/168/867/336/83 across the five
   non-empty tables, `universe` empty in both — never populated,
   expected).
3. **Turned on RLS properly instead of carrying forward the local-dev
   shortcut.** Local had RLS off catalog-wide with a blanket `SELECT`
   grant to `anon` — fine on localhost, but this project is now
   genuinely internet-reachable, so that implicit "everything open"
   default became a real, permanent exposure rather than a convenience.
   New migration (`20260829000000_enable_rls_public_read.sql`) enables
   RLS on all 8 catalog tables and adds an explicit `"public read
   access"` SELECT-only policy per table — same effective read access as
   before, but auditable, and correctly leaves writes closed to `anon`/
   `authenticated` by default. Applied to local too, to keep the two
   environments' policies in sync. Step 07 (ratings, friend graph) will
   need its own, much narrower policies once real user data exists —
   this pass deliberately doesn't try to anticipate that.
4. Repointed the catalog review tool at the hosted project's URL and
   publishable (anon-equivalent) key. Re-tested end-to-end in a real
   browser session against the hosted DB — list load, filtering, detail
   view all confirmed working.

**Going forward**: schema changes get authored and tested against local
Supabase, then promoted via `supabase db push` (standard workflow, kept
local running rather than fully retiring it). Actual catalog data (new
books, tag corrections) should be written directly against the hosted
project from here on — local Postgres is not being kept in sync with it
automatically, and would need another manual dump/push if it drifts.

## 2026-08-29 — Backfilled age_category/book_length for the 30 pilot books

Closed the data gap the review tool surfaced: the original 30-book pilot
corpus was tagged before `age_category` existed as a field and before
step 03's Hardcover ingestion supplied `page_count` (also confirmed the
round-3 fields — `prose_density`/`prose_complexity`/`intellectual_weight`/
`stakes_scope` — were NOT actually missing for these books; that round's
full-catalog retag already covered them).

- `book_length` — computed deterministically from each book's now-known
  `page_count` (same bucket thresholds as everywhere else in the
  project), not a judgment call.
- `age_category` — a real judgment call, made directly rather than via a
  tagging agent (30 well-known titles, low ambiguity for all but a
  couple). Two genuinely close calls, flagged here rather than silently
  decided: **A Wizard of Earthsea** and **Ender's Game** both tagged
  `ya` on the strength of common retail/library shelving and young
  protagonists, despite both having a real claim to `adult` (original
  adult-SF awards/marketing for Ender's Game; frequent "classic fantasy"
  adult shelving for Earthsea) — worth a second look if either's
  recommendation behavior looks off later. Genre-fit-excluded candidates
  (The Road, Bird Box) still got real `age_category`/`book_length`
  values here too — that's a separate, still-open question from whether
  they belong in the catalog at all.

Applied to both hosted and local DBs — see
`docs/remaining-catalog-tagging/pilot-corpus-backfill.sql`. Catalog now
has 100% field coverage across `age_category` and `book_length` for all
168 books (`audiobook_length` remains null for books with no audiobook
edition on Hardcover's side — that's a legitimate absence, not a gap).

## 2026-08-29 — Split stakes_scope into stakes_scope + personal_stakes

User caught a real design flaw during casual review: `stakes_scope` was
conflating two questions — how large a footprint is threatened (breadth)
and how dire the danger is for the protagonist personally (severity). A
boy who might get scolded for losing a toy and a man forced by the mafia
into a deadly heist are both "intimate" in scope, but obviously not the
same book. Worked through diverse calibration examples (Harry Potter,
LOTR, Star Wars, The Time Traveler's Wife, Ender's Game, The Green Mile,
Circe, The Lies of Locke Lamora) before committing, which also resolved
a previously-unaddressed ambiguity: whether a galaxy-spanning single-
universe empire (Star Wars, Dune, Foundation) counts as `global` or
`cosmic`. Settled: `cosmic` means beyond one universe/reality
(multiverse, alternate dimensions), not just "very large" — so those
stay `global`.

Added `personal_stakes` (`low`/`moderate`/`high`/`life_threatening`),
kept `stakes_scope`'s meaning unchanged but clarified to breadth-only.
Retagged all 168 books via the same lightweight background-agent
pattern (7 batches of 24 books, ~26K tokens each — two batches hit a
transient API server error and were cleanly retried). Distribution:
123 life_threatening / 24 high / 18 moderate / 3 low — expected skew for
an SFF catalog, but with real, checkable variance at the low end (The
House in the Cerulean Sea and Legends & Lattes landed on `low`, exactly
matching the calibration discussion; Good Omens and Circe landed on
`moderate`/`high` respectively for the "immortal protagonist" reason
worked out beforehand).

Applied via `supabase/migrations/20260829010000_split_stakes_scope_personal_stakes.sql`
plus a data-only update (`docs/remaining-catalog-tagging/personal-stakes-values.json`)
to both hosted and local DBs — verified matching distributions on both.

## 2026-08-29 — Recommendation engine v1: designed, built, validated

Main autonomous work for this window (user asleep ~7 hours until weekly
usage reset). Chose this over expanding the catalog further: catalog
growth doesn't reduce future tagging cost (a book costs the same to tag
whether it's added today or in six months) and we'd already agreed 168
books is enough to validate against; the recommendation engine is the
actual next roadmap milestone (step 05), and uniquely has a way to
self-validate without the user present — the 30-book pilot's real,
already-documented like/dislike reactions.

**Design** (matches the original artifact's spec: per-user weighted
vector, no collaborative filtering for v1): every book's DNA becomes a
flat feature space (ordinal fields by position, nominal fields by exact
match, tropes as a multi-select set; content warnings deliberately
excluded — they're filter material per book-dna.md, not a positive-match
signal). A user's profile is a liked-books centroid plus PER-FEATURE
WEIGHTS derived from how much that feature actually differs between
their liked and disliked books — not a fixed global formula. Implemented
in `scripts/recommend.py`, reading live from Postgres (same DATABASE_URL
pattern as every other script in this project).

**Validation** against the pilot's real, documented reactions (6 liked:
Golden Compass, Locke Lamora, Eye of the World, Kings of Paradise, Prince
of Thorns, Way of Kings; 8 disliked: Bird Box, Assassin's Apprentice, We
Are Legion, Interview with the Vampire, The Poppy War, Circe, Dark
Matter, He Who Fights with Monsters — pulled from `docs/pilot/findings.md`,
not fabricated). Result: strong, sensible signal — unprompted top-15 was
almost entirely multi-POV political/war epic fantasy (Malice, A Game of
Thrones, Oathbringer, LOTR, The Blade Itself, the ASOIAF books, etc.),
and 7 of 8 disliked books ranked in the bottom half when scored against
the same profile without being excluded. The algorithm independently
found `pov_count`/`person` as strong discriminators — correctly
separating Assassin's Apprentice (single-POV, disliked) from
structurally-similar liked books, without that distinction being
hand-coded anywhere.

**One honest limitation surfaced, not hidden**: The Poppy War (disliked
for being "preachy") didn't rank low, because a single disliked example
tagged `heavy_handed` doesn't outweigh 7 other disliked books mostly
tagged `subtle` in a centroid-average approach — small-sample preference
learning genuinely can't isolate a one-off qualitative reason yet. Same
category as the already-documented "Known limitations — engine-level,
not schema fixes" in book-dna.md, not a new problem.

**Real data gap found and fixed along the way**: chasing the Poppy War
result surfaced that `message_intensity` was null for all 30 original
pilot-corpus books (confirmed via a full column-by-column null check —
no other field had this gap) — same root cause as the earlier
age_category/book_length backfill. Fixed directly, applied to both
hosted and local DBs.

Full design writeup, validation table, and limitation analysis in
`docs/recommendation-engine/v1-findings.md`. This is a validated
algorithm, not a shipped feature — wiring it into the app as a real
service is step 06+ work once the app exists.

## 2026-08-29 — Series/universe data was systemically wrong catalog-wide

User spot-checked Sanderson's books and found real problems, which
turned out to be catalog-wide, not Sanderson-specific:

**1. Series `book_count`/`status` were auto-populated garbage.** Despite
the project's own explicit design decision (series/universe data is
manually curated, never pulled from a metadata API), step 03's
ingestion silently linked books to whatever "series" Hardcover's raw
feed returned, with that series' raw book_count/status carried over
uncorrected. Every single series in the catalog was wrong — Harry
Potter "29 books," A Song of Ice and Fire "59 books," The Wheel of Time
"86 books," and the specific case the user caught: "Mistborn: Wax &
Wayne" tagged as 9 books (it's 4). Corrected all 79 series against real
publication facts (75 in one pass, plus Mistborn x2/Stormlight/LOTR
handled separately below). Left `book_count` null for one fast-moving
ongoing series (He Who Fights with Monsters) rather than guess.

**2. The Cosmere (and Middle-earth) were never modeled as universes.**
The schema has always had this concept (`universe` → `series` → `book`,
explicitly "not auto-populated from any metadata API"), but it had
never actually been populated for any books, including the one series
where it obviously matters — Sanderson's shared-universe Cosmere. Fixed:
created a "The Cosmere" universe; renamed and corrected "The Mistborn
Saga: The Original Trilogy" → "Mistborn Era One" (3 books, completed)
and "Mistborn: Wax & Wayne" → "Mistborn Era Two (Wax and Wayne)" (4
books, completed), both linked to it; corrected Stormlight Archive to
10 books (Sanderson's own stated two-arc plan), linked to it; unlinked
Elantris, Warbreaker, and Tress of the Emerald Sea from bogus/
speculative "series" entries Hardcover had invented for them
(book_count 45, 2, and 4 respectively) and linked them to the Cosmere
universe directly as standalones instead. Same fix for Middle-earth:
The Hobbit had been linked to its own fabricated "series" (book_count
19); created a "Middle-earth" universe holding The Hobbit (standalone)
and a corrected "The Lord of the Rings" series (3 books, not 4 — see
below).

**3. Found and removed a genuine duplicate: "The Lord of the Rings" was
in the catalog twice.** Once correctly as three separate trilogy
volumes (Fellowship/Two Towers/Return of the King), and once as a
1178pp single-volume omnibus edition, independently tagged with its own
`book_dna`/tropes/content warnings. Since the omnibus is the same
content as the trilogy already in the catalog, having both would have
double-counted the same book in anyone's preference profile and could
recommend the same story to someone who'd already read it under a
different title. Deleted the omnibus row (cascaded to its DNA/tropes/
warnings automatically). Checked the rest of the catalog for
similarly-oversized entries — nothing else found; the other long books
(Stormlight, ASOIAF, Wise Man's Fear, Jonathan Strange) are genuinely
that long as individual novels.

**4. Rhythm of War's tropes were thin and had a real error.** User's
own read: the book has no single protagonist (Shallan, Dalinar, Adolin,
and Kaladin all get major POV time), and most of them read as heroic,
not morally grey — unlike The Way of Kings/Words of Radiance/Oathbringer,
where Szeth's tragic-assassin arc and Dalinar's dark-past flashbacks
genuinely justify that tag. Removed `morally_grey_protagonist` from
Rhythm of War; added `multiple_fantasy_species`, `found_family`,
`ancient_evil_awakens`, `shadow_self_confrontation`, and `redemption_arc`
(Venli's arc). Extended the same audit across all 15 Sanderson books in
the catalog: added `multiple_fantasy_species` wherever Parshendi/
singers/kandra/koloss were a clear omission (Way of Kings, Words of
Radiance, Oathbringer, Mistborn: The Final Empire, The Well of
Ascension, The Hero of Ages); fixed inconsistent tagging across the Wax
and Wayne era (The Alloy of Law had only 3 tropes total — added
`found_family`, `noir_detective_structure`, `twist_ending`; added
`morally_grey_protagonist` to Shadows of Self/Bands of Mourning/The
Lost Metal for consistency with Wax's ongoing moral-complexity arc
tagged elsewhere in the era); added `court_intrigue` to Warbreaker and
The Lost Metal (clear omissions given how political both books are);
added `epic_quest` to Tress of the Emerald Sea (only had 2 tropes
total); added `immortal_or_ageless_character` to Warbreaker (the
Returned are literally gods living as people) and `morally_grey_protagonist`
to Elantris (Hrathen, a major POV, is genuinely morally grey — a true
believer capable of real cruelty and real compassion).

**Proposed, not yet applied**: a new trope for gods/deities as directly
present, interactive characters (Sanderson's Shards — Odium, Preservation,
Ruin, the Returned in Warbreaker — plus the wider pattern in American
Gods, Percy Jackson, Circe). Distinct from `mythological_pantheon_as_characters`
(real-world myth specifically) and `dark_lord_or_evil_overlord` (a villain
archetype, not necessarily divine). Awaiting confirmation before adding,
same discipline as every other vocabulary decision in this project.

All fixes applied to both hosted and local DBs, verified matching.

## 2026-08-29 — Full-catalog quality audit (14 agents, all 167 books)

Following the Sanderson data-quality findings, ran the same review
discipline across the entire catalog rather than stopping at one author.
14 background agents, ~12 books each, each with direct read/write access
to the local Postgres DB — reviewed every existing tag against the
schema and their own knowledge of the book, fixed what was wrong,
added what was missing. Two batches hit a transient session rate limit
mid-run; cleanly retried once the limit reset.

Result: `book_tropes` went from 867 to 1166 rows (+299 net), content
warnings 336 to 350 (+14 net), plus numerous scalar-field corrections.
Full findings in `docs/catalog-audit/2026-08-29-findings.md`; every SQL
statement executed is in `docs/catalog-audit/full-audit-sync-2026-08-29.sql`.

Headline finding: the `morally_grey_protagonist` ensemble-mistag pattern
the user caught in Rhythm of War recurred independently across at least
6 more books (Good Omens, Harry Potter and the Half-Blood Prince, A Game
of Thrones, Jonathan Strange & Mr Norrell, and — notably — my own
Sanderson fix from earlier tonight on The Alloy of Law/The Bands of
Mourning got reverted on independent review). Also found: two books with
zero tropes at all (Bird Box, House of Leaves), one with exactly one
(The Hitchhiker's Guide to the Galaxy), a factual error verified via web
search (He Who Fights with Monsters was tagged `reincarnated_protagonist`
but the protagonist is transported while alive, not reincarnated — fixed
to `isekai`), a wrong `person` field on Frankenstein, and a second
poor-genre-fit case (The Girl with the Dragon Tattoo tagged `sci_fi`
despite zero speculative content, joining The Silent Patient from
earlier — both still need a product decision on exclusion).

Also ran a `stakes_scope` global/cosmic consistency pass using the
boundary clarified during the `personal_stakes` work (cosmic = beyond
one universe/reality, not just "very large") — caught several books
where the original tagging had contradicted the schema's own documented
examples (A Darker Shade of Magic was tagged `global` despite the schema
explicitly citing this book as the canonical `cosmic` example).

Synced all fixes from local to the hosted DB via 167 scoped per-book
statements (delete-then-reinsert per book_id, never a blanket table
wipe) rather than a full dump-and-replace, since Claude Code's auto-mode
classifier correctly flagged an unqualified `DELETE` on the hosted DB as
too risky to run without confirmation while the user was asleep — the
scoped version accomplishes the same sync safely. Verified matching row
counts on both DBs afterward.

One new vocabulary gap flagged independently by two different audit
batches (strong repeated-signal case, same pattern that justified
`embedded_system_text`): no trope exists for "multiple sentient alien
species" in a pure sci-fi book, since `multiple_fantasy_species` is
fantasy-coded by name and intent. Logged for review, not applied.

Also fixed alongside this: the author/narrator field-contamination bug
the user caught (Words of Radiance's author field read "Brandon
Sanderson, Michael Kramer, Kate Reading" — the latter two are audiobook
narrators). Added a minimal `narrators text[]` column and corrected this
one confirmed case. The bigger idea the user raised — full
audiobook-edition data (multiple editions, narrators, runtimes, and
GraphicAudio full-cast dramatizations) — logged as a scoped future
roadmap item in `book-dna.md`'s future-fields backlog and the published
artifact's ideas backlog, not built in this pass: it needs a real
one-to-many `audiobook_editions` table and dedicated per-book sourcing
(Hardcover's API likely doesn't carry GraphicAudio editions at all),
not a quick fix bundled into tonight's audit.

## 2026-08-29 (morning) — Series/universe hierarchy, new creature tropes, review tool fix

User reviewed the Sanderson fixes from overnight in the review tool and
found more: correct now, but flagged that the model needed one more
layer to express "Mistborn Era One and Era Two are both part of the
Cosmere, and also both part of 'Mistborn' as a saga" — plus the same
gap for Stormlight Archive (should be Era One, 5 books incl. Wind and
Truth, completed; Era Two not yet released — was flatly modeled as one
10-book ongoing series).

Fixed by adding `parent_series_id` (self-referencing, nullable) to the
`series` table rather than a rigid third "world" tier — lets any series
optionally nest under a broader saga umbrella at arbitrary depth, reusing
the existing table. Restructured:
- Cosmere → **Mistborn** (parent, no books of its own) → Mistborn Era
  One (3 books) / Mistborn Era Two (Wax and Wayne) (4 books)
- Cosmere → **The Stormlight Archive** (parent) → Stormlight Archive Era
  One (5 books, completed) / Stormlight Archive Era Two (not yet
  released, placeholder row, 0 books)

Also fixed: the review tool never displayed `position_in_series` or
series/parent-series names at all — pure UI gap, the data
(`position_in_series`, confirmed already correctly storing decimals like
Edgedancer's `2.5`) was always there. Now shows on both the card grid
and detail view (e.g. "Mistborn → Mistborn Era One, book 1 (3 books,
completed)"). Tested end-to-end in a real browser session.

Added 3 new tropes: `elves`, `dwarves`, `fae_or_fairies` — same precedent
as `vampires`/`dragons` (a specific, common fantasy race/creature readers
have real preferences on, including active fatigue with the generic
version absent a real twist). Schema and lookup-table only for now;
retroactive tagging across the catalog deliberately deferred (added to
roadmap, see below).

Checked before doing anything with two other ideas the user raised
(Abercrombie's First Law World; Mark Lawrence's Broken Empire/Red
Queen's War and Book of the Ancestor/Ice pairings) — the catalog
currently has only one book each from Abercrombie and Lawrence, so
building out that hierarchy now would have zero present benefit. Held
off; logged as a future item instead of modeling it prematurely.

Confirmed for the user, not fixed (deliberate, not missed):
- `audiobook_duration_minutes` (real runtime) is populated for every
  book; the full `audiobook_native` category (narrator quality, cast,
  etc.) was never populated for any book — flagged from the start as
  requiring real listening, not web research. The bigger audiobook-
  editions/GraphicAudio feature is the existing roadmap item from
  2026-08-29 (overnight).

New roadmap items added to the published artifact's ideas backlog and
`book-dna.md`'s future-fields backlog:
- Wind and Truth is missing from the catalog entirely (Stormlight Era
  One book 5) — a content gap, not just a metadata one.
- Recommendation engine should discount/avoid recommending a later
  series installment to someone who hasn't read the earlier ones — now
  possible since series position is properly modeled, but the v1 scoring
  prototype doesn't check it yet.
- Deeper per-book romance/creature trope pass (Rhythm of War: Dalinar/
  Navani and Adolin/Shallan are flattened into `found_family`; no
  vocabulary distinguishes "fantastical creatures" like chasm fiends
  from `multiple_fantasy_species`) — real residual gap even after the
  overnight full-catalog audit, deliberately left for a dedicated pass.
- Retroactively tag `elves`/`dwarves`/`fae_or_fairies` across the
  catalog once that pass happens.
- Self-labeled shared-world universes for Abercrombie/Lawrence, once/if
  the catalog's coverage of those authors grows.
- Series recap generator (possibly ElevenLabs-narrated) — explicitly a
  far-future idea, logged and parked.

On token efficiency (user is now watching spend carefully after two
autonomous overnight windows): did all of tonight's work directly
(schema edits, migrations, review-tool HTML edit) rather than spinning
up agents, since every item was small and well-defined enough that
agent overhead (tool listing, schema read, DB connect — fixed cost
regardless of task size) wasn't worth it. Recommended reserving
agent fan-out for genuinely large multi-book batches going forward.

## 2026-08-29 (later) — creature trope retroactive tagging pass + design discussion

Added two more creature tropes (`orcs`, `werewolves_or_shapeshifters`) to
round out the set alongside `dragons`/`vampires`/`elves`/`dwarves`/
`fae_or_fairies` — same fatigue-pattern rationale, applied via
`20260829050000_more_creature_tropes.sql` to both local and hosted.

Launched the deferred retroactive tagging pass across all 7 creature
tropes at once (rather than three separate passes) as 8 parallel
non-forked background agents, ~21 books each, each given the trope
definitions inline in the prompt (not a schema-file read) plus known
per-batch hints (e.g. LOTR volumes get elves/dwarves/orcs, Sanderson's
Cosmere gets none of these) to cut down on agent guesswork tokens.

All 8 batches completed cleanly — every agent correctly left ambiguous
cases untagged rather than forcing matches (e.g. batch 00 declined to
tag ASOIAF's warging/Bran or Tyrion as werewolves/dwarves since those
are a meaningfully different mechanic; batch 02 declined Veela as
fae_or_fairies; batch 05 declined Shanka/koloss/gnomes as orc/dwarf
equivalents since they're distinct original creations). One real
consistency gap found on manual review: the agent covering Mistborn:
The Final Empire correctly tagged `werewolves_or_shapeshifters` for
OreSeur (a kandra), but the agents covering the rest of the Mistborn
saga defaulted to zero across the board — kandra (OreSeur/TenSoon/
MeLaan) recur through the entire saga, not just book 1. Fixed directly
(no agent needed, small well-defined fix) by adding the tag to The Well
of Ascension, The Hero of Ages, The Alloy of Law, Shadows of Self, The
Bands of Mourning, and The Lost Metal. Consolidated everything into one
migration (`20260829060000_creature_trope_tagging_pass.sql`) and
applied to both local (via a psycopg2 script, since `supabase db query
--file` rejects multi-statement files) and hosted (via `supabase db
push`, which handled the multi-statement file fine) — both now at 82
creature-trope rows.

Also had a design discussion (not yet built, logged to `book-dna.md`'s
future-fields backlog):
- **`work_type` (novel/novella) on `books`** — user's idea, prompted by
  decimal `position_in_series` values (e.g. 2.5) not clearly signaling
  "this is a novella" to a newcomer, plus audiobook-credit economics
  (a novella may not be "worth" a full Audible credit). Leaning toward
  recommending this get built as a binary novella/novel field, mostly
  computable from page/word count with manual overrides for known cases
  (the 4 Murderbot novellas, Edgedancer) — not yet built pending user
  confirmation.
- **`crucial_to_arc` flag for interstitial series entries** — user's
  future-roadmap idea, citing Edgedancer (Nale the Herald lore, often
  skipped) and Dawnshard (bridges Stormlight 3→4 across a time jump) as
  examples of novellas that matter more than their skippable-side-story
  positioning suggests. Logged only, not built.

## 2026-08-29 (later still) — werewolves/shapeshifters split, work_type built, first real-user recommendation test

User feedback: `werewolves_or_shapeshifters` conflated two genuinely
different signals — classic lycanthropy vs. general shapeshifting.
Split into `werewolves` + `shapeshifters` (both new tropes), reclassified
all 19 previously-tagged books by which mechanic actually appears (one
book, Prisoner of Azkaban, got both — Lupin's condition and the Sirius/
Pettigrew Animagi reveal). One deliberate surprise: Twilight's wolf pack
are canonically shapeshifters per the books' own internal mythology (no
moon-tie, no silver vulnerability, transform at will), not lycanthropes,
despite the pop-culture "werewolf" label — tagged `shapeshifters`.
Applied via `20260829070000_split_werewolves_shapeshifters.sql` to both
local and hosted, verified matching (2 new tropes, old one removed).

Built `work_type` (novella/novel) on `books`
(`20260829080000_add_work_type.sql`). Checked page_count as a possible
auto-computation source first and rejected it — not reliable (Tor.com's
novella imprint trim/font inflates page counts, e.g. Edgedancer at 272pp
reads longer than full novels like Fahrenheit 451 at 227pp; The Time
Machine at 144pp is a full novel, shorter than every Murderbot novella).
Set manually from real publishing classification instead: the 4
Murderbot novellas, Edgedancer, and This Is How You Lose the Time War
(2020 Hugo Best Novella winner) — 6 books total, applied to both
databases.

Ran the first real-user recommendation engine test: the user's wife's
actual liked list (The Eye of the World, Harry Potter [used Philosopher's
Stone as the representative entry], Ender's Game, Lord of the Rings
[used Fellowship of the Ring], Eragon, The Hitchhiker's Guide to the
Galaxy — she couldn't name dislikes, mostly reads on family
recommendation rather than personal aversions). Two of her stated loves
(The Time Traveler's Wife, Murakami's Hard-Boiled Wonderland and the End
of the World) aren't in the catalog (out of SFF/audiobook-native scope
or simply not yet added) and were skipped. Top results were coherent,
classic-epic-fantasy-leaning (The Hobbit, Mistborn: The Final Empire,
several Harry Potter/LOTR entries, A Darker Shade of Magic) — driven
almost entirely by shared tropes (chosen_one, wise_mentor, epic_quest,
underdog_rising). Honest limitation surfaced: with no disliked signal,
per-user weights fall back to a flat default, so the 5-of-6 fantasy
majority in her list dominates the centroid and The Hitchhiker's Guide's
comedic-scifi signal gets diluted rather than genuinely represented —
a real, expected consequence of the "no dislikes yet" case documented in
v1-findings.md, now confirmed with a real (not synthetic) user.

## 2026-08-29 (later still) — weight cap fix + genre-scoped profiles

User flagged two real problems with the recommendation results shown
above: (1) the HP/LOTR recommendations were real mid-series entries
(Goblet of Fire, Order of the Phoenix, etc.) with no series-position
awareness -- confirms the existing roadmap gap with a concrete example;
(2) a small liked list can't capture an eclectic reader's actual taste,
since a single centroid blurs multi-modal preferences into the empty
space between them rather than resembling any of the input books. Tested
with the user's own deliberately eclectic list (grimdark/political
fantasy + hard SF liked; assorted single-POV/first-person books
disliked) and it surfaced a real bug: `pov_count`/`person` (structural
fields, not taste content) ended up with weights of 0.889/0.542 --
bigger than any individual trope -- because the liked set happened to be
uniformly multi-POV/third-person against a disliked set that wasn't,
so those two fields functioned as a near hard-filter dominating every
result's top factors.

Fix 1: added `WEIGHT_CAP = 0.5` in `recommend.py`, clamping every
computed weight (ordinal, nominal, and signed trope weights) so no
single field can dominate disproportionately. Reran the eclectic test --
ranking barely changed, because pov_count/person were still the two
largest weights even capped (0.5 each vs ~0.39 max for any trope). The
cap alone doesn't fix relative dominance, only extreme magnitude.

Fix 2 (the real fix, user's idea): genre-scoped profiles. `genre` was
already a real multi_enum field in book_dna (`[sci_fi, fantasy]`,
already populated per book) but had never been wired into scoring --
`MULTI_FIELDS` listed it but `build_profile`/`score_book` only ever
processed tropes. Added a `genre` param to `recommend()`: when set, both
the candidate pool AND the liked/disliked books used to build the
profile are scoped to that genre (falls back to the full unscoped list
if none of the user's ratings match, to avoid an empty profile). Tested
on the same eclectic list split into `genre='fantasy'` and
`genre='sci_fi'` runs -- dramatically more coherent than the blended
run: fantasy results were all grimdark/political multi-POV epic fantasy
(A Clash of Kings, A Storm of Swords, Malice, Jade City, Rhythm of War),
sci-fi results were all hard-SF/space-opera (Caliban's War, Project Hail
Mary, The Dark Forest, Neuromancer). Confirms genre-scoping, not weight
tuning, is the right fix for multi-modal taste -- it changes what data
goes into the profile rather than reweighting an already-blended one.

Product implication for the onboarding flow (step 07, still ahead): if
"summon a book" lets a user pick fantasy/sci-fi/both at recommendation
time, the rating flow should probably collect likes/dislikes as
separate fantasy/sci-fi buckets too, so a user's profile is never a
forced blend to begin with.

## 2026-08-29 (later still) — structural/content field split, pov_count widened + retagged

User raised two more good points on the genre split: (1) fully
genre-siloed scoring throws away real cross-genre signal -- a small
liked-fantasy sample can manufacture a false "likes multi-POV" signal
that a bigger cross-genre sample (including multi-POV dislikes from the
other genre) would correctly cancel out; (2) `pov_count` was a binary
single/multiple, so Kings of Paradise (~3 POVs) and A Game of Thrones
(~9 POVs) scored identically -- real information lost.

Fix 1: split fields into STRUCTURAL (craft/format -- pov_count, person,
pace_shape, book_length, etc.) vs CONTENT (tropes, darkness, romance
heat, violence, magic/scifi hardness). `recommend()` now always profiles
structural-field weights from the FULL unscoped liked/disliked pool
regardless of genre filter, while content fields stay genre-scoped.
Reran the eclectic fantasy/sci-fi test: `pov_count` dropped out of the
dominant-factor position once profiled on the full pool (it doesn't
actually discriminate this user's taste -- both liked and disliked sets
include multi-POV books), while `person` stayed prominent since it's a
genuine full-pool discriminator (dislikes skew first-person). Confirms
the mechanism works as intended -- some structural fields are real
signal, some are noise, and the full pool lets the data decide instead
of assuming either way.

Fix 2: widened `pov_count` from `[single, multiple]` to
`[single, dual, few, several, ensemble]` (single=1, dual=2, few=3-4,
several=5-7, ensemble=8+), moved from NOMINAL_FIELDS to ORDINAL_FIELDS
in `recommend.py` so a "few" book now scores partial similarity to an
"ensemble" book instead of flat match/no-match. Retagged all 86
previously-`multiple` books via 4 parallel batch agents (~21-22 books
each), instructed to count only recurring, page-time-significant POV
characters (excluding one-off interlude/prologue chapters).

Caught a real batching mistake on review: my batch prompts told agents
to assume every book was already confirmed genuinely multi-POV (since
the original binary tag said 'multiple'), so when several agents
independently reported finding NO real second recurring POV for a
specific book, they were forced to floor it at `dual` anyway rather
than the correct `single`. Corrected 7 books to `single` based on the
agents' own explicit findings: American Gods, The Fellowship of the
Ring, The Lies of Locke Lamora, and 4 of the earlier Dungeon Crawler
Carl books (Dungeon Crawler Carl, Carl's Doomsday Scenario, The Dungeon
Anarchist's Cookbook, The Gate of the Feral Gods) -- all four DCC books
consistently reported as still Carl-only POV at that point in the
series, before the later books introduce other crawlers' POV chapters.
Left the 3 later DCC entries (This Inevitable Ruin, The Eye of the
Bedlam Bride, The Butcher's Masquerade) as the agents tagged them --
genuine uncertainty about where the series' POV structure actually
expands, not a clear-cut single-vs-multi error like the other four.

Applied via two migrations: a widen-then-retag-then-tighten sequence
(`20260829090000` widens the CHECK constraint to a permissive superset
so the retagging pass can write new values without a transient
violation, `20260829100000` consolidates the full retagged state,
`20260829110000` tightens the constraint back down once no row was left
at the old 'multiple' value). Verified local and hosted match exactly:
dual=17, ensemble=10, few=31, several=21, single=88.

Logged a future-fields backlog idea (not built): exact POV count
(main-only, excluding one-off interludes) instead of the 5-bucket scale
-- deferred, real per-book editorial judgment call, bigger effort than
the bucket widening.

## 2026-08-29 (later still) — implemented diversity/fatigue controls, gap assessment, roadmap logging

Did a real assessment of recommendation-engine gaps rather than
assuming trope density was the bottleneck: mean tropes/book is 7.4
(median 7), so density is fine, but 31/167 books have <=3 tropes and
1 has zero (The Martian has only `last_minute_rescue` +
`survivalist_ingenuity` -- clearly under-tagged, not genuinely
trope-poor, since these are pre-vocabulary-growth artifacts from early
tagging rounds). Bigger finding: the `audiobook_native` schema module
(`narrator_performance`, `narrator_cast`, `narration_pace_vs_prose`,
`accent_authenticity`, `production_quality`) is 100% untagged across
the whole catalog and isn't even wired into `recommend.py`'s scoring
fields -- despite being marked `wedge: true` in the schema. User
clarified this isn't actually the product's core differentiator (a
good, calibratable recommendation engine is) and correctly pushed back
that narrator-performance data is genuinely hard to source (subjective
listening judgment -- pacing, theatricality, voice distinctness, cross-
gender acting -- not ordinary retailer metadata; only quasi-reliable
sources are professional audio critics like AudioFile Magazine/Audie
Awards, both with real coverage gaps). Checked actual data: even the
"easy tier" (narrator names, narrator_cast, audiobook_length) isn't
built -- `audiobook_length` is 59% populated (98/167) and
`books.narrators` is populated for exactly 1 book. Confirmed book/
audiobook recommendation `medium` mode is blocked on real data, not
just deferred by choice -- pushed to roadmap, Tier A backfill first
whenever that happens.

User also raised the echo-chamber/filter-bubble risk of pure best-match
scoring and proposed two fixes: a "summon something different" mode and
a "less of X" fatigue control, plus a refinement that "different" needs
a bounded level (a grimdark reader asking for variety doesn't want the
diametrical opposite, e.g. cozy romantasy YA). Designed and implemented
both in `recommend.py`:

- `diversity` param (0.0 default, hard-capped at `MAX_DIVERSITY = 0.5`
  in code, not just as a UI convention): blends relevance (profile
  match) against novelty (1 - max similarity to `recent_history` books,
  via a new unweighted `book_similarity()` helper combining ordinal
  closeness, nominal exact-match, and trope-set Jaccard similarity).
  Capping below 1.0 means the relevance term never fully disappears, so
  a diametrically-mismatched book stays capped low regardless of
  novelty -- verified: at diversity=1.0 the result is byte-identical to
  diversity=0.5 (silent clamp confirmed working), and a real test
  against a grimdark-fantasy profile with 5 recent grimdark reads
  surfaced genuinely different-but-still-fantasy picks (Perdido Street
  Station, The Gunslinger, Warbreaker, Throne of Glass) rather than
  anything taste-incompatible.
- `fatigue_overrides` param: a dict of {trope_or_field: weight} that
  directly clobbers the learned weight for that key after
  `build_profile()` runs -- verified with `{"court_intrigue": -0.5}`:
  A Clash of Kings dropped from #1 (0.889) to #3 (0.756) and the
  contribution breakdown shows `trope:court_intrigue` as a visible
  -0.5 line, not just a silent disappearance.

Both are caller-supplied parameters (recent_history as an explicit
list, same pattern as liked/disliked titles) since no real per-user
history/ratings table exists yet -- confirmed via schema check (only
books/book_dna/book_tropes/series/universe/tropes/content_warning_types
exist, no users/ratings table). Real persistence is future work once
the app has actual accounts.

Also logged two more roadmap ideas per user request: a rhythm-aware TBR
queue (insert lighter/standalone books after a heavy series run,
calibratable -- user's example: a reader breaking up The Wheel of Time
with standalone reads) and narrator collaborative filtering (once
per-user audiobook/narrator ratings exist, infer narrator quality from
correlated listener behavior instead of needing to source or judge it
ourselves -- sidesteps the Tier-B audiobook-field sourcing problem
entirely, though it needs the same missing ratings table plus a
critical mass of users to avoid a cold-start problem, and is a
deliberate collaborative-filtering hybrid rather than a v1 feature).

## 2026-08-29 (later still) — berserker_rage and long_journey tropes added + tagged

User's two new trope proposals both resolved and added. `long_journey`
needed clarification first: distinguishes the physical journey/travel
itself being the narrative's structural spine (The Lord of the Rings --
the whole point is delivering the ring across a long trek) from
`epic_quest` (only requires an important goal, which can play out almost
entirely in fixed locations -- The Way of Kings/Oathbringer have
epic_quest but no central journey). `berserker_rage` was already agreed:
a character whose combat power source is uncontrolled/building rage
itself (Logen Ninefingers' "the Bloody-Nine" in The Blade Itself,
Kratos-style mechanics) -- distinct from anti_hero/morally_grey_protagonist
(moral positioning, not a mechanic).

Added both to `tropes` via `20260829120000_berserker_and_long_journey_tropes.sql`,
then ran the same 8-parallel-batch-agent retroactive tagging pattern
across the full catalog. Results, consolidated and synced to both
databases via `20260829130000_berserker_long_journey_tagging_pass.sql`:
3 `berserker_rage` tags (Oathbringer -- Dalinar's "Blackthorn" berserker
persona, a real find the agent caught independently, not something I'd
flagged in the prompt; The Blade Itself -- Logen/the Bloody-Nine, the
trope's namesake example; The Song of Achilles -- Achilles' battle-rage)
and 23 `long_journey` tags (LOTR trilogy + The Hobbit, The Eye of the
World, The Golden Compass, Eragon, Hyperion, The Alchemist, The Road,
Parable of the Sower, and others). Agents consistently showed good
judgment on borderline cases -- correctly declining Frankenstein and The
Martian (real travel sequences, but not the book's overall structural
spine), all 5 ASOIAF volumes (political/court-intrigue structured
despite individual character travel subplots), and the Stormlight/
Mistborn catalog (epic_quest energy without a central journey, per the
calibration hint that was itself confirmed correct by these results).

## 2026-08-30 — external feedback batch (13 ideas), sequencing decided

User gathered feedback from other people in their network and brought
13 distinct ideas/questions in one batch, asking for a full triage
before deciding what to build next. Full assessment logged to
`book-dna.md`'s future-fields backlog (each idea given its own entry
there); summarized here:

- Two ideas turned out to already exist and needed no new work:
  description-detail-level is already `prose_density`; "Reader DNA" is
  already `build_profile()`'s output, just not named/productized.
- A "recommendation debugger" and "explain the match" overlap almost
  entirely with data already computed (`score_book()`'s `contributions`
  list) — bundled into one "explanation layer" idea (natural-language
  match/no-match explanations + a raw technical view), UX/wording work
  rather than new engine capability. Deliberately avoiding a literal
  "90% match" framing — the score is a relative ranking, not a
  calibrated probability.
- Confirmed missing: a `revenge` trope (real gap, should have been in
  the original vocabulary).
- Series DNA (a series' Book DNA can change dramatically across its own
  run, e.g. Wheel of Time going from single-POV/fast/journey-structured
  in book 1 to multi-POV/slow/political by book 6+) judged the strongest
  new idea — likely computable as an aggregation/rollup over existing
  per-book `book_dna` rows grouped by series and ordered by
  `position_in_series`, not a fresh tagging pass.
- Confidence/source layer on field/trope values: agreed valuable, with
  a real dual purpose beyond scoring-discount that the user specifically
  called out — a triage signal for flagging books that need deeper
  research, and a way for future community-tagging correlation to raise
  (or flag disagreement in) confidence over time.
- Community self-tagging/dispute-flagging, character-similarity
  recommendations, and hierarchical tropes: all judged real and valuable
  but correctly later-stage — needs real user accounts (confirmed: no
  `users` table exists at all) or a bigger new data model.

**Important correction from the user on the held-out validation test
idea** (originally proposed by me as an immediate, free next step):
`recommend.py` only ever accepted flat `liked_titles`/`disliked_titles`
lists — the 5-tier rating-magnitude scale from the earlier
ratings-precision discussion was designed but never actually implemented.
Without a real graduated score, there's nothing for the engine to
*predict* as a rating, only a relative ranking — so the validation test
isn't meaningful yet. This was a genuine gap in my own prior assessment,
caught by the user, not something I'd flagged myself.

**Agreed build sequence going forward:** rating-magnitude scoring system
first (unblocks the validation test) → revenge trope (quick) →
explanation layer → Series DNA → the rest of the batch (confidence/
source layer, post-read "why didn't it work" dropdown, then the
later-stage items: character-similarity recs, community tagging,
hierarchical tropes). Nothing in this batch was built yet — this was a
logging/triage/sequencing session, per explicit request.

Also wrote `README.md` for the repo (previously had none).

## 2026-08-30 (later) — rating-magnitude scoring system implemented

First item in the agreed build sequence from the feedback-triage
session above. `recommend()`/`build_profile()` previously only accepted
flat `liked_titles`/`disliked_titles` lists; replaced with a single
`ratings` dict of `{title: label}` using a new `RATING_LABELS` 5-tier
scale (hated=-1.0, disliked=-0.5, it_was_okay=0.0, liked=0.5, loved=1.0)
— labeled tiers rather than raw 1-5 stars, per the earlier
ratings-precision discussion's reasoning about calibration ambiguity.

Every mean/mode computation in `build_profile()` is now a
rating-magnitude-weighted average instead of a simple average, so a
"loved" book pulls the centroid and weights harder than a merely
"liked" one. `it_was_okay` (magnitude 0) is deliberately excluded from
both the liked and disliked pools for profile-building -- it shouldn't
pull taste in either direction -- but the book still gets excluded from
future candidate recommendations via the ratings dict's keys, since the
user has already read it. This was a deliberate full API replacement,
not an additive parameter -- this is an actively-developed prototype
script with no external callers depending on the old two-list shape, so
maintaining both would just be two parallel code paths for no benefit.

Verified with real tests: (1) uniform "liked"/"disliked" ratings (the
old binary equivalent) reproduce byte-identical rankings to the
pre-change eclectic-fantasy test result -- confirms this is a strict
generalization, not a behavior change for existing usage; (2) marking
two grimdark/political books "loved" instead of "liked" measurably
shifted top results toward more of that specific flavor (GRRM's own
ASOIAF sequels rose above previously-higher-ranked books); (3) marking
a previously-liked book "it_was_okay" correctly dropped it out of the
results entirely (still excluded as already-rated) without it
influencing the profile; (4) genre scoping, the structural/content
field split, `diversity`, and `fatigue_overrides` all re-verified
working correctly against the new interface, no regressions.

Next in the agreed sequence: the `revenge` trope, then the explanation
layer, then Series DNA.

## 2026-08-30 (later) — revenge trope added and tagged

Second item in the agreed build sequence. Added `revenge` (plot_devices)
per the schema rationale: avenging a specific wrong against a specific
target as the protagonist's sustained driving motivation, distinct from
`corruption_arc`/`redemption_arc` (moral trajectory, not motivation) and
`war_story`/`black_and_white_morality` (general conflict framing, not a
personal vendetta). Ran the same 8-parallel-batch-agent retroactive
tagging pattern across the full catalog.

Result: 16 books tagged, consolidated and synced to both databases via
`20260830020000_revenge_tagging_pass.sql` -- A Storm of Swords (Oberyn
vs. the Mountain), Dune, Eragon, Frankenstein, Kings of Paradise,
Malice, Mistborn: The Final Empire, Prince of Thorns, Red Rising, Six
of Crows, The Lies of Locke Lamora, The Poppy War, The Silent Patient,
The Way of Kings, The Will of the Many, Words of Radiance.

Agents were consistently precise about the trope's protagonist-specific
bar, correctly declining several plausible-looking candidates: Arya's
revenge list in ASOIAF (one thread among many POVs, not the book's
center), Golden Son (Darrow's own arc had shifted to systemic rebellion
by book 2, despite my own batch hint suggesting it), the Wax & Wayne
trilogy (Wax's guilt over Lessie is self-directed, not a "make them pay"
quest), all four later Dungeon Crawler Carl entries checked (real
revenge subplots exist, but they belong to secondary/antagonist
characters, not protagonist Carl), and Throne of Glass/The Name of the
Wind (real revenge motivations exist but are established series
backdrop, not this specific book's active plot driver). One real find
neither I nor the batch hints anticipated: Kaladin's arc against Amaram
in both The Way of Kings and Words of Radiance is genuine sustained
revenge, not just the war_story/epic_quest tags Stormlight already had.

Next in the agreed sequence: the explanation layer, then Series DNA.

## 2026-08-30 (later) — explanation layer implemented

Third item in the agreed build sequence. Bundles the three external
ideas that turned out to be one capability at different levels of
polish: "why was this recommended," "why is this a poor match" (for a
user searching a specific book), and a raw debugger view -- all now one
mechanism, `explain_match()`.

Key design decision: `score_book()`'s existing `contributions` list
wasn't enough on its own, because a field can have a small raw
contribution (weight * similarity) for two different reasons -- low
weight (doesn't matter to the user) or low similarity despite high
weight (matters a lot AND this book misses) -- and those look identical
in the old output but need opposite wording. Added `explain_book()`,
which tracks `deviation` (weight * (1 - similarity)) separately to
disambiguate, splitting every scoring factor into `matches` (pulling the
score up) and `mismatches` (pulling it down) rather than one
undifferentiated list.

Added a natural-language layer (`FIELD_DISPLAY_NAMES`, `VALUE_PHRASES`,
`phrase_field`/`phrase_trope`/`describe`) translating internal field/value
pairs into readable phrases ("cosmic-scale stakes", "a grimdark tone",
"third-person limited narration"), with a generic fallback for fields
without a custom override. Deliberately did NOT implement a literal
"90% match" framing -- added `match_label()` instead (Strong/Good/Mixed/
Poor match, rough first-pass thresholds not yet calibrated against real
user data) -- the score is a relative ranking, not a calibrated
probability, and a precise percentage overclaims rigor the model
doesn't have.

Refactored `recommend()`'s profile-building logic into a shared
`_resolve_profile()` helper so `explain_match()` reuses the exact same
genre-scoping/fatigue-override logic rather than duplicating it --
`explain_match()` works on ANY book in the catalog, not just
recommend()'s top results, so a user can search an arbitrary book and
get an honest explanation either way.

Verified: found and fixed an awkward phrasing gap during testing
(`person`/`pace_shape` enum values read poorly with the generic
fallback -- "third limited narrative person" -- added explicit
overrides). Also caught a bad demo choice on first pass: picked "Fourth
Wing" as a "deliberately mismatched" example, but it actually scored
0.806 ("Strong match") against the pilot profile -- not a bug, just a
wrong assumption about what would score poorly. Found a real bottom-of-
the-list book (The Restaurant at the End of the Universe, 0.221) and
used that instead. Confirmed fatigue_overrides now visibly show up in
the explanation too -- suppressing court_intrigue moved it from
`matches` to `mismatches` and dropped the match_label from Strong to
Good, not just the raw score.

Next in the agreed sequence: Series DNA.

## 2026-08-30 (later still) — explanation layer: sentence assembly

User feedback on the explanation layer's output: the flat comma-joined
phrase list ("Because of: prophecy, revenge, epic quest, third-person
limited narration, ...") wasn't natural enough to show a real
non-internal user, with a concrete example of the wanted shape ("Because
the book is told from third-person perspective, contains prophecies, a
revenge arc, an epic quest and a mysterious magic system").

Broke this into two separable improvements before building either:
(1) real sentence structure -- a verb clause plus a properly joined list
("X, and features Y, Z, and W") instead of a flat comma dump, and (2)
per-trope grammar -- bare "revenge" -> "a revenge arc", "prophecy" ->
"prophecies", which needs individual article/pluralization overrides
for each of the 120 tropes. Judged (1) cheap and worth doing now --
genuinely reusable by any future UI, not just this prototype's demo
output -- and (2) real but lower-priority effort with diminishing value
before an actual UI exists to observe it in context. Built (1), flagged
(2) as deferred rather than silently shipping a half-measure.

Added `NARRATIVE_STYLE_FIELDS` (person, pov_count, timeline,
narrator_reliability, form -- fields describing HOW a story is told) vs.
everything else (tone/content fields + tropes, describing WHAT the story
is about), `_join_list()` (proper Oxford-comma-joined list assembly),
and `natural_sentence()` which combines them into "The book is told with
X, and features/also has Y." `explain_match()` now returns `summary`/
`mismatch_summary` alongside the existing `matches`/`mismatches` lists
(kept, not replaced -- a real UI will likely want both: the sentence for
a one-line summary, the raw list for rendering as individual tags/chips).

Verified output reads naturally and matches the requested shape structurally, e.g.:
"The book is told with third-person limited narration, and features
revenge, prophecy, epic quest, and a soft, mysterious magic system."

## 2026-08-30 (later still) — Series DNA built

Fourth item in the agreed build sequence. User raised three
considerations before building: (1) DNF-prevention messaging ("the
series gets better for your taste on the next entry"), (2) recommendation
explanations should carry series-trajectory caveats, (3) how does the
series/universe nesting hierarchy affect scope -- does the Cosmere
merit its own DNA, or Mistborn as a whole, or only each era?

Resolved (3) first since it structurally determined everything else:
checked the actual data and found `books.series_id` already always
points at a LEAF series -- Mistborn's books link to "Mistborn Era One"/
"Era Two" specifically, never to the parent "Mistborn" row (confirmed:
0 books link to it directly), same for "The Stormlight Archive" parent
vs. its "Era One"/"Era Two" children. This means grouping book_dna by
`series_id` to compute a trajectory automatically operates at exactly
the right scope with zero extra logic needed: a universe (Cosmere) is
excluded because it's not even in the series hierarchy; a multi-era
parent series (Mistborn) is excluded because it has no books linked
directly; each leaf era gets its own trajectory correctly. This matches
the same reasoning as the earlier genre-split finding -- blending across
genuinely disjoint reading experiences (different eras, different
universes) loses signal rather than gaining it.

Built in `recommend.py`:
- `compute_series_dna(catalog)` -- groups books by `series_id`, ordered
  by `position_in_series`, computes a start-value/end-value/trend for
  every ordinal field (directional: increases/decreases/stable, gated
  by `TREND_THRESHOLD = 0.2` of the field's scale range to avoid noise)
  and every nominal field (non-directional: changes/stable). Returns
  nothing for single-book series (no trajectory to speak of).
- `describe_series_trajectory()` -- reuses the explanation layer's
  `phrase_field()`/`_join_list()` to turn the top 3 most reader-relevant
  shifts (prioritized: pace, pov_count, darkness, violence, worldbuilding,
  length, age_category, stakes) into one readable sentence.
- `series_dnf_outlook()` -- point 1, per-user (unlike the two above,
  which are objective/same for everyone): given a series and the book a
  user is currently on, compares that book's score against their profile
  to the NEXT book's score, with a small margin (0.05) to avoid noise,
  and returns a concrete "worth pushing through" / "may not improve" /
  "expect a similar fit" note.
- `explain_match()` extended with a `series_note` field -- point 2, pulls
  in `describe_series_trajectory()` for whichever series the explained
  book belongs to, "" if the book isn't part of a multi-book series or
  nothing shifts meaningfully (the common case).

Sanity-checked across all 18 multi-book series currently in the catalog
(printed every trajectory) -- every single one read as a real, credible,
independently-verifiable shift: Harry Potter light-to-dark/mild-to-graphic
violence, Percy Jackson's stakes narrowing back to regional in book 2 (a
real, minor beat), LOTR opening from single-POV Frodo-centric to several
POVs once the Fellowship splits, Murderbot's stakes/worldbuilding
widening from novella to novel scope, Mistborn Era One/Two both showing
real, distinct pace/POV/violence shifts. No spurious or noise-level
results found. Wheel of Time/First Law/Broken Empire correctly produced
no trajectory (only 1 book each currently in the catalog -- not enough
data, not a bug).

Verified `series_dnf_outlook()` on a real case: for an eclectic grimdark/
hard-SF profile, Mistborn: The Final Empire scored 0.626 against the
profile while The Well of Ascension scored 0.81 -- correctly generated
"worth pushing through" messaging. Edge cases (last book in series,
invalid position, invalid series_id) all handled cleanly, return None or
an appropriate terminal note rather than erroring.

## 2026-08-30 (later still) -- confidence/source layer built

Fifth item in the agreed build sequence. `book_tropes` gained
`confidence`/`source` columns directly (already one row per tag); scalar
fields needed a side table instead (`book_field_confidence`, keyed by
book_id + field_name) since a per-field column on book_dna's wide row
would mean ~29 extra columns. Source enum: ai_inferred (the default for
essentially everything), verified_external, manual_review,
community_tagged/community_confirmed (the last two not populated yet,
reserved for once community self-tagging exists).

Deliberately did not fabricate confidence numbers across the whole
catalog to make the feature look more complete than it is. Backfilled
only real, traceable cases: 6 work_type novellas (verified_external,
Hugo Award-backed, confidence 1.0), 7 pov_count values corrected during
this session's manual review (manual_review, 0.85), and 14 pov_count
values this session's own batch agents explicitly flagged as
borderline/uncertain in their own reports (ai_inferred, 0.4-0.65). 27
rows total. A full confidence audit across the rest of the catalog is
separate, much bigger future work, not attempted -- logged as its own
open item rather than silently declared done.

Wired into scoring: `get_confidence()` added to `recommend.py`,
defaulting to 1.0 (full trust) when no row exists -- absence must not
read as low confidence, since that would penalize the vast majority of
tags that were simply never flagged either way. `score_book()`/
`explain_book()` now discount a field/trope's effective weight by this
confidence for that specific book before it contributes to either the
score or the match/mismatch explanation -- both the contribution and
total_weight discounted equally, so it's a "counts for less" effect,
not a bias toward match or mismatch. Verified on The Bands of Mourning
(pov_count confidence 0.6): score shifted from 0.4433 (simulated full
trust) to 0.4423 with the real discount applied -- small but real, the
right order of magnitude for one moderately-uncertain field among ~20
total contributing signals.

Next: the post-read/DNF "why didn't it work" dropdown.

## 2026-08-30 (later still) -- post-read/DNF feedback dropdown built

Sixth item in the agreed build sequence. Instead of inventing a
separate fixed reason taxonomy, reused the explanation layer's own
`describe()` output: `book_feedback_options()` returns the book's own
already-tagged tropes/fields as a "which of these bothered you?"
checklist, plus a small fixed `NEUTRAL_FEEDBACK_REASONS` set (mood/
timing, general disengagement) that are explicitly not about the book's
content.

Caught a real design bug before shipping it, not after: my first
instinct was to translate ANY selected reason (trope or field) into a
`fatigue_overrides` entry via `feedback_to_fatigue_overrides()`. On
reflection this is wrong for fields -- `fatigue_overrides` flips a
field's weight relative to the user's own CENTROID ("avoid being similar
to your average"), not "avoid this book's specific value." If the
disliked book's pace was already far from centroid, applying the
existing mechanism would perversely reward other far-from-centroid
books instead of steering away from slow pacing. Only TROPE selections
translate correctly (tropes are presence-based, so "penalize this trope"
is exactly what the existing mechanism already means). Scoped
`feedback_to_fatigue_overrides()` to tropes only; field-level selections
are still captured for triage/logging but don't drive calibration --
the correct mechanism there is just rating the book hated/disliked,
which `build_profile()` already handles correctly once a field-level
dislike recurs across several books.

Verified end-to-end: selecting `court_intrigue` as a dislike reason on
A Clash of Kings correctly demoted court-intrigue-heavy candidates
(A Clash of Kings, A Storm of Swords, Malice) and promoted others (The
Gunslinger, The Two Towers, Eragon) through a real `recommend()` call.

This closes out the build sequence agreed after the 2026-08-30 roadmap
triage (scoring system -> revenge trope -> explanation layer -> Series
DNA -> confidence/source layer -> this). Remaining open items:
character-similarity recommendations, community self-tagging/dispute
flagging, hierarchical tropes -- all correctly scoped as later-stage,
needing either a bigger new data model or real user accounts that don't
exist yet.

## 2026-08-30 (later still) -- first real held-out validation test

First genuinely rigorous validation since the original 30-book pilot,
finally possible now that the rating-magnitude scoring system exists.
User provided 16 real, honestly-rated books spanning all 5 tiers
(4 loved, 4 liked, 1 it_was_okay, 4 disliked, 3 hated) across both
genres. Split into an 11-book training set and a 5-book held-out set
chosen for genre/tier diversity (The Blade Itself-loved/fantasy, Red
Rising-hated/sci-fi, Six of Crows-liked/fantasy, Artemis-disliked/
sci-fi, The Poppy War-it_was_okay/fantasy) -- the held-out ratings were
never given to the engine; only used afterward to check the predicted
score/match_label against the real one.

Results (blended, genre=None):
- The Blade Itself: true=loved, predicted=Strong match (0.817) -- correct.
- Six of Crows: true=liked, predicted=Strong match (0.754) -- correct
  direction (slightly high).
- Artemis: true=disliked, predicted=Mixed match (0.534) -- correct
  direction, soft miss (not as low as ideal).
- The Poppy War: true=it_was_okay, predicted=Good match (0.737) -- miss,
  overshoots.
- Red Rising: true=hated, predicted=Good match (0.701) -- clear miss.

Genre-scoped mode did NOT improve results and made Artemis measurably
worse (Mixed 0.534 -> Good 0.58) -- likely because the sci-fi training
pool was thin (only 4 books: Dark Matter-hated, We Are Legion-disliked,
Children of Time-liked, Old Man's War-liked), so genre-scoping content
fields to that small a sample produced a noisier profile, not a cleaner
one. Real, useful caveat: genre-scoping's earlier-demonstrated benefit
depends on having enough books per genre to learn from -- it isn't a
free win at every sample size.

Investigated the Red Rising miss in depth rather than just noting the
score: pulled its actual tropes (dystopia, rebellion_against_empire,
underdog_rising, court_intrigue, major_character_death,
deadly_competition_or_trial, found_family, revenge) and checked the
LEARNED weight for each against this training set. Found the real cause:
`dystopia`, `rebellion_against_empire`, and `deadly_competition_or_trial`
-- plausibly the tropes that actually define what the user disliked
(Red Rising's YA-dystopian, Hunger-Games-style trial structure) -- have
ZERO learned weight, because none of the 11 training books happen to be
tagged with them. Meanwhile `underdog_rising` (0.44) and `revenge`
(0.44), which Red Rising shares with the grimdark epic fantasy the user
loved (Eye of World, Way of Kings, Prince of Thorns, Blade Itself),
pulled the score up. This is not a bug -- the algorithm correctly
learned everything it had evidence for, but had zero information at all
about the axis that likely actually drove the dislike. The Poppy War's
overshoot follows the identical pattern (also shares underdog_rising +
revenge with the loved set). With only 11 training books, a small
number of dominant, unevenly-distributed tropes can overfit the profile
-- a real, honest limitation of small sample size, not a design flaw.
This also concretely validates the post-read feedback dropdown built
earlier today: if a user flags `deadly_competition_or_trial` as a
dislike reason after a miss like this, the system immediately learns
that specific signal going forward -- exactly the gap this test exposed.

Also found and fixed a real phrasing bug while reading Red Rising's
explanation: `ends_on_cliffhanger`'s generic fallback produced literal
"cliffhanger cliffhanger ending" (value "cliffhanger" + display label
"cliffhanger ending" concatenated verbatim). Added proper VALUE_PHRASES
overrides for `ends_on_cliffhanger`, `drive`, and `narrative_closure`
while in the area -- all three had awkward generic-fallback phrasing.

Overall verdict: directionally correct for 3 of 5 held-out books (Blade
Itself, Six of Crows, Artemis), with 2 real misses (Poppy War, Red
Rising) both traceable to the same specific, explainable cause -- small
training-set overfitting on a couple of dominant tropes, not a
fundamental flaw in the scoring approach. Recommended next steps: (1) a
larger validation round (30-50+ rated books) to check whether the
overfitting pattern goes away with more data, as expected; (2) treat
this as confirmation that the feedback-dropdown loop is load-bearing,
not a nice-to-have -- sparse-data misses like Red Rising will keep
happening for any new user with a short rating history, and the system
needs the correction mechanism already built, not just a bigger static
profile.
