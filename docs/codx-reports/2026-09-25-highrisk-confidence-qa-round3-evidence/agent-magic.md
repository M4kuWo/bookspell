# Independent magic/stakes QA — 2026-09-25

Proposal only. Seven pairs across five hosted identities, checked in `hosted.json` before literary research. Sources below were opened and their full returned page text inspected; search-only and failed-open material is explicitly excluded from dispositive evidence. No database or source changes.

| Book / hosted UUID | Field | Current | Outcome | Proposed |
|---|---|---|---|---|
| Exile / 028af82f-8b73-470d-9acb-19d32a8bd6b1 | magic_system_hardness | hard / .4 | genuinely-inconclusive | hard / .4 |
| Gone / a9933a04-241c-4f9b-9b94-7005fc109aef | stakes_scope | regional / .4 | confirmed-correct | regional / .85 |
| Gone / same | magic_system_hardness | na / .4 | genuinely-inconclusive | na / .4 |
| How to Become the Dark Lord and Die Trying / 402a3d10-2223-4d1d-ad9d-9b8a66c72790 | stakes_scope | regional / .4 | genuinely-inconclusive | regional / .4 |
| How to Become the Dark Lord and Die Trying / same | magic_system_hardness | hard / .4 | genuinely-inconclusive | hard / .4 |
| The Bone Ships / ea458bed-4c26-4888-aae0-cbbbad709fb9 | magic_system_hardness | soft / .4 | genuinely-inconclusive | soft / .4 |
| The Prison Healer / a85cb716-8563-439b-8280-ad64ab4d4a9b | magic_system_hardness | soft / .4 | genuinely-inconclusive | soft / .4 |

## Exile — magic hardness

Opened [Cindy Lynn Speer's SF Site review](https://www.sfsite.com/10b/ex186.htm), a named contemporary review of this actual volume, and [Wikipedia's volume-specific synopsis](https://en.wikipedia.org/wiki/Exile_(Salvatore_novel)). The review establishes resurrection of Zaknafein, mad wizards and mind-flayer enslavement; the synopsis identifies Zin-Carla and the undead father's eventual recovery of control. Neither source establishes how thoroughly this novel teaches the reader magical constraints or predictive rules. The Forgotten Realms/D&D setting is not evidence that this particular novel is hard magic. Conversely, magical resurrection and gods do not prove soft magic. Retain hard/.4 with no confidence increase. Need passages or a detailed volume-specific discussion of spell limits and their explanatory treatment.

## Gone — stakes and magic

Opened [SuperSummary's first-volume guide](https://www.supersummary.com/gone-grant/summary/), explicitly based on the 2008 Katherine Tegen edition, and [Samuel K. Sloan's 2008 review](https://www.dragonpage.com/2008/06/12/gone-a-dragon-page-book-review/). Also inspected only the Gone subsection of [Wikipedia's series page](https://en.wikipedia.org/wiki/Gone_(novel_series)).

The first-volume plot is a town and surrounding territory enclosed by a barrier, with children attempting to preserve food, care and social order; its final conflict defends those inhabitants from Caine's faction. This positively supports regional stakes rather than an inference from setting alone. SuperSummary also reports the Darkness's aspiration to destroy humanity; that is a wider antagonist ambition, whereas this volume's operative conflict and resolution remain the bounded community. Proposed regional/.85.

The same sources describe radiation associations, mutations, superpowers and an initially unexplained Darkness. SuperSummary calls the larger world science fiction/fantasy. This is not enough to prove the book is *pure* SF, as required by na, and unexplained powers alone do not justify reclassifying them as soft fantasy magic. Retain na/.4. A genre label or later-series explanation cannot settle this book's reader experience. Sloan's review has a clear age-threshold error (14 instead of 15), so it is corroboration for the geographical confinement only, not a sole authority. Total paraphrase of the SuperSummary source here is deliberately under its 200-word allowance.

## How to Become the Dark Lord and Die Trying — both fields

Opened [Kirkus's 2024 review](https://www.kirkusreviews.com/book-reviews/django-wexler/how-to-become-the-dark-lord-and-die-trying/), [The Lily Cafe's volume-one ARC review](https://thelilycafe.com/2024/05/30/book-review-how-to-become-the-dark-lord-and-die-trying-by-django-wexler/), and [Shannon Fallon's review](https://shannonfallon.com/2025/12/13/should-you-read-how-to-become-the-dark-lord-and-die-trying-by-django-wexler/).

Kirkus identifies a Kingdom-versus-wilders war and repeatedly destroyed humans; Lily Cafe describes this installment's immediate arc as building a horde and reaching the convocation to become Dark Lord. Kingdom-level regional stakes are plausible, but the extinction-of-humanity framing and the loop's unresolved nature leave a real regional/global boundary ambiguity. The volume-one objective is also narrower than the entire recurring war. Retain regional/.4 rather than promote confidence from the word Kingdom alone.

For hardness, Lily Cafe gives actual mechanism evidence: humans wield thaumite stones while wilders ingest them for abilities. Kirkus establishes a death-triggered reset. Fallon finds the magic understandable and integrated into society/conflict. Those support rule-governed magic, but none of these descriptions supplies enough limitations or predictive detail to establish hard as defined. Lily Cafe also explicitly leaves the reason and mechanism of Davi's recurrence unanswered for the sequel. That mystery need not negate hard thaumite magic, but it prevents a clean confident conclusion from these sources. Retain hard/.4; do not equate easy-to-understand with hard.

## The Bone Ships — magic hardness

Opened [James Latimer's Fantasy Hive ARC review](https://fantasy-hive.co.uk/2019/09/the-bone-ships-by-rj-barker-book-review/) and [Meditations' first-volume review](https://krikson.net/2020/04/review-the-bone-ships-r-j-barker/). The former describes unexplored wonders in this first volume; the latter specifically describes intelligent wind-producing birds central to navigation and war, and complains that characters do not investigate them. This is compatible with soft magic, but hints of unexplored worldbuilding and a reviewer's complaint do not directly establish the reader-facing extent of magical rules. Retain soft/.4.

A promising [Basilisk ARC review](https://www.reddit.com/r/Fantasy/comments/d6tx84) explicitly discussed mysterious principles in search results, but two open attempts failed (cache miss). A StoryGraph review open also failed. Neither is used as verified evidence for a confidence increase. A complete readable version of the Basilisk review or primary excerpt would be useful follow-up.

## The Prison Healer — magic hardness

Opened [Book for Thought's 2021 ARC review](https://book-for-thought.com/2021/03/13/review-prison-healer-lynette-noni/) and [Brylie and Books' review](https://skepticalcoffee.wordpress.com/2021/08/16/review-the-prison-healer-by-lynette-noni/), both explicitly this first book. Book for Thought calls the elemental system clear and easy to follow, and says the later trials become predictable. Brylie calls the magic basic and limited in quantity. This pushes against an automatic assumption of mysterious/soft magic, but simplicity, amount of magic and predictability of plot are distinct from explained constraints and predictable magical solutions. Neither review establishes the decisive rules/limits. Retain soft/.4, not a correction to hard based on those adjectives.

A series-wide Fandom magic entry surfaced but was not used: its cost/bloodline account lacks first-volume attribution and can import sequel knowledge. An unofficial full-text mirror surfaced and was not used.

## Research procedure and limitations

Local command used Python `json.load` on the supplied hosted snapshot and printed only the five requested title/author records. Their identities and series positions match the reviews. Web searches combined title, author and review/magic-system terms, followed by real `open` calls for every source credited above. No primary novel text was read, and no later-volume mechanics were imported. This is a conservative high-risk confidence audit: inconclusive is an evidentiary result, not confirmation of the existing value. Seven pairs accounted for: one confirmed, six genuinely inconclusive, zero proposed corrections, zero schema mismatches.
