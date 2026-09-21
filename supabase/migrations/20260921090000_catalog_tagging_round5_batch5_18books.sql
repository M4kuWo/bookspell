-- Round-5 tagging batch 5 (CLDA): 18 books, full Book DNA
-- Prioritized via tag-catalog-batch's partial-series-first query: all 11 legitimate
-- partial-series candidates surfaced (11 of 15 -- the other 4 are the standing
-- do-not-touch list: The Thorn of Emberlain, The Book of the New Sun, 1Q84: Book 1, Holly)
-- taken first, completing/advancing 10 series to 2/2 (or moving Forward Collection 1/3 -> 2/3),
-- plus 7 well-known standalones/series-openers chosen for solid existing literary knowledge
-- given this session's WebSearch budget was already exhausted by an earlier sibling batch.
-- Author-field contamination (illustrator/narrator credits mixed into books.author) found
-- and fixed inline for 4 books via Hardcover cached_contributors verification.

-- Author-field contamination fixes (verified via Hardcover cached_contributors GraphQL API)
-- A Dead Djinn in Cairo: Suehyla El-Attar is the audiobook Narrator per Hardcover cached_contributors, not a co-author.
update books set author = 'P. Djèlí Clark'
where title = 'A Dead Djinn in Cairo' and author = 'P. Djèlí Clark, Suehyla El-Attar';

-- The Dark Prophecy: John Rocco is the Illustrator (interior art/covers) per Hardcover cached_contributors, not a co-author.
update books set author = 'Rick Riordan'
where title = 'The Dark Prophecy' and author = 'Rick Riordan, John Rocco';

-- The Dream Thieves: Will Patton is the audiobook Narrator per Hardcover cached_contributors, not a co-author.
update books set author = 'Maggie Stiefvater'
where title = 'The Dream Thieves' and author = 'Maggie Stiefvater, Will Patton';

-- The Secret Commonwealth: Michael Sheen is the audiobook Narrator per Hardcover cached_contributors, not a co-author.
update books set author = 'Philip Pullman'
where title = 'The Secret Commonwealth' and author = 'Philip Pullman, Michael Sheen';

-- book_dna inserts
-- A Dead Djinn in Cairo: Agent Fatma investigation novella, Dead Djinn Universe #0.1 (A Master of Djinn already tagged, #1). Author-field OK as-is (single author).
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'light', 'tense', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'self_contained', 'happy', 'resolved', 'short', null, 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'A Dead Djinn in Cairo'
on conflict (book_id) do nothing;

-- Summer Frost: Forward Collection #2 novella (video-game AI Riley gains consciousness).
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', null, 'rare', 'mild', 'light', null, 'self_contained', 'ambiguous', 'resolved', 'short', null, 'na', 'soft', 'sparse', 'accessible', 'cerebral', 'intimate', 'moderate', 'accessible'
from books where title = 'Summer Frost'
on conflict (book_id) do nothing;

-- The Broken Kingdoms: Inheritance Trilogy #2 -- Oree Shoth, blind artist narrator; godsblood murder mystery.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'bittersweet', 'moderate', 'occasional', 'moderate', null, 'occasional', 'graphic', 'dense', null, 'self_contained', 'bittersweet', 'resolved', 'standard', null, 'soft', 'na', 'lush', 'moderate', 'moderate', 'regional', 'high', 'moderate'
from books where title = 'The Broken Kingdoms'
on conflict (book_id) do nothing;

-- The Dark Prophecy: Trials of Apollo #2 -- Apollo/Lester first-person narration, matches book 1.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'tense', 'subtle', 'rare', 'closed_door', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'standard', null, 'soft', 'na', 'sparse', 'accessible', 'escapist', 'regional', 'high', 'accessible'
from books where title = 'The Dark Prophecy'
on conflict (book_id) do nothing;

-- The Dream Thieves: Raven Cycle #2 -- ensemble/third_limited matches book 1; genre_accessibility bumped down one tier from computed 'demanding' for mainstream contemporary-small-town premise familiarity.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'slow_burn_to_fast_finish', 'character_driven', 'moderate', 'moderate', 'bittersweet', 'subtle', 'occasional', 'low', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'bittersweet', 'resolved', 'standard', null, 'soft', 'na', 'lush', 'moderate', 'moderate', 'intimate', 'high', 'moderate'
from books where title = 'The Dream Thieves'
on conflict (book_id) do nothing;

-- The Hammer of Thor: Magnus Chase #2 -- first-person Magnus, matches book 1.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'standard', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'fast', 'consistent', 'plot_driven', 'moderate', 'heavy', 'tense', 'moderate', 'rare', 'closed_door', null, 'occasional', 'moderate', 'moderate', null, 'requires_series', 'happy', 'resolved', 'standard', null, 'soft', 'na', 'sparse', 'accessible', 'escapist', 'global', 'high', 'accessible'
from books where title = 'The Hammer of Thor'
on conflict (book_id) do nothing;

-- The Secret Commonwealth: Book of Dust #2 -- Lyra now ~20, notably darker/bleaker register than La Belle Sauvage; age_category/drive flagged as a real divergence judgment call from book 1's ya/plot_driven.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'epic', 'dual', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'moderate', 'rare', 'low', null, 'occasional', 'graphic', 'dense', null, 'requires_series', 'tragic', 'cliffhanger', 'long', null, 'soft', 'na', 'lush', 'moderate', 'cerebral', 'global', 'high', 'demanding'
from books where title = 'The Secret Commonwealth'
on conflict (book_id) do nothing;

-- The Twelve: The Passage #2 -- viral-vampire post-apocalypse; found-document/future-academic framing device is the trilogy's structural hallmark.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'long', 'ensemble', 'third_limited', 'reliable', 'nonlinear', 'framing_device', 'medium', 'uneven', 'plot_driven', 'grimdark', 'none', 'gut_punch', 'moderate', 'occasional', 'moderate', null, 'frequent', 'brutal', 'dense', null, 'requires_series', 'bittersweet', 'cliffhanger', 'long', null, 'na', 'soft', 'lush', 'moderate', 'moderate', 'global', 'life_threatening', 'demanding'
from books where title = 'The Twelve'
on conflict (book_id) do nothing;

-- The World We Make: Great Cities #2 -- concludes the duology; overtly political (gentrification/racism as literal antagonist), matches book 1's register.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'ensemble', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'plot_driven', 'moderate', 'moderate', 'tense', 'heavy_handed', 'occasional', 'moderate', null, 'occasional', 'graphic', 'dense', null, 'self_contained', 'happy', 'resolved', 'standard', null, 'soft', 'na', 'lush', 'moderate', 'moderate', 'cosmic', 'high', 'demanding'
from books where title = 'The World We Make'
on conflict (book_id) do nothing;

-- Throne of Jade: Temeraire #2 -- Laurence/Temeraire voyage to China; matches book 1's third_limited/character_driven/woven.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'light', 'moderate', 'comfort_read', 'subtle', 'none', 'na', null, 'occasional', 'moderate', 'moderate', 'woven', 'requires_series', 'happy', 'resolved', 'standard', null, 'none', 'na', 'moderate', 'moderate', 'moderate', 'regional', 'moderate', 'moderate'
from books where title = 'Throne of Jade'
on conflict (book_id) do nothing;

-- Who Fears Death: Standalone -- Onyesonwu narrates her own life to a scribe before her execution (framing_device). Vocabulary gap: forced female genital cutting (a central, repeated element) has no clean content_warnings match -- closest umbrella used (child_abuse) is imprecise; flagged as a new gap in book-dna.md's tracker, see migration footer note.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi','fantasy'], 'adult', 'standard', 'single', 'first', 'reliable', 'linear', 'framing_device', 'medium', 'consistent', 'character_driven', 'grimdark', 'none', 'gut_punch', 'heavy_handed', 'occasional', 'moderate', null, 'frequent', 'brutal', 'dense', null, 'self_contained', 'tragic', 'resolved', 'standard', null, 'soft', 'soft', 'lush', 'moderate', 'cerebral', 'regional', 'life_threatening', 'demanding'
from books where title = 'Who Fears Death'
on conflict (book_id) do nothing;

-- 2312: Standalone -- Swan/Wahram/Genette POVs interspersed with documentary 'Extracts'/'Lists' chapters (basis for exposition_dump).
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'long', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'slow', 'uneven', 'worldbuilding_driven', 'moderate', 'light', 'bittersweet', 'heavy_handed', 'occasional', 'moderate', null, 'rare', 'mild', 'dense', 'exposition_dump', 'self_contained', 'happy', 'resolved', 'long', null, 'na', 'hard', 'lush', 'dense', 'cerebral', 'global', 'moderate', 'veteran_only'
from books where title = '2312'
on conflict (book_id) do nothing;

-- A Princess of Mars: Barsoom #1 -- John Carter's posthumous 'found manuscript' memoir (framing_device); classic pulp-melodrama romance presentation (declarations of love within days, heightened rescue/peril beats), not inferred from genre alone.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi','fantasy'], 'adult', 'short', 'single', 'first', 'reliable', 'linear', 'framing_device', 'fast', 'consistent', 'plot_driven', 'light', 'light', 'comfort_read', 'subtle', 'occasional', 'closed_door', 'melodramatic', 'frequent', 'moderate', 'moderate', 'exposition_dump', 'requires_series', 'bittersweet', 'cliffhanger', 'short', null, 'na', 'soft', 'moderate', 'moderate', 'escapist', 'global', 'life_threatening', 'moderate'
from books where title = 'A Princess of Mars'
on conflict (book_id) do nothing;

-- Babel-17: Standalone -- Rydra Wong linguist-poet decodes a language-as-weapon; New Weird-adjacent conceptual SF, drive tagged worldbuilding_driven (the linguistic-relativity idea is the book's real engine) over character_driven.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'short', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'worldbuilding_driven', 'moderate', 'light', 'tense', 'heavy_handed', 'rare', 'low', null, 'occasional', 'moderate', 'moderate', null, 'self_contained', 'happy', 'resolved', 'short', null, 'na', 'soft', 'lush', 'dense', 'cerebral', 'global', 'high', 'demanding'
from books where title = 'Babel-17'
on conflict (book_id) do nothing;

-- Dogs of War: Standalone -- bioform-soldier personhood/rights allegory; Rex (dog), Honey (bear), Bees (hive-mind) POV sections.
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['sci_fi'], 'adult', 'standard', 'few', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'uneven', 'character_driven', 'dark', 'light', 'gut_punch', 'heavy_handed', 'none', 'na', null, 'frequent', 'brutal', 'moderate', null, 'self_contained', 'bittersweet', 'resolved', 'standard', null, 'na', 'soft', 'moderate', 'accessible', 'cerebral', 'regional', 'life_threatening', 'moderate'
from books where title = 'Dogs of War'
on conflict (book_id) do nothing;

-- Empire in Black and Gold: Shadows of the Apt #1 -- insect-kinden secondary world, Wasp Empire invasion; series-opener worldbuilding leans expository (introducing the kinden taxonomy).
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'long', 'several', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'front_loaded', 'plot_driven', 'moderate', 'light', 'tense', 'moderate', 'occasional', 'low', null, 'occasional', 'moderate', 'dense', 'exposition_dump', 'requires_series', 'bittersweet', 'cliffhanger', 'long', null, 'soft', 'na', 'moderate', 'moderate', 'moderate', 'global', 'high', 'demanding'
from books where title = 'Empire in Black and Gold'
on conflict (book_id) do nothing;

-- Ella Enchanted: Standalone MG Cinderella retelling -- Ella/Char courtship is gentle and restrained on the page, not melodramatic (genuine presentation-level evidence, not genre default).
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'middle_grade', 'short', 'single', 'first', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'light', 'moderate', 'comfort_read', 'subtle', 'rare', 'closed_door', 'understated', 'rare', 'mild', 'light', null, 'self_contained', 'happy', 'resolved', 'short', null, 'soft', 'na', 'sparse', 'accessible', 'escapist', 'intimate', 'moderate', 'gateway'
from books where title = 'Ella Enchanted'
on conflict (book_id) do nothing;

-- Akata Witch: Nsibidi Scripts #1 -- Sunny Nwazue, Leopard Society; worldbuilding delivered via a genuine mix of in-scene discovery and interstitial 'Fast Facts for Free Agents' exposition inserts (basis for 'mixed').
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person, narrator_reliability, timeline, form, overall_pace, pace_shape, drive, darkness, humor_level, emotional_register, message_intensity, romance_heat_frequency, romance_heat_intensity, romance_tone, violence_frequency, violence_intensity, worldbuilding_density, worldbuilding_delivery, narrative_closure, emotional_resolution, ends_on_cliffhanger, audiobook_length, narrator_cast, magic_system_hardness, scifi_hardness, prose_density, prose_complexity, intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'ya', 'standard', 'single', 'third_limited', 'reliable', 'linear', 'standard_prose', 'medium', 'consistent', 'character_driven', 'moderate', 'light', 'tense', 'moderate', 'none', 'na', null, 'occasional', 'moderate', 'dense', 'mixed', 'self_contained', 'happy', 'resolved', 'standard', null, 'soft', 'na', 'moderate', 'accessible', 'moderate', 'regional', 'high', 'accessible'
from books where title = 'Akata Witch'
on conflict (book_id) do nothing;

-- book_tropes inserts
insert into book_tropes (book_id, trope_id)
select id, 'secret_magical_bureaucracy' from books where title = 'A Dead Djinn in Cairo'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'alternate_history' from books where title = 'A Dead Djinn in Cairo'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'noir_detective_structure' from books where title = 'A Dead Djinn in Cairo'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'multiple_fantasy_species' from books where title = 'A Dead Djinn in Cairo'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Summer Frost'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'virtual_reality_or_simulated_world' from books where title = 'Summer Frost'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'twist_ending', 0.5, 'ai_inferred' from books where title = 'Summer Frost'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'The Broken Kingdoms'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'mythological_pantheon_as_characters' from books where title = 'The Broken Kingdoms'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'hidden_identity_romance' from books where title = 'The Broken Kingdoms'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'noir_detective_structure' from books where title = 'The Broken Kingdoms'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'twist_ending' from books where title = 'The Broken Kingdoms'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'prophecy' from books where title = 'The Dark Prophecy'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'redemption_arc' from books where title = 'The Dark Prophecy'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'deadly_competition_or_trial' from books where title = 'The Dark Prophecy'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'underdog_rising' from books where title = 'The Dark Prophecy'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Dream Thieves'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'prophecy' from books where title = 'The Dream Thieves'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'slow_burn_romance' from books where title = 'The Dream Thieves'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'The Dream Thieves'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'The Dream Thieves'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The Hammer of Thor'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'epic_quest' from books where title = 'The Hammer of Thor'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'immortal_or_ageless_character' from books where title = 'The Hammer of Thor'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'chosen_one' from books where title = 'The Hammer of Thor'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'long_journey' from books where title = 'The Secret Commonwealth'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'epic_quest' from books where title = 'The Secret Commonwealth'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'The Secret Commonwealth'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'secret_magical_bureaucracy' from books where title = 'The Secret Commonwealth'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'post_apocalyptic' from books where title = 'The Twelve'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'vampires' from books where title = 'The Twelve'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'survivalist_ingenuity' from books where title = 'The Twelve'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'major_character_death' from books where title = 'The Twelve'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'The Twelve'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'cosmic_horror' from books where title = 'The World We Make'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'The World We Make'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'parallel_universe_or_multiverse' from books where title = 'The World We Make'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'urban_fantasy_setting' from books where title = 'The World We Make'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'dragons' from books where title = 'Throne of Jade'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'alternate_history' from books where title = 'Throne of Jade'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'long_journey' from books where title = 'Throne of Jade'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'non_european_inspired_setting' from books where title = 'Throne of Jade'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Throne of Jade'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'chosen_one' from books where title = 'Who Fears Death'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'revenge' from books where title = 'Who Fears Death'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'Who Fears Death'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'retrospective_memoir_narration' from books where title = 'Who Fears Death'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'post_apocalyptic' from books where title = 'Who Fears Death'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'terraforming_or_space_colonization' from books where title = '2312'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'cybernetic_enhancement' from books where title = '2312'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = '2312'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'space_opera' from books where title = '2312'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'isekai', 0.5, 'ai_inferred' from books where title = 'A Princess of Mars'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'epic_quest' from books where title = 'A Princess of Mars'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'multiple_alien_species' from books where title = 'A Princess of Mars'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'last_minute_rescue' from books where title = 'A Princess of Mars'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'black_and_white_morality' from books where title = 'A Princess of Mars'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'mind_uploading_or_digital_immortality', 0.5, 'ai_inferred' from books where title = 'Babel-17'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Babel-17'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'noir_detective_structure', 0.5, 'ai_inferred' from books where title = 'Babel-17'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'amnesia_driven_narrative', 0.5, 'ai_inferred' from books where title = 'Babel-17'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'android_or_replicant_rights' from books where title = 'Dogs of War'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'ai_consciousness' from books where title = 'Dogs of War'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'cybernetic_enhancement' from books where title = 'Dogs of War'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Dogs of War'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'hive_mind' from books where title = 'Dogs of War'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'multiple_fantasy_species' from books where title = 'Empire in Black and Gold'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'war_story' from books where title = 'Empire in Black and Gold'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'rebellion_against_empire' from books where title = 'Empire in Black and Gold'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'court_intrigue' from books where title = 'Empire in Black and Gold'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'steampunk' from books where title = 'Empire in Black and Gold'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'fae_or_fairies' from books where title = 'Ella Enchanted'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'Ella Enchanted'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'cursed_protagonist' from books where title = 'Ella Enchanted'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'wise_mentor' from books where title = 'Ella Enchanted'
on conflict (book_id, trope_id) do nothing;

insert into book_tropes (book_id, trope_id)
select id, 'magic_school' from books where title = 'Akata Witch'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'found_family' from books where title = 'Akata Witch'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'coming_of_age' from books where title = 'Akata Witch'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'non_european_inspired_setting' from books where title = 'Akata Witch'
on conflict (book_id, trope_id) do nothing;
insert into book_tropes (book_id, trope_id)
select id, 'hidden_talent_prodigy' from books where title = 'Akata Witch'
on conflict (book_id, trope_id) do nothing;

-- book_content_warnings inserts
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'brief', false from books where title = 'A Dead Djinn in Cairo'
on conflict (book_id, warning_id) do nothing;


insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'body_horror', 'moderate', false from books where title = 'The Broken Kingdoms'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'fictional_species_prejudice', 'moderate', false from books where title = 'The Broken Kingdoms'
on conflict (book_id, warning_id) do nothing;




insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'moderate', true from books where title = 'The Secret Commonwealth'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'stalking', 'moderate', false from books where title = 'The Secret Commonwealth'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'The Secret Commonwealth'
on conflict (book_id, warning_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'The Twelve'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Twelve'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_death', 'moderate', true from books where title = 'The Twelve'
on conflict (book_id, warning_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'racism_depicted', 'central_theme', false from books where title = 'The World We Make'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'classism', 'moderate', false from books where title = 'The World We Make'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'hate_speech_depicted', 'central_theme', false from books where title = 'The World We Make'
on conflict (book_id, warning_id) do nothing;


insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'genocide', 'central_theme', false from books where title = 'Who Fears Death'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'central_theme', true from books where title = 'Who Fears Death'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'racism_depicted', 'central_theme', false from books where title = 'Who Fears Death'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'central_theme', false from books where title = 'Who Fears Death'
on conflict (book_id, warning_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'natural_disaster_mass_casualty', 'moderate', false from books where title = '2312'
on conflict (book_id, warning_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'A Princess of Mars'
on conflict (book_id, warning_id) do nothing;


insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'animal_harm', 'central_theme', false from books where title = 'Dogs of War'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Dogs of War'
on conflict (book_id, warning_id) do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'moderate', false from books where title = 'Empire in Black and Gold'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'slavery', 'moderate', false from books where title = 'Empire in Black and Gold'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'torture', 'moderate', false from books where title = 'Empire in Black and Gold'
on conflict (book_id, warning_id) do nothing;


insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_death', 'central_theme', true from books where title = 'Akata Witch'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'ableism_depicted', 'moderate', false from books where title = 'Akata Witch'
on conflict (book_id, warning_id) do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'child_abuse', 'moderate', true from books where title = 'Akata Witch'
on conflict (book_id, warning_id) do nothing;

-- book_field_confidence inserts (scalar-field uncertainty)
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'A Dead Djinn in Cairo'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'A Dead Djinn in Cairo'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Summer Frost'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.5, 'ai_inferred' from books where title = 'Summer Frost'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 0.5, 'ai_inferred' from books where title = 'The Broken Kingdoms'
on conflict (book_id, field_name) do nothing;



insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The Hammer of Thor'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'age_category', 0.5, 'ai_inferred' from books where title = 'The Secret Commonwealth'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'The Secret Commonwealth'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'timeline', 0.5, 'ai_inferred' from books where title = 'The Twelve'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'form', 0.5, 'ai_inferred' from books where title = 'The Twelve'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 0.5, 'ai_inferred' from books where title = 'The World We Make'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = 'Throne of Jade'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'emotional_resolution', 0.6, 'ai_inferred' from books where title = 'Who Fears Death'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = '2312'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.6, 'ai_inferred' from books where title = '2312'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.5, 'ai_inferred' from books where title = 'A Princess of Mars'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'A Princess of Mars'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'Babel-17'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 0.5, 'ai_inferred' from books where title = 'Babel-17'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.5, 'ai_inferred' from books where title = 'Dogs of War'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.5, 'ai_inferred' from books where title = 'Dogs of War'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Empire in Black and Gold'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'ends_on_cliffhanger', 0.5, 'ai_inferred' from books where title = 'Empire in Black and Gold'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_tone', 0.6, 'ai_inferred' from books where title = 'Ella Enchanted'
on conflict (book_id, field_name) do nothing;

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'age_category', 0.5, 'ai_inferred' from books where title = 'Akata Witch'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 0.6, 'ai_inferred' from books where title = 'Akata Witch'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'worldbuilding_delivery', 0.5, 'ai_inferred' from books where title = 'Akata Witch'
on conflict (book_id, field_name) do nothing;
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 0.5, 'ai_inferred' from books where title = 'Akata Witch'
on conflict (book_id, field_name) do nothing;
