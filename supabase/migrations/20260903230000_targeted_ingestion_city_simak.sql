-- Targeted ingestion: "City" by Clifford D. Simak, another remembered
-- book the repo owner surfaced after reviewing the fantasy/sci-fi
-- genre-split lists. Bibliographic data only, not tagged (separate
-- pass). Confirmed via a search-only pass first (hardcover_id 373370,
-- 322 users -- the clear single-book match, not the two omnibus
-- editions also returned for the same search, same "prefer the
-- single-book edition" precedent as earlier ingestion batches).
-- Contribution data confirms a single, clean author credit (no
-- translator/narrator contamination).

insert into books (title, author, isbn, cover_url, synopsis, page_count, audiobook_duration_minutes, publication_year, hardcover_id, series_id, position_in_series)
values (
  'City',
  'Clifford D. Simak',
  '1504013034',
  'https://assets.hardcover.app/edition/12204609/6c10065d81ff994f71f67bd3c55d000b1033652a.jpeg',
  '[Comment by John Clute]:

We know better now, of course. But they still entrance us, the old page-turners from the glory days of American SF, half a century or so ago, when the world was full of futures we were never going to have. In the mid-1940s, when he began to publish the episodes that would be assembled as City in 1952, Clifford Simak, a Minneapolis-based journalist and author, could still carry us away with the dream that cars and pollution and even the great cities of the world would soon be brushed off the map by Progress, leaving nothing behind but tasteful exurbs filled with middle-class nuclear families living the good life, with fishing streams and greenswards sheltering each home from the stormy blast.

Fortunately, Simak soon gets past this demented vision of a near-future world saved by technological fixes, a dementia common then to SF writers and gurus and politicians alike, and launches into an astonishingly eventful narrative of the next 10,000 years as seen through the eyes of one family and the immortal robot Jenkins, and all told with a weird pastoral serenity. In its course City touches on almost everything dear to 1940s SF: robots, genetic engineering, space, Jupiter, domed cities, hiveminds, matter transmission, telepathy, parallel worlds, paranormal empathy, mutants, supermen. The whole is framed as a series of legends told by the uplifted Dogs who have replaced the human race, now gone forever. They have been bred not to kill. At the end, only Jenkins remains to keep them from learning how to repeat history and die.',
  288,
  586,
  1944,
  373370,
  null,
  null
)
on conflict (hardcover_id) do nothing;
