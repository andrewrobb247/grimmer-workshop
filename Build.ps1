param([string]$GameDirectory = 'C:\Program Files (x86)\Steam\steamapps\common\7 Days To Die')
$ErrorActionPreference = 'Stop'
$managed = Join-Path $GameDirectory '7DaysToDie_Data\Managed'
$modDirectory = Join-Path $PSScriptRoot 'Profile\Mods\GrimmerWorkshop'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$referenceNames = @('mscorlib.dll', 'System.dll', 'System.Core.dll', 'System.Xml.dll', 'System.Xml.Linq.dll', 'netstandard.dll', 'Assembly-CSharp.dll', 'Assembly-CSharp-firstpass.dll', 'UnityEngine.CoreModule.dll', 'LogLibrary.dll')
$references = $referenceNames | ForEach-Object { '/reference:' + (Join-Path $managed $_) }
$harmony = Join-Path $GameDirectory 'Mods\0_TFP_Harmony\0Harmony.dll'
New-Item -ItemType Directory -Path $modDirectory -Force | Out-Null
& $compiler /nologo /noconfig /target:library /nostdlib /optimize+ ("/out:" + (Join-Path $modDirectory 'GrimmerWorkshop.dll')) $references ("/reference:" + $harmony) (Join-Path $PSScriptRoot 'Source\Workshop.cs') (Join-Path $PSScriptRoot 'Source\Storage.cs') (Join-Path $PSScriptRoot 'Source\StorageButtons.cs') (Join-Path $PSScriptRoot 'Source\WorkstationCredit.cs') (Join-Path $PSScriptRoot 'Source\PracticeMath.cs') (Join-Path $PSScriptRoot 'Source\CraftingUi.cs') (Join-Path $PSScriptRoot 'Source\RecipeTraining.cs') (Join-Path $PSScriptRoot 'Source\Activities.cs') (Join-Path $PSScriptRoot 'Source\ActivityBudget.cs') (Join-Path $PSScriptRoot 'Source\ActionSkillPreview.cs') (Join-Path $PSScriptRoot 'Source\ActionPreviewMath.cs') (Join-Path $PSScriptRoot 'Source\LearnByDoing.cs') (Join-Path $PSScriptRoot 'Source\LearnByDoingRoutes.cs') (Join-Path $PSScriptRoot 'Source\SkillScreen.cs') (Join-Path $PSScriptRoot 'Source\SkillScreenText.cs') (Join-Path $PSScriptRoot 'Source\VehicleInspectionState.cs') (Join-Path $PSScriptRoot 'Source\VehicleInspection.cs') (Join-Path $PSScriptRoot 'Source\StoragePickup.cs') (Join-Path $PSScriptRoot 'Source\Gunsmith.cs') (Join-Path $PSScriptRoot 'Source\ArsenalRules.cs') (Join-Path $PSScriptRoot 'Source\RecipeVariants.cs') (Join-Path $PSScriptRoot 'Source\VehiclePackRules.cs') (Join-Path $PSScriptRoot 'Source\DecorRules.cs') (Join-Path $PSScriptRoot 'Source\DecorTime.cs') (Join-Path $PSScriptRoot 'Source\CropGrowth.cs') (Join-Path $PSScriptRoot 'Source\Utilities.cs')
if ($LASTEXITCODE -ne 0) { throw 'Game mod compilation failed.' }
python (Join-Path $PSScriptRoot 'Source\generate_config.py') $GameDirectory $modDirectory
if ($LASTEXITCODE -ne 0) { throw 'Configuration generation failed.' }
& python (Join-Path $PSScriptRoot 'Source\generate_homestead.py') $GameDirectory $PSScriptRoot
if ($LASTEXITCODE -ne 0) { throw 'Homestead generation failed.' }





& python (Join-Path $PSScriptRoot 'Source\generate_utilities.py') $GameDirectory $PSScriptRoot
if ($LASTEXITCODE -ne 0) { throw 'Utility generation failed.' }

