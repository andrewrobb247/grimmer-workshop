# Grimmer Workshop

Personal solo PvE mod pack for **7 Days to Die V3.4 b10**, with a separate profile and a Windows launcher.

## Install and update

**Already using the Workshop launcher?** Save and quit the game, click **Check for updates**, then **Install update** on the **testing** channel. Close and reopen the launcher afterwards. Your world, practice and personal settings are kept.

**New installation:** [Download Grimmer Workshop 0.1.4](https://github.com/andrewrobb247/grimmer-workshop/raw/refs/heads/main/Grimmer-Workshop-0.1.4.zip). Extract the complete folder, keep Steam running and open `Launch-Workshop.cmd`. The full original source and tests are included.

For an old installation without the launcher: [one-time updater setup](https://github.com/andrewrobb247/grimmer-workshop/raw/refs/heads/main/Workshop-Updater-Setup.zip), then check for updates in that launcher. Requires your own Steam game. Solo only; co-op is not implemented.

## 0.1.4: learn through play

- All 24 crafting skills have magazine-free crafting routes. An audit checks all 2,021 level transitions for unlock gaps.
- Gathering with tools, actual weapon damage, mature crop harvesting, electrical salvage, equipment repairs, block upgrades and medical use now grant relevant crafting-skill practice.
- Completed crafts and equipment scrapping retain their quality-based rewards. Q3 axe crafting (+15) and player-crafted Q3 scrapping (+1.5) were checked in-game.
- Short practice notifications and friendly skill names make progress easier to follow.
- **Gameplay settings / books** offers 226 individual book toggles. New crafting-magazine rolls default to paper; perk books and schematics remain enabled. Existing items are kept.
- Disabling perk books or schematics does not provide alternative routes to their unique bonuses yet. Crafting magazines never raise crafting skills, even when their loot checkbox is enabled.
- The launcher preserves saves/settings, verifies downloaded files and game compatibility, downloads only changes and keeps a rollback backup.

This is a testing preview, with no stable release yet. The new activity events and gameplay settings window still require a live check. Driving, wearing armour and idle movement do not yet grant activity practice; all crafting routes remain available. Detailed rewards, caps and controls are in the included README and `Source/PROGRESSION-AUDIT.md`.

Validation: 2,061 algorithm checks, 28 updater checks, and book-policy checks covering 226 items and 247 loot/trader references. The updater's online install/rollback was tested while preserving a test world and settings. No world reset is needed for this update.

No game binaries, saved worlds, credentials or personal logs are distributed. Source, build scripts and tests are included in the full ZIP. `channels/testing.json` selects the release from its version directory.
