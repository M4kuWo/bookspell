-- audiobook_editions had no unique constraint beyond its auto-generated
-- `id` PK -- meaning `on conflict do nothing` (as this table's own
-- INSERT convention, and the tag-audiobook-editions skill's own
-- example, both use) would silently do NOTHING to prevent duplicate
-- rows if a migration ever got re-applied: two identical INSERTs would
-- just create two rows with different fresh UUIDs, not a real
-- conflict. That violates this project's standing idempotent-SQL
-- requirement (CLAUDE.md).
--
-- A unique constraint on book_id alone would be wrong -- this table is
-- deliberately one-to-many (a book can have more than one real
-- edition, e.g. an original GraphicAudio recording and a later "Tenth
-- Anniversary" re-recording of the same book, both legitimate). A
-- constraint on (book_id, edition_type, production_company) would
-- still collide for that exact case, since both editions share the
-- same type and company. source_url is the one column that's
-- naturally distinct per real edition (each has its own product page)
-- while still allowing multiple real editions per book, so that's the
-- key used here.
alter table audiobook_editions
  add constraint audiobook_editions_book_source_unique
  unique (book_id, source_url);
