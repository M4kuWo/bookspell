-- execution-DNA trope sweep, romance_tone batch 21 of the candidate
-- pool. Continued broad-search + targeted-follow-up per candidate. 6
-- books researched (12 searches), 2 tagged. 4 left untagged: The
-- Magician King (Quentin/Julia -- a second search confirmed this pair
-- is explicitly PLATONIC, not romantic; the book's actual romance,
-- Quentin/Poppy, is casual and has no clean tone-specific discourse --
-- a real misattribution risk caught by the second search); Winter's
-- Heart (two searches found only "wooden"/"awkward"/"bland" craft-
-- quality complaints about Rand's poly arrangement, which describes
-- writing competence, not a restrained-vs-melodramatic presentation
-- choice); Kafka on the Shore (discourse dominated by a disturbing
-- consent-issue scene, explicitly excluded relationship-content
-- evidence, not tone); The Fires of Heaven (Rand/Aviendha discourse
-- conflated heat-level/explicitness with tone, and the rest was
-- structural "forced together"/tsundere-trope criticism, not a clean
-- presentation read).

-- Direct, clean, convergent across two searches: one reviewer calls it
-- outright "the tackiest and melodramatic 'relationship' imaginable";
-- a second search confirmed the pattern independently -- the climactic
-- reunion is mocked by other reviewers for its heavy-handed,
-- coincidence-driven sincerity (a childhood-sweethearts-reunited
-- resolution played completely straight).
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'melodramatic_romance_subplot', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('1Q84', 'Haruki Murakami')
on conflict do nothing;

-- Direct, clean: "so much honesty and tenderness... wasn't at all
-- sappy," "spun out so nicely," praised for "the amount of realism."
-- A second, adversarial-framed search specifically hunting for
-- "cheesy"/"sappy" counter-evidence found none on the presentation
-- axis -- the only real criticism found concerned romance quantity
-- (prominence) and one plot detail (an age-gap ending beat), not tone.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.6, 'ai_inferred'
from books b
where (b.title, b.author) = ('11/22/63', 'Stephen King')
on conflict do nothing;
