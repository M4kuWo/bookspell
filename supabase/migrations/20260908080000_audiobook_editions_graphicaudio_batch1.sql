-- tag-audiobook-editions skill, Sub-task A / Step A2, batch 1 of
-- GraphicAudio dramatized full-cast editions. 12 confirmed matches
-- researched and inserted (11 fully released, 1 correctly recorded as
-- 'announced' rather than assumed released -- see below). Every
-- narrator list, runtime, and release status below is sourced from a
-- real search result (Audible/Amazon/GraphicAudio product listings),
-- not guessed; where a figure wasn't reliably found, runtime_minutes
-- is left NULL rather than estimated, per the skill's own instruction.
--
-- Two books (Elantris, Warbreaker) have TWO real GraphicAudio editions
-- each -- an original recording and a later "Tenth Anniversary"
-- re-recording. Only ONE edition per book is inserted here (the one
-- with the most reliable data), noted per-book below; the other
-- edition is a real gap for a future session to add as a second row
-- (this table is one-to-many on book_id by design, per the new unique
-- constraint on (book_id, source_url) added in the prior migration).

-- Direct: two parts, both released and independently listed on
-- Audible/Amazon; 25-name full cast found; "11 hours" total runtime
-- explicitly stated in a secondary source (series-set listing).
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Katie Boothe','Stewart Crank','Khaya Fraites','Wyn Delano','Eric Messner',
    'Dawn Ursula','Matthew Bassett','Robb Moreira','Torian Brackett','Julie-Ann Elliott',
    'Michael John Casey','Earl Fisher','Christopher Walker','Holly Adams',
    'Christopher Graybill','Joe Mallon','Debi Tinsley','Karenna Foley','Renee Dorian',
    'Jenna Sharpe','Rayner Gabriel','James Konicek','Rob McFadyen','Yasmin Tuazon','Drew Kopas'],
  'GraphicAudio', 660, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/blood-and-ash-1-from-blood-and-ash-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('From Blood and Ash', 'Jennifer L. Armentrout')
on conflict (book_id, source_url) do nothing;

-- Direct: single release (Innkeeper Chronicles book 5), 45-person full
-- cast confirmed via Amazon listing, runtime 11:08:20 stated directly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Nora Sofyan','Danny Gavigan','Zeke Alton','Wyn Delano','Karen Novack',
    'Elena Anderson','Terence Aselford','Gail Shalan','RJ Bayley','Robb Moreira',
    'Cody Roberts','Khaya Fraites','Crystal Lee','Marni Penning','Richard Rohan',
    'Gabriel Michael','Tony Nam','Ryan Carlo Dalusung','Chris Davenport','Shravan Amin',
    'Bradley Foster Smith','Tia Shearer','Torian Brackett','Samantha Cooper','Jon Vertullo',
    'Nicole Perez','Michael John Casey','Holly Adams','Peter Holdway','Rob McFadyen',
    'Debi Tinsley','Rose Elizabeth Supan','Mort Shelby','Charlie Albers','Elias Khalil',
    'Alejandro Ruiz','Andrew James Spooner','Aure Nash','Scott McCormick',
    'Nhea Durousseau','Eva Wilhelm','Henry W. Kramer','Morgan Dalla Betta','Helen Day',
    'Yasmin Tuazon'],
  'GraphicAudio', 668, 'fully_released', null, null,
  'https://www.graphicaudio.net/innkeeper-chronicles-5-sweep-of-the-heart.html', current_date
from books b
where (b.title, b.author) = ('Sweep of the Heart', 'Ilona Andrews')
on conflict (book_id, source_url) do nothing;

-- Direct: two parts, both released and independently listed. Runtime
-- not reliably found -- left NULL rather than guessed.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Terence Aselford','Colleen Delany','Eric Messner','Todd Scofield',
    'Amanda Forstrom','Jessica Lauren Ball','Nanette Savard','Thomas Keegan',
    'Yasmin Tuazon','Richard Rohan','Nora Achrati','Bradley Smith','Carolyn Kashner',
    'Chris Genebach','Chris Stinson','David Jourdan','Ken Jackson','Kimberly Gilbert',
    'Lily Beacon','Lise Bruneau','Matthew Keenan'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/the-legends-of-the-first-empire-1-age-of-myth-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('Age of Myth', 'Michael J. Sullivan')
on conflict (book_id, source_url) do nothing;

-- Direct: two parts, both released and independently listed. One
-- source stated "8 hours" but didn't make clear whether that's
-- per-part or the combined total -- left runtime_minutes NULL rather
-- than risk recording a wrong total.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Chris Stinson','Holly Adams','Lise Bruneau','Lydia Kraniotis','Nazia Chaudhry',
    'Rose Supan','Scott McCormick','Wyn Delano','Kay Eluvian','Gabriel Michael',
    'Valentina Vinci'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/terra-ignota-1-too-like-the-lightning-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('Too Like the Lightning', 'Ada Palmer')
on conflict (book_id, source_url) do nothing;

-- Direct: single release (July 2024), large confirmed cast via Amazon
-- listing. Runtime not reliably found (only a 59-minute free sample
-- clip was confirmed) -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Nora Achrati','Ryan Dalusung','Lydia Kraniotis','Jessica Schly','Gabriel Michael',
    'Karenna Foley','Julian Dailey','Daniel Llaca','Jon Vertullo','Gregory Linnington',
    'Khaya Fraites','Kelly Baskin','Stephanie Nemeth-Parker','Crystal Lee','Dawn Ursula',
    'Lise Bruneau','Kaylee Eluvian','Marissa Clay','Bradley Foster Smith',
    'Michael John Casey','Ken Jackson','Tyler Hyrchuk'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/zodiac-academy-1-the-awakening.html', current_date
from books b
where (b.title, b.author) = ('Zodiac Academy: The Awakening', 'Caroline Peckham, Susanne Valenti')
on conflict (book_id, source_url) do nothing;

-- Direct, but a real judgment call: GraphicAudio has TWO Elantris
-- editions -- the original 2010-era "1 of 3" recording, and a newer
-- "Tenth Anniversary Author's Definitive Edition" (2 parts, ~2025) that
-- appears to be their current standard release. Recording the Tenth
-- Anniversary edition as primary since it's the one actively sold now.
-- Part 1's runtime (13h25m) is confirmed via Audible, but Part 2's
-- isn't -- left runtime_minutes NULL rather than record a partial/
-- guessed total. The original 3-part edition is a real gap for a
-- future session to add as a second row on this same book.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['James Konicek','Danny Gavigan','Jenna Sharpe','Thomas Penny','Richard Rohan',
    'Mort Shelby','Steven Carpenter','Wyn Delano','Christopher Williams','Anthony Palmini',
    'Megan Dominy','Tony Nam','Terence Aselford'],
  'GraphicAudio', null, 'fully_released', 2, 2,
  'https://www.graphicaudio.net/elantris-tenth-anniversary-author-s-definitive-edition-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('Elantris', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: single release (2017-05-16), full cast confirmed, runtime
-- 38:41 stated directly (rounded to 39 minutes).
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Colleen Delany','Kimberly Gilbert','Mort Shelby','James Lewis','Richard Rohan',
    'Michael John Casey','Danny Gavigan','Tracy Lynn Olivera','Eric Messner',
    'Nanette Savard','Chris Davenport','Evan Casey','Scott McCormick','Ken Jackson',
    'Tim Lynch','Thomas Penny','Rose Elizabeth Supan'],
  'GraphicAudio', 39, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-hope-of-elantris.html', current_date
from books b
where (b.title, b.author) = ('The Hope of Elantris', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: single release, full cast confirmed, runtime 3h31m stated
-- directly (211 minutes). Won a Hugo Award for Best Novella (2013) --
-- noted for interest, not a data field.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Colleen Delany','Kimberly Gilbert','Mort Shelby','Nora Achrati','Thomas Keegan',
    'Chris Genebach','Jacob Yeh','Bradley Smith','Lise Bruneau','Henry Kramer',
    'Scott McCormick','Nanette Savard','Terence Aselford','Ken Jackson',
    'Michael John Casey','Michael Glenn','Dani Stoller','Eric Messner','Nathanial Perry'],
  'GraphicAudio', 211, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-emperor-s-soul.html', current_date
from books b
where (b.title, b.author) = ('The Emperor''s Soul', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;

-- Direct: single release, full cast confirmed via Amazon listing.
-- Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Nora Sofyan','Michael Glenn','Steven Carpenter','Christopher Walker',
    'Bradley Foster Smith','Robb Moreira','Mort Shelby','Rose Elizabeth Supan',
    'Henry W. Kramer','Ken Jackson','Chris Davenport'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/kate-daniels-1-magic-bites.html', current_date
from books b
where (b.title, b.author) = ('Magic Bites', 'Ilona Andrews')
on conflict (book_id, source_url) do nothing;

-- Direct: single release, full cast confirmed via Amazon listing.
-- Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Nora Sofyan','Michael Glenn','Danny Gavigan','Kelly Baskin','Robb Moreira',
    'Chris Davenport','Emlyn McFarland','Dawn Ursula','KenYatta Rogers','Drew Kopas',
    'Eva Wilhelm','Jonathan Lee Taylor','Tia Shearer','Ken Jackson',
    'Bradley Foster Smith','Yasmin Tuazon','Tony Nam','Earl Fisher','Tanja Milojevic',
    'Ryan Carlo Dalusung','Sheree Wichard','Jacob Yeh','Michael John Casey',
    'K''Lai Rivera','Bianca Bryan','Colleen Delany','Debi Tinsley','Christopher Walker',
    'Alejandro Ruiz'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/kate-daniels-2-magic-burns.html', current_date
from books b
where (b.title, b.author) = ('Magic Burns', 'Ilona Andrews')
on conflict (book_id, source_url) do nothing;

-- Real catch: GraphicAudio has ANNOUNCED this as a pre-order, NOT
-- released. A GraphicAudio X/Twitter post explicitly titled "Pre-Order
-- Announcement!" and Amazon listings give Part 1's release date as
-- 2026-10-30 and Part 2's as 2027-01-07 -- both in the future relative
-- to today (2026-09-08). Recording this honestly as 'announced' with
-- parts_released=0 rather than assuming 'fully_released' the way the
-- rest of this batch's confirmed-out editions are -- exactly the kind
-- of release-status trap the skill's own Wind and Truth precedent
-- warns about. No individual narrator names were found (only "Full
-- Cast" generically) -- left NULL rather than guess.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast', null,
  'GraphicAudio', null, 'announced', 0, 2,
  'https://www.graphicaudio.net/the-sun-eater-1-empire-of-silence-1-of-2.html', current_date
from books b
where (b.title, b.author) = ('Empire of Silence', 'Christopher Ruocchio')
on conflict (book_id, source_url) do nothing;

-- Direct, another judgment call like Elantris above: GraphicAudio has
-- TWO Warbreaker editions -- the original "1 of 3"/"2 of 3"/"3 of 3"
-- recording (all three parts independently confirmed via Amazon
-- listings, so genuinely fully released) and a newer "Tenth
-- Anniversary Edition" (2-part re-recording) whose own completion
-- status and runtime weren't confirmed. Recording the original,
-- fully-confirmed 3-part edition as primary; the Tenth Anniversary
-- re-recording is a real gap for a future session to add as a second
-- row once its release status and runtime can be confirmed.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Dylan Lynch','Elizabeth Jernigan','Colleen Delany','James Konicek','Tim Getman',
    'Steven Carpenter','Ren Casey','David Coyne','Richard Rohan','Ken Jackson',
    'Amanda Thickpenny','Karen Carbone','Christopher Graybill','Scott McCormick'],
  'GraphicAudio', null, 'fully_released', 3, 3,
  'https://www.graphicaudio.net/warbreaker-1-of-3.html', current_date
from books b
where (b.title, b.author) = ('Warbreaker', 'Brandon Sanderson')
on conflict (book_id, source_url) do nothing;
