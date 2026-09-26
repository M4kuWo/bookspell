"""Experimental components of the recommendation engine."""


from .calibration import (
    scoring_confidence,
)
from .constants import (
    NOMINAL_FIELDS,
    ORDINAL_FIELDS,
    STRUCTURAL_NOMINAL_FIELDS,
    STRUCTURAL_ORDINAL_FIELDS,
    TROPE_BACKOFF_K,
    TROPE_SHRINKAGE_K,
    WEIGHT_CAP,
)
from .encoding import (
    ordinal_position,
)
from .profile import (
    _series_deduped,
    _split_by_sign,
)


# --- Trope-weight sample-size shrinkage (2026-09-06, EXPERIMENTAL -- ---
# DEFERRED, not wired into build_profile()/score_book() -- mixed results
# across 4 raters as of 2026-09-06 (Mathias's sparse-hated-rejection
# regressed at every tested k from 1 through 12), not a rejected idea
# either. See docs/scoring-test-protocol.md's 2026-09-06 entry for the
# full A/B results this was tested against; re-test before any future
# decision, don't assume this snapshot still holds. --------------------
# Motivated by a friend's review of a Recommendation Ledger run: some
# trope weights are large despite resting on very few rated books --
# e.g. hidden_talent_prodigy: +0.267 from only 3 liked books (Ender's
# Shadow, Firestarter, Ender's Game) with ZERO disliked counter-evidence.
# build_profile()'s trope loop treats `liked_freq - disliked_freq` as
# equally trustworthy regardless of how many distinct books that
# estimate is actually built from -- 3 books and 30 books produce
# equally "confident" weights if the frequency gap happens to be the
# same. This variant multiplies each trope's raw weight by n/(n+k)
# before the WEIGHT_CAP clamp, where n = the number of DISTINCT
# liked+disliked books carrying the trope (unweighted book count --
# sample SIZE is what's thin here, not any one observation's rating
# magnitude) and k = TROPE_SHRINKAGE_K.
#
# Repaired 2026-09-26 (CODX Task 24 audit): signature/format-gating had
# drifted from build_profile()'s real current contract (format_preference
# landed 2026-09-07, after this function was written) -- calling this
# with production's real 4-positional-argument convention silently
# bound format_preference to k. k is now keyword-only specifically so
# that mistake can't recur silently; any future caller must pass it
# explicitly by name.
def build_profile_trope_shrinkage(catalog, ratings, full_ratings=None, format_preference=None, *, k=TROPE_SHRINKAGE_K):
    """Identical to build_profile() for ORDINAL/NOMINAL fields (including
    its format_preference gating, added here 2026-09-26 to match); tropes
    get an added n/(n+k) sample-size shrinkage factor on the raw weight
    before the WEIGHT_CAP clamp. See the module-level comment above."""
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
            weights[field] = 0.3

    for field in NOMINAL_FIELDS:
        pool_liked = full_liked if field in STRUCTURAL_NOMINAL_FIELDS else liked
        pool_disliked = full_disliked if field in STRUCTURAL_NOMINAL_FIELDS else disliked
        # Same guard as production build_profile()'s NOMINAL_FIELDS loop
        # (fixed there 2026-09-11): a confidence-zeroed tag survives the
        # `if b.get(field)` filter (it HAS a value) but its weight is 0,
        # so a list of only such entries stayed non-empty while
        # total_m/total_dm summed to 0 -- ZeroDivisionError below. These
        # experimental variants never got the same fix (found by CODX's
        # 2026-09-14 review); filtering zero-weight entries out here
        # brings them in line with production.
        liked_vals = [(b.get(field), m * scoring_confidence(b, field)) for b, m in pool_liked if b.get(field)]
        liked_vals = [(v, m) for v, m in liked_vals if m > 0]
        if not liked_vals:
            continue
        counts = {}
        total_m = 0.0
        for v, m in liked_vals:
            counts[v] = counts.get(v, 0.0) + m
            total_m += m
        mode_val = max(counts, key=counts.get)
        liked_share = counts[mode_val] / total_m
        disliked_vals = [(b.get(field), m * scoring_confidence(b, field)) for b, m in pool_disliked if b.get(field)]
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

    trope_weights = {}
    liked_trope_pairs = liked
    disliked_trope_pairs = disliked
    total_liked_m = sum(m for _, m in liked_trope_pairs) or 1.0
    total_disliked_m = sum(m for _, m in disliked_trope_pairs)
    all_tropes = set(t for b, _ in liked_trope_pairs + disliked_trope_pairs for t in (b.get("tropes") or []))
    for t in all_tropes:
        n = (
            sum(1 for b, _ in liked_trope_pairs if t in (b.get("tropes") or []))
            + sum(1 for b, _ in disliked_trope_pairs if t in (b.get("tropes") or []))
        )
        liked_freq = sum(
            m * scoring_confidence(b, t) for b, m in liked_trope_pairs if t in (b.get("tropes") or [])
        ) / total_liked_m
        disliked_freq = (
            sum(m * scoring_confidence(b, t) for b, m in disliked_trope_pairs if t in (b.get("tropes") or []))
            / total_disliked_m
            if total_disliked_m else 0.0
        )
        raw = (liked_freq - disliked_freq) * (n / (n + k))
        trope_weights[t] = max(-WEIGHT_CAP, min(WEIGHT_CAP, raw))
    weights["tropes"] = trope_weights

    return centroid, weights


# Repaired 2026-09-26 (CODX Task 24 audit): same signature/format-gating
# drift and fix as build_profile_trope_shrinkage() above -- k made
# keyword-only so a future 4-positional-argument call can't silently
# bind format_preference to it. Still an unresolved research question,
# not a validated replacement -- no landed resolution found for the
# cross-genre-pooling sign-flip/independence concerns raised when this
# was prototyped (docs/scoring-test-protocol.md's 2026-09-06 entry).
def build_profile_trope_backoff(catalog, ratings, full_ratings=None, format_preference=None, *, k=TROPE_BACKOFF_K):
    """EXPERIMENTAL, NOT wired into production -- prototype for the
    repo owner's own middle-ground proposal (2026-09-06) between
    build_profile()'s current "tropes always genre-scoped" behavior and
    a blanket "tropes always cross-genre" change. Identical to
    build_profile() for ORDINAL/NOMINAL fields, including its
    format_preference gating (added here 2026-09-26 to match). For
    tropes, computes TWO estimates per trope -- `raw_scoped` (genre-
    scoped liked/disliked pool, same as build_profile()) and `raw_full`
    (the FULL cross-genre pool, same `full_ratings` already threaded
    through for STRUCTURAL fields) -- and blends them: `n/(n+k)` weight
    on the scoped estimate, `k/(n+k)` on the full one, where n = the
    number of distinct liked+disliked GENRE-SCOPED books carrying the
    trope. As n grows, this converges to build_profile()'s current
    scoped-only behavior; as n shrinks toward 0, it backs off toward the
    cross-genre estimate instead of toward zero (contrast with
    build_profile_trope_shrinkage() above, which shrinks toward zero
    regardless of what the broader pool says).

    Motivated directly by the friend-feedback audit's Step 4 finding:
    `revenge`'s fantasy-scoped disliked evidence collapses to ONE series
    (Poppy War/Dragon Republic) once Red Rising (tagged sci_fi) drops
    out of the fantasy-scoped calculation -- this lets Red Rising count
    again, proportional to how much fantasy-specific evidence already
    exists, rather than either ignoring it (current behavior) or
    trusting it exactly as much as fantasy-specific evidence (a blanket
    cross-genre merge, which risks blending a genuinely genre-
    conditional preference into one misleading average -- see
    docs/scoring-test-protocol.md's 2026-09-06 entry for the full
    pros/cons discussion this was weighed against before prototyping)."""
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
            weights[field] = 0.3

    for field in NOMINAL_FIELDS:
        pool_liked = full_liked if field in STRUCTURAL_NOMINAL_FIELDS else liked
        pool_disliked = full_disliked if field in STRUCTURAL_NOMINAL_FIELDS else disliked
        # Same guard as production build_profile()'s NOMINAL_FIELDS loop
        # (fixed there 2026-09-11): a confidence-zeroed tag survives the
        # `if b.get(field)` filter (it HAS a value) but its weight is 0,
        # so a list of only such entries stayed non-empty while
        # total_m/total_dm summed to 0 -- ZeroDivisionError below. These
        # experimental variants never got the same fix (found by CODX's
        # 2026-09-14 review); filtering zero-weight entries out here
        # brings them in line with production.
        liked_vals = [(b.get(field), m * scoring_confidence(b, field)) for b, m in pool_liked if b.get(field)]
        liked_vals = [(v, m) for v, m in liked_vals if m > 0]
        if not liked_vals:
            continue
        counts = {}
        total_m = 0.0
        for v, m in liked_vals:
            counts[v] = counts.get(v, 0.0) + m
            total_m += m
        mode_val = max(counts, key=counts.get)
        liked_share = counts[mode_val] / total_m
        disliked_vals = [(b.get(field), m * scoring_confidence(b, field)) for b, m in pool_disliked if b.get(field)]
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

    def trope_freqs(liked_pairs, disliked_pairs):
        total_liked_m = sum(m for _, m in liked_pairs) or 1.0
        total_disliked_m = sum(m for _, m in disliked_pairs)
        all_tropes = set(t for b, _ in liked_pairs + disliked_pairs for t in (b.get("tropes") or []))
        freqs = {}
        for t in all_tropes:
            n = (
                sum(1 for b, _ in liked_pairs if t in (b.get("tropes") or []))
                + sum(1 for b, _ in disliked_pairs if t in (b.get("tropes") or []))
            )
            liked_freq = sum(
                m * scoring_confidence(b, t) for b, m in liked_pairs if t in (b.get("tropes") or [])
            ) / total_liked_m
            disliked_freq = (
                sum(m * scoring_confidence(b, t) for b, m in disliked_pairs if t in (b.get("tropes") or []))
                / total_disliked_m
                if total_disliked_m else 0.0
            )
            freqs[t] = (liked_freq - disliked_freq, n)
        return freqs

    scoped_freqs = trope_freqs(liked, disliked)
    full_freqs = trope_freqs(full_liked, full_disliked)

    trope_weights = {}
    for t in set(scoped_freqs) | set(full_freqs):
        raw_scoped, n_scoped = scoped_freqs.get(t, (0.0, 0))
        raw_full, _ = full_freqs.get(t, (0.0, 0))
        blend_w = n_scoped / (n_scoped + k)
        blended = raw_scoped * blend_w + raw_full * (1 - blend_w)
        trope_weights[t] = max(-WEIGHT_CAP, min(WEIGHT_CAP, blended))
    weights["tropes"] = trope_weights

    return centroid, weights
