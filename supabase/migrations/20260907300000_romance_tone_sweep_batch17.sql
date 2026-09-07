-- execution-DNA trope sweep, romance_tone batch 17 of the candidate
-- pool. 11 books reviewed against the strict presentation-specific
-- evidence standard; only 2 tagged -- an unusually thin batch, not a
-- relaxed bar. 9 left untagged: The Hundred Thousand Kingdoms (only
-- heat-level/thematic complaints, excluded evidence), Winter, White
-- Night, Uglies (no presentation-specific discourse found at all for
-- any of these three), The Mists of Avalon (too generic/synthesized to
-- anchor), Dark Matter (discourse was about craft-quality -- "doesn't
-- convey why he loves her" -- not tone), Gideon the Ninth (romance
-- angle -- discourse concerned relationship TYPE, "siblings not
-- lovers," not presentation), The Left Hand of Darkness (a profound
-- bond explicitly described as beyond/other-than romantic love --
-- genuinely unclear whether this trope even applies), Iron Gold
-- (one poetic declaration quoted, but too ambiguous to call either
-- restrained or melodramatic), The Windup Girl (no central romantic
-- relationship to judge tone on at all).

-- Direct, clean: Nathaniel's characterization is explicitly "nuanced
-- and restrained rather than melodramatic," his interiority "told in
-- glimmers and moments" rather than dramatic declarations.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Calculating Stars', 'Mary Robinette Kowal')
on conflict do nothing;

-- Direct, clean: reviewer explicitly calls the Geralt/Yennefer romance
-- "poetic and lovely, and not pathetic enough to become angsty and
-- melodramatic," explicitly "not a sappy romance love-fest."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Blood of Elves', 'Andrzej Sapkowski')
on conflict do nothing;
