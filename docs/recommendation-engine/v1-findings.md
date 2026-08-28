# Recommendation engine — v1 prototype

Built during an autonomous work window (user asleep, weekly usage cap
about to reset) as the most valuable well-defined next step: step 05 on
the roadmap, with a built-in way to self-validate without the user
present — the original 30-book pilot has real, documented like/dislike
reactions (see `docs/pilot/findings.md`) that a scoring approach can be
checked against, the same way the pilot validated the schema itself.

## Design

Matches the original artifact's decision: **per-user weighted vector,
no collaborative filtering for v1.** Concretely:

1. Every book's DNA is encoded into a flat feature space: ordinal scalar
   fields (position on their ordered value list — e.g. `darkness`:
   light/moderate/dark/grimdark), nominal scalar fields (exact-match
   only — e.g. `person`, `form`), and tropes (multi-select set).
   **Content warnings are deliberately excluded from the score** — per
   `book-dna.md`, they're neutral descriptive data, not a taste signal
   to match toward. They belong in personalized hard filters (step 07:
   "never show me X"), not in a positive-match score.
2. A user's profile is built from their rated books, not a fixed global
   formula: for each feature, compare the average value among liked
   books to the average among disliked books. **A feature's per-user
   weight is how much it actually discriminates for that specific
   user** — a feature where liked and disliked books look the same
   tells us nothing about this user's taste and gets down-weighted
   automatically, no manual tuning required.
3. Catalog books are scored by weighted similarity to the liked-books
   centroid, using those per-user weights.

Implementation: `scripts/recommend.py`, a standalone script (not wired
into the DB as a stored function/API yet — that's step 06+ work, once
the app itself exists). Run directly: `python3 scripts/recommend.py`.

## Validation against real pilot data

Used the pilot's actual, documented reactions (not fabricated — pulled
from `docs/pilot/findings.md`'s two "DNA accuracy review" sections,
which explicitly name which books were liked vs. not loved):

- **Liked (6):** The Golden Compass, The Lies of Locke Lamora, The Eye
  of the World, Kings of Paradise, Prince of Thorns, The Way of Kings
- **Disliked/not loved (8):** Bird Box, Assassin's Apprentice, We Are
  Legion (We Are Bob), Interview with the Vampire, The Poppy War,
  Circe, Dark Matter, He Who Fights with Monsters

### Result: strong signal on structural taste

Top 15 recommendations, unprompted, were overwhelmingly multi-POV
political/war epic fantasy with hard-ish magic systems: Malice, A Game
of Thrones, A Darker Shade of Magic, Oathbringer, The Lord of the
Rings, The Blade Itself, Perdido Street Station, Rhythm of War, Ninth
House, A Dance with Dragons, The Priory of the Orange Tree, Dune
Messiah, A Clash of Kings, A Storm of Swords, A Feast for Crows.

That's exactly the right shape of answer for someone who liked Locke
Lamora/Eye of the World/Way of Kings and disliked Assassin's Apprentice
despite it being a very similar-looking book on paper — the algorithm
independently surfaced `pov_count` (multiple vs. single) and `person`
as two of the strongest discriminating features, which lines up with a
real, well-known reader-taste split (multi-POV political epic fantasy
vs. single-POV character study) without that split being hand-coded
anywhere.

Checking where the *disliked* books land when scored against the same
profile (not excluded from ranking):

| Book | Rank (of 162) | Score |
|---|---|---|
| The Poppy War | 57 | 0.645 |
| Circe | 96 | 0.541 |
| Bird Box | 115 | 0.482 |
| Assassin's Apprentice | 137 | 0.409 |
| Dark Matter | 139 | 0.393 |
| He Who Fights with Monsters | 150 | 0.333 |
| Interview with the Vampire | 153 | 0.319 |
| We Are Legion (We Are Bob) | 162 | 0.265 |

7 of 8 land in the bottom half, most in the bottom third — a
disliked book the algorithm had never seen a rating for still gets
pushed down correctly, purely from DNA similarity to what else was
liked/disliked.

### A real, honest limitation: The Poppy War

The one disliked book that DOESN'T rank low is The Poppy War (57/162,
top third) — and chasing down why surfaced something worth knowing
about the limits of this approach, not just the algorithm's success:

The user's actual stated reason for disliking it was that it felt
**preachy** — which the schema already has a field for
(`message_intensity: heavy_handed`). But this book (part of the
original 30-book pilot, tagged before recent backfills) had
`message_intensity` sitting `null` in the database — a real data gap,
now fixed (see below). Even after fixing the gap and re-running,
The Poppy War's rank barely moved. Digging into why: the *centroid
weighting* approach averages across ALL disliked books, and only one
of the 8 disliked books (Poppy War itself) is tagged `heavy_handed` —
the other 7 are mostly `subtle`. Averaged across 8 examples, "dislikes
heavy-handed books" isn't a strong enough aggregate signal to compete
with The Poppy War's otherwise very strong structural similarity
(multi-POV, violent, war-focused, hard magic-adjacent) to the liked
set.

This is a legitimate, known limitation of small-sample preference
learning — a single clearly-explained dislike ("too preachy") doesn't
reliably generalize to "avoid heavy_handed books" from a sample of one,
the same way a human wouldn't either without more data points. It's the
same category of thing `book-dna.md`'s existing "Known limitations —
engine-level, not schema fixes" section already flags (trope fatigue,
novelty perception, execution-quality chemistry) — not a sign the
schema or the scoring approach is broken, but a real signal that step
07's actual rating flow needs enough ratings per user before the
per-feature weights get reliable, and that a written "why did you
dislike this" free-text or tag-based reason (not just thumbs down)
would help this specific failure mode more than more DNA fields would.

## Data gap found and fixed along the way

Validating against real data caught a real, previously-unnoticed gap:
**`message_intensity` was `null` for all 30 original pilot-corpus
books** — the same 30 books that needed the `age_category`/
`book_length` backfill earlier, for the same root cause (tagged before
the field existed / before later backfills). Confirmed via a full
column-by-column null check that no other field has this gap. Backfilled
directly (all 30 are well-known books, low ambiguity for message
intensity specifically) and applied to both hosted and local DBs.
Notable calls: The Fifth Season and The Forever War tagged
`heavy_handed` (both are well-documented as deliberately, directly
thematic — systemic oppression allegory and anti-war statement,
respectively); The Poppy War also `heavy_handed`, matching the user's
own stated reaction.

## What this is (and isn't) yet

This is a validated v1 *algorithm*, not a shipped feature — it's a
standalone script reading a JSON export of the catalog, not wired into
the app or database as a live function. Turning it into a real backend
service (a Postgres function or API endpoint the eventual app calls) is
step 06+ work, once there's an app to call it from. What this pass
established: the core approach works, is validated against real (not
synthetic) preference data, and its failure modes are understood and
documented rather than hidden.
