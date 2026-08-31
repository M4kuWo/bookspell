-- A human-confirmed correction should outrank an unassessed AI guess in
-- the same field, not just tie with it -- see recommend.py's
-- HIGH_RISK_FIELD_DEFAULT (2026-08-31): person/pov_count/
-- narrator_reliability now default to 0.85 confidence when unassessed,
-- specifically so a manual_review-sourced value at 1.0 has somewhere
-- real to rise to. Applies to the three fields corrected this session
-- from external reader feedback.

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'person', 1.0, 'manual_review' from books where title = 'Dungeon Crawler Carl'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';

insert into book_field_confidence (book_id, field_name, confidence, source)
select id, 'narrator_reliability', 1.0, 'manual_review' from books where title = 'Dungeon Crawler Carl'
on conflict (book_id, field_name) do update set confidence = 1.0, source = 'manual_review';

update book_tropes set confidence = 1.0, source = 'manual_review'
where trope_id = 'multiple_alien_species'
  and book_id = (select id from books where title = 'Empire of Silence');
