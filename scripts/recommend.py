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

# Support both direct script execution and package imports.
if __package__:
    from .scoring.api import (
        explain_match,
        recommend,
        series_dnf_outlook,
    )
    from .scoring.audit import (
        _audit_attribute_nominal_or_trope,
        _audit_attribute_ordinal,
        audit_book_score,
        print_score_audit,
    )
    from .scoring.calibration import (
        get_confidence,
        match_label,
        scoring_confidence,
    )
    from .scoring.catalog import (
        load_catalog,
    )
    from .scoring.cold_start import (
        cold_start_weight,
        reader_experience_fraction,
    )
    from .scoring.constants import (
        AUDIT_BOOK_LIST_CAP,
        AUDIT_CONTRIBUTION_THRESHOLD,
        COLD_START_FADE_RATINGS,
        DATABASE_URL,
        DEALBREAKER_THRESHOLD,
        DEALBREAKER_VETO_CAP,
        DEALBREAKER_VETO_PULL_FLOOR,
        DEALBREAKER_VETO_SEVERITY_SPAN,
        DEFAULT_POOR_THRESHOLD,
        DEFAULT_REDUCE_STRENGTH,
        FEEDBACK_LOG_PATH,
        FIELD_DISPLAY_NAMES,
        GENRE_ACCESSIBILITY_DEMAND,
        GOOD_MATCH_THRESHOLD,
        HIGH_RISK_FIELDS,
        HIGH_RISK_FIELD_DEFAULT,
        MAX_DIVERSITY,
        MIN_CONFIDENCE_TO_COUNT,
        MIN_DEALBREAKER_SAMPLE,
        MIN_PREVALENCE_GROUP_SAMPLE,
        MULTI_FIELDS,
        NARRATIVE_STYLE_FIELDS,
        NA_VALUES,
        NEUTRAL_FEEDBACK_REASONS,
        NOMINAL_FIELDS,
        NOMINAL_PARTIAL_SIMILARITY,
        ORDINAL_FIELDS,
        PREVALENCE_DISCOUNT_FLOOR,
        RATING_LABELS,
        REDUNDANCY_DISCOUNTS,
        SERIES_REPEAT_WEIGHT,
        SERIES_TRAJECTORY_DIVERGENCE_THRESHOLD,
        SERIES_TRAJECTORY_MAX_PENALTY,
        STAT_SEPARATION_THRESHOLD,
        STRONG_MATCH_THRESHOLD,
        STRUCTURAL_NOMINAL_FIELDS,
        STRUCTURAL_ORDINAL_FIELDS,
        TRAJECTORY_PRIORITY_FIELDS,
        TREND_THRESHOLD,
        TROPE_BACKOFF_K,
        TROPE_SHRINKAGE_K,
        VALIDATED_DEALBREAKER_MAGNITUDE,
        VALUE_PHRASES,
        WEIGHT_CAP,
    )
    from .scoring.encoding import (
        nominal_similarity,
        ordinal_position,
    )
    from .scoring.experimental import (
        _dedup_factor_for_field,
        _dedup_factor_plain,
        build_profile_per_value,
        build_profile_series_field_dedup,
        build_profile_series_field_dedup_protected,
        build_profile_trope_backoff,
        build_profile_trope_shrinkage,
        explain_book_per_value,
        score_book_per_value,
    )
    from .scoring.explanations import (
        _join_list,
        dealbreaker_sentence,
        describe,
        natural_sentence,
        phrase_field,
        phrase_trope,
    )
    from .scoring.feedback import (
        book_feedback_options,
        feedback_to_fatigue_overrides,
        log_feedback,
    )
    from .scoring.pipeline import (
        _apply_dealbreaker_veto,
        _apply_dealbreaker_veto_graduated,
        _apply_series_repeat,
        _apply_series_trajectory_penalty,
        _iter_book_factors,
        _nominal_field_separation,
        _ordinal_field_separation,
        _redundancy_adjusted_weight,
        _series_trajectory_penalty_factor,
        _trope_separation,
        dealbreaker_flags,
        explain_book,
        field_or_trope_separation,
        score_book,
        score_candidate,
        user_calibrated_poor_threshold,
        validated_dealbreaker_fields,
    )
    from .scoring.prevalence import (
        build_prevalence_lookup,
        build_prevalence_lookup_grouped,
    )
    from .scoring.profile import (
        _n_independent_clusters,
        _resolve_profile,
        _series_deduped,
        _series_deduped_id_to_magnitude,
        _split_by_sign,
        build_profile,
    )
    from .scoring.rules import (
        _matches_rule_target,
        apply_user_rules,
        list_user_rule_targets,
        normalize_user_rules,
        parse_user_rule_key,
    )
    from .scoring.series import (
        book_similarity,
        compute_series_dna,
        describe_series_trajectory,
        series_position_ready,
        series_repeat_worst_similarity,
    )
else:
    from scoring.api import (
        explain_match,
        recommend,
        series_dnf_outlook,
    )
    from scoring.audit import (
        _audit_attribute_nominal_or_trope,
        _audit_attribute_ordinal,
        audit_book_score,
        print_score_audit,
    )
    from scoring.calibration import (
        get_confidence,
        match_label,
        scoring_confidence,
    )
    from scoring.catalog import (
        load_catalog,
    )
    from scoring.cold_start import (
        cold_start_weight,
        reader_experience_fraction,
    )
    from scoring.constants import (
        AUDIT_BOOK_LIST_CAP,
        AUDIT_CONTRIBUTION_THRESHOLD,
        COLD_START_FADE_RATINGS,
        DATABASE_URL,
        DEALBREAKER_THRESHOLD,
        DEALBREAKER_VETO_CAP,
        DEALBREAKER_VETO_PULL_FLOOR,
        DEALBREAKER_VETO_SEVERITY_SPAN,
        DEFAULT_POOR_THRESHOLD,
        DEFAULT_REDUCE_STRENGTH,
        FEEDBACK_LOG_PATH,
        FIELD_DISPLAY_NAMES,
        GENRE_ACCESSIBILITY_DEMAND,
        GOOD_MATCH_THRESHOLD,
        HIGH_RISK_FIELDS,
        HIGH_RISK_FIELD_DEFAULT,
        MAX_DIVERSITY,
        MIN_CONFIDENCE_TO_COUNT,
        MIN_DEALBREAKER_SAMPLE,
        MIN_PREVALENCE_GROUP_SAMPLE,
        MULTI_FIELDS,
        NARRATIVE_STYLE_FIELDS,
        NA_VALUES,
        NEUTRAL_FEEDBACK_REASONS,
        NOMINAL_FIELDS,
        NOMINAL_PARTIAL_SIMILARITY,
        ORDINAL_FIELDS,
        PREVALENCE_DISCOUNT_FLOOR,
        RATING_LABELS,
        REDUNDANCY_DISCOUNTS,
        SERIES_REPEAT_WEIGHT,
        SERIES_TRAJECTORY_DIVERGENCE_THRESHOLD,
        SERIES_TRAJECTORY_MAX_PENALTY,
        STAT_SEPARATION_THRESHOLD,
        STRONG_MATCH_THRESHOLD,
        STRUCTURAL_NOMINAL_FIELDS,
        STRUCTURAL_ORDINAL_FIELDS,
        TRAJECTORY_PRIORITY_FIELDS,
        TREND_THRESHOLD,
        TROPE_BACKOFF_K,
        TROPE_SHRINKAGE_K,
        VALIDATED_DEALBREAKER_MAGNITUDE,
        VALUE_PHRASES,
        WEIGHT_CAP,
    )
    from scoring.encoding import (
        nominal_similarity,
        ordinal_position,
    )
    from scoring.experimental import (
        _dedup_factor_for_field,
        _dedup_factor_plain,
        build_profile_per_value,
        build_profile_series_field_dedup,
        build_profile_series_field_dedup_protected,
        build_profile_trope_backoff,
        build_profile_trope_shrinkage,
        explain_book_per_value,
        score_book_per_value,
    )
    from scoring.explanations import (
        _join_list,
        dealbreaker_sentence,
        describe,
        natural_sentence,
        phrase_field,
        phrase_trope,
    )
    from scoring.feedback import (
        book_feedback_options,
        feedback_to_fatigue_overrides,
        log_feedback,
    )
    from scoring.pipeline import (
        _apply_dealbreaker_veto,
        _apply_dealbreaker_veto_graduated,
        _apply_series_repeat,
        _apply_series_trajectory_penalty,
        _iter_book_factors,
        _nominal_field_separation,
        _ordinal_field_separation,
        _redundancy_adjusted_weight,
        _series_trajectory_penalty_factor,
        _trope_separation,
        dealbreaker_flags,
        explain_book,
        field_or_trope_separation,
        score_book,
        score_candidate,
        user_calibrated_poor_threshold,
        validated_dealbreaker_fields,
    )
    from scoring.prevalence import (
        build_prevalence_lookup,
        build_prevalence_lookup_grouped,
    )
    from scoring.profile import (
        _n_independent_clusters,
        _resolve_profile,
        _series_deduped,
        _series_deduped_id_to_magnitude,
        _split_by_sign,
        build_profile,
    )
    from scoring.rules import (
        _matches_rule_target,
        apply_user_rules,
        list_user_rule_targets,
        normalize_user_rules,
        parse_user_rule_key,
    )
    from scoring.series import (
        book_similarity,
        compute_series_dna,
        describe_series_trajectory,
        series_position_ready,
        series_repeat_worst_similarity,
    )


# --- Per-value nominal weight learning -- NOT landed (tried + reverted 2026-09-04) ---
# `build_profile_per_value()`/`score_book_per_value()`/`explain_book_per_value()`
# above are a real, working alternative implementation, kept in the file
# for reference, but production still uses the original mode-based
# `build_profile()`/`score_book()`/`explain_book()` defined earlier.
#
# This WAS reassigned into production earlier today (`build_profile =
# build_profile_per_value` etc., right here), on the strength of an A/B
# test that appeared to show zero regressions plus a real, understood
# improvement (House of Earth and Blood's `emotional_resolution: happy`
# scoring as a real negative instead of diluting toward neutral). That
# A/B test was WRONG, and the "zero regressions" finding was invalid --
# see docs/scoring-test-protocol.md's 2026-09-04 entry for the full
# writeup, but the short version: the test monkeypatched names on
# `scripts.recommend`, while `scripts/scoring_tests.py` internally does
# `sys.path.insert(...); import recommend as R` -- a SEPARATE import of
# the same file under a different sys.modules key, hence a genuinely
# different module OBJECT with its own independent copy of every name.
# The monkeypatch silently never touched the module scoring_tests.py
# actually calls, so the "benchmark" run the whole time against
# unmodified mode-based scoring. Confirmed directly:
# `scripts.recommend is not (path-inserted) recommend` -> True.
#
# Once landed for real (by editing this file's own module-level names,
# which both import paths see since they both execute this file's
# top-level code), the REAL benchmark showed a severe regression --
# e.g. Mathias-full held-out: bucket accuracy 91%->73%, pairwise
# 89%->69%, loved_recall 100%->60%; Dandan-full bucket 71%->29%. Old
# Man's War (liked, held out) alone dropped 0.561->0.179. Root cause of
# the regression itself was not further chased once the "safe to land"
# premise collapsed -- reverted instead of debugging a mechanism that
# was never actually validated in the first place.
#
# Lesson for next time (added to docs/scoring-test-protocol.md too):
# when A/B testing via monkeypatch against `scoring_tests.py`, verify
# the patch actually lands on the SAME module object scoring_tests.py
# calls (`import scripts.recommend as R; import scripts.scoring_tests as
# T; R is T.R` should be True) -- don't just trust that "the numbers
# came out different/same" proves the patch took effect.
#
# NOMINAL_PARTIAL_SIMILARITY note (still applies if this is revisited):
# the per-value scheme replaces the fixed 50% person third_limited/
# third_omniscient partial-credit rule with a learned per-value weight
# -- a real behavior change against that already-tested fix, not a
# silent regression, should this be tried again with a valid test.


if __name__ == "__main__":
    catalog = load_catalog()
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
    results = recommend(catalog, ratings, top_n=15)
    for score, title, author, contributions in results:
        print(f"{score:.3f}  {title} ({author})")
        print(f"       top factors: {contributions}")

    print("\n--- explanation layer demo ---\n")
    top_pick = results[0][1]
    print(f"Why '{top_pick}' was recommended:")
    explanation = explain_match(catalog, ratings, top_pick)
    print(f"  {explanation['match_label']} ({explanation['score']})")
    print(f"  {explanation['summary']}")
    if explanation["mismatch_summary"]:
        print(f"  However, {explanation['mismatch_summary'][0].lower()}{explanation['mismatch_summary'][1:]}")
    if explanation["dealbreaker_summary"]:
        print(f"  ⚠ {explanation['dealbreaker_summary']}")

    print(f"\nWhy a genuinely poor-scoring book (bottom of the full ranked list) scores poorly:")
    explanation = explain_match(catalog, ratings, "The Restaurant at the End of the Universe")
    print(f"  {explanation['match_label']} ({explanation['score']})")
    print(f"  {explanation['summary']}")
    if explanation["mismatch_summary"]:
        print(f"  However, {explanation['mismatch_summary'][0].lower()}{explanation['mismatch_summary'][1:]}")
    if explanation["dealbreaker_summary"]:
        print(f"  ⚠ {explanation['dealbreaker_summary']}")

    print(f"\nDealbreaker-flag demo -- a book that mostly matches this profile but hits a known dislike:")
    explanation = explain_match(catalog, ratings, "Royal Assassin")
    print(f"  {explanation['match_label']} ({explanation['score']})")
    print(f"  {explanation['summary']}")
    if explanation["dealbreaker_summary"]:
        print(f"  ⚠ {explanation['dealbreaker_summary']}")
    else:
        print("  (no dealbreaker flag -- nothing crossed DEALBREAKER_THRESHOLD for this profile/book)")

