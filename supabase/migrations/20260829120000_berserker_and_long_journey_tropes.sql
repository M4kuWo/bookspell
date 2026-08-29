-- Two more tropes, both raised by the user and passing the "does this
-- change the recommendation" bar (see book-dna.schema.yaml for full
-- rationale on each):
--   berserker_rage -- combat power source is uncontrolled/building rage
--     itself, distinct from anti_hero/morally_grey_protagonist (moral
--     positioning, not a mechanic).
--   long_journey -- the physical journey IS the narrative's structural
--     spine, distinct from epic_quest (an important goal, which can
--     play out in fixed locations with no central journey).

insert into tropes (id, group_name, spoiler) values
  ('berserker_rage', 'character_archetypes', false),
  ('long_journey', 'plot_devices', false);
