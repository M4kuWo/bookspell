-- Catalog tagging batch: 20 CLDA-screened books (round-4 pool)
-- Includes: 2 author-field contamination fixes verified via Hardcover cached_contributors
-- (Alcatraz vs. the Evil Librarians: 'Hayley Lazo' is the book's Illustrator, not a co-author;
-- Cursed Bunny: 'Anton Hur' is Bora Chung's English translator, not a co-author).
-- Tagged by CLDA session, 2026-09-17. See docs/project-log.md for full batch report.

-- Author-field contamination fixes (verified via Hardcover cached_contributors GraphQL API)
update books set author = 'Brandon Sanderson' where title = 'Alcatraz vs. the Evil Librarians' and author = 'Brandon Sanderson, Hayley Lazo';
update books set author = 'Bora Chung' where title = 'Cursed Bunny' and author = 'Bora Chung, Anton Hur';

-- A Fate Inked in Blood
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'moderate', 'light', 'tense', 'subtle', 'frequent', 'explicit', null, 'occasional', 'graphic', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'accessible'
from books where title = 'A Fate Inked in Blood';

insert into book_tropes (book_id, trope_id) select id, 'arranged_marriage' from books where title = 'A Fate Inked in Blood';
insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'A Fate Inked in Blood';
insert into book_tropes (book_id, trope_id) select id, 'forced_proximity' from books where title = 'A Fate Inked in Blood';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'A Fate Inked in Blood';
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'A Fate Inked in Blood';
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'A Fate Inked in Blood';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'A Fate Inked in Blood';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'A Fate Inked in Blood';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'A Fate Inked in Blood';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'A Fate Inked in Blood' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'A Fate Inked in Blood' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'A Fate Inked in Blood' on conflict (book_id, field_name) do nothing;


-- A House With Good Bones
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'dark', 'moderate', 'tense', 'moderate', 'none', 'na', null, 'rare', 'moderate', 'light', null, 'self_contained', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'A House With Good Bones';

insert into book_tropes (book_id, trope_id, confidence, source) select id, 'ghost_sight', 0.6, 'ai_inferred' from books where title = 'A House With Good Bones';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'shadow_self_confrontation', 0.4, 'ai_inferred' from books where title = 'A House With Good Bones';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'A House With Good Bones';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'racism_depicted', 'moderate', true from books where title = 'A House With Good Bones';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'A House With Good Bones';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'A House With Good Bones' on conflict (book_id, field_name) do nothing;


-- A River Enchanted
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'standard', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'balanced', 'moderate', 'light', 'bittersweet', 'subtle', 'rare', 'closed_door', null, 'rare', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'standard', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'moderate', 'moderate'
from books where title = 'A River Enchanted';

insert into book_tropes (book_id, trope_id) select id, 'friends_to_lovers' from books where title = 'A River Enchanted';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'A River Enchanted';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'mythological_pantheon_as_characters', 0.4, 'ai_inferred' from books where title = 'A River Enchanted';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'found_family', 0.4, 'ai_inferred' from books where title = 'A River Enchanted';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'underdog_rising', 0.3, 'ai_inferred' from books where title = 'A River Enchanted';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'A River Enchanted';


-- Alcatraz vs. the Evil Librarians
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'middle_grade', 'short', 'single', 'first', 'unreliable', 'linear', 'framing_device', 'fast', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'moderate', 'none', 'na', null, 'occasional', 'mild', 'moderate', 'exposition_dump', 'requires_series', 'happy', 'resolved', 'short', 'hard', 'na', 'sparse', 'accessible', 'escapist', 'global', 'moderate', 'gateway'
from books where title = 'Alcatraz vs. the Evil Librarians';

insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'Alcatraz vs. the Evil Librarians';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Alcatraz vs. the Evil Librarians';
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'Alcatraz vs. the Evil Librarians';
insert into book_tropes (book_id, trope_id) select id, 'secret_magical_bureaucracy' from books where title = 'Alcatraz vs. the Evil Librarians';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Alcatraz vs. the Evil Librarians';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Alcatraz vs. the Evil Librarians';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'form', 0.5, 'ai_inferred' from books where title = 'Alcatraz vs. the Evil Librarians' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.5, 'ai_inferred' from books where title = 'Alcatraz vs. the Evil Librarians' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'Alcatraz vs. the Evil Librarians' on conflict (book_id, field_name) do nothing;


-- Allomancer Jak and the Pits of Eltania
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'short', 'single', 'first', 'unreliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'light', 'heavy', 'comfort_read', 'subtle', 'rare', 'low', null, 'occasional', 'mild', 'light', null, 'self_contained', 'happy', 'resolved', 'short', 'hard', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'moderate', 'gateway'
from books where title = 'Allomancer Jak and the Pits of Eltania';

insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'Allomancer Jak and the Pits of Eltania';
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Allomancer Jak and the Pits of Eltania';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'Allomancer Jak and the Pits of Eltania' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.6, 'ai_inferred' from books where title = 'Allomancer Jak and the Pits of Eltania' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'Allomancer Jak and the Pits of Eltania' on conflict (book_id, field_name) do nothing;


-- Belladonna
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'balanced', 'moderate', 'light', 'bittersweet', 'subtle', 'occasional', 'low', null, 'occasional', 'moderate', 'light', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'intimate', 'high', 'gateway'
from books where title = 'Belladonna';

insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Belladonna';
insert into book_tropes (book_id, trope_id) select id, 'love_triangle' from books where title = 'Belladonna';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'noir_detective_structure', 0.4, 'ai_inferred' from books where title = 'Belladonna';
insert into book_tropes (book_id, trope_id) select id, 'anthropomorphic_personification_protagonist' from books where title = 'Belladonna';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Belladonna';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', false from books where title = 'Belladonna';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.4, 'ai_inferred' from books where title = 'Belladonna' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'Belladonna' on conflict (book_id, field_name) do nothing;


-- Book of Night
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'nonlinear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'plot_driven', 'dark', 'light', 'tense', 'subtle', 'occasional', 'low', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'intimate', 'high', 'moderate'
from books where title = 'Book of Night';

insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Book of Night';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'Book of Night';
insert into book_tropes (book_id, trope_id) select id, 'urban_fantasy_setting' from books where title = 'Book of Night';
insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'Book of Night';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'twist_ending', 0.4, 'ai_inferred' from books where title = 'Book of Night';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'Book of Night' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'Book of Night' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrative_closure', 0.3, 'ai_inferred' from books where title = 'Book of Night' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'Book of Night' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'Book of Night' on conflict (book_id, field_name) do nothing;


-- Cemetery Boys
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'balanced', 'moderate', 'moderate', 'bittersweet', 'moderate', 'rare', 'closed_door', 'understated', 'rare', 'moderate', 'light', 'woven', 'self_contained', 'happy', 'resolved', 'standard', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'high', 'accessible'
from books where title = 'Cemetery Boys';

insert into book_tropes (book_id, trope_id) select id, 'ghost_sight' from books where title = 'Cemetery Boys';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'noir_detective_structure', 0.4, 'ai_inferred' from books where title = 'Cemetery Boys';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Cemetery Boys';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Cemetery Boys';
insert into book_tropes (book_id, trope_id) select id, 'mlm_romance' from books where title = 'Cemetery Boys';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', true from books where title = 'Cemetery Boys';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.4, 'ai_inferred' from books where title = 'Cemetery Boys' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.4, 'ai_inferred' from books where title = 'Cemetery Boys' on conflict (book_id, field_name) do nothing;


-- City of Dragons
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', 'understated', 'occasional', 'moderate', 'dense', 'woven', 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'high', 'demanding'
from books where title = 'City of Dragons';

insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'City of Dragons';
insert into book_tropes (book_id, trope_id) select id, 'telepathic_animal_bond' from books where title = 'City of Dragons';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'City of Dragons';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'mlm_romance', 0.5, 'ai_inferred' from books where title = 'City of Dragons';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'City of Dragons';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'City of Dragons';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'City of Dragons';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'City of Dragons' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.4, 'ai_inferred' from books where title = 'City of Dragons' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'City of Dragons' on conflict (book_id, field_name) do nothing;


-- Dragon Haven
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', 'understated', 'occasional', 'moderate', 'dense', 'woven', 'requires_series', 'bittersweet', 'cliffhanger', 'long', 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'high', 'demanding'
from books where title = 'Dragon Haven';

insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'Dragon Haven';
insert into book_tropes (book_id, trope_id) select id, 'telepathic_animal_bond' from books where title = 'Dragon Haven';
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Dragon Haven';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'mlm_romance', 0.5, 'ai_inferred' from books where title = 'Dragon Haven';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Dragon Haven';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'moderate', false from books where title = 'Dragon Haven';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'Dragon Haven';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'Dragon Haven' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.4, 'ai_inferred' from books where title = 'Dragon Haven' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'Dragon Haven' on conflict (book_id, field_name) do nothing;


-- City of Last Chances
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'plot_driven', 'dark', 'light', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'graphic', 'dense', 'woven', 'self_contained', 'ambiguous', 'resolved', 'long', 'soft', 'na', 'lush', 'dense', 'cerebral', 'regional', 'high', 'veteran_only'
from books where title = 'City of Last Chances';

insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'City of Last Chances';
insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'City of Last Chances';
insert into book_tropes (book_id, trope_id) select id, 'infiltration_or_undercover_plot' from books where title = 'City of Last Chances';
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'City of Last Chances';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'City of Last Chances';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'City of Last Chances';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'City of Last Chances';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'City of Last Chances' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'timeline', 0.4, 'ai_inferred' from books where title = 'City of Last Chances' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrative_closure', 0.3, 'ai_inferred' from books where title = 'City of Last Chances' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'City of Last Chances' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.4, 'ai_inferred' from books where title = 'City of Last Chances' on conflict (book_id, field_name) do nothing;


-- Cursed Bunny
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'mixed', 'ambiguous', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'heavy_handed', 'none', 'na', null, 'frequent', 'brutal', 'light', null, 'self_contained', 'ambiguous', 'resolved', 'standard', 'soft', 'na', 'sparse', 'moderate', 'cerebral', 'intimate', 'high', 'moderate'
from books where title = 'Cursed Bunny';

insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Cursed Bunny';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'cosmic_horror', 0.3, 'ai_inferred' from books where title = 'Cursed Bunny';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'shadow_self_confrontation', 0.4, 'ai_inferred' from books where title = 'Cursed Bunny';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'twist_filled', 0.4, 'ai_inferred' from books where title = 'Cursed Bunny';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', false from books where title = 'Cursed Bunny';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Cursed Bunny';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.3, 'ai_inferred' from books where title = 'Cursed Bunny' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'Cursed Bunny' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.4, 'ai_inferred' from books where title = 'Cursed Bunny' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'timeline', 0.3, 'ai_inferred' from books where title = 'Cursed Bunny' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pace_shape', 0.4, 'ai_inferred' from books where title = 'Cursed Bunny' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.3, 'ai_inferred' from books where title = 'Cursed Bunny' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'message_intensity', 0.4, 'ai_inferred' from books where title = 'Cursed Bunny' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'violence_intensity', 0.5, 'ai_inferred' from books where title = 'Cursed Bunny' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.3, 'ai_inferred' from books where title = 'Cursed Bunny' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'prose_density', 0.3, 'ai_inferred' from books where title = 'Cursed Bunny' on conflict (book_id, field_name) do nothing;


-- Dance of Thieves
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'ya', 'standard', 'dual', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'moderate', 'moderate', 'tense', 'subtle', 'occasional', 'moderate', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'cliffhanger', 'standard', 'na', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'accessible'
from books where title = 'Dance of Thieves';

insert into book_tropes (book_id, trope_id) select id, 'enemies_to_lovers' from books where title = 'Dance of Thieves';
insert into book_tropes (book_id, trope_id) select id, 'heist' from books where title = 'Dance of Thieves';
insert into book_tropes (book_id, trope_id) select id, 'forced_proximity' from books where title = 'Dance of Thieves';
insert into book_tropes (book_id, trope_id) select id, 'crime_family_saga' from books where title = 'Dance of Thieves';
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Dance of Thieves';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Dance of Thieves';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.6, 'ai_inferred' from books where title = 'Dance of Thieves' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'Dance of Thieves' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Dance of Thieves' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'Dance of Thieves' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.3, 'ai_inferred' from books where title = 'Dance of Thieves' on conflict (book_id, field_name) do nothing;


-- Delirium
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['sci_fi'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'romance_driven', 'moderate', 'none', 'bittersweet', 'heavy_handed', 'rare', 'closed_door', null, 'rare', 'moderate', 'moderate', 'exposition_dump', 'requires_series', 'tragic', 'cliffhanger', 'standard', 'na', 'soft', 'lush', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'Delirium';

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Delirium';
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Delirium';
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Delirium';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Delirium';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', true from books where title = 'Delirium';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.6, 'ai_inferred' from books where title = 'Delirium' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.4, 'ai_inferred' from books where title = 'Delirium' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'Delirium' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'Delirium' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'scifi_hardness', 0.4, 'ai_inferred' from books where title = 'Delirium' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'prose_density', 0.3, 'ai_inferred' from books where title = 'Delirium' on conflict (book_id, field_name) do nothing;


-- Emergency Skin
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'second', 'unreliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'heavy_handed', 'none', 'na', null, 'rare', 'mild', 'light', 'exposition_dump', 'self_contained', 'ambiguous', 'resolved', 'short', 'na', 'soft', 'sparse', 'moderate', 'cerebral', 'global', 'high', 'accessible'
from books where title = 'Emergency Skin';

insert into book_tropes (book_id, trope_id) select id, 'post_scarcity_utopia' from books where title = 'Emergency Skin';
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'Emergency Skin';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'satirical_or_comedic_scifi', 0.4, 'ai_inferred' from books where title = 'Emergency Skin';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'moderate', false from books where title = 'Emergency Skin';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.7, 'ai_inferred' from books where title = 'Emergency Skin' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'Emergency Skin' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.4, 'ai_inferred' from books where title = 'Emergency Skin' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_resolution', 0.4, 'ai_inferred' from books where title = 'Emergency Skin' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.3, 'ai_inferred' from books where title = 'Emergency Skin' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'scifi_hardness', 0.4, 'ai_inferred' from books where title = 'Emergency Skin' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.4, 'ai_inferred' from books where title = 'Emergency Skin' on conflict (book_id, field_name) do nothing;


-- Evershore
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['sci_fi'], 'ya', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'short', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'global', 'high', 'accessible'
from books where title = 'Evershore';

insert into book_tropes (book_id, trope_id) select id, 'hive_mind' from books where title = 'Evershore';
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'Evershore';
insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Evershore';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'found_family', 0.4, 'ai_inferred' from books where title = 'Evershore';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'Evershore' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrator_reliability', 0.4, 'ai_inferred' from books where title = 'Evershore' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.3, 'ai_inferred' from books where title = 'Evershore' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'scifi_hardness', 0.4, 'ai_inferred' from books where title = 'Evershore' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.4, 'ai_inferred' from books where title = 'Evershore' on conflict (book_id, field_name) do nothing;


-- Exile
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'dark', 'light', 'bittersweet', 'moderate', 'none', 'na', null, 'frequent', 'graphic', 'dense', 'woven', 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'life_threatening', 'moderate'
from books where title = 'Exile';

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Exile';
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Exile';
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Exile';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'Exile';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'black_and_white_morality', 0.4, 'ai_inferred' from books where title = 'Exile';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'moderate', false from books where title = 'Exile';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Exile';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.4, 'ai_inferred' from books where title = 'Exile' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.4, 'ai_inferred' from books where title = 'Exile' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'Exile' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.4, 'ai_inferred' from books where title = 'Exile' on conflict (book_id, field_name) do nothing;


-- Gone
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['sci_fi'], 'ya', 'long', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'closed_door', null, 'frequent', 'graphic', 'moderate', 'exposition_dump', 'requires_series', 'bittersweet', 'resolved', 'long', 'na', 'soft', 'sparse', 'accessible', 'moderate', 'regional', 'life_threatening', 'moderate'
from books where title = 'Gone';

insert into book_tropes (book_id, trope_id) select id, 'child_soldiers_in_warfare' from books where title = 'Gone';
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'Gone';
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Gone';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'morally_grey_protagonist', 0.4, 'ai_inferred' from books where title = 'Gone';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', false from books where title = 'Gone';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'bullying', 'moderate', false from books where title = 'Gone';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'brief', false from books where title = 'Gone';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'Gone' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'darkness', 0.4, 'ai_inferred' from books where title = 'Gone' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_register', 0.4, 'ai_inferred' from books where title = 'Gone' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'violence_intensity', 0.4, 'ai_inferred' from books where title = 'Gone' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.3, 'ai_inferred' from books where title = 'Gone' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.3, 'ai_inferred' from books where title = 'Gone' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'Gone' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.4, 'ai_inferred' from books where title = 'Gone' on conflict (book_id, field_name) do nothing;


-- Half a Soul
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'romance_driven', 'light', 'moderate', 'comfort_read', 'moderate', 'rare', 'closed_door', 'understated', 'rare', 'mild', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'short', 'soft', 'na', 'moderate', 'accessible', 'moderate', 'intimate', 'moderate', 'accessible'
from books where title = 'Half a Soul';

insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'Half a Soul';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'satirical_or_comedic_fantasy', 0.3, 'ai_inferred' from books where title = 'Half a Soul';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'underdog_rising', 0.3, 'ai_inferred' from books where title = 'Half a Soul';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'ableism_depicted', 'moderate', false from books where title = 'Half a Soul';
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'chronic_illness_or_disability', 'moderate', false from books where title = 'Half a Soul';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Half a Soul' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'darkness', 0.4, 'ai_inferred' from books where title = 'Half a Soul' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_register', 0.4, 'ai_inferred' from books where title = 'Half a Soul' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_tone', 0.4, 'ai_inferred' from books where title = 'Half a Soul' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'worldbuilding_delivery', 0.3, 'ai_inferred' from books where title = 'Half a Soul' on conflict (book_id, field_name) do nothing;


-- How to Become the Dark Lord and Die Trying
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'uneven', 'plot_driven', 'moderate', 'heavy', 'tense', 'subtle', 'occasional', 'moderate', null, 'frequent', 'graphic', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'standard', 'hard', 'na', 'sparse', 'accessible', 'moderate', 'regional', 'life_threatening', 'accessible'
from books where title = 'How to Become the Dark Lord and Die Trying';

insert into book_tropes (book_id, trope_id) select id, 'time_loop' from books where title = 'How to Become the Dark Lord and Die Trying';
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'How to Become the Dark Lord and Die Trying';
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_fantasy' from books where title = 'How to Become the Dark Lord and Die Trying';
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'How to Become the Dark Lord and Die Trying';
insert into book_tropes (book_id, trope_id, confidence, source) select id, 'morally_grey_protagonist', 0.4, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying';

insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'person', 0.5, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'pace_shape', 0.4, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'humor_level', 0.4, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_heat_frequency', 0.3, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'romance_heat_intensity', 0.3, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'narrative_closure', 0.4, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'emotional_resolution', 0.3, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'ends_on_cliffhanger', 0.3, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'magic_system_hardness', 0.4, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying' on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source) select id, 'stakes_scope', 0.4, 'ai_inferred' from books where title = 'How to Become the Dark Lord and Die Trying' on conflict (book_id, field_name) do nothing;

