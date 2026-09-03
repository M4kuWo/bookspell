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
