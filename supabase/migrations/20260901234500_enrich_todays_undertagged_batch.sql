-- Enrichment pass for books tagged earlier today (2026-09-01): a quantitative
-- audit found today's batches averaged 1.08 content warnings/book and 4.43
-- tropes/book, vs 1.83 and 6.61 catalog-wide -- a consistent gap across every
-- batch, not a handful of outliers. This migration adds genuine, missed
-- tropes and content warnings (content warnings prioritized, per the gap being
-- worse there) to the affected books, re-verified against the schema's
-- controlled vocabulary rather than relying on memory of what was tagged
-- earlier in the session. No blanket statements -- every insert is scoped to
-- one book via a title subselect, idempotent via ON CONFLICT DO NOTHING.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

-- A Short Stay in Hell
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'central_theme', false from books where title = 'A Short Stay in Hell' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'A Short Stay in Hell' on conflict do nothing;

-- How High We Go in the Dark
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'central_theme', false from books where title = 'How High We Go in the Dark' on conflict do nothing;

-- The Lovely Bones
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'The Lovely Bones' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Lovely Bones' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'brief', false from books where title = 'The Lovely Bones' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'stalking', 'moderate', false from books where title = 'The Lovely Bones' on conflict do nothing;

-- Mythos: The Greek Myths Retold
insert into book_tropes (book_id, trope_id) select id, 'mythological_pantheon_as_characters' from books where title = 'Mythos: The Greek Myths Retold' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'incest', 'central_theme', false from books where title = 'Mythos: The Greek Myths Retold' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'central_theme', false from books where title = 'Mythos: The Greek Myths Retold' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Mythos: The Greek Myths Retold' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'Mythos: The Greek Myths Retold' on conflict do nothing;

-- The Circle
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', true from books where title = 'The Circle' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'brief', false from books where title = 'The Circle' on conflict do nothing;

-- The Tales of Beedle the Bard
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'The Tales of Beedle the Bard' on conflict do nothing;

-- Contact
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'moderate', false from books where title = 'Contact' on conflict do nothing;

-- Roadside Picnic
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'Roadside Picnic' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Roadside Picnic' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'Roadside Picnic' on conflict do nothing;

-- The Andromeda Strain
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'The Andromeda Strain' on conflict do nothing;

-- The Glass Hotel
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'moderate', false from books where title = 'The Glass Hotel' on conflict do nothing;

-- The Memory Police
insert into book_tropes (book_id, trope_id) select id, 'forced_proximity' from books where title = 'The Memory Police' on conflict do nothing;

-- Breakfast of Champions
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'racism_depicted', 'moderate', false from books where title = 'Breakfast of Champions' on conflict do nothing;

-- Gravity's Rainbow
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Gravity''s Rainbow' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'moderate', false from books where title = 'Gravity''s Rainbow' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'Gravity''s Rainbow' on conflict do nothing;

-- The Green Mile
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', false from books where title = 'The Green Mile' on conflict do nothing;

-- Carmilla
insert into book_tropes (book_id, trope_id) select id, 'age_gap_romance' from books where title = 'Carmilla' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'central_theme', false from books where title = 'Carmilla' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'stalking', 'moderate', false from books where title = 'Carmilla' on conflict do nothing;

-- One Last Stop
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'One Last Stop' on conflict do nothing;

-- Record of a Spaceborn Few
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Record of a Spaceborn Few' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'Record of a Spaceborn Few' on conflict do nothing;

-- Redshirts
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Redshirts' on conflict do nothing;

-- The Lathe of Heaven
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'The Lathe of Heaven' on conflict do nothing;

-- A Canticle for Leibowitz
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'A Canticle for Leibowitz' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'A Canticle for Leibowitz' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'central_theme', false from books where title = 'A Canticle for Leibowitz' on conflict do nothing;

-- Authority
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Authority' on conflict do nothing;

-- Severance
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'religious_trauma_or_cults', 'moderate', false from books where title = 'Severance' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Severance' on conflict do nothing;

-- The Bad Beginning
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Bad Beginning' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Bad Beginning' on conflict do nothing;

-- The Invisible Man
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'brief', false from books where title = 'The Invisible Man' on conflict do nothing;

-- Twenty Thousand Leagues Under the Sea
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Twenty Thousand Leagues Under the Sea' on conflict do nothing;

-- A Scanner Darkly
insert into book_tropes (book_id, trope_id) select id, 'amnesia_driven_narrative' from books where title = 'A Scanner Darkly' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'chronic_illness_or_disability', 'moderate', false from books where title = 'A Scanner Darkly' on conflict do nothing;

-- Perfume
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', false from books where title = 'Perfume' on conflict do nothing;

-- Chain-Gang All-Stars
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'Chain-Gang All-Stars' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'Chain-Gang All-Stars' on conflict do nothing;

-- I Have No Mouth and I Must Scream
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'I Have No Mouth and I Must Scream' on conflict do nothing;

-- Ring Shout
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Ring Shout' on conflict do nothing;

-- The Calculating Stars
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'The Calculating Stars' on conflict do nothing;

-- The Space Between Worlds
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'substance_abuse', 'moderate', false from books where title = 'The Space Between Worlds' on conflict do nothing;

-- Blindness
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Blindness' on conflict do nothing;

-- Anathem
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Anathem' on conflict do nothing;

-- Frankenstein: The 1818 Text
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', false from books where title = 'Frankenstein: The 1818 Text' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'suicide', 'brief', true from books where title = 'Frankenstein: The 1818 Text' on conflict do nothing;

-- Hard-Boiled Wonderland and the End of the World
insert into book_tropes (book_id, trope_id) select id, 'noir_detective_structure' from books where title = 'Hard-Boiled Wonderland and the End of the World' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Hard-Boiled Wonderland and the End of the World' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'brief', false from books where title = 'Hard-Boiled Wonderland and the End of the World' on conflict do nothing;

-- Mostly Harmless
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'Mostly Harmless' on conflict do nothing;

-- Ringworld
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Ringworld' on conflict do nothing;

-- Rivers of London
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Rivers of London' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'domestic_abuse', 'brief', false from books where title = 'Rivers of London' on conflict do nothing;

-- The Adventures of Amina Al-Sirafi
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'The Adventures of Amina Al-Sirafi' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'The Adventures of Amina Al-Sirafi' on conflict do nothing;

-- The Assassin and the Healer
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Assassin and the Healer' on conflict do nothing;

-- The Eleventh Metal
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Eleventh Metal' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'The Eleventh Metal' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', true from books where title = 'The Eleventh Metal' on conflict do nothing;

-- The First Fifteen Lives of Harry August
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'The First Fifteen Lives of Harry August' on conflict do nothing;

-- The Wonderful Wizard of Oz
insert into book_tropes (book_id, trope_id) select id, 'portal_fantasy' from books where title = 'The Wonderful Wizard of Oz' on conflict do nothing;

-- Caraval
insert into book_tropes (book_id, trope_id) select id, 'arranged_marriage' from books where title = 'Caraval' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Caraval' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'Caraval' on conflict do nothing;

-- Every Heart a Doorway
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Every Heart a Doorway' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Every Heart a Doorway' on conflict do nothing;

-- Home: Habitat, Range, Niche, Territory
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Home: Habitat, Range, Niche, Territory' on conflict do nothing;

-- Light From Uncommon Stars
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'hate_speech_depicted', 'moderate', false from books where title = 'Light From Uncommon Stars' on conflict do nothing;

-- Pines
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'Pines' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Pines' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'central_theme', true from books where title = 'Pines' on conflict do nothing;

-- Red Mars
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Red Mars' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'Red Mars' on conflict do nothing;

-- Ship of Magic
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Ship of Magic' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexism_or_misogyny_depicted', 'central_theme', false from books where title = 'Ship of Magic' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'moderate', false from books where title = 'Ship of Magic' on conflict do nothing;

-- The Diamond Age
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_sexual_abuse', 'moderate', false from books where title = 'The Diamond Age' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'The Diamond Age' on conflict do nothing;

-- The Empress of Salt and Fortune
insert into book_tropes (book_id, trope_id) select id, 'arranged_marriage' from books where title = 'The Empress of Salt and Fortune' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'The Empress of Salt and Fortune' on conflict do nothing;

-- The Goblin Emperor
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'central_theme', false from books where title = 'The Goblin Emperor' on conflict do nothing;

-- The Host
insert into book_tropes (book_id, trope_id) select id, 'forced_proximity' from books where title = 'The Host' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Host' on conflict do nothing;

-- The Master and Margarita
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'The Master and Margarita' on conflict do nothing;

-- Uglies
insert into book_tropes (book_id, trope_id) select id, 'survivalist_ingenuity' from books where title = 'Uglies' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Uglies' on conflict do nothing;

-- Vicious
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Vicious' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'moderate', false from books where title = 'Vicious' on conflict do nothing;

-- Xenocide
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'Xenocide' on conflict do nothing;

-- Binti
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Binti' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Binti' on conflict do nothing;

-- Dawn 
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Dawn ' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'moderate', false from books where title = 'Dawn ' on conflict do nothing;

-- John Dies at the End
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'John Dies at the End' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'John Dies at the End' on conflict do nothing;

-- Senlin Ascends
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'Senlin Ascends' on conflict do nothing;

-- The City of Brass
insert into book_tropes (book_id, trope_id) select id, 'age_gap_romance' from books where title = 'The City of Brass' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', false from books where title = 'The City of Brass' on conflict do nothing;

-- The City We Became
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'hate_speech_depicted', 'moderate', false from books where title = 'The City We Became' on conflict do nothing;

-- The Divine Comedy
insert into book_tropes (book_id, trope_id) select id, 'mythological_retelling' from books where title = 'The Divine Comedy' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'The Divine Comedy' on conflict do nothing;

-- The Familiar
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Familiar' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'hate_speech_depicted', 'central_theme', false from books where title = 'The Familiar' on conflict do nothing;

-- The Hundred Thousand Kingdoms
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'The Hundred Thousand Kingdoms' on conflict do nothing;

-- City of Stairs
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'City of Stairs' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'City of Stairs' on conflict do nothing;

-- Lock In
insert into book_tropes (book_id, trope_id) select id, 'virtual_reality_or_simulated_world' from books where title = 'Lock In' on conflict do nothing;

-- Anansi Boys
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'Anansi Boys' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Anansi Boys' on conflict do nothing;

-- Armada
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Armada' on conflict do nothing;

-- Assistant to the Villain
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'chronic_illness_or_disability', 'moderate', false from books where title = 'Assistant to the Villain' on conflict do nothing;

-- Blood Rites
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'Blood Rites' on conflict do nothing;

-- Fool Moon
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Fool Moon' on conflict do nothing;

-- Furies of Calderon
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'moderate', false from books where title = 'Furies of Calderon' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'Furies of Calderon' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'sexual_assault', 'brief', false from books where title = 'Furies of Calderon' on conflict do nothing;

-- Gallant
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'ableism_depicted', 'moderate', false from books where title = 'Gallant' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'bullying', 'moderate', false from books where title = 'Gallant' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'Gallant' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Gallant' on conflict do nothing;

-- His Majesty's Dragon
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'His Majesty''s Dragon' on conflict do nothing;

-- In the Lives of Puppets
insert into book_tropes (book_id, trope_id) select id, 'ai_uprising_or_rebellion' from books where title = 'In the Lives of Puppets' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'In the Lives of Puppets' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'In the Lives of Puppets' on conflict do nothing;

-- Kings of the Wyld
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Kings of the Wyld' on conflict do nothing;

-- Mickey7
insert into book_tropes (book_id, trope_id) select id, 'cloning' from books where title = 'Mickey7' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Mickey7' on conflict do nothing;

-- Pandora's Star
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Pandora''s Star' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Pandora''s Star' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Pandora''s Star' on conflict do nothing;

-- Sabriel
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Sabriel' on conflict do nothing;

-- Starsight
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Starsight' on conflict do nothing;

-- The Caves of Steel
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'The Caves of Steel' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'classism', 'moderate', false from books where title = 'The Caves of Steel' on conflict do nothing;

-- The Ghost Brigades
insert into book_tropes (book_id, trope_id) select id, 'cloning' from books where title = 'The Ghost Brigades' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'The Ghost Brigades' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', true from books where title = 'The Ghost Brigades' on conflict do nothing;

-- The Long Walk
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', false from books where title = 'The Long Walk' on conflict do nothing;

-- Theft of Swords
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Theft of Swords' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'Theft of Swords' on conflict do nothing;

-- Bride
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'Bride' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'Bride' on conflict do nothing;

-- Children of Memory
insert into book_tropes (book_id, trope_id) select id, 'virtual_reality_or_simulated_world' from books where title = 'Children of Memory' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'moderate', false from books where title = 'Children of Memory' on conflict do nothing;

-- Daughter of the Moon Goddess
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Daughter of the Moon Goddess' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Daughter of the Moon Goddess' on conflict do nothing;

-- Going Postal
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'Going Postal' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'Going Postal' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'moderate', false from books where title = 'Going Postal' on conflict do nothing;

-- Heir to the Empire
insert into book_tropes (book_id, trope_id) select id, 'cloning' from books where title = 'Heir to the Empire' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'Heir to the Empire' on conflict do nothing;

-- Heretics of Dune
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', true from books where title = 'Heretics of Dune' on conflict do nothing;

-- The Magician's Nephew
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Magician''s Nephew' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'The Magician''s Nephew' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'central_theme', false from books where title = 'The Magician''s Nephew' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'chronic_illness_or_disability', 'central_theme', false from books where title = 'The Magician''s Nephew' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'animal_harm', 'brief', false from books where title = 'The Magician''s Nephew' on conflict do nothing;

-- The Waste Lands
insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Waste Lands' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'The Waste Lands' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Waste Lands' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'mental_illness_depiction', 'moderate', false from books where title = 'The Waste Lands' on conflict do nothing;

-- Wyrd Sisters
insert into book_tropes (book_id, trope_id) select id, 'dark_lord_or_evil_overlord' from books where title = 'Wyrd Sisters' on conflict do nothing;

-- Clockwork Angel
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'Clockwork Angel' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'Clockwork Angel' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'emotional_abuse', 'moderate', false from books where title = 'Clockwork Angel' on conflict do nothing;

-- Men at Arms
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'fictional_species_prejudice', 'central_theme', false from books where title = 'Men at Arms' on conflict do nothing;

-- Siege and Storm
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Siege and Storm' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'Siege and Storm' on conflict do nothing;

-- Sourcery
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'Sourcery' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'Sourcery' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_abuse', 'central_theme', false from books where title = 'Sourcery' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Sourcery' on conflict do nothing;

-- The Devils
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'moderate', false from books where title = 'The Devils' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'The Devils' on conflict do nothing;

-- The Mark of Athena
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'bullying', 'brief', false from books where title = 'The Mark of Athena' on conflict do nothing;

-- The Silver Chair
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'The Silver Chair' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'bullying', 'brief', false from books where title = 'The Silver Chair' on conflict do nothing;

-- City of Fallen Angels
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'City of Fallen Angels' on conflict do nothing;

-- The Son of Neptune
insert into book_tropes (book_id, trope_id) select id, 'war_story' from books where title = 'The Son of Neptune' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Son of Neptune' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'racism_depicted', 'brief', false from books where title = 'The Son of Neptune' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', true from books where title = 'The Son of Neptune' on conflict do nothing;

-- The Voyage of the Dawn Treader
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'slavery', 'central_theme', false from books where title = 'The Voyage of the Dawn Treader' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'moderate', false from books where title = 'The Voyage of the Dawn Treader' on conflict do nothing;

-- The Wicked King
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'central_theme', false from books where title = 'The Wicked King' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'brief', false from books where title = 'The Wicked King' on conflict do nothing;

-- Wizard And Glass
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'torture', 'central_theme', true from books where title = 'Wizard And Glass' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'moderate', false from books where title = 'Wizard And Glass' on conflict do nothing;

-- City of Ashes
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'City of Ashes' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'incest', 'moderate', false from books where title = 'City of Ashes' on conflict do nothing;

-- The Queen of Nothing
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'kidnapping_or_captivity', 'central_theme', false from books where title = 'The Queen of Nothing' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Queen of Nothing' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'dubious_consent', 'brief', false from books where title = 'The Queen of Nothing' on conflict do nothing;

-- City of Glass
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'central_theme', true from books where title = 'City of Glass' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'central_theme', false from books where title = 'City of Glass' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'City of Glass' on conflict do nothing;
insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'incest', 'moderate', false from books where title = 'City of Glass' on conflict do nothing;

