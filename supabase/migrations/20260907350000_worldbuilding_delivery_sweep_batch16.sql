-- execution-DNA trope sweep, worldbuilding delivery batch 16 of the
-- candidate pool. 6 books reviewed against the presentation-of-delivery
-- evidence standard; 5 tagged (2 clean woven, 1 clean exposition-dump,
-- 3 disputed -- one book tagged on both sides). 1 left untagged
-- (Between Two Fires -- discourse addressed tone/POV shifts and
-- gloom-balance, not narrator-exposition-vs-discovery specifically).

-- Direct, clean: worldbuilding described as "intuitive and easy to
-- understand," avoiding books that "drown readers in terminology";
-- exposition delivered with "a sense of humor," no info-dump
-- criticisms turned up.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Age of Myth', 'Michael J. Sullivan')
on conflict do nothing;

-- Direct, clean, repeated: the author "stumbles" trying "to pack too
-- much lore... into certain parts," leaving "huge sections of dense
-- exposition that put a damper on the story's momentum," requiring
-- readers to "take notes for the first few chapters."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Blackwing', 'Ed McDonald')
on conflict do nothing;

-- Direct, clean (majority read): worldbuilding "skillfully woven into
-- the narrative" so it "seem[s] effortless," establishing setting
-- "without getting bogged down."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Master of Djinn', 'P. Djèlí Clark')
on conflict do nothing;

-- Weak/disputed counterpoint on the same book: one reviewer specifically
-- flags "clunky bits of exposition" that "verge on 'As you know, Bob'"
-- -- a named, real exposition-dump pattern, a genuine minority
-- exception to the book's otherwise-woven reputation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Master of Djinn', 'P. Djèlí Clark')
on conflict do nothing;

-- Weak/disputed: one reviewer explicitly says the book "doesn't have
-- the problem of clunky or heavy exposition," but another describes
-- Adeyemi "front-loading the exposition" at the start "when details
-- could be gradually incorporated" -- a real, clean split.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Children of Blood and Bone', 'Tomi Adeyemi')
on conflict do nothing;

-- Weak/disputed: one strand praises worldbuilding "organically shown...
-- rather than dumped at the start," but others describe footnotes that
-- "bloated the page" and "exceed[ed] exposition," with the narration
-- "insisting" nothing could be understood without them -- real,
-- specific, and contested.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Chain-Gang All-Stars', 'Nana Kwame Adjei-Brenyah')
on conflict do nothing;
