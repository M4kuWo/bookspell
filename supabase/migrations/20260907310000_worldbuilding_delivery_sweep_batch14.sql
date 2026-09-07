-- execution-DNA trope sweep, worldbuilding delivery batch 14 of the
-- candidate pool. 6 books reviewed against the presentation-of-delivery
-- evidence standard; 4 tagged (2 clean woven, 2 disputed exposition-
-- dump). 2 left untagged (Ancillary Mercy -- discourse addressed
-- trilogy-wide themes/pacing, not this book's delivery mechanism
-- specifically; The Passage -- genuinely ambiguous, one review calling
-- inserted documents "too-well blueprinted" while another praised how
-- seamlessly description was integrated).

-- Weak/disputed: reviewers directly praise Muir's "absolute refusal to
-- spoon feed exposition," but the same book's climax is separately
-- described as drowning in "torrents of exposition" delivered
-- "hastily" -- a real, clean split on how the late-book exposition
-- actually lands.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Harrow the Ninth', 'Tamsyn Muir')
on conflict do nothing;

-- Direct, clean: readers are dropped in medias res with the author
-- "wasting no time on introductions or explaining the rules," instead
-- "slowly reveal[ing] pieces of a much larger puzzle" through the
-- story itself.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Library at Mount Char', 'Scott Hawkins')
on conflict do nothing;

-- Direct, clean, repeated: magic is "seamlessly integrated into the
-- fabric of everyday life," rules introduced "gradually," exposition
-- "feels natural rather than forced," "without overwhelming readers."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Rivers of London', 'Ben Aaronovitch')
on conflict do nothing;

-- Weak/disputed: one reviewer explicitly praises that worldbuilding
-- wasn't presented as "Character A telling a story of history to
-- Character B in a very lazy section of exposition," but others
-- describe "a lot of exposition" whose "political exposition can
-- overwhelm" and argue the author should have added more explanation
-- for readers unfamiliar with the Islamic-folklore basis -- genuinely
-- mixed on the delivery itself.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The City of Brass', 'S. A. Chakraborty')
on conflict do nothing;
