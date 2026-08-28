-- Third vocabulary growth round: user-sourced field ideas. See
-- docs/schema/book-dna.md ("Third growth round") and
-- docs/remaining-catalog-tagging/findings.md for rationale.

-- Two new tropes
insert into tropes (id, group_name, spoiler) values
  ('dragons', 'setting_worldbuilding', false),
  ('coming_of_age', 'character_archetypes', false);

-- Four new scalar fields. Every book needs a value for these (unlike
-- tropes/content warnings), so no default is set here — the retagging
-- pass fills every row before these are treated as "complete" data.
alter table book_dna add column prose_density text
  check (prose_density in ('sparse', 'moderate', 'lush'));
alter table book_dna add column prose_complexity text
  check (prose_complexity in ('accessible', 'moderate', 'dense'));
alter table book_dna add column intellectual_weight text
  check (intellectual_weight in ('escapist', 'moderate', 'cerebral'));
alter table book_dna add column stakes_scope text
  check (stakes_scope in ('intimate', 'regional', 'global', 'cosmic'));
