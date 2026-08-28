-- Splits what stakes_scope was conflating: breadth of what's at risk
-- (kept as stakes_scope) vs. how dire it is for the protagonist
-- personally (new personal_stakes field). See docs/schema/book-dna.md
-- for the full reasoning and worked examples.

alter table book_dna add column personal_stakes text
  check (personal_stakes in ('low', 'moderate', 'high', 'life_threatening'));
