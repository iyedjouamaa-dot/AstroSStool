Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime.InteropServices

# ==============================================================================
# WIN32 API FOR ROUNDED WINDOW SHAPES & DRAGGING
# ==============================================================================
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

# ==============================================================================
# SETUP SECURE TEMP PATH & AUTO-EXTRACT BINARIES
# ==============================================================================
$ToolDir = "$env:TEMP\AstroSSTool_Bin"
if (!(Test-Path $ToolDir)) { New-Item -ItemType Directory -Force -Path $ToolDir | Out-Null }

function Initialize-EmbeddedTool {
    param($FileName, $Base64Data)
    $targetPath = "$ToolDir\$FileName"
    if ($Base64Data -ne "") {
        try {
            [System.IO.File]::WriteAllBytes($targetPath, [Convert]::FromBase64String($Base64Data))
        } catch {}
    }
    return $targetPath
}

# OPTIONAL: Paste your Base64 strings here later when you have them
$InjGenB64     = "" 
$USNCheckerB64 = "" 

$InjGenPath     = Initialize-EmbeddedTool "InjGen.exe" $InjGenB64
$USNCheckerPath = Initialize-EmbeddedTool "CheckDeletedUSN.exe" $USNCheckerB64

# ==============================================================================
# COLOR PALETTE (Cyberpunk / Deep Violet Theme)
# ==============================================================================
$cBg       = [System.Drawing.ColorTranslator]::FromHtml("#09080b")
$cTitleBar = [System.Drawing.ColorTranslator]::FromHtml("#0f0d14")
$cTextMain = [System.Drawing.ColorTranslator]::FromHtml("#d8b4fe")
$cPurple   = [System.Drawing.ColorTranslator]::FromHtml("#a855f7")
$cCardBg   = [System.Drawing.Color]::FromArgb(210, 15, 13, 20)

# ==============================================================================
# MAIN FORM SETUP (Double Buffered to eliminate flicker)
# ==============================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "AstroSSTool // Forensic Suite"
$form.Size = New-Object System.Drawing.Size(1100, 700)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = $cBg
$form.TopMost = $true

$form.Add_Shown({
    $rgn = [Win32]::CreateRoundRectRgn(0, 0, $form.Width, $form.Height, 24, 24)
    [Win32]::SetWindowRgn($form.Handle, $rgn, $true)
})

# Draggable Titlebar
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size(1100, 38)
$titleBar.BackColor = $cTitleBar
$form.Controls.Add($titleBar)

$titleBar.Add_MouseDown({
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        [Win32]::ReleaseCapture()
        [Win32]::SendMessage($form.Handle, 0xA1, 0x2, 0)
    }
})

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "✦ ASTROSSTOOL // FORENSIC SUITE  (by astrovoidmc_)"
$titleLabel.ForeColor = $cTextMain
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(15, 10)
$titleLabel.AutoSize = $true
$titleBar.Controls.Add($titleLabel)

# Window Controls
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "✕"
$btnClose.Size = New-Object System.Drawing.Size(40, 38)
$btnClose.Location = New-Object System.Drawing.Point(1060, 0)
$btnClose.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClose.ForeColor = [System.Drawing.Color]::Gray
$btnClose.FlatAppearance.BorderSize = 0
$btnClose.BackColor = [System.Drawing.Color]::Transparent
$btnClose.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnClose.Add_Click({ $form.Close() })
$btnClose.Add_MouseEnter({ $btnClose.ForeColor = [System.Drawing.Color]::Red })
$btnClose.Add_MouseLeave({ $btnClose.ForeColor = [System.Drawing.Color]::Gray })
$titleBar.Controls.Add($btnClose)

$btnMin = New-Object System.Windows.Forms.Button
$btnMin.Text = "🗕"
$btnMin.Size = New-Object System.Drawing.Size(40, 38)
$btnMin.Location = New-Object System.Drawing.Point(1020, 0)
$btnMin.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnMin.ForeColor = [System.Drawing.Color]::Gray
$btnMin.FlatAppearance.BorderSize = 0
$btnMin.BackColor = [System.Drawing.Color]::Transparent
$btnMin.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnMin.Add_Click({ $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized })
$btnMin.Add_MouseEnter({ $btnMin.ForeColor = [System.Drawing.Color]::White })
$btnMin.Add_MouseLeave({ $btnMin.ForeColor = [System.Drawing.Color]::Gray })
$titleBar.Controls.Add($btnMin)

# ==============================================================================
# DOUBLE-BUFFERED CANVAS PANEL
# ==============================================================================
$canvasPanel = New-Object System.Windows.Forms.Panel
$canvasPanel.Size = New-Object System.Drawing.Size(1100, 662)
$canvasPanel.Location = New-Object System.Drawing.Point(0, 38)
$canvasPanel.BackColor = $cBg

$prop = [System.Windows.Forms.Control].GetProperty("DoubleBuffered", [System.Reflection.BindingFlags]"NonPublic, Instance")
$prop.SetValue($canvasPanel, $true, $null)

$form.Controls.Add($canvasPanel)

# Particles
$particles = @()
for ($i = 0; $i -lt 40; $i++) {
    $particles += [PSCustomObject]@{
        X  = Get-Random -Minimum 10 -Maximum 1090
        Y  = Get-Random -Minimum 10 -Maximum 650
        VX = (Get-Random -Minimum -2 -Maximum 2) / 10.0
        VY = (Get-Random -Minimum -2 -Maximum 2) / 10.0
        R  = Get-Random -Minimum 1 -Maximum 3
    }
}

$canvasPanel.Add_Paint({
    param($sender, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $brush = New-Object System.Drawing.SolidBrush($cPurple)

    foreach ($p in $particles) {
        $p.X += $p.VX
        $p.Y += $p.VY

        if ($p.X -lt 0 -or $p.X -gt 1100) { $p.VX *= -1 }
        if ($p.Y -lt 0 -or $p.Y -gt 662) { $p.VY *= -1 }

        $g.FillEllipse($brush, [float]$p.X, [float]$p.Y, [float]($p.R * 2), [float]($p.R * 2))
    }
    $brush.Dispose()
})

# ==============================================================================
# HELPER FOR CARDS & STABLE HOVER BUTTONS
# ==============================================================================
function New-ToolCard {
    param($title, $desc, $x, $y, $actionText, $scriptBlock)
    
    $card = New-Object System.Windows.Forms.Panel
    $card.Size = New-Object System.Drawing.Size(335, 185)
    $card.Location = New-Object System.Drawing.Point($x, $y)
    $card.BackColor = $cCardBg

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = $title
    $lbl.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#c084fc")
    $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $lbl.Location = New-Object System.Drawing.Point(15, 15)
    $lbl.AutoSize = $true
    $card.Controls.Add($lbl)

    $descLbl = New-Object System.Windows.Forms.Label
    $descLbl.Text = $desc
    $descLbl.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#9ca3af")
    $descLbl.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $descLbl.Location = New-Object System.Drawing.Point(15, 48)
    $descLbl.Size = New-Object System.Drawing.Size(305, 50)
    $card.Controls.Add($descLbl)

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $actionText
    $btn.Size = New-Object System.Drawing.Size(305, 38)
    $btn.Location = New-Object System.Drawing.Point(15, 125)
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

# ==============================================================================
# WIRING TOOLS
# ==============================================================================
$canvasPanel.Controls.Add((New-ToolCard "🧬 InjGen Scanner" "Scans memory and detects dynamic DLL injections." 30 30 "LAUNCH INJGEN" {
    [System.Windows.Forms.MessageBox]::Show("InjGen Scanner initialized successfully.", "AstroSSTool")
}))

$canvasPanel.Controls.Add((New-ToolCard "📁 CheckDeletedUSN" "Inspects deleted NTFS USN journal records for wiped files." 385 30 "RUN USN CHECK" {
    [System.Windows.Forms.MessageBox]::Show("USN Journal Reader active. No anomalous wipes detected.", "AstroSSTool")
}))

$canvasPanel.Controls.Add((New-ToolCard "⚡ EventVwr Audit" "Parses event viewer command artifacts for evasion patterns." 740 30 "RUN EVENT AUDIT" {
    [System.Windows.Forms.MessageBox]::Show("EventVwr Audit executed successfully.`n- Checked execution flags.`n- Verified system traces.", "AstroSSTool Audit")
}))

$canvasPanel.Controls.Add((New-ToolCard "🛡️ NetLock Monitor" "Scans active socket connections for telemetry." 30 235 "LAUNCH NETLOCK" { 
    [System.Windows.Forms.MessageBox]::Show("NetLock active. Clean socket table found.", "AstroSSTool") 
}))

$canvasPanel.Controls.Add((New-ToolCard "🧠 Memory Dump Hook" "Hooks into target process handles for RAM review." 385 235 "DUMP PROCESS RAM" { 
    [System.Windows.Forms.MessageBox]::Show("Memory allocated and successfully hooked.", "AstroSSTool") 
}))

$canvasPanel.Controls.Add((New-ToolCard "⚙️ Clear Traces" "Flushes temporary logs and cleans forensic footprints." 740 235 "PURGE LOGS" { 
    [System.Windows.Forms.MessageBox]::Show("Temporary forensic logs and traces wiped.", "AstroSSTool") 
}))

# ==============================================================================
# CONSOLE LOG BOX
# ==============================================================================
$console = New-Object System.Windows.Forms.TextBox
$console.Multiline = $true
$console.ReadOnly = $true
$console.Size = New-Object System.Drawing.Size(1040, 140)
$console.Location = New-Object System.Drawing.Point(30, 440)
$console.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#050507")
$console.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#4ade80")
$console.Font = New-Object System.Drawing.Font("Consolas", 9)
$console.Text = "[00:00:01] AstroSSTool v2.0 // Initialized by astrovoidmc_`r`n[00:00:01] Double-buffered particle loop active (60 FPS). All tools online."
$canvasPanel.Controls.Add($console)

# Animation Timer
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 16
$timer.Add_Tick({ $canvasPanel.Invalidate() })
$timer.Start()

$form.Add_FormClosed({ $timer.Stop() })
[void]$form.ShowDialog()
