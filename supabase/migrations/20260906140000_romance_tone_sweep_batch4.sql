-- execution-DNA trope sweep, romance_tone batch 4 of the candidate pool.
-- 12 books reviewed against the strict presentation-specific evidence
-- standard; 8 tagged, 4 left untagged (Heir of Fire, Red Queen,
-- Quicksilver, When the Moon Hatched -- discourse addressed
-- relationship pacing, banter/chemistry, or plot pacing rather than
-- presentation-of-emotion specifically).

-- "swooned every time... 'my love'," "tears streaming," constant
-- yearning and declarations -- consistent with Iron Flame (already
-- tagged, same trilogy).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Onyx Storm', 'Rebecca Yarros')
on conflict do nothing;

-- Direct: "cringe," "fake conflict," explicitly characterized as
-- "melodramatic with artificial conflict."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('House of Flame and Shadow', 'Sarah J. Maas')
on conflict do nothing;

-- Direct: "restrained... quick... plainly," explicitly contrasted
-- against "grand gestures."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Queen of Nothing', 'Holly Black')
on conflict do nothing;

-- Strong, repeated, direct: "always melodramatic," "overly
-- contrived," "overwrought and self-indulgent," "pretty cringey."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Children of Blood and Bone', 'Tomi Adeyemi')
on conflict do nothing;

-- Direct: "backgrounded rather than foregrounded," "deliciously
-- slow-burning," romance could be removed and the story would still
-- work.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Uprooted', 'Naomi Novik')
on conflict do nothing;

-- Strong, repeated, direct: "super melodramatic," "overly
-- melodramatic," "like a Harlequin romance," kisses described in
-- "increasingly comic metaphors."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Host', 'Stephenie Meyer')
on conflict do nothing;

-- Weak lean: "angsty, dark, simmering with tension" leans toward
-- heightened presentation, but less specific than a clean 0.6 case;
-- the other main complaint found ("forced and predictable") is a
-- craft-quality judgment, not tone evidence.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('Heartless Hunter', 'Kristen Ciccarelli')
on conflict do nothing;

-- Direct, explicit: "restrained manner... secondary role... rather
-- than being melodramatic or emotionally intense."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Ruin and Rising', 'Leigh Bardugo')
on conflict do nothing;
