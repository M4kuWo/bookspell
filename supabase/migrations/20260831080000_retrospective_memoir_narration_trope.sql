-- New trope suggested by the repo owner: the protagonist-narrator
-- recounting their OWN past from a later vantage point (The Name of the
-- Wind's Kvothe telling his life story to the Chronicler). Distinct from
-- `form: framing_device` in general, which is a broad umbrella also
-- covering frames where the narrator ISN'T the protagonist recounting
-- their own life -- see book-dna.schema.yaml for the full rationale.
--
-- Applied only to the two books directly confirmed (same Kingkiller
-- frame device throughout the duology). The other 31 books currently
-- tagged form = 'framing_device' are NOT touched here -- several
-- clearly use a different frame pattern (third-party storyteller,
-- footnoted-historian voice, found manuscript) and guessing which
-- subset qualifies from memory alone is exactly the mistake this
-- project has been correcting all session. Flagged for a real audit
-- pass instead.

insert into tropes (id, group_name, spoiler) values
  ('retrospective_memoir_narration', 'craft_devices', false);

insert into book_tropes (book_id, trope_id)
select id, 'retrospective_memoir_narration' from books
where title in ('The Name of the Wind', 'The Wise Man''s Fear');
