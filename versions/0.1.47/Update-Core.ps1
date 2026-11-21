Set-StrictMode -Version 2


function Write-WorkshopAttachments([string]$Root, [string]$GameDirectory) {
    [xml]$baseline = Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\item_modifiers.xml') -Raw
    if (-not $baseline.SelectSingleNode("/item_modifiers/item_modifier[@name='modGeneralMaster']")) { throw 'Attachment base definition changed.' }
    $directory = Join-Path $Root 'Profile\Mods\GrimmerWorkshop\Config'
    Assert-WorkshopPlainPath $directory
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $modifiers = @'
<configs>
  <append xpath="/item_modifiers">
    <item_modifier name="grimmerLightGrip" installable_tags="perkPummelPete,perkSkullCrusher,perkJavelinMaster,perkDeepCuts,perkBrawler,perkElectrocutioner" modifier_tags="grimmerGrip" blocked_tags="noMods" type="attachment">
      <property name="Extends" value="modGeneralMaster" />
      <property name="CustomIcon" value="modMeleeErgonomicGrip" />
      <property name="CustomIconTint" value="A7DDA8" />
      <property name="DescriptionKey" value="grimmerLightGripDesc" />
      <property name="DisplayType" value="grimmerLightGrip" />
      <property name="ShowQuality" value="false" />
      <property name="EconomicValue" value="150" />
      <effect_group tiered="false">
        <!-- Display metadata compensates for vanilla flooring after float conversion. Gameplay values stay exact. -->
        <display_value name="dStaminaLoss" value="-0.14999" />
        <display_value name="dDegradationPerUse" value="0.20001" />
        <passive_effect name="StaminaLoss" operation="perc_add" value="-0.15" tags="primary,secondary" />
        <passive_effect name="DegradationPerUse" operation="perc_add" value="0.20" tags="perkPummelPete,perkSkullCrusher,perkJavelinMaster,perkDeepCuts,perkBrawler,perkElectrocutioner" />
      </effect_group>
    </item_modifier>
    <item_modifier name="grimmerPowerGrip" installable_tags="perkPummelPete,perkSkullCrusher,perkJavelinMaster,perkDeepCuts,perkBrawler,perkElectrocutioner" modifier_tags="grimmerGrip" blocked_tags="noMods" type="attachment">
      <property name="Extends" value="modGeneralMaster" />
      <property name="CustomIcon" value="modMeleeWeightedHead" />
      <property name="CustomIconTint" value="DDA588" />
      <property name="DescriptionKey" value="grimmerPowerGripDesc" />
      <property name="DisplayType" value="grimmerPowerGrip" />
      <property name="ShowQuality" value="false" />
      <property name="EconomicValue" value="150" />
      <effect_group tiered="false">
        <display_value name="dEntityDamage" value="0.10001" />
        <display_value name="dStaminaLoss" value="0.15001" />
        <passive_effect name="EntityDamage" operation="perc_add" value="0.10" />
        <passive_effect name="StaminaLoss" operation="perc_add" value="0.15" tags="primary,secondary" />
      </effect_group>
    </item_modifier>
  </append>
</configs>
'@
    $localization = @'
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english
 grimmerLightGrip,items,Item,,,,Light Grip Mod
 grimmerLightGripDesc,items,Item,,,,"Light swings: adds -15% attack stamina cost and +20% durability loss per use. Fits clubs, sledges, spears, knives, knuckles and batons with a free mod slot. Choose one Workshop grip. Removable. Other perks and installed mods also affect final stats."
 grimmerPowerGrip,items,Item,,,,Power Grip Mod
 grimmerPowerGripDesc,items,Item,,,,"Heavy swings: adds +10% melee damage and +15% attack stamina cost. Fits clubs, sledges, spears, knives, knuckles and batons with a free mod slot. Choose one Workshop grip. Removable. Other perks and installed mods also affect final stats."
'@
    $localization = $localization -replace '(?m)^ grimmer','grimmer'
    $display = @'
<configs>
  <append xpath="/ui_display_info/item_display">
    <item_display_info display_type="grimmerLightGrip" display_group="groupRanged">
      <display_entry name="dStaminaLoss" title_key="grimmerAttackStamina" display_type="Percent" negative_preferred="true" display_leading_plus="true" />
      <display_entry name="dDegradationPerUse" title_key="grimmerDurabilityLoss" display_type="Percent" negative_preferred="true" display_leading_plus="true" />
    </item_display_info>
    <item_display_info display_type="grimmerPowerGrip" display_group="groupRanged">
      <display_entry name="dEntityDamage" title_key="grimmerMeleeDamage" display_type="Percent" display_leading_plus="true" />
      <display_entry name="dStaminaLoss" title_key="grimmerAttackStamina" display_type="Percent" negative_preferred="true" display_leading_plus="true" />
    </item_display_info>
  </append>
</configs>
'@
    $localization += "
" + @'
grimmerAttackStamina,ui_display,Stat,,,,Attack Stamina Cost
grimmerDurabilityLoss,ui_display,Stat,,,,Durability Loss Per Use
grimmerMeleeDamage,ui_display,Stat,,,,Melee Damage
craftingConstructionName,progression,Attribute,,,,Construction
craftingConstructionDesc,progression,Attribute,,,,"Learn by crafting building materials and base pieces or upgrading blocks. Construction gradually reduces crafting time for tagged building recipes by up to 15% at level 100. Existing recipe unlock requirements still apply."
craftingConstructionLongDesc,progression,Attribute,,,,Build and improve your base to learn Construction.
'@
    [xml]$validated = $display
    [xml]$validated = $modifiers
    foreach ($pair in @(@('item_modifiers.xml',$modifiers),@('Localization.csv',$localization),@('ui_display.xml',$display))) {
        $destination=Join-Path $directory $pair[0]
        Assert-WorkshopPlainPath $destination; Assert-WorkshopPlainPath ($destination+'.tmp')
        [IO.File]::WriteAllText(($destination+'.tmp'),$pair[1],(New-Object Text.UTF8Encoding($false)))
        Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    }
    Write-WorkshopToolOptions $Root $GameDirectory
    Write-WorkshopVehicleParts $Root $GameDirectory
    Write-WorkshopGunsmith $Root $GameDirectory
    Write-WorkshopCookingStove $Root $GameDirectory
    Write-WorkshopHomestead $Root $GameDirectory
    Write-WorkshopEnemyBalance $Root $GameDirectory
    Write-WorkshopTextFixes $Root $GameDirectory
}

function Write-WorkshopCookingStove([string]$Root, [string]$GameDirectory) {
    [xml]$nativeBlocks=Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\blocks.xml') -Raw
    [xml]$nativeRecipes=Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\recipes.xml') -Raw
    $base=$nativeBlocks.SelectSingleNode("/blocks/block[@name='campfire']")
    $model=$nativeBlocks.SelectSingleNode("/blocks/block[@name='cntWoodBurningStove']/property[@name='Model']")
    if(-not $base -or -not $model){throw 'Native cooking stove source definitions missing.'}
    [xml]$blocks='<configs><append xpath="/blocks" /></configs>'
    $stove=$blocks.ImportNode($base,$true);$stove.SetAttribute('name','grimmerCookingStove')
    $null=$blocks.configs.append.AppendChild($stove)
    # Enclosed wood-burning stove: retain native fuel/tools/queues and warmth,
    # remove the open campfire particle and contact-burning behaviour.
    foreach($property in @('ParticleName','ParticleOffset','BuffsWhenWalkedOn')){
        $node=$stove.SelectSingleNode("property[@name='$property']");if($node){$null=$stove.RemoveChild($node)}
    }
    $properties=@{DescriptionKey='grimmerCookingStoveDesc';WorkstationWindow='workstation_campfire';CustomIcon='cntWoodBurningStove';Model=$model.GetAttribute('value');Material='Mmetal';MaxDamage='500';EconomicValue='600';UnlockedBy='craftingFood';Place='TowardsPlacerInverted';SellableToTrader='true'}
    foreach($key in $properties.Keys){
        $node=$stove.SelectSingleNode("property[@name='$key']")
        if(-not $node){$node=$blocks.CreateElement('property');$node.SetAttribute('name',$key);$null=$stove.AppendChild($node)}
        $node.SetAttribute('value',$properties[$key])
    }
    $workstation=$stove.SelectSingleNode("property[@class='Workstation']")
    $area=$blocks.CreateElement('property');$area.SetAttribute('name','CraftingAreaRecipes');$area.SetAttribute('value','grimmerCookingStove');$null=$workstation.AppendChild($area)
    $repair=$stove.SelectSingleNode("property[@class='RepairItems']");$repair.RemoveAll();$repair.SetAttribute('class','RepairItems')
    $iron=$blocks.CreateElement('property');$iron.SetAttribute('name','resourceForgedIron');$iron.SetAttribute('value','3');$null=$repair.AppendChild($iron)
    [xml]$recipes='<configs><append xpath="/recipes" /></configs>'
    foreach($source in $nativeRecipes.SelectNodes("/recipes/recipe[@craft_area='campfire']")){
        $copy=$recipes.ImportNode($source,$true);$copy.SetAttribute('craft_area','grimmerCookingStove');$null=$recipes.configs.append.AppendChild($copy)
    }
    if($recipes.SelectNodes('/configs/append/recipe').Count -lt 40){throw 'Cooking stove recipe selection unexpectedly small.'}
    [xml]$progression=@'
<configs><append xpath="/progression/crafting_skills/crafting_skill[@name='craftingFood']/effect_group"><passive_effect name="RecipeTagUnlocked" operation="base_set" level="20,100" value="1" tags="grimmerCookingStove" /></append></configs>
'@
    $text=@'
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english
grimmerCookingStove,blocks,Block,,,,Cooking Stove
grimmerCookingStoveDesc,blocks,Block,,,,"Enclosed wood-burning kitchen stove. Unlocks at Food 20 and is crafted at a workbench. Cooks campfire recipes in 25% less time using normal fuel. Add the required pot, grill or beaker; recipe ingredients and unlocks stay the same. Completed food trains Food, with early Workstations practice where applicable."
'@
    $info=@'
<xml><Name value="ZZZ_GrimmerCooking" /><DisplayName value="Workshop Cooking Stove" /><Version value="0.1.0" /><Description value="Original cooking station using vanilla stove assets. Keep installed while saves contain this station." /><Author value="Grimmer Workshop" /></xml>
'@
    $modRoot=Join-Path $Root 'Profile\Mods\ZZZ_GrimmerCooking'
    $directory=Join-Path $modRoot 'Config';Assert-WorkshopPlainPath $directory
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    foreach($pair in @(@('blocks.xml',$blocks.OuterXml),@('recipes.xml',$recipes.OuterXml),@('progression.xml',$progression.OuterXml),@('Localization.csv',$text),@('..\ModInfo.xml',$info))){
        $destination=Join-Path $directory $pair[0];Assert-WorkshopPlainPath $destination;Assert-WorkshopPlainPath ($destination+'.tmp')
        [IO.File]::WriteAllText(($destination+'.tmp'),$pair[1],(New-Object Text.UTF8Encoding($false)))
        Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    }
}

function Write-WorkshopGunsmith([string]$Root, [string]$GameDirectory) {
    [xml]$nativeBlocks=Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\blocks.xml') -Raw
    [xml]$nativeRecipes=Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\recipes.xml') -Raw
    [xml]$customRecipes=Get-Content -LiteralPath (Join-Path $Root 'Profile\Mods\GrimmerWorkshop\Config\recipes.xml') -Raw
    [xml]$practice=Get-Content -LiteralPath (Join-Path $Root 'Profile\Mods\GrimmerWorkshop\PracticeRules.xml') -Raw
    $base=$nativeBlocks.SelectSingleNode("/blocks/block[@name='workbench']")
    if(-not $base){throw 'Native workbench definition missing.'}
    [xml]$blocks='<configs><append xpath="/blocks" /></configs>'
    $bench=$blocks.ImportNode($base,$true);$bench.SetAttribute('name','grimmerGunsmithBench')
    $null=$blocks.configs.append.AppendChild($bench)
    $properties=@{DescriptionKey='grimmerGunsmithBenchDesc';WorkstationWindow='workstation_workbench';CustomIcon='workbench';CustomIconTint='9AB4CD';EconomicValue='3000';UnlockedBy='craftingWorkstations'}
    foreach($key in $properties.Keys){
        $node=$bench.SelectSingleNode("property[@name='$key']")
        if(-not $node){$node=$blocks.CreateElement('property');$node.SetAttribute('name',$key);$null=$bench.AppendChild($node)}
        $node.SetAttribute('value',$properties[$key])
    }
    $bench.SelectSingleNode("property[@class='Workstation']/property[@name='CraftingAreaRecipes']").SetAttribute('value','grimmerGunsmithBench')
    # Only clone installed vanilla weapon-family recipes and our original melee
    # grips. Preserve ingredient modifiers, learnable tags and quality costs.
    $weaponSkills=@('craftingHandguns','craftingShotguns','craftingRifles','craftingMachineGuns','craftingBows','craftingExplosives','craftingClubs','craftingSledgehammers','craftingSpears','craftingBlades','craftingKnuckles','craftingRobotics')
    $eligible=@{}
    foreach($rule in $practice.practiceRules.rule){
        if($weaponSkills -contains $rule.skill -or ($rule.skill -eq 'craftingWorkstations' -and ($rule.item -like 'mod*' -or $rule.item -eq 'grimmerLightGrip' -or $rule.item -eq 'grimmerPowerGrip'))){$eligible[$rule.item]=$true}
    }
    [xml]$recipes='<configs><append xpath="/recipes" /></configs>'
    foreach($source in @($nativeRecipes.SelectNodes('/recipes/recipe'))+@($customRecipes.SelectNodes('/configs/append/recipe'))){
        $name=$source.GetAttribute('name')
        if($source.GetAttribute('craft_area') -ne 'workbench' -or -not $eligible.ContainsKey($name) -or $name -eq 'gunBotT3JunkDrone'){continue}
        $copy=$recipes.ImportNode($source,$true);$copy.SetAttribute('craft_area','grimmerGunsmithBench')
        $null=$recipes.configs.append.AppendChild($copy)
    }
    if($recipes.SelectNodes('/configs/append/recipe').Count -lt 50){throw 'Gunsmith recipe selection unexpectedly small.'}
    [xml]$progression=@'
<configs><append xpath="/progression/crafting_skills/crafting_skill[@name='craftingWorkstations']/effect_group"><passive_effect name="RecipeTagUnlocked" operation="base_set" level="20,75" value="1" tags="grimmerGunsmithBench" /></append></configs>
'@
    $text=@'
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english
grimmerGunsmithBench,blocks,Block,,,,Gunsmith Bench
grimmerGunsmithBenchDesc,blocks,Block,,,,"Specialist weapon bench. Unlocks at Workstations 20. Craft supported weapons, ammunition and weapon attachments in 15% less time using the same materials and unlock requirements. Completed crafts train their normal skills. Uses the standard workbench model."
'@
    $info=@'
<xml><Name value="ZZZ_GrimmerGunsmith" /><DisplayName value="Workshop Gunsmith Bench" /><Version value="0.1.0" /><Description value="Original specialist station using vanilla assets. Keep installed after rollback to preserve placed stations." /><Author value="Grimmer Workshop" /></xml>
'@
    $modRoot=Join-Path $Root 'Profile\Mods\ZZZ_GrimmerGunsmith'
    $directory=Join-Path $modRoot 'Config'
    Assert-WorkshopPlainPath $directory
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    foreach($pair in @(@('blocks.xml',$blocks.OuterXml),@('recipes.xml',$recipes.OuterXml),@('progression.xml',$progression.OuterXml),@('Localization.csv',$text),@('..\ModInfo.xml',$info))){
        $destination=Join-Path $directory $pair[0]
        Assert-WorkshopPlainPath $destination;Assert-WorkshopPlainPath ($destination+'.tmp')
        [IO.File]::WriteAllText(($destination+'.tmp'),$pair[1],(New-Object Text.UTF8Encoding($false)))
        Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    }
}

function Write-WorkshopVehicleParts([string]$Root, [string]$GameDirectory) {
    [xml]$baseline=Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\items.xml') -Raw
    if(-not $baseline.SelectSingleNode("/items/item[@name='resourceMechanicalParts']")) {throw 'Vehicle parts base item changed.'}
    # Keep the saved item identity in a companion folder, including on rollback.
    $modRoot=Join-Path $Root 'Profile\Mods\ZZZ_GrimmerVehicleParts'
    $directory=Join-Path $modRoot 'Config'
    Assert-WorkshopPlainPath $directory
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $items=@'
<configs>
  <append xpath="/items">
    <item name="grimmerRecoveredEngine">
      <property name="Extends" value="resourceMechanicalParts" />
      <property name="CustomIcon" value="smallEngine" />
      <property name="CustomIconTint" value="A89C86" />
      <property name="DescriptionKey" value="grimmerRecoveredEngineDesc" />
      <property name="Stacknumber" value="1" />
      <property name="EconomicValue" value="40" />
      <property name="Group" value="Resources" />
    </item>
  </append>
</configs>
'@
    $localization=@'
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english
grimmerRecoveredEngine,items,Item,,,,Damaged Engine Assembly
blockcommand_Inspect vehicle parts,ui,UI,,,,Inspect vehicle parts
blockcommand_Vehicle parts already inspected,ui,UI,,,,Vehicle parts already inspected
grimmerRecoveredEngineDesc,items,Item,,,,"Recovered from an abandoned vehicle inspection. Cannot power a vehicle or generator yet. Rebuild into an Engine at a workbench using 10 forged iron, 12 mechanical parts, 4 oil and 2 duct tape. Rebuilding trains Vehicles."
'@
    $info=@'
<xml>
  <Name value="ZZZ_GrimmerVehicleParts" />
  <DisplayName value="Workshop Vehicle Parts" />
  <Version value="0.1.0" />
  <Description value="Original recoverable engine component. Saved item identity retained across partial rollbacks." />
  <Author value="Grimmer Workshop" />
</xml>
'@
    [xml]$validated=$items; [xml]$validated=$info
    foreach($pair in @(@((Join-Path $directory 'items.xml'),$items),@((Join-Path $directory 'Localization.csv'),$localization),@((Join-Path $modRoot 'ModInfo.xml'),$info))) {
        $destination=$pair[0]
        Assert-WorkshopPlainPath $destination; Assert-WorkshopPlainPath ($destination+'.tmp')
        [IO.File]::WriteAllText(($destination+'.tmp'),$pair[1],(New-Object Text.UTF8Encoding($false)))
        Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    }
}

function Write-WorkshopToolOptions([string]$Root, [string]$GameDirectory) {
    # A generated companion modlet keeps item identities available when older
    # releases regenerate their own melee-grip definitions after a rollback.
    $modRoot=Join-Path $Root 'Profile\Mods\ZZZ_GrimmerToolOptions'
    $directory=Join-Path $modRoot 'Config'
    Assert-WorkshopPlainPath $directory
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $modifiers=@'
<configs>
  <append xpath="/item_modifiers">
    <item_modifier name="grimmerLightToolGrip" installable_tags="perkMiner69r,perkSalvageOperations" modifier_tags="grimmerToolChoice" blocked_tags="noMods,motorTool,repairingTools" type="attachment">
      <property name="Extends" value="modGeneralMaster" />
      <property name="CustomIcon" value="modMeleeErgonomicGrip" />
      <property name="CustomIconTint" value="9DDAAD" />
      <property name="DescriptionKey" value="grimmerLightToolGripDesc" />
      <property name="DisplayType" value="grimmerLightToolGrip" />
      <property name="ShowQuality" value="false" />
      <property name="EconomicValue" value="150" />
      <effect_group tiered="false">
        <display_value name="dStaminaLoss" value="-0.09999" />
        <display_value name="dDegradationPerUse" value="0.15001" />
        <passive_effect name="StaminaLoss" operation="perc_add" value="-0.10" tags="primary,secondary" />
        <passive_effect name="DegradationPerUse" operation="perc_add" value="0.15" tags="perkMiner69r,perkSalvageOperations" />
      </effect_group>
    </item_modifier>
    <item_modifier name="grimmerReinforcedToolFrame" installable_tags="perkMiner69r,perkSalvageOperations" modifier_tags="grimmerToolChoice" blocked_tags="noMods,motorTool,repairingTools" type="attachment">
      <property name="Extends" value="modGeneralMaster" />
      <property name="CustomIcon" value="modMeleeStructuralBrace" />
      <property name="CustomIconTint" value="9FBBD8" />
      <property name="DescriptionKey" value="grimmerReinforcedToolFrameDesc" />
      <property name="DisplayType" value="grimmerReinforcedToolFrame" />
      <property name="ShowQuality" value="false" />
      <property name="EconomicValue" value="150" />
      <effect_group tiered="false">
        <display_value name="dStaminaLoss" value="0.10001" />
        <display_value name="dDegradationPerUse" value="-0.24999" />
        <passive_effect name="StaminaLoss" operation="perc_add" value="0.10" tags="primary,secondary" />
        <passive_effect name="DegradationPerUse" operation="perc_add" value="-0.25" tags="perkMiner69r,perkSalvageOperations" />
      </effect_group>
    </item_modifier>
  </append>
</configs>
'@
    $display=@'
<configs>
  <append xpath="/ui_display_info/item_display">
    <item_display_info display_type="grimmerLightToolGrip" display_group="groupRanged">
      <display_entry name="dStaminaLoss" title_key="grimmerToolAttackStamina" display_type="Percent" negative_preferred="true" display_leading_plus="true" />
      <display_entry name="dDegradationPerUse" title_key="grimmerToolWear" display_type="Percent" negative_preferred="true" display_leading_plus="true" />
    </item_display_info>
    <item_display_info display_type="grimmerReinforcedToolFrame" display_group="groupRanged">
      <display_entry name="dStaminaLoss" title_key="grimmerToolAttackStamina" display_type="Percent" negative_preferred="true" display_leading_plus="true" />
      <display_entry name="dDegradationPerUse" title_key="grimmerToolWear" display_type="Percent" negative_preferred="true" display_leading_plus="true" />
    </item_display_info>
  </append>
</configs>
'@
    $localization=@'
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english
grimmerLightToolGrip,items,Item,,,,Light Tool Grip Mod
grimmerLightToolGripDesc,items,Item,,,,"Adds -10% attack stamina cost and +15% durability loss per use. Fits non-motor axes, picks, shovels and salvage tools with a free mod slot. Choose one Workshop tool mod. Repair hammers and nailguns are excluded. Removable; other perks and mods affect final stats."
grimmerReinforcedToolFrame,items,Item,,,,Reinforced Tool Frame Mod
grimmerReinforcedToolFrameDesc,items,Item,,,,"Adds -25% durability loss per use and +10% attack stamina cost. Fits non-motor axes, picks, shovels and salvage tools with a free mod slot. Choose one Workshop tool mod. Repair hammers and nailguns are excluded. Removable; other perks and mods affect final stats."
grimmerToolAttackStamina,ui_display,Stat,,,,Attack Stamina Cost
grimmerToolWear,ui_display,Stat,,,,Durability Loss Per Use
'@
    $info=@'
<xml>
  <Name value="ZZZ_GrimmerToolOptions" />
  <DisplayName value="Workshop Tool Options" />
  <Version value="0.1.0" />
  <Description value="Original optional craftable tool attachments. Retained across partial rollbacks to preserve existing items." />
  <Author value="Grimmer Workshop" />
</xml>
'@
    [xml]$validated=$modifiers; [xml]$validated=$display; [xml]$validated=$info
    foreach($pair in @(@((Join-Path $directory 'item_modifiers.xml'),$modifiers),@((Join-Path $directory 'ui_display.xml'),$display),@((Join-Path $directory 'Localization.csv'),$localization),@((Join-Path $modRoot 'ModInfo.xml'),$info))) {
        $destination=$pair[0]
        Assert-WorkshopPlainPath $destination; Assert-WorkshopPlainPath ($destination+'.tmp')
        [IO.File]::WriteAllText(($destination+'.tmp'),$pair[1],(New-Object Text.UTF8Encoding($false)))
        Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    }
}

function Write-WorkshopConstruction([string]$Root, [string]$GameDirectory) {
    [xml]$baseline=Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\progression.xml') -Raw
    if (-not $baseline.SelectSingleNode('/progression/crafting_skills')) { throw 'Crafting skill registry changed.' }
    if ($baseline.SelectSingleNode("//crafting_skill[@name='craftingConstruction']")) { throw 'Construction skill name already exists in game data.' }
    $directory=Join-Path $Root 'Profile\Mods\GrimmerWorkshop\Config'
    Assert-WorkshopPlainPath $directory
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $progression=@'
<configs>
  <append xpath="/progression/crafting_skills">
    <crafting_skill name="craftingConstruction" min_level="1" max_level="100" parent="attCrafting" name_key="craftingConstructionName" desc_key="craftingConstructionDesc" long_desc_key="craftingConstructionLongDesc" icon="ui_game_symbol_hammer">
      <effect_group>
        <passive_effect name="CraftingTime" operation="perc_add" level="1,100" value="0,-0.15" tags="grimmerConstruction" />
      </effect_group>
    </crafting_skill>
  </append>
</configs>
'@
    [xml]$validated=$progression
    $destination=Join-Path $directory 'progression.xml'
    Assert-WorkshopPlainPath $destination; Assert-WorkshopPlainPath ($destination+'.tmp')
    [IO.File]::WriteAllText(($destination+'.tmp'),$progression,(New-Object Text.UTF8Encoding($false)))
    Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
}

function Write-WorkshopArsenalDisplayEntries([string]$Root) {
    $pack = Join-Path $Root 'Profile\Mods\DSD_Arsenal'
    $patchPath = Join-Path $Root 'Profile\Mods\GrimmerWorkshop\Config\progression.xml'
    if (-not (Test-Path -LiteralPath (Join-Path $pack 'ModInfo.xml')) -or -not (Test-Path -LiteralPath $patchPath)) { return }
    [xml]$info = Get-Content -LiteralPath (Join-Path $pack 'ModInfo.xml') -Raw
    if ($info.SelectSingleNode('/xml/Name').GetAttribute('value') -ne 'DSD_Arsenal' -or
        $info.SelectSingleNode('/xml/Version').GetAttribute('value') -ne '1.2.1') { return }
    [xml]$items = Get-Content -LiteralPath (Join-Path $pack 'Config\items.xml') -Raw
    [xml]$recipes = Get-Content -LiteralPath (Join-Path $pack 'Config\recipes.xml') -Raw
    [xml]$progression = Get-Content -LiteralPath (Join-Path $pack 'Config\progression.xml') -Raw
    [xml]$patch = Get-Content -LiteralPath $patchPath -Raw
    $skillByTag = @{
        handgunSkill='craftingHandguns'; shotgunSkill='craftingShotguns'; rifleSkill='craftingRifles'
        machinegunSkill='craftingMachineGuns'; knuckleSkill='craftingKnuckles'; bladeSkill='craftingBlades'
        clubSkill='craftingClubs'; sledgeSkill='craftingSledgehammers'; spearSkill='craftingSpears'
        roboticsSkill='craftingRobotics'
    }
    $added = 0
    foreach ($item in $items.SelectNodes('//item')) {
        $name = $item.GetAttribute('name')
        if (-not $name.StartsWith('dsdArs',[StringComparison]::Ordinal)) { continue }
        $tagProperty = $item.SelectSingleNode('property[@name="Tags"]')
        if (-not $tagProperty -or $tagProperty.GetAttribute('value').Split(',') -notcontains 'weapon') { continue }
        $tags = @($tagProperty.GetAttribute('value').Split(',') | Where-Object { $skillByTag.ContainsKey($_) } | ForEach-Object { $skillByTag[$_] } | Select-Object -Unique)
        if ($tags.Count -ne 1) { continue }
        $matches = @()
        foreach ($operation in $progression.SelectNodes('/configs/*')) {
            $xpath = $operation.GetAttribute('xpath')
            if (-not $xpath.Contains("crafting_skill[@name='$($tags[0])']/effect_group")) { continue }
            foreach ($effect in $operation.SelectNodes('.//passive_effect[@name="RecipeTagUnlocked"]')) {
                if ($effect.GetAttribute('tags').Split(',') -contains $name) {
                    $levelText = $effect.GetAttribute('level').Split(',')[0]
                    $level = 0
                    if ([int]::TryParse($levelText,[ref]$level) -and $level -gt 0) { $matches += $level }
                }
            }
        }
        if ($matches.Count -ne 1 -or @($recipes.SelectNodes("//recipe[@name='$name']")).Count -ne 1) { continue }
        $append = $patch.CreateElement('append')
        $append.SetAttribute('xpath',"/progression/crafting_skills/crafting_skill[@name='$($tags[0])']")
        $entry = $patch.CreateElement('display_entry')
        $entry.SetAttribute('item',$name)
        $entry.SetAttribute('unlock_level',[string]$matches[0])
        $null = $append.AppendChild($entry)
        $null = $patch.DocumentElement.AppendChild($append)
        $added++
    }
    $cell = @($recipes.SelectNodes('//recipe[@name="dsdArsEnergyCell"]'))
    $cellListed = $patch.SelectSingleNode("/configs/append/display_entry[@item='dsdArsEnergyCell']")
    if ($cell.Count -eq 2 -and -not $cellListed) {
        $append = $patch.CreateElement('append')
        $append.SetAttribute('xpath',"/progression/crafting_skills/crafting_skill[@name='craftingElectrician']")
        $entry = $patch.CreateElement('display_entry')
        $entry.SetAttribute('item','dsdArsEnergyCell')
        $entry.SetAttribute('unlock_level','1')
        $null = $append.AppendChild($entry)
        $null = $patch.DocumentElement.AppendChild($append)
        $added++
    }
    Assert-WorkshopPlainPath $patchPath
    Assert-WorkshopPlainPath ($patchPath+'.tmp')
    [IO.File]::WriteAllText(($patchPath+'.tmp'),$patch.OuterXml,(New-Object Text.UTF8Encoding($false)))
    Move-Item -LiteralPath ($patchPath+'.tmp') -Destination $patchPath -Force
    if ($added -gt 0) { Write-Host "Added $added DSD Arsenal item icons and unlock levels to the Crafting skill page." }
}

function Write-WorkshopSkillScreen([string]$Root, [string]$GameDirectory) {
    $directory = Join-Path $Root 'Profile\Mods\GrimmerWorkshop\Config\XUi_InGame'
    Assert-WorkshopPlainPath $directory
    [xml]$baseline = Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\XUi_InGame\windows.xml') -Raw
    if (-not $baseline.SelectSingleNode("/windows/window[@name='windowSkillCraftingInfo']/rect[@name='content']/rect[@name='tableBox']/grid")) { throw 'Crafting skill window layout changed.' }
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $windows = @'
<configs>
  <append xpath="/windows/window[@name='windowBackpack']/rect[@name='header']">
    <button name="grimmerDepositNearby" depth="5" pos="270,-22" sprite="ui_game_symbol_store_similar_down" style="icon30px, press, hover" pivot="center" sound="[paging_click]" tooltip="Deposit nearby: move unlocked backpack items into nearby closed storage containing matching items. Applies to the whole backpack, including filtered-out items." />
    <button name="grimmerRefillNearby" depth="5" pos="320,-22" sprite="ui_game_symbol_store_similar_up" style="icon30px, press, hover" pivot="center" sound="[paging_click]" tooltip="Refill locked slots: top up occupied locked backpack slots from nearby closed storage." />
  </append>
  <set xpath="/windows/window[@name='windowSkillCraftingInfo']/rect[@name='content']/rect[@name='tableBox']/@pos">0,-380</set>
  <set xpath="/windows/window[@name='windowSkillCraftingInfo']/rect[@name='content']/rect[@name='tableBox']/@height">289</set>
  <set xpath="/windows/window[@name='windowSkillCraftingInfo']/rect[@name='content']/rect[@name='tableBox']/sprite[@name='backgroundMain']/@height">290</set>
  <set xpath="/windows/window[@name='windowSkillCraftingInfo']/rect[@name='content']/rect[@name='tableBox']/grid/@rows">3</set>
  <append xpath="/windows/window[@name='windowSkillCraftingInfo']/rect[@name='content']">
    <rect name="grimmerPracticePanel" pos="0,-280" width="647" height="100" depth="4">
      <sprite name="background" sprite="menu_empty" color="35,39,43,245" type="sliced" depth="1" />
      <label name="grimmerPractice" pos="12,-5" width="620" height="25" font_size="20" text="{gw_practice}" depth="3" />
      <sprite name="grimmerPracticeTrack" sprite="menu_empty" pos="12,-32" width="620" height="6" color="70,75,80,255" type="sliced" depth="2" />
      <sprite name="grimmerPracticeFill" sprite="menu_empty" pos="12,-32" width="620" height="6" color="90,195,155,255" type="filled" fillspritepad="true" fill="{gw_fill}" depth="3" />
      <label name="grimmerTraining" pos="12,-41" width="620" height="32" font_size="16" text="{gw_training}" tooltip="{gw_training}" depth="3" />
      <label name="grimmerNext" pos="12,-77" width="620" height="21" font_size="16" text="{gw_next}" tooltip="{gw_next_full}" depth="3" />
    </rect>
  </append>
</configs>
'@
    $templates = @'
<configs>
  <set xpath="/templates/recipe_entry/rect/label[@name='Name']/@width">238</set>
  <set xpath="/templates/recipe_entry/rect/label[@name='Name']/@pos">184,-22</set>
  <append xpath="/templates/recipe_entry/rect">
    <sprite name="grimmerRecipeTraining0" style="hover" sprite="{gw_recipe_icon_0}" pos="308,-13" width="18" height="18" depth="8" color="90,195,155,255" visible="{gw_recipe_show_0}" tooltip="{gw_recipe_training}" foregroundlayer="true" />
    <sprite name="grimmerRecipeTraining1" style="hover" sprite="{gw_recipe_icon_1}" pos="330,-13" width="18" height="18" depth="8" color="90,195,155,255" visible="{gw_recipe_show_1}" tooltip="{gw_recipe_training}" foregroundlayer="true" />
  </append>
  <append xpath="/templates/skill_entry/rect">
    <sprite name="grimmerSkillTrack" pos="4,-41" width="636" height="3" depth="4" sprite="menu_empty" color="70,75,80,255" type="sliced" visible="{skillpercentshouldshow}" />
    <sprite name="grimmerSkillFill" pos="4,-41" width="636" height="3" depth="5" sprite="menu_empty" color="90,195,155,255" type="filled" fill="{skillpercentthislevel}" visible="{skillpercentshouldshow}" />
  </append>
</configs>
'@
    foreach ($pair in @(@('windows.xml',$windows),@('templates.xml',$templates))) {
        $destination=Join-Path $directory $pair[0]
        Assert-WorkshopPlainPath $destination
        Assert-WorkshopPlainPath ($destination+'.tmp')
        Set-Content -LiteralPath ($destination+'.tmp') -Value $pair[1] -Encoding UTF8
        Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    }
}

function Get-WorkshopBookCatalog([string]$GameDirectory) {
    [xml]$items = Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\items.xml') -Raw
    [xml]$progression = Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\progression.xml') -Raw
    $skills = @($progression.SelectNodes('//crafting_skill') | ForEach-Object { $_.GetAttribute('name') })
    foreach ($item in $items.SelectNodes('/items/item[property[@name="Unlocks"]]')) {
        $name = $item.GetAttribute('name')
        if ($name -match '(?i)(admin|master|^invisible)') { continue }
        $unlocks = $item.SelectSingleNode('property[@name="Unlocks"]').GetAttribute('value')
        $category = if ($name.EndsWith('SkillMagazine') -and $skills -contains $unlocks) { 'craftingMagazines' }
                    elseif ($name.StartsWith('book') -and $unlocks.StartsWith('perk')) { 'perkBooks' }
                    elseif ($name.EndsWith('Schematic')) { 'schematics' } else { continue }
        $label = [regex]::Replace($name,'([a-z])([A-Z])','$1 $2')
        $label = [regex]::Replace($label,'([A-Za-z])([0-9])','$1 $2')
        [pscustomobject]@{Id=$name; Category=$category; Label=$label}
    }
}

function Get-WorkshopDisabledBooks([xml]$Settings, $Catalog) {
    $books = $Settings.SelectSingleNode('/workshop/books')
    foreach ($entry in $Catalog) {
        $enabled = $entry.Category -ne 'craftingMagazines'
        if ($books) {
            $value = $books.GetAttribute($entry.Category)
            if ($value -in @('true','false')) { $enabled = $value -eq 'true' }
            if ($books.SelectSingleNode("allow[@item='$($entry.Id)']")) { $enabled = $true }
            if ($books.SelectSingleNode("deny[@item='$($entry.Id)']")) { $enabled = $false }
        }
        if (-not $enabled) { $entry.Id }
    }
}

function Write-WorkshopBookPolicy([string]$Root, [string]$GameDirectory) {
    $mod = Join-Path $Root 'Profile\Mods\GrimmerWorkshop'
    Assert-WorkshopPlainPath $mod
    [xml]$settings = Get-Content -LiteralPath (Join-Path $mod 'WorkshopSettings.xml') -Raw
    $disabled = @(Get-WorkshopDisabledBooks $settings @(Get-WorkshopBookCatalog $GameDirectory))
    $magazines = @(Get-WorkshopBookCatalog $GameDirectory | Where-Object Category -eq 'craftingMagazines')
    $allMagazinesOff = @($magazines | Where-Object { $disabled -notcontains $_.Id }).Count -eq 0
    foreach ($file in @('loot.xml','traders.xml','quests.xml')) {
        [xml]$baseline = Get-Content -LiteralPath (Join-Path $GameDirectory ('Data\Config\' + $file)) -Raw
        $patch = New-Object Xml.XmlDocument
        $null = $patch.AppendChild($patch.CreateElement('configs'))
        foreach ($name in $disabled) {
            if ($name -notmatch '^[A-Za-z0-9_]+$') { throw 'Invalid book identifier.' }
            if ($file -eq 'quests.xml') {
                $rewardPath = "/quests//reward[@type='Item' and @id='$name']"
                if ($baseline.SelectNodes($rewardPath).Count) {
                    foreach ($attribute in @(@('value','3'),@('id','resourceRepairKit'))) {
                        $operation=$patch.CreateElement('set'); $operation.SetAttribute('xpath',$rewardPath + '/@' + $attribute[0]); $operation.InnerText=$attribute[1]
                        $null=$patch.DocumentElement.AppendChild($operation)
                    }
                }
                continue
            }
            $xpath = '/' + $baseline.DocumentElement.Name + "//item[@name='$name']/@name"
            if (-not $baseline.SelectNodes($xpath).Count) { continue }
            $operation = $patch.CreateElement('set'); $operation.SetAttribute('xpath',$xpath)
            # Paper preserves the existing loot-roll count and probability rather
            # than leaving empty loot groups or increasing other reward chances.
            $operation.InnerText = 'resourcePaper'; $null = $patch.DocumentElement.AppendChild($operation)
        }
        if ($file -eq 'loot.xml' -and $allMagazinesOff) {
            # Quest reward pools are deliberately useful rather than paper.
            # Replace the bundle reference, retaining the surrounding quest's
            # choice count, probability, XP and currency rewards.
            foreach ($group in @('groupQuestT1SkillMagazineBundle','groupChallengeRewardSkillMagazinesAll01')) {
                $groupPath="/lootcontainers/lootgroup[@name='$group']"
                if (-not $baseline.SelectSingleNode($groupPath)) { throw "Missing quest magazine reward pool: $group" }
                $operation=$patch.CreateElement('remove'); $operation.SetAttribute('xpath',$groupPath+'/item'); $null=$patch.DocumentElement.AppendChild($operation)
                $operation=$patch.CreateElement('append'); $operation.SetAttribute('xpath',$groupPath)
                $item=$patch.CreateElement('item'); $item.SetAttribute('name','resourceRepairKit'); $item.SetAttribute('count','3')
                $null=$operation.AppendChild($item); $null=$patch.DocumentElement.AppendChild($operation)
            }
        }
        $destination = Join-Path $mod ('Config\' + $file)
        Assert-WorkshopPlainPath $destination
        New-Item -ItemType Directory -Path (Split-Path $destination) -Force | Out-Null
        $temporary = $destination + '.tmp'
        Assert-WorkshopPlainPath $temporary
        $patch.Save($temporary)
        Move-Item -LiteralPath $temporary -Destination $destination -Force
    }
    return $disabled.Count
}

function Show-WorkshopGameplaySettings([string]$Root, [string]$GameDirectory) {
    Assert-WorkshopClosed
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $settingsPath = Join-Path $Root 'Profile\Mods\GrimmerWorkshop\WorkshopSettings.xml'
    Assert-WorkshopPlainPath $settingsPath
    [xml]$settings = Get-Content -LiteralPath $settingsPath -Raw
    $catalog = @(Get-WorkshopBookCatalog $GameDirectory)
    $disabled = @(Get-WorkshopDisabledBooks $settings $catalog)
    $dialog = New-Object Windows.Forms.Form
    $dialog.Text = 'Workshop gameplay settings'; $dialog.Size = New-Object Drawing.Size(720,740)
    $dialog.StartPosition = 'CenterScreen'; $dialog.Font = New-Object Drawing.Font('Segoe UI',10)
    $help = New-Object Windows.Forms.Label
    $help.Text = 'Checked books can appear in new loot and trader restocks. Unchecked rolls become paper. Existing items stay. Crafting magazines never raise crafting skills.'
    $help.SetBounds(20,15,660,60); $dialog.Controls.Add($help)
    $tabs = New-Object Windows.Forms.TabControl; $tabs.SetBounds(20,80,660,350); $dialog.Controls.Add($tabs)
    $lists = @{}
    foreach ($category in @('craftingMagazines','perkBooks','schematics')) {
        $page = New-Object Windows.Forms.TabPage
        $page.Text = switch ($category) { 'craftingMagazines' {'Crafting magazines'} 'perkBooks' {'Perk books'} 'schematics' {'Schematics'} }
        $page.Tag = $category
        $list = New-Object Windows.Forms.CheckedListBox
        $list.Dock = 'Fill'; $list.CheckOnClick = $true; $list.DisplayMember = 'Label'
        foreach ($entry in ($catalog | Where-Object {$_.Category -eq $category} | Sort-Object Label)) {
            $index = $list.Items.Add($entry); $list.SetItemChecked($index, $disabled -notcontains $entry.Id)
        }
        $page.Controls.Add($list); $tabs.TabPages.Add($page); $lists[$category] = $list
    }
    $all = New-Object Windows.Forms.Button; $all.Text = 'Enable this tab'; $all.SetBounds(20,440,145,32); $dialog.Controls.Add($all)
    $none = New-Object Windows.Forms.Button; $none.Text = 'Disable this tab'; $none.SetBounds(180,440,145,32); $dialog.Controls.Add($none)
    $all.Add_Click({ $list = $lists[[string]$tabs.SelectedTab.Tag]; for($i=0;$i -lt $list.Items.Count;$i++) { $list.SetItemChecked($i,$true) } })
    $none.Add_Click({ $list = $lists[[string]$tabs.SelectedTab.Tag]; for($i=0;$i -lt $list.Items.Count;$i++) { $list.SetItemChecked($i,$false) } })
    $activityLabel = New-Object Windows.Forms.Label; $activityLabel.Text = 'Activity learning speed (0 = off)'; $activityLabel.SetBounds(20,489,280,25); $dialog.Controls.Add($activityLabel)
    $activity = New-Object Windows.Forms.NumericUpDown
    $activity.Minimum = 0; $activity.Maximum = 10; $activity.DecimalPlaces = 1; $activity.Increment = 0.1; $activity.SetBounds(310,485,90,28)
    $activity.Value = 1
    if ($settings.DocumentElement.HasAttribute('activityLearningSpeed')) { $activity.Value = [decimal]::Parse($settings.DocumentElement.GetAttribute('activityLearningSpeed'),[Globalization.CultureInfo]::InvariantCulture) }
    $dialog.Controls.Add($activity)
    $notices = New-Object Windows.Forms.CheckBox
    $notices.Text = 'Show brief practice notifications'; $notices.SetBounds(20,525,400,28)
    $notices.Checked = $settings.DocumentElement.GetAttribute('practiceNotifications') -ne 'false'; $dialog.Controls.Add($notices)
    $learnByDoing = New-Object Windows.Forms.CheckBox
    $learnByDoing.Text = 'Enable Learn by Doing: actions raise real ranks; unspent points are saved while enabled'
    $learnByDoing.SetBounds(20,558,650,28)
    $learnByDoing.Checked = $true
    if ($settings.DocumentElement.HasAttribute('learnByDoing')) { $learnByDoing.Checked = $settings.DocumentElement.GetAttribute('learnByDoing') -eq 'true' }
    $dialog.Controls.Add($learnByDoing)
    $actionPreview = New-Object Windows.Forms.CheckBox
    $actionPreview.Text = 'Tracking-only action-skill preview (used when Learn by Doing is off)'
    $actionPreview.SetBounds(20,590,650,28)
    $actionPreview.Checked = $settings.DocumentElement.GetAttribute('actionSkillPreview') -eq 'true'
    $dialog.Controls.Add($actionPreview)
    $actionPreview.Enabled = -not $learnByDoing.Checked
    $learnByDoing.Add_CheckedChanged({ $actionPreview.Enabled = -not $learnByDoing.Checked })
    $previewSpeedLabel = New-Object Windows.Forms.Label
    $previewSpeedLabel.Text = 'Learn by Doing / preview speed'; $previewSpeedLabel.SetBounds(20,624,270,25); $dialog.Controls.Add($previewSpeedLabel)
    $previewSpeed = New-Object Windows.Forms.NumericUpDown
    $previewSpeed.Minimum = 0.1; $previewSpeed.Maximum = 10; $previewSpeed.DecimalPlaces = 1; $previewSpeed.Increment = 0.1; $previewSpeed.Value = 1
    if ($settings.DocumentElement.HasAttribute('learnByDoingSpeed')) { $previewSpeed.Value = [decimal]::Parse($settings.DocumentElement.GetAttribute('learnByDoingSpeed'),[Globalization.CultureInfo]::InvariantCulture) }
    elseif ($settings.DocumentElement.HasAttribute('actionPreviewSpeed')) { $previewSpeed.Value = [decimal]::Parse($settings.DocumentElement.GetAttribute('actionPreviewSpeed'),[Globalization.CultureInfo]::InvariantCulture) }
    $previewSpeed.SetBounds(310,620,90,28); $dialog.Controls.Add($previewSpeed)
    $save = New-Object Windows.Forms.Button; $save.Text = 'Save'; $save.SetBounds(450,660,105,34); $dialog.Controls.Add($save)
    $cancel = New-Object Windows.Forms.Button; $cancel.Text = 'Cancel'; $cancel.SetBounds(575,660,105,34); $cancel.DialogResult = 'Cancel'; $dialog.Controls.Add($cancel)
    $save.Add_Click({
        try {
            Assert-WorkshopClosed
            $old = $settings.SelectSingleNode('/workshop/books')
            if ($old) { $null = $settings.DocumentElement.RemoveChild($old) }
            $books = $settings.CreateElement('books')
            foreach ($category in @('craftingMagazines','perkBooks','schematics')) {
                $books.SetAttribute($category,'true'); $list = $lists[$category]
                for($i=0;$i -lt $list.Items.Count;$i++) {
                    if (-not $list.GetItemChecked($i)) { $deny = $settings.CreateElement('deny'); $deny.SetAttribute('item',$list.Items[$i].Id); $null = $books.AppendChild($deny) }
                }
            }
            $null = $settings.DocumentElement.AppendChild($books)
            $settings.DocumentElement.SetAttribute('activityLearningSpeed',$activity.Value.ToString([Globalization.CultureInfo]::InvariantCulture))
            $settings.DocumentElement.SetAttribute('practiceNotifications',$notices.Checked.ToString().ToLowerInvariant())
            $settings.DocumentElement.SetAttribute('learnByDoing',$learnByDoing.Checked.ToString().ToLowerInvariant())
            $settings.DocumentElement.SetAttribute('learnByDoingSpeed',$previewSpeed.Value.ToString([Globalization.CultureInfo]::InvariantCulture))
            $settings.DocumentElement.SetAttribute('actionSkillPreview',$actionPreview.Checked.ToString().ToLowerInvariant())
            $settings.DocumentElement.SetAttribute('actionPreviewSpeed',$previewSpeed.Value.ToString([Globalization.CultureInfo]::InvariantCulture))
            $temporary = $settingsPath + '.tmp'; Assert-WorkshopPlainPath $temporary; $settings.Save($temporary)
            Move-Item -LiteralPath $temporary -Destination $settingsPath -Force
            $null = Write-WorkshopBookPolicy $Root $GameDirectory
            $dialog.DialogResult = 'OK'; $dialog.Close()
        } catch { [Windows.Forms.MessageBox]::Show($_.Exception.Message,'Workshop settings') | Out-Null }
    })
    [void]$dialog.ShowDialog(); $dialog.Dispose()
}

function Get-WorkshopHash([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Test-WorkshopGameDirectory([string]$GameDirectory, [string]$ExpectedHash) {
    if ([string]::IsNullOrWhiteSpace($GameDirectory)) { return $false }
    $assembly = Join-Path $GameDirectory '7DaysToDie_Data\Managed\Assembly-CSharp.dll'
    if (-not (Test-Path -LiteralPath $assembly -PathType Leaf)) { return $false }
    if (-not [string]::IsNullOrWhiteSpace($ExpectedHash)) {
        try { if ((Get-WorkshopHash $assembly) -ne $ExpectedHash) { return $false } }
        catch { return $false }
    }
    return $true
}

function Find-WorkshopGameDirectory([string]$PreferredDirectory, [string]$ExpectedHash) {
    $candidates = New-Object 'System.Collections.Generic.List[string]'
    if (-not [string]::IsNullOrWhiteSpace($PreferredDirectory)) { $candidates.Add($PreferredDirectory) }

    $steamRoots = New-Object 'System.Collections.Generic.List[string]'
    foreach ($key in @('HKCU:\Software\Valve\Steam','HKLM:\SOFTWARE\WOW6432Node\Valve\Steam','HKLM:\SOFTWARE\Valve\Steam')) {
        try {
            $steamPath = (Get-ItemProperty -LiteralPath $key -Name SteamPath -ErrorAction Stop).SteamPath
            if ($steamPath) { $steamRoots.Add(($steamPath -replace '/','\')) }
        } catch { }
    }
    foreach ($steamRoot in @((Join-Path $env:ProgramFiles 'Steam'),(Join-Path ${env:ProgramFiles(x86)} 'Steam'))) {
        if ($steamRoot) { $steamRoots.Add($steamRoot) }
    }
    foreach ($steamRoot in $steamRoots) {
        $candidates.Add((Join-Path $steamRoot 'steamapps\common\7 Days To Die'))
        $libraries = Join-Path $steamRoot 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $libraries -PathType Leaf) {
            try {
                $text = Get-Content -LiteralPath $libraries -Raw
                foreach ($match in [regex]::Matches($text,'(?m)"path"\s+"((?:\\\\.|[^"])*)"')) {
                    $libraryRoot = $match.Groups[1].Value -replace '\\\\','\'
                    if ($libraryRoot) { $candidates.Add((Join-Path $libraryRoot 'steamapps\common\7 Days To Die')) }
                }
            } catch { }
        }
    }

    $seen = @{}
    foreach ($candidate in $candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) { continue }
        try { $full = [IO.Path]::GetFullPath($candidate) } catch { continue }
        $key = $full.ToLowerInvariant()
        if ($seen.ContainsKey($key)) { continue }
        $seen[$key] = $true
        if (Test-WorkshopGameDirectory $full $ExpectedHash) { return $full }
    }
    return $null
}


function Assert-WorkshopPlainPath([string]$Path) {
    $cursor = [IO.Path]::GetFullPath($Path)
    while ($cursor) {
        if ((Test-Path -LiteralPath $cursor) -and ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "Linked update path is not allowed: $cursor" }
        $cursor = [IO.Path]::GetDirectoryName($cursor)
    }
}

function Resolve-WorkshopFile([string]$Root, [string]$Relative) {
    $allowed = @('Launch-Workshop.cmd','Launch-Workshop.ps1','Launcher.ps1','Update-Core.ps1','Update-Workshop.cmd','Rollback-Workshop.cmd','Open-Display-Settings.cmd','README.md','Installed-Release.json','UpdaterSettings.json')
    $modAllowed = $Relative -match '^Profile/Mods/(GrimmerWorkshop|ZZZ_GrimmerHUD)/(ModInfo\.xml|GrimmerWorkshop\.dll|PracticeRules\.xml|CRAFTING-ROUTES\.csv|WorkshopSettings\.xml|Settings\.json|Configure\.ps1|Config/(items\.xml|recipes\.xml|progression\.xml|Localization\.txt|XUi_InGame/(windows|templates)\.xml))$'
    if (($allowed -notcontains $Relative) -and -not $modAllowed) { throw "Update path is not permitted: $Relative" }
    $rootPath = [IO.Path]::GetFullPath($Root).TrimEnd('\')
    $target = [IO.Path]::GetFullPath((Join-Path $rootPath $Relative.Replace('/','\')))
    if (-not $target.StartsWith($rootPath + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Update path escapes the installation.' }
    Assert-WorkshopPlainPath $target
    return $target
}

function Assert-WorkshopClosed {
    if (Get-Process -Name '7DaysToDie','7DaysToDieServer' -ErrorAction SilentlyContinue) { throw 'Save and quit 7 Days to Die before changing the installation.' }
}

function Assert-WorkshopGame([string]$GameDirectory, [string]$ExpectedHash) {
    $assembly = Join-Path $GameDirectory '7DaysToDie_Data\Managed\Assembly-CSharp.dll'
    if (-not (Test-Path -LiteralPath $assembly)) { throw 'Select your 7 Days to Die Steam installation.' }
    if ((Get-WorkshopHash $assembly) -ne $ExpectedHash) { throw 'This Workshop release requires 7 Days to Die V3.4 b10. Your game files differ; no update was installed.' }
}

function Get-WorkshopChannel([string]$Root) {
    $path = Join-Path $Root 'UpdaterSettings.json'
    if (Test-Path -LiteralPath $path) {
        $channel = (Get-Content -LiteralPath $path -Raw | ConvertFrom-Json).channel
        if ($channel -in @('stable','testing')) { return $channel }
    }
    return 'stable'
}

function Get-WorkshopManifest([string]$Channel) {
    if ($Channel -notin @('stable','testing')) { throw 'Choose stable or testing.' }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $url = "https://raw.githubusercontent.com/andrewrobb247/grimmer-workshop/main/channels/$Channel.json"
    return Invoke-RestMethod -Uri $url -TimeoutSec 20 -Headers @{'User-Agent'='Grimmer-Workshop-Updater'}
}

function Get-WorkshopPlan([string]$Root, $Manifest) {
    if ($Manifest.schema -ne 1 -or $Manifest.version -notmatch '^\d+\.\d+\.\d+$' -or $Manifest.gameAssemblySha256 -notmatch '^[a-f0-9]{64}$') { throw 'Invalid release manifest.' }
    if (@($Manifest.files).Count -lt 1 -or @($Manifest.files).Count -gt 100) { throw 'Invalid release file count.' }
    $seen = @{}; $total = 0L
    foreach ($entry in $Manifest.files) {
        $target = Resolve-WorkshopFile $Root $entry.path
        if ($seen.ContainsKey($entry.path)) { throw 'Duplicate release path.' }; $seen[$entry.path] = $true
        if ($entry.mode -notin @('managed','default') -or $entry.sha256 -notmatch '^[a-f0-9]{64}$' -or $entry.size -lt 1 -or $entry.size -gt 20971520) { throw 'Invalid release file metadata.' }
        if ($entry.path -match '(WorkshopSettings\.xml|Settings\.json|Config/XUi_InGame/windows\.xml)$' -and $entry.mode -ne 'default') { throw 'Personal settings must be preserved.' }
        $total += $entry.size
        if ($total -gt 104857600) { throw 'Release is too large.' }
        $prefix = "https://raw.githubusercontent.com/andrewrobb247/grimmer-workshop/main/versions/$($Manifest.version)/"
        if (-not $entry.url.StartsWith($prefix,[StringComparison]::Ordinal) -or $entry.url.Substring($prefix.Length) -ne $entry.path) { throw 'Unexpected release download address.' }
        if ($entry.mode -eq 'default' -and (Test-Path -LiteralPath $target)) { continue }
        if ((Test-Path -LiteralPath $target) -and (Get-WorkshopHash $target) -eq $entry.sha256) { continue }
        $entry
    }
}

function Invoke-WorkshopLocked([scriptblock]$Action) {
    $mutex = New-Object Threading.Mutex($false,'Local\GrimmerWorkshopUpdater')
    $locked = $false
    try {
        try { $locked = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $locked = $true }
        if (-not $locked) { throw 'Another Workshop update or rollback is already running.' }
        & $Action
    } finally { if ($locked) { $mutex.ReleaseMutex() }; $mutex.Dispose() }
}

function Install-WorkshopRelease([string]$Root, $Manifest, [string]$GameDirectory, [scriptblock]$Fetch) {
    Invoke-WorkshopLocked { Install-WorkshopReleaseFiles $Root $Manifest $GameDirectory $Fetch }
}

function Install-WorkshopReleaseFiles([string]$Root, $Manifest, [string]$GameDirectory, [scriptblock]$Fetch) {
    Assert-WorkshopClosed
    Assert-WorkshopGame $GameDirectory $Manifest.gameAssemblySha256
    $plan = @(Get-WorkshopPlan $Root $Manifest)
    if (-not $plan.Count) { return 'Already up to date.' }
    $updateRoot = Join-Path $Root 'Profile\Updates'
    Assert-WorkshopPlainPath $updateRoot
    New-Item -ItemType Directory -Path $updateRoot -Force | Out-Null
    if ((Get-Item -LiteralPath $updateRoot).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked update storage is not allowed.' }
    $stage = Join-Path $updateRoot ('staging-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $stage | Out-Null
    try {
        foreach ($entry in $plan) {
            $destination = Resolve-WorkshopFile $stage $entry.path
            New-Item -ItemType Directory -Path (Split-Path $destination) -Force | Out-Null
            if ($Fetch) { & $Fetch $entry.url $destination } else {
                Invoke-WebRequest -UseBasicParsing -Uri $entry.url -OutFile $destination -TimeoutSec 60 -Headers @{'User-Agent'='Grimmer-Workshop-Updater'}
            }
            if ((Get-Item -LiteralPath $destination).Length -ne $entry.size -or (Get-WorkshopHash $destination) -ne $entry.sha256) { throw "Download verification failed: $($entry.path)" }
        }
        Assert-WorkshopClosed
        $backup = Join-Path $updateRoot ('backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $backup | Out-Null
        $records = @()
        $backupPaths = @($plan | Where-Object {$_.mode -eq 'managed'} | ForEach-Object {$_.path})
        $backupPaths += 'Installed-Release.json'
        foreach ($relative in ($backupPaths | Select-Object -Unique)) {
            $target = Resolve-WorkshopFile $Root $relative
            $existed = Test-Path -LiteralPath $target
            if ($existed) {
                $copy = Resolve-WorkshopFile $backup $relative
                New-Item -ItemType Directory -Path (Split-Path $copy) -Force | Out-Null
                Copy-Item -LiteralPath $target -Destination $copy
            }
            $records += [pscustomobject]@{path=$relative; existed=[bool]$existed}
        }
        $records | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $backup 'backup.json') -Encoding UTF8
        Set-Content -LiteralPath (Join-Path $updateRoot 'latest-backup.txt') -Value $backup -Encoding UTF8
        try {
            foreach ($entry in $plan) {
                $target = Resolve-WorkshopFile $Root $entry.path
                New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
                Copy-Item -LiteralPath (Resolve-WorkshopFile $stage $entry.path) -Destination $target -Force
            }
            $Manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $Root 'Installed-Release.json') -Encoding UTF8
        } catch {
            Restore-WorkshopFiles $Root $backup $records
            throw
        }
        return "Installed Workshop $($Manifest.version). Your world and settings are kept."
    } finally {
        $resolvedStage = [IO.Path]::GetFullPath($stage)
        if ($resolvedStage.StartsWith([IO.Path]::GetFullPath($updateRoot) + '\',[StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedStage)) { Remove-Item -LiteralPath $resolvedStage -Recurse -Force }
    }
}

function Restore-WorkshopFiles([string]$Root, [string]$Backup, $Records) {
    foreach ($record in $Records) {
        $target = Resolve-WorkshopFile $Root $record.path
        if ($record.existed) {
            Copy-Item -LiteralPath (Resolve-WorkshopFile $Backup $record.path) -Destination $target -Force
        } elseif (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Force }
    }
}

function Undo-WorkshopRelease([string]$Root) {
    Invoke-WorkshopLocked { Undo-WorkshopReleaseFiles $Root }
}

function Undo-WorkshopReleaseFiles([string]$Root) {
    Assert-WorkshopClosed
    $updateRoot = Join-Path $Root 'Profile\Updates'
    Assert-WorkshopPlainPath $updateRoot
    $backup = (Get-Content -LiteralPath (Join-Path $updateRoot 'latest-backup.txt') -Raw).Trim()
    if (-not [IO.Path]::GetFullPath($backup).StartsWith([IO.Path]::GetFullPath($updateRoot) + '\',[StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid backup location.' }
    $records = ConvertFrom-Json -InputObject (Get-Content -LiteralPath (Join-Path $backup 'backup.json') -Raw)
    # Preflight all backup paths before touching the installation.
    foreach ($record in $records) {
        $null = Resolve-WorkshopFile $Root $record.path
        if ($record.existed -and -not (Test-Path -LiteralPath (Resolve-WorkshopFile $backup $record.path))) { throw 'Backup file missing.' }
    }
    Restore-WorkshopFiles $Root $backup $records
    Remove-Item -LiteralPath (Join-Path $updateRoot 'latest-backup.txt')
    return 'Restored the previous Workshop files. Saves and personal settings are kept.'
}



# BEGIN GENERATED HOMESTEAD
function Write-WorkshopHomestead([string]$Root, [string]$GameDirectory) {
    $directory=Join-Path $Root 'Profile\Mods\ZZZ_GrimmerHomestead'
    Assert-WorkshopPlainPath $directory
    $payloads=@{}
    $payloads['Config/blocks.xml']=@'
<configs><append xpath="/blocks"><block name="grimmerCompostBin">
	
	<property name="Class" value="Workstation" />
	<property class="Workstation">
		<property name="Modules" value="output" />
		<property name="CraftingAreaRecipes" value="grimmerCompostBin" />
	</property>
	<property name="CreativeMode" value="Player" />
	<property name="DescriptionKey" value="grimmerCompostBinDesc" />
	<property name="DisplayType" value="blockMulti" />
	<property name="WorkstationIcon" value="ui_game_symbol_workbench" />
	<property name="Stacknumber" value="1" />
	
	<property name="Material" value="MwoodReinforced" />
	<property name="Shape" value="ModelEntity" />
	<property name="Model" value="@:Entities/LootContainers/woodWritableCratePrefab.prefab" />
	<property name="ImposterDontBlock" value="true" />
	<property name="WaterFlow" value="permitted" />
	
	<property name="Place" value="TowardsPlacerInverted" />
	<property name="OnlySimpleRotations" value="true" />
	<property name="IsTerrainDecoration" value="true" />
	<property name="StabilitySupport" value="false" />
	
	<property name="Weight" value="0" />
	<property name="EconomicValue" value="30" />
	<property name="MaxDamage" value="500" />
	<property name="OpenSound" value="open_workbench" />
	<property name="CloseSound" value="close_workbench" />
	<property name="TakeDelay" value="15" />
	<property name="SortOrder1" value="B281" />
	<property name="SortOrder2" value="0300" />
	<property name="Group" value="Food/Cooking,Building" />
	<property name="Tags" value="workstationSkill,twitch_workstation" />
	<property name="FilterTags" value="MC_outdoor,SC_crops" />
	<property name="SoundPickup" value="workbench_grab" />
	<property name="SoundPlace" value="workbench_place" />
<property name="ModelOffset" value="0,0,0" /><property name="CustomIcon" value="cntWoodWritableCrate" /><property name="CustomIconTint" value="88A66B" /><property name="WorkstationWindow" value="workstation_workbench" /><property name="HeatMapStrength" value="0" /><property name="SellableToTrader" value="false" /><property class="RepairItems"><property name="resourceWood" value="10" /></property><drop event="Destroy" count="0" /></block>

<block name="grimmerRestoredForge">
	
	<property name="Class" value="Forge" />
	<property class="Workstation">
		<property name="CraftingAreaRecipes" value="forge" />
		<property name="Modules" value="tools,output,fuel,material_input" />
		<property name="InputMaterials" value="iron,brass,lead,glass,stone,clay" />
		<property name="ToolNames" value="1,2,3" />
	</property>
	<property name="UnlockedBy" value="craftingWorkstations" />
	
	<property name="CreativeMode" value="Player" />
	<property name="DescriptionKey" value="grimmerRestoredForgeDesc" />
	<property name="WorkstationIcon" value="ui_game_symbol_forge" />
	<property name="Stacknumber" value="1" />
	
	<property name="Material" value="Mstone_scrap" />
	<property name="Shape" value="ModelEntity" />
	<property name="Model" value="@:Entities/Crafting/forgeWorkstationPrefab.prefab" />
	<property name="MultiBlockDim" value="2,2,1" />
	<property name="ImposterDontBlock" value="true" />
	<property name="WaterFlow" value="permitted" />
	<property name="ParticleName" value="forgeWorkstation" />
	<property name="ParticleOffset" value="0,0.4,0.5" />
	
	<property name="Place" value="TowardsPlacerInverted" />
	<property name="OnlySimpleRotations" value="true" />
	<property name="Path" value="solid" />
	<property name="IsTerrainDecoration" value="true" />
	<property name="StabilitySupport" value="true" />
	
	<property name="Weight" value="0" />
	<property name="EconomicValue" value="1000" />
	<property name="TraderStageTemplate" value="midTier0" />
	
	<property name="MaxDamage" value="800" />
	<property name="HeatMapStrength" value="6" />
	<property name="HeatMapTime" value="5000" />
	<property name="HeatMapFrequency" value="1000" />
	<property name="BuffsWhenWalkedOn" value="buffBurningEnvironment" />
	<property name="ActiveRadiusEffects" value="buffCampfireAOE,5" />
	<property name="OpenSound" value="forge_open" />
	<property name="CloseSound" value="forge_close" />
	<property name="CraftSound" value="forge_smelt_click" />
	<property name="CraftCompleteSound" value="forge_item_complete" />
	<property name="TakeDelay" value="15" />
	<property class="RepairItems">
		<property name="resourceCobblestones" value="50" />
	</property>
	<drop event="Harvest" name="resourceRockSmall" count="40" tag="allHarvest,perkJunkMiner" />
	<drop event="Harvest" name="resourceClayLump" count="20" tag="allHarvest,perkJunkMiner" />
	<drop event="Harvest" name="resourceLeather" count="5" tag="allHarvest,perkJunkMiner" />
	<drop event="Destroy" count="0" />
	<drop event="Fall" name="terrDestroyedStone" count="1" prob="0.75" stick_chance="1" />
	
	<property name="SortOrder1" value="B281" />
	<property name="SortOrder2" value="0200" />
	<property name="Group" value="Building,TCScience,advBuilding" />
	<property name="Tags" value="workstationSkill,twitch_workstation" />
	<property name="FilterTags" value="MC_playerBlocks,SC_decor" />
	<property name="SoundPickup" value="forge_grab" />
	<property name="SoundPlace" value="forge_place" />
<property name="CustomIcon" value="forge" /><property name="WorkstationWindow" value="workstation_forge" /><property name="SellableToTrader" value="false" /></block>

<block name="grimmerRestoredWorkbench">
	
	<property name="Class" value="Workstation" />
	<property class="Workstation">
		<property name="Modules" value="output" />
		<property name="CraftingAreaRecipes" value="player,workbench" />
	</property>
	<property name="UnlockedBy" value="craftingWorkstations" />
	
	<property name="CreativeMode" value="Player" />
	<property name="DescriptionKey" value="grimmerRestoredWorkbenchDesc" />
	<property name="DisplayType" value="blockMulti" />
	<property name="WorkstationIcon" value="ui_game_symbol_workbench" />
	<property name="Stacknumber" value="1" />
	
	<property name="Material" value="Mmetal" />
	<property name="Shape" value="ModelEntity" />
	<property name="Model" value="@:Entities/Crafting/woodWorkBenchPrefab.prefab" />
	<property name="ModelOffset" value="0,.5,0" />
	<property name="MultiBlockDim" value="2,2,1" />
	<property name="ImposterDontBlock" value="true" />
	<property name="WaterFlow" value="permitted" />
	
	<property name="Place" value="TowardsPlacerInverted" />
	<property name="OnlySimpleRotations" value="true" />
	<property name="IsTerrainDecoration" value="true" />
	<property name="StabilitySupport" value="false" />
	
	<property name="Weight" value="0" />
	<property name="EconomicValue" value="2000" />
	<property name="TraderStageTemplate" value="midTier1" />
	
	<property name="MaxDamage" value="800" />
	<property name="HeatMapStrength" value="5" />
	<property name="HeatMapTime" value="5000" />
	<property name="HeatMapFrequency" value="1000" />
	<property name="OpenSound" value="open_workbench" />
	<property name="CloseSound" value="close_workbench" />
	<property name="TakeDelay" value="15" />
	<property class="RepairItems">
		<property name="resourceForgedIron" value="25" />
		<property name="resourceMechanicalParts" value="20" />
		<property name="resourceWood" value="50" />
	</property>
	<drop event="Harvest" name="resourceScrapIron" count="200" tag="allHarvest,perkJunkMiner" />
	<drop event="Harvest" name="resourceWood" count="20" tag="allHarvest,lumberjackHarvest,perkJunkMiner" />
	<drop event="Harvest" name="terrStone" count="0" tool_category="Disassemble" />
	<drop event="Harvest" name="resourceForgedIron" count="10" tag="salvageHarvest" />
	<drop event="Harvest" name="resourceMechanicalParts" count="8" tag="salvageHarvest" />
	<drop event="Harvest" name="resourceWood" count="20" tag="salvageHarvest" />
	<drop event="Destroy" count="0" />
	<drop event="Fall" name="terrDestroyedWoodDebris" count="1" prob="0.75" stick_chance="1" />
	
	<property name="SortOrder1" value="B281" />
	<property name="SortOrder2" value="0300" />
	<property name="Group" value="Limited,Building,TCScience,advBuilding" />
	<property name="Tags" value="workstationSkill,twitch_workstation" />
	<property name="FilterTags" value="MC_playerBlocks,SC_decor" />
	<property name="SoundPickup" value="workbench_grab" />
	<property name="SoundPlace" value="workbench_place" />
<property name="CustomIcon" value="workbench" /><property name="WorkstationWindow" value="workstation_workbench" /><property name="SellableToTrader" value="false" /></block>

<block name="grimmerRestoredMixer">
	
	<property name="Class" value="Workstation" />
	<property class="Workstation">
		<property name="Modules" value="output" />
	<property name="CraftingAreaRecipes" value="cementMixer" /></property>
	<property name="UnlockedBy" value="craftingWorkstations" />
	
	<property name="CreativeMode" value="Player" />
	<property name="DescriptionKey" value="grimmerRestoredMixerDesc" />
	<property name="WorkstationIcon" value="ui_game_symbol_cement" />
	<property name="CraftIcon" value="ui_game_symbol_cement" />
	<property name="CraftActionName" value="lblContextActionMix" />
	<property name="Stacknumber" value="1" />
	
	<property name="Material" value="Miron_scrap" />
	<property name="Shape" value="ModelEntity" />
	<property name="Model" value="@:Entities/Crafting/cementMixerPrefab.prefab" />
	<property name="ModelOffset" value="0,0,0" />
	<property name="ImposterDontBlock" value="true" />
	<property name="WaterFlow" value="permitted" />
	
	<property name="Place" value="TowardsPlacer" />
	<property name="OnlySimpleRotations" value="true" />
	<property name="Path" value="solid" />
	<property name="IsTerrainDecoration" value="true" />
	<property name="StabilitySupport" value="true" />
	
	<property name="Weight" value="0" />
	<property name="EconomicValue" value="2500" />
	<property name="TraderStageTemplate" value="midTier1" />
	
	<property name="MaxDamage" value="800" />
	<property name="HeatMapStrength" value="5" />
	<property name="HeatMapTime" value="5000" />
	<property name="HeatMapFrequency" value="1000" />
	<property name="OpenSound" value="cement_mixer_open" />
	<property name="CloseSound" value="cement_mixer_close" />
	<property name="CraftSound" value="cement_mixer_start_click" />
	<property name="CraftCompleteSound" value="cement_mixer_complete" />
	<property name="TakeDelay" value="15" />
	<property class="RepairItems">
		<property name="resourceForgedIron" value="25" />
		<property name="resourceSpring" value="4" />
		<property name="resourceMechanicalParts" value="10" />
	</property>
	<drop event="Harvest" name="resourceScrapIron" count="300" tag="allHarvest,perkJunkMiner" />
	<drop event="Harvest" name="terrStone" count="0" tool_category="Disassemble" />
	<drop event="Harvest" name="resourceForgedIron" count="10" tag="salvageHarvest" />
	<drop event="Harvest" name="resourceSpring" count="2" tag="salvageHarvest" />
	<drop event="Harvest" name="resourceMechanicalParts" count="4" tag="salvageHarvest" />
	<drop event="Destroy" count="0" />
	<drop event="Fall" name="scrapMetalPile" count="1" prob="0.75" stick_chance="1" />
	
	<property name="SortOrder1" value="B281" />
	<property name="SortOrder2" value="0400" />
	<property name="Group" value="Building,TCScience,advBuilding" />
	<property name="Tags" value="workstationSkill,twitch_workstation" />
	<property name="FilterTags" value="MC_playerBlocks,SC_decor" />
	<property name="SoundPickup" value="cementmixer_grab" />
	<property name="SoundPlace" value="cementmixer_place" />
<property name="CustomIcon" value="cementMixer" /><property name="WorkstationWindow" value="workstation_cementMixer" /><property name="SellableToTrader" value="false" /></block>

<block name="grimmerRestoredChemistry">
	
	<property name="Class" value="Campfire" />
	<property class="Workstation">
		<property name="Modules" value="output,fuel,input" />
	<property name="CraftingAreaRecipes" value="chemistryStation" /></property>
	<property name="UnlockedBy" value="craftingWorkstations" />
	
	<property name="CreativeMode" value="Player" />
	<property name="DisplayType" value="blockMulti" />
	<property name="WorkstationIcon" value="ui_game_symbol_chemistry" />
	<property name="CraftIcon" value="ui_game_symbol_chemistry" />
	<property name="CraftActionName" value="lblContextActionMix" />
	<property name="Stacknumber" value="1" />
	
	<property name="Material" value="Miron_scrap" />
	<property name="Shape" value="ModelEntity" />
	<property name="Model" value="@:Entities/Crafting/chemStationPrefab.prefab" />
	<property name="MultiBlockDim" value="3,2,1" />
	<property name="ImposterDontBlock" value="true" />
	<property name="WaterFlow" value="permitted" />
	<property name="ParticleName" value="chemistryStation" />
	<property name="ParticleOffset" value="0.5,0.5,0.5" />
	
	<property name="Place" value="TowardsPlacerInverted" />
	<property name="OnlySimpleRotations" value="true" />
	<property name="Collide" value="movement,melee,bullet,arrow,rocket" />
	<property name="Path" value="solid" />
	<property name="IsTerrainDecoration" value="true" />
	
	<property name="Weight" value="0" />
	<property name="EconomicValue" value="5000" />
	<property name="EconomicBundleSize" value="1" />
	<property name="TraderStageTemplate" value="midTier2" />
	
	<property name="MaxDamage" value="800" />
	<property name="HeatMapStrength" value="5" />
	<property name="HeatMapTime" value="5000" />
	<property name="HeatMapFrequency" value="1000" />
	<property name="ActiveRadiusEffects" value="buffCampfireAOE,3" />
	<property name="OpenSound" value="chem_station_open" />
	<property name="CloseSound" value="chem_station_close" />
	<property name="CraftSound" value="chem_station_mix_click" />
	<property name="CraftCompleteSound" value="chem_station_complete_item" />
	<property name="TakeDelay" value="15" />
	<property class="RepairItems">
		<property name="resourceForgedIron" value="10" />
		<property name="resourceMetalPipe" value="10" />
		<property name="resourceWood" value="40" />
	</property>
	<drop event="Harvest" name="resourceScrapIron" count="80" tag="allHarvest,perkJunkMiner" />
	<drop event="Harvest" name="resourceWood" count="16" tag="allHarvest,lumberjackHarvest,perkJunkMiner" />
	<drop event="Harvest" name="terrStone" count="0" tool_category="Disassemble" />
	<drop event="Harvest" name="resourceForgedIron" count="4" tag="salvageHarvest" />
	<drop event="Harvest" name="resourceMetalPipe" count="4" tag="salvageHarvest" />
	<drop event="Harvest" name="resourceWood" count="15" tag="salvageHarvest" />
	<drop event="Destroy" count="0" />
	<drop event="Fall" name="scrapMetalPile" count="1" prob="0.75" stick_chance="1" />
	
	<property name="SortOrder1" value="B281" />
	<property name="SortOrder2" value="0500" />
	<property name="Group" value="Building,Science,TCScience,advBuilding" />
	<property name="Tags" value="workstationSkill,twitch_workstation" />
	<property name="FilterTags" value="MC_playerBlocks,SC_decor" />
	<property name="SoundPickup" value="chemistrystation_grab" />
	<property name="SoundPlace" value="chemistrystation_place" />
<property name="CustomIcon" value="chemistryStation" /><property name="DescriptionKey" value="grimmerRestoredChemistryDesc" /><property name="WorkstationWindow" value="workstation_chemistryStation" /><property name="SellableToTrader" value="false" /></block>

<block name="grimmerCultivatedPlot">
	<property name="CreativeMode" value="Player" />
	<property name="CanMobsSpawnOn" value="true" />
	<property name="DisplayType" value="blockTerrainFertile" />
	<property name="Material" value="Mfarmland" />
	<property name="Shape" value="New" />
	<property name="Model" value="@:Shapes/farm_plot.fbx" />
	<property name="Texture" value="47,84,84,84,84,84" />
	<property name="UseGlobalUV" value="G,L,L,L,L,L" />
	<property name="ImposterExchange" value="imposterBlock" param1="5" />
	<property name="OnlySimpleRotations" value="true" />
	<property name="EconomicValue" value="50" />
	<property name="SoundPickup" value="farmplot_grab" />
	<property name="SoundPlace" value="farmplot_place" />
	<property class="RepairItems">
		<property name="resourceClayLump" value="14" />
	</property>
	<drop event="Harvest" name="resourceClayLump" count="22" tag="oreWoodHarvest" />
	<drop event="Harvest" name="resourcePotassiumNitratePowder" count="4" tag="oreWoodHarvest" />
	<drop event="Destroy" count="0" />
	<drop event="Fall" name="terrDirt" count="1" prob="0.25" stick_chance="1" />
	<drop event="Fall" name="resourceClayLump" count="44" prob="0.187" stick_chance="0" />
	<property name="SortOrder1" value="B965" />
	<property name="SortOrder2" value="0000" />
	<property name="Group" value="Food/Cooking,Building,advBuilding" />
	<property name="FilterTags" value="MC_outdoor,SC_crops" />
<property name="CustomIcon" value="farmPlotBlockVariantHelper" /><property name="CustomIconTint" value="8EBF63" /><property name="DescriptionKey" value="grimmerCultivatedPlotDesc" /><property name="UnlockedBy" value="craftingSeeds" /></block>

</append><append xpath="/blocks/block[@name='cntForgeWorkstationBroken']"><drop event="Destroy" name="grimmerForgeSalvage" count="1" prob="0.5" /></append><append xpath="/blocks/block[@name='cntCollapsedWorkbench']"><drop event="Destroy" name="grimmerBenchSalvage" count="1" prob="0.5" /></append><append xpath="/blocks/block[@name='cntCollapsedWorkbenchEmpty']"><drop event="Destroy" name="grimmerBenchSalvage" count="1" prob="0.5" /></append><append xpath="/blocks/block[@name='cntCollapsedCementMixer']"><drop event="Destroy" name="grimmerMixerSalvage" count="1" prob="0.5" /></append><append xpath="/blocks/block[@name='cntCollapsedChemistryStation']"><drop event="Destroy" name="grimmerChemistrySalvage" count="1" prob="0.5" /></append></configs>
'@
    $payloads['Config/items.xml']=@'
<configs><append xpath="/items"><item name="grimmerCompost"><property name="Extends" value="resourceMechanicalParts" /><property name="CustomIcon" value="foodRottingFlesh" /><property name="CustomIconTint" value="666F38" /><property name="DescriptionKey" value="grimmerCompostDesc" /><property name="EconomicValue" value="1" /><property name="SellableToTrader" value="false" /><property name="Stacknumber" value="100" /><property name="Weight" value="1" /><property name="Material" value="MresourceYuccaFibers" /></item><item name="grimmerForgeSalvage"><property name="Extends" value="resourceMechanicalParts" /><property name="CustomIcon" value="forge" /><property name="CustomIconTint" value="B9A585" /><property name="DescriptionKey" value="grimmerForgeSalvageDesc" /><property name="EconomicValue" value="1" /><property name="SellableToTrader" value="false" /><property name="Stacknumber" value="100" /><property name="Weight" value="1" /><property name="Material" value="MmechanicalParts" /></item><item name="grimmerBenchSalvage"><property name="Extends" value="resourceMechanicalParts" /><property name="CustomIcon" value="workbench" /><property name="CustomIconTint" value="B9A585" /><property name="DescriptionKey" value="grimmerBenchSalvageDesc" /><property name="EconomicValue" value="1" /><property name="SellableToTrader" value="false" /><property name="Stacknumber" value="100" /><property name="Weight" value="1" /><property name="Material" value="MmechanicalParts" /></item><item name="grimmerMixerSalvage"><property name="Extends" value="resourceMechanicalParts" /><property name="CustomIcon" value="cementMixer" /><property name="CustomIconTint" value="B9A585" /><property name="DescriptionKey" value="grimmerMixerSalvageDesc" /><property name="EconomicValue" value="1" /><property name="SellableToTrader" value="false" /><property name="Stacknumber" value="100" /><property name="Weight" value="1" /><property name="Material" value="MmechanicalParts" /></item><item name="grimmerChemistrySalvage"><property name="Extends" value="resourceMechanicalParts" /><property name="CustomIcon" value="chemistryStation" /><property name="CustomIconTint" value="B9A585" /><property name="DescriptionKey" value="grimmerChemistrySalvageDesc" /><property name="EconomicValue" value="1" /><property name="SellableToTrader" value="false" /><property name="Stacknumber" value="100" /><property name="Weight" value="1" /><property name="Material" value="MmechanicalParts" /></item></append></configs>
'@
    $payloads['Config/progression.xml']=@'
<configs><append xpath="/progression/crafting_skills/crafting_skill[@name='craftingSeeds']/effect_group"><passive_effect name="RecipeTagUnlocked" operation="base_set" level="5,20" value="1" tags="grimmerCultivatedPlot" /></append><append xpath="/progression/crafting_skills/crafting_skill[@name='craftingWorkstations']/effect_group"><passive_effect name="RecipeTagUnlocked" operation="base_set" level="4,75" value="1" tags="grimmerRestoredForge" /></append><append xpath="/progression/crafting_skills/crafting_skill[@name='craftingWorkstations']/effect_group"><passive_effect name="RecipeTagUnlocked" operation="base_set" level="10,75" value="1" tags="grimmerRestoredWorkbench" /></append><append xpath="/progression/crafting_skills/crafting_skill[@name='craftingWorkstations']/effect_group"><passive_effect name="RecipeTagUnlocked" operation="base_set" level="34,75" value="1" tags="grimmerRestoredMixer" /></append><append xpath="/progression/crafting_skills/crafting_skill[@name='craftingWorkstations']/effect_group"><passive_effect name="RecipeTagUnlocked" operation="base_set" level="50,75" value="1" tags="grimmerRestoredChemistry" /></append></configs>
'@
    $payloads['Config/Localization.csv']=@'
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english
grimmerCompost,items,Item,,,,Compost
grimmerCompostDesc,items,Item,,,,Made in a Compost Bin from 5 rotten flesh and 20 plant fibres. Two Compost replace the rotten flesh and reduce base nitrate from 25 to 10 in the alternative Farm Plot recipe. Composting trains Seeds; it does not directly change crop yield or growth time.
grimmerForgeSalvage,items,Item,,,,Forge Restoration Parts
grimmerForgeSalvageDesc,items,Item,,,,"Recoverable parts from a ruined station: 50% chance when the ruined station is destroyed. No special tool required for these parts; use a salvage tool for normal salvage resources. Consumed by an alternative rebuild recipe with about 30% fewer normal materials. Original skill unlock, crafting station, beakers and engines remain required."
grimmerBenchSalvage,items,Item,,,,Workbench Restoration Parts
grimmerBenchSalvageDesc,items,Item,,,,"Recoverable parts from a ruined station: 50% chance when the ruined station is destroyed. No special tool required for these parts; use a salvage tool for normal salvage resources. Consumed by an alternative rebuild recipe with about 30% fewer normal materials. Original skill unlock, crafting station, beakers and engines remain required."
grimmerMixerSalvage,items,Item,,,,Mixer Restoration Parts
grimmerMixerSalvageDesc,items,Item,,,,"Recoverable parts from a ruined station: 50% chance when the ruined station is destroyed. No special tool required for these parts; use a salvage tool for normal salvage resources. Consumed by an alternative rebuild recipe with about 30% fewer normal materials. Original skill unlock, crafting station, beakers and engines remain required."
grimmerChemistrySalvage,items,Item,,,,Chemistry Restoration Parts
grimmerChemistrySalvageDesc,items,Item,,,,"Recoverable parts from a ruined station: 50% chance when the ruined station is destroyed. No special tool required for these parts; use a salvage tool for normal salvage resources. Consumed by an alternative rebuild recipe with about 30% fewer normal materials. Original skill unlock, crafting station, beakers and engines remain required."
grimmerCompostBin,blocks,Block,,,,Compost Bin
grimmerCompostBinDesc,blocks,Block,,,,"Wooden composting bin. Craft from 40 wood, 10 nails and 10 plant fibres. No fuel or tools needed. Queue 5 rotten flesh and 20 plant fibres to make one Compost over 120 seconds. Open the bin after completion to claim Seeds practice. Uses the vanilla wooden crate model."
grimmerCultivatedPlot,blocks,Block,,,,Cultivated Farm Plot
grimmerCultivatedPlotDesc,blocks,Block,,,,"Compost-enriched growing bed. Unlocks at Seeds 5. Costs one Farm Plot Block, four Compost and five nitrate. Newly scheduled crop growth stages above this plot take 20% less time, including normal growth randomness. Sunlight and harvest yields stay normal. No watering needed. Build an empty plot before planting; this does not upgrade occupied beds in place. Keep Workshop installed for the speed benefit."
grimmerRestoredForge,blocks,Block,,,,Restored Forge
grimmerRestoredForgeDesc,blocks,Block,,,,"Rebuilt from ruined-station parts with about 30% fewer normal materials. Unlocks at Workstations 4. Uses the normal forge model, recipes, tools, fuel and crafting speed. Rebuilding trains Workstations; this is a material-saving restoration, not a faster or powered station."
grimmerRestoredWorkbench,blocks,Block,,,,Restored Workbench
grimmerRestoredWorkbenchDesc,blocks,Block,,,,"Rebuilt from ruined-station parts with about 30% fewer normal materials. Unlocks at Workstations 10. Uses the normal workbench model, recipes, tools, fuel and crafting speed. Rebuilding trains Workstations; this is a material-saving restoration, not a faster or powered station."
grimmerRestoredMixer,blocks,Block,,,,Restored Cement Mixer
grimmerRestoredMixerDesc,blocks,Block,,,,"Rebuilt from ruined-station parts with about 30% fewer normal materials. Unlocks at Workstations 34. Uses the normal cementMixer model, recipes, tools, fuel and crafting speed. Rebuilding trains Workstations; this is a material-saving restoration, not a faster or powered station."
grimmerRestoredChemistry,blocks,Block,,,,Restored Chemistry Station
grimmerRestoredChemistryDesc,blocks,Block,,,,"Rebuilt from ruined-station parts with about 30% fewer normal materials. Unlocks at Workstations 50. Uses the normal chemistryStation model, recipes, tools, fuel and crafting speed. Rebuilding trains Workstations; this is a material-saving restoration, not a faster or powered station."

'@
    $payloads['ModInfo.xml']=@'
<xml><Name value="ZZZ_GrimmerHomestead"/><DisplayName value="Workshop Farming and Restoration"/><Version value="0.1.0"/><Description value="Original native-asset composting and ruined-station restoration. Retain while saves contain these items."/><Author value="Grimmer Workshop"/></xml>
'@
    foreach($relative in $payloads.Keys) {
        $destination=Join-Path $directory $relative
        Assert-WorkshopPlainPath $destination; Assert-WorkshopPlainPath ($destination+'.tmp')
        New-Item -ItemType Directory -Path (Split-Path $destination) -Force | Out-Null
        [IO.File]::WriteAllText(($destination+'.tmp'),$payloads[$relative],(New-Object Text.UTF8Encoding($false)))
        Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    }
}
# END GENERATED HOMESTEAD
function Write-WorkshopEnemyBalance([string]$Root, [string]$GameDirectory) {
    $mods=Join-Path $Root 'Profile\Mods'
    $directory=Join-Path $mods 'ZZZ_GrimmerEnemies\Config'
    Assert-WorkshopPlainPath $directory
    [xml]$patch='<configs />'
    $pack=Join-Path $mods 'Guppy_Zombies_V3'
    $metadata=Join-Path $pack 'ModInfo.xml'
    if(Test-Path -LiteralPath $metadata) {
        [xml]$packInfo=Get-Content -LiteralPath $metadata -Raw
        if($packInfo.xml.Name.value -eq 'Guppy_Zombies_V3' -and $packInfo.xml.Version.value -eq '3.0.3.0') {
            [xml]$classes=Get-Content -LiteralPath (Join-Path $pack 'Config\entityclasses.xml') -Raw
            [xml]$groups=Get-Content -LiteralPath (Join-Path $pack 'Config\entitygroups.xml') -Raw
            [xml]$native=Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\entitygroups.xml') -Raw
            $selected=@('zombieAlma','zombieBeatCop','zombieBelle','zombieBilly','zombieBob','zombieCarmela','zombieCheerleader','zombieERNurse','zombieGlenda','zombieHungryGeorge','zombieHungryJeff','zombieHungryScott','zombieLucy','zombieOldManZombie','zombiePete','zombiePoliceRalph','zombieRoland','zombieSecurityGuard','zombieSeth','zombieStripper','zombieThorton')
            $custom=@($classes.SelectNodes('/configs/append/entity_class') | ForEach-Object {$_.GetAttribute('name')})
            foreach($name in $custom) {
                if($name -notmatch '^[A-Za-z0-9_]+$'){throw 'Unexpected external entity name.'}
                if($selected -notcontains $name) {
                    $node=$patch.CreateElement('remove');$node.SetAttribute('xpath',("/entitygroups/entitygroup/e[@n='{0}']" -f $name));$null=$patch.DocumentElement.AppendChild($node)
                }
            }
            $byGroup=@{}
            foreach($append in $groups.SelectNodes('/configs/append')) {
                $xpath=$append.GetAttribute('xpath')
                if($xpath -notmatch "^/entitygroups/entitygroup\[@name='([A-Za-z0-9_]+)'\]$"){throw 'Unexpected external spawn group selector.'}
                $name=$Matches[1]
                if(-not $byGroup.ContainsKey($name)){$byGroup[$name]=@()}
                $byGroup[$name]+= @($append.SelectNodes('e') | Where-Object {$selected -contains $_.GetAttribute('n')})
            }
            $culture=[Globalization.CultureInfo]::InvariantCulture
            foreach($name in $byGroup.Keys) {
                $original=$native.SelectSingleNode(("/entitygroups/entitygroup[@name='{0}']" -f $name))
                if(-not $original){throw ('External spawn group absent from installed game: '+$name)}
                $baseWeight=0.0
                foreach($entity in $original.SelectNodes('e')) {
                    $raw=$entity.GetAttribute('p');$weight=if($raw){[double]::Parse($raw,$culture)}else{1.0}
                    if($weight -gt 0){$baseWeight+=$weight}
                }
                $entries=@($byGroup[$name]);$addedWeight=0.0
                foreach($entity in $entries){$raw=$entity.GetAttribute('p');$addedWeight+=if($raw){[double]::Parse($raw,$culture)}else{1.0}}
                if($addedWeight -le 0 -or $entries.Count -eq 0){continue}
                # Additional relative weight <= one quarter of existing weight:
                # <=20% share in each standalone native+Guppy group. No spawn
                # count/frequency/gamestage changes and no native weights changed.
                $scale=[Math]::Min(1.0,($baseWeight*0.25)/$addedWeight)
                $byWeight=@{}
                foreach($entity in $entries) {
                    $raw=$entity.GetAttribute('p');$weight=if($raw){[double]::Parse($raw,$culture)}else{1.0}
                    $key=($weight*$scale).ToString('0.########',$culture)
                    if(-not $byWeight.ContainsKey($key)){$byWeight[$key]=@()}
                    $byWeight[$key]+=$entity.GetAttribute('n')
                }
                foreach($key in $byWeight.Keys) {
                    # Group equal weights into one native XPath operation.
                    $condition=(@($byWeight[$key] | Select-Object -Unique | ForEach-Object {"@n='$_'"}) -join ' or ')
                    $node=$patch.CreateElement('setattribute');$node.SetAttribute('xpath',("/entitygroups/entitygroup[@name='{0}']/e[{1}]" -f $name,$condition));$node.SetAttribute('name','p');$node.InnerText=$key;$null=$patch.DocumentElement.AppendChild($node)
                }
            }
        }
    }
    $modRoot=Split-Path $directory
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $info='<xml><Name value="ZZZ_GrimmerEnemies"/><DisplayName value="Workshop Optional Zombie Balance"/><Version value="0.1.0"/><Description value="Optional companion references separately installed Guppy 3.0.3.0. No external assets bundled."/><Author value="Grimmer Workshop"/></xml>'
    foreach($pair in @(@((Join-Path $directory 'entitygroups.xml'),$patch.OuterXml),@((Join-Path $modRoot 'ModInfo.xml'),$info))) {
        $destination=$pair[0];Assert-WorkshopPlainPath $destination;Assert-WorkshopPlainPath ($destination+'.tmp')
        [IO.File]::WriteAllText(($destination+'.tmp'),$pair[1],(New-Object Text.UTF8Encoding($false)))
        Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    }
}
function Get-WorkshopPackStatus([string]$Root) {
    $catalog=@(
        @{folder='DSD_Arsenal';name='DSD Arsenal';id='DSD_Arsenal';version='1.2.1';url='https://www.nexusmods.com/7daystodie/mods/13921';files=@('Config\items.xml','Config\recipes.xml','DSD_Arsenal.dll');note='Weapon practice integration'},
        @{folder='Guppy_Zombies_V3';name='Guppy Zombies';id='Guppy_Zombies_V3';version='3.0.3.0';url='https://www.nexusmods.com/7daystodie/mods/4412';files=@('Config\entityclasses.xml','Config\entitygroups.xml');note='21-appearance spawn companion'},
        @{folder='BdubsVehicles';name='Bdub Vehicles';id='Bdubs_Vehicles';version='3.4.0.2';url='https://www.nexusmods.com/7daystodie/mods/342';files=@('Config\items.xml','Config\recipes.xml','Config\vehicles.xml');note='Vehicles practice integration'},
        @{folder='GNS_BeautifulBases';name='Beautiful Bases';id='GNS_BeautifulBases';version='2.0';url='https://www.nexusmods.com/7daystodie/mods/3318';files=@('Config\blocks.xml','Config\recipes.xml','Config\shapes.xml');note='Archive 3.7 / metadata 2.0; Construction integration'},
        @{folder='Looted';name='Looted';id='Looted';version='3.4.9';url='https://www.nexusmods.com/7daystodie/mods/13822';files=@('Looted.dll','Config\XUi_InGame\windows.xml');note='Original map/POI tracking pack'},
        @{folder='FMG_LivelierWildlife';name='Livelier Wildlife';id='FMG_LivelierWildlife';version='1.0.0';url='https://www.nexusmods.com/7daystodie/mods/14042';files=@('Config\buffs.xml','Config\gameevents.xml','Config\spawning.xml','Config\entitygroups.xml');note='Original wildlife encounters; vanilla animal models'}
    )
    foreach($pack in $catalog) {
        $directory=Join-Path $Root ('Profile\Mods\'+$pack.folder)
        $metadata=Join-Path $directory 'ModInfo.xml'
        $version='';$state='Not installed'
        if(Test-Path -LiteralPath $directory) {
            $state='Incomplete / wrong folder layout'
            if(Test-Path -LiteralPath $metadata) {
                try {
                    [xml]$info=Get-Content -LiteralPath $metadata -Raw
                    $nameNode=$info.SelectSingleNode('/xml/Name');$versionNode=$info.SelectSingleNode('/xml/Version')
                    if(-not $nameNode -or -not $versionNode){throw 'Missing identity/version.'}
                    $version=$versionNode.GetAttribute('value')
                    $missing=@($pack.files|Where-Object {-not (Test-Path -LiteralPath (Join-Path $directory $_))})
                    if($nameNode.GetAttribute('value') -ne $pack.id){$state='Unexpected pack identity'}
                    elseif($missing.Count){$state='Missing required files'}
                    elseif($version -eq $pack.version){$state='Recognised metadata'}
                    else{$state='Different version - unreviewed'}
                } catch {$state='Unreadable metadata'}
            }
        }
        [pscustomobject]@{Pack=$pack.name;Version=$version;Status=$state;Integration=$pack.note;Url=$pack.url;Folder=$pack.folder}
    }
}

function Show-WorkshopPacks([string]$Root) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $dialog=New-Object Windows.Forms.Form
    $dialog.Text='Workshop optional packs';$dialog.Size=New-Object Drawing.Size(980,420);$dialog.MinimumSize=$dialog.Size;$dialog.StartPosition='CenterScreen'
    $list=New-Object Windows.Forms.ListView
    $list.View='Details';$list.FullRowSelect=$true;$list.MultiSelect=$false;$list.SetBounds(15,15,930,245);$list.Anchor='Top,Left,Right,Bottom'
    foreach($column in @(@('Pack',150),@('Version',80),@('Status',220),@('Integration',450))){$null=$list.Columns.Add($column[0],$column[1])}
    $dialog.Controls.Add($list)
    $note=New-Object Windows.Forms.Label;$note.SetBounds(15,270,930,45);$note.Anchor='Left,Right,Bottom';$note.Text='Recognised metadata means the reviewed identity/version and key files are present. It does not verify every file, loaded state or live compatibility. External packs need separate author downloads.';$dialog.Controls.Add($note)
    $refresh=New-Object Windows.Forms.Button;$refresh.Text='Refresh';$refresh.SetBounds(15,325,130,32);$refresh.Anchor='Left,Bottom';$dialog.Controls.Add($refresh)
    $website=New-Object Windows.Forms.Button;$website.Text='Original download page';$website.SetBounds(160,325,220,32);$website.Anchor='Left,Bottom';$dialog.Controls.Add($website)
    $close=New-Object Windows.Forms.Button;$close.Text='Close';$close.SetBounds(815,325,130,32);$close.Anchor='Right,Bottom';$dialog.Controls.Add($close)
    $reload={
        $list.Items.Clear()
        foreach($row in @(Get-WorkshopPackStatus $Root)){
            $item=New-Object Windows.Forms.ListViewItem($row.Pack)
            $null=$item.SubItems.Add([string]$row.Version);$null=$item.SubItems.Add($row.Status);$null=$item.SubItems.Add($row.Integration);$item.Tag=$row.Url;$null=$list.Items.Add($item)
        }
    }.GetNewClosure()
    $refresh.Add_Click($reload)
    $website.Add_Click({if($list.SelectedItems.Count){Start-Process $list.SelectedItems[0].Tag}}.GetNewClosure())
    $close.Add_Click({$dialog.Close()}.GetNewClosure())
    & $reload
    [void]$dialog.ShowDialog();$dialog.Dispose()
}
function Write-WorkshopTextFixes([string]$Root,[string]$GameDirectory) {
    $modRoot=Join-Path $Root 'Profile\Mods\ZZZ_GrimmerText'
    $directory=Join-Path $modRoot 'Config';Assert-WorkshopPlainPath $directory
    [xml]$blocks='<configs />';$rows=New-Object 'System.Collections.Generic.List[object]'
    $gns=Join-Path $Root 'Profile\Mods\GNS_BeautifulBases'
    if(Test-Path -LiteralPath (Join-Path $gns 'ModInfo.xml')) {
        $packDoc=New-Object Xml.XmlDocument;$packDoc.Load((Join-Path $gns 'ModInfo.xml'))
        if($packDoc.SelectSingleNode('/xml/Name').GetAttribute('value') -eq 'GNS_BeautifulBases' -and $packDoc.SelectSingleNode('/xml/Version').GetAttribute('value') -eq '2.0') {
            [xml]$source=Get-Content -LiteralPath (Join-Path $gns 'Config\blocks.xml') -Raw
            [xml]$native=Get-Content -LiteralPath (Join-Path $GameDirectory 'Data\Config\blocks.xml') -Raw
            $text=@(
                @('opensignBlockVariantHelper','Open Sign Shapes','Choose an open-sign shape before placing. Retains the chosen sign model and its original powered-light behaviour.'),
                @('flagBlockVariantHelper','Wall Flag Shapes','Choose a wall or hanging flag before placing. A decorative flag collection, including the GNS design.'),
                @('JailVariantHelper','Jail Doors and Bars','Choose a jail door, double door or bars before placing. Original opening and collision behaviour is retained.'),
                @('HoistVariantHelper','Hoist Shapes','Choose a decorative hook, chain, spreader or mount before placing. This decoration is not a working vehicle lift or crafting station.'),
                @('barbedWireSpindleVariantHelper','Barbed Wire Shapes','Choose a barbed-wire coil or sheet shape before placing. The selected source variant keeps its original behaviour.'),
                @('GNS_Wall_Sign_Round','GNS Round Wall Sign','Round decorative GNS wall sign. Place as base decoration; this item adds no crafting station or progression bonus.'),
                @('GNS_Flag','GNS Flag','Decorative GNS wall flag. Can be selected from the wall-flag shape collection.'),
                @('GNS_Sign_Logo','GNS Letter Sign','Powered decorative GNS lettering. Connect to an appropriate power source to use the light.'),
                @('GNS_Sign_Logo_Backplate','GNS Sign With Backplate','Powered decorative GNS sign with a backplate. Connect to an appropriate power source to use the light.'),
                @('GNS_Sign_Initials','GNS Initials Sign','Powered decorative GNS initials. Connect to an appropriate power source to use the light.'),
                @('plantHydroponicAloePlayer','Hydroponic Aloe Decor','Placeable hydroponic aloe decoration with the original powered-light behaviour. This is not a working crop-growing or watering system.'),
                @('plantHydroponicVerticalPlayer','Vertical Hydroponic Decor','Placeable vertical hydroponic decoration with the original powered-light behaviour. It does not grow harvestable crops or irrigate nearby plots.'),
                @('CorrugatedMetalSheetVariantHelper','Corrugated Metal Shapes','Choose a corrugated wall or siding shape before placing. Intended for base building and decoration.'),
                @('BanditPlatformVariantHelper','Platform and Ramp Shapes','Choose a platform, ramp or support shape before placing. Retains the selected shape and normal structural behaviour.'),
                @('bellBlockVariantHelper','Bell Shapes','Choose a bell shape before placing. Uses the source model and its existing interactions; no custom alarm system is added.'),
                @('FlashlightVariantHelper','Decorative Flashlight Shapes','Choose a placeable flashlight shape before placing. These are world decorations rather than equippable handheld flashlights.'),
                @('barrierMilitary','','Filled military barrier for base building. Its two genuine recipes use clay or sand with scrap iron and cloth.'),
                @('flagPoleWhiteRiver','','Placeable White River flagpole for base decoration. Craft using the recipe-listed metal parts, tape and cloth.'),
                @('flagPoleTrader','','Placeable trader flagpole for base decoration. Craft using the recipe-listed metal parts, tape and cloth.'),
                @('flagPoleAmerican','','Placeable American flagpole for base decoration. Craft using the recipe-listed metal parts, tape and cloth.'),
                @('capChimneyLargeSmoke','','Placeable smoking chimney decoration. The smoke is a visual effect; this item is not a fuel-burning cooking or production workstation.')
            )
            foreach($entry in $text) {
                $name=$entry[0];$key='grimmerAuditDescription_'+$name
                $definition=$source.SelectSingleNode(("/configs/append[@xpath='/blocks']/block[@name='{0}']" -f $name))
                if(-not $definition){$definition=$native.SelectSingleNode(("/blocks/block[@name='{0}']" -f $name))}
                if(-not $definition){throw ('Text companion target missing: '+$name)}
                if($definition.SelectSingleNode("property[@name='DescriptionKey']")) {
                    $node=$blocks.CreateElement('setattribute');$node.SetAttribute('xpath',("/blocks/block[@name='{0}']/property[@name='DescriptionKey']" -f $name));$node.SetAttribute('name','value');$node.InnerText=$key
                } else {
                    $node=$blocks.CreateElement('append');$node.SetAttribute('xpath',("/blocks/block[@name='{0}']" -f $name))
                    $property=$blocks.CreateElement('property');$property.SetAttribute('name','DescriptionKey');$property.SetAttribute('value',$key);$null=$node.AppendChild($property)
                }
                $null=$blocks.DocumentElement.AppendChild($node)
                if($entry[1]){$rows.Add(@($name,$entry[1]))}
                $rows.Add(@($key,$entry[2]))
            }
        }
    }
    $bdub=Join-Path $Root 'Profile\Mods\BdubsVehicles'
    if(Test-Path -LiteralPath (Join-Path $bdub 'ModInfo.xml')) {
        $vehicleDoc=New-Object Xml.XmlDocument;$vehicleDoc.Load((Join-Path $bdub 'ModInfo.xml'))
        if($vehicleDoc.SelectSingleNode('/xml/Name').GetAttribute('value') -eq 'Bdubs_Vehicles' -and $vehicleDoc.SelectSingleNode('/xml/Version').GetAttribute('value') -eq '3.4.0.2') {
            $rows.Add(@('vehicleMinibikePlaceableDesc','A placeable classic-style minibike. Assemble from its matching components and the recipe-listed parts. Fuel, repair and handling follow the original vehicle pack.'))
            $rows.Add(@('vehicleGNXBlackplaceableDesc','A placeable GNX car. Assemble from its matching chassis, accessories and the recipe-listed parts. Speed, storage, fuel and handling follow the original vehicle pack.'))
        }
    }
    $csv=New-Object Text.StringBuilder
    $null=$csv.AppendLine('Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english')
    foreach($row in $rows){$null=$csv.AppendLine(($row[0]+',blocks,Block,,,,"'+([string]$row[1]).Replace('"','""')+'"'))}
    $modInfoText='<xml><Name value="ZZZ_GrimmerText"/><DisplayName value="Workshop English Text Fixes"/><Version value="0.1.0"/><Description value="Original missing English names/descriptions; no author assets or gameplay changes."/><Author value="Grimmer Workshop"/></xml>'
    New-Item -ItemType Directory -Path $directory -Force|Out-Null
    foreach($pair in @(@((Join-Path $directory 'blocks.xml'),$blocks.OuterXml),@((Join-Path $directory 'Localization.csv'),$csv.ToString()),@((Join-Path $modRoot 'ModInfo.xml'),$modInfoText))) {
        $destination=$pair[0];Assert-WorkshopPlainPath $destination;Assert-WorkshopPlainPath ($destination+'.tmp')
        [IO.File]::WriteAllText(($destination+'.tmp'),$pair[1],(New-Object Text.UTF8Encoding($false)))
        Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    }
}

function Assert-WorkshopGeneratedConfig([string]$Root) {
    $mods=Join-Path $Root 'Profile\Mods'
    foreach($directory in Get-ChildItem -LiteralPath $mods -Directory|Where-Object {$_.Name -eq 'GrimmerWorkshop' -or $_.Name.StartsWith('ZZZ_Grimmer')}) {
        foreach($file in Get-ChildItem -LiteralPath $directory.FullName -Recurse -Filter '*.xml') {
            try {
                $document=New-Object Xml.XmlDocument;$document.Load($file.FullName)
                if($file.Name -eq 'ModInfo.xml' -and (-not $document.SelectSingleNode('/xml/Name[@value]') -or -not $document.SelectSingleNode('/xml/Version[@value]'))){throw 'Missing mod identity or version.'}
            } catch {throw ('Workshop generated invalid XML: '+$file.FullName+'. '+$_.Exception.Message)}
        }
    }
}
function Show-WorkshopDisplaySettings([string]$Root,[object]$Owner,[switch]$PreviewTest) {
    $configure=Join-Path $Root 'Profile\Mods\ZZZ_GrimmerHUD\Configure.ps1'
    if(-not (Test-Path -LiteralPath $configure -PathType Leaf)) {
        throw 'Display settings file is missing. Check for updates and install the repair, then reopen the launcher.'
    }
    if([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
        throw 'Open Workshop through Launch-Workshop.cmd so display settings run in the required STA mode.'
    }
    & $configure -Owner $Owner -PreviewTest:$PreviewTest
}

# BEGIN GENERATED UTILITIES
function Write-WorkshopUtilities([string]$Root) {
    $directory=Join-Path $Root 'Profile\Mods\ZZZ_GrimmerUtilities\Config'
    Assert-WorkshopPlainPath $directory
    New-Item -ItemType Directory -Path $directory -Force|Out-Null
    $value=@'
<configs><append xpath="/blocks"><block name="grimmerWorkshopDrive">
	<property name="CreativeMode" value="Player" />
	<property name="Class" value="Powered" />
	<property name="RequiredPower" value="20" />
	<property name="UnlockedBy" value="craftingElectrician" />
	<property name="DisplayType" value="blockElectrical" />
	<property name="Material" value="Mmetal_weak" />
	<property name="Shape" value="ModelEntity" />
	<property name="Model" value="@:Entities/Electrical/relayPrefab.prefab" />
	<property name="ImposterDontBlock" value="true" />
	<property name="WaterFlow" value="permitted" />
	<property name="HandleFace" value="Bottom" />
	<property name="Collide" value="movement,melee,bullet,arrow,rocket" />
	<property name="StabilitySupport" value="false" />
	<property name="EconomicValue" value="100" />
	<property name="SoundPickup" value="relay_grab" />
	<property name="SoundPlace" value="relay_place" />
	<property name="TraderStageTemplate" value="electricTier1" />
	<property name="TakeDelay" value="5" />
	<property class="RepairItems">
		<property name="resourceForgedIron" value="1" />
	</property>
	<drop event="Harvest" name="terrStone" count="0" tool_category="Disassemble" />
	<drop event="Harvest" name="resourceElectricParts" count="1" tag="salvageHarvest" />
	<drop event="Destroy" name="resourceScrapIron" count="1,5" />
	<drop event="Fall" name="scrapMetalPile" count="1" prob="0.75" stick_chance="1" />
	<property name="SortOrder1" value="B155" />
	<property name="SortOrder2" value="0006" />
	<property name="Group" value="Science,TCScience" />
	<property name="Tags" value="electricianSkill,scrap100" />
	<property name="FilterTags" value="MC_playerBlocks,SC_electrical" />
<property name="DescriptionKey" value="grimmerWorkshopDriveDesc" /><property name="CustomIcon" value="electricwirerelay" /><property name="CustomIconTint" value="C8944E" /><property name="SellableToTrader" value="false" /></block>

<block name="grimmerIrrigationController">
	<property name="CreativeMode" value="Player" />
	<property name="Class" value="Powered" />
	<property name="RequiredPower" value="10" />
	<property name="UnlockedBy" value="craftingElectrician" />
	<property name="DisplayType" value="blockElectrical" />
	<property name="Material" value="Mmetal_weak" />
	<property name="Shape" value="ModelEntity" />
	<property name="Model" value="@:Entities/Electrical/relayPrefab.prefab" />
	<property name="ImposterDontBlock" value="true" />
	<property name="WaterFlow" value="permitted" />
	<property name="HandleFace" value="Bottom" />
	<property name="Collide" value="movement,melee,bullet,arrow,rocket" />
	<property name="StabilitySupport" value="false" />
	<property name="EconomicValue" value="100" />
	<property name="SoundPickup" value="relay_grab" />
	<property name="SoundPlace" value="relay_place" />
	<property name="TraderStageTemplate" value="electricTier1" />
	<property name="TakeDelay" value="5" />
	<property class="RepairItems">
		<property name="resourceForgedIron" value="1" />
	</property>
	<drop event="Harvest" name="terrStone" count="0" tool_category="Disassemble" />
	<drop event="Harvest" name="resourceElectricParts" count="1" tag="salvageHarvest" />
	<drop event="Destroy" name="resourceScrapIron" count="1,5" />
	<drop event="Fall" name="scrapMetalPile" count="1" prob="0.75" stick_chance="1" />
	<property name="SortOrder1" value="B155" />
	<property name="SortOrder2" value="0006" />
	<property name="Group" value="Science,TCScience" />
	<property name="Tags" value="electricianSkill,scrap100" />
	<property name="FilterTags" value="MC_playerBlocks,SC_electrical" />
<property name="DescriptionKey" value="grimmerIrrigationControllerDesc" /><property name="CustomIcon" value="electricwirerelay" /><property name="CustomIconTint" value="4DAFC7" /><property name="SellableToTrader" value="false" /></block>

</append></configs>
'@
    $destination=Join-Path $directory 'blocks.xml'
    Assert-WorkshopPlainPath $destination;Assert-WorkshopPlainPath ($destination+'.tmp')
    [IO.File]::WriteAllText(($destination+'.tmp'),$value,(New-Object Text.UTF8Encoding($false)))
    Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    $value=@'
<configs><append xpath="/progression/crafting_skills/crafting_skill[@name='craftingElectrician']/effect_group"><passive_effect name="RecipeTagUnlocked" operation="base_set" level="35,100" value="1" tags="grimmerWorkshopDrive" /></append><append xpath="/progression/crafting_skills/crafting_skill[@name='craftingElectrician']/effect_group"><passive_effect name="RecipeTagUnlocked" operation="base_set" level="25,100" value="1" tags="grimmerIrrigationController" /></append></configs>
'@
    $destination=Join-Path $directory 'progression.xml'
    Assert-WorkshopPlainPath $destination;Assert-WorkshopPlainPath ($destination+'.tmp')
    [IO.File]::WriteAllText(($destination+'.tmp'),$value,(New-Object Text.UTF8Encoding($false)))
    Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    $value=@'
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english
grimmerWorkshopDrive,blocks,Block,,,,Workshop Drive
grimmerWorkshopDriveDesc,blocks,Block,,,,"Powered workshop aid. Draws 20 W while connected. Within 2 blocks in each direction of the station base, eligible workbenches, mixers, chemistry stations and Gunsmith Benches process recipe queues 25% faster while loaded and powered. Native tools and fuel remain required; forge smelting and composting are unchanged. Drives do not stack. Long offline catch-up receives no guessed power bonus. Uses the vanilla relay model."
grimmerIrrigationController,blocks,Block,,,,Irrigation Controller
grimmerIrrigationControllerDesc,blocks,Block,,,,"Draws 10 W and requires a water block touching one face of the controller. Covers cultivated soil within 3 blocks horizontally and 1 vertically. Newly scheduled planted-crop stage intervals are 10% shorter after the cultivated-bed bonus (about 28% shorter combined). Sunlight, yields and ordinary crops stay normal. Water is a reusable source, not consumed inventory; no pipe simulation or drought deaths. Conditions are checked when each stage is scheduled; already pending ticks are unchanged. Uses the vanilla relay model."

'@
    $destination=Join-Path $directory 'Localization.csv'
    Assert-WorkshopPlainPath $destination;Assert-WorkshopPlainPath ($destination+'.tmp')
    [IO.File]::WriteAllText(($destination+'.tmp'),$value,(New-Object Text.UTF8Encoding($false)))
    Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
    $value=@'
<xml><Name value="ZZZ_GrimmerUtilities"/><DisplayName value="Workshop Powered Utilities"/><Version value="0.1.0"/><Description value="Native relay models for workshop assistance and irrigation. Retain while saves contain these blocks."/><Author value="Grimmer Workshop"/></xml>
'@
    $destination=Join-Path $directory '../ModInfo.xml'
    Assert-WorkshopPlainPath $destination;Assert-WorkshopPlainPath ($destination+'.tmp')
    [IO.File]::WriteAllText(($destination+'.tmp'),$value,(New-Object Text.UTF8Encoding($false)))
    Move-Item -LiteralPath ($destination+'.tmp') -Destination $destination -Force
}
# END GENERATED UTILITIES
