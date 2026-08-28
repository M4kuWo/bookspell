-- Set up the Cosmere as a proper universe (was previously mis-modeled
-- as a "series" for Elantris, with book_count=45 pulled straight from
-- Hardcover's raw feed, and never linked at all for the other Cosmere
-- books). A book directly in a series gets series_id set (universe is
-- derived via series.universe_id); a standalone book that's still part
-- of a shared universe gets series_id null and universe_id set
-- directly -- no redundant double-linking. Fixed literal UUID so this
-- script is portable across local and hosted without a psql-only
-- \gset variable capture.

insert into universe (id, name) values
  ('6862330c-db3a-4b83-abaa-448406c1f77e', 'The Cosmere')
on conflict (id) do nothing;

-- Mistborn Era One (was "The Mistborn Saga: The Original Trilogy",
-- book_count=7/status=completed -- both wrong; it's 3 books).
update series set name = 'Mistborn Era One', book_count = 3, status = 'completed',
  universe_id = '6862330c-db3a-4b83-abaa-448406c1f77e'
where name = 'The Mistborn Saga: The Original Trilogy';

-- Mistborn Era Two / Wax and Wayne (was "Mistborn: Wax & Wayne",
-- book_count=9 -- the specific error you caught; it's 4 books).
update series set name = 'Mistborn Era Two (Wax and Wayne)', book_count = 4, status = 'completed',
  universe_id = '6862330c-db3a-4b83-abaa-448406c1f77e'
where name = 'Mistborn: Wax & Wayne';

-- The Stormlight Archive: Sanderson's own stated plan is two 5-book
-- back-to-back arcs, 10 total (was book_count=38).
update series set book_count = 10, status = 'ongoing',
  universe_id = '6862330c-db3a-4b83-abaa-448406c1f77e'
where name = 'The Stormlight Archive';

-- Elantris: standalone Cosmere novel, not a "series" of its own --
-- unlink the bogus "The Cosmere" series entry, keep universe link only.
update books set series_id = null, universe_id = '6862330c-db3a-4b83-abaa-448406c1f77e'
where title = 'Elantris';
delete from series where name = 'The Cosmere';

-- Warbreaker: standalone (no confirmed sequel -- "Nightblood" is
-- rumored, unwritten). Drop the speculative 2-book "series", keep
-- universe link only.
update books set series_id = null, universe_id = '6862330c-db3a-4b83-abaa-448406c1f77e'
where title = 'Warbreaker';
delete from series where name = 'Warbreaker' and book_count = 2;

-- Tress of the Emerald Sea: standalone Cosmere novel. "Hoid's
-- Travails" isn't an official series name, and only 1 of the actual 4
-- "Secret Projects" novellas it loosely groups with is in this
-- catalog -- not enough to model as a real series yet. Drop the link,
-- keep universe only; can be revisited if the other three get added.
update books set series_id = null, universe_id = '6862330c-db3a-4b83-abaa-448406c1f77e'
where title = 'Tress of the Emerald Sea';
delete from series where name = 'Hoid''s Travails';
