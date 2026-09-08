-- tag-audiobook-editions skill, Sub-task A / Step A2, batch 4 --
-- Researched: Mistborn Era Two/Wax and Wayne (all 4 books, completes
-- the era) and Stormlight Archive Era One (6 of 7 -- Wind and Truth
-- already has an edition from the 2026-09-05 schema-design seed row,
-- skipped here, not re-inserted). 10 confirmed matches inserted --
-- within the skill's 10-15 cap.

-- Direct: single release (no part split found), released 2016-04-27.
-- Total runtime (8h) confirmed directly. Only 3 named cast credits
-- found (lead roles + narrator) -- recorded as-is rather than padded.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Chris Genebach','Terence Aselford','Bradley Foster Smith'],
  'GraphicAudio', 480, 'fully_released', null, null,
  'https://www.graphicaudio.net/mistborn-4-the-alloy-of-law.html', current_date
from books b
where (b.title, b.author) = ('The Alloy of Law', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: single release (no part split found), released 2015-10-06.
-- Runtime not reliably found -- left NULL (the standard single-
-- narrator Macmillan Audio edition's 12h50m is a DIFFERENT, non-
-- GraphicAudio production and not used here).
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['David Harris','Richard Rohan','Terence Aselford','Michael John Casey',
    'Yasmin Tuazon','Dani Stoller','Bradley Foster Smith','Tracy Olivera',
    'Eva Wilhelm','Chris Genebach','Bob Payne'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/mistborn-5-shadows-of-self.html', current_date
from books b
where (b.title, b.author) = ('Shadows of Self', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently listed, released 2016-11-01.
-- Only Part 1's runtime (5h57m) confirmed as part-specific, not a
-- total -- left runtime_minutes NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Tracy Olivera','Matthew Keenan','David Jourdan','Dani Stoller',
    'Nora Achrati','Chris Genebach','Chris Davenport','Bradley Foster Smith',
    'Eva Wilhelm','Terence Aselford'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/mistborn-6-the-bands-of-mourning-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('The Bands of Mourning', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently listed (Part 1: 2022-12-07,
-- Part 2: 2023-01-26 per Amazon; a GraphicAudio.net listing separately
-- gives Part 2 as 2023-02-01 -- both confirm fully released, exact
-- date not needed for this schema). Only Part 2's runtime (8h12m)
-- confirmed as part-specific, not a total -- left runtime_minutes
-- NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Chris Genebach','Bradley Foster Smith','Dani Stoller','Eva Wilhelm',
    'Sura Siu','Tony Nam','Nora Achrati','Alysia Beltran','Amanda Forstrom',
    'Andrew James Spooner','Terence Aselford'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/mistborn-7-the-lost-metal-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('The Lost Metal', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: 5 parts, all independently listed. No reliable cast or
-- runtime breakdown found for this specific title -- both left NULL
-- rather than guess; existence and part count (5) are the only points
-- confirmed with confidence here.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', null, 'fully_released', 5, 5,
  'https://www.graphicaudio.net/the-stormlight-archive-1-the-way-of-kings-1-of-5.html', current_date
from books b
where (b.title, b.author) = ('The Way of Kings', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: 5 parts, all independently listed. Runtime not reliably
-- found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Zoe Badovinac','Tim Getman','Bob Payne','Casie Platt','Dylan Lynch',
    'Karen Novack','Nora Achrati','Yasmin Tuazon','Robbie Gay','Andy Clemence',
    'Chris Genebach'],
  'GraphicAudio', null, 'fully_released', 5, 5,
  'https://www.graphicaudio.net/the-stormlight-archive-2-words-of-radiance-1-of-5.html', current_date
from books b
where (b.title, b.author) = ('Words of Radiance', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: 6 parts, all independently listed. No reliable cast or
-- runtime breakdown found for this specific title -- both left NULL
-- rather than guess; existence and part count (6) are the only points
-- confirmed with confidence here.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', null, 'fully_released', 6, 6,
  'https://www.graphicaudio.net/the-stormlight-archive-3-oathbringer-1-of-6.html', current_date
from books b
where (b.title, b.author) = ('Oathbringer', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: 6 parts, all independently listed. Runtime not reliably
-- found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Michael Getz','Emlyn McFarland','Tracy Lynn Olivera','Lily Beacon',
    'Robbie Gay','Andy Clemence','Scott McCormick','Michael Glenn',
    'Chris Davenport','Richard Rohan','Terence Aselford'],
  'GraphicAudio', null, 'fully_released', 6, 6,
  'https://www.graphicaudio.net/the-stormlight-archive-4-rhythm-of-war-1-of-6.html', current_date
from books b
where (b.title, b.author) = ('Rhythm of War', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: single release (no part split found), released 2018-12-13.
-- Total runtime (~4h) confirmed directly. No reliable cast found --
-- left NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', 240, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-stormlight-archive-edgedancer.html', current_date
from books b
where (b.title, b.author) = ('Edgedancer', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: single release (no part split found), released 2024-10-23.
-- Total runtime (~5h) confirmed directly. No reliable cast found --
-- left NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', 300, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-stormlight-archive-dawnshard.html', current_date
from books b
where (b.title, b.author) = ('Dawnshard', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;
