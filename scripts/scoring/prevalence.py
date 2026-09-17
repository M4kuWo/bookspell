"""Prevalence components of the recommendation engine."""


from .constants import (
    MIN_PREVALENCE_GROUP_SAMPLE,
    NOMINAL_FIELDS,
    NOMINAL_PARTIAL_SIMILARITY,
    ORDINAL_FIELDS,
)


def build_prevalence_lookup(catalog, genre=None):
    """(field_prevalence, trope_prevalence) for the prevalence discount:
    field_prevalence[field][value] / trope_prevalence[trope] = fraction
    of the CANDIDATE pool (book_dna-tagged books in `genre`, or the
    whole catalog if genre is None) sharing that value/trope. Computed
    once per scoring session, not per candidate -- pass the result into
    score_book()/explain_book() for every book scored in the same run."""
    pool = [b for b in catalog.values() if genre is None or genre in (b.get("genre") or [])]
    n = len(pool) or 1
    field_prevalence = {}
    for field in list(ORDINAL_FIELDS) + list(NOMINAL_FIELDS):
        counts = {}
        for b in pool:
            v = b.get(field)
            if v is None:
                continue
            counts[v] = counts.get(v, 0) + 1
        field_prevalence[field] = {v: c / n for v, c in counts.items()}
    trope_counts = {}
    for b in pool:
        for t in (b.get("tropes") or []):
            trope_counts[t] = trope_counts.get(t, 0) + 1
    trope_prevalence = {t: c / n for t, c in trope_counts.items()}
    return field_prevalence, trope_prevalence


def build_prevalence_lookup_grouped(catalog, ratings, genre=None, min_sample=MIN_PREVALENCE_GROUP_SAMPLE):
    """Like build_prevalence_lookup(), but for any field with a
    NOMINAL_PARTIAL_SIMILARITY pair, pools the pair's prevalence
    together UNLESS the given user's OWN `ratings` show at least
    `min_sample` rated books on EACH side of the pair -- i.e. only
    collapse two values into one combined prevalence figure when this
    specific user doesn't have enough evidence to argue they're
    genuinely different for them. `ratings`: {title: rating_label}, the
    SAME shape passed to _resolve_profile()/recommend() -- this makes
    the grouping decision per-user, not a global catalog property (see
    MIN_PREVALENCE_GROUP_SAMPLE's comment for why, and Mathias's
    concrete numbers that motivated this)."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    user_value_counts = {}
    for title in ratings:
        bid = title_to_id.get(title)
        if bid is None:
            continue
        book = catalog[bid]
        for field in NOMINAL_PARTIAL_SIMILARITY:
            v = book.get(field)
            if v is None:
                continue
            user_value_counts.setdefault(field, {})
            user_value_counts[field][v] = user_value_counts[field].get(v, 0) + 1

    # Union-find per field over pairs that qualify for grouping (at
    # least one side has fewer than min_sample rated books for THIS user).
    group_of = {}
    for field, pairs in NOMINAL_PARTIAL_SIMILARITY.items():
        parent = {}

        def find(v):
            parent.setdefault(v, v)
            while parent[v] != v:
                v = parent[v]
            return v

        for pair in pairs:
            a, b = tuple(pair)
            counts = user_value_counts.get(field, {})
            if counts.get(a, 0) < min_sample or counts.get(b, 0) < min_sample:
                ra, rb = find(a), find(b)
                if ra != rb:
                    parent[ra] = rb
        group_of[field] = {v: find(v) for v in parent}

    pool = [b for b in catalog.values() if genre is None or genre in (b.get("genre") or [])]
    n = len(pool) or 1
    field_prevalence = {}
    for field in list(ORDINAL_FIELDS) + list(NOMINAL_FIELDS):
        grouping = group_of.get(field, {})
        group_counts = {}
        for b in pool:
            v = b.get(field)
            if v is None:
                continue
            key = grouping.get(v, v)
            group_counts[key] = group_counts.get(key, 0) + 1
        field_prevalence[field] = {
            v: group_counts[grouping.get(v, v)] / n
            for v in set(b.get(field) for b in pool if b.get(field) is not None)
        }
    trope_counts = {}
    for b in pool:
        for t in (b.get("tropes") or []):
            trope_counts[t] = trope_counts.get(t, 0) + 1
    trope_prevalence = {t: c / n for t, c in trope_counts.items()}
    return field_prevalence, trope_prevalence

