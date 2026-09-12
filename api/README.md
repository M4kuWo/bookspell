# Bookspell API

The only part of the v1 web app that genuinely needs live Python: calling
`scripts/recommend.py`'s scoring engine, and parsing an uploaded
Goodreads/Fable-exported CSV. Everything else (auth, catalog browse,
manual rating CRUD, filter-rule CRUD) is handled directly by the
frontend talking to Supabase — see
`~/.claude/plans/jaunty-chasing-eclipse.md` for the full architecture
and why this split was chosen, and `docs/project-log.md`'s 2026-09-12/13
"Bookspell v1 web app" entries for how it was built.

## Endpoints

- `GET /rule-targets` — no auth, the catalog's own valid "none of
  X"/"less of X" targets (mirrors `R.list_user_rule_targets()`).
- `GET /recommendations?genre=fantasy|sci_fi` (genre optional) — auth
  required (`Authorization: Bearer <supabase-jwt>`), returns this
  user's top-10 recommendations plus a human-readable why-summary per
  book.
- `POST /import/goodreads` — auth required, multipart file upload (a
  Goodreads library export CSV, or a Fable library exported via a
  third-party browser extension into that same format), upserts
  matched ratings for the caller.

## Local development

```bash
cd api
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres \
SUPABASE_JWKS_URL=https://yhvubjqstswxvctdikbc.supabase.co/auth/v1/.well-known/jwks.json \
.venv/bin/uvicorn main:app --reload
```

**`SUPABASE_JWKS_URL`**: verifies a caller's Supabase Auth JWT against
the hosted project's public signing key(s), fetched from this JWKS
endpoint and cached in-process (`PyJWKClient`, matched per-token by the
`kid` in the JWT header — this is what lets Supabase rotate signing
keys without breaking already-issued tokens). Confirmed 2026-09-13:
this project uses Supabase's newer asymmetric (ES256) signing keys, not
the legacy shared HS256 secret an earlier version of this doc assumed
as an unverified default — the JWKS URL is real, public, safe to use
here or in `.env`, and works identically for local dev and hosted (both
point at the same hosted Auth service; there's no separate "local"
JWKS since Auth itself only really exists on the hosted project).

## Deploying (Render, free tier)

1. Push this repo to GitHub (already done — Render deploys straight
   from a repo).
2. New Web Service on Render, pointed at this repo, root directory
   `api/`.
3. Build command: `pip install -r requirements.txt`. Start command:
   `uvicorn main:app --host 0.0.0.0 --port $PORT`.
4. Environment variables (Render dashboard, not committed anywhere):
   - `DATABASE_URL` — the **hosted** Supabase project's Postgres
     connection string (Dashboard → Project Settings → Database →
     Connection string). Never commit this — same rule as everywhere
     else in this project.
   - `SUPABASE_JWKS_URL` — see above. Not secret (it's a public-key
     endpoint by design), but keep it as an env var rather than
     hardcoded anyway, consistent with `DATABASE_URL`.
5. Free tier spins down after 15 min idle; the first request after
   that takes ~30-60s to wake up. The frontend needs a real "waking
   up..." loading state for this — an unexplained 30-60s hang on the
   first request of a session will otherwise read as broken. Flipping
   to Render's ~$7/mo tier removes this entirely if it becomes
   annoying at real usage — no code change needed either way.

## What's NOT here on purpose

Auth, catalog browse/search, manual rating add/edit/delete, and
filter-rule add/edit/delete are all direct `supabase-js` calls from the
frontend against Supabase's own REST API (RLS-scoped to the signed-in
user) — none of that needs this service at all. Keeping this service's
surface area to exactly the 3 endpoints above was a deliberate
architecture choice, not an oversight.
