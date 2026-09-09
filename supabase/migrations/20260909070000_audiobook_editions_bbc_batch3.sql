-- tag-audiobook-editions skill, Sub-task A / Step A2, BBC Audio
-- batch 3 -- final batch clearing the 31-confirmed-match pool from
-- this session's A1a/A1b work. Researched and inserted Ray Bradbury
-- (2) and the 5 classic-SF titles (Frankenstein, The Time Machine,
-- The War of the Worlds, Journey to the Center of the Earth, Solaris)
-- -- 7 confirmed matches, well within the skill's 10-15 cap.

-- Direct: BBC Radio 4, broadcast 1982-11-13, adapted by Gregory
-- Evans. Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Michael Pennington','Pamela Salem','Peter Miles','Jonathan Newth',
    'Patience Tomlinson','Spencer Banks','Michael Simkins','Susan Dowdall',
    'Peter Tuddenham','Hugh Dickson','Alan Dudley'],
  'BBC Radio 4', null, 'fully_released', null, null,
  'https://www.michaelpennington.me.uk/page326.html', current_date
from books b
where (b.title, b.author) = ('Fahrenheit 451', 'Ray Bradbury')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, 2014. Total runtime (70 min) confirmed
-- directly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Derek Jacobi','Hayley Atwell'],
  'BBC Radio 4', 70, 'fully_released', null, null,
  'https://www.openculture.com/2017/03/ray-bradburys-the-martian-chronicles-a-radio-drama-starring-derek-jacobi-hayley-atwell.html', current_date
from books b
where (b.title, b.author) = ('The Martian Chronicles', 'Ray Bradbury')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio, 1994, adapted by Nick Stafford, 2 parts. Runtime
-- not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Michael Maloney','John Wood'],
  'BBC Radio 4', null, 'fully_released', 2, 2,
  'https://www.amazon.com/Frankenstein-Dramatised/dp/B001E6J33E', current_date
from books b
where (b.title, b.author) = ('Frankenstein', 'Mary Shelley')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 3 (not Radio 4 -- launched BBC Radio's 2009
-- Science Fiction season), adapted by Philip Osment. Runtime not
-- reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Robert Glenister','William Gaunt'],
  'BBC Radio 3', null, 'fully_released', null, null,
  'https://www.amazon.com/Wells-BBC-Radio-Collection-Dramatisations/dp/B088RM879H', current_date
from books b
where (b.title, b.author) = ('The Time Machine', 'H.G. Wells')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4. Total runtime (~2h/120min) confirmed directly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Blake Ritson','Samuel James','Carl Prekopp'],
  'BBC Radio 4', 120, 'fully_released', null, null,
  'https://www.amazon.com/The-War-of-Worlds-H-G-Wells-audiobook/dp/B06XMQ6W87', current_date
from books b
where (b.title, b.author) = ('The War of the Worlds', 'H. G. Wells')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4. Total runtime (~1h30m/90min) confirmed
-- directly. Our catalog stores the American spelling "Center"; the
-- BBC's own dramatisation title uses British "Centre" -- same book.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Joel MacCormack','Stephen Critchlow','Jim Broadbent','Leslie Phillips',
    'Sagar Arya','Gudmundur Thorvaldsson','Neil McCaul','Madeline Hatt',
    'David Seddon','Yves Aubert','Nathan Osgood','Tayla Kovacevic-Ebong',
    'Kerry Gooderson'],
  'BBC Radio 4', 90, 'fully_released', null, null,
  'https://www.amazon.com/Journey-Centre-Earth-full-cast-dramatisation/dp/B06WRSJW39', current_date
from books b
where (b.title, b.author) = ('Journey to the Center of the Earth', 'Jules Verne')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4 "Classic Serial", broadcast 2007-07-29, 2
-- one-hour episodes. Total runtime (2h/120min) confirmed directly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Ron Cook','Tim McMullan','Stuart Richman','Joanne Froggatt'],
  'BBC Radio 4', 120, 'fully_released', 2, 2,
  'https://www.sffaudio.com/stanislaw-lems-solaris-to-air-on-bbc-radio-4/', current_date
from books b
where (b.title, b.author) = ('Solaris', 'Stanisław Lem')
on conflict (book_id, source_url) do nothing;
