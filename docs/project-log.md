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
