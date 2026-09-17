"""Cold start components of the recommendation engine."""


from .constants import (
    COLD_START_FADE_RATINGS,
    GENRE_ACCESSIBILITY_DEMAND,
)
from .profile import (
    _n_independent_clusters,
)


def reader_experience_fraction(catalog, id_to_magnitude):
    """How much genre experience this user has ALREADY demonstrated,
    independent of how many total ratings they've given -- someone who's
    rated even a single veteran_only book without disliking it has shown
    real readiness regardless of how short their list is. This is why
    it's a separate factor from rating count, not folded into one number
    -- a short list doesn't necessarily mean an inexperienced reader.

    Only counts books rated loved/liked/it_was_okay (magnitude >= 0) --
    disliking/hating a demanding book is ambiguous evidence (could mean
    "too much for me," could mean something unrelated) and isn't trusted
    as proof of readiness either way.

    Returns the highest genre_accessibility demand level (see
    GENRE_ACCESSIBILITY_DEMAND, 0.0-1.0) among those books, or 0.0 if
    none are tagged/rated."""
    best = 0.0
    for bid, mag in id_to_magnitude.items():
        if mag < 0:
            continue
        book = catalog.get(bid)
        if book is None:
            continue
        demand = GENRE_ACCESSIBILITY_DEMAND.get(book.get("genre_accessibility"))
        if demand is not None and demand > best:
            best = demand
    return best


def cold_start_weight(catalog, id_to_magnitude):
    """How much recommend() should lean on accessibility rather than the
    normal per-field profile match -- 1.0 (fully cold) down to 0.0 (fully
    trust the normal profile). Combines two independent factors: raw
    rating count alone isn't the right measure, since someone who's only
    rated one book but it's Gardens of the Moon has shown real genre
    readiness a short list doesn't capture on its own.

    count_component: linear fade from 1.0 at 0 ratings to 0.0 at
    COLD_START_FADE_RATINGS. experience_component: demonstrated readiness
    (see reader_experience_fraction()) discounts the count-based weight
    directly, so a single confirmed veteran_only-tier rating can zero
    this out even at n=1.

    n is independent-cluster count (_n_independent_clusters()), not raw
    rating count -- added 2026-09-05, same series-clustering-inflation
    reasoning as build_profile()'s own dedup: 12 ratings that are really
    6 Wheel of Time books + 6 standalones is 7 independent data points
    of demonstrated experience, not 12. A rater with no series overlap
    at all sees no change (every book is its own cluster)."""
    n = _n_independent_clusters(catalog, id_to_magnitude)
    count_component = max(0.0, 1.0 - n / COLD_START_FADE_RATINGS)
    experience = reader_experience_fraction(catalog, id_to_magnitude)
    return count_component * (1.0 - experience)

