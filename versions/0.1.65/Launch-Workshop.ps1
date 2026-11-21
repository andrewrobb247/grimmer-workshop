param([string]$GameDirectory = '')
$ErrorActionPreference = 'Stop'
try {
    . (Join-Path $PSScriptRoot 'Update-Core.ps1')
    $installed = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Installed-Release.json') -Raw | ConvertFrom-Json
    if (-not (Test-WorkshopGameDirectory $GameDirectory $installed.gameAssemblySha256)) {
        $GameDirectory = Find-WorkshopGameDirectory $GameDirectory $installed.gameAssemblySha256
    }
    if (-not $GameDirectory) { throw 'Steam could not be located automatically. Open Grimmer Workshop, click Game folder, and select the 7 Days To Die installation.' }
    Assert-WorkshopGame $GameDirectory $installed.gameAssemblySha256
    $gameExecutable = Join-Path $GameDirectory '7DaysToDie.exe'
    if (-not (Test-Path -LiteralPath $gameExecutable)) { throw 'Game executable not found. Supply -GameDirectory with your Steam game folder.' }
    if (Get-Process -Name '7DaysToDie' -ErrorAction SilentlyContinue) { throw 'Close the running game before launching Grimmer Workshop.' }
    $null = Write-WorkshopBookPolicy $PSScriptRoot $GameDirectory
    Write-WorkshopSkillScreen $PSScriptRoot $GameDirectory
    Write-WorkshopAttachments $PSScriptRoot $GameDirectory
    Write-WorkshopConstruction $PSScriptRoot $GameDirectory
    Write-WorkshopArsenalDisplayEntries $PSScriptRoot $GameDirectory
    Write-WorkshopUtilities $PSScriptRoot
    Expand-WorkshopVehicleWorkbenchAssets $PSScriptRoot
    Write-WorkshopVehicleWorkbench $PSScriptRoot $GameDirectory
    Assert-WorkshopGeneratedConfig $PSScriptRoot
    $profile = Join-Path $PSScriptRoot 'Profile'
    $logPath = Join-Path $profile 'output_log.txt'
    $arguments = @('-noeac', ('-userdatafolder="' + $profile + '"'), '-logfile', ('"' + $logPath + '"'))
    Start-Process -FilePath $gameExecutable -WorkingDirectory $GameDirectory -ArgumentList $arguments
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host 'Press Enter to close'
    exit 1
}
