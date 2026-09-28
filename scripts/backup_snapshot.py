#!/usr/bin/env python3
"""Take a Bookspell database backup that keeps credentials and session secrets out.

Writes three files into ../bookspell-backups/dumps/ (nothing is committed):
  full-backup-<date>.sql   schema only              (supabase db dump --linked)
  data-backup-<date>.sql   public + storage data    (supabase db dump --linked --data-only --schema public,storage)
  auth-users-<date>.sql    auth.users + auth.identities, non-secret columns only

Why (2026-09-28): the old `--data-only` dump included the whole `auth` schema:
bcrypt password hashes, live `sessions`/`refresh_tokens`/`one_time_tokens`, MFA data
and the auth audit log. Every user table has an FK to `auth.users`, so auth can't
simply be dropped, or ratings etc. couldn't be restored. Instead the user rows are
kept without `encrypted_password` or any token column, and every other auth table
is omitted. A restored user signs in again with a magic link or password reset.

Restore order on a fresh project: full-backup, then auth-users, then data-backup
(with `--disable-triggers`, see the backups README).

The script refuses to finish if any output still contains a secret column or a
secret auth table. Run from the main repo root with the supabase CLI linked:
  python3 scripts/backup_snapshot.py [--date YYYY-MM-DD]
"""
import datetime
import json
import os
import re
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.normpath(os.path.join(REPO, "..", "bookspell-backups", "dumps"))

USER_COLS = [
    "instance_id", "id", "aud", "role", "email", "email_confirmed_at", "invited_at",
    "confirmation_sent_at", "recovery_sent_at", "email_change", "email_change_sent_at",
    "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin",
    "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change",
    "phone_change_sent_at", "email_change_confirm_status", "banned_until",
    "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous",
]
# Deliberately excluded from auth.users: encrypted_password, confirmation_token,
# recovery_token, email_change_token_new, email_change_token_current,
# phone_change_token, reauthentication_token, and the generated confirmed_at.
IDENTITY_COLS = ["provider_id", "user_id", "identity_data", "provider",
                 "last_sign_in_at", "created_at", "updated_at", "id"]  # `email` is generated
JSONB = {"raw_app_meta_data", "raw_user_meta_data", "identity_data"}

SECRET_PATTERNS = [
    r"encrypted_password", r"confirmation_token", r"recovery_token", r"email_change_token",
    r"phone_change_token", r"reauthentication_token",
    r'"auth"\."(sessions|refresh_tokens|one_time_tokens|mfa_[a-z_]+|audit_log_entries|flow_state)"',
    r"postgres(ql)?://[^\s'\"]*:[^\s'\"@]+@", r"\beyJ[A-Za-z0-9_-]{20,}\.",
]


def run(cmd):
    r = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f"FAILED: {' '.join(cmd)}\n{r.stderr[-2000:]}")
    return r.stdout


def query_rows(sql):
    out = run(["supabase", "db", "query", "--linked", "--output-format", "json", sql])
    doc = json.loads(out[out.index("{"):out.rindex("}") + 1])
    return doc["rows"]


def literal(v, col):
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, (dict, list)):
        v = json.dumps(v)
    s = "'" + str(v).replace("'", "''") + "'"
    return s + "::jsonb" if col in JSONB else s


def inserts(table, cols, rows, conflict):
    lines = []
    for r in rows:
        vals = ", ".join(literal(r.get(c), c) for c in cols)
        lines.append(f'INSERT INTO auth.{table} ({", ".join(cols)}) VALUES ({vals}) ON CONFLICT ({conflict}) DO NOTHING;')
    return lines


def main():
    date = sys.argv[sys.argv.index("--date") + 1] if "--date" in sys.argv else datetime.date.today().isoformat()
    os.makedirs(OUT, exist_ok=True)
    full = os.path.join(OUT, f"full-backup-{date}.sql")
    data = os.path.join(OUT, f"data-backup-{date}.sql")
    auth = os.path.join(OUT, f"auth-users-{date}.sql")
    for f in (full, data, auth):
        if os.path.exists(f):
            sys.exit(f"REFUSING to overwrite existing {f}")

    run(["supabase", "db", "dump", "--linked", "-f", full])
    run(["supabase", "db", "dump", "--linked", "--data-only", "--schema", "public,storage", "-f", data])

    users = query_rows(f"select {', '.join(USER_COLS)} from auth.users order by created_at")
    idents = query_rows(f"select {', '.join(IDENTITY_COLS)} from auth.identities order by created_at")
    body = ["-- auth.users / auth.identities, NON-SECRET columns only (scripts/backup_snapshot.py).",
            "-- No password hashes, no tokens, no sessions. Restore after the schema dump,",
            "-- before the data dump. Restored users sign in again via magic link or reset.",
            "BEGIN;"]
    body += inserts("users", USER_COLS, users, "id")
    body += inserts("identities", IDENTITY_COLS, idents, "id")
    body.append("COMMIT;")
    with open(auth, "w") as fh:
        fh.write("\n".join(body) + "\n")

    problems = []
    for f in (full, data, auth):
        text = open(f).read()
        if f == full:  # the schema dump legitimately defines these columns/tables
            continue
        for pat in SECRET_PATTERNS:
            if re.search(pat, text):
                problems.append(f"{os.path.basename(f)}: matches {pat}")
    if problems:
        for f in (full, data, auth):
            os.remove(f)
        sys.exit("ABORTED, secret material found; all three files deleted:\n  " + "\n  ".join(problems))

    print(f"OK {date}: {len(users)} users, {len(idents)} identities (non-secret columns only)")
    for f in (full, data, auth):
        print(f"  {os.path.getsize(f):>10,} bytes  {f}")
    print("Next: review, then commit/push in ../bookspell-backups, and log it in docs/project-log.md\n"
          "under a dated heading containing the phrase \"database backup\".")


if __name__ == "__main__":
    main()
