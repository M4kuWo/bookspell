# Remaining-catalog tagging — 108-book round

Purpose: tag the remaining untagged books in the catalog (108 of 168 total,
after the 30-book pilot and the 30-book step04 test batch), during a window
the user explicitly authorized for autonomous work while away from their
computer ("use it to the max if you need").

## Methodology change from step04

Step04 used forked subagents (`subagent_type: "fork"`), which inherit the
full parent conversation history. That made each fork cost ~830K-840K
tokens for only 5-6 books of actual tagging work — the book-specific work
was a small fraction of each fork's token count.

This round switched to plain background agents (no fork) — each one
starts fresh, is told to `Read` the schema file itself
(`docs/schema/book-dna.schema.yaml`) plus `book-dna.md` for rationale, and
tags 6 books per agent. Per-agent usage came in at **~40K-65K tokens**,
roughly 15-20x cheaper than the forked approach, for materially the same
tagging quality (same schema-fidelity discipline, same vocabulary-only
rule, same gap-flagging behavior). This freed up the session's usage
budget to cover far more of the catalog in the same window than the
step04 cost projection assumed.

Each book was independently tagged by an agent that read the schema
directly rather than relying on inherited context, using the exact same
tagging discipline as every prior round: vocabulary-only trope IDs, valid
enum values only, content warnings scoped to the schema's controlled list,
and `book_length`/`audiobook_length`/`audiobook_native` explicitly excluded
(computed deterministically from stored `page_count`/
`audiobook_duration_minutes`, not judgment calls).

## Progress

- Wave 1 (groups 1-6, 36 books): tagged, validated, inserted. See
  `wave1-tagged.json`.
- Wave 2 (groups 7-12, 36 books): tagged, validated, inserted. See
  `wave2-tagged.json`.
- Wave 3 (groups 13-18, 36 books): tagged, validated, inserted. See
  `wave3-tagged.json`.

**All 108 remaining books tagged. Catalog is now at 168/168 books tagged
(100% coverage)** — confirmed via `select count(*) from books` vs
`select count(*) from book_dna` both returning 168, run at the end of
this session.

## Open items surfaced for later review (not applied yet)

- **Poor genre-fit candidates** (same treatment as Bird Box/The Road in
  earlier rounds — tagged but flagged as questionable catalog fits):
  The Silent Patient, The Girl with the Dragon Tattoo, House of Leaves,
  Slaughterhouse-Five, One Hundred Years of Solitude, The Alchemist,
  Tomorrow and Tomorrow and Tomorrow (tagged with `genre: []` — no forced
  sci-fi/fantasy tag applied at all, since the agent judged neither fit).
- **LitRPG `form` gap** — recurring across multiple rounds now (He Who
  Fights with Monsters → The Gate of the Feral Gods → Carl's Doomsday
  Scenario → The Butcher's Masquerade and others in the Dungeon Crawler
  Carl series). No `pov_structure.form` value captures embedded
  game-notification/system-text interruptions in otherwise-standard
  prose. Strong candidate for an actual schema addition given the
  recurrence count.
- **Corruption-arc trope gap** (The Ballad of Songbirds and Snakes) — no
  trope for a sympathetic-to-villain descent arc; `redemption_arc` only
  covers the opposite direction.
- **Mythological-figures-as-characters gap** (American Gods) — distinct
  from `mythological_retelling` (which implies retelling one specific
  myth's actual events); no vocabulary for a pantheon used as characters
  in an original plot.
- **Intelligence-enhancement-then-reversal gap** (Flowers for Algernon) —
  no trope captures a rise-then-tragic-fall arc; `underdog_rising` only
  covers the rise.
- **Fantasy-side satire gap** (The Colour of Magic, echoing Good Omens
  from step04) — `satirical_or_comedic_scifi` has no fantasy-side
  equivalent.
- **Sudden-apocalypse-in-progress gap** (Cat's Cradle) — `post_apocalyptic`
  only covers settings after collapse, not the unfolding event itself.
- **Ghost-sight / paranormal-perception gap** (Ninth House) — no trope for
  a character's ability to see/interact with ghosts specifically.
- **"Death game" / televised battle-royale gap** (Catching Fire and the
  Hunger Games series generally) — no single trope captures the
  state-mandated fight-to-the-death spectacle premise; several tropes
  cover adjacent pieces (`dystopia`, `child_soldiers_in_warfare`) but not
  the mechanic itself.
- **No content-warning ID for incest** (One Hundred Years of Solitude) or
  for **chronic pain/disability as lived experience distinct from
  `ableism_depicted`** (Tomorrow and Tomorrow and Tomorrow).
- **`narrator_reliability` binary gap** (Piranesi) — no middle ground
  between deceptive and merely naive/incomplete unreliable narration.
- A few individual imprecise-but-closest-available tags were flagged
  in-line by tagging agents (e.g. `telepathic_animal_bond` used for
  Dungeon Crawler Carl's Donut, whose abilities are LitRPG-progression-
  based rather than literally telepathic; `child_sexual_abuse` content
  warning applied to Snow Crash's Y.T./Raven relationship, flagged as
  worth a second look on severity/framing).

### Additional gaps surfaced in wave 3

- **LitRPG `form` gap** — reconfirmed twice more (Dungeon Crawler Carl book
  1, This Inevitable Ruin, The Eye of the Bedlam Bride). Now hit 6+ times
  across three tagging rounds — this is no longer a marginal one-off and
  is the strongest candidate for an actual schema addition.
- **Crime-family/gang-clan saga gap** (Jade City) — no trope for a
  mafia-style clan-turf-war structure; `court_intrigue`/`war_story`/
  `found_family` cover adjacent ground but not the genre blend itself.
- **Structured death-tournament/trial gap** (Harry Potter and the Goblet
  of Fire's Triwizard Tournament, Divergent's faction trials) — related to
  but distinct from the Hunger Games "death game" gap already noted;
  broader category of "formal, life-threatening competition among
  selected participants" with no matching trope.
- **Uplift gap** (Children of Time) — a species deliberately/accidentally
  granted intelligence via human tech has no matching trope;
  `species_divergence` only covers humanity splitting into new species,
  not another species being uplifted.
- **Amnesia-reveals-own-backstory gap** (Project Hail Mary) — no trope for
  a protagonist whose memory loss/recovery is the structural engine
  revealing his own past to himself, distinct from `twist_ending`/
  `twist_filled` (which are reader-facing reversals, not self-discovery).
- **Solo-survival-via-competence gap** (The Martian) — no trope for
  survivalist-ingenuity-against-an-indifferent-environment as the book's
  entire engine; left thin (`last_minute_rescue` only) despite being a
  defining genre entry.
- **No content-warning for pandemic/epidemic** (Station Eleven) — closest
  neighbors (`child_death`, `war_trauma`) don't fit civilizational
  collapse from disease specifically; a real gap for a growing subgenre.
- **No content-warning for fictional-species-based prejudice** (The Cruel
  Prince's fae-vs-human contempt, The House in the Cerulean Sea's
  anti-magical-youth bigotry) — `racism_depicted`/`hate_speech_depicted`
  are written for real-world-analog prejudice; in-world species bigotry
  doesn't map cleanly onto either.
- **Frankenstein — genre fit judgment call**: tagged `sci_fi` (scientific
  transgression, not supernatural), but the schema has no horror genre
  option and this is arguably gothic horror first. Not flagged for
  exclusion (unlike the sci-fi/fantasy-scoped poor fits above), just
  noted as an imperfect single-genre fit.

None of these were applied to the schema in this pass — same discipline as
every other vocabulary decision in this project: logged for deliberate
review with the user, not unilaterally added.
