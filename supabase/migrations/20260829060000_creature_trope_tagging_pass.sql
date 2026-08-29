-- Retroactive tagging pass for the 7 creature tropes (dragons, vampires,
-- elves, dwarves, fae_or_fairies, orcs, werewolves_or_shapeshifters)
-- across the full catalog, done via 8 parallel agents batching ~21 books
-- each. Also includes a manual consistency fix: the agent covering
-- Mistborn: The Final Empire correctly tagged werewolves_or_shapeshifters
-- for OreSeur (a kandra, a bone-based shapeshifter), but the agents
-- covering the rest of the Mistborn saga defaulted to zero across the
-- board per a "no elves/dwarves/dragons in Scadrial" hint that didn't
-- call out kandra specifically -- kandra (OreSeur/TenSoon/MeLaan) are a
-- recurring shapeshifter thread through the whole saga, not just book 1.

-- A Court of Thorns and Roses
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'A Court of Thorns and Roses' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'A Court of Thorns and Roses' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'A Court of Mist and Fury' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'A Court of Wings and Ruin' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'A Wizard of Earthsea' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'A Wizard of Earthsea' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'American Gods' on conflict do nothing;

-- Eragon / Carl's Doomsday Scenario / Dungeon Crawler Carl / City of Bones
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'Eragon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Eragon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'orcs' from books where title = 'Eragon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'Carl''s Doomsday Scenario' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Carl''s Doomsday Scenario' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'orcs' from books where title = 'Carl''s Doomsday Scenario' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'Dungeon Crawler Carl' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Dungeon Crawler Carl' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'orcs' from books where title = 'Dungeon Crawler Carl' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'City of Bones' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'City of Bones' on conflict do nothing;

-- Harry Potter series
insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'Harry Potter and the Philosopher''s Stone' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Harry Potter and the Chamber of Secrets' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'Harry Potter and the Prisoner of Azkaban' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'Harry Potter and the Goblet of Fire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Harry Potter and the Goblet of Fire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Harry Potter and the Order of the Phoenix' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'Harry Potter and the Order of the Phoenix' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Harry Potter and the Half-Blood Prince' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'Harry Potter and the Half-Blood Prince' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'Harry Potter and the Deathly Hallows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Harry Potter and the Deathly Hallows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'Harry Potter and the Deathly Hallows' on conflict do nothing;

-- Jonathan Strange & Mr Norrell / Legends & Lattes / Mistborn: The Final Empire / Ninth House
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'Jonathan Strange & Mr Norrell' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'orcs' from books where title = 'Legends & Lattes' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'Legends & Lattes' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'Legends & Lattes' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'Legends & Lattes' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'Mistborn: The Final Empire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'Ninth House' on conflict do nothing;

-- The Alchemist through The Bands of Mourning: none of the 7 apply except noted above

-- LOTR / Narnia / Witcher / Name of the Wind / Priory / Cruel Prince / House in Cerulean Sea
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'The Fellowship of the Ring' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'The Fellowship of the Ring' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'orcs' from books where title = 'The Fellowship of the Ring' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'The Hobbit, or There and Back Again' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'The Hobbit, or There and Back Again' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'orcs' from books where title = 'The Hobbit, or There and Back Again' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'The Two Towers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'The Two Towers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'orcs' from books where title = 'The Two Towers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'The Return of the King' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'The Return of the King' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'orcs' from books where title = 'The Return of the King' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'The Lion, the Witch and the Wardrobe' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'elves' from books where title = 'The Last Wish' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dwarves' from books where title = 'The Last Wish' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'The Last Wish' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'The Name of the Wind' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'The Wise Man''s Fear' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'The Cruel Prince' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'The House in the Cerulean Sea' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'fae_or_fairies' from books where title = 'The House in the Cerulean Sea' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'The House in the Cerulean Sea' on conflict do nothing;

-- Dungeon Crawler Carl sequels + Tress of the Emerald Sea + Twilight
insert into book_tropes (book_id, trope_id) select id, 'vampires' from books where title = 'The Butcher''s Masquerade' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'The Gate of the Feral Gods' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'dragons' from books where title = 'Tress of the Emerald Sea' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'Twilight' on conflict do nothing;

-- Manual consistency fix: kandra (OreSeur/TenSoon/MeLaan) run through the
-- entire Mistborn saga, not just book 1 -- werewolves_or_shapeshifters
-- should apply to the rest of the saga too, not just The Final Empire.
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'The Well of Ascension' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'The Hero of Ages' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'The Alloy of Law' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'Shadows of Self' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'The Bands of Mourning' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves_or_shapeshifters' from books where title = 'The Lost Metal' on conflict do nothing;
