-- Confidence + source layer, per the 2026-08-30 external feedback
-- triage: attach a confidence score (0-1) and a source to field/trope
-- values instead of treating every tag as equally-certain ground truth.
-- Two uses beyond scoring: (1) a triage signal -- low-confidence books
-- are exactly the ones needing deeper research; (2) once community
-- self-tagging exists, confidence can rise when community tags
-- correlate with ours (deferred, not built).
--
-- book_tropes gets confidence/source directly (already one row per
-- (book, trope) tag). Scalar book_dna fields need a side table instead
-- (one wide row per book, ~29 columns) -- book_field_confidence, keyed
-- by (book_id, field_name) so it also covers non-book_dna per-book
-- attributes like `books.work_type` without needing its own table.
--
-- source values: 'ai_inferred' (the vast majority of this catalog --
-- an LLM agent read/knows the book and made a judgment call),
-- 'verified_external' (a real, citable external authority -- e.g.
-- work_type's Hugo Award citations), 'manual_review' (a deliberate
-- editorial correction, not a fresh batch inference), 'community_tagged'
-- / 'community_confirmed' (future, once community self-tagging exists
-- -- see book-dna.md's backlog note; not populated yet).
--
-- confidence is nullable and deliberately NOT backfilled for the bulk
-- of existing data -- most of this catalog's tags predate this system,
-- and assigning precise confidence numbers to everything already tagged
-- would be fabrication, not data. Absence of a row means "unassessed,"
-- scored as full confidence (1.0) by default -- see recommend.py --
-- rather than silently penalizing the vast majority of tags that were
-- never flagged as uncertain. Only real, traceable cases are backfilled
-- below: work_type's Hugo Award-backed novellas, and the specific
-- pov_count values this session's own batch agents explicitly flagged
-- as borderline/uncertain (or that were manually corrected on review).
-- A systematic confidence audit across the rest of the catalog is
-- separate, larger future work -- logged to book-dna.md's backlog, not
-- attempted here.

alter table book_tropes add column confidence numeric check (confidence >= 0 and confidence <= 1);
alter table book_tropes add column source text not null default 'ai_inferred'
  check (source in ('ai_inferred', 'verified_external', 'manual_review', 'community_tagged', 'community_confirmed'));

create table book_field_confidence (
  book_id uuid not null references books(id),
  field_name text not null,
  confidence numeric not null check (confidence >= 0 and confidence <= 1),
  source text not null default 'ai_inferred'
    check (source in ('ai_inferred', 'verified_external', 'manual_review', 'community_tagged', 'community_confirmed')),
  primary key (book_id, field_name)
);

-- work_type: verified_external, backed by real publishing classification
-- (2020 Hugo Award for Best Novella, in This Is How You Lose the Time
-- War's case; the other 5 are the well-established Murderbot/Edgedancer
-- novella classifications).
insert into book_field_confidence (book_id, field_name, confidence, source)
  select id, 'work_type', 1.0, 'verified_external' from books
  where title in (
    'All Systems Red', 'Artificial Condition', 'Rogue Protocol', 'Exit Strategy',
    'Edgedancer', 'This Is How You Lose the Time War'
  );

-- pov_count: manual_review corrections (7 books where the original
-- batch agent's floor at 'dual' was an artifact of a wrong instruction
-- assumption, corrected 2026-08-29 after review) -- moderately high
-- confidence, a deliberate editorial fix, not a fresh guess.
insert into book_field_confidence (book_id, field_name, confidence, source)
  select id, 'pov_count', 0.85, 'manual_review' from books
  where title in (
    'American Gods', 'The Fellowship of the Ring', 'The Lies of Locke Lamora',
    'Dungeon Crawler Carl', 'Carl''s Doomsday Scenario',
    'The Dungeon Anarchist''s Cookbook', 'The Gate of the Feral Gods'
  );

-- pov_count: genuine, still-unresolved uncertainty the batch agents
-- explicitly flagged in their own reports (not corrected, since there
-- was no confident alternative to correct TO -- see project-log.md).
insert into book_field_confidence (book_id, field_name, confidence, source) values
  ((select id from books where title = 'A Game of Thrones'), 'pov_count', 0.6, 'ai_inferred'),
  ((select id from books where title = 'Ender''s Game'), 'pov_count', 0.6, 'ai_inferred'),
  ((select id from books where title = 'City of Bones'), 'pov_count', 0.6, 'ai_inferred'),
  ((select id from books where title = 'House of Leaves'), 'pov_count', 0.6, 'ai_inferred'),
  ((select id from books where title = 'I, Robot'), 'pov_count', 0.55, 'ai_inferred'),
  ((select id from books where title = 'Jurassic Park'), 'pov_count', 0.55, 'ai_inferred'),
  ((select id from books where title = 'The Bands of Mourning'), 'pov_count', 0.6, 'ai_inferred'),
  ((select id from books where title = 'The Eye of the Bedlam Bride'), 'pov_count', 0.4, 'ai_inferred'),
  ((select id from books where title = 'The Butcher''s Masquerade'), 'pov_count', 0.45, 'ai_inferred'),
  ((select id from books where title = 'The Lion, the Witch and the Wardrobe'), 'pov_count', 0.6, 'ai_inferred'),
  ((select id from books where title = 'This Inevitable Ruin'), 'pov_count', 0.55, 'ai_inferred'),
  ((select id from books where title = 'Tomorrow, and Tomorrow, and Tomorrow'), 'pov_count', 0.6, 'ai_inferred'),
  ((select id from books where title = 'We Are Legion (We Are Bob)'), 'pov_count', 0.65, 'ai_inferred'),
  ((select id from books where title = 'The Hitchhiker''s Guide to the Galaxy'), 'pov_count', 0.55, 'ai_inferred');
