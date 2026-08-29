-- Split werewolves_or_shapeshifters into two distinct tropes, per user
-- feedback: classic lycanthropy (full moon, silver vulnerability,
-- involuntary wolf-monster transformation) is a very different reader
-- signal from general shapeshifting (Animagi, kandra, dopplers,
-- Beauty-and-the-Beast-style curses, mimicry). Each of the 19
-- previously-tagged books is reclassified below based on which specific
-- mechanic actually appears in that book -- some get one, some the
-- other, one (Prisoner of Azkaban) gets both.

insert into tropes (id, group_name, spoiler) values
  ('werewolves', 'setting_worldbuilding', false),
  ('shapeshifters', 'setting_worldbuilding', false)
on conflict do nothing;

-- werewolves: classic lycanthropy
insert into book_tropes (book_id, trope_id) select id, 'werewolves' from books where title = 'City of Bones' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves' from books where title = 'Harry Potter and the Prisoner of Azkaban' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves' from books where title = 'Harry Potter and the Order of the Phoenix' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves' from books where title = 'Harry Potter and the Half-Blood Prince' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves' from books where title = 'Harry Potter and the Deathly Hallows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'werewolves' from books where title = 'The House in the Cerulean Sea' on conflict do nothing;

-- shapeshifters: general form-changing, not lycanthropy
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'A Court of Thorns and Roses' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'A Wizard of Earthsea' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'Harry Potter and the Prisoner of Azkaban' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'Mistborn: The Final Empire' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'The Well of Ascension' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'The Hero of Ages' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'The Alloy of Law' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'Shadows of Self' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'The Bands of Mourning' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'The Lost Metal' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'Ninth House' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'The Last Wish' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'The Gate of the Feral Gods' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'shapeshifters' from books where title = 'Twilight' on conflict do nothing;

-- remove the old combined tag and trope entirely
delete from book_tropes where trope_id = 'werewolves_or_shapeshifters';
delete from tropes where id = 'werewolves_or_shapeshifters';
