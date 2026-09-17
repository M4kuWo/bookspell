"""Explanations components of the recommendation engine."""


from .constants import (
    FIELD_DISPLAY_NAMES,
    NARRATIVE_STYLE_FIELDS,
    NA_VALUES,
    VALUE_PHRASES,
)


def phrase_field(field, value):
    """None return means "don't show this" -- either no value, or an
    explicit na/none override above (e.g. scifi_hardness: na on a pure
    fantasy book isn't a meaningful phrase to surface)."""
    if value is None or value in NA_VALUES:
        return None
    field_overrides = VALUE_PHRASES.get(field, {})
    if value in field_overrides:
        return field_overrides[value]
    label = FIELD_DISPLAY_NAMES.get(field, field.replace("_", " "))
    return f"{value.replace('_', ' ')} {label}"


def phrase_trope(trope_id):
    return trope_id.replace("_", " ")


def describe(label, book):
    """label: a contribution key as produced by explain_book() -- either
    a bare field name or "trope:<id>". Returns a human-readable phrase,
    or None if this shouldn't be shown (see phrase_field)."""
    if label.startswith("trope:"):
        return phrase_trope(label[len("trope:"):])
    return phrase_field(label, book.get(label))


def _join_list(items):
    """Oxford-comma joined list: 'a', 'a and b', 'a, b, and c'."""
    items = list(items)
    if not items:
        return ""
    if len(items) == 1:
        return items[0]
    if len(items) == 2:
        return f"{items[0]} and {items[1]}"
    return ", ".join(items[:-1]) + f", and {items[-1]}"


def natural_sentence(labeled_phrases, positive):
    """labeled_phrases: list of (label, phrase) pairs, same labels
    explain_book() produces (paired with describe()'s phrase output) so
    NARRATIVE_STYLE_FIELDS can be pulled out for their own clause.
    Assembles one readable sentence instead of a flat phrase list.

    Deliberately NOT attempting per-trope grammar (article/pluralization
    -- "revenge" -> "a revenge arc", "prophecy" -> "prophecies") here --
    that's real, separate effort (120 individual trope overrides) with
    diminishing value before there's an actual UI to see it rendered in
    context. This only fixes the SENTENCE STRUCTURE (a verb clause + a
    properly joined list) around whatever phrase.py/describe() already
    produces."""
    style = [p for label, p in labeled_phrases if label in NARRATIVE_STYLE_FIELDS]
    content = [p for label, p in labeled_phrases if label not in NARRATIVE_STYLE_FIELDS]
    if not style and not content:
        return ""
    clauses = []
    if style:
        clauses.append(f"is told with {_join_list(style)}")
    if content:
        verb = "features" if positive else "also has"
        clauses.append(f"{verb} {_join_list(content)}")
    return "The book " + ", and ".join(clauses) + "."


def dealbreaker_sentence(labeled_phrases):
    """Phrasing for dealbreaker_flags()'s output -- deliberately NOT
    natural_sentence()'s "also has" framing, which reads as one item in
    a list of minor notes. This needs to read as a distinct, standalone
    callout ("Good match, but: ...") rather than get lost among ordinary
    mismatches -- that's the whole point of surfacing it separately.
    "Possible" (not "known") because DEALBREAKER_THRESHOLD is currently a
    fixed magnitude heuristic, not yet a per-user statistically validated
    pattern -- see that constant's docstring."""
    phrases = [p for _, p in labeled_phrases]
    if not phrases:
        return ""
    return f"Possible dealbreaker: {_join_list(phrases)}."

