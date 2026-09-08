-- execution-DNA trope sweep, romance_tone batch 20 of the candidate
-- pool. Continued the broad-search + targeted-follow-up approach per
-- the standing recommendation. 6 books researched (12 searches total),
-- only 1 tagged (disputed) -- confirms the depletion problem flagged
-- 2026-09-07 is real and not just a shallow-search artifact: even with
-- the deeper approach, 5 of 6 candidates turned up nothing usable.
--
-- The deeper approach still earned its keep twice this batch, in two
-- different directions:
-- (1) On The Last Wish, a first search surfaced "melodrama at its
--     finest" -- looked like a clean hit. A second, targeted search
--     found the actual review context: the phrase describes Geralt's
--     general moral/political entanglements throughout the collection,
--     not the Geralt/Yennefer romance's presentation at all. Left
--     untagged -- would have been a real false positive on a single
--     search.
-- (2) On The Everlasting, a first search suggested clean, unambiguous
--     restraint ("restrained emotional tone," "understated"). A second,
--     targeted search hunting specifically for counter-evidence found
--     real, separate criticism calling the same romance "saccharine"
--     and "sentimental" -- genuinely disputed, not the clean 0.6 the
--     first search alone would have suggested.
--
-- Left untagged entirely: The Last Wish (see above), The True Bastards
-- (two searches confirmed no developed central romance to judge tone
-- on at all), The Hundred Thousand Kingdoms (second search still only
-- turned up relationship-dynamic/consent discourse, not presentation),
-- Dark Age (two searches found no scene-level detail at all), Mr.
-- Penumbra's 24-Hour Bookstore (two searches found only prominence/
-- character-quality complaints, e.g. "manic pixie dream girl," never
-- presentation-of-emotion).

-- Weak/disputed, found only via a second, adversarial-framed search:
-- one strand describes the romance as blossoming "solemnly and
-- tenderly," with a "restrained emotional tone" and "understated"
-- feel; a separate, real complaint calls the same romance "saccharine"
-- and "sweet... leaves a bad taste," criticizing it as overly
-- sentimental.
insert into book_tropes (book_id, trope_id, confidence, source)
select b.id, 'understated_romance', 0.2, 'ai_inferred'
from books b
where (b.title, b.author) = ('The Everlasting', 'Alix E. Harrow')
on conflict do nothing;
