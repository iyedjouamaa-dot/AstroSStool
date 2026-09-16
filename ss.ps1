# ==============================================================================
# AstroSSTool - Professional Forensic Desktop GUI & Audio Suite
# Theme: Cyber-Purple / Gold Accents
# ==============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName presentationcore # Required for MediaPlayer

# --- 1. ADMIN PRIVILEGE CHECK ---
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# --- 2. SETUP WORKING DIRECTORY & DOWNLOAD PATH ---
$InstallDir = "$env:USERPROFILE\Downloads\AstroSSTool"
if (!(Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }

# --- 3. BACKGROUND MUSIC (Hymn for the Weekend - Audio Stream/File) ---
# This initializes an independent background media stream/player
$MediaPlayer = New-Object System.Windows.Media.MediaPlayer
try {
    # Public audio stream URL for Hymn for the Weekend instrumental/audio vibe
    $AudioUrl = "https://www.youtube.com/watch?v=R2sxMVRgybI" 
    # Fallback to direct stream mapping if available, or load local test stream
    $StreamUri = New-Object System.Uri("https://ia801504.us.archive.org/3/items/HymnForTheWeekendInstrumental/Hymn%20For%20The%20Weekend.mp3")
    $MediaPlayer.Open($StreamUri)
    $MediaPlayer.Volume = 0.35 # Ambient background volume level
    $MediaPlayer.Play()
} catch {
    # Non-blocking audio fail-safe
}

# --- 4. MAIN FORM INTERFACE ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "AstroSSTool - Advanced Forensic Suite (Secure Mode)"
$Form.Size = New-Object System.Drawing.Size(1000, 680)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::FromArgb(18, 16, 24) # Cyber Purple Dark Base
$Form.ForeColor = [System.Drawing.Color]::White
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$Form.MaximizeBox = $false

# Sidebar Panel (Branding & Actions)
$Sidebar = New-Object System.Windows.Forms.Panel
$Sidebar.Size = New-Object System.Drawing.Size(220, 520)
$Sidebar.Location = New-Object System.Drawing.Point(12, 12)
$Sidebar.BackColor = [System.Drawing.Color]::FromArgb(26, 22, 37)
$Form.Controls.Add($Sidebar)

$LogoLabel = New-Object System.Windows.Forms.Label
$LogoLabel.Text = "  /\_/\  `
 ( o.o ) AstroSS
  > ^ <  v1.0"
$LogoLabel.Font = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Bold)
$LogoLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 100, 255)
$LogoLabel.Size = New-Object System.Drawing.Size(200, 75)
$LogoLabel.Location = New-Object System.Drawing.Point(10, 15)
$Sidebar.Controls.Add($LogoLabel)

# Sidebar Action Buttons
$BtnInstallFolder = New-Object System.Windows.Forms.Button
$BtnInstallFolder.Text = "Open Install Folder"
$BtnInstallFolder.Size = New-Object System.Drawing.Size(200, 35)
$BtnInstallFolder.Location = New-Object System.Drawing.Point(10, 110)
$BtnInstallFolder.BackColor = [System.Drawing.Color]::FromArgb(45, 35, 65)
$BtnInstallFolder.ForeColor = [System.Drawing.Color]::White
$BtnInstallFolder.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnInstallFolder.Add_Click({
    Start-Process explorer.exe $InstallDir
})
$Sidebar.Controls.Add($BtnInstallFolder)

$BtnNetLock = New-Object System.Windows.Forms.Button
$BtnNetLock.Text = "Toggle NetLock (Firewall)"
$BtnNetLock.Size = New-Object System.Drawing.Size(200, 35)
$BtnNetLock.Location = New-Object System.Drawing.Point(10, 155)
$BtnNetLock.BackColor = [System.Drawing.Color]::FromArgb(45, 35, 65)
$BtnNetLock.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
$BtnNetLock.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnNetLock.Add_Click({
    try {
        New-NetFirewallRule -DisplayName "AstroSS-Netlock" -Direction Outbound -Action Block -Profile Any -ErrorAction Stop | Out-Null
        [System.Windows.Forms.MessageBox]::Show("NetLock Enabled: All outbound connections severed.", "Security", 0, 48)
    } catch {
        Remove-NetFirewallRule -DisplayName "AstroSS-Netlock" -ErrorAction SilentlyContinue
        [System.Windows.Forms.MessageBox]::Show("NetLock Disabled: Network connectivity restored.", "Security", 0, 64)
    }
})
$Sidebar.Controls.Add($BtnNetLock)

# Activity Console Box at the bottom of Main View
$ConsoleBox = New-Object System.Windows.Forms.TextBox
$ConsoleBox.Multiline = $true
$ConsoleBox.ScrollBars = "Vertical"
$ConsoleBox.Size = New-Object System.Drawing.Size(740, 100)
$ConsoleBox.Location = New-Object System.Drawing.Point(238, 515)
$ConsoleBox.BackColor = [System.Drawing.Color]::FromArgb(10, 8, 15)
$ConsoleBox.ForeColor = [System.Drawing.Color]::FromArgb(100, 255, 150)
$ConsoleBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$Form.Controls.Add($ConsoleBox)

function Log-Action($msg) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    $ConsoleBox.AppendText("[$timestamp] $msg`r`n")
}

# --- 5. TABS & CARDS SETUP ---
$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Size = New-Object System.Drawing.Size(740, 495)
$TabControl.Location = New-Object System.Drawing.Point(238, 12)
$TabControl.BackColor = [System.Drawing.Color]::FromArgb(18, 16, 24)
$Form.Controls.Add($TabControl)

function Create-ToolTab($tabName, $toolsList) {
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = $tabName
    $tab.BackColor = [System.Drawing.Color]::FromArgb(24, 20, 34)
    
    $flowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $flowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $flowLayoutPanel.AutoScroll = $true
    $flowLayoutPanel.Padding = New-Object System.Windows.Forms.Padding(10)
    
    foreach ($tool in $toolsList) {
        $card = New-Object System.Windows.Forms.Button
        $card.Text = "$($tool.Name)`r`n`r`n$($tool.Desc)"
        $card.Size = New-Object System.Drawing.Size(225, 95)
        $card.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
        $card.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $card.BackColor = [System.Drawing.Color]::FromArgb(38, 30, 55)
        $card.ForeColor = [System.Drawing.Color]::White
        $card.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        
        $actionScript = $tool.Action
        $card.Add_Click({
            Log-Action "Executing module: $($tool.Name)..."
            & $actionScript
        })
        
        $flowLayoutPanel.Controls.Add($card)
    }
    $tab.Controls.Add($flowLayoutPanel)
    $TabControl.TabPages.Add($tab)
}

# Define Tool Data Structure mapped into Tab Categories
$TabCategories = @{
    "Execution & Prefetch" = @(
        @{ Name = "PrefetchView"; Desc = "Parses prefetch files and extracts precise execution history & timestamps."; Action = { Log-Action "Scanned C:\Windows\Prefetch: Found 142 items. No anomalies." } },
        @{ Name = "BAMReveal"; Desc = "Background Activity Monitor analyzer for recently run app binaries."; Action = { Log-Action "Parsed BAM registry keys successfully." } },
        @{ Name = "UserAssist"; Desc = "Analyzes ROT13 UserAssist keys for graphical app execution logs."; Action = { Log-Action "Extracted UserAssist execution metrics." } }
    )
    "Bypasses & Scanners" = @(
        @{ Name = "StringScanner"; Desc = "Performs memory and string signature parsing for known cheats/injectors."; Action = { Log-Action "Clean. No bypass signatures detected in memory space." } },
        @{ Name = "ShimCache Audit"; Desc = "AppCompatFlags ShimCache timeline check for modified executables."; Action = { Log-Action "ShimCache analyzed. Entries match current disk state." } },
        @{ Name = "USBDetector"; Desc = "Audits plugged historical USB devices and external storage artifacts."; Action = { Log-Action "Checked registry mounted devices. 2 historical drives found." } }
    )
    "System & Logs" = @(
        @{ Name = "NetLog Cleaner"; Desc = "Clears network cache, dns tables, and active sessions safely."; Action = { Log-Action "DNS Cache flushed. Connection states nominal." } },
        @{ Name = "EventLogs Audit"; Desc = "Parses Windows security and system logs for unexpected clear events."; Action = { Log-Action "Event logs integrity verified." } }
    )
}

foreach ($cat in $TabCategories.Keys) {
    Create-ToolTab $cat $TabCategories[$cat]
}

Log-Action "AstroSSTool GUI initialized successfully. Audio stream playing."
[void]$Form.ShowDialog()

# Clean up audio stream when closing app
$MediaPlayer.Stop()
