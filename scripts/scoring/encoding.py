"""Encoding components of the recommendation engine."""


from .constants import (
    NOMINAL_PARTIAL_SIMILARITY,
    ORDINAL_FIELDS,
)


def nominal_similarity(field, value_a, value_b):
    """1.0 for an exact match, else a partial-credit value from
    NOMINAL_PARTIAL_SIMILARITY if this specific (field, value_a, value_b)
    pair has one, else 0.0 (the original all-or-nothing behavior)."""
    if value_a == value_b:
        return 1.0
    return NOMINAL_PARTIAL_SIMILARITY.get(field, {}).get(frozenset({value_a, value_b}), 0.0)


def ordinal_position(field, value):
    """Returns (position, scale_max) or None if value is NA/missing for this
    field.

    FIXED 2026-09-05: previously checked `value in NA_VALUES` (a blanket
    {"na", "none"} set) BEFORE consulting the field's own scale, which
    incorrectly treated "none" as missing/not-applicable even for the
    three fields where it's a real, declared bottom-of-scale value
    (humor_level, violence_frequency, romance_heat_frequency all list
    "none" as position 0, not a stand-in for absent data) -- silently
    dropping 325 book-field values catalog-wide from ever contributing
    to build_profile()'s weighted mean for those fields, for every
    rater, since they were added. Confirmed directly: ordinal_position
    ("humor_level", "none") returned None instead of (0, 3).

    Fixed by consulting the scale FIRST -- "not in scale" already
    correctly captures genuine NA sentinels per field (violence_intensity/
    romance_heat_intensity's "na" isn't in either field's own value list,
    so it still correctly returns None), without needing a separate
    blanket NA_VALUES check that couldn't tell "none" apart from field to
    field. See docs/scoring-test-protocol.md for the full before/after
    benchmark."""
    if value is None:
        return None
    scale = ORDINAL_FIELDS[field]
    if value not in scale:
        return None
    return scale.index(value), len(scale) - 1

