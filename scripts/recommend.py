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
}
NA_VALUES = {"na", "none"}  # per-field "not applicable" sentinel, see above

NOMINAL_FIELDS = [
    "pov_count", "person", "narrator_reliability", "timeline", "form",
    "pace_shape", "drive", "narrative_closure", "emotional_resolution",
    "ends_on_cliffhanger", "magic_system_hardness", "scifi_hardness",
]

MULTI_FIELDS = ["tropes", "genre"]


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


def build_profile(catalog, liked_ids, disliked_ids):
    """Returns (centroid, weights) -- centroid is the target feature profile
    (liked books' average), weights say how much each feature matters for
    THIS user specifically."""
    liked = [catalog[i] for i in liked_ids if i in catalog]
    disliked = [catalog[i] for i in disliked_ids if i in catalog]

    centroid = {}
    weights = {}

    for field in ORDINAL_FIELDS:
        liked_raw = [x for x in (ordinal_position(field, b.get(field)) for b in liked) if x is not None]
        liked_vals = [p / m for p, m in liked_raw]
        disliked_raw = [x for x in (ordinal_position(field, b.get(field)) for b in disliked) if x is not None]
        disliked_vals = [p / m for p, m in disliked_raw]
        if not liked_vals:
            continue
        liked_mean = sum(liked_vals) / len(liked_vals)
        centroid[field] = liked_mean
        if disliked_vals:
            disliked_mean = sum(disliked_vals) / len(disliked_vals)
            weights[field] = abs(liked_mean - disliked_mean)
        else:
            # No disliked signal yet -- fall back to a modest default
            # weight rather than zero, so early users (few ratings) still
            # get a reasonable profile instead of an all-zero vector.
            weights[field] = 0.3

    for field in NOMINAL_FIELDS:
        liked_vals = [b.get(field) for b in liked if b.get(field)]
        if not liked_vals:
            continue
        # mode
        counts = {}
        for v in liked_vals:
            counts[v] = counts.get(v, 0) + 1
        mode_val = max(counts, key=counts.get)
        liked_share = counts[mode_val] / len(liked_vals)
        disliked_vals = [b.get(field) for b in disliked if b.get(field)]
        disliked_share = (
            sum(1 for v in disliked_vals if v == mode_val) / len(disliked_vals)
            if disliked_vals else 0.0
        )
        centroid[field] = mode_val
        weights[field] = max(0.0, liked_share - disliked_share) if disliked_vals else 0.3 * liked_share

    # Tropes: per-trope weight = how much more (or less) common it is in
    # liked books vs. disliked books. Negative weight = actively
    # penalize (the trope appears in disliked books, not liked ones).
    trope_weights = {}
    liked_trope_lists = [b.get("tropes") or [] for b in liked]
    disliked_trope_lists = [b.get("tropes") or [] for b in disliked]
    all_tropes = set(t for lst in liked_trope_lists + disliked_trope_lists for t in lst)
    for t in all_tropes:
        liked_freq = sum(1 for lst in liked_trope_lists if t in lst) / max(1, len(liked_trope_lists))
        disliked_freq = sum(1 for lst in disliked_trope_lists if t in lst) / max(1, len(disliked_trope_lists)) if disliked_trope_lists else 0.0
        trope_weights[t] = liked_freq - disliked_freq
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


def recommend(catalog, liked_titles, disliked_titles, top_n=10):
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    liked_ids = [title_to_id[t] for t in liked_titles if t in title_to_id]
    disliked_ids = [title_to_id[t] for t in disliked_titles if t in title_to_id]
    missing = [t for t in liked_titles + disliked_titles if t not in title_to_id]
    if missing:
        print(f"WARNING: not found in catalog: {missing}")

    centroid, weights = build_profile(catalog, liked_ids, disliked_ids)

    excluded = set(liked_ids) | set(disliked_ids)
    scored = []
    for bid, book in catalog.items():
        if bid in excluded:
            continue
        s, contributions = score_book(book, centroid, weights)
        scored.append((s, book["title"], book["author"], contributions))

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
