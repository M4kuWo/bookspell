-- Targeted ingestion + full Book DNA tagging: repo owner named and rated
-- both of these from memory (loved) while reviewing a recommendation
-- list; neither existed in the catalog at all before this (confirmed via
-- direct query, not just untagged). Both are genuine dark fantasy/horror
-- with real supernatural elements (Ig's literal devil horns and
-- confession-inducing power; Christmasland as a real supernatural
-- pocket-dimension reached via Manx's car) -- in scope for this
-- catalog's sci-fi/fantasy v1 scope, same treatment as other
-- horror-adjacent titles already tagged (Bird Box, Mexican Gothic,
-- Lovecraft Country). Bibliographic facts and structural fields
-- (POV count, timeline, pacing) verified via web search before tagging,
-- not assumed from memory -- per this project's standing policy on
-- newly-ingested books and HIGH_RISK_FIELDS.
insert into books (title, author, isbn, publication_year, page_count, work_type) values
  ('Horns', 'Joe Hill', '9780061147951', 2010, 376, 'novel'),
  ('NOS4A2', 'Joe Hill', '9780062200587', 2013, 692, 'novel')
on conflict do nothing;

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, violence_frequency,
  violence_intensity, worldbuilding_density, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, magic_system_hardness,
  scifi_hardness, prose_density, prose_complexity, intellectual_weight,
  stakes_scope, personal_stakes, genre_accessibility
)
select b.id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited',
  'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'character_driven',
  'dark', 'light', 'gut_punch', 'subtle',
  'rare', 'low', 'occasional',
  'graphic', 'light', 'self_contained',
  'bittersweet', 'resolved', 'soft',
  'na', 'moderate', 'accessible', 'moderate',
  'intimate', 'life_threatening', 'accessible'
from books b where b.title = 'Horns' and b.author = 'Joe Hill'
on conflict (book_id) do nothing;

insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, violence_frequency,
  violence_intensity, worldbuilding_density, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, magic_system_hardness,
  scifi_hardness, prose_density, prose_complexity, intellectual_weight,
  stakes_scope, personal_stakes, genre_accessibility
)
select b.id, array['fantasy'], 'adult', 'long', 'several', 'third_limited',
  'reliable', 'nonlinear', 'standard_prose', 'medium', 'uneven', 'plot_driven',
  'dark', 'light', 'gut_punch', 'subtle',
  'rare', 'low', 'occasional',
  'graphic', 'moderate', 'self_contained',
  'bittersweet', 'resolved', 'soft',
  'na', 'moderate', 'accessible', 'moderate',
  'intimate', 'life_threatening', 'accessible'
from books b where b.title = 'NOS4A2' and b.author = 'Joe Hill'
on conflict (book_id) do nothing;

-- Content warnings
insert into book_content_warnings (book_id, warning_id, severity)
select b.id, w.warning_id, w.severity
from books b, (values
  ('sexual_assault', 'central_theme'),
  ('body_horror', 'moderate')
) as w(warning_id, severity)
where b.title = 'Horns' and b.author = 'Joe Hill'
on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity)
select b.id, w.warning_id, w.severity
from books b, (values
  ('kidnapping_or_captivity', 'central_theme'),
  ('child_abuse', 'moderate'),
  ('body_horror', 'moderate')
) as w(warning_id, severity)
where b.title = 'NOS4A2' and b.author = 'Joe Hill'
on conflict do nothing;

-- Tropes: only tagging what's confidently supported -- 'revenge' already
-- exists as a trope (Horns' entire plot is Ig's investigation/revenge
-- against Lee for Merrin's murder). Deliberately not forcing any
-- character-archetype trope onto Manx (NOS4A2) -- an individual
-- predator preying on children doesn't cleanly fit
-- dark_lord_or_evil_overlord (usually scaled to armies/kingdoms) or
-- ancient_evil_awakens (usually a mythic/apocalyptic-scale threat), and
-- guessing would be exactly the "over-pattern-matching" failure mode
-- this project's tagging policy warns against.
insert into book_tropes (book_id, trope_id, source)
select b.id, 'revenge', 'ai_inferred'
from books b where b.title = 'Horns' and b.author = 'Joe Hill'
on conflict do nothing;

-- book_field_confidence: humor_level is a genuine lower-confidence guess
-- for both (Hill's prose voice carries dark wit even in grim material,
-- per general knowledge of his style, but not verified against
-- specific passages in either book).
insert into book_field_confidence (book_id, field_name, confidence, source)
select b.id, 'humor_level', 0.5, 'ai_inferred'
from books b where b.title in ('Horns', 'NOS4A2') and b.author = 'Joe Hill'
on conflict do nothing;
