-- Widen books.work_type (novella/novel, built 2026-08-29) to also allow
-- 'audio_original': a full-cast audio drama (e.g. an Audible Original)
-- with NO print/ebook counterpart at all. Reusing work_type rather than
-- adding a separate audio-only boolean flag -- it's already the
-- controlled-vocabulary field for "what kind of work is this," and an
-- audio-only original is a third real category alongside novella/novel,
-- not an orthogonal fact about an otherwise-normal novel. Nothing in
-- scripts/recommend.py currently reads work_type for scoring (checked
-- before this migration), so widening its CHECK constraint is safe --
-- no scoring-code change needed alongside this.
--
-- Book DNA implications for a future audio_original entry (see
-- docs/schema/book-dna.md and the tag-audiobook-editions skill this
-- migration was written alongside): book_length/page_count legitimately
-- stay NULL (no page count exists), audiobook_length is the only real
-- length signal, and prose_density/prose_complexity should only be
-- tagged if they genuinely map to the audio drama's actual narration/
-- dialogue -- never forced.

alter table books drop constraint if exists books_work_type_check;
alter table books add constraint books_work_type_check
  check (work_type = any (array['novella', 'novel', 'audio_original']));
