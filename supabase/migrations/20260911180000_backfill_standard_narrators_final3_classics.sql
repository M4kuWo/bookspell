-- Final, hand-picked batch of the audiobook_editions standard-narrator
-- backfill, covering the 3 books left genuinely flagged by
-- scripts/backfill-standard-narrators.js (5+ distinct real narrator
-- groups: Frankenstein 12, The Strange Case of Dr Jekyll and Mr Hyde 8,
-- Fahrenheit 451 6).
--
-- Why hand-picked rather than either bulk-inserting all of them or
-- leaving them empty: these are genuine public-domain classics with many
-- real historical narrations (every name checked shows no typo/
-- dramatized/placeholder red flags) -- but cataloging every single one
-- has low practical value and adds noise for a recommendation engine
-- that just needs real, representative narrator data per book. Picked
-- the 3 most-corroborated groups per book (highest Hardcover users_count,
-- preferring a populated runtime as a tiebreak, and preferring a solo
-- narrator over a same-tier multi-person group to keep the data clean
-- for these three specifically -- e.g. Frankenstein's "Anthony Heald,
-- Simon Templeman, Stefan Rudnicki" 3-person Blackstone Audio credit was
-- passed over in favor of Dan Stevens' solo reading at the same
-- confidence tier). The remaining, less-corroborated editions for these
-- 3 books are not inserted -- a real, bounded editorial choice, not a
-- silent gap. source_url values are the real Hardcover edition URLs from
-- the analysis run, not placeholders.

-- Fahrenheit 451 (Ray Bradbury)
insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Christopher Hurt']::text[], 'Blackstone Audio', 309, 'https://hardcover.app/books/fahrenheit-451/editions/7047938', current_date
from books where title = 'Fahrenheit 451' and author = 'Ray Bradbury'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Hoye']::text[], 'Tantor Audio', null, 'https://hardcover.app/books/fahrenheit-451/editions/30402184', current_date
from books where title = 'Fahrenheit 451' and author = 'Ray Bradbury'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Penn Badgley']::text[], 'Simon & Schuster Audio', 276, 'https://hardcover.app/books/fahrenheit-451/editions/32106095', current_date
from books where title = 'Fahrenheit 451' and author = 'Ray Bradbury'
on conflict (book_id, source_url) do nothing;

-- Frankenstein (Mary Shelley)
insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Simon Vance']::text[], 'Tantor Media', null, 'https://hardcover.app/books/frankenstein/editions/30752785', current_date
from books where title = 'Frankenstein' and author = 'Mary Shelley'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['George Guidhall']::text[], 'Recorded Books', 534, 'https://hardcover.app/books/frankenstein/editions/30403777', current_date
from books where title = 'Frankenstein' and author = 'Mary Shelley'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Dan Stevens']::text[], 'Audible Studios', 515, 'https://hardcover.app/books/frankenstein/editions/31323298', current_date
from books where title = 'Frankenstein' and author = 'Mary Shelley'
on conflict (book_id, source_url) do nothing;

-- The Strange Case of Dr Jekyll and Mr Hyde (Robert Louis Stevenson)
insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Scott Brick']::text[], 'Tantor Media', 180, 'https://hardcover.app/books/the-strange-case-of-dr-jekyll-and-mr-hyde-a-kaplan-sat-score-raising-classic-1886/editions/32386233', current_date
from books where title = 'The Strange Case of Dr Jekyll and Mr Hyde' and author = 'Robert Louis Stevenson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Ian Holm']::text[], 'Canongate', null, 'https://hardcover.app/books/the-strange-case-of-dr-jekyll-and-mr-hyde-a-kaplan-sat-score-raising-classic-1886/editions/31672262', current_date
from books where title = 'The Strange Case of Dr Jekyll and Mr Hyde' and author = 'Robert Louis Stevenson'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Richard Armitage']::text[], 'Audible Studios', 187, 'https://hardcover.app/books/the-strange-case-of-dr-jekyll-and-mr-hyde-a-kaplan-sat-score-raising-classic-1886/editions/31705400', current_date
from books where title = 'The Strange Case of Dr Jekyll and Mr Hyde' and author = 'Robert Louis Stevenson'
on conflict (book_id, source_url) do nothing;
