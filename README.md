# Grimmer Workshop

Personal solo PvE mod pack for **7 Days to Die V3.4 b10**, with a separate profile and a small Windows launcher.

## Download

- **New installation:** [Grimmer Workshop 0.1.3](https://github.com/andrewrobb247/grimmer-workshop/raw/refs/heads/main/Grimmer-Workshop-0.1.3.zip). Extract the entire folder, keep Steam running, then open `Launch-Workshop.cmd`.
- **Already playing Workshop:** [Install the updater](https://github.com/andrewrobb247/grimmer-workshop/raw/refs/heads/main/Workshop-Updater-Setup.zip). Save and quit, extract, then run `Install-Updater.cmd`. It adds the launcher to your existing installation and keeps your world and settings.

After the one-time setup, use **Check for updates** and **Install update** in the launcher. Only changed files download. Backups, rollback and game-version checks are included. Offline play works too.

## First testing preview

The testing channel contains 0.1.3. No stable release is published yet. Higher-quality crafting and equipment scrapping practice still need a live game check. Stable will follow that check.

- Learn the vanilla crafting skills by completing crafts and using their normal unlock milestones.
- Quality bonuses range from Q1 x1 to Q6 x2.5.
- Completed equipment scraps give smaller skill-practice rewards; raw materials and cancelled scraps give none.
- Craft using eligible nearby owned storage, with ingredient counts shown in the recipe UI.
- Preserve locked backpack slots during manual bulk deposit/refill.
- Configure the enemy health display using its preview window.

The mod remains **solo only**. Sharing it for another person to play solo is supported; co-op is not implemented. Each player needs their own game installation. No game binaries, saves, credentials or personal logs are included.

## Source and validation

The complete original source, build scripts, generated configuration and tests are included inside the full download under `Source`, `Tests`, `Build.ps1`, `Build-Release.ps1` and the launcher scripts. Detailed usage and limits are in the included README.

Validation: 2,054 practice/storage/recipe-UI regression checks, 28 updater checks under Windows PowerShell 5.1, and a bootstrap installation test preserving a test world. New quality/scrap behavior and the first visible launcher run still require live checking. This is an early personal project, not a completed overhaul.

`channels/testing.json` selects the current testing version; `versions/0.1.3` holds its verified runtime files. Existing personal settings are preserved by updates and rollback.
