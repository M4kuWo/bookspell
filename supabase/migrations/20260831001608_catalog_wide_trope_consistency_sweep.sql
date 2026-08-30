-- Catalog-wide trope consistency sweep, covering all 307 tagged books
-- (not just the 2026-08-30 batch). Method: cross-checked every series
-- against its own sibling entries for tropes present on some books but
-- missing on others despite the same element being real on both --
-- direct internal-consistency evidence rather than speculative addition.
-- Notable finds: the Dune saga was missing space_opera on 3 of 5 books
-- despite being the genre's own textbook space opera; Wheel of Time was
-- missing multiple_fantasy_species (Trollocs, Ogier) on every entry but
-- book 1 despite them recurring throughout; Discworld book 1 had
-- high_fantasy_setting but the other 4 catalog entries didn't, despite
-- sharing the same base setting the satire operates on top of; A Song of
-- Ice and Fire books 1-2 were missing multiple_fantasy_species (direwolves)
-- that books 3 and 5 have. 31 additions across 28 books.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'A Game of Thrones' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'A Clash of Kings' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'found_family' from books where title = 'A Wrinkle in Time' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Caliban''s War' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Dune' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Dune Messiah' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Children of Dune' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'space_opera' from books where title = 'Red Rising' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'The Blade Itself' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'sudden_apocalypse_event' from books where title = 'The Fifth Season' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'The Name of the Wind' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'Twilight' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Warbreaker' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Guards! Guards!' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Mort' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'Equal Rites' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'high_fantasy_setting' from books where title = 'The Light Fantastic' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'A Crown of Swords' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Dragon Reborn' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Fires of Heaven' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Great Hunt' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'multiple_fantasy_species' from books where title = 'The Shadow Rising' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'renaissance_or_mercantile_setting' from books where title = 'Crooked Kingdom' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'secret_royalty' from books where title = 'The Lord of the Rings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'mentor_death' from books where title = 'The Lord of the Rings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'reluctant_hero' from books where title = 'The Lord of the Rings' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'redemption_arc' from books where title = 'The Lord of the Rings' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Crown of Midnight' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Heir of Fire' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Queen of Shadows' on conflict do nothing;

insert into book_tropes (book_id, trope_id) select id, 'medieval_european_setting' from books where title = 'Empire of Storms' on conflict do nothing;

