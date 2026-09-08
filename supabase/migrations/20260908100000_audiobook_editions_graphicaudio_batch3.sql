-- tag-audiobook-editions skill, Sub-task A / Step A2, batch 3 --
-- Researched: Crescent City (3), Secret Projects' remaining books
-- (Frugal Wizard's Handbook, The Sunlit Man -- Isles of the Emberdark
-- checked, no confirmed GraphicAudio edition found, skipped), and
-- Mistborn Era One (Final Empire/Well of Ascension/Hero of Ages plus
-- the Secret History/Eleventh Metal companion-story bundle). 10
-- confirmed matches inserted -- within the skill's 10-15 cap.

-- Direct: 2 parts, both independently listed. Runtime not reliably
-- found for either part -- left NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Colleen Delany','Kit Swann','Danny Montooth','Nick J. Russo','Torian Brackett',
    'Gail Shalan','Stephanie Nemeth-Parker','Gabriel Michael','Robb Moreira',
    'Debi Tinsley','Lise Bruneau','Holly Adams','Daniel Llaca','Joel David Santner',
    'Nhea Durousseau','Khaya Fraites','Michael John Casey','Henry W. Kramer',
    'Karenna Foley','Jonathon Church','Sarah Ruth Dawson','Sura Siu','Ryan Haugen',
    'Bradley Foster Smith','Christopher Williams','Emily Beresford','Karen Novack',
    'LaMont Ridgell','Rob McFadyen','Deepa Samuel','Christopher Walker','Thomas Penny',
    'Jonathan David Bullock','Jeri Marshall'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/crescent-city-1-house-of-earth-and-blood-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('House of Earth and Blood', 'Sarah J. Maas')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently listed. Only Part 1's runtime
-- (12h15m) confirmed as part-specific, not a total -- left
-- runtime_minutes NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Colleen Delany','Kit Swann','Danny Montooth','Nick J. Russo','David Cui Cui',
    'Jonathan David Bullock','Danny Gavigan','Devon Lexington','Dawn Ursula',
    'Rayner Gabriel','Sura Siu'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/crescent-city-2-house-of-sky-and-breath-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('House of Sky and Breath', 'Sarah J. Maas')
on conflict (book_id, source_url) do nothing;

-- Direct: 2 parts, both independently listed, released 2024-12-17.
-- Only Part 1's runtime (13h7m) confirmed as part-specific, not a
-- total -- left runtime_minutes NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Colleen Delany','Kit Swann','Devon Lexington','Natalie Van Sistine',
    'Jonathan David Bullock','Danny Montooth','Danny Gavigan','Debi Tinsley',
    'Robb Moreira','Nick J. Russo','Julie-Ann Elliott'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/crescent-city-3-house-of-flame-and-shadow-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('House of Flame and Shadow', 'Sarah J. Maas')
on conflict (book_id, source_url) do nothing;

-- Direct: single release (no part split found). Total runtime
-- (7h55m) confirmed directly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Elias Khalil','David Cui Cui','Helen Day','Holly Adams','Colleen Delany',
    'Nathaniel Priestley','Bradley Foster Smith','Crystal Lee','Andrew James Spooner',
    'Zeke Alton','Danny Gavigan'],
  'GraphicAudio', 475, 'fully_released', null, null,
  'https://www.graphicaudio.net/secret-projects-2-the-frugal-wizard-s-handbook-for-surviving-medieval-england.html', current_date
from books b
where (b.title, b.author) = ('The Frugal Wizard''s Handbook for Surviving Medieval England', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: single release (no part split found), released 2025-03-10.
-- Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Wyn Delano','Alexander Amado','Nanette Savard','Torian Brackett','Taylor Coan',
    'Stephanie Nemeth-Parker','Nick J. Russo','Daniel Llaca','Yasmin Tuazon',
    'Elena Anderson','David Cui Cui'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/secret-projects-4-the-sunlit-man-a-cosmere-novel.html', current_date
from books b
where (b.title, b.author) = ('The Sunlit Man', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: 3 parts, all independently listed. Runtime not reliably
-- found across all 3 parts -- left NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Terence Aselford','David Jourdan','Kimberly Gilbert','Thomas Keegan',
    'Michael John Casey','Tony Nam','Danny Gavigan','Mort Shelby','Steven Carpenter',
    'Michael Glenn','Christopher Graybill','Ken Jackson','Nick DePinto',
    'Gregory Gorton','James Lewis','Scott McCormick','Evan Casey','Richard Rohan',
    'Gary Telles','Nanette Savard','Joe Brack','Tim Getman','Alyssa Wilmoth',
    'Nathanial Perry','David Coyne'],
  'GraphicAudio', null, 'fully_released', 3, 3,
  'https://www.graphicaudio.net/mistborn-1-the-final-empire-1-of-3.html', current_date
from books b
where (b.title, b.author) = ('Mistborn: The Final Empire', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: 3 parts, all independently listed. Parts 2 and 3 each
-- independently confirmed at ~7h, but Part 1's runtime wasn't found --
-- left total runtime_minutes NULL rather than guess Part 1's length.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Nanette Savard','Richard Rohan','Nick DePinto','Joel David Santner',
    'Terence Aselford','Thomas Keegan','Tony Nam','Kimberly Gilbert',
    'Bradley Foster Smith','Danny Gavigan','Gregory Gorton'],
  'GraphicAudio', null, 'fully_released', 3, 3,
  'https://www.graphicaudio.net/mistborn-2-the-well-of-ascension-1-of-3.html', current_date
from books b
where (b.title, b.author) = ('The Well of Ascension', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: 3 parts, all independently listed. No reliable cast or
-- runtime breakdown found for this specific title -- both left NULL
-- rather than guess (existence and part count are the only points
-- confirmed with confidence here).
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', null, 'fully_released', 3, 3,
  'https://www.graphicaudio.net/mistborn-3-the-hero-of-ages-1-of-3.html', current_date
from books b
where (b.title, b.author) = ('The Hero of Ages', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Judgment call, same pattern as the Riyria-omnibus flag from Step
-- A1b: this is ONE bundled GraphicAudio release ("Mistborn: Secret
-- History, The Eleventh Metal, and Allomancer Jak and the Pits of
-- Eltania", released 2018-05-29, ~6h total) covering THREE stories,
-- only two of which are separate rows in our catalog (Allomancer Jak
-- and the Pits of Eltania is not in our catalog at all -- not
-- inserted here, nothing to attach it to). Recording as two rows
-- (one per book), both pointing at the same bundle release and both
-- with runtime_minutes left NULL since the ~6h total can't be
-- cleanly attributed per-story. No confident narrator list found
-- specifically for the Secret History portion -- left NULL rather
-- than guess; the Eleventh Metal cast below WAS specifically
-- confirmed for that story.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/mistborn-secret-history-the-eleventh-metal-and-allomancer-jak-and-the-pits-of-eltania.html', current_date
from books b
where (b.title, b.author) = ('Mistborn: Secret History', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Terence Aselford','David Jourdan','Scott McCormick','Alejandro Ruiz'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/mistborn-secret-history-the-eleventh-metal-and-allomancer-jak-and-the-pits-of-eltania.html', current_date
from books b
where (b.title, b.author) = ('The Eleventh Metal', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;
