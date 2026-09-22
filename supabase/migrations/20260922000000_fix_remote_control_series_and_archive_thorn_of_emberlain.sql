-- Two small, unrelated data fixes flagged by CLDA during round-5 tagging
-- (see docs/project-log.md's 2026-09-21 "Round-5 tagging batch 5" and
-- "Catalog tagging batch 11" entries) but left for CLDO since neither is
-- a tagging-time judgment call the skill covers step-by-step.

-- 1. "Remote Control" (Nnedi Okorafor, 2021) is a standalone novella --
--    unrelated to her "Who Fears Death" series -- but got ingested with
--    that series' series_id, which also inflated the series row's
--    apparent membership. Decouple it; scoped by (title, author) per
--    CLAUDE.md's migration convention, not title alone.
update books
set series_id = null
where title = 'Remote Control' and author = 'Nnedi Okorafor';

-- 2. "The Thorn of Emberlain" (Scott Lynch, Gentleman Bastard #4) --
--    confirmed unpublished across two separate CLDA tagging passes
--    (batches 11 and round-5 batch 4), sitting untagged with zero
--    dependent rows. Archive it the same way the round-4 backlog's 118
--    non-SFF/graphic-novel/omnibus/unpublished books were archived
--    (20260921010000), rather than leaving it as a dangling untagged row.
update books
set archived = true,
    archived_reason = 'unpublished',
    archived_at = now()
where title = 'The Thorn of Emberlain' and author = 'Scott Lynch';
