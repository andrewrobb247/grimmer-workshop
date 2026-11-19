param([switch]$UpdateOnly, [switch]$RollbackOnly)
$ErrorActionPreference = 'Stop'
try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    . (Join-Path $PSScriptRoot 'Update-Core.ps1')
    $script:manifest = $null
    $script:gameDirectory = 'C:\Program Files (x86)\Steam\steamapps\common\7 Days To Die'
    $preferences = Join-Path $PSScriptRoot 'UpdaterSettings.json'
    if (Test-Path -LiteralPath $preferences) {
        $saved = Get-Content -LiteralPath $preferences -Raw | ConvertFrom-Json
        if ($saved.PSObject.Properties.Name -contains 'gameDirectory') { $script:gameDirectory = $saved.gameDirectory }
    }
    $form = New-Object Windows.Forms.Form
    $form.Text = 'Grimmer Workshop'; $form.Size = New-Object Drawing.Size(700,570)
    $form.StartPosition = 'CenterScreen'; $form.MinimumSize = $form.Size
    $form.Font = New-Object Drawing.Font('Segoe UI',10)
    $title = New-Object Windows.Forms.Label
    $title.Text = 'GRIMMER WORKSHOP'; $title.Font = New-Object Drawing.Font('Segoe UI',18,[Drawing.FontStyle]::Bold)
    $title.SetBounds(24,18,620,40); $form.Controls.Add($title)
    $version = New-Object Windows.Forms.Label
    $version.SetBounds(26,65,620,26); $form.Controls.Add($version)
    function Show-WorkshopVersion {
        $installed = Join-Path $PSScriptRoot 'Installed-Release.json'
        $version.Text = if (Test-Path -LiteralPath $installed) { 'Installed: ' + (Get-Content -LiteralPath $installed -Raw | ConvertFrom-Json).version + ' | Solo | 7D2D V3.4 b10' } else { 'Workshop | Solo | 7D2D V3.4 b10' }
    }
    Show-WorkshopVersion
    $channelLabel = New-Object Windows.Forms.Label
    $channelLabel.Text = 'Update channel'; $channelLabel.SetBounds(26,105,120,26); $form.Controls.Add($channelLabel)
    $channel = New-Object Windows.Forms.ComboBox
    $channel.DropDownStyle = 'DropDownList'; $channel.SetBounds(150,101,145,30)
    $channel.Items.AddRange(@('stable','testing')); $channel.SelectedItem = Get-WorkshopChannel $PSScriptRoot; $form.Controls.Add($channel)
    $check = New-Object Windows.Forms.Button
    $check.Text = 'Check for updates'; $check.SetBounds(310,100,165,34); $form.Controls.Add($check)
    $install = New-Object Windows.Forms.Button
    $install.Text = 'Install update'; $install.SetBounds(490,100,165,34); $install.Enabled = $false; $form.Controls.Add($install)
    $notes = New-Object Windows.Forms.TextBox
    $notes.Multiline = $true; $notes.ReadOnly = $true; $notes.ScrollBars = 'Vertical'; $notes.SetBounds(26,150,629,202)
    $notes.Text = 'Your worlds and personal settings stay in this Workshop folder. Stable is recommended for ordinary play. Testing contains changes still being checked.'
    $form.Controls.Add($notes)
    $status = New-Object Windows.Forms.Label
    $status.SetBounds(26,365,630,45); $status.Text = 'Ready. You can play while offline.'; $form.Controls.Add($status)
    $play = New-Object Windows.Forms.Button
    $play.Text = 'Play Workshop'; $play.SetBounds(26,419,165,38); $form.Controls.Add($play)
    $display = New-Object Windows.Forms.Button
    $display.Text = 'Display settings'; $display.SetBounds(205,419,145,38); $form.Controls.Add($display)
    $rollback = New-Object Windows.Forms.Button
    $rollback.Text = 'Roll back update'; $rollback.SetBounds(365,419,145,38); $form.Controls.Add($rollback)
    $gameFolder = New-Object Windows.Forms.Button
    $gameFolder.Text = 'Game folder'; $gameFolder.SetBounds(525,419,130,38); $form.Controls.Add($gameFolder)
    $gameplay = New-Object Windows.Forms.Button
    $gameplay.Text = 'Gameplay settings / books'; $gameplay.SetBounds(26,470,270,36); $form.Controls.Add($gameplay)
    $packs = New-Object Windows.Forms.Button
    $packs.Text = 'Optional packs / versions'; $packs.SetBounds(310,470,345,36); $form.Controls.Add($packs)
    $packs.Add_Click({
        try { Show-WorkshopPacks $PSScriptRoot }
        catch { [Windows.Forms.MessageBox]::Show($_.Exception.Message,'Workshop optional packs') | Out-Null }
    })
    $gameplay.Add_Click({
        try {
            $installed = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Installed-Release.json') -Raw | ConvertFrom-Json
            Assert-WorkshopGame $script:gameDirectory $installed.gameAssemblySha256
            Show-WorkshopGameplaySettings $PSScriptRoot $script:gameDirectory
        } catch { [Windows.Forms.MessageBox]::Show($_.Exception.Message,'Workshop gameplay settings') | Out-Null }
    })
    function Save-WorkshopPreferences {
        @{channel=[string]$channel.SelectedItem; gameDirectory=$script:gameDirectory} | ConvertTo-Json | Set-Content -LiteralPath $preferences -Encoding UTF8
    }
    function Check-WorkshopUpdate {
        $install.Enabled = $false; $script:manifest = $null; $status.Text = 'Checking for updates...'; $form.Refresh()
        try {
            Save-WorkshopPreferences
            $script:manifest = Get-WorkshopManifest ([string]$channel.SelectedItem)
            $plan = @(Get-WorkshopPlan $PSScriptRoot $script:manifest)
            $notes.Text = "Workshop $($script:manifest.version) - $($channel.SelectedItem)`r`n`r`n$($script:manifest.notes)"
            $install.Enabled = $plan.Count -gt 0
            $status.Text = if ($plan.Count) { "$($plan.Count) changed or missing files. Review the notes, then click Install update." } else { 'Your Workshop files match this channel.' }
        } catch { $status.Text = 'Update check unavailable. You can still play the installed version.'; $notes.Text = $_.Exception.Message }
    }
    $check.Add_Click({ Check-WorkshopUpdate })
    $channel.Add_SelectedIndexChanged({ $install.Enabled = $false; $script:manifest = $null; Save-WorkshopPreferences; $status.Text = 'Channel changed. Click Check for updates.' })
    $install.Add_Click({
        $install.Enabled = $false; $status.Text = 'Verifying and installing files...'; $form.Refresh()
        try {
            $status.Text = Install-WorkshopRelease $PSScriptRoot $script:manifest $script:gameDirectory
            Show-WorkshopVersion
            $notes.Text += "`r`n`r`nClose and reopen the launcher to use any updated launcher controls."
        } catch { $status.Text = 'Update not installed.'; [Windows.Forms.MessageBox]::Show($_.Exception.Message,'Workshop update') | Out-Null }
    })
    $rollback.Add_Click({
        try { $status.Text = Undo-WorkshopRelease $PSScriptRoot; Show-WorkshopVersion; $install.Enabled = $false }
        catch { [Windows.Forms.MessageBox]::Show($_.Exception.Message,'Workshop rollback') | Out-Null }
    })
    $gameFolder.Add_Click({
        $picker = New-Object Windows.Forms.FolderBrowserDialog
        $picker.Description = 'Select your Steam 7 Days To Die folder'
        if ($picker.ShowDialog() -eq 'OK') { $script:gameDirectory = $picker.SelectedPath; Save-WorkshopPreferences; $status.Text = 'Game folder saved.' }
        $picker.Dispose()
    })
    $display.Add_Click({ Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',('"' + (Join-Path $PSScriptRoot 'Profile\Mods\ZZZ_GrimmerHUD\Configure.ps1') + '"')) })
    $play.Add_Click({
        try {
            Assert-WorkshopClosed
            $installed = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Installed-Release.json') -Raw | ConvertFrom-Json
            Assert-WorkshopGame $script:gameDirectory $installed.gameAssemblySha256
            & (Join-Path $PSScriptRoot 'Launch-Workshop.ps1') -GameDirectory $script:gameDirectory
        } catch { [Windows.Forms.MessageBox]::Show($_.Exception.Message,'Workshop launch') | Out-Null }
    })
    $form.Add_Shown({ if ($RollbackOnly) { $rollback.PerformClick() } else { Check-WorkshopUpdate } })
    [void]$form.ShowDialog()
} catch {
    Add-Type -AssemblyName System.Windows.Forms
    [Windows.Forms.MessageBox]::Show($_.Exception.Message,'Grimmer Workshop launcher') | Out-Null
    exit 1
}
