-- Third batch of the audiobook_editions standard-narrator backfill.
--
-- Found while reviewing the "too many groups" flagged books from
-- batch 2: ~20 Terry Pratchett titles were showing 3-4 narrator
-- groups, most containing a recurring "Bill Nighy, X, Peter
-- Serafinowicz" trio. Verified via search: this is Penguin Random
-- House's 2022+ full-cast re-recording of all 40 Discworld novels
-- (produced by Ladbroke Audio), with Peter Serafinowicz voicing
-- Death and Bill Nighy narrating footnotes throughout the series --
-- a dramatized production, not a plain narration, that slipped past
-- the existing filters (Hardcover only credits a handful of named
-- leads per edition, not enough to trip the >4-narrator check, and
-- the publisher is the generic "Penguin Audio" imprint also used
-- for real standalone narrations). Added a known-ensemble-signature
-- exclusion for these two specific names to scripts/backfill-
-- standard-narrators.js.
--
-- 20 of the 64 previously-flagged "too many groups" books now
-- resolve cleanly (40 rows) to their real historical standard
-- narrators (Nigel Planer, Tony Robinson, Stephen Briggs, Celia
-- Imrie, and others across different Pratchett-adjacent titles).
-- 44 books remain flagged, needing individual research -- see
-- docs/TODO.md.
--
-- Every insert is title/author-scoped and idempotent via the
-- existing unique (book_id, source_url) constraint. Verified: all
-- 20 books' title/author pairs matched exactly one books row before
-- this file was generated (zero mismatches).

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Celia Imrie']::text[], 'ISIS Audio Books', 445, 'https://hardcover.app/books/equal-rites/editions/4840300', current_date
from books where title = 'Equal Rites' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/equal-rites/editions/3656949', current_date
from books where title = 'Equal Rites' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'ISIS Audio Books', 202, 'https://hardcover.app/books/eric/editions/29307734', current_date
from books where title = 'Eric' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Books', null, 'https://hardcover.app/books/eric/editions/14773251', current_date
from books where title = 'Eric' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 573, 'https://hardcover.app/books/feet-of-clay/editions/13591795', current_date
from books where title = 'Feet of Clay' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/feet-of-clay/editions/16312505', current_date
from books where title = 'Feet of Clay' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Martin Jarvis']::text[], 'HarperAudio', 752, 'https://hardcover.app/books/good-omens/editions/206371', current_date
from books where title = 'Good Omens: The Nice and Accurate Prophecies of Agnes Nutter, Witch' and author = 'Neil Gaiman, Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'ISIS Publishing', null, 'https://hardcover.app/books/good-omens/editions/31845484', current_date
from books where title = 'Good Omens: The Nice and Accurate Prophecies of Agnes Nutter, Witch' and author = 'Neil Gaiman, Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', null, 'https://hardcover.app/books/interesting-times/editions/20219544', current_date
from books where title = 'Interesting Times' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/interesting-times/editions/2709813', current_date
from books where title = 'Interesting Times' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/jingo/editions/28951723', current_date
from books where title = 'Jingo' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 647, 'https://hardcover.app/books/jingo/editions/12646293', current_date
from books where title = 'Jingo' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'HarperAudio', 664, 'https://hardcover.app/books/making-money/editions/30459433', current_date
from books where title = 'Making Money' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi', null, 'https://hardcover.app/books/making-money/editions/31720600', current_date
from books where title = 'Making Money' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 568, 'https://hardcover.app/books/men-at-arms/editions/7441908', current_date
from books where title = 'Men at Arms' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Books', null, 'https://hardcover.app/books/men-at-arms/editions/13591076', current_date
from books where title = 'Men at Arms' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 558, 'https://hardcover.app/books/mort/editions/12768604', current_date
from books where title = 'Mort' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/mort/editions/19634160', current_date
from books where title = 'Mort' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Transworld', null, 'https://hardcover.app/books/moving-pictures/editions/26130552', current_date
from books where title = 'Moving Pictures' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio', 611, 'https://hardcover.app/books/moving-pictures/editions/15492871', current_date
from books where title = 'Moving Pictures' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 593, 'https://hardcover.app/books/pyramids/editions/2835853', current_date
from books where title = 'Pyramids' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/pyramids/editions/9568144', current_date
from books where title = 'Pyramids' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 590, 'https://hardcover.app/books/small-gods/editions/31715391', current_date
from books where title = 'Small Gods' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi', 193, 'https://hardcover.app/books/small-gods/editions/6140582', current_date
from books where title = 'Small Gods' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 638, 'https://hardcover.app/books/soul-music/editions/2829241', current_date
from books where title = 'Soul Music' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/soul-music/editions/4011546', current_date
from books where title = 'Soul Music' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Trafalgar Square Publishing', null, 'https://hardcover.app/books/sourcery/editions/2946580', current_date
from books where title = 'Sourcery' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'Isis Audio', 475, 'https://hardcover.app/books/sourcery/editions/30438133', current_date
from books where title = 'Sourcery' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', 184, 'https://hardcover.app/books/the-colour-of-magic-1983/editions/1882997', current_date
from books where title = 'The Colour Of Magic' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 415, 'https://hardcover.app/books/the-colour-of-magic-1983/editions/3420962', current_date
from books where title = 'The Colour Of Magic' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Trafalgar Square Publishing', null, 'https://hardcover.app/books/the-light-fantastic/editions/27667762', current_date
from books where title = 'The Light Fantastic' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 407, 'https://hardcover.app/books/the-light-fantastic/editions/14537210', current_date
from books where title = 'The Light Fantastic' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/thief-of-time/editions/23530710', current_date
from books where title = 'Thief Of Time' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'ISIS Audio Books', 650, 'https://hardcover.app/books/thief-of-time/editions/20219545', current_date
from books where title = 'Thief Of Time' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Stephen Briggs']::text[], 'Transworld Publishers Limited', null, 'https://hardcover.app/books/thud/editions/19605503', current_date
from books where title = 'Thud!' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/thud/editions/15956985', current_date
from books where title = 'Thud!' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Nigel Planer']::text[], 'ISIS Audio Books', 452, 'https://hardcover.app/books/witches-abroad/editions/4610028', current_date
from books where title = 'Witches Abroad' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Trafalgar Square Publishing', null, 'https://hardcover.app/books/witches-abroad/editions/6376994', current_date
from books where title = 'Witches Abroad' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Tony Robinson']::text[], 'Corgi Audio', null, 'https://hardcover.app/books/wyrd-sisters/editions/32126677', current_date
from books where title = 'Wyrd Sisters' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions (book_id, edition_type, narrators, production_company, runtime_minutes, source_url, last_verified_date)
select id, 'standard', ARRAY['Celia Imrie']::text[], 'ISIS Audio Books', 626, 'https://hardcover.app/books/wyrd-sisters/editions/16787118', current_date
from books where title = 'Wyrd Sisters' and author = 'Terry Pratchett'
on conflict (book_id, source_url) do nothing;
