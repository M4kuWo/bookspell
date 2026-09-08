-- tag-audiobook-editions skill, Sub-task A / Step A2, batch 5 --
-- Researched: The Demon Cycle (all 5 books, completes the series) and
-- Red Rising Saga (all 6 books, completes the saga). 11 confirmed
-- matches inserted -- within the skill's 10-15 cap.

-- Direct: 2 parts, both independently listed. Only Part 1's runtime
-- (7h9m) confirmed as part-specific, not a total -- left
-- runtime_minutes NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Ken Jackson','Richard Rohan','Terence Aselford','Colleen Delany',
    'Delores King Williams','Elizabeth Jernigan','James Lewis',
    'Christopher Graybill','Nick DePinto','Thomas Penny','Steven Carpenter',
    'Michael Glenn','Eric Messner','Joe Brack','Mort Shelby',
    'Michael John Casey','Joseph Thornhill'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/demon-cycle-1-the-warded-man-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('The Warded Man', 'Peter V. Brett')
on conflict (book_id, source_url) do nothing;

-- Direct: 3 parts, all independently listed. Runtime not reliably
-- found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Dylan Lynch','Thomas Penny','Colleen Delany','Michael Glenn',
    'Ken Jackson','Kimberly Gilbert','Alyssa Wilmoth','Bradley Foster Smith',
    'Eric Messner','Joe Brack','Nick DePinto'],
  'GraphicAudio', null, 'fully_released', 3, 3,
  'https://www.graphicaudio.net/demon-cycle-2-the-desert-spear-1-of-3.html', current_date
from books b
where (b.title, b.author) = ('The Desert Spear', 'Peter V. Brett')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently listed. Runtime not reliably
-- found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Dylan Lynch','Thomas Penny','Johann Dettweiler','Eva Wilhelm',
    'Colleen Delany','Alyssa Wilmoth','Bradley Foster Smith','Joe Brack',
    'Katy Carkuff','Ken Jackson','Michael Glenn'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/demon-cycle-3-the-daylight-war-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('The Daylight War', 'Peter V. Brett')
on conflict (book_id, source_url) do nothing;

-- Direct: 3 parts, released 2015-01-01. No graphicaudio.net product
-- URL was reliably returned for this title -- recorded against its
-- confirmed Amazon listing instead. Runtime not reliably found --
-- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Dylan Lynch','Eva Wilhelm','Joe Brack','Bradley Foster Smith',
    'Katy Carkuff','Lily Beacon','Michael Glenn','Nanette Savard',
    'Colleen Delany','Ken Jackson','Christopher Scheeren'],
  'GraphicAudio', null, 'fully_released', 3, 3,
  'https://www.amazon.com/Skull-Throne-Demon-Cycle-GraphicAudio/dp/1628511761', current_date
from books b
where (b.title, b.author) = ('The Skull Throne', 'Peter V. Brett')
on conflict (book_id, source_url) do nothing;

-- Direct: 4 parts, all independently listed, released 2017-10-03.
-- Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Dylan Lynch','Eva Wilhelm','Johann Dettweiler','Thomas Penny'],
  'GraphicAudio', null, 'fully_released', 4, 4,
  'https://www.graphicaudio.net/demon-cycle-5-the-core-1-of-4.html', current_date
from books b
where (b.title, b.author) = ('The Core', 'Peter V. Brett')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently confirmed at 7h each -- a clean
-- total (14h/840min) rather than a partial figure, since both parts
-- were equally and specifically confirmed.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Stewart Crank','John Kielty','Richard Rohan','Stephanie Nemeth-Parker',
    'Jenna Sharpe','Kay Eluvian','Jon Vertullo','Ian Russell','Alejandro Ruiz',
    'Andrew Colford','Bradley Foster Smith'],
  'GraphicAudio', 840, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/red-rising-saga-1-red-rising-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('Red Rising', 'Pierce Brown')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently confirmed (Part 1: 9h,
-- released 2023-08-14; Part 2: 8h, released 2023-10-02) -- summed to
-- a total of 17h/1020min since both parts were specifically
-- confirmed, not guessed. No reliable named cast found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', 1020, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/red-rising-saga-2-golden-son-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('Golden Son', 'Pierce Brown')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently listed (Part 1 released
-- 2024-02-08, Part 2 released 2024-05-28). Only Part 2's runtime
-- (~10.5h) confirmed as part-specific, not a total -- left
-- runtime_minutes NULL rather than guess. No reliable named cast
-- found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/red-rising-saga-3-morning-star-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('Morning Star', 'Pierce Brown')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently listed. No reliable cast or
-- runtime found for this specific title -- both left NULL; existence
-- and part count (2) are the only points confirmed with confidence.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/red-rising-saga-4-iron-gold-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('Iron Gold', 'Pierce Brown')
on conflict (book_id, source_url) do nothing;

-- Direct: 3 parts, released 2025 (Red Rising 5). No graphicaudio.net
-- product URL was reliably returned for this title -- recorded
-- against its confirmed Amazon listing instead. Runtime not reliably
-- found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Stewart Crank','Jenna Sharpe','Christopher Tester','Rayner Gabriel',
    'Alex Hill-Knight','Jon Vertullo','Ian Putnam','Jessica Threet',
    'Elena Anderson','Natalie Van Sistine','Jonathan David Bullock'],
  'GraphicAudio', null, 'fully_released', 3, 3,
  'https://www.amazon.com/Dark-Age-Part-Dramatized-Adaptation/dp/B0FF5JD1D6', current_date
from books b
where (b.title, b.author) = ('Dark Age', 'Pierce Brown')
on conflict (book_id, source_url) do nothing;

-- Direct: 3 parts, all independently listed. No reliable cast or
-- runtime found for this specific title -- both left NULL; existence
-- and part count (3) are the only points confirmed with confidence.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', null, 'fully_released', 3, 3,
  'https://www.graphicaudio.net/red-rising-saga-6-light-bringer-1-of-3.html', current_date
from books b
where (b.title, b.author) = ('Light Bringer', 'Pierce Brown')
on conflict (book_id, source_url) do nothing;
