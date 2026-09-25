"""Constants components of the recommendation engine."""

import os

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
    "romance_tone", "worldbuilding_delivery",
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
#
# romance_tone/worldbuilding_delivery (2026-09-11, added alongside their
# conversion from trope pairs to scalar fields -- see
# convert-romance-worldbuilding-fields skill): `mixed` clears the same
# bar drive's `balanced` did -- explicit backing, not a guess. It's
# defined (see that migration's own comment) as "real evidence found on
# both sides" during tagging, a genuine midpoint by construction, so it
# gets partial credit against BOTH poles of its own pair, same shape as
# balanced/character_driven/plot_driven.
NOMINAL_PARTIAL_SIMILARITY = {
    "person": {
        frozenset({"third_limited", "third_omniscient"}): 0.5,
    },
    "drive": {
        frozenset({"character_driven", "balanced"}): 0.5,
        frozenset({"plot_driven", "balanced"}): 0.5,
    },
    "romance_tone": {
        frozenset({"understated", "mixed"}): 0.5,
        frozenset({"melodramatic", "mixed"}): 0.5,
    },
    "worldbuilding_delivery": {
        frozenset({"woven", "mixed"}): 0.5,
        frozenset({"exposition_dump", "mixed"}): 0.5,
    },
}


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

# Pseudo-count for TROPE_SHRINKAGE (see build_profile_trope_shrinkage(),
# EXPERIMENTAL, not wired into production) -- at n=TROPE_SHRINKAGE_K
# distinct liked+disliked books carrying a trope, its raw weight is
# halved; the discount vanishes as n grows past it. 5 chosen as a
# starting point (2026-09-06): small enough that well-evidenced tropes
# (10+ books) are barely touched, large enough to meaningfully discount
# the specific thin cases that motivated this (hidden_talent_prodigy:
# n=3, zero disliked counter-evidence) -- see
# docs/scoring-test-protocol.md's 2026-09-06 entry for the A/B numbers.
TROPE_SHRINKAGE_K = 5

# Hard ceiling on the `diversity` param (see recommend()) -- enforced in
# code, not just a UI convention. At diversity=1.0 (pure novelty, zero
# regard for relevance) a "summon something different" request could
# surface the diametrical opposite of a user's taste (a cozy romantasy
# YA for a grimdark reader) purely because it's unlike their recent
# history. Keeping diversity's contribution below MAX_DIVERSITY means
# the relevance term never gets crowded out entirely, so a book that
# doesn't match the user's taste at all stays capped low regardless of
# how novel it is -- see book-dna-decisions.md's 2026-08-29 refinement
# note (moved out of book-dna.md during the 2026-09-25 schema split).
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


DEFAULT_POOR_THRESHOLD = 0.35
GOOD_MATCH_THRESHOLD = 0.55
STRONG_MATCH_THRESHOLD = 0.75


# Fields describing HOW a story is told (lead into a "told with ..."
# clause) vs. everything else -- tone/content fields and tropes -- which
# read naturally as a "features/also has ..." list. This split is what
# turns a flat phrase list into an actual sentence; see natural_sentence().
NARRATIVE_STYLE_FIELDS = {"person", "pov_count", "timeline", "narrator_reliability", "form"}


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


# Below this, a tagged value is treated as too little evidence to
# influence scoring/weight-learning AT ALL -- added 2026-09-05,
# repo owner's own request while planning the execution-DNA rollout.
# Distinct from ordinary confidence discounting (which still lets a
# 0.5-confidence tag contribute half-strength): a value this uncertain
# shouldn't contribute even a token amount, since a string of many
# barely-above-zero contributions could still add up to something
# misleadingly influential. The row is NOT deleted or hidden -- see
# scoring_confidence() below -- so real validation later (raising the
# recorded confidence above this floor) makes it start counting
# automatically, no re-tagging needed. Checked against existing data
# before picking 0.3: no currently-recorded confidence value in the
# catalog sits at or below this floor (lowest existing entries are
# 0.4), so this doesn't retroactively invalidate any already-accepted
# tagging work -- it only matters for future low-confidence tags
# (e.g. a research pass that turns up little to no real discourse for
# a specific book).
MIN_CONFIDENCE_TO_COUNT = 0.3


TROPE_BACKOFF_K = 5


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


# --- Candidate-pool prevalence discount (2026-09-06, LANDED) -----------
# Motivated by a friend's review (relayed by the repo owner) of a
# Recommendation Ledger run: a field can be a genuine, non-spurious
# preference (real liked-vs-disliked separation in the RATED pool)
# while still doing little to RANK one candidate above another, if most
# of the CANDIDATE pool already shares the matching value -- e.g.
# emotional_resolution: bittersweet is a real, broad, well-evidenced
# preference (see docs/scoring-test-protocol.md's 2026-09-06 entries),
# but matches ~53% of the whole catalog, so agreeing on it barely
# discriminates two candidates that both have it. This is a DIFFERENT
# axis from build_profile_trope_shrinkage() below (which discounts a
# WEIGHT for being built on too little RATED evidence) -- this discounts
# a SCORING CONTRIBUTION for the matching VALUE being too common in the
# CANDIDATE pool being ranked, regardless of how well-evidenced the
# underlying preference is. Deliberately linear (1 - prevalence), not
# log-IDF -- with prevalences observed so far topping out around 53%, a
# log curve would barely differ from linear in the range that matters;
# simpler is better until real data says otherwise.
# PREVALENCE_DISCOUNT_FLOOR keeps even a near-universal value from being
# discounted to zero. Full validation (8-row scorecard, all 4 real
# raters, every regression traced to a specific book) in
# docs/scoring-test-protocol.md before this landed -- see score_book()'s
# own docstring for the numbers.
PREVALENCE_DISCOUNT_FLOOR = 0.1


# Minimum rated-book count a user needs on the MINORITY side of a
# NOMINAL_PARTIAL_SIMILARITY pair (e.g. person's third_limited/
# third_omniscient, already given 0.5 partial credit at scoring time --
# see nominal_similarity()) before build_prevalence_lookup_grouped()
# trusts that this user has a real, distinct reaction to that value
# worth keeping separate for prevalence purposes. Below this, the pair
# is folded into one combined prevalence figure instead. Same spirit
# and rough magnitude as MIN_DEALBREAKER_SAMPLE (3) -- checked directly
# for Mathias (2026-09-06): only 2 of his rated books are
# third_omniscient (1 loved, 1 disliked) vs. 93 third_limited, nowhere
# near enough to distinguish a real omniscient-specific reaction from
# noise, so grouping is correct for him specifically -- this constant
# is what makes that a per-user check, not a blanket assumption.
MIN_PREVALENCE_GROUP_SAMPLE = 5


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
#
# Permutation-based adaptive threshold: TRIED, REVERTED (2026-09-05).
# `person`'s separation had drifted to 0.412 as the rated pool grew,
# silently disabling the veto for Mathias's whole profile (see the
# 10-hypothesis review, #10) -- replaced this fixed constant with a
# permutation significance test (Bonferroni-corrected per candidate
# count) to adapt to pool size instead of going stale. `person` came
# back genuinely, robustly significant (p=0.001, not a marginal call)
# -- but reactivating its veto cost one real held-out book (Old Man's
# War, true=liked, a genuine individual exception to an otherwise-real
# pattern) with no compensating catch anywhere else, netting bucket
# accuracy 91%->82% and loved_recall 100%->80% on Mathias-full with no
# improvement on any other scenario. A statistically well-founded
# mechanism, working as designed -- but the honest empirical verdict on
# the one real benchmark available is a net regression, not a win, so
# reverted in full per this project's "if it doesn't help, dismiss"
# standard. Full numbers in docs/scoring-test-protocol.md. Revisit if a
# second rater's data ever gives an independent read on whether this
# trade is worth it on average, not just for Mathias.
STAT_SEPARATION_THRESHOLD = 0.65

# Once a field IS statistically validated for this user, a mismatch on
# it only needs to clear this much LOWER bar to be flagged -- we already
# have real evidence the field matters to them, so we trust a smaller
# mismatch on it more than an unvalidated field's. 0.15 sits just above
# explain_book()'s own noise floor (0.1, the cutoff for appearing in
# `mismatches` at all).
VALIDATED_DEALBREAKER_MAGNITUDE = 0.15


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


# --- Series-trajectory penalty (2026-09-04, EXPERIMENTAL -- UNDER TEST, --
# NOT wired into recommend()/explain_match() yet) -----------------------
# Repo owner's own proposal, after the Warded Man/The Pariah discussion:
# a series entry point that scores well now but whose SAME strong-
# matching fields trend AWAY from this reader's profile by the series'
# end shouldn't score as confidently as it currently does -- recommend
# ing something that gets worse (loved books 1-3, the finale "ruined
# the series") is a real harm distinct from recommending something that
# builds slowly toward a payoff (The Pariah). Deliberately NEGATIVE-ONLY
# -- mirrors _apply_series_repeat's shape but never boosts a score, only
# ever caps it down, avoiding the opposite failure mode (inflating a
# weak-looking opener because the series supposedly gets better --
# "undersells itself" is its own kind of bad recommendation, see the
# earlier positive-floor experiment's finding that a floor can't safely
# reorder things upward).
#
# Deliberate exclusion, per the repo owner's own caveat: skipped
# entirely when the candidate's OWN narrative_closure is
# 'self_contained' -- The Lies of Locke Lamora and the Dresden Files'
# early entries deliver a complete, satisfying experience regardless of
# what a later, loosely-connected sequel does; penalizing them for a
# future book's drift would make it impossible to ever recommend a
# genuinely great standalone-feeling entry point, exactly the failure
# mode flagged. `requires_series` books (The Warded Man) remain subject
# to the penalty.
SERIES_TRAJECTORY_DIVERGENCE_THRESHOLD = 0.15
SERIES_TRAJECTORY_MAX_PENALTY = 0.3


# Veto/cap ceiling: just under GOOD_MATCH_THRESHOLD, so a vetoed book can
# never read as "Good match" or "Strong match" no matter how far above
# this its raw weighted-average score sits. Deliberately NOT capped down
# to "Poor match" -- see _apply_dealbreaker_veto()'s docstring for why a
# validated dealbreaker means "don't confidently recommend this," not
# "this is certainly a bad match."
DEALBREAKER_VETO_CAP = GOOD_MATCH_THRESHOLD - 0.001


# EXPERIMENTAL (2026-09-07, prototyped alongside _apply_dealbreaker_veto,
# NOT wired into recommend()/explain_match()/audit_book_score() -- see
# docs/scoring-test-protocol.md's 2026-09-07 entry before landing this).
#
# Motivated by the exact gap the 2026-09-05 adaptive-threshold experiment
# hit and reverted over (see STAT_SEPARATION_THRESHOLD's docstring): once
# `person` validates, Mathias's genuine exceptions (Old Man's War, and --
# discovered during the 2026-09-06 series-dedup investigation -- Red
# Sister) got the SAME flat cap as his clearest dealbreaker cases (Royal
# Assassin, Interview with the Vampire), because the flat veto has no
# notion of "how much other evidence backs this book despite the flag."
#
# A live check (2026-09-07) of exactly this ruled out the first idea
# tried -- scaling the cap by the FLAGGED FIELD's own mismatch magnitude
# -- as a dead end: for a NOMINAL field, that magnitude is a function of
# (book's value, centroid's value, learned weight) only, so it's IDENTICAL
# across every candidate sharing the same value pair. Confirmed directly:
# Red Sister, Royal Assassin, Assassin's Apprentice, Interview with the
# Vampire, and Circe all show person_mismatch == 0.1688 against the same
# profile, despite wildly different raw scores (0.474, 0.342, 0.265,
# 0.224, 0.461) and wildly different real outcomes (loved vs. hated).
# Per-candidate field-magnitude graduation cannot distinguish them.
#
# What DOES vary per candidate is the raw score itself -- i.e. how much
# OTHER evidence this specific book has going for it. So this version
# graduates the PULL toward the cap (not the cap itself) by two things:
# how far the raw score sits above the cap (a book already near/below the
# cap is untouched, same as the flat version), and separately, how
# SEVERE the strongest flagged mismatch is in absolute terms (comparing
# ACROSS different possible dealbreaker fields, where magnitude does
# carry real information -- a near-floor 0.15 mismatch is trusted less
# than one nearing WEIGHT_CAP). A borderline-severity flag pulls the
# score only halfway to the cap; a max-severity flag pulls it all the
# way, reproducing the flat version's behavior exactly at that extreme.
DEALBREAKER_VETO_PULL_FLOOR = 0.5
DEALBREAKER_VETO_SEVERITY_SPAN = WEIGHT_CAP - VALIDATED_DEALBREAKER_MAGNITUDE


# --- User-adjustable rules (manual, opt-in) -----------------------------
# "None of X" / "less of X" -- added 2026-09-05, repo owner's own explicit
# request: some real preferences (his own examples -- avoiding melodrama,
# responding less positively to YA) structurally can NEVER show up in a
# rated history, because an avoidant reader doesn't read the thing they'd
# dislike in the first place. No amount of more ratings fixes that; an
# explicit channel is the only way that signal can ever reach the engine.
#
# Deliberately a SEPARATE, simpler mechanism from fatigue_overrides
# (the existing post-read/DNF "why didn't it work" feature) rather than
# reusing it -- fatigue_overrides clobbers a LEARNED weight and then
# still interacts with the centroid/similarity machinery (useful for its
# own purpose: "this field usually matters to you, but discount it here").
# A standing "never/less show me X" preference wants a flatter, easier-
# to-reason-about guarantee: does this candidate book carry X, yes or
# no -- independent of the user's learned profile entirely. Implemented
# as pure post-processing on an already-computed score, the same
# architectural slot as _apply_dealbreaker_veto/_apply_series_trajectory_penalty
# above -- it NEVER touches build_profile()/score_book()'s core weighted
# average, so a user with no rules set is byte-identical to today, and
# this carries none of the regression risk the automatic per-value
# nominal weight-LEARNING experiment did (tried and reverted twice the
# same day, see docs/scoring-test-protocol.md) -- that was about
# automatically inferring weights for everyone from ratings data; this is
# an explicit, per-user, opt-in override that changes nothing for anyone
# who doesn't set it.

# "less of" default strength when a caller/UI doesn't pick a specific
# number (a "simple mode" flow) -- "advanced mode" can pass any value in
# [0.0, 1.0]. 0.6 is a strong-but-not-absolute discount, deliberately
# short of 1.0 (a full multiplicative zero-out) -- that's what "exclude"
# is for; "reduce" should still let an otherwise-exceptional match
# through discounted, not erase it.
DEFAULT_REDUCE_STRENGTH = 0.6


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


# Cheap, durable record of real dislike/DNF reasons for later qualitative
# analysis -- there's no real per-user feedback table yet (no `users`
# table exists at all), so this is deliberately NOT per-user state, just
# an append-only log of real reasons as they come in, to build up a
# corpus of "why don't people like this book" worth mining later (e.g.
# for the confidence layer's triage use case, or just to sanity-check
# whether book_feedback_options()'s structured selections are capturing
# what people actually mean).
FEEDBACK_LOG_PATH = os.environ.get(
    "FEEDBACK_LOG_PATH", os.path.join(os.path.dirname(os.path.dirname(__file__)), "feedback_log.jsonl")
)


# --- Deep score audit -- INTERNAL/DEBUG TOOL, not part of the -----------
# production scoring path (2026-09-04). recommend()/explain_match() never
# call this. Built for manually analyzing a specific candidate's score
# against a specific profile in full detail: which specific liked/
# disliked training books drove each field/trope, what penalties/bonuses/
# interactions fired, and the exact pipeline that produced the final
# 0-1 score -- a superset of what explain_match() surfaces (which only
# shows aggregate field-level matches/mismatches, never traces back to
# individual training books).
#
# Attribution shape differs by field type, because the underlying
# statistic does:
# - NOMINAL fields/tropes: the centroid is a MODE/frequency-share, so a
#   specific training book either does or doesn't share the relevant
#   value -- individual books are directly nameable ("liked_supporting"/
#   "disliked_undercutting" below).
# - ORDINAL fields: the centroid is a continuous weighted MEAN position,
#   so no single training book "caused" it in a discrete sense -- reported
#   as a summary (mean position, n, magnitude-weighted) rather than a
#   book list, to avoid a misleading implication of discrete attribution
#   that doesn't match the actual math.
AUDIT_CONTRIBUTION_THRESHOLD = 0.1  # same magnitude floor explain_book() uses
AUDIT_BOOK_LIST_CAP = 8  # truncate long per-value book lists, note the overflow count

