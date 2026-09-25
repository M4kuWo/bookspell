# Independent high-risk QA: heat, Knight reliability, Raven magic

Research date: 2026-09-25. Proposal only; no database, engine, metadata, or migration writes. Scope is seven assigned book/field pairs. Identities checked against `hosted.json` before web research. Sources below were opened, not merely found in search, except where explicitly marked rejected/failed. This is evidence-based QA, not a claim to have read each complete novel.

## Results

| Book | Field | Current | Outcome | Proposed value / confidence |
|---|---|---|---|---|
| The Knight and the Moth — Rachel Gillig | narrator_reliability | ambiguous / .4 | genuinely-inconclusive | ambiguous / **.4 unchanged** |
| The Knight and the Moth — Rachel Gillig | romance_heat_intensity | low / .4 | confirmed-correct | low / **.8** |
| The Queen of the Tearling — Erika Johansen | romance_heat_intensity | low / .4 | genuinely-inconclusive | low / **.4 unchanged** |
| The Raven Scholar — Antonia Hodgson | romance_heat_intensity | low / .4 | genuinely-inconclusive | low / **.4 unchanged** |
| The Raven Scholar — Antonia Hodgson | magic_system_hardness | soft / .4 | confirmed-correct | soft / **.8** |
| The River Has Roots — Amal El-Mohtar | romance_heat_intensity | closed_door / .4 | genuinely-inconclusive | closed_door / **.4 unchanged** |
| The Tommyknockers — Stephen King | romance_heat_intensity | low / .4 | genuinely-inconclusive | low / **.4 unchanged** |

No identity mismatches found. No value-change recommendation reaches adequate confidence. Keeping a .4 row does not endorse the current value.

## Definitions and method

Read `docs/schema/book-dna.schema.yaml` sections beginning lines 93, 240, and 558. The YAML defines reliability ambiguity as deliberate withholding that prevents judging the account, rather than merely bias/personality. Magic is per-book reader knowledge: unexplained magic may be soft even when later volumes systematize it. Heat enum is `na, closed_door, low, moderate, explicit`; YAML does not provide precise prose thresholds for these adjacent values. Applied the assignment's on-page sexual-detail definition and avoided equating scene count, sexual violence, romance centrality, or generic content warnings with heat intensity. Source scales are not mechanically mapped to the enum.

### 1. The Knight and the Moth: narrator reliability

Identity: Rachel Gillig, 2025; hosted ID `2d1bb586-8e12-4e4b-a6db-b3b4a51ce823`, Hardcover 1120724, ISBN 0316597694. Sources consistently concern Sybil and the first Stonewater Kingdom volume.

Opened [SuperSummary character analysis](https://www.supersummary.com/the-knight-and-the-moth/major-character-analysis/) (secondary literary analysis with primary quotations). Lines 71–81 identify Sybil as narrator, describe her believing the abbess because of missing prior memories, and describe her eventual rejection of the abbess's account. [Ink & Imaginings](https://inkandimaginings.com/the-knight-and-the-moth-by-rachel-gillig-summary-review-and-character-guide/) (reader guide, ending spoilers; lines 182–192) supplies definite answers about the abbess, resurrection, and gargoyles.

These are concrete examples of discovering concealed truths, not evidence that readers remain unable to judge the narrative account. They undermine any rationale based solely on an initially misinformed protagonist. However, neither is a focused assessment of whether all narrated experiences are verifiable. Without full-text checking, replacing `ambiguous` with `reliable` would turn absence of supporting evidence into proof. **Genuinely inconclusive: keep ambiguous / .4**, with `reliable` the direction worth investigating in a full read. A search hit from a bookstore called The Unreliable Narrator was rejected: store branding is not a literary assessment.

### 2. The Knight and the Moth: heat

Opened [Books With Bunny, January 22, 2026](https://www.bookswithbunny.com/the-knight-and-the-moth-book-review/) (first-person reader review). Its compact label is “open-door, tame”; the body independently explains that the book contains an open-door scene the reviewer found tame (lines 14 and 25). [Ink & Imaginings](https://inkandimaginings.com/the-knight-and-the-moth-by-rachel-gillig-summary-review-and-character-guide/) explicitly distinguishes a non-explicit open-door scene from kisses and closed-door material and points to chapter 25 (lines 170–181). [BroMantasy, May 30, 2025](https://bromantasy.com/reviews/the-knight-and-the-moth/) describes mildly detailed intimacy (lines 199–201).

Agreement is on description level, not just number of peppers or rarity. This supports `low` over `closed_door`, without evidence of sustained explicit anatomy. **Confirmed-correct: low / .8.** Limitation: reader descriptions rather than a directly inspected complete intimate scene; therefore not .9–1.0. Multiple commercial review pages may not be fully independent; Books With Bunny and chapter-specific guide carry the main evidentiary weight.

### 3. The Queen of the Tearling: heat

Identity: Erika Johansen, 2014; hosted ID `297ba5bd-cae9-4a33-961c-c92766feb153`, Hardcover 162015, ISBN 0062328093.

Opened [Common Sense Media, Book 1 review](https://www.commonsensemedia.org/book-reviews/the-queen-of-the-tearling-book-1) (editorial content review). Lines 175–181 separate numerous mentioned coercive acts from directly narrated violence; the sexual-content summary describes brief anatomical reference, a recalled act, self-touching, nonsexual nudity, and mild romantic feelings. This verifies sexual references and some bodily specificity, but does not clearly establish the level of an on-page romantic/consensual encounter. The review's publication listing is 2015, but the title, author, first-volume framing and Kelsea plot match the 2014 work, not a sequel.

Plugged In's book-specific sexual-content review was found but returned 403 when opened; its search extract was not used as decisive evidence. StoryGraph warnings conflate several kinds of content and cannot resolve the target boundary.

**Genuinely inconclusive: keep low / .4.** Do not raise confidence merely because there are anatomical words; equally, do not infer closed-door from the romance being slight. Inspect the actual recalled/depicted encounter in a licensed copy to resolve `low` versus nearby alternatives and whether the material is in the field's intended scope.

### 4. The Raven Scholar: heat

Identity: Antonia Hodgson, 2025; hosted ID `daa688e7-b044-418e-ad67-87debc862ce1`, Hardcover 1250824, ISBN 139975209X. Reviews concern Neema and the first Eternal Path volume.

Opened [Adventure Through the Pages](https://adventurethroughthepages.com/the-raven-scholar-review/) (reader review; line 85), which assigns its own spice level two and calls the romance a subplot. Neither assertion explains anatomical detail or distinguishes closed-door from mild open-door. Opened [StoryGraph sexual-content reviews](https://app.thestorygraph.com/book_reviews/9867e9f4-835b-4657-aee2-7184abcfca61/content_warning/45?page=5): individual warnings range from minor to graphic and lack scene-level calibration. A separate StoryGraph search extract mentioned fade-to-black encounters, but the opened paginated page delivered different reviews; that text was not promoted to verified evidence.

**Genuinely inconclusive: keep low / .4.** Low pepper scores and minor romance do not substantiate this enum. Need the actual scenes or a reviewer explicitly describing their on-page treatment.

### 5. The Raven Scholar: magic hardness

Opened [Gem's Book Talk, August 12, 2025](https://gemsbooktalk.com/2025/08/12/book-review-the-raven-scholar/) (first-person literary review). Line 48 directly says magic is opaque, with few demonstrations and little detailed explanation in this volume, while distinguishing a possible later expansion. The account places this in a concrete world: Eight Guardians, the Raven's shifting involvement, and the restricted imperial-island setting. Opened [Russ Allbery's review](https://www.eyrie.org/~eagle/reviews/books/0-316-57723-5.html), which distinguishes detailed mythology from a comparatively underdeveloped non-Guardian magic system and describes the Guardians' folktale quality (lines 22, 35–36).

This is unusually well matched to the schema's per-book revelation rule. A richly developed religion does not itself make operational magic hard. **Confirmed-correct: soft / .8.** Limitation: critics' interpretation rather than an exhaustive inventory of rules and constraints. Positive comments about rich worldbuilding do not refute the specific lack of explained mechanics.

### 6. The River Has Roots: heat

Identity: Amal El-Mohtar, 2025; hosted ID `28fd9f51-7fab-4109-9d42-96f7a57fe1c6`, Hardcover 1562200, ISBN 1250341086.

Opened [Demi Utley's book-club account](https://demiutley.substack.com/p/book-club-the-river-has-roots-by) (reader discussion): line 29 identifies an unusually sexual scene when Esther becomes a harp. Opened [SuperSummary's important quotations](https://www.supersummary.com/the-river-has-roots/important-quotes/) (secondary study guide reproducing a primary-text excerpt): chapter 9, page 80 contains an extended harp-playing analogy to intimacy. The language depicts bodily tension and release through musical metaphor, rather than literal anatomical description. The guide explicitly interprets erotic double meanings and locates them beside Rin's transformation of Esther.

This provides a real boundary problem rather than a generic no-spice assertion. An on-page erotic metaphor may make `low` more apt than `closed_door`, but the available excerpt alone does not establish how literal sexual action is rendered across the whole scene. A reviewer calling it a sex scene does not erase the metaphorical distinction. **Genuinely inconclusive: keep closed_door / .4.** Inspect the surrounding chapter before proposing low. A further review at Red Headed Femme returned 429 on opening; its search-result quotation was not necessary to the conclusion and is not used as independent confirmation.

### 7. The Tommyknockers: heat

Identity: Stephen King, 1987; hosted ID `737bcad6-31e7-417d-b08f-48470408a692`, Hardcover 376972, ISBN 0399133143. Movie/miniseries advisories were rejected.

Opened [Deeper Thoughts for the Horror Inclined, December 10, 2022](https://horrorinclined.wordpress.com/2022/12/10/the-tommyknockers-1987/) (literary review). It explicitly discusses an on-page encounter involving a teenage town inhabitant and connects it to the alien transformation theme. Opened [StoryGraph](https://app.thestorygraph.com/book_reviews/33dbba3a-4737-4d67-8399-5b72d6241f96/content_warning/45), whose reviewers disagree markedly on minor/moderate/graphic sexual content; one explicitly describes the novel's sex as graphic. Opened [ILX reader discussion](https://www.ilxor.com/ILX/ThreadSelectedControllerServlet?boardid=55&threadid=112594): a poll attributes a brief anatomical phrase to this title, but the surrounding thread is joking and cross-book; it is not a verified primary excerpt. No sexual passage is reproduced here.

The presence of actual sex is supported, and `low` could be an understatement. But warnings, one unverified fragment, and general graphicness do not distinguish moderate from explicit with adequate confidence or establish the exact consensual/romantic context of every scene. The automated Bleeped severity counts found in search were not adopted: no text-level audit or mapping to this schema was available. **Genuinely inconclusive: keep low / .4.** Priority follow-up is direct scene inspection; do not treat this unchanged row as a clean bill of health.

## Research audit

Local reads: `hosted.json` via Python `json.load`; `rg --files` to identify the YAML; `rg -n 'romance_heat_intensity:|narrator_reliability:|magic_system_hardness:' docs/schema/book-dna.schema.yaml`; `sed -n '85,108p;232,278p;550,579p' docs/schema/book-dna.schema.yaml`; targeted heat-definition searches in schema Markdown and tagging skill. Initial `schema*` search failed because zsh expanded a nonexistent glob, then was replaced by `rg --files`; no conclusions rely on that failed command.

Web searches used exact title plus heat/spice/sex, narrator/unreliable, or magic-system terms; every relied-upon page is linked above and was successfully opened with the browser tool. Failed openings and search-only leads are explicitly excluded. No unlicensed complete-book source was used. No whole-book reading, new tagging, hosted write, or test-suite execution occurred. All proposed confidence changes are review output only.
