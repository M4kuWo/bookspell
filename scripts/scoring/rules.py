"""Rules components of the recommendation engine."""


from .constants import (
    DEFAULT_REDUCE_STRENGTH,
    NOMINAL_FIELDS,
    ORDINAL_FIELDS,
)


def parse_user_rule_key(key):
    """key: a bare trope id (e.g. "slow_burn_romance") or "field:value"
    (e.g. "drive:romance_driven", "age_category:ya"). Returns
    ("trope", trope_id) or ("field_value", field, value); None if the
    field half doesn't name a real ORDINAL_FIELDS/NOMINAL_FIELDS field,
    or (for an ordinal field, which has a known value list in this file)
    the value half isn't one of its real values. Nominal fields don't
    have their value list mirrored in Python (it lives in the DB's own
    CHECK constraints) -- a bogus nominal value simply never matches any
    book rather than being rejected here, a harmless no-op rather than
    an error. Deliberately DB-free and pure, so this (and everything
    built on it) is testable without a live connection."""
    if ":" in key:
        field, _, value = key.partition(":")
        if field in ORDINAL_FIELDS:
            return ("field_value", field, value) if value in ORDINAL_FIELDS[field] else None
        if field in NOMINAL_FIELDS:
            return ("field_value", field, value)
        return None
    return ("trope", key)


def normalize_user_rules(raw_rules):
    """raw_rules: {"exclude": [key, ...], "reduce": [{"key": key,
    "strength": 0.0-1.0} or {"key": key} (defaults to
    DEFAULT_REDUCE_STRENGTH), ...]}. Either list may be omitted/empty;
    None or {} means no rules at all -- a full reset, guaranteed
    byte-identical to not having this feature.

    Returns the normalized internal shape apply_user_rules() checks
    per-candidate: {"exclude": [target, ...], "reduce": [(target,
    strength), ...]}, target = parse_user_rule_key()'s return shape.
    Unparseable keys are dropped with a warning printed, not raised --
    consistent with this project's existing ratings-loading convention
    (one bad entry shouldn't crash an entire recommend() call)."""
    raw_rules = raw_rules or {}
    exclude, reduce_, bad = [], [], []

    for key in raw_rules.get("exclude") or []:
        target = parse_user_rule_key(key)
        (exclude if target else bad).append(target or key)

    for entry in raw_rules.get("reduce") or []:
        key = entry["key"]
        strength = max(0.0, min(1.0, entry.get("strength", DEFAULT_REDUCE_STRENGTH)))
        target = parse_user_rule_key(key)
        if target:
            reduce_.append((target, strength))
        else:
            bad.append(key)

    if bad:
        print(f"WARNING: unrecognized user rule key(s), ignored: {bad}")

    return {"exclude": exclude, "reduce": reduce_}


def _matches_rule_target(book, target):
    kind, field_or_value, value = target if target[0] == "field_value" else (target[0], None, target[1])
    if kind == "trope":
        return value in (book.get("tropes") or [])
    return book.get(field_or_value) == value


def apply_user_rules(book, score, normalized_rules):
    """Returns (new_score, excluded). normalized_rules is
    normalize_user_rules()'s output -- pass None/{} (or skip the call
    entirely) for a guaranteed no-op. `exclude` checked first (an
    excluded book's score is irrelevant, it's being dropped from
    results entirely -- see recommend()'s candidate loop); each matching
    `reduce` rule applies its own multiplicative discount in turn if a
    book happens to match more than one."""
    if not normalized_rules:
        return score, False
    for target in normalized_rules.get("exclude", []):
        if _matches_rule_target(book, target):
            return score, True
    for target, strength in normalized_rules.get("reduce", []):
        if _matches_rule_target(book, target):
            score = score * (1 - strength)
    return score, False


def list_user_rule_targets(catalog):
    """Every nameable thing a user could target with a rule, for a
    frontend search/autocomplete box to search against -- this function
    is the backend's single source of truth for "what's a valid rule
    key," so a submitted rule can always be validated against it rather
    than trusting free text blindly.

    Returns a list of {"key", "kind", "label", ...}:
    - one row per trope actually used somewhere in the catalog (kind
      "trope", plus its `group_name` for a frontend to organize by)
    - one row per (ordinal or nominal field, value) pair actually
      present on at least one book in the catalog (kind "field_value",
      plus the `field` name) -- e.g. {"key": "drive:romance_driven",
      "kind": "field_value", "field": "drive", "label": "Romance-driven"}

    Only surfaces values that actually occur in the catalog (not every
    theoretically-valid enum value) so the search box never offers a
    dead-end target that would match zero books. Every produced key is
    validated through parse_user_rule_key() itself (rather than
    duplicating its rules here) before being included -- this is what
    correctly excludes a field's genuine "not applicable" sentinel
    (e.g. violence_intensity: na, romance_heat_intensity: na -- neither
    is in ORDINAL_FIELDS' own value list for that field) while still
    correctly INCLUDING "none" as a real, meaningful bottom-of-scale
    target for the fields where it genuinely is one (humor_level,
    violence_frequency, romance_heat_frequency all list "none" as a
    real scale position, not a stand-in for missing data) -- the same
    single source of truth guarantees list_user_rule_targets() can never
    offer something apply_user_rules() would silently no-op on. `label`
    is a simple title-cased rendering of the value/trope id (e.g.
    "slow_burn_romance" -> "Slow Burn Romance") -- a real UI would
    likely want a curated label map instead, this is a reasonable
    default, not a final presentation layer."""
    def humanize(s):
        return s.replace("_", " ").title()

    seen_tropes = {}
    seen_values = {}
    for book in catalog.values():
        for t in (book.get("tropes") or []):
            seen_tropes[t] = None
        for field in list(ORDINAL_FIELDS) + list(NOMINAL_FIELDS):
            val = book.get(field)
            if val is not None and parse_user_rule_key(f"{field}:{val}") is not None:
                seen_values[(field, val)] = None

    targets = [
        {"key": t, "kind": "trope", "label": humanize(t)}
        for t in sorted(seen_tropes)
    ]
    targets += [
        {"key": f"{field}:{val}", "kind": "field_value", "field": field, "label": humanize(val)}
        for field, val in sorted(seen_values)
    ]
    return targets

