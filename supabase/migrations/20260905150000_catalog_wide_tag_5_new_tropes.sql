-- Catalog-wide tagging pass for the 5 new trope concepts added in
-- 20260905140000. Each book below was individually checked against real
-- knowledge of its plot/relationships, not pattern-matched from genre --
-- see docs/project-log.md for the precise scope each trope was applied
-- under and specific exclusions considered and rejected during the pass.
-- Idempotent (on conflict do nothing) and title+author scoped throughout.

-- sapphic_romance: the CENTRAL romance of the book is between two women.
insert into book_tropes (book_id, trope_id, source)
select b.id, 'sapphic_romance', 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('One Last Stop', 'Casey McQuiston'),
  ('The Priory of the Orange Tree', 'Samantha Shannon'),
  ('Gideon the Ninth', 'Tamsyn Muir')
)
on conflict do nothing;

-- mlm_romance: the CENTRAL romance of the book is between two men.
insert into book_tropes (book_id, trope_id, source)
select b.id, 'mlm_romance', 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('The Song of Achilles', 'Madeline Miller'),
  ('Carry On', 'Rainbow Rowell'),
  ('The House in the Cerulean Sea', 'TJ Klune'),
  ('In the Lives of Puppets', 'TJ Klune'),
  ('Somewhere Beyond the Sea', 'TJ Klune')
)
on conflict do nothing;

-- infiltration_or_undercover_plot: protagonist adopts a false identity to
-- embed within a hostile/dangerous institution for a covert mission
-- (heist, assassination, espionage, regime subversion) -- broader than
-- "destroys the institution" alone (Six of Crows/Nevernight's missions
-- are personal/heist-scoped, not political), but still requires a real
-- false-identity/covert-embedding device, not just political conflict
-- or a rebellion in the background (excluded: The Poppy War trilogy,
-- The Grace of Kings, Iron Widow, The Cruel Prince -- real political
-- scheming/rebellion, but the protagonist doesn't adopt a false
-- identity to infiltrate anything specific; excluded Babel on reflection
-- -- Robin discovers an already-embedded secret resistance cell rather
-- than adopting a false identity himself).
insert into book_tropes (book_id, trope_id, source)
select b.id, 'infiltration_or_undercover_plot', 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('Mistborn: The Final Empire', 'Brandon Sanderson'),
  ('Red Rising', 'Pierce Brown'),
  ('The Traitor Baru Cormorant', 'Seth Dickinson'),
  ('Nevernight', 'Jay Kristoff'),
  ('Six of Crows', 'Leigh Bardugo'),
  ('Crooked Kingdom', 'Leigh Bardugo'),
  ('The Lies of Locke Lamora', 'Scott Lynch'),
  ('Red Seas Under Red Skies', 'Scott Lynch'),
  ('The Republic of Thieves', 'Scott Lynch'),
  ('City of Stairs', 'Robert Jackson Bennett')
)
on conflict do nothing;

-- alternate_history: real-world history + an inserted point of divergence
-- (magic/tech/different outcome), distinct from a secondary invented
-- world merely inspired by a historical period, and distinct from hidden
-- supernatural beings coexisting within otherwise-UNaltered real history
-- (excluded: The Golem and the Djinni, The Night Circus -- secret magic,
-- not altered outcomes; excluded The Ministry of Time -- time travel
-- INTO the present, not a past divergence point).
insert into book_tropes (book_id, trope_id, source)
select b.id, 'alternate_history', 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('His Majesty''s Dragon', 'Naomi Novik'),
  ('Jonathan Strange & Mr Norrell', 'Susanna Clarke'),
  ('The Man in the High Castle', 'Philip K. Dick'),
  ('Babel, or The Necessity of Violence: An Arcane History of the Oxford Translators'' Revolution', 'R.F. Kuang')
)
on conflict do nothing;

-- multi_generational_saga: follows a lineage/dynasty/institution across
-- multiple generations (a different protagonist/era per book or
-- section), not a single-generation single-protagonist epic. Applied to
-- the whole Foundation series consistently (same defining structural
-- device throughout, different specific protagonists per era) and the
-- whole Green Bone Saga (explicit multi-decade generational scope,
-- pronounced by book 3).
insert into book_tropes (book_id, trope_id, source)
select b.id, 'multi_generational_saga', 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('Foundation', 'Isaac Asimov'),
  ('Foundation and Empire', 'Isaac Asimov'),
  ('Second Foundation', 'Isaac Asimov'),
  ('Foundation''s Edge', 'Isaac Asimov'),
  ('Foundation and Earth', 'Isaac Asimov'),
  ('Prelude to Foundation', 'Isaac Asimov'),
  ('Forward the Foundation', 'Isaac Asimov'),
  ('Fire & Blood', 'George R.R. Martin'),
  ('One Hundred Years of Solitude', 'Gabriel García Márquez'),
  ('Jade City', 'Fonda Lee'),
  ('Jade War', 'Fonda Lee'),
  ('Jade Legacy', 'Fonda Lee')
)
on conflict do nothing;

-- cosmic_horror: dread from an incomprehensible, indifferent cosmic
-- force/entity beyond human understanding, where CONFRONTING it (not
-- defeating it) is the arc -- distinct from ancient_evil_awakens (a
-- typically defeatable, anthropomorphized dark-lord antagonist).
-- Excluded on reflection: Perdido Street Station (the Slake Moths are
-- eventually defeated by human ingenuity, which cuts against the
-- "confronting, not defeating" test); The Library at Mount Char, The
-- Fifth Season (god-like/vast antagonists, but more personal/
-- comprehensible than genuinely cosmic-indifferent); What Moves the
-- Dead, Between Two Fires, Slewfoot, The Exorcist, Carmilla (real named,
-- comprehensible antagonists within a defined cosmology, not
-- Lovecraftian incomprehensibility).
insert into book_tropes (book_id, trope_id, source)
select b.id, 'cosmic_horror', 'ai_inferred'
from books b
where (b.title, b.author) in (
  ('The Call of Cthulhu', 'H. P. Lovecraft'),
  ('Annihilation', 'Jeff VanderMeer'),
  ('Authority', 'Jeff VanderMeer'),
  ('Acceptance', 'Jeff VanderMeer, Helen Macdonald'),
  ('Lovecraft Country', 'Matt Ruff'),
  ('The Fisherman', 'John  Langan'),
  ('Mexican Gothic', 'Silvia Moreno-Garcia'),
  ('Bird Box', 'Josh Malerman'),
  ('House of Leaves', 'Mark Z. Danielewski')
)
on conflict do nothing;
