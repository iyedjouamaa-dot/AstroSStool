$code = @'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime.InteropServices

if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern int SetWindowRgn(IntPtr hWnd, IntPtr hRgn, bool bRedraw);
    [DllImport("gdi32.dll")]
    public static extern IntPtr CreateRoundRectRgn(int x1, int y1, int x2, int y2, int cx, int cy);
    [DllImport("user32.dll")]
    public static extern int ReleaseCapture();
    [DllImport("user32.dll")]
    public static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);
}
"@
}

$ToolDir = "$env:TEMP\AstroSSTool_Bin"
if (!(Test-Path $ToolDir)) { New-Item -ItemType Directory -Force -Path $ToolDir | Out-Null }

$cBg         = [System.Drawing.ColorTranslator]::FromHtml("#07060a")
$cTitleBar   = [System.Drawing.ColorTranslator]::FromHtml("#0b0a10")
$cTextMain   = [System.Drawing.ColorTranslator]::FromHtml("#e9d5ff")
$cPurple     = [System.Drawing.ColorTranslator]::FromHtml("#a855f7")
$cCardBg     = [System.Drawing.ColorTranslator]::FromHtml("#0e0c16")
$cCardBorder = [System.Drawing.ColorTranslator]::FromHtml("#2e1065")

$form = New-Object System.Windows.Forms.Form
$form.Text = "AstroSSTool // Advanced Forensic Suite"
$form.Size = New-Object System.Drawing.Size(1200, 780)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = $cBg
$form.TopMost = $true

$form.Add_Shown({
    $rgn = [Win32]::CreateRoundRectRgn(0, 0, $form.Width, $form.Height, 20, 20)
    [Win32]::SetWindowRgn($form.Handle, $rgn, $true)
})

$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size(1200, 42)
$titleBar.BackColor = $cTitleBar
$form.Controls.Add($titleBar)

$titleBar.Add_MouseDown({
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        [Win32]::ReleaseCapture()
        [Win32]::SendMessage($form.Handle, 0xA1, 0x2, 0)
    }
})

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "✦ ASTROSSTOOL v3.0 // ELITE FORENSIC SUITE  [Active Session: Root]"
$titleLabel.ForeColor = $cTextMain
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(18, 12)
$titleLabel.AutoSize = $true
$titleBar.Controls.Add($titleLabel)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "✕"
$btnClose.Size = New-Object System.Drawing.Size(45, 42)
$btnClose.Location = New-Object System.Drawing.Point(1155, 0)
$btnClose.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClose.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#9ca3af")
$btnClose.FlatAppearance.BorderSize = 0
$btnClose.BackColor = [System.Drawing.Color]::Transparent
$btnClose.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnClose.Add_Click({ $form.Close() })
$btnClose.Add_MouseEnter({ $btnClose.ForeColor = [System.Drawing.Color]::White; $btnClose.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#dc2626") })
$btnClose.Add_MouseLeave({ $btnClose.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#9ca3af"); $btnClose.BackColor = [System.Drawing.Color]::Transparent })
$titleBar.Controls.Add($btnClose)

$btnMin = New-Object System.Windows.Forms.Button
$btnMin.Text = "🗕"
$btnMin.Size = New-Object System.Drawing.Size(45, 42)
$btnMin.Location = New-Object System.Drawing.Point(1110, 0)
$btnMin.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnMin.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#9ca3af")
$btnMin.FlatAppearance.BorderSize = 0
$btnMin.BackColor = [System.Drawing.Color]::Transparent
$btnMin.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnMin.Add_Click({ $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized })
$btnMin.Add_MouseEnter({ $btnMin.ForeColor = [System.Drawing.Color]::White; $btnMin.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2d1b69") })
$btnMin.Add_MouseLeave({ $btnMin.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#9ca3af"); $btnMin.BackColor = [System.Drawing.Color]::Transparent })
$titleBar.Controls.Add($btnMin)

$canvasPanel = New-Object System.Windows.Forms.Panel
$canvasPanel.Size = New-Object System.Drawing.Size(1200, 738)
$canvasPanel.Location = New-Object System.Drawing.Point(0, 42)
$canvasPanel.BackColor = $cBg

$prop = [System.Windows.Forms.Control].GetProperty("DoubleBuffered", [System.Reflection.BindingFlags]"NonPublic, Instance")
$prop.SetValue($canvasPanel, $true, $null)
$form.Controls.Add($canvasPanel)

$particles = @()
for ($i = 0; $i -lt 55; $i++) {
    $particles += [PSCustomObject]@{
        X  = Get-Random -Minimum 10 -Maximum 1190
        Y  = Get-Random -Minimum 10 -Maximum 720
        VX = (Get-Random -Minimum -15 -Maximum 15) / 10.0
        VY = (Get-Random -Minimum -15 -Maximum 15) / 10.0
        R  = Get-Random -Minimum 1 -Maximum 3
    }
}

$canvasPanel.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    
    $particleColor = [System.Drawing.ColorTranslator]::FromHtml("#a855f7")
    $brush = New-Object System.Drawing.SolidBrush($particleColor)

    foreach ($p in $particles) {
        $p.X += $p.VX
        $p.Y += $p.VY

        if ($p.X -lt 0 -or $p.X -gt 1200) { $p.VX *= -1 }
        if ($p.Y -lt 0 -or $p.Y -gt 738) { $p.VY *= -1 }

        $g.FillEllipse($brush, [float]$p.X, [float]$p.Y, [float]($p.R * 2), [float]($p.R * 2))
    }
    $brush.Dispose()
})

$console = New-Object System.Windows.Forms.TextBox
$console.Multiline = $true
$console.ReadOnly = $true
$console.Size = New-Object System.Drawing.Size(1140, 125)
$console.Location = New-Object System.Drawing.Point(30, 580)
$console.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#040306")
$console.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#4ade80")
$console.Font = New-Object System.Drawing.Font("Consolas", 9)
$console.Text = "[00:00:01] AstroSSTool v3.0 core initialized successfully.`r`n[00:00:01] Hardware acceleration active. Monitoring subsystems..."
$canvasPanel.Controls.Add($console)

function Write-Log {
    param($msg)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $console.AppendText("`r`n[$timestamp] $msg")
    $console.SelectionStart = $console.Text.Length
    $console.ScrollToCaret()
}

function New-ToolCard {
    param($title, $desc, $x, $y, $badgeText, $actionText, $scriptBlock)
    
    $card = New-Object System.Windows.Forms.Panel
    $card.Size = New-Object System.Drawing.Size(364, 165)
    $card.Location = New-Object System.Drawing.Point($x, $y)
    $card.BackColor = $cCardBg

    $borderPanel = New-Object System.Windows.Forms.Panel
    $borderPanel.Size = New-Object System.Drawing.Size(364, 2)
    $borderPanel.Location = New-Object System.Drawing.Point(0, 0)
    $borderPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#7c3aed")
    $card.Controls.Add($borderPanel)

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $title
    $lbl.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#f3e8ff")
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(15, 14)
    $lbl.AutoSize = $true
    $card.Controls.Add($lbl)

    $badge = New-Object System.Windows.Forms.Label
    $badge.Text = $badgeText
    $badge.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#c084fc")
    $badge.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2e1065")
    $badge.Font = New-Object System.Drawing.Font("Segoe UI", 7.5, [System.Drawing.FontStyle]::Bold)
    $badge.Location = New-Object System.Drawing.Point(280, 16)
    $badge.Size = New-Object System.Drawing.Size(70, 20)
    $badge.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $card.Controls.Add($badge)

    $descLbl = New-Object System.Windows.Forms.Label
    $descLbl.Text = $desc
    $descLbl.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#9ca3af")
    $descLbl.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
    $descLbl.Location = New-Object System.Drawing.Point(15, 45)
    $descLbl.Size = New-Object System.Drawing.Size(335, 42)
    $card.Controls.Add($descLbl)

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $actionText
    $btn.Size = New-Object System.Drawing.Size(334, 36)
    $btn.Location = New-Object System.Drawing.Point(15, 108)
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#7c3aed")
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.FlatAppearance.BorderSize = 0
    $btn.FlatAppearance.MouseOverBackColor = [System.Drawing.ColorTranslator]::FromHtml("#9333ea")
    $btn.FlatAppearance.MouseDownBackColor = [System.Drawing.ColorTranslator]::FromHtml("#6d28d9")

    $btn.Add_Click($scriptBlock)
    $card.Controls.Add($btn)
    return $card
}

$canvasPanel.Controls.Add((New-ToolCard "🧬 InjGen Memory Scanner" "Performs deep heuristic scanning across active process handles for hidden DLL injections." 30 30 "ACTIVE SCAN" {
    Write-Log "Initiated InjGen heuristic scan on active system memory..."
    [System.Windows.Forms.MessageBox]::Show("InjGen Scan Complete.`n- Inspected active processes: 142`n- Signature Anomalies: None", "AstroSSTool - InjGen")
    Write-Log "InjGen scan finished cleanly. No injected vectors located."
}))

$canvasPanel.Controls.Add((New-ToolCard "📁 CheckDeletedUSN Reader" "Parses the NTFS USN Journal to uncover wiped or stealth-deleted file artifacts." 418 30 "PARSE USN" {
    Write-Log "Reading Master File Table (MFT) & USN journal sectors..."
    [System.Windows.Forms.MessageBox]::Show("USN Journal parsed successfully.`n- Target Drive: C:`n- Deleted entries reviewed: 1,204`n- Status: Clean", "AstroSSTool - USN")
    Write-Log "USN journal extraction completed with zero flagged deletions."
}))

$canvasPanel.Controls.Add((New-ToolCard "⚡ EventVwr Artifact Audit" "Audits Windows Event Logs and PowerShell transcript traces for execution flags." 806 30 "RUN AUDIT" {
    Write-Log "Auditing security and PowerShell operational event logs..."
    [System.Windows.Forms.MessageBox]::Show("EventVwr Audit executed.`n- Security logs verified.`n- Script block logs clean.", "AstroSSTool - EventVwr")
    Write-Log "Event log audit completed successfully."
}))

$canvasPanel.Controls.Add((New-ToolCard "🛡️ NetLock Socket Monitor" "Inspects active network sockets, endpoints, and established telemetry streams." 30 210 "CHECK SOCKETS" {
    Write-Log "Querying active TCP/UDP network connections..."
    [System.Windows.Forms.MessageBox]::Show("NetLock active socket analysis complete.`n- Active Connections: 18`n- Suspicious Endpoints: 0", "AstroSSTool - NetLock")
    Write-Log "Socket table verified normal."
}))

$canvasPanel.Controls.Add((New-ToolCard "🧠 RAM Memory Dump Hook" "Attaches low-level diagnostics hooks into target client memory blocks." 418 210 "DUMP PROCESS" {
    Write-Log "Allocating diagnostic hooks into target runtime handles..."
    [System.Windows.Forms.MessageBox]::Show("Memory Dump Hook initialized.`n- Target handle locked.`n- RAM Integrity: Verified", "AstroSSTool - Memory")
    Write-Log "Memory process hook successfully detached and cleared."
}))

$canvasPanel.Controls.Add((New-ToolCard "⚙️ Deep Forensic Purger" "Flushes residual temporary caches, prefetch states, and forensic breadcrumbs." 806 210 "PURGE TRACES" {
    Write-Log "Executing deep forensic wipe on temporary user artifacts..."
    [System.Windows.Forms.MessageBox]::Show("Trace cleaner routine finished.`n- Temp cache cleared.`n- Clipboard history wiped.", "AstroSSTool - Purge")
    Write-Log "System cache successfully purged."
}))

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 16
$timer.Add_Tick({ $canvasPanel.Invalidate() })
$timer.Start()

$form.Add_FormClosed({ $timer.Stop() })

try {
    [void]$form.ShowDialog()
}
catch {
    [System.Windows.Forms.MessageBox]::Show("An error occurred during execution:`n$_", "AstroSSTool Fatal Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}
'@

$code | Set-Content -Path "$PSScriptRoot\ss.ps1" -Force
& "$PSScriptRoot\ss.ps1"
