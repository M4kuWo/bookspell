-- Adds the `script_or_stage_play` value to book_dna.form, surfaced by
-- Harry Potter and the Cursed Child (a stage-play script has no narrative
-- prose at all, so every existing `form` value was a poor fit -- it had
-- been force-fit into 'standard_prose' with a low-confidence flag).
-- See docs/schema/book-dna.md and book-dna.schema.yaml for rationale.

alter table book_dna drop constraint book_dna_form_check;
alter table book_dna add constraint book_dna_form_check
  check (form = any (array['standard_prose', 'epistolary', 'framing_device', 'verse', 'embedded_system_text', 'script_or_stage_play']));

-- Retag the one book that surfaced this gap, now that a real value exists.
update book_dna set form = 'script_or_stage_play'
where book_id = (select id from books where title = 'Harry Potter and the Cursed Child');

-- No longer a genuine coin-flip now that the correct value exists.
delete from book_field_confidence
where field_name = 'form'
  and book_id = (select id from books where title = 'Harry Potter and the Cursed Child');
