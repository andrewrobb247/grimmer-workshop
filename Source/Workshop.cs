using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Xml.Linq;
using HarmonyLib;
using UnityEngine;

namespace GrimmerWorkshop
{
    public class WorkshopMod : IModApi
    {
        public void InitMod(Mod mod)
        {
            Workshop.Root = mod.Path;
            Workshop.Load();
            new Harmony("grimmer.workshop.core").PatchAll(Assembly.GetExecutingAssembly());
            Log.Out("[Grimmer Workshop] 0.1.53 loaded. Learn by Doing: " + LearnByDoing.Enabled + ". Solo V3.4 b10. F1: grimmer help");
        }
    }

    public sealed class PracticeRule
    {
        public string Item, Skill;
        public int Output, Unlock, Until, Cap;
        public int Units = 1;
        public double Credit;
    }

    public static class Workshop
    {
        public static string Root;
        public static double Cost = 40, Growth = 0.5, Speed = 1;
        public static double ScrapCredit = 0.25, CraftedScrapCredit = 0.1;
        public static double ActivitySpeed = 1;
        public static bool PracticeNotifications = true;
        public static int Range = 20;
        public static bool NearbyCrafting = true;
        public static Dictionary<string, List<PracticeRule>> Rules = new Dictionary<string, List<PracticeRule>>();
        public static HashSet<string> Skills = new HashSet<string>();
        [ThreadStatic] public static int CraftingScope;
        [ThreadStatic] public static int ScrapOutputScope;

        public static void Load()
        {
            XDocument config = XDocument.Load(Path.Combine(Root, "WorkshopSettings.xml"));
            XElement settings = config.Root;
            Cost = ReadNumber(settings, "practicePerLevel", 40, 1, 10000);
            Growth = ReadNumber(settings, "practiceGrowth", 0.5, 0, 1000);
            Speed = ReadNumber(settings, "learningSpeed", 1, 0.1, 10);
            ScrapCredit = ReadNumber(settings, "scrapPracticeFraction", 0.25, 0, 1);
            CraftedScrapCredit = ReadNumber(settings, "craftedScrapPracticeFraction", 0.1, 0, 1);
            ActivitySpeed = ReadNumber(settings, "activityLearningSpeed", 1, 0, 10);
            PracticeNotifications = (bool?)settings.Attribute("practiceNotifications") ?? true;
            Range = (int)ReadNumber(settings, "storageRange", 20, 1, 40);
            NearbyCrafting = (bool?)settings.Attribute("nearbyCrafting") ?? true;
            bool actionPreview = (bool?)settings.Attribute("actionSkillPreview") ?? false;
            double actionPreviewSpeed = ReadNumber(settings, "actionPreviewSpeed", 1, 0.1, 10);
            bool learnByDoing = (bool?)settings.Attribute("learnByDoing") ?? true;
            double learnByDoingSpeed = ReadNumber(settings, "learnByDoingSpeed", actionPreviewSpeed, 0.1, 10);
            LearnByDoing.Load(Root, learnByDoing, learnByDoingSpeed);
            ActionSkillPreview.Load(Root, actionPreview && !learnByDoing, actionPreviewSpeed);
            var rules = new Dictionary<string, List<PracticeRule>>();
            var skills = new HashSet<string>();
            foreach (XElement entry in XDocument.Load(Path.Combine(Root, "PracticeRules.xml")).Root.Elements("rule"))
            {
                var rule = new PracticeRule {
                    Item = (string)entry.Attribute("item"), Skill = (string)entry.Attribute("skill"),
                    Output = (int)entry.Attribute("output"), Unlock = (int)entry.Attribute("unlock"),
                    Until = (int)entry.Attribute("until"), Cap = (int)entry.Attribute("cap"),
                    Units = (int?)entry.Attribute("units") ?? 1,
                    Credit = (double)entry.Attribute("credit")
                };
                if (rule.Units < 1 || rule.Units > 10000) throw new InvalidDataException("Invalid practice units: " + rule.Item);
                if (!rules.ContainsKey(rule.Item)) rules[rule.Item] = new List<PracticeRule>();
                rules[rule.Item].Add(rule);
                skills.Add(rule.Skill);
            }
            try {
                int optional = ArsenalRules.Register(Root,rules,skills);
                if (optional > 0) Log.Out("[Grimmer Workshop] Added practice for all 53 DSD Arsenal weapons and Energy Cells. Author pack files unchanged.");
            } catch(Exception error) { Log.Error("[Grimmer Workshop] Optional Arsenal practice unavailable: "+error.Message); }
            try {
                int optional=VehiclePackRules.Register(Root,rules,skills);
                if(optional>0)Log.Out("[Grimmer Workshop] Added Vehicles practice for "+optional+" Bdub outputs. Author files unchanged.");
            } catch(Exception error) { Log.Error("[Grimmer Workshop] Optional vehicle practice unavailable: "+error.Message); }
            try {
                int optional=DecorRules.Register(Root,rules,skills);
                if(optional>0)Log.Out("[Grimmer Workshop] Added Construction practice for "+optional+" Beautiful Bases outputs. Author files unchanged.");
            } catch(Exception error) { Log.Error("[Grimmer Workshop] Optional decor practice unavailable: "+error.Message); }
            Rules = rules;
            Skills = skills;
        }

        private static double ReadNumber(XElement element, string name, double fallback, double min, double max)
        {
            double value = (double?)element.Attribute(name) ?? fallback;
            if (double.IsNaN(value) || double.IsInfinity(value) || value < min || value > max)
                throw new InvalidDataException("Invalid setting: " + name);
            return value;
        }

        public static EntityPlayerLocal Player()
        {
            if (GameManager.Instance == null || GameManager.Instance.World == null) return null;
            if (!ConnectionManager.Instance.IsSinglePlayer) return null;
            return GameManager.Instance.World.GetPrimaryPlayer();
        }

        public static void Award(ItemStack stack, bool scrapped = false)
        {
            var player = Player();
            if (player == null || stack == null || stack.IsEmpty()) return;
            // Scrap teaches equipment skills, never raw-material processing loops.
            if (scrapped && !stack.itemValue.HasQuality) return;
            double multiplier = PracticeMath.QualityMultiplier(stack.itemValue.Quality);
            if (scrapped) {
                int crafted;
                bool playerMade = stack.itemValue.TryGetMetadata("GrimmerCrafted", out crafted) && crafted == 1;
                multiplier *= playerMade ? CraftedScrapCredit : ScrapCredit;
            }
            List<PracticeRule> rules;
            if (!Rules.TryGetValue(stack.itemValue.ItemClass.GetItemName(), out rules)) return;
            foreach (var rule in rules)
            {
                if (scrapped && rule.Skill == "craftingWorkstations") continue;
                var value = player.Progression.GetProgressionValue(rule.Skill);
                if (value == null) continue;
                int maximum = Math.Min(value.ProgressionClass.MaxLevel, rule.Cap);
                if (value.Level >= maximum) continue;
                double practice = player.Buffs.GetCustomVar("grimmerPractice_" + rule.Skill);
                double credit = PracticeMath.CreditAcrossLevels(PracticeMath.NormalizedOutput(stack.count, rule.Units), rule.Output, rule.Unlock, value.Level,
                    rule.Until, rule.Credit, Speed * multiplier, practice, maximum, Cost, Growth);
                Grant(player, rule.Skill, credit, maximum);
            }
        }

        public static void Grant(EntityPlayerLocal player, string skill, double amount, int cap)
        {
                if (amount <= 0 || double.IsNaN(amount) || double.IsInfinity(amount)) return;
                var value = player.Progression.GetProgressionValue(skill);
                if (value == null) return;
                int maximum = Math.Min(value.ProgressionClass.MaxLevel, cap);
                if (value.Level >= maximum) return;
                string key = "grimmerPractice_" + skill;
                double practice = player.Buffs.GetCustomVar(key);
                practice += amount;
                int before = value.Level;
                while (value.Level < maximum && practice >= PracticeMath.Required(value.Level, Cost, Growth))
                {
                    practice -= PracticeMath.Required(value.Level, Cost, Growth);
                    LearnByDoing.IncrementInternal(value);
                }
                player.Buffs.SetCustomVar(key, (float)practice, true, CVarOperation.set, false);
                Activities.Notify(player, skill, amount, value.Level, practice);
                if (before == value.Level) return;
                player.Progression.bProgressionStatsChanged = true;
                player.bPlayerStatsChanged = true;
                value.ProgressionClass.HandleCheckCrafting(player, before, value.Level);
                if (player.PlayerUI != null && player.PlayerUI.xui.CollectedItemList != null)
                    player.PlayerUI.xui.CollectedItemList.AddCraftingSkillNotification(value, false);
                Log.Out("[Grimmer Workshop] " + skill + " " + before + " -> " + value.Level);
        }
    }

    [HarmonyPatch(typeof(QuestEventManager), "CraftedItem")]
    public static class CraftCompletedPatch
    {
        public static void Postfix(ItemStack __0)
        {
            try { if (Workshop.ScrapOutputScope == 0) { Workshop.Award(__0); LearnByDoing.RecordCraft(__0); } }
            catch (Exception error) { Log.Error("[Grimmer Workshop] Craft practice: " + error); }
        }
    }

    [HarmonyPatch(typeof(QuestEventManager), "ScrappedItem")]
    public static class ScrapCompletedPatch
    {
        public static void Postfix(ItemStack __0)
        {
            try { Workshop.Award(__0, true); }
            catch (Exception error) { Log.Error("[Grimmer Workshop] Scrap practice: " + error); }
        }
    }

    // Vanilla's full-output retry uses a separate path without ScrappedItem.
    [HarmonyPatch(typeof(XUiC_RecipeStack), "Update")]
    public static class ScrapRetryPatch
    {
        public sealed class State { public ItemStack Source; public int Count; }
        public static void Prefix(bool ___isInventoryFull, Recipe ___recipe, int ___recipeCount, out State __state)
        {
            __state = null;
            if (!___isInventoryFull || ___recipe == null || !___recipe.IsScrap || ___recipe.ingredients.Count == 0) return;
            __state = new State { Source = ___recipe.ingredients[0].Clone(), Count = ___recipeCount };
            Workshop.ScrapOutputScope++;
        }
        public static void Postfix(bool ___isInventoryFull, int ___recipeCount, State __state)
        {
            if (__state == null || ___isInventoryFull || ___recipeCount >= __state.Count) return;
            try { Workshop.Award(__state.Source, true); }
            catch (Exception error) { Log.Error("[Grimmer Workshop] Scrap retry practice: " + error); }
        }
        public static Exception Finalizer(State __state, Exception __exception)
        {
            if (__state != null) Workshop.ScrapOutputScope--;
            return __exception;
        }
    }

    // Vanilla emits ScrappedItem only after output succeeds; cancellations never reach it.
    // Suppress craft credit for the raw materials produced by that same operation.
    [HarmonyPatch]
    public static class ScrapOutputScopePatch
    {
        public static IEnumerable<MethodBase> TargetMethods()
        {
            yield return AccessTools.Method(typeof(XUiC_RecipeStack), "outputStack");
            yield return AccessTools.Method(typeof(XUiC_RecipeStack), "AddItemToInventory");
        }
        public static void Prefix(Recipe ___recipe, out bool __state)
        {
            __state = ___recipe != null && ___recipe.IsScrap;
            if (__state) Workshop.ScrapOutputScope++;
        }
        public static Exception Finalizer(bool __state, Exception __exception)
        {
            if (__state) Workshop.ScrapOutputScope--;
            return __exception;
        }
    }

    // Mark newly constructed crafting outputs before insertion, including closed stations.
    // Repair paths clone the original item instead, preserving its existing provenance.
    [HarmonyPatch]
    public static class CraftedEquipmentPatch
    {
        public static IEnumerable<MethodBase> TargetMethods()
        {
            yield return AccessTools.Method(typeof(XUiC_RecipeStack), "outputStack");
            yield return AccessTools.Method(typeof(TileEntityWorkstation), "HandleRecipeQueue");
        }
        public static ItemValue Mark(ItemValue item)
        {
            if (item != null && item.HasQuality) item.SetMetadata("GrimmerCrafted", 1);
            return item;
        }
        public static IEnumerable<CodeInstruction> Transpiler(IEnumerable<CodeInstruction> instructions)
        {
            int matches = 0;
            foreach (var instruction in instructions) {
                yield return instruction;
                var constructor = instruction.operand as ConstructorInfo;
                if (instruction.opcode == System.Reflection.Emit.OpCodes.Newobj && constructor != null && constructor.DeclaringType == typeof(ItemValue) && constructor.GetParameters().Length == 6) {
                    matches++;
                    yield return new CodeInstruction(System.Reflection.Emit.OpCodes.Call, AccessTools.Method(typeof(CraftedEquipmentPatch), "Mark"));
                }
            }
            if (matches != 1) throw new InvalidOperationException("Craft output layout changed; expected exactly one ItemValue constructor.");
        }
    }

    // Limit remote counts to recipe UI queries. Currency and other inventory operations
    // must continue counting only items physically held by the player.
    [HarmonyPatch]
    public static class RecipeScopePatch
    {
        public static IEnumerable<MethodBase> TargetMethods()
        {
            yield return AccessTools.Method(typeof(ItemActionEntryCraft), "RefreshEnabled");
            yield return AccessTools.Method(typeof(XUiC_RecipeCraftCount), "calcMaxCraftable");
            yield return AccessTools.Method(typeof(XUiM_Recipes), "HasIngredientsForRecipe");
            yield return AccessTools.Method(typeof(XUiC_IngredientEntry), "GetBindingValueInternal");
        }
        public static void Prefix() { Workshop.CraftingScope++; }
        public static Exception Finalizer(Exception __exception)
        {
            Workshop.CraftingScope--;
            return __exception;
        }
    }

    [HarmonyPatch(typeof(XUiM_PlayerInventory), "GetItemCount", new Type[] { typeof(ItemValue) })]
    public static class RecipeCountPatch
    {
        public static void Postfix(ItemValue __0, ref int __result)
        {
            if (Workshop.CraftingScope <= 0 || !Workshop.NearbyCrafting) return;
            foreach (var container in Storage.Nearby())
                __result += Storage.Count(container.Grid, __0);
        }
    }

    [HarmonyPatch(typeof(XUiM_PlayerInventory), "HasItems")]
    public static class RecipeHasItemsPatch
    {
        public static void Postfix(XUiM_PlayerInventory __instance, IList<ItemStack> __0, int __1, ref bool __result)
        {
            if (__result || Workshop.CraftingScope <= 0 || !Workshop.NearbyCrafting || Workshop.Player() == null) return;
            var containers = Storage.Nearby();
            var needed = new Dictionary<int, long>();
            foreach (var item in __0)
            {
                long old;
                needed.TryGetValue(item.itemValue.type, out old);
                needed[item.itemValue.type] = old + (long)item.count * __1;
            }
            __result = needed.All(pair => {
                var value = new ItemValue(pair.Key, false);
                long count = __instance.GetItemCount(pair.Key);
                foreach (var container in containers) count += Storage.Count(container.Grid, value);
                return count >= pair.Value;
            });
        }
    }

    [HarmonyPatch(typeof(XUiM_PlayerInventory), "GetAllItemStacks")]
    public static class RecipeStacksPatch
    {
        public static void Postfix(ref List<ItemStack> __result)
        {
            if (Workshop.CraftingScope <= 0 || !Workshop.NearbyCrafting) return;
            __result = new List<ItemStack>(__result);
            foreach (var container in Storage.Nearby())
                for (int slot = 0; slot < container.Grid.Length; slot++)
                    if (!container.Grid.IsSlotLocked(slot) && !container.Grid[slot].IsEmpty() && !container.Grid[slot].itemValue.HasQuality)
                        __result.Add(container.Grid[slot].Clone());
        }
    }

    [HarmonyPatch(typeof(ItemActionEntryCraft), "OnActivated")]
    public static class CollectCraftIngredientsPatch
    {
        public static bool Prefix(ItemActionEntryCraft __instance)
        {
            if (!Workshop.NearbyCrafting || Workshop.Player() == null) return true;
            var entry = __instance.ItemController as XUiC_RecipeEntry;
            if (entry == null || entry.Recipe == null || !entry.Recipe.IsUnlocked(Workshop.Player())) return true;
            // Forge material recipes consume internal smelted materials, never nearby crates.
            if (entry.Recipe.materialBasedRecipe || entry.Recipe.craftingArea == "forge") return true;
            var counter = (XUiC_RecipeCraftCount)AccessTools.Field(typeof(ItemActionEntryCraft), "craftCountControl").GetValue(__instance);
            bool available;
            Workshop.CraftingScope++;
            try
            {
                available = (bool)AccessTools.Method(typeof(ItemActionEntryCraft), "hasItems").Invoke(__instance, new object[] { entry.xui, entry.Recipe });
            }
            finally { Workshop.CraftingScope--; }
            if (!available) return true;
            // Ask vanilla to calculate the exact ingredient costs, including selected
            // quality, perks and sandbox multipliers, before gathering anything.
            var ingredients = ((List<ItemStack>)AccessTools.Field(typeof(ItemActionEntryCraft), "tempIngredientList").GetValue(__instance)).Select(s => s.Clone()).ToList();
            string failure;
            if (!Storage.Gather(ingredients, counter.Count, out failure))
            {
                GameManager.ShowTooltip(Workshop.Player(), failure, false, false, 4);
                return false;
            }
            return true;
        }
    }

    public class ConsoleCmdGrimmer : ConsoleCmdAbstract
    {
        public override bool IsExecuteOnClient { get { return true; } }
        public override int DefaultPermissionLevel { get { return 1000; } }
        public override string[] getCommands() { return new[] { "grimmer", "gw" }; }
        public override string getDescription() { return "Grimmer Workshop progression, storage and settings"; }
        public override string getHelp() { return "grimmer status | store | refill | reload | help"; }
        public override void Execute(List<string> args, CommandSenderInfo sender)
        {
            try
            {
                var player = Workshop.Player();
                string action = args.Count == 0 ? "help" : args[0].ToLowerInvariant();
                if (action == "reload") { Workshop.Load(); SdtdConsole.Instance.Output("Workshop settings reloaded."); return; }
                if (player == null) { SdtdConsole.Instance.Output("Load a solo world first."); return; }
                if (action == "store" || action == "refill")
                {
                    int count = Storage.Transfer(action == "refill");
                    SdtdConsole.Instance.Output("Transferred " + count + " items using nearby player storage.");
                    return;
                }
                if (action == "status")
                {
                    SdtdConsole.Instance.Output("Nearby eligible storage: " + Storage.Nearby().Count);
                    foreach (string skill in Workshop.Skills.OrderBy(s => s))
                    {
                        var value = player.Progression.GetProgressionValue(skill);
                        if (value == null) continue;
                        float practice = player.Buffs.GetCustomVar("grimmerPractice_" + skill);
                        if (args.Count > 1 && (Activities.Name(skill) + " " + skill).IndexOf(args[1], StringComparison.OrdinalIgnoreCase) < 0) continue;
                        SdtdConsole.Instance.Output(Activities.Name(skill) + " level " + value.Level + " | " + practice.ToString("0.0") + "/" + PracticeMath.Required(value.Level, Workshop.Cost, Workshop.Growth).ToString("0.0") + " practice");
                    }
                    return;
                }
                SdtdConsole.Instance.Output(getHelp() + "\nCraft normally near your placed crates. Lock slots with the padlock. Store skips locked backpack slots; refill tops them up.");
            }
            catch (Exception error) { SdtdConsole.Instance.Output("Workshop error: " + error.Message); Log.Error("[Grimmer Workshop] " + error); }
        }
    }
}






