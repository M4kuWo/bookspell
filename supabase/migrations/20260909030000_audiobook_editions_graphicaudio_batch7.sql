-- tag-audiobook-editions skill, Sub-task A / Step A2, batch 7 --
-- Researched: The Dresden Files (14 books total). GraphicAudio only
-- started this series in August 2025 and is still rolling it out
-- sequentially -- 5 of 14 books (1-5) have a confirmed release; no
-- product page or announcement was found for book 6 (Blood Rites)
-- onward. 5 confirmed matches inserted -- a genuinely thin batch
-- reflecting the real size of the confirmed pool, not padded to hit
-- a target. The remaining 9 books need a future session once
-- GraphicAudio's production catches up, not more research now.

-- Direct: single release (no part split found), released 2025-08-27.
-- Total runtime (~8h) confirmed directly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Matthew Bassett','Nora Sofyan','Nicole Perez','Brian Kim McCormick',
    'Emlyn McFarland','Christopher Walker','Gregory Linington','John Kielty',
    'Drew Kopas','Stephanie Nemeth-Parker','Christopher McLinden'],
  'GraphicAudio', 480, 'fully_released', null, null,
  'https://www.graphicaudio.net/dresden-files-1-storm-front.html', current_date
from books b
where (b.title, b.author) = ('Storm Front', 'Jim Butcher')
on conflict (book_id, source_url) do nothing;

-- Direct: single release. Runtime not reliably found -- left NULL.
-- Cast list is partial ("and many other cast members" per source) --
-- recorded only the specifically named subset.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Matthew Bassett','Nora Sofyan','Nicole Perez'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/dresden-files-2-fool-moon.html', current_date
from books b
where (b.title, b.author) = ('Fool Moon', 'Jim Butcher')
on conflict (book_id, source_url) do nothing;

-- Direct: single release. Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Matthew Bassett','Wyn Delano','Nicole Perez','Nora Achrati',
    'Gabriel Michael','Laura C. Harris','Christopher Walker','Jessica Threet',
    'Julienne Irons'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/dresden-files-3-grave-peril.html', current_date
from books b
where (b.title, b.author) = ('Grave Peril', 'Jim Butcher')
on conflict (book_id, source_url) do nothing;

-- Direct: single release. Only the lead role's actor was specifically
-- named ("full cast" generic for the rest) -- recorded as-is rather
-- than padded. Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Matthew Bassett'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/dresden-files-4-summer-knight.html', current_date
from books b
where (b.title, b.author) = ('Summer Knight', 'Jim Butcher')
on conflict (book_id, source_url) do nothing;

-- Direct: single release. No reliable cast or runtime found for this
-- specific title -- both left NULL; existence is the only point
-- confirmed with confidence here.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/dresden-files-5-death-masks.html', current_date
from books b
where (b.title, b.author) = ('Death Masks', 'Jim Butcher')
on conflict (book_id, source_url) do nothing;
