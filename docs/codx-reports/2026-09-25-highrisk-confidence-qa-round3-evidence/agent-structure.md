# Structural-field QA evidence — 2026-09-25

Independent research subtask, six pairs. Read identities from `hosted.json` (fetched 2026-09-25T15:23:51Z); all five books match title/author and synopsis. No hosted writes or source edits. Numbers below are proposed confidence, not applied changes. Opened sources are linked individually. Search-result snippets alone are not decisive evidence.

| Book | Field | Current | Outcome | Proposed value/confidence |
|---|---|---|---|---|
| Provenance — Ann Leckie | person | first /.4 | likely-wrong | third_limited /.9 |
| The Eye of the Bedlam Bride — Matt Dinniman | pov_count | dual /.4 | inconclusive | dual /.4 unchanged |
| The Historian — Elizabeth Kostova | magic_system_hardness | soft /.4 | inconclusive | soft /.4 unchanged |
| The Redemption of Time — Baoshu, Ken Liu | stakes_scope | cosmic /.4 | confirmed-correct | cosmic /.95 |
| The Rise and Fall of D.O.D.O. — Neal Stephenson, Nicole Galland | stakes_scope | regional /.4 | likely-wrong | global /.8 |
| The Rise and Fall of D.O.D.O. — Neal Stephenson, Nicole Galland | narrative_closure | requires_series /.4 | confirmed-correct | requires_series /.8 |

## Provenance: person

[Author-attributed first-chapter excerpt at Vice](https://www.vice.com/en/article/read-a-mindbending-excerpt-from-ann-leckies-new-novel-provenance/): narration calls Ingray she and describes her private thoughts while presenting others through her perceptions. This directly contradicts first person.

[Canmom, Hwae and the Genders](https://canmom.art/crit/hwae-and-the-genders-so-far), opened October 2017 criticism, explicitly identifies third-person limited narration through Ingray. This supports the limited/omniscient distinction independently of pronouns. Caveat: critic says they are only one-third through the novel. The primary excerpt aligns. Thus .9 rather than absolute certainty. A StoryGraph full-book review by tsana also identified tight third person in search results, but opening returned an internal error; not necessary to the conclusion and not counted as opened evidence.

## The Eye of the Bedlam Bride: pov_count

[Penguin authorized sample](https://cdn.penguin.co.uk/dam-assets/books/9780241829899/9780241829899-sample.pdf), 83 PDF pages, identifies the title/author and includes Carl's first-person main narrative, plus a Donut-voiced recap newsletter in front matter. It is a 2026 UK edition with an additional 2025 copyright for Backstage at the Pineapple Cabaret; do not presume all supplementary material is in the 2023 catalog edition.

[Book-discussion podcast transcript, episode covering book six through the end](https://www.buzzsprout.com/2258249/episodes/19521607-season-7-episode-12-dcc-book-6-the-eye-of-the-bedlam-bride-pt-2-end), particularly 54:19–56:39, discusses epilogue material involving Agatha, the Homecoming Queen, and Princess Formidable. This establishes that simply seeing Carl's narration in the sample is not enough to assert single, while cast size or Donut's role as co-protagonist does not establish dual. Neither source inventories recurring significant viewpoints throughout the complete original edition. The recap and epilogue distinction matters under the supplied definition. Retain dual/.4 as inconclusive; a full original-edition POV inventory is needed. A SuperSummary chapter page was opened but hides most later summaries; it did not resolve the issue. Automated chapter-summary sites and an apparent unlicensed full-text result were not used as decisive evidence.

## The Historian: magic_system_hardness

[Laura Miller's 2005 Salon review](https://www.salon.com/2005/06/06/kostova/) describes the historians' search for the undead Vlad and gives a concrete supernatural detail: Muslim prayer beads repel vampires just as crucifixes do. It establishes actual supernatural content, so na would be unsuitable. The opened review does not establish the overall predictability or completeness of supernatural rules. A mystery premise is not by itself proof of soft magic; known vampire defenses are not by themselves proof of a hard system. Soft remains plausible, but confidence stays .4. Fantasy Literature's review was found but its open failed with 403; not counted as evidence.

## The Redemption of Time: stakes_scope

[Tor/Macmillan publisher page](https://us.macmillan.com/books/9781250306005/theredemptionoftime/) identifies Baoshu and translator Ken Liu, and explicitly describes Yun's recruitment by The Spirit against an entity threatening the whole universe's existence. This is direct book-specific scope evidence, not inference from space setting or the parent series. Confirm cosmic/.95.

## D.O.D.O.: stakes_scope and narrative_closure

[BookRags public plot summary](https://www.bookrags.com/studyguide-the-rise-and-fall-of-dodo/) describes the agency changing history to reshape international relations, Gráinne infiltrating it to prevent magic's end, then controlling its leadership while protagonists defect. Mel escapes her historical stranding at the end. Therefore an immediate rescue resolves, but Gráinne's central conflict remains.

[The Mary Sue's 2021 sequel review](https://www.themarysue.com/master-of-the-revels/) explicitly describes the first book as threatening world history, calls its ending a cliffhanger, and identifies the unresolved Gráinne threat as the sequel's starting point. These statements concern the first book; later sequel-specific claims about cosmic spells are deliberately excluded from scope evaluation.

Inference: replacing the historical scientific/magical order and altering international civilization exceeds a regional conflict; global/.8 is appropriate. Time travel itself does not establish cosmic stakes, and no first-book universe-destruction evidence was found. Closure requires_series/.8 is supported by the active unresolved antagonist and explicit cliffhanger, not merely the existence of a sequel. Limit: this is secondary plot evidence, not inspection of final chapters in a licensed full text.

## Research and limitation record

Tools: Python read-only selection of five `hosted.json` identity records; `rg` checked that `third_limited` is a schema value; web search followed by explicit opens of each linked source. No tests or database queries were required. Source failures: StoryGraph internal error and Fantasy Literature 403. Some search results contain apparently automated or mismatched summaries; these were not used to raise confidence. All six outcomes above use conservative book-level judgments and avoid audiobook narrator-count inference.
