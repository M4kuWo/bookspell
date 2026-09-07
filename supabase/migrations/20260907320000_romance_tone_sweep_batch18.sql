-- execution-DNA trope sweep, romance_tone batch 18 of the candidate
-- pool. An unusually thin batch, following directly on batch 17's thin
-- yield -- the easy, well-known candidates in this pool are largely
-- exhausted. 7 books reviewed; only 1 tagged (disputed). 6 left
-- untagged: Mickey7 (discourse explicitly reads as farce/comedy, a
-- third register this trope pair doesn't cover, not restrained or
-- melodramatic); Ship of Destiny (real discourse, but about narrative
-- agency/contrivance, not presentation); The Last Unicorn (only thin,
-- generic "restraint" language, not a directly-quoted claim); Dark Age,
-- The Circle, A Storm of Swords (real discourse found for each, but
-- none of it addressed presentation-of-emotion specifically).

-- Weak/disputed: some reviewers found the Will/Lyra romance "rushed
-- and a bit corny," with Lyra becoming "almost fully submissive," but
-- others praised the restrained mutual reliance and called the
-- bittersweet ending among "the best pages" -- genuinely split.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Amber Spyglass', 'Philip Pullman')
on conflict do nothing;
