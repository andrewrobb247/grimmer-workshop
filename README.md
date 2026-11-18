# Grimmer Workshop

Personal solo PvE mod pack for **7 Days to Die V3.4 b10**, with a separate profile and a Windows launcher.

## Install and update

Already using the launcher? Save and quit, choose **testing**, click **Check for updates**, then **Install update**. Reopen the launcher afterwards. Saves, practice and personal settings are preserved.

New players: [download Workshop 0.1.6](https://github.com/andrewrobb247/grimmer-workshop/raw/refs/heads/main/Grimmer-Workshop-0.1.6.zip), extract the complete folder, keep Steam running and open `Launch-Workshop.cmd`. Your own game installation is required. Solo only; co-op is not implemented.

Old installations without the launcher can use the [one-time updater setup](https://github.com/andrewrobb247/grimmer-workshop/raw/refs/heads/main/Workshop-Updater-Setup.zip), then update from the launcher. No account or Git installation is needed for public updates.

## 0.1.6: crafting skill screen

Fixes the empty practice panel and missing row bars seen in 0.1.5: the game lowercases runtime skill identifiers, which now resolve to the existing practice keys. No save changes or rate changes. The lowercase fixture reproduced the failure and now passes.

Open **Skills → crafting-skills tab → select a skill** to see saved practice, a progress bar, how to train and the next vanilla recipe/quality milestone. Crafting rows also show practice bars. The original unlock icons and recipe/quality table remain, using native paging to make room. Long next-unlock text has a full tooltip. Completed skills and already-completed recipe milestones have explicit states.

This is a testing preview. The new rendered skill-screen layout still needs an in-game check. UI queries do not change progress, and gameplay rates are unchanged.

## Progress by playing

- All 24 crafting skills have magazine-free crafting routes; an audit covers all 2,021 level transitions.
- Completed crafts and equipment scraps grant quality-based practice.
- Gathering, actual weapon damage, mature crop harvesting, electrical salvage, equipment repairs, block upgrades and medical use grant relevant practice.
- **Gameplay settings / books** offers 226 individual book toggles. Crafting magazines default off for new loot/trader rolls, which become paper. Perk books and schematics stay enabled; their unique bonuses have no replacement yet if you disable them.
- Nearby owned-storage crafting includes ingredient counts. Manual bulk transfers respect protected backpack slots.
- The launcher verifies changed downloads and game compatibility, keeps a rollback backup, and preserves worlds/settings. Offline play remains available.

Crafting, Q3 scrapping, harvesting, club combat and equipment repairs have been confirmed in-game. Cooking, crop harvesting and electrical salvage checks remain pending normal play. No stable channel is published yet.

Validation: 2,084 algorithm/binding regression checks, 24 skill-screen XML layout checks, 28 updater checks and book-policy checks across 226 items and 247 loot/trader references. Online updating/rollback was tested preserving a test world and settings.

The full ZIP includes original source, build scripts, tests and `Source/PROGRESSION-AUDIT.md`. No game binaries, saves, credentials or personal logs are distributed. `channels/testing.json` selects the runtime files under their version directory.

