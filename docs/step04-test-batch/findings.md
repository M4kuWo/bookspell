# Step 04 test batch — 30 books, tagging pipeline dry run

Purpose: validate the tagging approach (Claude via forked subagents, using
the synopsis already pulled from Hardcover during step 03 as the primary
source) against a real slice of the untagged catalog, and get a concrete
read on Claude usage cost before committing to tagging the remaining ~108
books. Not blind like the original 30-book pilot — these are all
well-known books tagged largely from existing knowledge plus the stored
synopsis, with supplementary web search available but rarely needed.

## Result

All 30 books tagged, validated cleanly against the current schema (99
tropes, 33 content warnings), and inserted into `book_dna` /
`book_tropes` / `book_content_warnings`. `book_length` and
`audiobook_length` were **not** left to the model — computed
deterministically from the `page_count` / `audiobook_duration_minutes`
already stored in `books` from step 03, since those are arithmetic, not
judgment calls.

## Schema gaps surfaced (candidates for later, not applied yet)

- **Jurassic Park**: no trope for "genetic-engineering hubris distinct
  from cloning" — approximated with `cloning`, flagged as imprecise.
- **Good Omens**: no fantasy-side equivalent of `satirical_or_comedic_scifi`
  — this book satirizes apocalyptic/religious convention, not sci-fi
  tropes, so the existing sci-fi-specific entry doesn't fit despite being
  usable cross-genre in principle.
- **LitRPG `form` gap confirmed again** — The Gate of the Feral Gods hit
  the same "no `form` value for embedded game-notification text" gap
  first flagged for He Who Fights with Monsters in the original pilot.
  Now two independent instances — stronger evidence this is worth fixing,
  not a one-off.
- **The Last Wish**: raised whether `mythological_retelling` should
  distinguish classical/religious myth (Circe) from fairy-tale retellings
  (Snow White, Beauty and the Beast, reframed here) — same shape of
  trope, arguably a different category. Open question, not resolved.

None of these were applied to the schema in this pass — logged here for
a deliberate review, same discipline as every other vocabulary decision
in this project (real gap, not just "a real term exists").

## Usage cost (the actual point of this test)

6 forked subagents, 5 books each, each inheriting this session's full
conversation history as context (that's most of the cost — the
book-specific tagging work itself is a small fraction of each fork's
token count). Per-fork usage: 831,859 / 836,022 / 831,484 / 831,827 /
831,484 / 844,156 subagent tokens — totaling **~5.0M tokens for 30
books**. See `docs/project-log.md` for the corresponding real Claude Code
usage delta (screenshotted before/after by the user) and what that
implies for tagging the remaining ~108 books.
