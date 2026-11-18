Set-StrictMode -Version 2

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
    $dialog.Text = 'Workshop gameplay settings'; $dialog.Size = New-Object Drawing.Size(720,650)
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
    $save = New-Object Windows.Forms.Button; $save.Text = 'Save'; $save.SetBounds(450,565,105,34); $dialog.Controls.Add($save)
    $cancel = New-Object Windows.Forms.Button; $cancel.Text = 'Cancel'; $cancel.SetBounds(575,565,105,34); $cancel.DialogResult = 'Cancel'; $dialog.Controls.Add($cancel)
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


