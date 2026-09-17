"""Pipeline components of the recommendation engine."""


from .calibration import (
    match_label,
    scoring_confidence,
)
from .constants import (
    DEALBREAKER_THRESHOLD,
    DEALBREAKER_VETO_CAP,
    DEALBREAKER_VETO_PULL_FLOOR,
    DEALBREAKER_VETO_SEVERITY_SPAN,
    DEFAULT_POOR_THRESHOLD,
    GENRE_ACCESSIBILITY_DEMAND,
    MAX_DIVERSITY,
    MIN_DEALBREAKER_SAMPLE,
    NOMINAL_FIELDS,
    ORDINAL_FIELDS,
    PREVALENCE_DISCOUNT_FLOOR,
    REDUNDANCY_DISCOUNTS,
    SERIES_REPEAT_WEIGHT,
    SERIES_TRAJECTORY_DIVERGENCE_THRESHOLD,
    SERIES_TRAJECTORY_MAX_PENALTY,
    STAT_SEPARATION_THRESHOLD,
    VALIDATED_DEALBREAKER_MAGNITUDE,
)
from .encoding import (
    nominal_similarity,
    ordinal_position,
)
from .profile import (
    _series_deduped_id_to_magnitude,
)
from .rules import (
    apply_user_rules,
)
from .series import (
    book_similarity,
    describe_series_trajectory,
    series_position_ready,
    series_repeat_worst_similarity,
)


def user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights,
                                    default=DEFAULT_POOR_THRESHOLD,
                                    field_prevalence=None, trope_prevalence=None):
    """A per-user replacement for match_label()'s fixed Poor/Mixed
    boundary: the midpoint between THIS user's own mean score on their
    liked/loved training books and their disliked/hated ones (both
    rescored against their own freshly-built profile -- i.e. how the
    model scores the very evidence it was built from).

    field_prevalence/trope_prevalence: pass the SAME prevalence lookup
    used to score the candidates this threshold will be compared
    against (see score_book()'s docstring) -- calibrating against
    undiscounted scores while candidates get discounted ones would
    silently miscalibrate the Poor/Mixed boundary itself.

    Falls back to `default` (unchanged) if the user has no disliked/hated
    ratings to calibrate against -- deliberately: with zero negative
    training signal there's no genuine dealbreaker pattern to locate, and
    inventing a cutoff from liked-book score variance alone would risk
    exactly the failure mode a purely relative/percentile threshold has
    (see the design discussion in docs/scoring-test-protocol.md,
    2026-09-02) -- labeling a user's merely-less-loved books "Poor" when
    nothing in their real history is actually a dealbreaker. Verified
    directly against a synthetic all-positive rating set in
    scripts/scoring_tests.py's threshold diagnostic.

    Capped to [0.20, 0.54] -- the ceiling sits just under the Good-match
    boundary (0.55) so a high midpoint can't collapse the "Mixed match"
    bucket entirely; the floor guards a tiny disliked-score outlier
    dragging the midpoint implausibly low."""
    liked_scores, disliked_scores = [], []
    for bid, mag in id_to_magnitude.items():
        book = catalog.get(bid)
        if book is None:
            continue
        score, _ = score_book(book, centroid, weights, field_prevalence, trope_prevalence)
        if mag > 0:
            liked_scores.append(score)
        elif mag < 0:
            disliked_scores.append(score)
    if not liked_scores or not disliked_scores:
        return default
    mean_liked = sum(liked_scores) / len(liked_scores)
    mean_disliked = sum(disliked_scores) / len(disliked_scores)
    return max(0.20, min(0.54, (mean_liked + mean_disliked) / 2))


def _redundancy_adjusted_weight(book, field, w):
    """w with any applicable REDUNDANCY_DISCOUNTS applied, conditional on
    this specific book's own value for the triggering field -- see
    REDUNDANCY_DISCOUNTS's comment above for why this must be per-book,
    not a blanket per-profile scaling."""
    for (dependent, trigger_field, trigger_value), discount in REDUNDANCY_DISCOUNTS.items():
        if field == dependent and book.get(trigger_field) == trigger_value:
            w = w * (1 - discount)
    return w


def _iter_book_factors(book, centroid, weights, field_prevalence=None, trope_prevalence=None):
    """Yield (label, similarity, raw_weight, effective_weight, is_trope).

    Scalar fields follow weights' insertion order; present tropes follow
    weights["tropes"] order afterward, exactly as the original consumers.
    Missing scalar values/centroids and absent tropes are skipped. Zero
    effective weights are retained: filtering and accumulation belong to
    the consumers, including their different raw-weight display gates.

    A present trope has similarity 1.0, but consumers still add its
    effective weight directly (rather than changing their arithmetic).
    This evaluator sits below scoring and explanation; it never invokes
    either consumer or a higher-level scoring modifier.
    """
    for field, w in weights.items():
        if field == "tropes":
            continue
        if field not in centroid:
            continue
        if field in ORDINAL_FIELDS:
            pos = ordinal_position(field, book.get(field))
            if pos is None:
                continue
            book_val = pos[0] / pos[1]
            sim = 1 - abs(book_val - centroid[field])
        else:
            # FIXED 2026-09-11: a NOMINAL field this book was never
            # tagged for (book.get(field) is None) used to fall through
            # to nominal_similarity(), which returns 0.0 -- a FULL
            # MISMATCH -- for any (None, real_value) pair, since no
            # partial-credit entry exists for None. That's wrong: no
            # tag means no evidence either way, the same "skip this
            # field for this book" treatment ORDINAL_FIELDS already
            # gets via ordinal_position() returning None above. Never
            # surfaced before because every existing NOMINAL field had
            # near-total coverage; romance_tone/worldbuilding_delivery
            # (this session) are the first with substantial (~85%)
            # missing data, which is what exposed this -- confirmed via
            # a real regression across every Mathias scorecard row in
            # an A/B test before this fix landed (see
            # docs/scoring-test-protocol.md's 2026-09-11 entry).
            if book.get(field) is None:
                continue
            sim = nominal_similarity(field, book.get(field), centroid[field])
        w_eff = _redundancy_adjusted_weight(book, field, w) * scoring_confidence(book, field)
        if field_prevalence is not None:
            prevalence = field_prevalence.get(field, {}).get(book.get(field), 0.0)
            w_eff *= max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence)
        yield field, sim, w, w_eff, False

    trope_weights = weights.get("tropes", {})
    book_tropes = set(book.get("tropes") or [])
    for t, w in trope_weights.items():
        if t not in book_tropes:
            continue
        w_eff = w * scoring_confidence(book, t)
        if trope_prevalence is not None:
            prevalence = trope_prevalence.get(t, 0.0)
            w_eff *= max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence)
        yield f"trope:{t}", 1.0, w, w_eff, True


def score_book(book, centroid, weights, field_prevalence=None, trope_prevalence=None):
    """Confidence discount (2026-08-30): a field/trope's effective weight
    for THIS book is scaled by get_confidence(book, field) before it
    contributes -- an uncertain tag gets less voting power in the
    weighted average rather than being trusted at face value or assumed
    to be a mismatch. Discounting both the numerator (contribution) and
    denominator (total_weight) equally is what keeps this a "count for
    less" effect rather than a bias toward either match or mismatch.

    Candidate-pool prevalence discount (2026-09-06, LANDED): field_prevalence/
    trope_prevalence -- from build_prevalence_lookup(catalog, genre), computed
    ONCE per scoring session by the caller, never per candidate -- further
    scale w_eff by max(PREVALENCE_DISCOUNT_FLOOR, 1 - prevalence) when given.
    A genuine, well-evidenced preference can still fail to RANK one candidate
    above another if most of the candidate pool already shares the matching
    value (e.g. emotional_resolution: bittersweet at ~53% catalog prevalence
    contributed a suspiciously constant +0.323 across nearly every top
    fantasy match before this landed) -- see docs/scoring-test-protocol.md's
    2026-09-06 entries for the full validation (8-row scorecard, all 4 real
    raters, every regression traced to a specific book and understood, not
    just accepted because the aggregate numbers looked fine) this landed on.
    None/None (the default) is a guaranteed no-op, byte-identical to
    pre-2026-09-06 behavior -- callers with no genre/catalog context handy
    (most of scripts/scoring_tests.py's direct calls) are unaffected."""
    score = 0.0
    total_weight = 0.0
    contributions = []

    for label, sim, w, w_eff, is_trope in _iter_book_factors(
        book, centroid, weights, field_prevalence, trope_prevalence
    ):
        contribution = w_eff if is_trope else w_eff * sim
        score += contribution
        total_weight += abs(w_eff)
        # Preserve the original asymmetry: scalar display gates use the
        # signed raw weight, while trope gates use its absolute value.
        if (abs(w) if is_trope else w) > 0.15:
            contributions.append((label, round(contribution, 3)))

    normalized = score / total_weight if total_weight > 0 else 0.0
    # Secondary sort key (field/trope name) for the same reason explain_book()
    # needs one -- see its own comment above the equivalent sort.
    contributions.sort(key=lambda x: (-abs(x[1]), x[0]))
    return normalized, contributions[:5]



def explain_book(book, centroid, weights, top_n=5, field_prevalence=None, trope_prevalence=None):
    """Splits scoring factors into what's pulling the score UP (matches)
    vs. DOWN (mismatches) for this book against this profile -- the same
    math score_book() uses, decomposed for human explanation instead of
    collapsed into one number.

    Why this needs its own factor view rather than just re-reading
    score_book()'s contributions: a field can have a small raw
    contribution (w * sim) for two very different reasons -- either the
    user doesn't weight it much (w is small), or it matters a lot AND
    this book misses on it (sim is small). Those look identical in
    score_book()'s output but need opposite wording ("doesn't matter to
    you" vs. "this is specifically why it's a mismatch"). `deviation`
    (w * (1 - sim)) disambiguates: a field can score low on
    contribution yet high on deviation, and that's exactly the
    "mismatch" case worth surfacing.

    Returns (matches, mismatches), each a list of (label, magnitude)
    pairs sorted descending, capped at top_n, magnitude thresholded at
    > 0.1 to exclude noise-level factors. Same confidence discount as
    score_book() -- see its docstring -- applied to `w` before either
    match or mismatch magnitude is computed, so a low-confidence tag
    shows up muted in the explanation too, not just the ranking.
    field_prevalence/trope_prevalence: same prevalence-discount mechanism
    as score_book() (see its docstring) -- pass the SAME lookup used for
    the candidate's score_book() call so the displayed matches/mismatches
    stay consistent with the number they're explaining, not a different
    pipeline than what the user actually sees."""
    matches, mismatches = [], []

    for field, sim, raw_weight, w, is_trope in _iter_book_factors(
        book, centroid, weights, field_prevalence, trope_prevalence
    ):
        if is_trope:
            (matches if w >= 0 else mismatches).append((field, abs(w)))
        elif w >= 0:
            matches.append((field, w * sim))
            mismatches.append((field, w * (1 - sim)))
        else:
            # Negative weight only comes from a fatigue override --
            # matching the profile here IS the mismatch (the user asked
            # to suppress this specifically), not matching it is the win.
            matches.append((field, abs(w) * (1 - sim)))
            mismatches.append((field, abs(w) * sim))

    # Secondary sort key (field/trope name) makes tie order deterministic --
    # without it, ties depend on set()/dict iteration order upstream (see
    # trope collection in _iter_book_factors()), which CODX's 2026-09-15 structural
    # audit (F10) caught actually flipping between two identical runs.
    # Scores/ranks are unaffected either way; only the DISPLAY order of
    # equal-magnitude matches/mismatches is now stable.
    matches = sorted((m for m in matches if m[1] > 0.1), key=lambda x: (-x[1], x[0]))
    mismatches = sorted((m for m in mismatches if m[1] > 0.1), key=lambda x: (-x[1], x[0]))
    return matches[:top_n], mismatches[:top_n]


def _ordinal_field_separation(catalog, id_to_magnitude, field):
    """Point-biserial-style correlation between group membership (loved/
    liked=1, disliked/hated=0; it_was_okay excluded, same split
    build_profile() uses) and this ORDINAL field's position, for THIS
    user's own rated books. None if fewer than MIN_DEALBREAKER_SAMPLE
    observations exist in either group.

    A confidence-zeroed tag (scoring_confidence() below
    MIN_CONFIDENCE_TO_COUNT) is excluded from both the statistic AND the
    sample-size gate -- build_profile() already treats this evidence as
    too uncertain to count at all; this validation path has to enforce
    the same floor or it can validate a field (and let the veto fire)
    on evidence the profile itself ignored (found by CODX's 2026-09-14
    review)."""
    liked, disliked = [], []
    for bid, mag in id_to_magnitude.items():
        if mag == 0:
            continue
        book = catalog.get(bid)
        if book is None:
            continue
        if scoring_confidence(book, field) <= 0:
            continue
        pos = ordinal_position(field, book.get(field))
        if pos is None:
            continue
        (liked if mag > 0 else disliked).append(pos[0] / pos[1])
    if len(liked) < MIN_DEALBREAKER_SAMPLE or len(disliked) < MIN_DEALBREAKER_SAMPLE:
        return None
    all_vals = liked + disliked
    n, n1, n0 = len(all_vals), len(liked), len(disliked)
    mean_all = sum(all_vals) / n
    variance = sum((v - mean_all) ** 2 for v in all_vals) / n
    sn = variance ** 0.5
    if sn == 0:
        return 0.0
    m1, m0 = sum(liked) / n1, sum(disliked) / n0
    p, q = n1 / n, n0 / n
    return (m1 - m0) / sn * (p * q) ** 0.5


def _nominal_field_separation(catalog, id_to_magnitude, field):
    """Modal-agreement gap for one NOMINAL field: the liked group's own
    most-common value, minus how common that SAME value is in the
    disliked group. Not a true correlation coefficient (nominal values
    have no natural order to correlate against) -- the natural analogous
    measure for unordered categorical data, structurally the same
    statistic build_profile() already computes as a nominal field's raw
    weight, isolated here for gating rather than feeding the score
    directly. None if fewer than MIN_DEALBREAKER_SAMPLE observations
    exist in either group. Same confidence-floor exclusion as
    _ordinal_field_separation() above (found by CODX's 2026-09-14
    review) -- see its docstring."""
    liked_vals, disliked_vals = [], []
    for bid, mag in id_to_magnitude.items():
        if mag == 0:
            continue
        book = catalog.get(bid)
        if book is None:
            continue
        if scoring_confidence(book, field) <= 0:
            continue
        val = book.get(field)
        if not val:
            continue
        (liked_vals if mag > 0 else disliked_vals).append(val)
    if len(liked_vals) < MIN_DEALBREAKER_SAMPLE or len(disliked_vals) < MIN_DEALBREAKER_SAMPLE:
        return None
    counts = {}
    for v in liked_vals:
        counts[v] = counts.get(v, 0) + 1
    mode_val = max(counts, key=counts.get)
    liked_share = counts[mode_val] / len(liked_vals)
    disliked_share = sum(1 for v in disliked_vals if v == mode_val) / len(disliked_vals)
    return liked_share - disliked_share


def _trope_separation(catalog, id_to_magnitude, trope_id):
    """Liked-frequency minus disliked-frequency for one trope's presence
    -- same statistic build_profile() already computes as a trope's raw
    weight, isolated here for gating. Sample-size gate uses TOTAL
    liked/disliked books rated (the frequency denominators), not just
    books that happen to have this trope -- a trope's absence is exactly
    as informative as its presence. None if fewer than
    MIN_DEALBREAKER_SAMPLE liked or disliked books exist at all. A book
    where THIS trope is tagged below MIN_CONFIDENCE_TO_COUNT is excluded
    from both the hit count and the sample gate -- we don't actually
    trust whether it's present or absent, so it can't count as evidence
    either way (same confidence-floor gap as the ordinal/nominal
    versions above, found by CODX's 2026-09-14 review)."""
    liked_n = disliked_n = liked_hits = disliked_hits = 0
    for bid, mag in id_to_magnitude.items():
        if mag == 0:
            continue
        book = catalog.get(bid)
        if book is None:
            continue
        if scoring_confidence(book, trope_id) <= 0:
            continue
        has = trope_id in (book.get("tropes") or [])
        if mag > 0:
            liked_n += 1
            liked_hits += has
        else:
            disliked_n += 1
            disliked_hits += has
    if liked_n < MIN_DEALBREAKER_SAMPLE or disliked_n < MIN_DEALBREAKER_SAMPLE:
        return None
    return liked_hits / liked_n - disliked_hits / disliked_n


def field_or_trope_separation(catalog, id_to_magnitude, key):
    """Dispatches to the right separation statistic for `key` (a bare
    field name, or "trope:<id>" as used throughout explain_book()'s
    output). None for anything not a known field/trope, or with too few
    observations to trust (see each helper's own docstring)."""
    if key.startswith("trope:"):
        return _trope_separation(catalog, id_to_magnitude, key[len("trope:"):])
    if key in ORDINAL_FIELDS:
        return _ordinal_field_separation(catalog, id_to_magnitude, key)
    if key in NOMINAL_FIELDS:
        return _nominal_field_separation(catalog, id_to_magnitude, key)
    return None


def validated_dealbreaker_fields(catalog, id_to_magnitude, min_strength=STAT_SEPARATION_THRESHOLD):
    """The set of field/trope keys that clear BOTH the minimum-sample
    gate and min_strength -- a per-user, statistically grounded set of
    genuine dealbreaker candidates for this specific person, rather than
    a fixed magnitude threshold applied uniformly to everyone.

    Only checks fields/tropes that appear at least once among this
    user's OWN rated books (liked or disliked) -- scanning the full
    catalog vocabulary would be wasted work and meaningless for anything
    this user has no rating evidence about. Returns an empty set for a
    user without enough liked AND disliked ratings to validate anything
    -- see dealbreaker_flags()'s fallback behavior for what happens then.

    Known simplification: unlike build_profile(), this doesn't apply
    STRUCTURAL_*_FIELDS genre-scoping (structural fields from the full
    rating pool, content fields/tropes from the genre-scoped pool) --
    always uses the full id_to_magnitude. A reasonable v1 scope limit,
    not revisited here; flagged in case it matters once more rater data
    exists.

    Series-deduped internally (2026-09-05, per the 10-hypothesis
    review's #2 finding) -- separation is computed against the same
    deduped evidence build_profile() itself uses, not raw magnitudes a
    heavily-clustered series would otherwise inflate. Dedupes its OWN
    id_to_magnitude argument fresh every call (never assumes the caller
    already deduped it) -- every existing call site keeps passing the
    same raw dict it always has; this function alone is now internally
    consistent with build_profile() regardless of caller. (A permutation-
    based adaptive replacement for min_strength itself was tried and
    reverted the same day -- see STAT_SEPARATION_THRESHOLD's own comment.)"""
    deduped = _series_deduped_id_to_magnitude(catalog, id_to_magnitude)

    keys = set()
    for bid, mag in deduped.items():
        if mag == 0:
            continue
        book = catalog.get(bid)
        if book is None:
            continue
        keys.update(f for f in ORDINAL_FIELDS if book.get(f) is not None)
        keys.update(f for f in NOMINAL_FIELDS if book.get(f) is not None)
        keys.update(f"trope:{t}" for t in (book.get("tropes") or []))

    validated = set()
    for key in keys:
        sep = field_or_trope_separation(catalog, deduped, key)
        if sep is not None and abs(sep) >= min_strength:
            validated.add(key)
    return validated


def dealbreaker_flags(book, centroid, weights, top_n=5, threshold=DEALBREAKER_THRESHOLD,
                       validated_fields=None, field_prevalence=None, trope_prevalence=None):
    """A subset of explain_book()'s mismatches strong enough to plausibly
    function as a personal dealbreaker for this book/user, not just one
    of several things slightly off. Computed over explain_book()'s FULL
    mismatch list (top_n=100, well above any realistic field count), not
    its caller-facing top_n cap, so a real dealbreaker can never be
    silently dropped by that cap the way the human-readable mismatch
    list can be.

    validated_fields: optional set from validated_dealbreaker_fields().
    When given AND NON-EMPTY, this REPLACES the fixed-threshold check
    rather than adding to it: only fields/tropes actually IN the set are
    eligible to be flagged at all, at a lower magnitude bar
    (VALIDATED_DEALBREAKER_MAGNITUDE) since real per-user statistical
    evidence already backs them -- an unvalidated field's mismatch,
    however large, is NOT flagged in this mode. This matters concretely:
    a sanity check across all 4 real raters (2026-09-02) found the fixed
    threshold ALONE has a high false-positive rate (books the user
    LOVED still tripping a "dealbreaker" flag -- 60% for Mathias, 100%
    for two smaller-data raters), because a field/trope's raw weight
    from only a handful of ratings is noisy, and noise can cross 0.3 by
    chance as easily as a real pattern can. Restricting to the validated
    set is what actually suppresses that -- adding a lower bar on top of
    the untouched fixed threshold would only add MORE flags, not remove
    the noisy ones. When validated_fields is None or empty (too few
    ratings to validate anything for this user -- see
    MIN_DEALBREAKER_SAMPLE), falls back to the original fixed-threshold
    behavior applied to every field -- noisier, but something is better
    than nothing when there's no evidence yet to be more selective with.

    This is purely additive to the SCORING side -- score/match_label/
    matches/mismatches are all computed exactly as before, regardless of
    this parameter. It exists because folding a single strong signal
    into the weighted-average score keeps failing: the average is
    compensatory by construction, so one real mismatch (e.g. disliking
    first-person narration) gets outvoted by several unrelated fields
    that happen to agree with the user's general taste (see
    docs/scoring-test-protocol.md's "stakes_drive/craft_density:
    investigated, not a real lever" and the design discussion that
    followed it). Surfacing the strong mismatch as an explicit flag next
    to the score sidesteps that math problem instead of re-fighting it."""
    _, mismatches = explain_book(book, centroid, weights, top_n=100,
                                  field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)
    if validated_fields:
        flags = [(f, m) for f, m in mismatches if f in validated_fields and m >= VALIDATED_DEALBREAKER_MAGNITUDE]
    else:
        flags = [(f, m) for f, m in mismatches if m >= threshold]
    return flags[:top_n]


def _apply_series_repeat(catalog, id_to_magnitude, book, score):
    """Blends `score` with the series-repeat signal (see above) when
    applicable; returns `score` unchanged otherwise."""
    worst_sim = series_repeat_worst_similarity(catalog, id_to_magnitude, book)
    if worst_sim is None:
        return score
    series_component = 1 - worst_sim
    return (1 - SERIES_REPEAT_WEIGHT) * score + SERIES_REPEAT_WEIGHT * series_component


def _series_trajectory_penalty_factor(series_dna, book, centroid, weights,
                                       field_prevalence=None, trope_prevalence=None):
    """Returns a multiplier in [1 - SERIES_TRAJECTORY_MAX_PENALTY, 1.0] --
    1.0 = no penalty, the common case (most books aren't series entry
    points with a real divergent trajectory). `series_dna`:
    compute_series_dna(catalog)'s result, precomputed ONCE by the
    caller (it's a pure function of the catalog, not of any one user's
    profile) rather than recomputed per candidate.

    Only applies to the series' ENTRY POINT (this book's own position
    equals the series' lowest tagged position) -- comparing "series
    start vs. end" only makes sense for a candidate that actually IS
    the start. Found and fixed during testing (2026-09-04): the first
    version applied this to every series book scored directly (Rhythm
    of War, WoT book 4; A Clash of Kings, ASOIAF book 2), which isn't
    what "will a NEW reader's experience of picking this series up
    diverge" is asking, and produced badly inflated, broad damage in
    the real benchmark (see docs/scoring-test-protocol.md)."""
    if book.get("narrative_closure") != "requires_series":
        return 1.0
    series_id = book.get("series_id")
    if series_id is None:
        return 1.0
    entry = series_dna.get(series_id)
    if entry is None:
        return 1.0
    own_position = book.get("position_in_series")
    if own_position is None:
        return 1.0
    earliest_position = min(pos for pos, _ in entry["books"] if pos is not None)
    if float(own_position) != float(earliest_position):
        return 1.0

    matches, _ = explain_book(book, centroid, weights, top_n=100,
                               field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)
    strong_fields = {f: c for f, c in matches if c > 0.15 and not f.startswith("trope:")}
    if not strong_fields:
        return 1.0

    total_divergence = 0.0
    for field in strong_fields:
        traj = entry["trajectories"].get(field)
        if traj is None or traj["trend"] == "stable" or field not in weights:
            continue
        if field in ORDINAL_FIELDS:
            start_pos = ordinal_position(field, traj["start_value"])
            end_pos = ordinal_position(field, traj["end_value"])
            if start_pos is None or end_pos is None:
                continue
            start_sim = 1 - abs(start_pos[0] / start_pos[1] - centroid[field])
            end_sim = 1 - abs(end_pos[0] / end_pos[1] - centroid[field])
        else:
            if field not in centroid:
                continue
            start_sim = nominal_similarity(field, traj["start_value"], centroid[field])
            end_sim = nominal_similarity(field, traj["end_value"], centroid[field])
        drop = start_sim - end_sim
        if drop > SERIES_TRAJECTORY_DIVERGENCE_THRESHOLD:
            field_weight = weights[field]
            if isinstance(field_weight, dict):
                # NOMINAL field under per-value weight learning (see
                # the 2026-09-04 landing note near this file's bottom)
                # -- "how much does this field matter" is now specific
                # to a VALUE, not the field as a whole. Use the
                # candidate's own value's weight: `strong_fields` was
                # already derived from this exact book's matches, so
                # this book's own value is the relevant one to weight
                # the divergence by.
                field_weight = field_weight.get(book.get(field), 0.0)
            total_divergence += drop * abs(field_weight)

    if total_divergence <= 0:
        return 1.0
    return 1 - min(SERIES_TRAJECTORY_MAX_PENALTY, total_divergence)


def _apply_series_trajectory_penalty(series_dna, book, centroid, weights, score,
                                      field_prevalence=None, trope_prevalence=None):
    return score * _series_trajectory_penalty_factor(series_dna, book, centroid, weights,
                                                       field_prevalence, trope_prevalence)


def _apply_dealbreaker_veto(catalog, id_to_magnitude, validated_fields, book, centroid, weights, score,
                             field_prevalence=None, trope_prevalence=None):
    """ELECTRE-style veto (option #2 from the aggregation-shape design
    discussion, 2026-09-02): if `book` mismatches on a field/trope
    that's statistically validated as a dealbreaker for THIS user (see
    validated_dealbreaker_fields()), caps `score` so it can never read
    as Good/Strong match -- this is what actually moves the RANKING,
    unlike dealbreaker_flags()/dealbreaker_summary (landed earlier the
    same day), which only ever added a displayed callout next to an
    unchanged score. Directly closes the gap that left open: Royal
    Assassin's flag correctly named "first-person narration" as the
    reason it's not for Mathias, but the score itself (0.339-0.65
    depending on scenario) never moved because of it.

    Deliberately conservative, unlike the 2026-08-29 "structural-field
    prior boost" this project already tried and rejected for reopening
    the WEIGHT_CAP_RATINGS domination bug (a blanket boost applied to
    every candidate regardless of evidence):
    - Only fires when `validated_fields` is non-empty -- i.e. real,
      per-user statistical evidence exists (see MIN_DEALBREAKER_SAMPLE/
      STAT_SEPARATION_THRESHOLD). NEVER fires from dealbreaker_flags()'s
      fixed-threshold fallback for low-data users -- that fallback is
      already documented as noisy (see the dealbreaker-flag sanity
      check) and isn't trustworthy enough to move a score, only to
      display a flag. A low-data user's ranking is completely unaffected
      by this function -- score in, score out, unchanged.
    - Caps at "just below Good match" (DEALBREAKER_VETO_CAP), not "forced
      to Poor match." A validated dealbreaker means the model shouldn't
      confidently recommend the book, not that it's certainly a bad
      match -- real exceptions exist in every rater's own data (Mathias
      liked Old Man's War despite `person` -- his single most validated
      dealbreaker field -- mismatching on it).
    - Does NOT stack across multiple flagged fields in this version --
      one validated mismatch is enough to cap; a second doesn't cap
      further. A scope decision, not a finding from testing -- revisit
      if real evidence says the cap needs to go lower.

    Returns `score` unchanged if validated_fields is empty or nothing
    flags."""
    if not validated_fields:
        return score
    flags = dealbreaker_flags(book, centroid, weights, validated_fields=validated_fields,
                               field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)
    if not flags:
        return score
    return min(score, DEALBREAKER_VETO_CAP)


def _apply_dealbreaker_veto_graduated(catalog, id_to_magnitude, validated_fields, book, centroid, weights, score,
                                       field_prevalence=None, trope_prevalence=None):
    """EXPERIMENTAL -- see the comment block above. Same trigger condition
    as _apply_dealbreaker_veto() (only fires with a non-empty validated_fields
    and a real flag), but instead of clamping score to DEALBREAKER_VETO_CAP
    outright, pulls it toward the cap by a fraction between
    DEALBREAKER_VETO_PULL_FLOOR (weakest qualifying flag) and 1.0 (a flag
    at or above WEIGHT_CAP severity -- identical to the flat clamp)."""
    if not validated_fields:
        return score
    flags = dealbreaker_flags(book, centroid, weights, validated_fields=validated_fields,
                               field_prevalence=field_prevalence, trope_prevalence=trope_prevalence)
    if not flags:
        return score
    if score <= DEALBREAKER_VETO_CAP:
        return score
    strongest = max(m for _, m in flags)
    severity = min(1.0, max(0.0, (strongest - VALIDATED_DEALBREAKER_MAGNITUDE) / DEALBREAKER_VETO_SEVERITY_SPAN))
    pull = DEALBREAKER_VETO_PULL_FLOOR + (1 - DEALBREAKER_VETO_PULL_FLOOR) * severity
    return score - pull * (score - DEALBREAKER_VETO_CAP)


def score_candidate(catalog, book_id, centroid, weights, id_to_magnitude, *,
                    policy, validated_fields, series_dna, field_prevalence,
                    trope_prevalence, poor_threshold, cold_start=None,
                    matches_genre=None, discovery_only=False, recent_books=(),
                    diversity=0.0, normalized_rules=None, top_n=None):
    """Assemble an explicit score result. `recommend()` consumes this via
    policy="ranking" (A3, 2026-09-16); `explain_match()` via
    policy="explanation" (A4, 2026-09-16); `scoring_tests._full_score()`
    via policy="evaluation" (A5, 2026-09-16); `audit_book_score()` via
    policy="audit" (2026-09-16, Task 8) -- every production/test caller
    of the original stage sequence now goes through this function.

    Prepared inputs belong to ONE caller-owned catalog/profile context:
    _resolve_profile() supplies centroid/weights/id_to_magnitude/matches_genre;
    validated_dealbreaker_fields(), compute_series_dna(), and
    build_prevalence_lookup() supply the other required context. Pass the
    independently computed user_calibrated_poor_threshold() result: calibration
    stays base-only and is never a stage of this candidate's pipeline. No
    module-global cache or implicit profile/genre/format choice is used here.

    Policies preserve the current callers' intentionally different contracts:
      ranking: eligibility -> base -> repeat -> veto -> trajectory -> diversity
               -> cold start -> rules (recommend)
      explanation / evaluation: base -> repeat -> veto -> trajectory
               (explain_match / scoring_tests._full_score)
      audit: base -> repeat -> veto -> trajectory -> cold start -> rules
               (audit_book_score; rule-excluded books still have a score)

    ranking requires matches_genre from _resolve_profile(). ranking/audit
    require cold_start from cold_start_weight(). Normalize rules and resolve
    recent titles to catalog books once OUTSIDE this function. Other policies
    ignore these ranking/audit-only inputs, just as their current callers do.
    Sorting and top-K selection remain the ranking caller's responsibility.

    Scores and factor tuples are unrounded. factors uses _iter_book_factors's
    (label, similarity, raw_weight, effective_weight, is_trope) contract;
    contributions retains score_book's rounded top-five display contract.
    matches/mismatches and dealbreaker_flags are raw (label, magnitude) pairs,
    not phrases or the audit's separately attributed/rounded display rows.
    top_n defaults to 100 for audit and 5 otherwise; flag count remains the
    existing dealbreaker_flags default, independent of top_n.

    stage_sequence names enabled score stages. A skipped optional stage carries
    forward its input unchanged in scores; it does NOT mean it was applied.
    Ranking eligibility short-circuits in recommend's order: the first exclusion
    is returned, all scores/label are None, and no scoring/evidence stage runs.
    Rule exclusions retain their final score and use the audit's existing
    'Excluded by user rule' label. Ranking currently exposes no label; its new
    label is a view of its final score, not a change to any production caller.
    series_note is the existing explanation view, supplied for every scored
    policy (audit currently documents it but does not actually return it).
    """
    sequences = {
        "ranking": ("base", "series_repeat", "veto", "trajectory", "diversity",
                    "cold_start", "user_rules"),
        "explanation": ("base", "series_repeat", "veto", "trajectory"),
        "evaluation": ("base", "series_repeat", "veto", "trajectory"),
        "audit": ("base", "series_repeat", "veto", "trajectory", "cold_start",
                  "user_rules"),
    }
    if policy not in sequences:
        raise ValueError(f"Unknown scoring policy: {policy!r}")
    if policy == "ranking" and matches_genre is None:
        raise ValueError("ranking requires matches_genre from _resolve_profile()")
    if policy in ("ranking", "audit") and cold_start is None:
        raise ValueError("ranking/audit require cold_start from cold_start_weight()")
    book = catalog[book_id]
    result = {
        "book_id": book_id, "title": book["title"], "author": book["author"],
        "policy": policy, "stage_sequence": sequences[policy],
        "scores": dict.fromkeys(("base", "after_series_repeat", "after_veto",
                                 "after_trajectory", "after_diversity",
                                 "after_cold_start", "final")),
        "poor_threshold": poor_threshold, "match_label": None,
        "factors": [], "contributions": [], "matches": [], "mismatches": [],
        "dealbreaker_flags": [], "exclusions": [],
        "excluded_by_user_rule": False, "series_note": "",
    }
    if policy == "ranking":
        if book_id in id_to_magnitude:
            result["exclusions"] = ["already_rated"]
        elif not matches_genre(book_id):
            result["exclusions"] = ["genre"]
        elif discovery_only and (
            book.get("series_id") in {
                s for bid in id_to_magnitude
                if (s := catalog[bid].get("series_id")) is not None
            } or book["author"] in {catalog[bid]["author"] for bid in id_to_magnitude}
        ):
            result["exclusions"] = ["discovery_only"]
        elif not series_position_ready(catalog, id_to_magnitude, book):
            result["exclusions"] = ["series_position"]
        if result["exclusions"]:
            return result

    scores = result["scores"]
    scores["base"], result["contributions"] = score_book(
        book, centroid, weights, field_prevalence, trope_prevalence
    )
    scores["after_series_repeat"] = _apply_series_repeat(
        catalog, id_to_magnitude, book, scores["base"]
    )
    scores["after_veto"] = _apply_dealbreaker_veto(
        catalog, id_to_magnitude, validated_fields, book, centroid, weights,
        scores["after_series_repeat"], field_prevalence, trope_prevalence
    )
    scores["after_trajectory"] = _apply_series_trajectory_penalty(
        series_dna, book, centroid, weights, scores["after_veto"],
        field_prevalence, trope_prevalence
    )
    relevance = scores["after_trajectory"]
    if policy == "ranking":
        diversity = max(0.0, min(diversity, MAX_DIVERSITY))
        if diversity > 0 and recent_books:
            novelty = 1 - max(book_similarity(book, h) for h in recent_books)
            relevance = (1 - diversity) * relevance + diversity * novelty
    scores["after_diversity"] = relevance
    if policy in ("ranking", "audit") and cold_start > 0:
        demand = GENRE_ACCESSIBILITY_DEMAND.get(book.get("genre_accessibility"), 0.5)
        relevance = (1 - cold_start) * relevance + cold_start * (1.0 - demand)
    scores["after_cold_start"] = relevance
    excluded_by_rule = False
    if policy in ("ranking", "audit"):
        relevance, excluded_by_rule = apply_user_rules(book, relevance, normalized_rules)
    scores["final"] = relevance
    result["excluded_by_user_rule"] = excluded_by_rule
    if excluded_by_rule:
        result["exclusions"] = ["user_rule"]
    result["match_label"] = (
        "Excluded by user rule" if excluded_by_rule else match_label(relevance, poor_threshold)
    )
    result["factors"] = list(_iter_book_factors(
        book, centroid, weights, field_prevalence, trope_prevalence
    ))
    result["matches"], result["mismatches"] = explain_book(
        book, centroid, weights, top_n=(100 if policy == "audit" else 5) if top_n is None else top_n,
        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence
    )
    result["dealbreaker_flags"] = dealbreaker_flags(
        book, centroid, weights, validated_fields=validated_fields,
        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence
    )
    if book.get("series_id"):
        series_entry = series_dna.get(book["series_id"])
        if series_entry:
            result["series_note"] = describe_series_trajectory(series_entry)
    return result

