-- worldbuilding_delivery trope sweep, batch 19 (continuing the sequential
-- batch numbering from batch 18, 20260908060000_worldbuilding_delivery_sweep_batch18.sql).
-- Per CLAUDE.md/tag-catalog-batch's Step 0, ONLY the worldbuilding_delivery
-- half of the priority batch was worked this session -- romance_tone is a
-- separate, unrelated work item this time and was not touched.
--
-- Candidates researched came from the live query:
--   select b.title, b.author from books b join book_dna d on d.book_id = b.id
--   where d.worldbuilding_density = 'dense'
--   and not exists (select 1 from book_tropes t where t.book_id = b.id
--     and t.trope_id in ('worldbuilding_woven_into_narrative','worldbuilding_via_exposition_dump'))
--   order by b.title;
-- (400 live candidates at session start). This session's web search budget
-- was exhausted partway through research (same documented precedent as
-- romance_tone batch 10 and the audiobook-editions skill's Step A2 batch 2
-- -- see docs/project-log.md), so only ~20 of a planned 30+ candidates got
-- a real search attempt; the rest of the pool is untouched, not exhausted.
--
-- Why each tag, condensed (full reasoning in docs/project-log.md):
--  - Blood of Elves (Sapkowski): reviews describe the book's history/lore
--    coming out "in dialogue" (a specific in-scene example: Geralt
--    explaining an elf/human war's history to Ciri at a ruin, mid-scene)
--    and contrast this favorably with material "thrown at the beginning"
--    in other fantasy -- a real, delivery-mechanism-specific description
--    of in-scene discovery. worldbuilding_woven_into_narrative, 0.6.
--  - Baptism of Fire (Sapkowski, same series, later book): reviews describe
--    "plodding and info-dumping sections" where "the story came to a
--    standstill as all the politics were divulged" and "the entire history
--    of Ciri's bloodline is even explained" -- narrator/character telling
--    rather than in-scene discovery, and specific to this later book (not
--    the same evidence as Blood of Elves' book 1). worldbuilding_via_
--    exposition_dump, 0.6.
--  - Ancillary Mercy (Leckie): reviews describe the Radch worldbuilding as
--    delivered through "narrative perspective, language choices" (the
--    Radchaai pronoun convention) "emerging organically through the
--    story" rather than exposition -- a real, mechanism-specific
--    description, if somewhat series-general rather than book-3-specific.
--    worldbuilding_woven_into_narrative, 0.6.
--  - A Desolation Called Peace (Martine): most reviews describe it as
--    "narration-heavy yet exposition-light," leaving imperial detail "to
--    be shown but more rarely explained," letting readers avoid "an
--    intense crash course" -- but one reviewer directly disagrees,
--    describing the same book as "talking the plot to death." Genuinely
--    disputed, real evidence on both sides. worldbuilding_woven_into_
--    narrative, 0.2 (below MIN_CONFIDENCE_TO_COUNT, excluded from scoring
--    until validated further).
--  - Altered Carbon (Morgan): reviews split between "exposition takes over
--    character development" and reads "dry," versus sci-fi elements
--    "explained through Kovacs' voice" blending worldbuilding into
--    character narration. Genuinely disputed. worldbuilding_via_
--    exposition_dump, 0.2.
--
-- Idempotent: on conflict do nothing on every insert, safe to re-run.

insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books where title = 'Blood of Elves' and author = 'Andrzej Sapkowski'
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books where title = 'Baptism of Fire' and author = 'Andrzej Sapkowski'
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books where title = 'Ancillary Mercy' and author = 'Ann Leckie'
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'worldbuilding_woven_into_narrative', 0.2, 'ai_inferred'
from books where title = 'A Desolation Called Peace' and author = 'Arkady Martine'
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books where title = 'Altered Carbon' and author = 'Richard K. Morgan'
on conflict do nothing;
