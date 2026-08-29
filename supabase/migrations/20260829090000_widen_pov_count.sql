-- Widen pov_count from a binary single/multiple to a 5-value ordinal
-- scale, per user feedback: Kings of Paradise (~3 POVs) and A Game of
-- Thrones (~9 POVs) were both just "multiple" -- real information lost
-- for recommendation scoring. Buckets: single (1), dual (2), few (3-4),
-- several (5-7), ensemble (8+). See book-dna.schema.yaml for full
-- rationale.
--
-- Step 1 of 2: widen the constraint to a permissive superset (old +
-- new values) so the retagging pass below can write the new bucket
-- values without a transient CHECK violation. Existing 'single' rows
-- are untouched (no widening needed); existing 'multiple' rows get
-- reclassified into the 4 new buckets via a per-book retagging pass (86
-- books, real per-book judgment, done via batched background agents).
-- Once no row is left with pov_count = 'multiple', a follow-up migration
-- tightens the constraint to drop 'multiple' from the allowed set.

alter table book_dna drop constraint book_dna_pov_count_check;
alter table book_dna add constraint book_dna_pov_count_check
  check (pov_count = any (array['single', 'multiple', 'dual', 'few', 'several', 'ensemble']));
