# Grimmer Workshop

A solo PvE mod pack for **7 Days to Die V3.4 b10**, with crafting progression through play, nearby storage and a Windows updater.

## Current testing release: 0.1.35

Audit repairs: fixes the malformed zombie-filter companion metadata that caused filtering to be skipped, fills 16 missing decor names and 23 descriptions (39 English entries), and validates Workshop-generated XML before game launch. 395 player-facing entries resolve English text, 361 recipes resolve references, and all 284 original external files match recorded originals. [Audit details](AUDIT-REPORT.md). Use the existing testing updater, then Play; no separate external download for these fixes. Models/animations/driving/crop timing remain live checks.

Optional full DSD Arsenal 1.2.1 support: install the author pack separately from https://www.nexusmods.com/7daystodie/mods/13921 into your Workshop Profile/Mods folder. Workshop adds practice for all 53 weapons and Energy Cells. The pack provides the actual new models and animations; its files are not modified or bundled here. Existing 635 base routes retained; 54 optional routes. Live pack checks pending.

Adds a Cooking Stove at Food 20: craft at a workbench with 10 forged iron, 4 short iron pipes, 4 mechanical parts and 10 small stones. Uses normal fuel and cooking tools; supports all 49 campfire recipe variants in 25% less time, preserving original requirements and practice. Uses the native wood-burning stove model. Live checks pending.

Also includes all previously published updates:

- **Vehicle inspection: parked.** Ordinary vehicles were reported to open normal loot. Recovery interaction is not an active supported feature; revisit only with a future vehicle-recovery design.
- **Engine restoration:** recover a Damaged Engine Assembly, then rebuild it at a workbench with 10 forged iron, 12 mechanical parts, 4 oil and 2 duct tape. Completion awards Vehicles practice.
- **Empty owned storage pickup:** hold use on your wooden, iron or steel crate. Empty, repair, unlock and close it first. Ownership and contents are checked again after the pickup timer. Sign text resets when replaced.
- **Gunsmith Bench:** unlock at Workstations 20. Craft with one additional workbench item, 10 forged iron, 10 mechanical parts and 4 duct tape. Its 118 supported weapon/ammo/attachment recipe variants take 15% less time while keeping original requirements, costs and practice. Uses the native workbench model/interface.

Existing progression includes 643 practice routes, Construction, quality-scaled crafting practice, activity learning, book toggles, nearby crafting and protected inventory transfers. No external weapon, enemy or vehicle model packs are included yet.

## Optional zombie and vehicle models

Download original [Guppycur Zombies](https://www.nexusmods.com/7daystodie/mods/4412) and [Bdub Vehicles](https://www.nexusmods.com/7daystodie/mods/342) separately. Workshop recognises exact inspected versions 3.0.3.0 and 3.4.0.2 respectively, in Profile/Mods/Guppy_Zombies_V3 and Profile/Mods/BdubsVehicles. Author files remain unchanged. Existing worlds do not automatically gain a newly generated mechanic trader POI. No vehicle-wreck recovery or new wildlife pack is claimed.

## Optional decor and map

Download original [GNS Beautiful Bases](https://www.nexusmods.com/7daystodie/mods/3318) and [Looted](https://www.nexusmods.com/7daystodie/mods/13822) separately. The inspected Beautiful Bases archive is labelled 3.7 with ModInfo 2.0; Workshop recognises its exact 16-recipe layout. Looted is version 3.4.9. Keep author files intact in Profile/Mods/GNS_BeautifulBases and Profile/Mods/Looted. See [DOWNLOAD-COMPATIBILITY.md](DOWNLOAD-COMPATIBILITY.md) for static checks and remaining live tests.

## Wildlife and pack status

Separately install original [Livelier Wildlife](https://www.nexusmods.com/7daystodie/mods/14042), inspected version 1.0.0 / folder FMG_LivelierWildlife. No DLL or replacement AI; uses native animals. Native requirements/actions, entity references and biome/buff targets check out. Event-spawned animals may persist longer than biome animals, so live population/performance checks remain. Reopen launcher after updating to see Optional packs / versions. Recognised metadata is not proof of loaded state or live compatibility.

## Existing players

Save and close the game. Open your existing Workshop launcher, choose **testing**, click **Check for updates**, then **Install update**. Launch through Workshop again so its configuration helpers run. Keep your current world; these updates do not require starting over. Back up saves before testing.

Vehicle inspection history is stored as `GrimmerVehicleInspections.xml` alongside the world save. Back it up with the world. Already inspected positions stay depleted, including after POI resets.

## First installation

[Download Grimmer Workshop 0.1.35](https://github.com/andrewrobb247/grimmer-workshop/raw/refs/heads/main/Grimmer-Workshop-0.1.35.zip)

Extract the whole Grimmer-Workshop folder somewhere permanent. Keep Steam running, close the game, then use Launch-Workshop.cmd. The launcher uses a separate Profile folder and disables EAC. Full original source, build scripts, tests and documentation are included in the archive. Do not extract an entire new package over an existing profile merely to update; use the launcher.

## Validation and pending checks

Production build and automated state, menu, storage, progression and optional Arsenal tests pass. Hosted payload and original updater checks are recorded in PUBLICATION.md after publication.

Build and automated tests pass. Actual placement, rewards, recipe gates, queue timing, save/reload and native interactions still need live checks. See [PLAYTEST-CHECKLIST.md](PLAYTEST-CHECKLIST.md).

External content ideas are research only. Permissions and integration notes are included under Source/NEXUS-CONTENT-IDEAS.md in the source archive.