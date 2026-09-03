-- Deletes 51 confirmed out-of-scope books (2026-09-03): pulled into the
-- catalog by Hardcover's noisy genre-search ingestion, classified by a
-- dedicated review pass (see docs/project-log.md), confirmed with the repo
-- owner before deletion per this project's standing catalog-scope policy.
-- Verified beforehand: zero dependent rows in book_dna/book_tropes/
-- book_content_warnings/book_field_confidence/rating_submissions for any
-- of these (all were untagged). Individually-scoped statements, one per
-- book, per this project's rule against blanket unscoped deletes.

delete from books where title = 'A Farewell to Arms';
delete from books where title = 'A Tree Grows in Brooklyn';
delete from books where title = 'Aristotle and Dante Discover the Secrets of the Universe';
delete from books where title = 'Around the World in Eighty Days';
delete from books where title = 'Atlas Shrugged';
delete from books where title = 'Atmosphere: A Love Story';
delete from books where title = 'Beartown';
delete from books where title = 'Billy Summers';
delete from books where title = 'Bridge to Terabithia';
delete from books where title = 'Butcher & Blackbird';
delete from books where title = 'Cosmos';
delete from books where title = 'Deception Point';
delete from books where title = 'Digital Fortress';
delete from books where title = 'Fangirl';
delete from books where title = 'Fifty Shades of Grey';
delete from books where title = 'Foucault''s Pendulum';
delete from books where title = 'Haunting Adeline';
delete from books where title = 'Holly';
delete from books where title = 'Home Before Dark';
delete from books where title = 'If on a Winter''s Night a Traveler';
delete from books where title = 'If We Were Villains';
delete from books where title = 'Inferno';
delete from books where title = 'Invisible Man';
delete from books where title = 'Mother Night';
delete from books where title = 'Orbital';
delete from books where title = 'Origin';
delete from books where title = 'Paradise Lost';
delete from books where title = 'Reamde';
delete from books where title = 'The Amazing Adventures of Kavalier & Clay';
delete from books where title = 'The Bluest Eye';
delete from books where title = 'The Crying of Lot 49';
delete from books where title = 'The Da Vinci Code';
delete from books where title = 'The Fountainhead';
delete from books where title = 'The Glass Castle';
delete from books where title = 'The Godfather';
delete from books where title = 'The Hawthorne Legacy';
delete from books where title = 'The Inheritance Games';
delete from books where title = 'The Lost Apothecary';
delete from books where title = 'The Maidens';
delete from books where title = 'The Naturals';
delete from books where title = 'The Overstory';
delete from books where title = 'The Pillars of the Earth';
delete from books where title = 'The Plague';
delete from books where title = 'The Secret of Secrets';
delete from books where title = 'The Shadow of the Wind';
delete from books where title = 'The Wasp Factory';
delete from books where title = 'The Yellow Wallpaper';
delete from books where title = 'There There';
delete from books where title = 'Twisted Love';
delete from books where title = 'White Noise';
delete from books where title = 'Wonder';
