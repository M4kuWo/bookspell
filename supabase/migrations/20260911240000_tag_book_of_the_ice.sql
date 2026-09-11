-- Tags the 3 Book of the Ice books (Mark Lawrence), ingested in
-- 20260911230000_ingest_book_of_the_ice_and_abeth_universe.sql, per
-- .claude/skills/tag-catalog-batch/SKILL.md's process and CLAUDE.md's
-- HIGH_RISK_FIELDS standard.
--
-- Research grounding (real search, not pattern-matched from genre):
-- - person/pov_count for book 1: an initial general search claimed
--   "first-person" -- a MORE TARGETED follow-up search (specifically
--   checking for "she"/pronoun usage) corrected this to third-person
--   limited, tied to Yaz, single POV throughout book 1. Caught exactly
--   the kind of confidently-wrong-on-a-specific-detail error CLAUDE.md
--   warns about; the general search was simply incorrect.
-- - pov_count for books 2-3: confirmed via search that book 2
--   introduces Thurin and a third character (named inconsistently
--   across sources as "Quell"/"Quina") as co-equal POV threads
--   alongside Yaz -- 3 confirmed POV characters, `pov_count: few`.
--   Book 3 continues with Yaz/Mali/Thurin. Real residual uncertainty
--   on the exact character-name consistency across sources -- flagged
--   via book_field_confidence rather than asserted as fully certain.
-- - Tone/content: confirmed via search -- "bleak and vicious," reads
--   closer to dark YA in book 1, escalates across books 2-3; no
--   explicit sexual content across any of Lawrence's series; themes of
--   found family, self-discovery, and a society's hierarchy of whose
--   lives count.
--
-- Fields without direct research evidence (pace_shape, prose_density,
-- message_intensity, etc.) are reasoned from the well-evidenced fields
-- above and general series-consistency, not verified individually --
-- flagged via book_field_confidence where genuinely uncertain rather
-- than asserted as equally solid.

-- === Book 1: The Girl and the Stars ===
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, violence_frequency,
  violence_intensity, worldbuilding_density, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven',
  'dark', 'light', 'tense', 'moderate',
  'none', 'na', 'occasional',
  'moderate', 'dense', 'requires_series',
  'bittersweet', 'resolved', null,
  'hard', 'na', 'moderate', 'moderate',
  'moderate', 'intimate', 'life_threatening', 'moderate'
  -- genre_accessibility: prose_complexity=moderate(0.5), overall_pace=
  -- medium(0.5 inverted), worldbuilding_density=dense(1), pov_count=
  -- single(0), intellectual_weight=moderate(0.5) -> avg 0.5 -> moderate.
from books where title = 'The Girl and the Stars' and author = 'Mark Lawrence'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['coming_of_age', 'hidden_talent_prodigy', 'found_family', 'dying_earth', 'post_apocalyptic']) as t
where title = 'The Girl and the Stars' and author = 'Mark Lawrence'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('kidnapping_or_captivity', 'central_theme'), ('body_horror', 'moderate'), ('child_death', 'moderate')) as cw(w, s)
where title = 'The Girl and the Stars' and author = 'Mark Lawrence'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, f, 0.5, 'ai_inferred' from books,
  unnest(array['overall_pace', 'pace_shape', 'magic_system_hardness', 'stakes_scope', 'ends_on_cliffhanger']) as f
where title = 'The Girl and the Stars' and author = 'Mark Lawrence'
on conflict (book_id, field_name) do nothing;

-- === Book 2: The Girl and the Mountain ===
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, violence_frequency,
  violence_intensity, worldbuilding_density, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven',
  'dark', 'light', 'tense', 'moderate',
  'none', 'na', 'occasional',
  'moderate', 'dense', 'requires_series',
  'bittersweet', 'cliffhanger', null,
  'hard', 'na', 'moderate', 'moderate',
  'moderate', 'regional', 'life_threatening', 'moderate'
  -- genre_accessibility: prose_complexity=moderate(0.5), overall_pace=
  -- medium(0.5), worldbuilding_density=dense(1), pov_count=few(0.5),
  -- intellectual_weight=moderate(0.5) -> avg 0.6 -> moderate/demanding
  -- boundary; kept moderate, multi-POV alone isn't a premise-familiarity
  -- barrier.
from books where title = 'The Girl and the Mountain' and author = 'Mark Lawrence'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['coming_of_age', 'found_family', 'dying_earth', 'lost_civilizations', 'epic_quest']) as t
where title = 'The Girl and the Mountain' and author = 'Mark Lawrence'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('body_horror', 'moderate'), ('kidnapping_or_captivity', 'moderate'), ('war_trauma', 'moderate')) as cw(w, s)
where title = 'The Girl and the Mountain' and author = 'Mark Lawrence'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, f, 0.5, 'ai_inferred' from books,
  unnest(array['pov_count', 'overall_pace', 'pace_shape', 'stakes_scope']) as f
where title = 'The Girl and the Mountain' and author = 'Mark Lawrence'
on conflict (book_id, field_name) do nothing;

-- === Book 3: The Girl and the Moon ===
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, violence_frequency,
  violence_intensity, worldbuilding_density, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'few', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'character_driven',
  'dark', 'light', 'gut_punch', 'moderate',
  'none', 'na', 'frequent',
  'graphic', 'dense', 'self_contained',
  'bittersweet', 'resolved', null,
  'hard', 'na', 'moderate', 'moderate',
  'moderate', 'global', 'life_threatening', 'moderate'
  -- genre_accessibility: same computation shape as book 2 -> moderate.
  -- narrative_closure: self_contained -- confirmed via search as the
  -- trilogy's real, satisfying conclusion (not requires_series like
  -- books 1-2).
from books where title = 'The Girl and the Moon' and author = 'Mark Lawrence'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array['coming_of_age', 'found_family', 'lost_civilizations', 'epic_quest', 'ancient_evil_awakens']) as t
where title = 'The Girl and the Moon' and author = 'Mark Lawrence'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, w, s, false from books,
  (values ('body_horror', 'moderate'), ('war_trauma', 'central_theme')) as cw(w, s)
where title = 'The Girl and the Moon' and author = 'Mark Lawrence'
on conflict (book_id, warning_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, f, 0.5, 'ai_inferred' from books,
  unnest(array['pov_count', 'overall_pace', 'pace_shape', 'stakes_scope', 'violence_intensity']) as f
where title = 'The Girl and the Moon' and author = 'Mark Lawrence'
on conflict (book_id, field_name) do nothing;
