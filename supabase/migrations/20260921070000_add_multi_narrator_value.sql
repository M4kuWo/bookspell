-- Add narrator_cast = 'multi_narrator' and backfill the real cases it
-- covers -- a follow-up to 20260921060000's catalog-wide backfill, which
-- correctly left 56 books NULL rather than force them into an existing
-- value. See docs/schema/book-dna.schema.yaml's narrator_cast comment and
-- docs/schema/book-dna.md's Tier A section for the full rationale.
--
-- Splits those 56 into two real, DIFFERENT data situations, not one:
--   * 21 books have a genuine 3+-narrator 'standard' edition, uniform
--     across every standard edition that book has -- a real, clean
--     multi_narrator case, backfilled here.
--   * 35 books have multiple DIFFERENT standard editions with different
--     narrator counts (e.g. a 1-narrator edition and a separate
--     2-narrator edition of the same book -- genuinely different
--     narrations, not one recording with several people). Which one is
--     'the' narrator_cast for the book is a genuinely open question this
--     single per-book column can't answer -- deliberately left NULL,
--     NOT set to multi_narrator (that would misrepresent 'multiple
--     different single/dual recordings exist' as 'one recording has
--     several narrators', which isn't what's actually true for any of
--     these 35). A real per-edition narrator_cast (rather than one value
--     per book) would be the honest fix if this is ever worth pursuing;
--     not attempted here.

alter table book_dna drop constraint book_dna_narrator_cast_check;
alter table book_dna add constraint book_dna_narrator_cast_check
  check (narrator_cast = any (array['single_narrator', 'dual_narrator', 'full_cast', 'multi_narrator']));

-- ===== narrator_cast = 'multi_narrator' (21) =====
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Bury Our Bones in the Midnight Soil' and author = 'V. E. Schwab') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Dune Messiah' and author = 'Frank Herbert') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Ender''s Game' and author = 'Orson Scott Card') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'God Emperor of Dune' and author = 'Frank Herbert') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'If It Bleeds' and author = 'Stephen King') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Onyx Storm' and author = 'Rebecca Yarros') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'The Buffalo Hunter Hunter' and author = 'Stephen Graham Jones') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'The Power' and author = 'Naomi Alderman') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Acceptance' and author = 'Jeff VanderMeer') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Anathem' and author = 'Neal Stephenson') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Chain-Gang All-Stars' and author = 'Nana Kwame Adjei-Brenyah') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Chapterhouse: Dune' and author = 'Frank Herbert') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Exhalation' and author = 'Ted Chiang') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Parable of the Talents' and author = 'Octavia E. Butler') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Sea of Tranquility' and author = 'Emily St. John Mandel') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'The Bone Shard Daughter' and author = 'Andrea Stewart') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'The Eye of the Bedlam Bride' and author = 'Matt Dinniman') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'The Five People You Meet in Heaven' and author = 'Mitch Albom') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'The Fragile Threads of Power' and author = 'V. E. Schwab') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'They Both Die at the End' and author = 'Adam Silvera') and narrator_cast is null;
update book_dna set narrator_cast = 'multi_narrator' where book_id = (select id from books where title = 'Weyward' and author = 'Emilia Hart') and narrator_cast is null;

