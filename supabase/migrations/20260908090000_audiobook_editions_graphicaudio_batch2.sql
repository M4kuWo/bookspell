-- tag-audiobook-editions skill, Sub-task A / Step A2, batch 2 --
-- CUT SHORT by this session's web search budget cap (200/200 calls
-- used partway through researching Crescent City after finishing the
-- A Court of Thorns and Roses series). Only the 5 fully-researched
-- ACOTAR books are inserted here -- did NOT fabricate/guess data for
-- Crescent City (House of Earth and Blood / Sky and Breath / Flame and
-- Shadow) or Secret Projects' remaining 3 books, which were queued for
-- this same batch but never reached. Same discipline as the
-- 2026-09-07 "romance_tone batch 10, cut short by search cap"
-- precedent (see project-log.md) -- stop and report the real blocker
-- rather than quietly degrading quality.

-- Direct: 2 parts, both independently listed, released 2022-05-01.
-- Total runtime (11h55m) stated directly for the book as a whole.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Melody Muze','Henry W. Kramer','Gabriel Michael','Natalie Van Sistine',
    'Debi Tinsley','Bradley Foster Smith','Karen Novack','Alejandro Ruiz',
    'Christopher Graybill','Julie Hoverson','Karen Foley','Eric Messner'],
  'GraphicAudio', 715, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/a-court-of-thorns-and-roses-1-a-court-of-thorns-and-roses-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('A Court of Thorns and Roses', 'Sarah J. Maas')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently listed, released 2022-06-01.
-- Only Part 1's runtime (8h26m) was confirmed as part-specific, not a
-- total -- left runtime_minutes NULL rather than guess the total.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Amanda Forstrom','Holly Adams','Nora Achrati','Anthony Palmini',
    'Henry W. Kramer','Natalie Van Sistine','Megan Dominy','Gabriel Michael',
    'Melody Muze','Shawn K. Jain','Jon Vertullo'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.audible.com/pd/A-Court-of-Mist-and-Fury-Part-1-of-2-Dramatized-Adaptation-Audiobook/B09YGG792Q', current_date
from books b
where (b.title, b.author) = ('A Court of Mist and Fury', 'Sarah J. Maas')
on conflict (book_id, source_url) do nothing;

-- Direct: 3 parts, all independently listed, released 2022-08-15.
-- Total runtime (18h42m) directly confirmed with a clean per-part
-- breakdown (6h11 + 6h31 + 6h00) that sums correctly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Melody Muze','Anthony Palmini','Gabriel Michael','Jon Vertullo','Nora Achrati',
    'Amanda Forstrom','Henry W. Kramer','Shawn K. Jain','Megan Dominy',
    'Natalie Van Sistine','Stephanie Nemeth-Parker','Ryan Haugen','Debi Tinsley',
    'Troy Allan','Matthew Bassett','Karenna Foley','Michael John Casey',
    'Yasmin Tuazon','Eric Messner','Karen Novack','Bradley Foster Smith',
    'Ann Flandermeyer','Christopher Williams'],
  'GraphicAudio', 1122, 'fully_released', 3, 3,
  'https://www.amazon.com/Court-Wings-Ruin-Dramatized-Adaptation/dp/B0B75W9KPK', current_date
from books b
where (b.title, b.author) = ('A Court of Wings and Ruin', 'Sarah J. Maas')
on conflict (book_id, source_url) do nothing;

-- Direct: single release (no part split found), released 2023-03-01.
-- Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Melody Muze','Anthony Palmini','Colleen Delany','Jon Vertullo','Amanda Forstrom',
    'Shawn K. Jain','Nora Achrati','Karenna Foley','Gabriel Michael','Natalie Van Sistine',
    'Eva Wilhelm','Henry W. Kramer','Bianca Bryan','Renee Dorian','Matthew Bassett',
    'Rob McFadyen','Ryan Carlo Dalusung','Yasmin Tuazon','Matthew Schleigh',
    'Nanette Savard','Dan Delgado','Michael John Casey','Alejandro Ruiz','Samantha Cooper'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/a-court-of-thorns-and-roses-a-court-of-frost-and-starlight.html', current_date
from books b
where (b.title, b.author) = ('A Court of Frost and Starlight', 'Sarah J. Maas')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently listed. Only Part 2's runtime
-- (10h33m) was confirmed as part-specific, not a total -- left
-- runtime_minutes NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Colleen Delany','Natalie Van Sistine','Jon Vertullo','Aure Nash',
    'Anthony Palmini','Melody Muze','Renee Dorian','Shawn K. Jain'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/a-court-of-thorns-and-roses-4-a-court-of-silver-flames-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('A Court of Silver Flames', 'Sarah J. Maas')
on conflict (book_id, source_url) do nothing;
