# Scoring engine test protocol

## Why this exists

Every scoring-formula test run so far (2026-08-29 through 2026-09-01) has
used exactly ONE real rater -- the repo owner. That's enough to catch
real bugs (it did: series-position blindness, series-vote inflation,
person/pov_count redundancy), but it is NOT enough to conclude an idea
is genuinely useless just because it didn't help this one person's
rating pattern. Several ideas below are marked "deferred," not
"disproven" -- they may become plausible again once a second or third
rater's real ratings exist and the test scenarios below get a real
rater #2/#3 added, not just a bigger version of rater #1.

**Rule: don't conclude an idea is dead from a single-rater test.** Log
it as deferred, note what data would change the verdict, move on.

## Running the tests

```
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres python3 scripts/scoring_tests.py
```

Rerun this whenever:
- Any change lands in `build_profile()`, `score_book()`, or anything
  else in the scoring path.
- A new rater's real ratings become available (add a new scenario to
  `scoring_tests.py` rather than replacing `REAL_RATINGS` -- keep every
  rater's scenario runnable independently AND together, so a fix that
  helps one rater and hurts another is visible).
- Enough time/data has passed that a deferred idea (see table below) is
  worth reconsidering.

## The two scenarios, and why both are required

**Scenario 1 (dilution)**: a real signal (e.g. "this reader dislikes
first-person, single-POV books") gets correctly detected but then
outvoted in the final average by many other fields that happen to agree
for unrelated reasons. Symptom: a field shows up correctly as a
mismatch in `explain_match()`, but the overall score still lands as a
"Good match."

**Scenario 2 (domination)**: one or two fields split so cleanly between
a rater's liked/disliked books that they get outsized weight and
function as a near hard-filter, drowning out every trope and other
field. Symptom: `person`/`pov_count`'s weight dwarfs every trope weight
in `build_profile()`'s output.

**A fix is only a candidate for landing if it's tested against BOTH.**
Every fix that's helped scenario 1 so far has either done nothing to
scenario 2 or made it worse, and vice versa -- see the table below.
`_split_by_sign` results should be checked with `run_held_out_test` for
scenario 1 and `run_weight_cap_check` for scenario 2 before any scoring
change is considered safe to land.

## What's been tried

| Idea | Scenario 1 (dilution) | Scenario 2 (domination) | Status |
|---|---|---|---|
| Flat `WEIGHT_CAP` (0.5) | N/A -- predates this protocol | Fixes it (the original 2026-08-29 fix) | **Landed** |
| Series-position gating | N/A -- separate bug class (correctness, not weighting) | N/A | **Landed** |
| Series-aware weighting (`_series_deduped`) | Real, consistent improvement, no regressions | Confirmed no interaction (person/pov_count still hit the same cap either way) | **Landed** |
| Redundancy discount, per-book conditional (person/pov_count, cliffhanger/narrative_closure) | Real improvement -- 2 more books flip a match-label bucket (Royal Assassin, Interview with the Vampire both Good->Mixed) vs. the blanket version below | Real fix -- pov_count's mismatch magnitude drops to 0.149, below max trope weight (0.429); person stays undiscounted and lands roughly at trope scale | **Landed** (superseded the blanket version below) |
| ~~Correlation discount, blanket per-profile (person/pov_count only)~~ | Some improvement | Real fix, but cruder | **Superseded 2026-09-01** -- discounted pov_count's weight for EVERY candidate in a profile once person was active anywhere, even for third-person candidates where nothing is actually redundant. The asymmetry check (P(single\|first)=0.88 but P(first\|single) only 0.61) showed the discount needs to be conditional on each candidate's OWN values, not a blanket per-profile scaling -- see the per-book version above, and `narrative_closure`/`ends_on_cliffhanger`'s much starker asymmetry (0.986 vs. 0.515) which motivated generalizing this properly instead of leaving it a one-off |
| Structural-field prior boost (person/pov/narrator_reliability/form ×1.8-3x) | Some improvement, plateaus quickly | Would reopen the original bug (untested at landing time -- caught before shipping) | **Rejected** -- conflicts with scenario 2 |
| Category-budget/alpha blend | Looked like a win under an incomplete alpha sweep; a full sweep found alpha=0 (no budget influence) best | alpha=0 reopens the original bug (confirmed via reconstruction) | **Deferred** -- not confirmed useless, only confirmed not to work with THIS rater's data at THIS scale; retest once more/varied rater data exists |
| BM25-style saturating curve | No clear help; one book moved the wrong direction at some settings | Does NOT fix it -- values stayed at 0.77-0.97 across all k tested, barely below the uncapped raw magnitude | **Rejected for scenario 2** -- the technique needs inputs with a much wider natural range than our [0,1]-bounded field weights have; may still be worth a different formulation later |
| Bayesian-average shrinkage | Wash -- 2 books better, 2 worse, no net movement | Modest help (person/pov_count both landed at 0.4) | **Deferred** -- doesn't clearly solve either scenario alone, but not disproven as a component of a combined approach |
| Author-affinity (flat, per-author average) | N/A (different mechanism) | N/A | **Rejected** -- nets neutral-to-negative; a consistent-catalog author (Robin Hobb) benefits, a stylistically varied one (Sanderson, Skyward vs. the rest) gets actively hurt |
| Author-affinity (two-layer: base + per-author exception profile) | N/A | N/A | **Validated logically, not landed** -- correctly explains a known outlier once it's rated, but can't be predictively tested with held-out methodology (its value is learning-after-the-fact); needs live data, not a synthetic split |
| Field-pairing/interaction effects (e.g. "dislikes slow pace unless grimdark") | Not tested | Not tested | **Deferred, not attempted** -- ~435 possible field pairs is too many to reliably estimate from a single rater's 10-50 ratings; revisit only for a SPECIFIC pattern that recurs in real feedback, not as a general mechanism |
| Series-repeat signal (disliking an earlier book in a series should weigh heavily on a later one, unless its own DNA diverges a lot) | Real improvement -- Royal Assassin and Assassin's Quest both move substantially toward correct (0.539->0.427, 0.575->0.476), no effect on anything without an actual disliked series-mate | No interaction -- no shared series between liked/disliked books in this scenario | **Landed** (`SERIES_REPEAT_WEIGHT`, `series_repeat_worst_similarity()`) -- honest limitation: even at full weight, doesn't always cross all the way to "Poor match" (book_similarity()'s trope-overlap component dilutes it, since same-series books naturally differ on plot-specific tropes even when narrative style stays consistent); correctly produces NO effect on the sparse (16-book) scenario, since that training set doesn't include the disliked Farseer book needed to trigger it -- confirms the mechanism only acts on evidence that's actually present, not a coincidence |

## Second rater: Osnat (2026-09-01, two rounds)

**Round 1** (partial list, no full Fable export): only 4 of 22 titles
both in the catalog and tagged -- too few for a real held-out test, used
a leave-one-out diagnostic instead. Not degenerate, but not a real
accuracy measurement either given the tiny n.

**Round 2** (a fuller star-rated reading history, ~131 more titles):
merged with round 1 per explicit repo-owner decisions (see
`data/ratings/osnat.json`'s `_meta` -- the newer star-rated list
supersedes round 1 wherever they overlap, which resolved a direct
contradiction on A Court of Frost and Starlight: hated vs. 4.0/liked;
stars map to our tiers via an even linear split). Usable tagged set grew
to 18 -- big enough for a real held-out test this time (5 held out: A
Court of Wings and Ruin, Harry Potter and the Half-Blood Prince, Harry
Potter and the Goblet of Fire, Divergent, Iron Flame).

Result: 3/5 correct on the surface, but the honest finding is more
important than that number -- **every single held-out prediction landed
in the same narrow "Strong match" band (0.79-0.89) regardless of
whether the true rating was loved, liked, or merely it_was_okay.** The
engine isn't actually discriminating between her preference gradations
right now; it's defaulting to uniformly high because of a real,
structural data problem: of her 18 tagged/in-catalog books, 17 are
positive (loved/liked/it_was_okay) and only 1 (The Midnight Library,
hated) is negative -- and that one outlier is a completely different
style of book (literary speculative fiction) from the YA-fantasy/magic-
school cluster (Harry Potter, ACOTAR, Fourth Wing/Iron Flame) that makes
up the rest, so it doesn't give the model anything to contrast against
for THAT cluster specifically. This is the same "no disliked signal ->
weights fall back to flat defaults" limitation documented early in this
project's history (2026-08-29, the wife's first real test), now
reconfirmed concretely with a second real rater rather than a synthetic
case. Not a new bug -- a real, expected consequence of a one-sided
rating pool, and a strong argument for getting some genuine dislikes
into her tagged set specifically (which currently isn't possible: none
of her actually-disliked titles are in the catalog at all -- see the
catalog-breadth finding below).

Real catalog-breadth finding, not a scoring finding: the large majority
of Osnat's ~145 total unique titles aren't in the catalog at all.
Several are genuinely out of v1 scope (pure contemporary romance --
Book Lovers, Beach Read, the Calendar Girl series, etc.), but several
are paranormal/fantasy romance that IS in v1 scope and simply hasn't
been ingested (the Kate Daniels/Magic Bites urban fantasy series,
Daughter of No Worlds, Ruthless Vows, Sweep of the Heart, When the Moon
Hatched, Mate, a Throne of Glass novella). The catalog's Hardcover-
sourced "top fantasy/sci-fi" ingestion likely under-represents this
subgenre specifically -- worth a targeted ingestion/tagging pass, not
just "more of the same books." Notably, several of her DISLIKED titles
specifically (Daughter of No Worlds, Magic Burns, When the Moon Hatched,
Mate) fall in this same gap -- ingesting and tagging them would directly
address the negative-signal shortage above, not just grow the catalog
generically.

## Catalog growth re-check (2026-09-02)

The catalog grew from 307 to 523 tagged books via parallel batch-tagging
sessions. Before rerunning anything, sanity-checked tagging quality on
the new batches (per this project's own "compare a fresh batch against
the existing catalog's average" convention): a real, confirmed
under-tagging signal, not a bug -- content warnings landed at ~1.02/book
across ALL new batches vs. 1.83/book baseline, and trope density shows a
clear declining trend WITHIN the session as it progressed (6.47 -> 4.27
-> 3.20 tropes/book across three successive batches). Worth flagging
back for enrichment; not blocking, since none of the specific books used
in scenarios 1/3/4 come from the thin batches.

Reran all 4 scenarios as-is: bit-for-bit identical results to before
catalog growth (same scores to 3 decimals). This is expected, not a null
result -- none of these scenarios reference catalog-wide statistics;
they only use the specific rated/held-out titles' own tags, none of
which changed. Catalog growth genuinely doesn't touch this held-out
methodology by design -- it matters for the live `recommend()` candidate
pool and for series-completion-dependent mechanics (series-position
gating, the series-repeat signal), not for these fixed-book accuracy
numbers.

Catalog growth DID fill 5 real gaps from the original ratings
collection: Lord of Chaos (WoT book 6), A Little Hatred/Best Served Cold
(First Law World extras), and Fool Moon/Grave Peril (Dresden books 2-3,
resolving the earlier "at least 3, liked all" ambiguity -- combined with
Storm Front, almost certainly the 3 meant). Added to
`data/ratings/mathias.json` and reran scenario 1 with the enriched
58-book pool: mixed, modest movement -- The Wise Man's Fear improved
substantially (0.630 -> 0.522, still "Mixed" not "Poor" but meaningfully
closer), Skyward and Old Man's War moved slightly in the correct
direction, but Royal Assassin/Interview with the Vampire/Assassin's
Quest moved slightly the WRONG direction (still same bucket). Net
correct-count unchanged (4/11) -- more relevant, complete data doesn't
guarantee improvement on every individual book, and isn't expected to.

## Sparse-data check (2026-09-01)

Added scenario 3 (`SPARSE_RATINGS`, the repo owner's original 16-book
list) specifically to check whether the landed fixes -- series-aware
weighting, the redundancy discount -- behave consistently with less
data, not just on the fuller 42-book training set they were tuned
against. Result: consistent. Royal Assassin, Skyward, and Assassin's
Quest score almost identically whether trained on 16 or 42 books.
Overall accuracy is a bit lower with less data (3/9 vs. 4/11), as
expected, and one book (The Last Wish) flips from a correct prediction
to an incorrect one with less evidence to go on -- a real, expected
degradation, not a sign either landed fix behaves differently or
unpredictably at this smaller scale. No case yet where a fix helps one
data regime and backfires in the other.

## Other correlated field pairs found (2026-09-01 scan)

A systematic Cramer's V scan across all ~30 structural/content fields
found several pairs more strongly associated than person/pov_count
(0.373), which was the only one discounted:

- `violence_frequency` / `violence_intensity` (0.645)
- `narrative_closure` / `ends_on_cliffhanger` (0.599)
- `romance_heat_frequency` / `romance_heat_intensity` (0.586)
- `darkness` / `emotional_register` (0.550)
- `darkness` / `violence_intensity` (0.548)
- `prose_density` / `prose_complexity` (0.451)
- `intellectual_weight` / `prose_complexity` (0.450)

**Deliberately not discounted.** High correlation alone doesn't mean
redundancy -- most of these are two genuinely distinct axes a reader
could hold separate opinions on (how OFTEN violence occurs vs. how
graphic it is; a book's closure vs. a literal cliffhanger device), not
one fact stated twice via two schema fields. person/pov_count was
judged different: first-person structurally implies single-POV closely
enough (P=0.88 vs. a 0.44 baseline) that treating them as one signal,
not two, is defensible. The others need the same kind of individual
judgment call before being added, not a blanket "discount anything
correlated" rule -- that would risk throwing away real independent
signal (see `recommend.py`'s comment on this for the exact reasoning).

## Open, untested hypothesis

**POV count as an amplifier, not just a redundant signal.** Raised
2026-09-01: high `pov_count` (ensemble casts, frequent POV-switching)
might not just correlate with `person`, but actively worsen the
*severity* of other problems a book has (thin pacing, weak character
work) -- a moderator/interaction effect, structurally different from
plain redundancy. Not tested: this needs the same interaction-effect
infrastructure already deferred above (too data-hungry for one rater's
ratings), and there's no clean way to isolate "worse BECAUSE of high
POV count" from "just also disliked" with only 53 ratings from one
person. Revisit once multiple raters' data exists and a specific,
recurring pattern (not just a hunch) can be checked.
