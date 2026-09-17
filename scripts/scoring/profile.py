"""Profile components of the recommendation engine."""


from .calibration import (
    scoring_confidence,
)
from .constants import (
    NOMINAL_FIELDS,
    ORDINAL_FIELDS,
    RATING_LABELS,
    STRUCTURAL_NOMINAL_FIELDS,
    STRUCTURAL_ORDINAL_FIELDS,
    WEIGHT_CAP,
)
from .encoding import (
    ordinal_position,
)


def _split_by_sign(catalog, ratings):
    """ratings: dict of {book_id: magnitude} (magnitude in [-1, 1], see
    RATING_LABELS). Returns (liked, disliked) as lists of (book, weight)
    pairs -- weight is the rating magnitude (always positive in both
    lists; disliked weights are the absolute value). Magnitude-0 ratings
    ("it_was_okay") appear in neither list -- see RATING_LABELS."""
    liked, disliked = [], []
    for bid, m in ratings.items():
        book = catalog.get(bid)
        if book is None:
            continue
        if m > 0:
            liked.append((book, m))
        elif m < 0:
            disliked.append((book, -m))
    return liked, disliked


def _series_deduped(pool):
    """pool: list of (book, magnitude) pairs. Returns the same shape, but
    a book sharing a series_id with others IN THIS POOL has its magnitude
    split evenly among its series-mates present here -- an N-book series
    a user rated collectively contributes the same total weight as ONE
    standalone book would, not N times as much. Added 2026-09-01: a real
    test set's 27 raw "liked" books collapsed to just 13 truly
    independent series/standalone clusters -- without this, a heavily-
    clustered series (e.g. a 6-book run all loved) systematically
    overstates how much real, independent evidence backs whatever
    field values that series happens to share, at every other pool
    member's expense. Standalones (or a series with only one rated
    member in this specific pool) are unaffected (divide by 1)."""
    counts = {}
    for b, _ in pool:
        key = b.get("series_id") or f"standalone:{b['id']}"
        counts[key] = counts.get(key, 0) + 1
    return [
        (b, m / counts[b.get("series_id") or f"standalone:{b['id']}"])
        for b, m in pool
    ]


def _series_deduped_id_to_magnitude(catalog, id_to_magnitude):
    """{book_id: magnitude} version of _series_deduped(), for the
    downstream consumers that take id_to_magnitude directly rather than
    build_profile()'s (book, magnitude) pools --
    validated_dealbreaker_fields() and the score-audit tool's own
    per-field reporting. Added 2026-09-05 per the 10-hypothesis
    review's #2 finding: these consumed RAW id_to_magnitude, giving a
    heavily-clustered series the same inflated influence on a field's
    apparent separation that build_profile() itself already corrects
    for (confirmed concretely: person's separation was 0.467 raw vs.
    0.356 deduped in this exact path).

    Liked/disliked deduped independently, matching build_profile()'s own
    split (a book's magnitude is only "redundant" against OTHER books on
    the SAME side of the like/dislike divide) -- magnitude-0
    ("it_was_okay") ratings pass through completely unchanged, since
    _split_by_sign() never routes them to either pool in the first
    place, same as everywhere else in this file.

    NOT a fix for cold_start_weight()'s own raw `len(id_to_magnitude)`
    count -- magnitude-splitting rescales weights, it doesn't shrink the
    number of dict entries, so this helper would leave that count
    completely unchanged. See _n_independent_clusters() instead, which
    is the actual count-shaped analog."""
    liked, disliked = _split_by_sign(catalog, id_to_magnitude)
    liked = _series_deduped(liked)
    disliked = _series_deduped(disliked)
    result = {bid: mag for bid, mag in id_to_magnitude.items() if mag == 0}
    result.update({b["id"]: m for b, m in liked})
    result.update({b["id"]: -m for b, m in disliked})
    return result


def _n_independent_clusters(catalog, id_to_magnitude):
    """Count-shaped analog to _series_deduped_id_to_magnitude() for
    cold_start_weight()'s `n` -- a book isn't a new independent
    experience data point just because it shares a series with 5
    already-counted siblings. Counts EVERY rating regardless of sign
    (including magnitude-0/it_was_okay), matching cold_start_weight()'s
    own existing "any rating counts as demonstrated engagement" scope --
    unlike the liked/disliked-only separation helpers above."""
    clusters = set()
    for bid in id_to_magnitude:
        book = catalog.get(bid)
        if book is None:
            continue
        clusters.add(book.get("series_id") or f"standalone:{bid}")
    return len(clusters)


def build_profile(catalog, ratings, full_ratings=None, format_preference=None):
    """Returns (centroid, weights) -- centroid is the target feature profile
    (a rating-magnitude-weighted average of positively-rated books),
    weights say how much each feature matters for THIS user specifically.

    ratings: {book_id: magnitude} (see RATING_LABELS), the (possibly
    genre-scoped) pool used for CONTENT fields and tropes.
    full_ratings: same shape, the unscoped pool used for STRUCTURAL
    fields (see STRUCTURAL_*_FIELDS above) -- defaults to `ratings` when
    not given, i.e. no genre scoping in play.

    format_preference (2026-09-07, LANDED): 'print' (or None, the
    default), 'audiobook', or 'mixed' -- gates whether `book_length` and
    `audiobook_length` participate at all. Before this, BOTH fields were
    always-on ORDINAL_FIELDS, learned and scored for every user
    regardless of whether they'd ever actually listened to an audiobook
    -- a pure print reader could pick up a spurious `audiobook_length`
    preference from coincidental correlation among their liked books
    (which fields get discounted for redundancy has nothing to do with
    whether the field is even relevant to how this person reads), and
    it would silently affect every candidate's score, symmetrically for
    an audiobook-only listener and `book_length`. Default ('print'/None)
    excludes `audiobook_length` entirely and keeps `book_length` --
    matches this project's primary format so far; 'audiobook' is the
    mirror image; 'mixed' keeps both fields exactly as before this
    landed (a genuine mixed-format reader cares about both signals).
    Read from a rater's `data/ratings/{name}.json`'s `_meta.
    format_preference` by callers, not by this function -- build_profile()
    itself just takes the resolved value."""
    full_ratings = ratings if full_ratings is None else full_ratings
    exclude_length_fields = set()
    if format_preference == "audiobook":
        exclude_length_fields = {"book_length"}
    elif format_preference != "mixed":
        exclude_length_fields = {"audiobook_length"}

    liked, disliked = _split_by_sign(catalog, ratings)
    full_liked, full_disliked = _split_by_sign(catalog, full_ratings)
    liked = _series_deduped(liked)
    disliked = _series_deduped(disliked)
    full_liked = _series_deduped(full_liked)
    full_disliked = _series_deduped(full_disliked)

    centroid = {}
    weights = {}

    def weighted_mean(pairs, positions):
        """positions: list of (position_fraction, weight) already
        filtered to non-None. Returns None if empty."""
        total_w = sum(w for _, w in positions)
        if total_w == 0:
            return None
        return sum(v * w for v, w in positions) / total_w

    for field in ORDINAL_FIELDS:
        if field in exclude_length_fields:
            continue
        pool_liked = full_liked if field in STRUCTURAL_ORDINAL_FIELDS else liked
        pool_disliked = full_disliked if field in STRUCTURAL_ORDINAL_FIELDS else disliked
        liked_positions = [
            (pos[0] / pos[1], m * scoring_confidence(b, field)) for b, m in pool_liked
            if (pos := ordinal_position(field, b.get(field))) is not None
        ]
        liked_mean = weighted_mean(pool_liked, liked_positions)
        if liked_mean is None:
            continue
        centroid[field] = liked_mean
        disliked_positions = [
            (pos[0] / pos[1], m * scoring_confidence(b, field)) for b, m in pool_disliked
            if (pos := ordinal_position(field, b.get(field))) is not None
        ]
        disliked_mean = weighted_mean(pool_disliked, disliked_positions)
        if disliked_mean is not None:
            weights[field] = min(WEIGHT_CAP, abs(liked_mean - disliked_mean))
        else:
            # No disliked signal yet -- fall back to a modest default
            # weight rather than zero, so early users (few ratings) still
            # get a reasonable profile instead of an all-zero vector.
            weights[field] = 0.3

    for field in NOMINAL_FIELDS:
        pool_liked = full_liked if field in STRUCTURAL_NOMINAL_FIELDS else liked
        pool_disliked = full_disliked if field in STRUCTURAL_NOMINAL_FIELDS else disliked
        # FIXED 2026-09-11: a book whose only evidence for this field is
        # below MIN_CONFIDENCE_TO_COUNT gets scoring_confidence()==0, but
        # `b.get(field)` is still truthy (it HAS a value, just an
        # unreliable one) -- so it used to survive into liked_vals/
        # disliked_vals as a zero-weight entry, making the list
        # non-empty while its weights summed to zero. Surfaced by
        # romance_tone/worldbuilding_delivery's confidence-0.2 backfilled
        # rows (this project's first NOMINAL_FIELD with real confidence-
        # 0.2 data clustered enough to zero out a whole pool for some
        # rater/genre split) as a ZeroDivisionError in disliked_share's
        # division -- but liked_share had the identical latent bug, just
        # hadn't hit the right data shape yet. Filtering zero-weight
        # entries out here (not just checking list non-emptiness) treats
        # "all evidence too unreliable to count" the same as "no
        # evidence" everywhere scoring_confidence() is used, which is
        # the correct, already-documented semantics -- this was an
        # oversight in applying it, not a new policy. The ORDINAL_FIELDS
        # loop's weighted_mean() already guards the equivalent case
        # (`if total_w == 0: return None`); this brings NOMINAL_FIELDS
        # in line with it.
        liked_vals = [
            (b.get(field), m * scoring_confidence(b, field)) for b, m in pool_liked if b.get(field)
        ]
        liked_vals = [(v, m) for v, m in liked_vals if m > 0]
        if not liked_vals:
            continue
        # magnitude-weighted mode
        counts = {}
        total_m = 0.0
        for v, m in liked_vals:
            counts[v] = counts.get(v, 0.0) + m
            total_m += m
        mode_val = max(counts, key=counts.get)
        liked_share = counts[mode_val] / total_m
        disliked_vals = [
            (b.get(field), m * scoring_confidence(b, field)) for b, m in pool_disliked if b.get(field)
        ]
        disliked_vals = [(v, m) for v, m in disliked_vals if m > 0]
        if disliked_vals:
            total_dm = sum(m for _, m in disliked_vals)
            disliked_share = sum(m for v, m in disliked_vals if v == mode_val) / total_dm
        else:
            disliked_share = 0.0
        centroid[field] = mode_val
        weights[field] = (
            min(WEIGHT_CAP, max(0.0, liked_share - disliked_share))
            if disliked_vals else 0.3 * liked_share
        )

    # Tropes: content, always genre-scoped. Per-trope weight = how much
    # more (or less) common it is in liked books vs. disliked books,
    # weighted by rating magnitude (a "loved" book's tropes count more
    # toward defining taste than a "liked" book's). Negative weight =
    # actively penalize (the trope appears in disliked books, not liked
    # ones).
    #
    # FIXED 2026-09-05: this loop (and the ORDINAL_FIELDS/NOMINAL_FIELDS
    # loops above) previously ignored get_confidence() entirely --
    # confidence only discounted a field/trope's contribution at
    # SCORING time (score_book()), never at WEIGHT-LEARNING time. A
    # low-confidence tag on a TRAINING book contributed to the learned
    # weight at full strength regardless of its own recorded
    # uncertainty -- confirmed directly: build_profile()'s trope
    # liked_freq/disliked_freq computation had no get_confidence() call
    # anywhere. This matters beyond the two new execution-DNA tropes:
    # real, non-uniform confidence values already exist for several
    # HIGH_RISK_FIELDS (person, pov_count, drive, narrative_closure,
    # romance_heat_intensity, and others) from earlier manual-review
    # passes -- this fix makes ALL of them actually count for less in
    # training, not just at scoring time. Keeps liked_trope_pairs/
    # disliked_trope_pairs as (book, magnitude) pairs (not
    # pre-extracted trope lists) specifically so get_confidence(b, t)
    # can be looked up per book per trope. total_liked_m/
    # total_disliked_m deliberately stay undiscounted -- they're a
    # shared normalizer across every trope (total rating-weight of the
    # whole pool), not something specific to any one trope's own
    # confidence; only each trope's OWN numerator (how much of that
    # pool actually counts as evidence for THIS trope) is discounted.
    trope_weights = {}
    liked_trope_pairs = liked
    disliked_trope_pairs = disliked
    total_liked_m = sum(m for _, m in liked_trope_pairs) or 1.0
    total_disliked_m = sum(m for _, m in disliked_trope_pairs)
    all_tropes = set(t for b, _ in liked_trope_pairs + disliked_trope_pairs for t in (b.get("tropes") or []))
    for t in all_tropes:
        liked_freq = sum(
            m * scoring_confidence(b, t) for b, m in liked_trope_pairs if t in (b.get("tropes") or [])
        ) / total_liked_m
        disliked_freq = (
            sum(m * scoring_confidence(b, t) for b, m in disliked_trope_pairs if t in (b.get("tropes") or []))
            / total_disliked_m
            if total_disliked_m else 0.0
        )
        raw = liked_freq - disliked_freq
        trope_weights[t] = max(-WEIGHT_CAP, min(WEIGHT_CAP, raw))
    weights["tropes"] = trope_weights

    return centroid, weights


def _resolve_profile(catalog, ratings, genre=None, fatigue_overrides=None, format_preference=None):
    """Shared by recommend() and explain_match(): resolves rating titles
    to ids, applies genre scoping, builds the profile, applies fatigue
    overrides. Returns (centroid, weights, id_to_magnitude, matches_genre).

    ratings: dict of {title: rating_label}, rating_label one of
    RATING_LABELS's keys ("hated", "disliked", "it_was_okay", "liked",
    "loved"). Replaces the old separate liked_titles/disliked_titles
    lists (2026-08-30) -- a flat like/dislike lost real information (see
    RATING_LABELS's docstring), and a "loved" book should pull a user's
    profile harder than a merely "liked" one.

    genre: None (blend everything, current default behavior), or
    'fantasy'/'sci_fi' to scope CONTENT-field profiling (tropes, tone,
    heat, violence -- see STRUCTURAL_*_FIELDS) to only the subset of
    rated books tagged with that genre. STRUCTURAL fields (pov_count,
    pacing, length, etc.) are always profiled from the FULL unscoped
    ratings regardless of genre, since craft/format taste plausibly
    doesn't depend on genre and benefits from the bigger sample -- see
    the WEIGHT_CAP-adjacent comment above for the case that motivated
    this split. Falls back to the unscoped ratings for content profiling
    if none of a user's ratings happen to fall in the requested genre.

    fatigue_overrides: optional dict of {trope_id_or_field_name: weight}
    that directly overrides the LEARNED weight for that key after
    build_profile() computes it -- e.g. {"werewolves": -1.0} to actively
    suppress a trope the user is fatigued on even though their rating
    history says they like it. A deliberate manual exception to their
    own average, not a re-estimate of it -- so it's a clobber, not a
    blend.

    format_preference: passed straight through to build_profile() (see
    its docstring) -- 'print'/None (default), 'audiobook', or 'mixed'.
    Callers should read this from the rater's `_meta.format_preference`,
    not guess it."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}

    id_to_magnitude = {}
    missing, invalid = [], []
    for title, label in ratings.items():
        if title not in title_to_id:
            missing.append(title)
            continue
        if label not in RATING_LABELS:
            invalid.append((title, label))
            continue
        id_to_magnitude[title_to_id[title]] = RATING_LABELS[label]
    if missing:
        print(f"WARNING: not found in catalog: {missing}")
    if invalid:
        print(f"WARNING: unknown rating label (must be one of {sorted(RATING_LABELS)}): {invalid}")

    def matches_genre(bid):
        return genre is None or genre in (catalog[bid].get("genre") or [])

    if genre is not None:
        scoped_ratings = {
            bid: m for bid, m in id_to_magnitude.items() if matches_genre(bid)
        } or id_to_magnitude
    else:
        scoped_ratings = id_to_magnitude

    centroid, weights = build_profile(catalog, scoped_ratings, id_to_magnitude, format_preference)

    if fatigue_overrides:
        for key, val in fatigue_overrides.items():
            val = max(-1.0, min(1.0, val))
            if key in ORDINAL_FIELDS or key in NOMINAL_FIELDS:
                weights[key] = val
            else:
                weights.setdefault("tropes", {})[key] = val

    return centroid, weights, id_to_magnitude, matches_genre

