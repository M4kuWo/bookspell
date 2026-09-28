#!/usr/bin/env python3
"""Apply CODX Task 25 lever A (+ sub-agent-scoped B) to the Bookspell repo.

A: move CLAUDE.md's six task-specific sections verbatim into docs/conventions/*.md,
   leaving each old heading as a forwarding pointer, and update the routing policy.
B: replace the stale-snapshot warning with a sub-agent-scoped disk re-read rule.
Also repoints the live references in skills, AGENTS.md, a workflow comment,
check_db_sync.py and book-dna-tables.md at the new files.

All-or-nothing: every precondition and replacement is checked in memory first;
nothing is written unless all of them pass. Run from the repo root.

  python3 apply_conventions_split.py --dry-run   # check + preview, writes nothing
  python3 apply_conventions_split.py             # apply
Undo:  git checkout -- . && rm -rf docs/conventions   (backup tag: pre-conventions-split)
"""
import os
import re
import shutil
import subprocess
import sys

REPO = "/Users/mathiaskurin/Documents/bookspell"
EVID = "docs/codx-reviews/context-load-improvements-2026-09-28-evidence"
BACKUP = os.path.join(os.path.dirname(os.path.abspath(__file__)), "CLAUDE.md.pre-conventions-split.bak")
DRY = "--dry-run" in sys.argv

os.chdir(REPO)


def die(msg):
    sys.exit(f"ABORTED, nothing written: {msg}")


def sub1(text, old, new, where):
    n = text.count(old)
    if n != 1:
        die(f"{where}: expected exactly 1 match, found {n}: {old[:70]!r}")
    return text.replace(old, new)


# --- Preconditions -----------------------------------------------------------
tagged = subprocess.run(["git", "show", "pre-conventions-split:CLAUDE.md"],
                        capture_output=True, text=True)
if tagged.returncode != 0:
    die("backup tag pre-conventions-split not found")
src = open("CLAUDE.md").read()
if src != tagged.stdout:
    die("CLAUDE.md differs from the pre-conventions-split tag; re-check before applying")

SECTIONS = [
    ("Database & migrations", "database"),
    ("Database backups", "backups"),
    ("Data quality / tagging", "tagging"),
    ("Catalog scope & series hierarchy", "catalog"),
    ("Recommendation engine (`scripts/recommend.py`)", "scoring"),
    ("v1 web app (`app/`, `api/`)", "web"),
]
HEADER = (
    "# {title}\n\n"
    "*Moved verbatim from `CLAUDE.md` on 2026-09-28 (CODX Task 25, lever A), so it is read\n"
    "only when a task needs it instead of being auto-loaded into every session. It is\n"
    "required reading, in full, whenever `CLAUDE.md`'s \"Startup reading and task routes\"\n"
    "table routes you here. Where this text says \"this file\", \"CLAUDE.md\" or points\n"
    "\"above\"/\"below\" outside this section, read it as referring to the whole\n"
    "convention set (`CLAUDE.md` plus `docs/conventions/`).*\n\n"
)

writes = {}  # path -> new content
new = src
for title, slug in SECTIONS:
    h = f"## {title}\n"
    i = new.index(h)
    j = new.index("\n## ", i + len(h)) + 1
    body = new[i:j]
    ref = open(f"{EVID}/moved-{slug}.md").read()
    if body.rstrip("\n") != ref.rstrip("\n"):
        die(f"section {title!r} doesn't match CODX's verified verbatim copy")
    content = body[len(h):]
    if slug == "tagging":
        content = sub1(content, 'it deleted — see "catalog scope" below).',
                       'it deleted — see "catalog scope" in `docs/conventions/catalog.md`).',
                       "tagging.md")
    writes[f"docs/conventions/{slug}.md"] = HEADER.format(title=title) + content.rstrip("\n") + "\n"
    fwd = (f"{h}\nMoved to [`docs/conventions/{slug}.md`](docs/conventions/{slug}.md)\n"
           f"(2026-09-28). **Required in full whenever the routing table above\n"
           f"routes you here** — it is not auto-loaded, so read the file.\n\n")
    new = new[:i] + fwd + new[j:]

# --- B: sub-agent-scoped freshness rule --------------------------------------
b_start = new.index("**If you're a sub-agent")
b_end = new.index("Read the startup policy below")
new = new[:b_start] + (
    "**If you're a sub-agent (launched by another Claude Code session),\n"
    "read `CLAUDE.md` from disk once before acting — don't rely on the copy\n"
    "in your system prompt.** That copy is a snapshot from when the parent\n"
    "session started, and has been confirmed stale repeatedly (12/12 test\n"
    "sub-agents on 2026-09-26) when this file changed during the parent's\n"
    "session. Comparing headings or `wc -w` against the snapshot is not a\n"
    "freshness check — an in-place wording edit passes both (demonstrated in\n"
    "CODX Task 25). The task-specific rules in `docs/conventions/` are never\n"
    "injected, so they are always read fresh; this re-read only concerns this\n"
    "(deliberately short) file. **A top-level session** loads this file from\n"
    "disk at startup and can use that copy — unless the file changes during\n"
    "the session (you edited it, or a `git pull`/merge touched it), in which\n"
    "case re-read it from disk before the next step that depends on it.\n\n"
) + new[b_end:]

# --- Routing policy + pointers in the universal sections ---------------------
C = "CLAUDE.md"
new = sub1(new, 'see the "Database\n& migrations" section below for the full incident history',
           'see\n`docs/conventions/database.md` for the full incident history', C)
new = sub1(new,
           "not just filenames or the task's label. Read every matching CLAUDE\n"
           "section in full and the external prerequisites below before acting.\n"
           "Combine routes for mixed work; reroute before expanding scope. If the\n"
           "scope is unclear, read all of CLAUDE.md and the schema core. Search may\n"
           "locate a required section, but does not replace reading its caveats.",
           "not just filenames or the task's label. Read every matching convention\n"
           "file in full and the external prerequisites below before acting.\n"
           "Combine routes for mixed work; reroute before expanding scope. If the\n"
           "scope is unclear, read all six `docs/conventions/` files and the schema\n"
           "core. Search may locate a required section, but does not replace reading\n"
           "its caveats.\n\n"
           "The six task-specific sections below the table are forwarding pointers\n"
           "to ordinary Markdown files in `docs/conventions/` (moved there 2026-09-28\n"
           "so they stop being auto-loaded into every session). Read the linked file\n"
           "in full for every matching route before acting. Do not auto-import those\n"
           "files (`@` imports) or move them into an automatically loaded rules\n"
           "directory — that would recreate the full-load cost this move removed.\n"
           "The old section headings remain as valid entry points, not substitutes\n"
           "for their targets.", C)
new = sub1(new,
           "applicability of any convention; all sections remain in this file.",
           "applicability of any convention; every section, including the ones\n"
           "moved to `docs/conventions/`, still applies.", C)
new = sub1(new, "| Trigger / task | Additional CLAUDE sections | External prerequisites |",
           "| Trigger / task | Additional convention files (see map below) | External prerequisites |", C)
new = sub1(new, "External schema names above live in `docs/schema/`;",
           "Convention file map: Database & migrations → `docs/conventions/database.md`;\n"
           "Database backups → `backups.md`; Data quality / tagging → `tagging.md`;\n"
           "Catalog scope & series hierarchy → `catalog.md`; Recommendation engine →\n"
           "`scoring.md`; v1 web app → `web.md` (all in `docs/conventions/`).\n"
           "External schema names above live in `docs/schema/`;", C)
new = sub1(new, "This doesn't relax any of the existing safety rules below (dependent-row",
           "This doesn't relax any of the existing safety rules (in\n"
           "`docs/conventions/database.md` and Safety / credentials below: dependent-row", C)
new = sub1(new, 'see this\nfile\'s "new public-catalog-style table" rule under "Database &\nmigrations" below)',
           'see the\n"new public-catalog-style table" rule in\n`docs/conventions/database.md`)', C)
writes["CLAUDE.md"] = new

# --- Live references elsewhere -----------------------------------------------
OTHER = [
    (".claude/skills/catalog-trope-gap-sweep/SKILL.md",
     'see CLAUDE.md\'s "Database & migrations" and "Data quality /\ntagging" sections)',
     'see `docs/conventions/database.md` and\n`docs/conventions/tagging.md`)'),
    (".claude/skills/tag-audiobook-editions/SKILL.md",
     'see CLAUDE.md\'s "Catalog scope"\nsection, same bar',
     'see\n`docs/conventions/catalog.md`, same bar'),
    (".claude/skills/tag-catalog-batch/SKILL.md",
     'standing CLAUDE.md rule ("Data quality / tagging")',
     'standing convention (`docs/conventions/tagging.md`)'),
    (".github/workflows/backup-reminder.yml",
     'CLAUDE.md\'s "Database backups" section)',
     '`docs/conventions/backups.md`)'),
    ("scripts/check_db_sync.py",
     "(see CLAUDE.md's Database & migrations section)",
     "(see docs/conventions/database.md)"),
    ("scripts/check_db_sync.py",
     "(CLAUDE.md's Database & migrations section)",
     "(docs/conventions/database.md)"),
    ("docs/schema/book-dna-tables.md",
     '(see CLAUDE.md\'s\n  "Data quality / tagging" section for the current field list)',
     '(see\n  `docs/conventions/tagging.md` for the current field list)'),
    ("AGENTS.md",
     'see CLAUDE.md\'s "Database &\nmigrations" section)',
     'see\n`docs/conventions/database.md`)'),
    ("AGENTS.md",
     "**every convention in `CLAUDE.md` applies to you\ntoo**",
     "**every convention in `CLAUDE.md` (and the\n`docs/conventions/` files its routing table points to) applies to you\ntoo**"),
]
for path, old, repl in OTHER:
    cur = writes.get(path) or open(path).read()
    writes[path] = sub1(cur, old, repl, path)

# --- Post-conditions (in memory) ---------------------------------------------
for title, slug in SECTIONS:
    body = writes[f"docs/conventions/{slug}.md"]
    if slug != "tagging" and body.split("\n\n", 2)[2].strip("\n") != \
            open(f"{EVID}/moved-{slug}.md").read().split("\n", 1)[1].strip("\n"):
        die(f"post-check: {slug}.md body is not verbatim")
    if f"docs/conventions/{slug}.md" not in writes["CLAUDE.md"]:
        die(f"post-check: CLAUDE.md has no pointer to {slug}.md")
for title, _ in SECTIONS:
    if f"## {title}\n" not in writes["CLAUDE.md"]:
        die(f"post-check: heading {title!r} missing from CLAUDE.md")

# --- Report / write ------------------------------------------------------------
print(f"CLAUDE.md words: {len(src.split())} -> {len(writes['CLAUDE.md'].split())}")
for p in sorted(writes):
    before = open(p).read() if os.path.exists(p) else ""
    print(f"  {'new ' if not before else 'edit'}  {p}  ({len(before.split())} -> {len(writes[p].split())} words)")
if DRY:
    print("DRY RUN: all checks passed, nothing written.")
    sys.exit(0)
shutil.copyfile("CLAUDE.md", BACKUP)
os.makedirs("docs/conventions", exist_ok=True)
for p, content in writes.items():
    with open(p, "w") as f:
        f.write(content)
print(f"APPLIED. Extra backup copy of the old CLAUDE.md: {BACKUP}")
print("Durable backup: git tag pre-conventions-split. Undo: git checkout -- . && rm -rf docs/conventions")
