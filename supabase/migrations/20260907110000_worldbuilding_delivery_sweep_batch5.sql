-- execution-DNA trope sweep, worldbuilding delivery batch 5. 6 books
-- reviewed; all 6 tagged (no skips this batch).

-- worldbuilding_via_exposition_dump -----------------------------------

-- One of the most canonical examples in the genre: the narrative is
-- literally interrupted by in-story civics-class flashback lectures
-- explicitly designed to teach the reader the setting's political
-- philosophy -- "the point... is to give the reader a guided tour of
-- the mindset and ethics" of the imagined military society.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Starship Troopers', 'Robert A. Heinlein')
on conflict do nothing;

-- Weaker/mixed: a direct complaint of "an awful lot of exposition" and
-- "political dialogue too long and convoluted," but also real praise
-- for its societal worldbuilding and idea-driven structure. Same
-- author/pattern as The Left Hand of Darkness (already tagged at 0.2).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Dispossessed', 'Ursula K. Le Guin')
on conflict do nothing;

-- Weaker/mixed: reviewers directly note "exposition minimal" overall,
-- but separately call out the committee-meeting scenes specifically
-- as "very heavy on exposition" -- a real, if narrower, complaint.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Rendezvous with Rama', 'Arthur C. Clarke')
on conflict do nothing;

-- Weaker/mixed: "a decently large amount of exposition necessary to
-- undergird the setting," criticized for spending "200 pages of...
-- meticulous world-building" before rushing the plot -- real but less
-- specifically a lecture-device complaint than Snow Crash/Cryptonomicon
-- (same author, already tagged at 0.6), more a pacing/balance issue.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Diamond Age', 'Neal Stephenson')
on conflict do nothing;

-- worldbuilding_woven_into_narrative --------------------------------

-- The Zone's rules are deliberately never fully explained -- reviewers
-- note the novel stays genuinely "vague" about its central mystery by
-- design, with meaning "woven throughout" via symbolism rather than
-- narrator explanation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Roadside Picnic', 'Arkady Strugatsky, Boris Strugatsky')
on conflict do nothing;

-- Direct, clean: "mechanics mentioned only when relevant... demonstrated
-- rather than told, avoiding heavy-handed information dumps,"
-- "organically throughout the narrative."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Golden Compass', 'Philip Pullman')
on conflict do nothing;
