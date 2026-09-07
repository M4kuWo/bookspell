-- execution-DNA trope sweep, romance_tone batch 10 -- cut short.
-- Only 4 books were researched before this session hit its web search
-- budget cap (200/200) partway through; 2 tagged, 2 left untagged
-- (Anansi Boys, Mr. Penumbra's 24-Hour Bookstore -- see
-- docs/project-log.md for why). No worldbuilding-delivery research was
-- done this batch at all for the same reason.

-- Direct: "heavy laden with melodramatic, teenage love anguish."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Illuminae', 'Amie Kaufman, Jay Kristoff')
on conflict do nothing;

-- Direct, repeated, consistent across multiple independent reviewers:
-- "suitably melodramatic," "dances on the line of melodramatic,"
-- "slightly too melodramatic for my tastes," "more than suitably
-- melodramatic when it suits him."
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('Empire of the Vampire', 'Jay Kristoff')
on conflict do nothing;
