-- Two of the 3 remaining open scope calls CLDA flagged during round-4
-- archiving (2026-09-21), resolved per the repo owner's direct
-- 2026-09-22 decisions.
--
-- 1. "Holly" (Stephen King, 2023) -- mostly a straight crime/thriller,
--    only a thin supernatural thread tying it to King's wider
--    interconnected universe. Repo owner's call: out of v1's sci-fi/
--    fantasy scope. Same treatment as the round-4 archive batch.
update books
set archived = true,
    archived_reason = 'non_sff_genre_leakage',
    archived_at = now()
where title = 'Holly' and author = 'Stephen King';

-- 2. "The Egg" (Andy Weir) was ingested as a standalone "book" but is
--    really a ~1,000-word flash-fiction piece -- not a real standalone
--    book (a format mis-ingest, confirmed via Hardcover: pages=3,
--    genuinely no larger context). Repo owner's framing: a short story
--    belongs in scope only via a real compilation it's part of, not by
--    itself. A real one exists -- "The Egg and Other Stories" (Hardcover
--    id 839124, audio-exclusive, genres Science Fiction/Fantasy per
--    Hardcover's own tagging) -- ingested separately in the next
--    migration (20260922040000). Delete this row rather than archive:
--    it's not an out-of-scope book, it's a mis-ingest being replaced by
--    the real book. Zero dependent rows (never tagged), confirmed before
--    deleting per CLAUDE.md's convention.
delete from books
where title = 'The Egg' and author = 'Andy Weir';
