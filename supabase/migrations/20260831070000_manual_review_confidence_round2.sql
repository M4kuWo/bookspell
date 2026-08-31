-- Record manual_review confidence=1.0 for every field/trope corrected in
-- 20260831060000, matching the precedent set for Dungeon Crawler Carl --
-- see recommend.py's HIGH_RISK_FIELDS, now expanded with the fields
-- corrected here.

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 1.0, 'manual_review' from books where title = 'Yumi and the Nightmare Painter'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'magic_system_hardness', 1.0, 'manual_review' from books where title = 'Yumi and the Nightmare Painter'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';

update book_tropes set confidence = 1.0, source = 'manual_review'
where trope_id = 'sanderlanche'
  and book_id = (select id from books where title = 'Yumi and the Nightmare Painter');

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'overall_pace', 1.0, 'manual_review' from books where title = 'Tress of the Emerald Sea'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 1.0, 'manual_review' from books where title = 'Jade City'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'drive', 1.0, 'manual_review' from books where title = 'Jade City'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'romance_heat_intensity', 1.0, 'manual_review' from books where title = 'This Is How You Lose the Time War'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'stakes_scope', 1.0, 'manual_review' from books where title = 'This Is How You Lose the Time War'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrative_closure', 1.0, 'manual_review' from books where title = 'Speaker for the Dead'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'humor_level', 1.0, 'manual_review' from books where title = 'Slaughterhouse-Five'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';
