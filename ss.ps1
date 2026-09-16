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
# MAIN FORM SETUP
# ==============================================================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "AstroSSTool // Forensic Suite"
$form.Size = New-Object System.Drawing.Size(840, 520)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#09080b")
$form.TopMost = $true

$form.Add_Shown({
    $rgn = [Win32]::CreateRoundRectRgn(0, 0, $form.Width, $form.Height, 24, 24)
    [Win32]::SetWindowRgn($form.Handle, $rgn, $true)
})

# Draggable Titlebar
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size(840, 35)
$titleBar.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0f0d14")
$form.Controls.Add($titleBar)

$titleBar.Add_MouseDown({
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        [Win32]::ReleaseCapture()
        [Win32]::SendMessage($form.Handle, 0xA1, 0x2, 0)
    }
})

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "✦ ASTROSSTOOL // FORENSIC SUITE  (by astrovoidmc_)"
$titleLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#d8b4fe")
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(15, 8)
$titleLabel.AutoSize = $true
$titleBar.Controls.Add($titleLabel)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "✕"
$btnClose.Size = New-Object System.Drawing.Size(35, 35)
$btnClose.Location = New-Object System.Drawing.Point(805, 0)
$btnClose.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClose.ForeColor = [System.Drawing.Color]::Gray
$btnClose.FlatAppearance.BorderSize = 0
$btnClose.BackColor = [System.Drawing.Color]::Transparent
$btnClose.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnClose.Add_Click({ $form.Close() })
$titleBar.Controls.Add($btnClose)

# ==============================================================================
# CANVAS PANEL WITH REAL-TIME PARTICLE ANIMATION LOOP
# ==============================================================================
$canvasPanel = New-Object System.Windows.Forms.Panel
$canvasPanel.Size = New-Object System.Drawing.Size(840, 485)
$canvasPanel.Location = New-Object System.Drawing.Point(0, 35)
$canvasPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#09080b")
$form.Controls.Add($canvasPanel)

# Generate Particles
$particles = @()
for ($i = 0; $i -lt 35; $i++) {
    $particles += [PSCustomObject]@{
        X  = Get-Random -Minimum 10 -Maximum 830
        Y  = Get-Random -Minimum 10 -Maximum 470
        VX = (Get-Random -Minimum -5 -Maximum 5) / 10
        VY = (Get-Random -Minimum -5 -Maximum 5) / 10
        R  = Get-Random -Minimum 1 -Maximum 3
    }
}

$canvasPanel.Add_Paint({
    $g = $_.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml("#a855f7"))
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color.FromArgb(25, 168, 85, 247)], 1)

    foreach ($p in $particles) {
        $p.X += $p.VX
        $p.Y += $p.VY

        if ($p.X -lt 0 -or $p.X -gt 840) { $p.VX *= -1 }
        if ($p.Y -lt 0 -or $p.Y -gt 485) { $p.VY *= -1 }

        $g.FillEllipse($brush, $p.X, $p.Y, $p.R * 2, $p.R * 2)
    }
    $brush.Dispose()
    $pen.Dispose()
})

# Render UI Controls on top of canvas panel
$card = New-Object System.Windows.Forms.Panel
$card.Size = New-Object System.Drawing.Size(380, 180)
$card.Location = New-Object System.Drawing.Point(25, 25)
$card.BackColor = [System.Drawing.Color.FromArgb(180, 18, 16, 23)]
$canvasPanel.Controls.Add($card)

$lblCardTitle = New-Object System.Windows.Forms.Label
$lblCardTitle.Text = "🔍 System Artifact Scanner"
$lblCardTitle.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#c084fc")
$lblCardTitle.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$lblCardTitle.Location = New-Object System.Drawing.Point(15, 15)
$lblCardTitle.AutoSize = $true
$card.Controls.Add($lblCardTitle)

$btnScan = New-Object System.Windows.Forms.Button
$btnScan.Text = "RUN PREFETCH SCAN"
$btnScan.Size = New-Object System.Drawing.Size(340, 40)
$btnScan.Location = New-Object System.Drawing.Point(20, 110)
$btnScan.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnScan.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#7c3aed")
$btnScan.ForeColor = [System.Drawing.Color]::White
$btnScan.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$card.Controls.Add($btnScan)

# Smooth Animation Timer Loop (60 FPS Particle Refresh)
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 16
$timer.Add_Tick({ $canvasPanel.Invalidate() })
$timer.Start()

$form.Add_FormClosed({ $timer.Stop() })
[void]$form.ShowDialog()
