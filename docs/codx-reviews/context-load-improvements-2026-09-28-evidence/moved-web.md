## v1 web app (`app/`, `api/`)

Static multi-page frontend (no build step, `supabase-js` from a CDN
`<script>` tag) on GitHub Pages, talking directly to hosted Supabase
(Auth + RLS-scoped tables) plus a small FastAPI backend (`api/`,
deployed to Render) for the actual `recommend()`/`explain_match()`
calls. See `~/.claude/plans/jaunty-chasing-eclipse.md` (or its
successor if superseded) for the original build plan.

- **`supabase config push` pushes the ENTIRE local `config.toml` to
  hosted, not just the section you meant to change.** Real,
  already-happened example (2026-09-13): pushing a `site_url`/
  `additional_redirect_urls` change also silently flipped hosted's
  `enable_confirmations`/`otp_length`/`max_frequency`/MFA settings to
  this file's stock local-dev defaults (email confirmation off, an
  effectively unthrottled 1-second email rate limit) for the few
  minutes between two pushes, until the diff `config push` itself
  prints was actually read and the values restored. **Always read
  the diff `config push` prints before/after** — don't just run it and
  move on — and expect this any time `config.toml` has drifted from
  hosted's real values for reasons unrelated to what you're changing.
- **An element toggled via the `hidden` IDL/content attribute must not
  have its `display` property set unconditionally in CSS** — an author
  stylesheet declaration always overrides the browser's own
  `[hidden] { display: none }` default for the same property, REGARDLESS
  of specificity (origin beats specificity in the cascade), so
  `el.hidden = true` silently does nothing if some rule elsewhere sets
  `display` on that element without excluding the hidden state. Real,
  already-happened example (2026-09-13): the book-info modal's
  `.modal-overlay { display: flex }` meant its close button visibly did
  nothing — the modal was already permanently "on," just usually
  unnoticed because `overlay.hidden` started `true` before the element
  was ever inserted. Fix: scope the rule to `:not([hidden])`
  (`.modal-overlay:not([hidden]) { display: flex; ... }`), never set
  `display` on a hideable element outside that guard.
- **Dark/light theming uses CSS custom-property tokens, not selector
  overrides** (`shared.css`'s `--paper`/`--ink`/`--accent`/etc., plus
  the `--gold`/`--gold-bg`/`--gold-border` set added 2026-09-13) —
  define every themed value as a token in the bare `:root` block, redefine
  the SAME tokens inside `@media (prefers-color-scheme: dark)` (guarded
  `:root:not([data-theme="light"])`) and again under
  `:root[data-theme="dark"]`, and have components reference `var(--x)`
  only. **Never write a component-specific dark-mode override directly
  on a class selector outside those two blocks** — caught myself about
  to do exactly that while building the gold membership badge (a
  `:root:not([data-theme="light"]) .membership-badge {...}` rule placed
  OUTSIDE the `@media` block, which would have applied the dark color to
  every viewer by default regardless of their actual theme, since almost
  every root element matches `:not([data-theme="light"])` unless the
  user explicitly chose light) — fixed before it shipped by switching to
  the token pattern instead.
- **`audiobook_editions`** (real per-edition narrator/cast/production
  data, distinct from `book_dna`'s own Tier B "listening quality"
  fields, which remain genuinely untagged catalog-wide) is populated by
  `.claude/skills/tag-audiobook-editions/SKILL.md`, with its current
  contract in `docs/schema/book-dna-tables.md` (full original design
  rationale preserved in `book-dna-decisions.md`) — read both before
  touching this table. `edition_type` values
  (verified directly against the live CHECK constraint, 2026-09-25 —
  `audio_original` is NOT one of them, a stale claim this same bullet
  used to make; that's a real value on the separate `books.work_type`
  column, not this table's `edition_type`): `standard`,
  `dramatized_full_cast`, `abridged`, `other`. `narrators` is a flat
  name array (no character-role mapping — a known, documented future
  gap, not a bug). A 2026-09-18 sweep found zero confirmed rows
  mislabeled `edition_type = 'standard'` catalog-wide (see
  `docs/TODO.md`) — a one-time clean result, not a standing guarantee,
  so still worth a light cross-check of narrator count/production
  company on genuinely ambiguous-looking rows, especially after any
  future GraphicAudio/BBC tagging batch.

