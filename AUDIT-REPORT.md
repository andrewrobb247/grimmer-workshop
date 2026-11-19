# Workshop audit - 19 November 2026 / 0.1.35

## Fixed

- Latest installed 0.1.34 log showed ZZZ_GrimmerEnemies skipped: its generated ModInfo.xml contained `System.Xml.XmlDocument`. The writer reused an XML-typed input variable for output text. Separate variables now produce real XML. Guppy itself loaded, but Workshop's intended spawn filtering was inactive. The repair applies to new spawns after launching; existing entities are not removed.
- English text companion adds 16 missing Beautiful Bases labels, 21 specific decor descriptions/pointers and two Bdub vehicle descriptions: 39 localization rows. Decoration descriptions explicitly distinguish hydroponic models, hoists and smoking chimneys from working production systems. Author definitions/assets are not edited.
- Launch now parses every Workshop-owned generated XML file and checks mod identity/version before starting. Regression fixture verifies both installed/absent Guppy cases and rejection of the exact malformed-metadata failure.

## Checks passed

| Scope | Result |
| --- | --- |
| Original external pack files | 284 checked; no missing or changed bytes against recorded originals |
| Prospective generated profile XML | 83 XML files parse, including corrected enemy metadata and new text companion |
| Expanded English item text | 435 added/exposed candidates; 395 player-facing entries; zero unresolved English names/descriptions, missing inheritance parents or malformed CSV rows |
| Recipe references | 361 mod/companion recipe declarations: all outputs and ingredients resolve; native generated shape helpers accounted for |
| UI statistics and progression | Used DisplayType/stat title keys resolve; all 643 base practice output IDs resolve |
| Merged config targets | 13 config sets, 882 additions; only two known benign Beautiful Bases church-bell drop-removal misses (drops already absent) |
| Regression suites | 2,627 core; 717 homestead/native/prior-route; 20,482 Guppy; 409 Bdub; 128 Arsenal; 43 decor; storage/queue/recipe/timing/crop/launcher suites pass |
| Generated XML guard | Present/absent Guppy metadata, active filter and deliberately corrupt manifest rejection pass under Windows PowerShell 5.1 |

English resolution includes inherited DescriptionKey/NameKey values and native defaults. Bdub's valid Key,English header is accepted. Internal developer-only entries excluded unless exposed by recipes. This checks key presence and supplied text; it does not establish that every inherited generic description is ideal copy or every translated language is complete.

XML merging models installed load order and the reviewed absent-SMX conditional branch. Original author bundles remain untouched. No native merged game data or external assets are included in the public source archive.

## Live evidence and remaining checks

Installed 0.1.34 startup log: Arsenal, Bdub, decor and Workshop DLL loaded; broken enemy companion was the relevant XML error found. Player confirmed Looted map, wall-decor pickup/replacement, decor Construction practice and visible new zombies. These do not establish animation/combat correctness or intended spawn weighting.

Pending after updating and Play: fresh error-free companion startup, English inspection tabs, crop stage timing, wildlife behaviour/population persistence, weapon models/animations, vehicle driving, longer queue/save checks and launcher layout. See PLAYTEST-CHECKLIST.md. No new world required for these text/metadata repairs. Vehicle inspection remains parked.

## Delivery

Use the existing testing launcher: save/quit, Check for updates, Install update, then Play. Companions regenerate at launch. No new external pack/helper download is required for this audit. Reopen the launcher if necessary after updates.