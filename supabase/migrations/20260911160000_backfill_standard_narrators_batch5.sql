-- Fifth batch of the audiobook_editions standard-narrator backfill.
--
-- Found while continuing the flagged-books review: BBC's classic-
-- literature/genre audio catalog is almost exclusively full-cast
-- radio dramatisations when 2+ people are credited (verified via
-- search: Left Hand of Darkness/Earthsea's "BBC Radio 4 Full-Cast
-- Dramatisation", the exact production already partially recorded
-- as a dramatized_full_cast row from the earlier BBC Audio batch).
-- Also: "David Suchet, Paul Scofield" recurring across both Narnia
-- books under "Tyndale Entertainment" is Focus on the Family's
-- "Radio Theatre" full-cast dramatization (later also aired on BBC
-- Radio) -- another dramatized production, not a plain narration.
--
-- 4 more books now resolve cleanly (8 rows). Verified: all 4 books'
-- title/author pairs matched exactly one books row before this file
-- was generated (zero mismatches).

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Greg Wagland']::text[], 'W. F. Howes Ltd', 487, 'https://hardcover.app/books/childhoods-end/editions/32086093', current_date
from books where title = 'Childhood''s End' and author = 'Arthur C. Clarke'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Eric Michael Summerer', 'Robert J. Sawyer']::text[], 'Brilliance Audio', null, 'https://hardcover.app/books/childhoods-end/editions/31157070', current_date
from books where title = 'Childhood''s End' and author = 'Arthur C. Clarke'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Lynn Redgrave']::text[], 'HarperChildrensAudio', null, 'https://hardcover.app/books/prince-caspian/editions/1288204', current_date
from books where title = 'Prince Caspian' and author = 'C. S. Lewis'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Maurice Denham']::text[], 'BBC Audiobooks', 128, 'https://hardcover.app/books/prince-caspian/editions/33239891', current_date
from books where title = 'Prince Caspian' and author = 'C. S. Lewis'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['George Guidall']::text[], 'Recorded Books', 580, 'https://hardcover.app/books/the-left-hand-of-darkness/editions/32908770', current_date
from books where title = 'The Left Hand of Darkness' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Alyssa Bresnahan', 'Michael Crouch']::text[], 'Recorded Books', 607, 'https://hardcover.app/books/the-left-hand-of-darkness/editions/31889675', current_date
from books where title = 'The Left Hand of Darkness' and author = 'Ursula K. Le Guin'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Derek Jacobi']::text[], 'HarperCollins Publishers', 351, 'https://hardcover.app/books/the-voyage-of-the-dawn-treader/editions/31497057', current_date
from books where title = 'The Voyage of the Dawn Treader' and author = 'C. S. Lewis'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Michael Hordern']::text[], 'BBC Audiobooks', null, 'https://hardcover.app/books/the-voyage-of-the-dawn-treader/editions/32928596', current_date
from books where title = 'The Voyage of the Dawn Treader' and author = 'C. S. Lewis'
on conflict (book_id, source_url) do nothing;
