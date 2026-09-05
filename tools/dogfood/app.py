"""Minimal internal dogfooding tool for the Bookspell recommendation
engine -- NOT the real product UI (see README.md in this directory for
why). Lets a real person interact with scripts/recommend.py directly:
pick/edit a rater's ratings, build "none of X"/"less of X" rules
against a search box, and see live recommendations with a per-book
explanation, without anyone hand-running Python in a terminal.

Run: tools/dogfood/.venv/bin/streamlit run tools/dogfood/app.py
"""
import json
import os
import sys

import streamlit as st

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "scripts"))
import recommend as R

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "data", "ratings")

st.set_page_config(page_title="Bookspell dogfood", layout="wide")


@st.cache_resource
def load_catalog():
    return R.load_catalog()


@st.cache_resource
def load_rule_targets(_catalog):
    return R.list_user_rule_targets(_catalog)


def list_raters():
    return sorted(
        f[:-5] for f in os.listdir(DATA_DIR)
        if f.endswith(".json") and f != "README.md"
    )


def load_rater_data(name):
    with open(os.path.join(DATA_DIR, f"{name}.json")) as f:
        return json.load(f)


def save_rater_data(name, data):
    with open(os.path.join(DATA_DIR, f"{name}.json"), "w") as f:
        json.dump(data, f, indent=2)


catalog = load_catalog()
all_titles = sorted(b["title"] for b in catalog.values())

st.title("Bookspell dogfood tool")
st.caption("Internal only -- not the real product UI. See tools/dogfood/README.md.")

# --- Rater picker ---------------------------------------------------------
raters = list_raters()
rater_name = st.sidebar.selectbox("Rater", raters, index=raters.index("mathias") if "mathias" in raters else 0)
rater_data = load_rater_data(rater_name)
ratings = rater_data["ratings"]

st.sidebar.metric("Ratings on file", len(ratings))

# --- Add/fix a rating (the exact gap-catching workflow from tonight) -----
with st.sidebar.expander("Add or fix a rating"):
    title_pick = st.selectbox("Book", [""] + all_titles, key="rating_title")
    label_pick = st.selectbox("Rating", [""] + list(R.RATING_LABELS.keys()), key="rating_label")
    if st.button("Save rating") and title_pick and label_pick:
        ratings[title_pick] = label_pick
        save_rater_data(rater_name, rater_data)
        st.success(f"{title_pick}: {label_pick}")
        st.cache_resource.clear()

# --- Rule builder ----------------------------------------------------------
st.sidebar.header("Rules: none of X / less of X")

if "rules" not in st.session_state:
    st.session_state.rules = {"exclude": [], "reduce": []}

targets = load_rule_targets(catalog)
target_labels = {f"{t['label']}  ({t['key']})": t["key"] for t in targets}

search = st.sidebar.text_input("Search (trope or field value)", placeholder="e.g. ya, romance, slow burn")
filtered = [label for label in target_labels if search.lower() in label.lower()] if search else []
if search and not filtered:
    st.sidebar.caption("No matches.")
picked_label = st.sidebar.selectbox("Match", filtered) if filtered else None

advanced = st.sidebar.toggle("Advanced (custom strength)", value=False)

col1, col2 = st.sidebar.columns(2)
if picked_label:
    key = target_labels[picked_label]
    if col1.button("None of this"):
        if key not in st.session_state.rules["exclude"]:
            st.session_state.rules["exclude"].append(key)
    if advanced:
        strength = st.sidebar.slider("Strength", 0.0, 1.0, R.DEFAULT_REDUCE_STRENGTH, 0.05)
    else:
        strength = R.DEFAULT_REDUCE_STRENGTH
    if col2.button("Less of this"):
        st.session_state.rules["reduce"] = [
            r for r in st.session_state.rules["reduce"] if r["key"] != key
        ] + [{"key": key, "strength": strength}]

if st.session_state.rules["exclude"] or st.session_state.rules["reduce"]:
    st.sidebar.write("**Active rules:**")
    for k in list(st.session_state.rules["exclude"]):
        c1, c2 = st.sidebar.columns([4, 1])
        c1.caption(f"None of: {k}")
        if c2.button("x", key=f"rm_ex_{k}"):
            st.session_state.rules["exclude"].remove(k)
    for r in list(st.session_state.rules["reduce"]):
        c1, c2 = st.sidebar.columns([4, 1])
        c1.caption(f"Less of: {r['key']} ({r['strength']:.2f})")
        if c2.button("x", key=f"rm_re_{r['key']}"):
            st.session_state.rules["reduce"].remove(r)

if st.sidebar.button("Reset all rules"):
    st.session_state.rules = {"exclude": [], "reduce": []}

# --- Recommendations --------------------------------------------------------
genre = st.selectbox("Genre", ["fantasy", "sci_fi"])
top_n = st.slider("How many", 5, 30, 20)

if st.button("Get recommendations", type="primary"):
    recs = R.recommend(catalog, ratings, top_n=top_n, genre=genre, user_rules=st.session_state.rules)
    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    id_to_magnitude = {title_to_id[t]: R.RATING_LABELS[l] for t, l in ratings.items() if t in title_to_id}
    centroid, weights = R.build_profile(catalog, id_to_magnitude)
    poor_threshold = R.user_calibrated_poor_threshold(catalog, id_to_magnitude, centroid, weights)

    for i, (score, title, author, contributions) in enumerate(recs, 1):
        label = R.match_label(score, poor_threshold)
        with st.expander(f"{i}. {title} -- {author} -- {score:.3f} ({label})"):
            audit = R.audit_book_score(catalog, ratings, title, genre=genre, user_rules=st.session_state.rules)
            st.write("**Pipeline:**")
            st.table(audit["pipeline"])
            st.write("**Top matches (pulled score up):**")
            for m in audit["matches"][:5]:
                st.write(f"- {m['field']}: +{m['contribution']}")
            st.write("**Top mismatches (pulled score down):**")
            for m in audit["mismatches"][:5]:
                st.write(f"- {m['field']}: {m['contribution']}")
