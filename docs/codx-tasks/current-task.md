# CODX current task

**Assigned**: 2026-09-25, by CLDO.
**Status**: ready to start.

See `docs/persona-workflow.md` if you haven't read it yet. Report to
`docs/codx-reports/<date>-<slug>.md` in your own clone as always.

**Note**: this REPLACES the previously-queued Task 20 (HIGH_RISK_FIELDS
confidence QA, round 3) at the repo owner's explicit request -- Task 20
is not cancelled, just deferred one slot. It'll be reassigned once this
one lands. If you already started Task 20 before pulling this file,
stop and finish this one first; Task 20's assignment is still intact
in git history (commit `1448192`) and will come back unchanged.

---

## Task 21 — review + ideate: fresh-session context/documentation load is growing unbounded

This is a review-and-brainstorm task, not a code/data task. Deliverable
is a written report with your assessment and proposals -- no file
changes, no migrations, no commits, same proposal-only posture as
every other task, just applied to documentation/process instead of
code or catalog data.

### The problem, with real numbers (measured 2026-09-25)

Every fresh Claude Code session in this repo (CLDO or CLDA) is
instructed by `CLAUDE.md` to read several files before doing anything
else. Measured sizes of what that actually costs, in round numbers
(~1.3 tokens/word as a rough proxy):

| File | Size | How CLAUDE.md says to read it |
|---|---|---|
| `CLAUDE.md` itself | ~6,900 words (~9k tokens) | Always, in full, automatically (it's the system prompt) |
| `docs/TODO.md` | ~4,400 words (~5.7k tokens) | Always, in full |
| `docs/schema/book-dna.md` | **~19,600 words (~25k tokens)** | Always, in full |
| `docs/project-log.md` | ~185,000 words total, ~22,000 lines | "The tail" -- CLAUDE.md's actual phrase, no defined bound |
| `docs/scoring-test-protocol.md` | ~30,800 words (~40k tokens) | Conditional -- only "before changing any scoring logic," correctly scoped already, not part of the fixed tax |

So the **mandatory fixed tax before any real work starts** is
conservatively 40k+ tokens (CLAUDE.md + TODO.md + book-dna.md, plus
whatever "the tail" of project-log.md ends up meaning that session --
which is itself the biggest source of variance, since nothing defines
how far back "the tail" goes). `book-dna.md` alone is larger than
CLAUDE.md. This has already happened once before, concretely:
`docs/TODO.md` itself ballooned to 4,408 lines of inline narrative
before a full rewrite brought it down to its current ~123 lines (see
`docs/project-log.md`'s 2026-09-22 TODO.md-rewrite entry, and
CLAUDE.md's own "Logging" section, which now has an explicit rule
against this recurring) -- the same failure mode is now visibly
recurring in `book-dna.md` and, more diffusely, in `project-log.md`'s
unbounded growth.

**Explicitly not on the table**: logging less, or losing any existing
detail. The repo owner was clear he wants this project's thorough
documentation habit to continue -- the problem is *retrieval/loading
efficiency* for a fresh session, not documentation discipline itself.

### CLDO's own proposal so far (not yet implemented -- review this critically, don't just rubber-stamp it)

1. **Split `docs/schema/book-dna.md` into a core file (field/trope
   vocabulary + definitions -- what every tagging/scoring session
   actually needs) and a separate backlog/rationale file (the "Future
   fields backlog" section and narrative design-rationale entries --
   needed only when someone's actually proposing a new field).**
   Update CLAUDE.md's "always read" instruction to point at the
   smaller core file only. Same fix pattern TODO.md already got, same
   reasoning, zero content lost -- pure reorganization.
2. **Give `project-log.md` a compact chronological index** -- one line
   per dated entry (date + title/one-line hook), not the full entries.
   A fresh session skims the index (probably a few hundred lines, not
   22,000) to find what's relevant, then jumps or greps to the actual
   dated entry instead of reading an undefined "tail" or scanning
   linearly. Open question even within this proposal: does the index
   live at the top of the same file, or as its own separate file
   (`docs/project-log-index.md`)? Either has tradeoffs (single-file
   keeps it in one place but makes the file itself even bigger to open;
   separate file needs its own maintenance discipline to stay in sync).
3. **Formalize "grep/search over full linear reads" as an explicit
   CLAUDE.md convention** for anything beyond the mandatory core files
   -- already informal practice, but not written down anywhere,
   meaning CLDA/you don't necessarily know to do it the same way.

### What to actually do

1. **Critically review proposals 1-3 above.** Where are they weak,
   incomplete, or likely to cause a NEW problem (e.g., does splitting
   book-dna.md risk someone editing the core file without realizing a
   related rationale entry now lives elsewhere and needs updating too;
   does a project-log index risk drifting out of sync with the real
   log the way TODO.md itself drifted before)? Say plainly if you think
   any of the three isn't worth doing.
2. **Independently brainstorm your own ideas**, not just react to
   CLDO's. You're a different model/tool with a different context
   window and different retrieval behavior (you already read hosted
   data over HTTP rather than a live DB connection for most of your
   work, and your own task handoff is itself file-based/asynchronous --
   you may have a genuinely different perspective on what "efficient
   for a fresh session to load" actually means in practice). Feel free
   to research how other real, long-running documentation-heavy
   projects or tools handle this class of problem (changelogs,
   architecture decision records, RAG-style indexing, etc.) if useful,
   but ground any borrowed idea in THIS repo's real constraints: multi-
   persona (CLDO/CLDA/you, each a genuinely different tool/session with
   no live channel between them), append-only history requirement
   (nothing gets deleted or rewritten after the fact), and the file-
   based git-committed nature of all of this (no external database or
   service to index into, unless you're proposing one and can justify
   the added complexity).
3. **If you think a concrete first step is obviously worth taking
   regardless of the rest, say so and why** -- but this task is
   deliberately review/ideation only, not implementation. Don't restructure
   any files yourself.

### Deliverable

A report at `docs/codx-reports/<date>-context-load-review.md`: your
assessment of proposals 1-3 (keep/modify/drop each, with reasoning),
your own additional or alternative ideas, and a recommended prioritized
next step or two. CLDO will read this, decide what to actually
implement, and this becomes a real project-log entry either way.
