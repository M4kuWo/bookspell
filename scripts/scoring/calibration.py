"""Calibration components of the recommendation engine."""


from .constants import (
    DEFAULT_POOR_THRESHOLD,
    GOOD_MATCH_THRESHOLD,
    HIGH_RISK_FIELDS,
    HIGH_RISK_FIELD_DEFAULT,
    MIN_CONFIDENCE_TO_COUNT,
    STRONG_MATCH_THRESHOLD,
)


def match_label(score, poor_threshold=DEFAULT_POOR_THRESHOLD):
    """Qualitative label instead of a bare percentage -- score is a
    relative ranking, not a calibrated probability, and a precise-looking
    number like "90% match" implies more rigor than the model has. The
    Good/Strong boundaries (GOOD_MATCH_THRESHOLD/STRONG_MATCH_THRESHOLD)
    are a rough first-pass calibration, not derived from real user data
    yet -- revisit once real ratings exist to check against.

    poor_threshold defaults to a fixed 0.35, but callers with a resolved
    profile should pass user_calibrated_poor_threshold()'s result instead
    (see its docstring) -- a fixed 0.35 can mathematically never fire on
    this project's real data: every genuinely disliked/hated held-out
    book tested so far scored 0.397-0.895, never below 0.35 (see
    docs/scoring-test-protocol.md's "Poor-match threshold diagnostic,"
    2026-09-02). Kept as the default here (not removed) so a caller with
    no resolved profile -- or no disliked ratings to calibrate from --
    still gets a sane, non-crashing value."""
    if score >= STRONG_MATCH_THRESHOLD:
        return "Strong match"
    if score >= GOOD_MATCH_THRESHOLD:
        return "Good match"
    if score >= poor_threshold:
        return "Mixed match"
    return "Poor match"


def get_confidence(book, field_or_trope):
    """Confidence (0-1) in this specific book's value for this specific
    field or trope. Defaults to 1.0 (full trust) when unassessed, except
    for HIGH_RISK_FIELDS (see above) -- see book_field_confidence's
    migration comment for why absence isn't treated as low confidence in
    general."""
    if field_or_trope in book.get("_trope_confidence", {}):
        return book["_trope_confidence"][field_or_trope]
    default = HIGH_RISK_FIELD_DEFAULT if field_or_trope in HIGH_RISK_FIELDS else 1.0
    return book.get("_field_confidence", {}).get(field_or_trope, default)


def scoring_confidence(book, field_or_trope):
    """get_confidence(), floored to 0.0 below MIN_CONFIDENCE_TO_COUNT --
    use this (not get_confidence() directly) anywhere confidence feeds
    into actual scoring or weight-learning math. get_confidence() itself
    stays the raw, undiscounted accessor for display/audit purposes
    (e.g. showing a real "25% confident" number to a human), which
    should never be silently zeroed."""
    conf = get_confidence(book, field_or_trope)
    return conf if conf >= MIN_CONFIDENCE_TO_COUNT else 0.0

