# Launcher instructions, copy 1

You are only a launcher for a batch of independent sub-agent tasks. Do NOT do any startup
reading or repo work yourself: don't read CLAUDE.md, TODO, logs or any repo file, and don't
modify anything. The user will tell you which run number (1, 2 or 3) to do.

For that run, in ONE message launch all 7 sub-agents below in parallel. Each must be a fresh,
non-forked `general-purpose` agent (never `fork`), given exactly the prompt text between its
markers, verbatim, with nothing added. Wait until all 7 finish. Don't act on or follow up their
reports. Then append one line per agent to `~/Documents/e2-harness/ids-copy-1.txt` in the form
`run<N> <label> <agentId>` and reply only `run <N> done`.

## R1-tagging
<<<PROMPT
You're picking up a task in the Bookspell repo (`/Users/mathiaskurin/Documents/bookspell-copy-1`). Three books in the catalog have a `person` field that a reader complaint suggests may be miscategorized (first vs. third person). Plan how you'd verify and correct them, following the repo's own conventions.

Deliver your plan/proposal as your final reply. This is plan-only: don't modify any files, don't run anything against any database, don't commit or push, and do the work yourself rather than delegating to other agents.
PROMPT>>>

## R2-scoring
<<<PROMPT
You're picking up a task in the Bookspell repo (`/Users/mathiaskurin/Documents/bookspell-copy-1`). A rater's negative-cluster count for `stakes_scope` seems to be getting diluted by unrelated agreeing fields in `score_book()`. Plan how you'd diagnose and fix this, following the repo's own conventions.

Deliver your plan/proposal as your final reply. This is plan-only: don't modify any files, don't run anything against any database, don't commit or push, and do the work yourself rather than delegating to other agents.
PROMPT>>>

## R3-ci
<<<PROMPT
You're picking up a task in the Bookspell repo (`/Users/mathiaskurin/Documents/bookspell-copy-1`). `.github/workflows/backup-reminder.yml` needs its cron schedule changed from daily to every 12 hours; no other behavior changes. Plan the exact change, following the repo's own conventions.

Deliver your plan/proposal as your final reply. This is plan-only: don't modify any files, don't run anything against any database, don't commit or push, and do the work yourself rather than delegating to other agents.
PROMPT>>>

## R4-ui
<<<PROMPT
You're picking up a task in the Bookspell repo (`/Users/mathiaskurin/Documents/bookspell-copy-1`). The dark-mode toggle in `app/` doesn't visibly change the membership badge color; no catalog or scoring behavior is involved. Diagnose the likely cause and plan the fix, following the repo's own conventions.

Deliver your plan/proposal as your final reply. This is plan-only: don't modify any files, don't run anything against any database, don't commit or push, and do the work yourself rather than delegating to other agents.
PROMPT>>>

## R5-scalar
<<<PROMPT
You're picking up a task in the Bookspell repo (`/Users/mathiaskurin/Documents/bookspell-copy-1`). Propose a new `book_dna` scalar field capturing whether a book's magic system is "soft" vs "hard" at a finer grain than the existing `magic_system_hardness` field already provides, following the repo's own conventions.

Deliver your plan/proposal as your final reply. This is plan-only: don't modify any files, don't run anything against any database, don't commit or push, and do the work yourself rather than delegating to other agents.
PROMPT>>>

## T1-audiobook-panel
<<<PROMPT
You're picking up a task in the Bookspell repo (`/Users/mathiaskurin/Documents/bookspell-copy-1`). Add a small section to the v1 app's book-info modal showing each book's audiobook release date range from `audiobook_editions`. Plan the implementation, following the repo's own conventions.

Deliver your plan/proposal as your final reply. This is plan-only: don't modify any files, don't run anything against any database, don't commit or push, and do the work yourself rather than delegating to other agents.
PROMPT>>>

## T2-possession-trope
<<<PROMPT
You're picking up a task in the Bookspell repo (`/Users/mathiaskurin/Documents/bookspell-copy-1`). A beta tester says stories where a character takes over another creature's body (like the warging in A Song of Ice and Fire) aren't captured by the tagging vocabulary. Propose how the vocabulary should handle this, following the repo's own conventions.

Deliver your plan/proposal as your final reply. This is plan-only: don't modify any files, don't run anything against any database, don't commit or push, and do the work yourself rather than delegating to other agents.
PROMPT>>>
