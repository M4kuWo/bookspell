"""
Bookspell recommendation engine — v1 prototype.

Design (matches the original artifact's decision: per-user weighted
vector, no collaborative filtering for v1):

1. Every book's Book DNA is encoded into a flat feature space: ordinal
   scalar fields (position on their ordered value list), nominal scalar
   fields (one value, exact-match only), and tropes (a multi-select set).
   Content warnings are deliberately EXCLUDED from the similarity score
   -- per book-dna.md, they're neutral descriptive data, not a taste
   signal to match toward. They belong in personalized hard filters
   (step 07 onboarding: "never show me X"), not in the score itself.

2. A user's profile is built from books they've rated on a 5-tier
   labeled scale (hated/disliked/it_was_okay/liked/loved -- see
   RATING_LABELS), not a binary liked/disliked, and not a fixed formula:
   for each feature, compare the RATING-MAGNITUDE-WEIGHTED average value
   among positively-rated books to the magnitude-weighted average among
   negatively-rated books, so a "loved" book pulls the centroid harder
   than a "liked" one, and "it_was_okay" (magnitude 0) contributes to
   neither side -- it's excluded from profile-building entirely, present
   only so the book gets excluded from future recommendations. A
   feature's PER-USER WEIGHT is how much it actually discriminates for
   that specific user (positive vs. negative differ a lot -> high
   weight; look the same on this feature -> low weight, it isn't telling
   us anything about this user's taste). This is the "per-user weighted
   vector" the artifact specified, not a fixed global formula applied
   identically to everyone.

3. Every other catalog book is scored by weighted similarity to the
   liked-books centroid, using those per-user weights.

4. explain_match() surfaces WHY a book scored the way it did, in
   readable language, for any book in the catalog -- not just
   recommend()'s top results. The same scoring math is decomposed into
   "matches" (factors pulling the score up) and "mismatches" (factors
   pulling it down), so the same mechanism explains both a strong
   recommendation and a poor one (e.g. a user searching a specific book
   that isn't for them). Deliberately avoids a bare "90% match" framing
   -- the score is a relative ranking, not a calibrated probability --
   in favor of a qualitative label (see match_label()) plus the reasons.

This is intentionally a standalone, runnable prototype (not wired into
the DB as a stored function/API yet) -- that's step 06+ work, once the
app itself exists. Reads directly from Postgres (DATABASE_URL in .env,
same as every other script in this project) -- no separate export step.
Run directly: `python3 scripts/recommend.py`.
"""

from scoring import api, catalog as scoring_catalog


if __name__ == "__main__":
    catalog = scoring_catalog.load_catalog()
    print(f"Loaded {len(catalog)} books.\n")

    # Original 2026-08-28 pilot data was collected as plain liked/disliked
    # (no magnitude) -- mapped straight onto the new labeled scale rather
    # than inventing granularity that was never actually reported.
    ratings = {
        "The Golden Compass": "liked", "The Lies of Locke Lamora": "liked",
        "The Eye of the World": "liked", "Kings of Paradise": "liked",
        "Prince of Thorns": "liked", "The Way of Kings": "liked",
        "Bird Box": "disliked", "Assassin's Apprentice": "disliked",
        "We Are Legion (We Are Bob)": "disliked",
        "Interview with the Vampire": "disliked", "The Poppy War": "disliked",
        "Circe": "disliked", "Dark Matter": "disliked",
        "He Who Fights with Monsters": "disliked",
    }

    print(f"Ratings: {ratings}\n")
    results = api.recommend(catalog, ratings, top_n=15)
    for score, title, author, contributions in results:
        print(f"{score:.3f}  {title} ({author})")
        print(f"       top factors: {contributions}")

    print("\n--- explanation layer demo ---\n")
    top_pick = results[0][1]
    print(f"Why '{top_pick}' was recommended:")
    explanation = api.explain_match(catalog, ratings, top_pick)
    print(f"  {explanation['match_label']} ({explanation['score']})")
    print(f"  {explanation['summary']}")
    if explanation["mismatch_summary"]:
        print(f"  However, {explanation['mismatch_summary'][0].lower()}{explanation['mismatch_summary'][1:]}")
    if explanation["dealbreaker_summary"]:
        print(f"  ⚠ {explanation['dealbreaker_summary']}")

    print(f"\nWhy a genuinely poor-scoring book (bottom of the full ranked list) scores poorly:")
    explanation = api.explain_match(catalog, ratings, "The Restaurant at the End of the Universe")
    print(f"  {explanation['match_label']} ({explanation['score']})")
    print(f"  {explanation['summary']}")
    if explanation["mismatch_summary"]:
        print(f"  However, {explanation['mismatch_summary'][0].lower()}{explanation['mismatch_summary'][1:]}")
    if explanation["dealbreaker_summary"]:
        print(f"  ⚠ {explanation['dealbreaker_summary']}")

    print(f"\nDealbreaker-flag demo -- a book that mostly matches this profile but hits a known dislike:")
    explanation = api.explain_match(catalog, ratings, "Royal Assassin")
    print(f"  {explanation['match_label']} ({explanation['score']})")
    print(f"  {explanation['summary']}")
    if explanation["dealbreaker_summary"]:
        print(f"  ⚠ {explanation['dealbreaker_summary']}")
    else:
        print("  (no dealbreaker flag -- nothing crossed DEALBREAKER_THRESHOLD for this profile/book)")
