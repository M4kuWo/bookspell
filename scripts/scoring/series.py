"""Series components of the recommendation engine."""


from .calibration import (
    scoring_confidence,
)
from .constants import (
    NOMINAL_FIELDS,
    ORDINAL_FIELDS,
    TRAJECTORY_PRIORITY_FIELDS,
    TREND_THRESHOLD,
)
from .encoding import (
    ordinal_position,
)
from .explanations import (
    _join_list,
    phrase_field,
)


def compute_series_dna(catalog):
    """Groups catalog books by series_id, ordered by position_in_series.
    Returns {series_id: {"name", "books": [(position, title), ...],
    "trajectories": {field: {"start_value", "end_value", "trend"}}}} for
    every series with >= 2 tagged books (a single-book series has no
    trajectory). `trend` is "increases"/"decreases"/"stable" for ordinal
    fields (a real directional shift, not just noise -- see
    TREND_THRESHOLD) and "changes"/"stable" for nominal fields (no
    direction, just "this isn't the same throughout")."""
    by_series = {}
    for b in catalog.values():
        sid = b.get("series_id")
        if sid is None:
            continue
        by_series.setdefault(sid, {"name": b.get("series_name"), "books": []})
        by_series[sid]["books"].append(b)

    result = {}
    for sid, data in by_series.items():
        books = sorted(data["books"], key=lambda b: float(b["position_in_series"] or 0))
        if len(books) < 2:
            continue

        trajectories = {}
        for field in ORDINAL_FIELDS:
            # A confidence-zeroed tag (below MIN_CONFIDENCE_TO_COUNT) is
            # excluded here the same way scoring_confidence() excludes it
            # everywhere else evidence feeds into scoring -- otherwise an
            # endpoint we don't actually trust could still anchor the
            # start/end comparison and trigger the trajectory penalty
            # below on evidence too uncertain to count (found by CODX's
            # 2026-09-14 review).
            valid = []
            for i, b in enumerate(books):
                if scoring_confidence(b, field) <= 0:
                    continue
                pos = ordinal_position(field, b.get(field))
                if pos is not None:
                    valid.append((i, pos[0] / pos[1]))
            if len(valid) < 2:
                continue
            start_i, start_val = valid[0]
            end_i, end_val = valid[-1]
            diff = end_val - start_val
            trend = "increases" if diff >= TREND_THRESHOLD else "decreases" if diff <= -TREND_THRESHOLD else "stable"
            trajectories[field] = {
                "start_value": books[start_i].get(field),
                "end_value": books[end_i].get(field),
                "trend": trend,
            }

        for field in NOMINAL_FIELDS:
            valid = [(i, b.get(field)) for i, b in enumerate(books) if b.get(field) and scoring_confidence(b, field) > 0]
            if len(valid) < 2:
                continue
            start_i, start_val = valid[0]
            end_i, end_val = valid[-1]
            trend = "stable" if start_val == end_val else "changes"
            trajectories[field] = {
                "start_value": start_val,
                "end_value": end_val,
                "trend": trend,
            }

        result[sid] = {
            "name": data["name"],
            "books": [(b.get("position_in_series"), b["title"]) for b in books],
            "trajectories": trajectories,
        }
    return result


def describe_series_trajectory(series_entry, max_items=3):
    """series_entry: one value from compute_series_dna()'s result dict.
    Returns a readable sentence describing how the series changes
    across its run, or "" if nothing changes meaningfully (this is the
    common case -- most series stay consistent, and that's fine, no
    caveat needed)."""
    changed = [(f, t) for f, t in series_entry["trajectories"].items() if t["trend"] != "stable"]
    if not changed:
        return ""
    changed.sort(key=lambda x: TRAJECTORY_PRIORITY_FIELDS.index(x[0]) if x[0] in TRAJECTORY_PRIORITY_FIELDS else len(TRAJECTORY_PRIORITY_FIELDS))

    phrases = []
    for field, t in changed[:max_items]:
        start_phrase = phrase_field(field, t["start_value"])
        end_phrase = phrase_field(field, t["end_value"])
        if not start_phrase or not end_phrase:
            continue
        phrases.append(f"{start_phrase} to {end_phrase}")
    if not phrases:
        return ""
    return f"Across the series, it shifts from {_join_list(phrases)}."


def book_similarity(book_a, book_b):
    """Objective book-to-book resemblance (NOT personalized -- no
    per-user weights involved), used only to compute novelty against
    recent history for the `diversity` param below. Personalization
    already lives in the relevance term (score_book against the user's
    profile); this is a separate, unweighted signal for "how alike are
    these two specific books," blending ordinal-field closeness,
    nominal-field exact-match, and trope-set Jaccard similarity."""
    ordinal_sims = []
    for field in ORDINAL_FIELDS:
        pa = ordinal_position(field, book_a.get(field))
        pb = ordinal_position(field, book_b.get(field))
        if pa is not None and pb is not None:
            ordinal_sims.append(1 - abs(pa[0] / pa[1] - pb[0] / pb[1]))

    nominal_sims = []
    for field in NOMINAL_FIELDS:
        va, vb = book_a.get(field), book_b.get(field)
        if va and vb:
            nominal_sims.append(1.0 if va == vb else 0.0)

    ta = set(book_a.get("tropes") or [])
    tb = set(book_b.get("tropes") or [])
    trope_sim = len(ta & tb) / len(ta | tb) if (ta or tb) else 0.0

    components = [trope_sim]
    if ordinal_sims:
        components.append(sum(ordinal_sims) / len(ordinal_sims))
    if nominal_sims:
        components.append(sum(nominal_sims) / len(nominal_sims))
    return sum(components) / len(components)


def series_repeat_worst_similarity(catalog, id_to_magnitude, book):
    """Highest book_similarity() between `book` and any DISLIKED book
    (magnitude < 0) from the same series in id_to_magnitude -- None if
    `book` isn't in a series or no disliked series-mate exists. High
    value = this book closely resembles one the reader already
    disliked in this exact series."""
    series_id = book.get("series_id")
    if series_id is None:
        return None
    disliked_mates = [
        b for bid, mag in id_to_magnitude.items()
        if mag < 0
        and (b := catalog.get(bid)) is not None
        and b.get("series_id") == series_id
        and b["id"] != book["id"]
    ]
    if not disliked_mates:
        return None
    return max(book_similarity(book, mate) for mate in disliked_mates)


def series_position_ready(catalog, id_to_magnitude, book):
    """False if `book` is a non-entry-point installment in a series and
    the user hasn't confirmed (rated) every earlier installment --
    recommending book 3 of a trilogy to someone who's only read book 1
    is useless at best, a spoiler risk at worst. True for standalones and
    for a series' entry point (its lowest position_in_series, so a
    prequel novella doesn't wrongly gate book 1 -- reading order nuance
    some readers skip anyway, a known simplification, not a bug).

    id_to_magnitude: {book_id: rating_magnitude} for books the user has
    actually rated (see _resolve_profile) -- being "read" for this check
    means "rated," not any weaker signal."""
    series_id = book.get("series_id")
    if series_id is None:
        return True
    position = book.get("position_in_series")
    if position is None:
        return True
    series_books = [b for b in catalog.values() if b.get("series_id") == series_id]
    earlier = [b for b in series_books if b.get("position_in_series") is not None
               and b["position_in_series"] < position]
    if not earlier:
        return True
    # Group by exact position, not by row -- a duplicate catalog entry at
    # the same position (e.g. an omnibus edition alongside the standalone
    # volume) is an alternate edition of the same slot, not a distinct
    # earlier installment, so only ONE representative per position needs
    # to be rated, not every row that happens to share that position.
    by_position = {}
    for b in earlier:
        by_position.setdefault(b["position_in_series"], []).append(b)
    return all(
        any(b["id"] in id_to_magnitude for b in books_at_pos)
        for books_at_pos in by_position.values()
    )

