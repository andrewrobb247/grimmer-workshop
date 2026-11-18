param([string]$GameDirectory = 'C:\Program Files (x86)\Steam\steamapps\common\7 Days To Die')
$ErrorActionPreference = 'Stop'
try {
    . (Join-Path $PSScriptRoot 'Update-Core.ps1')
    $installed = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Installed-Release.json') -Raw | ConvertFrom-Json
    Assert-WorkshopGame $GameDirectory $installed.gameAssemblySha256
    $gameExecutable = Join-Path $GameDirectory '7DaysToDie.exe'
    if (-not (Test-Path -LiteralPath $gameExecutable)) { throw 'Game executable not found. Supply -GameDirectory with your Steam game folder.' }
    if (Get-Process -Name '7DaysToDie' -ErrorAction SilentlyContinue) { throw 'Close the running game before launching Grimmer Workshop.' }
    $null = Write-WorkshopBookPolicy $PSScriptRoot $GameDirectory
    Write-WorkshopSkillScreen $PSScriptRoot $GameDirectory
    $profile = Join-Path $PSScriptRoot 'Profile'
    $logPath = Join-Path $profile 'output_log.txt'
    $arguments = @('-noeac', ('-userdatafolder="' + $profile + '"'), '-logfile', ('"' + $logPath + '"'))
    Start-Process -FilePath $gameExecutable -WorkingDirectory $GameDirectory -ArgumentList $arguments
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    Read-Host 'Press Enter to close'
    exit 1
}
