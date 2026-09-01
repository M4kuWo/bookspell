-- Follow-up enrichment pass specifically targeting the trope-density gap
-- left open by 20260901234500_enrich_todays_undertagged_batch.sql, which
-- prioritized content warnings over tropes and explicitly left this for a
-- second pass. Re-checked the same 60-book batch on 2026-09-02: content
-- warnings now match the catalog average (1.80 vs 1.75/book), but tropes
-- were still ~37% below average (3.58 vs 5.72/book). Researched via 4
-- parallel background agents (15 books each, no DB access, pure knowledge
-- review against the controlled vocabulary), hand-reviewed before writing
-- anything -- dropped one weak-fit proposal the researching agent itself
-- flagged as uncertain (The Dragonbone Chair: dragons -- legend/backstory
-- only, no live dragon in this book, does not meet the "defining setting
-- element" bar). Every insert scoped per-book via a title subselect,
-- idempotent via ON CONFLICT DO NOTHING.

-- Sleeping Giants
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'Sleeping Giants' on conflict do nothing;

-- Sphere
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Sphere' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'time_travel' from books where title = 'Sphere' on conflict do nothing;

-- Spinning Silver
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Spinning Silver' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ancient_evil_awakens' from books where title = 'Spinning Silver' on conflict do nothing;

-- Strange the Dreamer
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Strange the Dreamer' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'Strange the Dreamer' on conflict do nothing;

-- The Adventures of Amina Al-Sirafi
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'The Adventures of Amina Al-Sirafi' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Adventures of Amina Al-Sirafi' on conflict do nothing;

-- The Bear and the Nightingale
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Bear and the Nightingale' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Bear and the Nightingale' on conflict do nothing;

-- The Blacktongue Thief
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Blacktongue Thief' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Blacktongue Thief' on conflict do nothing;

-- The Book That Wouldn’t Burn
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'The Book That Wouldn’t Burn' on conflict do nothing;

-- The Calculating Stars
insert into book_tropes (book_id, trope_id) select id, 'terraforming_or_space_colonization' from books where title = 'The Calculating Stars' on conflict do nothing;

-- The Circle
insert into book_tropes (book_id, trope_id) select id, 'satirical_or_comedic_scifi' from books where title = 'The Circle' on conflict do nothing;

-- The City of Brass
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'The City of Brass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The City of Brass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The City of Brass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The City of Brass' on conflict do nothing;

-- The Collapsing Empire
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'The Collapsing Empire' on conflict do nothing;

-- The Devils
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'The Devils' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Devils' on conflict do nothing;

-- The Diamond Age
insert into book_tropes (book_id, trope_id) select id, 'hive_mind' from books where title = 'The Diamond Age' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'hidden_talent_prodigy' from books where title = 'The Diamond Age' on conflict do nothing;

-- The Divine Comedy
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Divine Comedy' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'ghost_sight' from books where title = 'The Divine Comedy' on conflict do nothing;

-- The Dragonbone Chair
insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Dragonbone Chair' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Dragonbone Chair' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'The Dragonbone Chair' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Dragonbone Chair' on conflict do nothing;

-- The Empress of Salt and Fortune
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Empress of Salt and Fortune' on conflict do nothing;

-- The Familiar
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Familiar' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'The Familiar' on conflict do nothing;

-- The First Fifteen Lives of Harry August
insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'The First Fifteen Lives of Harry August' on conflict do nothing;

-- The Goblin Emperor
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'The Goblin Emperor' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'arranged_marriage' from books where title = 'The Goblin Emperor' on conflict do nothing;

-- The Grace of Kings
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'The Grace of Kings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'tragic_reversal_of_fortune' from books where title = 'The Grace of Kings' on conflict do nothing;

-- The Green Mile
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'The Green Mile' on conflict do nothing;

-- The Host
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Host' on conflict do nothing;

-- The Hundred Thousand Kingdoms
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Hundred Thousand Kingdoms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'deadly_competition_or_trial' from books where title = 'The Hundred Thousand Kingdoms' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Hundred Thousand Kingdoms' on conflict do nothing;

-- The Knife of Never Letting Go
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Knife of Never Letting Go' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'telepathic_animal_bond' from books where title = 'The Knife of Never Letting Go' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'The Knife of Never Letting Go' on conflict do nothing;

-- The Library at Mount Char
insert into book_tropes (book_id, trope_id) select id, 'twist_filled' from books where title = 'The Library at Mount Char' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Library at Mount Char' on conflict do nothing;

-- The Long Walk
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Long Walk' on conflict do nothing;

-- The Magicians
insert into book_tropes (book_id, trope_id) select id, 'major_character_death' from books where title = 'The Magicians' on conflict do nothing;

-- The Master and Margarita
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'The Master and Margarita' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Master and Margarita' on conflict do nothing;

-- The Mercy of Gods
insert into book_tropes (book_id, trope_id) select id, 'multiple_alien_species' from books where title = 'The Mercy of Gods' on conflict do nothing;

-- The Passage
insert into book_tropes (book_id, trope_id) select id, 'chosen_one' from books where title = 'The Passage' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'The Passage' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Passage' on conflict do nothing;

-- The Raven Boys
insert into book_tropes (book_id, trope_id) select id, 'prophecy' from books where title = 'The Raven Boys' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Raven Boys' on conflict do nothing;

-- The Selection
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'The Selection' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'The Selection' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'The Selection' on conflict do nothing;

-- The Shadow of the Torturer
insert into book_tropes (book_id, trope_id) select id, 'retrospective_memoir_narration' from books where title = 'The Shadow of the Torturer' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'powerful_artifact_macguffin' from books where title = 'The Shadow of the Torturer' on conflict do nothing;

-- The Space Between Worlds
insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'The Space Between Worlds' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'morally_grey_protagonist' from books where title = 'The Space Between Worlds' on conflict do nothing;

-- The Warded Man
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Warded Man' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'underdog_rising' from books where title = 'The Warded Man' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'The Warded Man' on conflict do nothing;

-- The Way of Shadows
insert into book_tropes (book_id, trope_id) select id, 'anti_hero' from books where title = 'The Way of Shadows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'The Way of Shadows' on conflict do nothing;

-- The Wonderful Wizard of Oz
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'The Wonderful Wizard of Oz' on conflict do nothing;

-- Theft of Swords
insert into book_tropes (book_id, trope_id) select id, 'lost_civilizations' from books where title = 'Theft of Swords' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'epic_quest' from books where title = 'Theft of Swords' on conflict do nothing;

-- To Sleep in a Sea of Stars
insert into book_tropes (book_id, trope_id) select id, 'lost_civilizations' from books where title = 'To Sleep in a Sea of Stars' on conflict do nothing;

-- Twenty Thousand Leagues Under the Sea
insert into book_tropes (book_id, trope_id) select id, 'revenge' from books where title = 'Twenty Thousand Leagues Under the Sea' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'lost_civilizations' from books where title = 'Twenty Thousand Leagues Under the Sea' on conflict do nothing;

-- Uglies
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Uglies' on conflict do nothing;

-- Unsouled
insert into book_tropes (book_id, trope_id) select id, 'wise_mentor' from books where title = 'Unsouled' on conflict do nothing;

-- Vengeful
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Vengeful' on conflict do nothing;

-- Vicious
insert into book_tropes (book_id, trope_id) select id, 'immortal_or_ageless_character' from books where title = 'Vicious' on conflict do nothing;

-- Wicked: The Life and Times of the Wicked Witch of the West
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Wicked: The Life and Times of the Wicked Witch of the West' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'rebellion_against_empire' from books where title = 'Wicked: The Life and Times of the Wicked Witch of the West' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'coming_of_age' from books where title = 'Wicked: The Life and Times of the Wicked Witch of the West' on conflict do nothing;

-- Witch King
insert into book_tropes (book_id, trope_id) select id, 'court_intrigue' from books where title = 'Witch King' on conflict do nothing;

-- Wizard's First Rule
insert into book_tropes (book_id, trope_id) select id, 'forbidden_love' from books where title = 'Wizard''s First Rule' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'Wizard''s First Rule' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'twist_ending' from books where title = 'Wizard''s First Rule' on conflict do nothing;
