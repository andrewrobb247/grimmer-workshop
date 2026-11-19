# Workshop playtest checklist

Updated 19 November 2026. Current testing release: 0.1.28. Latest published release: 0.1.28.
Keep using the current world. Pending means not yet confirmed in live play.

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