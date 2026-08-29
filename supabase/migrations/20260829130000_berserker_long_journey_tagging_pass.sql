-- Consolidates the retroactive tagging pass for berserker_rage and
-- long_journey (added in 20260829120000) across the full catalog, done
-- via 8 parallel batch agents. 26 total tags: 3 berserker_rage, 23
-- long_journey.

insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'A Wizard of Earthsea' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'American Gods' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Children of Time' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Eragon' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Harry Potter and the Deathly Hallows' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Hyperion' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'I Who Have Never Known Men' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'berserker_rage' from books where title = 'Oathbringer' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Parable of the Sower' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Station Eleven' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Alchemist' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'berserker_rage' from books where title = 'The Blade Itself' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Eye of the World' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Fellowship of the Ring' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Golden Compass' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Gunslinger' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Hobbit, or There and Back Again' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Lightning Thief' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Long Way to a Small, Angry Planet' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Return of the King' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Road' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Sea of Monsters' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'berserker_rage' from books where title = 'The Song of Achilles' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Two Towers' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'The Wise Man''s Fear' on conflict do nothing;
insert into book_tropes (book_id, trope_id) select id, 'long_journey' from books where title = 'Tress of the Emerald Sea' on conflict do nothing;
