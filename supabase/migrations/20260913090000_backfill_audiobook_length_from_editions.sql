-- Backfill book_dna.audiobook_length from real audiobook_editions data
-- (2026-09-13, prompted by a real user noticing "The Way of Kings" showed
-- no audiobook length despite the app claiming that field is tagged
-- catalog-wide). audiobook_editions (1123 rows, collected separately from
-- the book_dna tagging batches) has real runtime_minutes for standard-
-- edition audiobooks that was never backfilled into this bucketed field.
--
-- Mechanical, not a judgment call: docs/schema/book-dna.schema.yaml's own
-- documented thresholds (short <8h, standard 8-15h, long 15-25h, epic
-- 25h+) applied directly to runtime_minutes/60. Scoped to the 40 books
-- with EXACTLY ONE 'standard'-type audiobook_editions row with a non-null
-- runtime -- 18 more books have multiple standard-edition rows with
-- differing runtimes (different narrators/publishers/abridgements) and
-- are deliberately left null rather than guessing which one is "the"
-- canonical length. All 40 titles confirmed unique in `books` before
-- generating this (title-scoped, per this project's migration
-- convention, never a raw UUID).
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = '11/22/63')
  and audiobook_length is null;
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = 'A Clash of Kings')
  and audiobook_length is null;
update book_dna set audiobook_length = 'short'
where book_id = (select id from books where title = 'A Clockwork Orange')
  and audiobook_length is null;
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = 'A Feast for Crows')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'A Wizard’s Guide to Defensive Baking')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Artemis')
  and audiobook_length is null;
update book_dna set audiobook_length = 'short'
where book_id = (select id from books where title = 'Before the Coffee Gets Cold')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Bird Box')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Brave New World')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Catching Fire')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Circe')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Dark Matter')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Do Androids Dream of Electric Sheep?')
  and audiobook_length is null;
update book_dna set audiobook_length = 'short'
where book_id = (select id from books where title = 'Edgedancer')
  and audiobook_length is null;
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = 'Elantris')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Good Omens: The Nice and Accurate Prophecies of Agnes Nutter, Witch')
  and audiobook_length is null;
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = 'He Who Fights with Monsters')
  and audiobook_length is null;
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = 'Kings of Paradise')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Klara and the Sun')
  and audiobook_length is null;
update book_dna set audiobook_length = 'long'
where book_id = (select id from books where title = 'Leviathan Wakes')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Old Man''s War')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Parable of the Sower')
  and audiobook_length is null;
update book_dna set audiobook_length = 'long'
where book_id = (select id from books where title = 'Perdido Street Station')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Prince of Thorns')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Shadow and Bone')
  and audiobook_length is null;
update book_dna set audiobook_length = 'long'
where book_id = (select id from books where title = 'Snow Crash')
  and audiobook_length is null;
update book_dna set audiobook_length = 'long'
where book_id = (select id from books where title = 'The Ballad of Songbirds and Snakes')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'The Black Company')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'The Cruel Prince')
  and audiobook_length is null;
update book_dna set audiobook_length = 'long'
where book_id = (select id from books where title = 'The Fifth Season')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'The Gunslinger')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'The Handmaid’s Tale')
  and audiobook_length is null;
update book_dna set audiobook_length = 'short'
where book_id = (select id from books where title = 'The Hitchhiker''s Guide to the Galaxy')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'The Maze Runner')
  and audiobook_length is null;
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = 'The Name of the Wind')
  and audiobook_length is null;
update book_dna set audiobook_length = 'long'
where book_id = (select id from books where title = 'The Poppy War')
  and audiobook_length is null;
update book_dna set audiobook_length = 'short'
where book_id = (select id from books where title = 'The Road')
  and audiobook_length is null;
update book_dna set audiobook_length = 'epic'
where book_id = (select id from books where title = 'The Way of Kings')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'Tomorrow, and Tomorrow, and Tomorrow')
  and audiobook_length is null;
update book_dna set audiobook_length = 'standard'
where book_id = (select id from books where title = 'We Are Legion (We Are Bob)')
  and audiobook_length is null;
