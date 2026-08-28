-- Catalog-wide series book_count/status correction. Every series in
-- the DB was auto-populated from Hardcover's raw feed at step 03
-- ingestion time (omnibus editions, box sets, translations, etc. all
-- counted as separate "books"), despite the project's own design intent
-- that series/universe data be curated, not auto-populated. Corrected
-- here against real-world publication facts. Mistborn (both eras),
-- Stormlight, and Middle-earth/LOTR were already fixed separately
-- (see fix_cosmere.sql / fix_middle_earth.sql).
--
-- Where I'm not confident of an exact current count for a fast-moving
-- ongoing series, book_count is left NULL rather than guessed -- the
-- schema explicitly allows this ("nullable/estimated while ongoing").

update series set book_count = 5, status = 'ongoing' where name = 'A Court of Thorns and Roses';
update series set book_count = 7, status = 'ongoing' where name = 'A Song of Ice and Fire';
update series set book_count = 1, status = 'completed' where name = 'American Gods';
update series set book_count = 3, status = 'ongoing' where name = 'Ana and Din Mysteries';
update series set book_count = 3, status = 'completed' where name = 'Bas-Lag';
update series set book_count = 4, status = 'ongoing' where name = 'Before the Coffee Gets Cold';
update series set book_count = 2, status = 'completed' where name = 'Bird Box';
update series set book_count = 1, status = 'completed' where name = 'Blade Runner';
update series set book_count = 5, status = 'ongoing' where name = 'Bobiverse';
update series set book_count = 1, status = 'completed' where name = 'Cerulean Chronicles';
update series set book_count = 3, status = 'ongoing' where name = 'Children of Time';
update series set book_count = 41, status = 'completed' where name = 'Discworld';
update series set book_count = 3, status = 'completed' where name = 'Divergent';
update series set book_count = 6, status = 'completed' where name = 'Dune';
update series set book_count = 12, status = 'ongoing' where name = 'Dungeon Crawler Carl';
update series set book_count = 6, status = 'completed' where name = 'Earthsea Cycle';
update series set book_count = 2, status = 'completed' where name = 'Earthseed';
update series set book_count = 4, status = 'ongoing' where name = 'Ender''s Saga';
update series set book_count = 7, status = 'completed' where name = 'Foundation';
update series set book_count = 7, status = 'ongoing' where name = 'Gentleman Bastard';
update series set book_count = 8, status = 'completed' where name = 'Hainish Cycle';
update series set book_count = 7, status = 'completed' where name = 'Harry Potter';
update series set book_count = null, status = 'ongoing' where name = 'He Who Fights with Monsters';
update series set book_count = 3, status = 'ongoing' where name = 'Hierarchy';
update series set book_count = 3, status = 'completed' where name = 'His Dark Materials';
update series set book_count = 4, status = 'completed' where name = 'Hyperion Cantos';
update series set book_count = 2, status = 'completed' where name = 'Jurassic Park';
update series set book_count = 2, status = 'ongoing' where name = 'Legends & Lattes';
update series set book_count = 7, status = 'ongoing' where name = 'Millennium';
update series set book_count = 3, status = 'ongoing' where name = 'Ninth House';
update series set book_count = 6, status = 'completed' where name = 'Old Man''s War';
update series set book_count = 5, status = 'completed' where name = 'Percy Jackson and the Olympians';
update series set book_count = 2, status = 'completed' where name = 'Ready Player One';
update series set book_count = 7, status = 'ongoing' where name = 'Red Rising Saga';
update series set book_count = 3, status = 'completed' where name = 'Remembrance of Earth''s Past';
update series set book_count = 5, status = 'completed' where name = 'Robot';
update series set book_count = 5, status = 'ongoing' where name = 'Shades of Magic';
update series set book_count = 3, status = 'completed' where name = 'Silo';
update series set book_count = 2, status = 'completed' where name = 'Six of Crows';
update series set book_count = 4, status = 'ongoing' where name = 'Southern Reach';
update series set book_count = 3, status = 'completed' where name = 'Sprawl';
update series set book_count = 1, status = 'completed' where name = 'Strange & Norrell';
update series set book_count = 3, status = 'completed' where name = 'The Broken Earth';
update series set book_count = 3, status = 'completed' where name = 'The Broken Empire';
update series set book_count = 7, status = 'completed' where name = 'The Chronicles of Narnia (Publication Order)';
update series set book_count = 10, status = 'completed' where name = 'The Chronicles of the Black Company';
update series set book_count = 8, status = 'completed' where name = 'The Dark Tower';
update series set book_count = 5, status = 'ongoing' where name = 'The Empyrean';
update series set book_count = 9, status = 'completed' where name = 'The Expanse';
update series set book_count = 4, status = 'completed' where name = 'The Faithful and the Fallen';
update series set book_count = 3, status = 'completed' where name = 'The Farseer Trilogy';
update series set book_count = 3, status = 'completed' where name = 'The First Law';
update series set book_count = 3, status = 'completed' where name = 'The Folk of the Air';
update series set book_count = 2, status = 'completed' where name = 'The Forever War';
update series set book_count = 4, status = 'completed' where name = 'The Giver';
update series set book_count = 3, status = 'completed' where name = 'The Green Bone Saga';
update series set book_count = 5, status = 'completed' where name = 'The Hitchhiker''s Guide to the Galaxy';
update series set book_count = 5, status = 'ongoing' where name = 'The Hunger Games';
update series set book_count = 4, status = 'completed' where name = 'The Inheritance Cycle';
update series set book_count = 3, status = 'ongoing' where name = 'The Kingkiller Chronicle';
update series set book_count = 4, status = 'completed' where name = 'The Locked Tomb';
update series set book_count = 5, status = 'completed' where name = 'The Maze Runner';
update series set book_count = 1, status = 'completed' where name = 'The Midnight World';
update series set book_count = 6, status = 'completed' where name = 'The Mortal Instruments';
update series set book_count = 7, status = 'ongoing' where name = 'The Murderbot Diaries';
update series set book_count = 3, status = 'completed' where name = 'The Poppy War';
update series set book_count = 2, status = 'ongoing' where name = 'The Roots of Chaos';
update series set book_count = 3, status = 'completed' where name = 'The Shadow and Bone Trilogy';
update series set book_count = 4, status = 'completed' where name = 'The Twilight Saga';
update series set book_count = 13, status = 'completed' where name = 'The Vampire Chronicles';
update series set book_count = 14, status = 'completed' where name = 'The Wheel of Time';
update series set book_count = 8, status = 'completed' where name = 'The Witcher';
update series set book_count = 7, status = 'completed' where name = 'Throne of Glass';
update series set book_count = 5, status = 'completed' where name = 'Time Quintet';
update series set book_count = 4, status = 'completed' where name = 'Wayfarers';
