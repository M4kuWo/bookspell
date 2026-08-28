-- Second vocabulary growth round, after the 108-book remaining-catalog
-- tagging pass. See docs/remaining-catalog-tagging/findings.md for the
-- per-item rationale (specific book, specific gap, "distinct from X").

insert into tropes (id, group_name, spoiler) values
  ('ghost_sight', 'character_archetypes', false),
  ('sudden_apocalypse_event', 'setting_worldbuilding', false),
  ('satirical_or_comedic_fantasy', 'setting_worldbuilding', false),
  ('crime_family_saga', 'setting_worldbuilding', false),
  ('deadly_competition_or_trial', 'plot_devices', false),
  ('survivalist_ingenuity', 'plot_devices', false),
  ('uplift', 'scifi_specific', false),
  ('corruption_arc', 'craft_devices', true),
  ('mythological_pantheon_as_characters', 'craft_devices', false),
  ('tragic_reversal_of_fortune', 'craft_devices', true),
  ('amnesia_driven_narrative', 'craft_devices', false);

insert into content_warning_types (id) values
  ('pandemic_or_epidemic'),
  ('fictional_species_prejudice'),
  ('incest'),
  ('chronic_illness_or_disability');

-- Add embedded_system_text as a valid `form` value (LitRPG game-notification
-- text interleaved with standard prose — no prior value fit this).
alter table book_dna drop constraint book_dna_form_check;
alter table book_dna add constraint book_dna_form_check
  check (form in ('standard_prose', 'epistolary', 'framing_device', 'verse', 'embedded_system_text'));
