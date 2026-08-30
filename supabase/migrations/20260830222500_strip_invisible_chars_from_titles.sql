-- Data-quality fix: strips zero-width/invisible Unicode characters (zero-
-- width space, ZWNJ/ZWJ, LRM/RLM, BOM, word joiner, soft hyphen) from
-- books.title. Surfaced by "A Court of Silver Flames", which had a
-- zero-width space (U+200B) embedded between "A" and "Court", silently
-- breaking exact-title lookups (e.g. the title-keyed subselects every
-- migration in this project uses for book_id). Table-wide regexp rather
-- than a single-row fix, and safe to rerun: confirmed via a full-table
-- scan that only this one row was affected as of 2026-08-30, but this
-- makes any future import of the same bad data a no-op instead of a
-- silent repeat.

update books
set title = regexp_replace(title, '[​‌‍‎‏﻿⁠­]', '', 'g')
where title ~ '[​‌‍‎‏﻿⁠­]';
