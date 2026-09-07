-- execution-DNA trope sweep, romance_tone batch 15 of the candidate
-- pool. Deliberately picked known-intense/romantasy-reputation
-- candidates this batch to correct batch 14's understated skew (see
-- that batch's process note). 8 books reviewed against the strict
-- presentation-specific evidence standard; 4 tagged (3 melodramatic-
-- leaning, 1 understated -- better direction balance this time). 4 left
-- untagged (Glass Sword -- the "dramatic" discourse found describes the
-- book's plot/action, not the romance's presentation specifically, and
-- the romance itself is described as restrained by circumstance; Cress,
-- An Absolutely Remarkable Thing, Kings of Paradise -- real discourse
-- found for each but it addressed chemistry/integration/prominence, not
-- a clean presentation read).

-- Weak/disputed: betrayal/heartbreak beats ("expertly planned
-- betrayal... absolutely heartbroken") support melodrama, but other
-- reviewers describe the central Mare/Cal development as "perfectly
-- paced" and explicitly "not insta love" -- real, but genuinely split.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Red Queen', 'Victoria Aveyard')
on conflict do nothing;

-- Weak/disputed: "angsty romantic longing" and "dramatic irony" point
-- toward melodrama, but the same discourse calls it "cute," "slow
-- burn," and notes the romance "did not overshadow" the plot --
-- genuinely mixed rather than a clean read.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Renegades', 'Marissa Meyer')
on conflict do nothing;

-- Direct, clean: Maniscalco's books described outright as "dark,
-- melodramatic, over the top," with the Emilia/Wrath pairing
-- specifically called a "tumultuous enemies to lovers" dynamic.
-- (Re-researched after an earlier session left this untagged for lack
-- of evidence -- new, clearer evidence found this pass.)
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Kingdom of the Wicked', 'Kerri Maniscalco')
on conflict do nothing;

-- Direct, clean, repeated: called "a masterpiece of understatement,"
-- conveying "depth of feeling with an absolute minimum of words,"
-- explicitly favoring restraint over melodrama.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Empress of Salt and Fortune', 'Nghi Vo')
on conflict do nothing;
