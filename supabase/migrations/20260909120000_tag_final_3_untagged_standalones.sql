-- Tags the last 3 real remaining untagged books in the catalog
-- (the other 10 untagged books are permanent, correctly-skipped
-- exceptions: graphic novels, omnibus/compilation duplicates, or
-- unpublished -- see docs/TODO.md's catalog-tagging-completion entry).
-- Researched via web search for the checkable/HIGH_RISK_FIELDS facts
-- (POV, narrator reliability, form, series completion status) rather
-- than recalled from memory alone, per CLAUDE.md's standing policy.

-- A Wizard's Guide to Defensive Baking -- POV/standalone status confirmed via web search
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven', 'moderate', 'moderate', 'tense', 'subtle', 'none', 'na', 'occasional', 'moderate', 'moderate', 'self_contained', 'happy', 'resolved', 'soft', 'na', 'moderate', 'accessible', 'escapist', 'regional', 'high', 'accessible'
from books where title = 'A Wizard’s Guide to Defensive Baking' and author = 'T. Kingfisher'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 0.5, 'ai_inferred' from books where title = 'A Wizard’s Guide to Defensive Baking' and author = 'T. Kingfisher'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'overall_pace', 0.6, 'ai_inferred' from books where title = 'A Wizard’s Guide to Defensive Baking' and author = 'T. Kingfisher'
on conflict (book_id, field_name) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'underdog_rising', 'ai_inferred' from books where title = 'A Wizard’s Guide to Defensive Baking' and author = 'T. Kingfisher'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'coming_of_age', 'ai_inferred' from books where title = 'A Wizard’s Guide to Defensive Baking' and author = 'T. Kingfisher'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'court_intrigue', 0.5, 'ai_inferred' from books where title = 'A Wizard’s Guide to Defensive Baking' and author = 'T. Kingfisher'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'noir_detective_structure', 0.4, 'ai_inferred' from books where title = 'A Wizard’s Guide to Defensive Baking' and author = 'T. Kingfisher'
on conflict (book_id, trope_id) do nothing;

-- Emily Wilde's Map of the Otherlands -- confirmed book 2 of 3 (requires_series), journal/epistolary format confirmed via web search
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'epistolary', 'medium', 'consistent', 'balanced', 'moderate', 'moderate', 'bittersweet', 'subtle', 'occasional', 'closed_door', 'rare', 'mild', 'dense', 'requires_series', 'bittersweet', 'resolved', 'soft', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'Emily Wilde’s Map of the Otherlands' and author = 'Heather Fawcett'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.6, 'ai_inferred' from books where title = 'Emily Wilde’s Map of the Otherlands' and author = 'Heather Fawcett'
on conflict (book_id, field_name) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'fae_courts', 'ai_inferred' from books where title = 'Emily Wilde’s Map of the Otherlands' and author = 'Heather Fawcett'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'fae_or_fairies', 'ai_inferred' from books where title = 'Emily Wilde’s Map of the Otherlands' and author = 'Heather Fawcett'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'portal_fantasy', 'ai_inferred' from books where title = 'Emily Wilde’s Map of the Otherlands' and author = 'Heather Fawcett'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, source)
select id, 'dark_academia_setting', 'ai_inferred' from books where title = 'Emily Wilde’s Map of the Otherlands' and author = 'Heather Fawcett'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'secret_royalty', 0.6, 'ai_inferred' from books where title = 'Emily Wilde’s Map of the Otherlands' and author = 'Heather Fawcett'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'hidden_identity_romance', 0.5, 'ai_inferred' from books where title = 'Emily Wilde’s Map of the Otherlands' and author = 'Heather Fawcett'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'slow_burn_romance', 0.6, 'ai_inferred' from books where title = 'Emily Wilde’s Map of the Otherlands' and author = 'Heather Fawcett'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'court_intrigue', 0.5, 'ai_inferred' from books where title = 'Emily Wilde’s Map of the Otherlands' and author = 'Heather Fawcett'
on conflict (book_id, trope_id) do nothing;

-- The Handmaid's Tale -- narrator_reliability (Offred's self-described 'reconstruction') and the withheld/ambiguous ending confirmed via web search
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'single', 'first', 'unreliable', 'nonlinear', 'framing_device', 'slow', 'consistent', 'character_driven', 'dark', 'none', 'gut_punch', 'heavy_handed', 'rare', 'low', 'occasional', 'graphic', 'moderate', 'self_contained', 'ambiguous', 'cliffhanger', 'na', 'soft', 'lush', 'dense', 'cerebral', 'intimate', 'life_threatening', 'moderate'
from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.6, 'ai_inferred' from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, field_name) do nothing;

insert into book_tropes (book_id, trope_id, source)
select id, 'dystopia', 'ai_inferred' from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'retrospective_memoir_narration', 0.7, 'ai_inferred' from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, trope_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity)
select id, 'sexual_assault', 'central_theme' from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity)
select id, 'dubious_consent', 'central_theme' from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity)
select id, 'sexism_or_misogyny_depicted', 'central_theme' from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity)
select id, 'religious_trauma_or_cults', 'central_theme' from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity)
select id, 'kidnapping_or_captivity', 'moderate' from books where title = 'The Handmaid’s Tale' and author = 'Margaret Atwood'
on conflict (book_id, warning_id) do nothing;
