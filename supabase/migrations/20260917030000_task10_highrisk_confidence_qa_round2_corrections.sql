-- Task 10 QA pass (round 2): corrections + confidence increases on
-- HIGH_RISK_FIELDS tags. Independently researched by CODX
-- (docs/codx-reports/2026-09-17-highrisk-confidence-qa-round2.md, its
-- own clone) and independently re-verified by CLDO -- WebFetch-checked
-- the cited sources for all 3 value corrections directly, re-confirmed
-- every current value/confidence below matched CODX's snapshot
-- immediately before writing this file. Permanent record: docs/codx-
-- reviews/codx-highrisk-confidence-qa-round2-2026-09-17.md.
--
-- Each UPDATE is conditional on the exact prior value/confidence CODX
-- researched against, so it safely no-ops rather than silently
-- overwriting anything if the underlying tag has changed since.
--
-- 7 of the 20 reviewed pairs were genuinely inconclusive and 4 were
-- schema/format mismatches (Cursed Bunny is a short-story collection
-- that doesn't map cleanly onto several single-narrative-shaped
-- fields; Quidditch Through the Ages is an in-universe fake textbook,
-- not a novel with a narrative person) -- all 11 deliberately left
-- unchanged, not included below.

-- === 3 corrections (value + confidence both change) ===

-- Translation State (Ann Leckie): two independent reviews explicitly
-- identify Qven's chapters as first-person against Enae/Reet's
-- third-person chapters -- the schema's actual "mixed" definition
-- (different grammatical persons), not an inference from differing
-- character genders/pronouns.
update book_dna set person = 'mixed'
where book_id = (select id from books where title = 'Translation State')
  and person = 'third_limited';

update book_field_confidence set confidence = 0.95
where book_id = (select id from books where title = 'Translation State')
  and field_name = 'person' and confidence = 0.3;

-- Dance of Thieves (Mary E. Pearson): book-specific accounts identify
-- the Gift as real, present, unexplained supernatural perception
-- (Kazi's own experience of it, Synove's dreams, a seer) -- neither
-- pure SF (na) nor magic-free (none); a soft, unexplained system.
update book_dna set magic_system_hardness = 'soft'
where book_id = (select id from books where title = 'Dance of Thieves')
  and magic_system_hardness = 'na';

update book_field_confidence set confidence = 0.80
where book_id = (select id from books where title = 'Dance of Thieves')
  and field_name = 'magic_system_hardness' and confidence = 0.3;

-- How to Become the Dark Lord and Die Trying (Django Wexler): two
-- independent reviews explicitly report fade-to-black sexual
-- encounters (not on-page/explicit) -- CLDO independently verified the
-- cited review text directly, per CODX's own flag that this is the
-- most boundary-sensitive of the three corrections.
update book_dna set romance_heat_intensity = 'closed_door'
where book_id = (select id from books where title = 'How to Become the Dark Lord and Die Trying')
  and romance_heat_intensity = 'moderate';

update book_field_confidence set confidence = 0.75
where book_id = (select id from books where title = 'How to Become the Dark Lord and Die Trying')
  and field_name = 'romance_heat_intensity' and confidence = 0.3;

-- === 6 confirmed-correct: confidence raised, value unchanged ===

-- Book of Night (Holly Black): confirmed a real, deliberate cliffhanger
-- ending requiring the sequel, per explicit reviews of the ending.
update book_field_confidence set confidence = 0.75
where book_id = (select id from books where title = 'Book of Night')
  and field_name = 'narrative_closure' and confidence = 0.3;

-- City of Last Chances (Adrian Tchaikovsky): confirmed self-contained,
-- per explicit reviews discussing its ending.
update book_field_confidence set confidence = 0.85
where book_id = (select id from books where title = 'City of Last Chances')
  and field_name = 'narrative_closure' and confidence = 0.3;

-- A House With Good Bones (T. Kingfisher): confirmed a soft, unexplained
-- system of family curse-magic/haunting, per book-specific accounts.
update book_field_confidence set confidence = 0.65
where book_id = (select id from books where title = 'A House With Good Bones')
  and field_name = 'magic_system_hardness' and confidence = 0.4;

-- Book of Night (Holly Black): confirmed a soft, unexplained "gloaming"
-- shadow-magic system, per book-specific accounts.
update book_field_confidence set confidence = 0.70
where book_id = (select id from books where title = 'Book of Night')
  and field_name = 'magic_system_hardness' and confidence = 0.4;

-- Evershore (Sanderson & Patterson): confirmed global-scale collective
-- conflict stakes, per book-specific accounts.
update book_field_confidence set confidence = 0.75
where book_id = (select id from books where title = 'Evershore')
  and field_name = 'stakes_scope' and confidence = 0.4;

-- Exile (R. A. Salvatore): confirmed intimate-scale personal-survival
-- stakes (Drizzt's own journey through the Underdark), per book-specific
-- accounts, not the wider Underdark setting's scale.
update book_field_confidence set confidence = 0.80
where book_id = (select id from books where title = 'Exile')
  and field_name = 'stakes_scope' and confidence = 0.4;
