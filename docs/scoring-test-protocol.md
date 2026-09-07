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
| Per-user calibrated Poor-match threshold (`user_calibrated_poor_threshold()`, replaces the fixed 0.35 `match_label()` cutoff) | Real improvement -- Mathias full: hated_rejection 0%->60%, bucket accuracy 36%->64%; Mathias sparse: 0%->50%, 33%->56%; zero regression on pairwise accuracy or loved recall in either | No interaction tested directly (WEIGHT_CAP_RATINGS has no disliked/hated distinction fine-grained enough), but the redundancy-discount/WEIGHT_CAP mechanisms are untouched -- this only changes label assignment on an already-computed score, never a weight | **Landed** 2026-09-02 -- see "Poor-match threshold diagnostic" section below for full reasoning/numbers. Honest limitation: does nothing for Osnat (still 0% hated_rejection in every variant) or Mathias's series-isolated scenario -- both are cases where the disliked book's raw score itself never drops low enough for ANY plausible threshold to catch, a genuine DNA-similarity/tagging gap (see the Magic Bites/Magic Burns case), not a labeling problem this fix can reach |
| Trope-weight sample-size shrinkage (`build_profile_trope_shrinkage()`, `n/(n+k)` factor on each trope's raw weight, k swept 1-12) | Genuinely mixed at every k tested, all 4 real raters -- e.g. k=3: Mathias full pairwise 0.84->0.91 (real gain, no bucket/hated_rejection regression) but Osnat pairwise 0.67->0.61 and Dandan bucket 0.71->0.57 (real regressions); Mathias sparse hated_rejection 0.50->0.25 regresses at EVERY k from 1 to 12, never recovers | Confirmed no interaction with person/pov_count (ordinal/nominal loops untouched by construction) | **Deferred** 2026-09-06 -- mechanism does exactly what it's designed to (hidden_talent_prodigy: +0.267->+0.100 at k=5, well-evidenced tropes barely move), but at this dataset's scale you can't tell from sample size alone whether a thin-evidence trope is noise (helps) or a genuine minority signal (hurts, e.g. Royal Assassin/Mathias-sparse) -- same conclusion as the already-deferred Bayesian-average shrinkage above, now confirmed for a trope-only, more targeted version of the same idea. Kept as `build_profile_trope_shrinkage()` in recommend.py, not wired into production, same pattern as `build_profile_per_value()` |
| Candidate-pool prevalence discount (`score_book_prevalence_discount()`, each field/trope's contribution scaled by `max(0.1, 1-prevalence)` where prevalence = fraction of the WHOLE CATALOG sharing that value -- the friend's IDF-style proposal) | Real improvement, no clear regression -- Mathias full: bucket 0.73->0.82, hated_rejection 0.80->1.00, pairwise unchanged; Mathias sparse: bucket 0.56->0.67, hated_rejection 0.50->0.75, pairwise 0.73->0.70 (small); Dandan: pairwise 0.73->0.87, bucket unchanged; Osnat: pairwise 0.67->0.61 (one real regression, on the rater already flagged with a structural 17-liked/1-disliked data skew) | Assassin's Apprentice (WEIGHT_CAP_RATINGS) raw score 0.257->0.192, moving further in the correct (disliked) direction, not reopening the bug | **Promising, not yet landed** 2026-09-06 -- directly confirms the friend's #2 concern with real numbers: `emotional_resolution`'s near-constant +0.323 (53.0% catalog prevalence) drops to +0.152 for every book sharing that value; `person`'s contribution for a `third_limited` match (53.3% prevalence, the modal/most-common value) drops from 0.227 to 0.106 -- directly answers point #4 (repo owner: "we still see person take a huge weight") for the common case that dominates the Ledger, while a genuinely rare mismatch value (`first`, 29.8% prevalence) stays closer to full strength, which is the mechanism working as intended, not a gap. Needs the isolated/author scenarios and a full scorecard run, plus understanding the Osnat regression, before this is a real landing candidate -- not done yet, this is a first-pass A/B only |

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

## Catalog growth re-check, round 2 (2026-09-02, later)

Rechecked both raters against the catalog after another round of
tagging. Mathias: no change -- the only titles still missing (Black
Prism sequels) haven't been ingested. Osnat: usable set grew 18 -> 30,
importantly adding 3 more negative-rated titles (When the Moon Hatched,
Daughter of No Worlds, Magic Burns, all hated) on top of the one
available before.

Tested Daughter of No Worlds and Magic Burns as new held-out cases.
Both wrong; Magic Burns badly so -- 0.895 ("Strong match") despite
being hated, higher than most of her actually-loved books.
`explain_match()` shows almost no real mismatch against her profile.
Root cause, confirmed via series lookup: Magic Bites (liked) and Magic
Burns (hated) are books 1 and 2 of the same series (Kate Daniels), and
their DNA fields genuinely don't differ enough to explain the dislike.

This is the mirror image of the Farseer case, and it sharpens a real
asymmetry the repo owner identified independently: disliking a
predecessor is strong, reliable evidence for distrusting a sequel
(what the series-repeat signal exploits) -- but liking a predecessor is
NOT equally reliable evidence FOR a sequel, and there's no equivalent
mechanism for that direction, nor an obvious way to build one from DNA
fields alone if the two books don't differ on the fields tracked. May
be a genuine limit of a field-based system, not a gap to patch --
logged as an open question, not a bug to fix reflexively.

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

## Benchmark scorecard (added 2026-09-02)

Prompted by a repo-owner brainstorm (with ChatGPT) about whether
held-out bucket accuracy should be the only accuracy metric. Verdict:
no -- bucket accuracy (the original test) blends several different
questions into one correct/wrong count, which can hide a system that's
lopsided in a specific, fixable way. Added three new metrics to
`scripts/scoring_tests.py`, all computed from the SAME held-out rows a
normal `run_held_out_test()` call already produces (no new ratings or
retraining needed):

- **Pairwise preference accuracy** (`pairwise_accuracy()`) -- of every
  pair of held-out books with a different true rating, does the
  predicted score rank them in the same direction? Turns an 11-book
  held-out set's 11 independent bucket verdicts into up to 55 pairwise
  comparisons -- more statistical power from the same data, which
  matters given how small every real rater's set still is.
- **Loved recall / hated rejection** (`recall_and_rejection()`) -- of
  truly loved/liked held-out books, what fraction scored Good/Strong
  ("can it find books I'd enjoy"); of truly hated/disliked ones, what
  fraction scored Poor ("can it recognize a dealbreaker"). These are two
  different capabilities a single blended accuracy number conflates.
- **Series/author-isolated held-out** (`run_isolated_held_out_test()`,
  `_isolated_training_set()`) -- strips every OTHER rated title sharing
  a series or author with a held-out book out of training, not just the
  held-out titles themselves. Directly targets a real gap in the
  existing scenarios: Royal Assassin and Assassin's Quest are held out
  in `REAL_HELD_OUT` while Assassin's Apprentice (same series, also
  disliked) stays in training -- exactly the evidence the series-repeat
  signal (see the "landed" table above) is designed to use. The normal
  held-out test can't distinguish "the DNA fields genuinely generalize"
  from "the series-repeat mechanism is doing the work." Osnat's set has
  the same shape via ACOTAR/Harry Potter/Fourth Wing/Kate Daniels.

All three feed `build_scorecard()`/`print_scorecard()`, a single table
(6 rows: Mathias full/sparse/series-isolated/author-isolated, Osnat
full/series-isolated) x 4 metric columns, each cell flagged against a
target in `SCORECARD_TARGETS`. Run via `scripts/scoring_tests.py`'s
`run_all()`, under "=== Benchmark scorecard ===".

**Baseline run (2026-09-02, current catalog/formula) and what it means:**

| Test | n | Bucket acc. | Pairwise acc. | Loved recall | Hated reject. |
|---|---|---|---|---|---|
| Mathias -- full (53 ratings) | 11 | 36% | 67% | 80% | **0%** |
| Mathias -- sparse (16 ratings) | 9 | 33% | 67% | 75% | **0%** |
| Mathias -- series-isolated | 11 | 36% | 67% | 80% | **0%** |
| Mathias -- author-isolated | 11 | 36% | 64% | 80% | **0%** |
| Osnat -- full (30 ratings) | 7 | 43% | 72% | 100% | **0%** |
| Osnat -- series-isolated | 7 | 43% | 61% | 100% | **0%** |

Targets in `SCORECARD_TARGETS` were calibrated FROM this baseline, not
picked first and compared against it -- see the constant's own comment
for the reasoning per dimension.

**The one finding that actually matters here: hated_rejection is 0% in
every single row.** The engine has never once correctly scored a truly
hated/disliked held-out book as "Poor match," for either rater, in any
variant (full, sparse, series-isolated, author-isolated). This isn't a
new bug -- it's the same asymmetry already flagged concretely in the
Magic Bites/Magic Burns case above (0.895 "Strong match" for a hated
book) and the WEIGHT_CAP/redundancy-discount work generally -- but it
was never visible as its own number before, because it was always
averaged together with loved-book recall (which is genuinely healthy:
75-100% across every row) into one bucket-accuracy figure. **This is
the concrete, prioritized target the "DNA ablation" idea from the same
brainstorm should be pointed at next**, rather than re-running ablation
against blended accuracy the way the brainstorm originally proposed --
a field whose removal moves hated_rejection specifically is a much more
useful signal than one that moves overall bucket accuracy by some
fraction of a percent.

Pairwise accuracy (61-72%) and loved recall (75-100%) already clear
their targets almost everywhere -- read that as "these dimensions are
already reasonably healthy," not as the scorecard being miscalibrated.
Series/author isolation barely moved bucket accuracy for Mathias (36%
either way) but did measurably raise several isolated scores relative
to their non-isolated versions (e.g. Royal Assassin: 0.397 -> 0.560
series-isolated) -- consistent with the series-repeat signal actively
pulling scores down in the non-isolated version, exactly as designed,
though not by enough to cross a bucket boundary in this case.

## DNA ablation, chasing hated_rejection (2026-09-02)

Implemented `run_ablation_study()`/`print_ablation_table()` in
`scripts/scoring_tests.py`: re-runs the held-out benchmark with one
field-group's weight zeroed out post-hoc (after `build_profile()`
computes it normally -- `_apply_ablation()` never touches
`build_profile()`/`score_book()` themselves), across 8 groups
(`ABLATION_GROUPS`) x 3 base scenarios (Mathias full/sparse, Osnat
full -- `ABLATION_BASES`). Grouped by real scoring questions (tropes,
pace, tone, POV/structure, stakes/drive, content intensity,
craft/density, magic/scifi-hardness), not tested field-by-field --
~30 individual fields against an 11-book held-out set would be almost
pure noise.

**Headline result, and it's a real reframing, not the answer the
brainstorm expected: hated_rejection stayed at EXACTLY 0% in all 24
(group x base) ablation runs, with zero exceptions.** Removing any
single field group -- including tropes entirely, including all of
POV/structure -- never once flips a single truly-hated/disliked
held-out book into "Poor match." The brainstorm's framing (ablation
will produce a clean importance ranking like "-7.2% pace, -0.8% POV"
that tells you what to reweight) doesn't hold for this specific metric:
**the problem isn't that one field group's weight is wrong or
overrepresented -- no single group is carrying the failure, so the fix
isn't in weight composition at all.** More likely candidates, not yet
tested: `match_label()`'s fixed 0.35 "Poor match" threshold may simply
sit too LOW given how the weighted-average formula behaves in practice
-- scores for genuinely disliked/hated held-out books have landed in
the 0.397-0.895 range across every scenario tested so far (lowest ever
observed: Royal Assassin, 0.397, Mathias's full scenario -- see the
Magic Bites/Magic Burns case and this doc's baseline table for the high
end), never once dipping under the 0.35 cutoff needed to actually be
labeled "Poor" -- or the averaging mechanism itself may structurally
resist producing low scores whenever a book matches on enough
uncorrelated fields by chance, regardless of which specific fields
those are. Next step should be diagnosing THAT mechanism (e.g. does
raising the Poor match threshold, or an explicit "how many fields actively mismatch"
count, better separate real dislikes?) rather than more field-level
ablation -- logged as the next thing to try, not actioned here.

Two secondary findings, both consistent with "check at least 2
scenarios before concluding anything" already being the right standard:

- **Tropes matter enormously for Osnat's ranking quality, and appear to
  actively hurt Mathias's on the sparse scenario -- a direct
  contradiction across raters/data regimes, not a consensus finding.**
  Removing tropes costs Osnat's pairwise accuracy -61pp (72% -> 11%,
  by far the largest single effect in the whole study -- unsurprising
  given her catalog is largely trope-dense romantasy/YA fantasy where
  structural fields alone barely discriminate one book from another).
  But removing tropes for Mathias's SPARSE scenario *improves* pairwise
  accuracy +17pp (67% -> 83%) and loved recall +25pp (75% -> 100%) --
  plausibly overfitting noise from too few trope data points at that
  training size, not a real signal that tropes are bad. Do not
  generalize either direction from this alone.
- **POV/structure fields (person, pov_count, narrator_reliability,
  timeline, form) are a real, positive ranking signal for Mathias**:
  removing them costs pairwise accuracy -13pp (67% -> 53%) on the full
  scenario, no effect on sparse, -6pp for Osnat. Consistent with
  person/pov_count's known importance from the WEIGHT_CAP/redundancy
  work -- this is corroborating evidence, not a new finding.

Bucket accuracy moved for almost no group/base combination (mostly
`+0pp`) -- only pairwise accuracy, a continuous ranking metric, showed
any sensitivity to ablation at all. That's itself informative: the
4-bucket match-label thresholds are too coarse to detect this kind of
signal at this sample size, which retroactively justifies adding
pairwise accuracy in the first place rather than relying on bucket
accuracy alone for this kind of test.

## Poor-match threshold diagnostic -- LANDED (2026-09-02)

Direct follow-up to the ablation study above: since no field group
explained hated_rejection's 0%, the next suspect was `match_label()`'s
fixed 0.35 "Poor match" cutoff itself. Repo owner independently proposed
the right general shape of the fix (make the threshold relative instead
of a fixed constant) while also flagging the real risk in the naive
version of that idea: a threshold relative to the CATALOG's score
distribution (e.g. "bottom N% of scored books is Poor") would force
SOME books into "Poor" on every profile, even one built from a purely
positive rating history where nothing is actually a dealbreaker --
mislabeling a merely-less-loved book as a real negative.

**Refinement landed instead: calibrate relative to the USER's own
liked-vs-disliked score gap, not the catalog's distribution.**
`user_calibrated_poor_threshold()` (`scripts/recommend.py`) takes the
midpoint between a user's mean TRAINING score on their own liked/loved
books and their own disliked/hated books (both rescored against their
own freshly-built profile), capped to [0.20, 0.54]. If the user has NO
disliked/hated ratings, there's no disliked-score mean to compute a
midpoint from, so it returns the original fixed 0.35 unchanged --
directly satisfying the repo owner's caveat without a special case: the
guard falls out of the calibration having nothing to calibrate against,
rather than an explicit "if no dislikes, do X" branch. Verified
concretely, not just by inspection: a synthetic all-positive 69-rating
Mathias subset correctly returns 0.350 (see `print_threshold_diagnostic()`'s
"no-negative-signal fallback check").

**Evidence before landing** (checked across 3 base scenarios --
Mathias full/sparse, Osnat full -- per this doc's "at least 2 failure
scenarios" standard, generalized here to "check every scenario you
have, not just the one that motivated the idea"):

| Base | Metric | Fixed 0.35 (old) | Calibrated (landed) |
|---|---|---|---|
| Mathias, full | bucket accuracy | 36% | **64%** |
| Mathias, full | hated_rejection | 0% | **60%** |
| Mathias, full | pairwise / loved_recall | 67% / 80% | 67% / 80% (unchanged) |
| Mathias, sparse | bucket accuracy | 33% | **56%** |
| Mathias, sparse | hated_rejection | 0% | **50%** |
| Mathias, sparse | pairwise / loved_recall | 67% / 75% | 67% / 75% (unchanged) |
| Osnat, full | all 4 metrics | -- | unchanged (0% hated_rejection) |

Zero regression on pairwise accuracy or loved recall in any scenario --
this is a pure win for Mathias, a correct no-op for Osnat. Also compared
against a plain fixed-value sweep (0.40/0.45/0.50/0.54) to confirm
"calibrated" earns its complexity over the simplest possible fix: a
single global constant either undershoots Mathias (0.50 catches 3 of 5
disliked books, 0.54 needed for the 4th) or does nothing for Osnat (no
constant below ~0.72 would ever fire on her data, and a constant that
high would misclassify most of the catalog as "Poor" for everyone) --
no fixed value serves both raters at once, which is exactly why a
per-user calibrated value was the right shape for this fix, not a
retuned constant.

**Why it does nothing for Osnat or Mathias's series-isolated scenario --
an honest limitation, not a bug.** Osnat's actual disliked held-out
books (Magic Burns 0.895, Daughter of No Worlds 0.724) score far above
even the 0.54 cap -- no threshold change in a sane range reaches them.
This is the same root cause already documented in the Magic Bites/Magic
Burns case: those specific books' DNA fields genuinely don't
differentiate from her liked profile, so their raw score itself never
drops far enough for ANY relabeling rule to catch -- a tagging/DNA-
similarity gap, not a labeling problem. Mathias's series-isolated
Royal Assassin/Skyward scores (0.556-0.560) sit just above the 0.55
Good-match boundary itself -- again, no Poor-threshold change reaches a
score that's already inside "Good" territory; that gap is what the
series-repeat signal exists to close, and only fires with series
evidence in training, which this scenario deliberately removes.

**Ablation study re-run under the landed threshold** surfaces sharper,
more useful signal than the pre-fix run did (when everything was pinned
at 0% hated_rejection, ablation could only ever show "no change"):
`stakes_drive` and `craft_density` removal each *improve* Mathias-full's
hated_rejection (+20pp, 60%->80%) and bucket accuracy (+9pp, 64%->73%)
-- flagged as candidates worth a closer look. **Investigated 2026-09-02
and NOT landed -- see "stakes_drive/craft_density: investigated, not a
real lever" below for why.** Tropes
removal cuts the other direction for Mathias's sparse scenario
specifically: it improves pairwise accuracy (+17pp) and loved recall
(+25pp) but *tanks* hated_rejection (50%->0%) -- tropes are doing real,
specific work catching his dislikes there even though they're noisy for
other metrics on that same small training set. None of this is acted on
yet -- logged as candidates for the next scoring-change proposal, to be
checked against all 3 base scenarios again before anything is changed,
per this doc's standing rule.

## stakes_drive/craft_density: investigated, not a real lever (2026-09-02)

Followed up on the ablation candidate above by pulling `explain_book()`'s
full match/mismatch breakdown for all 5 of Mathias's disliked/hated
held-out books (Royal Assassin, Skyward, The Wise Man's Fear, Interview
with the Vampire, Assassin's Quest). **Same pattern, every single time,
with no exception:** the single largest, CORRECTLY DETECTED mismatch is
always `person` (weight 0.425 -- Mathias dislikes first-person
narration and the engine catches it consistently) -- but it's
consistently outvoted by 6-10 other MATCHING fields that happen to
agree with his overall taste for unrelated reasons: `darkness`,
`violence_intensity`/`violence_frequency`, `worldbuilding_density`,
`book_length`, `scifi_hardness`, `drive`, plus several tropes
(`medieval_european_setting`, `epic_quest`). These books genuinely fit
his favorite genre (dark, violent, dense-worldbuilding, epic-length
grimdark/political fantasy) on every axis except narrative person --
this is exactly "Scenario 1 dilution" as already defined earlier in
this doc, now confirmed as the literal mechanism behind every one of
Mathias's current held-out mispredictions, not a new discovery.

**Verdict: NOT landed.** Removing `stakes_drive`/`craft_density`
specifically is coincidental, not principled -- those two groups just
happened to carry enough combined diluting weight to tip 2-4 books
below the Poor threshold, but `darkness`/`violence_intensity`/
`scifi_hardness`/tropes are contributing to the exact same dilution and
aren't touched by removing those two groups. A blanket removal is also
directly falsified by evidence already in hand: craft_density removal
measurably HURT Osnat's pairwise accuracy (-6pp, see the ablation table
above) -- exactly the "adjustment must be conditional on the specific
book being scored, never blanket" failure this project's own rules
exist to prevent (a real, already-shipped bug once, per this repo's
CLAUDE.md). More fundamentally: every general mechanism previously
tried for this exact class of dilution problem has already been tried
and rejected/deferred in this project -- structural-field prior boost
(**rejected**, reopens the domination/scenario-2 bug), category-budget/
alpha blend (**deferred**, no clean win under a full sweep), Bayesian-
average shrinkage (**deferred**, no net effect). This isn't a fresh
angle on dilution; it's the same wall this project has hit three times
already, now confirmed to be the actual cause here too rather than
disproven. Genuine dilution-resistant scoring (down-weighting "generic
taste agreement" specifically when one strong structural mismatch
exists) remains unsolved and is not a small change to attempt casually
-- any future attempt needs to check against BOTH scenario 1 and
scenario 2 from the very first test, per this doc's standing rule, not
just Mathias's held-out set.

## Design discussion: aggregation shape, not weights (2026-09-02)

Repo owner shared the dilution finding above with an outside technical
contact, who correctly reframed the whole class of problem: a weighted
arithmetic mean is COMPENSATORY by construction -- any deficit on one
field can always be offset by surplus on others. Every weight-tuning
idea this project has tried for this failure mode (WEIGHT_CAP,
redundancy discounts, structural-field boosts, alpha-blending, Bayesian
shrinkage) either did nothing or turned into a de facto hard filter,
which is exactly what that framing predicts -- you can't fix a shape
problem by turning a dial inside that shape. Four candidate fixes were
proposed, roughly in order of risk:

1. **Split display: keep the blended score for taste-fit, surface a
   strong single-field mismatch as a separate flag/badge instead of
   forcing it into one number.** Lowest risk -- `explain_book()` already
   computes matches/mismatches separately; this promotes the strongest
   mismatch to a distinct, explicit callout instead of a subordinate
   "however" clause.
2. **Non-compensatory veto/cap**: compute the normal weighted average,
   then separately cap the final score if any field's mismatch exceeds a
   per-user "veto threshold" (an ELECTRE-style outranking method).
   Flagged as carrying real risk specific to this project: the closest
   thing already tried -- boosting a structural field's weight so it
   could dominate -- was REJECTED for reopening the domination/scenario-2
   bug. A veto cap has the same failure shape if the threshold is too
   aggressive; landable only via the same per-book-conditional pattern
   `REDUNDANCY_DISCOUNTS` already uses, and only after testing against
   BOTH scenario 1 and scenario 2, same as any scoring change.
3. **Statistical per-user dealbreaker detection** (AUC/point-biserial
   separation of a user's own loved vs. hated books on each field,
   gated by a minimum sample size) instead of hardcoded field
   categories -- directly answers why the stakes_drive/craft_density
   ablation was wrong (it wasn't conditional on being a REAL per-user
   dealbreaker, just a blunt category removal). More tractable than the
   already-deferred field-PAIR interaction idea: ~30 single fields to
   estimate, not ~435 pairs.
4. **Soft non-linear penalty** (power mean with p<1, or squaring the
   mismatch before averaging) instead of a hard cap. Flagged as the
   weakest fit for THIS project specifically: a close cousin (BM25-style
   saturating curve) was already tried and rejected for a documented
   reason -- our [0,1]-bounded field weights don't have enough dynamic
   range for a curve-shape change to matter. Deprioritized relative to
   1-3.

**#1 and #3 landed 2026-09-02, #2 landed 2026-09-02 (later)** -- see
below for each. #4 remains deprioritized, not attempted.

## Dealbreaker flags -- LANDED (2026-09-02)

`dealbreaker_flags()`/`dealbreaker_sentence()` in `scripts/recommend.py`,
wired into `explain_match()`'s return value as two new keys
(`dealbreaker_flags`, `dealbreaker_summary`), additive only -- `score`,
`match_label`, `matches`, and `mismatches` are all computed exactly as
before, unchanged. A flag is any mismatch (field or trope) whose
magnitude clears `DEALBREAKER_THRESHOLD = 0.3`, computed over
`explain_book()`'s FULL mismatch list (not its `top_n`-capped one), so a
real dealbreaker can't be silently cut by the human-readable summary's
cap.

**0.3 is a first-pass fixed heuristic, not yet a statistically validated
per-user threshold** (that's what option #3 above would provide) --
picked from a real, consistent, unambiguous gap found across Mathias's 5
disliked/hated held-out mispredictions: their top 1-2 mismatches
(`person`, `magic_system_hardness`, `scifi_hardness`) always clustered
>= 0.34, while every other mismatch in the same lists sat <= 0.211 --
zero ambiguous cases in between. Verified live against his real profile
(training on his full ratings minus 3 disliked titles): Royal Assassin,
Skyward, and Interview with the Vampire all correctly surface "Possible
dealbreaker: first-person narration," while Warbreaker (loved) gets no
flag at all -- the common case, not a sign anything's wrong. Verified
this doesn't touch scoring: reran the full `scoring_tests.py` suite
before and after, benchmark scorecard output identical byte-for-byte.

Not yet tested against Osnat/Dandan/Gabriel's profiles or tuned
per-user -- since this is purely additive metadata (never changes score
or match_label), the blast radius of an imperfect threshold is much
lower than an actual scoring change, so it didn't need the full
two-scenario gauntlet before landing. Worth revisiting once option #3
(statistical per-user detection) exists, both to validate 0.3 as a
reasonable default and to make the threshold adapt per user instead of
staying fixed.

## Dealbreaker-flag sanity check across all 4 raters (2026-09-02)

Closed the gap flagged above: `check_dealbreaker_flags()`/
`run_leave_one_out_flags_check()`/`run_dealbreaker_sanity_check()` in
`scripts/scoring_tests.py` run the fixed `DEALBREAKER_THRESHOLD` against
Osnat, Dandan, and Gabriel's held-out/LOO sets (Mathias re-checked too,
for a full false-positive-rate reading he didn't get before), reporting
a false-positive rate (flagged on a truly loved/liked book -- should be
rare) and true-positive rate (flagged on a truly disliked/hated book)
per rater.

**Result: the fixed threshold has a real false-positive problem the
original spot-check against Mathias's 3 known dislikes never surfaced,
because it only checked true positives, never the full held-out set for
false ones.** Measured properly: Mathias 3/5 (60%) false-positive rate,
Osnat 1/3 (33%), Dandan 3/3 (100%), Gabriel 5/5 (100%) -- e.g. Dandan's
Words of Radiance (loved) and The Way of Kings (it_was_okay) both
tripped a "court intrigue" dealbreaker flag despite his actually rating
them fine. Root cause: a field/trope's raw weight from only a handful
of ratings is genuinely noisy, and noise crosses a fixed 0.3 magnitude
threshold just as easily as a real pattern does -- the fixed threshold
has no sample-size awareness at all.

**This directly motivated fixing the statistical-validation design
(see below) before it shipped as originally planned.** The first draft
of `validated_dealbreaker_fields()` only ADDED a lower magnitude bar for
validated fields on top of the untouched fixed threshold -- which cannot
fix a false-positive problem, since every already-noisy crossing above
0.3 still cleared the (unchanged) fixed bar regardless. Caught before
landing by running this exact sanity check with the statistical layer
wired in and seeing zero improvement in false-positive rate. Fixed by
making validation REPLACE the fixed-threshold check when enough data
exists (see `dealbreaker_flags()`'s current docstring) rather than
supplementing it.

**Re-run with the fix, same 4 raters:**

| Rater | Fixed threshold FP/TP | Validated FP/TP | Change |
|---|---|---|---|
| Mathias | 3/5 FP, 5/5 TP | **1/5 FP**, 5/5 TP | FP cut 60%->20%, TP unchanged |
| Osnat | 1/3 FP, 0/2 TP | 1/3 FP, 0/2 TP | No change |
| Dandan | 3/3 FP, 1/1 TP | 3/3 FP, 1/1 TP | No change |
| Gabriel | 5/5 FP, 0/1 TP | 5/5 FP, 0/1 TP | No change |

Mathias is a clean, real win: false positives cut from 60% to 20% with
zero loss of true-positive recall -- the one remaining false positive
(Old Man's War, liked, flagged for first-person narration) is a
legitimate exception in his own rating pattern, not a mechanism failure:
`person` is his single most statistically validated dealbreaker field
(separation well above the 0.5 bar), and this is simply a first-person
book he happened to like anyway. No per-field mechanism can predict
every individual exception to someone's own general pattern.

**Why the other 3 show zero change -- verified this is a real data
limit, not a bug**, by checking `validated_dealbreaker_fields()` against
each rater's FULL rating set (not the reduced held-out-split training
the sanity check uses):
- **Osnat**: FULL profile has 4 disliked ratings (enough sample) but
  STILL validates nothing -- her disliked/liked split genuinely doesn't
  separate strongly on any single tracked field, consistent with the
  already-documented Magic Bites/Magic Burns finding (her actual hated
  books' DNA doesn't differ enough from her liked profile to separate
  on ANY field, not just the ones tested before).
- **Dandan**: FULL profile (32 ratings) DOES validate one field --
  `pace_shape` (separation 0.565) -- that the held-out test's reduced
  training set (2 disliked, below the 3-sample gate once his one hated
  book is held out) couldn't reach. Confirmed live against his real
  profile: his actual disliked/hated books don't happen to mismatch
  specifically on pace_shape, so no flag fires for them regardless --
  correct, expected behavior, not a contradiction.
- **Gabriel**: FULL profile has exactly 1 disliked rating -- can never
  clear `MIN_DEALBREAKER_SAMPLE=3` no matter how the data is split. A
  real, unavoidable limit until he rates more books he disliked.

Net: the statistical-validation fix is real and correctly conservative
-- it only engages where there's genuine evidence, degrades gracefully
to the (noisier, but honest) fixed threshold otherwise, and its benefit
for the 3 newer/smaller raters should grow automatically as more
submissions arrive, without any further code change.

## Veto/cap mechanism -- LANDED (2026-09-02, after a caught regression)

Option #2 from the design discussion above: `_apply_dealbreaker_veto()`
in `scripts/recommend.py`, wired into BOTH `recommend()` (so it actually
changes rankings, not just an explanation) and `explain_match()`. If a
book mismatches on a field/trope that's in `validated_dealbreaker_fields()`
for that user, the final score is capped at `DEALBREAKER_VETO_CAP` (just
under `GOOD_MATCH_THRESHOLD`) -- it can never read as Good/Strong match
regardless of how well everything else agrees. This is what
`dealbreaker_flags()` (landed earlier the same day) never did: that
mechanism only ever displayed a callout next to an unchanged score. The
veto only fires via the STATISTICALLY VALIDATED path -- never from
`dealbreaker_flags()`'s fixed-threshold fallback for low-data users,
which is already documented as noisy and untrustworthy enough to move a
score. `match_label()`'s Good/Strong boundaries were extracted into
named constants (`GOOD_MATCH_THRESHOLD`/`STRONG_MATCH_THRESHOLD`) as
part of this, replacing inline magic numbers.

**A real regression was caught before this was considered landed, by
running the full benchmark suite rather than just the domination stress
test that motivated the design.** First version used
`STAT_SEPARATION_THRESHOLD = 0.5` (already landed for `dealbreaker_flags()`
that morning). Rerunning `scoring_tests.py`'s scorecard with the veto
wired into `run_held_out_test()`/`run_ablation_held_out()`/
`run_leave_one_out_diagnostic()`/`run_threshold_diagnostic()` (all
updated to call scoring through a new shared `_full_score()` helper, so
every scenario reflects the real production pipeline -- the same gap
already caught once for the calibrated threshold) showed Mathias's
SPARSE scenario collapsing: loved_recall 75% -> 0%, bucket accuracy
56% -> 33%, pairwise 67% -> 43%. Root cause, found by inspecting
`validated_dealbreaker_fields()` directly: with only 8 liked/7 disliked
ratings, SIX fields validated at 0.5, five of them landing suspiciously
right at the threshold (0.500-0.523) -- a textbook multiple-comparisons
artifact (~30 fields tested against a small sample means several cross
a fixed bar by chance, not because they're real). With 6 fields eligible
to trigger a veto, nearly every held-out book mismatched on at least one,
capping almost everything regardless of true rating.

**Fixed by raising `STAT_SEPARATION_THRESHOLD` to 0.65** (from the
originally-landed 0.5), picked empirically by sweeping 0.5-0.75 across
Mathias full/sparse and the WEIGHT_CAP_RATINGS domination scenario: 0.65
is where Mathias's full AND sparse scenarios converge on the SAME single
field (`person`, separation 0.75-0.82 in both -- genuinely robust) and
where the domination scenario's validated set stabilizes (3 fields,
unchanged through 0.75) rather than continuing to shrink -- a real
plateau, not an arbitrary round number. Safe to raise purely upward:
since both `dealbreaker_flags()`'s validated path and the new veto
require clearing this bar, raising it only makes each MORE conservative,
never introduces a new failure mode. Re-running the full suite after the
fix confirmed the sparse regression is completely gone (56%/70%/75%/50%,
matching pre-veto baseline almost exactly) with zero regressions across
all 8 scorecard rows, and Mathias's full/series-isolated/author-isolated
scenarios show a real, clean pairwise-accuracy gain (67%->73%, 67%->78%,
64%->73%) with no cost anywhere else. Osnat/Dandan/Gabriel unaffected
(none currently clear the raised bar), consistent with everything
already documented about their data.

**Domination stress test (WEIGHT_CAP_RATINGS) re-checked directly, not
just via its own existing weight-magnitude metric** (which the veto
doesn't touch and remains unaffected): scored several first-person and
third-person candidates not in that scenario's training set, before and
after the veto. Third-person candidates that AGREE with the profile's
validated fields are correctly unaffected (The Dark Forest, Revelation
Space -- scores unchanged). First-person candidates get correctly capped
(Morning Star: 0.766 -> 0.549). **Found one genuine, pre-existing
limitation this exposed more sharply, not a new bug**: a FEW third-person
candidates (Persepolis Rising, Children of Ruin) also got capped, via
`pov_count` (a real, graduated ordinal mismatch -- an ensemble cast
against a profile whose validated POV pattern sits elsewhere, legitimate
signal) and one (Children of Dune) via `person` itself, despite being
third-person -- because `person`'s values (`third_limited` vs.
`third_omniscient`) match on an ALL-OR-NOTHING basis (nominal fields have
no partial credit for "similar" categorical values), a property of
`score_book()` that predates the veto entirely. The veto just makes this
particular pre-existing limitation more consequential (a hard cap
instead of a smaller weighted-average contribution). Not fixed here --
would require restructuring nominal-field similarity to recognize
"close" categorical groups, real scope beyond building the veto itself.
Logged as a known, deferred limitation, not blocking, because it doesn't
manifest in any real rater's data across this entire testing pass, only
in the deliberately extreme synthetic domination scenario.

**Nominal-field all-or-nothing gap -- PARTIALLY ADDRESSED (2026-09-03).**
Added `NOMINAL_PARTIAL_SIMILARITY`/`nominal_similarity()` to
`scripts/recommend.py`, called from both `score_book()` and
`explain_book()` (previously each had its own inline
`1.0 if a == b else 0.0`). Deliberately conservative scope, covering
only two pairs with explicit schema-comment justification rather than
guessing at "closeness" generally: `person`'s `third_limited`/
`third_omniscient` (the pair that motivated this, above) and `drive`'s
`balanced` against both `character_driven` and `plot_driven` (the
schema comment for `drive` explicitly frames `balanced` as "an even
split of" the two). Considered and rejected extending to
`narrator_reliability`'s `ambiguous` and `emotional_resolution`'s
`bittersweet` -- both have schema comments framing them as a genuinely
different axis rather than a blend, so no partial credit was added
there.

Verified via a stash/unstash before-after diff of the full
`scoring_tests.py` suite (same catalog/rating data, only this code
change toggled): zero MISS/OK label flips and zero scorecard-row
regressions across all 8 benchmark rows; one ablation sub-metric
improved (Mathias sparse, tropes-removed pairwise accuracy 83% -> 87%);
a handful of scores nudged up slightly for exactly the affected
candidates (e.g. A Clash of Kings, Old Man's War) and nothing else
moved.

Re-checked the Children of Dune case directly: raw `score_book()`
(pre-veto) is 0.916, and the `person` mismatch magnitude used by
`dealbreaker_flags()`/the veto dropped from full weight (~0.42, sim=0)
to half weight (0.212, sim=0.5) -- the fix is working as intended. It
still clears the veto's `VALIDATED_DEALBREAKER_MAGNITUDE=0.15` trigger
bar in this specific deliberately extreme domination scenario (person's
learned weight there is large enough that even half-credit deviation
exceeds 0.15), so Children of Dune's *capped* score is unchanged at
0.549 -- the veto itself is a separate boolean/threshold mechanism, not
in scope for this fix, and this residual is the same already-documented
non-blocking limitation ("doesn't manifest in any real rater's data").
The underlying scoring gap this was meant to fix -- nominal fields
treating a close categorical pair identically to a totally unrelated
one -- is resolved.

Verified live end-to-end through `explain_match()`/`recommend()`
directly, not just the test harness: Royal Assassin (trained on
Mathias's real ratings minus itself and Skyward) now scores 0.323 (down
from ~0.34-0.40 pre-veto depending on training set), still correctly
"Poor match," with `dealbreaker_summary` still showing "Possible
dealbreaker: first-person narration." `recommend()`'s top-5 ranked list
ran without error and contained no first-person titles.

## Validated positive floor -- tested, REVERTED (2026-09-03)

Motivated by a qualitative review round 2 finding (see project-log):
the repo owner correctly identified that `anti_hero`/
`morally_grey_protagonist` -- real, validated-ish positive signal for
him -- were present on Jade City/Blood Over Bright Haven but not
driving them high enough in the ranking, because structural fields
(`person`, `pov_count`) dominate. Proposed fix: a mirror image of the
veto/cap -- `_apply_validated_positive_floor()`, floors `score` to
`VALIDATED_POSITIVE_FLOOR` (= `GOOD_MATCH_THRESHOLD`) when a book
matches EVERY field/trope in `validated_dealbreaker_fields()` for that
user, using the exact same evidence-gated pattern that made the veto
safe (never fires without real per-user statistical separation).

**A real regression was found and fixed before considering this even
as a candidate**, same discipline as the veto's own rollout: a field
with PARTIAL nominal credit (see `nominal_similarity()`, e.g. person's
`third_limited`/`third_omniscient` at sim=0.5) can register as BOTH a
validated match (`w*sim` clears `VALIDATED_DEALBREAKER_MAGNITUDE`) AND
a validated mismatch (`w*(1-sim)` also clears it) on the SAME field
simultaneously -- "matches every validated field" and "has a validated
dealbreaker mismatch" turned out NOT mutually exclusive, contrary to
the function's original design assumption. Caught via the
WEIGHT_CAP_RATINGS domination stress test: Children of Dune, correctly
capped to "Mixed match" (0.549) by the veto for its partial `person`
mismatch, got immediately un-capped back to "Good match" (0.550) by
the floor on the same call, because that same partial-credit `person`
field also counted as "matched." Fixed by making the floor explicitly
defer to the veto: if `dealbreaker_flags()` finds ANY validated
mismatch at all, the floor never fires, full stop.

**After that fix, re-tested and found ZERO positive effect anywhere**:
- Domination scenario (WEIGHT_CAP_RATINGS): confirmed no more
  regression (Children of Dune/Persepolis Rising/Children of Ruin
  correctly back at 0.549 "Mixed match"), and the floor genuinely never
  fires elsewhere in that scenario either.
- Full `scoring_tests.py` suite, all 4 real raters: byte-for-byte
  identical scorecard/ablation/threshold-diagnostic output before and
  after (confirmed via a stash-free direct before/after run; the only
  diff lines were pre-existing Python set-iteration nondeterminism in
  tied-magnitude mismatch lists, reproduced identically by rerunning
  the SAME code twice with no code change at all).
- The specific motivating books: Jade City, Blood Over Bright Haven,
  Graceling, City of Bones, House of Earth and Blood all scored
  IDENTICALLY with and without the floor (0.751-0.814, all already
  above `VALIDATED_POSITIVE_FLOOR`=0.55).

**Why it can't work, structurally, not just "wasn't tuned right"**: a
floor can only ever pull a LOW score UP to a fixed value -- it can
never re-order two candidates that both already clear that value. Every
book this was meant to help was already scoring well above 0.55; the
actual complaint (rank Jade City ABOVE City of Stairs) requires
changing the RELATIVE ranking within the "already clears Good match"
band, which a floor structurally cannot do. Also: even setting that
aside, only `person` currently validates as a dealbreaker/positive
field for Mathias at `STAT_SEPARATION_THRESHOLD`=0.65 --
`anti_hero` separation is 0.143, `darkness` 0.202, `violence_intensity`
0.169, `age_category` 0.052 (all real numbers, none close to
validating) -- so even a working floor mechanism has no positive
evidence to act on for these fields yet, regardless of shape.

**REVERTED**: `_apply_validated_positive_floor()`/
`_validated_positive_matches()`/`VALIDATED_POSITIVE_FLOOR` removed
from `scripts/recommend.py` entirely rather than left as unwired dead
code, and the `_full_score()` test helper in `scripts/scoring_tests.py`
reverted to its pre-floor form (score_book + series_repeat + veto
only) -- consistent with how this project has always handled a
tested-and-rejected idea (see "stakes_drive/craft_density: investigated,
not a real lever" and the 2026-08-29 structural-field-boost rejection
above). The real, still-open problem this was meant to solve --
structural fields (`person`=0.5, `pov_count`=0.474) dwarfing
content/taste fields the repo owner considers more predictive
(`darkness`=0.22, `anti_hero`=0.226, `age_category`=0.029) -- remains
unsolved. A genuine fix would need to change the RELATIVE weighting
inside `score_book()`'s aggregation itself, which is precisely the
class of fix (structural-field boost, alpha-blending, category budgets)
this project has already tried multiple times and rejected for
reopening the WEIGHT_CAP_RATINGS domination bug -- still an open,
hard problem, not a quick follow-up.

**One unrelated real surprise surfaced during this investigation,
worth the repo owner's own attention**: the `revenge` trope's
liked-vs-disliked separation for Mathias is **-0.041** -- i.e. slightly
MORE common among his disliked/hated books than his liked ones,
contradicting his own stated intuition that revenge-driven plots are a
strong positive signal for him. Not investigated further here (no
scoring change follows from one trope's sign on its own), but worth a
manual look at which specific `revenge`-tagged books he's disliked.

## `discovery_only` flag -- LANDED (2026-09-03)

Second half of the same qualitative-review-round-2 feedback: ranking
Wind and Truth #3 (loves Stormlight) and New Spring #15 (loves Wheel of
Time) are probably correct PRODUCT recommendations, but trivial ones
for judging whether the DNA fields themselves generalize to new
authors/series -- exactly why `scoring_tests.py` already has
series-isolated/author-isolated held-out variants. Those variants
exist for the automated benchmark; there was no equivalent for a human
manually eyeballing a live `recommend()` pull.

Added `discovery_only` (default `False`) to `recommend()`'s signature.
When `True`, additionally excludes any candidate sharing a `series_id`
OR an `author` string with ANY already-rated book (any sign, not just
loved/liked -- the point is "the reader has direct experience with this
series/author already," which explains the match either way).
Deliberately a MANUAL, explicit opt-in the caller must pass every time,
never a smarter default -- recommending the next book of a series a
user loves is genuinely useful, not a bug, for a real end user; it only
becomes noise for the specific task of auditing whether the algorithm's
DNA-based matching generalizes, which is what this flag is for.

Verified on Mathias's real profile: default top-10 includes Wind and
Truth (Sanderson) and The Shadow of the Gods (excluded too, correctly
-- he's also rated Malice, a different John Gwynne series, confirming
the author-level exclusion works across series by the same author, not
just within one series). `discovery_only=True` removes both and
promotes Jade City, The City of Brass, and Wizard's First Rule into the
top 10 instead, all previously ranked just below the cutoff. Reran the
full `scoring_tests.py` suite after adding the parameter (default
unchanged): zero regressions, identical output modulo the same
pre-existing tie-ordering nondeterminism noted above.

## Author-gender correlation -- checked, confounded, not built (2026-09-03)

Repo owner's hypothesis: "I feel like I respond less positively to
books by female authors." Checked directly against his 86 real ratings
(classified each of his 35 rated authors' publicly-known gender by
hand -- all public professional authors, not private individuals).
Raw numbers: female-authored books (7 authors, 11 ratings) average
magnitude **-0.227** (between it_was_okay and disliked); male-authored
(28 authors, 75 ratings) average **+0.593** (between liked and loved).
A real, large-looking gap on its face.

**But it doesn't survive decomposition -- it's confounded by two
mechanisms this project already tracks and has independently
validated.** Of the 7 negative-magnitude female-authored ratings, 5 are
`person: first` (Circe, Interview with the Vampire, Royal Assassin,
Assassin's Apprentice, Assassin's Quest) -- his single most
statistically validated dealbreaker field, separation 0.692, landed
weeks before this check. The other 2 (The Poppy War, The Dragon
Republic) are both `message_intensity: heavy_handed` -- the exact,
already-documented, independently-corroborated (by a friend who read
the same author's Babel) issue from the 2026-09-02 enjoyment-vs-quality
rating correction. Meanwhile every POSITIVE female-authored rating
(Six of Crows, Crooked Kingdom, The Time Traveler's Wife) is
third-limited or first-but-not-heavy-handed, fast/medium pace --
unremarkable, ordinary matches to his general profile.

**Not built as a field.** Two independent reasons, not just "small
sample": (1) statistically, once you condition on `person` and
`message_intensity`, there's no residual gender signal left to explain
-- an author-gender field would be redundant with mechanisms already
in the schema, not a new source of predictive power; (2) by design,
this schema targets the actual TEXTUAL/structural mechanism driving a
reaction (person, pace, message intensity, darkness...), not a
demographic proxy for it -- even where a demographic correlation is
real on its face, the mechanism-based fields already explain it more
precisely and without the risk of a spurious/confounded signal
generalizing badly to a female author who doesn't write first-person
or heavy-handed books. `n=11` for female-authored ratings is also
genuinely small; revisit if a much larger, still-unexplained gap
appears once his history grows via the learning-curve work below.

## Learning curve: accuracy vs. rating-history size -- added (2026-09-03)

Repo owner's own question: "maybe if we add more books to my list we
could improve it more... maybe we could correlate the level of accuracy
with the history size." Added `run_learning_curve()`/
`print_learning_curve()` to `scripts/scoring_tests.py` (wired into
`run_all()` as Scenario 10) -- for a range of training-set sizes, draws
15 random subsets of that size from Mathias's real ratings (excluding
`REAL_HELD_OUT`, which stays fixed across every point so every size is
judged against the exact same 11-book test), trains a profile on each,
and averages pairwise/bucket accuracy across the repeats. Deterministic
(seeded RNG) so the curve is reproducible run to run.

Result, current data (86 ratings total, 75 available for training after
excluding the fixed held-out set):

| Train size | Pairwise acc. | Bucket acc. |
|---|---|---|
| 10 | 63% | 32% |
| 22 | 65% | 35% |
| 34 | 68% | 42% |
| 46 | 72% | 52% |
| 58 | 72% | 63% |
| 70 | 73% | 68% |
| 75 (full, 1 draw) | 69% | 64% |

**Clear, real answer: yes, more ratings help, substantially.** Bucket
accuracy roughly DOUBLES from 32% at 10 ratings to 68% at 70 -- the
single biggest lever this project has found for prediction quality,
bigger than any individual scoring-formula change tried this session.
Pairwise accuracy also improves (63%->73%) but visibly plateaus earlier,
around 45-60 ratings -- consistent with pairwise accuracy already being
a more forgiving, higher-power metric even at small sample sizes (see
its own docstring). The `n=1` final row (no repeats possible at the
full pool size) is noisier than the rest of the curve by construction
and shouldn't be read as a real dip.

Diversity-of-history (the other half of the repo owner's question --
not just count, but how varied the rated books are) is NOT measured
here yet -- this only varies sample SIZE via random draws from his
existing pool, which already has whatever diversity his real reading
history has. A real diversity metric would need a second axis (e.g.
re-running at fixed size but deliberately narrow vs. broad genre/author
mixes) -- flagged as a natural follow-up, not built this round.

## Diversity curve: does author VARIETY matter, independent of count? (2026-09-03)

The follow-up the size-only learning curve above couldn't answer.
Added `run_diversity_curve()`/`print_diversity_curve()` (Scenario 11 in
`run_all()`): fixes training size at 40 (a mid-curve point from
Scenario 10, chosen so there's real room for both narrow and broad
author mixes to occur naturally), draws 40 random size-40 subsets, and
for each records how many DISTINCT authors happened to land in that
draw alongside its held-out pairwise/bucket accuracy -- isolating
variety as the thing measured, size held constant.

**Result: a real but weak, NOT robust signal, clearly secondary to raw
size.** At seed=7: Pearson r = +0.143 (pairwise) / +0.351 (bucket);
tercile breakdown shows bucket accuracy climbing 44%->52% from
low-diversity (18-20 authors) to high-diversity (22-25 authors) draws.
But rerunning at two more seeds (99, 123) gave r = +0.040/+0.103 and
+0.336/+0.299 respectively -- always positive in direction, but
bouncing between "negligible" and "moderate" in magnitude, meaning 40
samples isn't enough to pin down a stable effect size yet. Likely
cause: his real author distribution is heavily skewed (Sanderson alone
is 20 of his 86 ratings), so a random size-40 draw can only naturally
range across roughly 17-25 distinct authors -- not nearly wide enough
a spread to cleanly separate a real diversity effect from sampling
noise with this few repeats.

**Honest conclusion**: volume (Scenario 10, 32%->68% bucket accuracy
from 10->70 ratings) is the dominant, clearly-established lever.
Variety looks like it helps too, modestly, but the current evidence
is too noisy to put a real number on it or treat it as landed. Worth
rerunning once his rating history both grows in size AND gains real
new authors (the remembered-books batch ingested 2026-09-03 adds
~15-20 new authors at once) -- both effects should show up together
in a rerun, and a bigger total pool would also allow deliberately
stratified sampling (force a "min N distinct authors" vs "max N"
draw) instead of relying on natural random variance, a real
follow-up if this remains a live question.

**Repo owner's explicit call (2026-09-03)**: leave this deliberately
open-ended rather than chase a firmer number now -- rerun once the
newly-ingested batch above is tagged and contributes real new
authors/data, not before. `run_diversity_curve()` stays in the suite
as-is (Scenario 11), ready to rerun then.

## Would validation even detect a new field before we tag it? (2026-09-03)

Repo owner's own proposal, in response to the `message_themes` idea:
"give values like v,w,x,y,z... to books and perform tests to see if
anything moves." Genuinely two different questions hiding in that one
suggestion, and only one of them is answerable with pure random labels:

1. **False-positive risk**: does `STAT_SEPARATION_THRESHOLD` (0.65)
   ever validate pure noise? Answerable with random labels, exactly as
   proposed.
2. **Detection power**: if a field's real-world effect is genuinely as
   strong as this user's one confirmed real dealbreaker (`person`,
   separation 0.692), would the current machinery actually catch it,
   or would his current small disliked-book count let a real signal
   slip through as noise? **Not answerable with random labels** --
   noise has no true effect by construction, so a random-label test
   can only ever confirm the absence of a false alarm, never the
   presence of real detection capability. Needs a KNOWN planted effect
   to check detection against.

Built `simulate_field_validation()` (question 1) and
`simulate_detection_power()` (question 2) in `scripts/scoring_tests.py`
-- both inject a fake nominal field into a copy of the real catalog
(never touches the DB) and reuse `R._nominal_field_separation()`
directly, so they test the EXACT real validation statistic, not an
approximation of it.

**Question 1 result**: 0.00% false-positive rate across 3000 trials,
both at 2-value (boolean-style, the noisiest realistic case) and
5-value fictional labels, on his real 86-book tagged/rated pool
(63 liked, 15 disliked). Max |separation| ever seen by chance: 0.537
(2-value) / 0.381 (5-value), both comfortably below the 0.65 bar.
Confirms the validation machinery doesn't spuriously fire on noise at
his CURRENT full sample size -- consistent with, not a surprise given,
the multiple-comparisons regression this project already found and
fixed once at a SMALLER sample size (the sparse-scenario STAT_
SEPARATION_THRESHOLD incident). Worth re-running this exact check at a
smaller probe-sized subsample before trusting any small-batch tagging
result specifically (a 15-30 book probe showed a real, non-trivial
0.5-1.3% false-positive rate in an earlier ad-hoc version of this
check -- not zero the way the full sample is).

**Question 2 result -- the actually decision-relevant one**:

| True separation planted | Detection rate |
|---|---|
| 0.50 | 10% |
| 0.65 (current threshold) | 52% |
| 0.70 (~matches `person`) | 70% |
| 0.80 | 95% |
| 0.90 | 100% |

Even a real effect AS STRONG as this user's single best-known real
dealbreaker (`person`, 0.692) would only be caught roughly 70% of the
time -- not because of anything about `message_themes` specifically,
but because his DISLIKED/HATED pool is small (only 15 rated-and-tagged
books) and that's the side the separation statistic's noise is
dominated by (liked=63 contributes comparatively little variance).
This is a structural constraint on validating ANY new dealbreaker-style
field for this user right now, not specific to message themes -- it
would apply identically to protagonist gender or any other backlog
idea. The threshold (0.65) was deliberately set close to `person`'s own
observed value (see its own landing note), so by construction any OTHER
real signal of similar strength faces similarly uncertain detection --
this isn't a flaw in 0.65, it's an honest reflection of how thin the
disliked-side evidence currently is.

**Conclusion**: a message_themes tagging probe is still worth trying if
the repo owner wants to (a real, larger effect -- 0.8+ -- would likely
be caught), but the SINGLE biggest lever for making this AND any future
dealbreaker-style validation more reliable is more disliked/hated
ratings specifically, not more liked ones and not more total books.
Directly reinforces the learning-curve finding above from a different
angle: it's not just "more data helps accuracy in general," it's "the
disliked/hated side specifically is the bottleneck for detecting real
per-user dealbreakers at all."

## Repo owner's 10-hypothesis structural review (2026-09-04)

The repo owner reviewed a full qualitative recommendation output plus
the score-audit tool's output against his real reading history and
wrote a detailed, 10-point structural critique, explicitly asking for
each to be classified (genuinely present / partially present / already
handled / unsupported / a data limitation rather than an algorithm
problem) BEFORE any scoring change, and smallest-principled-change
proposals rather than immediate fixes. Full real numbers below; see the
conversation itself for the complete per-hypothesis writeup.

**#1 (frequency vs. discriminative preference)**: unsupported as
literally stated -- `build_profile()`'s weights are already a real
discriminative statistic (`|liked_mean - disliked_mean|`), verified
exactly matching deduped separation for every flagged field (person,
emotional_register, emotional_resolution, violence_intensity, darkness,
prose_density, worldbuilding_density, form). But checking pairwise
correlation among the flagged fields across all rated books found a
real redundancy: `darkness`/`violence_intensity`/`emotional_register`
correlate at r=0.48-0.71 (a genuine shared "how dark/intense" latent
dimension), while `prose_density`/`worldbuilding_density` are
independent (r near 0). Reframes the actual problem as undetected
field-group redundancy, not miscalibrated individual weights.

**#2 (series clustering)**: partially handled. `_series_deduped()`
already exists (2026-09-01) and IS applied inside `build_profile()` --
confirmed its real weights exactly match cluster-deduped separation,
not raw. Not applied to `validated_dealbreaker_fields()`,
`cold_start_weight()`, or the score-audit tool's own reporting, all of
which consume raw `id_to_magnitude` directly. Concretely: person's raw
separation is 0.467 vs. 0.356 deduped (~24% inflation) in the
validation path specifically. Doesn't currently change any real outcome
(neither number clears 0.65), but is a real, fixable inconsistency.
Raw liked pool: 86 books -> 40 independent clusters; disliked: 20 -> 17.

**#3 (accumulation/dilution)**: genuinely present, this project's own
long-documented unsolved problem. Daughter of No Worlds is the cleanest
live example: a real, correctly-detected `person` mismatch (-0.302)
gets outvoted by 4-5 correlated matches (emotional_register,
violence_intensity, emotional_resolution, darkness, war_story), landing
at 0.771 ("Strong match") anyway -- compounded by #1's redundancy
finding, since some of those "5 votes" are substantially 2 independent
signals wearing 3-5 different field names.

**#4 (feature interactions)**: genuinely present, architectural.
`score_book()` is a pure linear model, zero cross-terms -- cannot
represent "A is great with B but bad with C" by construction. Real, but
flagged as genuinely risky to fix at ~100 ratings (real overfitting
risk estimating interaction terms with this little data).

**#5 (romance)**: confirmed, not a scoring bug. `romance_heat_frequency`/
`romance_heat_intensity` weights are negligible (0.004, 0.067) -- no
learned romance-aversion exists. Schema genuinely can't represent
"narrative centrality" vs. "explicitness," which is the repo owner's
actual axis. **Action taken**: added `romance_driven` to `drive`'s
enum (`20260904000000_add_romance_driven_to_drive_field.sql`) for
narrative centrality specifically -- same precedent as
`worldbuilding_driven`'s earlier addition to the same field. Logged the
harder "tone/melodrama/execution quality" axis to book-dna.md's backlog
with the same validation-probe treatment as `message_themes`,
explicitly because the repo owner himself flagged having no real
negative training data for it yet -- a DNA gap AND an evidence gap,
needing different fixes.

**#6**: a framing distinction, not an independent technical claim --
addressed via #9's specific cases.

**#7 (dates)**: confirmed, total gap -- zero temporal data existed
anywhere. **Action taken**: added optional `rated_dates` (sibling to
`ratings`, same title keys, ISO date or coarser, never inferred) to all
4 rater JSON files' schema (currently empty everywhere -- nothing
invents a date). Nothing reads this yet. Standing rule recorded in
`data/ratings/README.md`: any future date-aware feature MUST be tested
both with and without dates present, per the repo owner's own explicit
requirement -- a real user population will always include raters who
can't or won't supply them, so "works without dates" is a permanent
constraint, not a temporary bootstrapping concern.

**#8 (contrastive pairs)**: genuinely present opportunity, generalized
into a permanent tool (`find_contrastive_pairs()`/
`check_contrastive_pair_ranking()`/`run_contrastive_pairs_diagnostic()`,
Scenario 12 in `run_all()`) -- NOT hardcoded to any specific books,
works automatically on any rater's data via `book_similarity()` (high
DNA similarity + large rating gap). Results across all 4 real raters:
- **Mathias**: The Grey Bastards (loved) vs. The True Bastards (hated),
  similarity 0.859, differing only on `drive` + 2 tropes. Held-out
  test: model gets the ranking BACKWARDS (0.6965 vs. 0.7041) --
  strong evidence the real differentiator (very plausibly the
  protagonist-identity change between books, Jackal to Fetching) isn't
  represented in the schema at all, not a weighting bug.
- **Osnat**: Magic Bites (liked) vs. Magic Burns (hated), similarity
  0.905, ZERO field differences (only trope differences). Same failure
  mode, confirms this isn't Mathias-specific.
- **Dandan**: 17 pairs found (mostly Wheel of Time, expected given the
  series' length) -- 15/17 (88%) correctly ranked, real DNA differences
  found and used correctly in most cases (pace_shape, violence,
  personal_stakes shifts). Contrast with Mathias/Osnat's 0/1 -- when
  real DNA signal exists, the model uses it; when it doesn't, it can't.
- A separate, real, already-diagnosed contrast: The Name of the Wind
  (it_was_okay) vs. The Wise Man's Fear (hated) -- real DNA differences
  (pace_shape, personal_stakes, book 2 ADDS `monster_or_fae_romance`/
  `slow_burn_romance` tropes) -- model correctly ranks 0.634 vs. 0.426.

**#9 (specific books)**: 1Q84's mismatches are genuinely
`prose_density`/`overall_pace`, exactly as the repo owner suspected --
not a false positive, Hard-Boiled Wonderland (loved) is real supporting
evidence. Rage of Dragons (0.814, #8 of 20 fantasy) scores via the same
correlated bundle as everything else -- the "should score even better
for the SPECIFIC revenge+momentum combination" intuition is real but is
the interaction-modeling gap (#4), not missing evidence. From Blood and
Ash/Daughter of No Worlds/House of Earth and Blood all score via the
same bundle; Daughter of No Worlds is the cleanest #3 case (real
`person` mismatch, outvoted anyway).

**#10 (dealbreaker semantics)**: verified, and surfaced a real,
previously-undocumented state change: `validated_dealbreaker_fields()`
currently returns an EMPTY SET for Mathias (was `{'person'}` earlier
this session) -- person's separation dropped 0.692 -> 0.467 as his
rated-and-tagged pool roughly doubled (86->106+, several newly-tagged
disliked books sharing `person: third_limited`). Since nothing clears
0.65 now, the veto can never fire, so `dealbreaker_flags()` falls back
to its noisier fixed-threshold mode -- explaining the "flags fired,
veto no change" pattern the repo owner's own audit output showed. This
is the system working exactly as designed (the veto deliberately never
acts on unvalidated fixed-threshold evidence), not a bug -- but the
veto/cap safety net built and tuned earlier this session is currently
INACTIVE for his real profile, a real and consequential fact nobody had
noticed until this review.

## Group-redundancy discount -- tested, REVERTED (2026-09-04)

Direct test of the #1/#3 finding above: built
`score_book_with_group_redundancy()` (experimental variant of
`score_book()`) discounting all-but-the-strongest member of
`REDUNDANCY_GROUPS = [("darkness", "violence_intensity",
"emotional_register")]` by 50%, but ONLY when 2+ members already clear
the same 0.15 significance floor `score_book()` itself uses for a
SPECIFIC candidate -- conditional on the book being scored, never a
blanket adjustment, per this project's own standing rule (see the
2026-08-29 structural-field-boost rejection).

A/B tested via a monkey-patched `_full_score` against the full real
benchmark suite (all 4 raters) plus the WEIGHT_CAP_RATINGS domination
scenario. Result: **zero regressions in "Mathias -- full", "Mathias --
sparse", "Mathias -- series-isolated", and the domination scenario**
(byte-identical output) -- but a **real regression in "Mathias --
author-isolated"**: bucket accuracy 73%->64%, loved_recall 80%->60%.
Rhythm of War flips from correctly-matched to a miss.

**Root cause, checked directly, is a genuine conceptual flaw in the
design, not a parameter to retune**: for Rhythm of War, `darkness`
(sim=0.987) and `violence_intensity` (sim=0.98) are BOTH independently,
genuinely true -- the book really is extremely dark AND extremely
violent, not "one fact counted twice." The discount conflates
POPULATION-level field correlation (a real, measured fact about how
these fields covary across the rated corpus) with INDIVIDUAL-candidate
redundancy (whether matching both fields for THIS book is over-counted
evidence) -- but a candidate that genuinely, independently confirms two
correlated traits at once is providing real double-confirmation, not
inflated evidence. Population correlation doesn't imply per-candidate
redundancy; this design assumed it did.

**REVERTED** in full (`score_book_with_group_redundancy()`,
`_full_score_group_redundancy()`, `REDUNDANCY_GROUPS` constants all
removed from `scripts/recommend.py`/`scripts/scoring_tests.py`) rather
than left half-built, same precedent as the positive-floor experiment.
The underlying #1/#3 finding (real field correlation exists and
plausibly inflates some scores) remains open and unsolved -- a real fix
would need a genuinely different mechanism than "discount when
population-correlated fields agree for this candidate," since that
specific mechanism is now shown not to work. Worth revisiting with a
design that distinguishes "these fields are correlated in general" from
"this candidate's agreement on both is redundant specifically" -- not
obviously the same test, and this experiment conflated them.

## Series DNA / dedup integration -- investigated, not built (2026-09-04)

Repo owner asked whether `compute_series_dna()` (the existing
trajectory-aggregation feature) could inform smarter series
deduplication. Confirmed: it's currently used ONLY inside
`explain_match()` for the human-readable trajectory caveat text --
zero connection to `_series_deduped()`/`build_profile()`/any
weight-learning path. A real, well-motivated idea: `_series_deduped()`
currently treats every series-mate as equally redundant with every
other on EVERY field, but `compute_series_dna()` already knows, per
field, whether a series is `stable` or genuinely drifts across its run
-- a field that drifts isn't actually redundant evidence the way a
stable one is. Not built: this would require per-FIELD-conditional
deduplication inside `build_profile()`'s core loop (changing dedup
granularity from "book" to "book-field pair"), a bigger, riskier change
to core scoring math than the plain validation-path consistency fix,
deserving its own dedicated design-and-test pass. Logged as a real,
scoped follow-up, not built this round.

## Series-trajectory penalty -- tested and LANDED (2026-09-04)

Repo owner's own design, refined after two real examples (The Warded
Man -- loved books 1-3, book 4 "ruined the series" for him; The Pariah
-- didn't click until partway into book 1). Negative-only: a series
entry point that scores well now, whose SAME strong-matching fields
trend AWAY from the user's profile by the series' end (per
`compute_series_dna()`'s existing trajectories), gets its score capped
down -- never boosted, mirroring the earlier positive-floor finding
that boosting can't safely reorder things and avoids "undersells
itself" disappointment. Explicit exclusion, per the repo owner's own
caveat: skipped entirely when `narrative_closure: self_contained`
(The Lies of Locke Lamora, the Dresden Files' early entries) -- a
complete, satisfying standalone shouldn't be penalized for what a
later, loosely-connected sequel does. Verified against real data before
building: Locke Lamora and Storm Front are indeed tagged
`self_contained`, The Warded Man `requires_series`.

**First version had a real bug, caught by testing**: applied the
penalty to EVERY series book scored directly, not just entry points --
Rhythm of War (WoT book 4) and A Clash of Kings (ASOIAF book 2) both
got penalized using a "series start vs. end" comparison that only
makes sense for a book that IS the start. Produced badly inflated,
broad damage in the real benchmark (Mathias sparse loved_recall
75%->25%, Osnat series-isolated pairwise 61%->44%). **Fixed** by
gating on `book.position_in_series == min(series' tagged positions)`
-- only the actual entry point is ever penalized.

**After the fix: a clean, real improvement, zero regressions anywhere**
(all 4 raters, plus the WEIGHT_CAP_RATINGS domination scenario,
byte-identical where unaffected):
- Mathias full: bucket 82%->91%, pairwise 84%->89%, hated_rejection
  80%->100%.
- Mathias series-isolated: bucket 64%->73%, pairwise 73%->78%,
  hated_rejection 60%->80%.
- Mathias author-isolated: pairwise 76%->78%.
- Skyward flips from a MISS to correctly-ranked in 3 separate
  scenarios (held-out full, author-isolated, series-isolated).
- Every other row (sparse, Osnat both rows, Dandan) byte-identical.

**Verified the exclusion and the mechanism directly**: Locke Lamora and
Storm Front get `penalty_factor=1.000` (untouched, confirming the
exclusion works); Skyward gets `0.955` (a real, modest ~4.5% discount,
enough to flip 3 held-out labels). Honest finding on The Warded Man
itself: `penalty_factor=1.000` -- it does NOT fire on the repo owner's
own original motivating example, because its tagged DNA trajectory
doesn't cross the current divergence threshold. Plausible explanation,
not confirmed: what "ruined it" for him may be more about narrative
EXECUTION/ending satisfaction than a measurable content-field shift --
the same "DNA gap vs. quality judgment" theme found elsewhere this
session, not something any DNA-based mechanism can fully capture.

**LANDED**: wired into `recommend()`, `explain_match()`, and
`audit_book_score()`'s real pipeline (after the veto, before the
cold-start blend), and merged into `scoring_tests.py`'s real
`_full_score()` (the separate experimental variant removed). `SERIES_
TRAJECTORY_DIVERGENCE_THRESHOLD=0.15`, `SERIES_TRAJECTORY_MAX_PENALTY=
0.3` -- picked as reasonable starting points, not exhaustively swept;
revisit if real use surfaces either as miscalibrated.

## Per-value nominal weight learning -- tested, SAFE but UNPROVEN, not yet merged (2026-09-04)

Direct test of the architectural finding from the `drive`/
`romance_driven` pushback: `build_profile_per_value()`/
`score_book_per_value()`/`explain_book_per_value()` built as full
parallel implementations (not modifying the real `build_profile()`/
`score_book()`/`explain_book()` in place). NOMINAL fields' values each
get their own `liked_freq - disliked_freq` weight (same formula as
tropes), looked up directly at scoring time -- no similarity-to-mode
calculation. A/B tested by monkeypatching `R.build_profile`,
`R.score_book`, `R.explain_book` (all three needed --
`dealbreaker_flags()`/the veto call `explain_book()` internally, and
its old nominal-similarity branch can't handle a dict-shaped weight)
and rerunning the full suite.

**Result: byte-identical scorecard across every real scenario, all 4
raters** -- zero regressions, but also no measurable benefit shown.
Directly verified this is a genuine null result, not a broken test
pathway: computed real per-value weights directly (`drive:
character_driven = -0.139`, a real negative the old mode-based formula
couldn't see at all; `person: first = -0.262`, `third_limited =
+0.356`) and confirmed `score_book_per_value()` produces genuinely
different raw scores per candidate (City of Stairs: 0.8812 old vs.
0.8608 new) -- the mechanism is real and active, it just doesn't happen
to flip any bucket/pairwise labels in the CURRENT held-out test set.
Fully explained by the same evidence gap already documented:
`romance_driven` (the case that motivated this) has zero occurrences
anywhere in Mathias's rated history, so no test case exists yet where
per-value learning would diverge from mode-based learning in a way
that changes an outcome.

**A real, unresolved tension found, not swept under**: the old
`NOMINAL_PARTIAL_SIMILARITY` mechanism (person's third_limited/
third_omniscient partial credit, tested and landed 2026-09-03) assumed
third_omniscient deserves 50% credit against a third_limited mode. The
new per-value scheme instead computes third_omniscient's OWN weight
from real (sparse) evidence -- currently -0.042 for Mathias, a
genuinely different and weaker number than the old hand-coded 50%
assumption would produce. This is arguably more principled (real
evidence over an assumed relationship) but is a real behavior change
against an already-tested-and-landed fix, not something this
experiment straightforwardly subsumes or preserves -- flagged
honestly, not resolved.

**NOT merged into production.** Genuinely safe (zero regressions) and
architecturally sound, but the benefit can't be demonstrated with
current data, and it touches EVERY nominal field's core scoring math
(a much larger blast radius than the trajectory penalty above), plus
the unresolved tension with the partial-credit fix above. Awaiting a
decision on whether to land now (on architectural merit + safety) or
wait for real per-value-relevant evidence to exist (e.g. once
`romance_driven`-rated books exist) before committing.

## Per-value nominal weight learning -- tried for real, REVERTED (2026-09-04, same day)

The "byte-identical, zero regressions" result above was **wrong**, and
the mistake is itself worth recording since it's a real testing-
methodology gap, not a one-off slip.

After Mathias retagged The Time Traveler's Wife to `drive:
romance_driven` (a real, correct catch on his part -- see
`supabase/migrations/20260904020000_retag_time_travelers_wife_
romance_driven.sql`; the entire novel is Henry and Clare's relationship
across nonlinear time, there's no substantial external plot beyond it)
and asked whether to land per-value weights now, this looked like the
evidence needed to decide yes: `emotional_resolution: happy` now scored
as a real, understood negative contribution instead of diluting toward
neutral (House of Earth and Blood: 0.80 -> 0.67), directly explained
and directly tied to real evidence.

Landed it by reassigning `build_profile = build_profile_per_value` etc.
at the bottom of `recommend.py` (after an earlier, riskier line-splice
attempt corrupted the file and had to be `git checkout`-reverted).
Found and fixed three real compatibility bugs surfaced by the dict-
shaped nominal weights (`fatigue_overrides` handling in
`_resolve_profile()`, a crash in `_series_trajectory_penalty_factor()`,
a silently-dropped `narrative_closure` redundancy discount in both
`score_book_per_value()`/`explain_book_per_value()`'s nominal
branches). Then ran the real, non-monkeypatched suite and got a severe
regression across nearly every scenario: Mathias-full bucket accuracy
91%->73%, pairwise 89%->69%, loved_recall 100%->60%; Dandan-full bucket
71%->29%. Old Man's War (liked, held out) alone: 0.561 -> 0.179.

This directly contradicted the "byte-identical" finding above, which
prompted elimination testing (ruled out: the reassignment mechanism
itself, the trajectory penalty, the Time Traveler's Wife retag, the
`score_book` redundancy-discount fix) before finding the actual
explanation, which was upstream of all of it:

**The original A/B test never actually exercised per-value scoring.**
It monkeypatched names on `scripts.recommend` (`import scripts.recommend
as R; R.build_profile = R.build_profile_per_value`), then called into
`scripts/scoring_tests.py`. But `scoring_tests.py` internally does
`sys.path.insert(0, ...); import recommend as R` -- importing the SAME
FILE under a DIFFERENT `sys.modules` key (`recommend`, not
`scripts.recommend`). Python caches these as two distinct module
objects, each with its own independent copy of every top-level name.
Confirmed directly:

```python
import scripts.recommend as R1
import sys; sys.path.insert(0, 'scripts')
import recommend as R2
R1 is R2   # False
```

The monkeypatch modified `R1`'s `build_profile` attribute; every real
call inside `scoring_tests.py` reads `R2`'s. The "zero regressions"
result was real -- it's just that it was measuring unmodified
mode-based scoring against itself the whole time. The trajectory-
penalty experiment earlier this session did NOT have this flaw, because
that one was tested by editing `_full_score()` inside
`scoring_tests.py` directly (adding a real call to
`R._apply_series_trajectory_penalty`), not by external monkeypatching
of a same-named-but-different module object.

**Reverted.** `build_profile`/`score_book`/`explain_book` are back to
the original mode-based implementations; `build_profile_per_value()`/
`score_book_per_value()`/`explain_book_per_value()` stay in
`recommend.py` as a real, working, un-landed reference (with the three
compatibility fixes above still applied to them, so they're usable
as-is for a future, correctly-designed test). Full suite reconfirmed
back at the known-good baseline (Mathias full 91%/89%/100%/100%) after
reverting.

**Lesson, now a standing testing rule for this repo**: when A/B testing
via monkeypatch against `scoring_tests.py`, verify the patch lands on
the SAME module object `scoring_tests.py` actually calls (`import
scripts.recommend as R; import scripts.scoring_tests as T; R is T.R`
should be `True`) before trusting any "same/different numbers"
conclusion. Don't infer that a patch took effect just because the
before/after numbers look plausible either way.

**Net answer to "should we land per-value nominal weights now?": no.**
The one real test that actually exercised the mechanism against the
full benchmark showed a severe regression whose root cause was never
identified (elimination testing ruled out the obvious candidates but
didn't isolate the real one before the "was this even a valid finding"
question took priority). Landing requires: (a) a valid test (edit
`scoring_tests.py`'s `_full_score()` directly, or verify module
identity before monkeypatching), (b) actually finding why per-value
scoring tanks Old Man's War and similar books, not just reverting past
the symptom.

## Series-dedup consistency fix -- LANDED (2026-09-05)

The 10-hypothesis review's #2 finding (`validated_dealbreaker_fields()`,
`cold_start_weight()`, and the score-audit tool's own reporting all
consume raw `id_to_magnitude` directly, unlike `build_profile()` which
already deduplicates series-mates before computing weights) was left as
a "real, fixable inconsistency" pending a decision. Fixed directly:
added `_series_deduped_id_to_magnitude()` (the id_to_magnitude-keyed
analog of `_series_deduped()`'s weight-splitting, for the three
separation-statistic consumers) and `_n_independent_clusters()` (the
count-shaped analog for `cold_start_weight()`'s own `n`, since
magnitude-splitting doesn't change a dict's length the way it changes
weights -- these needed genuinely different fixes, not the same helper
applied twice). All three call sites (`validated_dealbreaker_fields()`,
`cold_start_weight()`, `audit_book_score()`'s own display helpers)
dedupe internally now, self-contained regardless of caller. Full
benchmark suite: zero regressions, byte-identical scorecard.

## Permutation-based adaptive dealbreaker threshold -- tried, REVERTED (2026-09-05)

Direct follow-up to the fix above and the 10-hypothesis review's #10
finding: `STAT_SEPARATION_THRESHOLD`'s fixed 0.65 had itself gone stale
as Mathias's rated pool grew past where it was calibrated -- `person`'s
separation drifted from 0.75-0.82 (when 0.65 was picked) down to 0.412,
silently disabling `validated_dealbreaker_fields()` (returns an empty
set) and therefore the whole veto mechanism for his profile, unnoticed
until that review.

Replaced the fixed magnitude with a permutation significance test:
`STAT_SEPARATION_THRESHOLD` demoted to a cheap 0.3 pre-filter (skip
permutation-testing obviously-dead candidates), real validation via
`_permutation_p_value()` (empirical p-value from 200 label-shuffled
trials) gated at `alpha=0.05` Bonferroni-corrected by however many
candidates actually got tested for that user (`alpha / n_candidates`)
-- genuinely adaptive to both sample size and how many fields/tropes
are in play, rather than a number picked once and left to go stale.

Result for Mathias: `person` (p=0.001), `emotional_resolution`
(p=0.002), `worldbuilding_density` (p=0.002), and `prose_density`
(p=0.002, negative direction) all validated -- `pov_count` cleared the
0.3 pre-filter (0.322) but correctly failed significance, consistent
with its known correlation with `person`. Runtime: 0.06s, no
performance concern.

Full benchmark suite: **real regression**. Mathias-full bucket accuracy
91%->82%, loved_recall 100%->80%; Mathias-series-isolated bucket
73%->64%, loved_recall 80%->60%. Root cause, checked directly via
`audit_book_score()`: Old Man's War (true=liked) now gets vetoed by a
`person` mismatch (0.251, above the newly-lower
`VALIDATED_DEALBREAKER_MAGNITUDE` bar of 0.15) -- a real, individual
exception to an otherwise genuinely strong, statistically robust
pattern (Mathias generally dislikes first-person books; this is one
real counter-example). Every other held-out book that the veto now
also fires on (The Wise Man's Fear, Royal Assassin, Skyward, Interview
with the Vampire, Assassin's Quest) was ALREADY correctly labeled
"Poor match" without the veto, so reactivating it bought zero new
correct catches while costing this one book -- a clean net negative on
the only real benchmark available, not a marginal wash.

**Not a bug in the permutation test itself** -- `person`'s p=0.001 is
about as statistically unambiguous as this kind of test produces;
tightening the correction further to exclude it would mean suppressing
a genuinely real, strong signal specifically to dodge one legitimate
exception, which defeats the point of a dealbreaker mechanism at all.
This is the same "a trope aversion should lower a score, not
disqualify a book" tension the schema doc already names -- restoring a
CORRECTLY-validated veto has a real, inherent false-positive cost on
individual exceptions, no threshold tuning removes that cost, it can
only be traded off. On the one dataset available, the trade nets
negative right now.

**Reverted in full** (`_permutation_p_value()`, `PERMUTATION_TRIALS`,
`PERMUTATION_ALPHA`, `_PERMUTATION_SEED` all removed;
`STAT_SEPARATION_THRESHOLD` restored to 0.65;
`validated_dealbreaker_fields()` restored to the plain magnitude
check) rather than left half-built, same precedent as the positive-floor
and group-redundancy-discount experiments. The series-dedup fix above
is unaffected and stays landed -- it was tested independently and is
clean on its own.

**Open for whoever revisits this**: the underlying problem (a
fixed-pool-size-calibrated constant going stale as real data
accumulates) is real and will recur -- `person`'s separation will keep
drifting as more books get rated, and 0.65 is exactly as arbitrary
going forward as it was when first picked. A future attempt needs
either (a) a second rater whose data can show whether the Old-Man's-War-
style cost is typical or a one-off, since a single rater's single
exception isn't enough to judge a general mechanism by, or (b) a
design that keeps the field validated but softens the veto's magnitude
threshold specifically for borderline mismatches (Old Man's War's 0.251
sits well below the un-validated fallback bar of 0.3) rather than
inheriting the full lower validated-field bar of 0.15 automatically.

## Execution-DNA validation probe (protagonist competence/narrative favoritism) -- tried, structurally UNTESTABLE, reverted (2026-09-05)

Direct follow-up to the friend-sourced Book DNA field review earlier
tonight: repo owner asked to encode the highest-potential "execution
DNA" concepts as tropes (per this project's own per-value-nominal-
weight-learning limitation -- tropes already get real per-value
learning, scalar nominal fields don't yet), tag a small deliberately
contrastive validation set first, and apply/dismiss based on whether it
actually helps.

Added `protagonist_undermined_or_diminished` and
`narrative_favoritism_between_co_leads` as tropes, tagged ONLY on The
True Bastards (the one book with a real, specific account of this
pattern -- Jackal repeatedly loses and needs rescue by Fetching, who
reads as narratively favored despite not being competent) -- Grey
Bastards deliberately untagged (book 1's arc is straightforward earned
growth). This is the exact pair `docs/scoring-test-protocol.md`'s
10-hypothesis review #8 already flagged as a confirmed model failure
(scored backwards: True Bastards 0.7367 vs. Grey Bastards 0.7268,
hated outscoring loved).

**Result: the new tropes learned NO weight in the held-out test and
changed nothing (scores identical to 3+ decimals).** Root cause isn't a
bug -- it's a hard structural fact about held-out testing: True
Bastards is the ONLY book in Mathias's entire rated history carrying
this trope, and it's also the book being predicted in this exact test.
`build_profile()`'s trope weight is `liked_freq - disliked_freq` over
the TRAINING pool only -- with the sole real-world instance excluded
from training (because it's the held-out target), the trope has zero
training-set presence and therefore zero learnable weight, regardless
of how real the underlying pattern is. Confirmed the tagging mechanism
itself works correctly by a separate sanity check: with True Bastards
included in the FULL (non-held-out) training pool, both tropes learn a
real, sensibly-signed weight (-0.08 each).

This is the same ceiling already documented in "Would validation even
detect a new field before we tag it?" (2026-09-03) -- that entry was
about STATISTICAL detection power for dealbreaker validation
specifically; this is the more basic version of the same problem,
applying to plain weight-learning: **a brand-new trope whose only
known real-world evidence IS the held-out test case can never be
validated by leave-one-out, no matter how real the pattern is.**
Structurally identical to why `message_themes`/`protagonist
competence` were originally flagged "needs more than one account
before committing to vocabulary" rather than built speculatively --
this is that exact prediction, now empirically confirmed rather than
just anticipated.

Checked whether any of the OTHER backlog "execution DNA" concepts
(`humor_flavor`, `romance_tone`, earnest/ironic tone, worldbuilding
delivery, consequences/permanence) have enough real contrastive
evidence across any of the 4 real raters to test at all, before
building any of them speculatively: **none do.** Concretely checked
`humor_flavor`'s best real-world test case (Terry Pratchett/Discworld,
famously dry/witty voice) -- zero Pratchett titles rated by any of the
4 raters despite ~30 Discworld books in the catalog. `romance_tone` was
already self-diagnosed by the repo owner as lacking negative training
examples. No new tagging attempted for any of these tonight --
would be tagging on spec with literally nothing to validate against,
the exact anti-pattern this project's "don't add fields just for
completeness" rule exists to prevent.

**Initially reverted in full, then RE-ADDED and kept dormant (same
day, repo owner's own follow-up call).** First reverted (both tropes
and the one tagging instance removed from local DB) on the reasoning
that "if it doesn't help, dismiss" meant remove -- but the repo owner
pushed back correctly: this experiment is genuinely different in kind
from the adaptive-threshold revert above. That one caused an active,
measured regression (a real cost to keeping it). This one is simply
inert -- zero effect in either direction, and the tag itself isn't
wrong, it's a real, accurate fact about the book that just has no
training-set leverage YET. Re-added via
`20260905170000_readd_execution_dna_probe_kept_dormant.sql`,
re-confirmed byte-identical scorecard. Kept as a harmless, dormant data
point rather than deleted -- costs nothing to leave in place, and is
immediately available to start contributing the moment a second
rater's data gives it real training-set presence. Not a decision that
the concept is validated; still just a validation probe, tagged on one
book, awaiting more evidence.

**What would actually unblock this**: a SECOND real account of the
same competence/favoritism pattern, on a different book, so the
trope has training-set presence independent of whatever it's being
used to predict. Same underlying fix as the dealbreaker-detection
ceiling above -- more disliked/hated ratings specifically (not more
total ratings) is the actual lever, generalized here to "more real
examples of any single specific narrative pattern," not a scoring or
tagging fix.

## Standing methodological finding: Goodreads star ratings and Bookspell ratings can measure genuinely different things (2026-09-05)

Surfaced analyzing Mathias's own Goodreads review text: three books
(The Hero of Ages, The Well of Ascension, The Path of Daggers) show
"loved" in `mathias.json` despite 3-star, genuinely critical
contemporaneous Goodreads reviews ("I did not enjoy this book... too
long... not believable and sadly overrated" -- Hero of Ages). Checked
directly with him rather than assuming the discrepancy was an error.

**Confirmed deliberate, not a bug, for two real reasons:**
1. He's since re-experienced the Mistborn trilogy and The Path of
   Daggers via GraphicAudio full-cast productions, and his actual
   enjoyment genuinely improved on re-listen even though his specific
   critiques (pacing, character logic, believability) still stand.
   Critique and enjoyment are separable -- this system tracks
   enjoyment, and a book can be re-experienced differently.
2. More generally and more importantly: **he rated by a different
   criterion on Goodreads (perceived quality) than he does for this
   project (enjoyment)** -- not just occasional conflation (already
   documented, see the Poppy War correction), but a real, standing
   difference in what the NUMBER itself was measuring at the time.

**Consequence for any future Goodreads (or other external-source)
import work**: a contemporaneous star rating is NOT automatically more
trustworthy than a direct enjoyment-based report just because it's
closer in time to the reading experience -- for a rater who used a
different rating criterion on that platform, the two numbers can be
measuring genuinely different axes, and neither one is simply "more
correct." This project's own standing rule (a rater's direct report
outranks an import on conflict, see `data/ratings/README.md`) already
gets this right by default, but the REASONING matters for any future
case: don't assume an import disagreement is necessarily catching an
error in the direct report. Ask, rather than auto-correct.

## Execution-DNA validation probes: romance_tone + worldbuilding delivery -- tried, KEPT (2026-09-05)

Follow-up to the True Bastards probe (structurally untestable, one
instance only). This time real, multi-book contrastive evidence existed
from Mathias's own Goodreads review text -- see docs/project-log.md.

**understated_romance / melodramatic_romance_subplot** (romance_tone,
encoded as two tropes rather than a scalar field): tagged Warbreaker,
Six of Crows, Shadows of Self, The Bands of Mourning, The Lost Metal
(understated, all liked/loved) and The Wise Man's Fear (melodramatic,
hated) + The Well of Ascension (melodramatic, loved overall but a real
documented negative pull, not expected to flip the rating). Both
Warbreaker and The Wise Man's Fear are in the standard held-out set,
but -- unlike True Bastards -- other training-set books still carry
each trope even with those two held out, so this is a genuine
predictive test, not a structurally-empty one.

Weights on the full pool: `understated_romance` +0.045,
`melodramatic_romance_subplot` -0.065 -- both correctly signed. Full
benchmark suite: real, tiny movement in ONE scenario (Mathias,
author-isolated: Rhythm of War flips Good->Mixed, 0.551->0.547).
Checked directly: Rhythm of War carries neither new trope at all --
the shift is a normalization-denominator side effect of adding any new
weighted trope to the profile (the same mechanism, not a targeted
error), identical in kind to the Old Man's War/Dragon Reborn
threshold-crossings already documented and accepted elsewhere in this
project. Every other scenario (Mathias-full/sparse/series-isolated,
all of Osnat/Dandan/Gabriel) is byte-identical. **Kept** -- correctly-
signed real weights, only cost is razor-thin boundary noise on one
already-fragile prediction, no evidence of a targeted problem.

**worldbuilding_woven_into_narrative**: tagged Red Sister/Grey Sister/
Holy Sister (loved, explicit direct quote: "unlike many fantasy books
I've read lately which bombard you with info dumps, here the exposition
is subtle and intriguing... that is basically how I feel about Book of
the Ancestor"). Checked directly for a negative counterpart in his own
rated history (The Way of Kings, The Eye of the World, Words of
Radiance) -- none found, all loved, none flagged for info-dumping.
Real weight computed on the full pool (+0.028, correctly signed) since
3 same-direction examples exist (unlike True Bastards' single
instance), but **one-sided**: with no disliked-side presence, this
trope can currently only ever reinforce an already-positive
prediction, never help catch a dislike. Kept as a real, honest,
moderate-confidence tag (not dismissed) since it's directionally
correct and inert everywhere else -- but flagged as needing a real
negative example before it can be considered validated in the fuller
sense, same open item as the True Bastards probe.

All three tagged at `confidence: 0.6` (not the default unassessed/1.0)
via `book_field_confidence`-adjacent per-trope confidence, per the
repo owner's own explicit framing: apply now using the existing
confidence/source layer rather than treating "tag now" and "wait for
real users" as mutually exclusive -- ready for community tagging to
correct later, not presented as equivalent-confidence to a verified
structural fact.

## Confidence-in-weight-learning gap -- FIXED and tested (2026-09-05)

Real architectural gap found while discussing the two execution-DNA
probes' rollout risk: `get_confidence()` only discounted a field/
trope's contribution at SCORING time (`score_book()`), never at
WEIGHT-LEARNING time (`build_profile()`). Confirmed directly -- none
of the ORDINAL_FIELDS/NOMINAL_FIELDS/tropes weight-computation loops
called `get_confidence()` anywhere. A low-confidence tag on a TRAINING
book contributed to the learned weight at full strength regardless of
its own recorded uncertainty -- meaning confidence only ever protected
against a wrong tag showing up on a CANDIDATE book being scored, never
against a wrong tag corrupting the weight itself during training. This
wasn't hypothetical -- real, non-uniform confidence values already
exist for several HIGH_RISK_FIELDS (person, pov_count, drive,
narrative_closure, romance_heat_intensity, and others) from earlier
manual-review passes, so this gap was already live catalog-wide, not
just relevant to the two new tropes.

Fixed by discounting each contributing book's magnitude by
`get_confidence(book, field_or_trope)` before it counts toward the
weighted mean (ordinal), mode/share computation (nominal), or
liked_freq/disliked_freq (tropes) -- for tropes specifically, only the
per-trope NUMERATOR is discounted; `total_liked_m`/`total_disliked_m`
stay undiscounted since they're a shared normalizer across every
trope, not specific to any one trope's own confidence.

Verified directly: `understated_romance`/`melodramatic_romance_subplot`/
`worldbuilding_woven_into_narrative` (tagged at confidence 0.6) all
shrank in magnitude by roughly the expected ~40% (e.g.
melodramatic_romance_subplot: -0.065 -> -0.039) -- the mechanism works
as designed. Full benchmark suite: byte-identical to the pre-fix
state across all 8 scenarios -- none of the catalog's existing
confidence-override rows happen to land on books in these specific
held-out test cases, so no further movement was exercised here, but
the fix is real and will matter the moment a future test scenario (or
a real user's profile) touches one of the fields/tropes that already
carry non-default confidence.

## Minimum confidence threshold for scoring/weight-learning -- added (2026-09-05)

Repo owner's own design addition, while planning the melodrama/
worldbuilding-delivery research pass: below a floor, a tagged value
shouldn't influence scoring/weight-learning AT ALL, not just be
heavily discounted -- a string of many barely-above-zero contributions
could otherwise still add up to something misleadingly influential.
Distinct from ordinary confidence discounting (a 0.5-confidence tag
still counts at half strength); this is a hard cutoff for "too little
evidence to count as evidence at all yet."

Added `MIN_CONFIDENCE_TO_COUNT = 0.3` and `scoring_confidence()` (a
thin wrapper around `get_confidence()` that floors to 0.0 below the
threshold) -- `get_confidence()` itself stays the raw, undiscounted
accessor for display/audit purposes, never silently zeroed. Wired
`scoring_confidence()` into all 10 real call sites across
`build_profile()`/`score_book()`/`explain_book()` (left the
experimental `_per_value` variants untouched, not in production use).

Checked existing data before picking 0.3: no currently-recorded
confidence value in the catalog sits at or below this floor (lowest
existing entries are 0.4) -- confirmed via the full benchmark suite,
byte-identical to before this change. This doesn't retroactively
invalidate any already-accepted tagging work; it only matters for
future low-confidence tags, e.g. a research pass that turns up little
to no real discourse for a specific book -- exactly the situation the
upcoming melodrama/understated-romance research pass is expected to
hit for some candidates. The row is never deleted for falling below
the floor -- real validation later (raising the recorded confidence)
makes it start counting automatically, no re-tagging needed.

## External review: prevalence/discriminatory-value weighting, oversized trope effects, additive-vs-interaction scoring -- audited, not implemented (2026-09-06)

A friend of the repo owner reviewed a Recommendation Ledger run (top-20
fantasy/sci_fi, "None of: age_category:ya" applied) and raised a
7-point architectural critique: (1) weights should reflect preference
strength × discriminatory/information value × confidence, not
preference strength alone -- conceptually IDF-like, discounting a
field by how common its matching value is in the CANDIDATE pool, not
just the rated pool; (2) audit recurring dominant contributors,
starting with `emotional_resolution`'s near-constant +0.323; (3) add
preference-evidence tracing (which ratings support a weight, how
independent they are); (4) be suspicious of oversized trope effects
built on thin evidence; (5) move toward interaction effects (e.g.
`romance_drive × romance_tone`) since additive scoring lets several
mediocre matches overwhelm one highly predictive mismatch; (6)/(7)
used From Blood and Ash (rank 10, fantasy) and Altered Carbon (rank
16, sci_fi) as diagnostic probes. Explicitly asked to be evaluated
against real data, not hand-tuned toward expected results.

Audited empirically (not implemented) before doing anything else, per
this doc's own standing rule -- checked prior art first, so as not to
re-litigate settled ground:

- **#1's specific mechanism (candidate-pool prevalence discount) is
  new** -- the 2026-09-04 10-hypothesis review tested "frequency vs.
  preference strength" as a claim about the RATED pool and found the
  weight formula already IS a real discriminative statistic
  (`|liked_mean - disliked_mean|`), not a raw frequency count. But
  that review never tested discounting by prevalence in the
  UNRATED CANDIDATE pool, which is what the friend actually proposed.
  Confirmed directly in code (`build_profile()`, recommend.py ~970-1066):
  no ordinal/nominal/trope weight computation anywhere references
  candidate-pool prevalence -- `REDUNDANCY_DISCOUNTS` is the only
  prevalence-adjacent mechanism that exists, and it's two hardcoded
  field pairs, not a general one. The friend's factual claim about the
  mechanism is exactly correct.
- **A near-identical group-redundancy discount was already tried and
  reverted** (2026-09-04, see the entry above from that date) --
  population-level field correlation doesn't imply per-candidate
  redundancy; a genuinely dark+violent book confirming both fields is
  real double-confirmation, not double-counting. Direct warning
  against a naive implementation of #1 -- any prevalence-discount
  experiment needs the same two-scenario discipline this doc already
  requires, not a quick patch.
- **`emotional_resolution: bittersweet` prevalence**: 53.0% of all
  tagged books (437/825), 54.2% of fantasy (287/530) -- a real
  plurality, not the 80-90% the friend guessed. Liked-pool support (86
  of 109 liked books) spans ~40 independent series/standalone
  clusters across 27 authors -- genuinely broad, not one-series-driven.
  10/24 disliked books are ALSO bittersweet (41.7%) -- real separation
  exists but is moderate. Verdict: the weight is a real, non-spurious
  signal; its ranking usefulness IS capped by candidate-pool
  prevalence roughly as claimed, just less extreme than guessed.
- **Trope evidence checked for independence**: `hidden_talent_prodigy`
  (+0.267, sci_fi) rests on only 3 liked books (Ender's Shadow,
  Firestarter, Ender's Game) with ZERO disliked counter-evidence --
  thin. `underdog_rising` (-0.261) has genuinely balanced evidence (5
  liked/4 disliked, independent clusters on both sides) yet still
  swings to 52% of `WEIGHT_CAP` -- the mechanism doesn't shrink toward
  zero for a small-but-balanced sample the way a
  significance-weighted estimate would. Both support #4 directly.
  `revenge` (fantasy) has broad liked support (17 books/~12 clusters)
  but disliked counter-evidence collapses to ONE series (Poppy
  War/Dragon Republic, Kuang) once genre-scoped to fantasy -- Red
  Rising, the friend's other cited disliked-revenge example, is tagged
  sci_fi and drops out of the fantasy-scoped calculation entirely. A
  real, previously-unnoticed side effect of genre-scoping thinning
  evidence independence, not something anyone had caught before.
- **From Blood and Ash (#6 diagnostic)**: sum of positive contributions
  1.892 vs. the single `romance_heat_intensity` mismatch (-0.126) --
  15:1. But the book IS tagged `melodramatic_romance_subplot`
  (confidence 0.2, from this week's romance_tone probe) -- the
  interaction signal the friend hypothesized is missing isn't
  missing from the schema; it's present and deliberately suppressed by
  `MIN_CONFIDENCE_TO_COUNT` (0.3), because this week's own research
  found real reader discourse disputing whether this book's romance
  execution is actually melodramatic ("a perfect slow burn," per
  reviews). This corrects the friend's hypothesis rather than
  confirming it as stated: the real next step here is evidence/
  confidence work on that specific tag, not a new interaction
  mechanism -- the interaction mechanism already exists.
- **Altered Carbon (#7 diagnostic)**: does NOT support the friend's
  suspicion. `person: first` -- 22.0% of liked books (24/109) vs. 50.0%
  of disliked (12/24). `pace_shape: consistent` -- 22.2% of liked
  (4/18) vs. 62.5% of disliked (5/8), across 5 independent authors.
  Both mismatches are backed by real, broad, disproportionate
  representation in the disliked pool -- DNA values and the penalty
  both look correct, not a spurious correlation.

**Follow-up question from the repo owner, resolved by reading the code
directly rather than assumption**: doesn't liking a revenge story in
sci-fi already inform fantasy revenge scoring, and vice versa? Answer:
partially, and the split is real, not a memory of a prior agreement --
`_resolve_profile()`'s own docstring documents it: STRUCTURAL fields
(`STRUCTURAL_ORDINAL_FIELDS`/`STRUCTURAL_NOMINAL_FIELDS` --
`overall_pace`, `worldbuilding_density`, `pov_count`, `person`,
`pace_shape`, `emotional_resolution`, `drive`, and others) are ALREADY
profiled from the rater's FULL cross-genre rating history regardless of
which genre is being scored, exactly the cross-genre-informs-taste
intuition being asked about -- this is why `emotional_resolution`'s
Step 3 audit above found genuinely broad, 40-cluster evidence; it's
drawing on all 143 ratings, not just the fantasy subset. TROPES are
different: `build_profile()`'s trope loop is explicitly, deliberately
"always genre-scoped" (see its own comment) -- a fantasy candidate's
trope weights are learned ONLY from fantasy-tagged rated books. This is
exactly why Red Rising (tagged sci_fi, disliked) dropped out of the
fantasy-scoped `revenge` calculation in Step 4 above, thinning its
disliked-side evidence to one series. Whether tropes that plausibly
transcend genre (revenge, found_family, morally_grey_protagonist) should
ALSO pool cross-genre evidence like structural fields do -- vs. staying
scoped, since some tropes genuinely are genre-specific
(`faster_than_light_travel`, `magic_system_hardness`-adjacent tropes)
and blending those would be wrong -- is a real, currently-unresolved
design question, not something this project has previously decided
either way. Not changed here; flagging as open rather than guessing.

**Bottom line, nothing implemented yet**: #4 (oversized trope effects
from thin/small-sample evidence, and the genre-scoping evidence-
thinning found via `revenge`) is real, evidence-backed, and worth a
genuine experiment next -- something like a sample-size-aware shrinkage
on trope weights (a small liked/disliked count pulling the learned
weight toward zero) is the concrete next candidate, tested the normal
way (two failure scenarios, `scripts/scoring_tests.py`) before landing.
#3's interaction-effects concern is real but ALREADY MODELED for the
romance case via the confidence/source layer -- the actual gap is
strengthening/re-researching a specific low-confidence tag, not adding
a new mechanism. #1's prevalence-discount idea is plausible and #1's
own math is confirmed correct as a description of the current
mechanism, but implementing it needs the same caution the reverted
2026-09-04 redundancy discount already taught this project. #7 is
directly contradicted by this catalog's actual data for the specific
case cited.

## Trope cross-genre backoff -- prototyped, negligible on the motivating case, real (and one alarming) effect on thinner cases (2026-09-06)

Repo owner's own middle-ground proposal, between "tropes always
genre-scoped" (current) and "tropes always cross-genre" (rejected above
as too risky blanket): `build_profile_trope_backoff()` blends a
trope's genre-scoped estimate with its full cross-genre estimate,
weighted `n/(n+k)` toward the scoped one (k=5), where n = distinct
scoped liked+disliked book count. As n grows this converges to current
behavior; as n shrinks it backs off toward the broader pool instead of
toward zero (contrast with the shrinkage entry above).

Tested against all 4 real raters' full held-out suite: **zero
measurable effect anywhere** -- byte-identical bucket/pairwise/
loved_recall/hated_rejection in every scenario. Not a null result on
the mechanism itself, though: `revenge` (fantasy-scoped, the motivating
case) barely moved (0.165->0.150) because fantasy's own scoped n=19 is
already large enough that k=5 barely defers to the cross-genre pool --
the Red Rising problem isn't really about raw COUNT being thin, it's
about evidence INDEPENDENCE (2 disliked books, one series) being thin,
which a plain n/(n+k) on raw book count doesn't capture. Genuinely
thin-BY-COUNT cases moved a lot more: `hidden_talent_prodigy` (sci_fi)
0.267->0.114, `underdog_rising` (sci_fi) -0.261->-0.196. One result
worth flagging before anyone trusts it: `revenge` (sci_fi-scoped)
**flips sign**, -0.146->+0.023 -- fantasy's much larger positive-revenge
pool pulling a thin, uncertain sci-fi-specific estimate past neutral.
A sign flip is a big claim; this needs a dedicated look (does Mathias's
real sci-fi-revenge reaction actually support "slightly positive," or
is this the pooling mechanism overreaching exactly the way the "cons"
side of this idea's discussion predicted) before it's trusted, not
just accepted because the aggregate held-out numbers stayed flat.

**Status: prototyped, not landed.** The held-out silence here isn't
evidence of safety -- it's an artifact of none of the fixed held-out
titles happening to carry these specific thin tropes. A real n needs
to be independence-aware (distinct series/authors, not raw book count)
to actually move the Red Rising case the way it was meant to; the
current version is closer to "correct nudge for a genuinely rare
trope, unpredictable nudge for a genre-imbalanced one" than a clean win.

## `emotional_resolution` spot-check -- no smoking gun, but a real gap in review coverage (2026-09-06)

Repo owner asked to validate whether "bittersweet"'s 53.0% catalog
prevalence reflects deliberate tagging or a default-shaped shortcut.
Two checks: (1) only 14 of 437 bittersweet-tagged books (3.2%) have
ever had an explicit `book_field_confidence` override for this field --
96.8% sit at default trust, same untouched-by-review rate as most other
fields catalog-wide, not something distinctively worse for this one.
(2) Spot-checked a random sample of 20 against known plot facts: Red
Rising (major character loss alongside a real victory), Ender's Shadow,
The Lies of Locke Lamora, Sea of Tranquility all read as genuinely,
specifically bittersweet, not a shrug default. One borderline case,
Vicious (V.E. Schwab) -- arguably closer to `ambiguous` given its
morally-inverted, unresolved ending -- but not clearly wrong either.

**Verdict: no evidence of systematic misapplication found in this
sample.** The field only has 4 possible values (`happy`/`tragic`/
`ambiguous`/`bittersweet` -- see book-dna.schema.yaml), so 53% for one
value is about 2x a no-signal baseline (25%), not the 8-10-category
red flag it would be with a finer-grained schema -- and "bittersweet"
being the modal adult-SFF ending style tracks with real genre
convention (cost-of-victory endings are genuinely common in this
genre), not an artifact. Not added to `HIGH_RISK_FIELDS` on the
strength of this pass -- a 20-book spot-check against my own general
knowledge of these titles is real signal but not the rigorous
per-book research-grade verification `HIGH_RISK_FIELDS` entries get;
flagging as worth the repo owner's own attention given how much scoring
weight rides on it, not asserting it's fully clean.

## `person`: third_limited/third_omniscient grouped for prevalence purposes -- implemented, gated per-user, real prevalence shift, no measurable held-out effect yet (2026-09-06)

Repo owner's observation: third_limited/third_omniscient are "close
cousins" -- and `nominal_similarity()` already agrees, giving them 0.5
partial credit against each other (`NOMINAL_PARTIAL_SIMILARITY["person"]`),
a real, pre-existing precedent for treating them as related rather than
two arbitrary buckets. Proposed: fold them into one combined prevalence
figure for the prevalence-discount experiment, UNLESS a specific user's
own data shows enough evidence to argue they're genuinely different for
that person.

Built `build_prevalence_lookup_grouped()`: per-user gated via
`MIN_PREVALENCE_GROUP_SAMPLE` (5, same spirit as `MIN_DEALBREAKER_SAMPLE`)
-- only groups a `NOMINAL_PARTIAL_SIMILARITY` pair when the user's own
rated history has fewer than 5 books on at least one side. Checked
directly for Mathias: only 2 of his 143 rated books are
third_omniscient (1 loved, 1 disliked) vs. 93 third_limited -- nowhere
near enough to argue a real distinct reaction, so grouping applies for
him. Combined prevalence: 65.1% (53.3% + 11.8% -- higher than the
55% estimate that motivated checking this, strengthening the case, not
weakening it).

Held-out effect: negligible on the current fixed held-out sets (one
title moved by 0.007, no verdict changes) -- expected, since none of
those specific held-out titles happen to be third_omniscient. The real
effect is on THIRD_OMNISCIENT CANDIDATES specifically (their prevalence
discount jumps from a mild 11.8%-based factor to the same steep
65.1%-based factor third_limited already gets) -- not exercised by this
benchmark's fixed title list, but real for actual recommend() output.
**Implemented and gated correctly; needs a recommend()-level check
(not just the fixed held-out titles) to see its real effect before
folding into any final version of the prevalence-discount experiment.**

**UPDATE (2026-09-06, live recommend() check done)**: ran real
`recommend()` for Mathias (both genres, "None of: age_category:ya"
applied) comparing ungrouped vs. grouped prevalence lookup across all
64 fantasy and 32 sci_fi unrated third_omniscient candidates. Effect is
real but modest, as expected -- 8 fantasy and 9 sci_fi candidates moved
by more than 0.005, typically a handful of rank positions each
direction (e.g. Station Eleven rank 18->16, Needful Things rank 44->39,
Mythos rank 55->48), nothing crossing dramatically (no top-20 book
knocked out or a buried book jumping to the top). Confirms the
mechanism is a fine-tuning correction, not a disruptive one -- safe to
carry forward.

## Sci-fi/revenge sign flip under trope backoff -- explained, substantively unresolved (2026-09-06)

Traced directly: Mathias's sci-fi-scoped `revenge` evidence is just 2
books total -- Steelheart (loved) vs. Red Rising (hated), essentially a
coin-toss sample. The cross-genre pool adds 17 more liked-revenge books
(all fantasy: The Way of Kings, Prince of Thorns, Best Served Cold,
Malice, King of Thorns, The Lies of Locke Lamora, and others) against
only 2 more disliked ones (Poppy War/Dragon Republic) -- an 18-vs-3
pool overwhelming the noisy 1-vs-1 sci-fi-only comparison, which is
exactly why the backoff mechanism swings positive. This is NOT a bug in
the mechanism -- it's doing exactly what "trust the bigger, better-
evidenced pool when the specific-scope sample is this thin" means to
do.

Whether that's the RIGHT call substantively is a different, unresolved
question: it depends on whether Mathias's revenge preference genuinely
transfers across genre, or whether Red Rising's "hated" rating is
really about something else that happens to correlate with it being
revenge-driven sci-fi (protagonist type, execution, aesthetic --
exactly the confound the friend's original critique #4/#5 warned
about). Checked directly: Red Rising has NO recorded review, no
rated_date, and no `_meta` note anywhere explaining why it was hated --
this is a genuine gap in the data, not something this analysis can
resolve further without the repo owner's own recollection. Flagging as
an open question for him rather than guessing either way.

## Candidate-pool prevalence discount -- full validation, all 3 regressions traced and understood (2026-09-06)

Ran the full `build_scorecard()` (all 8 rows: Mathias full/sparse/
series-isolated/author-isolated, Osnat full/series-isolated, Dandan
full, Gabriel LOO) with `score_book_prevalence_discount()` swapped in
for `score_book()`, not just the earlier 4-scenario spot check.

**Clear, substantial wins, no offsetting cost**: Mathias full (bucket
+9.1pt, hated_rejection +20pt, pairwise/loved_recall unchanged),
Mathias sparse (bucket +11.1pt, hated_rejection +25pt, pairwise -3.3pt),
Mathias series-isolated (bucket +18.2pt, hated_rejection +40pt),
Osnat series-isolated (pairwise +5.6pt), Dandan full (pairwise +13.3pt).

**All 3 regressions traced to a specific book and explained, not left
as unexplained numbers:**

- **Osnat full, pairwise -5.6pt**: turned out to be exactly ONE pair
  (Divergent vs. Iron Flame) crossing -- and they were already a
  near-tie at baseline (0.788 vs. 0.781, 0.007 apart). Noise-level, not
  a systematic problem with the mechanism.
- **Mathias author-isolated, loved_recall -20pt**: Rhythm of War
  (loved) drops from Good to Poor (0.595->0.497) once trained with
  every Sanderson book excluded. Traced to the exact fields: its two
  matches (`emotional_resolution: bittersweet` 53.0% prevalence,
  `worldbuilding_density: dense` 61.0% prevalence) both get discounted
  heavily, while its one mismatch (`magic_system_hardness: hard`, only
  18.9% prevalence) barely gets discounted at all -- exactly the
  mechanism working as designed, but in this artificially thinned
  stress test, the now-smaller matches can no longer outweigh the
  now-relatively-larger mismatch. The SAME row's Royal Assassin
  correctly flips from a MISS to a hated_rejection win in exchange --
  a real trade-off within one test condition, not a one-sided cost.
- **Gabriel LOO, bucket -14.3pt / loved_recall -20pt**: The Dragon
  Reborn crosses the Good/Mixed boundary (0.564->0.516). Least
  concerning of the three -- Gabriel's leave-one-out training set is
  only 6 books, already the noisiest, smallest-n scenario in this whole
  suite before any scoring change is applied.

**Verdict: ready to land**, with these three trade-offs documented
rather than hidden. The wins are large and consistent across Mathias's
three main scenarios; every regression is either noise-level (Osnat) or
mechanistically sound but exposed only by a deliberately-harsh stress
test (author-isolation, a 6-book leave-one-out set) rather than normal
full-training use. Landing this for real requires deciding HOW
`field_prevalence`/`trope_prevalence` (computed once per scoring
session, not per candidate) get threaded through `score_book()`'s many
call sites (`recommend()`, `explain_book()`, `audit_book_score()`,
`_apply_series_trajectory_penalty()`'s internal `explain_book()` call)
-- a real architectural decision, not done in this pass.

## Candidate-pool prevalence discount -- LANDED for real (2026-09-06)

Merged `score_book_prevalence_discount()`'s logic directly into
`score_book()`/`explain_book()` (new optional `field_prevalence=None,
trope_prevalence=None` params -- None/None is a byte-identical no-op,
so any caller that doesn't have genre/catalog context handy is
unaffected) and removed the now-redundant standalone function, following
this project's own established landing pattern (edit the real
module-level names directly, don't leave two near-identical
implementations lying around).

Threaded `field_prevalence`/`trope_prevalence` through EVERY real
consumer, not just the two obvious ones -- traced the full call graph
first rather than assuming: `recommend()`, `explain_match()`,
`audit_book_score()` (all compute the lookup once via
`build_prevalence_lookup(catalog, genre)` and pass it down),
`user_calibrated_poor_threshold()`, `_apply_dealbreaker_veto()` (a real
catch -- it calls `dealbreaker_flags()` internally, which calls
`explain_book()`, so it's genuinely part of the scoring pipeline, not
just a display helper the way it first looked), `dealbreaker_flags()`,
`_series_trajectory_penalty_factor()`/`_apply_series_trajectory_penalty()`,
and `series_dnf_outlook()` (self-contained, computes its own lookup
since nothing threads into it). `tools/dogfood/app.py` also fixed --
it separately called `build_profile()` unscoped and
`user_calibrated_poor_threshold()` undiscounted just to compute
match-label thresholds, which would have silently miscalibrated labels
against `recommend()`'s now-discounted scores; switched to
`_resolve_profile()` (genre-scoped) plus the same prevalence lookup.

**Real gap caught while landing, not after**: `scripts/scoring_tests.py`
calls `R.score_book()`/`R.explain_book()`/etc. directly, with none of
the new params -- meaning the ENTIRE benchmark suite would have
silently kept testing the pre-2026-09-06 undiscounted pipeline forever,
exactly the "benchmark tests a different pipeline than what a live
user sees" gap `_full_score()`'s own docstring already warns about for
the veto/trajectory stages. Fixed by adding a `_get_prevalence_cache()`
helper (same catalog-wide, genre=None lookup every scenario in this
file already uses unscoped) and threading it through `_full_score()`
plus every direct `user_calibrated_poor_threshold()`/`dealbreaker_flags()`/
`explain_book()` call across `run_held_out_test()`,
`run_leave_one_out_diagnostic()`, `run_weight_cap_check()`,
`run_ablation_held_out()`, `run_threshold_diagnostic()`, and both
dealbreaker-flag sanity-check functions.

**Re-ran the full suite after landing**: all 13 scenarios pass, and the
real numbers now match the earlier validation A/B exactly (Mathias
full: 9/11 = 82% bucket, Osnat held-out scores byte-identical to the
"prevalence" column from the validation pass) -- confirms the harness
now genuinely exercises production behavior rather than a stale
snapshot of it. Gabriel's LOO pairwise dropped slightly further (33%->20%)
than the earlier quick A/B showed, because this full landing threads
the discount through the dealbreaker veto and threshold calibration too
(the quick validation script only patched `score_book()`) -- a MORE
complete, not less correct, application of the same already-accepted
trade-off (Gabriel's 6-book leave-one-out set is the noisiest scenario
in the suite regardless).

**Consistency check**: `recommend()`'s returned score and
`audit_book_score()`'s `final_score` for the same book/profile/rules
verified identical to 1e-5 across the top 5 fantasy candidates (a
suspected 0.880 vs. 0.8797 "mismatch" while landing turned out to be my
own test script comparing an unrounded score against `audit_book_score()`'s
deliberate `round(final, 4)` -- not a real bug, confirmed by relaxing
the tolerance and rechecking). Live-checked in the dogfood tool's
browser UI too: rankings genuinely reordered (City of Stairs edged
ahead of The Shadow of the Gods, exactly the kind of relative reshuffle
this mechanism is meant to produce), and the expanded audit view's
pipeline numbers matched the header score exactly.

`build_prevalence_lookup_grouped()` (the third_limited/third_omniscient
person-grouping refinement) is NOT included in this landing -- it
remains a separate, already-validated-but-not-requested enhancement,
available to layer on later.

## Field-conditional series deduplication -- prototyped, tested, REAL REGRESSION found and traced, NOT landed (2026-09-06)

The follow-up flagged back on 2026-09-04 ("Series DNA / dedup
integration -- investigated, not built"): `_series_deduped()` treats
every series-mate as equally redundant on EVERY field uniformly (a
6-book series divides every field's contribution by 6), even though a
field can genuinely drift across a series while another stays
constant. Built `build_profile_series_field_dedup()` -- moves
dedup from "book" granularity to "book, field" granularity for
ORDINAL_FIELDS/NOMINAL_FIELDS: a series-mate's magnitude for a specific
field is now divided by how many OTHER rated series-mates share BOTH
the series AND the exact same value for that field, not just the
series. If a series' rated books all share one value for a field, this
is identical to today's behavior; if they genuinely split across
different values, each value-group is treated as its own independent
cluster instead of all being diluted together. Deliberately scoped to
ordinal/nominal fields only, tropes untouched (see the function's own
module comment for why the shared trope normalizer makes a
trope-conditional version a separate, harder design question).

**Full 8-row scorecard, all 4 real raters -- a real, consistent
regression, not a wash:**

| Scenario | bucket | pairwise | hated_rejection |
|---|---|---|---|
| Mathias full | -9.1pt | 0 | **-20pt** |
| Mathias series-isolated | **-18.2pt** | -2.2pt | **-40pt** |
| Mathias author-isolated | -9.1pt | -2.2pt | -20pt |
| Osnat full | 0 | +5.6pt | 0 |
| (Osnat series-isolated / Dandan / Gabriel) | 0 | 0 | 0 |

No domination-scenario interaction (person/pov_count both still hit
WEIGHT_CAP=0.5 either way).

**Traced to an exact, understood cause, not left as a mystery number**:
every regression is the SAME two books -- Royal Assassin and Interview
with the Vampire (both correctly-Poor at baseline, both flip to
incorrectly-Good/Mixed here) -- both real, since both are first-person
books this mechanism weakens Mathias's `person` dealbreaker signal
against. Root cause found directly: the Book of the Ancestor trilogy
(Red Sister=first-person, Grey Sister/Holy Sister=third_limited, all 3
loved) is the ONLY series in his rated history where `person` genuinely
splits within a series. Under the OLD dedup, Red Sister's "first" value
counted at 1/3 weight (diluted by its own third-limited sequels).
Under the NEW dedup, it counts at FULL weight as its own value-
subgroup -- correctly giving a real counterexample (he loved a
first-person book) its full due, but the net numerical effect is that
`person`'s liked-vs-disliked separation weakens (weight 0.2504->0.2398
on the real full profile), softening the exact signal that correctly
flags Royal Assassin/Interview with the Vampire.

**This is a genuine precision/recall trade-off, not a bug**: giving a
real counterexample its full weight is conceptually correct and did
happen for a real reason (Red Sister really is a genuine exception in
his history) -- but on this specific held-out test, the cost (weakening
a mostly-correct dealbreaker signal) outweighs the benefit (properly
representing one real exception) for this rater's actual data. Same
class of finding as several already-deferred ideas in this document:
conceptually well-motivated, real mechanism, net negative once tested
against real data rather than reasoned about in the abstract.

**Verdict: NOT landed.** Kept as `build_profile_series_field_dedup()`
in recommend.py for reference, not wired into production, same pattern
as every other deferred/reverted experiment here. Worth reconsidering
only if a future version specifically protects a user's validated
dealbreaker fields (`validated_dealbreaker_fields()`) from this
de-dilution effect, or only applies it when the differing subgroup is
the cluster's minority rather than any split -- neither built or tested
here; noted as the concrete next idea if this gets revisited, not
implemented speculatively.

## Validated-dealbreaker-protected variant -- tried, produces IDENTICAL results, does not fix anything (2026-09-07)

Built the concrete follow-up proposed above: `build_profile_series_
field_dedup_protected()` -- any field in the user's `validated_
dealbreaker_fields()` set keeps today's plain book-level dedup
(`_dedup_factor_plain()`), only non-validated fields get the field-
conditional treatment.

**Result: byte-identical scorecard to the unprotected version, every
single row, all 4 raters** -- confirmed directly (`unprotected and
protected produce byte-identical scores: True` across the full
held-out set). The safeguard never activates because of a fact worth
flagging on its own: **`person` is currently NOT a validated
dealbreaker field for Mathias** -- `field_or_trope_separation()` returns
0.345 against a `STAT_SEPARATION_THRESHOLD` of 0.65, so
`validated_dealbreaker_fields(catalog, id_to_magnitude)` returns an
empty set for his full profile right now. This directly contradicts an
earlier claim made in this same session (the Recommendation Engine
Schematic artifact stated "person is currently your one real validated
dealbreaker field") -- that claim was stale by the time of this check,
most likely because several ratings were added to `data/ratings/
mathias.json` afterward (Battle Royale, The Crimson Campaign, The
Autumn Republic, The Broken Eye, Dragons of Autumn Twilight) and
`person`'s separation shifted below the validation bar in the
meantime. Worth remembering: a "validated field" is a live computation
against current data, not a fact to cache and reuse across a session
without rechecking.

**Verdict: this specific fix does not work, for a clean, understood
reason** -- it protects the wrong condition. The regression is driven
by `person`'s de-dilution, but `person` isn't (currently) validated, so
"protect validated fields" has nothing to protect. A real fix would
need to key off something else -- e.g. a lower, still-real separation
threshold specifically for this purpose (not full dealbreaker-veto
validation), or the minority-subgroup idea already logged above.
Neither built here. NOT landed, same as the unprotected version --
kept in recommend.py as `build_profile_series_field_dedup_protected()`
for reference.

## Graduated dealbreaker veto -- built and structurally verified, NOT landed (revealed a bigger finding instead) (2026-09-07)

Follow-up to the person-dealbreaker-threshold investigation (see the
protected-variant entry above): the 2026-09-05 adaptive-threshold
experiment correctly found `person` statistically real for Mathias via
a permutation test, but reverting it was blamed on the flat veto's cap
being a blunt instrument -- Old Man's War (a genuine exception, loved
despite mismatching `person`) got the exact same hard clamp to
`DEALBREAKER_VETO_CAP` as his clearest dealbreaker cases, for no
compensating gain (bucket accuracy 91%->82%, loved_recall 100%->80%).

**First design tried, ruled out with real data before writing any
code around it**: scale the cap by the flagged field's OWN mismatch
magnitude. Checked directly -- for a NOMINAL field, that magnitude is a
function of (book's value, centroid's value, learned weight) only, so
it's IDENTICAL across every candidate sharing the same value pair.
Confirmed: Red Sister, Royal Assassin, Assassin's Apprentice, Interview
with the Vampire, and Circe all show `person_mismatch == 0.169` against
the same fantasy profile, despite raw scores of 0.474/0.342/0.265/0.224/
0.461 and wildly different real outcomes (loved vs. hated). Per-candidate
field-magnitude graduation cannot distinguish a real dealbreaker hit from
a genuine exception -- ruled out before implementation, not after.

**What actually varies per candidate is the raw score itself** -- how
much OTHER evidence this book has going for it. Built
`_apply_dealbreaker_veto_graduated()` instead: pulls the score toward
the cap by a fraction between `DEALBREAKER_VETO_PULL_FLOOR` (0.5, for a
flag right at the validated-magnitude floor) and 1.0 (a flag at or above
`WEIGHT_CAP` severity -- reproduces the flat clamp exactly), rather than
clamping outright. Verified analytically: correctly degrades to the
existing flat behavior at max severity, softens for borderline severity.

**Testing it exposed a much bigger problem than "which veto shape is
better"**: scanning Mathias's FULL rated fantasy pool for person=first
books (not just the held-out set) shows `person` mismatches at 0.169 --
clears `VALIDATED_DEALBREAKER_MAGNITUDE` (0.15) -- for every single one,
but the label split is 18 loved/liked vs. only 5 hated/disliked (3 of
which are the same Farseer trilogy). 11 of those loved/liked books score
*above* `DEALBREAKER_VETO_CAP` (Grave Peril, The Pariah, The Martyr, The
Traitor, Prince of Fools, The Wheel of Osheim, Blackwing, Hard-Boiled
Wonderland, Death Masks, Emperor of Thorns, King of Thorns, Summer
Knight). Forcing `person` into `validated_fields` (replicating the
2026-09-05 setup, since it doesn't validate under today's data) and
running either veto shape against these would incorrectly suppress 11
genuinely loved/liked books to catch effectively 3 real cases (Circe,
Interview with the Vampire, and one trilogy). This is NOT a flaw in the
graduated veto -- it's confirmation that `STAT_SEPARATION_THRESHOLD`
(0.65) is currently doing its job correctly by keeping `person` OUT of
the validated set. Sci-fi's person mismatch (0.144) doesn't even clear
the 0.15 floor at all, so no fantasy-style false-positive risk there,
but also nothing to test against.

**Consequence for testing the graduated veto itself**: `validated_
dealbreaker_fields()` currently returns an EMPTY set for all 4 real
raters (confirmed directly, see the person-threshold diagnostic this
session opened with) -- meaning the existing flat veto is ALSO
currently dormant in production for everyone, not just a Mathias/person
issue. There is no real rater/field pair today where the graduated veto
would fire with genuine validated evidence, so its benefit over the
flat version can't be demonstrated on real data right now -- both are
equally inert. Landing an unproven mechanism would break this project's
own standing rule (every scoring change checked against real scenarios
before landing, not just "looks right").

**Verdict: built, structurally verified, NOT landed.** Kept as
`_apply_dealbreaker_veto_graduated()` in recommend.py (EXPERIMENTAL
comment block, not wired into `_full_score()`/`recommend()`/
`explain_match()`/`audit_book_score()`) for whenever a field/user pair
DOES validate in the future -- at that point, re-run this same
force-validated comparison against real held-out data before landing,
the way this entry did, rather than assuming the structural argument
alone is enough.
