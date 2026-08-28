update book_dna set message_intensity = v.message_intensity
from (values
  ('11b7e342-0a73-4a55-8798-bd5e6e1f2837'::uuid, 'subtle'),       -- A Wizard of Earthsea
  ('19d4ed2f-b1dd-4670-887f-2378ace7f2d0'::uuid, 'subtle'),       -- Assassin's Apprentice
  ('10a141f2-33cb-4028-bd1d-67a682a4a027'::uuid, 'subtle'),       -- Bird Box
  ('572f08b2-8b21-4cc8-9665-dc4b63250297'::uuid, 'moderate'),     -- Circe
  ('95c67424-a866-4877-96b0-0ef9ccad1bc8'::uuid, 'subtle'),       -- Dark Matter
  ('fe08b7b0-ef8b-4609-ace7-7b6fb1cccb4a'::uuid, 'moderate'),     -- Ender's Game
  ('a3d488d1-8b77-471e-a58b-f8d989d2254a'::uuid, 'subtle'),       -- He Who Fights with Monsters
  ('ea8f74f1-a083-40b1-ae0e-e8c3c9a35f77'::uuid, 'moderate'),     -- Interview with the Vampire
  ('2f92aa1e-75c7-46f9-a2cc-7c7d6a8d8e36'::uuid, 'moderate'),     -- Kings of Paradise
  ('62a20847-36a2-47e4-b612-00c36568b300'::uuid, 'subtle'),       -- Leviathan Wakes
  ('d9e914a8-325a-4364-a318-f971e29e6ed2'::uuid, 'subtle'),       -- Malice
  ('ffe610de-6936-4b8d-ace9-18f97d283b4e'::uuid, 'subtle'),       -- Neuromancer
  ('4f1715ac-1023-498a-ae0b-fc57df87c236'::uuid, 'subtle'),       -- Old Man's War
  ('91f59bfa-4206-46bb-b5ce-a889c1a912f5'::uuid, 'moderate'),     -- Perdido Street Station
  ('306a62c0-df13-48ec-8f3e-4e6e0943282b'::uuid, 'subtle'),       -- Prince of Thorns
  ('3fecce0f-1505-4b80-9cb9-f9987d79381a'::uuid, 'subtle'),       -- The Black Company
  ('b66e829e-da99-49b4-ac49-2126eca2b4c4'::uuid, 'subtle'),       -- The Eye of the World
  ('c491eec3-1c4d-4402-87bf-4a23218451cf'::uuid, 'heavy_handed'), -- The Fifth Season
  ('599b4704-7dad-4ff4-b090-6bff2cd25a7a'::uuid, 'heavy_handed'), -- The Forever War
  ('d67034b9-1305-4a6a-89d4-d56b504fc44c'::uuid, 'moderate'),     -- The Golden Compass
  ('b889d6e8-7630-4284-b17a-9b50e8cda7ef'::uuid, 'subtle'),       -- The Gunslinger
  ('1d88b91b-800a-47ff-afda-e5abd0dbcdc2'::uuid, 'subtle'),       -- The Hitchhiker's Guide to the Galaxy
  ('da4aa5a6-574e-43ef-9caf-5438f5a0c17a'::uuid, 'subtle'),       -- The Lies of Locke Lamora
  ('c671a150-708e-41e1-b280-0ce16df162f6'::uuid, 'moderate'),     -- The Man in the High Castle
  ('c1507bbf-878a-49a0-a1d3-5a32d891ef78'::uuid, 'heavy_handed'), -- The Poppy War
  ('26f6065b-35aa-45b5-98e4-76e0ce36df51'::uuid, 'moderate'),     -- The Road
  ('8a66d806-f218-4419-9d41-f55e1f6089df'::uuid, 'moderate'),     -- The Three-Body Problem
  ('a37a0f42-4444-4e3f-98f0-fe863d1be4e7'::uuid, 'moderate'),     -- The Time Machine
  ('40d83360-ee8a-4d80-b78f-edf2c7ba64d8'::uuid, 'subtle'),       -- The Way of Kings
  ('8eaf89ba-17ae-4ff6-abd0-523a5feb7aa0'::uuid, 'subtle')        -- We Are Legion (We Are Bob)
) as v(book_id, message_intensity)
where book_dna.book_id = v.book_id;
