-- Content-warning enrichment pass on the 140-book batch (companion to
-- 20260830235742's trope enrichment). The same quality audit found
-- content warnings/book lower than the pre-existing catalog (1.41 vs.
-- 2.10 avg, 29% vs. 16% of books with zero CWs). Adds 13 genuinely missing,
-- central warnings across 13 books -- real misses (Cinder's letumosis
-- plague and I Am Legend's vampire-plague origin both clearly fit
-- pandemic_or_epidemic; a few Wheel of Time/series-consistency gaps where
-- sibling entries had war_trauma and one didn't), not padding. Many
-- zero-CW books in the batch were left as-is on purpose -- comfort reads,
-- children's books, and comedic sci-fi/fantasy that genuinely don't
-- warrant a content warning. Does not touch pre-existing catalog data.
-- Tagged by ettydaniel.levy@gmail.com via Claude Code (tag-catalog-batch skill).

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'moderate', false from books where title = 'A Deadly Education' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'A Court of Silver Flames' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'colonization_themes', 'central_theme', false from books where title = 'Ancillary Justice' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'Cinder' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'genocide', 'moderate', false from books where title = 'Consider Phlebas' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Fairy Tale' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'pandemic_or_epidemic', 'central_theme', false from books where title = 'I Am Legend' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Insurgent' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'body_horror', 'moderate', false from books where title = 'Nettle & Bone' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'Skyward' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Black Prism' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'child_death', 'brief', false from books where title = 'The Graveyard Book' on conflict do nothing;

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler) select id, 'war_trauma', 'moderate', false from books where title = 'The Great Hunt' on conflict do nothing;

