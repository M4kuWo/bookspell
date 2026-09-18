-- Normalize 3 audiobook_editions.production_company values that were
-- entered inconsistently -- a bare 'Macmillan' (2 rows: The Great
-- Hunt's Rosamund Pike edition, A Gathering of Shadows) and a
-- trailing-space 'Macmillan Audio ' (What Moves the Dead) where every
-- other row for the same real imprint uses 'Macmillan Audio' exactly.
-- Verified via web search that both books are genuinely published by
-- Macmillan Audio (not a different Macmillan sub-imprint like
-- Macmillan Digital Audio/Macmillan Young Listeners, which are real
-- and left alone) before normalizing -- not a blind string replace.
-- Found while investigating a repo-owner question about why The Great
-- Hunt's Kramer/Reading edition says 'Audio Renaissance' while The
-- Dragon Reborn's says 'Macmillan Audio' for the same narrator pair --
-- that part turned out to be real edition history, not a bug (see
-- docs/project-log.md's 2026-09-18 entry), but this specific
-- bare-'Macmillan'/trailing-space inconsistency was a real, separate,
-- small data-entry gap worth fixing while already looking at this data.
update audiobook_editions set production_company = 'Macmillan Audio'
where id = (select ae.id from audiobook_editions ae join books b on b.id = ae.book_id
            where b.title = 'The Great Hunt' and ae.production_company = 'Macmillan');
update audiobook_editions set production_company = 'Macmillan Audio'
where id = (select ae.id from audiobook_editions ae join books b on b.id = ae.book_id
            where b.title = 'A Gathering of Shadows' and ae.production_company = 'Macmillan');
update audiobook_editions set production_company = 'Macmillan Audio'
where id = (select ae.id from audiobook_editions ae join books b on b.id = ae.book_id
            where b.title = 'What Moves the Dead' and ae.production_company = 'Macmillan Audio ');
