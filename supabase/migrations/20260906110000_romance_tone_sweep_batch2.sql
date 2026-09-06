-- execution-DNA trope sweep, romance_tone batch 2 of the candidate pool
-- (see .claude/skills/tag-catalog-batch/SKILL.md Step 0). 20 books
-- reviewed against the strict presentation-specific evidence standard;
-- 16 tagged, 4 left untagged (Strange the Dreamer, House of Earth and
-- Blood, Kingdom of the Wicked, Zodiac Academy: The Awakening -- all
-- had real discourse, but it addressed authenticity/quality/banter/
-- genre-appeal rather than presentation-of-emotion specifically).

-- Weak/mixed: one direct "melodramatic" quote about specific arguments,
-- but blended with real-content evidence (sexual assault as plot
-- device) that's explicitly excluded as tone evidence.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Outlander', 'Diana Gabaldon')
on conflict do nothing;

-- Direct, repeated: "overflows with melodrama," push-pull dynamic
-- described explicitly.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Interview with the Vampire', 'Anne Rice')
on conflict do nothing;

-- Direct, repeated use of "melodramatic" to describe Bella's emotional
-- presentation specifically (not just plot events).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('New Moon', 'Stephenie Meyer')
on conflict do nothing;

-- Genuinely disputed: "how she managed to contain herself" (restraint)
-- directly contradicted by "awkward," "out of nowhere," "forced."
-- Leaning understated since the more presentation-specific quote
-- supports restraint; the counter-evidence reads more like a quality
-- complaint.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Shadow and Bone', 'Leigh Bardugo')
on conflict do nothing;

-- Strong, repeated, explicit use of the exact axis language: "restrained
-- tension-building rather than melodramatic emotional declarations,"
-- "emotional grounding rather than over-the-top declarations."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Cruel Prince', 'Holly Black')
on conflict do nothing;

-- Direct: "avoids being too saccharine," explicitly contrasted against
-- Fourth Wing's over-the-top register by its own reviewers.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Divine Rivals', 'Rebecca Ross')
on conflict do nothing;

-- Weak/disputed: one direct "melodramatic" quote, contradicted by
-- other readers wanting MORE intensity/atmosphere (opposite complaint).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Serpent & Dove', 'Shelby Mahurin')
on conflict do nothing;

-- "80% drama," "dramaish," "swoon-worthy," heightened declarations --
-- consistent with book 1 (Shatter Me) already an existing calibration
-- anchor for this same trilogy/tone.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Ignite Me', 'Tahereh Mafi')
on conflict do nothing;

-- Direct, specific: "emotionally restrained heroes who love deeply but
-- speak carefully," "the weight of restraint, the intensity of
-- unspoken longing" -- genuine presentation-of-emotion language, more
-- specific than the countervailing "vapid"/"paper-thin" quality
-- complaints.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Once Upon a Broken Heart', 'Stephanie Garber')
on conflict do nothing;

-- Genuinely disputed, real direct contradiction ("juvenile,
-- melodramatic, inauthentic" vs. "beautifully understated... subtle,
-- yet fits perfectly") -- majority of specific quotes lean understated.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Night Circus', 'Erin Morgenstern')
on conflict do nothing;

-- Strong, consistent, unambiguous: "quiet love story," "exquisite
-- slowness," "clean and spare," never "overwrought" -- clean
-- presentation-specific evidence for restraint.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Song of Achilles', 'Madeline Miller')
on conflict do nothing;

-- Genuinely disputed, direct contradiction: "melodramatic poetry about
-- how amazing/sexy [they are]" vs. "presented with restraint to
-- emphasize emotional bonds over explicit detail." Leaning
-- melodramatic since that quote is the more specific, presentation-
-- focused one.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Empire of Storms', 'Sarah J. Maas')
on conflict do nothing;

-- Consistent direct evidence: "occasionally overwrought," "melodramatic
-- and the plot as emotionally trite" -- no comparably specific
-- restraint evidence found to counter it.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Time Traveler''s Wife', 'Audrey Niffenegger')
on conflict do nothing;

-- Direct, repeated: "melodramatic elements," "melodramatic to some
-- readers," reviewers themselves comparing it to "trash TV."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Selection', 'Kiera Cass')
on conflict do nothing;

-- Direct, explicit contrast: "rather than melodramatic, reviewers
-- emphasize restraint and complexity," "considerable tension rather
-- than overt melodrama."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Wicked King', 'Holly Black')
on conflict do nothing;

-- Direct: "acted stupid and melodramatic about their strained
-- relationship for more than half the book."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Siege and Storm', 'Leigh Bardugo')
on conflict do nothing;
