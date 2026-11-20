# Learn by Doing: 0.1.41 testing build

Learn by Doing now changes the player's native perk and attribute ranks. It is enabled by default when the setting is missing. Open **Gameplay settings / books** in the launcher to change the mode or adjust its speed. Existing ranks are left as they are. While enabled, spendable skill points are banked and restored if the mode is later turned off. The mode still respects the game's native player level and attribute gates for each rank.

## What currently earns practice

- Real damage from mapped rifles, shotguns, spears, clubs, sledges, bows, blades, batons, pistols, machine guns, knuckles, explosives and robotic weapons trains the corresponding weapon perk. A confirmed rifle, bow or pistol headshot adds a bounded bonus.
- Weapon use gives a smaller share to the parent attribute and, where mapped, a secondary combat perk. Attribute practice can also advance the matching mastery after its native gates are met.
- Existing completed-craft, useful-harvest, block-upgrade, repair and quest-completion events award the mapped perk and attribute practice.
- Existing preview counters are transferred once into the live practice ledger when Learn by Doing starts.

The damage amount is capped per hit and is based on health actually removed, so misses and overkill give no practice. Damage is enough to start training; no special effect is required. Repeatedly applying a status is not a practice route.

## What to look for in-game

1. Start a solo save with Learn by Doing enabled.
2. Damage a zombie with the Break-Action Rifle. The Dead Eye progress bar should move; its rank should increase automatically after enough practice and when native requirements are met.
3. Check the Perception bar too. Existing Perception rank should stay unchanged until its own practice threshold is met.
4. Open the skill screen to see practice, next-rank progress and current rank. Level-up notices appear when a rank changes.

Rifle damage and a few combat bonuses are the first direct weapon routes. Reloads, power attacks, fresh status attribution, passive travel/stealth, loot searches, trading and several other proposal routes still need verified event hooks. Test the progress rate before we tune the default speed or claim those routes are complete. This release has not been validated in a live game session yet.
