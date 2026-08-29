-- Common fantasy creature tropes, parallel to the existing
-- vampires/dragons precedent -- readers have real, independent
-- preferences on these specific races, including active fatigue with
-- the generic Tolkien-derivative default absent a real twist.
-- Schema-only for now; retroactive tagging across the catalog is a
-- separate, deliberately deferred pass (see project log).

insert into tropes (id, group_name, spoiler) values
  ('elves', 'setting_worldbuilding', false),
  ('dwarves', 'setting_worldbuilding', false),
  ('fae_or_fairies', 'setting_worldbuilding', false);
