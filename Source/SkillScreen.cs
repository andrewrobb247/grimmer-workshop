using System;
using System.Collections.Generic;
using System.Globalization;
using System.Runtime.CompilerServices;
using HarmonyLib;
using UnityEngine;

namespace GrimmerWorkshop
{
    public static class SkillScreen
    {
        sealed class Snapshot { public float Next, Practice, ActionBase, ActionBonus; public string Name; public int Level; public bool Discovered; public double Cost, Growth, Activity; }
        static readonly ConditionalWeakTable<XUiController, Snapshot> snapshots = new ConditionalWeakTable<XUiController, Snapshot>();
        public static string SkillName(ProgressionValue skill)
        {
            if (skill == null) return null;
            foreach (string name in Workshop.Skills)
                if (String.Equals(name,skill.Name,StringComparison.OrdinalIgnoreCase)) return name;
            return null;
        }
        public static bool IsCrafting(ProgressionValue skill)
        {
            return SkillName(skill) != null && Workshop.Player() != null;
        }
        public static bool Changed(XUiController controller, ProgressionValue skill)
        {
            bool crafting = IsCrafting(skill);
            bool action = skill != null && ActionSkillPreview.IsActionSkill(skill.Name) && Workshop.Player() != null;
            bool learning = skill != null && LearnByDoing.Enabled && LearnByDoing.HasSkill(skill.Name) && Workshop.Player() != null;
            bool hidden = skill != null && LearnByDoing.HasSkill(skill.Name) && LearnByDoing.Find(skill.Name).Hidden && Workshop.Player() != null;
            if ((!crafting && !action && !learning && !hidden) || controller.WindowGroup == null || !controller.WindowGroup.isShowing) return false;
            var snapshot = snapshots.GetOrCreateValue(controller);
            float now = Time.realtimeSinceStartup;
            if (now < snapshot.Next && now >= snapshot.Next - 0.25f) return false;
            snapshot.Next = now + 0.25f;
            if (learning || hidden) {
                var value=Workshop.Player().Progression.GetProgressionValue(skill.Name);
                float learningPractice=(float)LearnByDoing.Read(Workshop.Player(),skill.Name);
                bool discovered=LearnByDoing.IsVisible(skill.Name);
                bool learningChanged=snapshot.Name!=skill.Name || snapshot.Level!=(value==null?0:value.Level) || snapshot.Practice!=learningPractice || snapshot.Discovered!=discovered;
                snapshot.Name=skill.Name; snapshot.Level=value==null?0:value.Level; snapshot.Practice=learningPractice;
                snapshot.Discovered=discovered;
                return learningChanged;
            }
            if (action) {
                float actionBase=(float)ActionSkillPreview.Read(skill.Name,"base"), actionBonus=(float)ActionSkillPreview.Read(skill.Name,"bonus");
                bool actionChanged=snapshot.Name!=skill.Name || snapshot.ActionBase!=actionBase || snapshot.ActionBonus!=actionBonus;
                snapshot.Name=skill.Name; snapshot.ActionBase=actionBase; snapshot.ActionBonus=actionBonus;
                return actionChanged;
            }
            float practice = Workshop.Player().Buffs.GetCustomVar("grimmerPractice_" + SkillName(skill));
            bool changed = snapshot.Name != skill.Name || snapshot.Level != skill.Level || snapshot.Practice != practice || snapshot.Cost != Workshop.Cost || snapshot.Growth != Workshop.Growth || snapshot.Activity != Workshop.ActivitySpeed;
            snapshot.Name=skill.Name; snapshot.Level=skill.Level; snapshot.Practice=practice; snapshot.Cost=Workshop.Cost; snapshot.Growth=Workshop.Growth; snapshot.Activity=Workshop.ActivitySpeed;
            return changed;
        }
        public static string Progress(ProgressionValue skill)
        {
            return SkillScreenText.Progress(skill.Level,skill.ProgressionClass.MaxLevel,Workshop.Player().Buffs.GetCustomVar("grimmerPractice_"+SkillName(skill)),Workshop.Cost,Workshop.Growth);
        }
        public static string Fill(ProgressionValue skill)
        {
            return SkillScreenText.Ratio(skill.Level,skill.ProgressionClass.MaxLevel,Workshop.Player().Buffs.GetCustomVar("grimmerPractice_"+SkillName(skill)),Workshop.Cost,Workshop.Growth).ToString("0.####",CultureInfo.InvariantCulture);
        }
        public static string Next(ProgressionValue skill)
        {
            if (SkillName(skill)=="craftingConstruction") return "Construction bonus: " + (15.0*Math.Max(0,Math.Min(99,skill.Level-1))/99).ToString("0.#",CultureInfo.InvariantCulture) + "% less building craft time (15% at level 100).";
            var milestones = new List<SkillMilestone>();
            if (skill.ProgressionClass.DisplayDataList != null) foreach (var display in skill.ProgressionClass.DisplayDataList) {
                if (!display.Enabled) continue;
                int next = display.GetNextPoints(skill.Level);
                if (next <= skill.Level) continue;
                // Non-quality entries name the next pending recipe using the
                // zero-based count of completed thresholds. At the threshold
                // itself GetName has already advanced to the following recipe.
                string name = Localization.Get(display.GetName(display.HasQuality ? next : next - 1),false);
                milestones.Add(new SkillMilestone { Level=next, Name=name, Quality=display.HasQuality ? display.GetQualityLevel(next) : 0 });
            }
            return SkillScreenText.Next(skill.Level,skill.ProgressionClass.MaxLevel,milestones);
        }
        public static bool IsActionPreview(ProgressionValue skill)
        {
            return skill != null && ActionSkillPreview.IsActionSkill(skill.Name);
        }
        public static bool IsLearnByDoing(ProgressionValue skill)
        {
            return skill != null && LearnByDoing.Enabled && LearnByDoing.HasSkill(skill.Name);
        }
        public static string IsHiddenSkillVisible(ProgressionValue skill)
        {
            if (skill == null || !LearnByDoing.HasSkill(skill.Name)) return "true";
            var definition = LearnByDoing.Find(skill.Name);
            if (definition == null || !definition.Hidden) return "true";
            // If a player turns off practice progression, keep ordinary native
            // perks usable through the vanilla point system. Secret perks stay hidden.
            if (!LearnByDoing.Enabled && definition.Kind != "secret") return "true";
            return LearnByDoing.IsVisible(skill.Name) ? "true" : "false";
        }
    }

    [HarmonyPatch(typeof(XUiC_SkillCraftingInfoWindow), "GetBindingValueInternal")]
    public static class SkillDetailsBindingsPatch
    {
        public static bool Prefix(XUiC_SkillCraftingInfoWindow __instance, ref string __0, string __1, ref bool __result)
        {
            var skill = __instance.CurrentSkill;
            if (SkillScreen.IsLearnByDoing(skill)) {
                switch(__1) {
                    case "gw_practice": __0=LearnByDoing.Progress(Workshop.Player(),skill.Name); __result=true; return false;
                    case "gw_fill": __0=LearnByDoing.Ratio(Workshop.Player(),skill.Name).ToString("0.####",CultureInfo.InvariantCulture); __result=true; return false;
                    case "gw_training": { var definition=LearnByDoing.Find(skill.Name); __0="Train: " + (definition==null || String.IsNullOrEmpty(definition.Action) ? "use actions matching this skill." : definition.Action) + " Ranks increase automatically when native gates are met."; __result=true; return false; }
                    case "gw_next": __0="Learn by Doing is active. Unspent skill points are banked until the mode is turned off."; __result=true; return false;
                    case "gw_next_full": __0="Learn by Doing is active. Unspent skill points are banked until the mode is turned off."; __result=true; return false;
                    case "groupdescription": __0="Learn by Doing: actions build practice and raise ranks automatically. Existing ranks are preserved; native attribute requirements still apply."; __result=true; return false;
                }
            }
            if (skill != null && ActionSkillPreview.IsActionSkill(skill.Name) && __1=="groupdescription") { __0=ActionSkillPreview.Description(skill.Name); __result=true; return false; }
            if (SkillScreen.IsActionPreview(skill)) {
                switch(__1) {
                    case "gw_practice": __0=ActionSkillPreview.Progress(skill.Name); __result=true; return false;
                    case "gw_fill": __0=ActionSkillPreview.Fill(skill.Name); __result=true; return false;
                    case "gw_training": __0="Tracked actions earn preview practice. Specialty actions add bonus practice where recorded."; __result=true; return false;
                    case "gw_next": __0="Preview only: this bar does not change perk ranks or skill points."; __result=true; return false;
                    case "gw_next_full": __0="Preview only: this bar does not change perk ranks or skill points."; __result=true; return false;
                }
            }
            if (!SkillScreen.IsCrafting(skill)) {
                if (__1=="gw_practice" || __1=="gw_fill" || __1=="gw_training" || __1=="gw_next" || __1=="gw_next_full") {
                    __0=__1=="gw_fill" ? "0" : ""; __result=true; return false;
                }
                return true;
            }
            switch(__1) {
                case "gw_practice": __0=SkillScreen.Progress(skill); break;
                case "gw_fill": __0=SkillScreen.Fill(skill); break;
                case "gw_training": __0=SkillScreenText.Training(SkillScreen.SkillName(skill),skill.Level,Workshop.ActivitySpeed>0); break;
                case "gw_next": __0=SkillScreenText.Shorten(SkillScreen.Next(skill),80); break;
                case "gw_next_full": __0=SkillScreen.Next(skill); break;
                case "groupdescription": __0=SkillScreen.SkillName(skill)=="craftingConstruction" ? "Craft base pieces and upgrade blocks. Gradually reduces building recipe craft time by up to 15%." : "Learn by crafting and relevant activities. Better-quality crafts teach more."; break;
                default: return true;
            }
            __result=true; return false;
        }
    }

    [HarmonyPatch(typeof(XUiC_SkillEntry), "GetBindingValueInternal")]
    public static class SkillRowBindingsPatch
    {
        public static void Postfix(XUiC_SkillEntry __instance, ref string __0, string __1, ref bool __result)
        {
            var skill=__instance.Skill;
            if (__1=="gw_skill_visible") { __0=SkillScreen.IsHiddenSkillVisible(skill); __result=true; return; }
            if (SkillScreen.IsLearnByDoing(skill)) {
                if (__1=="skillpercentthislevel") { __0=LearnByDoing.Ratio(Workshop.Player(),skill.Name).ToString("0.####",CultureInfo.InvariantCulture); __result=true; }
                if (__1=="skillpercentshouldshow") { __0="true"; __result=true; }
                return;
            }
            if (SkillScreen.IsActionPreview(skill)) {
                if (__1=="skillpercentthislevel") { __0=ActionSkillPreview.Fill(skill.Name); __result=true; }
                if (__1=="skillpercentshouldshow") { __0="true"; __result=true; }
                return;
            }
            if (!SkillScreen.IsCrafting(skill)) return;
            if (__1=="skillpercentthislevel") { __0=SkillScreen.Fill(skill); __result=true; }
            if (__1=="skillpercentshouldshow") { __0="true"; __result=true; }
        }
    }

    [HarmonyPatch(typeof(XUiC_SkillEntry), "GetGroupPointCost")]
    public static class LearnByDoingSkillCostPatch
    {
        public static void Postfix(XUiC_SkillEntry __instance, ref string __result)
        {
            if (SkillScreen.IsLearnByDoing(__instance.Skill)) __result="LEARN";
        }
    }

    [HarmonyPatch(typeof(XUiC_SkillCraftingInfoWindow), "Update")]
    public static class SkillDetailsRefreshPatch
    {
        public static void Prefix(XUiC_SkillCraftingInfoWindow __instance)
        {
            if (SkillScreen.Changed(__instance,__instance.CurrentSkill)) __instance.IsDirty=true;
        }
    }
    [HarmonyPatch(typeof(XUiC_SkillEntry), "Update")]
    public static class SkillRowsRefreshPatch
    {
        public static void Prefix(XUiC_SkillEntry __instance)
        {
            if (SkillScreen.Changed(__instance,__instance.Skill)) __instance.IsDirty=true;
        }
    }

    // The native rank templates contain every future rank, including locked
    // names. Preserve the game's pager decision, then expose only ranks already
    // earned and the next rank the player can work toward.
    static class SkillRankVisibility
    {
        public static void Apply(ProgressionValue skill, int level, string binding, ref string value, ref bool handled)
        {
            if (binding != "nothiddenbypager" || skill == null || level <= skill.Level + 1) return;
            value = "false";
            handled = true;
        }
    }

    [HarmonyPatch(typeof(XUiC_SkillAttributeLevel), "GetBindingValueInternal")]
    public static class SkillAttributeRankVisibilityPatch
    {
        public static void Postfix(XUiC_SkillAttributeLevel __instance, ref string __0, string __1, ref bool __result)
        {
            SkillRankVisibility.Apply(__instance.CurrentSkill, __instance.Level, __1, ref __0, ref __result);
        }
    }

    [HarmonyPatch(typeof(XUiC_SkillPerkLevel), "GetBindingValueInternal")]
    public static class SkillPerkRankVisibilityPatch
    {
        public static void Postfix(XUiC_SkillPerkLevel __instance, ref string __0, string __1, ref bool __result)
        {
            SkillRankVisibility.Apply(__instance.CurrentSkill, __instance.Level, __1, ref __0, ref __result);
        }
    }
}
