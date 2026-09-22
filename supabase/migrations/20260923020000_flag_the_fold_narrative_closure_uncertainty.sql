-- CODX's Task 16 QA pass flagged "The Fold" (Peter Clines) as "likely
-- wrong" on narrative_closure = requires_series, based on one review
-- describing enough closure to stand alone. Independently re-checked
-- (CLDO, 2026-09-23) before changing anything, per CODX's own explicit
-- caveat that it hadn't inspected the actual ending: a second, separate
-- source describes the ending as leaving real "more to come" setup for
-- a sequel, with at least one reader explicitly frustrated by a
-- semi-cliffhanger. That does NOT confirm the proposed self_contained
-- correction -- the evidence is genuinely mixed, not a clear error like
-- Enchanters' End Game turned out to be. Leaving the tag as-is; flagging
-- the real uncertainty via book_field_confidence instead of guessing
-- either direction. See docs/codx-reviews/2026-09-22-post-round5-qa.md.
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrative_closure', 0.5, 'manual_review'
from books where title = 'The Fold' and author = 'Peter Clines'
on conflict (book_id, field_name) do update set confidence = excluded.confidence, source = excluded.source;
