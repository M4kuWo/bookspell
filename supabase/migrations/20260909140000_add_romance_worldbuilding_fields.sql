-- Step 1 of the convert-romance-worldbuilding-fields skill: add the two new
-- scalar book_dna columns that romance_tone/worldbuilding_delivery will live
-- in, replacing their current trope-pair representation.
--
-- Why: romance_tone (understated vs. melodramatic) and worldbuilding_delivery
-- (woven vs. exposition_dump) were deliberately tagged as trope pairs first
-- (understated_romance/melodramatic_romance_subplot,
-- worldbuilding_woven_into_narrative/worldbuilding_via_exposition_dump) as a
-- cheap validation probe using existing trope machinery, before committing to
-- real schema -- see docs/schema/book-dna.md's "Romance TONE/execution-quality"
-- entry and docs/scoring-test-protocol.md's 2026-09-05 "Execution-DNA
-- validation probes" entry. The probe validated (correctly-signed weights,
-- confirmed in production scoring) and a multi-week tagging sweep has since
-- built up real data, so these are being promoted to proper scalar fields.
--
-- Why 3 values each, not a clean binary: a handful of books have been tagged
-- with BOTH tropes in a pair -- real evidence found both ways during tagging,
-- not a bug. 'mixed' is an honest third value for that case rather than
-- forcing a binary choice that would drop real evidence. NULL (the default,
-- left untouched by this migration) means "no evidence either way" and is
-- distinct from 'mixed'.
--
-- This migration is purely additive (new nullable columns, no data written or
-- read) -- zero risk to existing data. The trope-pair data itself is left in
-- place; converting/backfilling it into these columns and removing the old
-- trope data are separate, later steps (Steps 2-4 of the skill), deliberately
-- NOT part of this migration.

alter table book_dna add column romance_tone text
  check (romance_tone = any (array['understated', 'melodramatic', 'mixed']));
alter table book_dna add column worldbuilding_delivery text
  check (worldbuilding_delivery = any (array['woven', 'exposition_dump', 'mixed']));
