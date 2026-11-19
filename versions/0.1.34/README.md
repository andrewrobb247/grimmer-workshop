## 0.1.34 - Cultivated plots, wildlife and pack status

Cultivated Farm Plot unlocks at Seeds 5. Build an empty new bed from one Farm Plot Block, four Compost and five nitrate. Growing plants directly above this soil use 20% shorter newly scheduled growth-stage intervals, retaining native randomness, world crop-speed setting, sunlight and harvest rules. No watering or repeated fertiliser upkeep required; this is an enriched bed, not a moisture simulation. Already pending crop ticks are not rescheduled. Build before planting; no occupied-plot upgrade action. Construction and Seeds practice awarded on crafting, with normal relevance/caps. Existing plot/station definition order retained; two new rules bring base total to 643, all previous 641 preserved. Retain homestead companion after rollback; old core loses only the growth benefit.

Optional Livelier Wildlife 1.0.0 is an unchanged separate XML pack: daytime herds, dusk predators, scent/scavenger and vulture encounters using native animal models. No new species/models, no replacement animal AI or DLL. All 227 requirement/action type references and biome/buff append targets resolve against native V3.4 b10; entity/event references checked. Author notes event-spawned animals may persist longer than biome animals; encounter balance/population needs live checks. External files are not bundled. Existing worlds supported by author; no new POIs involved.

Launcher has Optional packs / versions: recognises six reviewed pack identities/versions and checks key files, flags absent/incomplete/unknown/unreadable cases, and links original downloads. Recognised metadata is not a full file-hash check, proof of loaded state or a compatibility guarantee. Close/reopen launcher after updating. No automatic mod removal, updates or author asset redistribution.

## 0.1.33 - Optional Beautiful Bases and Looted

Adds read-only Construction practice for the separately installed GNS Beautiful Bases download (archive 3.7; ModInfo 2.0). Sixteen recipes produce 15 distinct outputs: both Military Barrier material alternatives share one practice route. Cheap one-iron hoists give 0.1 base practice; steel jail doors give 8, with intermediate awards for other decor. Standard learning speed, relevance falloff and Construction cap 100 apply. Registered decor also receives the existing Construction speed progression: 0% at level 1, up to 15% less craft time at 100. Original pack files, models, ingredient costs, unlocks and pickup behavior stay unchanged. No new base rules: 641 base plus 15 optional decor routes (and existing optional Arsenal/Bdub routes).

Looted 3.4.9 is an unchanged separate dependency adding map/POI tracking and its own options. All 338 direct native API references resolve and its map attachment selector matches. Live map size/markers/options/restock/persistence still need testing with Workshop HUD. Beautiful Bases has two benign missing church-bell drop removal selectors; other block/recipe/shape targets match installed native data. Elisk's Zombie Pack is not installed in this batch.

External author packs are not bundled in this updater or source archive. Local installation backs up saves, verifies originals, refuses existing-pack overwrites, preserves Arsenal/Guppy/Bdub and installs only Beautiful Bases/Looted. Keep optional packs installed while saves contain their items/state. Actual game checks remain on PLAYTEST-CHECKLIST.md. Vehicle inspection remains parked; powered stations/wildlife remain pending.

## 0.1.32 - Composting and restored workstations

Adds a Compost Bin (40 wood, 10 nails, 10 plant fibres). Queue 5 rotten flesh plus 20 plant fibres for one Compost over 120 seconds without fuel. Completion trains Seeds; open the bin to claim. A distinct alternative Farm Plot recipe consumes 2 Compost and only 10 base nitrate instead of 25, retaining wood/clay and farming perks. This prepares farm plots; it does not change plant growth or yield.

Ruined forges, workbenches (including empty variant), mixers and chemistry stations can drop their matching Restoration Parts on destruction (50% chance, one component maximum per destruction). No special tool is needed for these parts; normal wrench salvage remains unchanged. Build distinctly named Restored stations using one component and roughly 30% fewer ordinary materials, retaining normal skill unlocks, crafting station, scarce beakers/engines, tools, fuel and speed. Restored stations use native models, not new art or powered upgrades. New total 641 practice routes; all 635 previous routes retained. Placed new stations/items require the generated ZZZ_GrimmerHomestead companion to remain installed after rollback. Live placement/queues/rewards checks pending.

Also adds optional, read-only practice for independently installed Bdubs_Vehicles 3.4.0.2: 106 recipe outputs (41 vehicle assemblies, 64 components, one door mod), retaining the author's unlocks, ingredients, physics and models. Components give 8 base Vehicles practice, final assembly 15, door mod 2, with normal relevance/cap rules. The separate original pack includes old vanilla variants as well as genuinely different vehicles. Its mechanic POI is world-generation content and is not retroactively inserted into an existing world. No promise of automatic drivable wrecks or inspection/recovery integration.

For separately installed Guppy_Zombies_V3 3.0.3.0, a generated companion selects 21 ordinary entity appearances out of 41 declarations and caps their added relative spawn weight at one quarter of native weight (at most 20% of native+Guppy combined weight in each group). Excludes the other custom entities from natural spawns without deleting definitions or changing author files. No spawn count/frequency/gamestage edits. No new wildlife pack is included; KGX Wildlife was held due to reported AI movement problems. All external bundles must be downloaded separately and are not included in this updater/source archive. New models/animations/driving/spawns still need live testing.

Vehicle inspection work is parked by user request; published inspection behavior is unchanged here.

## 0.1.31 - Vehicle inspection menu and coverage

Keeps an enabled already-inspected status entry beside Search, rather than silently hiding inspection and letting the native one-action menu immediately start looting. Adds an inspection menu gate for eligible unlocked vehicles. Adds searchable minivans, pickups, semi trucks, fire trucks, service trucks, box trucks, army trucks and farm trucks. Vehicles still require a storage feature; standalone rear sections, helpers, player vehicles and placed props are excluded. Existing inspection history and one-payout rule remain intact. Native Search and salvage retained. Includes 0.1.30 recipe display fix. Live sedan interaction remains pending; one inspection is already recorded in the current save.

## 0.1.30 - Repeated specialist recipe rows

Fixes repeated weapons, attachments and cooking entries caused by showing Workshop specialist variants alongside their originals in the general crafting list. The display prefers the original in general views and the matching specialist recipe at Gunsmith Bench/Cooking Stove, including all-recipes view. Legitimate vanilla/other-mod alternatives remain available. No item definitions, author pack files, recipes, costs, unlocks, practice, inventory or saves removed. Close and relaunch after updating; keep current world. Live checks pending. Source/RECIPE-DISPLAY-FIX.md has details.
## 0.1.29 - Optional full Arsenal practice

Adds read-only practice integration for the separately downloaded, unchanged DSD Arsenal 1.2.1 pack: all 53 weapons (35 firearms, 18 melee) and Energy Cell crafting. Actual models, animations, sounds, loot, traders, recipes and balance come from the author's pack, installed locally in Profile/Mods/DSD_Arsenal. No author assets are bundled in the Workshop updater. Existing 635 rules retained; optional pack adds 54 runtime routes. Normal skill gates, quality, crafting/scrap multipliers, activity practice and relevance apply. See Source/ARSENAL-INTEGRATION.md. Live startup/animation/combat checks pending.
## 0.1.28 - Cooking Stove

Adds a fuel-burning kitchen stove using the native wood-burning stove model. Unlock at Food 20; build at a workbench with 10 forged iron, 4 short iron pipes, 4 mechanical parts and 10 small stones. All 49 campfire recipe variants cook in 25% less time, keeping ingredients, tools, unlocks and practice. Fuel remains required. Campfire alternatives remain available. Construction trains Workstations; existing 634 routes retained, new total 635. Includes the cumulative 0.1.27 features. Live placement, fuel/tools, queue, practice and persistence checks pending. Source/COOKING-STOVE.md has implementation and rollback details.
## 0.1.27 - Gunsmith Bench (unpublished candidate)

Adds an original specialist bench at Workstations 20. Craft at a workbench with 1 additional workbench item, 10 forged iron, 10 mechanical parts and 4 duct tape. Supports 118 weapon, ammunition and weapon-attachment recipe variants in 15% less time, retaining their original costs, unlock requirements, quality rules and practice. Uses the native workbench model/interface. Building it trains Workstations; total 634 practice routes. Existing 633 routes and original recipes retained. No external weapon assets added. Live placement, queue, progression and save checks pending. Includes engine restoration, inspection and owned storage pickup. See Source/GUNSMITH-BENCH.md.
## 0.1.26 - Recovered engine rebuilding (unpublished candidate)

Vehicle inspections can recover a Damaged Engine Assembly instead of a working component. Rebuild it into an Engine at a workbench using 10 forged iron, 12 mechanical parts, 4 oil and 2 duct tape. Base time 120 seconds; 12 base Vehicles practice, with normal relevance decay after 40. No schematic required. Existing working-component odds and all 632 previous routes retained; new total 633. Previously inspected vehicles stay depleted. Includes empty owned crate pickup and vehicle inspection. Live checks pending; publication remains blocked by GitHub integration HTTP 403. See Source/VEHICLE-RESTORATION.md.
## 0.1.25 - Empty owned storage pickup (unpublished candidate)

Hold use on your wooden, iron or steel storage crate and choose Pick up empty storage. Empty it, repair it, unlock it and close its inventory first. A two-second native pickup timer returns the crate at its existing material tier; ownership and contents are checked again before completion. No land claim required for these owned crates. Existing world props and insecure destroyed-lock variants are excluded. Sign text resets when the returned crate is placed again. Pickup itself gives no crafting practice. Includes vehicle inspection from 0.1.24. Live checks pending; GitHub publication remains blocked by integration permissions.
## 0.1.24 - Abandoned vehicle inspection (testing candidate)

Hold the use key on an abandoned sedan, police car, bus or ambulance and choose Inspect vehicle parts. Recover mostly small components, occasionally a usable engine, battery or wheel, with Vehicles and Salvage Tools practice. Unlock locked vehicles first. Normal Search and wrench salvage remain available. One saved payout per parent position in this world, including after reload, downgrades and POI resets. Full-inventory rewards drop at your feet. Keep the current world; no restart required beyond reloading the game after updating. Details and crash-window limits: Source/VEHICLE-INSPECTION.md. Automated checks pass; live play checks pending.
## 0.1.23 — Tool choices

Adds two original tool choices: Light Tool Grip (-10% attack stamina, +15% wear) and Reinforced Tool Frame (-25% wear, +10% stamina). Craft at a workbench without a schematic; fits non-motor harvesting/salvage tools with a slot, one Workshop tool choice at a time. Motor tools and repair hammers/nailguns excluded. Crafting trains Workstations to 25. Existing 630 routes/melee grips retained. Live equipped/slot checks pending.

## 0.1.22 — Fixtures and manufacturing

Finishes the recipe coverage pass with 52 routes for remaining fixtures, manufacturing, traps/seeds, protective biome gear and full vehicle assembly. Small per-unit awards for paper, nails, forged metals and components; 50-pick bundles match ordinary lockpick practice. All 578 existing routes retained. 18 refund/packing/terrain/grass conversions stay excluded. Existing recipe ingredients, outputs, unlocks and progress retained; new building recipes get Construction tags. Live checks pending.

## 0.1.21 — Attachment practice

Adds practice to all 75 vanilla attachment recipes. Pockets train Backpacks; armour fittings Armor; electronics Electrician; drone/baton parts Robotics; vehicle mods Vehicles; specialist weapon/tool parts their skills; universal parts Workstations. One skill per attachment, with modest tiered base awards and existing quality/relevance scaling. Existing 503 routes, recipes, schematics and progress retained. Live attachment checks pending.

## 0.1.20 — Ammunition practice

Adds small ammunition practice: handgun/shotgun ammo, shared 7.62mm rifle/machine-gun practice, arrows/bolts, turret rounds and iron darts. Bundle awards use real 100/1000/75-round contents and apply relevance at each level; opening bundles gives no second award. 57 new routes; 446 existing routes, recipes, unlocks and saved progress unchanged. Live ammo checks pending.

## 0.1.19 — Preparation practice

Adds small Food practice for cornmeal, boiled eggs, mineral water, blackstrap coffee, canned Sham, four biome smoothies and chicken feed; Medical practice for aloe cream and splints. Four campfire recipes also train Workstations through level 10. Feed award is per 10-item batch. Existing 430 routes, unlocks and saved levels retained. Live preparation checks pending.

## 0.1.18 — Construction

Adds Construction (levels 1-100) to the crafting skills screen: 82 building/material/furniture routes plus block-upgrade practice. Higher Construction gradually reduces tagged building recipe craft time, up to 15% at 100. Existing recipe unlocks and 348 practice routes preserved. Corrects grip percentage display rounding. New skill added to existing characters on reload; live skill/bonus/save checks pending.

## 0.1.17 — Recipe training and Workstations

Recipe training icons with skill/cap hover text, hidden at cap. Food now gives 12 early Workstations practice per batch (was 5); boiled water gives 2 through level 10. Workbench equipment adds 2 secondary practice through 75, with relevance decay; Workshop grips give 4 through 25. Station practice excluded from scrap. Existing levels retained. Live UI/cooking tests pending.

## 0.1.16 — Grip display fix

Fixes crafted grip names, descriptions and percentage stat panels. Light Grip: -15% attack stamina cost, +20% durability loss; Power Grip: +10% melee damage, +15% attack stamina cost. Existing grips retained. Clarifies early Workstations training. Live display check pending.

# Grimmer Workshop 0.1.15

First playable foundation for a personal solo PvE overhaul of 7 Days to Die V3.4 b10.

## Start playing

1. Extract the whole `Grimmer-Workshop` folder somewhere permanent.
2. Close any running copy of 7 Days to Die. Keep Steam running.
3. Double-click `Open-Display-Settings.cmd` if you want to adjust the health display. Its preview updates immediately. Save when finished.
4. Double-click `Launch-Workshop.cmd` to open the Workshop launcher, then click Play Workshop.
5. Create a fresh solo world. Keep crafting progression enabled in the world's sandbox settings.

The launcher uses your existing Steam installation and a separate `Profile` folder for this pack's mods, worlds, saves and log. It starts the game executable with EAC disabled. The default Steam path is the one inspected on your PC. If it changes, pass `-GameDirectory` to `Launch-Workshop.ps1`.

The Steam installation's own Mods folder is also loaded by the game. At build time that folder contained only the stock `0_TFP_Harmony` loader. Additional mods placed there later can affect this profile.

## Included in this build

- Completed crafts award practice to the relevant vanilla crafting skill.
- 311 training routes cover all 24 crafting skills. The complete mapping is `Profile/Mods/GrimmerWorkshop/CRAFTING-ROUTES.csv`.
- Primitive tools train harvesting, cooking trains food and early workstation skills, bandages train early medicine, and cloth trains backpack crafting up to its first unlock.
- Electrical and mechanical component assembly recipes provide accessible training for those skills. The mechanical recipe needs forged iron, so the forge is an early objective.
- Recipe unlocks and quality tiers use vanilla's crafting progression milestones.
- Outdated recipes give diminishing practice. Higher unlock tiers give more practice.
- Quality multiplies crafting practice: Q1 x1, Q2 x1.25, Q3 x1.5, Q4 x1.75, Q5 x2, Q6 x2.5.
- Completed inventory scraps of mapped equipment award practice to its crafting skill: 25% of the equivalent craft reward for unmarked gear, 10% for gear crafted after this update. Raw materials do not earn scrap practice. Cancelled scraps earn nothing.
- Newly crafted equipment carries a saved provenance marker, including workstation outputs. Equipment made before 0.1.2 is unmarked and receives the unmarked scrap rate. Looted equipment uses its matching rule and current recipe relevance/caps.
- Crafting magazines never raise crafting skills. Their new loot and trader rolls default to paper in 0.1.4; individual book toggles are in Gameplay settings / books. Perk books and schematics stay enabled by default.
- Nearby crafting gathers plain ingredients from your placed, owned, closed storage within 20 metres. Protected container slots are excluded.
- Ingredient counters, recipe availability and maximum crafting quantities include eligible chest supplies. A read-only display snapshot refreshes every half second while the crafting UI is open, including when walking into or out of range.
- Ingredient costs use the game's selected quality, perk and sandbox calculation. Collected ingredients enter your backpack before vanilla queues the craft. If the queue is full, gathered materials may remain in your backpack.
- If there is insufficient space or material to gather everything needed, the storage operation is rejected.
- Workstation crafting reports practice when the game delivers its completion event to the player. Away/offline station completions may therefore be credited on returning to the station.
- The health display defaults to a smaller bar with names hidden and health numbers shown. Use the Windows preview to change it.

## Storage controls

Open the console with F1 and enter these commands.

| Command | Action |
| --- | --- |
| `grimmer status` | Show crafting levels, practice and eligible nearby container count. |
| `grimmer store` | Deposit unlocked backpack items into nearby containers that already contain matching items. |
| `grimmer refill` | Top up occupied locked backpack slots from nearby storage. |
| `grimmer reload` | Reload learning and storage configuration. |
| `grimmer help` | Show the available commands. |

`gw` is a shorter alias for `grimmer`. Lock inventory slots using vanilla's padlock control. Slot locks protect bulk transfers. Normal crafting can consume ingredients in locked backpack slots, as in vanilla.

Use the two arrow icons beside the Inventory title: Deposit nearby moves unlocked backpack items into nearby closed storage already containing matching items; Refill locked slots tops up occupied locked backpack slots. Hover for tooltips. Both actions apply to the whole backpack, including filtered-out items. Console commands remain available.

## Configuration

Edit `Profile/Mods/GrimmerWorkshop/WorkshopSettings.xml`, then run `grimmer reload`.

| Attribute | Default | Meaning |
| --- | --- | --- |
| `practicePerLevel` | 40 | Practice needed for the earliest levels. |
| `practiceGrowth` | 0.5 | Extra practice required per existing skill level. |
| `learningSpeed` | 1 | Multiplier on practice earned, allowed range 0.1 to 10. |
| `storageRange` | 20 | Metres, allowed range 1 to 40. |
| `nearbyCrafting` | true | Enable automatic collection of crafting ingredients. |
| `scrapPracticeFraction` | 0.25 | Scrap practice for unmarked equipment, from 0 to 1. |
| `craftedScrapPracticeFraction` | 0.1 | Scrap practice for newly player-crafted equipment, from 0 to 1. |

Display settings have their own preview window and apply after restarting the game. This vanilla profile uses the game's own selectable inventory-lock button.

## What still needs live testing

This build compiles against the installed b10 assemblies. Its original storage, practice and recipe UI code passed automated regression checks using an in-memory game fixture. XML targets and method signatures were checked against the installed game. Live testing of 0.1 confirmed crafting practice, Quality 2 stone-tool unlocking, level persistence after quitting/reloading, and crafting with chest ingredients. Version 0.1.1 repairs the missing chest ingredient counts and recipe availability display. The user confirmed chest ingredient counts and range updates in-game. Version 0.1.2 quality and scrap changes compile and pass 2054 regression checks; they still need a live game check. A standalone Harmony installation probe cannot execute these Unity methods under the Windows .NET Framework runtime (default interface implementation mismatch), so it does not validate live patch installation.

First live check

1. Run `grimmer status` and note Harvesting Tools practice.
2. Craft a stone axe and check the increase. Cancel another queued axe and check that it earns no practice.
3. Put wood and stone into a placed chest, close it, and craft another axe nearby. Check the exact quantities in both chest and backpack.
4. Lock a backpack supply slot, run `grimmer store`, then `grimmer refill`.
5. Cook at a campfire, check workstation practice, save, quit and reload. Verify the practice was retained.
6. Check the health display and normal slot-lock toggle in-game.

A real run is also needed to tune the learning rate. No full playthrough or multiplayer validation has been completed.

## Current boundaries

- Solo only. The code intentionally stays inactive outside a single-player world.
- Nearby crafting covers plain ingredients, with quality-bearing equipment selected through vanilla. Forge input and smelted materials use the original forge system.
- Nearby storage is limited to placed containers owned by the local player. Vehicles, drones, POI loot and open containers are excluded from this first storage system.
- The launch profile uses a fresh world. Combining it with War3zuk or another overhaul has not been validated.

## Next stages

1. Validate the first loop in a live game and improve inventory controls and practice feedback.
2. Balance trader rewards, crafting rates and resource costs together.
3. Add weapon roles, attachment choices and vehicle restoration.
4. Expand farming, cooking and base defences.
5. Add quest chains, wandering-horde variety and world events.
6. Implement and test an optional co-op profile.

## Source and ownership

Gameplay code, transfer logic and display tooling in this package were written for this project. No third-party mod code, custom assets or proprietary game DLLs are bundled. Game item identifiers and unlock data are generated from the local vanilla configuration. The game supplies its stock Harmony loader.

`Build.ps1` builds against the local game using the Windows .NET Framework compiler and Python. `Test.ps1` exercises the production practice and storage code using the small fixture in `Tests`.

When updating, preserve `Profile/Saves` and `Profile/GeneratedWorlds` and keep a copy of your configuration. Remove or replace only the pack's own mod folders as needed.

## 0.1.2 live checks

Continue the existing world. Compare practice before and after one Q1 and one Q2 stone axe (10 and 12.5 at early levels before relevance falloff). Scrap the newly crafted Q2 axe: expect 1.25 practice. Queue and cancel another scrap: expect zero. Looted Q2 equipment gives 25% of its own matching craft rule. Check a full inventory retry and a workstation craft, then save/reload. Existing settings need no edits: missing new attributes use the defaults above.


## Launcher and updates (0.1.3)

Open Launch-Workshop.cmd. The launcher checks the selected GitHub channel and shows the release notes. Install update downloads only changed files, verifies SHA-256 hashes, and checks the exact installed game assembly against V3.4 b10 before applying anything. A failed download leaves the installation untouched. Failed application restores the previous files; Roll back update restores the last backup. A backup pointer is saved before application, allowing manual rollback after an interruption.

Worlds, progression and personal settings are kept. Existing WorkshopSettings.xml, updater preferences, HUD Settings.json and generated HUD windows.xml are preserved. New default settings are kept even when rolling back. Source/development files are not automatically installed by the player updater. No Steam game binaries, saves, credentials or personal logs are published.

The first release is a testing preview. Its quality/scrap gameplay changes still need a live check. The stable channel will be published after those checks; there is no stable release yet. Stable is intended for your friend's regular play once available. Channel changes take effect only when you click Install update, including switching back to an older release. Offline play remains available. No account, token or Git installation is required to download public updates.

Select Game folder if Steam is installed elsewhere. Each user needs their own Steam game. Workshop remains solo only and does not modify the game's Steam installation. The updater's source is fixed to the public andrewrobb247/grimmer-workshop repository; its testing channel is hosted there.

Checks: 28 automated updater checks under Windows PowerShell 5.1, plus 2054 storage/practice/UI algorithm checks. A native launcher window could not be inspected from the restricted execution desktop, so its first visible run still needs checking. Online downloading still needs checking after the GitHub publication. Build-Release.ps1 stages an immutable version directory and its channel manifest, containing only the original mod pack files.



## 0.1.4 progression and book controls

All 2,021 crafting-level transitions across 24 skills have a magazine-free recipe route. See Source/PROGRESSION-AUDIT.md for the generated starter recipes and station requirements. This checks unlock continuity; it is not a full ingredient-economy playthrough. Crafting, quality bonuses, scrapping, skill levels and existing save variables are retained.

Activity rewards supplement crafting. They award crafting-skill practice, not character XP:

| Activity | Base practice |
| --- | --- |
| Gather resources using mapped harvesting, salvage or blade tools | 0.1 per harvested item, at most 2 per harvest event |
| Deal actual health damage to zombies/animals with a mapped weapon | 1 per 25 health lost, at most 3 per hit |
| Harvest a mature crop | 0.5 per harvested item, at most 1 per event |
| Salvage electrical parts | 0.25 Electronics practice per part, at most 1 per event |
| Complete an equipment repair | 2 Repair Tools practice |
| Upgrade a block | 1 Repair Tools and 0.25 Workstations practice |
| Use a medical/drug item | 1 Medical practice |

Activity practice is capped at 3 per real second for each skill and uses actual harvest/damage/use events. Empty swings and hits on dead bodies do not count. Weapon attribution uses the damage source's attacking item, not whichever weapon you switch to later. Cooking continues to teach Food and early Workstations through completed recipes. Wearing armour, driving and idle movement do not yet give activity practice; their crafting routes remain available.

Open Gameplay settings / books in the launcher while the game is closed. There are 226 individually selectable book items across crafting magazines, perk books and schematics, with Enable/Disable this tab controls. Crafting magazines default off; the other categories default on. Disabled new loot/trader rolls become paper, preserving the old roll probabilities and counts. Existing inventory/chest items and existing trader stock are kept. Changes affect newly generated loot and future trader restocks; read bonuses and learned recipes are not revoked. Creative/admin gifts and arbitrary third-party scripted rewards are outside this loot policy.

Book preferences are saved inside WorkshopSettings.xml, which the updater preserves. The launcher regenerates the two local book-policy XML patches before each game launch. No new manual ZIP setup is needed for existing launcher users. Reading crafting magazines stays disabled regardless of whether their loot checkbox is enabled. Turning off perk books or schematics does not replace their unique effects/recipes yet; leave those enabled if you want those benefits.

Gameplay settings also control activityLearningSpeed (0 disables activity practice) and practiceNotifications. Missing attributes in older settings use 1 and true. Use grimmer reload to reread those two settings, or restart; book loot changes require restarting. Brief notifications are throttled to one every two seconds; grimmer status now uses friendly names and can filter, for example grimmer status harvesting.

Validation: 2061 algorithm regression checks; 28 updater checks; book-policy checks across 226 items and 247 loot/trader references, with individual overrides and re-enabling tested. Existing Q3 craft (+15) and scrap (+1.5) were confirmed by the player in 0.1.3. The new activity events and gameplay settings window still need live checking after installation. No world reset is needed.

## 0.1.5 crafting skill screen

Open the Skills window, choose its crafting-skills tab and select a skill. A new panel shows saved practice versus the next-level requirement, a filled progress bar, relevant training activities and the next recipe/quality milestone. For example, Harvesting Tools level 5 points to Stone Tools Q4 at level 6. The milestones come from vanilla's actual crafting display data, including quality changes rather than only new technology tiers. Hover long next-unlock text for its complete version.

Crafting skill rows also have small practice bars. Completed skills show a full bar and MAXIMUM LEVEL. Once all recipe/quality milestones are unlocked before a skill cap, the panel states that separately. Training hints omit activity rewards when activity learning is disabled; early cooking/campfire caps are shown in the Workstations hints. Generic no-selection bindings are cleared safely, and ordinary perk descriptions retain vanilla behavior.

The vanilla icon grid and recipe/quality tables remain. The table uses three rows, with native paging when needed, to make room for the practice panel. Visible controllers check for practice changes at most four times per second; idle skill details do not continually rebuild. UI queries never modify saved progress. The launcher generates these XUi patches before game launch, so existing updater installations need no extra manual files. The HUD health-display settings are separate.

Validation: 2081 regression checks include the actual new binding/refresh code against the in-memory fixture, saved practice, idle refresh, no-selection behavior, native perk fallback and milestone text. A further 24 XML layout checks verify targets, retained icon controls and paging. Compilation uses the installed V3.4 b10 assemblies. The actual rendered layout still needs a live check. No gameplay rates or save keys changed. Existing harvesting, club combat and equipment-repair activity rewards were confirmed in-game in 0.1.4; cooking/crop/electrical checks remain pending normal play.

## 0.1.6 skill identifier fix

The first 0.1.5 live screenshot showed layout changes but no practice text or bars. The installed DLL matched the release and initialized without errors. Inspection of ProgressionFromXml confirmed that vanilla lowercases runtime progression identifiers. The UI now resolves those identifiers case-insensitively back to the original rule name before reading saved practice or choosing training hints. Existing save keys and rates are kept. The test fixture now uses actual lowercase runtime names: it reproduced the blank-panel failure before the fix and passes afterwards. 2084 regression checks pass, including canonical save-key lookup, category hints and list-bar visibility. The rendered correction still needs an in-game check.


## 0.1.7 skill-screen copy and milestone correction

Remove the redundant magazine sentence from the selected-skill description. Non-quality display entries use zero-based pending-recipe names; querying the name at its unlock threshold selected the following recipe. Resolve the name immediately before that threshold instead. Workstations now points to Forge at level 4, then Chicken Coop at level 6. The quality milestone path remains unchanged. 2087 regression checks pass, including both non-quality transitions and the description copy. The 0.1.6 screenshot confirmed practice text, row bars and training hints in-game; this correction still needs a live check. No save keys or rates changed.




## 0.1.8 nearby storage buttons

Adds deposit and refill arrow buttons beside the Inventory title. Uses existing storage transfers, preserves vanilla locking and reports results. Button event and native XML layout checks pass; live layout and transfer checks remain in PLAYTEST-CHECKLIST.md. No progression changes.



## 0.1.9 quest reward book policy

When all crafting magazine types are disabled, the quest magazine bundle and crafting-magazine challenge reward pools offer three repair kits instead. Direct disabled book/schematic Item rewards also become three repair kits. Individual magazine toggles retain their existing loot behaviour when some types remain enabled. XP, currency and reward choice counts are unchanged. Already generated quest choices may persist; choose another reward on those quests. Existing bundles are not converted. Generated quest policy is rebuilt at launch and clears when books are re-enabled.



## 0.1.10 storage button click correction

Fixes deposit/refill buttons ignoring left-clicks. The installed game's XUiController.Pressed dispatches OnPress using -1, whereas the initial handler expected 0. The button regression fixture now uses the real input value and rejects both right-click (-2) and unrelated zero input. Storage selection and transfer rules are unchanged. Live click/transfer confirmation pending.


## 0.1.11 mixed-quality equipment deposit

Nearby deposit selects chests by exact base item type, allowing different-quality batons and other equipment into the same chest. Actual stacking and refill still require vanilla stack compatibility. Quality, condition and attached mods are retained in separate slots. Full/protected destinations leave items in the backpack. 2095 regression checks pass; the new equipment case reproduces the old failure before the fix. Live transfer confirmation remains pending.

## 0.1.12 workstation quality credit

Keep different-quality workstation crafts in separate completion records so practice uses each quality multiplier. The native completion list, saving and claim/removal path remain. Open a station to claim finished crafting practice; standing nearby alone is not the reliable trigger. Plain cooking batches still aggregate. Existing already-merged records cannot be reconstructed. 14 focused code checks and four installed-game layout checks pass. See Source/WORKSTATION-AUDIT.md. Live mixed-quality and away/return checks remain pending; no rates or save keys changed.

## 0.1.13 targeted fuel practice balance

Reduce rapid fuel refining base practice from 10 to 0.1 per two-fuel batch. At Vehicle skill 20 this changes 17.6 to 0.176 practice before later falloff. One shale should not train more than building a bicycle chassis. The other 310 routes, recipe costs, unlocks, caps, quality multipliers and global learning rates are unchanged. From Vehicle level 20, 2,000 fuel previously could max the skill in one grouped claim; the new reward reaches level 23 with 26 practice. Source/BALANCE-AUDIT.md and BALANCE-DATA.csv cover 311 routes and 321 recipe variants; economic bundle sizes are normalised and limitations stated. Automated policy comparison checks only the fuel credit changed. Live refining check pending. Existing levels are retained.

## 0.1.14 consistent batch practice

Grouped completion records now recalculate recipe relevance as crafting levels rise, matching sequential recipe-batch credit within normal numeric precision. Large queues cannot hold their starting-level relevance for every output. Evaluation skips groups that cannot cross a level, avoiding a loop for every item. Existing quality factors, recipe credits, level costs, caps, saved levels and save keys remain. One grant per skill keeps notifications consolidated. The same calculation covers mapped equipment scrapping. 2605 regression checks pass, including 500 grouped/sequential comparisons and huge-queue cap checks. The release builder also writes marker-free UTF-8 JSON on Windows PowerShell to prevent the updater schema error. Live grouped-vs-separate checks remain pending.

## 0.1.15 melee grip choices

Two removable Workshop grip mods can be crafted at a workbench without a schematic. Search Workshop Light Grip Mod or Workshop Power Grip Mod. Light Grip adds -15% attack stamina cost and +20% durability loss per use; Power Grip adds +10% entity damage and +15% attack stamina cost. Final values also depend on normal attachment bonuses, perks and other installed mods. Fits clubs, sledges, spears, knives, knuckles and batons with a free mod slot. A shared modifier tag prevents installing both Workshop grips together. Ranged weapons and harvesting tools are excluded. Recipes and English descriptions are included; no loot/trader injection or new crafting-practice routes. The launcher generates modifier and localization definitions before starting the game, keeping old updater compatibility. Generated definitions may remain if rolling back, preserving the identities of already-crafted attachments. No baseline weapon stat changes or world reset. 51 definition/recipe/compatibility checks pass; actual equip effects remain on the playtest checklist.
