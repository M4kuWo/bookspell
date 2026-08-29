-- Step 2 of 2 (see 20260829090000): tighten pov_count's CHECK constraint
-- now that the retagging pass has reclassified every row out of the old
-- 'multiple' value.

alter table book_dna drop constraint book_dna_pov_count_check;
alter table book_dna add constraint book_dna_pov_count_check
  check (pov_count = any (array['single', 'dual', 'few', 'several', 'ensemble']));
