-- The last of the 3 open scope calls CLDA flagged during round-4
-- archiving (2026-09-21). "The Lottery" (Shirley Jackson) -- unlike The
-- Egg, the real full collection it belongs to ("The Lottery and Other
-- Stories") is itself tagged "Gothic" by Hardcover, not Science
-- Fiction/Fantasy, and its description confirms straight literary
-- horror with no speculative elements. Repo owner's 2026-09-22 call:
-- archive, same treatment as Holly -- a real book, just out of v1's
-- sci-fi/fantasy scope regardless of format. Zero dependent rows
-- (never tagged), confirmed before archiving.
update books
set archived = true,
    archived_reason = 'non_sff_genre_leakage',
    archived_at = now()
where title = 'The Lottery' and author = 'Shirley Jackson';
