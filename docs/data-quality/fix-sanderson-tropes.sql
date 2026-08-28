-- Fix: Rhythm of War has no single protagonist (many major POVs --
-- Shallan, Dalinar, Kaladin, Adolin, Navani, Venli), and most of those
-- POVs read as heroic, not morally grey (unlike The Way of Kings/Words
-- of Radiance/Oathbringer, where Szeth's tragic-assassin arc and
-- Dalinar's dark-past flashbacks genuinely justify the tag).
delete from book_tropes where book_id = '73fd635a-5f33-4f68-a386-ba9fb2a6e8d7' and trope_id = 'morally_grey_protagonist';

insert into book_tropes (book_id, trope_id) values
  -- Rhythm of War: singers/Parshendi central to the plot; the bridge-crew
  -- found family continues; Odium's threat escalates; Venli's redemption
  -- and Navani's psychological arc both fit existing tropes not yet applied.
  ('73fd635a-5f33-4f68-a386-ba9fb2a6e8d7', 'multiple_fantasy_species'),
  ('73fd635a-5f33-4f68-a386-ba9fb2a6e8d7', 'found_family'),
  ('73fd635a-5f33-4f68-a386-ba9fb2a6e8d7', 'ancient_evil_awakens'),
  ('73fd635a-5f33-4f68-a386-ba9fb2a6e8d7', 'shadow_self_confrontation'),
  ('73fd635a-5f33-4f68-a386-ba9fb2a6e8d7', 'redemption_arc'),

  -- The Way of Kings: Parshendi and spren as distinct sentient
  -- species were a clear omission; the bridge crew is a defining
  -- found-family unit.
  ('40d83360-ee8a-4d80-b78f-edf2c7ba64d8', 'multiple_fantasy_species'),
  ('40d83360-ee8a-4d80-b78f-edf2c7ba64d8', 'found_family'),

  -- Words of Radiance: Parshendi even more central to this book's plot.
  ('f78770e6-b846-42cb-82b1-616947d617fa', 'multiple_fantasy_species'),

  -- Oathbringer: the parsh/singer rebellion is a central plot thread;
  -- the bridge crew found-family thread continues.
  ('97af41ab-5e6b-4d59-9ac5-8ffd3fe0982e', 'multiple_fantasy_species'),
  ('97af41ab-5e6b-4d59-9ac5-8ffd3fe0982e', 'found_family'),

  -- Mistborn: The Final Empire -- kandra and koloss are distinct
  -- non-human sentient/quasi-sentient races central to the plot; the
  -- Lord Ruler is centuries-old (immortal_or_ageless_character); the
  -- ending's reveal about Kelsier's true plan is a real twist.
  ('ac69f36c-fc97-4d5d-aa3c-83bdde4ea6cc', 'multiple_fantasy_species'),
  ('ac69f36c-fc97-4d5d-aa3c-83bdde4ea6cc', 'immortal_or_ageless_character'),
  ('ac69f36c-fc97-4d5d-aa3c-83bdde4ea6cc', 'twist_ending'),

  -- The Well of Ascension: koloss army is central to this book's plot;
  -- the crew is very much a found family (an omission vs. book 1 and 3).
  ('24aebaeb-fe33-42ec-b755-4e5ea4ab8e1e', 'multiple_fantasy_species'),
  ('24aebaeb-fe33-42ec-b755-4e5ea4ab8e1e', 'found_family'),

  -- The Hero of Ages: kandra/koloss/Terris reveal is central to the
  -- climax.
  ('88963f82-4a1a-476d-838f-032322bec4f9', 'multiple_fantasy_species'),

  -- The Alloy of Law: only 3 tropes total -- clearly under-tagged.
  -- Found-family dynamic among Wax/Wayne/Marasi established here;
  -- the noir-detective structure that all three later Wax & Wayne
  -- books carry actually starts here and was a real omission; there's
  -- a genuine villain-identity twist at the climax.
  ('6f7b8a46-8432-4b02-b4b5-4ce33d2d5f17', 'found_family'),
  ('6f7b8a46-8432-4b02-b4b5-4ce33d2d5f17', 'noir_detective_structure'),
  ('6f7b8a46-8432-4b02-b4b5-4ce33d2d5f17', 'twist_ending'),

  -- Shadows of Self: for consistency with Wax's ongoing moral-complexity
  -- arc (obsessive vengeance, willingness to kill, real guilt over his
  -- past) tagged elsewhere in the era; genuine twist regarding the
  -- villain's plan.
  ('f2250e75-ee7f-4ba7-ac02-8a7663133ad9', 'morally_grey_protagonist'),
  ('f2250e75-ee7f-4ba7-ac02-8a7663133ad9', 'twist_ending'),

  -- The Bands of Mourning: same consistency case as Shadows of Self.
  ('ee194d75-20ff-41ff-8361-760db3bcbded', 'morally_grey_protagonist'),

  -- The Lost Metal: interplanetary political stakes rise sharply in
  -- this book (a real court_intrigue omission); consistency with the
  -- era's morally_grey_protagonist tagging.
  ('88e159fc-7e5c-4aa7-a201-544273ec4976', 'court_intrigue'),
  ('88e159fc-7e5c-4aa7-a201-544273ec4976', 'morally_grey_protagonist'),

  -- Elantris: Hrathen (a major POV) is a genuinely morally grey
  -- character -- a true-believer priest capable of real cruelty and
  -- real compassion, not a straightforward villain.
  ('cdbd50f7-9fdd-403f-af90-fa6c20d437e7', 'morally_grey_protagonist'),

  -- Tress of the Emerald Sea: only 2 tropes -- her voyage across the
  -- spore seas to save Charlie is squarely an epic-quest structure.
  ('71f674fe-ef93-4fd6-a186-625bf0bd6234', 'epic_quest'),

  -- Warbreaker: a very political plot centered on the God King's
  -- court (a clear court_intrigue omission); the Returned (including
  -- Lightsong, Susebron) are literally gods living as people --
  -- immortal_or_ageless_character applies directly.
  ('0b47fa61-b41b-4398-81af-cd0d50e5acc1', 'court_intrigue'),
  ('0b47fa61-b41b-4398-81af-cd0d50e5acc1', 'immortal_or_ageless_character')
on conflict do nothing;
