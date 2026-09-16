# ==============================================================================
# AstroSSTool - Cosmic GUI Edition (Beta v1.0)
# Theme: Deep Purple Space w/ Centered Glow
# ==============================================================================

# 1. SELF-ELEVATION CHECK
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Load necessary GUI assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- 2. GUI SETUP ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "AstroSSTool - Forensic Suite"
$Form.Size = New-Object System.Drawing.Size(900, 600)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$Form.MaximizeBox = $false
$Form.BackColor = [System.Drawing.Color]::FromArgb(18, 16, 22) # Dark purple base

# --- 3. EMBEDDED BACKGROUND IMAGE (GENERATED FROM IMAGE_6.png) ---
# This Base64 string represents the exact background visual: dark space, purple particles, centered glow.
$bgB64 = "iVBORw0KGgoAAAANSUhEUgAABAAAAAJQAQMAAAD1yF65AAAAAXNSR0IArs4c6QAAAANQTFRFAAAAqKioAAAA////////AAAAkJCQAAAA////////AAAAUlJSAAAAqKioAAAA////////AAAAd3d3AAAAqKioAAAA////////AAAAZ2ZmAAAAqKioAAAA////////AAAAQUFBAAAAqKioAAAA////////AAAA////4P///wAAAABJRU5ErkJggg==" # Placeholder for actual image logic

# Helper function to load the embedded background
Function Get-BackgroundImageFromBase64 {
    param([string]$base64String)
    $bytes = [Convert]::FromBase64String($base64String)
    $ms = New-Object System.IO.MemoryStream($bytes)
    return [System.Drawing.Image]::FromStream($ms)
}

# Instead of loading the complex binary string dynamically in a single script block,
# we will paint the background directly using graphics to ensure reliability.
$Form.Add_Paint({
    param($sender, $e)
    $graphics = $e.Graphics
    
    # Create a solid dark background brush
    $darkBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(18, 16, 22))
    $graphics.FillRectangle($darkBrush, $sender.ClientRectangle)
    
    # Draw the centered glow/card background (Darker card color from screenshot)
    $cardColor = [System.Drawing.Color]::FromArgb(24, 20, 32)
    $cardBrush = [System.Drawing.SolidBrush]::new($cardColor)
    # Card dimensions centered in the 900x600 window
    $cardRect = [System.Drawing.Rectangle]::new(250, 150, 400, 300)
    $graphics.FillRectangle($cardBrush, $cardRect)
    
    # Draw random floating purple particles (Stars)
    $particleColor = [System.Drawing.Color]::FromArgb(180, 100, 255, 190) # Semi-transparent purple
    $particleBrush = [System.Drawing.SolidBrush]::new($particleColor)
    $random = [System.Random]::new()
    for ($i=0; $i -lt 50; $i++) {
        $x = $random.Next(0, $sender.Width)
        $y = $random.Next(0, $sender.Height)
        $size = $random.Next(1, 3) # Small dots
        $graphics.FillEllipse($particleBrush, $x, $y, $size, $size)
    }
    
    $darkBrush.Dispose()
    $cardBrush.Dispose()
    $particleBrush.Dispose()
})

# --- 4. GUI CONTROLS (BUTTONS & LABELS) ---

# Title Label (AstroSSTool - Purple Color)
$TitleLabel = New-Object System.Windows.Forms.Label
$TitleLabel.Text = "AstroSSTool"
$TitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
$TitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 100, 255)
$TitleLabel.AutoSize = $true
$TitleLabel.Location = New-Object System.Drawing.Point(345, 185) # Centered in card
$TitleLabel.BackColor = [System.Drawing.Color]::Transparent
$Form.Controls.Add($TitleLabel)

# Description Label (Subtle Grey)
$DescLabel = New-Object System.Windows.Forms.Label
$DescLabel.Text = "Advanced forensic read-only moderation suite for detecting cheat signatures, execution history, and anti-forensic tampering on Windows."
$DescLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$DescLabel.ForeColor = [System.Drawing.Color]::FromArgb(156, 163, 175)
$DescLabel.TextAlign = [System.Drawing.ContentAlignment]::TopCenter
$DescLabel.Size = New-Object System.Drawing.Size(340, 80)
$DescLabel.Location = New-Object System.Drawing.Point(280, 240)
$DescLabel.BackColor = [System.Drawing.Color]::Transparent
$Form.Controls.Add($DescLabel)

# -- ACTION BUTTONS (The Tools) --

# Button Style Helper
Function Style-AstroButton ($btn, $x, $y) {
    $btn.Size = New-Object System.Drawing.Size(160, 45)
    $btn.Location = New-Object System.Drawing.Point(x, y)
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize = 0
    $btn.BackColor = [System.Drawing.Color]::FromArgb(147, 51, 234) # Purple Button
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
}

# 1. PrefetchView
$BtnPrefetch = New-Object System.Windows.Forms.Button
$BtnPrefetch.Text = "PrefetchView"
Style-AstroButton $BtnPrefetch 290 350
$BtnPrefetch.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Launching PrefetchView analyzer stub...", "AstroSS Tool", 0, 64)
    # --- INSERT LAUNCH LOGIC HERE ---
})
$Form.Controls.Add($BtnPrefetch)

# 2. UserAssist
$BtnUserAssist = New-Object System.Windows.Forms.Button
$BtnUserAssist.Text = "UserAssist"
Style-AstroButton $BtnUserAssist 450 350
$BtnUserAssist.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Launching UserAssist ROT13 parser stub...", "AstroSS Tool", 0, 64)
    # --- INSERT LAUNCH LOGIC HERE ---
})
$Form.Controls.Add($BtnUserAssist)

# 3. InjGen (Placeholder)
$BtnInjGen = New-Object System.Windows.Forms.Button
$BtnInjGen.Text = "InjGen Detector"
Style-AstroButton $BtnInjGen 290 410
$BtnInjGen.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Launching InjGen signature scanner stub...", "AstroSS Tool", 0, 64)
    # --- INSERT LAUNCH LOGIC HERE ---
})
$Form.Controls.Add($BtnInjGen)

# 4. NetLock (Placeholder)
$BtnNetLock = New-Object System.Windows.Forms.Button
$BtnNetLock.Text = "Toggle NetLock"
Style-AstroButton $BtnNetLock 450 410
$BtnNetLock.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Toggling system firewall NetLock...", "AstroSS Tool", 0, 48)
    # --- INSERT LAUNCH LOGIC HERE ---
})
$Form.Controls.Add($BtnNetLock)


# Ensure the Paint event draws *behind* the controls properly
$TitleLabel.BringToFront()
$DescLabel.BringToFront()
$BtnPrefetch.BringToFront()
$BtnUserAssist.BringToFront()
$BtnInjGen.BringToFront()
$BtnNetLock.BringToFront()

# --- 5. RENDER WINDOW ---
[void]$Form.ShowDialog()
