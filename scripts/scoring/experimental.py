"""Experimental components of the recommendation engine."""


from .calibration import (
    get_confidence,
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
from .pipeline import (
    _redundancy_adjusted_weight,
    validated_dealbreaker_fields,
)
from .profile import (
    _series_deduped,
    _split_by_sign,
)


# --- Trope-weight sample-size shrinkage (2026-09-06, EXPERIMENTAL -- ---
# UNDER TEST, NOT wired into build_profile()/score_book() yet) ----------
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
# magnitude) and k = TROPE_SHRINKAGE_K. See docs/scoring-test-
# protocol.md's 2026-09-06 entry for the A/B results this was tested
# against before any decision to land -- kept side-by-side with
# build_profile() rather than reassigned, same pattern as
# build_profile_per_value() below (tried, evaluated, not swapped into
# production without passing the full test suite first).
def build_profile_trope_shrinkage(catalog, ratings, full_ratings=None, k=TROPE_SHRINKAGE_K):
    """Identical to build_profile() for ORDINAL/NOMINAL fields; tropes
    get an added n/(n+k) sample-size shrinkage factor on the raw weight
    before the WEIGHT_CAP clamp. See the module-level comment above."""
    full_ratings = ratings if full_ratings is None else full_ratings

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


def build_profile_trope_backoff(catalog, ratings, full_ratings=None, k=TROPE_BACKOFF_K):
    """EXPERIMENTAL, NOT wired into production -- prototype for the
    repo owner's own middle-ground proposal (2026-09-06) between
    build_profile()'s current "tropes always genre-scoped" behavior and
    a blanket "tropes always cross-genre" change. Identical to
    build_profile() for ORDINAL/NOMINAL fields. For tropes, computes
    TWO estimates per trope -- `raw_scoped` (genre-scoped liked/disliked
    pool, same as build_profile()) and `raw_full` (the FULL cross-genre
    pool, same `full_ratings` already threaded through for STRUCTURAL
    fields) -- and blends them: `n/(n+k)` weight on the scoped estimate,
    `k/(n+k)` on the full one, where n = the number of distinct
    liked+disliked GENRE-SCOPED books carrying the trope. As n grows,
    this converges to build_profile()'s current scoped-only behavior;
    as n shrinks toward 0, it backs off toward the cross-genre estimate
    instead of toward zero (contrast with build_profile_trope_shrinkage()
    above, which shrinks toward zero regardless of what the broader
    pool says).

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


def _dedup_factor_for_field(pool, field):
    """{book_id: divisor} for series-cluster-AND-VALUE-conditional
    dedup on one specific field -- unlike _series_deduped() (which
    treats every series-mate as equally redundant on EVERY field
    uniformly), a book's magnitude for THIS field is only divided by
    how many OTHER pool members share both its series AND its exact
    value for this field. A series-mate showing a genuinely different
    value for this field is real, distinct evidence for it, not a
    repeat -- even if that same book is still fully redundant for some
    OTHER field that stays constant across the series (see
    build_profile_series_field_dedup()'s module comment for the full
    motivation). Standalones (or a lone rated series-mate) always
    divide by 1, same as _series_deduped()."""
    counts = {}
    for b, _ in pool:
        series_key = b.get("series_id") or f"standalone:{b['id']}"
        key = (series_key, b.get(field))
        counts[key] = counts.get(key, 0) + 1
    return {
        b["id"]: counts[(b.get("series_id") or f"standalone:{b['id']}", b.get(field))]
        for b, _ in pool
    }


# --- Field-conditional series dedup (2026-09-06, EXPERIMENTAL -- UNDER --
# TEST, NOT wired into build_profile() yet) -----------------------------
# Logged as a real, scoped follow-up back on 2026-09-04 (see
# docs/scoring-test-protocol.md's "Series DNA / dedup integration"
# entry) and explicitly flagged there as bigger/riskier than a quick
# fix, deserving its own dedicated pass -- this is that pass.
#
# _series_deduped() (used by build_profile() today) treats every
# series-mate as equally redundant on EVERY field: if you rated 6
# Mistborn Era One books, each one's magnitude gets divided by 6 for
# ALL fields uniformly, including ones that genuinely change across the
# series (darkness escalating book to book, say) just as much as ones
# that stay constant (POV, most likely). That's real information loss --
# a field that drifts across a series isn't actually redundant evidence
# the way a stable one is, and it shouldn't be diluted to 1/6th strength
# just because 5 OTHER books in the same series happen to have a
# DIFFERENT value on that specific field.
#
# This variant moves deduplication from "book" granularity to "book,
# field" granularity: for each field, group a series' rated books by
# their ACTUAL VALUE on that field (not just their series_id), and
# divide a book's magnitude only by the size of its OWN value-group.
# If all N series-mates share the same value for field F, this is
# identical to _series_deduped() (divide by N). If the series' rated
# books split into groups with genuinely different values, each group
# is treated as its own independent cluster of evidence -- neither
# group cancels or dilutes the other, and neither is inflated to look
# like N independent observations either.
#
# Deliberately scoped to ORDINAL_FIELDS/NOMINAL_FIELDS only, NOT
# tropes -- tropes' weight formula shares ONE total_liked_m/
# total_disliked_m normalizer across every trope (see build_profile()'s
# own comment on why that stays undiscounted), and switching to a
# per-trope-conditional divisor would require redesigning what that
# shared normalizer even means, a separate, not-yet-designed question.
# Tropes keep today's plain book-level _series_deduped() dedup here,
# unchanged.
def build_profile_series_field_dedup(catalog, ratings, full_ratings=None):
    """Identical to build_profile() for tropes (plain book-level
    _series_deduped() dedup, unchanged) and identical in every OTHER
    respect except: ORDINAL_FIELDS/NOMINAL_FIELDS use
    _dedup_factor_for_field() (per-field-and-value-conditional) instead
    of the single upfront _series_deduped() pool. See the module
    comment above for the full motivation."""
    full_ratings = ratings if full_ratings is None else full_ratings

    liked_raw, disliked_raw = _split_by_sign(catalog, ratings)
    full_liked_raw, full_disliked_raw = _split_by_sign(catalog, full_ratings)
    # Tropes still use the plain, book-level dedup -- computed once here,
    # same as build_profile().
    liked = _series_deduped(liked_raw)
    disliked = _series_deduped(disliked_raw)

    centroid = {}
    weights = {}

    def weighted_mean(pairs, positions):
        total_w = sum(w for _, w in positions)
        if total_w == 0:
            return None
        return sum(v * w for v, w in positions) / total_w

    for field in ORDINAL_FIELDS:
        pool_liked = full_liked_raw if field in STRUCTURAL_ORDINAL_FIELDS else liked_raw
        pool_disliked = full_disliked_raw if field in STRUCTURAL_ORDINAL_FIELDS else disliked_raw
        liked_div = _dedup_factor_for_field(pool_liked, field)
        disliked_div = _dedup_factor_for_field(pool_disliked, field)
        liked_positions = [
            (pos[0] / pos[1], (m / liked_div[b["id"]]) * scoring_confidence(b, field)) for b, m in pool_liked
            if (pos := ordinal_position(field, b.get(field))) is not None
        ]
        liked_mean = weighted_mean(pool_liked, liked_positions)
        if liked_mean is None:
            continue
        centroid[field] = liked_mean
        disliked_positions = [
            (pos[0] / pos[1], (m / disliked_div[b["id"]]) * scoring_confidence(b, field)) for b, m in pool_disliked
            if (pos := ordinal_position(field, b.get(field))) is not None
        ]
        disliked_mean = weighted_mean(pool_disliked, disliked_positions)
        if disliked_mean is not None:
            weights[field] = min(WEIGHT_CAP, abs(liked_mean - disliked_mean))
        else:
            weights[field] = 0.3

    for field in NOMINAL_FIELDS:
        pool_liked = full_liked_raw if field in STRUCTURAL_NOMINAL_FIELDS else liked_raw
        pool_disliked = full_disliked_raw if field in STRUCTURAL_NOMINAL_FIELDS else disliked_raw
        liked_div = _dedup_factor_for_field(pool_liked, field)
        disliked_div = _dedup_factor_for_field(pool_disliked, field)
        # Same zero-weight guard as the other build_profile* variants
        # above (production build_profile() fixed 2026-09-11; these
        # series-dedup experimental variants never got it -- found by
        # CODX's 2026-09-14 review).
        liked_vals = [
            (b.get(field), (m / liked_div[b["id"]]) * scoring_confidence(b, field))
            for b, m in pool_liked if b.get(field)
        ]
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
        disliked_vals = [
            (b.get(field), (m / disliked_div[b["id"]]) * scoring_confidence(b, field))
            for b, m in pool_disliked if b.get(field)
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


def _dedup_factor_plain(pool):
    """{book_id: divisor} for _series_deduped()'s own plain, book-level
    grouping (series only, ignoring field value) -- the fallback
    build_profile_series_field_dedup_protected() uses for a user's
    VALIDATED dealbreaker fields, see that function's module comment."""
    counts = {}
    for b, _ in pool:
        key = b.get("series_id") or f"standalone:{b['id']}"
        counts[key] = counts.get(key, 0) + 1
    return {
        b["id"]: counts[b.get("series_id") or f"standalone:{b['id']}"]
        for b, _ in pool
    }


# --- Field-conditional series dedup, validated-dealbreaker-protected ---
# (2026-09-07, EXPERIMENTAL -- UNDER TEST, NOT wired into build_profile()
# yet) -----------------------------------------------------------------
# build_profile_series_field_dedup() (above) was tested and found a
# real regression (see docs/scoring-test-protocol.md's 2026-09-06 entry):
# de-diluting a series where a field genuinely splits (Red Sister vs.
# its third_limited sequels) gave a real counterexample its full weight,
# but the net effect softened `person`'s liked-vs-disliked separation
# enough to stop correctly flagging Royal Assassin/Interview with the
# Vampire as poor matches -- a real precision/recall trade-off, not a
# bug. This variant tests the concrete fix proposed there: protect a
# user's own VALIDATED dealbreaker fields (validated_dealbreaker_fields()
# -- real, per-user statistical evidence, not a guess) from the
# de-dilution effect entirely, keeping them on the plain book-level
# dedup exactly like build_profile() does today, while still applying
# the field-conditional treatment to every OTHER ordinal/nominal field.
# The idea: a field that's already proven itself a genuine dealbreaker
# for this user is exactly the field where a diluted-but-consistent
# signal is worth MORE than a fully-weighted rare exception -- other,
# non-validated fields have less to lose from the more granular
# treatment.
def build_profile_series_field_dedup_protected(catalog, ratings, full_ratings=None):
    """Identical to build_profile_series_field_dedup(), except any field
    in validated_dealbreaker_fields(catalog, full_ratings) uses the
    plain, book-level _series_deduped() divisor (via
    _dedup_factor_plain()) instead of the field-conditional one --
    see the module comment above."""
    full_ratings = ratings if full_ratings is None else full_ratings

    liked_raw, disliked_raw = _split_by_sign(catalog, ratings)
    full_liked_raw, full_disliked_raw = _split_by_sign(catalog, full_ratings)
    liked = _series_deduped(liked_raw)
    disliked = _series_deduped(disliked_raw)
    validated_fields = validated_dealbreaker_fields(catalog, full_ratings)

    centroid = {}
    weights = {}

    def weighted_mean(pairs, positions):
        total_w = sum(w for _, w in positions)
        if total_w == 0:
            return None
        return sum(v * w for v, w in positions) / total_w

    for field in ORDINAL_FIELDS:
        pool_liked = full_liked_raw if field in STRUCTURAL_ORDINAL_FIELDS else liked_raw
        pool_disliked = full_disliked_raw if field in STRUCTURAL_ORDINAL_FIELDS else disliked_raw
        if field in validated_fields:
            liked_div = _dedup_factor_plain(pool_liked)
            disliked_div = _dedup_factor_plain(pool_disliked)
        else:
            liked_div = _dedup_factor_for_field(pool_liked, field)
            disliked_div = _dedup_factor_for_field(pool_disliked, field)
        liked_positions = [
            (pos[0] / pos[1], (m / liked_div[b["id"]]) * scoring_confidence(b, field)) for b, m in pool_liked
            if (pos := ordinal_position(field, b.get(field))) is not None
        ]
        liked_mean = weighted_mean(pool_liked, liked_positions)
        if liked_mean is None:
            continue
        centroid[field] = liked_mean
        disliked_positions = [
            (pos[0] / pos[1], (m / disliked_div[b["id"]]) * scoring_confidence(b, field)) for b, m in pool_disliked
            if (pos := ordinal_position(field, b.get(field))) is not None
        ]
        disliked_mean = weighted_mean(pool_disliked, disliked_positions)
        if disliked_mean is not None:
            weights[field] = min(WEIGHT_CAP, abs(liked_mean - disliked_mean))
        else:
            weights[field] = 0.3

    for field in NOMINAL_FIELDS:
        pool_liked = full_liked_raw if field in STRUCTURAL_NOMINAL_FIELDS else liked_raw
        pool_disliked = full_disliked_raw if field in STRUCTURAL_NOMINAL_FIELDS else disliked_raw
        if field in validated_fields:
            liked_div = _dedup_factor_plain(pool_liked)
            disliked_div = _dedup_factor_plain(pool_disliked)
        else:
            liked_div = _dedup_factor_for_field(pool_liked, field)
            disliked_div = _dedup_factor_for_field(pool_disliked, field)
        # Same zero-weight guard as the other build_profile* variants
        # above (production build_profile() fixed 2026-09-11; these
        # series-dedup experimental variants never got it -- found by
        # CODX's 2026-09-14 review).
        liked_vals = [
            (b.get(field), (m / liked_div[b["id"]]) * scoring_confidence(b, field))
            for b, m in pool_liked if b.get(field)
        ]
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
        disliked_vals = [
            (b.get(field), (m / disliked_div[b["id"]]) * scoring_confidence(b, field))
            for b, m in pool_disliked if b.get(field)
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


# --- Per-value nominal weight learning (2026-09-04, EXPERIMENTAL -- ----
# UNDER TEST, NOT wired into build_profile()/score_book() yet) ----------
# Repo owner's own pushback on why `drive: romance_driven`'s weight
# being 0.0 didn't mean what it looked like it meant: build_profile()'s
# normal NOMINAL_FIELDS loop computes exactly ONE weight per field, tied
# entirely to whichever value is most common among liked books (the
# "mode") -- `liked_share(mode) - disliked_share(mode)`. It has no way
# to learn a separate relationship for any OTHER value independent of
# the mode's own separation -- `romance_driven` could be a real,
# validated-strength negative signal and this formula would never see
# it unless the MODE value's own separation also happened to shift.
#
# This variant treats every nominal field's VALUES like tropes: each
# value gets its own `liked_freq(value) - disliked_freq(value)` weight
# (same formula, same WEIGHT_CAP), and scoring becomes a direct lookup
# of the candidate's own value's weight -- no similarity-to-centroid
# math, no partial-credit maps (NOMINAL_PARTIAL_SIMILARITY's hand-picked
# exceptions become moot: if the user's real ratings show they like
# BOTH third_limited and third_omniscient, each gets its own real
# positive weight from genuine evidence, rather than borrowing partial
# credit from a hardcoded pair list).
def build_profile_per_value(catalog, ratings, full_ratings=None):
    """Per-value nominal weight learning -- LANDED 2026-09-04 (this is
    now the real `build_profile`, reassigned at the bottom of this file;
    see that reassignment's own comment for the full landing writeup).
    Identical to the original mode-based approach for ORDINAL fields and
    tropes; NOMINAL fields get `weights[field] = {value: weight, ...}`
    (a dict, like weights["tropes"]) instead of a single scalar tied to
    one mode value. `centroid[field]` is still set to the mode purely
    for display/explain-text compatibility and the series-trajectory
    penalty's own similarity-to-mode need -- normal scoring never reads
    it for nominal fields anymore."""
    full_ratings = ratings if full_ratings is None else full_ratings
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
        pool_liked = full_liked if field in STRUCTURAL_ORDINAL_FIELDS else liked
        pool_disliked = full_disliked if field in STRUCTURAL_ORDINAL_FIELDS else disliked
        liked_positions = [
            (pos[0] / pos[1], m) for b, m in pool_liked
            if (pos := ordinal_position(field, b.get(field))) is not None
        ]
        liked_mean = weighted_mean(pool_liked, liked_positions)
        if liked_mean is None:
            continue
        centroid[field] = liked_mean
        disliked_positions = [
            (pos[0] / pos[1], m) for b, m in pool_disliked
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
        liked_vals = [(b.get(field), m) for b, m in pool_liked if b.get(field)]
        disliked_vals = [(b.get(field), m) for b, m in pool_disliked if b.get(field)]
        if not liked_vals and not disliked_vals:
            continue
        total_liked_m = sum(m for _, m in liked_vals) or 1.0
        total_disliked_m = sum(m for _, m in disliked_vals)
        all_values = set(v for v, _ in liked_vals) | set(v for v, _ in disliked_vals)
        per_value = {}
        for v in all_values:
            liked_freq = sum(m for val, m in liked_vals if val == v) / total_liked_m
            disliked_freq = (
                sum(m for val, m in disliked_vals if val == v) / total_disliked_m
                if total_disliked_m else 0.0
            )
            raw = liked_freq - disliked_freq
            per_value[v] = max(-WEIGHT_CAP, min(WEIGHT_CAP, raw))
        weights[field] = per_value
        if liked_vals:
            counts = {}
            for v, m in liked_vals:
                counts[v] = counts.get(v, 0.0) + m
            centroid[field] = max(counts, key=counts.get)

    trope_weights = {}
    liked_trope_pairs = [(b.get("tropes") or [], m) for b, m in liked]
    disliked_trope_pairs = [(b.get("tropes") or [], m) for b, m in disliked]
    total_liked_m = sum(m for _, m in liked_trope_pairs) or 1.0
    total_disliked_m = sum(m for _, m in disliked_trope_pairs)
    all_tropes = set(t for lst, _ in liked_trope_pairs + disliked_trope_pairs for t in lst)
    for t in all_tropes:
        liked_freq = sum(m for lst, m in liked_trope_pairs if t in lst) / total_liked_m
        disliked_freq = (
            sum(m for lst, m in disliked_trope_pairs if t in lst) / total_disliked_m
            if total_disliked_m else 0.0
        )
        raw = liked_freq - disliked_freq
        trope_weights[t] = max(-WEIGHT_CAP, min(WEIGHT_CAP, raw))
    weights["tropes"] = trope_weights

    return centroid, weights


def score_book_per_value(book, centroid, weights):
    """Per-value nominal weight learning -- LANDED 2026-09-04 (this is
    now the real `score_book`; see the reassignment near the bottom of
    this file). Identical to the original approach for ORDINAL fields
    and tropes; NOMINAL fields look up `weights[field][book_value]`
    directly (0.0 if that specific value was never observed in training
    data -- no evidence, no signal, rather than falling back to a
    similarity-to-mode calculation)."""
    score = 0.0
    total_weight = 0.0
    contributions = []

    for field, w in weights.items():
        if field == "tropes":
            continue
        if field not in centroid and field not in weights:
            continue
        if field in ORDINAL_FIELDS:
            if field not in centroid:
                continue
            pos = ordinal_position(field, book.get(field))
            if pos is None:
                continue
            book_val = pos[0] / pos[1]
            sim = 1 - abs(book_val - centroid[field])
            w_eff = _redundancy_adjusted_weight(book, field, w) * get_confidence(book, field)
            contribution = w_eff * sim
        else:
            book_val = book.get(field)
            if book_val is None or not isinstance(w, dict):
                continue
            raw_w = w.get(book_val, 0.0)
            # _redundancy_adjusted_weight() expects a scalar -- pass the
            # already-looked-up per-VALUE weight, not the whole dict, so
            # e.g. narrative_closure's REDUNDANCY_DISCOUNTS entry still
            # applies under per-value scoring (a real gap found and
            # fixed while landing this, see docs/scoring-test-protocol.md).
            w_eff = _redundancy_adjusted_weight(book, field, raw_w) * get_confidence(book, field)
            contribution = w_eff
        score += contribution
        total_weight += abs(w_eff)
        if abs(contribution) > 0.15:
            contributions.append((field, round(contribution, 3)))

    trope_weights = weights.get("tropes", {})
    book_tropes = set(book.get("tropes") or [])
    for t, w in trope_weights.items():
        if t in book_tropes:
            w_eff = w * get_confidence(book, t)
            score += w_eff
            total_weight += abs(w_eff)
            if abs(w) > 0.15:
                contributions.append((f"trope:{t}", round(w_eff, 3)))

    normalized = score / total_weight if total_weight > 0 else 0.0
    contributions.sort(key=lambda x: -abs(x[1]))
    return normalized, contributions[:5]


def explain_book_per_value(book, centroid, weights, top_n=5):
    """Per-value nominal weight learning -- LANDED 2026-09-04 (this is
    now the real `explain_book`; see the reassignment near the bottom of
    this file). NOMINAL fields: match/mismatch bucket is decided by the
    SIGN of the candidate's own per-value weight (same pattern the trope
    loop below already uses), not by similarity-to-centroid."""
    matches, mismatches = [], []

    for field, w in weights.items():
        if field == "tropes":
            continue
        if field in ORDINAL_FIELDS:
            if field not in centroid:
                continue
            pos = ordinal_position(field, book.get(field))
            if pos is None:
                continue
            sim = 1 - abs(pos[0] / pos[1] - centroid[field])
            w = _redundancy_adjusted_weight(book, field, w) * get_confidence(book, field)
            if w >= 0:
                matches.append((field, w * sim))
                mismatches.append((field, w * (1 - sim)))
            else:
                matches.append((field, abs(w) * (1 - sim)))
                mismatches.append((field, abs(w) * sim))
        else:
            if not isinstance(w, dict):
                continue
            book_val = book.get(field)
            if book_val is None:
                continue
            raw_w = w.get(book_val, 0.0)
            w_eff = _redundancy_adjusted_weight(book, field, raw_w) * get_confidence(book, field)
            (matches if w_eff >= 0 else mismatches).append((field, abs(w_eff)))

    trope_weights = weights.get("tropes", {})
    book_tropes = set(book.get("tropes") or [])
    for t, w in trope_weights.items():
        if t not in book_tropes:
            continue
        w = w * get_confidence(book, t)
        (matches if w >= 0 else mismatches).append((f"trope:{t}", abs(w)))

    matches = sorted((m for m in matches if m[1] > 0.1), key=lambda x: -x[1])
    mismatches = sorted((m for m in mismatches if m[1] > 0.1), key=lambda x: -x[1])
    return matches[:top_n], mismatches[:top_n]

