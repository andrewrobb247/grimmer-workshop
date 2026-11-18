# Grimmer Workshop 0.1.14

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
