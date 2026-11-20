# Learn by Doing: 0.1.43 testing build

Learn by Doing advances native perk and attribute ranks from practice. It is enabled by default when no preference is saved. The launcher’s **Gameplay settings / books** screen controls it and adjusts the learning speed. Existing ranks are preserved; spendable skill points are banked while the mode is on and restored if it is later turned off. The game’s native player level and attribute requirements still gate rank-ups.

## What earns practice

- Confirmed damage to hostile zombies and animals trains its matching weapon perk. Weapon damage is the base route; headshots add a bounded precision bonus. Weapon use also gives a smaller parent-attribute share and relevant secondary combat practice.
- Completed crafts, useful harvests, repairs, block upgrades, and quest hand-ins train their mapped skills.
- Movement practice is tied to on-foot distance, sprinting, jumping, encumbrance, crouched movement, and recent combat. Incoming hostile damage, real recovery, and melee attacks while wounded can train Fortitude skills.
- Armor practice is earned during hostile combat with worn armor. Loot-container opens, changed trader inventory, active lockpick use, trap interaction, and shovel digging have limited activity routes.
- Attribute practice can advance the matching mastery after its native gates are met. Practice counters and ranks are separate, and no special effect is required to begin weapon-skill progression.

Repeat-sensitive routes are distance based, deduplicated, or cooldown limited. Several proposed specialty bonuses still need tuning and confirmation in a live game, especially fresh stun/bleed attribution and the exact power-attack, encumbrance, and modded-content signals.

## In-game check

1. Open launcher **Gameplay settings / books**, confirm **Learn by Doing** is enabled, and leave learning speed at `1.0` for the first check.
2. Load the solo save and shoot a zombie with the Break-Action Rifle. The **Dead Eye** practice bar should move immediately; the **Perception** bar should also gain a smaller amount.
3. After enough practice, Dead Eye should rank up automatically once the game’s native requirements are met. Skill points should remain banked while Learn by Doing is on.
4. To check another route, sprint on foot, jump across a gap, loot a previously unopened container, trade with a trader, or fight while wearing armor. Compare the related skill bar before and after each activity.

If a bar does not move, the first useful details are the selected skill, action, launcher version, and whether the game log contains a `[Grimmer Workshop]` error. Ranks are modified only in the active save; this code has compiled against the installed V3.4 b10 assemblies but has not yet been verified in a live game session.
