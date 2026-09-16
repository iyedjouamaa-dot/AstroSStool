# ==============================================================================
# AstroSSTool - Dedicated GUI Window Edition
# ==============================================================================

# 1. Self-Elevation Check
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 2. Build the Main Window
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "AstroSSTool"
$Form.Size = New-Object System.Drawing.Size(520, 360)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::FromArgb(18, 16, 22) # Cyber Dark Purple
$Form.ForeColor = [System.Drawing.Color]::White
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$Form.MaximizeBox = $false

# Title Label
$TitleLabel = New-Object System.Windows.Forms.Label
$TitleLabel.Text = "AstroSSTool"
$TitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$TitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 100, 255)
$TitleLabel.AutoSize = $true
$TitleLabel.Location = New-Object System.Drawing.Point(170, 30)
$Form.Controls.Add($TitleLabel)

# Description Label
$DescLabel = New-Object System.Windows.Forms.Label
$DescLabel.Text = "Advanced forensic read-only moderation suite for detecting cheat signatures, execution history, and anti-forensic tampering on Windows."
$DescLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$DescLabel.ForeColor = [System.Drawing.Color]::FromArgb(156, 163, 175)
$DescLabel.Size = New-Object System.Drawing.Size(420, 45)
$DescLabel.Location = New-Object System.Drawing.Point(50, 85)
$Form.Controls.Add($DescLabel)

# GitHub Button
$BtnGitHub = New-Object System.Windows.Forms.Button
$BtnGitHub.Text = "GitHub Repository"
$BtnGitHub.Size = New-Object System.Drawing.Size(160, 40)
$BtnGitHub.Location = New-Object System.Drawing.Point(85, 160)
$BtnGitHub.BackColor = [System.Drawing.Color]::FromArgb(147, 51, 234)
$BtnGitHub.ForeColor = [System.Drawing.Color]::White
$BtnGitHub.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnGitHub.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$BtnGitHub.Add_Click({
    Start-Process "https://github.com/iyedjouamaa-dot/AstroSSTool"
})
$Form.Controls.Add($BtnGitHub)

# Run Scan Button (Local Execution trigger)
$BtnScan = New-Object System.Windows.Forms.Button
$BtnScan.Text = "Run Quick Audit"
$BtnScan.Size = New-Object System.Drawing.Size(160, 40)
$BtnScan.Location = New-Object System.Drawing.Point(265, 160)
$BtnScan.BackColor = [System.Drawing.Color]::FromArgb(55, 40, 80)
$BtnScan.ForeColor = [System.Drawing.Color]::White
$BtnScan.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnScan.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$BtnScan.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Executing Prefetch and Registry forensic checks...", "AstroSS Audit", 0, 64)
})
$Form.Controls.Add($BtnScan)

# 3. Render Window
[void]$Form.ShowDialog()
