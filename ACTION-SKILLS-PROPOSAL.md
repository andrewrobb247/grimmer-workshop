# Learning by doing: attributes and perks

Implementation status - testing build 0.1.41. Learn by Doing now uses the 62 generated skill definitions and native rank gates; weapon damage and several crafting, harvest and quest routes raise real ranks. Specialized routes remain under implementation and in-game balance testing. The design below remains the intended coverage for all five attributes and 57 gameplay perks. Crafting magazines/book-set completions are separate systems, not omitted gameplay perks.

## Recommended model

Actions earn practice in the matching gameplay perk, a smaller share in the parent attribute, and the existing crafting practice where relevant. One attributed action creates one parent-attribute award, even when it trains several related perks. Keep normal player XP/level and quest rewards; remove spendable skill points only when this optional mode is enabled. Do not turn all character XP into all skills.

Example: a knife hit trains Deep Cuts primarily, a smaller Whirlwind share, and one Agility share. Skinning trains Huntsman and a smaller Deep Cuts share; it does not automatically count as an Agility combat hit. A sledge hit trains Skull Crusher and Strength. Carrying an overloaded pack trains Pack Mule and Strength only while travelling on foot. Existing crafting practice remains; this does not replace recipe learning with combat-only requirements.

## Attribute routes

| Attribute | Productive actions |
| --- | --- |
| Strength | Clubs, sledgehammers, shotguns, mining/chopping and loaded on-foot travel. |
| Perception | Rifles, spears, explosives, salvage, treasure recovery, first world-loot searches and lockpicking. |
| Fortitude | Knuckles, machine guns, hunting, mature-crop harvesting, sustained running and surviving genuine fights. |
| Agility | Knives, bows, handguns, meaningful jumping, undetected movement near enemies and moving during combat/reloads. |
| Intellect | Batons, robotics, engineering/electrical production, medicine, vehicle work, genuine trading and quests. |

General perks have independent practice meters. For their smaller attribute share, use Light Armor -> Agility; Medium Armor -> Fortitude; Heavy Armor -> Strength; Master Chef -> Intellect; Living off the Land -> Fortitude; Lock Picking and Lucky Looter -> Perception. These are proposed affinities, not native attribute gates.

## All gameplay perks

### Perception

| Skill | Maximum ranks | Proposed training |
| --- | --- | --- |
| Dead Eye | 5 | Deal real rifle damage; small precision bonus for confirmed headshots. |
| Demolitions Expert | 5 | Deal real explosive damage to hostiles; useful destruction of previously intact world obstacles, with a strict area budget. |
| Spear Master | 5 | Deal real spear damage, including power attacks. |
| Quick and Perceptive | 5 | Spear combat; small secondary share of the same confirmed hit. |
| The Infiltrator | 5 | Discover previously unrecorded live mines/traps at close range; safely clear those hazards. Never require taking trap damage. |
| Animal Tracker | 5 | First close-range discovery of a living wild animal, then successfully hunt it. Discovery route must work at rank zero without tracking markers. |
| The Penetrator | 5 | Confirmed rifle headshots and damage to armoured hostiles; verified penetration may earn a bounded bonus. |
| Treasure Hunter | 5 | Complete buried-supply/treasure digs and first-open buried treasure; useful excavation inside the active objective area. |
| Salvage Operations | 5 | Recover real materials with salvage tools from world objects; no rewards for damage without recovered resources. |
| Perception Mastery | 5 | Small advanced-practice share from Perception activities once the native mastery entry requirement is met. |

### Strength

| Skill | Maximum ranks | Proposed training |
| --- | --- | --- |
| Boomstick | 5 | Deal real shotgun damage to hostiles. |
| Pummel Pete | 5 | Deal real club/bat damage to hostiles. |
| Skull Crusher | 5 | Deal real sledgehammer damage to hostiles. |
| Grand Slam | 5 | Club/bat/sledge power hits and actual knockdowns; no extra credit for striking an already defeated target. |
| Big and Fast | 5 | Club/bat/sledge combat; small secondary share of confirmed hits. |
| Pack Mule | 5 | Travel on foot with genuine encumbrance, credited by distance and load. Standing still, teleporting or riding gives none. |
| Strength Mastery | 5 | Small advanced-practice share from Strength activities once the native mastery entry requirement is met. |
| Miner 69'er | 5 | Extract real wood, stone and ore with the appropriate mining/harvesting tools. |
| Mother Lode | 5 | Recover real natural resources while mining; normalize bulk yields so large stacks cannot bypass the curve. |
| Junk Miner | 5 | Recover resources from non-natural world blocks and scrap piles with appropriate tools; exclude player-placed break/rebuild loops. |

### Fortitude

| Skill | Maximum ranks | Proposed training |
| --- | --- | --- |
| The Brawler | 5 | Deal real fist/knuckle damage to hostiles. |
| Machine Gunner | 5 | Deal real machine-gun damage to hostiles. |
| Lightning Hands | 5 | Fist/knuckle combat; small secondary share of confirmed hits. |
| The Huntsman | 5 | Harvest genuine animal corpses for meat, hide and bone; each corpse has a total practice budget. |
| Pain Tolerance | 5 | Survive a genuine hostile encounter with incoming enemy damage; bounded encounter award, no self/fire/fall/friendly damage. |
| Fortitude Mastery | 5 | Small advanced-practice share from Fortitude activities once the native mastery entry requirement is met. |
| Siphoning Strikes | 5 | Successful melee combat while actually wounded; bounded recovery/combat share without requiring the perk effect at rank zero. |
| Healing Factor | 5 | Recover health actually lost to recent hostile damage; budget by original injury and exclude self-inflicted healing loops. |
| Iron Gut | 5 | Restore genuine hunger/thirst with food and drink during active play. Nutrition variety can help; consuming at full needs gives none. |
| Rule 1: Cardio | 5 | Sustained on-foot sprinting credited by valid distance and stamina effort; no running against a wall. |

### Agility

| Skill | Maximum ranks | Proposed training |
| --- | --- | --- |
| Archery | 5 | Deal real bow/crossbow damage to hostiles. |
| Gunslinger | 5 | Deal real pistol/revolver/SMG damage according to native weapon perk tags. |
| Deep Cuts | 5 | Deal real knife/blade damage; skinning offers a smaller useful-action route. Bleed damage is attributed once to its originating attack. |
| Whirlwind | 5 | Knife/blade combat; small secondary share of confirmed hits. |
| Run and Gun | 5 | Move on foot while reloading a weapon used in a recent hostile encounter; no empty-magazine idle reload farming. |
| Hard Target | 5 | Move/sprint while actively pursued or attacked by a hostile, using distance and encounter budgets rather than requiring damage taken. |
| Parkour | 5 | Meaningful jumps/vaults with displacement or height gain during travel; repeated jumps in the same spot diminish to zero. |
| Agility Mastery | 5 | Small advanced-practice share from Agility activities once the native mastery entry requirement is met. |
| Hidden Strike | 5 | Deal confirmed sneak-attack damage to unaware hostiles. |
| From The Shadows | 5 | Travel undetected near actual unaware hostiles; first infiltration/escape per encounter. Empty-room crouching gives none. |

### Intellect

| Skill | Maximum ranks | Proposed training |
| --- | --- | --- |
| Electrocutioner | 5 | Deal real baton/stun-baton damage to hostiles. |
| Robotics Inventor | 5 | Player-owned deployed turret/robotic-sledge damage to hostiles, plus actual robotics assembly/repair; retain ownership attribution. |
| Calculated Attack | 5 | Baton combat; small secondary share of confirmed hits. |
| Better Barter | 5 | Complete genuine item trades with traders, with daily economic budgets and reverse-transaction suppression; no buy/sell-back loop. |
| The Daring Adventurer | 5 | Complete unique trader quests and higher difficulty objectives; credit once per quest instance. |
| Charismatic Nature | 5 | Finish cooperative objectives/support allies; solo alternative through successful trader quest hand-ins. No party required to start. |
| Physician | 5 | Restore real missing health or treat a genuine injury with medical items; credit each injury/recovery only once. |
| Advanced Engineering | 5 | Complete useful station/electrical/construction production, repair machinery or install a newly working circuit; no placement/pickup loops. |
| Grease Monkey | 5 | Assemble vehicle components/vehicles, repair real vehicle damage, and maintain them; ordinary driving offers a small capped route. |
| Intellect Mastery | 5 | Small advanced-practice share from Intellect activities once the native mastery entry requirement is met. |

### General perks

| Skill | Maximum ranks | Proposed training |
| --- | --- | --- |
| Light Armor | 4 | Move and fight in light armour during genuine hostile encounters; credit activity, not standing in armour. |
| Medium Armor | 4 | Move and fight in medium armour during genuine hostile encounters; mixed sets split a single armour-practice budget. |
| Heavy Armor | 4 | Move and fight in heavy armour during genuine hostile encounters; no reward for deliberately taking self damage. |
| Master Chef | 3 | Complete actual food/drink preparation, scaled to recipe work and cost; exclude wrapping/unwrapping the same food. |
| Living off the Land | 3 | Harvest mature planted crops and produce seeds/compost; no credit for planting and immediately removing the same seed. |
| Lock Picking | 3 | Successfully open a previously locked world container with lockpicks; never credit relocking owned storage. |
| Lucky Looter | 1 | First search of genuine world loot, with lower budget for trash and no reopening player containers. |

## Progression and balance

- Retain attribute ranks 1-10 and each native perk rank limit. Rank costs should rise substantially; low-tier actions remain useful with diminishing returns, while meaningful harder activity earns more. No rate is final until playtested.
- Use normalized activity units before XP: real health removed, useful resources recovered, validated travel distance, completed recipes and unique objectives. Do not pay by mouse click or weapon swing.
- Suggested initial curve for experiments: perk rank requirement 100 x (next rank)^1.6 practice; attribute requirement 500 x (next rank - 1)^1.8. These are tuning seeds, not hours-to-max promises; calibrate real activity rates first.
- Keep native attribute gates initially. Perk practice can fill the next rank while its attribute catches up, with a one-rank bank limit; display the exact gate. Masteries open at their native entry condition, then learn from advanced category actions. Do not invent impossible rank-zero requirements.
- No forced multi-weapon checklist: a knife specialist can eventually raise Agility by using knives, while variety can give a modest bonus. No profession becomes permanently inaccessible.
- Count outcomes once, exclude overkill/corpses/player damage where inappropriate, and budget each victim, corpse, location, trade reversal, quest and real-time window. Attribute gain is based on source action, not the sum of all derived perk awards.
- Encumbrance uses distance and moderate load; jumping uses displacement; sneak practice requires an actual hostile. Avoid encouraging starvation, injury farming or standing AFK. Armour progress comes from active encounters, not intentional damage.

## Character migration and options

Offer Vanilla points / Learn by doing as a gameplay setting, with independent learning speed and notifications. Default mode must remain unchanged until the user chooses the overhaul. Save a world/player-keyed practice ledger. Preserve all existing ranks and equipment; do not reset this character. Disable new point grants and purchase actions in the chosen mode, while displaying practice/gates in place of point cost. Archive existing unspent points for an explicit return to vanilla mode; do not duplicate or silently spend/refund them. The vanilla mode migration policy must be finalized before enabling switches on live saves.

Book-set perks and schematics stay governed by their separate current toggles; removing skill points does not silently delete those systems. New weapon families should resolve native perk/action tags (plus explicit Arsenal integration), rather than guessing from item name.

## Implementation stages

1. Add a shadow ledger and activity monitor, with no stat/rank changes. Measure event attribution, rates, save/reload and UI costs on the current world.
2. Enable the clearest combat, harvesting, crafting, sprint/travel and medical routes in an isolated test profile; retain point purchases during measurement only to avoid blocking normal play.
3. Cover tricky attribution: deployed turrets, bleed/explosive kills, unique loot, trade reversal, enemy-aware stealth, injury provenance, armour mixtures and solo Charismatic Nature.
4. Verify all 57 perks have a rank-zero route and can reach every native rank without points. Add migration/rollback and per-character keys.
5. Only then offer the optional point-free mode in a published test release. Avoid shipping a partial overhaul that strands utility perks.

This document and JSON map are a complete proposal, not proof that every event hook exists or a claim of implemented progression. Native gate effects and per-action hooks need further inspection before activation.
