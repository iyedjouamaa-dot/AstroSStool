Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll")]
    public static extern IntPtr SetWindowRgn(IntPtr hWnd, IntPtr hRgn, bool bRedraw);
}
"@

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$installDir = "$env:USERPROFILE\Downloads\AstroSSTool"

# INTEGRATED TOOL DATA (AstroSSTool + Cheesy's Tools Merged safely)
$ToolData = @(
    @{ Name="PrefetchView";       Desc="Parses prefetch, extracts file info";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/PrefetchView/releases/latest" },
    @{ Name="BAMReveal";              Desc="Parses BAM forensic artefact";                 Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/BAMReveal/releases/latest" },
    @{ Name="StringsParser";          Desc="Strings + YARA + signatures scanner";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/StringsParser/releases/latest" },
    @{ Name="Fileless";               Desc="Detects fileless via eventlog + memdump";      Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/Fileless/releases/latest" },
    @{ Name="DPS-Analyzer";           Desc="Analyzes DPS memory";                          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/DPS-Analyzer/releases/latest" },
    @{ Name="UserAssistView";         Desc="Parses UserAssist registry artifact";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/UserAssistView/releases/latest" },
    @{ Name="JournalParser";          Desc="Parses NTFS USNJournal entries";               Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/JournalParser/releases/latest" },
    @{ Name="InjGen";                 Desc="Detects JNI/JVMTI memory injections";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/InjGen/releases/latest" },
    @{ Name="USBDetector";            Desc="Detects USB device history";                   Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/USBDetector/releases/latest" },
    @{ Name="PFTrace";                Desc="Rundll32/Regsvr32 prefetch analysis";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/PFTrace/releases/latest" },
    @{ Name="CheckDeletedUSN";        Desc="Compares USN timestamp vs boot time";          Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/CheckDeletedUSN/releases/latest" },
    @{ Name="JARParser";              Desc="Parses JAR prefetch, DcomLaunch strings";      Category="Orbdiff";    Type="GitHub"; URL="https://github.com/Orbdiff/JARParser/releases/latest" },
    @{ Name="BAM-parser";             Desc="Parses BAM entries for execution history";     Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/BAM-parser/releases/latest" },
    @{ Name="PathsParser";            Desc="Extracts and analyzes executable paths";       Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/PathsParser/releases/latest" },
    @{ Name="JournalTrace";           Desc="Traces file activity via USN journal";         Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/JournalTrace/releases/latest" },
    @{ Name="KernelLiveDumpTool";     Desc="Captures live kernel memory dump";             Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/KernelLiveDumpTool/releases/latest" },
    @{ Name="BamDeletedKeys";         Desc="Finds deleted BAM registry keys";              Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/BamDeletedKeys/releases/latest" },
    @{ Name="Espouken Tool";          Desc="All-in-one SS forensics toolkit";              Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/Tool/releases/latest" },
    @{ Name="pcasvc-executed";        Desc="Extracts PCA service execution records";       Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/pcasvc-executed/releases/latest" },
    @{ Name="process-parser";         Desc="Parses process execution artefacts";           Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/process-parser/releases/latest" },
    @{ Name="prefetch-parser";        Desc="Parses Windows prefetch files";                Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/prefetch-parser/releases/latest" },
    @{ Name="ActivitiesCache";        Desc="Parses ActivitiesCache execution history";     Category="Spokwn";     Type="GitHub"; URL="https://github.com/spokwn/ActivitiesCache-execution/releases/latest" },
    @{ Name="MeowDoomsdayFucker";     Desc="Detects Doomsday cheat artefacts";             Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowDoomsdayFucker/releases/latest" },
    @{ Name="MeowModAnalyzer";        Desc="Analyzes mod files for suspicious content";    Category="Tonynoh";    Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/MeowTonynoh/MeowModAnalyzer/main/MeowModAnalyzer.ps1")' },
    @{ Name="MeowResolver";           Desc="Resolves obfuscated strings in binaries";      Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowResolver/releases/latest" },
    @{ Name="MeowNovowareFucker";     Desc="Detects Novoware cheat artefacts";             Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowNovowareFucker/releases/latest" },
    @{ Name="MeowImportsChecker";     Desc="Checks PE imports for suspicious DLLs";        Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowImportsChecker/releases/latest" },
    @{ Name="MeowClientsFucker";      Desc="Detects known cheat client artefacts";         Category="Tonynoh";    Type="GitHub"; URL="https://github.com/MeowTonynoh/MeowClientsFucker/releases/latest" },
    @{ Name="PSHunter";               Desc="Hunts suspicious PowerShell activity";         Category="Praiselily"; Type="GitHub"; URL="https://github.com/praiselily/PSHunter/releases/latest" },
    @{ Name="AltDetector";            Desc="Detects alternate account artefacts";          Category="Praiselily"; Type="GitHub"; URL="https://github.com/praiselily/AltDetector/releases/latest" },
    @{ Name="WeHateFakers";           Desc="Checks hotspot / tethering logs";              Category="Praiselily"; Type="Cmd";    Command='iwr https://raw.githubusercontent.com/praiselily/WeHateFakers/refs/heads/main/HotspotLogs.ps1 | iex' },
    @{ Name="CommonDirectories";      Desc="Lists files in common suspicious dirs";        Category="Praiselily"; Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/CommonDirectories.ps1")' },
    @{ Name="HarddiskConverter";      Desc="Converts harddisk identifiers for review";     Category="Praiselily"; Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/HarddiskConverter.ps1")' },
    @{ Name="Services";               Desc="Lists and analyzes running services";          Category="Praiselily"; Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Services.ps1")' },
    @{ Name="SignedScheduledTasks";   Desc="Finds unsigned / suspicious scheduled tasks";  Category="Praiselily"; Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Signed-Scheduled-Tasks.ps1")' },
    @{ Name="RL ModAnalyzer";         Desc="Analyzes mod files for cheat indicators";      Category="RedLotus";   Type="GitHub"; URL="https://github.com/ItzIceHere/RedLotus-Mod-Analyzer/releases/latest" },
    @{ Name="RL TaskSentinel";        Desc="Monitors scheduled tasks for anomalies";       Category="RedLotus";   Type="GitHub"; URL="https://github.com/ItzIceHere/RedLotus-Task-Sentinel/releases/latest" },
    @{ Name="RL AltChecker";          Desc="Checks for alternate account indicators";      Category="RedLotus";   Type="GitHub"; URL="https://github.com/ItzIceHere/RedLotusAltChecker/releases/latest" },
    @{ Name="ComputerActivityView";   Desc="Timeline of computer activity events";         Category="Others";     Type="Web";    URL="https://www.nirsoft.net/utils/computer_activity_view.html" },
    @{ Name="AmcacheParser";          Desc="Parses AMCache with YARA + signatures";        Category="Others";     Type="Web";    URL="https://download.ericzimmermanstools.com/net9/AmcacheParser.zip" },
    @{ Name="SystemInformer";         Desc="Advanced process and kernel inspector";        Category="Others";     Type="Link";   URL="https://www.systeminformer.com/canary" },
    @{ Name="DIE-engine";             Desc="Detects file type, packer, compiler";          Category="Others";     Type="Web";    URL="https://github.com/horsicq/DIE-engine/releases" },
    @{ Name="MacroDetector";          Desc="Detects macro / clicker software traces";      Category="Others";     Type="Cmd";    Command='iex (iwr "https://raw.githubusercontent.com/NiccBlahh/MacroDetector/refs/heads/main/MacroDetector.ps1")' },
    @{ Name="Jarabel";                Desc="Locates .jar files with detailed checks";      Category="Others";     Type="GitHub"; URL="https://github.com/nay-cat/Jarabel/releases/latest" },
    @{ Name="Luyten";                 Desc="Open source Java decompiler GUI (Procyon)";    Category="Others";     Type="GitHub"; URL="https://github.com/deathmarine/Luyten/releases/latest" },
    @{ Name="VMAware";                Desc="Advanced VM detection library and tool";       Category="Others";     Type="GitHub"; URL="https://github.com/kernelwernel/VMAware/releases/latest" },
    @{ Name="Velociraptor";           Desc="Endpoint DFIR and threat hunting agent";       Category="Others";     Type="GitHub"; URL="https://github.com/Velocidex/velociraptor/releases/latest" },
    @{ Name="NTFS Parser";            Desc="NTFS forensics: MFT, Bitlocker, USN";          Category="Others";     Type="GitHub"; URL="https://github.com/thewhiteninja/ntfstool/releases/latest" },
    @{ Name="Hayabusa";               Desc="Fast forensics timeline generator";            Category="Others";     Type="GitHub"; URL="https://github.com/Yamato-Security/hayabusa/releases/latest" },
    @{ Name="Everything";             Desc="Instant filename search engine for Windows";   Category="Others";     Type="Link";   URL="https://www.voidtools.com/downloads/" },
    @{ Name="HxD";                    Desc="Fast hex editor with disk and RAM editing";    Category="Others";     Type="Link";   URL="https://mh-nexus.de/en/hxd/" },
    @{ Name="bstrings";               Desc="Searches strings with regex + YARA";           Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/bstrings.zip" },
    @{ Name="JLECmd";                 Desc="Parses Jump List files (CLI)";                 Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/JLECmd.zip" },
    @{ Name="JumpListExplorer";       Desc="GUI explorer for Jump List artefacts";         Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/JumpListExplorer.zip" },
    @{ Name="MFTECmd";                Desc="Parses MFT, UsnJrnl, LogFile, Boot";           Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/MFTECmd.zip" },
    @{ Name="PECmd";                  Desc="Parses Windows prefetch files (CLI)";          Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/PECmd.zip" },
    @{ Name="RecentFileCacheParser";  Desc="Parses RecentFileCache.bcf artefact";          Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/RecentFileCacheParser.zip" },
    @{ Name="RegistryExplorer";       Desc="GUI explorer for registry hives";              Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/RegistryExplorer.zip" },
    @{ Name="ShellBagsExplorer";      Desc="GUI explorer for ShellBags artefacts";         Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/ShellBagsExplorer.zip" },
    @{ Name="SrumECmd";               Desc="Parses SRUM database for usage data";          Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/SrumECmd.zip" },
    @{ Name="TimelineExplorer";       Desc="GUI viewer for CSV timeline output";           Category="Zimmerman";  Type="Web";    URL="https://download.ericzimmermanstools.com/net9/TimelineExplorer.zip" },
    @{ Name="FullEventLogView";       Desc="Views all Windows event log entries";          Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/fulleventlogview.zip" },
    @{ Name="NetworkUsageView";       Desc="Shows network usage per process";              Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/networkusageview.zip" },
    @{ Name="BrowserDownloadsView";   Desc="Lists all browser download history";           Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/browserdownloadsview.zip" },
    @{ Name="AlternateStreamView";    Desc="Reveals hidden NTFS alternate streams";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/alternatestreamview.zip" },
    @{ Name="USBDeview";              Desc="Lists all USB devices ever connected";         Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/usbdeview.zip" },
    @{ Name="OpenSaveFilesView";      Desc="Shows files opened/saved via dialogs";         Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/opensavefilesview.zip" },
    @{ Name="ExecutedProgramsList";   Desc="Lists programs run from various sources";      Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/executedprogramslist.zip" },
    @{ Name="TaskSchedulerView";      Desc="Views all scheduled tasks and history";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/taskschedulerview.zip" },
    @{ Name="JumpListsView";          Desc="Views Jump List recent/frequent files";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/jumplistsview.zip" },
    @{ Name="WinPrefetchView";        Desc="Views Windows prefetch file details";          Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/winprefetchview.zip" },
    @{ Name="RegScanner";             Desc="Scans registry for values / patterns";         Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/regscanner.zip" },
    @{ Name="ShellBagsView";          Desc="Views ShellBags folder access history";        Category="NirSoft";    Type="Web";    URL="https://www.nirsoft.net/utils/shellbagsview.zip" },
    @{ Name="NET 9.0";                Desc="Microsoft .NET 9 SDK runtime";                 Category="Dependencies"; Type="Web"; URL="https://download.visualstudio.microsoft.com/download/pr/92dba916-bc51-4e76-8b0e-d41d37ce5fa4/ab08f3e95bf7a3d3da336a7e8c8eca63/dotnet-sdk-9.0.203-win-x64.exe" },
    @{ Name="NET 10.0";               Desc="Microsoft .NET 10 runtime";                    Category="Dependencies"; Type="Web"; URL="https://download.visualstudio.microsoft.com/download/pr/b3f93f0e-9e5e-4b4c-a4c4-36db0c4b0e3e/dotnet-runtime-10.0.0-win-x64.exe" },
    @{ Name="VSRedist";               Desc="Visual C++ redistributable (x64)";             Category="Dependencies"; Type="Web"; URL="https://aka.ms/vs/17/release/vc_redist.x64.exe" }
)
