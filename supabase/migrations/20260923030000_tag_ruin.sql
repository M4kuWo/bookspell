-- Tag "Ruin" (John Gwynne, The Faithful and the Fallen #3) -- CLDO,
-- 2026-09-23. Ingested 2026-09-22 (migration 20260922010000) to close
-- the gap that left this series 3/4 in the catalog; now fully tagged so
-- the series is 4/4 both bibliographically and for the scoring engine.
--
-- Grounded in real research (Grimdark Magazine, Winter Is Coming,
-- Novel Notions, FanFiAddict reviews), not pattern-matched from the
-- series alone -- HIGH_RISK_FIELDS (pov_count, person, narrative_closure
-- among them) specifically verified against real review text, not
-- inferred from Malice/Valor/Wrath's own tags:
--   - pov_count = ensemble: multiple reviews independently describe a
--     "multi-perspective narrative of twelve characters" -- not just
--     "several important characters," a real, confirmed ensemble count.
--   - ends_on_cliffhanger = cliffhanger, narrative_closure =
--     requires_series: reviews explicitly describe the book ending "in
--     a gut-wrenching cliffhanger," consistent with its position as the
--     penultimate volume (not the finale, which is Wrath).
--   - emotional_resolution = tragic (not bittersweet, despite Valor/
--     Wrath both being bittersweet): reviews specifically emphasize loss
--     and reversal -- "whatever little progress was made, ended up being
--     undone or worse, in some heart-wrenching tragedy" -- a notably
--     darker resolution than the surrounding books, not just inherited
--     from series tone.
--   - violence_intensity = brutal, darkness = dark: "battles more costly
--     and brutal," "stakes were higher than ever" -- both directly
--     supported, matching Valor/Wrath's own escalation from Malice.
--
-- worldbuilding_delivery and romance_tone left null, matching Valor and
-- Wrath's own precedent -- no real presentation-specific evidence found
-- for either axis, and forcing a value without it would violate this
-- project's evidence standard for exactly these two fields.
--
-- narrator_cast / audiobook_length left null: no audiobook_editions row
-- exists yet for this book (checked directly), so there's no real data
-- to bucket from.
--
-- genre_accessibility: computed baseline from prose_complexity=moderate
-- (0.5), overall_pace=fast (inverted: 0), worldbuilding_density=dense
-- (1), pov_count=ensemble (1), intellectual_weight=moderate (0.5) ->
-- average 0.6 -> "demanding" tier by the formula. Adjusted down one
-- tier to "moderate", matching the SAME adjustment already present on
-- Valor and Wrath (both also compute to "demanding" by this exact
-- formula but are tagged "moderate") -- the real justification for the
-- adjustment is series-specific: this book's actual readership has
-- already read 2 prior entries, so the raw craft-field demand doesn't
-- translate to the same accessibility barrier a first-time reader would
-- face. Kept consistent with that established precedent rather than
-- leaving Ruin as an unexplained outlier at "demanding".
insert into book_dna (
  book_id, genre, age_category, book_length, pov_count, person,
  narrator_reliability, timeline, form, overall_pace, pace_shape, drive,
  darkness, humor_level, emotional_register, message_intensity,
  romance_heat_frequency, romance_heat_intensity, romance_tone,
  violence_frequency, violence_intensity, worldbuilding_density,
  worldbuilding_delivery, narrative_closure,
  emotional_resolution, ends_on_cliffhanger, audiobook_length,
  narrator_cast,
  magic_system_hardness, scifi_hardness, prose_density, prose_complexity,
  intellectual_weight, stakes_scope, personal_stakes, genre_accessibility
)
select
  id, array['fantasy'], 'adult', 'epic', 'ensemble', 'third_limited',
  'reliable', 'linear', 'standard_prose', 'fast', 'slow_burn_to_fast_finish', 'plot_driven',
  'dark', 'light', 'gut_punch', 'moderate',
  'rare', 'low', null,
  'frequent', 'brutal', 'dense',
  null, 'requires_series',
  'tragic', 'cliffhanger', null,
  null,
  'soft', 'na', 'moderate', 'moderate',
  'moderate', 'cosmic', 'life_threatening', 'moderate'
from books where title = 'Ruin' and author = 'John Gwynne';

insert into book_tropes (book_id, trope_id)
select id, t from books, unnest(array[
  'chosen_one', 'war_story', 'prophecy', 'mythological_pantheon_as_characters',
  'child_soldiers_in_warfare', 'major_character_death', 'found_family',
  'underdog_rising', 'court_intrigue'
]) as t
where title = 'Ruin' and author = 'John Gwynne';

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'war_trauma', 'central_theme', false from books where title = 'Ruin' and author = 'John Gwynne';
