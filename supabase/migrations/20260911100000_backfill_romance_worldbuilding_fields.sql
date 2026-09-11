-- Step 3 of the convert-romance-worldbuilding-fields skill: backfill
-- book_dna.romance_tone / book_dna.worldbuilding_delivery from the existing
-- trope-pair data, and record book_field_confidence for every book touched.
--
-- Why: Step 1 added the two nullable scalar columns (see
-- 20260909140000_add_romance_worldbuilding_fields.sql). Step 2's fresh
-- overlap re-query (run 2026-09-11 against hosted) found the SAME 5
-- dual-tagged books the skill doc's 2026-09-09 snapshot listed -- the
-- tagging sweep has not produced any new dual-tagged book in either pair
-- since then. This migration converts all 160 romance-trope-tagged and 117
-- worldbuilding-trope-tagged books (union counts, not sums -- a dual-tagged
-- book counts once) into the new scalar fields. The old book_tropes rows and
-- 'tropes' vocabulary entries for these 4 trope IDs are deliberately left in
-- place -- deleting them is Step 4, which requires live repo-owner
-- confirmation and is explicitly out of scope for this migration.
--
-- Resolution rule for the 5 dual-tagged (overlap) books, applied exactly as
-- specified in the skill doc: differing confidences -> higher-confidence
-- trope's value wins (its confidence carries over); tied confidences -> a
-- genuine 'mixed' value (confidence = the shared tied value). All 5 cases
-- below were individually verified via the fresh Step 2 query, not copied
-- from the skill doc's example table.

-- === romance_tone: single-tag books (159 = 160 union - 1 overlap) ===
update book_dna set romance_tone = 'understated'
where book_id in (
  select book_id from book_tropes where trope_id = 'understated_romance'
  except select book_id from book_tropes where trope_id = 'melodramatic_romance_subplot'
);

update book_dna set romance_tone = 'melodramatic'
where book_id in (
  select book_id from book_tropes where trope_id = 'melodramatic_romance_subplot'
  except select book_id from book_tropes where trope_id = 'understated_romance'
);

insert into book_field_confidence (book_id, field_name, confidence, source)
select bt.book_id, 'romance_tone', bt.confidence, 'ai_inferred'
from book_tropes bt
where bt.trope_id = 'understated_romance'
and bt.book_id in (
  select book_id from book_tropes where trope_id = 'understated_romance'
  except select book_id from book_tropes where trope_id = 'melodramatic_romance_subplot'
)
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select bt.book_id, 'romance_tone', bt.confidence, 'ai_inferred'
from book_tropes bt
where bt.trope_id = 'melodramatic_romance_subplot'
and bt.book_id in (
  select book_id from book_tropes where trope_id = 'melodramatic_romance_subplot'
  except select book_id from book_tropes where trope_id = 'understated_romance'
)
on conflict (book_id, field_name) do nothing;

-- === romance_tone: overlap case (1 book) ===
-- Sword of Destiny (Andrzej Sapkowski): understated 0.6 / melodramatic 0.6,
-- a genuine tie -- a short-story collection with both tones across
-- different stories. -> mixed, confidence 0.6.
update book_dna set romance_tone = 'mixed'
where book_id = (select id from books where title = 'Sword of Destiny' and author = 'Andrzej Sapkowski');

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred'
from books where title = 'Sword of Destiny' and author = 'Andrzej Sapkowski'
on conflict (book_id, field_name) do nothing;

-- === worldbuilding_delivery: single-tag books (113 = 117 union - 4 overlap) ===
update book_dna set worldbuilding_delivery = 'woven'
where book_id in (
  select book_id from book_tropes where trope_id = 'worldbuilding_woven_into_narrative'
  except select book_id from book_tropes where trope_id = 'worldbuilding_via_exposition_dump'
);

update book_dna set worldbuilding_delivery = 'exposition_dump'
where book_id in (
  select book_id from book_tropes where trope_id = 'worldbuilding_via_exposition_dump'
  except select book_id from book_tropes where trope_id = 'worldbuilding_woven_into_narrative'
);

insert into book_field_confidence (book_id, field_name, confidence, source)
select bt.book_id, 'worldbuilding_delivery', bt.confidence, 'ai_inferred'
from book_tropes bt
where bt.trope_id = 'worldbuilding_woven_into_narrative'
and bt.book_id in (
  select book_id from book_tropes where trope_id = 'worldbuilding_woven_into_narrative'
  except select book_id from book_tropes where trope_id = 'worldbuilding_via_exposition_dump'
)
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select bt.book_id, 'worldbuilding_delivery', bt.confidence, 'ai_inferred'
from book_tropes bt
where bt.trope_id = 'worldbuilding_via_exposition_dump'
and bt.book_id in (
  select book_id from book_tropes where trope_id = 'worldbuilding_via_exposition_dump'
  except select book_id from book_tropes where trope_id = 'worldbuilding_woven_into_narrative'
)
on conflict (book_id, field_name) do nothing;

-- === worldbuilding_delivery: overlap cases (4 books) ===

-- A Master of Djinn (P. Djeli Clark): woven 0.6 / exposition_dump 0.2 ->
-- higher-confidence side wins. -> woven, confidence 0.6.
update book_dna set worldbuilding_delivery = 'woven'
where book_id = (select id from books where title = 'A Master of Djinn' and author = 'P. Djèlí Clark');

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred'
from books where title = 'A Master of Djinn' and author = 'P. Djèlí Clark'
on conflict (book_id, field_name) do nothing;

-- Gideon the Ninth (Tamsyn Muir): woven 0.6 / exposition_dump 0.2 ->
-- higher-confidence side wins. -> woven, confidence 0.6.
update book_dna set worldbuilding_delivery = 'woven'
where book_id = (select id from books where title = 'Gideon the Ninth' and author = 'Tamsyn Muir');

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred'
from books where title = 'Gideon the Ninth' and author = 'Tamsyn Muir'
on conflict (book_id, field_name) do nothing;

-- Homeland (R. A. Salvatore): woven 0.6 / exposition_dump 0.2 ->
-- higher-confidence side wins. -> woven, confidence 0.6.
update book_dna set worldbuilding_delivery = 'woven'
where book_id = (select id from books where title = 'Homeland' and author = 'R. A. Salvatore');

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred'
from books where title = 'Homeland' and author = 'R. A. Salvatore'
on conflict (book_id, field_name) do nothing;

-- Mistborn: The Final Empire (Brandon Sanderson): woven 0.2 /
-- exposition_dump 0.2, a genuine tie, both weak/disputed with no clear
-- winner. -> mixed, confidence 0.2.
update book_dna set worldbuilding_delivery = 'mixed'
where book_id = (select id from books where title = 'Mistborn: The Final Empire' and author = 'Brandon Sanderson');

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.2, 'ai_inferred'
from books where title = 'Mistborn: The Final Empire' and author = 'Brandon Sanderson'
on conflict (book_id, field_name) do nothing;
