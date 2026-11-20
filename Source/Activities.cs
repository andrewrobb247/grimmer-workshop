using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using HarmonyLib;
using UnityEngine;

namespace GrimmerWorkshop
{
    public static class Activities
    {
        static readonly ConditionalWeakTable<EntityPlayerLocal, ActivityBudget> budgets = new ConditionalWeakTable<EntityPlayerLocal, ActivityBudget>();
        static float lastNotice = -100;
        public static string Name(string skill)
        {
            switch(skill) {
                case "craftingHarvestingTools": return "Harvesting Tools";
                case "craftingRepairTools": return "Repair Tools";
                case "craftingSalvageTools": return "Salvage Tools";
                case "craftingMachineGuns": return "Machine Guns";
                case "craftingWorkstations": return "Workstations";
                case "craftingElectrician": return "Electronics";
                case "craftingBackpack": return "Backpacks";
                default: return skill.StartsWith("crafting") ? skill.Substring(8) : skill;
            }
        }
        public static void Notify(EntityPlayerLocal player, string skill, double amount, int level, double practice)
        {
            if (!Workshop.PracticeNotifications || Time.realtimeSinceStartup - lastNotice < 2) return;
            lastNotice = Time.realtimeSinceStartup;
            try {
                if (player.PlayerUI != null) GameManager.ShowTooltip(player, Name(skill) + " +" + amount.ToString("0.##") + " practice | level " + level + " | " + practice.ToString("0.#") + "/" + PracticeMath.Required(level, Workshop.Cost, Workshop.Growth).ToString("0.#"), false, false, 2);
            } catch(Exception error) { Log.Error("[Grimmer Workshop] Practice notification: " + error.Message); }
        }
        public static void Award(string skill, double amount)
        {
            var player = Workshop.Player();
            if (player == null || Workshop.ActivitySpeed <= 0) return;
            amount = budgets.GetOrCreateValue(player).Take(skill, amount * Workshop.ActivitySpeed * Workshop.Speed, Time.realtimeSinceStartup);
            Workshop.Grant(player, skill, amount, int.MaxValue);
        }
        public static void Equipment(ItemValue item, double amount, bool harvesting)
        {
            if (item == null || item.IsEmpty()) return;
            List<PracticeRule> rules;
            if (!Workshop.Rules.TryGetValue(item.ItemClass.GetItemName(), out rules)) return;
            var seen = new HashSet<string>();
            foreach (var rule in rules) {
                bool tool = rule.Skill == "craftingHarvestingTools" || rule.Skill == "craftingSalvageTools" || rule.Skill == "craftingBlades";
                bool weapon = rule.Skill == "craftingKnuckles" || rule.Skill == "craftingBlades" || rule.Skill == "craftingClubs" || rule.Skill == "craftingSledgehammers" || rule.Skill == "craftingBows" || rule.Skill == "craftingSpears" || rule.Skill == "craftingHandguns" || rule.Skill == "craftingShotguns" || rule.Skill == "craftingRifles" || rule.Skill == "craftingMachineGuns" || rule.Skill == "craftingExplosives" || rule.Skill == "craftingRobotics";
                if ((harvesting ? tool : weapon) && seen.Add(rule.Skill)) Award(rule.Skill, amount);
            }
        }
    }

    [HarmonyPatch(typeof(QuestEventManager), "HarvestedItem")]
    public static class HarvestPracticePatch
    {
        public static void Postfix(ItemValue __0, ItemStack __1, BlockValue __2)
        {
            try {
                if (Workshop.Player() == null || __1 == null || __1.IsEmpty()) return;
                Activities.Equipment(__0, Math.Min(2, __1.count * 0.1), true);
                LearnByDoing.RecordHarvest(__0, __1, __2);
                string block = __2.Block.GetBlockName();
                if (block.StartsWith("planted", StringComparison.Ordinal) && block.IndexOf("Harvest", StringComparison.Ordinal) >= 0)
                    Activities.Award("craftingSeeds", Math.Min(1, __1.count * 0.5));
                string material = __1.itemValue.ItemClass.GetItemName();
                if (material == "resourceElectricParts") Activities.Award("craftingElectrician", Math.Min(1, __1.count * 0.25));
            } catch(Exception error) { Log.Error("[Grimmer Workshop] Harvest practice: " + error); }
        }
    }

    [HarmonyPatch(typeof(EntityAlive), "DamageEntity", new Type[] { typeof(DamageSource), typeof(int), typeof(bool), typeof(float) })]
    public static class CombatPracticePatch
    {
        public sealed class State { public int Health; public HashSet<string> Buffs; }
        public static void Prefix(EntityAlive __instance, out State __state)
        { __state = new State { Health = __instance.Health, Buffs = LearnByDoingRoutes.BuffNames(__instance) }; }
        public static void Postfix(EntityAlive __instance, DamageSource __0, State __state)
        {
            try {
                var player = Workshop.Player();
                if (__state == null) return;
                LearnByDoingRoutes.IncomingDamage(__instance, __0, __state.Health);
                int damage = Math.Min(__state.Health, Math.Max(0, __state.Health - __instance.Health));
                if (damage <= 0) return;
                LearnByDoingRoutes.BleedTick(__instance, __0, damage);
                if (player == null || __0 == null || __state.Health <= 0 || !(__instance is EntityZombie || __instance is EntityAnimal) || __0.getEntityId() != player.entityId) return;
                LearnByDoingRoutes.Combat(__instance, __0, damage, __0.bodyParts == EnumBodyPartHit.Head, __state.Buffs);
                Activities.Equipment(__0.AttackingItem, Math.Min(3, damage / 25.0), false);
                ActionSkillPreview.RecordWeaponDamage(player, __0.AttackingItem, damage, __0.bodyParts == EnumBodyPartHit.Head);
            } catch(Exception error) { Log.Error("[Grimmer Workshop] Combat practice: " + error); }
        }
    }

    [HarmonyPatch(typeof(QuestEventManager), "RepairedItem")]
    public static class RepairPracticePatch
    {
        public static void Postfix(ItemValue __0)
        {
            try { Activities.Award("craftingRepairTools", 2); }
            catch(Exception error) { Log.Error("[Grimmer Workshop] Repair practice: " + error); }
        }
    }

    [HarmonyPatch(typeof(QuestEventManager), "BlockUpgraded")]
    public static class UpgradePracticePatch
    {
        public static void Postfix()
        {
            try { Activities.Award("craftingRepairTools", 1); Activities.Award("craftingWorkstations", 0.25); Activities.Award("craftingConstruction", 0.5); }
            catch(Exception error) { Log.Error("[Grimmer Workshop] Upgrade practice: " + error); }
        }
    }

    [HarmonyPatch(typeof(QuestEventManager), "UsedItem")]
    public static class MedicalPracticePatch
    {
        public static void Postfix(ItemValue __0)
        {
            try {
                if (__0 == null || __0.IsEmpty()) return;
                LearnByDoingRoutes.ItemUsed(__0);
                string name = __0.ItemClass.GetItemName();
                if (name.StartsWith("medical", StringComparison.Ordinal) || name.StartsWith("drug", StringComparison.Ordinal)) Activities.Award("craftingMedical", 1);
            } catch(Exception error) { Log.Error("[Grimmer Workshop] Medical practice: " + error); }
        }
    }
}
