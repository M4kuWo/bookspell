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

2. A user's profile is built from books they've rated (liked/disliked),
   not from a fixed formula: for each feature, compare the average value
   among liked books to the average among disliked books. A feature's
   PER-USER WEIGHT is how much it actually discriminates for that
   specific user (liked vs. disliked differ a lot -> high weight; liked
   and disliked look the same on this feature -> low weight, it isn't
   telling us anything about this user's taste). This is the "per-user
   weighted vector" the artifact specified, not a fixed global formula
   applied identically to everyone.

3. Every other catalog book is scored by weighted similarity to the
   liked-books centroid, using those per-user weights.

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


def build_profile(catalog, liked_ids, disliked_ids, full_liked_ids=None, full_disliked_ids=None):
    """Returns (centroid, weights) -- centroid is the target feature profile
    (liked books' average), weights say how much each feature matters for
    THIS user specifically.

    liked_ids/disliked_ids: the (possibly genre-scoped) pool used for
    CONTENT fields and tropes. full_liked_ids/full_disliked_ids: the
    unscoped pool used for STRUCTURAL fields (see STRUCTURAL_*_FIELDS
    above) -- defaults to the same pool as liked_ids/disliked_ids when
    not given, i.e. no genre scoping in play."""
    full_liked_ids = liked_ids if full_liked_ids is None else full_liked_ids
    full_disliked_ids = disliked_ids if full_disliked_ids is None else full_disliked_ids

    liked = [catalog[i] for i in liked_ids if i in catalog]
    disliked = [catalog[i] for i in disliked_ids if i in catalog]
    full_liked = [catalog[i] for i in full_liked_ids if i in catalog]
    full_disliked = [catalog[i] for i in full_disliked_ids if i in catalog]

    centroid = {}
    weights = {}

    for field in ORDINAL_FIELDS:
        pool_liked = full_liked if field in STRUCTURAL_ORDINAL_FIELDS else liked
        pool_disliked = full_disliked if field in STRUCTURAL_ORDINAL_FIELDS else disliked
        liked_raw = [x for x in (ordinal_position(field, b.get(field)) for b in pool_liked) if x is not None]
        liked_vals = [p / m for p, m in liked_raw]
        disliked_raw = [x for x in (ordinal_position(field, b.get(field)) for b in pool_disliked) if x is not None]
        disliked_vals = [p / m for p, m in disliked_raw]
        if not liked_vals:
            continue
        liked_mean = sum(liked_vals) / len(liked_vals)
        centroid[field] = liked_mean
        if disliked_vals:
            disliked_mean = sum(disliked_vals) / len(disliked_vals)
            weights[field] = min(WEIGHT_CAP, abs(liked_mean - disliked_mean))
        else:
            # No disliked signal yet -- fall back to a modest default
            # weight rather than zero, so early users (few ratings) still
            # get a reasonable profile instead of an all-zero vector.
            weights[field] = 0.3

    for field in NOMINAL_FIELDS:
        pool_liked = full_liked if field in STRUCTURAL_NOMINAL_FIELDS else liked
        pool_disliked = full_disliked if field in STRUCTURAL_NOMINAL_FIELDS else disliked
        liked_vals = [b.get(field) for b in pool_liked if b.get(field)]
        if not liked_vals:
            continue
        # mode
        counts = {}
        for v in liked_vals:
            counts[v] = counts.get(v, 0) + 1
        mode_val = max(counts, key=counts.get)
        liked_share = counts[mode_val] / len(liked_vals)
        disliked_vals = [b.get(field) for b in pool_disliked if b.get(field)]
        disliked_share = (
            sum(1 for v in disliked_vals if v == mode_val) / len(disliked_vals)
            if disliked_vals else 0.0
        )
        centroid[field] = mode_val
        weights[field] = (
            min(WEIGHT_CAP, max(0.0, liked_share - disliked_share))
            if disliked_vals else 0.3 * liked_share
        )

    # Tropes: content, always genre-scoped. Per-trope weight = how much
    # more (or less) common it is in liked books vs. disliked books.
    # Negative weight = actively penalize (the trope appears in disliked
    # books, not liked ones).
    trope_weights = {}
    liked_trope_lists = [b.get("tropes") or [] for b in liked]
    disliked_trope_lists = [b.get("tropes") or [] for b in disliked]
    all_tropes = set(t for lst in liked_trope_lists + disliked_trope_lists for t in lst)
    for t in all_tropes:
        liked_freq = sum(1 for lst in liked_trope_lists if t in lst) / max(1, len(liked_trope_lists))
        disliked_freq = sum(1 for lst in disliked_trope_lists if t in lst) / max(1, len(disliked_trope_lists)) if disliked_trope_lists else 0.0
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


def recommend(catalog, liked_titles, disliked_titles, top_n=10, genre=None,
              recent_history=None, diversity=0.0, fatigue_overrides=None):
    """genre: None (blend everything, current default behavior), or
    'fantasy'/'sci_fi' to scope the candidate pool (only books tagged
    with that genre) and CONTENT-field profiling (tropes, tone, heat,
    violence -- see STRUCTURAL_*_FIELDS) to only the subset of
    liked/disliked books tagged with that genre. STRUCTURAL fields
    (pov_count, pacing, length, etc.) are always profiled from the FULL
    unscoped liked/disliked list regardless of genre, since craft/format
    taste plausibly doesn't depend on genre and benefits from the bigger
    sample -- see the WEIGHT_CAP-adjacent comment above for the case
    that motivated this split. Falls back to the unscoped liked/disliked
    set for content profiling if none of a user's ratings happen to fall
    in the requested genre.

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

    fatigue_overrides: optional dict of {trope_id_or_field_name: weight}
    that directly overrides the LEARNED weight for that key after
    build_profile() computes it -- e.g. {"werewolves": -1.0} to actively
    suppress a trope the user is fatigued on even though their rating
    history says they like it. A deliberate manual exception to their
    own average, not a re-estimate of it -- so it's a clobber, not a
    blend."""
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    liked_ids = [title_to_id[t] for t in liked_titles if t in title_to_id]
    disliked_ids = [title_to_id[t] for t in disliked_titles if t in title_to_id]
    missing = [t for t in liked_titles + disliked_titles if t not in title_to_id]
    if missing:
        print(f"WARNING: not found in catalog: {missing}")

    def matches_genre(bid):
        return genre is None or genre in (catalog[bid].get("genre") or [])

    if genre is not None:
        scoped_liked = [i for i in liked_ids if matches_genre(i)] or liked_ids
        scoped_disliked = [i for i in disliked_ids if matches_genre(i)] or disliked_ids
    else:
        scoped_liked, scoped_disliked = liked_ids, disliked_ids

    centroid, weights = build_profile(catalog, scoped_liked, scoped_disliked, liked_ids, disliked_ids)

    if fatigue_overrides:
        for key, val in fatigue_overrides.items():
            val = max(-1.0, min(1.0, val))
            if key in ORDINAL_FIELDS or key in NOMINAL_FIELDS:
                weights[key] = val
            else:
                weights.setdefault("tropes", {})[key] = val

    diversity = max(0.0, min(diversity, MAX_DIVERSITY))
    recent_books = [
        catalog[title_to_id[t]] for t in (recent_history or []) if t in title_to_id
    ]

    excluded = set(liked_ids) | set(disliked_ids)
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


if __name__ == "__main__":
    catalog = load_catalog()
    print(f"Loaded {len(catalog)} books.\n")

    liked = [
        "The Golden Compass", "The Lies of Locke Lamora", "The Eye of the World",
        "Kings of Paradise", "Prince of Thorns", "The Way of Kings",
    ]
    disliked = [
        "Bird Box", "Assassin's Apprentice", "We Are Legion (We Are Bob)",
        "Interview with the Vampire", "The Poppy War", "Circe",
        "Dark Matter", "He Who Fights with Monsters",
    ]

    print(f"Liked: {liked}")
    print(f"Disliked: {disliked}\n")
    results = recommend(catalog, liked, disliked, top_n=15)
    for score, title, author, contributions in results:
        print(f"{score:.3f}  {title} ({author})")
        print(f"       top factors: {contributions}")
