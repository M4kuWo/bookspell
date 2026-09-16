# Persona workflow: how tasks actually move between CLDO/CLDA/CODX

This is the single source of truth for the *mechanics* of cross-persona
handoff — who triggers whom, with what phrase, where a task is read
from, where output lands, and who reviews it. `CLAUDE.md`'s "Persona
system" section and `AGENTS.md` both point here instead of re-explaining
this, on purpose (duplicated mechanics drift out of sync and get
misremembered — this file exists specifically because that already
happened once, 2026-09-16: a session described CODX's task handoff as
"copy-paste a prompt between terminals," which is real but was
incorrectly generalized to CLDA too). If this file and either of those
two ever disagree about a mechanical detail, this file wins — fix the
other one to match, don't split the difference.

**There is no live channel between any of these sessions.** Not
CLDO<->CLDA, not CLDO<->CODX, not CLDA<->CODX. The repo owner is the one
who starts each session and tells it to sync; the repo itself (git
history, plus a couple of specific files) is the only thing carrying
information from one session to another. Keep that model in mind before
assuming any session "already knows" something that only happened in a
different session's conversation.

## The two trigger phrases (use these exact words)

- **CLDA**: *"Sync with the repo and get your next instructions."*
- **CODX**: *"Sync with the repo and start on your next task."*

CLDO doesn't have a trigger phrase — it's driven by live conversation
with the repo owner, not a sync-and-fetch model. CLDO's job in this
workflow is to keep the other two personas' input files stocked with a
concrete, ready-to-execute task *before* the repo owner triggers them —
not a vague backlog pointer they have to figure out cold.

## Per-persona: input (where a task is read from) and output (where work lands)

| | Reads its task from | Writes output to | Who reviews/lands it |
|---|---|---|---|
| **CLDA** | `docs/TODO.md` — the shared, cross-cutting backlog (also read by CLDO/CODX). She syncs, reads the project-log tail + TODO.md + relevant skills per `CLAUDE.md`'s standing instruction, then tells the repo owner what she'd work on next; he picks. | Commits/pushes directly — real migration files, `docs/project-log.md` entries (append-only), `docs/TODO.md` updates. She has real, if gated, write access (see `CLAUDE.md`'s "Cross-session destructive-action gate"). | No separate review step for routine batch work, per her established track record. CLDO reviews anything she flags in `docs/PENDING_APPROVALS.md`. |
| **CODX** | `docs/codx-tasks/current-task.md` — a single, always-current assignment, written by CLDO, **committed in the shared, tracked repo** (not CODX's own clone). An ordinary `git pull` gets it — no copy-pasted prompt text, same mechanism as CLDA's TODO.md now. | Its own clone's local, **untracked** `docs/codx-reports/<date>-<slug>.md` — CODX cannot commit or push, ever, so this file only exists on disk on this machine until CLDO copies it out. | CLDO reads the report directly from CODX's clone (same machine, same disk — a plain file read, not a git operation), independently re-verifies every claim, and — if it lands — copies the reviewed report into the shared, tracked `docs/codx-reviews/` (the permanent record) and applies the real change. |
| **CLDO** | Live conversation with the repo owner — not file-driven. | Commits/pushes directly, same as CLDA. Also writes/overwrites `docs/TODO.md` entries for CLDA and `docs/codx-tasks/current-task.md` for CODX when their next task is ready. | Reviews `docs/PENDING_APPROVALS.md` at the start of every sync; independently re-verifies every CODX proposal before applying it (never trusts a report at face value, regardless of how thorough it looks). |

## The one asymmetry to actually remember

**Input now works identically for CLDA and CODX**: both read their next
task from a file that lives in the shared, git-tracked repo, refreshed
by CLDO, picked up by an ordinary sync. Neither one requires the repo
owner to paste prompt text into a terminal anymore.

**Output is where they genuinely differ**, because of a real trust/access
difference, not a workflow inconsistency: CLDA can commit and push her
own work directly (real, gated write access, earned over time). CODX
cannot commit or push *at all*, by design (see `CLAUDE.md`'s persona
section and `AGENTS.md`'s "starting scope" section for why) — so its
output sits locally in its own clone until CLDO manually reads,
independently verifies, and copies it into the tracked record. That
manual copy step is a deliberate control, not a gap to "fix" by giving
CODX push access.

## Keeping `docs/codx-tasks/current-task.md` current

This file always holds exactly one task: the one CODX should work on
right now. When CLDO lands a finished CODX proposal, the next action is
to overwrite this file with the next task (or leave a short "nothing
queued right now, check back after \<X\>" note if there genuinely isn't
one yet) — don't leave a stale, already-completed task sitting here for
the repo owner to trigger CODX against by accident. The file's own git
history is the record of what's been assigned over time; the file itself
only needs to reflect the current, live assignment.

A task written here should be self-contained the way a fresh AGENTS.md
read would need it to be — exact commit/baseline to sync to, exact scope
boundaries (what's decided vs. what CODX is building/validating), exact
validation bar, and where to write the report. CODX has no memory of the
conversation that produced the task; the file is all it gets.
