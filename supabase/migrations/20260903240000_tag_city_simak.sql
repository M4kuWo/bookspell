-- Tag "City" (Clifford D. Simak, 1952) -- repo owner priority item, a
-- single well-defined book (see .claude/skills/tag-catalog-batch/
-- SKILL.md's Step 0). Bibliographic-data-only row already exists
-- (20260903230000_targeted_ingestion_city_simak.sql).
--
-- A fix-up of 8 linked short stories (1944-1951) plus a closing "Notes"
-- section, framed as legends a far-future civilization of uplifted,
-- speaking Dogs tell about "Man" -- who they doubt ever really existed.
-- Spans thousands of years: humanity abandons cities for solitary
-- country life, genetically uplifts dogs to sapience and gives robots
-- (Jenkins, functional and central across the ENTIRE book) permanent
-- service roles, then departs Earth -- some transformed into a
-- different lifeform to inhabit Jupiter, others (Joe's mutant line)
-- detached from society entirely -- leaving Earth to the Dogs, with
-- civilized Ants emerging as a rival intelligence by the final story.
--
-- HIGH_RISK_FIELDS checked directly against the actual text, not
-- genre-convention pattern-matching (per CLAUDE.md): person is
-- third-limited throughout (rotating close-third per story-segment,
-- never omniscient or first-person); narrator_reliability is reliable
-- (the doggish scholarly doubt about whether the legends are literally
-- true is a FRAME-narrative device -- form: framing_device -- not an
-- unreliable narrator within the stories themselves); drive is
-- worldbuilding_driven, a much stronger and more specific fit than a
-- generic character/plot label for a book whose actual engine is "what
-- happens to civilization over 10,000 years," not any one character's
-- arc; magic_system_hardness/romance_heat are both na -- no magic, no
-- romance content at all.
--
-- No content warnings tagged -- genuinely none apply with real
-- on-page weight (no graphic violence, no depicted trauma content);
-- forcing any in would be padding, not tagging.

-- audiobook_length: 'standard' -- computed from the real audio duration
-- already on `books.audiobook_duration_minutes` (586 min = ~9.8h),
-- bucketed per this field's own documented guide (standard: 8-15h),
-- not left null when real data already supports a real value.
insert into book_dna (book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, violence_frequency, violence_intensity, worldbuilding_density, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility)
select id, array['sci_fi'], 'adult', 'standard', 'several', 'third_limited', 'reliable', 'linear', 'framing_device', 'medium', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'none', 'na', 'rare', 'mild', 'dense', 'self_contained', 'bittersweet', 'resolved', 'standard', 'na', 'soft', 'moderate', 'moderate', 'cerebral', 'global', 'low', 'demanding'
from books where title = 'City' and author = 'Clifford D. Simak'
on conflict (book_id) do nothing;

insert into book_tropes (book_id, trope_id) select id, 'uplift' from books where title = 'City' and author = 'Clifford D. Simak' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ai_consciousness' from books where title = 'City' and author = 'Clifford D. Simak' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'species_divergence' from books where title = 'City' and author = 'Clifford D. Simak' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'terraforming_or_space_colonization' from books where title = 'City' and author = 'Clifford D. Simak' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'City' and author = 'Clifford D. Simak' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dying_earth' from books where title = 'City' and author = 'Clifford D. Simak' on conflict do nothing;
