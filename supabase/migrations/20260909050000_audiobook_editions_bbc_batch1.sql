-- tag-audiobook-editions skill, Sub-task A / Step A2, BBC Audio
-- batch 1 -- first BBC Audio insert batch, following Step A1a/A1b's
-- 39-title pull / 31-confirmed-match cross-reference this session.
-- Researched and inserted the Pratchett/Discworld + Good Omens +
-- Neverwhere + His Dark Materials group (11 confirmed matches) --
-- within the skill's 10-15 cap. `edition_type` uses the same
-- 'dramatized_full_cast' value as GraphicAudio's rows since these are
-- genuinely the same kind of thing (a full-cast dramatized
-- adaptation), just a different producer.

-- Direct: BBC Radio 4, 1992, 6 episodes. Runtime not reliably found --
-- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['John Wood','Stephen Thorne','Melvyn Hayes','Robert Gwilym',
    'Crawford Logan','Helen Atkinson-Wood','Michael Roberts','Jeff Nuttall'],
  'BBC Radio 4', null, 'fully_released', 6, 6,
  'https://www.comedy.co.uk/radio/terry_pratchetts_guards_guards/', current_date
from books b
where (b.title, b.author) = ('Guards! Guards!', 'Terry Pratchett')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, 1995, 4 episodes. Runtime not reliably found --
-- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Lynda Baron','Deborah Berlin','Sheila Hancock','Andrew Branch','John Hartley'],
  'BBC Radio 4', null, 'fully_released', 4, 4,
  'https://www.comedy.co.uk/radio/terry_pratchetts_wyrd_sisters/', current_date
from books b
where (b.title, b.author) = ('Wyrd Sisters', 'Terry Pratchett')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4. Episode count and runtime not reliably found --
-- left NULL; cast is specifically confirmed for this title.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Geoffrey Whitehead','Carl Prekopp','Philip Jackson','Clare Corbett',
    'Alice Hart','Adam Godley','Anton Lesser'],
  'BBC Radio 4', null, 'fully_released', null, null,
  'https://www.comedy.co.uk/radio/terry_pratchetts_mort/', current_date
from books b
where (b.title, b.author) = ('Mort', 'Terry Pratchett')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, first broadcast February 2006, 4 episodes.
-- Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Anton Lesser','Patrick Barlow','Carl Prekopp','Alex Jennings',
    'Geoffrey Beevers','Philip Fox','Sean Barrett','Gerard McDermott',
    'John Cummins','Nick Sayce'],
  'BBC Radio 4', null, 'fully_released', 4, 4,
  'https://www.comedy.co.uk/radio/terry_pratchetts_small_gods/', current_date
from books b
where (b.title, b.author) = ('Small Gods', 'Terry Pratchett')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, 5-part adaptation. Runtime not reliably found
-- -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Philip Jackson','Carl Prekopp','Paul Ritter','Sam Dale','Ben Onwukwe'],
  'BBC Radio 4', null, 'fully_released', 5, 5,
  'https://www.comedy.co.uk/radio/terry_pratchetts_night_watch/', current_date
from books b
where (b.title, b.author) = ('Night Watch', 'Terry Pratchett')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4. Episode count and runtime not reliably found
-- -- left NULL; cast is specifically confirmed for this title.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Mark Heap','Will Howard','Geoffrey Whitehead','Robert Blythe','Rick Warden'],
  'BBC Radio 4', null, 'fully_released', null, null,
  'https://www.comedy.co.uk/radio/terry_pratchett_eric/', current_date
from books b
where (b.title, b.author) = ('Eric', 'Terry Pratchett')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, broadcast 2014-12-22 to 2014-12-27, 6 episodes
-- (five 30-minute + one hour-long finale). Total runtime (~2h30m)
-- confirmed directly from the episode breakdown.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Mark Heap','Peter Serafinowicz','Jim Norton','Adam Thomas Wright',
    'Josie Lawrence','Charlotte Ritchie','Colin Morgan','Clive Russell',
    'Julia Deakin'],
  'BBC Radio 4', 150, 'fully_released', 6, 6,
  'https://www.amazon.com/Good-Omens-audiobook/dp/B00S999ED8', current_date
from books b
where (b.title, b.author) = ('Good Omens: The Nice and Accurate Prophecies of Agnes Nutter, Witch', 'Neil Gaiman, Terry Pratchett')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4, 2013 (Dirk Maggs adaptation). Total runtime
-- (3h48m, includes 25+ min of bonus unbroadcast material) confirmed
-- directly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['David Harewood','Sophie Okonedo','Benedict Cumberbatch','Christopher Lee',
    'Anthony Head','David Schofield','James McAvoy','Natalie Dormer'],
  'BBC Radio 4', 228, 'fully_released', null, null,
  'https://www.amazon.com/Neverwhere-BBC-Radio-Full-Cast-Dramatisation/dp/B00ELIKX9K', current_date
from books b
where (b.title, b.author) = ('Neverwhere', 'Neil Gaiman')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4 full-cast dramatisation of book 1 of the His
-- Dark Materials trilogy (published in the UK as "Northern Lights",
-- the title our catalog's US edition "The Golden Compass" is the same
-- book as). Runtime not reliably found for this specific installment
-- -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Lulu Popplewell','Terence Stamp','Bill Paterson','Kenneth Cranham',
    'Adrian Scarborough'],
  'BBC Radio 4', null, 'fully_released', null, null,
  'https://www.amazon.com/His-Dark-Materials-Collection-Dramatisations/dp/B09CFTWR3V', current_date
from books b
where (b.title, b.author) = ('The Golden Compass', 'Philip Pullman')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4 full-cast dramatisation of book 2. Total
-- runtime (150 min) confirmed directly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Lulu Popplewell','Terence Stamp','Bill Paterson','Kenneth Cranham',
    'Adrian Scarborough'],
  'BBC Radio 4', 150, 'fully_released', null, null,
  'https://www.penguin.com.au/books/his-dark-materials-part-2-the-subtle-knife-radio-full-cast-dramatisation-9781405694155', current_date
from books b
where (b.title, b.author) = ('The Subtle Knife', 'Philip Pullman')
on conflict (book_id, source_url) do nothing;

-- Direct: BBC Radio 4 full-cast dramatisation of book 3. A secondary
-- source mentioned it's "divided into two parts" but didn't confirm
-- whether that's the drama's real broadcast structure or just a
-- packaging split -- left parts_released/parts_total NULL rather than
-- guess which. Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Lulu Popplewell','Terence Stamp','Bill Paterson','Kenneth Cranham',
    'Adrian Scarborough'],
  'BBC Radio 4', null, 'fully_released', null, null,
  'https://www.amazon.com/His-Dark-Materials-Collection-Dramatisations/dp/B09CFTWR3V', current_date
from books b
where (b.title, b.author) = ('The Amber Spyglass', 'Philip Pullman')
on conflict (book_id, source_url) do nothing;
