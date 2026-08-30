-- Enrichment pass on the 140 books tagged in the 2026-08-30 batch runs
-- (migrations 20260830221511 through 20260830234428). A quality audit
-- comparing that batch against the pre-existing catalog found tropes/book
-- was meaningfully lower (4.70 avg vs. 7.65 for pre-existing tags),
-- concentrated almost entirely in the setting_worldbuilding trope group
-- (applied to 35% of new books vs. 71% of pre-existing ones) and, to a
-- lesser extent, character_archetypes and craft_devices. This adds 58
-- genuinely missing, defining setting/craft tropes across 49 of those 140
-- books -- real gaps (e.g. no ACOTAR book had fae_or_fairies/fae_courts;
-- most Red Rising/Expanse/Foundation/Ancillary Justice entries lacked
-- space_opera; most Wheel of Time/Malazan/Stormlight entries lacked
-- high_fantasy_setting), not padding for its own sake. Does not touch any
-- pre-existing catalog data or scalar book_dna fields.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'A Court of Frost and Starlight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_courts' from books where title = 'A Court of Frost and Starlight' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'A Court of Frost and Starlight' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'A Court of Silver Flames' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_courts' from books where title = 'A Court of Silver Flames' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'A Court of Silver Flames' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'A Crown of Swords' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'A Discovery of Witches' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'A Memory Called Empire' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Ancillary Justice' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Assassin''s Quest' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Babylon''s Ashes' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Before They Are Hanged' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'Blindsight' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Blood of Elves' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Blood of Elves' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Blood of Elves' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Breaking Dawn' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Brisingr' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Brisingr' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'Brisingr' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Cibola Burn' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Dark Age' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Dawnshard' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Eclipse' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Fairy Tale' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Foundation and Empire' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Gardens of the Moon' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'God Emperor of Dune' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'magic_school' from books where title = 'Harry Potter and the Cursed Child' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'House of Earth and Blood' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Iron Gold' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Last Argument of Kings' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Light Bringer' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Mistborn: Secret History' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Nemesis Games' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'New Moon' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Persepolis Rising' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'dystopia' from books where title = 'Red Queen' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Royal Assassin' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Second Foundation' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Sword of Destiny' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Sword of Destiny' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'The Black Prism' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Complete Chronicles of Narnia' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'The Dragon Reborn' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'The Fall of Hyperion' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'The Fires of Heaven' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'The Great Hunt' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Obelisk Gate' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'The Shadow of What Was Lost' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'The Shadow Rising' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'post_apocalyptic' from books where title = 'The Stone Sky' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'The Sword of Kaigen' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Tiamat''s Wrath' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Uprooted' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Wind and Truth' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'non_european_inspired_setting' from books where title = 'Yumi and the Nightmare Painter' on conflict do nothing;

