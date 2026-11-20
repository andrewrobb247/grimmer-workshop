param([string]$Version='0.1.45', [string]$OutputDirectory=(Join-Path $PSScriptRoot '..\Workshop-Publish'), [string]$Channel='testing', [string]$Notes='Learn by Doing now has rank progression routes for all 57 gameplay perks and five attributes. Weapon damage earns base practice; activity routes add practice, and ranks rise automatically when practice and native gates are met. Existing ranks are preserved, practice speed is adjustable, and unspent points are banked/restored with the setting. Movement, combat recovery, harvesting/digging, looting, trading, armor and lockpick routes are included. Specialty attribution and balance are ready for in-game playtesting.')
$ErrorActionPreference = 'Stop'
if ($Version -notmatch '^\d+\.\d+\.\d+$' -or $Channel -notin @('stable','testing')) { throw 'Invalid release version or channel.' }
. (Join-Path $PSScriptRoot 'Update-Core.ps1')
$release = Join-Path $OutputDirectory ('versions\' + $Version)
if (Test-Path -LiteralPath $release) { throw 'Release folders are immutable. Choose a fresh output folder or version.' }
New-Item -ItemType Directory -Path $release -Force | Out-Null
$paths = @('Launch-Workshop.cmd','Launch-Workshop.ps1','Launcher.ps1','Update-Core.ps1','Update-Workshop.cmd','Rollback-Workshop.cmd','Open-Display-Settings.cmd','README.md','UpdaterSettings.json')
$paths += Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'Profile\Mods') -Recurse -File | ForEach-Object { $_.FullName.Substring($PSScriptRoot.Length+1).Replace('\','/') }
$files = @()
foreach ($relative in $paths) {
    $source = Resolve-WorkshopFile $PSScriptRoot $relative
    $destination = Resolve-WorkshopFile $release $relative
    New-Item -ItemType Directory -Path (Split-Path $destination) -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination
    $mode = if ($relative -match '(WorkshopSettings\.xml|Settings\.json|Config/XUi_InGame/windows\.xml)$') { 'default' } else { 'managed' }
    $files += [pscustomobject]@{path=$relative;mode=$mode;size=(Get-Item -LiteralPath $source).Length;sha256=(Get-WorkshopHash $source);url="https://raw.githubusercontent.com/andrewrobb247/grimmer-workshop/main/versions/$Version/$relative"}
}
$installed = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Installed-Release.json') -Raw | ConvertFrom-Json
$manifest = [pscustomobject]@{schema=1;version=$Version;gameVersion='V3.4 b10';gameAssemblySha256=$installed.gameAssemblySha256;notes=$Notes;files=$files}
New-Item -ItemType Directory -Path (Join-Path $OutputDirectory 'channels') -Force | Out-Null
# Windows PowerShell 5.1 Set-Content -Encoding UTF8 adds a BOM.
# Invoke-RestMethod then treats GitHub text/plain JSON as a string.
$utf8 = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $OutputDirectory "channels\$Channel.json"), ($manifest | ConvertTo-Json -Depth 10), $utf8)
[IO.File]::WriteAllText((Join-Path $release 'Installed-Release.json'), (@{schema=1;version=$Version;gameVersion='V3.4 b10';gameAssemblySha256=$installed.gameAssemblySha256} | ConvertTo-Json), $utf8)
$null = @(Get-WorkshopPlan $PSScriptRoot $manifest)
Write-Host "Prepared $Version on $Channel with $($files.Count) files. No game binaries or saves included."









