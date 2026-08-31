-- Third round of external reader feedback (2026-08-31), all verified
-- against current tags before applying:
--
-- Yumi and the Nightmare Painter: narrator_reliability was 'unreliable',
-- likely over-applied from "it's a frame narrative told by a storyteller"
-- -- same category of mistake as Dungeon Crawler Carl (defaulting off
-- the narrative device rather than the book's actual trustworthiness).
-- The narrator has personality/bias but no real grounds to distrust the
-- account -- book-dna.schema.yaml's own guardrail on narrator_reliability
-- says exactly this shouldn't be tagged unreliable/ambiguous just for a
-- strong-voiced narrator. Corrected to 'reliable'. Also missing
-- 'sanderlanche' (a real omission -- Sanderson's climaxes reliably have
-- this) and magic_system_hardness was 'hard'; reader places it between
-- hard/soft and the schema has no medium value, so per his own fallback,
-- 'soft'.
--
-- Tress of the Emerald Sea: overall_pace corrected medium -> fast.
--
-- Jade City: missing sexual_assault content warning (added, severity
-- judgment-called as 'moderate' -- flag for the repo owner to confirm
-- for central_theme if it fics a bigger role than that). romance_heat_intensity
-- corrected closed_door -> explicit. drive corrected balanced ->
-- character_driven.
--
-- This Is How You Lose the Time War: person NOT changed -- checked via
-- web search first since I had a specific (and, it turned out, wrong)
-- recollection of the book using second person; it actually intercuts
-- third-person present-tense narrative sections with first-person
-- epistolary letters between Red and Blue, which is genuinely 'mixed',
-- not just 'first'. Flagged back to the reader rather than force-changed.
-- romance_heat_intensity corrected moderate -> low (the characters are
-- rarely physically together). stakes_scope corrected cosmic -> intimate
-- (schema has no literal 'personal' value; 'intimate' is the smallest-
-- scope option and matches what the reader described).
--
-- Ender's Game: the genocide content warning is the book's final twist
-- and was NOT flagged as a spoiler -- corrected reveals_spoiler to true.
--
-- Speaker for the Dead: narrative_closure was 'self_contained'; reader
-- compared it to Mistborn: The Final Empire (confirmed tagged
-- 'requires_series') -- corrected to match.
--
-- Slaughterhouse-Five: humor_level corrected light -> heavy (Vonnegut's
-- dark satirical humor is a defining feature, not incidental).

update book_dna set narrator_reliability = 'reliable', magic_system_hardness = 'soft'
where book_id = (select id from books where title = 'Yumi and the Nightmare Painter');

insert into book_tropes (book_id, trope_id)
select id, 'sanderlanche' from books where title = 'Yumi and the Nightmare Painter'
on conflict (book_id, trope_id) do nothing;

update book_dna set overall_pace = 'fast'
where book_id = (select id from books where title = 'Tress of the Emerald Sea');

insert into book_content_warnings (book_id, warning_id, severity, reveals_spoiler)
select id, 'sexual_assault', 'moderate', false from books where title = 'Jade City'
on conflict (book_id, warning_id) do nothing;

update book_dna set romance_heat_intensity = 'explicit', drive = 'character_driven'
where book_id = (select id from books where title = 'Jade City');

update book_dna set romance_heat_intensity = 'low', stakes_scope = 'intimate'
where book_id = (select id from books where title = 'This Is How You Lose the Time War');

update book_content_warnings set reveals_spoiler = true
where warning_id = 'genocide'
  and book_id = (select id from books where title = 'Ender''s Game');

update book_dna set narrative_closure = 'requires_series'
where book_id = (select id from books where title = 'Speaker for the Dead');

update book_dna set humor_level = 'heavy'
where book_id = (select id from books where title = 'Slaughterhouse-Five');
