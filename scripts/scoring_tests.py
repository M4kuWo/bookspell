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
    correct = wrong = soft = 0
    rows = []
    for title in held_out:
        book = catalog[title_to_id[title]]
        score, _ = R.score_book(book, centroid, weights)
        score = R._apply_series_repeat(catalog, id_to_magnitude, book, score)
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

    _, _, r = run_held_out_test(catalog, REAL_RATINGS, REAL_HELD_OUT, "Mathias, full", quiet=True, summary=False)
    rows.append(scorecard_row("Mathias -- full (53 ratings)", r, "full"))

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
    rows = []
    for title in held_out:
        book = catalog[title_to_id[title]]
        score, _ = R.score_book(book, centroid, weights)
        score = R._apply_series_repeat(catalog, id_to_magnitude, book, score)
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

    raw = {}
    for title in held_out:
        book = catalog[title_to_id[title]]
        score, _ = R.score_book(book, centroid, weights)
        raw[title] = R._apply_series_repeat(catalog, id_to_magnitude, book, score)

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


if __name__ == "__main__":
    run_all()
