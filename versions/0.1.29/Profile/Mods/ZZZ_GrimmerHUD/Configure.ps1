param([switch]$GenerateOnly, [switch]$PreviewTest)
$ErrorActionPreference = 'Stop'
$settingsPath = Join-Path $PSScriptRoot 'Settings.json'
$outputPath = Join-Path $PSScriptRoot 'Config\XUi_InGame\windows.xml'
$settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json

function Write-UiPatch($values) {
    $width = [int]$values.BarWidth
    $height = [int]$values.BarHeight
    $nameSize = [int]$values.NameSize
    $healthSize = [int]$values.HealthSize
    $offset = [int]$values.VerticalOffset
    if ($width -lt 140 -or $width -gt 700 -or $height -lt 12 -or $height -gt 60 -or
        $nameSize -lt 10 -or $nameSize -gt 40 -or $healthSize -lt 10 -or $healthSize -gt 40 -or
        $offset -lt -500 -or $offset -gt -20) {
        throw 'A setting is outside its supported range.'
    }
    $left = -[int]($width / 2)
    $nameTop = $nameSize + 6
    $healthTop = [Math]::Max(0, [int](($height - $healthSize) / 2))
    $nameVisible = ([bool]$values.ShowNames).ToString().ToLowerInvariant()
    $healthVisible = ([bool]$values.ShowHealth).ToString().ToLowerInvariant()
    # The rect selector intentionally limits this patch to regular enemy displays.
    $target = "/windows/window[@name='windowTargetBar']/rect[@visible='{isnotboss}']"
    $xml = @"
<?xml version="1.0" encoding="UTF-8"?>
<configs>
  <set xpath="/windows/window[@name='windowTargetBar']/@visibility">always</set>
  <set xpath="$target/@width">$width</set>
  <set xpath="$target/@height">$height</set>
  <set xpath="$target/@pos">$left,$offset</set>
  <set xpath="$target/sprite/@width">$width</set>
  <remove xpath="$target/label[@name='TextContent']" />
  <append xpath="$target">
    <label name="grimmerEnemyName" depth="3" pos="0,$nameTop" width="$width" height="$nameTop" font_size="$nameSize" color="[white]" justify="center" pivot="topleft" text="{name}" visible="$nameVisible" />
    <label name="grimmerEnemyHealth" depth="3" pos="0,-$healthTop" width="$width" height="$height" font_size="$healthSize" color="[white]" justify="center" pivot="topleft" text="{currentwithmax}" visible="$healthVisible" />
  </append>
</configs>
"@
    [xml]$validatedXml = $xml
    $outputDirectory = Split-Path $outputPath
    [IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
    $temporaryPath = "$outputPath.tmp"
    [IO.File]::WriteAllText($temporaryPath, $xml, [Text.UTF8Encoding]::new($false))
    Move-Item -LiteralPath $temporaryPath -Destination $outputPath -Force
    [IO.File]::WriteAllText($settingsPath, ($values | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
}

if ($GenerateOnly) {
    Write-UiPatch $settings
    return
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
$form = New-Object Windows.Forms.Form
$form.Text = 'Grimmer Workshop - Display Preview'
$form.ClientSize = New-Object Drawing.Size(1200, 550)
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object Drawing.Font('Segoe UI', 10)
$inputs = @{}
$row = 16
foreach ($definition in @(
    @('BarWidth', 'Health bar width', 140, 700),
    @('BarHeight', 'Health bar height', 12, 60),
    @('NameSize', 'Zombie name size', 10, 40),
    @('HealthSize', 'Health number size', 10, 40),
    @('VerticalOffset', 'Vertical position', -500, -20)
)) {
    $label = New-Object Windows.Forms.Label
    $label.Text = $definition[1]
    $label.Location = New-Object Drawing.Point(18, $row)
    $label.Size = New-Object Drawing.Size(245, 28)
    $number = New-Object Windows.Forms.NumericUpDown
    $number.Minimum = $definition[2]
    $number.Maximum = $definition[3]
    $number.Value = $settings.($definition[0])
    $number.Location = New-Object Drawing.Point(285, $row)
    $number.Size = New-Object Drawing.Size(145, 28)
    $inputs[$definition[0]] = $number
    $form.Controls.AddRange(@($label, $number))
    $row += 40
}
foreach ($definition in @(
    @('ShowNames', 'Show zombie names'),
    @('ShowHealth', 'Show health numbers')
)) {
    $checkbox = New-Object Windows.Forms.CheckBox
    $checkbox.Text = $definition[1]
    $checkbox.Checked = $settings.($definition[0])
    $checkbox.Location = New-Object Drawing.Point(18, $row)
    $checkbox.Size = New-Object Drawing.Size(415, 29)
    $inputs[$definition[0]] = $checkbox
    $form.Controls.Add($checkbox)
    $row += 34
}
$note = New-Object Windows.Forms.Label
$note.Text = "Changes apply after restarting the game.`r`nDisplay changes apply on the next game start."
$note.Location = New-Object Drawing.Point(18, 330)
$note.Size = New-Object Drawing.Size(415, 48)
$form.Controls.Add($note)
$status = New-Object Windows.Forms.Label
$status.Location = New-Object Drawing.Point(18, 418)
$status.Size = New-Object Drawing.Size(415, 40)
$form.Controls.Add($status)
$save = New-Object Windows.Forms.Button
$save.Text = 'Save settings'
$save.Location = New-Object Drawing.Point(285, 382)
$save.Size = New-Object Drawing.Size(145, 32)
$save.Add_Click({
    try {
        foreach ($key in $inputs.Keys) {
            $control = $inputs[$key]
            if ($control -is [Windows.Forms.CheckBox]) {
                $settings.$key = $control.Checked
            } else {
                $settings.$key = [int]$control.Value
            }
        }
        Write-UiPatch $settings
        $status.Text = 'Saved. Restart Grimmer Workshop to apply.'
    } catch {
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Could not save settings') | Out-Null
    }
})
$form.Controls.Add($save)

$previewTitle = New-Object Windows.Forms.Label
$previewTitle.Text = 'Live preview'
$previewTitle.Location = New-Object Drawing.Point(468, 16)
$previewTitle.Size = New-Object Drawing.Size(700, 26)
$form.Controls.Add($previewTitle)
$preview = New-Object Windows.Forms.Panel
$preview.Location = New-Object Drawing.Point(468, 50)
$preview.Size = New-Object Drawing.Size(714, 450)
$preview.BackColor = [Drawing.Color]::FromArgb(35, 39, 43)
$preview.Add_Paint({
    param($sender, $eventArgs)
    $graphics = $eventArgs.Graphics
    $graphics.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $barWidth = [int]$inputs.BarWidth.Value
    $barHeight = [int]$inputs.BarHeight.Value
    $barLeft = [single](($sender.ClientSize.Width - $barWidth) / 2)
    $barTop = [single](-[int]$inputs.VerticalOffset.Value)
    $border = New-Object Drawing.Pen([Drawing.Color]::FromArgb(150, 150, 150), 1)
    $emptyBrush = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(70, 21, 23))
    $fillBrush = New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(185, 35, 35))
    $nameFont = New-Object Drawing.Font('Arial', [single]$inputs.NameSize.Value, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
    $healthFont = New-Object Drawing.Font('Arial', [single]$inputs.HealthSize.Value, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
    $format = New-Object Drawing.StringFormat
    $format.Alignment = [Drawing.StringAlignment]::Center
    $format.LineAlignment = [Drawing.StringAlignment]::Center
    try {
        $graphics.FillRectangle($emptyBrush, $barLeft, $barTop, [single]$barWidth, [single]$barHeight)
        $graphics.FillRectangle($fillBrush, $barLeft, $barTop, [single]($barWidth * 0.7), [single]$barHeight)
        $graphics.DrawRectangle($border, $barLeft, $barTop, [single]$barWidth, [single]$barHeight)
        if ($inputs.ShowHealth.Checked) {
            $healthRect = New-Object Drawing.RectangleF($barLeft, $barTop, $barWidth, $barHeight)
            $graphics.DrawString('350 / 500', $healthFont, [Drawing.Brushes]::White, $healthRect, $format)
        }
        if ($inputs.ShowNames.Checked) {
            $nameHeight = [single]([int]$inputs.NameSize.Value + 6)
            $nameRect = New-Object Drawing.RectangleF($barLeft, ($barTop - $nameHeight), $barWidth, $nameHeight)
            $graphics.DrawString($sampleName.Text, $nameFont, [Drawing.Brushes]::White, $nameRect, $format)
        }
    } finally {
        $border.Dispose()
        $emptyBrush.Dispose()
        $fillBrush.Dispose()
        $nameFont.Dispose()
        $healthFont.Dispose()
        $format.Dispose()
    }
})
$form.Controls.Add($preview)
$sampleLabel = New-Object Windows.Forms.Label
$sampleLabel.Text = 'Preview zombie name'
$sampleLabel.Location = New-Object Drawing.Point(18, 466)
$sampleLabel.Size = New-Object Drawing.Size(250, 24)
$form.Controls.Add($sampleLabel)
$sampleName = New-Object Windows.Forms.TextBox
$sampleName.Text = 'Radiated Ferocious Zombie Destroyer'
$sampleName.Location = New-Object Drawing.Point(18, 493)
$sampleName.Size = New-Object Drawing.Size(412, 28)
$sampleName.Add_TextChanged({ $preview.Invalidate() })
$form.Controls.Add($sampleName)
$previewNote = New-Object Windows.Forms.Label
$previewNote.Text = 'Approximate UI pixels. In-game font, resolution and UI scaling affect the final appearance.'
$previewNote.Location = New-Object Drawing.Point(468, 510)
$previewNote.Size = New-Object Drawing.Size(714, 35)
$form.Controls.Add($previewNote)
foreach ($control in $inputs.Values) {
    if ($control -is [Windows.Forms.NumericUpDown]) {
        $control.Add_ValueChanged({ $preview.Invalidate() })
    } else {
        $control.Add_CheckedChanged({ $preview.Invalidate() })
    }
}
if ($PreviewTest) {
    $form.StartPosition = 'Manual'
    $form.Location = New-Object Drawing.Point(-3000, -3000)
    $form.ShowInTaskbar = $false
    $form.Show()
    [Windows.Forms.Application]::DoEvents()
    $inputs.ShowNames.Checked = $true
    $bitmap = New-Object Drawing.Bitmap($form.Width, $form.Height)
    $form.DrawToBitmap($bitmap, (New-Object Drawing.Rectangle(0, 0, $bitmap.Width, $bitmap.Height)))
    $bitmap.Save((Join-Path $PSScriptRoot '..\preview-test.png'), [Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    $inputs.BarWidth.Value = 500
    $inputs.BarHeight.Value = 42
    $inputs.NameSize.Value = 26
    $inputs.HealthSize.Value = 24
    [Windows.Forms.Application]::DoEvents()
    $bitmap = New-Object Drawing.Bitmap($form.Width, $form.Height)
    $form.DrawToBitmap($bitmap, (New-Object Drawing.Rectangle(0, 0, $bitmap.Width, $bitmap.Height)))
    $bitmap.Save((Join-Path $PSScriptRoot '..\preview-large-test.png'), [Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    $form.Dispose()
    return
}
[void]$form.ShowDialog()
