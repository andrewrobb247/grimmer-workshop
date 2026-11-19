# Grimmer Workshop

A solo PvE mod pack for **7 Days to Die V3.4 b10**, with crafting progression through play, nearby storage and a Windows updater.

## Current testing release: 0.1.28

Adds a Cooking Stove at Food 20: craft at a workbench with 10 forged iron, 4 short iron pipes, 4 mechanical parts and 10 small stones. Uses normal fuel and cooking tools; supports all 49 campfire recipe variants in 25% less time, preserving original requirements and practice. Uses the native wood-burning stove model. Live checks pending.

Also includes all previously published updates:

- **Vehicle inspection:** hold use on an abandoned sedan, police car, bus or ambulance and inspect for parts. One saved recovery per vehicle position. Normal Search and wrench salvage remain available. Unlock locked vehicles first.
- **Engine restoration:** recover a Damaged Engine Assembly, then rebuild it at a workbench with 10 forged iron, 12 mechanical parts, 4 oil and 2 duct tape. Completion awards Vehicles practice.
- **Empty owned storage pickup:** hold use on your wooden, iron or steel crate. Empty, repair, unlock and close it first. Ownership and contents are checked again after the pickup timer. Sign text resets when replaced.
- **Gunsmith Bench:** unlock at Workstations 20. Craft with one additional workbench item, 10 forged iron, 10 mechanical parts and 4 duct tape. Its 118 supported weapon/ammo/attachment recipe variants take 15% less time while keeping original requirements, costs and practice. Uses the native workbench model/interface.

Existing progression includes 635 practice routes, Construction, quality-scaled crafting practice, activity learning, book toggles, nearby crafting and protected inventory transfers. No external weapon, enemy or vehicle model packs are included yet.

## Existing players

Save and close the game. Open your existing Workshop launcher, choose **testing**, click **Check for updates**, then **Install update**. Launch through Workshop again so its configuration helpers run. Keep your current world; these updates do not require starting over. Back up saves before testing.

Vehicle inspection history is stored as `GrimmerVehicleInspections.xml` alongside the world save. Back it up with the world. Already inspected positions stay depleted, including after POI resets.

## First installation

[Download Grimmer Workshop 0.1.28](https://github.com/andrewrobb247/grimmer-workshop/raw/refs/heads/main/Grimmer-Workshop-0.1.28.zip)

Extract the whole Grimmer-Workshop folder somewhere permanent. Keep Steam running, close the game, then use Launch-Workshop.cmd. The launcher uses a separate Profile folder and disables EAC. Full original source, build scripts, tests and documentation are included in the archive. Do not extract an entire new package over an existing profile merely to update; use the launcher.

## Validation and pending checks

All 23 hosted release/identity/source-archive/README files matched staging before the testing channel was enabled. The unchanged original 0.1.10 updater detected 0.1.28 and accepted all 20 runtime update files under Windows PowerShell 5.1.

Build and automated tests pass. Actual placement, rewards, recipe gates, queue timing, save/reload and native interactions still need live checks. See [PLAYTEST-CHECKLIST.md](PLAYTEST-CHECKLIST.md).

External content ideas are research only. Permissions and integration notes are included under Source/NEXUS-CONTENT-IDEAS.md in the source archive.