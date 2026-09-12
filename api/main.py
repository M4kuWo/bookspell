"""Bookspell v1 API -- the ONLY things that genuinely need live Python:
calling recommend.py's scoring engine, and parsing an uploaded
Goodreads/Fable-exported CSV. Everything else (auth, catalog browse,
manual rating CRUD, filter-rule CRUD) is handled directly by the
frontend talking to Supabase -- see the approved plan
(~/.claude/plans/jaunty-chasing-eclipse.md) for the full architecture
and why this split was chosen.

Run locally: `DATABASE_URL=... SUPABASE_JWKS_URL=... uvicorn main:app --reload`
(from inside api/). See api/README.md for hosted deployment (Render).
"""
import os
import sys
import tempfile

import jwt
import psycopg2
from fastapi import FastAPI, Header, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from jwt import PyJWKClient

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))
import recommend as R  # noqa: E402
from import_goodreads import fetch_isbns_by_book_id, import_goodreads_csv  # noqa: E402

from catalog_cache import get_catalog  # noqa: E402

# This project's hosted Supabase uses the newer asymmetric JWT signing
# keys (confirmed 2026-09-13 -- the project exposes a
# SUPABASE_JWKS_URL, which only exists under this model), not the
# legacy shared-secret HS256 scheme an earlier version of this file
# assumed as an unverified default. Verification here fetches
# Supabase's public signing key(s) from that JWKS endpoint (cached by
# PyJWKClient, matched per-token by the `kid` in the JWT header -- this
# is what lets Supabase rotate signing keys without breaking already-
# issued tokens) and checks the token's ES256 signature against it.
# Nothing here can forge a token: the private key never leaves
# Supabase, only its public counterpart is ever fetched.
SUPABASE_JWKS_URL = os.environ.get("SUPABASE_JWKS_URL")
if not SUPABASE_JWKS_URL:
    raise RuntimeError(
        "SUPABASE_JWKS_URL not set -- required to verify a caller's Supabase "
        "Auth JWT. Find it in the hosted project's dashboard: Project Settings "
        "-> API -> JWKS URL (looks like "
        "https://<project-ref>.supabase.co/auth/v1/.well-known/jwks.json)."
    )
_jwks_client = PyJWKClient(SUPABASE_JWKS_URL, cache_keys=True)

app = FastAPI(title="Bookspell API")

# The frontend is served from GitHub Pages (a different origin than
# wherever this API ends up hosted), so a real CORS allow-list is
# needed -- not just "same repo" the way the two existing static tools
# get away with (they call Supabase's REST API directly, no CORS
# preflight-sensitive custom backend involved).
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://m4kuwo.github.io"],
    allow_methods=["GET", "POST"],
    allow_headers=["Authorization", "Content-Type"],
)


def require_user_id(authorization: str = Header(default=None)) -> str:
    """Verifies the caller's Supabase Auth JWT (sent by supabase-js as a
    normal Bearer token once a user is signed in) and returns their
    user id (the JWT's `sub` claim, same value as auth.uid() inside
    Postgres RLS policies). Raises 401 for anything else -- no
    anonymous access to any endpoint that touches a specific user's
    ratings/rules."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")
    token = authorization[len("Bearer "):]
    try:
        signing_key = _jwks_client.get_signing_key_from_jwt(token)
        payload = jwt.decode(token, signing_key.key, algorithms=["ES256"], audience="authenticated")
    except jwt.InvalidTokenError as exc:
        raise HTTPException(status_code=401, detail=f"Invalid token: {exc}") from exc
    return payload["sub"]


def _db():
    return psycopg2.connect(R.DATABASE_URL)


def _load_user_ratings(user_id: str, catalog: dict) -> dict:
    """{title: rating_label} -- the raw shape recommend()/explain_match()
    expect, built by joining this user's `ratings` rows to `books.title`
    (recommend.py's own functions only know titles, not book_id/user_id
    -- see the plan's research pass on this)."""
    conn = _db()
    try:
        cur = conn.cursor()
        cur.execute(
            "select b.title, r.rating from ratings r join books b on b.id = r.book_id where r.user_id = %s",
            (user_id,),
        )
        return {title: rating for title, rating in cur.fetchall()}
    finally:
        conn.close()


def _load_user_rules(user_id: str) -> dict:
    """{"exclude": [...], "reduce": [{"key":..., "strength":...}, ...]}
    -- normalize_user_rules()'s expected RAW input shape (it does its
    own internal normalization; this just reconstructs the raw shape
    from the DB rows)."""
    conn = _db()
    try:
        cur = conn.cursor()
        cur.execute(
            "select rule_key, rule_type, strength from user_rules where user_id = %s",
            (user_id,),
        )
        rules = {"exclude": [], "reduce": []}
        for key, rule_type, strength in cur.fetchall():
            if rule_type == "exclude":
                rules["exclude"].append(key)
            else:
                rules["reduce"].append({"key": key, "strength": float(strength) if strength is not None else R.DEFAULT_REDUCE_STRENGTH})
        return rules
    finally:
        conn.close()


def _load_format_preference(user_id: str):
    conn = _db()
    try:
        cur = conn.cursor()
        cur.execute("select format_preference from profiles where id = %s", (user_id,))
        row = cur.fetchone()
        return row[0] if row else None
    finally:
        conn.close()


@app.get("/rule-targets")
def rule_targets():
    """Not user-specific -- just the catalog's own vocabulary of valid
    "none of X"/"less of X" targets, same data tools/dogfood/app.py's
    filter search box already uses. No auth needed, same trust level as
    the catalog tables anyone can already read via the anon key."""
    catalog = get_catalog()
    return R.list_user_rule_targets(catalog)


@app.get("/recommendations")
def recommendations(genre: str = None, authorization: str = Header(default=None)):
    user_id = require_user_id(authorization)
    catalog = get_catalog()
    ratings = _load_user_ratings(user_id, catalog)
    user_rules = _load_user_rules(user_id)
    format_preference = _load_format_preference(user_id)

    if genre not in (None, "fantasy", "sci_fi"):
        raise HTTPException(status_code=400, detail="genre must be 'fantasy', 'sci_fi', or omitted")

    results = R.recommend(
        catalog, ratings, top_n=10, genre=genre,
        user_rules=user_rules, format_preference=format_preference,
    )
    out = []
    for score, title, author, contributions in results:
        detail = R.explain_match(catalog, ratings, title, genre=genre, format_preference=format_preference)
        out.append({
            "title": title,
            "author": author,
            "score": round(score, 3),
            "match_label": detail["match_label"],
            "summary": detail["summary"],
            "mismatch_summary": detail["mismatch_summary"],
            "dealbreaker_summary": detail["dealbreaker_summary"],
            "series_note": detail["series_note"],
        })
    return {"results": out}


@app.post("/import/goodreads")
async def import_goodreads(file: UploadFile, authorization: str = Header(default=None)):
    """Parses an uploaded Goodreads library export CSV (or a Fable
    library exported via a third-party tool into the same
    Goodreads-compatible format -- no Fable-specific code needed) and
    upserts matched ratings for the calling user.

    Reuses scripts/import_goodreads.py's title/ISBN matching logic
    UNCHANGED -- see that file's own docstring for the exact matching
    rules. That file also notes it has NOT yet been run against a real
    Goodreads export (only a synthetic fixture) -- test this endpoint
    against a real export before trusting it for a real rater's data."""
    user_id = require_user_id(authorization)
    catalog = get_catalog()
    isbns_by_book_id = fetch_isbns_by_book_id()

    with tempfile.NamedTemporaryFile(mode="wb", suffix=".csv", delete=False) as tmp:
        tmp.write(await file.read())
        tmp_path = tmp.name
    try:
        ratings, rated_dates, reviews, matched_rows, unmatched_rows = import_goodreads_csv(
            tmp_path, catalog, isbns_by_book_id
        )
    finally:
        os.unlink(tmp_path)

    title_to_id = {b["title"]: bid for bid, b in catalog.items()}
    conn = _db()
    try:
        cur = conn.cursor()
        for title, label in ratings.items():
            book_id = title_to_id.get(title)
            if book_id is None:
                continue
            cur.execute(
                """
                insert into ratings (user_id, book_id, rating, rated_date, review, source)
                values (%s, %s, %s, %s, %s, 'goodreads_import')
                on conflict (user_id, book_id) do update
                  set rating = excluded.rating,
                      rated_date = coalesce(excluded.rated_date, ratings.rated_date),
                      review = coalesce(excluded.review, ratings.review),
                      source = 'goodreads_import',
                      updated_at = now()
                """,
                (user_id, book_id, label, rated_dates.get(title), reviews.get(title)),
            )
        conn.commit()
    finally:
        conn.close()

    return {
        "matched": len(ratings),
        "unmatched": [{"title": t, "author": a} for t, a, _avg in unmatched_rows],
    }
