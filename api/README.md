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
SUPABASE_JWT_SECRET=<anything-locally, see below> \
.venv/bin/uvicorn main:app --reload
```

**`SUPABASE_JWT_SECRET`**: verifies a caller's Supabase Auth JWT. For
real (hosted) use this MUST be the hosted project's actual JWT secret
(Dashboard → Project Settings → API → JWT Secret) — a token signed by
Supabase Auth won't verify against any other value. For local smoke
testing without a real hosted login, any string works as long as you
sign your own test token with the same value (see
`docs/project-log.md`'s 2026-09-13 entry for the exact snippet used to
verify this locally before deploying).

**Caveat, not yet resolved**: this assumes the hosted project still
uses Supabase's legacy shared-secret (HS256) JWT model. If it's since
moved to the newer asymmetric JWT signing keys, this verification
approach needs replacing with a JWKS fetch instead — not yet checked
which mode this specific project is in.

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
   - `SUPABASE_JWT_SECRET` — see above.
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
