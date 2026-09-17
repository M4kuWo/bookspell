"""Audit components of the recommendation engine."""


from .cold_start import (
    cold_start_weight,
)
from .constants import (
    AUDIT_BOOK_LIST_CAP,
    AUDIT_CONTRIBUTION_THRESHOLD,
    NOMINAL_FIELDS,
    ORDINAL_FIELDS,
)
from .encoding import (
    ordinal_position,
)
from .pipeline import (
    _redundancy_adjusted_weight,
    score_candidate,
    user_calibrated_poor_threshold,
    validated_dealbreaker_fields,
)
from .prevalence import (
    build_prevalence_lookup,
)
from .profile import (
    _resolve_profile,
    _series_deduped_id_to_magnitude,
)
from .rules import (
    normalize_user_rules,
)
from .series import (
    compute_series_dna,
    series_repeat_worst_similarity,
)


def _audit_attribute_nominal_or_trope(catalog, id_to_magnitude, id_to_title, field_key, relevant_value):
    """Which liked books SHARE relevant_value on this field/trope (support
    for it being the profile's preference), and which disliked books
    ALSO share it (undercutting -- see field_or_trope_separation()'s own
    math: a disliked book sharing the liked group's preferred value is
    exactly what LOWERS that field's separation/weight)."""
    is_trope = field_key.startswith("trope:")
    key = field_key[len("trope:"):] if is_trope else field_key

    def has_value(bid):
        if is_trope:
            return key in (catalog[bid].get("tropes") or [])
        return catalog[bid].get(key) == relevant_value

    liked = [id_to_title[bid] for bid, mag in id_to_magnitude.items() if mag > 0 and has_value(bid)]
    disliked = [id_to_title[bid] for bid, mag in id_to_magnitude.items() if mag < 0 and has_value(bid)]
    return {
        "liked_supporting": liked[:AUDIT_BOOK_LIST_CAP],
        "liked_supporting_overflow": max(0, len(liked) - AUDIT_BOOK_LIST_CAP),
        "disliked_undercutting": disliked[:AUDIT_BOOK_LIST_CAP],
        "disliked_undercutting_overflow": max(0, len(disliked) - AUDIT_BOOK_LIST_CAP),
    }


def _audit_attribute_ordinal(catalog, id_to_magnitude, field):
    """Summary form for an ordinal field -- see module note above for why
    this isn't a book list. Returns magnitude-weighted mean position and
    sample size for each side.

    `mag == 0` (a neutral "it_was_okay" rating) is excluded from BOTH
    sides -- the old `(mag > 0) != (sign > 0)` filter let a neutral
    rating pass through on the disliked side (mag > 0 is False there
    too), contributing a real position at weight abs(0) == 0. That made
    `positions` non-empty while `total_w` stayed exactly 0, raising
    ZeroDivisionError below whenever the disliked side's only evidence
    was neutral ratings, and inflated the reported `n` with entries that
    carried zero actual weight either way (found by CODX's 2026-09-14
    review). `total_w <= 0` is also guarded directly as a second layer,
    since this function is a display/audit tool, not a hot scoring path
    -- a defensive return here costs nothing."""
    def summarize(sign):
        positions = []
        for bid, mag in id_to_magnitude.items():
            if mag == 0 or (mag > 0) != (sign > 0):
                continue
            pos = ordinal_position(field, catalog[bid].get(field))
            if pos is not None:
                positions.append((pos[0] / pos[1], abs(mag)))
        if not positions:
            return None
        total_w = sum(w for _, w in positions)
        if total_w <= 0:
            return None
        mean = sum(p * w for p, w in positions) / total_w
        return {"n": len(positions), "mean_position": round(mean, 3)}
    return {"liked": summarize(1), "disliked": summarize(-1)}


def audit_book_score(catalog, ratings, title, genre=None, fatigue_overrides=None, user_rules=None, format_preference=None):
    """Full attribution trace for one candidate against one profile.
    Returns a dict (see print_score_audit() for a readable rendering):
    {
      "title", "author", "final_score", "match_label",
      "pipeline": [ {"stage", "score", "changed"}, ... ],
      "matches": [ {"field", "contribution", "weight", "similarity",
                     "redundancy_discounted", <attribution keys>}, ... ],
      "mismatches": [ same shape ],
      "dealbreaker_flags": [ (field, magnitude), ... ],
      "validated_fields": set(...),
      "series_note": str,
    }"""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    centroid, weights, id_to_magnitude, matches_genre = _resolve_profile(
        catalog, ratings, genre, fatigue_overrides, format_preference
    )
    id_to_title = {bid: catalog[bid]["title"] for bid in id_to_magnitude}
    validated_fields = validated_dealbreaker_fields(catalog, id_to_magnitude)
    csw = cold_start_weight(catalog, id_to_magnitude)
    # Deduped once here so the audit's own "why" display (training_data,
    # liked_supporting/disliked_undercutting) reflects the same evidence
    # validated_fields' separation numbers above were computed against
    # (validated_dealbreaker_fields() dedupes internally) -- 2026-09-05,
    # the third of the 10-hypothesis review's #2 finding's three
    # inconsistent consumers.
    deduped_id_to_magnitude = _series_deduped_id_to_magnitude(catalog, id_to_magnitude)
    series_dna = compute_series_dna(catalog)
    field_prevalence, trope_prevalence = build_prevalence_lookup(catalog, genre)
    book_id = title_to_id[title]
    book = catalog[book_id]

    poor_threshold = user_calibrated_poor_threshold(
        catalog, id_to_magnitude, centroid, weights,
        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence
    )
    result = score_candidate(
        catalog, book_id, centroid, weights, id_to_magnitude,
        policy="audit", validated_fields=validated_fields, series_dna=series_dna,
        field_prevalence=field_prevalence, trope_prevalence=trope_prevalence,
        poor_threshold=poor_threshold, cold_start=csw,
        normalized_rules=normalize_user_rules(user_rules), top_n=100
    )
    raw_score = result["scores"]["base"]
    after_series = result["scores"]["after_series_repeat"]
    after_veto = result["scores"]["after_veto"]
    after_trajectory = result["scores"]["after_trajectory"]
    after_cold_start = result["scores"]["after_cold_start"]
    final = result["scores"]["final"]
    excluded_by_rule = result["excluded_by_user_rule"]

    pipeline = [
        {"stage": "raw score_book()", "score": round(raw_score, 4), "changed": None},
        {"stage": "after _apply_series_repeat()", "score": round(after_series, 4),
         "changed": abs(after_series - raw_score) > 1e-9},
        {"stage": "after _apply_dealbreaker_veto()", "score": round(after_veto, 4),
         "changed": abs(after_veto - after_series) > 1e-9},
        {"stage": "after _apply_series_trajectory_penalty()", "score": round(after_trajectory, 4),
         "changed": abs(after_trajectory - after_veto) > 1e-9},
        {"stage": "after cold-start blend", "score": round(after_cold_start, 4),
         "changed": abs(after_cold_start - after_trajectory) > 1e-9, "cold_start_weight": round(csw, 3)},
        {"stage": "after user_rules", "score": round(final, 4),
         "changed": abs(final - after_cold_start) > 1e-9 or excluded_by_rule,
         "excluded": excluded_by_rule},
    ]

    matches, mismatches = result["matches"], result["mismatches"]

    def build_rows(rows, negate=False):
        out = []
        for field_key, contribution in rows:
            if abs(contribution) < AUDIT_CONTRIBUTION_THRESHOLD:
                continue
            if negate:
                # explain_book() stores mismatch magnitude as a positive
                # number (w*(1-sim), "how much this pulls down"), not a
                # signed delta -- negate here so "contribution" has
                # consistent sign semantics for any caller: positive
                # always means "pulled the score up," negative always
                # means "pulled it down," regardless of which list it
                # came from.
                contribution = -contribution
            plain_field = field_key[len("trope:"):] if field_key.startswith("trope:") else field_key
            row = {"field": field_key, "contribution": round(contribution, 3)}
            if not field_key.startswith("trope:") and plain_field in weights:
                raw_w = weights[plain_field]
                eff_w = _redundancy_adjusted_weight(book, plain_field, raw_w)
                if abs(eff_w - raw_w) > 1e-9:
                    row["weight_raw"] = round(raw_w, 3)
                    row["weight_after_redundancy_discount"] = round(eff_w, 3)
            if field_key.startswith("trope:") or plain_field in NOMINAL_FIELDS:
                # Always attribute against the CENTROID's own preferred
                # value (its mode), not the candidate book's value -- a
                # mismatch row means the book differs from that mode, but
                # "who supports/undercuts this field's weight" is always
                # about the mode itself, in both the match and mismatch
                # case. Unused for tropes (has_value() checks presence,
                # not a specific value).
                relevant_value = centroid.get(plain_field)
                row.update(_audit_attribute_nominal_or_trope(catalog, deduped_id_to_magnitude, id_to_title, field_key, relevant_value))
            elif plain_field in ORDINAL_FIELDS:
                row["training_data"] = _audit_attribute_ordinal(catalog, deduped_id_to_magnitude, plain_field)
            out.append(row)
        return out

    dealbreaker = result["dealbreaker_flags"]
    series_sim = series_repeat_worst_similarity(catalog, id_to_magnitude, book)

    return {
        "title": book["title"],
        "author": book["author"],
        "final_score": round(final, 4),
        "match_label": result["match_label"],
        "excluded_by_user_rule": excluded_by_rule,
        "pipeline": pipeline,
        "matches": build_rows(matches),
        "mismatches": build_rows(mismatches, negate=True),
        "dealbreaker_flags": [(f, round(m, 3)) for f, m in dealbreaker],
        "validated_fields": sorted(validated_fields),
        "series_repeat_worst_similarity": round(series_sim, 3) if series_sim is not None else None,
    }


def print_score_audit(audit, max_matches=None, max_mismatches=None):
    """max_matches/max_mismatches: cap how many rows print (the returned
    audit dict from audit_book_score() always has the FULL list --
    this only truncates DISPLAY, for running this across many books at
    once without an unmanageable wall of text). None = print everything
    above AUDIT_CONTRIBUTION_THRESHOLD, same as audit_book_score()'s
    default."""
    print(f"\n### {audit['title']} by {audit['author']} -- final score {audit['final_score']} ({audit['match_label']})")
    print("  Pipeline:")
    for stage in audit["pipeline"]:
        flag = "" if stage["changed"] is None else ("  <- CHANGED" if stage["changed"] else "  (no change)")
        extra = f" (cold_start_weight={stage['cold_start_weight']})" if "cold_start_weight" in stage else ""
        print(f"    {stage['stage']:<38} {stage['score']:.4f}{extra}{flag}")

    if audit["validated_fields"]:
        print(f"  Statistically validated dealbreaker fields for this profile: {', '.join(audit['validated_fields'])}")
    if audit["dealbreaker_flags"]:
        print(f"  Dealbreaker flags fired: {audit['dealbreaker_flags']}")
    if audit["series_repeat_worst_similarity"] is not None:
        print(f"  Series-repeat: worst similarity to a disliked series-mate = {audit['series_repeat_worst_similarity']}")

    def print_rows(rows, label, cap):
        if not rows:
            return
        shown = rows if cap is None else rows[:cap]
        overflow = 0 if cap is None else max(0, len(rows) - cap)
        print(f"  {label}{f' (top {cap} of {len(rows)})' if overflow else ''}:")
        for row in shown:
            w_note = ""
            if "weight_raw" in row:
                w_note = f" [redundancy discount: {row['weight_raw']} -> {row['weight_after_redundancy_discount']}]"
            print(f"    {row['field']:<35} contribution={row['contribution']:+.3f}{w_note}")
            if "liked_supporting" in row:
                ls, lo = row["liked_supporting"], row["liked_supporting_overflow"]
                du, do = row["disliked_undercutting"], row["disliked_undercutting_overflow"]
                if ls:
                    print(f"        liked books also sharing this: {ls}{f' (+{lo} more)' if lo else ''}")
                if du:
                    print(f"        disliked books ALSO sharing this (undercuts the signal): {du}{f' (+{do} more)' if do else ''}")
            if "training_data" in row:
                td = row["training_data"]
                if td["liked"]:
                    print(f"        liked training data: n={td['liked']['n']}, mean position={td['liked']['mean_position']}")
                if td["disliked"]:
                    print(f"        disliked training data: n={td['disliked']['n']}, mean position={td['disliked']['mean_position']}")

    print_rows(audit["matches"], "Matches (pulling score UP)", max_matches)
    print_rows(audit["mismatches"], "Mismatches (pulling score DOWN)", max_mismatches)

