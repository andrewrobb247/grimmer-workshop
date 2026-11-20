# Workshop playtest checklist

Updated 20 November 2026. Current testing release: 0.1.38. Latest published release: 0.1.38.
Keep using the current world. Pending means not yet confirmed in live play.

## 0.1.38 recipe skill icons

- [ ] Recipe-list symbols match the Crafting screen: Construction hammer, Food fork, Seeds crops, etc.
- [ ] Two-skill recipes show both active skill icons; hover lists both names and caps. Reaching one cap removes just that route's icon without reopening crafting.
- [ ] Long names, favourites and recipe locks remain readable; no-practice/full-cap recipes have no training marker.

## 0.1.37 utilities - live checks pending

- [ ] Electrical25/35 unlock Controller/Drive; costs and green practice icons correct, no magazine or point changes.
- [ ] Place/wire native relay models: Controller10 W/Drive20 W; confirm circuit load, power failure and pickup/save/reload.
- [ ] Drive within2 blocks X/Y/Z of station base: supported queues25% faster, tools/fuel remain; without power native speed. Multiple drives do not stack; forge/compost unaffected.
- [ ] Controller touches water on a face, covers cultivated soil within3 X/Z and1 Y; new stages take an additional10% less time. Ordinary plots/yields/sunlight unchanged; controllers do not stack.
- [ ] Unloaded catch-up gets no assumed power bonus; existing queued work/materials, restored stations and stored practice survive restart.
- [ ] Save/rollback retains utility blocks/companion; no invisible models, duplicate outputs or unexpected ingredient usage.

Latest reviewed0.1.36 session (20 November09:12 onward): enemy/text companions loaded and zero ERR/EXC lines. Two known church-bell remove-selector warnings are benign; two ActionTarget-to-Vector3 warnings have unconfirmed origin and remain under observation. This log does not prove driving, crop speed or animation correctness.

## 0.1.36 Display settings

- [ ] Install, then close/reopen launcher. Display settings opens in front of launcher; closing returns to launcher.
- [ ] Existing saved values remain; change preview controls, save, close and reopen. Values persist; next game start applies HUD changes.
- Local verified: Windows PowerShell 5.1 preview draw, control save/reload, generated XML, spaced profile paths, original defaults untouched, missing/corrupt file errors propagate.

## 0.1.35 audit repairs - pending live checks

- [ ] Save/quit, install through existing testing launcher, then Play. Confirm no ZZZ_GrimmerEnemies metadata/XML errors in fresh log and the filtered companion loads.
- [ ] Check new decor names/descriptions and classic minibike/GNX descriptions; attachment stat and description tabs remain readable.
- [ ] Confirm normal startup, crafting and existing save contents; intended roster weighting affects new spawns, not already present zombies.
- [ ] Compare cultivated crop stages, wildlife population/behaviour and vehicle/weapon models/animations during normal play.

## Player confirmations �?" 19 November 2026

- [x] Looted map appears to work in normal play.
- [x] Beautiful Bases decorations can be taken from walls and placed in the player's base.
- [x] Crafting new decor awards Construction practice.
- [x] New zombie appearances are visible during exploration.
- Still pending: broader map/restock/options persistence, decor craft-time scaling, zombie combat/animations/ragdolls/spawn balance, and vehicle driving checks. These confirmations do not establish those behaviors.

## 0.1.34 cultivated plots / wildlife / launcher - pending live checks

- [ ] Reopen updated launcher: six optional pack entries, installed versions/status and original-download links. Incorrect/missing folders do not show as recognised.
- [ ] Seeds5 unlocks Cultivated Farm Plot, consuming one plot, four Compost and five nitrate; normal plots retained. Crafting trains Construction/Seeds within caps.
- [ ] Plant same crop on normal and cultivated beds under matching sunlight/world settings. Compare newly scheduled stage timing over multiple plants: enriched intervals 20% shorter, normal randomness retained. Harvest yields/skill awards unchanged.
- [ ] Cultivated plot, crop stages and native scheduled ticks survive save/reload; no extra reward from picking up/replacing. Existing stations/plots remain correct.
- [ ] Wildlife original pack loads without XML errors; daytime animals/dusk predators/scavenger/vulture events appear in appropriate biomes/conditions.
- [ ] Watch animal accumulation, AI movement, performance, cooldowns and safety conditions during normal play; author notes event animals may persist.
- [ ] Existing Looted map, decor Construction practice, weapons, vehicles and storage still work. No new species/models or watering simulation claimed.

## 0.1.33 Beautiful Bases / Looted - pending installation/live checks

- [ ] Installer copies the two originals unchanged; existing Arsenal/Guppy/Bdub remain. Startup registers 15 decor routes and Looted with no load exceptions.
- [ ] Decor names/models/shapes, recipe costs and placement/pickup work; no unexpected duplicate output rows except real barrier material alternatives.
- [ ] Craft cheap hoist (.1 base), a cloth flag (2) and a steel jail door (8); Construction practice once per completed output, scaled normally. Cancellation/pickup/replacement gives no new completion credit.
- [ ] Green training icon and Construction tooltip show while below cap. Higher Construction reduces these decor recipe times up to 15%; native recipe speed unchanged.
- [ ] Looted map opens normally: labels/buttons, zoom, tracking, options, cleared-POI/restock markers and save/reload work with the Workshop HUD.
- [ ] Inventory lock/deposit/refill, owned storage pickup, Construction, prior stations and optional weapon/vehicle practice still work.
- [ ] Elisk is not installed. Author content remains outside public Workshop updater/archive.

## 0.1.32 optional zombie/vehicle originals - pending installation/live checks

- [ ] Local helper installs the two original packs unchanged after backing up saves; Arsenal remains intact. Startup log confirms 106 Bdub practice routes, no failed mod/XML patches.
- [ ] Ordinary Guppy models, animations, hitboxes, sounds and ragdolls work. Natural spawns use selected roster without replacing normal zombies.
- [ ] Bdub dirt bike/utility pickup/cargo truck recipe gates and practice are correct; author ingredients/quality remain. Actual driving, storage, fuel, damage/repair, pickup and save/reload work.
- [ ] New mechanic POI is not assumed to appear in the existing generated world. No parked inspection feature testing required.
- [ ] Friends install original author packs separately; updater carries no external assets.

## 0.1.32 composting and restored stations - pending live checks

- [ ] Compost Bin recipe consumes 40 wood, 10 nails, 10 fibres. Place/open; crate model has a one-block footprint.
- [ ] Compost takes 5 rotten flesh and 20 fibres per output, 120 seconds, no fuel/tools. Cancellation returns ingredients and gives no practice.
- [ ] Finish with bin closed; open it to claim Seeds once. Reopen gives no second award; save/reload keeps unclaimed credit.
- [ ] Compost Farm Plot alternative uses 2 Compost, 10 nitrate, 100 clay and 4 wood before native farming reductions. Original Farm Plot still available.
- [ ] Destroy ordinary ruined stations: matching Restoration Parts sometimes drop (50%); native loot/salvage remains. Destroyed restored/player stations produce no new recovery parts.
- [ ] Restored Forge/Workbench/Mixer/Chemistry recipes respect original skill levels and crafting areas; require the matching component and reduced normal materials. Engine/beaker still required.
- [ ] Restored stations place/open with correct native UI, recipe lists, forge smelting, tools/fuel, heat and speed. They are not powered/faster stations.
- [ ] Queue/cancel/complete/save/reload and pickup/replacement preserve items/practice without duplicates.

## Parked vehicle inspection

User reports ordinary vehicles still immediately loot on 0.1.31; locked police-car menu works. Feature development/testing parked pending future distinct vehicle restoration design. Retain existing history; no further inspection fix claimed.

## 0.1.31 vehicle interaction follow-up (parked)

- [ ] Uninspected sedan: hold use; Search and Inspect vehicle parts appear. Inspect yields one reward.
- [ ] Inspected sedan: hold use; Search and Vehicle parts already inspected appear. Status gives no repeat reward.
- [ ] Try searchable minivan, pickup and truck variants; inspection is available without a tool.
- [ ] Locked/in-use vehicles remain protected; standalone rear sections without storage are excluded.
- Evidence: current save has a persisted recovery at 305,38,-798. This does not confirm which sedan the user tested. Live interaction still pending.

## 0.1.24 vehicle inspection - pending live checks

- [ ] Hold use on an abandoned sedan; Search and Inspect vehicle parts both appear.
- [ ] Inspect once: parts arrive; Vehicles and Salvage Tools practice increases.
- [ ] A second inspection, including another side of the same car, gives no parts/practice.
- [ ] Save, quit and reload; inspection remains depleted.
- [ ] Normal Search and wrench salvage still work before/after inspection.
- [ ] Locked police car refuses inspection until unlocked; bus/ambulance are supported.
- [ ] Full inventory: recovered parts drop at your feet and can be collected.
- [ ] Player vehicles, cardboard boxes and placed storage have no inspection command.
- [ ] Damaging/downgrading or resetting a previously inspected vehicle does not pay again.
## 0.1.25 storage pickup - pending live checks

- [ ] Owned empty wooden, iron and steel crates show Pick up empty storage on the hold-use menu.
- [ ] Filled, damaged, locked, open or someone else's storage cannot be picked up.
- [ ] The two-second timer returns the correct crate tier; replacing it works; sign text can be rewritten.
- [ ] Adding contents or opening storage during the timer cancels completion without loss.
- [ ] Full inventory uses native overflow drop; recovered crate can be collected.
- [ ] Native forge/workbench pickup, storage Search and vehicle inspection still work.
## 0.1.26 engine restoration - pending live checks

- [ ] An uninspected abandoned vehicle can yield a Damaged Engine Assembly; name/icon/description display correctly.
- [ ] It cannot substitute for a working engine in a vehicle or generator.
- [ ] Workbench Engine recipe consumes 1 assembly, 10 forged iron, 12 mechanical parts, 4 oil and 2 duct tape.
- [ ] Completed rebuild gives one usable native Engine and Vehicles practice when station credit is claimed.
- [ ] Cancelling a rebuild returns ingredients and grants no completion practice.
- [ ] Previously inspected vehicles remain depleted after update/reload; no second recovery.
- [ ] Existing small-parts/working components, Search, salvage and owned crate pickup still work.
## 0.1.27 Gunsmith Bench - pending live checks

- [ ] Gunsmith Bench recipe is locked at Workstations 19 and unlocked at 20 without a magazine.
- [ ] Craft with 1 extra workbench item, 10 forged iron, 10 mechanical parts and 4 duct tape; crafting station remains placed.
- [ ] Placement and opening work with the normal workbench footprint/UI; name/description/icon are readable.
- [ ] Weapon, ammunition and supported weapon-mod recipes appear; engine/vehicle/armour/drone recipes do not.
- [ ] Original recipe gates and quality-dependent ingredient costs still apply.
- [ ] A matching recipe takes 15% less time than the ordinary workbench under the same perks/settings.
- [ ] Completed crafts give normal practice when station credit is claimed; cancellation gives none; ammo bundles grant no extra opening credit.
- [ ] Queued crafts and placed bench survive save/reload; native output/reclaim rules work.
- [ ] Ordinary workbench crafting, engine restoration, vehicle inspection and storage pickup still work.
## 0.1.28 Cooking Stove - pending live checks

- [ ] Recipe is locked at Food 19 and unlocked at Food 20 without a magazine.
- [ ] Workbench construction consumes 10 forged iron, 4 short iron pipes, 4 mechanical parts and 10 small stones; awards Workstations practice.
- [ ] Stove places with the wood-burning stove model, sensible collision and readable name/description.
- [ ] Opens native cooking UI; all 49 campfire recipe variants retain their original gates and ingredient costs.
- [ ] Pot, grill and beaker insert into their slots; recipes require the same tools as the campfire.
- [ ] Fuel is required; start/stop work; running out of fuel stops cooking.
- [ ] Matching recipe takes 25% less time than a campfire under the same perks/tools/settings.
- [ ] Completion gives normal practice when claimed; cancelled crafts give no completion practice.
- [ ] Station, tools, fuel and queued cooking survive save/reload; native reclaim rules work.
- [ ] Ordinary campfire, Gunsmith Bench, engine restoration, vehicle inspection and storage pickup still work.
## 0.1.29 full Arsenal - pending live checks

- [x] Verified startup log: DSD_Arsenal 1.2.1 and Workshop 0.1.29 load; practice registered for all 53 weapons plus Energy Cells; no matching startup errors in inspected log.
- [ ] New melee and firearms display their actual models, animations and sounds in first and third person.
- [ ] Normal author skill unlocks and Q1-Q6 crafting work without reading crafting magazines.
- [ ] Crafting, actual combat damage and crafted/found scraps train the intended weapon skill once.
- [ ] Energy Cell crafting gives small Electrician practice; firing/opening does not count as crafting.
- [ ] Supported vanilla and Workshop attachments equip correctly; custom sights/reloads/laser effects work.
- [ ] Normal loot/trader refresh introduces author weapons; existing containers/stocks may remain unchanged until refresh.
- [ ] Items, equipped mods and skill practice survive save/reload.
- [ ] Existing Workshop stove, Gunsmith Bench, engine restoration, vehicle inspection and storage pickup still work.
## 0.1.30 recipe display - pending live checks

- [ ] General crafting search shows one row for each original/Workshop specialist recipe pair (.44 Magnum, Auto Shotgun, Arrow Rest Mod, etc.).
- [ ] Gunsmith Bench still shows its craftable versions and 15% time reduction, including all-recipes view.
- [ ] Cooking Stove retains its own recipes and 25% time reduction; original campfire still works.
- [ ] Legitimate alternate vanilla/third-party recipes and all Arsenal weapons remain available.
- [ ] Existing inventory, equipped items, queued crafts, skills and saves remain intact.
## Confirmed by player

- [x] Completed crafting awards practice.
- [x] Quality 3 stone axe gives 15 practice; scrapping that crafted axe gives 1.5.
- [x] Harvesting gives Harvesting Tools practice.
- [x] Club damage gives Clubs practice.
- [x] Equipment repair gives Repair Tools practice.
- [x] Storage ingredients appear in recipe ingredient counts.
- [x] Crafting screen shows saved practice, bars and training hints (0.1.6).
- [x] Vanilla inventory locks work. The reported broken lock belonged to War3zuk.

## Check on the next normal restart

- [ ] Practice totals and skill levels survive save, quit and reload. Compare a screenshot before/after without performing another activity.
- [ ] In 0.1.7 the skill description has no magazine sentence.
- [ ] Workstations next unlock says Forge at level 4, then Chicken Coop at level 6. Check against the native unlock table.
- [ ] Display settings preview changes as values change. Save a smaller bar, launch, and compare against an enemy.
- [ ] With names off and health numbers on, the enemy bar has numbers but no name.
- [ ] With names on, the selected name size appears after restarting. Restore the preferred setting afterwards.

## Check when materials become available

- [ ] Cooking: complete charred meat at a campfire. No cooking pot is needed for this recipe. Expect Food practice while below its level-2 training cap, and Workstations practice while below level 10.
- [ ] Farming: harvesting a mature crop awards Seeds practice; hitting an immature crop must not give the same harvest reward.
- [ ] Electrical salvage: salvage an object that actually yields electrical parts. Expect Electrician practice as well as any applicable salvage practice.
- [ ] Block upgrades award Repair Tools and a smaller amount of Workstations practice.
- [ ] Workstation craft: collect completed output and confirm practice is credited once, including after leaving and returning.
- [ ] Cancelling an unfinished craft or scrap awards no completion practice.
- [ ] Storage counts update when entering/leaving chest range and resources are consumed once.
- [ ] Newly generated loot/trader stock respects book toggles. Existing items can remain.

## Balance observations to collect

- [ ] Does reaching the forge feel natural through cooking/building, rather than repeatedly making campfires?
- [ ] Does the next tool technology become available before the previous tool stops feeling useful?
- [ ] Do quality upgrades feel worth their material cost?
- [ ] Can each category progress at a reasonable pace during ordinary play? Pay particular attention to armour, backpacks, traps and vehicles, whose routes rely on crafting.

## Development follow-up

- Review the balance findings in Source/BALANCE-REVIEW.md before changing rates.
- Nearby deposit/refill buttons implemented in 0.1.8; pending live checks listed below.
- Test a clean friend installation and document multiplayer requirements before presenting the pack as multiplayer-ready.

## 0.1.8 storage button checks

- [ ] Two arrow icons appear beside Inventory without covering the native controls.
- [ ] Deposit nearby moves matching unlocked items once and protects locked backpack slots.
- [ ] Refill tops up occupied locked slots and leaves empty locked slots alone.
- [ ] Out-of-range, open and unowned chests are excluded; protected chest slots stay untouched.
- [ ] Reopening inventory does not duplicate click handlers. Compare item totals before/after both transfers.
- [ ] No-op transfers explain what is missing. Right-clicking does not transfer.



## 0.1.9 quest reward checks

- [ ] With all crafting magazines disabled, newly generated magazine-bundle reward rolls offer 3 repair kits instead.
- [ ] Crafting-magazine challenge reward pools also give repair kits.
- [ ] Disabled direct book/schematic rewards become 3 repair kits; other choices, XP and Dukes stay unchanged.
- [ ] Re-enabling magazines restores the original reward pools on newly generated choices.
- [ ] Old saved choices/bundles can remain; do not treat those as newly generated rewards.


## 0.1.10 deposit/refill correction

- [ ] Left-click each button: it should now transfer items or display an explanation.
- [ ] Check locked backpack slots remain protected during deposit and refill tops up occupied locked slots.
- [ ] Recheck item totals and repeat after reopening inventory.


## 0.1.11 equipment deposit

- [ ] Deposit a baton into a chest containing the same baton type at another quality. Check separate slots, quality, condition and attached mods.
- [ ] Locked backpack items and protected chest slots stay untouched; a full chest leaves equipment in the backpack.
- [ ] Refill does not combine incompatible qualities. Different base item types do not seed the same deposit destination.

## 0.1.12 workstation quality credit

- [ ] Queue the same equipment at two different qualities, let both finish with the station closed, then open it. Confirm each quality receives its own practice reward.
- [ ] Reopen the station: practice must not be awarded again.
- [ ] Finish cooking with the campfire closed; open it to claim. Save/reload before claiming another batch and confirm it remains claimable once.
- [ ] Older completion records already merged before this update cannot be used to check the new quality separation. Use freshly queued crafts.

## 0.1.13 fuel reward check

- [ ] At Vehicle skill 20, complete 20 fuel (10 two-fuel batches) and open the chemistry station. Expect 1.76 practice at default learning speed, before any recipe falloff. At other levels/settings the reward differs. Use skill-screen totals because brief notifications may round small gains.
- [ ] Reopening the station must not credit it again. Existing levels and stored practice are retained.
- [ ] Track backpack, armour, trap and vehicle equipment progression during normal play before further rate changes.

## 0.1.14 batch consistency

- [ ] Queue enough of an outdated recipe to cross a crafting level; confirm practice reflects its reduced relevance as levels rise.
- [ ] Compare grouped and separate claims from equivalent starting levels/practice and settings. Small floating-point display differences are possible.
- [ ] Ensure ordinary single-craft and single-equipment scrap rewards match before the update.
- [ ] Training caps still stop credit, and reopening a station does not award it again.

## 0.1.15 melee grips

- [ ] At a workbench, search Workshop Light Grip Mod and Workshop Power Grip Mod. Confirm names, icons, descriptions and recipe ingredients.
- [ ] Craft one, install on a compatible melee weapon with a free slot, and remove it again.
- [ ] Light Grip lowers primary/power-attack stamina cost and increases durability loss. Compare the same weapon, perks and attack against the same target type.
- [ ] Power Grip increases damage and attack stamina cost. Other attachments/perks affect final displayed percentages.
- [ ] Both Workshop grips cannot be installed together, including when installed in the reverse order.
- [ ] Neither installs on a gun, bow or harvesting tool. Existing vanilla attachments remain usable.
- [ ] Save/reload with a grip installed: identity and effects persist.

## 0.1.16
- Relaunch from Workshop after updating. Inspect existing Light Grip Mod and Power Grip Mod: readable names, description tab, two percentage stat rows.
- Light Grip: -15% attack stamina cost and +20% durability loss. Power Grip: +10% melee damage and +15% attack stamina cost.
- No recrafting needed. Verify effects when equipped.

## 0.1.17
- Hover the green skill icon beside a recipe; check skill names and caps. Campfire icon should hide at Workstations 4.
- Food gives Workstations practice until 10; boiled water gives 2 per completed batch until 10. Open the campfire to collect completed-craft credit.
- Craft a workbench weapon/tool: its main skill plus smaller Workstations award. Repeat after level 10.
- Craft either Workshop grip: Workstations practice through 25. Scrapping equipment does not train Workstations.
- Native favorite/unlock icons and recipe selection remain usable.
- Check 0.1.16 grip names, descriptions and two stat rows.

## 0.1.18 Construction
- [x] User confirmed grip names, stat panels and descriptions work in 0.1.17.
- [ ] Light Grip now displays -15% rather than -16%; actual effect unchanged.
- [ ] Existing character has Construction 1/100 on the Crafting tab (likely second page). Select it and check description, practice bar and craft-time bonus.
- [ ] Craft frames/wood blocks, a bedroll, door or storage crate: Construction practice and recipe icon tooltip.
- [ ] Upgrade a block: Construction +0.5 practice, alongside existing Repair Tools/Workstations awards.
- [ ] Save, quit and reload: Construction level and practice persist.
- [ ] At higher levels, tagged building recipes craft faster (up to 15% less time at 100); other recipes unaffected. This needs a controlled live test.
- [ ] No existing recipe unlocks were replaced or newly gated.
- [ ] Multi-skill recipe icons remain while any route can train: after Workstations 4, a campfire can still show Construction until its own cap. Tooltip should drop only the capped Workstations route.

## 0.1.19 Preparation practice
- [ ] Cornmeal: Food base 1 practice per item. Chicken feed: Food base 2 per ten-item batch. Awards reduce past Food 10.
- [ ] Aloe cream: Medical base 2; splint: Medical base 4. Later levels apply relevance decay.
- [ ] Boiled eggs, mineral water, blackstrap coffee and canned Sham: Food plus Workstations if below 10.
- [ ] Smoothies train Food; existing biome unlocks still apply.
- [ ] Hover green icons to see skills and caps; craft and save/reload to check new practice persists.
- [ ] No changes to resource bundles, raw-meat packaging, biome outfits or forge refunds.
- [x] User confirmed Construction registration, description, practice panel and recipe hover indicators. Construction award/persistence/bonus live checks remain.

## 0.1.20 Ammunition practice
- [ ] Stone arrows/bolts train Bows; base 0.05 per projectile before relevance decay.
- [ ] 100 ball pistol rounds give Handguns base 2; a crafted 100-round bundle gives the same.
- [ ] 7.62mm splits a small award equally between Rifles and Machine Guns.
- [ ] Turret ammo trains Robotics; iron darts train Traps.
- [ ] Craft one bundle, record practice, then open it: opening adds ammo but no second practice award. Opening a looted bundle also gives none.
- [ ] Existing ammo and bundle unlock requirements still apply.
- [ ] Hover new training icons, then save/reload to check progress persists.

## 0.1.21 Attachment practice
- [ ] A pocket mod tooltip lists Backpacks; crafting gives practice.
- [ ] An armour fitting lists Armor, a drone mod Robotics, a vehicle mod Vehicles.
- [ ] Bow and shotgun specialists list their relevant skills; universal grips/scopes list Workstations.
- [ ] Existing schematics and recipe requirements still apply; no extra unlocks added.
- [ ] Installing/removing an attachment gives no practice. Crafting does.
- [ ] Original Workshop grips retain their prior stats, compatibility and practice route.
- [ ] Save/reload to check new skill practice persists.

## 0.1.22 Fixtures and manufacturing
- [ ] Craft a candle or safe: Construction icon and practice. Paintbrushes/torches also train Construction.
- [ ] Craft glue or paper, then open the campfire/chemistry station after completion to claim Workstations practice. A ten-sheet paper batch gives base 0.2 before scaling.
- [ ] Forge parts, cooking pot/grill and metal components give small manufacturing awards when completed and claimed. Raw material withdrawals do not.
- [ ] Craft 100 nails: Construction base 0.5 before relevance/learning-speed scaling.
- [ ] Final vehicle assembly trains Vehicles, in addition to the earlier component crafting. Picking up/redeploying it gives no new craft award.
- [ ] Crafted biome protection gear trains Armor; challenge requirements remain unchanged.
- [ ] A manufactured lockpick bundle matches 50 ordinary picks; opening gives no additional practice.
- [ ] Save/reload and check practice persists.

## 0.1.23 Tool choices
- [ ] Workbench lists Light Tool Grip Mod and Reinforced Tool Frame Mod without schematics. Crafting gives Workstations practice below 25.
- [ ] Inspect: names/descriptions show, with two stat rows: Light -10% stamina/+15% wear; Frame -25% wear/+10% stamina.
- [ ] Install in an eligible axe/pick/shovel or wrench/ratchet/impact driver with a free slot; actual stamina/wear tradeoff works.
- [ ] Only one of the two Workshop tool choices can be installed at once.
- [ ] Chainsaws, augers, repair hammers, nailguns and weapons reject them.
- [ ] Removing and reinstalling gives no practice; mods remain after save/reload.
- [ ] Original melee grips retain their previous stats and compatibility.