Set-StrictMode -Version 2

function Get-WorkshopHash([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
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
    $modAllowed = $Relative -match '^Profile/Mods/(GrimmerWorkshop|ZZZ_GrimmerHUD)/(ModInfo\.xml|GrimmerWorkshop\.dll|PracticeRules\.xml|CRAFTING-ROUTES\.csv|WorkshopSettings\.xml|Settings\.json|Configure\.ps1|Config/(items\.xml|recipes\.xml|XUi_InGame/windows\.xml))$'
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

