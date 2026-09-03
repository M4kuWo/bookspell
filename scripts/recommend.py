"""
Bookspell recommendation engine — v1 prototype.

Design (matches the original artifact's decision: per-user weighted
vector, no collaborative filtering for v1):

1. Every book's Book DNA is encoded into a flat feature space: ordinal
   scalar fields (position on their ordered value list), nominal scalar
   fields (one value, exact-match only), and tropes (a multi-select set).
   Content warnings are deliberately EXCLUDED from the similarity score
   -- per book-dna.md, they're neutral descriptive data, not a taste
   signal to match toward. They belong in personalized hard filters
   (step 07 onboarding: "never show me X"), not in the score itself.

2. A user's profile is built from books they've rated on a 5-tier
   labeled scale (hated/disliked/it_was_okay/liked/loved -- see
   RATING_LABELS), not a binary liked/disliked, and not a fixed formula:
   for each feature, compare the RATING-MAGNITUDE-WEIGHTED average value
   among positively-rated books to the magnitude-weighted average among
   negatively-rated books, so a "loved" book pulls the centroid harder
   than a "liked" one, and "it_was_okay" (magnitude 0) contributes to
   neither side -- it's excluded from profile-building entirely, present
   only so the book gets excluded from future recommendations. A
   feature's PER-USER WEIGHT is how much it actually discriminates for
   that specific user (positive vs. negative differ a lot -> high
   weight; look the same on this feature -> low weight, it isn't telling
   us anything about this user's taste). This is the "per-user weighted
   vector" the artifact specified, not a fixed global formula applied
   identically to everyone.

3. Every other catalog book is scored by weighted similarity to the
   liked-books centroid, using those per-user weights.

4. explain_match() surfaces WHY a book scored the way it did, in
   readable language, for any book in the catalog -- not just
   recommend()'s top results. The same scoring math is decomposed into
   "matches" (factors pulling the score up) and "mismatches" (factors
   pulling it down), so the same mechanism explains both a strong
   recommendation and a poor one (e.g. a user searching a specific book
   that isn't for them). Deliberately avoids a bare "90% match" framing
   -- the score is a relative ranking, not a calibrated probability --
   in favor of a qualitative label (see match_label()) plus the reasons.

This is intentionally a standalone, runnable prototype (not wired into
the DB as a stored function/API yet) -- that's step 06+ work, once the
app itself exists. Reads directly from Postgres (DATABASE_URL in .env,
same as every other script in this project) -- no separate export step.
Run directly: `python3 scripts/recommend.py`.
"""

import os

import psycopg2
import psycopg2.extras

DATABASE_URL = os.environ.get(
    "DATABASE_URL", "postgresql://postgres:postgres@127.0.0.1:54322/postgres"
)

# --- Field encoding scheme -------------------------------------------------

# Ordinal fields: value lists in increasing order. na/none are handled as
# a separate "not applicable" bucket per field (see NA_VALUES) rather than
# forced onto the scale, since e.g. violence_intensity: na (no violence at
# all) isn't "less violent than mild" in a meaningful taste sense -- it's
# a different regime (this book doesn't have that content at all).
ORDINAL_FIELDS = {
    "overall_pace": ["slow", "medium", "fast"],
    "darkness": ["light", "moderate", "dark", "grimdark"],
    "humor_level": ["none", "light", "moderate", "heavy"],
    "emotional_register": ["comfort_read", "bittersweet", "tense", "gut_punch"],
    "message_intensity": ["subtle", "moderate", "heavy_handed"],
    "intellectual_weight": ["escapist", "moderate", "cerebral"],
    "romance_heat_frequency": ["none", "rare", "occasional", "frequent"],
    "romance_heat_intensity": ["closed_door", "low", "moderate", "explicit"],
    "violence_frequency": ["none", "rare", "occasional", "frequent"],
    "violence_intensity": ["mild", "moderate", "graphic", "brutal"],
    "worldbuilding_density": ["light", "moderate", "dense"],
    "stakes_scope": ["intimate", "regional", "global", "cosmic"],
    "personal_stakes": ["low", "moderate", "high", "life_threatening"],
    "book_length": ["short", "standard", "long", "epic"],
    "audiobook_length": ["short", "standard", "long", "epic"],
    "prose_density": ["sparse", "moderate", "lush"],
    "prose_complexity": ["accessible", "moderate", "dense"],
    "age_category": ["middle_grade", "ya", "new_adult", "adult"],
    # Widened 2026-08-29 from a binary single/multiple -- see
    # book-dna.schema.yaml. Now ordinal instead of nominal so a "few"
    # book (e.g. Kings of Paradise, 3 POVs) scores partial similarity to
    # an "ensemble" book (e.g. A Game of Thrones, 9 POVs) instead of a
    # flat match/no-match against every other multi-POV book alike.
    "pov_count": ["single", "dual", "few", "several", "ensemble"],
}
NA_VALUES = {"na", "none"}  # per-field "not applicable" sentinel, see above

NOMINAL_FIELDS = [
    "person", "narrator_reliability", "timeline", "form",
    "pace_shape", "drive", "narrative_closure", "emotional_resolution",
    "ends_on_cliffhanger", "magic_system_hardness", "scifi_hardness",
]

# Nominal fields match all-or-nothing by default (see nominal_similarity()
# below) -- correct for most nominal values, which really are just
# different categories with no natural "closeness." But a stress test
# during the veto/cap mechanism's rollout (2026-09-02) found a real gap:
# person's third_limited and third_omniscient got scored as a COMPLETE
# mismatch against each other, identical to third_limited vs. first --
# even though a reader would call both "basically third person." This
# maps specific (field, value_a, value_b) pairs to a partial-credit
# similarity instead of 0.0 for a non-exact match. Exact match is always
# 1.0 regardless of what's here.
#
# Deliberately conservative -- NOT a blanket "give nominal fields partial
# credit" change (see this project's general caution against inventing
# field relationships without real justification, e.g. the deferred
# field-pairing-interactions idea in docs/scoring-test-protocol.md).
# Each entry here has either (a) direct empirical evidence a full
# mismatch is wrong (person, the case that motivated this), or (b)
# explicit textual justification in the schema itself (drive's
# `balanced` is documented as "an even split of" character_driven and
# plot_driven -- a real midpoint, not an unrelated fourth category, so it
# gets partial credit against each of those two specifically, but NOT
# against worldbuilding_driven, which the schema treats as a genuinely
# separate axis). Deliberately did NOT extend this to narrator_reliability's
# `ambiguous` (the schema explicitly frames it as a different axis from
# unreliable, not a blend -- "withholds the information needed to judge
# either way," not "somewhat unreliable") or emotional_resolution's
# `bittersweet` (linguistically plausible as a happy/tragic blend, but
# without either empirical evidence or explicit schema backing -- a
# candidate to revisit, not added speculatively).
NOMINAL_PARTIAL_SIMILARITY = {
    "person": {
        frozenset({"third_limited", "third_omniscient"}): 0.5,
    },
    "drive": {
        frozenset({"character_driven", "balanced"}): 0.5,
        frozenset({"plot_driven", "balanced"}): 0.5,
    },
}


def nominal_similarity(field, value_a, value_b):
    """1.0 for an exact match, else a partial-credit value from
    NOMINAL_PARTIAL_SIMILARITY if this specific (field, value_a, value_b)
    pair has one, else 0.0 (the original all-or-nothing behavior)."""
    if value_a == value_b:
        return 1.0
    return NOMINAL_PARTIAL_SIMILARITY.get(field, {}).get(frozenset({value_a, value_b}), 0.0)


MULTI_FIELDS = ["tropes", "genre"]

# Rating scale, added 2026-08-30. Labeled tiers rather than raw 1-5
# stars, per the ratings-precision discussion -- raw numeric stars have
# a well-known calibration problem (is a "solid but unremarkable" book a
# 3 or a 4?), while labeled tiers map onto how people actually talk
# about books. "it_was_okay" is a genuine neutral (magnitude 0): it
# should pull a user's profile toward neither their liked nor disliked
# side, but still needs to exclude the book from future recommendations
# (they've already read it) -- see recommend()'s exclusion logic.
RATING_LABELS = {
    "loved": 1.0,
    "liked": 0.5,
    "it_was_okay": 0.0,
    "disliked": -0.5,
    "hated": -1.0,
}

# Which fields get their weight computed from the FULL liked/disliked
# pool (structural/craft -- how a story is told, not what it's about;
# taste on these plausibly doesn't depend on genre) vs. only the
# genre-scoped subset when a genre filter is active (content -- what the
# story is about; taste here plausibly IS genre-contextual, e.g. wanting
# grimdark fantasy but hopeful sci-fi is a real, common reader pattern).
# Added 2026-08-29 after a real test case: a user liked 2 multi-POV
# fantasy books and disliked 5 multi-POV sci-fi books. Scored purely
# within-genre, the fantasy profile saw only 2 data points and read
# "multiple POV" as a positive signal; scored on the full pool, the 5
# sci-fi dislikes correctly cancel that out -- pov_count isn't actually
# discriminating this user's taste, something else about those 5 books
# is. Structural fields need the bigger, cross-genre sample; content
# fields (tropes, tone, heat, violence) should stay genre-scoped so one
# genre's content preferences don't bleed into the other's.
STRUCTURAL_ORDINAL_FIELDS = {
    "overall_pace", "worldbuilding_density", "stakes_scope",
    "personal_stakes", "book_length", "audiobook_length", "prose_density",
    "prose_complexity", "age_category", "pov_count",
}
STRUCTURAL_NOMINAL_FIELDS = {
    "person", "narrator_reliability", "timeline", "form", "pace_shape",
    "drive", "narrative_closure", "emotional_resolution", "ends_on_cliffhanger",
}

# Caps the magnitude any single field's weight can reach. Without this, a
# field that happens to split cleanly between a user's liked/disliked sets
# (e.g. pov_count, person -- structural/formal fields, not taste content)
# can end up with a much bigger weight than any individual trope ever
# gets, and then dominates the normalized score almost like a hard filter
# rather than contributing as one signal among many. Found via a real test:
# a liked list that happened to be all multi-POV/third-person against a
# disliked list that was mostly single-POV/first-person produced
# pov_count/person weights of 0.89/0.54 -- dwarfing every trope weight
# (individual tropes rarely exceed ~0.4) and making those two structural
# fields the de facto decision-maker for every recommendation.
WEIGHT_CAP = 0.5

# Hard ceiling on the `diversity` param (see recommend()) -- enforced in
# code, not just a UI convention. At diversity=1.0 (pure novelty, zero
# regard for relevance) a "summon something different" request could
# surface the diametrical opposite of a user's taste (a cozy romantasy
# YA for a grimdark reader) purely because it's unlike their recent
# history. Keeping diversity's contribution below MAX_DIVERSITY means
# the relevance term never gets crowded out entirely, so a book that
# doesn't match the user's taste at all stays capped low regardless of
# how novel it is -- see book-dna.md's 2026-08-29 refinement note.
MAX_DIVERSITY = 0.5

# --- Cold-start fallback (2026-09-03) -------------------------------------
# genre_accessibility (book_dna column, see its migration) powers a
# SEPARATE blend from the normal per-field weighted average -- it's
# deliberately NOT in ORDINAL_FIELDS/build_profile() at all, so it can
# never dilute real signal for a user who already has a rating history
# (the same failure mode this project already hit once for other
# fields -- see docs/scoring-test-protocol.md's aggregation-shape design
# discussion). Instead, for a user with too little demonstrated
# experience, recommend() blends toward "broadly accessible" results
# instead of trusting a profile built from almost nothing. This directly
# fixes a real, confirmed bug: recommend() with 0 ratings previously
# returned literal 0.000 scores in arbitrary order (build_profile() has
# nothing to compute weights from), not a graceful default.
#
# Scope: this only affects recommend()'s ranking. explain_match() is
# unchanged -- a user asking "why would/wouldn't I like THIS book"
# still gets their real profile-based reasoning even when it's thin,
# since there's no "ranked list" for a cold-start fallback to replace.
GENRE_ACCESSIBILITY_DEMAND = {
    "gateway": 0.0, "accessible": 0.25, "moderate": 0.5,
    "demanding": 0.75, "veteran_only": 1.0,
}

# Ratings count at which cold-start blending fully fades to 0 (pure
# normal scoring) -- a first-pass, provisional cutoff like every other
# constant in this file, not derived from real data (there's no real
# "brand-new user going through onboarding" data yet to check it
# against). 12 sits just past this project's own "sparse" scenario (16
# ratings, already treated as real, non-degenerate data) and just past
# where a 7-rating rater (Gabriel) showed weak but real personalization
# -- a reasonable middle ground, not a precise number.
COLD_START_FADE_RATINGS = 12


def reader_experience_fraction(catalog, id_to_magnitude):
    """How much genre experience this user has ALREADY demonstrated,
    independent of how many total ratings they've given -- someone who's
    rated even a single veteran_only book without disliking it has shown
    real readiness regardless of how short their list is. This is why
    it's a separate factor from rating count, not folded into one number
    -- a short list doesn't necessarily mean an inexperienced reader.

    Only counts books rated loved/liked/it_was_okay (magnitude >= 0) --
    disliking/hating a demanding book is ambiguous evidence (could mean
    "too much for me," could mean something unrelated) and isn't trusted
    as proof of readiness either way.

    Returns the highest genre_accessibility demand level (see
    GENRE_ACCESSIBILITY_DEMAND, 0.0-1.0) among those books, or 0.0 if
    none are tagged/rated."""
    best = 0.0
    for bid, mag in id_to_magnitude.items():
        if mag < 0:
            continue
        book = catalog.get(bid)
        if book is None:
            continue
        demand = GENRE_ACCESSIBILITY_DEMAND.get(book.get("genre_accessibility"))
        if demand is not None and demand > best:
            best = demand
    return best


def cold_start_weight(catalog, id_to_magnitude):
    """How much recommend() should lean on accessibility rather than the
    normal per-field profile match -- 1.0 (fully cold) down to 0.0 (fully
    trust the normal profile). Combines two independent factors: raw
    rating count alone isn't the right measure, since someone who's only
    rated one book but it's Gardens of the Moon has shown real genre
    readiness a short list doesn't capture on its own.

    count_component: linear fade from 1.0 at 0 ratings to 0.0 at
    COLD_START_FADE_RATINGS. experience_component: demonstrated readiness
    (see reader_experience_fraction()) discounts the count-based weight
    directly, so a single confirmed veteran_only-tier rating can zero
    this out even at n=1."""
    n = len(id_to_magnitude)
    count_component = max(0.0, 1.0 - n / COLD_START_FADE_RATINGS)
    experience = reader_experience_fraction(catalog, id_to_magnitude)
    return count_component * (1.0 - experience)


# --- Explanation layer: field/value -> human-readable phrase ---------------
# Generic fallback is "{value} {display name}" (e.g. "dark tone"); override
# below only where that reads awkwardly or a field's raw values need real
# rewording to make sense as a phrase. Not every field needs an entry here.
FIELD_DISPLAY_NAMES = {
    "overall_pace": "pacing", "darkness": "tone", "humor_level": "humor",
    "emotional_register": "emotional register", "message_intensity": "messaging",
    "intellectual_weight": "intellectual weight", "romance_heat_frequency": "romance frequency",
    "romance_heat_intensity": "romance heat", "violence_frequency": "violence frequency",
    "violence_intensity": "violence", "worldbuilding_density": "worldbuilding density",
    "stakes_scope": "stakes", "personal_stakes": "personal stakes",
    "book_length": "length", "audiobook_length": "audiobook length",
    "prose_density": "prose", "prose_complexity": "prose complexity",
    "age_category": "age category", "pov_count": "POV structure",
    "person": "narrative person", "narrator_reliability": "narrator reliability",
    "timeline": "timeline", "form": "narrative form", "pace_shape": "pacing shape",
    "drive": "story drive", "narrative_closure": "ending closure",
    "emotional_resolution": "emotional resolution", "ends_on_cliffhanger": "cliffhanger ending",
    "magic_system_hardness": "magic system", "scifi_hardness": "sci-fi rigor",
}

VALUE_PHRASES = {
    "stakes_scope": {
        "intimate": "intimate, personal stakes", "regional": "regional-scale stakes",
        "global": "world-spanning stakes", "cosmic": "cosmic-scale stakes",
    },
    "darkness": {
        "light": "a light tone", "moderate": "a moderate tone",
        "dark": "a dark tone", "grimdark": "a grimdark tone",
    },
    "pov_count": {
        "single": "a single POV", "dual": "dual POV",
        "few": "a handful of POV characters", "several": "several POV characters",
        "ensemble": "a large ensemble cast",
    },
    "violence_intensity": {
        "mild": "mild violence", "moderate": "moderate violence",
        "graphic": "graphic violence", "brutal": "brutal, unflinching violence",
    },
    "book_length": {
        "short": "a short length", "standard": "a standard length",
        "long": "a long length", "epic": "an epic length",
    },
    "prose_density": {
        "sparse": "sparse, lean prose", "moderate": "moderately descriptive prose",
        "lush": "lush, immersive prose",
    },
    "magic_system_hardness": {
        "hard": "a hard, rules-based magic system", "soft": "a soft, mysterious magic system",
        "none": None, "na": None,
    },
    "scifi_hardness": {"hard": "hard science-fiction rigor", "soft": "soft science fiction", "na": None},
    "person": {
        "first": "first-person narration", "second": "second-person narration",
        "third_limited": "third-person limited narration", "third_omniscient": "third-person omniscient narration",
        "mixed": "mixed narrative person",
    },
    "pace_shape": {
        "consistent": "a consistent pace throughout", "slow_burn_to_fast_finish": "a slow burn building to a fast finish",
        "front_loaded": "a front-loaded pace", "uneven": "an uneven pace",
    },
    "ends_on_cliffhanger": {
        "resolved": "a resolved ending", "cliffhanger": "a cliffhanger ending",
    },
    "drive": {
        "character_driven": "a character-driven story", "plot_driven": "a plot-driven story",
        "balanced": "a story balanced between character and plot", "worldbuilding_driven": "a worldbuilding-driven story",
    },
    "narrative_closure": {
        "self_contained": "a self-contained story", "requires_series": "an ending that requires the rest of the series",
    },
}


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


DEFAULT_POOR_THRESHOLD = 0.35
GOOD_MATCH_THRESHOLD = 0.55
STRONG_MATCH_THRESHOLD = 0.75


def match_label(score, poor_threshold=DEFAULT_POOR_THRESHOLD):
    """Qualitative label instead of a bare percentage -- score is a
    relative ranking, not a calibrated probability, and a precise-looking
    number like "90% match" implies more rigor than the model has. The
    Good/Strong boundaries (GOOD_MATCH_THRESHOLD/STRONG_MATCH_THRESHOLD)
    are a rough first-pass calibration, not derived from real user data
    yet -- revisit once real ratings exist to check against.

    poor_threshold defaults to a fixed 0.35, but callers with a resolved
    profile should pass user_calibrated_poor_threshold()'s result instead
    (see its docstring) -- a fixed 0.35 can mathematically never fire on
    this project's real data: every genuinely disliked/hated held-out
    book tested so far scored 0.397-0.895, never below 0.35 (see
    docs/scoring-test-protocol.md's "Poor-match threshold diagnostic,"
    2026-09-02). Kept as the default here (not removed) so a caller with
    no resolved profile -- or no disliked ratings to calibrate from --
    still gets a sane, non-crashing value."""
    if score >= STRONG_MATCH_THRESHOLD:
        return "Strong match"
    if score >= GOOD_MATCH_THRESHOLD:
        return "Good match"
    if score >= poor_threshold:
        return "Mixed match"
    return "Poor match"


def user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights,
                                    default=DEFAULT_POOR_THRESHOLD):
    """A per-user replacement for match_label()'s fixed Poor/Mixed
    boundary: the midpoint between THIS user's own mean score on their
    liked/loved training books and their disliked/hated ones (both
    rescored against their own freshly-built profile -- i.e. how the
    model scores the very evidence it was built from).

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
        score, _ = score_book(book, centroid, weights)
        if mag > 0:
            liked_scores.append(score)
        elif mag < 0:
            disliked_scores.append(score)
    if not liked_scores or not disliked_scores:
        return default
    mean_liked = sum(liked_scores) / len(liked_scores)
    mean_disliked = sum(disliked_scores) / len(disliked_scores)
    return max(0.20, min(0.54, (mean_liked + mean_disliked) / 2))


# Fields describing HOW a story is told (lead into a "told with ..."
# clause) vs. everything else -- tone/content fields and tropes -- which
# read naturally as a "features/also has ..." list. This split is what
# turns a flat phrase list into an actual sentence; see natural_sentence().
NARRATIVE_STYLE_FIELDS = {"person", "pov_count", "timeline", "narrator_reliability", "form"}


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


# --- Series DNA --------------------------------------------------------
# A series can change dramatically across its own run (The Wheel of Time:
# book 1 is single-POV/fast/journey-structured; book 6+ is multi-POV/
# slow/political) -- scoring or describing a series by only its first
# entry's Book DNA can misrepresent the whole commitment. Series DNA is
# an AGGREGATION over book_dna rows already tagged per book, grouped by
# `series_id` and ordered by `position_in_series` -- not a fresh tagging
# pass.
#
# Scope question resolved 2026-08-30: does a shared universe (the
# Cosmere) or a parent series spanning tonally different eras (Mistborn,
# spanning the original trilogy and the later Wax & Wayne books) merit
# its own DNA? No to both -- the existing series hierarchy already
# settles this for free. `books.series_id` always points at a LEAF
# series (confirmed: Mistborn: The Final Empire etc. link to "Mistborn
# Era One", never to the parent "Mistborn" row, which has zero books
# linked directly). Grouping by series_id therefore naturally computes
# trajectories only at the level a reader actually commits to reading in
# order -- a universe or a multi-era parent series is too heterogeneous
# to blend into one coherent centroid (same reasoning as the earlier
# genre-split finding: blending across genuinely disjoint reading
# experiences loses signal rather than gaining it).
TREND_THRESHOLD = 0.2  # fraction of the ordinal scale's full range

# Fields most likely to matter to a reader deciding whether to continue
# a series -- used only to prioritize which detected shifts get
# surfaced first when there are several (see describe_series_trajectory).
TRAJECTORY_PRIORITY_FIELDS = [
    "overall_pace", "pov_count", "darkness", "violence_intensity",
    "worldbuilding_density", "book_length", "age_category", "stakes_scope",
]


def compute_series_dna(catalog):
    """Groups catalog books by series_id, ordered by position_in_series.
    Returns {series_id: {"name", "books": [(position, title), ...],
    "trajectories": {field: {"start_value", "end_value", "trend"}}}} for
    every series with >= 2 tagged books (a single-book series has no
    trajectory). `trend` is "increases"/"decreases"/"stable" for ordinal
    fields (a real directional shift, not just noise -- see
    TREND_THRESHOLD) and "changes"/"stable" for nominal fields (no
    direction, just "this isn't the same throughout")."""
    by_series = {}
    for b in catalog.values():
        sid = b.get("series_id")
        if sid is None:
            continue
        by_series.setdefault(sid, {"name": b.get("series_name"), "books": []})
        by_series[sid]["books"].append(b)

    result = {}
    for sid, data in by_series.items():
        books = sorted(data["books"], key=lambda b: float(b["position_in_series"] or 0))
        if len(books) < 2:
            continue

        trajectories = {}
        for field in ORDINAL_FIELDS:
            positions = [ordinal_position(field, b.get(field)) for b in books]
            valid = [(i, p[0] / p[1]) for i, p in enumerate(positions) if p is not None]
            if len(valid) < 2:
                continue
            start_i, start_val = valid[0]
            end_i, end_val = valid[-1]
            diff = end_val - start_val
            trend = "increases" if diff >= TREND_THRESHOLD else "decreases" if diff <= -TREND_THRESHOLD else "stable"
            trajectories[field] = {
                "start_value": books[start_i].get(field),
                "end_value": books[end_i].get(field),
                "trend": trend,
            }

        for field in NOMINAL_FIELDS:
            valid = [(i, b.get(field)) for i, b in enumerate(books) if b.get(field)]
            if len(valid) < 2:
                continue
            start_i, start_val = valid[0]
            end_i, end_val = valid[-1]
            trend = "stable" if start_val == end_val else "changes"
            trajectories[field] = {
                "start_value": start_val,
                "end_value": end_val,
                "trend": trend,
            }

        result[sid] = {
            "name": data["name"],
            "books": [(b.get("position_in_series"), b["title"]) for b in books],
            "trajectories": trajectories,
        }
    return result


def describe_series_trajectory(series_entry, max_items=3):
    """series_entry: one value from compute_series_dna()'s result dict.
    Returns a readable sentence describing how the series changes
    across its run, or "" if nothing changes meaningfully (this is the
    common case -- most series stay consistent, and that's fine, no
    caveat needed)."""
    changed = [(f, t) for f, t in series_entry["trajectories"].items() if t["trend"] != "stable"]
    if not changed:
        return ""
    changed.sort(key=lambda x: TRAJECTORY_PRIORITY_FIELDS.index(x[0]) if x[0] in TRAJECTORY_PRIORITY_FIELDS else len(TRAJECTORY_PRIORITY_FIELDS))

    phrases = []
    for field, t in changed[:max_items]:
        start_phrase = phrase_field(field, t["start_value"])
        end_phrase = phrase_field(field, t["end_value"])
        if not start_phrase or not end_phrase:
            continue
        phrases.append(f"{start_phrase} to {end_phrase}")
    if not phrases:
        return ""
    return f"Across the series, it shifts from {_join_list(phrases)}."


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
    scores = [score_book(b, centroid, weights)[0] for b in books]

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


def load_catalog():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    cur.execute("""
        select b.id, b.title, b.author, b.series_id, s.name as series_name,
               b.position_in_series, d.*
        from books b
        join book_dna d on d.book_id = b.id
        left join series s on s.id = b.series_id
    """)
    books = [dict(row) for row in cur.fetchall()]

    cur.execute("""
        select book_id, array_agg(trope_id) as tropes
        from book_tropes group by book_id
    """)
    tropes_by_book = {row["book_id"]: row["tropes"] for row in cur.fetchall()}

    # Confidence layer (2026-08-30) -- see book_field_confidence's
    # migration comment. Absence of a row means "unassessed"; get_confidence()
    # below defaults to full trust (1.0) rather than penalizing the vast
    # majority of tags that were never explicitly flagged as uncertain.
    cur.execute("select book_id, trope_id, confidence from book_tropes where confidence is not null")
    trope_confidence_by_book = {}
    for row in cur.fetchall():
        trope_confidence_by_book.setdefault(row["book_id"], {})[row["trope_id"]] = float(row["confidence"])

    cur.execute("select book_id, field_name, confidence from book_field_confidence")
    field_confidence_by_book = {}
    for row in cur.fetchall():
        field_confidence_by_book.setdefault(row["book_id"], {})[row["field_name"]] = float(row["confidence"])

    cur.close()
    conn.close()

    for b in books:
        b["tropes"] = tropes_by_book.get(b["id"], [])
        b["_trope_confidence"] = trope_confidence_by_book.get(b["id"], {})
        b["_field_confidence"] = field_confidence_by_book.get(b["id"], {})
    return {b["id"]: b for b in books}


# Fields with at least one CONFIRMED real tagging error from external
# reader feedback so far (2026-08-31, two rounds). An unassessed value on
# these fields defaults BELOW full trust, so that a `manual_review`-
# sourced correction (confidence 1.0, the ceiling every field already
# nominally has) can actually outrank an unverified guess instead of
# tying with it -- confidence is capped at 1.0, so "verified" only means
# something if "unverified" doesn't already sit at the same ceiling.
# Policy: membership is evidence-driven, not a priori guesswork -- a
# field joins this set once a real reader has caught a real error on it,
# not because it "sounds" error-prone. Round 1: person, pov_count,
# narrator_reliability (Dungeon Crawler Carl). Round 2: magic_system_hardness,
# overall_pace, romance_heat_intensity, drive, stakes_scope,
# narrative_closure, humor_level (Yumi and the Nightmare Painter, Tress
# of the Emerald Sea, Jade City, This Is How You Lose the Time War,
# Speaker for the Dead, Slaughterhouse-Five). Round 2 alone matching
# round 1's error rate across 7 more fields is real evidence that
# tagging errors aren't confined to a narrow "mechanical fields" category
# -- expect this set to keep growing as more real feedback comes in,
# not to stabilize at some small fixed list.
HIGH_RISK_FIELD_DEFAULT = 0.85
HIGH_RISK_FIELDS = {
    "person", "pov_count", "narrator_reliability",
    "magic_system_hardness", "overall_pace", "romance_heat_intensity",
    "drive", "stakes_scope", "narrative_closure", "humor_level",
}


def get_confidence(book, field_or_trope):
    """Confidence (0-1) in this specific book's value for this specific
    field or trope. Defaults to 1.0 (full trust) when unassessed, except
    for HIGH_RISK_FIELDS (see above) -- see book_field_confidence's
    migration comment for why absence isn't treated as low confidence in
    general."""
    if field_or_trope in book.get("_trope_confidence", {}):
        return book["_trope_confidence"][field_or_trope]
    default = HIGH_RISK_FIELD_DEFAULT if field_or_trope in HIGH_RISK_FIELDS else 1.0
    return book.get("_field_confidence", {}).get(field_or_trope, default)


def ordinal_position(field, value):
    """Returns (position, scale_max) or None if value is NA/missing for this field."""
    if value is None or value in NA_VALUES:
        return None
    scale = ORDINAL_FIELDS[field]
    if value not in scale:
        return None
    return scale.index(value), len(scale) - 1


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


def build_profile(catalog, ratings, full_ratings=None):
    """Returns (centroid, weights) -- centroid is the target feature profile
    (a rating-magnitude-weighted average of positively-rated books),
    weights say how much each feature matters for THIS user specifically.

    ratings: {book_id: magnitude} (see RATING_LABELS), the (possibly
    genre-scoped) pool used for CONTENT fields and tropes.
    full_ratings: same shape, the unscoped pool used for STRUCTURAL
    fields (see STRUCTURAL_*_FIELDS above) -- defaults to `ratings` when
    not given, i.e. no genre scoping in play."""
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
        """positions: list of (position_fraction, weight) already
        filtered to non-None. Returns None if empty."""
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
            # No disliked signal yet -- fall back to a modest default
            # weight rather than zero, so early users (few ratings) still
            # get a reasonable profile instead of an all-zero vector.
            weights[field] = 0.3

    for field in NOMINAL_FIELDS:
        pool_liked = full_liked if field in STRUCTURAL_NOMINAL_FIELDS else liked
        pool_disliked = full_disliked if field in STRUCTURAL_NOMINAL_FIELDS else disliked
        liked_vals = [(b.get(field), m) for b, m in pool_liked if b.get(field)]
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
        disliked_vals = [(b.get(field), m) for b, m in pool_disliked if b.get(field)]
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


# Redundancy discounts (2026-09-01, revised): a field pair where knowing
# one value makes the other near-certain, in ONE direction only -- these
# are asymmetric implications, not a symmetric correlation, so the
# discount can't correctly be a blanket per-profile weight scaling
# (that would wrongly discount the field for every candidate book, even
# ones where the implication doesn't hold and the field carries full,
# independent information). Applied per-book, inside score_book()/
# explain_book(), conditional on the SPECIFIC triggering value being
# present on THAT book:
#   - person=first implies pov_count=single 88% of the time (vs. a 44%
#     baseline) -- but pov_count=single does NOT strongly imply
#     person=first (61% vs. a 31% baseline, a much weaker reverse
#     implication -- plenty of single-POV books are third-person). So
#     pov_count is only discounted on books that are actually
#     person=first; a third-person single-POV book keeps pov_count's
#     full weight, since nothing there is redundant.
#   - ends_on_cliffhanger=cliffhanger implies narrative_closure=
#     requires_series 98.6% of the time (nearly a hard rule) -- but
#     requires_series does NOT imply cliffhanger (51.5% vs. a 44.3%
#     baseline, barely above chance -- a book can need the series to
#     continue for all sorts of reasons besides ending on a literal
#     cliffhanger). So narrative_closure is only discounted on books
#     that actually end on a cliffhanger.
# A broader scan found several other correlated pairs (violence
# frequency/intensity, romance heat frequency/intensity, darkness/
# emotional_register) deliberately left alone -- see
# docs/scoring-test-protocol.md for why those are two genuinely
# distinct axes, not the same fact stated twice.
REDUNDANCY_DISCOUNTS = {
    # (dependent_field, triggering_field, triggering_value): discount
    ("pov_count", "person", "first"): 0.44,
    ("narrative_closure", "ends_on_cliffhanger", "cliffhanger"): 0.60,
}


def _redundancy_adjusted_weight(book, field, w):
    """w with any applicable REDUNDANCY_DISCOUNTS applied, conditional on
    this specific book's own value for the triggering field -- see
    REDUNDANCY_DISCOUNTS's comment above for why this must be per-book,
    not a blanket per-profile scaling."""
    for (dependent, trigger_field, trigger_value), discount in REDUNDANCY_DISCOUNTS.items():
        if field == dependent and book.get(trigger_field) == trigger_value:
            w = w * (1 - discount)
    return w


def score_book(book, centroid, weights):
    """Confidence discount (2026-08-30): a field/trope's effective weight
    for THIS book is scaled by get_confidence(book, field) before it
    contributes -- an uncertain tag gets less voting power in the
    weighted average rather than being trusted at face value or assumed
    to be a mismatch. Discounting both the numerator (contribution) and
    denominator (total_weight) equally is what keeps this a "count for
    less" effect rather than a bias toward either match or mismatch."""
    score = 0.0
    total_weight = 0.0
    contributions = []

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
            sim = nominal_similarity(field, book.get(field), centroid[field])
        w_eff = _redundancy_adjusted_weight(book, field, w) * get_confidence(book, field)
        contribution = w_eff * sim
        score += contribution
        total_weight += abs(w_eff)
        if w > 0.15:
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


def explain_book(book, centroid, weights, top_n=5):
    """Splits scoring factors into what's pulling the score UP (matches)
    vs. DOWN (mismatches) for this book against this profile -- the same
    math score_book() uses, decomposed for human explanation instead of
    collapsed into one number.

    Why this needs its own pass rather than just re-reading
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
    shows up muted in the explanation too, not just the ranking."""
    matches, mismatches = [], []

    for field, w in weights.items():
        if field == "tropes" or field not in centroid:
            continue
        if field in ORDINAL_FIELDS:
            pos = ordinal_position(field, book.get(field))
            if pos is None:
                continue
            sim = 1 - abs(pos[0] / pos[1] - centroid[field])
        else:
            sim = nominal_similarity(field, book.get(field), centroid[field])
        w = _redundancy_adjusted_weight(book, field, w) * get_confidence(book, field)

        if w >= 0:
            matches.append((field, w * sim))
            mismatches.append((field, w * (1 - sim)))
        else:
            # Negative weight only comes from a fatigue override --
            # matching the profile here IS the mismatch (the user asked
            # to suppress this specifically), not matching it is the win.
            matches.append((field, abs(w) * (1 - sim)))
            mismatches.append((field, abs(w) * sim))

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


# A mismatch magnitude this large is treated as a likely personal
# dealbreaker, surfaced as its own flag alongside the blended score
# rather than folded into it -- see dealbreaker_flags()'s docstring for
# why. 0.3 is a first-pass heuristic, not yet a statistically validated
# per-user threshold: picked from a real, consistent gap found across
# Mathias's 5 disliked/hated held-out mispredictions (2026-09-02) -- in
# every one, the top 1-2 mismatches (person, magic_system_hardness,
# scifi_hardness) clustered >= 0.34, while every other mismatch in the
# same lists sat <= 0.211, a clean, unambiguous split. Revisit once
# per-user statistical dealbreaker detection (AUC/point-biserial
# separation of a user's own loved vs. hated books, gated by a minimum
# sample size) replaces this fixed constant -- see
# docs/scoring-test-protocol.md's design-discussion entry.
DEALBREAKER_THRESHOLD = 0.3

# --- Statistical per-user dealbreaker validation (2026-09-02) ----------
# Option #3 from the design discussion: instead of trusting
# DEALBREAKER_THRESHOLD's fixed magnitude everywhere, measure per USER,
# per FIELD, how well that field alone separates THEIR OWN loved/liked
# books from their disliked/hated ones, and only trust a field as a
# validated dealbreaker candidate once there's real evidence AND enough
# of it. This directly answers what the stakes_drive/craft_density
# investigation got wrong: that was a blanket category removal, not
# conditioned on being a genuine per-user dealbreaker -- see
# docs/scoring-test-protocol.md's design-discussion entry.
#
# MIN_DEALBREAKER_SAMPLE: minimum observations required in EACH group
# (liked, disliked) before trusting a field's separation at all -- below
# this, a large-looking gap is as likely to be noise from a handful of
# ratings as a real pattern (the same "too few ratings" problem this
# project already handles elsewhere via leave-one-out instead of a real
# held-out split). 3 is a low bar deliberately: even Gabriel (7 ratings
# total, usually only 1 disliked) won't clear it for most fields, which
# is the INTENDED behavior -- validated_dealbreaker_fields() returns an
# empty set for him, and dealbreaker_flags() gracefully falls back to
# the fixed threshold rather than validating nothing and flagging
# nothing.
MIN_DEALBREAKER_SAMPLE = 3

# STAT_SEPARATION_THRESHOLD: how strong a field's separation must be to
# count as "validated." Originally set to 0.5 (the standard behavioral-
# science "large effect size" convention for point-biserial correlation:
# small=0.1, medium=0.3, large=0.5), but RAISED to 0.65 after landing the
# veto/cap mechanism (_apply_dealbreaker_veto(), 2026-09-02) exposed a
# real problem at 0.5: Mathias's SPARSE scenario (8 liked/7 disliked)
# validated 6 fields at 0.5, five of them landing suspiciously close to
# the threshold itself (0.500-0.523) -- a classic multiple-comparisons
# artifact (testing ~30 fields against a small sample means several will
# cross a fixed bar by chance alone, not because they're real). With 6
# fields eligible to trigger a veto, the mechanism capped EVERY loved/
# liked held-out book in that scenario (loved_recall 75% -> 0%) -- caught
# by rerunning the full benchmark suite before treating the veto as
# landed, exactly the "check against >= 2 scenarios" discipline this
# project already has a track record of needing (see WEIGHT_CAP,
# redundancy discounts). 0.65 was picked empirically, not by convention:
# it's the point where Mathias's full AND sparse scenarios converge on
# the SAME single field (`person`, separation 0.75-0.82 in both --
# genuinely robust, unlike the marginal ones it filters out), and where
# the WEIGHT_CAP_RATINGS domination-stress-test's validated set stabilizes
# (5 fields at 0.6, 3 fields at 0.65-0.75, no further change) rather than
# continuing to shrink -- a real plateau, not an arbitrary round number.
# This was safe to do PURELY because dealbreaker_flags()'s VALIDATED path
# (and now the veto) requires clearing this bar -- raising it only makes
# both mechanisms MORE conservative, never introduces a new failure mode.
STAT_SEPARATION_THRESHOLD = 0.65

# Once a field IS statistically validated for this user, a mismatch on
# it only needs to clear this much LOWER bar to be flagged -- we already
# have real evidence the field matters to them, so we trust a smaller
# mismatch on it more than an unvalidated field's. 0.15 sits just above
# explain_book()'s own noise floor (0.1, the cutoff for appearing in
# `mismatches` at all).
VALIDATED_DEALBREAKER_MAGNITUDE = 0.15


def _ordinal_field_separation(catalog, id_to_magnitude, field):
    """Point-biserial-style correlation between group membership (loved/
    liked=1, disliked/hated=0; it_was_okay excluded, same split
    build_profile() uses) and this ORDINAL field's position, for THIS
    user's own rated books. None if fewer than MIN_DEALBREAKER_SAMPLE
    observations exist in either group."""
    liked, disliked = [], []
    for bid, mag in id_to_magnitude.items():
        if mag == 0:
            continue
        book = catalog.get(bid)
        if book is None:
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
    exist in either group."""
    liked_vals, disliked_vals = [], []
    for bid, mag in id_to_magnitude.items():
        if mag == 0:
            continue
        book = catalog.get(bid)
        if book is None:
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
    MIN_DEALBREAKER_SAMPLE liked or disliked books exist at all."""
    liked_n = disliked_n = liked_hits = disliked_hits = 0
    for bid, mag in id_to_magnitude.items():
        if mag == 0:
            continue
        book = catalog.get(bid)
        if book is None:
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
    exists."""
    keys = set()
    for bid, mag in id_to_magnitude.items():
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
        sep = field_or_trope_separation(catalog, id_to_magnitude, key)
        if sep is not None and abs(sep) >= min_strength:
            validated.add(key)
    return validated


def dealbreaker_flags(book, centroid, weights, top_n=5, threshold=DEALBREAKER_THRESHOLD,
                       validated_fields=None):
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
    _, mismatches = explain_book(book, centroid, weights, top_n=100)
    if validated_fields:
        flags = [(f, m) for f, m in mismatches if f in validated_fields and m >= VALIDATED_DEALBREAKER_MAGNITUDE]
    else:
        flags = [(f, m) for f, m in mismatches if m >= threshold]
    return flags[:top_n]


def book_similarity(book_a, book_b):
    """Objective book-to-book resemblance (NOT personalized -- no
    per-user weights involved), used only to compute novelty against
    recent history for the `diversity` param below. Personalization
    already lives in the relevance term (score_book against the user's
    profile); this is a separate, unweighted signal for "how alike are
    these two specific books," blending ordinal-field closeness,
    nominal-field exact-match, and trope-set Jaccard similarity."""
    ordinal_sims = []
    for field in ORDINAL_FIELDS:
        pa = ordinal_position(field, book_a.get(field))
        pb = ordinal_position(field, book_b.get(field))
        if pa is not None and pb is not None:
            ordinal_sims.append(1 - abs(pa[0] / pa[1] - pb[0] / pb[1]))

    nominal_sims = []
    for field in NOMINAL_FIELDS:
        va, vb = book_a.get(field), book_b.get(field)
        if va and vb:
            nominal_sims.append(1.0 if va == vb else 0.0)

    ta = set(book_a.get("tropes") or [])
    tb = set(book_b.get("tropes") or [])
    trope_sim = len(ta & tb) / len(ta | tb) if (ta or tb) else 0.0

    components = [trope_sim]
    if ordinal_sims:
        components.append(sum(ordinal_sims) / len(ordinal_sims))
    if nominal_sims:
        components.append(sum(nominal_sims) / len(nominal_sims))
    return sum(components) / len(components)


# Series-repeat signal (2026-09-01, user's own proposed rule): if a
# reader disliked an earlier book in this exact series, that's a strong
# prior the candidate will disappoint too -- UNLESS the candidate's own
# DNA diverges substantially from that disliked predecessor (e.g. The
# Wise Man's Fear's predecessor, The Name of the Wind, was rated
# it_was_okay -- neutral, not disliked -- so this deliberately does NOT
# fire there; only an ACTUAL disliked/hated series-mate counts).
# Verified against the Farseer case: Royal Assassin and Assassin's Quest
# (both disliked, held out) both moved substantially in the correct
# direction once blended in (Royal Assassin's score dropped from 0.539
# to 0.446 at this weight), while every non-series or no-disliked-
# series-mate book is completely unaffected. Confirmed no interaction
# with the WEIGHT_CAP domination case either (no shared series there).
#
# Honest limitation: even at full weight, this doesn't always cross all
# the way to "Poor match" -- book_similarity() blends in trope-set
# overlap, and different books in the same series naturally have
# different specific plot tropes even when the narrative style that
# actually drove the dislike stays consistent, which dilutes the
# similarity below what "basically the same reading experience"
# deserves. A dedicated same-series similarity measure (weighting
# narrative-style fields higher, discounting plot-specific tropes) would
# likely close more of that gap -- not built yet, flagged as a real
# follow-up rather than oversold as fully solved.
SERIES_REPEAT_WEIGHT = 0.6


def series_repeat_worst_similarity(catalog, id_to_magnitude, book):
    """Highest book_similarity() between `book` and any DISLIKED book
    (magnitude < 0) from the same series in id_to_magnitude -- None if
    `book` isn't in a series or no disliked series-mate exists. High
    value = this book closely resembles one the reader already
    disliked in this exact series."""
    series_id = book.get("series_id")
    if series_id is None:
        return None
    disliked_mates = [
        b for bid, mag in id_to_magnitude.items()
        if mag < 0
        and (b := catalog.get(bid)) is not None
        and b.get("series_id") == series_id
        and b["id"] != book["id"]
    ]
    if not disliked_mates:
        return None
    return max(book_similarity(book, mate) for mate in disliked_mates)


def _apply_series_repeat(catalog, id_to_magnitude, book, score):
    """Blends `score` with the series-repeat signal (see above) when
    applicable; returns `score` unchanged otherwise."""
    worst_sim = series_repeat_worst_similarity(catalog, id_to_magnitude, book)
    if worst_sim is None:
        return score
    series_component = 1 - worst_sim
    return (1 - SERIES_REPEAT_WEIGHT) * score + SERIES_REPEAT_WEIGHT * series_component


# Veto/cap ceiling: just under GOOD_MATCH_THRESHOLD, so a vetoed book can
# never read as "Good match" or "Strong match" no matter how far above
# this its raw weighted-average score sits. Deliberately NOT capped down
# to "Poor match" -- see _apply_dealbreaker_veto()'s docstring for why a
# validated dealbreaker means "don't confidently recommend this," not
# "this is certainly a bad match."
DEALBREAKER_VETO_CAP = GOOD_MATCH_THRESHOLD - 0.001


def _apply_dealbreaker_veto(catalog, id_to_magnitude, validated_fields, book, centroid, weights, score):
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
    flags = dealbreaker_flags(book, centroid, weights, validated_fields=validated_fields)
    if not flags:
        return score
    return min(score, DEALBREAKER_VETO_CAP)


def _resolve_profile(catalog, ratings, genre=None, fatigue_overrides=None):
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
    blend."""
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

    centroid, weights = build_profile(catalog, scoped_ratings, id_to_magnitude)

    if fatigue_overrides:
        for key, val in fatigue_overrides.items():
            val = max(-1.0, min(1.0, val))
            if key in ORDINAL_FIELDS or key in NOMINAL_FIELDS:
                weights[key] = val
            else:
                weights.setdefault("tropes", {})[key] = val

    return centroid, weights, id_to_magnitude, matches_genre


def series_position_ready(catalog, id_to_magnitude, book):
    """False if `book` is a non-entry-point installment in a series and
    the user hasn't confirmed (rated) every earlier installment --
    recommending book 3 of a trilogy to someone who's only read book 1
    is useless at best, a spoiler risk at worst. True for standalones and
    for a series' entry point (its lowest position_in_series, so a
    prequel novella doesn't wrongly gate book 1 -- reading order nuance
    some readers skip anyway, a known simplification, not a bug).

    id_to_magnitude: {book_id: rating_magnitude} for books the user has
    actually rated (see _resolve_profile) -- being "read" for this check
    means "rated," not any weaker signal."""
    series_id = book.get("series_id")
    if series_id is None:
        return True
    position = book.get("position_in_series")
    if position is None:
        return True
    series_books = [b for b in catalog.values() if b.get("series_id") == series_id]
    earlier = [b for b in series_books if b.get("position_in_series") is not None
               and b["position_in_series"] < position]
    if not earlier:
        return True
    # Group by exact position, not by row -- a duplicate catalog entry at
    # the same position (e.g. an omnibus edition alongside the standalone
    # volume) is an alternate edition of the same slot, not a distinct
    # earlier installment, so only ONE representative per position needs
    # to be rated, not every row that happens to share that position.
    by_position = {}
    for b in earlier:
        by_position.setdefault(b["position_in_series"], []).append(b)
    return all(
        any(b["id"] in id_to_magnitude for b in books_at_pos)
        for books_at_pos in by_position.values()
    )


def recommend(catalog, ratings, top_n=10, genre=None,
              recent_history=None, diversity=0.0, fatigue_overrides=None,
              discovery_only=False):
    """See _resolve_profile() for ratings/genre/fatigue_overrides.

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
        catalog, ratings, genre, fatigue_overrides
    )
    validated_fields = validated_dealbreaker_fields(catalog, id_to_magnitude)
    csw = cold_start_weight(catalog, id_to_magnitude)

    diversity = max(0.0, min(diversity, MAX_DIVERSITY))
    recent_books = [
        catalog[title_to_id[t]] for t in (recent_history or []) if t in title_to_id
    ]

    excluded = set(id_to_magnitude.keys())
    known_series = {
        s for bid in excluded if (s := catalog[bid].get("series_id")) is not None
    }
    known_authors = {catalog[bid]["author"] for bid in excluded}
    scored = []
    for bid, book in catalog.items():
        if bid in excluded or not matches_genre(bid):
            continue
        if discovery_only and (
            book.get("series_id") in known_series or book["author"] in known_authors
        ):
            continue
        if not series_position_ready(catalog, id_to_magnitude, book):
            continue
        relevance, contributions = score_book(book, centroid, weights)
        relevance = _apply_series_repeat(catalog, id_to_magnitude, book, relevance)
        relevance = _apply_dealbreaker_veto(catalog, id_to_magnitude, validated_fields, book, centroid, weights, relevance)
        if diversity > 0 and recent_books:
            novelty = 1 - max(book_similarity(book, h) for h in recent_books)
            relevance = (1 - diversity) * relevance + diversity * novelty
        if csw > 0:
            demand = GENRE_ACCESSIBILITY_DEMAND.get(book.get("genre_accessibility"), 0.5)
            accessibility = 1.0 - demand
            final = (1 - csw) * relevance + csw * accessibility
        else:
            final = relevance
        scored.append((final, book["title"], book["author"], contributions))

    scored.sort(key=lambda x: -x[0])
    return scored[:top_n]


def explain_match(catalog, ratings, title, genre=None, fatigue_overrides=None, top_n=5):
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
    book = catalog[title_to_id[title]]

    centroid, weights, id_to_magnitude, _ = _resolve_profile(catalog, ratings, genre, fatigue_overrides)
    validated = validated_dealbreaker_fields(catalog, id_to_magnitude)
    score, _ = score_book(book, centroid, weights)
    score = _apply_series_repeat(catalog, id_to_magnitude, book, score)
    score = _apply_dealbreaker_veto(catalog, id_to_magnitude, validated, book, centroid, weights, score)
    poor_threshold = user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights)
    matches, mismatches = explain_book(book, centroid, weights, top_n=top_n)
    flags = dealbreaker_flags(book, centroid, weights, validated_fields=validated)

    matches_labeled = [(label, p) for label, _ in matches if (p := describe(label, book))]
    mismatches_labeled = [(label, p) for label, _ in mismatches if (p := describe(label, book))]
    flags_labeled = [(label, p) for label, _ in flags if (p := describe(label, book))]

    series_note = ""
    if book.get("series_id"):
        series_dna = compute_series_dna(catalog)
        series_entry = series_dna.get(book["series_id"])
        if series_entry:
            series_note = describe_series_trajectory(series_entry)

    return {
        "title": title,
        "score": round(score, 3),
        "match_label": match_label(score, poor_threshold),
        "matches": [p for _, p in matches_labeled],
        "mismatches": [p for _, p in mismatches_labeled],
        "summary": natural_sentence(matches_labeled, positive=True),
        "mismatch_summary": natural_sentence(mismatches_labeled, positive=False),
        "dealbreaker_flags": [p for _, p in flags_labeled],
        "dealbreaker_summary": dealbreaker_sentence(flags_labeled),
        "series_note": series_note,
    }


# --- Post-read/DNF feedback ------------------------------------------------
# "Why didn't it work" / "what did you love" dropdown, per the 2026-08-30
# external feedback triage. Deliberately distinct from asking a user to
# explain field-by-field on every single rating (rejected earlier as
# defeating the point of structured Book DNA inference): this is
# optional, triggered only after a clear miss (a low rating or a DNF),
# and reuses the book's OWN already-tagged tropes/fields (via describe())
# as a checklist instead of inventing a separate reason taxonomy --
# "here's what we tagged this book with, tell us which of these worked
# against you."
NEUTRAL_FEEDBACK_REASONS = {
    "wasnt_my_mood": "wasn't in the mood for it",
    "didnt_click_with_characters": "didn't click with the characters",
    "lost_interest_partway": "lost interest partway through",
    "life_got_in_the_way": "life got in the way, not the book's fault",
}


def book_feedback_options(catalog, title, top_n=8):
    """For a book a user just finished/DNF'd and rated poorly: returns
    this book's own tropes/fields as a checklist of "did this bother
    you?" content_options, plus a small fixed set of neutral_options that
    aren't about the book's content at all (mood/timing, general
    disengagement) and therefore can't drive any calibration -- kept
    separate so they're never mistaken for a content signal."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    if title not in title_to_id:
        raise ValueError(f"{title!r} not found in catalog")
    book = catalog[title_to_id[title]]

    trope_options = [
        {"key": f"trope:{t}", "label": describe(f"trope:{t}", book)}
        for t in (book.get("tropes") or [])
    ]
    field_options = [
        {"key": field, "label": phrase}
        for field in list(ORDINAL_FIELDS) + NOMINAL_FIELDS
        if (phrase := describe(field, book))
    ]

    return {
        "content_options": (trope_options + field_options)[:top_n],
        "neutral_options": [
            {"key": key, "label": label} for key, label in NEUTRAL_FEEDBACK_REASONS.items()
        ],
    }


def feedback_to_fatigue_overrides(selected_keys, strength=-0.6):
    """Turns selected book_feedback_options keys into a fatigue_overrides
    dict for recommend()/explain_match(). Only TROPE selections translate
    -- tropes are presence-based, so "penalize this trope going forward"
    is exactly what fatigue_overrides' weights['tropes'][t] override
    already means.

    Field-level selections (e.g. 'overall_pace') deliberately do NOT
    translate the same way, and it would be a real bug to force them to:
    fatigue_overrides flips a field's weight relative to the user's own
    CENTROID ("avoid being similar to your average on this field"), not
    "avoid this specific book's value on it." If the disliked book's
    pace was already far from the user's centroid, flipping the sign
    would perversely reward OTHER far-from-centroid books instead of
    specifically steering away from slow pacing. The correct existing
    mechanism for field-level dislikes is simply rating the book itself
    hated/disliked via RATING_LABELS -- build_profile() already learns
    whether pace is a real discriminator once it recurs across several
    disliked books, which is the right way to learn it (a pattern across
    many books), not a single-book override. Field-level selections are
    still returned by book_feedback_options() for triage/logging value,
    just not fed into this function's output yet."""
    return {
        key[len("trope:"):]: strength
        for key in selected_keys
        if key.startswith("trope:")
    }


# Cheap, durable record of real dislike/DNF reasons for later qualitative
# analysis -- there's no real per-user feedback table yet (no `users`
# table exists at all), so this is deliberately NOT per-user state, just
# an append-only log of real reasons as they come in, to build up a
# corpus of "why don't people like this book" worth mining later (e.g.
# for the confidence layer's triage use case, or just to sanity-check
# whether book_feedback_options()'s structured selections are capturing
# what people actually mean).
FEEDBACK_LOG_PATH = os.environ.get(
    "FEEDBACK_LOG_PATH", os.path.join(os.path.dirname(__file__), "feedback_log.jsonl")
)


def log_feedback(title, selected_keys=None, notes=None):
    """Appends one JSON-lines record to FEEDBACK_LOG_PATH: title, the
    structured book_feedback_options() selections (if any), free-text
    notes (if any -- this is where a real, detailed reason like "felt
    juvenile and preachy" belongs, distinct from the structured
    trope/field checklist), and a timestamp."""
    import json
    from datetime import datetime, timezone

    record = {
        "title": title,
        "selected": selected_keys or [],
        "notes": notes,
        "logged_at": datetime.now(timezone.utc).isoformat(),
    }
    with open(FEEDBACK_LOG_PATH, "a") as f:
        f.write(json.dumps(record) + "\n")


if __name__ == "__main__":
    catalog = load_catalog()
    print(f"Loaded {len(catalog)} books.\n")

    # Original 2026-08-28 pilot data was collected as plain liked/disliked
    # (no magnitude) -- mapped straight onto the new labeled scale rather
    # than inventing granularity that was never actually reported.
    ratings = {
        "The Golden Compass": "liked", "The Lies of Locke Lamora": "liked",
        "The Eye of the World": "liked", "Kings of Paradise": "liked",
        "Prince of Thorns": "liked", "The Way of Kings": "liked",
        "Bird Box": "disliked", "Assassin's Apprentice": "disliked",
        "We Are Legion (We Are Bob)": "disliked",
        "Interview with the Vampire": "disliked", "The Poppy War": "disliked",
        "Circe": "disliked", "Dark Matter": "disliked",
        "He Who Fights with Monsters": "disliked",
    }

    print(f"Ratings: {ratings}\n")
    results = recommend(catalog, ratings, top_n=15)
    for score, title, author, contributions in results:
        print(f"{score:.3f}  {title} ({author})")
        print(f"       top factors: {contributions}")

    print("\n--- explanation layer demo ---\n")
    top_pick = results[0][1]
    print(f"Why '{top_pick}' was recommended:")
    explanation = explain_match(catalog, ratings, top_pick)
    print(f"  {explanation['match_label']} ({explanation['score']})")
    print(f"  {explanation['summary']}")
    if explanation["mismatch_summary"]:
        print(f"  However, {explanation['mismatch_summary'][0].lower()}{explanation['mismatch_summary'][1:]}")
    if explanation["dealbreaker_summary"]:
        print(f"  ⚠ {explanation['dealbreaker_summary']}")

    print(f"\nWhy a genuinely poor-scoring book (bottom of the full ranked list) scores poorly:")
    explanation = explain_match(catalog, ratings, "The Restaurant at the End of the Universe")
    print(f"  {explanation['match_label']} ({explanation['score']})")
    print(f"  {explanation['summary']}")
    if explanation["mismatch_summary"]:
        print(f"  However, {explanation['mismatch_summary'][0].lower()}{explanation['mismatch_summary'][1:]}")
    if explanation["dealbreaker_summary"]:
        print(f"  ⚠ {explanation['dealbreaker_summary']}")

    print(f"\nDealbreaker-flag demo -- a book that mostly matches this profile but hits a known dislike:")
    explanation = explain_match(catalog, ratings, "Royal Assassin")
    print(f"  {explanation['match_label']} ({explanation['score']})")
    print(f"  {explanation['summary']}")
    if explanation["dealbreaker_summary"]:
        print(f"  ⚠ {explanation['dealbreaker_summary']}")
    else:
        print("  (no dealbreaker flag -- nothing crossed DEALBREAKER_THRESHOLD for this profile/book)")
