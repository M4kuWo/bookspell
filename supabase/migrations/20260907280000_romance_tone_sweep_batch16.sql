-- execution-DNA trope sweep, romance_tone batch 16 of the candidate
-- pool. 6 books reviewed against the strict presentation-specific
-- evidence standard; all 6 tagged (4 understated -- 1 disputed, 2
-- melodramatic -- 1 disputed). No skips this batch.

-- Direct, clean, repeated: reviewer found Scarlet "incredibly
-- melodramatic at every turn," to the point of "dreading the chapters"
-- centered on her -- a real, specific presentation complaint, not just
-- a general dislike of her as a character.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Scarlet', 'Marissa Meyer')
on conflict do nothing;

-- Weak/disputed: reviewers explicitly call the Darrow/Mustang dynamic
-- "restrained rather than melodramatic" and praise the tyranny's
-- "genuine intellectual force... rather than melodramatic," but the
-- same discourse's dominant complaint is that the relationship is too
-- thin/underdeveloped ("not much actual connection... obvious
-- flirting") -- a different axis (prominence) muddying the read.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Golden Son', 'Pierce Brown')
on conflict do nothing;

-- Weak/disputed: Kirkus directly says "the melodrama sometimes is a
-- bit much" in this second book, a real shift from book 1 (already
-- tagged understated) -- but the overall discourse still calls the
-- romance charming and the melodrama only occasional, not dominant.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Emily Wilde’s Map of the Otherlands', 'Heather Fawcett')
on conflict do nothing;

-- Direct, clean: explicitly described as "restrained" rather than
-- melodramatic, consistent with book 1 (Magic Bites, already tagged
-- understated) -- hate-to-love tension kept as subtext, "vaguely
-- trying" rather than played for dramatic declarations.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Magic Burns', 'Ilona Andrews')
on conflict do nothing;

-- Direct, clean: explicitly "a restrained approach rather than a
-- melodramatic one," described as "emotionally nuanced rather than
-- melodramatic."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Day of Fallen Night', 'Samantha Shannon')
on conflict do nothing;

-- Direct, clean: a doomed romance handled with "restraint and
-- emotional depth," expressed "through poetry and perfectly chosen
-- words" rather than overt declarations -- explicitly "restrained,
-- literary... rather than melodramatic."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Blacktongue Thief', 'Christopher Buehlman')
on conflict do nothing;
