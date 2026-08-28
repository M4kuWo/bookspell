-- The Hobbit was linked to a bogus "Middle Earth" series (book_count=19,
-- its only member) instead of being recognized as a standalone prequel
-- in the same wider setting as the Lord of the Rings trilogy. Model
-- properly: a "Middle-earth" universe holding both the standalone
-- Hobbit and the LOTR trilogy series, matching how Cosmere now works.

insert into universe (id, name) values
  ('a1e6b6d4-3f9a-4b1e-9f2b-3d6e2c8a7b10', 'Middle-earth')
on conflict (id) do nothing;

update books set series_id = null, universe_id = 'a1e6b6d4-3f9a-4b1e-9f2b-3d6e2c8a7b10', position_in_series = null
where title = 'The Hobbit, or There and Back Again';
delete from series where name = 'Middle Earth';

update series set name = 'The Lord of the Rings', book_count = 3, status = 'completed',
  universe_id = 'a1e6b6d4-3f9a-4b1e-9f2b-3d6e2c8a7b10'
where name = 'The Lord of the Rings';
