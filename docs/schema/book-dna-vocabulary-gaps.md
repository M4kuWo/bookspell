# Book DNA — flagged vocabulary gaps tracker

Split out of `book-dna.md` 2026-09-25 as its own file (was the
"Flagged single-occurrence vocabulary gaps" subsection of "Future
fields backlog") — see `docs/codx-reports/2026-09-25-book-dna-split-review.md`
for why: this is ACTIVE operational content `tag-catalog-batch` and
`catalog-trope-gap-sweep` require reading before tagging, not
historical backlog. Read this file in full before running either skill,
per `book-dna.md`'s own routing pointer and each skill's own
requirement. See `book-dna.md` for the standing vocabulary bar ("does
this predict a different recommendation") this tracker applies, and
`book-dna-decisions.md` for the full dated chronology of every growth
round referenced below by name.

**A running tracker, not a one-off list — update it every time `tag-catalog-batch`
flags a real vocabulary gap it didn't act on, and check it BEFORE deferring
a new one.** This project's vocabulary bar is deliberately "does this change
what gets recommended," not "is this a real term" (see CLAUDE.md's "Data
quality / tagging" section) — a real gap seen on exactly one book is
correctly deferred rather than turned into vocabulary on the spot. The gap
in that process (raised by the repo owner 2026-09-13): several single-book
gaps *were* being flagged in `docs/project-log.md` batch reports as the
catalog was tagged, but nothing tracked them centrally, so a second book
hitting the same gap in a later batch had no way to be recognized as a
second occurrence — the only way to notice would be remembering (or
re-reading) every prior batch's report by hand, which doesn't scale past a
few thousand log lines. This list is the fix: every flagged gap goes here
the moment it's noted (not just in that day's log entry), and gets removed
(with a note on where it landed) once a second real occurrence promotes it
to an actual schema/vocabulary proposal.

**Open** (seed list, backfilled 2026-09-13 from `docs/project-log.md`'s
existing "Vocabulary gap noted, not acted on" entries — check this list,
don't re-derive it from the log):
- **Content warning**: no `content_warnings` value cleanly covers
  "climate/natural-disaster mass casualty" (distinct from `war_trauma`,
  which is the closest existing fit but an imperfect one). First seen
  2026-09-09 tagging *The Ministry for the Future* (Kim Stanley
  Robinson's opening heat-wave mass-death event, tagged `war_trauma` at
  `moderate` as the nearest fit). Watch for climate-disaster-driven SFF
  (flooding, ecological collapse, mass-casualty weather events as a
  book's inciting incident, not just background setting).
  **CHECKED 2026-09-13 (catalog-trope-gap-sweep), still just one real
  occurrence — stays Open.** Searched tagged books carrying
  `sudden_apocalypse_event`/`post_apocalyptic`/`dying_earth` tropes plus
  known cli-fi-adjacent titles for a second natural-disaster-driven mass
  casualty event. Real candidates exist in the catalog but aren't
  tagged yet (no `book_dna` row, out of this sweep's scope to tag):
  *American War*, *Termination Shock*, *The Year of the Flood*, *The
  Overstory*. Of the tagged books checked, the closest near-miss is
  *Parable of the Sower* (Octavia Butler) — but its Robledo-community
  destruction is human-perpetrated arson/looting enabled by societal
  collapse, not itself a natural-disaster event the way Ministry for
  the Future's heat wave is, so it doesn't cleanly hit this gap either
  (already correctly tagged without this warning). Worth re-checking
  the four untagged candidates above directly against this gap once
  they're tagged.
  <!-- FLAGGED 2026-09-25: this exact gap ALSO appears below under
  "Promoted / resolved" (as natural_disaster_mass_casualty) AND again
  in the "stays Open, not promoted" note further down -- a real,
  pre-existing 3-way internal status contradiction, found while
  splitting this file out of book-dna.md, NOT introduced by the split
  and NOT resolved here. See
  docs/codx-reports/2026-09-25-book-dna-split-review.md. Needs a human
  decision on the actual current status (check the live
  content_warnings/tropes tables directly) before trusting any of the
  three conflicting notes below at face value. -->
- **Trope**: no existing trope cleanly captures first-contact-with-a-
  non-human-non-alien-intelligence-via-natural-evolution (as opposed to
  genetic uplift, which has its own trope, or contact with an actual
  extraterrestrial). First seen 2026-09-09 tagging *The Mountain in the
  Sea* (Ray Nayler — octopus intelligence arising through ordinary
  evolution), tagged as the closest real fits (`first_contact` at 0.6,
  `uplift` at 0.5) rather than proposing a new value off one book. The
  log entry that first flagged this named two plausible next
  occurrences worth checking if/when they're tagged: *Alien Clay*
  (Adrian Tchaikovsky) and *Blindsight* (Peter Watts) — check both
  against this exact gap before tagging either, since either one hitting
  it would be the second occurrence this list exists to catch.
  **CHECKED 2026-09-13 (catalog-trope-gap-sweep), still just one real
  occurrence — stays Open.** Both named candidates are in the catalog
  now: *Blindsight* IS tagged (`first_contact` among its tropes), but
  its actual mechanism is contact with a genuine extraterrestrial
  intelligence (the Rorschach/scramblers) — precisely the case this gap
  is defined to exclude ("as opposed to... contact with an actual
  extraterrestrial"), so it's correctly tagged `first_contact` as-is and
  isn't a second occurrence. *Alien Clay* is in the catalog but NOT yet
  tagged (no `book_dna` row) — out of scope for this sweep to tag (that's
  `tag-catalog-batch`'s job), but worth checking directly against this
  gap when it does get tagged: its premise (an alien planet's biosphere
  functioning as an emergent collective intelligence) is a plausible
  near-miss, but note it's still contact with an *alien* (extraterrestrial)
  ecology, not a natural-evolution-on-Earth case like The Mountain in the
  Sea's octopuses — check the actual mechanism, don't assume it qualifies
  just because it's evolution-flavored.
  **CHECKED again 2026-09-13 (sweep #3)**, still just one real
  occurrence — stays Open. *Alien Clay* confirmed still untagged (no
  `book_dna` row) — Step 1's required light-touch check. *Blindsight*
  re-confirmed correctly excluded (genuine extraterrestrial contact, not
  natural-Earth-evolution). No other book across all 7 sweep-#3 clusters
  hit this specific mechanism.
  **CHECKED again 2026-09-16 (CLDA, round-4 standalone batch)** — *Alien
  Clay* is now tagged (this session). Confirmed via direct research
  (Wikipedia plot summary) exactly as this tracker predicted: Kiln's
  "builders" are an emergent property of an *alien* planet's own
  ecosystem — genuine extraterrestrial biology, not a natural-Earth-
  evolution case — so it's correctly excluded on the same grounds as
  *Blindsight*, tagged plain `first_contact` (no `incomprehensible_alien_
  contact` either, since mutual nonverbal comprehension is achieved).
  Still just one real occurrence — stays Open.
- **Trope**: `skinchanging_or_body_possession` — a character projects
  their consciousness into and directly controls another living
  creature's body (animal or human) while their own body remains
  inert/vulnerable, distinct from transforming one's own body. Found
  2026-09-13 (catalog-trope-gap-sweep) on A Song of Ice and Fire's
  warging (Bran Stark/Varamyr Sixskins, recurring across *A Game of
  Thrones* through *A Dance with Dragons*) — real and cleanly distinct
  from `shapeshifters` (own-body transformation) and
  `telepathic_animal_bond` (a two-way bond, not active possession), but
  all evidence is one series. Watch for a second book/series with this
  specific possession mechanic (not just "animal companion" or
  "shapeshifting"). **CHECKED again 2026-09-13 (sweep #2)**, still no
  confirmed second occurrence — stays Open. Stuart Turton's *The 7 1/2
  Deaths of Evelyn Hardcastle* was considered and rejected (sequential
  serial host-hopping within a time loop, no separate vulnerable "home
  body" left behind — mechanically different, see its own new entry
  below). Samantha Shannon's *The Bone Season* "dreamwalking" is a
  **possible but unverified** lead — the reviewing agent's confidence in
  the exact mechanic (active host-body control vs. astral
  travel/communication only) wasn't solid enough to assert; worth a
  firmer check by someone with closer knowledge of books 2-4. Stephenie
  Meyer's *The Host* was also considered and correctly ruled a different
  concept, not this one — see its own new entry below.
  **CHECKED again 2026-09-13 (sweep #3)**, still no confirmed second
  occurrence — stays Open. Checked closely against the epic/grimdark
  fantasy cluster's telepathic-bond candidates (Anne McCaffrey's
  *Dragonflight* dragon-rider bond, Robert Jordan/Sanderson's wolf-dream
  bond in *Towers of Midnight*) — both are explicitly TWO-WAY telepathic
  links that leave neither party's body inert/vulnerable, already
  correctly captured by `telepathic_animal_bond`, not a match. The Bone
  Season lead from sweep #2 remains unverified (not re-checked this
  round — out of this round's book pool).
- **Trope**: `remote_piloted_robotic_surrogate` — a person's
  consciousness/neural signal controls a separate robotic body in real
  time (telepresence) while their own body remains elsewhere, distinct
  from digitizing consciousness or enhancing one's own biological body.
  Found 2026-09-13 (catalog-trope-gap-sweep) on John Scalzi's *Lock In*/
  *Head On* ("threeps" piloted by Haden's-syndrome sufferers) — real and
  distinct from `cybernetic_enhancement`/`android_or_replicant_rights`/
  `mind_uploading_or_digital_immortality`, but both evidence books are
  one duology (arguably one story). Watch for a second, independent
  telepresence/robotic-surrogate book. **CHECKED again 2026-09-13
  (sweep #2)**, no matches found across ~366 books/6 author clusters —
  stays Open.
- **Trope**: `magical_archive_guardian` — protagonist's central
  vocation/identity is steward or keeper of a repository of magical
  books/spells (a library, archive, or shop built from one), often
  having fled or been expelled from the official institution while still
  carrying that custodial duty forward. Found 2026-09-13 (sweep #3) on
  Sarah Beth Durst's *The Spellshop* (Kiela flees the destroyed Great
  Library with a wagon of illegal spellbooks, becomes a covert
  spell-dispensing shopkeeper) and Margaret Rogerson's *Sorcery of
  Thorns* (Elisabeth Scrivener trains as a Warden protecting the Great
  Library of Summershall's sentient grimoires, later framed/expelled but
  still fighting to protect them) — real cross-mechanism match (a cozy
  cottage-shop vs. a gothic library-academy look different on the
  surface, but the underlying "entrusted-with/fleeing-with a magical
  book collection one must protect" mechanism is the same specific,
  checkable plot fact in both). Deliberately NOT promoted this round —
  only 2 books, and the reviewing agent flagged its own uncertainty about
  whether the surface-setting difference undercuts the pattern; held to
  the more cautious bar rather than forced in. Distinct from
  `dark_academia_setting` (atmosphere tag, only fits one of the two
  evidence books) and `magic_school` (neither book is a school-attendance
  narrative).
- **Trope**: serial body-hopping time-loop mystery — protagonist's
  consciousness wakes in a different host's body each day within a
  repeating time loop, the host's own will suppressed, but with no
  separate vulnerable "home body" left elsewhere (the discriminator from
  `skinchanging_or_body_possession` above). Found 2026-09-13 (sweep #2)
  on Stuart Turton's *The 7 1/2 Deaths of Evelyn Hardcastle* — distinct
  from `time_loop` + `amnesia_driven_narrative` (both already tagged on
  it, neither captures the body-hopping mechanism specifically). One
  occurrence only.
- **Trope**: ritualized, consequence-free time travel for emotional
  closure — a strictly bounded time-travel device (fixed seat/location,
  fixed short duration, cannot leave the setting, and critically:
  nothing done in the past changes the present) used purely to say
  goodbye/gain closure, not for plot-consequence time travel. Found
  2026-09-13 (sweep #2) on Toshikazu Kawaguchi's *Before the Coffee Gets
  Cold* and *Tales from the Cafe* — tonally opposite from every other
  `time_travel`-tagged book checked in the same cluster (Hyperion, Sea of
  Tranquility). Both evidence books are one author's series; watch for a
  second, independent author using this same no-consequence-closure
  mechanic.
- **Trope**: sanctioned, ritualized killing as a professional class
  within an otherwise-utopian, death-eliminated society — distinct from
  `genocide` (group-identity-targeted) and `war_trauma` (conflict-driven).
  Found 2026-09-13 (sweep #2) on Neal Shusterman's Scythe trilogy (an AI,
  the Thunderhead, has eliminated natural death; sanctioned Scythes
  ritually "glean" people to control population). One occurrence only;
  a content-warning angle on the same premise is also worth watching for
  separately.
- **Trope**: magic system revealed to be powered by a hidden, exploited/
  erased underclass — the setting's celebrated magic is exposed as
  running on a covered-up atrocity against a subjugated population,
  central to a plot twist. Found 2026-09-13 (sweep #2) on M.L. Wang's
  *Blood Over Bright Haven*. Distinct from `magically_binding_bargain`
  (an individual contract, not a societal-exploitation reveal) and the
  `magic_system_hardness` scalar (cost mechanics, not this specific
  reveal). One occurrence only.
- **Trope**: state magically drains citizens' power/life-force as
  tribute, with a formal trial/competition mechanic letting individuals
  reduce their own tax. Found 2026-09-13 (sweep #2) on James Islington's
  *The Will of the Many* (the Vis/Catenary system). Distinct from
  `deadly_competition_or_trial` (covers the trial mechanic generically,
  not the extraction-as-tribute economics it's wrapped around). One
  occurrence only.
- **Content warning**: no `content_warnings` value cleanly covers a
  planned, human-perpetrated mass-casualty attack (a shooting, a bombing)
  in an otherwise-ordinary contemporary setting — distinct from
  `war_trauma` (implies organized conflict), `natural_disaster_mass_
  casualty` (explicitly natural/astronomical in origin, promoted
  2026-09-13), and `genocide` (requires group-identity targeting). First
  seen 2026-09-16 (CLDA, tagging batch) on *Odd Thomas* (Dean Koontz) --
  the book's climax is a foiled mall shooting/bombing plot, tagged with
  no content warning at all rather than forced into one of the three
  near-misses above. Watch for a second occurrence (a school shooting, a
  terrorist bombing, etc. as a book's central event).
- **Trope**: permanent, non-consensual parasitic body possession — an
  entity permanently colonizes a resistant human host with no return
  trip and no separate vulnerable body of its own, while the original
  consciousness remains trapped and aware inside. Found 2026-09-13
  (sweep #2) on Stephenie Meyer's *The Host*. Deliberately distinct from
  `skinchanging_or_body_possession` above (that's temporary projection
  with an inert-but-recoverable home body left behind elsewhere; this is
  permanent occupation with no home body to return to at all) — a real,
  related, but mechanically different concept, not a second occurrence
  of the existing entry. One occurrence only.
- **Trope**: a family/castle society bound by an exhaustive, unbroken
  book of ceremonial ritual observance that dictates daily life down to
  the smallest gesture, where deviation from the prescribed ritual is
  itself a central source of dramatic tension — distinct from
  `court_intrigue` (political scheming among people, not
  observance-as-law) and `caste_or_faction_stratified_society` (a formal
  caste-sorting mechanism, not a ritual-observance regime). Found
  2026-09-20 (CLDA, catalog tagging batch 8) on Mervyn Peake's *Titus
  Groan* — the Groan family's entire existence is governed by
  Gormenghast's "Book" of ritual, tracked and enforced by the Master of
  Ritual (Sourdust). One occurrence only; watch for a second.
- **Trope**: a comatose/unconscious protagonist's own spirit or
  consciousness detaches from and observes/moves through the physical
  world outside their inert body, weighing whether to live or die --
  distinct from `ghost_sight` (which covers seeing OTHER dead people, not
  being an out-of-body spirit oneself) and from `amnesia_driven_narrative`
  (no memory loss is involved). Found 2026-09-21 (CLDA, catalog tagging
  batch 9) on Gayle Forman's *If I Stay* -- Mia's spirit walks the
  hospital observing her own body and the people around her while in a
  coma after a car accident, deciding whether to stay. One occurrence
  only; watch for a second.
- **Content warning**: no `content_warnings` value cleanly covers forced
  female genital cutting/circumcision specifically -- distinct from
  `sexual_assault` (a different act) and `child_abuse` (a real but
  imprecise umbrella that doesn't name the actual practice). Found
  2026-09-21 (CLDA, round-5 batch 5) tagging Nnedi Okorafor's *Who Fears
  Death*, where forced circumcision of 11-year-old girls (including the
  protagonist) is a repeated, central plot element -- tagged `child_abuse`
  at `central_theme` as the nearest available fit rather than left
  unflagged, but that's a real gap, not a clean match. One occurrence
  only; watch for a second (any book depicting FGM/forced circumcision as
  a real plot element, not just referenced in passing).

**Promoted / resolved**:
- **`caste_or_faction_stratified_society`** — promoted 2026-09-13 (sweep
  #3) on a genuine new confirming instance (*Brave New World*) plus real
  discriminating counter-evidence resolving sweep #2's self-flagged
  co-occurrence-with-`dystopia` risk (*Battle Royale*/*The Knife of Never
  Letting Go* are both `dystopia`-tagged with no caste-sorting mechanism
  at all). See `book-dna-decisions.md`'s "Vocabulary growth process —
  dated growth rounds" section ("Seventh growth round").
- **`monster_hunter_for_hire`** — promoted 2026-09-13 (sweep #2) on a
  genuine second, cross-genre occurrence (Ilona Andrews's Kate Daniels —
  Magic Bites, Magic Burns) alongside the original Witcher evidence. See
  `book-dna-decisions.md`'s growth-rounds section ("Sixth growth round").
- **Content warning, climate/natural-disaster mass-casualty gap** —
  promoted 2026-09-13 (sweep #2) as `natural_disaster_mass_casualty`
  (scoped broadly, not narrowly "climate" — see that entry's own naming
  rationale) on two independent second occurrences (James Dashner's *The
  Kill Order*, Neal Stephenson's *Seveneves*). See `book-dna-decisions.md`'s
  growth-rounds section ("Sixth growth round"). <!-- FLAGGED: see the
  inline flag on the matching "Open" entry above -- this status
  directly contradicts that entry and the "stays Open, not promoted"
  note below. Not resolved here. -->
- **6 trope values** (5 concepts: `sapphic_romance`/`mlm_romance`,
  `infiltration_or_undercover_plot`, `alternate_history`,
  `multi_generational_saga`, `cosmic_horror`) — landed 2026-09-05 via
  the first catalog-wide gap sweep (migration
  `20260905140000_add_5_new_tropes_from_gap_sweep.sql`), but never
  actually recorded in this tracker or documented in this file/
  `book-dna.schema.yaml` until the 2026-09-13 sweep caught the gap by
  cross-checking the live DB against the docs directly. See
  `book-dna-decisions.md`'s growth-rounds section ("Fourth growth
  round") for full detail.
- **5 trope values** (`anthropomorphic_personification_protagonist`,
  `government_experimentation_on_the_gifted`, `magically_binding_bargain`,
  `predictive_social_science`, `post_scarcity_utopia`) — landed
  2026-09-13 via the second catalog-wide gap sweep (migration
  `20260913170000_catalog_trope_gap_sweep_5_new_tropes.sql`). See
  `book-dna-decisions.md`'s growth-rounds section ("Fifth growth
  round") for full detail.
- **10 more trope values** (`forced_psychological_reconditioning`,
  `incomprehensible_alien_contact`, `impossible_or_non_euclidean_architecture`,
  `mass_unexplained_sensory_or_memory_loss`, `animated_construct_companion`,
  `institutional_time_travel_bureaucracy`, `secret_magical_bureaucracy`,
  `old_faith_displaced_by_new_religion`,
  `state_mandated_body_harvesting_or_modification`,
  `modern_knowledge_as_power_source`) — landed 2026-09-13 via the third
  catalog-wide gap sweep (migration
  `20260913230000_catalog_trope_gap_sweep_3_11_new_tropes.sql`, alongside
  the `caste_or_faction_stratified_society` promotion above — 11 new
  values total in that migration). See `book-dna-decisions.md`'s
  growth-rounds section ("Seventh growth round") for full detail.
- Both already-open gaps (climate/natural-disaster mass-casualty CW;
  first-contact-via-natural-evolution trope) were re-checked 2026-09-13
  and confirmed to still have only one real occurrence each — see their
  own entries above for what was checked. They stay Open, not promoted.
  <!-- FLAGGED: this line directly contradicts the "Promoted/resolved"
  entry for the same content warning, two entries above. Both are
  preserved verbatim from the pre-split file; neither has been altered
  or reconciled by this split. -->
- `remote_piloted_robotic_surrogate` and `skinchanging_or_body_possession`
  were also re-checked against sweep #3's book pool where relevant
  (telepathic-bond candidates in the epic-fantasy cluster) — no second
  occurrence found; both stay Open. `fragmented_nonlinear_structure`
  (Infinite Jest/Gravity's Rainbow) was investigated as a new candidate
  and REJECTED, not deferred — both evidence books already carry
  `timeline: nonlinear`, confirmed via direct DB query, so it's fully
  redundant rather than a real gap (see `book-dna-decisions.md`'s
  "Rejected / superseded decisions" section). `cannibalism` (content
  warning) was re-surfaced with stronger cross-author evidence (Tender
  Is the Flesh, The Road) than its original single-book pilot-era
  rejection, but deliberately left as a flagged-for-reconsideration item
  rather than added or formally reopened unilaterally — see
  `book-dna-decisions.md`'s "Rejected / superseded decisions" section
  (the `cannibalism` entry) for the full, still-pending status.

**Process note for whoever runs `tag-catalog-batch` next**: Step 1 of that
skill already says to flag a suspected vocabulary gap instead of silently
working around it — read this section as part of that step (both to check
an already-open gap against the book you're tagging, and to add any new
single-occurrence gap you find), not just as something to write in that
day's `project-log.md` entry. The log entry is still the right place for
the narrative/reasoning; this list is what makes a *second* occurrence
actually recognizable later.
