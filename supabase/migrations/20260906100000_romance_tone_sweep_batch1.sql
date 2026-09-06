-- execution-DNA trope sweep, romance_tone batch 1 of the candidate pool
-- (see .claude/skills/tag-catalog-batch/SKILL.md Step 0). 21 books
-- reviewed against the strict presentation-specific evidence standard
-- (how emotion is EXPRESSED on the page, never drive/pacing/toxicity/
-- quality/heat -- see the skill for the full exclusion list); 18 tagged,
-- 3 left untagged because the evidence found didn't clear the bar
-- either way (A Court of Wings and Ruin, A Court of Frost and
-- Starlight, An Ember in the Ashes -- all had real discourse, but it
-- was craft-quality or plot-drama commentary, not presentation-of-
-- emotion evidence).
--
-- Note: A Court of Mist and Fury and A Court of Wings and Ruin (both
-- Feyre/Rhysand, same series) landed differently -- ACOMAF has clear
-- melodrama evidence (reviewers describe a tonal shift into
-- "Harlequin romance/erotica" register), ACOWAR's own reviews instead
-- emphasize partnership/equality without describing scene-level
-- emotional expression either way. Consistent with the skill's own
-- warning not to assume tone from series reputation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Court of Mist and Fury', 'Sarah J. Maas')
on conflict do nothing;

-- Evidence blends real plot-event drama (a kidnapping, a murder) with
-- emotional-intensity language -- not a clean presentation-only read.
-- Tagged below MIN_CONFIDENCE_TO_COUNT rather than skipped, since a
-- real (if weak) lean toward dramatic was found.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Crown of Midnight', 'Sarah J. Maas')
on conflict do nothing;

-- Direct quoted declaration ("You are my life now") plus a documented
-- reputation for absolutist, heightened romantic dialogue -- real
-- presentation evidence, not just genre pattern-matching.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Breaking Dawn', 'Stephenie Meyer')
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('City of Bones', 'Cassandra Clare')
on conflict do nothing;

-- Reviewers use "restraint" directly to describe how the Will/Jem/
-- Tessa triangle is handled -- no rivalry staged, feelings shown
-- through subtle hints rather than declarations, an explicit contrast
-- with typical love-triangle presentation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Clockwork Angel', 'Cassandra Clare')
on conflict do nothing;

-- Weak/adjacent evidence: reviewers call the romance underdeveloped
-- ("little meaning", "few paragraphs together") rather than
-- describing a restrained-but-real emotional presentation -- may be
-- a craft-quality complaint more than a tone one. Recorded, not
-- skipped, since a real lean toward "understated" was found.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Cinder', 'Marissa Meyer')
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Court of Silver Flames', 'Sarah J. Maas')
on conflict do nothing;

-- Strong, specific presentation evidence: no kiss/makeout scene,
-- feelings shown through action (Kaz's fear-of-touch arc) rather than
-- declaration, reviewers explicitly praising the restraint.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Crooked Kingdom', 'Leigh Bardugo')
on conflict do nothing;

-- Adjacent evidence: search surfaced Miller's general narrative-voice
-- style (distant, controlled) rather than a scene-specific read on the
-- Circe/Odysseus relationship itself. Real lean, not a clean case.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Circe', 'Madeline Miller')
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Daughter of Smoke & Bone', 'Laini Taylor')
on conflict do nothing;

-- Genuinely disputed in real discourse: one review calls it
-- "melodramatic," another calls the exact same romance "bland and
-- mild-mannered" -- a real, direct contradiction rather than
-- one-sided evidence either way.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Discovery of Witches', 'Deborah Harkness')
on conflict do nothing;

-- Weak evidence: reviewers describe witty banter, not specifically
-- restrained emotional expression -- banter/humor is adjacent to but
-- not the same axis as romance_tone.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Bride', 'Ali Hazelwood')
on conflict do nothing;

-- Strong evidence: reviewers directly describe the prose as
-- "dramatic... at times almost too flowery," explicitly compared to
-- Anne Rice's gothic register.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('A Dowry of Blood', 'S.T. Gibson')
on conflict do nothing;

-- Strong evidence: reviewers use "restrained," "measured," "not at
-- all mechanical," "romance of respect and partnership" directly.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Daughter of No Worlds', 'Carissa Broadbent')
on conflict do nothing;

-- Shared arc/climax across both books: "dramatic triangle," "dramatic
-- climax," "tested to the extreme," a documented reader wish for an
-- even MORE dramatic audiobook reading of the declarations.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Clockwork Prince', 'Cassandra Clare')
on conflict do nothing;

insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Clockwork Princess', 'Cassandra Clare')
on conflict do nothing;

-- "Angst" invoked repeatedly and directly by multiple reviewers to
-- describe the Clary/Jace/Sebastian dynamic's presentation.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('City of Lost Souls', 'Cassandra Clare')
on conflict do nothing;

-- Strong, direct evidence: reviewers explicitly contrast "passionate
-- rather than understated," describe a "meat grinder of emotional
-- angst, self-loathing, and intense yearning."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Alchemised', 'SenLinYu')
on conflict do nothing;
