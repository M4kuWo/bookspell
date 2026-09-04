"""Reusable scoring-engine test scenarios -- see docs/scoring-test-protocol.md
for what each one checks and when to rerun them. Run directly:

    DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres python3 scripts/scoring_tests.py

Every scenario here is real data (an actual person's ratings), not
synthetic, EXCEPT WEIGHT_CAP_RATINGS, which is a reconstruction (the
original test's exact titles weren't logged verbatim -- only its
structural shape: "grimdark/political fantasy + hard SF liked, all
multi-POV/third-person; assorted single-POV/first-person disliked" --
see project-log.md 2026-09-01). Built from real catalog books matching
that shape, not fabricated ratings.
"""
import sys
import os
import json
import random
import statistics

sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
import recommend as R

EXPECT_GOOD = {"loved", "liked"}
EXPECT_POOR = {"hated", "disliked"}

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "ratings")


def load_rater(name):
    """Loads {name}.json from data/ratings/ -- see data/ratings/README.md
    for the roster and why this lives as durable, versioned files rather
    than hardcoded literals: a new rater's data should extend this test
    suite, not require rewriting it."""
    path = os.path.join(DATA_DIR, f"{name}.json")
    with open(path) as f:
        return json.load(f)["ratings"]


# --- Scenario 1: the repo owner's real ratings, combined across both
# test rounds this session (16-book original list + 20-item numbered
# list + resolved series/aggregate statements). Currently the ONLY real
# rater we have -- see the protocol doc for why every conclusion drawn
# from this scenario alone is provisional. See data/ratings/ for the
# full roster of raters expected to contribute lists next. ---
REAL_RATINGS = load_rater("mathias")
REAL_HELD_OUT = [
    "Warbreaker", "A Clash of Kings", "Rhythm of War", "The Wise Man's Fear",
    "Royal Assassin", "Skyward", "Eragon", "Interview with the Vampire",
    "The Last Wish", "Old Man's War", "Assassin's Quest",
]

# --- Scenario 2: WEIGHT_CAP-motivating reconstruction -- the "domination"
# failure mode: liked = all multi-POV/third-person, disliked = all
# single-POV/first-person. A fix that helps scenario 1's "dilution" case
# MUST be checked against this one too before landing -- neither failure
# mode alone is a valid test of a candidate fix. ---
WEIGHT_CAP_RATINGS = {
    "A Game of Thrones": "loved", "A Clash of Kings": "loved", "A Storm of Swords": "loved",
    "The Blade Itself": "loved", "Mistborn: The Final Empire": "loved",
    "Caliban's War": "loved", "Leviathan Wakes": "loved", "Children of Time": "loved",
    "The Three-Body Problem": "loved", "Dune": "loved",
    "Assassin's Apprentice": "disliked", "Prince of Thorns": "disliked",
    "Red Rising": "disliked", "Storm Front": "disliked",
}

# --- Scenario 3: sparse-data check -- the repo owner's ORIGINAL 16-book
# list (the very first real test round, before the 20-item follow-up),
# a genuine smaller dataset, not a synthetic contrivance. Every scoring
# change should be checked against both this AND scenario 1 (the full
# 53-book set) -- a fix tuned/validated only on the richer set could
# behave differently (better OR worse) with less evidence, and that's
# exactly the kind of gap real new users will sit in. ---
SPARSE_TITLES = [
    "The Eye of the World", "The Way of Kings", "Dark Matter", "Circe", "Six of Crows",
    "Prince of Thorns", "The Blade Itself", "Red Rising", "The Gunslinger",
    "We Are Legion (We Are Bob)", "The Poppy War", "Artemis", "Children of Time",
    "Interview with the Vampire", "Old Man's War", "The Lion, the Witch and the Wardrobe",
]
SPARSE_RATINGS = {t: REAL_RATINGS[t] for t in SPARSE_TITLES}
# Interview with the Vampire is IN the sparse set as training, not
# held-out there -- exclude it from this scenario's held-out list
# specifically (it's still held out for scenario 1's richer set).
SPARSE_HELD_OUT = [t for t in REAL_HELD_OUT if t not in SPARSE_RATINGS]

# --- Scenario 4: second rater, Osnat -- grew from 4 usable books, to 18
# once she sent her fuller star-rated reading history, to 30 now that
# catalog-growth tagging caught up with several previously-untagged or
# not-yet-ingested titles (2026-09-02). Merged per explicit repo-owner
# decisions: where a title appeared in both her lists, the newer
# star-rated list superseded the older qualitative one (resolved a
# direct contradiction on A Court of Frost and Starlight: hated vs.
# 4.0/liked), and stars map to our tiers via an even linear split
# (5=loved, 4-4.5=liked, 3-3.75=it_was_okay, 2-2.75=disliked, 1=hated).
# See data/ratings/osnat.json's _meta for the full merge notes.
#
# The negative-signal gap flagged in the 18-book version is now
# partially closed: When the Moon Hatched, Daughter of No Worlds, and
# Magic Burns are all newly tagged and all rated hated -- 4 negative
# examples total now (with The Midnight Library), instead of 1. ---
OSNAT_RATINGS = load_rater("osnat")
OSNAT_TAGGED_TITLES = [
    "A Court of Frost and Starlight", "A Court of Mist and Fury", "A Court of Silver Flames",
    "A Court of Thorns and Roses", "A Court of Wings and Ruin", "A Wrinkle in Time",
    "Divergent", "Eclipse", "Ender's Game", "Fourth Wing",
    "Harry Potter and the Chamber of Secrets", "Harry Potter and the Deathly Hallows",
    "Harry Potter and the Goblet of Fire", "Harry Potter and the Half-Blood Prince",
    "Harry Potter and the Order of the Phoenix", "Harry Potter and the Prisoner of Azkaban",
    "Harry Potter and the Philosopher's Stone", "Iron Flame",
    "The Midnight Library",  # from List 1
    "An Absolutely Remarkable Thing", "Divine Rivals", "From Blood and Ash",
    "When the Moon Hatched", "The Assassin and the Healer", "Magic Bites",
    "Ruthless Vows", "Daughter of No Worlds", "The Serpent and the Wings of Night",
    "Magic Burns", "A Questionable Client",
]
OSNAT_USABLE = {t: OSNAT_RATINGS[t] for t in OSNAT_TAGGED_TITLES}
OSNAT_HELD_OUT = [
    "A Court of Wings and Ruin", "Harry Potter and the Half-Blood Prince",
    "Harry Potter and the Goblet of Fire", "Divergent", "Iron Flame",
    "Daughter of No Worlds", "Magic Burns",  # new: test the newly-available negative signal
]

# --- Scenario 5: third rater, Dandan -- 32 ratings via tools/rate-books/,
# the public intake form, 2026-09-02 (see data/ratings/dandan.json's
# _meta). Heavily Wheel of Time/Mistborn/Ender's Saga, skewed positive.
# Held-out list picked to keep at least 2 of her 3 negative-tier ratings
# in TRAINING (only The Path of Daggers, her one "hated," is held out)
# so the calibrated Poor threshold has enough negative signal to compute
# a meaningful midpoint from -- holding out ALL her negative ratings at
# once would make this scenario untestable for hated_rejection, same
# failure mode already documented for Osnat's early rounds. ---
DANDAN_RATINGS = load_rater("dandan")
DANDAN_HELD_OUT = [
    "The Path of Daggers", "The Way of Kings", "Words of Radiance",
    "Mistborn: The Final Empire", "The Hero of Ages", "Ender's Shadow",
    "Shadows of Self",
]

# --- Scenario 6: fourth rater, Gabriel Lempert -- 7 ratings via
# tools/rate-books/, 2026-09-02. Not on the original expected-raters
# list (Osnat/Dandan/Omri/Irael/Shahar) -- an independent friend
# submission, used anyway per explicit repo-owner instruction. Too few
# for a real held-out split -- run as leave-one-out, same treatment
# Osnat's round-1 4-book list got. ---
GABRIEL_RATINGS = load_rater("gabriel")


def run_leave_one_out_diagnostic(catalog, ratings, label, quiet=False):
    """For each title in `ratings`, trains on the rest and scores it --
    a sanity check for a rater with too few usable ratings for a real
    held-out split (see scenario 4's comment above for why n this small
    can't support a real accuracy test). Returns rows in the same shape
    run_held_out_test() does, so pairwise_accuracy()/recall_and_rejection()/
    scorecard_row() all work on it unchanged.

    Uses R.user_calibrated_poor_threshold() per leave-one-out iteration,
    same as run_held_out_test() -- each training set gets its own
    calibration, consistent with how a real profile would actually be
    built."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    rows = []
    if not quiet:
        print(f"  {label}:")
    for held_out_title, true in ratings.items():
        train = {t: r for t, r in ratings.items() if t != held_out_title}
        centroid, weights, id_to_mag, _ = R._resolve_profile(catalog, train)
        poor_threshold = R.user_calibrated_poor_threshold(catalog, id_to_mag, centroid, weights)
        validated = R.validated_dealbreaker_fields(catalog, id_to_mag)
        book = catalog[title_to_id[held_out_title]]
        score = _full_score(catalog, id_to_mag, validated, centroid, weights, book)
        pred = R.match_label(score, poor_threshold)
        v = verdict(true, pred)
        rows.append((held_out_title, true, score, pred, v))
        if not quiet:
            print(f"    {held_out_title:<35} true={true:<12} {score:.3f} ({pred}) {v}")
    return rows


# Computed ONCE (pure function of the catalog, not of any user's
# profile) and reused across every _full_score() call, rather than
# recomputed per candidate -- see
# R._series_trajectory_penalty_factor()'s own docstring.
_SERIES_DNA_CACHE = None


def _full_score(catalog, id_to_magnitude, validated_fields, centroid, weights, book):
    """score_book() + _apply_series_repeat() + _apply_dealbreaker_veto()
    (2026-09-02, the veto/cap mechanism -- option #2 from the
    aggregation-shape design discussion) + _apply_series_trajectory_penalty()
    (2026-09-04, LANDED -- see docs/scoring-test-protocol.md), in the
    same order recommend()/explain_match() apply them. Centralized here
    so every scenario in this file reflects the real production scoring
    pipeline -- the same gap that was caught and fixed for the
    calibrated threshold applies here too: a benchmark that doesn't
    call these would silently test a DIFFERENT pipeline than what a
    live user actually sees.

    A symmetric "validated positive floor" (mirror of the veto, floors
    instead of caps) was designed and tested here 2026-09-03, then
    REVERTED -- see docs/scoring-test-protocol.md's qualitative-review-
    round-2 entry for the full writeup. Short version: a floor can only
    ever pull a LOW score UP to a fixed value; it can never re-order two
    candidates that already both clear that value, which is exactly the
    case for every real book this was meant to help (Jade City, Blood
    Over Bright Haven -- already 0.81+, nowhere near the floor). Zero
    effect across all 4 real raters' full benchmark, and testing it
    against the WEIGHT_CAP_RATINGS domination scenario also caught a
    real regression before it could ship: a field with PARTIAL nominal
    credit (see nominal_similarity()) could register as both a validated
    match and a validated mismatch on the same field simultaneously,
    letting the floor silently undo the veto's cap on Children of Dune
    et al. Not worth keeping half-built dead code around for a
    mechanism that's structurally the wrong shape for the problem it
    targeted -- removed rather than left unwired.

    A "correlated-field redundancy group" discount was designed and
    tested here 2026-09-04, then also REVERTED -- see
    docs/scoring-test-protocol.md's "Group-redundancy discount" entry.
    Found a real regression in the author-isolated scenario, traced to
    a genuine conceptual flaw (population-level field correlation
    doesn't imply a specific candidate's simultaneous match on both is
    redundant evidence) rather than a parameter to retune -- removed."""
    global _SERIES_DNA_CACHE
    if _SERIES_DNA_CACHE is None:
        _SERIES_DNA_CACHE = R.compute_series_dna(catalog)
    score, _ = R.score_book(book, centroid, weights)
    score = R._apply_series_repeat(catalog, id_to_magnitude, book, score)
    score = R._apply_dealbreaker_veto(catalog, id_to_magnitude, validated_fields, book, centroid, weights, score)
    score = R._apply_series_trajectory_penalty(_SERIES_DNA_CACHE, book, centroid, weights, score)
    return score


def verdict(true_label, predicted_label):
    if true_label in EXPECT_GOOD:
        return "OK" if predicted_label in ("Strong match", "Good match") else "MISS"
    if true_label in EXPECT_POOR:
        return "OK" if predicted_label == "Poor match" else "MISS"
    return "OK" if predicted_label == "Mixed match" else "SOFT-MISS"


def run_held_out_test(catalog, all_ratings, held_out, label, quiet=False, train_ratings=None, summary=True):
    """Trains on all_ratings minus held_out (or on train_ratings directly,
    if given -- for a fixed smaller training set like SPARSE_RATINGS,
    where all_ratings is only used to look up held-out titles' true
    labels, not as the training pool itself). Scores each held-out
    title, reports directional correctness. Returns (correct, total, rows).
    summary=False also suppresses the trailing "N/M correct" line, for
    callers (e.g. build_scorecard) collecting rows into their own report
    rather than printing this test's output directly.

    Uses R.user_calibrated_poor_threshold() (2026-09-02 landed fix) for
    the Poor/Mixed boundary rather than the flat 0.35 default -- this is
    now real production behavior (explain_match() uses the same
    function), so the benchmark should reflect what a live user actually
    sees, not the pre-fix baseline. See docs/scoring-test-protocol.md's
    "Poor-match threshold diagnostic" section for the numbers that
    justified this."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    train = train_ratings if train_ratings is not None else {
        t: r for t, r in all_ratings.items() if t not in held_out
    }
    centroid, weights, id_to_magnitude, _ = R._resolve_profile(catalog, train)
    poor_threshold = R.user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights)
    validated = R.validated_dealbreaker_fields(catalog, id_to_magnitude)
    correct = wrong = soft = 0
    rows = []
    for title in held_out:
        book = catalog[title_to_id[title]]
        score = _full_score(catalog, id_to_magnitude, validated, centroid, weights, book)
        pred = R.match_label(score, poor_threshold)
        true = all_ratings[title]
        v = verdict(true, pred)
        if v == "OK":
            correct += 1
        elif v == "MISS":
            wrong += 1
        else:
            soft += 1
        rows.append((title, true, score, pred, v))
        if not quiet:
            print(f"    {title:<28} {true:<12} {score:.3f} {pred:<14} {v}")
    total = len(held_out)
    if summary:
        print(f"  {label}: {correct}/{total} correct, {wrong} wrong, {soft} soft-miss")
    return correct, total, rows


def pairwise_accuracy(rows):
    """Pairwise preference accuracy over a set of already-scored held-out
    rows (as returned by run_held_out_test): for every pair of books with
    a DIFFERENT true rating, does the predicted score rank them in the
    same direction? Ties in true rating are excluded (no real preference
    to check against).

    Motivation: a held-out set of 11 books gives you 11 independent
    bucket verdicts, but up to C(11,2)=55 pairwise comparisons -- much
    more statistical power from the same data, which matters given how
    small every real rater's set currently is (see
    docs/scoring-test-protocol.md's repeated "don't conclude from a
    single-rater test" caveat). Returns (correct, total)."""
    correct = total = 0
    for i in range(len(rows)):
        for j in range(i + 1, len(rows)):
            _, true_i, score_i, _, _ = rows[i]
            _, true_j, score_j, _, _ = rows[j]
            mag_i, mag_j = R.RATING_LABELS[true_i], R.RATING_LABELS[true_j]
            if mag_i == mag_j:
                continue
            total += 1
            if (score_i > score_j) == (mag_i > mag_j):
                correct += 1
    return correct, total


def recall_and_rejection(rows):
    """Splits already-computed held-out rows into two directional rates
    that a single blended correct/wrong count can hide:

    - loved_recall: of truly loved/liked held-out books, what fraction
      scored Good/Strong match? (the system's ability to surface books
      a reader would actually enjoy)
    - hated_rejection: of truly hated/disliked held-out books, what
      fraction scored Poor match? (its ability to recognize personal
      dealbreakers, not just find generally-appealing books)

    A system can look decent on blended accuracy while being lopsided on
    one of these -- see the ChatGPT brainstorm discussion this was added
    for for why that's worth catching separately. Returns
    {"loved_recall": (hits, n), "hated_rejection": (hits, n)}."""
    good = [r for r in rows if r[1] in EXPECT_GOOD]
    poor = [r for r in rows if r[1] in EXPECT_POOR]
    return {
        "loved_recall": (sum(1 for r in good if r[4] == "OK"), len(good)),
        "hated_rejection": (sum(1 for r in poor if r[4] == "OK"), len(poor)),
    }


def _isolated_training_set(catalog, all_ratings, held_out, isolate_by):
    """Removes not just the held-out titles but every OTHER rated title
    that shares a series (isolate_by="series") or author
    (isolate_by="author") with one of them -- so a held-out prediction
    can't be answered by "I've already seen this series/author," only by
    genuine DNA-field similarity.

    This matters concretely here: Royal Assassin and Assassin's Quest are
    both held out in REAL_HELD_OUT while Assassin's Apprentice (same
    series, also disliked) stays in training -- the series-repeat signal
    (see docs/scoring-test-protocol.md, "landed" table) is specifically
    designed to use that kind of same-series evidence, so the normal
    held-out test partly measures series memory, not just DNA
    generalization. Osnat's set has the same shape via ACOTAR/Harry
    Potter/Fourth Wing/Kate Daniels. Isolating strips that out to see
    what's left."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    held_out_ids = [title_to_id[t] for t in held_out if t in title_to_id]
    if isolate_by == "series":
        keys = {catalog[bid]["series_id"] for bid in held_out_ids if catalog[bid].get("series_id")}
        def is_linked(bid):
            return catalog[bid].get("series_id") in keys
    elif isolate_by == "author":
        keys = {catalog[bid]["author"] for bid in held_out_ids}
        def is_linked(bid):
            return catalog[bid].get("author") in keys
    else:
        raise ValueError(f"unknown isolate_by: {isolate_by!r}")

    train = {}
    for title, label in all_ratings.items():
        if title in held_out:
            continue
        bid = title_to_id.get(title)
        if bid is not None and is_linked(bid):
            continue
        train[title] = label
    return train


def run_isolated_held_out_test(catalog, all_ratings, held_out, label, isolate_by="series", quiet=False, summary=True):
    """Same as run_held_out_test, but trained on the series/author-isolated
    pool from _isolated_training_set() instead of the normal
    all-minus-held-out pool. Returns (correct, total, rows), same shape as
    run_held_out_test, so callers (e.g. the scorecard) can treat both
    uniformly."""
    train = _isolated_training_set(catalog, all_ratings, held_out, isolate_by)
    return run_held_out_test(catalog, all_ratings, held_out, label, quiet=quiet, train_ratings=train, summary=summary)


def run_weight_cap_check(catalog, label):
    """Reports person/pov_count weight vs. the largest trope weight --
    the domination check. person/pov_count each dwarfing every trope
    (as in the original 2026-08-29 bug) is a FAIL; both landing near or
    below typical trope magnitude (~0.4-0.5) is a PASS.

    Since 2026-09-01's conditional redundancy discount, the raw weights
    dict from build_profile() is context-free (undiscounted) -- the
    discount only applies per-candidate inside score_book()/
    explain_book(), conditional on that specific book's own field
    values. So this checks the ACTUAL per-book contribution for a
    representative person=first candidate (Assassin's Apprentice, one
    of this scenario's own disliked ratings -- fine for checking the
    mechanism fires correctly, even though it's not a fair held-out
    prediction test), not the raw weights dict."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    ids = {title_to_id[t]: R.RATING_LABELS[r] for t, r in WEIGHT_CAP_RATINGS.items()}
    centroid, weights = R.build_profile(catalog, ids)
    max_trope = max((abs(w) for w in weights.get("tropes", {}).values()), default=0)
    candidate = catalog[title_to_id["Assassin's Apprentice"]]
    # Assassin's Apprentice mismatches person/pov_count against this
    # profile's (multi-POV/third-person) centroid -- score_book()'s
    # "contribution" measures the MATCH pull (w_eff * sim), which is
    # near-zero here simply because sim is near-zero, not because the
    # weight is suppressed. explain_book()'s mismatch magnitude
    # (w_eff * (1-sim)) is what actually reflects the field's real,
    # dominance-relevant weight.
    matches, mismatches = R.explain_book(candidate, centroid, weights, top_n=30)
    mismatch_map = dict(mismatches)
    person_mismatch = mismatch_map.get("person", 0)
    pov_mismatch = mismatch_map.get("pov_count", 0)
    print(f"  {label}: person mismatch={person_mismatch:.3f}  pov_count mismatch={pov_mismatch:.3f}  max_trope weight={max_trope:.3f}")
    return person_mismatch, pov_mismatch, max_trope


# --- Scorecard --------------------------------------------------------
# One row per named test; each row reports the four metrics below, all
# derived from the same held-out `rows` (no separate retraining needed).
#
# Targets below are NOT aspirational round numbers -- they're calibrated
# off this suite's actual 2026-09-02 baseline run (see
# docs/scoring-test-protocol.md's "Benchmark scorecard" section for the
# real numbers this was set from), the same way match_label()'s
# thresholds are documented as a provisional first pass. Where the
# baseline already cleared a plausible bar (pairwise accuracy ~61-72%,
# loved recall 75-100%), the target sits close to current performance --
# those dimensions are already reasonably healthy, and the point of a
# target is to catch regressions, not manufacture a gap that isn't real.
# Where the baseline was clearly weak, the target is deliberately set
# ABOVE current performance as a real bar to close, not padded down to
# whatever the baseline already does -- hated_rejection landed at 0%
# across every single row of the 2026-09-02 baseline (it has NEVER
# correctly flagged a held-out hated/disliked book as "Poor match" for
# either rater, in any variant), which is this scorecard's single most
# actionable finding: the system currently cannot recognize a personal
# dealbreaker at all, only find generally-appealing books. Revisit these
# targets as more rater data comes in.
#
# Isolated/sparse rows get a deliberately lower bar than "full": they're
# testing a harder question (genuine DNA generalization without
# series/author memory, or with less evidence) than the full blended
# rows, so holding them to the same target would conflate "the model got
# worse" with "this question is inherently harder."
SCORECARD_TARGETS = {
    "full": {"bucket_accuracy": 0.55, "pairwise_accuracy": 0.70, "loved_recall": 0.75, "hated_rejection": 0.40},
    "sparse": {"bucket_accuracy": 0.45, "pairwise_accuracy": 0.60, "loved_recall": 0.65, "hated_rejection": 0.30},
    "isolated": {"bucket_accuracy": 0.40, "pairwise_accuracy": 0.55, "loved_recall": 0.65, "hated_rejection": 0.25},
}


def _pct(hits, n):
    return None if n == 0 else hits / n


def _fmt_pct(p):
    return "n/a" if p is None else f"{p:.0%}"


def _metrics_from_rows(rows):
    """The 4 scorecard metrics computed from one set of already-scored
    held-out rows -- shared by scorecard_row() and the ablation study
    below so both draw from one definition."""
    bucket_hits = sum(1 for r in rows if r[4] == "OK")
    pw_hits, pw_n = pairwise_accuracy(rows)
    rr = recall_and_rejection(rows)
    return {
        "bucket_accuracy": _pct(bucket_hits, len(rows)),
        "pairwise_accuracy": _pct(pw_hits, pw_n),
        "loved_recall": _pct(*rr["loved_recall"]),
        "hated_rejection": _pct(*rr["hated_rejection"]),
    }


def scorecard_row(name, rows, target_key):
    return {"name": name, "target_key": target_key, "n": len(rows), **_metrics_from_rows(rows)}


def build_scorecard(catalog):
    rows = []

    # Training-set size in the row label is computed fresh each run, not
    # hardcoded -- it drifts every time more ratings are added/tagged
    # (was stale at "53" for a long stretch this session while real
    # count grew past 100; see docs/project-log.md's 2026-09-03 note).
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    full_train_size = len({t for t in REAL_RATINGS if t not in REAL_HELD_OUT and t in title_to_id})

    _, _, r = run_held_out_test(catalog, REAL_RATINGS, REAL_HELD_OUT, "Mathias, full", quiet=True, summary=False)
    rows.append(scorecard_row(f"Mathias -- full ({full_train_size} ratings)", r, "full"))

    _, _, r = run_held_out_test(catalog, REAL_RATINGS, SPARSE_HELD_OUT, "Mathias, sparse",
                                 train_ratings=SPARSE_RATINGS, quiet=True, summary=False)
    rows.append(scorecard_row("Mathias -- sparse (16 ratings)", r, "sparse"))

    _, _, r = run_isolated_held_out_test(catalog, REAL_RATINGS, REAL_HELD_OUT, "Mathias, series-isolated",
                                          isolate_by="series", quiet=True, summary=False)
    rows.append(scorecard_row("Mathias -- series-isolated", r, "isolated"))

    _, _, r = run_isolated_held_out_test(catalog, REAL_RATINGS, REAL_HELD_OUT, "Mathias, author-isolated",
                                          isolate_by="author", quiet=True, summary=False)
    rows.append(scorecard_row("Mathias -- author-isolated", r, "isolated"))

    _, _, r = run_held_out_test(catalog, OSNAT_USABLE, OSNAT_HELD_OUT, "Osnat, full", quiet=True, summary=False)
    rows.append(scorecard_row(f"Osnat -- full ({len(OSNAT_USABLE)} ratings)", r, "full"))

    _, _, r = run_isolated_held_out_test(catalog, OSNAT_USABLE, OSNAT_HELD_OUT, "Osnat, series-isolated",
                                          isolate_by="series", quiet=True, summary=False)
    rows.append(scorecard_row("Osnat -- series-isolated", r, "isolated"))

    _, _, r = run_held_out_test(catalog, DANDAN_RATINGS, DANDAN_HELD_OUT, "Dandan, full",
                                 quiet=True, summary=False)
    rows.append(scorecard_row(f"Dandan -- full ({len(DANDAN_RATINGS)} ratings)", r, "full"))

    r = run_leave_one_out_diagnostic(catalog, GABRIEL_RATINGS, "Gabriel, LOO", quiet=True)
    rows.append(scorecard_row(f"Gabriel -- LOO ({len(GABRIEL_RATINGS)} ratings)", r, "sparse"))

    return rows


def print_scorecard(scorecard):
    cols = ["bucket_accuracy", "pairwise_accuracy", "loved_recall", "hated_rejection"]
    headers = ["Test", "n", "Bucket acc.", "Pairwise acc.", "Loved recall", "Hated reject."]
    widths = [32, 3, 17, 17, 17, 17]
    print("  " + "  ".join(h.ljust(w) for h, w in zip(headers, widths)))
    print("  " + "-" * (sum(widths) + 2 * (len(widths) - 1)))
    for row in scorecard:
        target = SCORECARD_TARGETS[row["target_key"]]
        cells = [row["name"].ljust(widths[0]), str(row["n"]).ljust(widths[1])]
        for col, w in zip(cols, widths[2:]):
            val = row[col]
            if val is None:
                cell = "n/a"
            elif val >= target[col]:
                cell = f"{val:.0%} OK"
            else:
                cell = f"{val:.0%} (target {target[col]:.0%})"
            cells.append(cell.ljust(w))
        print("  " + "  ".join(cells))


# --- DNA ablation -------------------------------------------------------
# Re-runs the held-out benchmark with one field-group's weight zeroed out
# POST-HOC (after build_profile() computes it normally -- never a change
# to build_profile()/score_book() themselves), to see how much each
# group actually moves accuracy. Added specifically to chase the
# scorecard's one clear finding: hated_rejection sits at 0% across every
# scenario in the 2026-09-02 baseline (see docs/scoring-test-protocol.md)
# -- this is pointed at explaining THAT, not at re-deriving default
# weights in general.
#
# Grouped by what a real scoring decision would plausibly change
# together, not tested field-by-field -- ~30 individual fields against
# an 11-book held-out set would be almost pure noise. Groups matching a
# real question ("does tone matter," "does POV/structure matter") give a
# more stable signal from the same tiny dataset, though "more stable"
# here still means "still small-n" -- results are DIRECTIONAL evidence,
# never proof, per this doc's standing "don't conclude from a
# single-rater test" rule. Run across 3 base scenarios (Mathias full,
# Mathias sparse, Osnat full) rather than just one, for the same reason
# -- a group that moves hated_rejection for one rater but not the other
# is a real, useful finding in itself (see the results table), not a
# contradiction to resolve.
ABLATION_GROUPS = {
    "tropes": ["tropes"],
    "pace": ["overall_pace", "pace_shape"],
    "tone": ["darkness", "emotional_register", "humor_level", "message_intensity"],
    "pov_structure": ["person", "pov_count", "narrator_reliability", "timeline", "form"],
    "stakes_drive": ["drive", "stakes_scope", "personal_stakes", "narrative_closure",
                      "emotional_resolution", "ends_on_cliffhanger"],
    "content_intensity": ["romance_heat_frequency", "romance_heat_intensity",
                           "violence_frequency", "violence_intensity"],
    "craft_density": ["worldbuilding_density", "book_length", "audiobook_length",
                       "prose_density", "prose_complexity", "age_category"],
    "magic_scifi": ["magic_system_hardness", "scifi_hardness"],
}

# (base label, all_ratings pool, held-out titles, fixed train_ratings or
# None to derive it as all_ratings-minus-held_out) -- same 3 scenarios
# the scorecard already reports on for "full"/"sparse" data richness
# across both real raters; deliberately excludes the isolated variants,
# which test a different axis (series/author memory) that would combine
# combinatorially with ablation for little added signal at this n.
ABLATION_BASES = [
    ("Mathias, full", REAL_RATINGS, REAL_HELD_OUT, None),
    ("Mathias, sparse", REAL_RATINGS, SPARSE_HELD_OUT, SPARSE_RATINGS),
    ("Osnat, full", OSNAT_USABLE, OSNAT_HELD_OUT, None),
]


def _apply_ablation(weights, fields):
    """weights with each of `fields`' weight zeroed (the special key
    "tropes" empties the whole trope-weights dict instead) -- applied
    AFTER build_profile() computes weights normally. score_book() treats
    a zero weight as a no-op contribution (0 numerator, 0 added to the
    normalizing denominator), so this cleanly removes a field's voice
    without needing to delete it from the dict or touch centroid. Returns
    a new dict; doesn't mutate the input."""
    ablated = dict(weights)
    for f in fields:
        if f == "tropes":
            ablated["tropes"] = {}
        elif f in ablated:
            ablated[f] = 0.0
    return ablated


def run_ablation_held_out(catalog, all_ratings, held_out, train_ratings, ablate_fields):
    """Same mechanics as run_held_out_test, but zeroes ablate_fields'
    weight(s) right after the profile is built. Returns rows in the same
    shape run_held_out_test does.

    Recalibrates the Poor threshold AFTER ablation, against the ablated
    weights -- not reused from the un-ablated baseline. This measures
    "if this field group didn't exist at all, could the (re-calibrated)
    system still separate this rater's dislikes," which is the fair
    question when the whole point is checking whether a field group is
    load-bearing for that separation."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    train = train_ratings if train_ratings is not None else {
        t: r for t, r in all_ratings.items() if t not in held_out
    }
    centroid, weights, id_to_magnitude, _ = R._resolve_profile(catalog, train)
    weights = _apply_ablation(weights, ablate_fields)
    poor_threshold = R.user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights)
    validated = R.validated_dealbreaker_fields(catalog, id_to_magnitude)
    rows = []
    for title in held_out:
        book = catalog[title_to_id[title]]
        score = _full_score(catalog, id_to_magnitude, validated, centroid, weights, book)
        pred = R.match_label(score, poor_threshold)
        true = all_ratings[title]
        rows.append((title, true, score, pred, verdict(true, pred)))
    return rows


def run_ablation_study(catalog):
    """Returns (baselines, results): baselines is {base_name: metrics}
    for the un-ablated run of each ABLATION_BASES scenario; results is
    {group_name: {base_name: metrics}} for every (group, base) pair."""
    baselines = {}
    for name, all_ratings, held_out, train in ABLATION_BASES:
        rows = run_ablation_held_out(catalog, all_ratings, held_out, train, [])
        baselines[name] = _metrics_from_rows(rows)

    results = {}
    for group, fields in ABLATION_GROUPS.items():
        results[group] = {}
        for name, all_ratings, held_out, train in ABLATION_BASES:
            rows = run_ablation_held_out(catalog, all_ratings, held_out, train, fields)
            results[group][name] = _metrics_from_rows(rows)
    return baselines, results


def print_ablation_table(baselines, results):
    cols = ["bucket_accuracy", "pairwise_accuracy", "loved_recall", "hated_rejection"]
    headers = ["Group removed", "Base", "Bucket acc.", "Pairwise acc.", "Loved recall", "Hated reject."]
    widths = [18, 16, 15, 15, 15, 15]
    print("  Baseline (nothing removed):")
    for name, m in baselines.items():
        print(f"    {name:<16} " + "  ".join(f"{c}={_fmt_pct(m[c])}" for c in cols))
    print()
    print("  " + "  ".join(h.ljust(w) for h, w in zip(headers, widths)))
    print("  " + "-" * (sum(widths) + 2 * (len(widths) - 1)))
    for group, per_base in results.items():
        for base_name, metrics in per_base.items():
            base = baselines[base_name]
            cells = [group.ljust(widths[0]), base_name.ljust(widths[1])]
            for col, w in zip(cols, widths[2:]):
                base_val, abl_val = base[col], metrics[col]
                if base_val is None or abl_val is None:
                    cell = "n/a"
                else:
                    delta = (abl_val - base_val) * 100
                    cell = f"{abl_val:.0%} ({delta:+.0f}pp)"
                cells.append(cell.ljust(w))
            print("  " + "  ".join(cells))


# --- Poor-match threshold diagnostic ------------------------------------
# Follows directly from the ablation study's finding: hated_rejection was
# 0% no matter which field group was zeroed, so the fix wasn't in weight
# composition -- it was in match_label()'s fixed 0.35 "Poor match" cutoff
# itself. Disliked/hated held-out books scored 0.397-0.895 across every
# scenario tested (see docs/scoring-test-protocol.md) -- NEVER below
# 0.35 -- so a fixed threshold that low could mathematically never fire
# on this project's real data.
#
# LANDED 2026-09-02: R.user_calibrated_poor_threshold() (in
# scripts/recommend.py) is now real production behavior, used by
# explain_match() and, via run_held_out_test()/run_ablation_held_out()
# above, by every scenario/scorecard/ablation number in this file. This
# section keeps the comparison sweep as a permanent regression/rationale
# check, not a one-off diagnostic -- it's what justified picking
# "calibrated" over a simpler fixed-value change, and rerunning it after
# a future scoring change confirms the calibrated approach still wins.
#
# Two families compared:
#  - A fixed-value sweep (0.35 old default, 0.40, 0.45, 0.50, 0.54) --
#    the simplest possible fix, but a single global constant either
#    overfits to Mathias's score range or does nothing for Osnat's
#    (whose disliked scores run much higher, 0.72-0.90 -- no fixed
#    constant in a plausible range fixes both raters at once).
#  - The landed per-user CALIBRATED threshold (R.user_calibrated_poor_
#    threshold()): the midpoint between this specific user's own mean
#    TRAINING score on their liked/loved books vs. their disliked/hated
#    books. This is the repo owner's original idea, refined: rather than
#    a threshold relative to the CATALOG's score distribution (the repo
#    owner's initial "bottom N% of scored books" framing), it's relative
#    to THIS USER's own liked-vs-disliked score gap -- self-calibrating
#    per profile without needing a full candidate-pool scoring pass, and
#    it naturally satisfies the repo owner's own caveat: if a user has
#    rated nothing as disliked/hated, there's no disliked-score mean to
#    calibrate against, so it falls back to the fixed 0.35 default
#    rather than inventing a cutoff from pure liked-book variance (which
#    would risk exactly what the repo owner flagged -- labeling a user's
#    merely-less-loved books "Poor" when nothing in their history is
#    actually a dealbreaker). Verified below (see run_all()'s printed
#    "no-negative-signal fallback check").

FIXED_THRESHOLD_SWEEP = [0.35, 0.40, 0.45, 0.50, 0.54]


def run_threshold_diagnostic(catalog, all_ratings, held_out, train_ratings):
    """Returns {variant_label: metrics} for one base scenario, across the
    fixed-threshold sweep and the (landed) calibrated threshold, all
    derived from ONE set of raw scores (computed once) so every variant
    is compared on identical underlying predictions."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    train = train_ratings if train_ratings is not None else {
        t: r for t, r in all_ratings.items() if t not in held_out
    }
    centroid, weights, id_to_magnitude, _ = R._resolve_profile(catalog, train)
    validated = R.validated_dealbreaker_fields(catalog, id_to_magnitude)

    raw = {}
    for title in held_out:
        book = catalog[title_to_id[title]]
        raw[title] = _full_score(catalog, id_to_magnitude, validated, centroid, weights, book)

    def rows_for(threshold):
        rows = []
        for title, score in raw.items():
            true = all_ratings[title]
            pred = R.match_label(score, threshold)
            rows.append((title, true, score, pred, verdict(true, pred)))
        return rows

    variants = {f"fixed {t:.2f}" + (" (old default)" if t == 0.35 else ""): t for t in FIXED_THRESHOLD_SWEEP}
    calibrated = R.user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights)
    variants[f"calibrated ({calibrated:.3f}) -- LANDED"] = calibrated

    return {name: _metrics_from_rows(rows_for(t)) for name, t in variants.items()}


def print_threshold_diagnostic(catalog):
    cols = ["bucket_accuracy", "pairwise_accuracy", "loved_recall", "hated_rejection"]
    headers = ["Base", "Threshold variant", "Bucket acc.", "Pairwise acc.", "Loved recall", "Hated reject."]
    widths = [16, 28, 13, 13, 13, 13]
    print("  " + "  ".join(h.ljust(w) for h, w in zip(headers, widths)))
    print("  " + "-" * (sum(widths) + 2 * (len(widths) - 1)))
    for base_name, all_ratings, held_out, train in ABLATION_BASES:
        for variant, metrics in run_threshold_diagnostic(catalog, all_ratings, held_out, train).items():
            cells = [base_name.ljust(widths[0]), variant.ljust(widths[1])]
            for col, w in zip(cols, widths[2:]):
                cells.append(_fmt_pct(metrics[col]).ljust(w))
            print("  " + "  ".join(cells))
        print()

    print("  No-negative-signal fallback check (repo owner's caveat):")
    all_positive = {t: r for t, r in REAL_RATINGS.items() if r in ("loved", "liked", "it_was_okay")}
    centroid, weights, id_to_magnitude, _ = R._resolve_profile(catalog, all_positive)
    calibrated = R.user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights)
    print(f"    {len(all_positive)} all-positive ratings (no disliked/hated) -> "
          f"calibrated threshold = {calibrated:.3f} "
          f"({'falls back to default, as intended' if calibrated == 0.35 else 'DID NOT FALL BACK -- BUG'})")


# --- Dealbreaker-flag sanity check --------------------------------------
# dealbreaker_flags() (recommend.py, 2026-09-02) was validated only
# against Mathias before landing -- purely additive metadata, never
# touches score/match_label, so it shipped without the full two-scenario
# gauntlet a real scoring change needs. This closes that gap: checks the
# same fixed DEALBREAKER_THRESHOLD against the other 3 real raters'
# held-out/leave-one-out sets, reporting a false-positive rate (flags on
# truly liked/loved books -- should be rare) and a true-positive rate
# (flags on truly disliked/hated books -- the whole point of the
# feature) per rater, plus the actual flagged phrases for a manual read.

def check_dealbreaker_flags(catalog, all_ratings, held_out, train_ratings, label,
                             validated_fields_fn=None):
    """Runs dealbreaker_flags() over one scenario's held-out/LOO set.
    validated_fields_fn: optional callable(id_to_magnitude) -> set, for
    checking the statistically-validated variant (see
    validated_dealbreaker_fields() in recommend.py) instead of the fixed
    threshold alone. Returns (fp_count, fp_total, tp_count, tp_total,
    detail_rows) where detail_rows is [(title, true, flagged_phrases)]."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    train = train_ratings if train_ratings is not None else {
        t: r for t, r in all_ratings.items() if t not in held_out
    }
    centroid, weights, id_to_magnitude, _ = R._resolve_profile(catalog, train)
    validated = validated_fields_fn(id_to_magnitude) if validated_fields_fn else None

    fp = fp_total = tp = tp_total = 0
    rows = []
    for title in held_out:
        book = catalog[title_to_id[title]]
        true = all_ratings[title]
        flags = R.dealbreaker_flags(book, centroid, weights, validated_fields=validated)
        phrases = [p for f, _ in flags if (p := R.describe(f, book))]
        rows.append((title, true, phrases))
        if true in EXPECT_GOOD:
            fp_total += 1
            if flags:
                fp += 1
        elif true in EXPECT_POOR:
            tp_total += 1
            if flags:
                tp += 1
    print(f"  {label}: false-positive rate {fp}/{fp_total} (flagged on a liked/loved book) -- "
          f"true-positive rate {tp}/{tp_total} (flagged on a disliked/hated book)")
    for title, true, phrases in rows:
        if phrases:
            print(f"    {title:<35} true={true:<12} -> {'; '.join(phrases)}")
    return fp, fp_total, tp, tp_total, rows


def run_leave_one_out_flags_check(catalog, ratings, label, validated_fields_fn=None):
    """Same idea as check_dealbreaker_flags(), but leave-one-out (for a
    rater too small for a real held-out split, e.g. Gabriel)."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    fp = fp_total = tp = tp_total = 0
    rows = []
    for held_out_title, true in ratings.items():
        train = {t: r for t, r in ratings.items() if t != held_out_title}
        centroid, weights, id_to_magnitude, _ = R._resolve_profile(catalog, train)
        validated = validated_fields_fn(id_to_magnitude) if validated_fields_fn else None
        book = catalog[title_to_id[held_out_title]]
        flags = R.dealbreaker_flags(book, centroid, weights, validated_fields=validated)
        phrases = [p for f, _ in flags if (p := R.describe(f, book))]
        rows.append((held_out_title, true, phrases))
        if true in EXPECT_GOOD:
            fp_total += 1
            if flags:
                fp += 1
        elif true in EXPECT_POOR:
            tp_total += 1
            if flags:
                tp += 1
    print(f"  {label}: false-positive rate {fp}/{fp_total} (flagged on a liked/loved book) -- "
          f"true-positive rate {tp}/{tp_total} (flagged on a disliked/hated book)")
    for title, true, phrases in rows:
        if phrases:
            print(f"    {title:<35} true={true:<12} -> {'; '.join(phrases)}")
    return fp, fp_total, tp, tp_total, rows


def run_dealbreaker_sanity_check(catalog, validated_fields_fn=None):
    check_dealbreaker_flags(catalog, REAL_RATINGS, REAL_HELD_OUT, None, "Mathias",
                             validated_fields_fn=validated_fields_fn)
    check_dealbreaker_flags(catalog, OSNAT_USABLE, OSNAT_HELD_OUT, None, "Osnat",
                             validated_fields_fn=validated_fields_fn)
    check_dealbreaker_flags(catalog, DANDAN_RATINGS, DANDAN_HELD_OUT, None, "Dandan",
                             validated_fields_fn=validated_fields_fn)
    run_leave_one_out_flags_check(catalog, GABRIEL_RATINGS, "Gabriel (LOO)",
                                   validated_fields_fn=validated_fields_fn)


def run_all():
    catalog = R.load_catalog()

    print("=== Scenario 1: real-rater held-out validation ===")
    run_held_out_test(catalog, REAL_RATINGS, REAL_HELD_OUT, "held-out")

    print("\n=== Scenario 2: WEIGHT_CAP domination check ===")
    run_weight_cap_check(catalog, "current formula")

    print("\n=== Scenario 3: sparse-data check (original 16-book list) ===")
    run_held_out_test(catalog, REAL_RATINGS, SPARSE_HELD_OUT, "sparse (16 ratings)",
                       train_ratings=SPARSE_RATINGS)

    print(f"\n=== Scenario 4: second rater (Osnat) -- held-out validation ({len(OSNAT_USABLE)} usable ratings) ===")
    run_held_out_test(catalog, OSNAT_USABLE, OSNAT_HELD_OUT, "Osnat held-out")

    print(f"\n=== Scenario 4b: third rater (Dandan) -- held-out validation ({len(DANDAN_RATINGS)} ratings) ===")
    run_held_out_test(catalog, DANDAN_RATINGS, DANDAN_HELD_OUT, "Dandan held-out")

    print(f"\n=== Scenario 4c: fourth rater (Gabriel) -- leave-one-out ({len(GABRIEL_RATINGS)} ratings, too few for held-out) ===")
    run_leave_one_out_diagnostic(catalog, GABRIEL_RATINGS, "Gabriel leave-one-out")

    print("\n=== Scenario 5: series/author-isolated held-out (no series or author memory) ===")
    run_isolated_held_out_test(catalog, REAL_RATINGS, REAL_HELD_OUT, "Mathias, series-isolated", isolate_by="series")
    run_isolated_held_out_test(catalog, REAL_RATINGS, REAL_HELD_OUT, "Mathias, author-isolated", isolate_by="author")
    run_isolated_held_out_test(catalog, OSNAT_USABLE, OSNAT_HELD_OUT, "Osnat, series-isolated", isolate_by="series")

    print("\n=== Benchmark scorecard ===")
    print_scorecard(build_scorecard(catalog))

    print("\n=== Scenario 6: DNA ablation (post-hoc field-group zeroing) ===")
    baselines, results = run_ablation_study(catalog)
    print_ablation_table(baselines, results)

    print("\n=== Scenario 7: Poor-match threshold diagnostic ===")
    print_threshold_diagnostic(catalog)

    print("\n=== Scenario 8: dealbreaker-flag sanity check (fixed threshold, all 4 raters) ===")
    run_dealbreaker_sanity_check(catalog)

    print("\n=== Scenario 9: dealbreaker-flag sanity check (statistically validated, all 4 raters) ===")
    run_dealbreaker_sanity_check(
        catalog,
        validated_fields_fn=lambda id_to_mag: R.validated_dealbreaker_fields(catalog, id_to_mag),
    )

    print("\n=== Scenario 10: learning curve (accuracy vs. rating-history size) ===")
    curve = run_learning_curve(catalog, REAL_RATINGS, REAL_HELD_OUT)
    print_learning_curve(curve, "Mathias", len(REAL_HELD_OUT))

    print("\n=== Scenario 11: diversity curve (accuracy vs. author variety, size held fixed) ===")
    div_points = run_diversity_curve(catalog, REAL_RATINGS, REAL_HELD_OUT)
    print_diversity_curve(div_points, "Mathias", DIVERSITY_FIXED_SIZE)

    print("\n=== Scenario 12: contrastive pairs (near-identical DNA, opposite ratings) ===")
    run_contrastive_pairs_diagnostic(catalog, REAL_RATINGS, "Mathias")
    run_contrastive_pairs_diagnostic(catalog, OSNAT_USABLE, "Osnat")
    run_contrastive_pairs_diagnostic(catalog, DANDAN_RATINGS, "Dandan")
    run_contrastive_pairs_diagnostic(catalog, GABRIEL_RATINGS, "Gabriel")


# --- Learning curve: does accuracy actually improve with more ratings? --
# (2026-09-03) Repo owner's own question after the qualitative-review-
# round-2 critique: "if we add more books... maybe we could correlate
# the level of accuracy with the history size." REAL_HELD_OUT stays
# fixed (never trained on, across every sample) so every point on the
# curve is judged against the exact same test -- only the TRAINING pool
# size varies. Sampled repeatedly at each size (not just once) because
# a single random subset at a small size is noisy enough to make the
# curve meaningless otherwise -- see this project's repeated "don't
# conclude from one small sample" caveats elsewhere in this file.
LEARNING_CURVE_REPEATS = 15
LEARNING_CURVE_SEED = 42


def run_learning_curve(catalog, all_ratings, held_out, sizes=None, repeats=LEARNING_CURVE_REPEATS, seed=LEARNING_CURVE_SEED):
    """For each size in `sizes`, draws `repeats` random subsets of that
    size from all_ratings (excluding held_out), trains a profile on each,
    scores the SAME fixed held_out set, and averages pairwise/bucket
    accuracy across the repeats. Returns a list of
    {"size", "pairwise_accuracy", "bucket_accuracy", "n_repeats"} dicts,
    one per size actually run (a requested size larger than the
    available pool is silently skipped, not padded/clamped).

    sizes: defaults to a spread from 10 up to the full pool in ~6 steps.
    Deterministic (fixed `seed`) so this is reproducible run to run, not
    a different curve every time out of pure sampling luck.

    Only draws from ratings for books actually IN `catalog` (i.e.
    tagged) -- a rating can exist in all_ratings for a book that's been
    ingested bibliographically but not yet tagged (see
    docs/project-log.md's 2026-09-03 targeted-ingestion entries), which
    _resolve_profile() already handles gracefully elsewhere (warns and
    skips), but this function samples titles directly rather than going
    through it, so it needs the same filter itself -- otherwise `size`
    would silently overstate how many books actually fed the profile."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    pool = {t: r for t, r in all_ratings.items() if t not in held_out and t in title_to_id}
    pool_titles = list(pool.keys())
    max_size = len(pool_titles)

    if sizes is None:
        step = max(5, max_size // 6)
        sizes = list(range(10, max_size, step)) + [max_size]
        sizes = sorted(set(s for s in sizes if s <= max_size))

    rng = random.Random(seed)
    curve = []
    for size in sizes:
        if size > max_size:
            continue
        pw_hits_total = pw_n_total = bucket_hits_total = 0
        n_repeats = 1 if size == max_size else repeats
        for _ in range(n_repeats):
            sample_titles = pool_titles if size == max_size else rng.sample(pool_titles, size)
            train = {t: pool[t] for t in sample_titles}
            _, _, rows = run_held_out_test(catalog, all_ratings, held_out, None,
                                            train_ratings=train, summary=False, quiet=True)
            pw_hits, pw_n = pairwise_accuracy(rows)
            pw_hits_total += pw_hits
            pw_n_total += pw_n
            bucket_hits_total += sum(1 for r in rows if r[4] == "OK")
        curve.append({
            "size": size,
            "pairwise_accuracy": _pct(pw_hits_total, pw_n_total),
            "bucket_accuracy": _pct(bucket_hits_total, n_repeats * len(held_out)),
            "n_repeats": n_repeats,
        })
    return curve


def print_learning_curve(curve, label, held_out_size):
    print(f"  {label} (held-out set fixed at {held_out_size} books, "
          f"up to {LEARNING_CURVE_REPEATS} random samples per size):")
    print(f"    {'Train size':<12} {'Pairwise acc.':<16} {'Bucket acc.':<14} {'Repeats'}")
    for point in curve:
        print(f"    {point['size']:<12} {_fmt_pct(point['pairwise_accuracy']):<16} {_fmt_pct(point['bucket_accuracy']):<14} {point['n_repeats']}")


# --- Diversity: at a FIXED size, does the VARIETY of a rating history --
# (distinct authors, not just count) predict accuracy, independent of
# size itself? (2026-09-03) The learning-curve above only varies sample
# SIZE via plain random draws -- it can't answer this, since a random
# draw's diversity is just whatever falls out of the pool by chance, not
# a controlled variable. Fixing size and varying diversity as the thing
# actually measured isolates the question the repo owner asked.
DIVERSITY_FIXED_SIZE = 40
DIVERSITY_NUM_SAMPLES = 40
DIVERSITY_SEED = 7


def run_diversity_curve(catalog, all_ratings, held_out, size=DIVERSITY_FIXED_SIZE,
                         num_samples=DIVERSITY_NUM_SAMPLES, seed=DIVERSITY_SEED):
    """Draws `num_samples` random subsets, ALL of the same fixed `size`,
    from all_ratings (excluding held_out). For each, records how many
    DISTINCT authors happen to be in that draw (the diversity metric --
    a size-40 draw pulling from 35 different authors is a much more
    varied slice of taste than one where the same 8 authors' books repeat
    5x each) alongside its held-out pairwise/bucket accuracy against the
    same fixed held_out set the learning curve uses. Author count, not
    series count, is the primary metric -- series-diversity is highly
    correlated with author-diversity for most authors in this catalog
    (one series each) and author is the more direct proxy for "how many
    genuinely different voices/styles is this profile built from."

    Returns a list of {"n_authors", "size", "pairwise_accuracy",
    "bucket_accuracy"} dicts, one per sample (NOT averaged/bucketed --
    the caller decides how to summarize, since both a raw correlation
    and a tercile breakdown are useful views of the same data).

    Only draws from ratings for books actually IN `catalog` (i.e.
    tagged) -- see run_learning_curve()'s docstring for why this filter
    is needed here specifically (this function looks up `catalog`
    directly for the author-count metric, so an untagged-but-rated
    title would KeyError rather than being silently skipped the way
    _resolve_profile() handles it elsewhere)."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    pool = {t: r for t, r in all_ratings.items() if t not in held_out and t in title_to_id}
    pool_titles = list(pool.keys())

    rng = random.Random(seed)
    points = []
    for _ in range(num_samples):
        sample_titles = rng.sample(pool_titles, size)
        train = {t: pool[t] for t in sample_titles}
        n_authors = len({catalog[title_to_id[t]]["author"] for t in sample_titles})
        _, _, rows = run_held_out_test(catalog, all_ratings, held_out, None,
                                        train_ratings=train, summary=False, quiet=True)
        pw_hits, pw_n = pairwise_accuracy(rows)
        bucket_hits = sum(1 for r in rows if r[4] == "OK")
        points.append({
            "n_authors": n_authors,
            "pairwise_accuracy": _pct(pw_hits, pw_n),
            "bucket_accuracy": _pct(bucket_hits, len(held_out)),
        })
    return points


def print_diversity_curve(points, label, size):
    print(f"  {label} (fixed train size={size}, {len(points)} random samples, "
          f"varying only in how many distinct authors happen to appear):")

    authors = [p["n_authors"] for p in points]
    pw = [p["pairwise_accuracy"] for p in points]
    bucket = [p["bucket_accuracy"] for p in points]

    if len(set(authors)) > 1:
        r_pw = statistics.correlation(authors, pw)
        r_bucket = statistics.correlation(authors, bucket)
        print(f"    Pearson r (distinct authors vs. pairwise accuracy): {r_pw:+.3f}")
        print(f"    Pearson r (distinct authors vs. bucket accuracy):   {r_bucket:+.3f}")
    else:
        print("    (no variance in author count across samples -- correlation undefined)")

    # Tercile breakdown -- easier to read than a bare correlation
    # coefficient, and more robust to a couple of outlier samples.
    ranked = sorted(points, key=lambda p: p["n_authors"])
    n = len(ranked)
    third = max(1, n // 3)
    low, mid, high = ranked[:third], ranked[third:n - third], ranked[n - third:]
    print(f"    {'Author-diversity tercile':<28} {'n_authors range':<18} {'Pairwise acc.':<16} {'Bucket acc.'}")
    for name, bucket_pts in [("Low", low), ("Mid", mid), ("High", high)]:
        if not bucket_pts:
            continue
        lo_a = min(p["n_authors"] for p in bucket_pts)
        hi_a = max(p["n_authors"] for p in bucket_pts)
        avg_pw = sum(p["pairwise_accuracy"] for p in bucket_pts) / len(bucket_pts)
        avg_bucket = sum(p["bucket_accuracy"] for p in bucket_pts) / len(bucket_pts)
        print(f"    {name:<28} {f'{lo_a}-{hi_a}':<18} {_fmt_pct(avg_pw):<16} {_fmt_pct(avg_bucket)}")


# --- Before tagging a NEW field: would validated_dealbreaker_fields() --
# even be able to detect it? (2026-09-03) The repo owner's own question
# ("give random fictional values, see if anything moves") pointed at a
# real, reusable pre-check worth running before paying any tagging cost
# for a brand-new field/trope, not just message_themes. Two separate
# questions, answered by two separate simulations:
#
# 1. FALSE-POSITIVE risk: does the current STAT_SEPARATION_THRESHOLD
#    ever validate pure noise, and does that risk change with sample
#    size? (a literal version of the repo owner's random-label idea)
# 2. DETECTION POWER: if a field's real effect size matches this user's
#    STRONGEST already-known real dealbreaker, would the current
#    machinery reliably catch it, or would it plausibly get missed by
#    sampling noise even though it's real? (the question random labels
#    alone can NEVER answer, since random labels carry no real signal
#    to detect in the first place)
#
# A pure random-label test answers #1 (worth doing -- it's cheap and
# real) but NOT #2, because #2 requires a KNOWN true effect to check
# detection against, and noise has no true effect by construction.
# Skipping #2 would leave the actually load-bearing question --
# "is it even worth tagging books for this idea" -- unanswered.
def simulate_field_validation(catalog, id_to_magnitude, n_values=2, trials=2000, seed=0):
    """Question 1 (false-positive risk): injects a fake nominal field
    with `n_values` uniformly-random fictional values (default 2, i.e.
    a boolean-style trope-like field -- the noisiest realistic case)
    onto every book in `id_to_magnitude`, `trials` times, and reports
    what fraction of trials spuriously clear STAT_SEPARATION_THRESHOLD
    purely by chance. Returns (false_positive_rate, max_abs_separation_seen)."""
    import random as _random
    rng = _random.Random(seed)
    values = ["v", "w", "x", "y", "z"][:n_values]
    false_positives = 0
    max_sep = 0.0
    for _ in range(trials):
        assignment = {bid: rng.choice(values) for bid in id_to_magnitude}
        fake_catalog = {
            bid: {**book, "_sim_field": assignment[bid]} if bid in assignment else book
            for bid, book in catalog.items()
        }
        sep = R._nominal_field_separation(fake_catalog, id_to_magnitude, "_sim_field")
        if sep is not None:
            max_sep = max(max_sep, abs(sep))
            if abs(sep) >= R.STAT_SEPARATION_THRESHOLD:
                false_positives += 1
    return false_positives / trials, max_sep


def simulate_detection_power(catalog, id_to_magnitude, true_separation, trials=2000, seed=1):
    """Question 2 (detection power): plants a REAL effect of the given
    magnitude (a 'theme present' value shown at rates chosen so
    liked_share - disliked_share == true_separation exactly in
    expectation) across ALL of `id_to_magnitude`, `trials` times, and
    reports what fraction of trials actually clear
    STAT_SEPARATION_THRESHOLD -- i.e. how often a real signal this
    strong would be CAUGHT, not missed to sampling noise. Uses this
    user's REAL liked/disliked group sizes (not a hypothetical larger
    or smaller sample) -- the point is to answer "would it work with
    the data we actually have," not a generic power calculation."""
    import random as _random
    rng = _random.Random(seed)
    liked_ids = [bid for bid, m in id_to_magnitude.items() if m > 0]
    disliked_ids = [bid for bid, m in id_to_magnitude.items() if m < 0]
    # Split true_separation between the two groups around a 50/50
    # baseline so the effect isn't driven entirely by one side.
    p_liked = max(0.0, 0.5 - true_separation / 2)
    p_disliked = min(1.0, 0.5 + true_separation / 2)
    detected = 0
    for _ in range(trials):
        assignment = {}
        for bid in liked_ids:
            assignment[bid] = "present" if rng.random() < p_liked else "absent"
        for bid in disliked_ids:
            assignment[bid] = "present" if rng.random() < p_disliked else "absent"
        fake_catalog = {
            bid: {**book, "_sim_field": assignment[bid]} if bid in assignment else book
            for bid, book in catalog.items()
        }
        sep = R._nominal_field_separation(fake_catalog, id_to_magnitude, "_sim_field")
        if sep is not None and abs(sep) >= R.STAT_SEPARATION_THRESHOLD:
            detected += 1
    return detected / trials


# --- Contrastive pairs: books with near-identical DNA but opposite -----
# ratings (2026-09-04). Repo owner's own proposal, generalized to work
# on ANY rater's data automatically (not hardcoded to specific titles):
# find_contrastive_pairs() scans every pair of a rater's OWN rated books
# for high objective DNA similarity (book_similarity() -- unweighted,
# not personalized) combined with a large rating-magnitude gap. Since
# most fields are held constant in such a pair, whatever DIFFERS is
# disproportionately likely to be the real driver of the differing
# reaction -- much more information-dense than an average unrelated
# pair, and a natural, sharp diagnostic for "is the model using the
# real signal when one exists, or is the DNA schema simply missing the
# actual differentiator." Two known examples surfaced BY HAND before
# this was generalized (see docs/project-log.md's 2026-09-04 "structural
# issues" entry): The Grey Bastards/The True Bastards (near-DNA-twins,
# loved/hated -- the model fails, likely a real DNA representation gap
# around protagonist identity) and The Name of the Wind/The Wise Man's
# Fear (real DNA differences exist -- pace_shape, personal_stakes, two
# new romance tropes in book 2 -- and the model correctly ranks them).
CONTRASTIVE_MIN_SIMILARITY = 0.85
CONTRASTIVE_MIN_RATING_GAP = 1.0  # e.g. loved(1.0) vs hated(-1.0) = 2.0; loved vs disliked = 1.5; liked vs hated = 1.5


def find_contrastive_pairs(catalog, ratings, min_similarity=CONTRASTIVE_MIN_SIMILARITY,
                            min_rating_gap=CONTRASTIVE_MIN_RATING_GAP, max_pairs=20):
    """Returns up to max_pairs dicts, sorted by (similarity desc, gap
    desc): {"book_a", "book_b", "similarity", "rating_a", "rating_b",
    "gap", "dna_diffs": {field: (val_a, val_b)}, "tropes_only_a",
    "tropes_only_b"}. O(n^2) over this rater's rated-and-tagged books --
    fine at real rater sizes (hundreds, not tens of thousands)."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    rated_ids = [title_to_id[t] for t in ratings if t in title_to_id]
    pairs = []
    for i in range(len(rated_ids)):
        for j in range(i + 1, len(rated_ids)):
            book_a, book_b = catalog[rated_ids[i]], catalog[rated_ids[j]]
            title_a, title_b = book_a["title"], book_b["title"]
            mag_a, mag_b = R.RATING_LABELS[ratings[title_a]], R.RATING_LABELS[ratings[title_b]]
            gap = abs(mag_a - mag_b)
            if gap < min_rating_gap:
                continue
            sim = R.book_similarity(book_a, book_b)
            if sim < min_similarity:
                continue
            dna_diffs = {}
            for field in list(R.ORDINAL_FIELDS) + list(R.NOMINAL_FIELDS):
                va, vb = book_a.get(field), book_b.get(field)
                if va is not None and vb is not None and va != vb:
                    dna_diffs[field] = (va, vb)
            ta, tb = set(book_a.get("tropes") or []), set(book_b.get("tropes") or [])
            pairs.append({
                "book_a": title_a, "book_b": title_b, "similarity": round(sim, 3),
                "rating_a": ratings[title_a], "rating_b": ratings[title_b], "gap": gap,
                "dna_diffs": dna_diffs,
                "tropes_only_a": sorted(ta - tb), "tropes_only_b": sorted(tb - ta),
            })
    pairs.sort(key=lambda p: (-p["similarity"], -p["gap"]))
    return pairs[:max_pairs]


def check_contrastive_pair_ranking(catalog, all_ratings, pair):
    """Trains on all_ratings minus BOTH books in the pair, scores both
    through the real production pipeline (_full_score()), and checks
    whether the model correctly ranks the higher-rated book above the
    lower-rated one. Returns `pair` with "score_a", "score_b",
    "correctly_ranked" added."""
    title_a, title_b = pair["book_a"], pair["book_b"]
    train = {t: r for t, r in all_ratings.items() if t not in (title_a, title_b)}
    centroid, weights, id_to_mag, _ = R._resolve_profile(catalog, train)
    validated = R.validated_dealbreaker_fields(catalog, id_to_mag)
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    score_a = _full_score(catalog, id_to_mag, validated, centroid, weights, catalog[title_to_id[title_a]])
    score_b = _full_score(catalog, id_to_mag, validated, centroid, weights, catalog[title_to_id[title_b]])
    mag_a = R.RATING_LABELS[pair["rating_a"]]
    mag_b = R.RATING_LABELS[pair["rating_b"]]
    correctly_ranked = (mag_a > mag_b) == (score_a > score_b)
    return {**pair, "score_a": round(score_a, 4), "score_b": round(score_b, 4), "correctly_ranked": correctly_ranked}


def run_contrastive_pairs_diagnostic(catalog, ratings, label):
    pairs = find_contrastive_pairs(catalog, ratings)
    print(f"  {label}: {len(pairs)} contrastive pair(s) found "
          f"(DNA similarity >= {CONTRASTIVE_MIN_SIMILARITY}, rating gap >= {CONTRASTIVE_MIN_RATING_GAP})")
    correct = 0
    for pair in pairs:
        result = check_contrastive_pair_ranking(catalog, ratings, pair)
        correct += result["correctly_ranked"]
        verdict = "OK" if result["correctly_ranked"] else "MISS -- model can't distinguish these"
        print(f"\n    {result['book_a']} ({result['rating_a']}, held-out score {result['score_a']}) vs "
              f"{result['book_b']} ({result['rating_b']}, held-out score {result['score_b']})  [{verdict}]")
        print(f"      DNA similarity: {result['similarity']}")
        if result["dna_diffs"]:
            print(f"      Field differences: {result['dna_diffs']}")
        else:
            print("      Field differences: NONE -- fully identical on every measured field")
        if result["tropes_only_a"]:
            print(f"      Tropes only in '{result['book_a']}': {result['tropes_only_a']}")
        if result["tropes_only_b"]:
            print(f"      Tropes only in '{result['book_b']}': {result['tropes_only_b']}")
    if pairs:
        print(f"\n  {label} summary: model correctly ranked {correct}/{len(pairs)} contrastive pairs.")


if __name__ == "__main__":
    run_all()
