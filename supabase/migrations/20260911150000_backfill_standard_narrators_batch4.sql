-- Fourth batch of the audiobook_editions standard-narrator backfill.
--
-- Found while continuing the flagged-books review: (1) "full cast"
-- (Harry Potter and the Philosopher's Stone) and "Ensemble Cast"
-- (The Hobbit) are Hardcover placeholder values, not real narrator
-- names; (2) Phil Dragash's Lord of the Rings recurred across all 3
-- volumes -- confirmed via search to be an explicitly unofficial,
-- free fan recording, not a licensed commercial edition, out of
-- scope for this catalog; (3) publishers named "... Radio
-- Productions" are radio-drama full-cast adaptations leaking into
-- the standard pool the same way GraphicAudio did.
--
-- 4 more books now resolve cleanly (8 rows): Harry Potter and the
-- Philosopher's Stone (Jim Dale/Stephen Fry), and all 3 Fellowship/
-- Two Towers/Return of the King volumes (Rob Inglis's classic
-- narration vs. Andy Serkis's 2021 re-recording -- the same UK/US-
-- style genuine-dual-edition pattern as The Eye of the World).
--
-- Verified: all 4 books' title/author pairs matched exactly one
-- books row before this file was generated (zero mismatches).

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Jim Dale']::text[], 'Pottermore', 498, 'https://hardcover.app/books/harry-potter-and-the-philosophers-stone/editions/30649544', current_date
from books where title = 'Harry Potter and the Philosopher''s Stone' and author = 'J.K. Rowling'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Fry']::text[], 'Pottermore Publishing', 506, 'https://hardcover.app/books/harry-potter-and-the-philosophers-stone/editions/30920081', current_date
from books where title = 'Harry Potter and the Philosopher''s Stone' and author = 'J.K. Rowling'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rob Inglis']::text[], 'Recorded Books', null, 'https://hardcover.app/books/the-fellowship-of-the-ring/editions/16862026', current_date
from books where title = 'The Fellowship of the Ring' and author = 'J.R.R. Tolkien'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Andy Serkis']::text[], 'Recorded Books', 1358, 'https://hardcover.app/books/the-fellowship-of-the-ring/editions/31618405', current_date
from books where title = 'The Fellowship of the Ring' and author = 'J.R.R. Tolkien'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rob Inglis']::text[], ' Recorded Books, Inc', 1099, 'https://hardcover.app/books/the-return-of-the-king/editions/1410385', current_date
from books where title = 'The Return of the King' and author = 'J.R.R. Tolkien'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Andy Serkis']::text[], 'Recorded Books', 1312, 'https://hardcover.app/books/the-return-of-the-king/editions/31706927', current_date
from books where title = 'The Return of the King' and author = 'J.R.R. Tolkien'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Andy Serkis']::text[], 'Recorded Books, Inc.', 1247, 'https://hardcover.app/books/the-two-towers/editions/30920082', current_date
from books where title = 'The Two Towers' and author = 'J.R.R. Tolkien'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Rob Inglis']::text[], 'Recorded Books', null, 'https://hardcover.app/books/the-two-towers/editions/4131511', current_date
from books where title = 'The Two Towers' and author = 'J.R.R. Tolkien'
on conflict (book_id, source_url) do nothing;
