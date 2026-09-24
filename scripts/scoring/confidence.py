"""Diagnostic recommendation-confidence instrumentation (2026-09-25).

Origin: the 2026-09-23 external AI review's R7
(docs/external-reviews/2026-09-23-gpt-review.md) -- every recommendation
is currently presented with the same apparent certainty (a bare match
score) regardless of how much real evidence backs it. The Magic Burns
case (docs/codx-reviews/2026-09-23-magic-burns-ranking.md) is the
concrete illustration this is meant to make visible going forward:
Osnat's profile at the time had only 2 negative ratings and zero
statistically validated fields, yet the app would show "Strong match:
0.885" with nothing distinguishing it from a recommendation resting on
a well-established profile.

Two genuinely different kinds of uncertainty, kept separate rather than
silently collapsed into one number a reader can't interpret:
  - rater_evidence_confidence: how much real, validated evidence backs
    THIS READER'S profile, independent of any specific candidate book.
  - candidate_metadata_confidence: how confidently tagged the specific
    fields/tropes that actually drove THIS candidate's score are.

DELIBERATELY NOT fed into score_candidate()/build_profile()/ranking in
any way -- this is display-only, computed as a post-processing step
over score_candidate()'s already-returned factors, per the review's own
explicit caution: "Do NOT immediately multiply confidence into the
recommendation score. First measure whether low-confidence
recommendations actually fail more often" -- there's no real-outcome
data yet to make that call (see docs/TODO.md's prospective-outcome-
tracking item, itself still pending a privacy design pass before it can
even start collecting that data). Building a re-ranking mechanism on
top of this now would be pure speculation. Wired into
explain_match_with_profile()'s output only (scoring/api.py) --
recommend()'s own ranking path never imports this module."""

from .calibration import get_confidence
from .cold_start import cold_start_weight
from .constants import MIN_DEALBREAKER_SAMPLE
from .profile import _series_deduped, _split_by_sign


def rater_evidence_confidence(catalog, id_to_magnitude):
    """0.0-1.0. Combines two already-existing signals rather than
    inventing a new one:
      - experience_component: 1 - cold_start_weight() -- the same
        independent-cluster-count + demonstrated-genre-readiness blend
        recommend() already uses to decide how much to lean on
        accessibility instead of profile match.
      - negative_evidence_component: independent negative (disliked or
        hated) rating clusters, series-deduped the same way
        _n_independent_clusters() dedupes for cold_start_weight(),
        faded to 1.0 at MIN_DEALBREAKER_SAMPLE (3) -- the same minimum-
        sample floor validated_dealbreaker_fields() itself requires
        before it will validate ANY field. Directly speaks to the
        Magic Burns finding (a profile with very few real dislikes),
        without depending on any single field actually clearing
        STAT_SEPARATION_THRESHOLD's much stricter 0.65 effect-size bar
        -- confirmed against real rater data (2026-09-25) that reusing
        validated_dealbreaker_fields() itself here would have made this
        component permanently 0.0: even Mathias's 143-rating, 21-
        negative-cluster profile validates zero fields at that
        threshold, since STAT_SEPARATION_THRESHOLD is deliberately
        conservative for actual veto-firing, not tuned as a continuous
        confidence signal. A raw sample-size floor is the right, much
        weaker claim this component is actually allowed to make: "there
        is enough negative evidence to mean something," not "a specific
        field has been statistically validated."
    Simple unweighted average of the two -- a first-pass choice, stated
    plainly rather than presented as derived; revisit once real-outcome
    data exists to check whether one component predicts failure better
    than the other (see module docstring)."""
    experience_component = 1.0 - cold_start_weight(catalog, id_to_magnitude)
    _, disliked = _split_by_sign(catalog, id_to_magnitude)
    disliked = _series_deduped(disliked)
    neg_clusters = len({
        b.get("series_id") or f"standalone:{b['id']}" for b, _ in disliked
    })
    negative_evidence_component = min(1.0, neg_clusters / MIN_DEALBREAKER_SAMPLE)
    return (experience_component + negative_evidence_component) / 2


def candidate_metadata_confidence(book, factors):
    """0.0-1.0. Weighted average of get_confidence(book, field_or_trope)
    over the specific fields/tropes that actually appeared in THIS
    candidate's score_candidate() factors -- not every field the book
    happens to have a value for, only the ones this rater's profile
    actually drew evidence from. Weighted by each factor's RAW weight
    (abs(w), not the confidence-discounted w_eff) -- weighting by w_eff
    would double-count confidence (a low-confidence factor already has
    a shrunk w_eff from scoring_confidence(), so weighting the average
    by w_eff too would bias the result toward LOOKING confident, exactly
    backwards). Uses get_confidence() (the raw, undiscounted accessor),
    not scoring_confidence() -- this reports real confidence for
    display, it doesn't floor it to 0 the way scoring math does.

    factors: score_candidate()'s own result["factors"] -- reused
    directly, never recomputed, since score_candidate() already builds
    this for every non-excluded candidate regardless of caller."""
    total_w = 0.0
    weighted_sum = 0.0
    for label, _sim, w, _w_eff, is_trope in factors:
        key = label[len("trope:"):] if is_trope else label
        weighted_sum += abs(w) * get_confidence(book, key)
        total_w += abs(w)
    return weighted_sum / total_w if total_w > 0 else 1.0


def evidence_confidence(catalog, id_to_magnitude, book, factors):
    """Combines both components into one diagnostic bundle -- never
    surfaced as a single opaque number alone, so a caller/UI can
    distinguish "we don't know much about this reader yet" from "we
    know the reader well but this specific book's tags are shaky,"
    which call for different framing to a user. `overall` is a plain
    unweighted average of the two, same first-pass-not-derived caveat
    as rater_evidence_confidence() above."""
    rater = rater_evidence_confidence(catalog, id_to_magnitude)
    candidate = candidate_metadata_confidence(book, factors)
    return {
        "overall": round((rater + candidate) / 2, 3),
        "rater_evidence": round(rater, 3),
        "candidate_metadata": round(candidate, 3),
    }
