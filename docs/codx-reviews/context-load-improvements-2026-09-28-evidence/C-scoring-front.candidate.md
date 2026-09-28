## Reading contract (proposed)

Read this front section through "What's been tried" in full for scoring
behavior changes, scoring-semantic tests, and scalar-field proposals. Answer
all ten gate questions before implementing a scoring change. The table is
historical navigation, not a complete or authoritative current-status index.
Search the entire remaining protocol and project log for touched identifiers,
related concepts, old names and known failure modes. Read complete relevant
entries and their later corrections, not isolated matching lines. Consult
current code and contracts before treating a historical status as current.
Record search terms and the entries supporting the proposal. If a dependency
or reversal cannot be resolved, broaden the read, including the full history
when needed. No design change can be justified by a narrow search miss.

Always include the latest canonical-pipeline/module-import conventions and
metric-interpretation corrections when changing or evaluating scoring behavior.
Both failure scenarios and applicable current validation requirements remain
mandatory. This reading policy grants no implementation or benchmark authority.
For a scalar proposal failing an earlier gate, report that stop explicitly;
do not claim a complete design review or permission to bypass later gates.

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

## Before proposing any scoring change: the 10-question gate

Adopted 2026-09-24 from an external AI (GPT/"Astra") review's section 7
(`docs/external-reviews/2026-09-23-gpt-review.md`) -- a genuinely good,
reusable checklist that matches this project's existing discipline
closely enough to make it a real, binding gate rather than filing it
away as "a good idea from a review." Answer all ten before writing a
line of scoring code, the same way the two-scenario requirement below
is already mandatory, not optional:

1. **What observed failure class is this intended to solve?**
2. **Is this failure present across multiple books/readers, or only
   one example?** (a single example is a CODX-style diagnosis task, not
   yet a scoring-change proposal)
3. **Could the problem instead be incorrect metadata?** (check the
   book's actual tags before touching the formula)
4. **Could it be caused by insufficient reader history?** (see the
   Magic Burns case, `docs/codx-reviews/2026-09-23-magic-burns-ranking.md`
   -- a real example where the honest answer was yes, and the correct
   response was "wait for more data," not "add a heuristic")
5. **Can the problem already be represented by existing Book DNA?**
6. **Which metric should improve if the change works?** (pairwise
   accuracy, NDCG, rank percentile, top-K rejection rate, or a real
   prospective outcome -- name it before starting, not after)
7. **What metric/regression would cause us to reject the change?**
8. **Can this be implemented without creating another parallel scoring
   path?** (see `score_candidate()`'s canonical-pipeline design --
   every consumer calls it, nothing reconstructs scoring semantics
   independently)
9. **Can the change be ablated independently?** (`run_ablation_study()`/
   `ABLATION_GROUPS` in `scripts/scoring_tests.py` already exist for
   exactly this)
10. **Does the added complexity earn its maintenance cost?**

If these ten can't be answered, the change isn't ready to implement --
log it as a deferred idea in the table below instead, same as this
file already does for every other idea that didn't clear its bar.

See also `docs/schema/book-dna.md`'s "The bar for a new scalar
`book_dna` field" section (still in the core file, not moved out,
after the 2026-09-25 schema split -- see that file's own reasoning on
why) for the equivalent, more specific gate for proposing a brand-new
scalar `book_dna` field (question 2 and 9 above, made concrete for that
particular kind of change).

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

