# Book DNA — decisions, history & deferred proposals

Companion to `book-dna.md` (the core schema reference), split out
2026-09-25 as part of the fresh-session context-load reduction effort
(`docs/codx-reports/2026-09-25-book-dna-split-review.md`,
`docs/project-log.md`'s 2026-09-25 "CODX Task 22 landed" entry). Read
this when proposing a new field/trope/content-warning (check for a
prior rejection first), revisiting a past design decision, or tracing
why a current field looks the way it does — NOT part of the mandatory
every-session read. For the two other split-out pieces, see
`book-dna-vocabulary-gaps.md` (the active tagging-gap tracker) and
`book-dna-tables.md` (current contracts for tables built out of this
backlog — `audiobook_editions`, `work_type`, Series DNA, confidence/
source, post-read/DNF feedback). All original text below is preserved
verbatim from the pre-split `book-dna.md`; only relative "above"/
"below" navigation has been repaired to point at real destinations.

This file has three parts: **Deferred / open proposals** (genuinely
still-speculative ideas, not built), **Rejected / superseded
decisions** (considered and explicitly turned down, or reopened and
still pending), and **Dated implementation/review history** (a
chronological record of how the schema got to its current shape).

## Deferred / open proposals

Ideas raised, considered against this schema's standing bar ("does
this predict a different recommendation, not just is it a real
term" — see `book-dna.md`'s "Vocabulary growth process" section), and
NOT built. Revisit only if new evidence clears that bar; don't
re-derive a finding already recorded here without checking first.

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
- **Multiple cover-art variants per book, browsable from the book-info
  modal.** Repo owner's idea, 2026-09-18, prompted by fixing a batch of
  broken `cover_url` values — right now `books.cover_url` is a single
  value per book, but a real book often has genuinely different cover
  art across releases (his example: The Stormlight Archive's American
  vs. British editions look nothing alike). Proposed shape: a real
  `book_covers` (or similar) join table — `book_id`, `image_url`,
  maybe `edition_label`/`region` — with the book-info modal (which as
  of 2026-09-18 already shows one large cover, see the "click a
  thumbnail to see the full cover" fix in `app/shared.js`) gaining a
  simple prev/next control to page through variants when more than one
  exists. **Explicitly not urgent** (repo owner's own words) — noted
  for the roadmap, not scheduled. Also explicitly flagged as a real
  storage-cost tradeoff by the repo owner himself: more variants means
  more images to store, which matters more once/if the separate
  self-hosting-images idea (see `docs/TODO.md`'s P1, added the same
  day) actually happens, since hotlinking has no storage cost but
  self-hosting does. Not scoped further than this — needs a real
  decision on how many variants are worth sourcing per book (all
  known editions vs. just a curated couple) before any schema work
  starts.
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
  single/multiple → 5-bucket widening (see `book-dna.md`'s `pov_count`
  entry). Even `few`/`several`/`ensemble` buckets are still a
  compression of the real number, and a "main POV" count needs its own
  judgment call — excluding one-off/interlude chapters from a POV that
  otherwise never recurs (e.g. a single prologue chapter from a minor
  character), not just a raw count of every chapter's narrator.
  Deferred — real per-book editorial judgment call, larger effort than
  the bucket scale, revisit if the bucket scale proves too coarse in
  practice.
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
  average, not a re-estimate of it).

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

  **CORRECTION (2026-09-25, verified against live code while splitting
  this doc): the "summon something different" half of this idea IS now
  built** — `scripts/scoring/pipeline.py`'s `score_candidate()` (ranking
  policy) and `recommend()` both take a `diversity` parameter, blending
  `final = (1 - diversity) * relevance + diversity * novelty` exactly as
  proposed here, capped at `MAX_DIVERSITY` (see `scripts/scoring/
  constants.py`). The "less of X" fatigue-override half is ALSO built
  (`fatigue_overrides`, see the post-read/DNF feedback entry in
  `book-dna-tables.md`). This paragraph was never updated when either
  landed — flagging it here rather than silently rewriting the entry
  above, since the original proposal text is still useful context for
  why the mechanism exists.
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
  revisit medium-mode only once it's real. (Note: these population
  figures are as first recorded 2026-08-29 and were not re-verified
  during the 2026-09-25 split — see `book-dna.md`'s Audiobook-native
  section and `book-dna-tables.md` for the current state.)
- **Post-read/listen ratings feeding narrator collaborative filtering**
  — future roadmap idea, raised 2026-08-29. Once users can log and rate
  a recommended book after finishing it (including, if they took the
  audiobook, a separate rating for the audiobook/narration itself), that
  per-narrator rating data could drive real collaborative filtering
  between users: "listeners who rated narrator A highly also rated
  narrator B highly" → recommend narrator B's books to someone who liked
  A, without needing any structured narrator-quality tags at all. This
  neatly sidesteps the Tier-B audiobook-field sourcing problem (see
  `book-dna.md`'s Audiobook-native section) by inferring narrator quality
  from correlated listener behavior instead of needing to source or
  judge it ourselves. Two real caveats: it needs an actual per-user
  ratings table to exist first (the same missing piece the
  diversity/fatigue mechanism above depends on — NOTE: that table now
  exists, `ratings`, built with the v1 web app; this proposal itself has
  not been re-evaluated against that), and it has a cold-start
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
- **`revenge` (trope) satisfying vs. hollow resolution** — raised
  2026-09-03 by the repo owner after his `revenge` separation checked
  out as slightly NEGATIVE (-0.041, see scoring-test-protocol.md's
  qualitative-review-round-2 entry), contradicting his own stated
  instinct. His clarification: he likes revenge "coming to a sweet
  fruition," not revenge used as a device to illustrate "violence leads
  to more violence, why can't we all just hold hands" (Red Rising named
  as the specific example that doesn't work for him). This is really
  the SAME axis as `message_intensity`/`emotional_resolution` intersected
  with the `revenge` trope specifically, not a wholly new field — but
  no existing field currently distinguishes "the revenge plot resolves
  as earned catharsis" from "the revenge plot resolves as a cautionary
  tale about violence." Repo owner's own words: "I don't know how this
  could be caught by a pattern recognition system" — genuinely unclear
  whether this needs a new controlled value (e.g. splitting
  `emotional_resolution` or adding a revenge-specific resolution
  sub-trope) or is better left as a case the veto/message_intensity
  fields already partially catch (both Poppy War and Dragon Republic,
  his actual heavy-handed-message dislikes, already validate via
  `message_intensity: heavy_handed`). Not built — needs more than one
  data point (Red Rising) before it clears this project's "does this
  change what gets recommended" bar.

  **UPDATE (2026-09-06)**: this exact gap resurfaced independently, via
  a friend's scoring-architecture review and the resulting sci-fi/
  revenge cross-genre-pooling investigation (see
  scoring-test-protocol.md) — worth noting for future sessions that
  this is a RECURRENCE of the same open question, not a new one; check
  this backlog before re-deriving a finding from scratch. Concretely
  proposed name this time: `revenge_denied_or_undercut` (or similar) as
  a trope-level counterpart to plain `revenge`. Repo owner's own
  reaction: logged per his instruction, but **explicitly not convinced
  this is the right fix** — still exactly one real data point (Red
  Rising), same bar as before. Also fixed a related, separate,
  higher-confidence finding from the same conversation: Red Rising's
  `message_intensity` was corrected from `moderate` to `heavy_handed`
  (`20260906040000_fix_red_rising_message_intensity.sql`) based on his
  own detailed explanation — that fix stands on its own regardless of
  whether a new trope ever gets built. Given the `message_themes`
  proposal directly below this entry already offers a more general,
  revenge-non-specific mechanism for exactly this class of problem
  (objectively-tagged authorial stance, same weight-learning as any
  other trope), that may be the better investment if/when this clears
  the bar for real — not a revenge-specific sub-trope.
- **`message_themes` — a trope-like controlled vocabulary for a book's
  authorial STANCE, not just its intensity** — repo owner's own
  follow-up proposal (2026-09-03) to the entry above: "a small
  archetype list... pacifism, anti-militarism, pro-religion, heroism,
  altruism, feminism, etc." **Correction to this doc's earlier framing**
  (in the entry above and in docs/project-log.md's 2026-09-03 "message
  intensity gap" entry): this does NOT require modeling the reader's own
  beliefs as a new kind of field. If message stance is tagged as an
  OBJECTIVE attribute of the book (a new trope group, exactly like
  existing tropes), the same per-user weight-learning `build_profile()`
  already does for every other trope (liked_freq - disliked_freq) would
  organically discover which specific stances correlate positively or
  negatively for THIS reader, with no need to ever encode his personal
  political/philosophical views anywhere. Structurally identical to how
  `darkness` or any trope already works — the system doesn't need to
  know WHY a reader likes dark books, it just needs the tag and his own
  ratings. This is a real, buildable idea, not just a thought experiment.

  Two real costs before committing to it, though: (1) tagging
  difficulty/subjectivity is genuinely higher than a plot-event trope
  (`revenge` = did this happen; `message_themes:anti_militarism` =
  what is this book ARGUING, an interpretive judgment) — though not
  categorically different from `message_intensity` itself or
  `black_and_white_morality`/`corruption_arc`, which already require
  similar interpretive calls; (2) retroactively tagging the existing
  catalog for a brand-new field is real work, and per this project's
  own schema-change bar this needs evidence it will actually move
  recommendations before that cost is paid across ~600+ books.

  **Recommended path if the repo owner wants to proceed**: don't tag
  the whole catalog speculatively. Start with a narrow 2-3 value probe
  (`anti_militarist_message` is the clearest, most directly evidenced
  one — it's exactly the Poppy War/Dragon Republic/Red Rising pattern
  already found) tagged on just a handful of relevant books (the ones
  already implicated, plus a few loved books that might carry a
  countervailing or absent stance, to get real liked/disliked contrast)
  as a real, cheap validation check before any catalog-wide rollout.
  Implement as a new trope group (reuses all existing trope machinery —
  weight learning, confidence, `validated_dealbreaker_fields()` — rather
  than inventing a separate mechanism). Not started -- awaiting the
  repo owner's go-ahead on scope given the tagging-cost implications.
- **Protagonist gender as a possible field** — raised 2026-09-03: repo
  owner loved The Grey Bastards but hated its sequel, hypothesizing
  protagonist gender/POV-character change as the reason. A single
  before/after pair from one duology, not yet checked against his wider
  rating history (no `protagonist_gender` field exists to check it
  against retroactively). Worth real investigation once/if a field like
  this is added — but per this project's schema-change bar, needs
  either (a) enough of his catalog independently re-tagged to check the
  hypothesis, or (b) more real examples surfacing the same pattern,
  before committing to a new controlled vocabulary value. Flagged, not
  built.
  **UPDATE (2026-09-04)**: repo owner gave a much richer, specific
  account of what he thinks actually happened in The True Bastards —
  not just "the protagonist changed," but Jackal (the beloved,
  earned-growth lead of book 1) is written to lose repeatedly and be
  rescued by the new lead, Fetching, who he reads as narratively
  favored despite not being written as a competent leader. This
  decomposes the original single hypothesis into (at least) three
  possibly-distinct real axes — see the two entries directly below.
  Still not built; the account is real, specific evidence but still a
  single narrator's read of two books, same evidentiary bar as before.
- **Protagonist competence/agency trajectory** — added 2026-09-04, from
  the same True Bastards account above. Whether a protagonist is
  written as increasingly capable/effective across a book, or
  deliberately undermined/humiliated (repeatedly loses, needs rescuing,
  etc.), independent of that character's objective power level or the
  book's stakes. No existing field captures this at all — `drive`,
  `personal_stakes`, and the character-archetype tropes describe
  structural facts (who's driving the plot, how dangerous is it) not
  this specific narrative-treatment axis. Genuinely hard to tag
  consistently — this is an authorial-intent/craft judgment, not a
  plot-event fact, closer in kind to `message_intensity`'s own
  subjectivity than to a trope like `revenge`. Flagged, not built —
  needs more than one account before committing to vocabulary.
- **Narrative sympathy/favoritism between co-leads** — added
  2026-09-04, same source. Distinct from protagonist competence above:
  this is about which character the TEXT ITSELF seems to validate vs.
  criticize when a book has two or more co-leads, independent of either
  character's own competence or agency. A book could write both
  co-leads as equally competent while still tonally favoring one's
  perspective — these are separable signals. Same tagging-difficulty
  caution as the entry above; flagged, not built.

  **UPDATE (2026-09-05): both this entry and protagonist competence
  above were actually built as a validation probe (two tropes, tagged
  only on The True Bastards) then reverted three times in the same
  day** — see docs/scoring-test-protocol.md for the full technical
  trajectory (structurally untestable via held-out methodology with
  only one real instance; re-added dormant on the reasoning that an
  inert-but-accurate tag shouldn't be deleted for lacking test
  evidence; then removed for real once the repo owner reconsidered the
  CONCEPT, not just the evidence). His sharper description of what
  actually bothered him, on reflection: **"Jackal isn't a lead in True
  Bastards. He just goes through character assassination."** Neither
  built field actually named this — "favoritism between co-leads"
  wrongly assumed Jackal remains a comparably-positioned co-lead in
  book 2 (he doesn't; he's been narratively demoted), and "competence
  trajectory" was too general/sequel-agnostic to capture the specific
  shape of the complaint (a previously-established, competent lead
  from an EARLIER book being actively torn down within a LATER one,
  not a trajectory within a single book). A future, better-scoped
  attempt at this idea should center that framing —
  `established_lead_narratively_torn_down` or similar, explicitly
  scoped to sequels/later series entries relative to an earlier book's
  characterization — rather than either of the two shapes tried here.
  Still needs a second real account before clearing this schema's
  standing bar; one book's read is not enough to commit vocabulary to,
  regardless of how it's framed.
- **Per-value nominal-field weight learning** — a real architectural
  finding, not a new field, surfaced 2026-09-04 by a sharp technical
  pushback on why `drive: romance_driven`'s addition "changed nothing"
  for the repo owner's own recommendations. `build_profile()` computes
  exactly ONE weight per nominal field, tied entirely to whichever
  value is most common among a user's liked books (the "mode") — it
  never learns a separate relationship for any OTHER value independent
  of the mode's own separation. Checked directly: his `drive` weight is
  0.0 because `character_driven` (the mode) is proportionally MORE
  common in his disliked books (57%) than liked (45%) — a fact about
  `character_driven` specifically, not about `romance_driven` (0
  occurrences anywhere in his rated history). `nominal_similarity()`
  correctly flags `romance_driven` as a full mismatch against the mode
  — the pipeline isn't blind to it — but a near-zero field weight means
  that correct detection currently contributes nothing regardless. This
  is a real limitation for EVERY nominal field, not specific to `drive`
  or this user: any value other than the mode is currently invisible to
  weight-learning even with real per-value evidence. Proposed fix, not
  built: treat nominal field VALUES more like tropes — each with its
  own learned `liked_freq - disliked_freq` weight, rather than one
  scalar tied to the mode. This is a real scoring-architecture change
  (not a schema/tagging one) and needs the standard 2-scenario test
  discipline in `scripts/scoring_tests.py` before landing, same as any
  other scoring change — flagged in
  `docs/scoring-test-protocol.md`, not attempted yet.
- **Crossovers/easter eggs referencing other books** — raised by the
  repo owner 2026-09-12, explicitly low-priority ("cool idea for the
  future," not P1). Two examples he gave, deliberately spanning both
  shapes this would need to cover: (1) **same-universe crossover
  cameos** — characters from The Emperor's Soul and Tress of the
  Emerald Sea appearing in later Mistborn Era Two books, all already
  linked via the `Cosmere` universe row, but the specific CAMEO itself
  isn't captured anywhere (`universe` only says "these books share a
  continuity," not "this specific book contains a nameable appearance
  from that other specific book"); (2) **cross-franchise cameos with no
  shared continuity at all** — From a Buick 8's Man in Black character
  gesturing at The Dark Tower, where the two books are explicitly NOT
  the same universe (this exact example is already discussed in
  `docs/project-log.md`'s 2026-09-11 shared-universe-audit entries, but
  only as a reason NOT to merge two series into one `universe` row —
  that audit question and this proposed field are related but distinct;
  don't conflate them). A field/mechanism here would need to capture
  the SAME thing (a specific, nameable crossover moment) in both cases,
  independent of whether the two books happen to already share a
  `universe`.
  **Real implementation-shape question, not just vocabulary**: unlike
  most entries in this backlog, this isn't a scalar enum or a
  self-contained trope — a crossover is inherently a relationship
  BETWEEN two specific books (or a book and an external franchise not
  in this catalog at all, if the referenced work isn't SFF or isn't
  ingested), so it likely needs its own linking table (something like
  `book_crossover_references`: `book_id`, `referenced_book_id`
  nullable/`referenced_work_title` for out-of-catalog references, a
  `relationship_type` — shared_universe_cameo vs. cross_franchise_easter_egg
  vs. shared_character — and a confidence/severity axis for how central
  vs. blink-and-miss-it the reference is) rather than a `book_tropes`
  row. Whether this clears the "does this change what gets recommended"
  bar (not just "is this real") is genuinely untested — plausible
  mechanism: a reader who loved Mistborn getting a discovery-delight
  nudge toward The Emperor's Soul or Tress specifically BECAUSE of the
  crossover appeal, independent of how those books score on the normal
  DNA-similarity vector; needs the same real-evidence validation-probe
  discipline as `romance_tone`/`message_themes` before committing
  vocabulary, not started.
- **A real way to model omnibus/compilation editions** (the deferred
  DATA-MODEL half — the current operational rule, "skip tagging a
  duplicate compilation," is in `book-dna-tables.md`, not here).
  Surfaced 2026-09-07 while checking partially-tagged series for the
  catalog-completion TODO: `The Farseer Trilogy`, `The Foundation
  Trilogy`, `Villains Duology`, and `Monk and Robot` all exist as their
  own `books` row (each sitting at `position_in_series = 1`, page count
  roughly matching 2-3 combined volumes) *alongside* the
  individually-tagged books they collect (`Assassin's Apprentice`,
  `Foundation`, `Vicious`, `A Psalm for the Wild-Built` respectively) —
  same series, same position number, because there's currently no
  field distinguishing "this row is a compilation of other rows in
  this series" from "this is its own book." This makes those series
  look partially-tagged (Series DNA needs >= 2 tagged books, and these
  omnibus rows sit untagged forever by design) when they're actually
  fully tagged at the individual-book level. Proposed shape: a
  `books.edition_kind` (or similar) field — standalone/compilation,
  plus a second flag on compilations for whether they're pure
  repackaging or add real new content (e.g. an omnibus with an
  exclusive bonus novella is a different case from a pure
  combine-and-reprint) — so compilation rows can be excluded from
  "needs tagging" queries and Series DNA completion counts without
  being deleted (they're real catalog entries, e.g. useful for a reader
  choosing which physical/ebook edition to buy). Not built yet — needs
  a repo-owner decision on the exact vocabulary/shape.
  Also encountered, but a separate case (not a schema gap, just
  currently-nonexistent books): `The Winds of Winter` (GRRM, ASOIAF #6)
  and `The Doors of Stone` (Rothfuss, Kingkiller #3) are both real
  future entries in already-tagged series but neither has been
  published yet (no `publication_year`/`page_count` for the former,
  `publication_year = 2030` placeholder for the latter) — nothing to
  read or tag. Skip these too; re-check once actually published.

## Rejected / superseded decisions

- **`cannibalism`** (content_warnings) — considered during the 30-book
  pilot (The Road), rejected on reflection. Unlike the researched
  content_warnings additions elsewhere (cross-checked against StoryGraph/
  real book lists before adding), this was only a single in-the-moment
  inference while tagging one book — weaker evidence, and on the same
  "does this change the recommendation, not just is it upsetting" bar, it
  reads as a specific flavor of `body_horror` + `violence_intensity:
  graphic` rather than a distinct category, same reasoning that excluded
  gore/blood/injury earlier. Not added.
  **UPDATE (2026-09-13, sweep #3)**: re-surfaced independently by a
  different reviewing agent, with real cross-author evidence this time
  (Tender Is the Flesh's entire legalized-human-meat-industry premise,
  not just incidental content; The Road's marauder gangs and
  captive-harvesting basement scene) — stronger than the single in-the-
  moment inference that led to the original rejection. Deliberately NOT
  added this round either: reopening an explicit, already-reasoned prior
  decision is a different kind of call than filling a previously-
  unexamined gap, and isn't something to flip unilaterally mid-sweep.
  **STILL PENDING repo-owner decision as of the 2026-09-25 split** —
  not resolved by this reorganization, just relocated. Whoever picks
  this up next should confirm it's still genuinely unresolved (check
  for a more recent decision first) before treating this status as
  current.
- **`fragmented_nonlinear_structure`** (a deliberately
  out-of-chronological-order/digression-heavy narrative structure —
  Infinite Jest, Gravity's Rainbow) — seriously investigated during
  sweep #3 (2026-09-13) and deliberately rejected as redundant: direct
  DB check confirmed both evidence books already carry `timeline:
  nonlinear` — the exact same redundancy trap sweep #1 caught with
  `non_linear_timeline_narrative` (Vicious/Vengeful/Six of Crows/Crooked
  Kingdom, also already captured by the `timeline` scalar). Not added.

## Dated implementation/review history

### Resolved during review

- **`darkness` / `humor_level` granularity** — keeping both as 4-point
  enums. They're independent axes (a grimdark book can still be heavily
  funny) — that's *why* they're separate fields, not one combined "tone"
  scale.
- **`magic_system_hardness`** — stays a separate field, not folded into
  `tropes`. Reads as a spectrum property of the worldbuilding, not a
  discrete narrative beat.
- **`romance_heat_level` / `violence_gore_level`** — split into frequency
  + intensity pairs (see `book-dna.md`'s Content & shape section).
- **`series_structure`** — replaced by `narrative_closure`; series
  membership and completion status moved out of `book_dna` entirely (see
  `book-dna.md`'s "Series & universe" section).
- **Twists** — split `twist_ending` (single late reveal) from
  `twist_filled` (repeated reversals throughout), added to `tropes`.
- **Added `sanderlanche`** to `tropes` — see `book-dna.md`'s Tropes &
  craft section.
- **`content_warnings`** — expanded 14 → 23, renamed `graphic_torture` →
  `torture` and `animal_death` → `animal_harm` for consistency with the
  "neutral fact, severity is separate" principle, and added a shared
  `severity` axis (`brief` / `moderate` / `central_theme`) per selected
  warning rather than a full frequency+intensity split.
- **`tropes`** — expanded ~30 → ~61, organized into 6 groups (see
  `book-dna.md`'s Tropes & craft section). Reasoning: multi-select
  vocabulary growth is cheap (no per-book cost for values that don't
  apply), unlike scalar fields.
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
  trope gaps (added), `person: mixed` + `timeline:
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
  correctly diagnosed as engine-level, not schema gaps — see
  `book-dna.md`'s "Known limitations" section. Neither new field was
  retroactively backfilled onto the 30-book pilot corpus.
- **DNA accuracy review, on the 10 pilot books the user actually read and
  liked** — a check the original pilot design called for but hadn't been
  done until asked for directly: checking tagged values against firsthand
  knowledge of the source material, not just checking whether the
  similarity ranking came out right. Found: `isekai` and
  `renaissance_or_mercantile_setting` as two more real trope gaps (The
  Golden Compass, The Lies of Locke Lamora), a `violence_intensity: brutal`
  tier, and three real per-book tagging corrections applied
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
  see `book-dna.md`'s Scope and "Series & universe" sections.

### Full original write-ups for now-built tables/mechanisms

`book-dna-tables.md` promises each of the 5 items below has its "full
original rationale... preserved verbatim" here. That preservation step
was incomplete after the 2026-09-25 split's implementation stalled
partway through -- caught by the split's own after-the-fact acceptance
testing (a fresh agent's investigation flagged the confidence-layer
entry specifically as missing; checking the other 4 confirmed the same
gap). Restored verbatim from the pre-split commit (`git show
pre-book-dna-split:docs/schema/book-dna.md`) the same day, not
rewritten -- these are exactly what the original file said, including
any staleness already noted inline at the time.

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

  **UPDATE (2026-09-05): table BUILT** (`audiobook_editions`,
  `20260905260000_audiobook_editions_table.sql`) — `book_id,
  edition_type (standard/dramatized_full_cast/abridged/other),
  narrators, production_company, runtime_minutes`, plus a real,
  repo-owner-flagged addition the original idea missed: dramatized
  full-cast productions (GraphicAudio in particular, but the same
  applies to other dramatized adaptations) release EPISODICALLY over
  months, not all at once — confirmed directly, Wind and Truth's
  GraphicAudio adaptation released across 5 parts between roughly late
  2025 and March 2026. A lookup done mid-release would correctly find
  "yes, a GraphicAudio exists" while badly misrepresenting reality (only
  some parts out, no way to say how much of the story is actually
  available to listen to). Added `release_status`
  (fully_released/in_progress/announced), `parts_released`/
  `parts_total`, and `last_verified_date` — the same "refreshed from
  metadata sources periodically, never set once at tagging time" pattern
  this project already uses for `series.status`/`book_count`, now backed
  by an actual column instead of just a documented expectation, so a
  future tagging session can tell whether a row needs re-checking rather
  than trusting a stale status indefinitely. Seeded with one real,
  directly-verified row (Wind and Truth) as a working example — full
  catalog backfill is separate, future work, not attempted in this pass.
  Populating this at real scale is still blocked on the same
  data-sourcing problem as before (Hardcover's API likely doesn't carry
  GraphicAudio editions; needs per-book research).

  **UPDATE (2026-09-07): real-scale population handed off** as
  `.claude/skills/tag-audiobook-editions/SKILL.md` -- covers GraphicAudio
  AND BBC Audio/Radio drama (a second confirmed real producer, not just
  GraphicAudio) for existing catalog books, plus Audible Originals
  (audio-only, no print counterpart -- see `books.work_type`'s new
  `'audio_original'` value, migration `20260907140000_work_type_audio_
  original.sql`) as brand-new catalog entries.

  **UPDATE (2026-09-09): real progress, 94 rows populated** across
  GraphicAudio and BBC Audio (see project-log.md's many 2026-09-08/09
  "audiobook-editions skill" entries for the full batch-by-batch
  history) -- `narrators` stores a flat array of names only, no
  character-role mapping. Repo owner raised a real future idea: a
  movie-credits-style "who plays whom" cast list, prompted by
  GraphicAudio's own site not publishing this (their product pages
  list a cast but not which actor voices which character). Genuinely
  future work, explicitly placed further back in the roadmap than the
  current per-book/per-producer sourcing effort -- would need either a
  richer `narrators` shape (array of `{name, character}` objects
  instead of plain strings) or a new join table, plus a real data
  source for the character-level mapping (GraphicAudio doesn't publish
  it, so this would need liner notes, credits read directly from the
  audio, or another source entirely). Not scoped further than that;
  revisit once the current sourcing effort is further along.

  **UPDATE (2026-09-18): added `release_date_start`/`release_date_end`**
  (migration `20260918231000_audiobook_editions_release_date_range.sql`),
  prompted by a repo-owner report that a `release_date` field was
  missing entirely. Deliberately a RANGE, not a single date -- a
  single-release edition gets both columns set to the same date, but a
  multi-part dramatized release (GraphicAudio's Wind and Truth again
  being the concrete example, 5 parts over ~4 months) genuinely has a
  different start and end, and `release_date_end` should stay null
  until `release_status = 'fully_released'` rather than guess an end
  date for a release still in progress. Schema only -- every existing
  row has both columns null; populating them (along with the separately
  tracked 306-row `runtime_minutes` gap, see `docs/TODO.md`) is real
  per-row research queued to `.claude/skills/tag-audiobook-editions/
  SKILL.md`, not attempted in this pass.

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

- **Series DNA — built 2026-08-30.** External suggestion, judged the
  strongest idea in the batch. A series can change dramatically across
  its own run (Harry Potter: light tone/mild violence in book 1 to dark
  tone/graphic violence by book 7) — recommending or scoring against
  only the first entry's Book DNA can misrepresent the whole commitment.
  Confirmed the key insight: NOT a fresh tagging pass — computed as an
  aggregation over `book_dna` rows already tagged per book, grouped by
  `series_id` (`compute_series_dna()` in `recommend.py`) and ordered by
  `position_in_series`.

  Scope question resolved: does a shared universe (the Cosmere) or a
  parent series spanning tonally different eras (Mistborn, spanning the
  original trilogy and the later Wax & Wayne books) merit its own DNA?
  No to both, and the existing series hierarchy already settles this for
  free — `books.series_id` always points at a LEAF series (confirmed:
  Mistborn's books link to "Mistborn Era One"/"Era Two", never to the
  parent "Mistborn" row, which has zero books linked directly), so
  grouping by `series_id` naturally computes trajectories only at the
  level a reader actually commits to reading in order. No special-casing
  needed. Verified across all 18 multi-book series currently in the
  catalog: every trajectory read as genuine and well-known (Harry
  Potter's darkening, Percy Jackson's stakes narrowing in book 2, LOTR's
  POV structure opening up once the Fellowship splits, Murderbot's
  stakes widening from novella to novel scope).

  Two more pieces built alongside the core aggregation, both from user
  feedback: (1) `series_dnf_outlook()` — per-user (unlike the objective
  trajectory above): compares how well the CURRENT book in a series
  scores against a specific user's profile vs. the NEXT one, to answer
  "will this series get better for me if I keep going" instead of
  silence when a reader is on the fence about DNFing; (2) `explain_match()`
  now includes a `series_note` field — when a book's explanation is
  shown, it's paired with an objective caveat about how the series shifts
  over its run (e.g. "Across the series, it shifts from several POV
  characters to a large ensemble cast..."), reusing the same
  `describe_series_trajectory()`/`phrase_field()` machinery already built
  for the explanation layer.

- **Confidence + source layer on field/trope values — built 2026-08-30.**
  External suggestion, e.g. "slow pace" tagged with a 0.8 confidence
  level, plus which source produced it. `book_tropes` gained
  `confidence`/`source` columns directly; scalar `book_dna`/`books`
  fields use a new side table, `book_field_confidence` (book_id,
  field_name, confidence, source), since a per-field companion column on
  the wide `book_dna` row would mean ~29 extra columns. Source values:
  `ai_inferred` (the vast majority — an LLM judgment call), `verified_external`
  (a real citable authority, e.g. `work_type`'s Hugo Award backing),
  `manual_review` (a deliberate editorial correction, not a fresh batch
  guess), `community_tagged`/`community_confirmed` (future, not populated
  yet — see the community-validation idea below).

  Deliberately did NOT retroactively fabricate confidence numbers across
  the whole catalog — most existing tags predate this system, and a
  precise-looking number invented after the fact would be worse than no
  number. Absence of a row means "unassessed," scored as full confidence
  (1.0) by default, not penalized. Backfilled only real, traceable cases:
  6 `work_type` novellas (`verified_external`, Hugo Award-backed), 7
  `pov_count` values corrected during manual review (`manual_review`,
  0.85), and 14 `pov_count` values this session's own batch agents
  explicitly flagged as borderline/uncertain in their own reports
  (`ai_inferred`, 0.4-0.65 depending on how uncertain). A systematic
  confidence audit across the rest of the catalog (all other fields,
  all other tropes) is separate, much larger future work — not
  attempted here, logged as its own open item.

  Wired into `recommend.py` scoring: `score_book()`/`explain_book()` now
  discount a field/trope's effective weight by `get_confidence(book,
  field)` before it contributes, for that specific book only — an
  uncertain tag gets less voting power in the weighted average rather
  than being trusted at face value. Both the contribution (numerator)
  and total_weight (denominator) are discounted equally, so this is a
  "counts for less" effect, not a bias toward match or mismatch. Verified
  on The Bands of Mourning (pov_count confidence 0.6, in a profile where
  pov_count carries weight 0.5): score shifts modestly (0.4423 vs. 0.4433
  simulated full-trust) — small but real, and the right order of
  magnitude given one moderately-uncertain field is only one of ~20
  contributing signals for that book.

  Two originally-proposed uses NOT built yet: using low confidence as a
  triage signal to prioritize re-research, and raising confidence via
  future community-tag correlation (both still logged, need the data --
  more confidence-scored books, and community tagging respectively --
  to be worth building on top of).

- **Post-read/DNF "why didn't it work" dropdown — built 2026-08-30.**
  External suggestion, distinguished from what this doc already rejected
  elsewhere (asking users to explain field-by-field on every single
  rating, which defeats the point of structured Book DNA inference).
  Design choice: rather than inventing a separate fixed reason taxonomy
  ("too slow," "too much romance," ...), reuse the book's OWN
  already-tagged tropes/fields (via the explanation layer's `describe()`)
  as a dynamic checklist — "here's what we tagged this book with, tell
  us which of these worked against you" — plus a small fixed set of
  `NEUTRAL_FEEDBACK_REASONS` (wasn't the mood, didn't click with
  characters, lost interest, life got in the way) that are explicitly
  NOT about the book's content and produce no calibration signal.

  Real design catch made during implementation, worth recording: only
  TROPE selections translate into a `fatigue_overrides` entry.
  Field-level selections (e.g. "overall_pace" was the problem)
  deliberately do NOT, because `fatigue_overrides` flips a field's
  weight relative to the user's own CENTROID ("avoid being similar to
  your average"), which is a different statement from "avoid this
  specific book's slow-pace value" — if the disliked book's pace was
  already far from the user's centroid, force-applying the existing
  mechanism would perversely reward OTHER far-from-centroid books
  instead of steering away from slow pacing specifically. The correct
  existing mechanism for field-level dislikes is just rating the book
  itself hated/disliked (already built, see the rating-magnitude
  scoring system entry) — `build_profile()` already learns whether pace
  is a real discriminator once it recurs across several disliked books,
  which is the right way to learn a pattern, not a single-book override.
  Field-level selections are still captured by `book_feedback_options()`
  for triage/logging value, just not wired into calibration yet.

  Verified end-to-end: selecting `court_intrigue` as a dislike reason on
  *A Clash of Kings* correctly demoted court-intrigue-heavy books
  (A Clash of Kings, A Storm of Swords, Malice) and promoted others
  (The Gunslinger, The Two Towers, Eragon) in a real `recommend()` call,
  while a simultaneously-selected neutral reason ("wasn't my mood")
  correctly produced no calibration change on its own.

### Vocabulary growth process — dated growth rounds

The opening standing rule for this process ("does this predict a
different recommendation, not just is it a real term") lives in
`book-dna.md`, not here. What follows is the full chronological record
of every deliberate vocabulary-growth pass, preserved for its per-book
evidence and "distinct from X" reasoning trail.

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

**Fourth growth round (2026-09-05, first catalog-wide deliberate gap
sweep)** — 6 trope values (5 distinct concepts; the queer-romance
concept split into two values rather than one combined tag) added and
applied catalog-wide (43 book-trope insertions across 42 books, migration
`20260905140000_add_5_new_tropes_from_gap_sweep.sql`), each verified
against 2+ real catalog books sharing ZERO trope-level signal despite
being the same recognizable subgenre/device — the precedent this skill's
2026-09-13 sweep (see below) followed. **Documented here for the first
time 2026-09-13** — a real, already-happened instance of this project's
own "docs must be updated in the same session as the schema change" rule
being missed: the migration landed and was applied catalog-wide, but
neither this file nor `book-dna.schema.yaml` was ever updated, so these
6 values existed live in the database and in the tagging data for over a
week with no documentation trail. Caught only because the 2026-09-13
sweep cross-checked the DB's actual `tropes` table (129 rows) against
`book-dna.schema.yaml` (123 documented at the time) rather than trusting
the docs — see `docs/project-log.md`'s 2026-09-13 gap-sweep entry.
- `sapphic_romance` / `mlm_romance` (romance_relationships) — a
  female-female / male-male romantic relationship as a central or
  significant thread. Split into two values rather than one combined
  `queer_romance` tag per the sweep's own recommendation (different
  reader-taste signals, not interchangeable). Evidence: Gideon the
  Ninth, One Last Stop, The Once and Future Witches, The Priory of the
  Orange Tree (sapphic); Carry On, The Song of Achilles, The House in
  the Cerulean Sea, Under the Whispering Door (mlm).
- `infiltration_or_undercover_plot` (plot_devices) — a character
  deliberately adopts a false identity to infiltrate an enemy
  organization/institution as the plot's driving mechanism. Evidence:
  City of Stairs, Mistborn: The Final Empire, Red Rising, The Lies of
  Locke Lamora, The Traitor Baru Cormorant. Distinct from `heist` (a
  bounded job, not necessarily an assumed identity) — and distinct
  enough from a merely-discovered hidden faction that Babel was
  deliberately dropped from consideration (Robin uncovers an
  already-embedded resistance cell rather than adopting a false
  identity himself).
- `alternate_history` (setting_worldbuilding) — a real historical era
  diverging from actual history via a speculative premise woven into
  that real history. Evidence: Babel, His Majesty's Dragon, Jonathan
  Strange & Mr Norrell, The Man in the High Castle.
- `multi_generational_saga` (plot_devices) — the story spans multiple
  generations of a family/dynasty/civilization, following descendants
  across decades or centuries. Evidence: the Foundation series, the
  Jade City trilogy, One Hundred Years of Solitude, Fire & Blood.
- `cosmic_horror` (craft_devices) — dread from vast, incomprehensible,
  uncaring cosmic forces that human minds/morality cannot meaningfully
  confront or defeat, not just fight and win against. Evidence: the
  Southern Reach trilogy, House of Leaves, The Call of Cthulhu, Mexican
  Gothic. The "confronting, not defeating" test is the key
  discriminator — Perdido Street Station was deliberately dropped
  because the Slake Moths, however alien, are eventually defeated by
  human ingenuity.

**Fifth growth round (2026-09-13, second catalog-wide deliberate gap
sweep, `.claude/skills/catalog-trope-gap-sweep/SKILL.md`)** — 5 new
trope values added and applied catalog-wide (24 book-trope insertions
across 24 books, migration
`20260913170000_catalog_trope_gap_sweep_5_new_tropes.sql`), same method
as the fourth round: real per-book literary verification, "does this
change the recommendation" bar, willingness to reject plausible
candidates. Covered by author/cluster (6 parallel non-forked background
agents per CLAUDE.md's agent-efficiency guidance): Terry Pratchett +
Brandon Sanderson (71 books); Stephen King + Jim Butcher + Sarah J. Maas
+ John Scalzi (69); Rick Riordan + Mark Lawrence + James S. A. Corey +
Isaac Asimov + Robert Jordan (67); Robin Hobb + Joe Abercrombie + Martha
Wells + V. E. Schwab + Leigh Bardugo + Steven Erikson (63); Cassandra
Clare + Matt Dinniman + Ursula K. Le Guin + C. S. Lewis + J.K. Rowling +
Brent Weeks + Andrzej Sapkowski (58); Orson Scott Card + Douglas Adams +
Adrian Tchaikovsky + Becky Chambers + George R.R. Martin + Iain M. Banks
+ Neil Gaiman (49) — 377 tagged books total, all fully reviewed.
- `anthropomorphic_personification_protagonist` (craft_devices) — an
  abstract force/concept (Death, Time, Music) embodied as a literal
  character with human-like problems and agency. Evidence: Terry
  Pratchett's Death sub-series — Mort, Reaper Man, Hogfather, Soul
  Music. Distinct from `mythological_pantheon_as_characters` (requires
  an actual named/worshipped mythology, which Death explicitly isn't —
  he predates and exists outside the Discworld's own gods) and from
  `immortal_or_ageless_character` (a trait, not the concept-made-literal
  mechanism).
- `government_experimentation_on_the_gifted` (plot_devices) — a
  clandestine government agency abducts and holds captive people with
  innate psychic/supernatural abilities to study, control, or weaponize
  them. Evidence: Stephen King's Firestarter and The Institute (two
  independent standalone novels decades apart, not a series).
- `magically_binding_bargain` (plot_devices) — protagonist enters a
  supernatural contract with a powerful entity, trading power/salvation
  for costly, enforced ongoing obligations that drive later plot.
  Evidence, cross-author: Jim Butcher's Dresden Files (Harry's deal with
  Queen Mab to become her Winter Knight — made in Changes, driving Cold
  Days/Skin Game/Peace Talks) and Sarah J. Maas's A Court of Thorns and
  Roses/A Court of Mist and Fury (Feyre's bargain with Rhysand).
- `predictive_social_science` (scifi_specific) — a non-mystical,
  explicitly scientific model used to predict and steer a civilization's
  future over generations, as opposed to fate or supernatural foresight.
  Evidence: Asimov's Foundation/Second Foundation/Foundation's Edge
  (psychohistory). Worth noting: all three were already tagged
  `prophecy` before this addition — a real instance of the "confidently
  pattern-matched to genre convention" mistagging risk CLAUDE.md's
  HIGH_RISK_FIELDS section warns about (Foundation's whole premise is
  explicitly anti-mystical), left as-is rather than removed since
  correcting an existing tag is a `tag-catalog-batch`-scope edit, not
  this sweep's vocabulary-backfill scope — flagged here for a future
  tagging session to reconsider. (Not re-verified whether this was ever
  actually fixed as part of the 2026-09-25 split — check current live
  data before assuming either way.)
- `post_scarcity_utopia` (setting_worldbuilding) — a society where
  advanced (often AI-run) technology has eliminated material scarcity,
  removing conventional economic/survival stakes from character
  motivation. Evidence, cross-author: Iain M. Banks's Culture novels (7
  tagged books) and Becky Chambers's Monk & Robot duology. No prior
  "utopia"-valence setting value existed at all.

Three real candidates found but deliberately NOT added this round —
each rests on a single series/work within the current catalog rather
than an independently-recurring pattern, so held to the same "talk
yourself out of it" discipline as the fourth round's Babel/Perdido
Street Station exclusions. Recorded in `book-dna-vocabulary-gaps.md`'s
tracker rather than discarded, so a genuine second occurrence in a
future sweep or tagging batch is recognizable:
`monster_hunter_for_hire` (Andrzej Sapkowski's Witcher — The Last Wish,
Sword of Destiny; a same-catalog Dresden Files comparison was considered
but rejected as already substantially covered by Dresden's own
`noir_detective_structure` tagging), `skinchanging_or_body_possession`
(A Song of Ice and Fire's warging — Bran/Varamyr across 4 books, but all
one series), and `remote_piloted_robotic_surrogate` (John Scalzi's Lock
In/Head On — one duology, arguably one story told across two books).

**Sixth growth round (2026-09-13, third catalog-wide deliberate gap
sweep, "sweep #2" of `.claude/skills/catalog-trope-gap-sweep/SKILL.md`,
continuing sweep #1 from earlier the same day)** — 7 new trope values
plus 1 new content warning added and applied catalog-wide (migration
`20260913220000_catalog_trope_gap_sweep_2_7_new_tropes_1_cw.sql`), same
method as the fourth/fifth rounds: real per-book literary verification,
"does this change the recommendation" bar, willingness to reject
plausible candidates. Covered the ~366-book pool of authors NOT swept
by sweep #1 (6 parallel non-forked background agents, ~60-62 books
each, per CLAUDE.md's agent-efficiency guidance) — see
`docs/project-log.md`'s 2026-09-13 "sweep #2" entry for the exact
per-cluster author lists.
- `monster_hunter_for_hire` (plot_devices) — protagonist's defining
  narrative structure is a paid, episodic profession, taking discrete
  contracts to hunt/kill a specific named monster/threat for coin, town
  to town. **Promoted from sweep #1's single-occurrence tracker** (first
  seen on Andrzej Sapkowski's Witcher — The Last Wish, Sword of Destiny)
  on a genuine second, cross-genre occurrence: Ilona Andrews's Kate
  Daniels (Magic Bites, Magic Burns) — a freelance mercenary/Order-
  contracted investigator taking paid jobs against specific magical
  threats in post-Shift Atlanta. Distinct from `noir_detective_structure`
  (already tagged on both Kate Daniels books) — that's narrative
  voice/investigation structure; this is the plot-generating job
  mechanism (contracts, payment, episodic creature-of-the-book).
- `underworld_descent_journey` (plot_devices) — protagonist(s)
  physically travel into the literal land of the dead/underworld/hell to
  rescue a person or retrieve something, and must find a way back. The
  classical katabasis structure. Evidence, cross-author: R.F. Kuang's
  Katabasis and Rick Riordan's The Lightning Thief + The House Of Hades
  — only shared tag across all three was `epic_quest`, too broad to
  discriminate.
- `closed_circle_mystery` (plot_devices) — a murder/mystery investigation
  confined to a small, fixed cast of suspects trapped together in an
  isolated setting with no way to leave until the killer is found.
  Evidence, cross-author: Stuart Turton's The 7 1/2 Deaths of Evelyn
  Hardcastle + The Last Murder at the End of the World, and Tamsyn
  Muir's Gideon the Ninth. Distinct from `noir_detective_structure`
  (broader — doesn't require an isolated/fixed cast; Alastair Reynolds's
  Chasm City and P. Djèlí Clark's A Master of Djinn both carry it without
  being closed-circle).
- `flintlock_fantasy_setting` (setting_worldbuilding) — a fantasy setting
  in a gunpowder/early-industrial era where firearms are a defining part
  of the world's technology and often its magic system itself. Evidence,
  cross-author: Brian McClellan's Powder Mage series (4 books) and
  Brandon Sanderson's Mistborn Era Two (4 books, none of which carried
  any setting-group tag at all before this). Distinct from `steampunk`
  and `renaissance_or_mercantile_setting`.
- `creation_turns_on_creator` (craft_devices) — a creator's own
  artificial/reanimated/engineered being, the product of their hubris,
  ultimately turns against and causes the downfall of their maker (the
  "Frankenstein complex"). Evidence, cross-author: Mary Shelley's
  Frankenstein (both editions) and H. G. Wells's The Island of Doctor
  Moreau — zero trope overlap despite sharing this exact mechanism.
  Deliberately kept distinct from `engineered_creation_escapes_control`
  below (see that entry) rather than merged into one value — a reader
  drawn to Frankenstein/Moreau's intimate Gothic creator-tragedy is not
  the same reader as one drawn to Jurassic Park/Prey's ensemble
  techno-thriller, despite both sharing the broader "hubris punished by
  your own creation" theme.
- `engineered_creation_escapes_control` (plot_devices) — a
  scientifically-created organism/system breaches human containment and
  turns on its creators/handlers, driven by institutional hubris/
  negligence rather than personal malice or a designed AI's intentional
  revolt. Evidence, same-author (Michael Crichton, 3 separate novels,
  same precedent as the fifth round's Firestarter/The Institute):
  Jurassic Park, Prey, and The Lost World — zero trope overlap between
  Jurassic Park and Prey despite sharing this exact mechanism. Distinct
  from `ai_uprising_or_rebellion` — notably NOT applied to Prey's swarm
  even though the vocabulary already existed, since the swarm's threat is
  emergent/evolutionary rather than a designed AI's deliberate uprising,
  confirming this is a genuinely separate axis.
- `royal_suitor_selection_competition` (romance_relationships) — a
  formalized, multi-contestant competition in which eligible candidates
  compete for the right to marry a monarch/royal heir, distinct from a
  single pre-decided union. Evidence, cross-author: Kiera Cass's
  Selection trilogy (the titular broadcast elimination process) and
  Victoria Aveyard's Red Queen (the in-world "Queenstrial"). Distinct
  from `arranged_marriage` (single decided union), `love_triangle`
  (entanglement, not a structured competition), and
  `deadly_competition_or_trial` (explicitly lethal-stakes; this
  competition isn't fight-to-the-death).

**Content warning**: `natural_disaster_mass_casualty` — a natural or
astronomical disaster causing mass death as a book's inciting/central
event, distinct from `war_trauma` (human conflict) and
`pandemic_or_epidemic` (disease). Promotes the tracker's open
climate/natural-disaster gap (first flagged 2026-09-09 on *The Ministry
for the Future*, re-checked-but-still-single-occurrence in sweep #1
earlier the same day as this round) on **two independent second
occurrences** found by different sweep clusters: James Dashner's *The
Kill Order* (catastrophic solar flares) and Neal Stephenson's
*Seveneves* (the Moon shatters, triggering the "Hard Rain" bombardment
that kills ~7 billion). Deliberately named/scoped broadly rather than
narrowly "climate" — neither new evidence book is climate-driven, both
are astronomical in origin, so a climate-scoped name would have missed
the actual evidence that promoted it. All three evidence books tagged
`severity: central_theme` (the disaster is each book's defining event,
not background) and `reveals_spoiler: false` (established at or near
the opening in all three).

**NOTE (added during the 2026-09-25 split, per
`docs/codx-reports/2026-09-25-book-dna-split-review.md`): the tracker
in `book-dna-vocabulary-gaps.md` currently shows a real, unresolved
status inconsistency for this exact content warning** — appearing as
both "Open" and "Promoted/resolved" in different places. Not silently
fixed here; flagged for a human decision. See that file's own inline
flag at the entry.

Two real candidates found but deliberately NOT added this round —
recorded in `book-dna-vocabulary-gaps.md`'s tracker rather than
discarded: `caste_or_faction_stratified_society` (a formalized,
named-caste/faction sorting mechanism as a society's defining
structure — Divergent, Red Rising, The Selection, Empire of Silence —
real cross-author evidence, but held back on a genuine, self-flagged
risk that it would just co-occur with the existing `dystopia` tag
across most of the catalog rather than discriminating a real subset of
it; needs a broader catalog-wide check before promotion, not just this
round's one cluster) and a possible-but-unconfirmed second occurrence
of the deferred `skinchanging_or_body_possession` candidate (Samantha
Shannon's *The Bone Season* "dreamwalking" — the reviewing agent's own
confidence in the exact mechanic, host-body control vs. astral travel/
communication only, wasn't solid enough to assert).

**Seventh growth round (2026-09-13, fourth and — for now — final catalog-wide
deliberate gap sweep, "sweep #3" of
`.claude/skills/catalog-trope-gap-sweep/SKILL.md`)** — 11 new trope values
added and applied catalog-wide (migration
`20260913230000_catalog_trope_gap_sweep_3_11_new_tropes.sql`, 28
book-trope insertions across 24 books), same method as prior rounds: real
per-book literary verification, "does this change the recommendation" bar,
willingness to reject plausible candidates. Unlike sweeps #1-2 (author
clusters), this round's pool was ~99% single-tagged-book authors (221
authors, 224 books), so Step 3 clustered by subgenre/narrative-mechanism/
theme instead of by author (7 parallel non-forked background agents) — see
`docs/project-log.md`'s 2026-09-13 "sweep #3" entry for the exact
per-cluster book lists.
- `forced_psychological_reconditioning` (plot_devices) — a totalitarian
  state captures a protagonist who has committed an act of individual
  dissent/rebellion and subjects them to a deliberate, named medical or
  psychological procedure engineered to strip their capacity for
  independent thought and force ideological conformity — succeeding by
  the narrative's end. Evidence, cross-author: 1984 (Room 101), A
  Clockwork Orange (the Ludovico Technique), We (the Great Operation/
  fantasiectomy). Distinct from `dystopia` (generic setting tag) and
  `corruption_arc` (a protagonist's own gradual choices, not an
  externally imposed procedure).
- `incomprehensible_alien_contact` (scifi_specific) — contact with an
  alien intelligence/phenomenon that remains fundamentally unknowable
  and uncommunicative despite sustained effort — the narrative's point
  is the FAILURE of comprehension itself. Evidence: Solaris, Roadside
  Picnic. Confirmed distinct from `cosmic_horror` (neither evidence book
  carries that tag — philosophical/melancholic register, not
  horror-dread) and from `first_contact` (too neutral/broad to
  discriminate this specific permanent-incomprehension subset).
- `impossible_or_non_euclidean_architecture` (setting_worldbuilding) — a
  structure whose interior physically defies its exterior
  dimensions/ordinary geometry, itself a central plot/horror engine.
  Evidence: House of Leaves, The Library at Mount Char, Acceptance (the
  Southern Reach's Tower/Tunnel). Distinct from `new_weird_setting`
  (atmosphere, not this specific mechanism) and `cosmic_horror` (dread
  from scale, not spatial impossibility).
- `mass_unexplained_sensory_or_memory_loss` (plot_devices) — an
  inexplicable, population-wide loss of a specific human faculty (sight,
  memory) with no clear physical cause, itself the book's central
  speculative engine. Evidence: Blindness, The Memory Police. Distinct
  from `sudden_apocalypse_event` (a catch-all for any sudden catastrophe,
  doesn't name the specific mechanism) and `pandemic_or_epidemic` CW
  (implies a transmissible illness, neither book frames it that way).
- `animated_construct_companion` (character_archetypes) — a significant
  character is an animate being made of inanimate, non-biological
  material, with full personhood and agency. Evidence, cross-author: The
  Wonderful Wizard of Oz (the Scarecrow, the Tin Woodman), Howl's Moving
  Castle (Calcifer; Turnip-head), The Neverending Story (the
  Rockbiter). Distinct from `shapeshifters` (own-body transformation, not
  this) and `multiple_fantasy_species` (broad diversity tag, not this
  specific mechanism).
- `institutional_time_travel_bureaucracy` (scifi_specific) — a formal
  agency administers time travel via assigned handlers, permits, and
  clearances, foregrounding the procedural apparatus as a load-bearing
  element. Evidence: The Ministry of Time, Doomsday Book. Distinct from
  plain `time_travel` (says nothing about who administers it) and
  `dark_academia_setting` (atmosphere, not this apparatus).
- `secret_magical_bureaucracy` (setting_worldbuilding) — the protagonist
  works within a hidden, institutionalized government agency/police
  branch — rank, hierarchy, procedure, payroll — whose job is managing
  the supernatural within an otherwise mundane world. Evidence: Rivers
  of London (the Folly), The Rook (the Checquy Group). Distinct from
  `urban_fantasy_setting` (general setting tag, doesn't capture the
  institutional employment structure) and
  `infiltration_or_undercover_plot` (these protagonists operate openly
  as members, not undercover).
- `old_faith_displaced_by_new_religion` (setting_worldbuilding) — an old,
  animistic folk religion visibly loses power as an organized religion
  spreads through the same population, and this shift drives the plot.
  Evidence: The Bear and the Nightingale, The Mists of Avalon. Distinct
  from `colonization_themes` CW (literal external conquest — this is an
  internal religious shift) and `mythological_pantheon_as_characters`
  (the shared device is the decline mechanism, not gods-as-characters).
- `state_mandated_body_harvesting_or_modification`
  (setting_worldbuilding) — the ruling power practices forced,
  magically-enabled harvesting/alteration of its subjects' bodies as
  tribute, tax, or punishment, as a routine instrument of governance.
  Evidence: The Bone Shard Daughter (bone-shard tribute from children),
  Perdido Street Station (judicial "Remaking"). Distinct from
  `body_horror` CW (generic grotesque-transformation warning, doesn't
  capture the state-as-harvester angle) and `slavery` CW (Bone Shard's
  tribute-children keep their freedom — a tax system, not ownership).
- `modern_knowledge_as_power_source` (plot_devices) — the protagonist's
  real-world, mundane, learned knowledge (not innate talent, not a
  system-granted stat) is the literal mechanism by which they gain an
  edge in a new/fantastical world. Evidence: Off to Be the Wizard
  (Martin's IT troubleshooting skills let him "hack" reality), The
  Wandering Inn (Erin's modern recipes/business sense). Distinct from
  `isekai` (transportation mechanism only) and `hidden_talent_prodigy`
  (an innate gift, the opposite of learned mundane knowledge).
- `caste_or_faction_stratified_society` (setting_worldbuilding) —
  **promoted from sweep #2's single-occurrence tracker.** Sweep #2 had
  real cross-author evidence (Divergent, Red Rising, The Selection,
  Empire of Silence) but held back on a self-flagged risk that it would
  just co-occur with `dystopia` catalog-wide rather than discriminating
  a real subset of it. This round resolved that concern two ways: a
  genuine new confirming instance (*Brave New World*'s Alpha/Beta/Gamma/
  Delta/Epsilon castes, assigned via the Bokanovsky Process) AND real
  discriminating counter-evidence — *Battle Royale* and *The Knife of
  Never Letting Go* are both `dystopia`-tagged with NO caste/faction-
  sorting mechanism at all, directly proving the trope does not simply
  shadow `dystopia` catalog-wide. All 5 evidence books backfilled in one
  migration (the 4 original sweep-#2 evidence books had never actually
  been tagged with it, since the trope didn't exist yet).

One candidate seriously investigated and deliberately rejected as
redundant this round — see "Rejected / superseded decisions" above
(`fragmented_nonlinear_structure`).

One content-warning candidate considered and deliberately NOT
added, flagged for repo-owner reconsideration rather than
unilaterally overridden — see "Rejected / superseded decisions" above
(`cannibalism`).

## Open for review

Nothing outstanding. Both controlled vocabularies (`tropes` at 152
values, `content_warnings` at 38 — current as of the 2026-09-13 sweep #3
catalog-wide gap sweep, cross-checked directly against the live DB
tables rather than trusted from memory) have had both a researched pass
against real external sources and a real-books pilot pass (30 books
blind-tagged, see `docs/pilot/`), and both are still expected to keep
growing as an ongoing practice once real books get tagged in step 04 —
see `book-dna.md`'s "Vocabulary growth process" section.

(These counts are as last checked 2026-09-13, not re-verified during
the 2026-09-25 split — see `book-dna.schema.yaml` for the current
exact count.)

## Next step

Roadmap step 02: scaffold the app (Next.js + Supabase — auth, and core
tables for `books`, `users`, `ratings`, `book_dna`). This schema file was
the direct input for the `book_dna` table shape once the open-review items
above were settled. (Historical — step 02 is long since done; the v1
web app shipped 2026-09-18, see `docs/TODO.md`.)
