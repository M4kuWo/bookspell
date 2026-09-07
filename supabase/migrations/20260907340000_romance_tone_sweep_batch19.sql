-- execution-DNA trope sweep, romance_tone batch 19 of the candidate
-- pool. Per repo owner's request, invested more per candidate this
-- batch -- a broad search followed by a targeted follow-up search per
-- book to check for contradicting evidence before tagging, rather than
-- a single search. 4 books researched this way, 3 tagged (one on both
-- sides), 1 left untagged after the deeper check confirmed the
-- evidence genuinely doesn't land cleanly.
--
-- The extra rigor caught a real near-miss: an initial search on Sword
-- of Destiny surfaced a review calling a passage "melodramatic," but a
-- second, more targeted search identified the actual passage and
-- confirmed it was Geralt's internal monologue about a DIFFERENT
-- romantic interest (Essi Daven), not the Geralt/Yennefer relationship
-- the first search seemed to be describing. A single shallow search
-- would have risked tagging the wrong pairing's tone.

-- Direct: reviewer explicitly calls the character development "nicely
-- done, if a bit melodramatic"; a second, targeted search for actual
-- dialogue found repeated sharp, tumultuous push-pull exchanges
-- ("Sloppy idiot... I do not choose to be charmed by you") and other
-- reviewers independently describing the courtship as "tumultuous" and
-- the romance subplot as "repetitive" -- convergent evidence across
-- two searches, not a single passing remark.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Republic of Thieves', 'Scott Lynch')
on conflict do nothing;

-- Direct, clean, repeated across two independent searches: "a natural,
-- friendship-based romance without any drama," "not a high-drama
-- fantasy," romance kept as "background" rather than "constant on-page
-- presence." A follow-up search specifically hunting for
-- counter-evidence (forced romance, melodrama) turned up none -- all
-- criticism found was about the narrator's voice, unrelated to the
-- romance's tone.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Tress of the Emerald Sea', 'Brandon Sanderson')
on conflict do nothing;

-- Left untagged after two searches: The Last Graduate (Naomi Novik).
-- All real discourse found concerned Orion's PROMINENCE/absence for
-- much of the book (a pacing/prominence complaint, explicitly excluded
-- evidence), not the tone of the romance itself; a targeted follow-up
-- search on the climactic declaration turned up only "awkward, yet
-- also endearing and sincere" -- read as roughly neutral/restrained,
-- not clean enough on its own to anchor a tag either way.

-- Direct, correctly attributed after a targeted follow-up search: the
-- Geralt/Essi Daven thread in this collection includes a verbatim,
-- highly overwrought internal monologue ("a little sacrifice, he
-- thought... Essi's hair is not a black tornado of gleaming curls...")
-- comparing her unfavorably to Yennefer -- genuinely melodramatic
-- prose, distinct from the main Geralt/Yennefer relationship in the
-- same book.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Sword of Destiny', 'Andrzej Sapkowski')
on conflict do nothing;

-- Direct, correctly attributed: the main Geralt/Yennefer relationship
-- in this same collection is separately described as "bitter and
-- restrained," with a moment of "suppressed trembling of her lips"
-- before she turns away -- a quiet, restrained gesture rather than a
-- declaration. Consistent with Blood of Elves (already tagged
-- understated for this pairing).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Sword of Destiny', 'Andrzej Sapkowski')
on conflict do nothing;
