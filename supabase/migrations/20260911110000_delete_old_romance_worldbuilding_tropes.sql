-- Step 4 of the convert-romance-worldbuilding-fields skill: remove the old
-- book_tropes rows and the 4 trope vocabulary entries now that Steps 1-3
-- have converted this data into book_dna.romance_tone/worldbuilding_delivery
-- scalar columns (see 20260909140000_add_romance_worldbuilding_fields.sql
-- and 20260911100000_backfill_romance_worldbuilding_fields.sql).
--
-- Why delete rather than leave them: per the schema decision, these 4
-- trope IDs should never be tagged again now that the scalar fields exist
-- (tagging both the old trope and the new field for the same book would be
-- redundant and could drift out of sync over time).
--
-- Reversibility: run only after live, explicit repo-owner confirmation in
-- the main conversation (not just the project's file-based
-- PENDING_APPROVALS.md gate -- see docs/TODO.md's note on this). Every row
-- being deleted here was captured immediately beforehand in the companion
-- file 20260911110000_delete_old_romance_worldbuilding_tropes_manifest.tsv,
-- so both the book_tropes associations and the tropes vocabulary rows
-- themselves are fully reinstatable from that file if ever needed.

-- Dependent-row check per CLAUDE.md: book_tropes must be empty for these 4
-- trope IDs before deleting from tropes itself (the delete below achieves
-- that; this delete statement is the one being verified, not a separate
-- pre-check query, since there's no other table referencing book_tropes
-- rows by these trope_ids).
delete from book_tropes where trope_id in (
  'understated_romance', 'melodramatic_romance_subplot',
  'worldbuilding_woven_into_narrative', 'worldbuilding_via_exposition_dump'
);

delete from tropes where id in (
  'understated_romance', 'melodramatic_romance_subplot',
  'worldbuilding_woven_into_narrative', 'worldbuilding_via_exposition_dump'
);
