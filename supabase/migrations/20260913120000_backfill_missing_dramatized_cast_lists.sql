-- Backfill narrator/cast lists for GraphicAudio dramatized_full_cast
-- editions that had a real production but no cast recorded yet (21
-- flagged in docs/TODO.md 2026-09-13). Sourced from each edition's own
-- source_url (GraphicAudio's official 'Director & Cast' product-page
-- attribute), not guessed. 12 of the 21 are recoverable this way; the
-- other 9 are handled separately (6 are a deliberate prior no-op for
-- bundled Earthsea/Foundation BBC dramatizations where per-book cast
-- can't be attributed safely, 3 -- Dresden Files 5: Death Masks, Red
-- Rising Saga 6: Light Bringer, Throne of Glass -- genuinely have no
-- cast published on GraphicAudio's own site yet, confirmed by checking
-- every available product-page variant, not a lookup that was skipped.

update audiobook_editions set narrators = array['Danny Montooth', 'Yasmin Tuazon', 'Matthew McGee', 'Elizabeth Jernigan', 'Joe Mallon', 'Andy Brownstein', 'Lily Beacon', 'Robbie Gay', 'Chris Davenport', 'Evan Casey', 'Stephon Walker', 'Nazia Chaudhry', 'Keval Shah', 'Julie Hoverson', 'Christopher Williams', 'Laura C. Harris', 'Peter Holdway', 'Mike Carnes', 'Matthew Bassett', 'Eric Messner', 'David Zitney', 'David Engel']
  where book_id = (select id from books where title = 'Dawnshard')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-stormlight-archive-dawnshard.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['Terence Aselford', 'Kimberly Gilbert', 'Bradley Smith', 'Scott McCormick', 'Elisabeth Demery', 'Colleen Delany', 'Yasmin Tuazon', 'Ken Jackson', 'Nora Achrati', 'Nick DePinto', 'Evan Casey', 'Chris Genebach', 'Amanda Forstrom', 'Nanette Savard', 'Michael John Casey', 'Tracy Lynn Olivera', 'Mort Shelby', 'Rose Elizabeth Supan']
  where book_id = (select id from books where title = 'Edgedancer')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-stormlight-archive-edgedancer.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['Henry W. Kramer', 'Ken Jackson', 'Stewart Crank', 'Chingwe Padraig Sullivan', 'Khaya Fraites', 'Ryan Haugen', 'Michael Glenn', 'Torian Brackett', 'Colleen Delany', 'Damon Alums', 'Karen Novack', 'Marni Penning', 'Nanette Savard', 'James Lewis', 'Richard Rohan', 'Ryan Dalusung', 'Elena Anderson', 'Lily Beacon', 'John Kielty', 'Elias Khalil', 'Brian Kim McCormick', 'Keith Richards', 'Rob McFadyen', 'Jeri J. Marshall', 'Holly Adams', 'Rose Elizabeth Supan', 'Mort Shelby', 'Steve Wannall', 'Michael John Casey', 'Crystal Lee', 'Terence Aselford', 'Yenni Ann', 'Aure Nash', 'Troy Allan', 'Yasmin Tuazon', 'Chikondi Chanthunya', 'Andrew Mimms', 'Dan Delgado', 'Taylor Coan', 'Thomas Penny']
  where book_id = (select id from books where title = 'Empire of Silence')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-sun-eater-1-empire-of-silence-1-of-2.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['Stewart Crank', 'Jenna Sharpe', 'Jon Vertullo', 'Ian Russell', 'Richard Rohan', 'Julie-Ann Elliott', 'Andrew James Spooner', 'Laura C. Harris', 'Kay Eluvian', 'Nhea Durrosseau', 'Amanda Forstrom', 'Andy Clemence', 'Bradly Foster Smith', 'Chris Davenport', 'Colleen Delany', 'Danny Gavigan', 'David Cui Cui', 'David Engel', 'Dylan Lynch', 'Elena Anderson', 'Elizabeth Jernigan', 'Eric Messner', 'Gabriel Michael', 'Holly Adams', 'Ian Putnam', 'James Konicek', 'John Kielty', 'Julie Hoverson', 'Karen Novak', 'Ken Jackson', 'Lucy Symons', 'Marni Penning', 'Matthew Bassett', 'Michael John Casey', 'Mike Carnes', 'Nanatte Savard', 'Nazia Chaudhry', 'Nicole Perez', 'Peter Stray', 'Rana Kay', 'Scott McCormick', 'Shanta Parasuraman', 'Stephanie Németh-Parker', 'Steve Wannall', 'Todd Scofield', 'Wyn Delano', 'Yasmin Tuazon', 'Zeke Alton']
  where book_id = (select id from books where title = 'Golden Son')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/red-rising-saga-2-golden-son-1-of-2.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['Stewart Crank', 'Alex Hill-Knight', 'Elena Anderson', 'Christopher Tester', 'Jenna Sharpe', 'John Kielty', 'Todd Scofield', 'Richard Rohan', 'Jon Vertullo', 'Ian Putnam', 'Melody Muze', 'Damon Alums', 'Danny Gavigan', 'Rayner Gabriel', 'Matthew Schleigh', 'Matthew Bassett', 'Eric Messner', 'Michael John Casey', 'Nathaniel Priestly', 'Drew Kopas', 'Carolyn Kashner', 'David Ault', 'Lise Bruneau', 'Elizabeth Jernigan', 'Su Ling Chan', 'Nora Achrati', 'Jessica Schly', 'Tia Shearer', 'Eva Wilhelm', 'Dave Fernandez', 'Robb Moreira', 'Marni Penning', 'Peter Stanley', 'James Lewis', 'Robert Bayley', 'Sheree Wichard', 'Andy Brownstein', 'James Konicek', 'Rana Kay', 'Laura C. Harris', 'Jeff Baker', 'Scott McCormick', 'Terence Aselford', 'Karen Novak', 'Donald Guzzi', 'Bradley Foster Smith', 'Crystal Lee', 'Kimberly Gilbert']
  where book_id = (select id from books where title = 'Iron Gold')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/red-rising-saga-4-iron-gold-1-of-2.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['Terence Aselford', 'David Jourdan', 'Alejandro Ruiz', 'Ken Jackson', 'Chris Davenport', 'Dawn Ursula', 'Nick DePinto', 'Tony Nam', 'Zeke Altonn', 'Bradley Smith', 'Kimberly Gilbert', 'Christopher Walker', 'Nanette Savard', 'Peter Holdway', 'Scott McCormick', 'Colleen Delany', 'Nathanial Perry', 'Mort Shelby', 'Rose Elizabeth Supan', 'Richard Rohan', 'Michael John Casey', 'Elizabeth Jernigan']
  where book_id = (select id from books where title = 'Mistborn: Secret History')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/mistborn-secret-history-the-eleventh-metal-and-allomancer-jak-and-the-pits-of-eltania.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['Stewart Crank', 'Jon Vertullo', 'Jenna Sharpe', 'Andrew James Spooner', 'Laura C. Harris', 'Kimberly Gilbert', 'Bradley Foster Smith', 'Andy Brownstein', 'Chris Davenport', 'Colleen Delany', 'Danny Gavigan', 'Elena Anderson', 'Eric Messner', 'Ian Putnam', 'Joel David Santner', 'John Kielty', 'Kay Eluvian', 'Ken Jackson', 'Lucy Symons', 'Marni Penning', 'Matthew Bassett', 'Michael Glenn', 'Michael John Casey', 'Nanatte Savard', 'Nazia Chaudhry', 'Nhea Durrosseau', 'Peter Stray', 'Shanta Parasuraman', 'Stephanie Németh-Parker', 'Steve Wannall', 'Todd Scofield', 'Yasmin Tuazon', 'Zeke Alton']
  where book_id = (select id from books where title = 'Morning Star')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/red-rising-saga-3-morning-star-1-of-2.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['David Cui Cui', 'Crystal Lee', 'Elena Anderson', 'Natalie Van Sistine', 'Alejandro Ruiz', 'Amanda Forstrom', 'Christopher Williams', 'Colleen Delany', 'Debi Tinsley', 'Emily Beresford', 'Eva Wilhelm', 'Gabriel Michael', 'Gail Shalan', 'Holly Adams', 'Ken Jackson', 'Khaya Fraites', 'Laura C. Harris', 'Lise Bruneau', 'Lydia Kraniotis', 'Marni Penning', 'Nick Russo', 'Samantha Cooper', 'Sarah Ruth Thomas', 'Scott McCormick', 'Shanta Parasuraman', 'Thomas Penny', 'Triya Leong', 'Tyler Hyrchuk', 'Yasmin Tuazon', 'Zeke Alton']
  where book_id = (select id from books where title = 'Network Effect')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-murderbot-diaries-5-network-effect.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['Dylan Lynch', 'Andy Clemence', 'David Harris', 'Robbie Gay', 'Casie Platt', 'Tim Getman', 'Lily Beacon', 'Evan Casey', 'Nora Achrati', 'Chris Genebach', 'Mort Shelby', 'Rose Elizabeth Supan', 'Christopher Graybill', 'Alejandro Ruiz', 'Terence Aselford', 'Niusha Nawab', 'James Konicek', 'Karen Novack', 'Joe Mallon', 'Kimberly Gilbert', 'Michael John Casey', 'Dani Stoller', 'Ken Jackson', 'Thomas Penny', 'Todd Scofield', 'Colleen Delany', 'Christopher Scheeren', 'Yasmin Tuazon', 'David Jourdan', 'Laura C. Harris', 'Elizabeth Jernigan', 'Christopher Walker', 'Richard Rohan', 'Matthew McGee', 'Jessica Lefkow', 'Peter Holdway', 'Carolyn Kashner', 'Tim Pabon']
  where book_id = (select id from books where title = 'Oathbringer')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-stormlight-archive-3-oathbringer-1-of-6.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['Terence Aselford', 'Kimberly Gilbert', 'Bradley Smith', 'Nick DePinto', 'Tony Nam', 'Richard Rohan', 'Thomas Keegan', 'Rose Elizabeth Supan', 'Mort Shelby', 'Bob Payne', 'Michael Glenn', 'Steven Carpenter', 'Eric Messner', 'Laura C. Harris', 'Tim Carlin', 'David Jourdan', 'Ken Jackson', 'Evan Casey', 'David Harris', 'Tara Giordano', 'Mathew Keenan', 'Chris Davenport', 'Jefferson A. Russell', 'Andy Brownstein', 'Scott Graham', 'David Coyne', 'Patrick Bussink', 'Christopher Graybill', 'Joel Santner', 'Emlyn McFarland', 'Scott McCormick', 'Elizabeth Jernigan', 'Steve Wannall', 'Gregory Gorton', 'Nathanial Perry', 'James Lewis', 'Nanette Savard']
  where book_id = (select id from books where title = 'The Hero of Ages')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/mistborn-3-the-hero-of-ages-1-of-3.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['Dylan Lynch', 'Robbie Gay', 'Casie Platt', 'Andy Clemence', 'Tim Getman', 'Zoe Badovinac', 'Nora Achrati', 'Mort Shelby', 'Drew Kopas', 'Evan Casey', 'Christopher Scheeren', 'Christopher Walker', 'Bradley Smith', 'Maboud Ebrahimzadeh', 'Michael Glenn', 'Michael John Casey', 'Terence Aselford', 'Thomas Penny', 'Matthew Keenan', 'James Konicek', 'Richard Rohan', 'Steven Carpenter', 'Colleen Delany', 'Thomas Keegan', 'Scott McCormick', 'Eric Messner', 'Shasha Olinick', 'Bob Payne', 'Chris Davenport', 'Christopher Graybill', 'Andy Brownstein', 'Tony Nam', 'David Harris', 'Ken Jackson', 'Marni Penning', 'Jacob Yeh', 'Jeff Allin', 'Patrick Bussink', 'Rose Elizabeth Supan', 'Yasmin Tuazon', 'Nick DePinto', 'Kimberly Gilbert', 'Tim Pabon']
  where book_id = (select id from books where title = 'The Way of Kings')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-stormlight-archive-1-the-way-of-kings-1-of-5.html'
    and (narrators is null or array_length(narrators,1) is null);

update audiobook_editions set narrators = array['Danny Montooth', 'Emlyn McFarland', 'Robbie Gay', 'Andy Clemence', 'Chris Davenport', 'Nora Achrati', 'Terence Aselford', 'James Konicek', 'Drew Kopas', 'Lily Beacon', 'Bradley Foster Smith', 'Kay Elúvian', 'Christopher Walker', 'Kimberly Gilbert', 'Zoé Badovinac', 'Donald Guzzi', 'Yenni Ann', 'Rana Kay', 'Torian Brackett', 'Mort Shelby', 'Stephon Walker', 'Karen Novack', 'Jonathon Church', 'Jon Vertullo', 'Joe Mallon', 'Richard Rohan', 'Sura Siu', 'Damon Alums', 'Evan Casey', 'RJ Bayley', 'Chris Stinson', 'Elizabeth Jernigan', 'Stephanie Németh-Parker', 'Joey Sourlis', 'Sandi Stock', 'Matthew Aldwin McGee', 'Danny Gavigan', 'Elena Anderson', 'Michael Glenn', 'Scott McCormick', 'Dani Stoller', 'Barbara Pinolini', 'Marni Penning', 'Eric Messner', 'Daniel Llaca', 'Sarah Ruth Thomas', 'Thomas Penny', 'Nicole Shara', 'Matthew Bassett', 'David M. Jourdan', 'Tanja Milojevic', 'Rayner Gabriel', 'Keval Shah', 'Wyn Delano', 'Grace Srinivasan', 'Dylan Lynch', 'Peter Holdway', 'Ken Jackson', 'Jacob Yeh', 'Shravan Amin', 'Zura Johnson', 'Julie-Ann Elliott', 'Todd Scofield', 'Christopher Williams', 'Andrew Arceus', 'Holly Adams']
  where book_id = (select id from books where title = 'Wind and Truth')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-stormlight-archive-5-wind-and-truth-series-set.html'
    and (narrators is null or array_length(narrators,1) is null);
