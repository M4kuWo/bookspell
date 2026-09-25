-- Task 20 QA pass, round 3: corrections + confidence increases on
-- HIGH_RISK_FIELDS tags. Independently researched by CODX
-- (docs/codx-reports/2026-09-25-highrisk-confidence-qa-round3.md, its
-- own clone) and independently re-verified by CLDO -- all 22 current
-- values/confidences (0.4 across the board) confirmed against local
-- Postgres before applying, and the cited sources for the 2
-- highest-impact value corrections (Provenance/person,
-- The River Has Roots/person) fetched and re-read directly, both
-- confirming the proposed reclassification. Permanent record:
-- docs/codx-reports/2026-09-25-highrisk-confidence-qa-round3.md.
--
-- 14 of the 22 assigned pairs were genuinely inconclusive and are
-- deliberately NOT included here -- they stay at their current
-- value/0.4, per the same "unchanged means retain, not certify"
-- convention rounds 1-2 used.
--
-- Each UPDATE is conditional on the exact prior value/confidence CODX
-- researched against, so it safely no-ops rather than silently
-- overwriting anything if the underlying tag changed since.

-- === 3 corrections (value + confidence both change) ===

-- Provenance (Ann Leckie): the authorized excerpt narrates Ingray in
-- third person ("Ingray knew that if she reached...") -- re-verified
-- directly via the cited VICE excerpt, not just CODX's summary of it.
update book_dna set person = 'third_limited'
where book_id = (select id from books where title = 'Provenance')
  and person = 'first';

update book_field_confidence set confidence = 0.9
where book_id = (select id from books where title = 'Provenance')
  and field_name = 'person' and confidence = 0.4;

-- The River Has Roots (Amal El-Mohtar): re-verified directly via the
-- cited Reactor review -- explicitly describes an omniscient narrator
-- ("as if you're there watching the sisters like an omniscient god"),
-- not a single-character-limited viewpoint.
update book_dna set person = 'third_omniscient'
where book_id = (select id from books where title = 'The River Has Roots')
  and person = 'third_limited';

update book_field_confidence set confidence = 0.8
where book_id = (select id from books where title = 'The River Has Roots')
  and field_name = 'person' and confidence = 0.4;

-- The Rise and Fall of D.O.D.O. (Neal Stephenson, Nicole Galland):
-- secondary plot summaries describe historical interventions reshaping
-- international relations and preventing magic's disappearance
-- civilization-wide, not a single city/kingdom-scoped conflict.
update book_dna set stakes_scope = 'global'
where book_id = (select id from books where title = 'The Rise and Fall of D.O.D.O.')
  and stakes_scope = 'regional';

update book_field_confidence set confidence = 0.8
where book_id = (select id from books where title = 'The Rise and Fall of D.O.D.O.')
  and field_name = 'stakes_scope' and confidence = 0.4;

-- === 5 confidence-only increases (value already correct) ===

update book_field_confidence set confidence = 0.85
where book_id = (select id from books where title = 'Gone')
  and field_name = 'stakes_scope' and confidence = 0.4;

update book_field_confidence set confidence = 0.8
where book_id = (select id from books where title = 'The Knight and the Moth')
  and field_name = 'romance_heat_intensity' and confidence = 0.4;

update book_field_confidence set confidence = 0.8
where book_id = (select id from books where title = 'The Raven Scholar')
  and field_name = 'magic_system_hardness' and confidence = 0.4;

update book_field_confidence set confidence = 0.95
where book_id = (select id from books where title = 'The Redemption of Time')
  and field_name = 'stakes_scope' and confidence = 0.4;

update book_field_confidence set confidence = 0.8
where book_id = (select id from books where title = 'The Rise and Fall of D.O.D.O.')
  and field_name = 'narrative_closure' and confidence = 0.4;
