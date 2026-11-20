# Action skill practice preview

This is an optional, tracking-only test of the first learn-by-doing slice. It does not add skill ranks, spend or award points, change attributes, or alter existing progression.

## Enable it

Open **Gameplay settings / books** in the Workshop launcher. Turn on **Enable action-skill practice preview** and choose a preview learning speed. Save, close the launcher, and start the game again.

The preview is off by default. Disable it at any time from the same settings screen.

## What this build records

| Skill | Recorded practice |
| --- | --- |
| Dead Eye | Real rifle damage; a bounded bonus for confirmed headshots |
| Spear Master | Real spear damage |
| Boomstick | Real shotgun damage |
| Pummel Pete | Real club damage |
| Skull Crusher | Real sledge damage |
| Archery | Real bow/crossbow damage; a bounded bonus for confirmed headshots |
| Deep Cuts | Real knife/machete damage |
| Electrocutioner | Real baton damage |

The matching parent attribute receives one contribution per weapon action frame. This prevents pellet and multi-target callbacks from multiplying the parent award. Damage practice is based on health actually removed, with a per-hit cap; misses and overkill earn none.

The skill details panel shows the preview status and accumulated base/bonus practice for these eight skills. The other proposed weapon bonuses, passive skills, and masteries are displayed as not recorded yet. The preview does not claim that an unobserved action is working.

## First playtest

Use ordinary combat first, then compare the displayed practice after:

- regular body hits and a confirmed headshot with rifles and bows;
- hits with a spear, shotgun, club, sledge, knife, and baton;
- multiple shotgun pellets or a melee hit that damages more than one enemy;
- reloading, power attacks, aiming, and status effects, which this build does not yet count.

Please note whether practice feels too fast or slow and whether any displayed total changes when it should not. This is a recorder test; no perk rank should increase from it.
