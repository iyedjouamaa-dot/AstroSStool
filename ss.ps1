<#
    AstroSSTool - Transparent Screenshare Diagnostic Companion
    ------------------------------------------------------------
    Read-only system inspection tool for use during voluntary screenshares.
    It only LISTS information already visible via built-in Windows tools
    (Task Manager, Event Viewer, Resource Monitor, netstat, etc). It does not:
      - inject code or hook into any other process's memory
      - modify, delete, or wipe any files, logs, caches, or prefetch data
      - require elevation to view its results
    Every module here is intentionally readable so anyone (including the
    person being screenshared) can review exactly what it does before
    running it.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------------------------------------------------------------------------
# Background music (optional). Plays a looping .wav file if one is found next
# to this script. WAV is used because System.Media.SoundPlayer (built into
# .NET Framework, no extra downloads needed) only supports .wav natively.
# To enable: place a file named "theme.wav" in the same folder as this
# script, or change $MusicFile below to point at your own .wav file.
# ---------------------------------------------------------------------------
$MusicFile = Join-Path $PSScriptRoot "theme.wav"
$script:MusicPlayer = $null

function Start-BackgroundMusic {
    param([string]$Path)
    if (Test-Path $Path) {
        try {
            $script:MusicPlayer = New-Object System.Media.SoundPlayer($Path)
            $script:MusicPlayer.PlayLooping()
            return $true
        } catch {
            return $false
        }
    }
    return $false
}

function Stop-BackgroundMusic {
    if ($script:MusicPlayer) {
        try { $script:MusicPlayer.Stop() } catch {}
    }
}

# ---------------------------------------------------------------------------
# Win32 interop: rounded corners + borderless window dragging
# ---------------------------------------------------------------------------
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("gdi32.dll")]
    public static extern IntPtr CreateRoundRectRgn(int nLeftRect,int nTopRect,int nRightRect,int nBottomRect,int nWidthEllipse,int nHeightEllipse);
    [DllImport("user32.dll")]
    public static extern int SetWindowRgn(IntPtr hWnd, IntPtr hRgn, bool bRedraw);
    [DllImport("user32.dll")]
    public static extern bool ReleaseCapture();
    [DllImport("user32.dll")]
    public static extern int SendMessage(IntPtr hWnd, int Msg, int wParam, int lParam);
}
"@

# ---------------------------------------------------------------------------
# Theme (Elite Cyber-Violet) - all colors via ColorTranslator for safe parsing
# ---------------------------------------------------------------------------
$ColorBackground = [System.Drawing.ColorTranslator]::FromHtml("#07060a")
$ColorCard       = [System.Drawing.ColorTranslator]::FromHtml("#0e0c16")
$ColorCardBorder = [System.Drawing.ColorTranslator]::FromHtml("#231a35")
$ColorAccent     = [System.Drawing.ColorTranslator]::FromHtml("#a855f7")
$ColorAccentDim  = [System.Drawing.ColorTranslator]::FromHtml("#6d28d9")
$ColorText       = [System.Drawing.ColorTranslator]::FromHtml("#e9d5ff")
$ColorSubText    = [System.Drawing.ColorTranslator]::FromHtml("#9d8bb0")
$ColorConsoleBg  = [System.Drawing.ColorTranslator]::FromHtml("#040306")
$ColorConsoleFg  = [System.Drawing.ColorTranslator]::FromHtml("#4ade80")
$ColorBadgeBg    = [System.Drawing.ColorTranslator]::FromHtml("#1a1329")
$ColorClose      = [System.Drawing.ColorTranslator]::FromHtml("#f87171")

$FontTitle  = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$FontSub    = New-Object System.Drawing.Font("Segoe UI", 9)
$FontCard   = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$FontDesc   = New-Object System.Drawing.Font("Segoe UI", 8.5)
$FontBadge  = New-Object System.Drawing.Font("Segoe UI", 7.5, [System.Drawing.FontStyle]::Bold)
$FontBtn    = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$FontConsole= New-Object System.Drawing.Font("Consolas", 9.5)

# ---------------------------------------------------------------------------
# Main Form
# ---------------------------------------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "AstroSSTool"
$form.Size = New-Object System.Drawing.Size(1040, 760)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = $ColorBackground
$form.DoubleBuffered = $true

$form.Add_Load({
    $rgn = [Win32]::CreateRoundRectRgn(0, 0, $form.Width, $form.Height, 22, 22)
    [Win32]::SetWindowRgn($form.Handle, $rgn, $true)
})
$form.Add_Resize({
    $rgn = [Win32]::CreateRoundRectRgn(0, 0, $form.Width, $form.Height, 22, 22)
    [Win32]::SetWindowRgn($form.Handle, $rgn, $true)
})

# ---------------------------------------------------------------------------
# Title bar (draggable, custom close/minimize)
# ---------------------------------------------------------------------------
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size($form.Width, 42)
$titleBar.Dock = "Top"
$titleBar.BackColor = $ColorCard

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "ASTRO  SS TOOL"
$titleLabel.Font = $FontTitle
$titleLabel.ForeColor = $ColorText
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(18, 9)
$titleBar.Controls.Add($titleLabel)

$subLabel = New-Object System.Windows.Forms.Label
$subLabel.Text = "transparent  ·  read-only  ·  open source"
$subLabel.Font = $FontSub
$subLabel.ForeColor = $ColorSubText
$subLabel.AutoSize = $true
$subLabel.Location = New-Object System.Drawing.Point(200, 14)
$titleBar.Controls.Add($subLabel)

$closeBtn = New-Object System.Windows.Forms.Label
$closeBtn.Text = "✕"
$closeBtn.Font = $FontBtn
$closeBtn.ForeColor = $ColorClose
$closeBtn.Size = New-Object System.Drawing.Size(40, 42)
$closeBtn.TextAlign = "MiddleCenter"
$closeBtn.Location = New-Object System.Drawing.Point(($form.Width - 40), 0)
$closeBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$closeBtn.Add_Click({ $form.Close() })
$titleBar.Controls.Add($closeBtn)

$minBtn = New-Object System.Windows.Forms.Label
$minBtn.Text = "—"
$minBtn.Font = $FontBtn
$minBtn.ForeColor = $ColorSubText
$minBtn.Size = New-Object System.Drawing.Size(40, 42)
$minBtn.TextAlign = "MiddleCenter"
$minBtn.Location = New-Object System.Drawing.Point(($form.Width - 80), 0)
$minBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$minBtn.Add_Click({ $form.WindowState = [System.Windows.Forms.FormWindowState]::Minimized })
$titleBar.Controls.Add($minBtn)

$dragHandler = {
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        [Win32]::ReleaseCapture() | Out-Null
        [Win32]::SendMessage($form.Handle, 0xA1, 0x2, 0) | Out-Null
    }
}
$titleBar.Add_MouseDown($dragHandler)
$titleLabel.Add_MouseDown($dragHandler)
$subLabel.Add_MouseDown($dragHandler)

$form.Controls.Add($titleBar)

# ---------------------------------------------------------------------------
# Hero panel with floating particle animation
# ---------------------------------------------------------------------------
$heroPanel = New-Object System.Windows.Forms.Panel
$heroPanel.Size = New-Object System.Drawing.Size($form.Width, 90)
$heroPanel.Dock = "Top"
$heroPanel.BackColor = $ColorBackground
$heroPanel.GetType().GetProperty("DoubleBuffered", [System.Reflection.BindingFlags]"NonPublic,Instance").SetValue($heroPanel, $true, $null)

$heroLabel = New-Object System.Windows.Forms.Label
$heroLabel.Text = "Screenshare Diagnostic Companion"
$heroLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$heroLabel.ForeColor = $ColorText
$heroLabel.AutoSize = $true
$heroLabel.BackColor = [System.Drawing.Color]::Transparent
$heroLabel.Location = New-Object System.Drawing.Point(20, 14)
$heroPanel.Controls.Add($heroLabel)

$heroSub = New-Object System.Windows.Forms.Label
$heroSub.Text = "Every module below only reads and reports information. Nothing is modified, injected, or deleted."
$heroSub.Font = $FontSub
$heroSub.ForeColor = $ColorSubText
$heroSub.AutoSize = $true
$heroSub.BackColor = [System.Drawing.Color]::Transparent
$heroSub.Location = New-Object System.Drawing.Point(20, 44)
$heroPanel.Controls.Add($heroSub)

$script:Particles = @()
$rand = New-Object System.Random
for ($i = 0; $i -lt 36; $i++) {
    $script:Particles += [PSCustomObject]@{
        X  = $rand.Next(0, 1000)
        Y  = $rand.Next(0, 90)
        VX = (($rand.Next(-10, 10)) / 10.0)
        VY = (($rand.Next(-6, 6)) / 10.0)
        R  = $rand.Next(1, 3)
    }
}

$heroPanel.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $brush = New-Object System.Drawing.SolidBrush($ColorAccent)
    foreach ($p in $script:Particles) {
        $g.FillEllipse($brush, [float]$p.X, [float]$p.Y, [float]($p.R * 2), [float]($p.R * 2))
    }
    $brush.Dispose()
})

$particleTimer = New-Object System.Windows.Forms.Timer
$particleTimer.Interval = 16
$particleTimer.Add_Tick({
    foreach ($p in $script:Particles) {
        $p.X += $p.VX
        $p.Y += $p.VY
        if ($p.X -le 0 -or $p.X -ge $heroPanel.Width)  { $p.VX = -$p.VX }
        if ($p.Y -le 0 -or $p.Y -ge $heroPanel.Height) { $p.VY = -$p.VY }
    }
    $heroPanel.Invalidate()
})
$particleTimer.Start()

$form.Controls.Add($heroPanel)

# ---------------------------------------------------------------------------
# Console / log output (bottom terminal)
# ---------------------------------------------------------------------------
$consolePanel = New-Object System.Windows.Forms.Panel
$consolePanel.Size = New-Object System.Drawing.Size($form.Width, 220)
$consolePanel.Dock = "Bottom"
$consolePanel.BackColor = $ColorCard
$consolePanel.Padding = New-Object System.Windows.Forms.Padding(14)

$consoleLabel = New-Object System.Windows.Forms.Label
$consoleLabel.Text = "OUTPUT LOG"
$consoleLabel.Font = $FontBadge
$consoleLabel.ForeColor = $ColorSubText
$consoleLabel.AutoSize = $true
$consoleLabel.Location = New-Object System.Drawing.Point(14, 4)
$consolePanel.Controls.Add($consoleLabel)

$script:OutputBox = New-Object System.Windows.Forms.TextBox
$script:OutputBox.Multiline = $true
$script:OutputBox.ReadOnly = $true
$script:OutputBox.ScrollBars = "Vertical"
$script:OutputBox.BackColor = $ColorConsoleBg
$script:OutputBox.ForeColor = $ColorConsoleFg
$script:OutputBox.Font = $FontConsole
$script:OutputBox.BorderStyle = "FixedSingle"
$script:OutputBox.Location = New-Object System.Drawing.Point(14, 26)
$script:OutputBox.Size = New-Object System.Drawing.Size(($form.Width - 28), 180)
$script:OutputBox.Anchor = "Top,Bottom,Left,Right"
$consolePanel.Controls.Add($script:OutputBox)

$form.Controls.Add($consolePanel)

function Write-Log {
    param([string]$Message, [string]$Level = "Info")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = switch ($Level) {
        "Warn"  { "[WARN]" }
        "Error" { "[ERR ]" }
        default { "[INFO]" }
    }
    $line = "[$timestamp] $prefix $Message`r`n"
    $script:OutputBox.AppendText($line)
    $script:OutputBox.SelectionStart = $script:OutputBox.Text.Length
    $script:OutputBox.ScrollToCaret()
}

# ---------------------------------------------------------------------------
# Diagnostic modules (all read-only)
# ---------------------------------------------------------------------------
function Invoke-ProcessScan {
    Write-Log "Scanning running processes for signature status..."
    try {
        $procs = Get-Process | Where-Object { $_.Path } | Sort-Object ProcessName
        $flagged = 0
        foreach ($p in $procs) {
            try {
                $sig = Get-AuthenticodeSignature -FilePath $p.Path -ErrorAction Stop
                $status = $sig.Status
            } catch {
                $status = "Unreadable"
            }
            if ($status -ne "Valid") {
                $flagged++
                Write-Log ("  [!] {0} (PID {1}) -> signature: {2}" -f $p.ProcessName, $p.Id, $status) "Warn"
            }
        }
        Write-Log ("Process scan complete. {0} processes checked, {1} without a valid signature." -f $procs.Count, $flagged)
    } catch {
        Write-Log "Process scan failed: $($_.Exception.Message)" "Error"
    }
}

function Invoke-StartupScan {
    Write-Log "Reading startup entries and scheduled tasks..."
    try {
        $startup = Get-CimInstance Win32_StartupCommand -ErrorAction Stop
        foreach ($s in $startup) {
            Write-Log ("  [Startup] {0}  ->  {1}" -f $s.Name, $s.Command)
        }
        Write-Log ("Startup entries listed: {0}" -f (@($startup)).Count)
    } catch {
        Write-Log "  Could not read startup commands: $($_.Exception.Message)" "Warn"
    }
    try {
        $tasks = Get-ScheduledTask -ErrorAction Stop | Where-Object { $_.State -ne "Disabled" }
        foreach ($t in $tasks) {
            Write-Log ("  [Task] {0}{1}" -f $t.TaskPath, $t.TaskName)
        }
        Write-Log ("Active scheduled tasks listed: {0}" -f (@($tasks)).Count)
    } catch {
        Write-Log "  Could not read scheduled tasks: $($_.Exception.Message)" "Warn"
    }
}

function Invoke-RecentFilesScan {
    Write-Log "Reading recent file activity..."
    try {
        $recentPath = [Environment]::GetFolderPath("Recent")
        if (Test-Path $recentPath) {
            $files = Get-ChildItem $recentPath -ErrorAction SilentlyContinue |
                     Sort-Object LastWriteTime -Descending | Select-Object -First 25
            foreach ($f in $files) {
                Write-Log ("  {0}   ({1})" -f $f.Name, $f.LastWriteTime)
            }
            Write-Log ("Recent items listed: {0}" -f (@($files)).Count)
        } else {
            Write-Log "  Recent folder not found." "Warn"
        }
    } catch {
        Write-Log "Recent files scan failed: $($_.Exception.Message)" "Error"
    }
}

function Invoke-NetworkScan {
    Write-Log "Inspecting active TCP connections..."
    try {
        $conns = Get-NetTCPConnection -ErrorAction Stop |
                 Where-Object { $_.State -eq "Established" -or $_.State -eq "Listen" }
        foreach ($c in $conns) {
            $procName = try { (Get-Process -Id $c.OwningProcess -ErrorAction Stop).ProcessName } catch { "N/A" }
            Write-Log ("  [{0}] {1}:{2} -> {3}:{4}  ({5})" -f $c.State, $c.LocalAddress, $c.LocalPort, $c.RemoteAddress, $c.RemotePort, $procName)
        }
        Write-Log ("Network scan complete. {0} connections listed." -f (@($conns)).Count)
    } catch {
        Write-Log "  Get-NetTCPConnection unavailable, falling back to netstat..." "Warn"
        try {
            $netstat = netstat -ano | Select-String "ESTABLISHED|LISTENING"
            foreach ($line in $netstat) { Write-Log "  $line" }
        } catch {
            Write-Log "Network scan failed: $($_.Exception.Message)" "Error"
        }
    }
}

function Invoke-EventLogAudit {
    Write-Log "Auditing recent Security/PowerShell event log entries..."
    try {
        $events = Get-WinEvent -FilterHashtable @{ LogName = "Windows PowerShell"; Id = 400,600 } -MaxEvents 20 -ErrorAction Stop
        foreach ($ev in $events) {
            Write-Log ("  [{0}] {1} - {2}" -f $ev.TimeCreated, $ev.Id, ($ev.Message -split "`n")[0])
        }
        Write-Log ("PowerShell log entries listed: {0}" -f (@($events)).Count)
    } catch {
        Write-Log "  No recent PowerShell log entries found or access denied." "Warn"
    }
}

function Invoke-ExportReport {
    try {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $file = Join-Path $desktop "AstroSSTool_Report_$stamp.txt"
        $notes = $script:NotesBox.Text
        $content = @"
AstroSSTool - Screenshare Session Report
Generated: $(Get-Date)

--- NOTES ---
$notes

--- FULL OUTPUT LOG ---
$($script:OutputBox.Text)
"@
        Set-Content -Path $file -Value $content -Encoding UTF8
        Write-Log "Report exported to: $file"
    } catch {
        Write-Log "Export failed: $($_.Exception.Message)" "Error"
    }
}

# ---------------------------------------------------------------------------
# Card grid
# ---------------------------------------------------------------------------
$gridPanel = New-Object System.Windows.Forms.Panel
$gridPanel.Dock = "Fill"
$gridPanel.BackColor = $ColorBackground
$gridPanel.AutoScroll = $true
$gridPanel.Padding = New-Object System.Windows.Forms.Padding(20)
$form.Controls.Add($gridPanel)
$gridPanel.BringToFront()

function New-ToolCard {
    param(
        [string]$Icon,
        [string]$Title,
        [string]$Desc,
        [string]$Badge,
        [string]$ButtonText,
        [scriptblock]$OnClick,
        [int]$X,
        [int]$Y,
        [int]$W = 460,
        [int]$H = 150
    )

    $card = New-Object System.Windows.Forms.Panel
    $card.Size = New-Object System.Drawing.Size($W, $H)
    $card.Location = New-Object System.Drawing.Point($X, $Y)
    $card.BackColor = $ColorCard

    $border = {
        param($s, $e)
        $pen = New-Object System.Drawing.Pen($ColorCardBorder, 1)
        $e.Graphics.DrawRectangle($pen, 0, 0, ($card.Width - 1), ($card.Height - 1))
        $pen.Dispose()
    }
    $card.Add_Paint($border)

    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "$Icon  $Title"
    $lblTitle.Font = $FontCard
    $lblTitle.ForeColor = $ColorText
    $lblTitle.AutoSize = $true
    $lblTitle.Location = New-Object System.Drawing.Point(16, 14)
    $card.Controls.Add($lblTitle)

    $lblBadge = New-Object System.Windows.Forms.Label
    $lblBadge.Text = "  $Badge  "
    $lblBadge.Font = $FontBadge
    $lblBadge.ForeColor = $ColorAccent
    $lblBadge.BackColor = $ColorBadgeBg
    $lblBadge.AutoSize = $true
    $lblBadge.Location = New-Object System.Drawing.Point(($W - 100), 16)
    $card.Controls.Add($lblBadge)

    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Text = $Desc
    $lblDesc.Font = $FontDesc
    $lblDesc.ForeColor = $ColorSubText
    $lblDesc.Size = New-Object System.Drawing.Size(($W - 32), 50)
    $lblDesc.Location = New-Object System.Drawing.Point(16, 44)
    $card.Controls.Add($lblDesc)

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $ButtonText
    $btn.Font = $FontBtn
    $btn.ForeColor = $ColorText
    $btn.BackColor = $ColorAccentDim
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.Size = New-Object System.Drawing.Size(($W - 32), 32)
    $btn.Location = New-Object System.Drawing.Point(16, ($H - 44))
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.Add_Click($OnClick)
    $card.Controls.Add($btn)

    $gridPanel.Controls.Add($card)
    return $card
}

$colW = 460
$gap  = 20
$col1X = 0
$col2X = $colW + $gap
$rowH = 150
$rowGap = 18

New-ToolCard -Icon "🧩" -Title "Process Integrity Viewer" `
    -Desc "Lists running processes and flags any whose executable does not carry a valid digital signature." `
    -Badge "READ-ONLY" -ButtonText "Run Scan" -OnClick { Invoke-ProcessScan } `
    -X $col1X -Y 0 -W $colW -H $rowH

New-ToolCard -Icon "🗂️" -Title "Startup & Task Auditor" `
    -Desc "Reads registry startup entries and active Scheduled Tasks for review." `
    -Badge "READ-ONLY" -ButtonText "Run Audit" -OnClick { Invoke-StartupScan } `
    -X $col2X -Y 0 -W $colW -H $rowH

New-ToolCard -Icon "🕘" -Title "Recent File Activity" `
    -Desc "Shows the most recently accessed files from the Windows Recent Items folder." `
    -Badge "READ-ONLY" -ButtonText "View Recent" -OnClick { Invoke-RecentFilesScan } `
    -X $col1X -Y ($rowH + $rowGap) -W $colW -H $rowH

New-ToolCard -Icon "🌐" -Title "Network Connection Monitor" `
    -Desc "Lists active TCP connections and the process that owns each one." `
    -Badge "READ-ONLY" -ButtonText "Scan Connections" -OnClick { Invoke-NetworkScan } `
    -X $col2X -Y ($rowH + $rowGap) -W $colW -H $rowH

New-ToolCard -Icon "📜" -Title "PowerShell Log Audit" `
    -Desc "Reads recent PowerShell event log entries (module/script execution records)." `
    -Badge "READ-ONLY" -ButtonText "Read Logs" -OnClick { Invoke-EventLogAudit } `
    -X $col1X -Y ((($rowH + $rowGap) * 2)) -W $colW -H $rowH

# --- Notes & Export card (wider, with embedded textbox) ---
$notesY = (($rowH + $rowGap) * 2)
$notesCard = New-Object System.Windows.Forms.Panel
$notesCard.Size = New-Object System.Drawing.Size($colW, ($rowH + 90))
$notesCard.Location = New-Object System.Drawing.Point($col2X, $notesY)
$notesCard.BackColor = $ColorCard
$notesCard.Add_Paint({
    param($s, $e)
    $pen = New-Object System.Drawing.Pen($ColorCardBorder, 1)
    $e.Graphics.DrawRectangle($pen, 0, 0, ($notesCard.Width - 1), ($notesCard.Height - 1))
    $pen.Dispose()
})

$notesTitle = New-Object System.Windows.Forms.Label
$notesTitle.Text = "📝  Session Notes & Export"
$notesTitle.Font = $FontCard
$notesTitle.ForeColor = $ColorText
$notesTitle.AutoSize = $true
$notesTitle.Location = New-Object System.Drawing.Point(16, 14)
$notesCard.Controls.Add($notesTitle)

$notesDesc = New-Object System.Windows.Forms.Label
$notesDesc.Text = "Both people on the call can see these notes. Export saves the notes plus the full output log as a text file on the Desktop."
$notesDesc.Font = $FontDesc
$notesDesc.ForeColor = $ColorSubText
$notesDesc.Size = New-Object System.Drawing.Size(($colW - 32), 34)
$notesDesc.Location = New-Object System.Drawing.Point(16, 42)
$notesCard.Controls.Add($notesDesc)

$script:NotesBox = New-Object System.Windows.Forms.TextBox
$script:NotesBox.Multiline = $true
$script:NotesBox.BackColor = $ColorConsoleBg
$script:NotesBox.ForeColor = $ColorText
$script:NotesBox.Font = $FontDesc
$script:NotesBox.BorderStyle = "FixedSingle"
$script:NotesBox.Location = New-Object System.Drawing.Point(16, 80)
$script:NotesBox.Size = New-Object System.Drawing.Size(($colW - 32), 100)
$notesCard.Controls.Add($script:NotesBox)

$exportBtn = New-Object System.Windows.Forms.Button
$exportBtn.Text = "Export Report to Desktop"
$exportBtn.Font = $FontBtn
$exportBtn.ForeColor = $ColorText
$exportBtn.BackColor = $ColorAccentDim
$exportBtn.FlatStyle = "Flat"
$exportBtn.FlatAppearance.BorderSize = 0
$exportBtn.Size = New-Object System.Drawing.Size(($colW - 32), 32)
$exportBtn.Location = New-Object System.Drawing.Point(16, 188)
$exportBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$exportBtn.Add_Click({ Invoke-ExportReport })
$notesCard.Controls.Add($exportBtn)

$gridPanel.Controls.Add($notesCard)

# ---------------------------------------------------------------------------
# Consent / intro screen - shown before the dashboard is accessible.
# Explains, in plain language, what this tool actually does and does not do.
# ---------------------------------------------------------------------------
$introTop = $titleBar.Height
$introPanel = New-Object System.Windows.Forms.Panel
$introPanel.Location = New-Object System.Drawing.Point(0, $introTop)
$introPanel.Size = New-Object System.Drawing.Size($form.Width, ($form.Height - $introTop))
$introPanel.BackColor = $ColorBackground

$script:IntroParticles = @()
$introRand = New-Object System.Random
for ($i = 0; $i -lt 55; $i++) {
    $script:IntroParticles += [PSCustomObject]@{
        X  = $introRand.Next(0, $introPanel.Width)
        Y  = $introRand.Next(0, $introPanel.Height)
        VX = (($introRand.Next(-8, 8)) / 10.0)
        VY = (($introRand.Next(-8, 8)) / 10.0)
        R  = $introRand.Next(1, 3)
    }
}

$introPanel.Add_Paint({
    param($s, $e)
    $g = $e.Graphics
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $brush = New-Object System.Drawing.SolidBrush($ColorAccent)
    foreach ($p in $script:IntroParticles) {
        $g.FillEllipse($brush, [float]$p.X, [float]$p.Y, [float]($p.R * 2), [float]($p.R * 2))
    }
    $brush.Dispose()
})

$introTimer = New-Object System.Windows.Forms.Timer
$introTimer.Interval = 16
$introTimer.Add_Tick({
    if ($introPanel.Visible) {
        foreach ($p in $script:IntroParticles) {
            $p.X += $p.VX
            $p.Y += $p.VY
            if ($p.X -le 0 -or $p.X -ge $introPanel.Width)  { $p.VX = -$p.VX }
            if ($p.Y -le 0 -or $p.Y -ge $introPanel.Height) { $p.VY = -$p.VY }
        }
        $introPanel.Invalidate()
    }
})
$introTimer.Start()

# Centered consent card
$cardW = 620
$cardH = 480
$introCard = New-Object System.Windows.Forms.Panel
$introCard.Size = New-Object System.Drawing.Size($cardW, $cardH)
$introCard.Location = New-Object System.Drawing.Point((($introPanel.Width - $cardW) / 2), (($introPanel.Height - $cardH) / 2))
$introCard.BackColor = $ColorCard
$introCard.Add_Paint({
    param($s, $e)
    $pen = New-Object System.Drawing.Pen($ColorAccentDim, 1)
    $e.Graphics.DrawRectangle($pen, 0, 0, ($introCard.Width - 1), ($introCard.Height - 1))
    $pen.Dispose()
})

$introIcon = New-Object System.Windows.Forms.Label
$introIcon.Text = "🛡️"
$introIcon.Font = New-Object System.Drawing.Font("Segoe UI", 26)
$introIcon.AutoSize = $true
$introIcon.BackColor = [System.Drawing.Color]::Transparent
$introIcon.Location = New-Object System.Drawing.Point(30, 28)
$introCard.Controls.Add($introIcon)

$introTitle = New-Object System.Windows.Forms.Label
$introTitle.Text = "Before You Continue"
$introTitle.Font = New-Object System.Drawing.Font("Segoe UI", 17, [System.Drawing.FontStyle]::Bold)
$introTitle.ForeColor = $ColorText
$introTitle.AutoSize = $true
$introTitle.BackColor = [System.Drawing.Color]::Transparent
$introTitle.Location = New-Object System.Drawing.Point(84, 24)
$introCard.Controls.Add($introTitle)

$introSub = New-Object System.Windows.Forms.Label
$introSub.Text = "AstroSSTool — please read this before using the tool"
$introSub.Font = $FontSub
$introSub.ForeColor = $ColorSubText
$introSub.AutoSize = $true
$introSub.BackColor = [System.Drawing.Color]::Transparent
$introSub.Location = New-Object System.Drawing.Point(84, 54)
$introCard.Controls.Add($introSub)

$introBody = New-Object System.Windows.Forms.Label
$introBody.Text =
"This tool only reads information that is already visible through built-in Windows utilities, such as Task Manager, Event Viewer, and Resource Monitor.

It does not inject code into, or attach to, any other running program. It does not modify, delete, or clear any files, logs, caches, or prefetch data. It does not require administrator rights to view its results.

Every module's source code is contained in this single script. You are welcome to open it in a text editor and read exactly what each button does, before or during use.

By continuing, you confirm you understand what this tool does and does not do."
$introBody.Font = $FontDesc
$introBody.ForeColor = $ColorText
$introBody.Size = New-Object System.Drawing.Size(($cardW - 60), 260)
$introBody.Location = New-Object System.Drawing.Point(30, 96)
$introCard.Controls.Add($introBody)

$introCheck = New-Object System.Windows.Forms.CheckBox
$introCheck.Text = "  I have read the above and understand what this tool does"
$introCheck.Font = $FontDesc
$introCheck.ForeColor = $ColorSubText
$introCheck.AutoSize = $true
$introCheck.Location = New-Object System.Drawing.Point(30, 366)
$introCard.Controls.Add($introCheck)

$introCancelBtn = New-Object System.Windows.Forms.Button
$introCancelBtn.Text = "Cancel"
$introCancelBtn.Font = $FontBtn
$introCancelBtn.ForeColor = $ColorSubText
$introCancelBtn.BackColor = $ColorBadgeBg
$introCancelBtn.FlatStyle = "Flat"
$introCancelBtn.FlatAppearance.BorderColor = $ColorCardBorder
$introCancelBtn.FlatAppearance.BorderSize = 1
$introCancelBtn.Size = New-Object System.Drawing.Size(180, 38)
$introCancelBtn.Location = New-Object System.Drawing.Point(30, 410)
$introCancelBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$introCancelBtn.Add_Click({ $form.Close() })
$introCard.Controls.Add($introCancelBtn)

$introContinueBtn = New-Object System.Windows.Forms.Button
$introContinueBtn.Text = "I Understand — Continue"
$introContinueBtn.Font = $FontBtn
$introContinueBtn.ForeColor = $ColorText
$introContinueBtn.BackColor = $ColorCardBorder
$introContinueBtn.FlatStyle = "Flat"
$introContinueBtn.FlatAppearance.BorderSize = 0
$introContinueBtn.Size = New-Object System.Drawing.Size(230, 38)
$introContinueBtn.Location = New-Object System.Drawing.Point(($cardW - 260), 410)
$introContinueBtn.Enabled = $false
$introContinueBtn.Cursor = [System.Windows.Forms.Cursors]::No
$introCard.Controls.Add($introContinueBtn)

$introCheck.Add_CheckedChanged({
    if ($introCheck.Checked) {
        $introContinueBtn.Enabled = $true
        $introContinueBtn.BackColor = $ColorAccentDim
        $introContinueBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
    } else {
        $introContinueBtn.Enabled = $false
        $introContinueBtn.BackColor = $ColorCardBorder
        $introContinueBtn.Cursor = [System.Windows.Forms.Cursors]::No
    }
})

$introContinueBtn.Add_Click({
    $introPanel.Visible = $false
    $heroPanel.Visible = $true
    $gridPanel.Visible = $true
    $consolePanel.Visible = $true
    Write-Log "Consent acknowledged. Dashboard unlocked."
})

$introPanel.Controls.Add($introCard)
$form.Controls.Add($introPanel)
$introPanel.BringToFront()

# Hide the dashboard until consent is given
$heroPanel.Visible = $false
$gridPanel.Visible = $false
$consolePanel.Visible = $false

# ---------------------------------------------------------------------------
# Startup log message
# ---------------------------------------------------------------------------
Write-Log "AstroSSTool ready. All modules are read-only: nothing is modified, injected, or deleted."
Write-Log "Source is fully visible in this script - review any module before running it."

if (Start-BackgroundMusic -Path $MusicFile) {
    Write-Log "Background music playing from theme.wav"
} else {
    Write-Log "No theme.wav found next to the script - running without music." "Warn"
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
[System.Windows.Forms.Application]::EnableVisualStyles()
$form.Add_FormClosed({
    $particleTimer.Stop(); $particleTimer.Dispose()
    $introTimer.Stop(); $introTimer.Dispose()
    Stop-BackgroundMusic
})
[void]$form.ShowDialog()
