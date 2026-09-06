-- execution-DNA trope sweep, worldbuilding delivery batch 2 (both
-- worldbuilding_woven_into_narrative and its negative counterpart
-- worldbuilding_via_exposition_dump, added last batch). 10 books
-- reviewed; 9 tagged, 1 left untagged (Perdido Street Station -- its
-- discourse addressed descriptive/prose density, not the discovery-
-- vs-narrator-exposition delivery axis this trope pair targets).

-- worldbuilding_woven_into_narrative --------------------------------

-- Genuinely disputed: "reveals information as Darrow encounters it...
-- learn as Darrow learns," "history woven into this tale" directly
-- contradicted by "exposition dump... multiple exposition dumps,
-- especially in the first third."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Red Rising', 'Pierce Brown')
on conflict do nothing;

-- "drops reader into unfamiliar world and explains nothing," "not
-- spoonfeeding," "narrative not bogged down by worldbuilding" -- same
-- discovery-based pattern as Gideon the Ninth/Gardens of the Moon.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Neuromancer', 'William Gibson')
on conflict do nothing;

-- "bewildering... possibly intentionally so, to create disorientation
-- the protagonist might feel" -- confusion from immersion/discovery
-- (unfamiliar court terminology, never explained by the narrator),
-- not from narrator exposition. Same pattern as Gideon/Gardens/
-- Neuromancer.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Goblin Emperor', 'Katherine Addison')
on conflict do nothing;

-- "journal structure," reader "reliant upon Piranesi's observations,"
-- "tension comes from discovery" -- clean, direct, pure discovery
-- narration.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Piranesi', 'Susanna Clarke')
on conflict do nothing;

-- Genuinely disputed: "avoiding most of it via flashback sequences...
-- doesn't tend to rely on exposition too much" directly contradicted
-- by "long-winded exposition pushed some readers away."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Words of Radiance', 'Brandon Sanderson')
on conflict do nothing;

-- worldbuilding_via_exposition_dump -----------------------------------

-- Extremely clean, well-documented example: "Stephenson lectures,
-- riffs, digresses," a literal in-fiction librarian AI character
-- exists to lecture the protagonist for pages at a time, "exposition
-- drags," reviewers call Hiro "a tiring deliverer of Sumerian history
-- and language theory."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Snow Crash', 'Neal Stephenson')
on conflict do nothing;

-- Explicit, repeated: "reads like a history book," "dense, dry,
-- confusing," "crowded with names," "brisk telling of events" --
-- literally structured as an in-world historical chronicle rather
-- than character-POV scenes.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Silmarillion', 'J.R.R. Tolkien')
on conflict do nothing;

-- Weaker/mixed: the narrative interleaves in-world ethnographic
-- "reports" and myths with the main story -- a formalized exposition
-- device, distinct from in-scene discovery, though executed with
-- literary skill readers describe as "measured and contemplative"
-- rather than tiring. Tagged at low confidence, not the clean 0.6
-- Snow Crash/Silmarillion earned.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Left Hand of Darkness', 'Ursula K. Le Guin')
on conflict do nothing;

-- Genuinely disputed: philosophical exposition delivered "through
-- dialogue" (avoiding being "transparently preachy") directly
-- contradicted by a specific, strong complaint of "230 pages of plot
-- buried in 500 pages of redundant explanations, appendices,
-- exposition... digressions."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Consider Phlebas', 'Iain M. Banks')
on conflict do nothing;
