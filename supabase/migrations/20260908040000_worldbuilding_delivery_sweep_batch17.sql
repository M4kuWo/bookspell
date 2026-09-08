-- execution-DNA trope sweep, worldbuilding delivery batch 17 of the
-- candidate pool. 7 books reviewed against the presentation-of-delivery
-- evidence standard; 4 tagged (2 clean woven, 2 disputed exposition-
-- dump). 3 left untagged (Caraval -- discourse was about worldbuilding
-- being thin/confusing/contradictory, a density-and-coherence
-- complaint, not a clean delivery-mechanism read; Carry On -- only
-- generic creativity/originality praise, nothing about narrator-
-- exposition-vs-discovery specifically; Daughter of No Worlds -- only
-- generic quality praise, same issue).

-- Direct, clean, repeated: readers learn about the world "because of
-- the dangers the characters face, not through long passages of
-- exposition"; backstories are "seamlessly woven into the current
-- action."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Crooked Kingdom', 'Leigh Bardugo')
on conflict do nothing;

-- Weak/disputed: a real, specific complaint about "endless trivial
-- descriptions of bureaucracy" and "oblique dead-end details" that
-- amount to "an obstinate refusal to further the plot... other than
-- with fruitless clues" -- excessive unenlightening description,
-- distinct from (and alongside) the book's separate, deliberate
-- ambiguity about its central mystery.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Authority', 'Jeff VanderMeer')
on conflict do nothing;

-- Direct, clean, repeated: "worldbuilding isn't revealed until later
-- in the book," exposition handled so it "feels like it's being
-- written in first [person]," readers "discover the world's mysteries
-- alongside the protagonist rather than through lengthy explanatory
-- passages."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_woven_into_narrative', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Daughter of Smoke & Bone', 'Laini Taylor')
on conflict do nothing;

-- Weak/disputed: one strand praises the world "unveil[ing] without
-- exposition dumps," but another reviewer specifically flags
-- "occasional but dense info-dumps and expositions," naming the
-- Queen's backstory as a concrete example -- real and specific on both
-- sides.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'worldbuilding_via_exposition_dump', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Aching God', 'Mike Shel')
on conflict do nothing;
