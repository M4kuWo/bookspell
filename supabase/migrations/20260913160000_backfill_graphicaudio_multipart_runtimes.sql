-- Backfill total runtime_minutes for 28 multi-part GraphicAudio
-- dramatized_full_cast editions (e.g. "The Way of Kings" released as
-- parts 1-5) that had no total runtime recorded. Each part's own
-- "Approximate Running Time" was fetched from its individual
-- graphicaudiointernational.net product page (graphicaudio.net
-- 302-redirects there) and summed per book. 3 of the 28 had no
-- graphicaudio.net source_url on file (Dark Age, The Skull Throne --
-- amazon.com; A Court of Mist and Fury -- audible.com); the real
-- GraphicAudio product pages for all three were found via GraphicAudio's
-- own site search and confirmed by matching series/book in the page
-- title before use (see docs/project-log.md 2026-09-13 entry for the
-- per-book totals and the special-case URLs used).


update audiobook_editions set runtime_minutes = 960
  where book_id = (select id from books where title = 'A Court of Mist and Fury')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.audible.com/pd/A-Court-of-Mist-and-Fury-Part-1-of-2-Dramatized-Adaptation-Audiobook/B09YGG792Q'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1230
  where book_id = (select id from books where title = 'A Court of Silver Flames')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/a-court-of-thorns-and-roses-4-a-court-of-silver-flames-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 660
  where book_id = (select id from books where title = 'Age of Myth')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-legends-of-the-first-empire-1-age-of-myth-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 2010
  where book_id = (select id from books where title = 'Dark Age')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.amazon.com/Dark-Age-Part-Dramatized-Adaptation/dp/B0FF5JD1D6'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1350
  where book_id = (select id from books where title = 'Elantris')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/elantris-tenth-anniversary-author-s-definitive-edition-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1440
  where book_id = (select id from books where title = 'House of Earth and Blood')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/crescent-city-1-house-of-earth-and-blood-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1560
  where book_id = (select id from books where title = 'House of Flame and Shadow')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/crescent-city-3-house-of-flame-and-shadow-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1440
  where book_id = (select id from books where title = 'House of Sky and Breath')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/crescent-city-2-house-of-sky-and-breath-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1350
  where book_id = (select id from books where title = 'Iron Gold')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/red-rising-saga-4-iron-gold-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1620
  where book_id = (select id from books where title = 'Light Bringer')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/red-rising-saga-6-light-bringer-1-of-3.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1140
  where book_id = (select id from books where title = 'Mistborn: The Final Empire')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/mistborn-1-the-final-empire-1-of-3.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1230
  where book_id = (select id from books where title = 'Morning Star')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/red-rising-saga-3-morning-star-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 2460
  where book_id = (select id from books where title = 'Oathbringer')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-stormlight-archive-3-oathbringer-1-of-6.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 2700
  where book_id = (select id from books where title = 'Rhythm of War')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-stormlight-archive-4-rhythm-of-war-1-of-6.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 720
  where book_id = (select id from books where title = 'The Bands of Mourning')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/mistborn-6-the-bands-of-mourning-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1260
  where book_id = (select id from books where title = 'The Core')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/demon-cycle-5-the-core-1-of-4.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 840
  where book_id = (select id from books where title = 'The Daylight War')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/demon-cycle-3-the-daylight-war-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1020
  where book_id = (select id from books where title = 'The Desert Spear')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/demon-cycle-2-the-desert-spear-1-of-3.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1260
  where book_id = (select id from books where title = 'The Hero of Ages')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/mistborn-3-the-hero-of-ages-1-of-3.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 960
  where book_id = (select id from books where title = 'The Lost Metal')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/mistborn-7-the-lost-metal-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1140
  where book_id = (select id from books where title = 'The Skull Throne')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.amazon.com/Skull-Throne-Demon-Cycle-GraphicAudio/dp/1628511761'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 780
  where book_id = (select id from books where title = 'The Warded Man')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/demon-cycle-1-the-warded-man-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 2220
  where book_id = (select id from books where title = 'The Way of Kings')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-stormlight-archive-1-the-way-of-kings-1-of-5.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1320
  where book_id = (select id from books where title = 'The Well of Ascension')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/mistborn-2-the-well-of-ascension-1-of-3.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1020
  where book_id = (select id from books where title = 'Too Like the Lightning')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/terra-ignota-1-too-like-the-lightning-1-of-2.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 1020
  where book_id = (select id from books where title = 'Warbreaker')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/warbreaker-1-of-3.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 3090
  where book_id = (select id from books where title = 'Wind and Truth')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-stormlight-archive-5-wind-and-truth-series-set.html'
    and runtime_minutes is null;

update audiobook_editions set runtime_minutes = 2220
  where book_id = (select id from books where title = 'Words of Radiance')
    and edition_type = 'dramatized_full_cast'
    and source_url = 'https://www.graphicaudio.net/the-stormlight-archive-2-words-of-radiance-1-of-5.html'
    and runtime_minutes is null;
