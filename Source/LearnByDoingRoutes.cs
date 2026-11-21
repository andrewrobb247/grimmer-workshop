using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using HarmonyLib;
using UnityEngine;

namespace GrimmerWorkshop
{
    // Routes activity that is not represented by harvested/crafted stacks or weapon
    // damage. All polling is throttled and distance based so standing still cannot
    // train movement skills.
    public static class LearnByDoingRoutes
    {
        sealed class PlayerState
        {
            public Vector3 Position;
            public float NextSample, LastCombat, LastInjury, LastMove;
            public float LastAim, LastFullDraw, LastKill, LastHipFire, TraderRewardTime;
            public int Health, InjuredHealth;
            public bool HasPosition;
            public int KillStreak;
            public int HipFireShotSequence, LastCreditedHipFireSequence;
            public string TraderInventory, LastCombatItem;
        }
        sealed class BleedCredit { public float Expires, LastAward; public int Ticks; }

        static readonly Dictionary<int, PlayerState> players = new Dictionary<int, PlayerState>();
        static readonly HashSet<string> usedTraps = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        static readonly HashSet<string> openedContainers = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        static readonly Dictionary<string, float> comboTimes = new Dictionary<string, float>(StringComparer.OrdinalIgnoreCase);
        static readonly Dictionary<int, float> shockedTargets = new Dictionary<int, float>();
        static readonly Dictionary<int, BleedCredit> bleedCredits = new Dictionary<int, BleedCredit>();
        static readonly HashSet<int> recentKnockdowns = new HashSet<int>();
        static float knockdownWindow = -100;
        static float lastTreasurePractice = -100;

        static object Member(object instance, params string[] names)
        {
            if (instance == null) return null;
            for (Type type = instance.GetType(); type != null; type = type.BaseType)
                foreach (string name in names)
                {
                    try {
                        const BindingFlags flags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly;
                        FieldInfo field = type.GetField(name, flags);
                        if (field != null) return field.GetValue(instance);
                        PropertyInfo property = type.GetProperty(name, flags);
                        if (property != null && property.GetIndexParameters().Length == 0) return property.GetValue(instance, null);
                    } catch { }
                }
            return null;
        }

        static bool Flag(object instance, params string[] names)
        {
            object value = Member(instance, names);
            if (value is bool) return (bool)value;
            if (value is int) return (int)value != 0;
            return false;
        }

        static float Number(object instance, params string[] names)
        {
            object value = Member(instance, names);
            if (value == null) return 0;
            try { return Convert.ToSingle(value); } catch { return 0; }
        }

        static string ItemName(ItemValue item)
        { return item == null || item.IsEmpty() || item.ItemClass == null ? "" : item.ItemClass.GetItemName(); }

        static ItemValue FindItemValue(object root)
        {
            if (root == null) return null;
            var pending = new Queue<object>(); var seen = new HashSet<object>(); pending.Enqueue(root);
            int visited = 0;
            while (pending.Count > 0 && visited++ < 48) {
                object current = pending.Dequeue();
                if (current == null || current is string || current.GetType().IsPrimitive || current.GetType().IsEnum || !seen.Add(current)) continue;
                if (current is ItemValue) { var value = (ItemValue)current; if (!value.IsEmpty()) return value; continue; }
                object nested = Member(current, "itemValue", "ItemValue", "value");
                if (nested is ItemValue) { var value = (ItemValue)nested; if (!value.IsEmpty()) return value; }
                IEnumerable enumerable = current as IEnumerable;
                if (enumerable != null) { try { foreach (object child in enumerable) pending.Enqueue(child); } catch { } continue; }
                for (Type type=current.GetType(); type!=null; type=type.BaseType)
                    foreach (FieldInfo field in type.GetFields(BindingFlags.Instance|BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.DeclaredOnly))
                        try { object child=field.GetValue(current); if(child!=null && !(child is string))pending.Enqueue(child); } catch { }
            }
            return null;
        }

        static string WeaponSkill(string itemName)
        {
            List<PracticeRule> rules;
            if (!String.IsNullOrEmpty(itemName) && Workshop.Rules.TryGetValue(itemName, out rules))
                foreach (var rule in rules) if (rule.Skill.StartsWith("crafting", StringComparison.OrdinalIgnoreCase)) return rule.Skill;
            return null;
        }

        static bool HasAny(HashSet<string> buffs, params string[] tokens)
        {
            if (buffs == null) return false;
            foreach (string buff in buffs) foreach (string token in tokens)
                if (buff.IndexOf(token, StringComparison.OrdinalIgnoreCase) >= 0) return true;
            return false;
        }

        public static HashSet<string> BuffNames(EntityAlive entity)
        {
            var result = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            object manager = Member(entity, "Buffs", "buffs");
            object active = Member(manager, "ActiveBuffs", "activeBuffs");
            var list = active as IEnumerable;
            if (list == null) return result;
            try { foreach (object buff in list) { object name=Member(buff,"buffName","BuffName"); if(name!=null)result.Add(Convert.ToString(name)); } } catch { }
            return result;
        }

        static PlayerState State(EntityPlayerLocal player)
        {
            PlayerState state;
            if (!players.TryGetValue(player.entityId, out state)) {
                state = new PlayerState();
                players[player.entityId] = state;
            }
            return state;
        }

        public static void Combat(EntityAlive target, DamageSource source, int damage, bool headshot, HashSet<string> buffsBefore)
        {
            if (!LearnByDoing.Enabled || damage <= 0) return;
            EntityPlayerLocal player = Workshop.Player();
            if (player == null || source == null || source.getEntityId() != player.entityId) return;
            PlayerState state = State(player);
            float now = Time.realtimeSinceStartup;
            state.LastCombat = now;

            ItemValue weapon = source.AttackingItem;
            string name = ItemName(weapon);
            string weaponSkill = WeaponSkill(name);
            string perk = LearnByDoing.PrimaryWeaponPerk(name, weaponSkill);
            string bonusType = Convert.ToString(source.BonusDamageType);
            HashSet<string> buffsAfter = BuffNames(target);
            bool freshBleed = HasAny(buffsAfter, "buffInjuryBleeding") && !HasAny(buffsBefore, "buffInjuryBleeding");
            bool freshShock = HasAny(buffsAfter, "buffShocked") && !HasAny(buffsBefore, "buffShocked");
            bool freshStun = bonusType.Equals("Stun", StringComparison.OrdinalIgnoreCase) ||
                (HasAny(buffsAfter, "buffInjuryStunned") && !HasAny(buffsBefore, "buffInjuryStunned"));
            bool freshLeg = HasAny(buffsAfter, "buffInjuryCrippled", "buffLegSprained", "buffLegBroken") &&
                !HasAny(buffsBefore, "buffInjuryCrippled", "buffLegSprained", "buffLegBroken");
            bool freshSlow = HasAny(buffsAfter, "buffInjurySlow", "buffHazard_Slow", "twitch_shock_slowdown") &&
                !HasAny(buffsBefore, "buffInjurySlow", "buffHazard_Slow", "twitch_shock_slowdown");
            bool freshKnockdown = bonusType.IndexOf("KnockDown", StringComparison.OrdinalIgnoreCase) >= 0 ||
                (HasAny(buffsAfter, "buffInjuryKnockdown") && !HasAny(buffsBefore, "buffInjuryKnockdown"));
            bool power = bonusType.IndexOf("power", StringComparison.OrdinalIgnoreCase) >= 0 || source.damageMultiplier >= 1.5f;
            float charge = 0;
            bool charged = weapon != null && !weapon.IsEmpty() && weapon.TryGetMetadata("charge", out charge) && charge >= 4;
            bool aimed = now - state.LastAim <= 1.5f || Flag(player, "isAiming", "IsAiming", "isAimingGun", "bIsAiming");
            bool fullyDrawn = now - state.LastFullDraw <= 1.5f || source.damageMultiplier >= 1.25f;

            if (perk == "perkDeadEye" && aimed) LearnByDoing.Grant(perk, Math.Min(0.6, damage / 80.0));
            if (perk == "perkArchery" && fullyDrawn) LearnByDoing.Grant(perk, Math.Min(0.8, damage / 60.0));
            if (perk == "perkJavelinMaster" && (power || freshSlow)) LearnByDoing.Grant(perk, Math.Min(0.6, damage / 80.0));
            if (perk == "perkBoomstick" && (freshStun || freshLeg)) LearnByDoing.Grant(perk, 0.75);
            if (perk == "perkDeepCuts" && freshBleed) {
                LearnByDoing.Grant(perk, 1.0);
                bleedCredits[target.entityId] = new BleedCredit { Expires = now + 15 };
            }
            if (perk == "perkElectrocutioner" && (charged || freshShock)) LearnByDoing.Grant(perk, 0.75);
            float shockAt;
            if (perk == "perkElectrocutioner" && shockedTargets.TryGetValue(target.entityId, out shockAt) && now-shockAt <= 4) {
                LearnByDoing.Grant(perk, 0.35);
                shockedTargets.Remove(target.entityId);
            }
            if (freshShock) shockedTargets[target.entityId] = now;

            bool targetWasStunned = HasAny(buffsBefore, "buffInjuryStunned", "buffInjuryKnockdown");
            string comboKey = player.entityId + ":" + target.entityId + ":" + (weaponSkill ?? perk ?? name);
            float lastHit;
            int combo = comboTimes.TryGetValue(comboKey, out lastHit) && now-lastHit <= 3 ? 2 : 1;
            comboTimes[comboKey] = now;
            string secondary = LearnByDoing.SecondaryWeaponPerk(weaponSkill);
            if (combo > 1 && secondary != null) LearnByDoing.Grant(secondary, Math.Min(0.25, damage / 300.0));
            bool firearm = weaponSkill == "craftingRifles" || weaponSkill == "craftingHandguns" ||
                weaponSkill == "craftingShotguns" || weaponSkill == "craftingMachineGuns";
            if (firearm && state.HipFireShotSequence > state.LastCreditedHipFireSequence && now - state.LastHipFire <= 1.0f) {
                state.LastCreditedHipFireSequence = state.HipFireShotSequence;
                LearnByDoing.Grant("perkRunAndGun", Math.Min(0.5, damage / 100.0));
            }
            if (perk == "perkPummelPete" && (targetWasStunned || freshKnockdown || combo > 1))
                LearnByDoing.Grant(perk, Math.Min(0.75, damage / 100.0));
            if (perk == "perkSkullCrusher" && (power || freshKnockdown))
                LearnByDoing.Grant(perk, Math.Min(0.8, damage / 90.0));
            if (freshKnockdown) {
                if (now-knockdownWindow > 5) { knockdownWindow=now; recentKnockdowns.Clear(); }
                recentKnockdowns.Add(target.entityId);
                if (recentKnockdowns.Count >= 2) LearnByDoing.Grant("perkGrandSlam", 1.0);
            }
            if (perk == "perkGrandSlam" && power) LearnByDoing.Grant(perk, Math.Min(0.5, damage / 150.0));
            bool melee = name.IndexOf("spear", StringComparison.OrdinalIgnoreCase) >= 0 ||
                name.IndexOf("club", StringComparison.OrdinalIgnoreCase) >= 0 ||
                name.IndexOf("sledge", StringComparison.OrdinalIgnoreCase) >= 0 ||
                name.IndexOf("knife", StringComparison.OrdinalIgnoreCase) >= 0 ||
                name.IndexOf("machete", StringComparison.OrdinalIgnoreCase) >= 0 ||
                name.IndexOf("knuckle", StringComparison.OrdinalIgnoreCase) >= 0 ||
                name.IndexOf("baton", StringComparison.OrdinalIgnoreCase) >= 0;
            if (melee && player.Health < player.GetMaxHealth()) {
                LearnByDoing.Grant("perkSiphoningStrikes", Math.Min(0.5, damage / 100.0));
                state.LastInjury = Time.realtimeSinceStartup;
            }
            if ((name.IndexOf("club", StringComparison.OrdinalIgnoreCase) >= 0 || name.IndexOf("sledge", StringComparison.OrdinalIgnoreCase) >= 0) &&
                power && Flag(player, "isSprinting", "IsSprinting", "bIsSprinting"))
                LearnByDoing.Grant("perkGrandSlam", Math.Min(0.35, damage / 250.0));
            bool sneakAttack = bonusType.IndexOf("sneak", StringComparison.OrdinalIgnoreCase) >= 0 || Flag(target, "isSleeping", "IsSleeping");
            if (headshot && sneakAttack)
                LearnByDoing.Grant("perkHiddenStrike", Math.Min(1.0, damage / 50.0));

            if (target.Health <= 0 && (perk == "perkDeadEye" || perk == "perkArchery" || perk == "perkGunslinger")) {
                state.KillStreak = now-state.LastKill <= 12 ? state.KillStreak+1 : 1;
                state.LastKill = now;
                if (state.KillStreak >= 2 && (headshot || aimed || fullyDrawn))
                    LearnByDoing.Grant(perk, Math.Min(1.0, state.KillStreak * 0.15));
            }
            state.LastCombatItem = name;

            // Hunting advances tracking as well as the weapon/harvesting routes.
            if (target is EntityAnimal && target.Health <= 0)
                LearnByDoing.Grant("perkAnimalTracker", 2);
        }

        public static void IncomingDamage(EntityAlive target, DamageSource source, int before)
        {
            EntityPlayerLocal player = Workshop.Player();
            if (!LearnByDoing.Enabled || player == null || !ReferenceEquals(target, player) || source == null || before <= player.Health) return;
            // Environmental/fall/self damage has no attacking entity id and must not train combat resilience.
            if (source.getEntityId() <= 0 || source.getEntityId() == player.entityId) return;
            PlayerState state = State(player);
            state.LastCombat = Time.realtimeSinceStartup;
            state.LastInjury = Time.realtimeSinceStartup;
            state.InjuredHealth = Math.Max(state.InjuredHealth, before);
            LearnByDoing.Grant("perkPainTolerance", Math.Min(2.0, (before - player.Health) / 20.0));
            ArmorPractice(player);
        }

        public static void BleedTick(EntityAlive target, DamageSource source, int damage)
        {
            if (!LearnByDoing.Enabled || target == null || source == null || damage <= 0 ||
                !String.Equals(Convert.ToString(source.damageType), "BloodLoss", StringComparison.OrdinalIgnoreCase)) return;
            BleedCredit credit;
            float now = Time.realtimeSinceStartup;
            if (!bleedCredits.TryGetValue(target.entityId, out credit)) return;
            if (now > credit.Expires || credit.Ticks >= 5) { bleedCredits.Remove(target.entityId); return; }
            if (now - credit.LastAward < 0.75f) return;
            credit.LastAward = now;
            credit.Ticks++;
            LearnByDoing.Grant("perkDeepCuts", Math.Min(0.25, damage / 100.0));
            if (credit.Ticks >= 5) bleedCredits.Remove(target.entityId);
        }

        public static void Tick(EntityPlayerLocal player)
        {
            if (!LearnByDoing.Enabled || player == null || !ReferenceEquals(player, Workshop.Player())) return;
            PlayerState state = State(player);
            float now = Time.realtimeSinceStartup;
            if (now < state.NextSample) return;
            state.NextSample = now + 0.5f;

            Vector3 position;
            object rawPosition = Member(player, "position", "Position");
            if (rawPosition is Vector3) position = (Vector3)rawPosition; else return;

            if (state.HasPosition) {
                Vector3 delta = position - state.Position;
                float distance = delta.magnitude;
                bool riding = Member(player, "AttachedToEntity", "attachedToEntity", "vehicle") != null;
                bool sprinting = Flag(player, "isSprinting", "IsSprinting", "bIsSprinting", "sprinting");
                bool crouching = Flag(player, "isCrouching", "IsCrouching", "bIsCrouching");
                bool recentCombat = now - state.LastCombat < 12;

                if (!riding && distance >= 1.0f) {
                    state.LastMove = now;
                    if (sprinting) LearnByDoing.Grant("perkRuleOneCardio", Math.Min(0.4, distance * 0.08));
                    if (recentCombat) LearnByDoing.Grant("perkHardTarget", Math.Min(0.3, distance * 0.04));
                    if (crouching && recentCombat) LearnByDoing.Grant("perkFromTheShadows", Math.Min(0.15, distance * 0.02));
                    if (delta.y >= 0.8f && distance >= 1.25f) LearnByDoing.Grant("perkParkour", 0.2);
                    if (Flag(player, "IsEncumbered", "isEncumbered", "bIsEncumbered"))
                        LearnByDoing.Grant("perkPackMule", Math.Min(0.4, distance * 0.06));
                }

                // Healing Factor only learns from health returned after a recent injury.
                if (player.Health > state.Health && now - state.LastInjury < 120 && state.InjuredHealth > player.Health) {
                    int recovered = player.Health - state.Health;
                    LearnByDoing.Grant("perkHealingFactor", Math.Min(2.0, recovered / 10.0));
                    state.InjuredHealth = Math.Max(player.Health, state.InjuredHealth - recovered);
                }
            }

            state.Position = position;
            state.Health = player.Health;
            state.HasPosition = true;
        }

        public static void Reload(object[] args)
        {
            EntityPlayerLocal player = Workshop.Player();
            if (!LearnByDoing.Enabled || player == null) return;
            PlayerState state = State(player);
            ItemValue item = args == null ? null : args.Select(FindItemValue).FirstOrDefault(x => x != null && !x.IsEmpty());
            string name = ItemName(item);
            if (String.IsNullOrEmpty(name)) name = Convert.ToString(Member(player, "holdingItemItemValue", "HoldingItemItemValue"));
            if (Time.realtimeSinceStartup - state.LastCombat >= 12 || Time.realtimeSinceStartup - state.LastMove >= 2 ||
                String.IsNullOrEmpty(state.LastCombatItem) || (!String.IsNullOrEmpty(name) && !String.Equals(name, state.LastCombatItem, StringComparison.OrdinalIgnoreCase))) return;
            LearnByDoing.Grant("perkRunAndGun", 0.5);
            string skill=WeaponSkill(state.LastCombatItem);
            string perk=LearnByDoing.PrimaryWeaponPerk(state.LastCombatItem,skill);
            if (perk=="perkDeadEye" || perk=="perkBoomstick" || perk=="perkArchery") LearnByDoing.Grant(perk,0.5);
        }

        public static void RangedShot(object[] args)
        {
            EntityPlayerLocal player=Workshop.Player();
            if (!LearnByDoing.Enabled || player==null || args==null) return;
            object data=args.FirstOrDefault(x=>x!=null);
            PlayerState state=State(player); float now=Time.realtimeSinceStartup;
            ItemValue item=FindItemValue(data); string name=ItemName(item);
            bool aimed=Flag(data,"wasAiming","isAiming","IsAiming") || now-state.LastAim<=0.2f || Flag(player,"isAiming","IsAiming","isAimingGun","bIsAiming");
            if (aimed) state.LastAim=now; else { state.LastHipFire=now; state.HipFireShotSequence++; }
            float draw=Number(data,"drawTime","chargeTime","holdDuration","heldTime","pullDuration");
            if (draw>=0.65f || Flag(data,"bFullyDrawn","isFullyDrawn","fullyDrawn")) state.LastFullDraw=now;
            if (!String.IsNullOrEmpty(name)) state.LastCombatItem=name;
        }

        public static void AimUpdate(object[] args)
        {
            EntityPlayerLocal player=Workshop.Player();
            if (!LearnByDoing.Enabled || player==null || args==null || args.Length<2 || !(args[1] is bool) || !(bool)args[1]) return;
            State(player).LastAim=Time.realtimeSinceStartup;
        }

        public static void CatapultUpdate(object[] args)
        {
            EntityPlayerLocal player=Workshop.Player();
            if (!LearnByDoing.Enabled || player==null || args==null || args.Length==0) return;
            object actionData=args[0];
            float start=Number(actionData,"m_ActivateTime"), duration=Number(actionData,"m_MaxStrainTime");
            if (duration>0 && Time.time-start>=duration*0.8f) State(player).LastFullDraw=Time.realtimeSinceStartup;
        }

        public static void ItemUsed(ItemValue item)
        {
            if (item == null || item.IsEmpty()) return;
            EntityPlayerLocal player = Workshop.Player();
            if (player == null) return;
            string name = item.ItemClass.GetItemName();
            if (name.IndexOf("honey", StringComparison.OrdinalIgnoreCase) >= 0) {
                LearnByDoing.Discover("perkApiarist", 10);
                if (LearnByDoing.IsDiscovered(player, "perkApiarist")) LearnByDoing.Grant("perkApiarist", 0.5);
            }
            if (!LearnByDoing.Enabled) return;
            if ((name.StartsWith("food", StringComparison.OrdinalIgnoreCase) || name.StartsWith("drink", StringComparison.OrdinalIgnoreCase)) &&
                (Member(player, "foodValue", "FoodValue", "food", "Food", "waterValue", "WaterValue", "water", "Water") != null))
                LearnByDoing.Grant("perkSlowMetabolism", 0.25);
        }

        public static void Harvest(ItemValue tool, ItemStack output, BlockValue block)
        {
            if (!LearnByDoing.Enabled || tool == null || tool.IsEmpty() || output == null || output.IsEmpty()) return;
            string itemName = tool.ItemClass.GetItemName();
            string blockName = block.Block == null ? "" : block.Block.GetBlockName();
            if (itemName.IndexOf("shovel", StringComparison.OrdinalIgnoreCase) >= 0 &&
                (blockName.IndexOf("treasure", StringComparison.OrdinalIgnoreCase) >= 0 || blockName.IndexOf("buried", StringComparison.OrdinalIgnoreCase) >= 0 ||
                 blockName.IndexOf("dirt", StringComparison.OrdinalIgnoreCase) >= 0 || blockName.IndexOf("sand", StringComparison.OrdinalIgnoreCase) >= 0)) {
                float now = Time.realtimeSinceStartup;
                if (now - lastTreasurePractice >= 2) { lastTreasurePractice = now; LearnByDoing.Grant("perkTreasureHunter", 0.25); }
            }
        }

        public static void Trap(string blockName, Vector3i position)
        {
            if (!LearnByDoing.Enabled || String.IsNullOrEmpty(blockName)) return;
            if (blockName.IndexOf("mine", StringComparison.OrdinalIgnoreCase) < 0 && blockName.IndexOf("trap", StringComparison.OrdinalIgnoreCase) < 0) return;
            string key = blockName + "@" + position.x + "," + position.y + "," + position.z;
            if (usedTraps.Add(key)) LearnByDoing.Grant("perkInfiltrator", 1);
        }

        public static void TrapArgs(object[] args)
        {
            if (args==null) return;
            string blockName=null; Vector3i? position=null;
            foreach(object arg in args) {
                if(arg is string && (((string)arg).IndexOf("mine",StringComparison.OrdinalIgnoreCase)>=0 || ((string)arg).IndexOf("trap",StringComparison.OrdinalIgnoreCase)>=0)) blockName=(string)arg;
                if(arg is Vector3i) position=(Vector3i)arg;
            }
            if(blockName!=null && position.HasValue) Trap(blockName,position.Value);
        }

        public static void ContainerOpened(object[] args)
        {
            if (!LearnByDoing.Enabled || args == null) return;
            string key = null;
            foreach (object arg in args) {
                if (arg is Vector3i) {
                    Vector3i p = (Vector3i)arg;
                    key = p.x + "," + p.y + "," + p.z;
                    break;
                }
                if (arg != null && !(arg is EntityPlayerLocal) && !(arg is ItemValue))
                    key = arg.GetType().FullName + "@" + arg.GetHashCode();
            }
            if (String.IsNullOrEmpty(key)) return;
            if (openedContainers.Add(key)) {
                LearnByDoing.Grant("perkLuckyLooter", 0.5);
                EntityPlayerLocal player = Workshop.Player();
                object held = Member(player, "holdingItemItemValue", "HoldingItemItemValue", "holdingItem");
                string heldName = held is ItemValue ? ((ItemValue)held).ItemClass.GetItemName() : Convert.ToString(Member(held, "ItemClass", "itemClass"));
                if (!String.IsNullOrEmpty(heldName) && heldName.IndexOf("lockpick", StringComparison.OrdinalIgnoreCase) >= 0)
                    LearnByDoing.Grant("perkLockPicking", 1);
            }
        }

        static string InventorySignature(EntityPlayerLocal player)
        {
            object inventory = Member(player, "inventory", "Inventory");
            if (inventory == null) return null;
            var entries = new List<string>();
            var seen = new HashSet<object>();
            var pending = new Queue<object>();
            pending.Enqueue(inventory);
            int visited = 0;
            while (pending.Count > 0 && visited++ < 128) {
                object current = pending.Dequeue();
                if (current == null || current is string || current.GetType().IsPrimitive || current.GetType().IsEnum || !seen.Add(current)) continue;
                ItemValue value = current as ItemValue;
                if (value != null && !value.IsEmpty()) { entries.Add(value.ItemClass.GetItemName() + ":1"); continue; }
                object itemValue = Member(current, "itemValue", "ItemValue");
                if (itemValue is ItemValue && !((ItemValue)itemValue).IsEmpty()) {
                    object count = Member(current, "count", "Count");
                    entries.Add(((ItemValue)itemValue).ItemClass.GetItemName() + ":" + Convert.ToString(count));
                    continue;
                }
                IEnumerable enumerable = current as IEnumerable;
                if (enumerable != null) { try { foreach (object child in enumerable) pending.Enqueue(child); } catch { } continue; }
                for (Type type = current.GetType(); type != null; type = type.BaseType)
                    foreach (FieldInfo field in type.GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly))
                        try { object child = field.GetValue(current); if (child != null && !(child is string)) pending.Enqueue(child); } catch { }
            }
            if (entries.Count == 0) return null;
            entries.Sort(StringComparer.Ordinal);
            return String.Join("|", entries.ToArray());
        }

        static string ArmorTags(ItemValue item)
        {
            if (item == null || item.IsEmpty() || item.ItemClass == null) return "";
            object tags = Member(item.ItemClass, "Tags", "tags");
            if (tags != null) return Convert.ToString(tags);
            object properties = Member(item.ItemClass, "Properties", "properties");
            if (properties == null) return "";
            try {
                MethodInfo getString = AccessTools.Method(properties.GetType(), "GetString", new Type[] { typeof(string) });
                return getString == null ? "" : Convert.ToString(getString.Invoke(properties, new object[] { "Tags" }));
            } catch { return ""; }
        }

        static void ArmorPractice(EntityPlayerLocal player)
        {
            object equipment = Member(player, "equipment", "Equipment", "EquipmentSlots");
            if (equipment == null) return;
            var found = new HashSet<object>();
            var pending = new Queue<object>();
            pending.Enqueue(equipment);
            int visited = 0, light = 0, medium = 0, heavy = 0;
            while (pending.Count > 0 && visited++ < 96) {
                object current = pending.Dequeue();
                if (current == null || current is string || current.GetType().IsPrimitive || current.GetType().IsEnum || !found.Add(current)) continue;
                object raw = current is ItemValue ? current : Member(current, "itemValue", "ItemValue");
                if (raw is ItemValue) {
                    ItemValue item = (ItemValue)raw;
                    string tags = ArmorTags(item);
                    if (tags.IndexOf("lightArmor", StringComparison.OrdinalIgnoreCase) >= 0) light++;
                    if (tags.IndexOf("mediumArmor", StringComparison.OrdinalIgnoreCase) >= 0) medium++;
                    if (tags.IndexOf("heavyArmor", StringComparison.OrdinalIgnoreCase) >= 0) heavy++;
                    continue;
                }
                IEnumerable enumerable = current as IEnumerable;
                if (enumerable != null) { try { foreach (object child in enumerable) pending.Enqueue(child); } catch { } continue; }
                for (Type type = current.GetType(); type != null; type = type.BaseType)
                    foreach (FieldInfo field in type.GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly))
                        try { object child = field.GetValue(current); if (child != null && !(child is string)) pending.Enqueue(child); } catch { }
            }
            int total = light + medium + heavy;
            if (total <= 0) return;
            if (light > 0) LearnByDoing.Grant("perkLightArmor", 0.4 * light / total);
            if (medium > 0) LearnByDoing.Grant("perkMediumArmor", 0.4 * medium / total);
            if (heavy > 0) LearnByDoing.Grant("perkHeavyArmor", 0.4 * heavy / total);
        }

        public static void TraderOpened()
        {
            EntityPlayerLocal player = Workshop.Player();
            if (player != null) State(player).TraderInventory = InventorySignature(player);
        }

        public static void TraderClosed()
        {
            if (!LearnByDoing.Enabled) return;
            EntityPlayerLocal player = Workshop.Player();
            if (player == null) return;
            PlayerState state = State(player);
            string after = InventorySignature(player);
            if (!String.IsNullOrEmpty(state.TraderInventory) && !String.IsNullOrEmpty(after) && !String.Equals(state.TraderInventory, after, StringComparison.Ordinal) && Time.realtimeSinceStartup-state.TraderRewardTime>=30) {
                LearnByDoing.Grant("perkBetterBarter", 1);
                state.TraderRewardTime=Time.realtimeSinceStartup;
            }
            state.TraderInventory = null;
        }
    }

    [HarmonyPatch(typeof(GameManager), "Update")]
    public static class LearnByDoingActivityTickPatch
    {
        public static void Postfix() { try { LearnByDoingRoutes.Tick(Workshop.Player()); } catch (Exception error) { Log.Error("[Grimmer Workshop] Activity tick: " + error); } }
    }

    [HarmonyPatch]
    public static class LearnByDoingReloadPatch
    {
        public static System.Collections.Generic.IEnumerable<MethodBase> TargetMethods()
        {
            MethodBase method = AccessTools.Method(typeof(ItemActionRanged), "CompleteReload");
            if (method != null) yield return method;
        }
        public static void Postfix(object[] __args) { try { LearnByDoingRoutes.Reload(__args); } catch (Exception error) { Log.Error("[Grimmer Workshop] Reload practice: " + error); } }
    }

    [HarmonyPatch]
    public static class LearnByDoingRangedShotPatch
    {
        public static System.Collections.Generic.IEnumerable<MethodBase> TargetMethods()
        {
            MethodBase method = AccessTools.Method(typeof(ItemActionRanged), "onHoldingEntityFired");
            if (method != null) yield return method;
        }
        public static void Prefix(object[] __args) { try { LearnByDoingRoutes.RangedShot(__args); } catch (Exception error) { Log.Error("[Grimmer Workshop] Shot context: " + error); } }
    }

    [HarmonyPatch]
    public static class LearnByDoingAimContextPatch
    {
        public static System.Collections.Generic.IEnumerable<MethodBase> TargetMethods()
        {
            MethodBase method=AccessTools.Method(typeof(ItemActionRanged),"updateAccuracy");
            if(method!=null)yield return method;
        }
        public static void Prefix(object[] __args) { try { LearnByDoingRoutes.AimUpdate(__args); } catch(Exception error) { Log.Error("[Grimmer Workshop] Aim context: "+error); } }
    }

    [HarmonyPatch]
    public static class LearnByDoingDrawContextPatch
    {
        public static System.Collections.Generic.IEnumerable<MethodBase> TargetMethods()
        {
            Type type=AccessTools.TypeByName("ItemActionCatapult");
            MethodBase method=type==null?null:AccessTools.Method(type,"OnHoldingUpdate");
            if(method!=null)yield return method;
        }
        public static void Postfix(object[] __args) { try { LearnByDoingRoutes.CatapultUpdate(__args); } catch(Exception error) { Log.Error("[Grimmer Workshop] Draw context: "+error); } }
    }

    [HarmonyPatch(typeof(QuestEventManager), "HarvestedItem")]
    public static class LearnByDoingDigPracticePatch
    {
        public static void Postfix(ItemValue __0, ItemStack __1, BlockValue __2)
        { try { LearnByDoingRoutes.Harvest(__0, __1, __2); } catch (Exception error) { Log.Error("[Grimmer Workshop] Dig practice: " + error); } }
    }

    [HarmonyPatch(typeof(QuestEventManager), "BlockActivated")]
    public static class LearnByDoingTrapPracticePatch
    {
        public static void Postfix(string __0, Vector3i __1)
        { try { LearnByDoingRoutes.Trap(__0, __1); } catch (Exception error) { Log.Error("[Grimmer Workshop] Trap practice: " + error); } }
    }

    [HarmonyPatch]
    public static class LearnByDoingTrapClearPatch
    {
        public static System.Collections.Generic.IEnumerable<MethodBase> TargetMethods()
        {
            MethodBase method=AccessTools.Method(typeof(QuestEventManager),"BlockDestroyed");
            if(method!=null)yield return method;
        }
        public static void Postfix(object[] __args) { try { LearnByDoingRoutes.TrapArgs(__args); } catch(Exception error) { Log.Error("[Grimmer Workshop] Trap clear practice: "+error); } }
    }

    [HarmonyPatch]
    public static class LearnByDoingContainerPracticePatch
    {
        public static System.Collections.Generic.IEnumerable<MethodBase> TargetMethods()
        {
            MethodBase method = AccessTools.Method(typeof(QuestEventManager), "OpenedContainer");
            if (method != null) yield return method;
        }
        public static void Postfix(object[] __args)
        { try { LearnByDoingRoutes.ContainerOpened(__args); } catch (Exception error) { Log.Error("[Grimmer Workshop] Container practice: " + error); } }
    }

    [HarmonyPatch]
    public static class LearnByDoingTraderOpenPatch
    {
        public static System.Collections.Generic.IEnumerable<MethodBase> TargetMethods()
        {
            Type type = AccessTools.TypeByName("XUiC_TraderWindow");
            MethodBase method = type == null ? null : AccessTools.Method(type, "OnOpen");
            if (method != null) yield return method;
        }
        public static void Postfix() { try { LearnByDoingRoutes.TraderOpened(); } catch (Exception error) { Log.Error("[Grimmer Workshop] Trader snapshot: " + error); } }
    }

    [HarmonyPatch]
    public static class LearnByDoingTraderClosePatch
    {
        public static System.Collections.Generic.IEnumerable<MethodBase> TargetMethods()
        {
            Type type = AccessTools.TypeByName("XUiC_TraderWindow");
            MethodBase method = type == null ? null : AccessTools.Method(type, "OnClose");
            if (method != null) yield return method;
        }
        public static void Postfix() { try { LearnByDoingRoutes.TraderClosed(); } catch (Exception error) { Log.Error("[Grimmer Workshop] Trader practice: " + error); } }
    }
}
