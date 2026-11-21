using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Xml.Linq;
using HarmonyLib;
using UnityEngine;

namespace GrimmerWorkshop
{
    public sealed class LearningSkillDefinition
    {
        public string Id, Name, Parent, Kind, Action;
        public int MaxRank;
        public bool Hidden;
        public readonly Dictionary<int, List<LearningGate>> Gates = new Dictionary<int, List<LearningGate>>();
    }

    public sealed class LearningGate
    {
        public string Name, Progression, Operation;
        public int Value;
    }

    // Optional point-free progression mode. The ledger is stored on the player,
    // and direct rank changes are scoped so ordinary point purchases can be blocked.
    public static class LearnByDoing
    {
        const string PracticePrefix = "grimmerLearnPractice_";
        const string DiscoveryPrefix = "grimmerHiddenSkillV3_";
        const string BankedPointsKey = "grimmerLearnByDoingBankedSkillPoints";
        static readonly Dictionary<string, LearningSkillDefinition> definitions = new Dictionary<string, LearningSkillDefinition>(StringComparer.OrdinalIgnoreCase);
        static readonly ActionPreviewFrameBudget attributeFrames = new ActionPreviewFrameBudget();
        static float lastNotice = -100;
        static bool migratingPreview;
        [ThreadStatic] static int internalRankChange;
        public static bool Enabled;
        public static double Speed = 1;
        internal static bool IsInternalRankChange { get { return internalRankChange > 0; } }
        public static bool HasSkill(string id) { return Find(id) != null; }

        public static void Load(string root, bool enabled, double speed)
        {
            Enabled = enabled;
            Speed = speed;
            definitions.Clear();
            try {
                foreach (XElement entry in XDocument.Load(Path.Combine(root, "PracticeRules.xml")).Root.Elements("learningSkill"))
                {
                    var definition = new LearningSkillDefinition {
                        Id = (string)entry.Attribute("id"), Name = (string)entry.Attribute("name"),
                        Parent = (string)entry.Attribute("parent"), Kind = (string)entry.Attribute("kind"), Action = (string)entry.Attribute("action"),
                        MaxRank = (int)entry.Attribute("maxRank"), Hidden = (bool?)entry.Attribute("hidden") ?? false
                    };
                    foreach (XElement rank in entry.Elements("rank"))
                    {
                        int level = (int)rank.Attribute("level");
                        var gates = rank.Elements("gate").Select(g => new LearningGate {
                            Name = (string)g.Attribute("name"), Progression = (string)g.Attribute("progression"),
                            Operation = (string)g.Attribute("operation"), Value = (int)g.Attribute("value")
                        }).ToList();
                        definition.Gates[level] = gates;
                    }
                    definitions.Add(definition.Id, definition);
                }
                if (definitions.Count != 63) throw new InvalidDataException("Expected five attributes, 57 gameplay perks and one hidden Apiarist skill; found " + definitions.Count + ".");
            } catch (Exception error) {
                definitions.Clear(); Enabled=false;
                Log.Error("[Grimmer Workshop] Learn by Doing disabled: " + error.Message);
            }
        }

        public static LearningSkillDefinition Find(string id)
        {
            LearningSkillDefinition result;
            return id != null && definitions.TryGetValue(id, out result) ? result : null;
        }

        public static IEnumerable<LearningSkillDefinition> All { get { return definitions.Values; } }

        public static bool IsDiscovered(EntityPlayerLocal player, string skill)
        {
            var definition = Find(skill);
            if (definition == null) return false;
            if (!definition.Hidden) return true;
            if (player == null) return false;
            if (player.Buffs.GetCustomVar(DiscoveryPrefix + skill) >= 1) return true;

            // Existing ranks remain visible. Practice and older discovery
            // flags do not reveal a zero-rank skill; it becomes visible only
            // when the player actually completes rank 1.
            try {
                var value = player.Progression.GetProgressionValue(skill);
                if (value != null && value.Level > 0) {
                    player.Buffs.SetCustomVar(DiscoveryPrefix + skill, 1, true, CVarOperation.set, false);
                    return true;
                }
            } catch { }
            return false;
        }

        public static bool IsVisible(string skill)
        {
            return IsDiscovered(Workshop.Player(), skill);
        }

        public static void Discover(string skill, double firstPractice)
        {
            var player = Workshop.Player();
            var definition = Find(skill);
            if (player == null || definition == null || !definition.Hidden) return;
            if (Enabled && firstPractice > 0) Grant(skill, firstPractice);
            if (player.Buffs.GetCustomVar(DiscoveryPrefix + skill) >= 1) return;
            var value = player.Progression.GetProgressionValue(skill);
            if (value == null || value.Level < 1) return;
            player.Buffs.SetCustomVar(DiscoveryPrefix + skill, 1, true, CVarOperation.set, false);
            if (player.PlayerUI != null) {
                try { GameManager.ShowTooltip(player, "[FFD45A]*** SKILL DISCOVERED ***[-]  " + definition.Name, false, false, 4); }
                catch { }
            }
            Log.Out("[Grimmer Workshop] Hidden skill discovered: " + skill);
        }

        public static void MigratePreview(EntityPlayerLocal player)
        {
            if (!Enabled || player == null || player.Buffs.GetCustomVar("grimmerLearnByDoingPreviewMigrated") >= 1) return;
            if (migratingPreview) return;
            migratingPreview=true;
            var parents = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            try {
                foreach (var action in ActionSkillPreview.All)
                {
                    double total = ActionSkillPreview.Read(action.Id, "base") + ActionSkillPreview.Read(action.Id, "bonus");
                    if (total > 0) Grant(action.Id, total);
                    if (!String.IsNullOrEmpty(action.Attribute)) parents.Add(action.Attribute);
                }
                foreach (string parent in parents) {
                    double previous = ActionSkillPreview.Read(parent, "base");
                    if (previous > 0) Grant(parent, previous);
                }
                player.Buffs.SetCustomVar("grimmerLearnByDoingPreviewMigrated", 1, true, CVarOperation.set, false);
            }
            finally { migratingPreview=false; }
        }

        public static string Key(string skill) { return PracticePrefix + skill; }

        public static double Read(EntityPlayerLocal player, string skill)
        {
            if (player == null || Find(skill) == null) return 0;
            return Math.Max(0, player.Buffs.GetCustomVar(Key(skill)));
        }

        public static double Required(string skill, int currentRank)
        {
            var definition = Find(skill);
            if (definition == null) return double.PositiveInfinity;
            if (definition.Kind == "attribute") return 500 * Math.Pow(Math.Max(1, currentRank), 1.8);
            if (skill == "perkApiarist") return 25 * Math.Pow(Math.Max(1, currentRank + 1), 1.6);
            return 100 * Math.Pow(Math.Max(1, currentRank + 1), 1.6);
        }

        public static double Ratio(EntityPlayerLocal player, string skill)
        {
            var definition = Find(skill);
            if (definition == null) return 0;
            var value = player == null ? null : player.Progression.GetProgressionValue(skill);
            if (value == null || value.Level >= definition.MaxRank) return value == null ? 0 : 1;
            double required = Required(skill, value.Level);
            return required <= 0 ? 0 : Math.Max(0, Math.Min(1, Read(player, skill) / required));
        }

        public static string Progress(EntityPlayerLocal player, string skill)
        {
            var definition = Find(skill);
            var value = player == null ? null : player.Progression.GetProgressionValue(skill);
            if (definition == null || value == null) return "";
            if (value.Level >= definition.MaxRank) return definition.Name.ToUpperInvariant() + " | MAX RANK " + definition.MaxRank;
            double required = Required(skill, value.Level), practice = Read(player, skill);
            string gate = MeetsGates(player, definition, value.Level + 1) ? "" : " | WAITING FOR NATIVE REQUIREMENT";
            return definition.Name.ToUpperInvariant() + " PRACTICE " + practice.ToString("0.#", CultureInfo.InvariantCulture) +
                " / " + required.ToString("0.#", CultureInfo.InvariantCulture) + "  |  RANK " + value.Level + "/" + definition.MaxRank + gate;
        }

        public static bool Grant(string skill, double amount)
        {
            var player = Workshop.Player();
            var definition = Find(skill);
            if (!Enabled || player == null || definition == null || amount <= 0 ||
                double.IsNaN(amount) || double.IsInfinity(amount) || Speed <= 0) return false;
            // Hidden practice accrues without showing the skill. Reveal it only
            // after the first full rank has actually been earned.
            if (!migratingPreview) MigratePreview(player);
            var value = player.Progression.GetProgressionValue(skill);
            if (value == null || value.Level >= definition.MaxRank) return false;

            double practice = Read(player, skill) + amount * Speed;
            int before = value.Level;
            while (value.Level < definition.MaxRank)
            {
                double required = Required(skill, value.Level);
                if (practice < required) break;
                if (!MeetsGates(player, definition, value.Level + 1)) { practice = Math.Min(practice, required); break; }
                practice -= required;
                internalRankChange++;
                try { value.Level++; }
                finally { internalRankChange--; }
            }
            player.Buffs.SetCustomVar(Key(skill), (float)Math.Min(float.MaxValue, Math.Max(0, practice)), true, CVarOperation.set, false);
            if (definition.Kind == "attribute") GrantMasteryShare(definition.Id, amount);
            if (before == value.Level) return true;
            Refresh(player, value, before);
            if (definition.Hidden && before == 0 && value.Level > 0) Discover(skill, 0);
            TryPending(player);
            return true;
        }

        static void GrantMasteryShare(string attribute, double amount)
        {
            string mastery;
            switch(attribute) {
                case "attPerception": mastery="perkPerceptionMastery"; break;
                case "attStrength": mastery="perkStrengthMastery"; break;
                case "attFortitude": mastery="perkFortitudeMastery"; break;
                case "attAgility": mastery="perkAgilityMastery"; break;
                case "attIntellect": mastery="perkIntellectMastery"; break;
                default: return;
            }
            var player=Workshop.Player(); var definition=Find(mastery);
            var value=player==null?null:player.Progression.GetProgressionValue(mastery);
            if (definition!=null && value!=null && value.Level<definition.MaxRank && MeetsGates(player,definition,value.Level+1))
                Grant(mastery,amount*0.1);
        }

        static bool MeetsGates(EntityPlayerLocal player, LearningSkillDefinition definition, int nextRank)
        {
            List<LearningGate> gates;
            if (!definition.Gates.TryGetValue(nextRank, out gates)) return true;
            foreach (var gate in gates)
            {
                int actual;
                if (gate.Name == "PlayerLevel") actual = player.Progression.GetLevel();
                else if (gate.Name == "ProgressionLevel") {
                    var required = player.Progression.GetProgressionValue(gate.Progression);
                    actual = required == null ? 0 : required.Level;
                } else continue;
                switch (gate.Operation) {
                    case "GTE": if (actual < gate.Value) return false; break;
                    case "GT": if (actual <= gate.Value) return false; break;
                    case "LTE": if (actual > gate.Value) return false; break;
                    case "LT": if (actual >= gate.Value) return false; break;
                    case "Equals": if (actual != gate.Value) return false; break;
                    case "NotEquals": if (actual == gate.Value) return false; break;
                }
            }
            return true;
        }

        static void TryPending(EntityPlayerLocal player)
        {
            foreach (var definition in definitions.Values)
            {
                var value = player.Progression.GetProgressionValue(definition.Id);
                if (value == null || value.Level >= definition.MaxRank || Read(player, definition.Id) < Required(definition.Id, value.Level) ||
                    !MeetsGates(player, definition, value.Level + 1)) continue;
                double remainder = Read(player, definition.Id) - Required(definition.Id, value.Level);
                internalRankChange++;
                try { value.Level++; }
                finally { internalRankChange--; }
                player.Buffs.SetCustomVar(Key(definition.Id), (float)Math.Max(0, remainder), true, CVarOperation.set, false);
                Refresh(player, value, value.Level - 1);
                if (definition.Hidden && value.Level == 1) Discover(definition.Id, 0);
            }
        }

        static void Refresh(EntityPlayerLocal player, ProgressionValue value, int before)
        {
            player.Progression.bProgressionStatsChanged = true;
            player.bPlayerStatsChanged = true;
            try { player.Progression.RefreshPerks(value.Name); } catch { }
            try { value.ProgressionClass.HandleCheckCrafting(player, before, value.Level); } catch { }
            if (Time.realtimeSinceStartup - lastNotice >= 2 && Workshop.PracticeNotifications && player.PlayerUI != null)
            {
                lastNotice = Time.realtimeSinceStartup;
                try { GameManager.ShowTooltip(player, value.Name + " reached rank " + value.Level + " (Learn by Doing)", false, false, 3); }
                catch { }
            }
            Log.Out("[Grimmer Workshop] Learn by Doing: " + value.Name + " " + before + " -> " + value.Level);
        }

        static void StorePoints(EntityPlayerLocal player)
        {
            int points = player.Progression.SkillPoints;
            if (points <= 0) return;
            float banked = player.Buffs.GetCustomVar(BankedPointsKey);
            player.Buffs.SetCustomVar(BankedPointsKey, banked + points, true, CVarOperation.set, false);
            player.Progression.SkillPoints = 0;
            player.Progression.bProgressionStatsChanged = true;
        }

        static void RestorePoints(EntityPlayerLocal player)
        {
            float banked = Math.Max(0, player.Buffs.GetCustomVar(BankedPointsKey));
            if (banked <= 0) return;
            int grant = (int)Math.Min(int.MaxValue - player.Progression.SkillPoints, Math.Floor(banked));
            if (grant <= 0) return;
            player.Progression.SkillPoints += grant;
            player.Buffs.SetCustomVar(BankedPointsKey, banked - grant, true, CVarOperation.set, false);
            player.Progression.bProgressionStatsChanged = true;
        }

        public static void SyncPoints(Progression progression)
        {
            var player = Workshop.Player();
            if (player == null || progression == null || !ReferenceEquals(player.Progression, progression)) return;
            if (Enabled) StorePoints(player); else RestorePoints(player);
        }

        public static void Tick(EntityPlayerLocal player)
        {
            if (player == null || !ReferenceEquals(player, Workshop.Player())) return;
            if (Enabled) { StorePoints(player); MigratePreview(player); TryPending(player); }
            else RestorePoints(player);
        }

        public static void IncrementInternal(ProgressionValue value)
        {
            internalRankChange++;
            try { value.Level++; }
            finally { internalRankChange--; }
        }

        public static void RecordWeapon(string itemName, string weaponSkill, int damage, bool headshot)
        {
            if (!Enabled || damage <= 0) return;
            string perk = PrimaryWeaponPerk(itemName, weaponSkill);
            if (perk == null) return;
            double basePractice = ActionPreviewMath.BaseDamage(damage, 1);
            Grant(perk, basePractice);
            var definition = Find(perk);
            if (definition != null && !String.IsNullOrEmpty(definition.Parent) && attributeFrames.Take(definition.Parent + "_" + (weaponSkill ?? perk), Time.frameCount))
                Grant(definition.Parent, basePractice * 0.5);
            string secondary = SecondaryWeaponPerk(weaponSkill);
            if (secondary != null) Grant(secondary, basePractice * 0.2);
            if (headshot && (perk == "perkDeadEye" || perk == "perkArchery" || perk == "perkGunslinger")) Grant(perk, ActionPreviewMath.HeadshotBonus(basePractice));
            if (headshot && weaponSkill == "craftingRifles") Grant("perkPenetrator", ActionPreviewMath.HeadshotBonus(basePractice));
        }

        public static void RecordCraft(ItemStack stack)
        {
            if (stack == null || stack.IsEmpty()) return;
            string craftedName = stack.itemValue.ItemClass.GetItemName();
            if (craftedName.IndexOf("apiary", StringComparison.OrdinalIgnoreCase) >= 0)
                Discover("perkApiarist", 10);
            if (IsDiscovered(Workshop.Player(), "perkApiarist") &&
                (craftedName.IndexOf("apiary", StringComparison.OrdinalIgnoreCase) >= 0 ||
                 craftedName.IndexOf("honey", StringComparison.OrdinalIgnoreCase) >= 0))
                Grant("perkApiarist", Math.Min(1.0, stack.count * 0.1));
            if (!Enabled) return;
            List<PracticeRule> rules;
            if (!Workshop.Rules.TryGetValue(craftedName, out rules)) return;
            var seen = new HashSet<string>(); var parents = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var rule in rules) {
                string perk = null;
                switch (rule.Skill) {
                    case "craftingFood": perk="perkMasterChef"; break;
                    case "craftingMedical": perk="perkPhysician"; break;
                    case "craftingVehicles": perk="perkGreaseMonkey"; break;
                    case "craftingSeeds": perk="perkLivingOffTheLand"; break;
                    case "craftingElectrician": case "craftingWorkstations": case "craftingConstruction": perk="perkAdvancedEngineering"; break;
                }
                if (perk != null && seen.Add(perk)) {
                    double normalized = PracticeMath.NormalizedOutput(stack.count, rule.Units) / (double)Math.Max(1, rule.Output);
                    double credit = Math.Min(2, normalized * Math.Max(0.1, rule.Credit * 0.1));
                    Grant(perk, credit);
                    var definition=Find(perk); if(definition!=null && !String.IsNullOrEmpty(definition.Parent))parents.Add(definition.Parent);
                }
            }
            foreach(string parent in parents) Grant(parent,0.5);
        }

        public static void RecordHarvest(ItemValue tool, ItemStack output, BlockValue block)
        {
            if (output == null || output.IsEmpty()) return;
            string blockName = block.Block == null ? "" : block.Block.GetBlockName();
            string itemName = output.itemValue.ItemClass.GetItemName();
            bool apiary = blockName.IndexOf("Apiary", StringComparison.OrdinalIgnoreCase) >= 0;
            bool honey = itemName.IndexOf("Honey", StringComparison.OrdinalIgnoreCase) >= 0;
            if (apiary && honey) Discover("perkApiarist", 10);
            if (IsDiscovered(Workshop.Player(), "perkApiarist") && honey)
                Grant("perkApiarist", Math.Min(2, output.count * 0.2));
            if (!Enabled) return;
            double credit = Math.Min(2, Math.Max(0.1, output.count * 0.1));
            if (blockName.StartsWith("planted", StringComparison.OrdinalIgnoreCase) && blockName.IndexOf("Harvest", StringComparison.OrdinalIgnoreCase) >= 0) {
                Grant("perkLivingOffTheLand", credit);
                Grant("attFortitude", credit * 0.5);
                return;
            }
            if (itemName.StartsWith("resourceAnimal", StringComparison.OrdinalIgnoreCase) || itemName.IndexOf("Animal", StringComparison.OrdinalIgnoreCase) >= 0) {
                Grant("perkTheHuntsman", credit);
                if (tool != null && !tool.IsEmpty()) {
                    string toolName=tool.ItemClass.GetItemName();
                    if (toolName.IndexOf("knife",StringComparison.OrdinalIgnoreCase)>=0 || toolName.IndexOf("machete",StringComparison.OrdinalIgnoreCase)>=0)
                        Grant("perkDeepCuts",credit*0.25);
                }
                Grant("attFortitude", credit * 0.5);
                return;
            }
            bool natural = blockName.IndexOf("ore", StringComparison.OrdinalIgnoreCase) >= 0 ||
                blockName.IndexOf("stone", StringComparison.OrdinalIgnoreCase) >= 0 ||
                blockName.IndexOf("rock", StringComparison.OrdinalIgnoreCase) >= 0 ||
                blockName.IndexOf("tree", StringComparison.OrdinalIgnoreCase) >= 0 ||
                blockName.IndexOf("wood", StringComparison.OrdinalIgnoreCase) >= 0;
            if (natural) {
                Grant("perkMiner69r", credit);
                Grant("perkMotherLode", credit * 0.2);
                Grant("attStrength", credit * 0.5);
            } else {
                Grant("perkSalvageOperations", credit);
                Grant("perkJunkMiner", credit * 0.5);
                Grant("attPerception", credit * 0.5);
            }
        }

        public static string PrimaryWeaponPerk(string itemName, string weaponSkill)
        {
            if (!String.IsNullOrEmpty(itemName)) {
                if (itemName.IndexOf("baton", StringComparison.OrdinalIgnoreCase) >= 0) return "perkElectrocutioner";
            }
            switch (weaponSkill) {
                case "craftingRifles": return "perkDeadEye";
                case "craftingShotguns": return "perkBoomstick";
                case "craftingSpears": return "perkJavelinMaster";
                case "craftingClubs": return "perkPummelPete";
                case "craftingSledgehammers": return "perkSkullCrusher";
                case "craftingBows": return "perkArchery";
                case "craftingBlades": return "perkDeepCuts";
                case "craftingHandguns": return "perkGunslinger";
                case "craftingMachineGuns": return "perkMachineGunner";
                case "craftingKnuckles": return "perkBrawler";
                case "craftingExplosives": return "perkDemolitionsExpert";
                case "craftingRobotics": return "perkTurrets";
                default: return null;
            }
        }

        public static string SecondaryWeaponPerk(string weaponSkill)
        {
            switch (weaponSkill) {
                case "craftingSpears": return "perkFlurryOfPerception";
                case "craftingClubs": case "craftingSledgehammers": return "perkFlurryOfStrength";
                case "craftingKnuckles": return "perkFlurryOfFortitude";
                case "craftingBlades": return "perkFlurryOfAgility";
                case "craftingRobotics": return "perkFlurryOfIntellect";
                default: return null;
            }
        }
    }

    [HarmonyPatch(typeof(ProgressionValue), "set_Level")]
    public static class LearnByDoingRankPurchasePatch
    {
        public static bool Prefix(ProgressionValue __instance, int __0)
        {
            return !LearnByDoing.Enabled || LearnByDoing.IsInternalRankChange || __0 <= __instance.Level;
        }
    }

    [HarmonyPatch(typeof(Progression), "SpendSkillPoints")]
    public static class LearnByDoingSpendPointsPatch
    {
        public static bool Prefix(Progression __instance) { LearnByDoing.SyncPoints(__instance); return !LearnByDoing.Enabled; }
    }

    [HarmonyPatch(typeof(Progression), "AddLevelExp")]
    public static class LearnByDoingPointBankPatch
    {
        public static void Prefix(Progression __instance, out int __state) { __state = __instance.SkillPoints; }
        public static void Postfix(Progression __instance) { LearnByDoing.SyncPoints(__instance); }
    }

    [HarmonyPatch(typeof(XUiC_SkillList), "OnOpen")]
    public static class LearnByDoingSkillScreenPatch
    {
        public static void Postfix() { LearnByDoing.Tick(Workshop.Player()); }
    }

    [HarmonyPatch(typeof(QuestJournal), "CompleteQuest")]
    public static class LearnByDoingQuestPracticePatch
    {
        public static void Postfix(Quest __0)
        {
            if (!LearnByDoing.Enabled || __0 == null) return;
            LearnByDoing.Grant("perkDaringAdventurer", 15);
            LearnByDoing.Grant("perkCharismaticNature", 10);
            LearnByDoing.Grant("attIntellect", 10);
        }
    }
}
