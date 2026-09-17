"""Api components of the recommendation engine."""


from .cold_start import (
    cold_start_weight,
)
from .constants import (
    MAX_DIVERSITY,
)
from .explanations import (
    dealbreaker_sentence,
    describe,
    natural_sentence,
)
from .pipeline import (
    score_book,
    score_candidate,
    user_calibrated_poor_threshold,
    validated_dealbreaker_fields,
)
from .prevalence import (
    build_prevalence_lookup,
)
from .profile import (
    _resolve_profile,
)
from .rules import (
    normalize_user_rules,
)
from .series import (
    compute_series_dna,
)


def series_dnf_outlook(catalog, ratings, series_id, current_position, genre=None, fatigue_overrides=None):
    """For a user currently on (or considering DNFing) a specific book in
    a series, compares how well THIS user's profile matches the current
    entry vs. the entries still ahead -- surfaces "it gets better for
    you" or "it may not improve" instead of silence. Unlike
    compute_series_dna() above (objective, same for every reader), this
    is per-user: whether a series "improves" depends on what's shifting
    and whether that shift moves toward or away from THIS reader's
    taste, not just whether it shifts at all.

    Returns None if series_id isn't found, has < 2 books, or
    current_position isn't in it. Otherwise: {"current": (title, score),
    "next": (title, score) or None, "improves": bool or None, "note": str}."""
    books = sorted(
        (b for b in catalog.values() if b.get("series_id") == series_id),
        key=lambda b: float(b["position_in_series"] or 0),
    )
    if len(books) < 2:
        return None
    positions = [float(b["position_in_series"]) for b in books]
    if current_position not in positions:
        return None
    idx = positions.index(current_position)

    centroid, weights, _, _ = _resolve_profile(catalog, ratings, genre, fatigue_overrides)
    field_prevalence, trope_prevalence = build_prevalence_lookup(catalog, genre)
    scores = [score_book(b, centroid, weights, field_prevalence, trope_prevalence)[0] for b in books]

    current_title, current_score = books[idx]["title"], scores[idx]
    if idx + 1 >= len(books):
        return {
            "current": (current_title, round(current_score, 3)),
            "next": None,
            "improves": None,
            "note": f"'{current_title}' is the last entry in this series.",
        }

    next_title, next_score = books[idx + 1]["title"], scores[idx + 1]
    improves = next_score > current_score + 0.05  # small margin, not noise
    if improves:
        note = f"'{next_title}' tends to fit your taste better than '{current_title}' -- worth pushing through."
    elif next_score < current_score - 0.05:
        note = f"'{next_title}' fits your taste even less than '{current_title}' -- this series may not be for you."
    else:
        note = f"'{next_title}' is a similar fit to '{current_title}' -- don't expect it to feel very different."

    return {
        "current": (current_title, round(current_score, 3)),
        "next": (next_title, round(next_score, 3)),
        "improves": improves,
        "note": note,
    }


def recommend(catalog, ratings, top_n=10, genre=None,
              recent_history=None, diversity=0.0, fatigue_overrides=None,
              discovery_only=False, user_rules=None, format_preference=None):
    """See _resolve_profile() for ratings/genre/fatigue_overrides/format_preference.

    user_rules: raw shape for normalize_user_rules() -- explicit,
    user-supplied "none of X"/"less of X" preferences, applied as the
    very last step (after the cold-start blend), same as a hard content-
    warning filter would be. None/{} (the default) is a guaranteed
    no-op. See the "User-adjustable rules" section above recommend()
    for the full design rationale.

    recent_history: list of titles the user was recently recommended/has
    recently read, most-relevant for the `diversity` param below. Purely
    caller-supplied for now (no real per-user history table exists yet
    -- see book-dna.md's 2026-08-29 diversity/fatigue design note).

    diversity: 0.0 (default, today's pure-relevance behavior) up to
    MAX_DIVERSITY. Blends relevance (profile match) against novelty
    (distance from recent_history) via
    `final = (1 - diversity) * relevance + diversity * novelty`.
    Silently clamped to MAX_DIVERSITY -- diversity never reaches 1.0, so
    the relevance term never disappears entirely and a book that's a
    diametrical mismatch for the user's taste (not just "different from
    recent picks") stays capped low regardless of how novel it is. This
    is "summon something different," not "ignore my taste."

    discovery_only: manual opt-in, default False -- NEVER applied
    automatically, must be explicitly passed True by the caller each
    time (see docs/scoring-test-protocol.md's qualitative-review-round-2
    entry). When True, additionally excludes any candidate sharing a
    series_id OR an author string with ANY already-rated book,
    regardless of that rating's sign. This is a lens for a human
    manually auditing a recommendation list for whether the DNA fields
    themselves generalize to new authors/series, NOT a better default:
    recommending the next book of a series a user loves is correct,
    useful PRODUCT behavior, not a bug -- it only reads as "trivial"
    when the question being asked is "does the algorithm work," which
    is exactly why this stays a manual flag a caller must deliberately
    check, mirroring the existing series-isolated/author-isolated
    held-out test variants in scripts/scoring_tests.py rather than
    replacing recommend()'s default behavior with them."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    centroid, weights, id_to_magnitude, matches_genre = _resolve_profile(
        catalog, ratings, genre, fatigue_overrides, format_preference
    )
    validated_fields = validated_dealbreaker_fields(catalog, id_to_magnitude)
    csw = cold_start_weight(catalog, id_to_magnitude)
    series_dna = compute_series_dna(catalog)
    normalized_rules = normalize_user_rules(user_rules)
    field_prevalence, trope_prevalence = build_prevalence_lookup(catalog, genre)
    # Calibration is base-only and shared by every candidate in this call.
    # Ranking still returns only scores/contributions, not match labels.
    poor_threshold = user_calibrated_poor_threshold(
        catalog, id_to_magnitude, centroid, weights,
        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence
    )

    diversity = max(0.0, min(diversity, MAX_DIVERSITY))
    recent_books = [
        catalog[title_to_id[t]] for t in (recent_history or []) if t in title_to_id
    ]

    scored = []
    for bid, book in catalog.items():
        result = score_candidate(
            catalog, bid, centroid, weights, id_to_magnitude,
            policy="ranking", validated_fields=validated_fields,
            series_dna=series_dna, field_prevalence=field_prevalence,
            trope_prevalence=trope_prevalence, poor_threshold=poor_threshold,
            cold_start=csw, matches_genre=matches_genre,
            discovery_only=discovery_only, recent_books=recent_books,
            diversity=diversity, normalized_rules=normalized_rules
        )
        if result["exclusions"] or result["excluded_by_user_rule"]:
            continue
        scored.append((result["scores"]["final"], book["title"], book["author"],
                       result["contributions"]))

    scored.sort(key=lambda x: -x[0])
    return scored[:top_n]


def explain_match(catalog, ratings, title, genre=None, fatigue_overrides=None, top_n=5, format_preference=None):
    """Why does/doesn't `title` match this user's profile, in readable
    language? Works for ANY book in the catalog, not just ones
    recommend() would surface as a top result -- including a deliberately
    poor match, so a user searching a specific book gets an honest "why
    this probably isn't for you" instead of silence. Same underlying
    scoring math recommend() uses (see explain_book()), just decomposed
    for explanation instead of collapsed into a ranking.

    Returns {"title", "score", "match_label", "matches", "mismatches",
    "summary", "mismatch_summary", "dealbreaker_flags",
    "dealbreaker_summary", "series_note"} -- matches/mismatches are
    ordered lists of human-readable phrases (see describe());
    summary/mismatch_summary are the same data assembled into one
    readable sentence each (see natural_sentence()) instead of a flat
    list. dealbreaker_flags/dealbreaker_summary are a SEPARATE view of
    strong mismatches specifically (see dealbreaker_flags()) -- these
    already appear inside `mismatches` too (this doesn't remove or
    change anything there), but are called out on their own here so a
    caller can render "Good match, but: X" as a distinct, prominent
    callout instead of a strong dealbreaker reading as just one more
    item in a list of minor notes, and so a caller doesn't have to
    re-derive "which of these mismatches is actually the important one"
    itself. What counts as "strong enough" is per-user where there's
    enough evidence to say so (validated_dealbreaker_fields() -- a lower
    bar for a field with real statistical separation in THIS user's own
    liked-vs-disliked history) and a fixed fallback threshold otherwise.
    dealbreaker_flags is [] (and dealbreaker_summary "") on the
    common case where nothing crosses the threshold -- most books don't
    hit a real dealbreaker, so an empty flag list is the expected
    default, not a sign anything's wrong. series_note is a caveat about
    how the book's series changes over its run (see
    compute_series_dna()/describe_series_trajectory()), "" if the book
    isn't part of a multi-book series or nothing shifts meaningfully --
    most series stay consistent, so this is the common case, not a
    bug."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    if title not in title_to_id:
        raise ValueError(f"{title!r} not found in catalog")
    book_id = title_to_id[title]
    book = catalog[book_id]

    centroid, weights, id_to_magnitude, _ = _resolve_profile(catalog, ratings, genre, fatigue_overrides, format_preference)
    validated = validated_dealbreaker_fields(catalog, id_to_magnitude)
    series_dna = compute_series_dna(catalog)
    field_prevalence, trope_prevalence = build_prevalence_lookup(catalog, genre)
    poor_threshold = user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights,
                                                     field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)
    if top_n is None:
        # explain_book() treats [:None] as unlimited; score_candidate() uses
        # None for its default limit. Each scalar/trope supplies at most one
        # row per evidence list, so this bound preserves the unlimited view.
        top_n = len(weights) + len(weights.get("tropes", {}))
    result = score_candidate(
        catalog, book_id, centroid, weights, id_to_magnitude,
        policy="explanation", validated_fields=validated, series_dna=series_dna,
        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence,
        poor_threshold=poor_threshold, top_n=top_n
    )
    score = result["scores"]["final"]
    matches, mismatches = result["matches"], result["mismatches"]
    flags = result["dealbreaker_flags"]
    series_note = result["series_note"]

    matches_labeled = [(label, p) for label, _ in matches if (p := describe(label, book))]
    mismatches_labeled = [(label, p) for label, _ in mismatches if (p := describe(label, book))]
    flags_labeled = [(label, p) for label, _ in flags if (p := describe(label, book))]

    return {
        "title": title,
        "score": round(score, 3),
        "match_label": result["match_label"],
        "matches": [p for _, p in matches_labeled],
        "mismatches": [p for _, p in mismatches_labeled],
        "summary": natural_sentence(matches_labeled, positive=True),
        "mismatch_summary": natural_sentence(mismatches_labeled, positive=False),
        "dealbreaker_flags": [p for _, p in flags_labeled],
        "dealbreaker_summary": dealbreaker_sentence(flags_labeled),
        "series_note": series_note,
    }

