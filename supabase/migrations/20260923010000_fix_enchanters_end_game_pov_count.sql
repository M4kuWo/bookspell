-- Enchanters' End Game (David Eddings, The Belgariad #5) was tagged
-- pov_count = single -- confirmed wrong by CODX's Task 16 QA pass and
-- independently re-verified here (web search: this book is the one
-- Belgariad volume that departs from Garion-only narration, splitting
-- roughly half its length between Garion/Belgarath/Silk and Ce'Nedra
-- leading the western defense alongside multiple named Alorn queens,
-- each getting real page time). Confirmed wrong, but the exact
-- few-vs-several boundary (does each named queen count as its own
-- recurring viewpoint, or read more as a collective council thread)
-- isn't settled without a full read -- corrected to the defensible
-- floor (few: Garion, Ce'Nedra, the queens' thread) rather than guessed
-- at the higher bucket, with the real remaining uncertainty recorded
-- via book_field_confidence per this project's standing convention for
-- exactly this situation, not silently picked.
update book_dna
set pov_count = 'few'
where book_id = (select id from books where title = 'Enchanters'' End Game' and author = 'David Eddings');

-- book_field_confidence.source is a constrained enum (ai_inferred/
-- verified_external/manual_review/community_tagged/community_confirmed),
-- not a free-text explanation field -- the "why" lives in this file's
-- own comment above and in docs/codx-reviews/2026-09-22-post-round5-qa.md,
-- not in the row itself.
insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'pov_count', 0.6, 'manual_review'
from books where title = 'Enchanters'' End Game' and author = 'David Eddings'
on conflict (book_id, field_name) do update set confidence = excluded.confidence, source = excluded.source;
