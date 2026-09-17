# Task 10 — HIGH_RISK_FIELDS confidence QA, round 2

Prepared by CODX, 2026-09-17 (Asia/Jerusalem). **Proposal only for CLDO. Contains plot spoilers.**

## Outcome and scope

Reviewed all **20 assigned pairs across 14 works**: **3 likely wrong, 6 confirmed correct with proposed confidence increases, 7 genuinely inconclusive, and 4 schema/format mismatches**. The latter two categories retain both current value and confidence. No database values, migrations, scoring code, or tracked files were changed.

The three proposed corrections are:

- **Translation State / person:** `third_limited` → `mixed`, confidence **0.95**. Independent reviews explicitly distinguish Qven's first-person chapters from Enae's and Reet's third-person chapters.
- **Dance of Thieves / magic_system_hardness:** `na` → `soft`, confidence **0.80**. Book-specific accounts identify the Gift, visions, and warnings from the dead; this is neither pure SF nor an absence of magic.
- **How to Become the Dark Lord and Die Trying / romance_heat_intensity:** `moderate` → `closed_door`, confidence **0.75**. Two reviews explicitly report fade-to-black sexual encounters. Frequent sexual language does not establish on-page sex intensity. This is the most boundary-sensitive correction and needs scene-level confirmation before application.

Baseline after sync: `3621ecb` (full hash in evidence/execution.txt). The task brief's embedded `c983c71` reference is older than the pulled tip; the current task is nevertheless clearly Task 10, ready to start. Task 9's completed report was consulted for method and efficiency improvements.

## Method and limits

The initial hosted read preceded literary research. The script used only HTTP GETs with the public anon key from `app/shared.js`; no `.env`, Postgres connection, linked Supabase CLI, or user data was used. It paginated public books as 1,000 + 256 rows, matched each exact title **and author** uniquely, then fetched the 14 selected DNA rows and their 62 confidence records. All 20 assigned confidences matched hosted. The snapshot includes UUIDs, Hardcover work IDs, ISBNs, publication years, synopses, exact current values, confidence sources, query parameters, and UTC time.

Read the shared conventions, task and persona workflow, relevant schema and backlog guidance, project-log history, and Task 9 report. Applied the identity and high-risk evidence standards from [tag-catalog-batch/SKILL.md](../../.claude/skills/tag-catalog-batch/SKILL.md) to a review; did not invoke its tagging or write workflow.

Research prioritised author/publisher material, accessible excerpts, and reviews that discuss the actual mechanical claim. Reviews and fan discussions are identified as such, not relabelled primary text. No whole-book reading or exhaustive scene census is claimed. Confidence proposals are judgments of evidence strength, not calibrated statistical probabilities. Inconclusive does **not** mean verified correct.

The machine-readable schema is decisive: `pov_count` counts recurring, significant viewpoints (single=1, dual=2, few=3–4, several=5–7, ensemble=8+); `mixed` means different grammatical persons, not merely different pronouns or characters. The human-readable schema's introductory POV table still lists the obsolete single/multiple vocabulary, so it was not used for bucket definitions. `narrator_reliability: ambiguous` requires deliberate textual uncertainty about the account, not merely supernatural events, unreliable characters, or uncertainty on the tagger's part.

Magic hardness reflects rules explained in **this work**, not the parent series' reputation. `none` means fantasy without magic; `na` means the concept does not apply, such as pure SF. Closure concerns completion of this book's plot, not membership in a series. Stakes concern the breadth of what is threatened: `regional` can cover a city/kingdom/planet, while `global` includes an entire civilisation; `cosmic` requires more than a large space setting. The presence of a dimension-travel mechanism alone does not establish cosmic stakes.

### Identity assurance

The following is the **stored catalog identity**, not a claim that every external numeric Hardcover ID or translated ISBN has been independently authenticated against Hardcover's API. Sources were matched to the work using author, characters, premise, and publication context; exact edition-level validation remains a limitation. Several ISBNs represent translations/audio editions. In particular, the research on Cursed Bunny uses Anton Hur's English translation and the Quidditch sample is a 2017 English edition; neither is a reading of the stored translated edition. No title-only joins were used.

| Hosted title | Author | Hardcover ID | Stored ISBN | Stored year |
|---|---|---:|---|---:|
| Book of Night | Holly Black | 455632 | 1250863678 | 2022 |
| City of Last Chances | Adrian Tchaikovsky | 552134 | 1801108439 | 2022 |
| Cursed Bunny | Bora Chung | 1617146 | 8556521991 | 2017 |
| Dance of Thieves | Mary E. Pearson | 428642 | 1250159024 | 2018 |
| How to Become the Dark Lord and Die Trying | Django Wexler | 1086192 | 1405561912 | 2023 |
| Quidditch Through the Ages | J.K. Rowling, Kennilworthy Whisp | 213743 | 4863893809 | 2001 |
| Translation State | Ann Leckie | 643090 | 154916483X | 2023 |
| A House With Good Bones | T. Kingfisher | 512318 | 125082981X | 2023 |
| Allomancer Jak and the Pits of Eltania | Brandon Sanderson | 427892 | — | 2014 |
| Auberon | James S. A. Corey | 430999 | 1549170090 | 2019 |
| Belladonna | Adalyn Grace | 470922 | 6171709093 | 2022 |
| Emergency Skin | N. K. Jemisin | 427937 | 1542093570 | 2019 |
| Evershore | Brandon Sanderson, Janci Patterson | 434359 | 1399602225 | 2021 |
| Exile | R. A. Salvatore | 446224 | 0786931264 | 1990 |

**Auberon** is Corey's 2019 Expanse novella about Governor Rittenaur and Erich, confirmed by [Hachette Australia's work page](https://www.hachette.com.au/james-s-a-corey/auberon-an-expanse-novella). **Evershore** is Sanderson and Patterson's 2021 Skyward Flight novella about Jorgen, Alanik, and the Kitsen, confirmed by [Sanderson's Skyward Flight page, Book 3](https://www.brandonsanderson.com/pages/skyward-flight). They are unrelated works. **Exile** is Salvatore's Drizzt novel, not Ender in Exile, a similarly titled romance, or the graphic adaptation. **Allomancer Jak** means Episodes 28–30, not every Jak broadsheet or all of Arcanum Unbounded.

Incidental metadata flag: the hosted year for How to Become the Dark Lord and Die Trying is 2023, while the researched release/review context is 2024. No metadata correction is proposed without a separate edition check.

## Recommendations at a glance

| # | Book / field | Current value / confidence | Finding | Proposed value / confidence |
|---:|---|---|---|---|
| 1 | Book of Night / narrative_closure | `requires_series` / 0.3 | Confirmed correct | `requires_series` / 0.75 |
| 2 | City of Last Chances / narrative_closure | `self_contained` / 0.3 | Confirmed correct | `self_contained` / 0.85 |
| 3 | Cursed Bunny / drive | `character_driven` / 0.3 | Schema/format mismatch | unchanged |
| 4 | Cursed Bunny / pov_count | `single` / 0.3 | Schema/format mismatch | unchanged |
| 5 | Cursed Bunny / magic_system_hardness | `soft` / 0.3 | Genuinely inconclusive | unchanged |
| 6 | Dance of Thieves / magic_system_hardness | `na` / 0.3 | Likely wrong | `soft` / 0.80 |
| 7 | How to Become the Dark Lord and Die Trying / romance_heat_intensity | `moderate` / 0.3 | Likely wrong | `closed_door` / 0.75 |
| 8 | Quidditch Through the Ages / person | `third_omniscient` / 0.3 | Schema/format mismatch | unchanged |
| 9 | Translation State / person | `third_limited` / 0.3 | Likely wrong | `mixed` / 0.95 |
| 10 | A House With Good Bones / magic_system_hardness | `soft` / 0.4 | Confirmed correct | `soft` / 0.65 |
| 11 | Allomancer Jak and the Pits of Eltania / magic_system_hardness | `hard` / 0.4 | Genuinely inconclusive | unchanged |
| 12 | Auberon / narrator_reliability | `reliable` / 0.4 | Genuinely inconclusive | unchanged |
| 13 | Auberon / person | `third_limited` / 0.4 | Genuinely inconclusive | unchanged |
| 14 | Belladonna / drive | `balanced` / 0.4 | Genuinely inconclusive | unchanged |
| 15 | Book of Night / magic_system_hardness | `soft` / 0.4 | Confirmed correct | `soft` / 0.70 |
| 16 | Cursed Bunny / narrator_reliability | `ambiguous` / 0.4 | Schema/format mismatch | unchanged |
| 17 | Emergency Skin / stakes_scope | `global` / 0.4 | Genuinely inconclusive | unchanged |
| 18 | Evershore / narrator_reliability | `reliable` / 0.4 | Genuinely inconclusive | unchanged |
| 19 | Evershore / stakes_scope | `global` / 0.4 | Confirmed correct | `global` / 0.75 |
| 20 | Exile / stakes_scope | `intimate` / 0.4 | Confirmed correct | `intimate` / 0.80 |

## Individual findings

### 1. Book of Night — narrative_closure

**Current: `requires_series` / 0.3. Confirmed correct; retain value, raise confidence to 0.75.**

[Charami's September 2022 review](https://charami.com/2022/09/05/fairyloot-adult-3-book-of-night/) explicitly disputes the initial standalone presentation and describes the ending as leaving a consequential unresolved question. [Haley's Book Haven](https://www.haleysbookhaven.com/post/the-book-of-night-by-holly-black-book-review) also describes the final turn as requiring continuation. These agree with the specific unresolved relationship identified in [this contemporary spoiler discussion](https://www.reddit.com/r/YAlit/comments/vfbcg8/): Vince is bound to Charlie but loses recognition of their relationship.

This is not based solely on a sequel existing or a reviewer using “cliffhanger.” The external confrontation is substantially resolved; the central relationship is not. That distinction keeps the confidence below the stronger City finding. CLDO should confirm the final binding scene and its significance to the book's central arc.

### 2. City of Last Chances — narrative_closure

**Current: `self_contained` / 0.3. Confirmed correct; retain value, raise confidence to 0.85.**

[Foreword Reviews, Ho Lin](https://www.forewordreviews.com/reviews/city-of-last-chances/) explicitly calls the story self-contained while allowing future stories in the setting. [Grimdark Magazine, James Tivendale](https://www.grimdarkmagazine.com/review-city-of-last-chances-by-adrian-tchaikovsky/) independently says the ending wraps up rewardingly. These are assessments of the completed book, not merely pre-publication marketing. Its Tyrant Philosophers membership does not override that evidence. Foreword's prose contains a title typo (“Lost”); its heading, author, ISBN and Ilmar plot identify the correct work.

### 3. Cursed Bunny — drive

**Current: `character_driven` / 0.3. Schema/format mismatch; leave unchanged.**

The [Booker reading guide](https://thebookerprizes.com/sites/default/files/2022-04/cursed-bunny-reading-guide.pdf) establishes a collection crossing speculative modes. [Jonathan Thornton's review](https://archive.gnofhorror.com/fiction-reviews/cursed-bunny-by-bora-chung-translated-by-anton-hur-2021-book-review-by-jonathan-thornton.html) distinguishes revenge fables, a debt-bound domestic story, a ghost relationship, and an engineer's robots. This is not one character arc competing with one plot arc. Social critique is not itself evidence of `character_driven`.

The present vocabulary has no explicit collection aggregation rule for drive. Neither `balanced` as a miscellaneous bucket nor `worldbuilding_driven` as a proxy for conceptual fiction solves that. A reader could reasonably judge the dominant experience after reading all stories, but that aggregation choice needs to be documented first.

### 4. Cursed Bunny — pov_count

**Current: `single` / 0.3. Schema/format mismatch; leave unchanged.**

The [publisher's description](https://www.hachettebookgroup.com/titles/bora-chung/cursed-bunny/9781643753607/) identifies separate story protagonists, rather than one protagonist recurring throughout. `single` could mean a typical story's focalisation, but it does not straightforwardly describe the entire collection. Equally, ten stories do not automatically mean ten recurring POVs or `ensemble`: the schema's measure concerns simultaneous/recurring narrative threads, not a count of disconnected protagonists.

Do not change to `ensemble` by counting the table of contents. The unresolved decision is whether this field should describe within-story viewpoint complexity, a dominant story pattern, or something else for collections.

### 5. Cursed Bunny — magic_system_hardness

**Current: `soft` / 0.3. Genuinely inconclusive; leave unchanged.**

Unlike POV count, hardness can plausibly describe the recurring reading experience of separate fantastic stories. The [Booker guide](https://thebookerprizes.com/sites/default/files/2022-04/cursed-bunny-reading-guide.pdf) supports magical-realistic/surreal treatment, but [Thornton](https://archive.gnofhorror.com/fiction-reviews/cursed-bunny-by-bora-chung-translated-by-anton-hur-2021-book-review-by-jonathan-thornton.html) also identifies a technological robot story alongside curses and fairy-tale transformations. A surreal label alone does not establish how much each story explains its supernatural causality.

`soft` remains plausible for the fantastic pieces; I did not obtain a story-by-story rules inventory sufficient to raise it. Do not change the whole collection to `na` because one story is SF, or to `hard` because an individual curse has a stated condition. This is related to the format issue but retains a potentially meaningful axis, hence inconclusive rather than a fourth automatic Cursed Bunny mismatch.

### 6. Dance of Thieves — magic_system_hardness

**Current: `na` / 0.3. Likely wrong; propose `soft` / 0.80.**

[Keri's 2018 review](https://areyoumybook.wordpress.com/2018/08/05/arc-review-dance-of-thieves/) explicitly identifies the Gift as subtle background magic and describes Kazi's distinct experience of it within this book. [Elian Quill's reading notes](https://scribbleandrewrite.wordpress.com/2026/05/15/daily-notes-from-dance-of-thieves-by-mary-e-pearson/), “Day 4: Magic” and “Day 6: Magic (again),” independently identify Kazi's encounters with the dead, Synové's dreams and a seer; the reviewer notes uncertainty about their mechanism.

This evidence answers both presence and presentation: actual book-specific supernatural perception, without a clearly explained predictive system. A Goodreads discussion saying there is no magic was contradicted by these more specific accounts. `none` would therefore be an overcorrection. The classification does not import the prior Remnant Chronicles trilogy's full magic knowledge.

### 7. How to Become the Dark Lord and Die Trying — romance_heat_intensity

**Current: `moderate` / 0.3. Likely wrong; propose `closed_door` / 0.75, subject to CLDO checking representative scenes.**

[Garik16's April 2024 review](https://garik16.blogspot.com/2024/04/scififantasy-book-review-how-to-become.html) explicitly distinguishes Davi's sexual preoccupation and language from sex scenes that cut away. [Shannon Fallon's December 2025 review](https://shannonfallon.com/2025/12/13/should-you-read-how-to-become-the-dark-lord-and-die-trying-by-django-wexler/) independently reports fade-to-black encounters, while noting details before or after the fade.

That is substantially stronger evidence about intensity than marketing it as raunchy. `closed_door` is the best fit for the reported scene treatment; it does not mean no sexual language, no nudity, or suitable for children. The residual uncertainty is precisely the explicitness of the framing details and how the project's `low`/`moderate` boundaries treat them. Do not change frequency or content-warning tags based on this proposal. No full-text maximum-explicitness census was performed.

### 8. Quidditch Through the Ages — person

**Current: `third_omniscient` / 0.3. Schema/format mismatch; leave unchanged.**

[Bloomsbury's book page](https://www.bloomsbury.com/uk/quidditch-through-the-ages-9781526603029/) identifies a fictional sporting history/rulebook. The [Bloomsbury sample hosted by retailer Public](https://media.public.gr/Books-PDF/9781408883082-1219087.pdf) supplies direct evidence: Dumbledore's foreword uses first-person framing (PDF pages 11–14), while the first chapter uses historical exposition and an inclusive wizarding “we” (pages 16–19). It is not an omniscient narrator accessing a novel's characters' minds.

A simple `mixed` correction would also be misleading: forewords, quoted sources, and an essayist's inclusive voice are not necessarily the separate grammatical-person narrative threads the enum describes. The original 2026-09-13 log already flagged this exact format mismatch. Whisp is a fictional author persona, not a newly discovered real co-author; no author-field edit is proposed.

### 9. Translation State — person

**Current: `third_limited` / 0.3. Likely wrong; propose `mixed` / 0.95.**

[Dear Author, Janine](https://dearauthor.com/book-reviews/overall-b-reviews/b-plus-reviews/review-translation-state-by-ann-leckie/) explicitly identifies first-person Qven chapters and third-person Enae/Reet chapters. [The Frumious Consortium](https://www.thefrumiousconsortium.net/2025/09/01/translation-state-by-ann-leckie/) independently identifies Qven as the sole first-person thread and supplies a short illustrative passage. This is the actual `mixed` definition, not an inference from the cast's different gender pronouns.

The [author's excerpt announcement](https://annleckie.com/2023/01/09/translation-state-cover-reveal-and-excerpt-at-io9/) also leads to an authorised opening chapter; it supports Enae's third-person narration but is not claimed to cover all threads. The whole-book distinction above is independently reviewed rather than a complete primary-text audit.

### 10. A House With Good Bones — magic_system_hardness

**Current: `soft` / 0.4. Confirmed correct; retain value, raise confidence cautiously to 0.65.**

[Joplin Public Library, Alyssa Berry](https://www.joplinpubliclibrary.org/a-house-with-good-bones-by-t-kingfisher/) describes the protagonist encountering ancestral sorcery and a haunting while rejecting supernatural explanations until late. [The Gothic Library](https://www.thegothiclibrary.com/review-of-a-house-with-good-bones-bugs-blooms-and-boogeymen/) identifies the roses and underground children as manifestations of weird horror. [Susan Peak's BSFA review](https://www.bsfa.co.uk/BSFA-Review-A-House-with-Good-Bones-by-T-Kingfisher/) describes the climax as drawing on previously unsuspected capacities.

My inference is that this book presents supernatural power principally through unsettling discovery, rather than a reader-understood rule system. This is not simply “horror means soft,” and it is not a claim that no magical constraints exist. Because the sources are reviews rather than a direct inventory of the concluding explanations, this is the weakest proposed confidence increase. CLDO may reasonably retain 0.4 pending a closer text check.

### 11. Allomancer Jak and the Pits of Eltania — magic_system_hardness

**Current: `hard` / 0.4. Genuinely inconclusive; leave unchanged.**

[Sanderson's original announcement](https://www.brandonsanderson.com/blogs/blog/mistborn-adventure-game-alloy-of-law-supplement-new-allomancer-jak-story-giveaway) identifies the specific story and Handerwym's annotations. [PalmKD's review](https://palmkd.wordpress.com/2022/11/09/novella-review-allomancer-jak-and-the-pits-of-eltania-by-brandon-sanderson/) explains how those annotations correct Jak's exaggerated account. A [17th Shard discussion](https://www.17thshard.com/forums/topic/87295-allomancer-jak-is-a-feruchemist/) explicitly mentions tin supplying enhanced senses in this story, but its main argument is speculative and draws on wider Cosmere knowledge.

The tin detail supports a rule-bound mechanism, but does not alone settle whether this short, deliberately unreliable account explains enough for `hard` without other Mistborn books. The old author preview link now redirects to a collections page; I did not recover a usable authorised excerpt. The fan theory is not adopted. A focused read of the opening resource constraints, Handerwym's corrections, and the koloss-spike explanation would resolve the remaining question much more directly than another general Mistborn search.

### 12. Auberon — narrator_reliability

**Current: `reliable` / 0.4. Genuinely inconclusive; leave unchanged.**

The [publisher](https://www.hachette.com.au/james-s-a-corey/auberon-an-expanse-novella) and [Julia's novella review](https://pagesofjulia.com/2020/12/11/auberon-by-james-s-a-corey-audio/) establish a conflict involving political ideals, coercion, and private vulnerabilities. Neither provides a specific audit of narrative reliability. Characters lying or compromising their principles is not evidence that the narrator misreports events; equally, a synopsis containing no mention of unreliability cannot certify `reliable`.

No primary-text sample spanning the narrative's revelations was obtained. Do not borrow the narration of The Churn, The Vital Abyss, or the main Expanse novels to fill this gap.

### 13. Auberon — person

**Current: `third_limited` / 0.4. Genuinely inconclusive; leave unchanged.**

[Julia](https://pagesofjulia.com/2020/12/11/auberon-by-james-s-a-corey-audio/) discusses scenes involving Erich and the Rittenaurs, and [Eric Mesa](https://www.ericsbinaryworld.com/2021/09/19/review-auberon/) identifies the governor as the central subject. These are useful identity and focus checks, but do not establish limited versus omniscient focalisation. The available publisher page exposes an audio sample control; no listening or transcription of it is claimed here.

A reliable determination needs passages on both sides of scene/POV transitions, not a count of major characters. No new confidence is warranted from the available evidence.

### 14. Belladonna — drive

**Current: `balanced` / 0.4. Genuinely inconclusive; leave unchanged.**

[Melissa Ng's review](https://thereadingnook.com.au/belladonna-adalyn-grace-review/) describes a substantial murder investigation, Signa's personal development, and romance with Death. [Fantasy Romance's review](https://fantasy-romance.com/adalyn-grace-belladonna-review/) goes further, describing the murder mystery as occupying most of the plot. That is a reason to consider `plot_driven`, rather than blindly confirm `balanced`. However, one review's plot emphasis does not settle the balance of investigation and individual character arc. “Romantasy” is not itself proof that the relationship is the plot.

`balanced` remains plausible, but it should not become a confident compromise merely because the sources discuss several ingredients. A useful follow-up would trace which problem motivates the major decisions and resolves in the climax. No romance-tone assessment is made.

### 15. Book of Night — magic_system_hardness

**Current: `soft` / 0.4. Confirmed correct; retain value, raise confidence to 0.70.**

[Haley's review](https://www.haleysbookhaven.com/post/the-book-of-night-by-holly-black-book-review), under Narrative Style/Pacing and Final Thoughts, specifically says gloaming's rules need to be made more concrete. [Charami](https://charami.com/2022/09/05/fairyloot-adult-3-book-of-night/) independently describes unexplained mechanics. These address what the reader understands in Book 1, rather than simply how novel or complex the system is.

The book has named techniques, research, and magical documents, as [Kirkus](https://www.kirkusreviews.com/book-reviews/holly-black/book-of-night-black/) explains; their existence does not guarantee a reader-predictable system. `soft` is therefore supported under the per-book definition, with a moderate confidence increase. Do not infer anything about later instalments.

### 16. Cursed Bunny — narrator_reliability

**Current: `ambiguous` / 0.4. Schema/format mismatch; leave unchanged.**

[Hopscotch Translation's analysis](https://hopscotchtranslation.com/2022/12/05/cursed-bunny-review/) distinguishes the perspectives of separate stories, including the engineer/companion reversal in Goodbye, My Love and the ghost-mediated relationship in Reunion. A collection with distinct narrators cannot be assigned one narrative-reliability verdict simply because its events are bizarre or its endings overturn expectations.

`ambiguous` is not the schema's uncertainty bucket. Establishing it would require evidence that the individual accounts deliberately remain unjudgeable, plus a rule for aggregating that finding across stories. I found no adequate basis for replacing it wholesale with either reliable or unreliable. Retaining the low-confidence record is the honest interim action, not endorsement of its semantics.

### 17. Emergency Skin — stakes_scope

**Current: `global` / 0.4. Genuinely inconclusive; leave unchanged.**

[Kirkus/AudioFile's review](https://www.kirkusreviews.com/audiobook-reviews/nk-jemisin/emergency-skin/) describes a single traveller discovering that Earth contradicts the controlling AI's account. [Katethulu's detailed synopsis](https://katethulumysterycave.com/2020/07/25/short-story-saturday-emergency-skin/) distinguishes that personal awakening from the decision at the end to return and foment a revolution.

The story has civilisation-scale implications, but Earth's earlier ecological recovery is background, and the planned revolution is not an extended on-page conflict. The unresolved boundary is how much the ending's prospective social transformation counts toward “what is at risk” in this specific story. `global` is plausible, but counting the setting's planets or the importance of its themes would not verify it. No automatic downgrade to intimate/regional is proposed.

### 18. Evershore — narrator_reliability

**Current: `reliable` / 0.4. Genuinely inconclusive; leave unchanged.**

[Sanderson's Book 3 description](https://www.brandonsanderson.com/pages/skyward-flight) establishes Jorgen as the viewpoint and makes uncertainty about the Kitsen and his developing powers explicit. [Raph's novella review](https://raphscozymusings.com/2023/05/08/novella-review-evershore-skyward-flight-novella-3-by-brandon-sanderson-and-janci-patterson/) discusses his personal development. Neither shows that the narrative account is misleading, but neither explicitly establishes its reliability through the whole novella.

Grief, self-doubt, and incomplete understanding of cytonics are not sufficient for either `unreliable` or `ambiguous`. Retain the tag pending direct comparison of Jorgen's claims and later textual corrections. This conclusion uses Evershore, not Spensa's separate experience in Cytonic.

### 19. Evershore — stakes_scope

**Current: `global` / 0.4. Confirmed correct; retain value, raise confidence to 0.75.**

The [author's Book 3 description](https://www.brandonsanderson.com/pages/skyward-flight) ties the mission to rebuilding Detritus's position and forming an alliance against the Superiority. The [contemporary Evershore full-reactions discussion](https://www.17thshard.com/forums/topic/102665-evershore-full-reactions/), especially robardin's December 30, 2021 comment, identifies the deployment of Detritus and its defences in support of another planet. This is an actual collective-defence conflict in this novella, not just a large setting borrowed from the main series.

The stakes extend beyond rescuing individual captives to the survival/security of the affected societies and their alliance. That supports the civilisation-scale `global` bucket. The use of cytonic travel does not by itself make the threat `cosmic`. The detailed climax evidence is a reader discussion, so the confidence remains below a primary-text confirmation.

### 20. Exile — stakes_scope

**Current: `intimate` / 0.4. Confirmed correct; retain value, raise confidence to 0.80.**

[Penguin Random House's work description](https://www.penguinrandomhouse.com/books/752217/exile-dungeons-and-dragons-by-ra-salvatore/) makes Drizzt's survival, search for a home, and pursuit by his own family the central conflict. [This book-specific review](https://topbottomleftright.wordpress.com/2011/02/04/exile-by-r-a-salvatore-a-review/) corroborates the intensely personal Drizzt/Zaknafein conflict and the new companions.

Deadly combat and travel through the Underdark do not enlarge the stakes to civilisation-wide danger. The personal and small-group focus supports `intimate`; this does not mean safe, cozy, or low personal stakes. The cited publisher edition is a later prose reissue of the same novel, not its comic adaptation.

## Cluster investigation and decisions for CLDO

**Cursed Bunny is an already-recognised structural problem, not four freshly discovered missing facts.** The September 17 round-4 project-log entry explicitly says its anthology structure did not map cleanly to several scalar fields and records deliberate best guesses at low confidence. The migration preserves those values without per-field explanatory comments. This review independently supports that diagnosis for drive, POV count and reliability. Hardness has a potentially useful collection-level interpretation but still lacks sufficient evidence here. No new tags, nulling operation, collection exclusion, or scoring adjustment is proposed. Being in catalog scope and fitting every existing field are different questions; this finding does not reopen the decision that short-story collections belong in the catalog.

**Quidditch was already flagged on September 13.** The excerpt makes its reference-book form directly observable. The unresolved issue is how to express applicability, not whether another web search will discover a hidden novelistic POV. Do not use a confidence increase to erase that uncertainty.

**Book of Night, Auberon, Evershore:** no analogous collection/reference-format problem found. Book of Night's two fields are independent questions about closure and explanation of magic. Auberon's two findings remain constrained by missing focalisation/reliability evidence. Evershore's stakes can be assessed from its collective conflict while its narrator reliability remains unverified. Successful identity checks do not imply successful verification of every tag.

For a future task, include UUID, Hardcover ID, ISBN, current value, confidence, original migration, and a short reason code for low confidence. This batch added author/field/confidence but still needed the other joins. Persist `format/applicability unresolved` separately in the task queue so these rows do not repeatedly consume a research-only pass. A small source record with URL, chapter/section, mechanical observation, and whether evidence is primary text or review would make re-verification cheaper. These are workflow proposals, not a new scoring design.

## Execution record

Initial `git status --short` showed only pre-existing untracked output:

```text
?? docs/codx-recommend-review-2026-09-14.md
?? docs/codx-reports/
```

`git config --get core.hooksPath` returned `.githooks`; the tracked pre-push hook ends in unconditional `exit 1`. It was inspected, not tested by attempting a push.

The initial `git pull --ff-only` failed in the sandbox with `cannot open '.git/FETCH_HEAD': Operation not permitted`. The same command succeeded with escalation:

```text
From https://github.com/M4kuWo/bookspell
   94e0c4b..3621ecb  main -> origin/main
Updating 94e0c4b..3621ecb
Fast-forward
15 files changed, 2118 insertions(+), 116 deletions(-)
```

Hosted collection command:

```sh
python3 docs/codx-reports/2026-09-17-highrisk-confidence-qa-round2-evidence/read_hosted.py
```

First attempt failed sandbox DNS resolution. The escalated attempt then returned HTTP 400 because I had used incorrect bibliographic column names (`published_year`, `description`). Comparing the existing Task 9 identity snapshot exposed the correct names (`publication_year`, `synopsis`); after correcting the script, the escalated run succeeded. The retained script and JSON are that successful version. This was a read-query error; no database mutation was attempted.

Successful request row counts:

```text
books offset 0: 1000
books offset 1000: 256
book_dna scoped to 14 IDs: 14
book_field_confidence scoped to 14 IDs: 62
assigned pairs matching current confidence: 20 / 20
unique title + author identities: 14 / 14
```

The companion directory retains `read_hosted.py`, `hosted.json`, a readable rendering in `hosted.txt`, and final verification output. `hosted.txt` is rendered from the saved successful JSON, not misrepresented as a shell transcript. The successful command's rows and queries were also visible in tool output. The original snapshot is not overwritten with a later catalog state.

Research ran through the web tool using title/author plus field-specific queries: closure/ending, magic/rules/Gift, sex/fade-to-black, grammatical person/Qven, narrator/reliability, and stakes/collective conflict. The exact accepted source URLs and observations are recorded per finding. Material access limits: Paste's Translation State review could not be opened (other independent reviews used); Coppermind sample/story pages and an attempted Reddit Allomancer discussion open failed; the old Sanderson preview redirects to a collections page; a guessed SuperSummary ending URL failed; several publisher pages expose sample controls without usable text. Search-result snippets were leads, not silently claimed to be full-text reads. No paid access or private account was used.

No local Postgres was used, so the new `check_db_sync.py` prerequisite for relying on local data was not triggered. No scoring suite was run: it cannot validate literary evidence and this task changes no scoring or catalog behavior. No commit, push, or migration execution occurred. Existing untracked reports were preserved.

## Final verification and handoff

```text
HEAD: 3621ecbb412dc42cb931ec25fe6186e54f9f9937
Hosted snapshot UTC: 2026-09-17T09:05:52.490979+00:00
Report pair sections and JSON recommendations: 20 / 20
Section current values/confidences match hosted snapshot: 20 / 20
Assigned confidences match hosted snapshot: 20 / 20
Unique exact title + author identities: 14 / 14
Unchanged inconclusive/mismatch recommendations verified: 11 / 11
Outcome counts: {"Confirmed correct": 6, "Schema/format mismatch": 4, "Genuinely inconclusive": 7, "Likely wrong": 3}
git diff --exit-code: exit 0; no output
git diff --cached --exit-code: exit 0; no output
SHA-256 comparison of tracked files to HEAD: 342 files, 0 mismatches
```

CLDO should independently recheck the cited passages and re-read each exact hosted UUID/value/confidence immediately before applying any accepted proposal. The snapshot is a baseline, not a guarantee against concurrent catalog edits. Review the three corrections individually; do not promote the seven inconclusive or four mismatch findings into confident tags. This report intentionally supplies no executable migration.
