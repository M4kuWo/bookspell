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

# --- Scenario 4: second rater, Osnat -- only a partial list available
# (no full Fable export), and most of it turned out to be either out of
# v1 scope (pure contemporary romance) or in-scope-but-not-yet-ingested
# (paranormal/fantasy romance -- a real catalog-breadth gap, see
# data/ratings/osnat.json's _meta). Only 4 of 22 titles are both in the
# catalog and tagged -- far too few for a real held-out test (can't
# fairly split 4 points into train/test), so this uses a leave-one-out
# diagnostic instead: hold out ONE rating, train on the other 3, check
# direction. This is a sanity check that the pipeline behaves sanely for
# a brand-new rater with a very different taste profile (romantasy vs.
# the repo owner's epic fantasy/hard sci-fi), NOT a real accuracy
# measurement -- don't draw conclusions about scoring quality from this,
# only "does anything look broken." ---
OSNAT_RATINGS = load_rater("osnat")
OSNAT_USABLE = {
    "Iron Flame": "loved",
    "A Court of Frost and Starlight": "hated",
    "Fourth Wing": "loved",
    "The Midnight Library": "hated",
}


def run_leave_one_out_diagnostic(catalog, ratings, label):
    """For each title in `ratings`, trains on the rest and scores it --
    a sanity check for a rater with too few usable ratings for a real
    held-out split (see scenario 4's comment above for why n this small
    can't support a real accuracy test)."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    print(f"  {label}:")
    for held_out_title, true in ratings.items():
        train = {t: r for t, r in ratings.items() if t != held_out_title}
        centroid, weights, id_to_mag, _ = R._resolve_profile(catalog, train)
        book = catalog[title_to_id[held_out_title]]
        score, _ = R.score_book(book, centroid, weights)
        score = R._apply_series_repeat(catalog, id_to_mag, book, score)
        pred = R.match_label(score)
        v = verdict(true, pred)
        print(f"    {held_out_title:<35} true={true:<12} {score:.3f} ({pred}) {v}")


def verdict(true_label, predicted_label):
    if true_label in EXPECT_GOOD:
        return "OK" if predicted_label in ("Strong match", "Good match") else "MISS"
    if true_label in EXPECT_POOR:
        return "OK" if predicted_label == "Poor match" else "MISS"
    return "OK" if predicted_label == "Mixed match" else "SOFT-MISS"


def run_held_out_test(catalog, all_ratings, held_out, label, quiet=False, train_ratings=None):
    """Trains on all_ratings minus held_out (or on train_ratings directly,
    if given -- for a fixed smaller training set like SPARSE_RATINGS,
    where all_ratings is only used to look up held-out titles' true
    labels, not as the training pool itself). Scores each held-out
    title, reports directional correctness. Returns (correct, total, rows)."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    train = train_ratings if train_ratings is not None else {
        t: r for t, r in all_ratings.items() if t not in held_out
    }
    centroid, weights, id_to_magnitude, _ = R._resolve_profile(catalog, train)
    correct = wrong = soft = 0
    rows = []
    for title in held_out:
        book = catalog[title_to_id[title]]
        score, _ = R.score_book(book, centroid, weights)
        score = R._apply_series_repeat(catalog, id_to_magnitude, book, score)
        pred = R.match_label(score)
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
    print(f"  {label}: {correct}/{total} correct, {wrong} wrong, {soft} soft-miss")
    return correct, total, rows


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


def run_all():
    catalog = R.load_catalog()

    print("=== Scenario 1: real-rater held-out validation ===")
    run_held_out_test(catalog, REAL_RATINGS, REAL_HELD_OUT, "held-out")

    print("\n=== Scenario 2: WEIGHT_CAP domination check ===")
    run_weight_cap_check(catalog, "current formula")

    print("\n=== Scenario 3: sparse-data check (original 16-book list) ===")
    run_held_out_test(catalog, REAL_RATINGS, SPARSE_HELD_OUT, "sparse (16 ratings)",
                       train_ratings=SPARSE_RATINGS)

    print("\n=== Scenario 4: second rater (Osnat) -- leave-one-out diagnostic, NOT a real accuracy test ===")
    run_leave_one_out_diagnostic(catalog, OSNAT_USABLE, "Osnat (n=4 usable)")


if __name__ == "__main__":
    run_all()
