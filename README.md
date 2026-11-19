# Grimmer Workshop

A solo PvE mod pack for **7 Days to Die V3.4 b10**, with crafting progression through play, nearby storage and a Windows updater.

## Current testing release: 0.1.32

Adds composting and material-saving restored workstations. A Compost Bin processes rotten flesh/fibres into Compost; the alternative Farm Plot uses less nitrate. Four Restored stations keep normal unlocks, fuel, tools and speed. Includes optional support for separately installed Guppy 3.0.3.0 (21-entity conservative spawn companion) and Bdub 3.4.0.2 (practice for 106 vehicle/component outputs). No original external models, sounds or author files are bundled. Actual model/spawn/driving and station checks remain pending. Vehicle inspection development is parked; 0.1.31 ordinary-car menu behavior is not claimed fixed.

Optional full DSD Arsenal 1.2.1 support: install the author pack separately from https://www.nexusmods.com/7daystodie/mods/13921 into your Workshop Profile/Mods folder. Workshop adds practice for all 53 weapons and Energy Cells. The pack provides the actual new models and animations; its files are not modified or bundled here. Existing 635 base routes retained; 54 optional routes. Live pack checks pending.

Adds a Cooking Stove at Food 20: craft at a workbench with 10 forged iron, 4 short iron pipes, 4 mechanical parts and 10 small stones. Uses normal fuel and cooking tools; supports all 49 campfire recipe variants in 25% less time, preserving original requirements and practice. Uses the native wood-burning stove model. Live checks pending.

Also includes all previously published updates:

- **Vehicle inspection:** hold use on an abandoned sedan, police car, bus, ambulance, minivan, pickup or supported truck and inspect for parts. One saved recovery per vehicle position. Normal Search and wrench salvage remain available. Unlock locked vehicles first.
- **Engine restoration:** recover a Damaged Engine Assembly, then rebuild it at a workbench with 10 forged iron, 12 mechanical parts, 4 oil and 2 duct tape. Completion awards Vehicles practice.
- **Empty owned storage pickup:** hold use on your wooden, iron or steel crate. Empty, repair, unlock and close it first. Ownership and contents are checked again after the pickup timer. Sign text resets when replaced.
- **Gunsmith Bench:** unlock at Workstations 20. Craft with one additional workbench item, 10 forged iron, 10 mechanical parts and 4 duct tape. Its 118 supported weapon/ammo/attachment recipe variants take 15% less time while keeping original requirements, costs and practice. Uses the native workbench model/interface.

Existing progression includes 641 practice routes, Construction, quality-scaled crafting practice, activity learning, book toggles, nearby crafting and protected inventory transfers. No external weapon, enemy or vehicle model packs are included yet.

## Optional zombie and vehicle models

Download original [Guppycur Zombies](https://www.nexusmods.com/7daystodie/mods/4412) and [Bdub Vehicles](https://www.nexusmods.com/7daystodie/mods/342) separately. Workshop recognises exact inspected versions 3.0.3.0 and 3.4.0.2 respectively, in Profile/Mods/Guppy_Zombies_V3 and Profile/Mods/BdubsVehicles. Author files remain unchanged. Existing worlds do not automatically gain a newly generated mechanic trader POI. No vehicle-wreck recovery or new wildlife pack is claimed.

## Existing players

Save and close the game. Open your existing Workshop launcher, choose **testing**, click **Check for updates**, then **Install update**. Launch through Workshop again so its configuration helpers run. Keep your current world; these updates do not require starting over. Back up saves before testing.

Vehicle inspection history is stored as `GrimmerVehicleInspections.xml` alongside the world save. Back it up with the world. Already inspected positions stay depleted, including after POI resets.

## First installation

[Download Grimmer Workshop 0.1.32](https://github.com/andrewrobb247/grimmer-workshop/raw/refs/heads/main/Grimmer-Workshop-0.1.32.zip)

Extract the whole Grimmer-Workshop folder somewhere permanent. Keep Steam running, close the game, then use Launch-Workshop.cmd. The launcher uses a separate Profile folder and disables EAC. Full original source, build scripts, tests and documentation are included in the archive. Do not extract an entire new package over an existing profile merely to update; use the launcher.

## Validation and pending checks

Production build and automated state, menu, storage, progression and optional Arsenal tests pass. Hosted payload and original updater checks are recorded in PUBLICATION.md after publication.

Build and automated tests pass. Actual placement, rewards, recipe gates, queue timing, save/reload and native interactions still need live checks. See [PLAYTEST-CHECKLIST.md](PLAYTEST-CHECKLIST.md).

External content ideas are research only. Permissions and integration notes are included under Source/NEXUS-CONTENT-IDEAS.md in the source archive.