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

## A2: canonical `score_candidate()` orchestrator -- LANDED (2026-09-16, proposed by CODX, independently verified and applied by CLDO)

Implements the actual Phase A step 2 from `docs/TODO.md` (not to be
confused with "A2 (prerequisite)" above, a separate, earlier scaffolding
step): ONE canonical function, `score_candidate(catalog, book_id,
centroid, weights, id_to_magnitude, *, policy, validated_fields,
series_dna, field_prevalence, trope_prevalence, poor_threshold,
cold_start=None, matches_genre=None, discovery_only=False,
recent_books=(), diversity=0.0, normalized_rules=None, top_n=None)`,
added to `scripts/recommend.py`. It covers the full stage sequence
(base -> series-repeat -> dealbreaker veto -> series trajectory ->
diversity -> cold-start blend -> user rules) behind one of four
`policy` values (`ranking`/`explanation`/`evaluation`/`audit`) that
each preserve the current callers' existing, intentionally different
contracts (see the report's policy table), and returns a rich result
dict (per-stage scores, label, factors, contributions, matches/
mismatches, dealbreaker flags, series note, exclusions) instead of a
bare float. **Purely additive**: no existing function is modified, and
nothing calls the new function yet -- `recommend()`, `explain_match()`,
`audit_book_score()`, and `scoring_tests.py` are all byte-for-byte
unchanged. Caller migration is A3, a separate task.

CODX built and validated this as real running code in its own clone
(`docs/codx-reports/2026-09-16-a2-canonical-scorer-proposal.md`, ~1720
lines), per the same standing clarification that local sandbox
implementation/execution is in scope for a proposal. Its validation:
a `sys.settrace` bit-for-bit comparison (IEEE-754 hex encoding,
including signed zero) against the *original* stage helpers' actual
locals, using a live 978-book catalog snapshot pulled once via
`codx_readonly`; the exact 378-case Task 3 battery reused verbatim
across all four policies; 48 real-rater/synthetic profile combinations
(4 real raters + the Goodreads fixture, x genre x format, plus
empty-history/one-rating/negative-fatigue edge profiles) with entire
ranked lists and top-10 detail views compared, not just aggregate
scores; and a targeted 8-book synthetic catalog built from real
(unmocked) profile/calibration/series-DNA/cold-start preparation,
specifically to exercise stacked, non-commuting stage interactions
(veto cap actually triggered, then trajectory discount, diversification,
cold-start blend, and rule reduction/exclusion, checked separately per
policy). 308,658 bit-exact assertions passed. The canonical suite
passed before and after (exit 0 each), byte-identical (matching
SHA-256). CODX explicitly reported its own dead ends along the way
(an initial coverage gap where no sampled profile actually changed
score at the veto stage, closed by the synthetic catalog; an invalid
rule-key typo caught by the real parser) rather than hiding them.
Reverted its own clone to exact HEAD bytes afterward, hash-verified,
and confirmed the saved patch still applies cleanly against the
restored tree before calling it done -- same discipline as A2
(prerequisite).

**Independently re-verified by CLDO before applying**: extracted the
diff from CODX's report, applied it to this repo's own checkout at the
matching base revision (`git apply --check` clean), and confirmed via
Python's `ast` module that the patch adds exactly one top-level
function (`score_candidate`) and changes the AST of every other
existing top-level function/class by zero bytes -- not just trusting
the diff's visual shape. Ran the real `scripts/scoring_tests.py`
against local Supabase before and after applying -- byte-identical
(matching SHA-256), a genuinely different database than CODX's hosted
read-only snapshot. Read the diff directly: the policy table, stage
order (veto before trajectory, diversity before cold start, rules
last), and per-policy input-ignoring behavior all match the report's
prose exactly, and the interaction-test numbers in the report are
internally consistent with that table (e.g. `after_veto` identical
across all four policies since every policy shares the same base ->
veto pipeline; `after_diversity`/`after_cold_start` only move for
`ranking`/`audit`, carried forward unchanged for `explanation`/
`evaluation`).

Landed as-is; no further changes needed before this is real production
behavior. Next: A3 (migrate `recommend()`'s own loop to call
`score_candidate(..., policy="ranking")`, full scorecard byte-identical
check before moving on) per `docs/TODO.md`'s Phase A plan.

## Phase B step 2 (B4): shim dropped, all 5 real consumers on direct imports -- LANDED (2026-09-17, Task 12, proposed by CODX, independently verified and applied by CLDO)

CLDO again did the module-boundary research up front -- pulling the
exact name-to-submodule mapping straight from Task 11's own
`module-map.json` and grepping every real `R.name` access across all 5
consumers -- so this stayed bounded/mechanical for CODX. All 5 real
consumers (`api/main.py`, `api/catalog_cache.py`,
`scripts/scoring_tests.py`, `scripts/import_goodreads.py`,
`tools/dogfood/app.py`) now import directly from `scripts/scoring/`
submodules; `scripts/recommend.py` drops from 439 to 105 lines, keeping
only its original module docstring and CLI demo (the documented
`python3 scripts/recommend.py` entry point still works, byte-identical
output) -- no re-export/shim role left at all.

**CODX caught a real bug CLDO's own task brief would have introduced
if followed literally**: the brief specified `from scoring import
catalog` unaliased, but `scoring_tests.py`'s `run_all()` and
`import_goodreads.py`'s importer both already assign to a local
variable named `catalog` in the exact function that would do this
import -- Python's scoping rules would make that local assignment
shadow the module-level import throughout the function, so
`catalog = catalog.load_catalog()` would raise `UnboundLocalError:
local variable 'catalog' referenced before assignment`. Fixed with
`catalog as scoring_catalog` aliasing (and similar aliasing elsewhere
`audit`/`rules` collided with existing local names). Not a hypothetical
risk -- CLDO independently confirmed the exact line
(`catalog = scoring_catalog.load_catalog()` inside `run_all()`) and
traced through why the unaliased version would genuinely fail.

**Validation went beyond the requested bar**: real Streamlit `AppTest`
execution of the dogfood tool (launched at startup and after a real
"Get recommendations" click, comparing all expander labels/markdown/20
audit tables -- not just confirming it imports), a real execution of
the Goodreads importer's existing synthetic CSV self-check, and the
same isolated-venv real-FastAPI-dependency endpoint comparison Task 11
used -- all outputs byte-identical to Task 11's own saved baseline
hashes, not just internally consistent.

**Flagged, not fixed, a real resulting documentation staleness**:
`CLAUDE.md`'s monkeypatch A/B-testing guidance checks a single
`import scripts.recommend as R; ... R is T.R` identity, which stops
applying once `scoring_tests.py` imports several submodules instead of
one `R`. CODX's proposed replacement is more technically precise than
the original -- checking a specific function's `__globals__` dict
identity (`T.pipeline.score_candidate.__globals__ is vars(pipeline)`),
not just module identity, since that's what actually determines which
binding a monkeypatched function looks up at call time. CLDO to apply
this after review, same process as every other doc/skill staleness
CODX has flagged.

**Independently re-verified by CLDO before applying**: applied the
patch in a worktree, ran the canonical suite and the CLI demo against
local Supabase -- both byte-identical (a different environment than
CODX's hosted/frozen-snapshot runs). Confirmed via grep that zero
`R.`/`import recommend`/shim references remain across all 6 files.
Confirmed all 6 files are syntactically valid Python. Manually read
`api/main.py`'s exact diff line-by-line and confirmed every replacement
matches the specified mapping exactly. Independently traced the
`UnboundLocalError` claim to the real code (not just trusted the
report's explanation).

Landed as-is. **Phase B is now fully complete (B1-B4)**:
`scripts/recommend.py` is a genuine, minimal CLI demo script; the real
engine lives entirely under `scripts/scoring/`, and every real consumer
imports from it directly.

## 2026-09-22 -- NDCG@5/10/20 and top-K rejection-rate metrics added to scripts/scoring_tests.py

From the 2026-09-14 external AI (ChatGPT "Astra") review's confirmed-real,
not-yet-built list (see `docs/TODO.md`'s P1 entry): a real, genuine gap
independently re-verified before starting -- `recall_and_rejection()`
(landed earlier) measures whether a held-out book's own predicted MATCH
LABEL was right, in isolation, but says nothing about where that book
actually lands in a real `recommend()` call's top-K, which is the only
thing a real user ever sees. Not a scoring-algorithm change -- no
`score_book()`/`build_profile()`/`score_candidate()` edits, purely a new
read-only measurement in the test harness, so the "two failure
scenarios before landing" rule for scoring CHANGES doesn't strictly
apply, but it was run against 2 real raters anyway (see below) as
routine due diligence.

**What was built**: `ranking_metrics()` in `scripts/scoring_tests.py`,
trains a profile the same way `run_held_out_test()` does, then calls
the REAL `api.recommend()` (same eligibility logic production uses --
every trained-on book excluded as `already_rated`, held-out books
included since they're absent from the training profile) and measures,
per k in (5, 10, 20):
- `ndcg`: standard graded-relevance NDCG@k (loved=2, liked=1, everything
  else -- including a disliked/hated held-out title -- contributes 0).
  Kept to non-negative standard relevance deliberately, rather than a
  signed variant using `RATING_LABELS`' -1..1 scale -- see below.
- `top_k_rejection_rate`: of the held-out hated/disliked titles, what
  fraction are correctly kept OUT of the top-k. 1.0 = perfect.

Kept deliberately SEPARATE (not blended into one number), same
reasoning as `recall_and_rejection()`'s own `loved_recall`/
`hated_rejection` split, which this directly extends to real rank
position: a system can be lopsided on one while looking fine on the
other. Considered a single signed-relevance NDCG (using
`constants.RATING_LABELS`' -1.0..1.0 scale directly, letting a
high-ranked hated book contribute negative DCG) but rejected it --
non-standard (classic NDCG assumes non-negative grades), and the
existing recall/rejection split already proves this project's own
convention is to keep those two questions legible separately rather
than collapse them.

Both metrics report `None` (not `0.0`) when the held-out set has
nothing of the relevant kind to measure (no loved/liked for `ndcg`, no
hated/disliked for `top_k_rejection_rate`) -- "nothing to measure" isn't
the same claim as "the system found none of it," same distinction
`_pct()` already makes elsewhere in this file.

Wired into `run_all()` as a new Scenario 1c, run against Mathias (both
the print-profile baseline matching Scenario 1, and his real
`format_preference` matching Scenario 1b) and Osnat.

**A real, substantive finding, not a bug** (verified by hand before
trusting it -- see below): Mathias's NDCG@5/10/20 is **0.000** across
the board. None of his 5 held-out loved/liked titles (Warbreaker, A
Clash of Kings, Rhythm of War, The Last Wish, Old Man's War) crack the
real top-20 of a full ~1483-book `recommend()` ranking, despite scoring
0.46-0.77 individually in the isolated `run_held_out_test()` check
(several landing "Good"/"Strong match"). The real top-20 for his
profile scores 0.79-0.88 -- there are simply enough other candidate
books scoring that high that none of the held-out set is competitive
for a spot a user would actually see. This is exactly the gap the
external review's NDCG proposal was meant to expose and
`recall_and_rejection()` structurally cannot: a book can be correctly
LABELED a good match while still never actually surfacing. Verified not
a title-matching/slicing bug in the new code by manually printing
`api.recommend()`'s real top-20 titles/scores and confirming by eye that
none of the 5 held-out titles appear anywhere in it (see the
conversation this landed in for the exact printout). `top_k_rejection_rate`
is a clean 100% for Mathias at every k (all 5 held-out hated/disliked
titles correctly absent from the top-20) -- consistent with Scenario
1's own bucket verdicts, where every one of them already scored "Poor
match, OK". Osnat: `ndcg` also 0.000 (0 of 3 relevant held-out titles in
her top-20), `top_k_rejection_rate` 50% (1 of her 2 negative held-out
titles DOES leak into her top-20) -- a real, smaller-magnitude version
of the same finding.

**Not investigated further this session** -- landing the metric itself,
not chasing the finding it surfaced. Worth a dedicated follow-up: is
"loved/liked held-out books don't crack a full-catalog top-20" a
structural property of a still-small catalog/rating-count regime (not
enough signal yet to separate a genuinely great match from a merely
good one at the very top), or a real ranking-quality gap independent of
data volume? The reader-count-bottleneck framework this project already
tracks (`docs/TODO.md`'s P1 external-review entry) is the natural lens
to revisit this through once more real raters exist.

**Verification**: full `scripts/scoring_tests.py` suite run to
completion, exit code 0, no regressions in any of the other 13
scenarios (scorecard/ablation/threshold/dealbreaker/user-rules/
confidence-floor checks all still pass exactly as before -- this
change adds a new scenario, touches nothing existing).

## 2026-09-22, later still -- ranking_metrics() demoted from "accuracy metric" to "product-surface metric"; rank_percentile_report() added

Same day the metric above landed. The repo owner pushed back on the
"NDCG=0.000" finding with a genuinely good methodological question,
worth recording in full since the original framing was wrong and a
future session might otherwise re-derive the same mistake. Logged per
his explicit request ("log the reasoning behind it for posterity, we
might change our mind in the future") -- this is a correction entry,
not a rewrite; the original 2026-09-22 entry above stays as-is.

**The question, paraphrased**: imagine a friend reads 20 self-chosen
books and loves 6 of them. What are the odds those 6 land in the top
percentiles of the catalog, and what would that actually tell us?

**The math**: under a genuinely random ranking, 6 independent titles
all landing above, say, the 90th percentile would be astronomically
unlikely (0.1^6, about one in a million) -- so a high percentile alone
does look like strong evidence of SOMETHING real. That part of the
original framing wasn't wrong.

**What was wrong**: held-out titles aren't a random sample of the
catalog. A rater chose to read them, which means they already passed
that PERSON'S OWN "this looks appealing" filter before the scoring
system ever touched them. A system that can't discriminate taste at
all -- one that only detects "books shaped like what this person tends
to pick up" (genre, tropes, surface pattern-matching) -- would ALSO
rank a rater's own held-out books above the catalog median, for the
same reason: they were self-selected to be appealing-looking in the
first place. Both a rater's loved AND their disliked held-out titles
cleared that same self-selection filter. So a high percentile on
EITHER one doesn't distinguish "this system understands MY taste" from
"this system detects the genre/shape I already read" -- the only thing
that isolates real taste-discrimination is the GAP between where loved
titles rank and where disliked titles rank, not either one's absolute
position.

**The real consequence**: this project already has a metric that
measures exactly that gap, more directly and with more statistical
power -- `pairwise_accuracy()` (every loved/disliked PAIR compared
head-to-head, not each title's own isolated rank). `ranking_metrics()`
does not out-perform it as an accuracy signal and was wrong to be
implicitly framed that way (both in its own docstring and in how the
2026-09-22 landing entry above reported the Mathias/Osnat findings as
if they were primarily about ranking quality).

**What `ranking_metrics()`/`rank_percentile_report()` ARE still
genuinely good for, and why they're kept rather than reverted**: real
PRODUCT-surface visibility -- does a specific held-out title literally
appear in the top-K a user would see on screen, using the actual
`api.recommend()` call. That's a narrower, different, still-legitimate
question ("what does this person actually see") from "does the system
generalize" ("is the ranking logic sound") -- worth tracking on its
own, just not as evidence of accuracy. `ranking_metrics()`'s docstring
now states this distinction explicitly rather than implying otherwise.

**Also added this session**: `rank_percentile_report()` -- the
`ranking_metrics()` top-K binary check (in the top-K or not) turned out
to be nearly uninformative on its own, for a related, simpler reason: a
specific title's chance of landing in a K-wide window purely by chance
is K/pool_size, and with a 661-698-book pool and K=20, that's about 3%
-- so a handful of held-out titles missing a top-20 cutoff barely moves
the needle either way. The actual rank/percentile (computed once, by
hand, in the conversation this landed in, now a real reusable function)
told a far richer story: 3 of Mathias's 5 held-out loved/liked titles
landed in the top 5-19% of the scored pool (Warbreaker #29/661 = top
4.4%; The Last Wish #62/661 = top 9.4%; Rhythm of War #123/661 = top
18.6%), which is real, meaningful separation even though none reached
the literal top-20. It also surfaced a genuinely concrete, actionable
finding the binary check couldn't: Osnat's `top_k_rejection_rate` at
k=20 read as a middling "50%", but the actual rank shows why that
number understates the problem -- *Magic Burns*, a book she HATED, is
ranked **#4 of 695**, nearly the single top recommendation the system
would show her. That's a much sharper, more useful signal than "50%
rejection" conveyed on its own.

**Not chased further this session**: WHY Magic Burns ranks so high
despite being hated, or whether the Mathias loved-books percentiles (top
5-19%, real but shy of top-20) reflect a still-small catalog/rating-count
regime or something scoring-side. Both are real follow-up candidates,
not attempted here -- this session's scope was fixing the metric's
framing and tooling, not chasing findings it surfaces.

**Verification**: full suite re-run after both the docstring rewrite
and the new function, exit code 0, all 14 scenarios still pass exactly
as before (this only added a new function and reworded documentation --
no existing function's behavior changed).
