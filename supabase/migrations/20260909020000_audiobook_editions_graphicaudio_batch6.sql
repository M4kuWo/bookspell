-- tag-audiobook-editions skill, Sub-task A / Step A2, batch 6 --
-- Researched: Throne of Glass (9 books total) and The Murderbot
-- Diaries (10 books total). Only 1 of the 9 Throne of Glass books has
-- a confirmed GraphicAudio release so far -- GraphicAudio has
-- publicly said it's "starting production" on the series, but no
-- individually confirmed release/pre-order page was found for Crown
-- of Midnight, Heir of Fire, Queen of Shadows, Empire of Storms,
-- Tower of Dawn, Kingdom of Ash, The Assassin's Blade, or The
-- Assassin and the Healer -- not inserted, not guessed at, worth a
-- re-check in a later session as that production continues. 8 of the
-- 10 Murderbot Diaries books are confirmed (Compulsory and Home:
-- Habitat, Range, Niche, Territory -- both very short prequel/
-- companion pieces -- have no confirmed GraphicAudio edition found).
-- 9 confirmed matches inserted total -- within the skill's 10-15 cap,
-- reflecting the real size of the confirmed-match pool rather than
-- padded to hit a target.

-- Direct: single release (no part split found). No reliable cast or
-- runtime found -- a secondary blog's "roughly 9 hours" figure was
-- NOT used since it wasn't confirmed against a primary listing (the
-- same caution CLAUDE.md flags for checkable specifics) -- left both
-- NULL rather than risk a wrong number.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/throne-of-glass-1-throne-of-glass.html', current_date
from books b
where (b.title, b.author) = ('Throne of Glass', 'Sarah J. Maas')
on conflict (book_id, source_url) do nothing;

-- Direct: single release, released 2023-09-12. Only one cast name
-- (the Murderbot actor) reliably confirmed for this specific title --
-- recorded as-is rather than padded with the series' broader cast.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['David Cui Cui'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-murderbot-diaries-1-all-systems-red.html', current_date
from books b
where (b.title, b.author) = ('All Systems Red', 'Martha Wells')
on conflict (book_id, source_url) do nothing;

-- Direct: single release. Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['David Cui Cui','Elena Anderson','Alejandro Ruiz','Bradley Foster Smith',
    'Carolyn Kashner','Eric Messner','Jeri Marshall','Ken Jackson',
    'Marni Penning','Michael John Casey','Rayner Gabriel','Scott McCormick',
    'Shanta Parasuraman','Yasmin Tuazon'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-murderbot-diaries-2-artificial-condition.html', current_date
from books b
where (b.title, b.author) = ('Artificial Condition', 'Martha Wells')
on conflict (book_id, source_url) do nothing;

-- Direct: single release. Runtime not reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['David Cui Cui','Julienne Irons','Natalie Van Sistine','Alejandro Ruiz',
    'Alysia Beltran','Bradley Foster Smith','Elena Anderson','Eric Messner',
    'Jenna Sharpe','Khaya Fraites','Marni Penning','Michael John Casey',
    'Scott McCormick','Yasmin Tuazon'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-murderbot-diaries-3-rogue-protocol.html', current_date
from books b
where (b.title, b.author) = ('Rogue Protocol', 'Martha Wells')
on conflict (book_id, source_url) do nothing;

-- Direct: single release, released 2023-10-26. Total runtime (2h54m)
-- confirmed directly. Cast list is partial ("and others" per source)
-- -- recorded only the specifically named subset.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['David Cui Cui','Khaya Fraites','Aure Nash','Alejandro Ruiz'],
  'GraphicAudio', 174, 'fully_released', null, null,
  'https://www.barnesandnoble.com/w/exit-strategy-dramatized-adaptation-martha-wells/1144306868', current_date
from books b
where (b.title, b.author) = ('Exit Strategy', 'Martha Wells')
on conflict (book_id, source_url) do nothing;

-- Direct: single release, released 2024-01-15. Runtime was reported
-- as "8.22 hours" by a secondary source -- genuinely ambiguous
-- whether that means 8h13m (decimal) or 8h22m (H.MM shorthand), so
-- left NULL rather than guess which reading is correct. No reliable
-- named cast found for this specific title -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  null, 'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-murderbot-diaries-5-network-effect.html', current_date
from books b
where (b.title, b.author) = ('Network Effect', 'Martha Wells')
on conflict (book_id, source_url) do nothing;

-- Direct: single release, released 2024-01-24. Total runtime (3h12m)
-- confirmed directly. Cast list is partial ("and others" per source)
-- -- recorded only the specifically named subset.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['Amanda Forstrom','Bradley Foster Smith','Chris Stinson','Christopher Walker'],
  'GraphicAudio', 192, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-murderbot-diaries-6-fugitive-telemetry.html', current_date
from books b
where (b.title, b.author) = ('Fugitive Telemetry', 'Martha Wells')
on conflict (book_id, source_url) do nothing;

-- Direct: single release, released 2024-03-04. Total runtime (~5h)
-- confirmed directly.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['David Cui Cui','Debi Tinsley','Elena Anderson'],
  'GraphicAudio', 300, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-murderbot-diaries-7-system-collapse.html', current_date
from books b
where (b.title, b.author) = ('System Collapse', 'Martha Wells')
on conflict (book_id, source_url) do nothing;

-- Direct: single release (novel published 2026-05-05, GraphicAudio
-- edition confirmed via its own graphicaudio.net product page). Only
-- one cast name (the Murderbot actor) reliably confirmed. Runtime not
-- reliably found -- left NULL.
insert into audiobook_editions
  (book_id, edition_type, narrators, production_company, runtime_minutes,
   release_status, parts_released, parts_total, source_url, last_verified_date)
select b.id, 'dramatized_full_cast',
  array['David Cui Cui'],
  'GraphicAudio', null, 'fully_released', null, null,
  'https://www.graphicaudio.net/the-murderbot-diaries-8-platform-decay.html', current_date
from books b
where (b.title, b.author) = ('Platform Decay', 'Martha Wells')
on conflict (book_id, source_url) do nothing;
