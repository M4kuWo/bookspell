-- Adds a self-referencing parent_series_id to series, so a series can
-- optionally nest under a broader saga umbrella without a rigid
-- universe -> world -> series three-tier requirement. Arbitrary depth,
-- reuses the existing table instead of adding a new one.
--
-- Example: Cosmere (universe) -> Mistborn (parent series, no books of
-- its own) -> Mistborn Era One / Mistborn Era Two (child series, each
-- with their own books). Same mechanism will work for Abercrombie's
-- First Law World or similar once/if the catalog has enough of those
-- books to make it worth modeling (it doesn't yet -- see project log).

alter table series add column parent_series_id uuid references series(id);

-- Mistborn: create the parent umbrella, nest the two eras under it.
insert into series (id, name, status, book_count, universe_id) values
  ('7c1a1e2d-5b3f-4a6e-9c8d-2f1e3a4b5c6d', 'Mistborn', 'ongoing', 7, '6862330c-db3a-4b83-abaa-448406c1f77e')
on conflict (id) do nothing;

update series set parent_series_id = '7c1a1e2d-5b3f-4a6e-9c8d-2f1e3a4b5c6d'
where name in ('Mistborn Era One', 'Mistborn Era Two (Wax and Wayne)');

-- Stormlight Archive: the existing series row becomes Era One (5 books
-- once Wind and Truth is added to the catalog -- see project log for
-- that gap), a new parent umbrella is created, and an empty Era Two
-- placeholder represents the real-world not-yet-published second arc.
update series set name = 'Stormlight Archive Era One', book_count = 5, status = 'completed'
where name = 'The Stormlight Archive';

insert into series (id, name, status, book_count, universe_id) values
  ('9d2b3c4e-6a5f-4b7c-8d9e-3f2a4b5c6d7e', 'The Stormlight Archive', 'ongoing', null, '6862330c-db3a-4b83-abaa-448406c1f77e'),
  ('a3c4d5e6-7b6f-4c8d-9e0f-4a3b5c6d7e8f', 'Stormlight Archive Era Two', 'ongoing', null, '6862330c-db3a-4b83-abaa-448406c1f77e')
on conflict (id) do nothing;

update series set parent_series_id = '9d2b3c4e-6a5f-4b7c-8d9e-3f2a4b5c6d7e'
where name in ('Stormlight Archive Era One', 'Stormlight Archive Era Two');
