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


def match_label(score):
    """Qualitative label instead of a bare percentage -- score is a
    relative ranking, not a calibrated probability, and a precise-looking
    number like "90% match" implies more rigor than the model has.
    Thresholds are a rough first-pass calibration, not derived from real
    user data yet -- revisit once real ratings exist to check against."""
    if score >= 0.75:
        return "Strong match"
    if score >= 0.55:
        return "Good match"
    if score >= 0.35:
        return "Mixed match"
    return "Poor match"


def load_catalog():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    cur.execute("""
        select b.id, b.title, b.author, d.*
        from books b join book_dna d on d.book_id = b.id
    """)
    books = [dict(row) for row in cur.fetchall()]

    cur.execute("""
        select book_id, array_agg(trope_id) as tropes
        from book_tropes group by book_id
    """)
    tropes_by_book = {row["book_id"]: row["tropes"] for row in cur.fetchall()}

    cur.close()
    conn.close()

    for b in books:
        b["tropes"] = tropes_by_book.get(b["id"], [])
    return {b["id"]: b for b in books}


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


def score_book(book, centroid, weights):
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
            sim = 1.0 if book.get(field) == centroid[field] else 0.0
        contribution = w * sim
        score += contribution
        total_weight += abs(w)
        if w > 0.15:
            contributions.append((field, round(contribution, 3)))

    trope_weights = weights.get("tropes", {})
    book_tropes = set(book.get("tropes") or [])
    for t, w in trope_weights.items():
        if t in book_tropes:
            score += w
            total_weight += abs(w)
            if abs(w) > 0.15:
                contributions.append((f"trope:{t}", round(w, 3)))

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
    > 0.1 to exclude noise-level factors."""
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
            sim = 1.0 if book.get(field) == centroid[field] else 0.0

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
        (matches if w >= 0 else mismatches).append((f"trope:{t}", abs(w)))

    matches = sorted((m for m in matches if m[1] > 0.1), key=lambda x: -x[1])
    mismatches = sorted((m for m in mismatches if m[1] > 0.1), key=lambda x: -x[1])
    return matches[:top_n], mismatches[:top_n]


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


def recommend(catalog, ratings, top_n=10, genre=None,
              recent_history=None, diversity=0.0, fatigue_overrides=None):
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
    is "summon something different," not "ignore my taste."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    centroid, weights, id_to_magnitude, matches_genre = _resolve_profile(
        catalog, ratings, genre, fatigue_overrides
    )

    diversity = max(0.0, min(diversity, MAX_DIVERSITY))
    recent_books = [
        catalog[title_to_id[t]] for t in (recent_history or []) if t in title_to_id
    ]

    excluded = set(id_to_magnitude.keys())
    scored = []
    for bid, book in catalog.items():
        if bid in excluded or not matches_genre(bid):
            continue
        relevance, contributions = score_book(book, centroid, weights)
        if diversity > 0 and recent_books:
            novelty = 1 - max(book_similarity(book, h) for h in recent_books)
            final = (1 - diversity) * relevance + diversity * novelty
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

    Returns {"title", "score", "match_label", "matches", "mismatches"} --
    matches/mismatches are ordered lists of human-readable phrases (see
    describe())."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    if title not in title_to_id:
        raise ValueError(f"{title!r} not found in catalog")
    book = catalog[title_to_id[title]]

    centroid, weights, _, _ = _resolve_profile(catalog, ratings, genre, fatigue_overrides)
    score, _ = score_book(book, centroid, weights)
    matches, mismatches = explain_book(book, centroid, weights, top_n=top_n)

    return {
        "title": title,
        "score": round(score, 3),
        "match_label": match_label(score),
        "matches": [p for label, _ in matches if (p := describe(label, book))],
        "mismatches": [p for label, _ in mismatches if (p := describe(label, book))],
    }


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
    print(f"  Because of: {', '.join(explanation['matches'])}")
    if explanation["mismatches"]:
        print(f"  Working against it: {', '.join(explanation['mismatches'])}")

    print(f"\nWhy a genuinely poor-scoring book (bottom of the full ranked list) scores poorly:")
    explanation = explain_match(catalog, ratings, "The Restaurant at the End of the Universe")
    print(f"  {explanation['match_label']} ({explanation['score']})")
    print(f"  Because of: {', '.join(explanation['matches'])}")
    if explanation["mismatches"]:
        print(f"  Working against it: {', '.join(explanation['mismatches'])}")
