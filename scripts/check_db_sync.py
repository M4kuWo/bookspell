#!/usr/bin/env python3
"""Quick local-vs-hosted row-count comparison for the tables tagging
batches touch most.

Exists because the same drift class recurred three times in three days
(2026-09-13, and twice on 2026-09-17): a tagging batch lands correctly
on hosted, but the corresponding local-apply step gets skipped, so
local Postgres silently falls behind -- see docs/project-log.md's
2026-09-17 "third occurrence" entry. Root cause: `.claude/skills/
tag-catalog-batch/SKILL.md` used to tell CLDA she didn't need a
separate local-apply step because "the repo owner's own local Postgres
will pick it up next time he re-syncs" -- false. `git pull` only
fetches the migration FILE; nothing executes it against local Postgres.
That responsibility now belongs explicitly to whoever next syncs with
local Postgres access (see CLAUDE.md's Database & migrations section),
backed by this script instead of relying on memory to catch it.

This is a heuristic, not a real migration-tracking mechanism: local's
own `supabase_migrations.schema_migrations` table is unreliable for
this purpose, since local applies happen via raw psycopg2 (per
CLAUDE.md's own documented convention), bypassing the Supabase CLI
entirely. A row-count mismatch means SOMETHING is missing locally; it
does NOT pinpoint which migration file, and a pure-UPDATE migration
with no net row-count change (e.g. a confidence/value correction) will
not be caught by this check at all -- it only catches inserts/deletes.

Usage:
    python3 scripts/check_db_sync.py

Needs local Postgres reachable at the default local URL (override with
LOCAL_DATABASE_URL) and the Supabase CLI linked to the hosted project
(`supabase link`) for the hosted-side counts.
"""
import json
import os
import subprocess
import sys
import tempfile

import psycopg2

LOCAL_URL = os.environ.get(
    "LOCAL_DATABASE_URL", "postgresql://postgres:postgres@127.0.0.1:54322/postgres"
)
TABLES = [
    "books",
    "book_dna",
    "book_tropes",
    "tropes",
    "content_warning_types",
    "audiobook_editions",
    "series",
    "universe",
]


def local_counts():
    conn = psycopg2.connect(LOCAL_URL)
    cur = conn.cursor()
    counts = {}
    for table in TABLES:
        cur.execute(f"select count(*) from {table}")
        counts[table] = cur.fetchone()[0]
    return counts


def hosted_counts():
    query = (
        "select "
        + ", ".join(f"(select count(*) from {t}) as {t}" for t in TABLES)
        + ";"
    )
    with tempfile.NamedTemporaryFile(
        "w", suffix=".sql", delete=False
    ) as f:
        f.write(query)
        sql_path = f.name
    try:
        result = subprocess.run(
            ["supabase", "db", "query", "--file", sql_path, "--linked"],
            capture_output=True,
            text=True,
            timeout=60,
        )
    finally:
        os.unlink(sql_path)
    if result.returncode != 0:
        print(
            "Could not query hosted (is `supabase link` set up?):\n"
            + (result.stderr or result.stdout),
            file=sys.stderr,
        )
        sys.exit(2)
    stdout = result.stdout
    start = stdout.find("{")
    end = stdout.rfind("}")
    if start == -1 or end == -1:
        print("Could not find JSON in hosted output:\n" + stdout, file=sys.stderr)
        sys.exit(2)
    try:
        payload = json.loads(stdout[start : end + 1])
    except json.JSONDecodeError as exc:
        print(f"Could not parse hosted output as JSON: {exc}\n{stdout}", file=sys.stderr)
        sys.exit(2)
    return payload["rows"][0]


def main():
    local = local_counts()
    hosted = hosted_counts()
    mismatch = False
    print(f"{'table':<25}{'local':>10}{'hosted':>10}  status")
    for table in TABLES:
        l, h = local[table], hosted[table]
        status = "OK" if l == h else "MISMATCH"
        if l != h:
            mismatch = True
        print(f"{table:<25}{l:>10}{h:>10}  {status}")
    if mismatch:
        print(
            "\nLocal does NOT match hosted. Find the migration file(s) whose "
            "effects are missing locally (check recent files under "
            "supabase/migrations/ by date) and apply them via the documented "
            "raw-psycopg2 method (CLAUDE.md's Database & migrations section) "
            "before trusting any local-only query result."
        )
        sys.exit(1)
    print("\nLocal matches hosted on all checked tables.")


if __name__ == "__main__":
    main()
