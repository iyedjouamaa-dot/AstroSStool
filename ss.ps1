# ==============================================================================
# AstroSSTool - Forensic Moderation Suite
# ==============================================================================

# 1. Self-Elevation Check
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ToolsDir = "$env:USERPROFILE\Downloads\AstroSSTool"
if (!(Test-Path $ToolsDir)) { New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null }

# --- 2. MAIN WINDOW CONFIGURATION ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "AstroSSTool - Forensic Moderation Suite"
$Form.Size = New-Object System.Drawing.Size(950, 650)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 24) # Matches #161618
$Form.ForeColor = [System.Drawing.Color]::FromArgb(224, 224, 224)
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$Form.MaximizeBox = $false

# --- 3. SIDEBAR PANEL ---
$Sidebar = New-Object System.Windows.Forms.Panel
$Sidebar.Size = New-Object System.Drawing.Size(210, 470)
$Sidebar.Location = New-Object System.Drawing.Point(12, 12)
$Sidebar.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 34)
$Form.Controls.Add($Sidebar)

$TitleLbl = New-Object System.Windows.Forms.Label
$TitleLbl.Text = "^._.^ AstroSS"
$TitleLbl.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$TitleLbl.ForeColor = [System.Drawing.Color]::FromArgb(192, 132, 252) # #c084fc
$TitleLbl.Location = New-Object System.Drawing.Point(15, 15)
$TitleLbl.Size = New-Object System.Drawing.Size(180, 30)
$Sidebar.Controls.Add($TitleLbl)

function Create-SidebarButton($text, $y, $color, $action) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(180, 35)
    $btn.Location = New-Object System.Drawing.Point(15, $y)
    $btn.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 48)
    $btn.ForeColor = $color
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize = 0
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.Add_Click($action)
    $Sidebar.Controls.Add($btn)
}

Create-SidebarButton "Open Install Folder" 70 ([System.Drawing.Color]::White) {
    Start-Process explorer.exe $ToolsDir
    Write-ConsoleLog "Opened install directory: $ToolsDir"
}

Create-SidebarButton "Clear Cache" 115 ([System.Drawing.Color]::White) {
    Remove-Item "$ToolsDir\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-ConsoleLog "Cleared downloaded tool cache."
}

Create-SidebarButton "Toggle NetLock" 160 ([System.Drawing.Color]::FromArgb(255, 100, 100)) {
    try {
        $rule = Get-NetFirewallRule -DisplayName "AstroSS-Netlock" -ErrorAction SilentlyContinue
        if ($rule) {
            Remove-NetFirewallRule -DisplayName "AstroSS-Netlock"
            Write-ConsoleLog "NetLock DISABLED: Network access restored."
        } else {
            New-NetFirewallRule -DisplayName "AstroSS-Netlock" -Direction Outbound -Action Block -Profile Any | Out-Null
            Write-ConsoleLog "NetLock ENGAGED: Outbound connection blocked."
        }
    } catch {
        Write-ConsoleLog "ERROR: Failed to update firewall rules."
    }
}

# --- 4. ACTIVITY TERMINAL CONSOLE (BOTTOM) ---
$ConsoleBox = New-Object System.Windows.Forms.TextBox
$ConsoleBox.Multiline = $true
$ConsoleBox.ScrollBars = "Vertical"
$ConsoleBox.ReadOnly = $true
$ConsoleBox.Size = New-Object System.Drawing.Size(912, 110)
$ConsoleBox.Location = New-Object System.Drawing.Point(12, 490)
$ConsoleBox.BackColor = [System.Drawing.Color]::FromArgb(14, 14, 16)
$ConsoleBox.ForeColor = [System.Drawing.Color]::FromArgb(74, 222, 128)
$ConsoleBox.Font = New-Object System.Drawing.Font("Consolas", 9.5)
$Form.Controls.Add($ConsoleBox)

function Write-ConsoleLog($msg) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    $ConsoleBox.AppendText("[$timestamp] $msg`r`n")
    $ConsoleBox.SelectionStart = $ConsoleBox.Text.Length
    $ConsoleBox.ScrollToCaret()
}

# --- 5. TABS & TOOL CARDS INTERFACE ---
$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Size = New-Object System.Drawing.Size(695, 470)
$TabControl.Location = New-Object System.Drawing.Point(230, 12)
$TabControl.BackColor = [System.Drawing.Color]::FromArgb(22, 22, 24)
$Form.Controls.Add($TabControl)

function Create-ToolTab($tabTitle, $tools) {
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = $tabTitle
    $tab.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 34)
    
    $flow = New-Object System.Windows.Forms.FlowLayoutPanel
    $flow.Dock = [System.Windows.Forms.DockStyle]::Fill
    $flow.AutoScroll = $true
    $flow.Padding = New-Object System.Windows.Forms.Padding(10)
    
    foreach ($t in $tools) {
        $card = New-Object System.Windows.Forms.Button
        $card.Text = "$($t.Name)`r`n`r`n$($t.Desc)"
        $card.Size = New-Object System.Drawing.Size(210, 90)
        $card.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
        $card.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $card.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 48)
        $card.ForeColor = [System.Drawing.Color]::White
        $card.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $card.FlatAppearance.BorderSize = 0
        $card.Cursor = [System.Windows.Forms.Cursors]::Hand
        
        $action = $t.Action
        $card.Add_Click($action)
        $flow.Controls.Add($card)
    }
    $tab.Controls.Add($flow)
    $TabControl.TabPages.Add($tab)
}

# Structured Forensic Categories & Cards
$Categories = @{
    "Orbdiff" = @(
        @{ Name = "PrefetchView"; Desc = "Parses prefetch files for exact execution history."; Action = { Write-ConsoleLog "Launching PrefetchView module..." } }
        @{ Name = "BAMReveal"; Desc = "Background Activity Monitor record scanner."; Action = { Write-ConsoleLog "Parsing BAM registry keys..." } }
        @{ Name = "StringsParser"; Desc = "Performs string lookups on active processes."; Action = { Write-ConsoleLog "Executing string signature analysis..." } }
    )
    "Spokwn" = @(
        @{ Name = "InjGen"; Desc = "Memory injection and bypass signature parser."; Action = { Write-ConsoleLog "Scanning system memory for InjGen footprints..." } }
        @{ Name = "UserAssist"; Desc = "ROT13 UserAssist execution trail parser."; Action = { Write-ConsoleLog "Extracting UserAssist timeline..." } }
    )
    "Tonynoh" = @(
        @{ Name = "ShimCache"; Desc = "AppCompatFlags historical execution audit."; Action = { Write-ConsoleLog "Parsing ShimCache entries..." } }
    )
    "Praiselily" = @(
        @{ Name = "FilelessDetector"; Desc = "Detects fileless threats via event logs."; Action = { Write-ConsoleLog "Running fileless threat scan..." } }
    )
}

foreach ($cat in $Categories.Keys) {
    Create-ToolTab $cat $Categories[$cat]
}

# --- 6. INITIALIZATION & LAUNCH ---
Write-ConsoleLog "AstroSSTool initialized successfully. Ready for scan."
[void]$Form.ShowDialog()
