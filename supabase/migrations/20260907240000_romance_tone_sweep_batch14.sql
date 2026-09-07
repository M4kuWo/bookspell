-- execution-DNA trope sweep, romance_tone batch 14 of the candidate pool.
-- 11 books reviewed against the strict presentation-specific evidence
-- standard; only 4 tagged, all understated -- a real skew this batch,
-- not a selection artifact: 7 left untagged (Daughter of the Moon
-- Goddess, The Familiar, Legend, The Grey Bastards, Prince of Fools,
-- The Book Eaters, Katabasis) because their real discourse addressed
-- prominence/pacing/quality/buildup rather than a clean presentation
-- read, or (Prince of Fools, Grey Bastards) barely had a central
-- romantic relationship to judge tone on at all. Process note: this
-- batch's candidate picks leaned toward quieter/literary titles: the
-- next romance_tone batch should deliberately include known-intense
-- romantasy candidates to keep both directions represented, the way
-- batch 11/12 did.

-- Direct, clean: "quiet relationship forming," described as a
-- restrained slow-burn sapphic romance with minimal explicit content,
-- emphasis on "thoughtful, understated" emotional beats throughout.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Light From Uncommon Stars', 'Ryka Aoki')
on conflict do nothing;

-- Direct, clean: explicitly "not a swoony gothic 'hot guy in an old
-- house' romance," described as "sweet" and "low-key" with chemistry
-- as an "undercurrent" rather than overt declarations or confrontation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Starling House', 'Alix E. Harrow')
on conflict do nothing;

-- Direct, clean: the ending "teeters on the edge of melodrama" but
-- explicitly "does not quite fall into the abyss below" -- restraint
-- specifically contrasted against melodrama by name.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('How to Stop Time', 'Matt Haig')
on conflict do nothing;

-- Direct, clean: reviewers explicitly emphasize "mutual understanding
-- and emotional support" over "overt romantic gestures," a bond built
-- on "utter lack of judgement" rather than declarations -- restrained,
-- not melodramatic, per direct contrast in the discourse.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Heir of Fire', 'Sarah J. Maas')
on conflict do nothing;
