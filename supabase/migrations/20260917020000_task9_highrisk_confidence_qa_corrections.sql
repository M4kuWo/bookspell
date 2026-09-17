-- Task 9 QA pass: corrections + confidence increases on HIGH_RISK_FIELDS
-- tags flagged low-confidence from 2026-09-16's two tagging batches.
-- Independently researched by CODX (docs/codx-reports/2026-09-17-highrisk-
-- confidence-qa-pass.md, its own clone) and independently re-verified by
-- CLDO -- WebFetch-checked the cited sources for the 3 value corrections
-- and the Shroud/Ilium identity disambiguation, re-confirmed every current
-- value/confidence below matched CODX's snapshot immediately before writing
-- this file. Permanent record: docs/codx-reviews/codx-highrisk-confidence-
-- qa-pass-2026-09-17.md.
--
-- Each UPDATE is conditional on the exact prior value/confidence CODX
-- researched against, so it safely no-ops rather than silently overwriting
-- anything if the underlying tag has changed since (e.g. from a later,
-- independent tagging correction).

-- === 3 corrections (value + confidence both change) ===

-- Gateway (Frederik Pohl): CODX's most interpretive finding -- Broadhead's
-- retrospective account is distorted by guilt/self-deception per 3
-- independent reviews (Andrew Gibson, Wildspace, Jo Walton's Reactor essay),
-- not simply an unpleasant protagonist. Verified the cited review text
-- directly before applying.
update book_dna set narrator_reliability = 'unreliable'
where book_id = (select id from books where title = 'Gateway')
  and narrator_reliability = 'reliable';

update book_field_confidence set confidence = 0.75
where book_id = (select id from books where title = 'Gateway')
  and field_name = 'narrator_reliability' and confidence = 0.4;

-- Fall or, Dodge in Hell (Neal Stephenson): BookRags' study-guide Point of
-- View section explicitly identifies an omniscient third-person narrator,
-- not mixed grammatical persons (different characters/worlds are not
-- different persons). Verified the cited source text directly.
update book_dna set person = 'third_omniscient'
where book_id = (select id from books where title = 'Fall or, Dodge in Hell')
  and person = 'mixed';

update book_field_confidence set confidence = 0.80
where book_id = (select id from books where title = 'Fall or, Dodge in Hell')
  and field_name = 'person' and confidence = 0.5;

-- Gods of Jade and Shadow (Silvia Moreno-Garcia): two independent reviews
-- identify three recurring viewpoint threads (Casiopea, Martin, Vucub-Kame),
-- fitting the schema's "few" (3-4) bucket, not "dual". Verified the primary
-- cited review's exact wording directly before applying.
update book_dna set pov_count = 'few'
where book_id = (select id from books where title = 'Gods of Jade and Shadow')
  and pov_count = 'dual';

update book_field_confidence set confidence = 0.85
where book_id = (select id from books where title = 'Gods of Jade and Shadow')
  and field_name = 'pov_count' and confidence = 0.5;

-- === 8 confirmed-correct: confidence raised, value unchanged ===

-- Shroud (Adrian Tchaikovsky, 2025 -- disambiguated from John Banville's
-- unrelated 2003 novel of the same title; CLDO independently verified the
-- Goodreads editions listing + Orbit's official excerpt both match the
-- hosted synopsis/ISBN before trusting any of the three findings below).
update book_field_confidence set confidence = 0.85
where book_id = (select id from books where title = 'Shroud')
  and field_name = 'pov_count' and confidence = 0.4;

update book_field_confidence set confidence = 0.80
where book_id = (select id from books where title = 'Shroud')
  and field_name = 'person' and confidence = 0.5;

update book_field_confidence set confidence = 0.70
where book_id = (select id from books where title = 'Shroud')
  and field_name = 'humor_level' and confidence = 0.5;

-- Soulless (Gail Carriger): a PhD thesis analyzing the novel against
-- Regis's 8-part romance structure -- stronger evidence than a genre label.
update book_field_confidence set confidence = 0.75
where book_id = (select id from books where title = 'Soulless')
  and field_name = 'drive' and confidence = 0.4;

-- Lord of Light (Roger Zelazny): a study-guide's explicit Point of View
-- section describes narrator access to multiple characters' thoughts away
-- from Sam, matching the schema's omniscient category.
update book_field_confidence set confidence = 0.75
where book_id = (select id from books where title = 'Lord of Light')
  and field_name = 'person' and confidence = 0.5;

-- The Bright Sword (Lev Grossman): a review specifically describes
-- recurrent banter/gallows humor alongside quests and violence -- book-
-- specific evidence, not an assumption from Grossman's general style.
update book_field_confidence set confidence = 0.70
where book_id = (select id from books where title = 'The Bright Sword')
  and field_name = 'humor_level' and confidence = 0.5;

-- Accelerando (Charles Stross): concrete comic devices identified (a
-- multi-page FAQ for revived historical simulations, perceptual filtering
-- of unwanted guests) -- specific to this novel, not reputation-based.
update book_field_confidence set confidence = 0.75
where book_id = (select id from books where title = 'Accelerando')
  and field_name = 'humor_level' and confidence = 0.5;

-- Ilium (Dan Simmons): an authorized ebook preview directly shows chapter 1
-- (Hockenberry) in first person and chapter 2 (Daeman) in third person --
-- CLDO verified this is a genuine grammatical-person mix, not a generic
-- "multi-POV" label.
update book_field_confidence set confidence = 0.90
where book_id = (select id from books where title = 'Ilium')
  and field_name = 'person' and confidence = 0.6;

-- 10 of the original 21 items were reviewed and found genuinely
-- inconclusive -- left unchanged on purpose, per CODX's report: Congo/
-- person, Dreamcatcher/person, Legion/narrator_reliability, Pushing Ice/
-- pov_count, Shards of Honour/drive, Six Wakes/narrator_reliability, The
-- Bright Sword/pov_count, The Deep Sky/drive, Annie Bot/humor_level, The
-- Echo Wife/humor_level.
