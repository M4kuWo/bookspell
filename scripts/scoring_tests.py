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

sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
import recommend as R

EXPECT_GOOD = {"loved", "liked"}
EXPECT_POOR = {"hated", "disliked"}

# --- Scenario 1: the repo owner's real ratings, combined across both
# test rounds this session (16-book original list + 20-item numbered
# list + resolved series/aggregate statements). Currently the ONLY real
# rater we have -- see the protocol doc for why every conclusion drawn
# from this scenario alone is provisional. ---
REAL_RATINGS = {
    "The Eye of the World": "loved", "The Way of Kings": "loved", "Dark Matter": "hated",
    "Circe": "hated", "Six of Crows": "liked", "Prince of Thorns": "loved",
    "The Blade Itself": "loved", "Red Rising": "hated", "The Gunslinger": "liked",
    "We Are Legion (We Are Bob)": "disliked", "The Poppy War": "it_was_okay",
    "Artemis": "disliked", "Children of Time": "liked", "Interview with the Vampire": "disliked",
    "Old Man's War": "liked", "The Lion, the Witch and the Wardrobe": "disliked",
    "Before They Are Hanged": "loved", "Empire of Silence": "disliked", "Storm Front": "liked",
    "The Black Prism": "it_was_okay", "The Emperor's Soul": "liked", "The Name of the Wind": "it_was_okay",
    "The Subtle Knife": "loved", "The Wise Man's Fear": "hated", "Warbreaker": "loved",
    "The Shadow of What Was Lost": "liked", "The Last Wish": "liked", "Steelheart": "loved",
    "Skyward": "disliked", "Royal Assassin": "disliked", "Ready Player One": "liked",
    "Eragon": "it_was_okay", "Assassin's Apprentice": "disliked", "A Wizard of Earthsea": "it_was_okay",
    "A Clash of Kings": "loved", "The Great Hunt": "loved", "The Dragon Reborn": "loved",
    "The Shadow Rising": "loved", "The Fires of Heaven": "loved", "A Crown of Swords": "loved",
    "Last Argument of Kings": "loved", "Assassin's Quest": "disliked", "Words of Radiance": "loved",
    "Edgedancer": "loved", "Oathbringer": "loved", "Rhythm of War": "loved",
    "Mistborn: The Final Empire": "loved", "The Well of Ascension": "loved", "The Hero of Ages": "loved",
    "The Alloy of Law": "liked", "Shadows of Self": "liked", "The Bands of Mourning": "liked",
    "The Lost Metal": "liked",
}
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


def verdict(true_label, predicted_label):
    if true_label in EXPECT_GOOD:
        return "OK" if predicted_label in ("Strong match", "Good match") else "MISS"
    if true_label in EXPECT_POOR:
        return "OK" if predicted_label == "Poor match" else "MISS"
    return "OK" if predicted_label == "Mixed match" else "SOFT-MISS"


def run_held_out_test(catalog, all_ratings, held_out, label, quiet=False):
    """Trains on all_ratings minus held_out, scores each held-out title,
    reports directional correctness. Returns (correct, total, rows)."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    train = {t: r for t, r in all_ratings.items() if t not in held_out}
    centroid, weights, _, _ = R._resolve_profile(catalog, train)
    correct = wrong = soft = 0
    rows = []
    for title in held_out:
        book = catalog[title_to_id[title]]
        score, _ = R.score_book(book, centroid, weights)
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


if __name__ == "__main__":
    run_all()
