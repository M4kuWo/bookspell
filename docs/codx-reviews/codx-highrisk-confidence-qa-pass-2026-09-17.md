# Task 9 — independent QA of low-confidence high-risk tags

Prepared by CODX, 2026-09-17 (Asia/Jerusalem). Proposal only for CLDO.

## Outcome and scope

Reviewed all 20 assigned book/field pairs, plus Ilium/person: **3 likely wrong, 8 confirmed correct with proposed confidence increases, 10 genuinely inconclusive and unchanged**. No catalog, confidence, scoring, migration, or application changes were made. The recommendations below require CLDO's independent review; the confidence numbers express evidence strength, not statistically calibrated probabilities.

The strongest correction is Gods of Jade and Shadow/pov_count: two independent reviews identify Casiopea, Martín, and Vucub-Kamé as viewpoint threads, making `few` appropriate. Fall/person has explicit third-person omniscient evidence rather than mixed grammatical persons. Gateway/reliability is a more interpretive correction, supported by reviews addressing self-deception and the therapeutic framing, and should receive correspondingly careful owner review.

This assignment supersedes the completed scorer migrations. The task was read from `docs/codx-tasks/current-task.md` after `git pull --ff-only`, following `docs/persona-workflow.md`. Baseline: **c41933e6b6a7e1c2f345b93d225f8c43552c12f4**. Read CLAUDE.md, the project-log tail and the two September 16 batch entries, the CODX backlog, schema guidance, and `.claude/skills/tag-catalog-batch/SKILL.md`. Applied that skill's identity and evidence standards to a review only; did not invoke its tagging/write procedure.

## Method and limits

Read hosted public `books`, `book_dna`, and `book_field_confidence` through HTTP GET using the anon key already shipped in `app/shared.js`. This happened before field research. All 21 assigned confidence values matched the brief. Books were paginated explicitly: the server capped the first request at 1,000 rows, so the final read used two ordered pages (1,000 + 256). Selected 18 distinct works. Raw bibliographic and confidence evidence is retained in the companion evidence directory and summarized below.

Research used web searches followed by accessible reviews, sample chapters, and an academic analysis. Sources are linked at each finding. A source identifying two protagonists does not establish two POVs; a large cast does not establish an ensemble. `pov_count` uses recurring, page-time-significant viewpoints: single=1, dual=2, few=3–4, several=5–7, ensemble=8+. `mixed` means different grammatical persons across narrative threads, not multiple third-person characters. These definitions come from `docs/schema/book-dna.schema.yaml`. Memory loss, mental illness, subjective narration, and a mystery's withholding of clues do not alone establish an unreliable or ambiguous narrator under that schema.

For subjective drive/humor boundaries, evidence of an ingredient is weaker than evidence of its prevalence or structural dominance. I recommend increases only where the research improves that distinction. Inconclusive means retain both the exact current value and confidence; it does not mean that the current tag has been verified. No whole-book reading or exhaustive chapter-by-chapter POV census is claimed.

Identity checks used hosted UUID, author, Hardcover work ID, ISBN, year, synopsis, and the matching author/work discussed by sources. **I did not independently authenticate all numeric Hardcover IDs against Hardcover's API or inspect every stored ISBN edition.** Its public Shroud page yielded no usable metadata through the web tool; a direct unauthenticated fetch returned HTTP 403. The links and table below establish the catalog rows and researched works, not an independent audit of Hardcover's internal identity mapping. Several stored ISBNs represent translations/reissues; English-language work-level evidence is used, not a claim about translation-specific humor. CLDO should retain this qualification if applying the proposals.

## Hosted identity record

The stored title is `Fall or, Dodge in Hell`, without the task brief's semicolon. Exact UUIDs are in the companion JSON. Stored publication years are reproduced as data, not endorsed: Fall's stored 2018 differs from the 2019 publication context of the reviewed novel. That is an incidental metadata follow-up, outside this task.

| Hosted title | Author | Hardcover work ID | Stored ISBN | Stored year |
|---|---|---:|---|---:|
| Accelerando | Charles Stross | 374578 | 1841493899 | 2005 |
| Annie Bot | Sierra Greer | 1061553 | 0063312697 | 2024 |
| Congo | Michael Crichton | 380571 | 0613100557 | 1980 |
| Dreamcatcher | Stephen King | 381512 | 3453437330 | 2001 |
| Fall or, Dodge in Hell | Neal Stephenson | 434196 | 0062887467 | 2018 |
| Gateway | Frederik Pohl | 97435 | 0345253787 | 1977 |
| Gods of Jade and Shadow | Silvia Moreno-Garcia | 428523 | 6070796667 | 2019 |
| Ilium | Dan Simmons | 377360 | 8417347356 | 2003 |
| Legion | Brandon Sanderson | 427735 | 1250218330 | 2012 |
| Lord of Light | Roger Zelazny | 109204 | 1857988205 | 1967 |
| Pushing Ice | Alastair Reynolds | 127926 | 0441014011 | 2005 |
| Shards of Honour | Lois McMaster Bujold | 427370 | 9731248382 | 1986 |
| Shroud | Adrian Tchaikovsky | 1420497 | 1035013827 | 2025 |
| Six Wakes | Mur Lafferty | 427471 | 6049769753 | 2017 |
| Soulless | Gail Carriger | 33557 | 0316438952 | 2009 |
| The Bright Sword | Lev Grossman | 484946 | 0593833562 | 2024 |
| The Deep Sky | Yume Kitasei | 584712 | 1250875331 | 2023 |
| The Echo Wife | Sarah Gailey | 427729 | 1432884131 | 2021 |

**Shroud disambiguation, before assessing its fields:** hosted UUID `7249fe6d-23ad-4506-9375-5615f0463402`, author Adrian Tchaikovsky, year 2025, Hardcover ID **1420497**, ISBN **1035013827**. [Goodreads' editions listing](https://www.goodreads.com/work/editions/216604275-shroud) identifies the corresponding ISBN-13 **9781035013821** as the 2025 Tchaikovsky work. [Orbit's official excerpt](https://www.hachettebookgroup.com/orbit-books/excerpt-shroud-by-adrian-tchaikovsky/?lens=twelve) concerns Juna, Mai, and the hostile alien moon, matching the hosted synopsis. None of the following Shroud conclusions uses John Banville's 2003 novel. The numeric Hardcover ID is the verified hosted association, subject to the external-ID limitation above.

## Recommendations at a glance

| # | Book / field | Current | Finding | Proposed value / confidence |
|---:|---|---|---|---|
| 1 | Shroud / pov_count | dual / 0.4 | Confirmed correct | dual / 0.85 |
| 2 | Shroud / person | first / 0.5 | Confirmed correct | first / 0.80 |
| 3 | Shroud / humor_level | light / 0.5 | Confirmed correct | light / 0.70 |
| 4 | Gateway / narrator_reliability | reliable / 0.4 | Likely wrong | unreliable / 0.75 |
| 5 | Soulless / drive | romance_driven / 0.4 | Confirmed correct | romance_driven / 0.75 |
| 6 | Congo / person | third_limited / 0.5 | Genuinely inconclusive | unchanged |
| 7 | Dreamcatcher / person | third_limited / 0.5 | Genuinely inconclusive | unchanged |
| 8 | Fall or, Dodge in Hell / person | mixed / 0.5 | Likely wrong | third_omniscient / 0.80 |
| 9 | Gods of Jade and Shadow / pov_count | dual / 0.5 | Likely wrong | few / 0.85 |
| 10 | Legion / narrator_reliability | reliable / 0.5 | Genuinely inconclusive | unchanged |
| 11 | Lord of Light / person | third_omniscient / 0.5 | Confirmed correct | third_omniscient / 0.75 |
| 12 | Pushing Ice / pov_count | few / 0.5 | Genuinely inconclusive | unchanged |
| 13 | Shards of Honour / drive | character_driven / 0.5 | Genuinely inconclusive | unchanged |
| 14 | Six Wakes / narrator_reliability | ambiguous / 0.5 | Genuinely inconclusive | unchanged |
| 15 | The Bright Sword / pov_count | few / 0.5 | Genuinely inconclusive | unchanged |
| 16 | The Bright Sword / humor_level | moderate / 0.5 | Confirmed correct | moderate / 0.70 |
| 17 | The Deep Sky / drive | balanced / 0.5 | Genuinely inconclusive | unchanged |
| 18 | Accelerando / humor_level | moderate / 0.5 | Confirmed correct | moderate / 0.75 |
| 19 | Annie Bot / humor_level | light / 0.5 | Genuinely inconclusive | unchanged |
| 20 | The Echo Wife / humor_level | light / 0.5 | Genuinely inconclusive | unchanged |
| 21 | Ilium / person | mixed / 0.6 | Confirmed correct | mixed / 0.90 |

## Individual findings

### 1. Shroud — pov_count

**Current:** `dual`, confidence **0.4**. Identity: Tchaikovsky/2025, Hardcover 1420497, as disambiguated above.

[Grimdark Magazine, Rai Furniss-Greasley, February 17, 2026](https://www.grimdarkmagazine.com/review-shroud-by-adrian-tchaikovsky/) explicitly identifies two narrators: Juna Ceelander and the Shrouded. [R. Cawkwell's March 18, 2025 audiobook review](https://everythingisbetterwithdragons.co.uk/2025/03/18/audiobook-review-shroud-by-adrian-tchaikovsky-narrated-by-sophie-aldred/) independently describes alternating human and alien sections. Mai is Juna's companion, not the second viewpoint. The latter review also describes translator interludes; it does not establish an additional recurring, independent viewpoint arc.

**Confirmed correct. Recommend `dual`, confidence 0.85.** This is supported by explicit structural descriptions, not by counting the two stranded humans. Residual uncertainty concerns interlude treatment and the distributed alien identity, so not 1.0.

### 2. Shroud — person

**Current:** `first`, confidence **0.5**. Same verified work, Hardcover 1420497.

The [official Orbit excerpt](https://www.hachettebookgroup.com/orbit-books/excerpt-shroud-by-adrian-tchaikovsky/?lens=twelve) directly shows Juna narrating in first person. [Grimdark's review](https://www.grimdarkmagazine.com/review-shroud-by-adrian-tchaikovsky/) describes first-person narration across the two perspectives, and [Cawkwell](https://everythingisbetterwithdragons.co.uk/2025/03/18/audiobook-review-shroud-by-adrian-tchaikovsky-narrated-by-sophie-aldred/) specifically discusses why first person works for Juna and the Shrouded.

**Confirmed correct. Recommend `first`, confidence 0.80.** The primary excerpt inspected covers the human opening, not the entire alien thread; the latter is independently reviewed rather than directly sampled here. Changing species or collective identity does not by itself imply `mixed`.

### 3. Shroud — humor_level

**Current:** `light`, confidence **0.5**. Same verified work, Hardcover 1420497.

The [Orbit excerpt](https://www.hachettebookgroup.com/orbit-books/excerpt-shroud-by-adrian-tchaikovsky/?lens=twelve) supplies book-specific dry corporate irony: the narrator's treatment of Special Projects' internal factions and management's expectations. [Filip Magnus's June 6, 2026 review](https://filipmagnuswrites.wordpress.com/2026/06/06/terror-and-mystery-in-shroud-by-adrian-tchaikovsky-book-review/) situates occasional dark humor within the survival narrative. This replaces the migration's assumption from the author's usual style with actual evidence from this work.

**Confirmed correct. Recommend `light`, confidence 0.70.** The humor is a secondary register amid sustained danger; the evidence does not justify upgrading the level to moderate or heavy. This is a cautious tonal judgment, not a measured joke frequency.

### 4. Gateway — narrator_reliability

**Current:** `reliable`, confidence **0.4**. Frederik Pohl's 1977 novel, Hardcover 97435; Robinette Broadhead and the Heechee gateway, not a similarly titled work.

[Andrew Gibson's review](https://andrewggibson.com/gateway/) explicitly identifies Broadhead as unreliable within the retrospective therapeutic narrative. [Wildspace's April 26, 2016 review](https://spelljammerblog.wordpress.com/2016/04/26/book-review-gateway-by-frederik-pohl/) gives a concrete interpretive discrepancy: Broadhead's account of his supposed cowardice is distorted by survivor guilt and self-loathing. [Jo Walton's February 9, 2011 essay](https://reactormag.com/absentee-aliens-frederik-pohls-gateway/) independently establishes the alternating therapy/life-story structure and the gradual reconstruction of the event underlying his guilt.

**Likely wrong. Recommend `unreliable`, confidence 0.75.** The case is distorted self-accounting exposed through the narrative, not simply an unpleasant protagonist or the fact that he receives therapy. This is less mechanical than a pronoun/POV count. CLDO should check the therapeutic corrections against the text before applying; I am not claiming that every event he reports is false, nor endorsing readers' speculative murder theories.

### 5. Soulless — drive

**Current:** `romance_driven`, confidence **0.4**. Gail Carriger's 2009 Alexia Tarabotti novel, Hardcover 33557; not the manga adaptation or later series volumes.

Shannon Marie Rollins, *Crafting Women's Narratives: The Material Impact of Twenty-First Century Romance Fiction on Contemporary Steampunk Dress*, PhD thesis, University of Edinburgh, 2019, [printed page 131 / PDF page 146](https://era.ed.ac.uk/bitstream/1842/36570/1/Rollins2019.pdf), analyzes Soulless as following Regis's eight-part romance structure. That is stronger evidence than a publisher's genre label. The [LoveVampires review](https://www.lovevampires.com/gcsoulless.html) describes the romance as primary while acknowledging a substantial mystery. [All About Romance](https://allaboutromance.com/book-review/soulless-by-gail-carriger-2/) emphasizes its genre blend, which is a reason to keep the increase moderate.

**Confirmed correct. Recommend `romance_driven`, confidence 0.75.** Removing the courtship would leave an external mystery but lose the central relationship structure described by the analysis. Neither sex frequency nor romance tone was evaluated here.

### 6. Congo — person

**Current:** `third_limited`, confidence **0.5**. Michael Crichton's 1980 novel, Hardcover 380571; sources about the 1995 film were excluded.

Searches for Crichton/Congo/narrator/omniscient and point of view produced little direct classification. [Jimmy Maher's detailed discussion](https://www.filfre.net/2013/10/michael-crichton/) identifies passages of narrator-supplied scientific exposition alternating with the expedition narrative. That is a real reason to question a simple close-limited classification, but exposition alone does not settle whether the narrative voice is omniscient. The [publisher's book page](https://www.penguinrandomhouse.com/books/33489/congo-by-michael-crichton/9780307816504) establishes the correct work, not the limited-versus-omniscient distinction. An attempted BookRags styles page was unavailable.

**Genuinely inconclusive. Retain `third_limited`, confidence 0.5.** Do not raise confidence merely because third-person narration seems clear. A useful follow-up is a text sample spanning a scene transition and narrator knowledge, not another plot synopsis.

### 7. Dreamcatcher — person

**Current:** `third_limited`, confidence **0.5**. Stephen King's 2001 novel, Hardcover 381512; not the film, television episode, or E. J. Mellow's similarly titled work.

[Library of 1000 Books, February 24, 2019](https://libraryof1000books.wordpress.com/2019/02/24/book-697-dreamcatcher-by-stephen-king/) describes third-person narration with frequent switches among the friends, military characters, and an occasional minor character. [SFRevu's contemporary review](https://sfrevu.com/ISSUES/2001/0103/9956%20Dreamcatcher/dreamcatcher_by_stephen_king.htm) corroborates the switch to the military strand. Neither establishes whether those switches consistently preserve limited focalization or use an omniscient narrator. Searches specifically for omniscience did not resolve that distinction.

**Genuinely inconclusive. Retain `third_limited`, confidence 0.5.** Multiple third-person viewpoints are compatible with limited narration; rapid switches alone do not prove omniscience. No change to the separate POV-count tag is proposed.

### 8. Fall or, Dodge in Hell — person

**Current:** `mixed`, confidence **0.5**. Neal Stephenson's novel, Hardcover 434196; identified by Dodge/Egdod, Sophia, and Bitworld, despite the catalog's title punctuation and year differences noted above.

[BookRags' visible Point of View section](https://www.bookrags.com/studyguide-fall-or-dodge-in-hell/styles.html) explicitly identifies an omniscient third-person narrator, with chapters generally following one character and sometimes several. It discusses the same characters before and after their digital afterlives. The [authorized CrimeReads excerpt](https://crimereads.com/fall-or-dodge-in-hell/) corroborates third-person narration in the opening, although an opening alone cannot establish the whole novel's structure.

**Likely wrong. Recommend `third_omniscient`, confidence 0.80.** Different characters and worlds are not different grammatical persons. The whole-book classification rests principally on the study guide; no full-text pronoun census was performed.

### 9. Gods of Jade and Shadow — pov_count

**Current:** `dual`, confidence **0.5**. Silvia Moreno-Garcia's 2019 novel, Hardcover 428523; the Casiopea/Hun-Kamé journey in Jazz Age Mexico.

[Dini Panda Reads, April 16, 2022](https://dinipandareads.com/2022/04/16/book-review-gods-of-jade-and-shadow-by-silvia-moreno-garcia/) explicitly identifies three POVs: Casiopea, Martín, and Vucub-Kamé, and distinguishes Hun-Kamé as sharing Casiopea's narrative rather than receiving his own viewpoint. [Malin's November 3, 2023 review](https://kingmagu.blogspot.com/2023/11/cbr15-book-64-gods-of-jade-and-shadows.html) independently describes recurring switches to Martín and chapters following Vucub-Kamé.

**Likely wrong. Recommend `few`, confidence 0.85.** Three recurring threads fit the schema's 3–4 bucket. This is not counting the romantic pair or the named cast. Malin's cross-post on Cannonball Read would be the same evidence, not a third independent source.

### 10. Legion — narrator_reliability

**Current:** `reliable`, confidence **0.5**. Brandon Sanderson's original 2012 novella, Hardcover 427735, catalog length 88 pages. Research excluded conclusions specific to the later three-novella collection and Lies of the Beholder.

[Sanderson's own excerpt](https://www.brandonsanderson.com/blogs/blog/legion-excerpt) openly distinguishes Stephen Leeds's hallucinated aspects from external people. His [author FAQ](https://faq.brandonsanderson.com/knowledge-base/where-did-you-get-the-idea-for-legion/) describes the aspects as manifestations of useful specialist knowledge. That argues against treating hallucinations as an automatic unreliability tag. However, [Publishers Weekly's review of the original 88-page novella](https://www.publishersweekly.com/9781596064850) emphasizes uncertainty around reality and illusion. These sources do not conclusively establish how far the narrator's own account should be trusted throughout the entire novella.

**Genuinely inconclusive. Retain `reliable`, confidence 0.5.** The opening is transparently self-disclosing, but is insufficient to certify the whole narrative. Do not substitute a diagnosis for textual evidence or import the trilogy's ending into this novella.

### 11. Lord of Light — person

**Current:** `third_omniscient`, confidence **0.5**. Roger Zelazny's 1967 novel, Hardcover 109204; Sam and the technologically empowered gods.

The [Gale study-guide material hosted by BookRags](https://www.bookrags.com/studyguide-lord-of-light/style.html), visible Point of View section, describes a narrator with access to characters' thoughts and motivations, including scenes away from Sam. Its wording uses “omnipotent,” but the described narrative access maps to the schema's omniscient category. This is evidence about narration, not an inference from the characters being gods.

**Confirmed correct. Recommend `third_omniscient`, confidence 0.75.** Explicit whole-book structural analysis improves on 0.5, but the accessible evidence is one study-guide source rather than independent primary samples across the novel.

### 12. Pushing Ice — pov_count

**Current:** `few`, confidence **0.5**. Alastair Reynolds's 2005 novel, Hardcover 127926; the Rockhopper/Janus expedition.

Reviews found through searches for narrative perspectives and POV count, including [Marginalia Notes](https://marginalianotes.ca/2012/10/28/review-pushing-ice-by-alastair-reynolds/) and [Random Alex](https://randomalex.net/2011/05/11/pushing-ice-its-what-we-do/), discuss Bella and Svetlana and the wider crew. The [Fantasy Literature search result](https://fantasyliterature.com/reviews/pushing-ice/) also discusses human perspectives, but opening the page returned HTTP 403. None of this supplies a defensible census of recurring viewpoint characters. Crew names, antagonistic leads, and a framing scene are not interchangeable with such a census.

**Genuinely inconclusive. Retain `few`, confidence 0.5.** Neither a downgrade to dual based on the two leaders nor an increase based on the crew's size is supported. Chapter-level viewpoint mapping would resolve this more efficiently than further generic reviews.

### 13. Shards of Honour — drive

**Current:** `character_driven`, confidence **0.5**. Lois McMaster Bujold's 1986 novel, Hardcover 427370; the US spelling Shards of Honor in sources refers to the same work. Not Barrayar or the combined Cordelia's Honor volume.

[Paperwights' July 4, 2015 discussion](https://paperwights.wordpress.com/2015/07/04/lois-mcmaster-bujold-shards-of-honor/) directly debates whether courtship or speculative action is primary, acknowledging the romance structure while disagreeing on its dominance. [Romance Novels for Feminists](https://romancenovelsforfeminists.blogspot.com/2013/06/1980s-feminism-in-lois-mcmaster-bujolds.html) reads the Cordelia/Aral relationship as a romance. These are relevant competing interpretations, not evidence that every book with strong characters is character-driven.

**Genuinely inconclusive. Retain `character_driven`, confidence 0.5.** The researched accounts do not decisively distinguish character, romance, and balanced narrative drive. A confident correction from the military setting or the eventual marriage would repeat the genre-pattern error this review is meant to avoid.

### 14. Six Wakes — narrator_reliability

**Current:** `ambiguous`, confidence **0.5**. Mur Lafferty's 2017 novel, Hardcover 427471; six revived clones aboard the Dormire.

[Kirkus](https://www.kirkusreviews.com/book-reviews/mur-lafferty/six-wakes/) establishes missing memories and a murder mystery involving the crew's concealed histories. [Destiny Daniels's October 3, 2023 review](https://authordestinydaniels.home.blog/2023/10/03/a-review-six-wakes-by-mur-lafferty/) discusses the narrators' withheld information and memory problems as near-unreliability. Neither source demonstrates the schema's stricter requirement for `ambiguous`: the text ultimately withholding enough information that narrator trustworthiness remains unresolved.

**Genuinely inconclusive. Retain `ambiguous`, confidence 0.5.** This is an unresolved concern about the existing tag, not confirmation. Solving a mystery from incomplete memories differs from a narrative refusing to resolve reliability. A final-act textual check is needed before choosing reliable or unreliable instead.

### 15. The Bright Sword — pov_count

**Current:** `few`, confidence **0.5**. Lev Grossman's 2024 novel, Hardcover 484946; Collum's arrival after Arthur's death.

[Grimdark's review](https://www.grimdarkmagazine.com/review-the-bright-sword-by-lev-grossman/) discusses Collum and several lesser-known knights; [the novel's plot overview](https://en.wikipedia.org/wiki/The_Bright_Sword) describes a structure involving their backstories. Searches for explicit POV counts and reviews of the flashback structure did not establish how many characters have recurring, page-time-significant viewpoint sections. There is a credible reason to investigate a larger bucket, but counting Bedivere, Dagonet, Palomides, Dinadan, Nimue, and Collum as characters does not prove that all meet the schema's viewpoint criterion.

**Genuinely inconclusive. Retain `few`, confidence 0.5.** This is a priority for a reader with the full text: list each focalizer's chapter appearances and distinguish narrated backstory from a change of narrative perspective. I do not propose several or ensemble without that evidence.

### 16. The Bright Sword — humor_level

**Current:** `moderate`, confidence **0.5**. Same Grossman work, Hardcover 484946.

[Z. B. Steele's Grimdark review, April 18, 2025](https://www.grimdarkmagazine.com/review-the-bright-sword-by-lev-grossman/) specifically describes extensive banter and gallows humor alongside quests and violence. This provides work-specific evidence of a recurrent comic register rather than the migration's assumption from Grossman's general style. It also describes substantial brutality and loss, so the novel is not being classified as predominantly comedy.

**Confirmed correct. Recommend `moderate`, confidence 0.70.** This is a modest increase based on explicit recurrence, with room for reader disagreement at the light/moderate boundary. The POV-count uncertainty above does not undermine the separate tonal evidence.

### 17. The Deep Sky — drive

**Current:** `balanced`, confidence **0.5**. Yume Kitasei's 2023 novel, Hardcover 584712; Asuka and the Phoenix mission.

[Primmlife's July 18, 2023 review](https://primmlife.com/2023/07/18/review-the-deep-sky-by-yume-kitasei/) discusses both the investigation and character material. [The Bossy Bookworm's August 23, 2023 review](https://www.bossybookworm.com/post/review-of-the-deep-sky-by-yume-kitasei) calls the story primarily character-driven while describing the lethal sabotage investigation, family history, and Asuka's exclusion from the crew. The accounts establish both substantial external action and internal development, but their presence does not itself prove balanced dominance.

**Genuinely inconclusive. Retain `balanced`, confidence 0.5.** Character-driven is a plausible alternative; the research does not justify selecting it or raising confidence in balanced. This finding does not assess the separate person or humor tags.

### 18. Accelerando — humor_level

**Current:** `moderate`, confidence **0.5**. Charles Stross's 2005 fix-up novel, Hardcover 374578; the Macx family through the singularity.

[Jim Mann's review in SIGMA](https://www.cs.cmu.edu/afs/cs/usr/roboman/www/sigma/review/accelerando.html) identifies concrete comic devices: group-mind terminology, a multi-page FAQ for revived historical simulations, and perceptual filtering of unwanted party guests. [Kirkus](https://www.kirkusreviews.com/book-reviews/charles-stross/accelerando/) also identifies wit within the speculative treatment. These examples concern this novel, replacing the batch's admitted assumption from Stross's reputation.

**Confirmed correct. Recommend `moderate`, confidence 0.75.** Several extended and embedded comic devices support more than incidental lightness, while the work retains substantial technical and family narrative. No claim of uniformly heavy comedy is made.

### 19. Annie Bot — humor_level

**Current:** `light`, confidence **0.5**. Sierra Greer's 2024 novel, Hardcover 1061553; Annie and her owner Doug, not the film Companion or another robot story.

[Melisa Ezgi Guleryuz's October 9, 2025 Stanford Daily review](https://stanforddaily.com/2025/10/09/text-and-the-city-in-sierra-greers-annie-bot-patriarchy-enters-the-chat/) explicitly reads the novel as darkly funny satire amid coercion and abuse. That establishes a reader's perception of humor, but not a reliable light-versus-moderate frequency boundary. The review's own comic language cannot be counted as humor in the novel; I have not relied on its purported textual quotations as independently verified primary text. Searches combining Annie Bot with humor, satire, and review did not produce sufficiently precise prevalence evidence.

**Genuinely inconclusive. Retain `light`, confidence 0.5.** A dark subject does not imply no humor, and the word satire does not establish moderate humor. Reader feedback or representative passages beyond the opening would be useful.

### 20. The Echo Wife — humor_level

**Current:** `light`, confidence **0.5**. Sarah Gailey's 2021 novel, Hardcover 427729; Evelyn, Martine, and the cloning/relationship plot.

[Lauren's February 16, 2021 ARC review](https://never-anyone-else.blogspot.com/2021/02/the-echo-wife-by-sarah-gailey-arc-review.html) describes a small amount of dark humor within the thriller. [English Studies, October 17, 2022](https://englishstudens.com/2022/10/17/review-the-echo-wife/) emphasizes the uncomfortable character dynamics. The former makes light plausible, but supplies no concrete comic passage or distribution across the book. Generic claims about Gailey's dry wit, and humor language belonging to reviews of other Gailey novels on archive pages, were not accepted as evidence.

**Genuinely inconclusive. Retain `light`, confidence 0.5.** Some book-specific corroboration exists, but it is not enough to certify the exact level under the high-risk-field evidence standard. This differs from Accelerando's identified comic set pieces.

### 21. Ilium — person (additional self-flagged item)

**Current:** `mixed`, confidence **0.6**. Dan Simmons's 2003 novel, Hardcover 377360; not its sequel Olympos.

The [authorized HarperCollins ebook preview on Everand](https://www.everand.com/book/163584967/Ilium) makes the structural claim directly inspectable: chapter 1, The Plains of Ilium, is Hockenberry's first-person account; chapter 2, Ardis Hills, Ardis Hall, narrates Daeman in third person; the Europa/Mahnmut section likewise uses third-person narration. These are narrative passages, not dialogue pronouns. They independently confirm the Earth and Jovian-moon strands alongside Hockenberry's first-person thread.

**Confirmed correct. Recommend `mixed`, confidence 0.90.** Unlike a generic review labeling a book multi-POV, the preview demonstrates different grammatical persons in the specified threads. The inspected edition is the English HarperCollins ebook, ISBN 9780061794988; the catalog's ISBN is a different edition, and no translation-specific analysis is claimed.

## The nine-book humor cluster

All nine entries are in the **first** September 16 tagging migration, `supabase/migrations/20260916000000_catalog_tagging_batch_20_standalone_sff_books.sql`. Thus “across both batches” accurately describes the task's combined selection but should not imply the nine are spread between the two files. They also appear at 0.5 in the hosted confidence read.

| Book | Recorded migration rationale (paraphrased) | SQL line |
|---|---|---:|
| Accelerando | Assumed author register; no scene verification | 86 |
| Annie Bot | Consulted review did not establish humor | 225 |
| Aurora | Uncertain whether literal computational narration reads as dry humor | 297 |
| Embassytown | Assumed author irony; no scene verification | 437 |
| Hell Followed with Us | Recalled banter; not scene-verified | 763 |
| Shroud | Assumed author's usual dry wit | 1042 |
| The Bright Sword | Assumed author's usual wit | 1260 |
| The Deep Sky | Not established by research | 1412 |
| The Echo Wife | Assumed author's usual dry wit | 1495 |

**Finding: a common 0.5 uncertainty bucket, with real but heterogeneous per-book reasons.** Five of nine explicitly rely on author-style assumptions; others record missing evidence, memory, or interpretation. This is not nine independently demonstrated, equally calibrated uncertainties. It is also not an undocumented blanket default: the migration preserves specific reasons, especially Aurora's tonal ambiguity. The uniform number alone would not prove a process problem; the comments make this inference supportable.

Within the five assigned humor pairs, new book-specific evidence supports confidence increases for Shroud, The Bright Sword, and Accelerando, while Annie Bot and The Echo Wife remain unresolved at the exact level boundary. The other four cluster titles were examined for provenance, not subjected to an unrequested full tag review. No blanket confidence increase is proposed.

## Execution record, evidence, and handoff

Actual sync command: `git pull --ff-only`. The initial sandbox attempt failed to open `.git/FETCH_HEAD`; the same approved command was rerun with escalation and succeeded. Relevant actual output:

```text
From https://github.com/M4kuWo/bookspell
   ef91ed2..c41933e  main -> origin/main
Updating ef91ed2..c41933e
Fast-forward
6 files changed, 1759 insertions(+), 174 deletions(-)
```

`git rev-parse HEAD` returned:

```text
c41933e6b6a7e1c2f345b93d225f8c43552c12f4
```

Hosted collection scripts were executed as `python3 /private/tmp/codx-task9/read_hosted.py` and `python3 /private/tmp/codx-task9/read_identity.py` (outputs retained in hosted.txt and identities.txt). Initial network access in the sandbox failed DNS resolution; the reads succeeded with network escalation. The read_hosted script was corrected to paginate after discovering the 1,000-row server cap, and the retained JSON is the final paginated read. Both scripts use urllib's default GET, never issue a database write, and do not read private database credentials. The initial Hardcover disambiguation fetch returned HTTP 403; it was not bypassed.

The accompanying directory `2026-09-17-highrisk-confidence-qa-pass-evidence/` contains the exact read scripts, final hosted.json, identities.json, and command output. These are public catalog records, not user data. JSON includes request parameters, row counts, source metadata, and the UTC fetch time. Local raw-source files are not a substitute for the linked research; source pages may change and no full external articles are reproduced here.

Web research was conducted through the web tool, not a shell browser command. Queries paired exact title and author with the actual claim: POV count/perspectives, first person/omniscient, unreliable narrator, romance/character-driven, and humor/satire. Sources and rejected inference types are recorded per finding. Important access failures: direct Hardcover fetch 403; Pushing Ice/Fantasy Literature 403; attempted Congo and Dreamcatcher BookRags styles pages unavailable; some Bright Sword review/interview pages could not be fetched. No conclusion depends on pretending those pages were fully read.

No canonical scoring suite was run: this is a research proposal with no scoring or catalog changes. The suite would not validate literary claims. No code needs restoration because no tracked source was edited. Existing untracked reports were preserved. Final tracked-tree verification and evidence checks appear below.

CLDO can review each proposed change separately. Before applying any accepted recommendation, re-read the current UUID/value/confidence and check it still equals this snapshot. This report deliberately provides no executable migration. Do not promote an inconclusive finding or treat all recommended confidence increases as equally strong.

## Making the next round more efficient

1. Include UUID, Hardcover work ID, ISBN, current value, confidence, and the original confidence-note comment in the assignment export. This avoids title punctuation joins and quickly distinguishes missing evidence from genuine ambiguity.
2. Retain a source URL plus chapter/section and a one-sentence mechanical observation for each high-risk claim. A title/author query result or an author's reputation is insufficient provenance.
3. Separate quick structural checks from full-text census tasks. Ilium's persons can be verified from an authorized preview; Pushing Ice and The Bright Sword POV counts need recurring-viewpoint maps. Marking the latter inconclusive is more useful than repeatedly searching broad reviews.
4. Record why confidence is low: no source, conflicting sources, identity uncertainty, or a fuzzy category boundary. Keep the numerical confidence, but avoid treating every 0.5 as the same evidence state.
5. For subjective humor/drive, request specific passages or reader observations about recurrence and narrative dominance. Preserve inconclusive values until the new evidence actually distinguishes adjacent categories. Romance tone and worldbuilding delivery remain outside this review.

## Final verification

```text
Report pair sections: 21 / 21
Summary current values/confidences match live snapshot: 21 / 21
git diff --exit-code: exit 0; no output
git diff --cached --exit-code: exit 0; no output
SHA-256 tracked file comparison to HEAD: 330 files, 0 mismatches
```

All tracked blob contents were compared against HEAD with SHA-256, not only the two scoring files. Only untracked report/evidence artifacts were added. Evidence file hashes are in the companion directory’s `SHA256SUMS`. No commit, push, migration execution, or hosted write occurred.
