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
# COMPREHENSIVE TOOL DATA DATABASE ($ToolData)
# ==============================================================================
$Global:ToolData = @(
    @{ Name="PrefetchView";        Desc="Parses prefetch, extracts file info";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/PrefetchView/releases/latest" },
    @{ Name="BAMReveal";             Desc="Parses BAM forensic artefact";                 Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/BAMReveal/releases/latest" },
    @{ Name="StringsParser";         Desc="Strings + YARA + signatures scanner";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/StringsParser/releases/latest" },
    @{ Name="Fileless";              Desc="Detects fileless via eventlog + memdump";      Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/Fileless/releases/latest" },
    @{ Name="DPS-Analyzer";          Desc="Analyzes DPS memory";                          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/DPS-Analyzer/releases/latest" },
    @{ Name="UserAssistView";        Desc="Parses UserAssist registry artifact";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/UserAssistView/releases/latest" },
    @{ Name="JournalParser";         Desc="Parses NTFS USNJournal entries";               Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/JournalParser/releases/latest" },
    @{ Name="InjGen";                Desc="Detects JNI/JVMTI memory injections";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/InjGen/releases/latest" },
    @{ Name="USBDetector";           Desc="Detects USB device history";                   Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/USBDetector/releases/latest" },
    @{ Name="PFTrace";               Desc="Rundll32/Regsvr32 prefetch analysis";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/PFTrace/releases/latest" },
    @{ Name="CheckDeletedUSN";       Desc="Compares USN timestamp vs boot time";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/CheckDeletedUSN/releases/latest" },
    @{ Name="JARParser";             Desc="Parses JAR prefetch, DcomLaunch strings";      Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/JARParser/releases/latest" },
    @{ Name="BAM-parser";            Desc="Parses BAM entries for execution history";     Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/BAM-parser/releases/latest" },
    @{ Name="PathsParser";           Desc="Extracts and analyzes executable paths";       Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/PathsParser/releases/latest" },
    @{ Name="JournalTrace";          Desc="Traces file activity via USN journal";         Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/JournalTrace/releases/latest" },
    @{ Name="KernelLiveDumpTool";    Desc="Captures live kernel memory dump";             Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/KernelLiveDumpTool/releases/latest" },
    @{ Name="BamDeletedKeys";        Desc="Finds deleted BAM registry keys";              Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/BamDeletedKeys/releases/latest" },
    @{ Name="Espouken Tool";         Desc="All-in-one SS forensics toolkit";              Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/Tool/releases/latest" },
    @{ Name="pcasvc-executed";       Desc="Extracts PCA service execution records";       Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/pcasvc-executed/releases/latest" },
    @{ Name="process-parser";        Desc="Parses process execution artefacts";           Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/process-parser/releases/latest" },
    @{ Name="prefetch-parser";       Desc="Parses Windows prefetch files";                Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/prefetch-parser/releases/latest" },
    @{ Name="ActivitiesCache";       Desc="Parses ActivitiesCache execution history";     Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/ActivitiesCache-execution/releases/latest" },
    @{ Name="MeowDoomsdayFucker";    Desc="Detects Doomsday cheat artefacts";             Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowDoomsdayFucker/releases/latest" },
    @{ Name="MeowModAnalyzer";       Desc="Analyzes mod files for suspicious content";    Category="Tonynoh";    Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/MeowTonynoh/MeowModAnalyzer/main/MeowModAnalyzer.ps1")' },
    @{ Name="MeowResolver";          Desc="Resolves obfuscated strings in binaries";      Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowResolver/releases/latest" },
    @{ Name="MeowNovowareFucker";    Desc="Detects Novoware cheat artefacts";             Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowNovowareFucker/releases/latest" },
    @{ Name="MeowImportsChecker";    Desc="Checks PE imports for suspicious DLLs";        Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowImportsChecker/releases/latest" },
    @{ Name="MeowClientsFucker";     Desc="Detects known cheat client artefacts";         Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowClientsFucker/releases/latest" },
    @{ Name="PSHunter";              Desc="Hunts suspicious PowerShell activity";         Category="Praiselily"; Type="GitHub"; URL="https://github.com/praiselily/PSHunter/releases/latest" },
    @{ Name="AltDetector";           Desc="Detects alternate account artefacts";          Category="Praiselily"; Type="GitHub"; URL="https://github.com/praiselily/AltDetector/releases/latest" },
    @{ Name="WeHateFakers";          Desc="Checks hotspot / tethering logs";              Category="Praiselily"; Type="Cmd";    Command='iwr https://raw.githubusercontent.com/praiselily/WeHateFakers/refs/heads/main/HotspotLogs.ps1 | iex' },
    @{ Name="CommonDirectories";     Desc="Lists files in common suspicious dirs";        Category="Praiselily"; Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/CommonDirectories.ps1")' },
    @{ Name="HarddiskConverter";     Desc="Converts harddisk identifiers for review";     Category="Praiselily"; Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/HarddiskConverter.ps1")' },
    @{ Name="Services";              Desc="Lists and analyzes running services";          Category="Praiselily"; Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Services.ps1")' },
    @{ Name="SignedScheduledTasks";  Desc="Finds unsigned / suspicious scheduled tasks";  Category="Praiselily"; Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Signed-Scheduled-Tasks.ps1")' },
    @{ Name="RL ModAnalyzer";        Desc="Analyzes mod files for cheat indicators";      Category="RedLotus";   Type="GitHub"; URL="https://github.com/ItzIceHere/RedLotus-Mod-Analyzer/releases/latest" },
    @{ Name="RL TaskSentinel";       Desc="Monitors scheduled tasks for anomalies";       Category="RedLotus";   Type="GitHub"; URL="https://github.com/ItzIceHere/RedLotus-Task-Sentinel/releases/latest" },
    @{ Name="RL AltChecker";          Desc="Checks for alternate account indicators";      Category="RedLotus";   Type="GitHub"; URL="https://github.com/ItzIceHere/RedLotusAltChecker/releases/latest" },
    @{ Name="ComputerActivityView";  Desc="Timeline of computer activity events";         Category="Others";     Type="Web";    URL="https://www.nirsoft.net/utils/computer_activity_view.html" },
    @{ Name="AmcacheParser";          Desc="Parses AMCache with YARA + signatures";        Category="Others";     Type="Web";    URL="https://download.ericzimmermanstools.com/net9/AmcacheParser.zip" },
    @{ Name="SystemInformer";        Desc="Advanced process and kernel inspector";        Category="Others";     Type="Link";   URL="https://www.systeminformer.com/canary" },
    @{ Name="DIE-engine";            Desc="Detects file type, packer, compiler";          Category="Others";     Type="Web";    URL="https://github.com/horsicq/DIE-engine/releases" },
    @{ Name="MacroDetector";         Desc="Detects macro / clicker software traces";      Category="Others";     Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/NiccBlahh/MacroDetector/refs/heads/main/MacroDetector.ps1")' },
    @{ Name="Jarabel";               Desc="Locates .jar files with detailed checks";      Category="Others";     Type="GitHub"; URL="https://github.com/nay-cat/Jarabel/releases/latest" },
    @{ Name="Luyten";                Desc="Open source Java decompiler GUI (Procyon)";    Category="Others";     Type="GitHub"; URL="https://github.com/deathmarine/Luyten/releases/latest" },
    @{ Name="VMAware";               Desc="Advanced VM detection library and tool";       Category="Others";     Type="GitHub"; URL="https://github.com/kernelwernel/VMAware/releases/latest" },
    @{ Name="Velociraptor";          Desc="Endpoint DFIR and threat hunting agent";       Category="Others";     Type="GitHub"; URL="https://github.com/Velocidex/velociraptor/releases/latest" },
    @{ Name="NTFS Parser";           Desc="NTFS forensics: MFT, Bitlocker, USN";          Category="Others";     Type="GitHub"; URL="https://github.com/thewhiteninja/ntfstool/releases/latest" },
    @{ Name="Hayabusa";              Desc="Fast forensics timeline generator";            Category="Others";     Type="GitHub"; URL="https://github.com/Yamato-Security/hayabusa/releases/latest" },
    @{ Name="Everything";            Desc="Instant filename search engine for Windows";   Category="Others";     Type="Link";   URL="https://www.voidtools.com/downloads/" },
    @{ Name="HxD";                   Desc="Fast hex editor with disk and RAM editing";    Category="Others";     Type="Link";   URL="https://mh-nexus.de/en/hxd/" },
    @{ Name="bstrings";              Desc="Searches strings with regex + YARA";           Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/bstrings.zip" },
    @{ Name="JLECmd";                Desc="Parses Jump List files (CLI)";                 Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/JLECmd.zip" },
    @{ Name="JumpListExplorer";      Desc="GUI explorer for Jump List artefacts";         Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/JumpListExplorer.zip" },
    @{ Name="MFTECmd";               Desc="Parses MFT, UsnJrnl, LogFile, Boot";           Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/MFTECmd.zip" },
    @{ Name="PECmd";                 Desc="Parses Windows prefetch files (CLI)";          Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/PECmd.zip" },
    @{ Name="RecentFileCacheParser"; Desc="Parses RecentFileCache.bcf artefact";          Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/RecentFileCacheParser.zip" },
    @{ Name="RegistryExplorer";      Desc="GUI explorer for registry hives";              Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/RegistryExplorer.zip" },
    @{ Name="ShellBagsExplorer";     Desc="GUI explorer for ShellBags artefacts";         Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/ShellBagsExplorer.zip" },
    @{ Name="SrumECmd";              Desc="Parses SRUM database for usage data";          Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/SrumECmd.zip" },
    @{ Name="TimelineExplorer";      Desc="GUI viewer for CSV timeline output";           Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/TimelineExplorer.zip" },
    @{ Name="FullEventLogView";      Desc="Views all Windows event log entries";          Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/fulleventlogview.zip" },
    @{ Name="NetworkUsageView";      Desc="Shows network usage per process";              Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/networkusageview.zip" },
    @{ Name="BrowserDownloadsView";  Desc="Lists all browser download history";           Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/browserdownloadsview.zip" },
    @{ Name="AlternateStreamView";   Desc="Reveals hidden NTFS alternate streams";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/alternatestreamview.zip" },
    @{ Name="USBDeview";             Desc="Lists all USB devices ever connected";         Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/usbdeview.zip" },
    @{ Name="OpenSaveFilesView";     Desc="Shows files opened/saved via dialogs";         Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/opensavefilesview.zip" },
    @{ Name="ExecutedProgramsList";  Desc="Lists programs run from various sources";      Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/executedprogramslist.zip" },
    @{ Name="TaskSchedulerView";     Desc="Views all scheduled tasks and history";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/taskschedulerview.zip" },
    @{ Name="JumpListsView";         Desc="Views Jump List recent/frequent files";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/jumplistsview.zip" },
    @{ Name="WinPrefetchView";       Desc="Views Windows prefetch file details";          Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/winprefetchview.zip" },
    @{ Name="RegScanner";            Desc="Scans registry for values / patterns";         Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/regscanner.zip" },
    @{ Name="ShellBagsView";         Desc="Views ShellBags folder access history";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/shellbagsview.zip" },
    @{ Name="NET 9.0";               Desc="Microsoft .NET 9 SDK runtime";                 Category="Dependencies"; Type="Web"; URL="https://download.visualstudio.microsoft.com/download/pr/92dba916-bc51-4e76-8b0e-d41d37ce5fa4/ab08f3e95bf7a3d3da336a7e8c8eca63/dotnet-sdk-9.0.203-win-x64.exe" },
    @{ Name="NET 10.0";              Desc="Microsoft .NET 10 runtime";                    Category="Dependencies"; Type="Web"; URL="https://download.visualstudio.microsoft.com/download/pr/b3f93f0e-9e5e-4b4c-a4c4-36db0c4b0e3e/dotnet-runtime-10.0.0-win-x64.exe" },
    @{ Name="VSRedist";              Desc="Visual C++ redistributable (x64)";             Category="Dependencies"; Type="Web"; URL="https://aka.ms/vs/17/release/vc_redist.x64.exe" }
)

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
$form.Size = New-Object System.Drawing.Size(1150, 750)
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
$titleBar.Size = New-Object System.Drawing.Size(1150, 38)
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
$btnClose.Location = New-Object System.Drawing.Point(1110, 0)
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
$btnMin.Location = New-Object System.Drawing.Point(1070, 0)
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
$canvasPanel.Size = New-Object System.Drawing.Size(1150, 712)
$canvasPanel.Location = New-Object System.Drawing.Point(0, 38)
$canvasPanel.BackColor = $cBg

$prop = [System.Windows.Forms.Control].GetProperty("DoubleBuffered", [System.Reflection.BindingFlags]"NonPublic, Instance")
$prop.SetValue($canvasPanel, $true, $null)
$form.Controls.Add($canvasPanel)

# Particles Engine
$particles = @()
for ($i = 0; $i -lt 40; $i++) {
    $particles += [PSCustomObject]@{
        X  = Get-Random -Minimum 10 -Maximum 1140
        Y  = Get-Random -Minimum 10 -Maximum 700
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

        if ($p.X -lt 0 -or $p.X -gt 1150) { $p.VX *= -1 }
        if ($p.Y -lt 0 -or $p.Y -gt 712) { $p.VY *= -1 }

        $g.FillEllipse($brush, [float]$p.X, [float]$p.Y, [float]($p.R * 2), [float]($p.R * 2))
    }
    $brush.Dispose()
})

# ==============================================================================
# UI COMPONENTS (Search Bar & Scrollable Tool Grid Container)
# ==============================================================================
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(30, 20)
$searchBox.Size = New-Object System.Drawing.Size(1085, 26)
$searchBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#13111c")
$searchBox.ForeColor = [System.Drawing.Color]::White
$searchBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$canvasPanel.Controls.Add($searchBox)

# Placeholder text behavior
$searchBox.Text = "Search tools by name, description, or category..."
$searchBox.ForeColor = [System.Drawing.Color]::Gray
$searchBox.Add_GotFocus({
    if ($searchBox.Text -eq "Search tools by name, description, or category...") {
        $searchBox.Text = ""
        $searchBox.ForeColor = [System.Drawing.Color]::White
    }
})
$searchBox.Add_LostFocus({
    if ([string]::IsNullOrWhiteSpace($searchBox.Text)) {
        $searchBox.Text = "Search tools by name, description, or category..."
        $searchBox.ForeColor = [System.Drawing.Color]::Gray
    }
})

# Scrollable Panel for Tools
$flowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowPanel.Location = New-Object System.Drawing.Point(30, 60)
$flowPanel.Size = New-Object System.Drawing.Size(1090, 470)
$flowPanel.AutoScroll = $true
$flowPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$flowPanel.WrapContents = $true
$canvasPanel.Controls.Add($flowPanel)

# CONSOLE LOG BOX
$console = New-Object System.Windows.Forms.TextBox
$console.Multiline = $true
$console.ReadOnly = $true
$console.Size = New-Object System.Drawing.Size(1085, 130)
$console.Location = New-Object System.Drawing.Point(30, 545)
$console.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#050507")
$console.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#4ade80")
$console.Font = New-Object System.Drawing.Font("Consolas", 9)
$console.Text = "[00:00:01] AstroSSTool v2.0 // Loaded `$ToolData database successfully.`r`n[00:00:01] Ready for forensic queries."
$canvasPanel.Controls.Add($console)

function Write-ConsoleLog {
    param($msg)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $console.AppendText("`r`n[$timestamp] $msg")
    $console.SelectionStart = $console.Text.Length
    $console.ScrollToCaret()
}

# ==============================================================================
# POPULATE TOOL CARDS FUNCTION
# ==============================================================================
function Load-ToolCards {
    param($filter = "")
    $flowPanel.Controls.Clear()

    foreach ($t in $Global:ToolData) {
        if (-not [string]::IsNullOrEmpty($filter) -and $filter -ne "Search tools by name, description, or category...") {
            if ($t.Name -notmatch $filter -and $t.Desc -notmatch $filter -and $t.Category -notmatch $filter) {
                continue
            }
        }

        $card = New-Object System.Windows.Forms.Panel
        $card.Size = New-Object System.Drawing.Size(345, 145)
        $card.Margin = New-Object System.Windows.Forms.Padding(8)
        $card.BackColor = $cCardBg

        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = "$($t.Name) [$($t.Category)]"
        $lbl.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#c084fc")
        $lbl.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $lbl.Location = New-Object System.Drawing.Point(12, 12)
        $lbl.Size = New-Object System.Drawing.Size(320, 22)
        $card.Controls.Add($lbl)

        $descLbl = New-Object System.Windows.Forms.Label
        $descLbl.Text = $t.Desc
        $descLbl.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#9ca3af")
        $descLbl.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
        $descLbl.Location = New-Object System.Drawing.Point(12, 38)
        $descLbl.Size = New-Object System.Drawing.Size(320, 38)
        $card.Controls.Add($descLbl)

        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = "EXECUTE / OPEN [$($t.Type)]"
        $btn.Size = New-Object System.Drawing.Size(320, 34)
        $btn.Location = New-Object System.Drawing.Point(12, 95)
        $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $btn.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#7c3aed")
        $btn.ForeColor = [System.Drawing.Color]::White
        $btn.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
        $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btn.FlatAppearance.BorderSize = 0
        $btn.FlatAppearance.MouseOverBackColor = [System.Drawing.ColorTranslator]::FromHtml("#9333ea")
        $btn.FlatAppearance.MouseDownBackColor = [System.Drawing.ColorTranslator]::FromHtml("#6d28d9")

        # Handle Action Execution per tool type
        $toolItem = $t
        $btn.Add_Click({
            Write-ConsoleLog "Triggered action for: $($toolItem.Name) (Type: $($toolItem.Type))"
            if ($toolItem.Type -eq "GitHub" -or $toolItem.Type -eq "Web" -or $toolItem.Type -eq "Link") {
                Start-Process $toolItem.URL
                Write-ConsoleLog "Opened URL: $($toolItem.URL)"
            }
            elseif ($toolItem.Type -eq "Cmd") {
                try {
                    Write-ConsoleLog "Executing inline command script..."
                    Invoke-Expression $toolItem.Command
                } catch {
                    Write-ConsoleLog "Error executing command: $_"
                }
            }
        })

        $card.Controls.Add($btn)
        $flowPanel.Controls.Add($card)
    }
}

# Initial Population
Load-ToolCards

# Live Search Event Binding
$searchBox.Add_TextChanged({
    Load-ToolCards -filter $searchBox.Text
})

# Animation Timer
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 16
$timer.Add_Tick({ $canvasPanel.Invalidate() })
$timer.Start()

$form.Add_FormClosed({ $timer.Stop() })
[void]$form.ShowDialog()
