# Full DSD Arsenal integration - 0.1.29

User requested all weapons, with actual models and animations. The optional dependency is the unchanged author download DSD Arsenal 1.2.1 (Nexus 13921), inspected locally. No vanilla-model weapon substitutes are included.

When DSD Arsenal 1.2.1 is installed alongside Grimmer Workshop in the Workshop profile, the launch step adds its weapon and Energy Cell `display_entry` records to our progression patch. The game then uses the pack's item definitions for localized names and icons and its progression unlock levels for the crafting skill page. The launcher only reads the pack files; it writes the generated display patch inside Grimmer Workshop's own config folder.

## Included locally when the dependency is installed

All 53 author weapons: 35 firearms (including seven energy weapons) and 18 melee weapons, plus their models, animations, sounds, attachments, loot/trader entries, original recipes and progression. The pack remains a separately installed folder, `Profile/Mods/DSD_Arsenal`. It is not bundled with the public Workshop download or updater.

Workshop reads the installed pack's item tags, recipe outputs and native-skill unlock effects. It registers 53 normal weapon practice routes and one small Energy Cell crafting route. Weapons earn 10 base practice at appropriate relevance, then normal quality, diminishing relevance and crafted/found scrap multipliers apply. Actual weapon damage uses the existing activity learning route. Energy Cells give 0.02 base Electrician practice per crafted cell; two alternative recipes do not create two output rules.

Mapping: 16 Handguns, 6 Shotguns, 6 Rifles, 7 Machine Guns; 3 Knuckles, 3 Blades, 5 Clubs, 3 Sledgehammers, 3 Spears and 1 Robotics weapon. The weapon pack's existing skill gates and quality progression are retained; Workshop already levels these native skills through play. No books are needed to raise those skills in Workshop. Weapons remain at their author-defined crafting stations; this integration does not copy the pack recipes into our Gunsmith Bench.

Base Workshop routes remain 635. The inspected optional pack adds 54 runtime routes, total 689 when present. Absent pack means no optional routes. Unknown versions or malformed/ambiguous mappings fail closed for optional practice with a clear game-log message; base Workshop remains available. This does not validate arbitrary future pack versions.

## Preservation and permissions

The adapter reads metadata only and does not change the author's weapons, configuration, balancing, meshes, DLL, sound or animation files. No author content is uploaded to the Workshop repository. Players obtain the pack directly from its author. Keep the pack installed after saving its items in a world; rolling back Workshop does not remove external content.

Inspected archive SHA256: D79486663EF1588AB90D2C914EBA1DDEE0FFE33E5011361FB32029ED2B555147. Static metadata review resolved 49 game API member references in its DLL against the installed V3.4 b10 assemblies. That is a compatibility check, not a guarantee of animation/combat correctness. The author DLL is not executed by the review tests.

## Validation and live checks

Production build, existing regressions and 128 adapter checks pass against the downloaded pack metadata: all 53 weapons, exact family counts, one award route per output, author unlock levels, relevance limits, Energy Cell amount, absent dependency and duplicate-registration protection. Original downloaded files were verified against local staged files byte for byte. Existing saves are backed up locally before installation.

Optional adapter tests: `Test.ps1 -ArsenalDirectory PATH_TO_ORIGINAL_DSD_Arsenal`.

Live tests are still required for game startup/log, models, first/third-person animations, sounds, attachments, crafting quality/costs, combat practice, scraps, loot/trader refresh and save/reload. Existing loot containers/trader stocks may need their normal refresh. Do not claim player confirmation from static tests.
