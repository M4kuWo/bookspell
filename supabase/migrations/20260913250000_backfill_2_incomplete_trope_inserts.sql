-- Fix the "incomplete-insert" data-quality issue flagged (not fixed) during
-- catalog-trope-gap-sweep #3, 2026-09-13: two books (*How High We Go in the
-- Dark*, *A Short Stay in Hell*) have a real `book_dna` row and real
-- `book_content_warnings` rows but ZERO `book_tropes` rows -- looks like an
-- earlier tagging pass's trope-insert step was silently skipped for these
-- two, not a deliberate zero-tropes case. See docs/project-log.md's
-- 2026-09-13 "sweep #3" entry for the original flag.
--
-- This is a per-book tagging backfill (tag-catalog-batch-style), not a
-- vocabulary change -- both tropes used already exist in the current
-- 152-value vocabulary, verified against real plot details before tagging
-- (re-checked via web search, not assigned from genre pattern-matching),
-- per CLAUDE.md's standing evidence discipline for any trope asserting a
-- specific plot mechanism:
--
-- A Short Stay in Hell (Steven L. Peck): the protagonist is condemned to a
-- hell that takes the literal form of a library "orders of magnitude
-- larger than the known universe" (a Library-of-Babel-style near-infinite
-- structure) and must search it for one specific book -- confirmed via
-- Wikipedia's plot summary. This is a direct, high-confidence match to
-- `impossible_or_non_euclidean_architecture` (added this same session,
-- migration 20260913230000), whose own evidence set already includes an
-- almost identical concept (The Library at Mount Char's infinite,
-- inter-planar library). Full confidence (source: ai_inferred, no
-- confidence discount -- this is a clean structural match, not a
-- borderline call).
--
-- How High We Go in the Dark (Sequoia Nagamatsu): confirmed via search
-- (Wikipedia + multiple reviews) to be a chronological mosaic novel
-- tracing a climate-triggered pandemic across MULTIPLE DECADES, ending
-- with humanity's survivors generations later aboard a generation ship
-- (a widowed painter and her teenaged granddaughter searching for a new
-- home planet) -- reviewers explicitly compare its cross-generational
-- structural resonance to Cloud Atlas. This is a real but genuinely
-- BORDERLINE fit for `multi_generational_saga` (whose own evidence set --
-- Foundation, Jade City, One Hundred Years of Solitude, Fire & Blood -- are
-- all more explicitly family/dynasty-centered than this book's own
-- pandemic-mosaic structure): tagged with a reduced confidence (0.55,
-- below this project's 0.6 "low-confidence" flag threshold) rather than
-- either skipping it or asserting it at full confidence, per CLAUDE.md's
-- confidence-layer policy for a genuinely uncertain call. Deliberately did
-- NOT also tag `sudden_apocalypse_event` -- confirmed via search that the
-- pandemic does NOT collapse civilization (society organizes new
-- industries around mass death and a cure is eventually found), which
-- doesn't clear that trope's "collapse of civilization" bar.
--
-- Both titles confirmed unique in `books` before writing.

insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'A Short Stay in Hell'), 'impossible_or_non_euclidean_architecture', null, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id, confidence, source) values
  ((select id from books where title = 'How High We Go in the Dark'), 'multi_generational_saga', 0.55, 'ai_inferred')
on conflict (book_id, trope_id) do nothing;
