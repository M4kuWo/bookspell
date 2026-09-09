-- tag-audiobook-editions skill, Sub-task A / Step A2, BBC Audio
-- batch 2 -- researched and inserted the Hitchhiker's Guide radio
-- series (5), the Earthsea trilogy + Left Hand of Darkness (4),
-- Asimov's Foundation Trilogy (3), and Wyndham's The Day of the
-- Triffids (1) -- 13 confirmed matches, within the skill's 10-15 cap.

-- Direct: BBC Radio 4, Primary Phase, 1978, 6 episodes ("Fit the
-- First" to "Fit the Sixth"). Runtime not reliably found for just
-- this phase (only a whole-series-spanning figure exists) -- left
-- NULL rather than guess a per-phase split.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Peter Jones','Simon Jones','Geoffrey McGivern','Mark Wing-Davey',
    'Susan Sheridan','Stephen Moore'],
  'BBC Radio 4', null, 'fully_released', 6, 6,
  'https://en.wikipedia.org/wiki/The_Hitchhiker''s_Guide_to_the_Galaxy_Primary_and_Secondary_Phases', current_date
from books b
where (b.title, b.author) = ('The Hitchhiker''s Guide to the Galaxy', 'Douglas Adams')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, Secondary Phase, 1979-1980. Runtime not
-- reliably found for just this phase -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Peter Jones','Simon Jones','Geoffrey McGivern','Mark Wing-Davey','Stephen Moore'],
  'BBC Radio 4', null, 'fully_released', null, null,
  'https://www.amazon.com/Hitchhikers-Guide-Galaxy-Secondary-Collection/dp/056347789X', current_date
from books b
where (b.title, b.author) = ('The Restaurant at the End of the Universe', 'Douglas Adams')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, Tertiary Phase, broadcast 2004-09-21 to
-- 2004-10-26. Total runtime (3h10m) confirmed directly from its own
-- 3-CD release.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Simon Jones','Geoffrey McGivern','Susan Sheridan','Mark Wing-Davey',
    'Stephen Moore','Richard Griffiths','Leslie Phillips','Chris Langham',
    'Joanna Lumley','William Franklyn','Roger Gregg'],
  'BBC Radio 4', 190, 'fully_released', null, null,
  'https://www.amazon.com/Hitchhikers-Guide-Galaxy-Tertiary-Dramatized/dp/B000992AV4', current_date
from books b
where (b.title, b.author) = ('Life, the Universe and Everything', 'Douglas Adams')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, Quandary Phase, broadcast May 2005 (4
-- episodes). Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Simon Jones','Geoffrey McGivern','Stephen Moore','William Franklyn',
    'Jane Horrocks'],
  'BBC Radio 4', null, 'fully_released', 4, 4,
  'https://www.audible.com/pd/The-Hitchhikers-Guide-to-the-Galaxy-The-Quandary-Phase-Dramatized-Audiobook/B002V5BIDA', current_date
from books b
where (b.title, b.author) = ('So Long, and Thanks for All the Fish', 'Douglas Adams')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, Quintessential Phase, 2005. Runtime not
-- reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Simon Jones','Geoffrey McGivern','Stephen Moore','Mark Wing-Davey',
    'Susan Sheridan','Sandra Dickinson'],
  'BBC Radio 4', null, 'fully_released', null, null,
  'https://www.audible.com/pd/The-Hitchhikers-Guide-to-the-Galaxy-The-Quintessential-Phase-Dramatized-Audiobook/B002V8MJWQ', current_date
from books b
where (b.title, b.author) = ('Mostly Harmless', 'Douglas Adams')
on conflict (book_id, source_url) do nothing;

-- Judgment call, same pattern as the Mistborn Secret History/Eleventh
-- Metal bundle: this is ONE combined BBC Radio 4 dramatisation
-- (~3h30m total) covering all three Earthsea books in our catalog.
-- Different actors play the same character (Ged, Tenar) at different
-- ages across the three books -- attributing the full combined cast
-- list to any one book risked naming actors who don't actually
-- appear in that specific installment, so narrators left NULL for
-- all three rather than guess the per-book breakdown. Same reasoning
-- for runtime_minutes -- the 3h30m total can't be cleanly split
-- three ways.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'BBC Radio 4', null, 'fully_released', null, null,
  'https://play.google.com/store/audiobooks/details/Earthsea_BBC_Radio_4_full_cast_dramatisation?id=AQAAAAA6hmOGSM', current_date
from books b
where (b.title, b.author) = ('A Wizard of Earthsea', 'Ursula K. Le Guin')
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'BBC Radio 4', null, 'fully_released', null, null,
  'https://play.google.com/store/audiobooks/details/Earthsea_BBC_Radio_4_full_cast_dramatisation?id=AQAAAAA6hmOGSM', current_date
from books b
where (b.title, b.author) = ('The Tombs of Atuan', 'Ursula K. Le Guin')
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'BBC Radio 4', null, 'fully_released', null, null,
  'https://play.google.com/store/audiobooks/details/Earthsea_BBC_Radio_4_full_cast_dramatisation?id=AQAAAAA6hmOGSM', current_date
from books b
where (b.title, b.author) = ('The Farthest Shore', 'Ursula K. Le Guin')
on conflict (book_id, source_url) do nothing;

-- Direct: standalone BBC Radio 4 dramatisation (not part of the
-- Earthsea bundle). Total runtime (5h25m) confirmed directly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Kobna Holdbrook-Smith','Lesley Sharp','Toby Jones','Louise Brealey',
    'Noma Dumezweni','Ruth Gemmell','Adjoa Andoh','Stephen Critchlow',
    'David Acton','David Hounslow','Rhiannon Neads'],
  'BBC Radio 4', 325, 'fully_released', null, null,
  'https://www.amazon.com/Complete-Earthsea-Left-Hand-Darkness/dp/B09G7WVS64', current_date
from books b
where (b.title, b.author) = ('The Left Hand of Darkness', 'Ursula K. Le Guin')
on conflict (book_id, source_url) do nothing;

-- Judgment call, same pattern as Earthsea above: ONE continuous
-- 8-episode BBC Radio 4 serial (1973, 8 hours total) adapting all
-- three Foundation novels, with no clean per-book episode breakdown
-- confirmed. The trilogy spans generations -- specific named cast
-- members (e.g. Hari Seldon, Salvor Hardin) are book-specific
-- characters, so attributing the whole cast list to every one of the
-- 3 catalog rows risked naming actors who don't appear in that
-- specific book. Narrators and runtime_minutes left NULL for all
-- three rather than guess the split; existence and the shared source
-- are the only points confirmed with confidence per-row.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'BBC Radio 4', null, 'fully_released', null, null,
  'https://www.audible.com/pd/The-Foundation-Trilogy-Dramatized-Audiobook/B004NTZ1A8', current_date
from books b
where (b.title, b.author) = ('Foundation', 'Isaac Asimov')
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'BBC Radio 4', null, 'fully_released', null, null,
  'https://www.audible.com/pd/The-Foundation-Trilogy-Dramatized-Audiobook/B004NTZ1A8', current_date
from books b
where (b.title, b.author) = ('Foundation and Empire', 'Isaac Asimov')
on conflict (book_id, source_url) do nothing;

insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'BBC Radio 4', null, 'fully_released', null, null,
  'https://www.audible.com/pd/The-Foundation-Trilogy-Dramatized-Audiobook/B004NTZ1A8', current_date
from books b
where (b.title, b.author) = ('Second Foundation', 'Isaac Asimov')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, 1968, adapted by Giles Cooper, 6 episodes.
-- Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Gary Watson','Barbara Shelley','Peter Sallis','Peter Pratt',
    'Christopher Bidmead','David Brierley'],
  'BBC Radio 4', null, 'fully_released', 6, 6,
  'https://www.amazon.com/The-Day-Of-Triffids-John-Wyndham-audiobook/dp/B000ILYXKO', current_date
from books b
where (b.title, b.author) = ('The Day of the Triffids', 'John Wyndham')
on conflict (book_id, source_url) do nothing;
