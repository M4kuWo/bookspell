"""Feedback components of the recommendation engine."""


from .constants import (
    FEEDBACK_LOG_PATH,
    NEUTRAL_FEEDBACK_REASONS,
    NOMINAL_FIELDS,
    ORDINAL_FIELDS,
)
from .explanations import (
    describe,
)


def book_feedback_options(catalog, title, top_n=8):
    """For a book a user just finished/DNF'd and rated poorly: returns
    this book's own tropes/fields as a checklist of "did this bother
    you?" content_options, plus a small fixed set of neutral_options that
    aren't about the book's content at all (mood/timing, general
    disengagement) and therefore can't drive any calibration -- kept
    separate so they're never mistaken for a content signal."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    if title not in title_to_id:
        raise ValueError(f"{title!r} not found in catalog")
    book = catalog[title_to_id[title]]

    trope_options = [
        {"key": f"trope:{t}", "label": describe(f"trope:{t}", book)}
        for t in (book.get("tropes") or [])
    ]
    field_options = [
        {"key": field, "label": phrase}
        for field in list(ORDINAL_FIELDS) + NOMINAL_FIELDS
        if (phrase := describe(field, book))
    ]

    return {
        "content_options": (trope_options + field_options)[:top_n],
        "neutral_options": [
            {"key": key, "label": label} for key, label in NEUTRAL_FEEDBACK_REASONS.items()
        ],
    }


def feedback_to_fatigue_overrides(selected_keys, strength=-0.6):
    """Turns selected book_feedback_options keys into a fatigue_overrides
    dict for recommend()/explain_match(). Only TROPE selections translate
    -- tropes are presence-based, so "penalize this trope going forward"
    is exactly what fatigue_overrides' weights['tropes'][t] override
    already means.

    Field-level selections (e.g. 'overall_pace') deliberately do NOT
    translate the same way, and it would be a real bug to force them to:
    fatigue_overrides flips a field's weight relative to the user's own
    CENTROID ("avoid being similar to your average on this field"), not
    "avoid this specific book's value on it." If the disliked book's
    pace was already far from the user's centroid, flipping the sign
    would perversely reward OTHER far-from-centroid books instead of
    specifically steering away from slow pacing. The correct existing
    mechanism for field-level dislikes is simply rating the book itself
    hated/disliked via RATING_LABELS -- build_profile() already learns
    whether pace is a real discriminator once it recurs across several
    disliked books, which is the right way to learn it (a pattern across
    many books), not a single-book override. Field-level selections are
    still returned by book_feedback_options() for triage/logging value,
    just not fed into this function's output yet."""
    return {
        key[len("trope:"):]: strength
        for key in selected_keys
        if key.startswith("trope:")
    }


def log_feedback(title, selected_keys=None, notes=None):
    """Appends one JSON-lines record to FEEDBACK_LOG_PATH: title, the
    structured book_feedback_options() selections (if any), free-text
    notes (if any -- this is where a real, detailed reason like "felt
    juvenile and preachy" belongs, distinct from the structured
    trope/field checklist), and a timestamp."""
    import json
    from datetime import datetime, timezone

    record = {
        "title": title,
        "selected": selected_keys or [],
        "notes": notes,
        "logged_at": datetime.now(timezone.utc).isoformat(),
    }
    with open(FEEDBACK_LOG_PATH, "a") as f:
        f.write(json.dumps(record) + "\n")

