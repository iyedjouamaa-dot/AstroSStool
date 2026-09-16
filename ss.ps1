Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Administrator Check
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$WorkDir = "$env:USERPROFILE\Downloads\AstroSSTool"
if (!(Test-Path $WorkDir)) { New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null }

# Form Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "AstroSSTool // Forensic Suite"
$form.Size = New-Object System.Drawing.Size(920, 620)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#09080b")

# Custom TitleBar for Dragging & Close
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size(920, 35)
$titleBar.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0f0d14")
$form.Controls.Add($titleBar)

$dragging = $false
$offset = $null
$titleBar.Add_MouseDown({ if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) { $global:dragging = $true; $global:offset = $_.Location } })
$titleBar.Add_MouseUp({ $global:dragging = $false })
$titleBar.Add_MouseMove({ if ($global:dragging) { $form.Location = New-Object System.Drawing.Point(($form.Location.X + $_.X - $global:offset.X), ($form.Location.Y + $_.Y - $global:offset.Y)) } })

# Title Text
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "✦  ASTROSSTOOL // FORENSIC SUITE"
$titleLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#a855f7")
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(12, 10)
$titleLabel.AutoSize = $true
$titleBar.Controls.Add($titleLabel)

# Close Button
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "✕"
$btnClose.Size = New-Object System.Drawing.Size(35, 25)
$btnClose.Location = New-Object System.Drawing.Size(875, 5)
$btnClose.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClose.ForeColor = [System.Drawing.Color]::Gray
$btnClose.FlatAppearance.BorderSize = 0
$btnClose.Add_Click({ $form.Close() })
$titleBar.Controls.Add($btnClose)

# Sidebar Panel
$sidebar = New-Object System.Windows.Forms.Panel
$sidebar.Size = New-Object System.Drawing.Size(220, 475)
$sidebar.Location = New-Object System.Drawing.Point(0, 35)
$sidebar.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0f0d14")
$form.Controls.Add($sidebar)

# Console Output Box
$console = New-Object System.Windows.Forms.TextBox
$console.Multiline = $true
$console.ReadOnly = $true
$console.Size = New-Object System.Drawing.Size(920, 110)
$console.Location = New-Object System.Drawing.Point(0, 510)
$console.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#070609")
$console.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#4ade80")
$console.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($console)

function Write-Log($msg) {
    $time = Get-Date -Format "HH:mm:ss"
    $console.AppendText("[$time] $msg`r`n")
}

# Action Buttons
$btnFolder = New-Object System.Windows.Forms.Button
$btnFolder.Text = "Open Folder"
$btnFolder.Size = New-Object System.Drawing.Size(196, 36)
$btnFolder.Location = New-Object System.Drawing.Point(12, 12)
$btnFolder.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnFolder.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#d8b4fe")
$btnFolder.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#121017")
$btnFolder.FlatAppearance.BorderColor = [System.Drawing.ColorTranslator]::FromHtml("#1f1b29")
$btnFolder.Add_Click({
    Start-Process explorer.exe $WorkDir
    Write-Log "Opened directory: $WorkDir"
})
$sidebar.Controls.Add($btnFolder)

Write-Log "AstroSSTool initialized successfully. Ready."
[void]$form.ShowDialog()
