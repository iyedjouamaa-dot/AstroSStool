# AstroSSTool - Native PowerShell Forensic Scanner
[CmdletBinding()]
param()

$Host.UI.RawUI.WindowTitle = "AstroSSTool v1.0.0"
Clear-Host

# Theme Colors (Cosmic Purple & Cyan)
$PURPLE  = "`e[38;2;147;112;219m"
$CYAN    = "`e[38;2;0;255;255m"
$MAGENTA = "`e[38;2;255;0;255m"
$RED     = "`e[38;2;255;85;85m"
$GREEN   = "`e[38;2;85;255;85m"
$RESET   = "`e[0m"

$BANNER = @"
$$\   $$\  $$$$$$\ $$$$$$$$\ $$$$$$$\   $$$$$$\   $$$$$$\  $$$$$$$$\  $$$$$$\  $$$$$$$$\ 
$$ |  $$ |$$  __$$\\__$$  __|$$  __$$\ $$  __$$\ $$  __$$\ \__$$  __|$$  __$$\ $$  _____|
$$ |  $$ |$$ /  \__|  $$ |   $$ |  $$ |$$ /  $$ |$$ /  \__|   $$ |   $$ /  $$ |$$ |      
$$$$$$$$ |$$ |        $$ |   $$$$$$$  |$$ |  $$ |\$$$$$$\     $$ |   $$ |  $$ |$$$$$\    
$$  __$$ |$$ |        $$ |   $$  __$$< $$ |  $$ | \____$$\    $$ |   $$ |  $$ |$$  __|   
$$ |  $$ |$$ |  $$\   $$ |   $$ |  $$ |$$ |  $$ |$$\   $$ |   $$ |   $$ |  $$ |$$ |      
$$ |  $$ |\$$$$$$  |  $$ |   $$ |  $$ | $$$$$$  |\$$$$$$  |   $$ |    $$$$$$  |$$$$$$$$\ 
\__|  \__| \______/   \__|   \__|  \__| \______/  \______/    \__|    \______/ \________|
               ---  F O R E N S I C   A N T I - C H E A T   S C A N N E R  ---
"@

Write-Host "$PURPLE$BANNER$RESET"
Write-Host "$CYAN [★] Version: 1.0.0 | Repository: iyedjouamaa-dot/AstroSSTool$RESET"
Write-Host "$MAGENTA ==========================================================$RESET"

# Admin Check
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "$RED [!] FATAL: AstroSSTool must be run in Administrator PowerShell.$RESET"
    exit
}

# 1. Active Process Check
Write-Host "`n$CYAN[1/4] Scanning Active Processes...$RESET"
$processes = Get-Process | Select-Object -ExpandProperty ProcessName
if ($processes -contains "javaw") {
    Write-Host "$GREEN  [✓] Minecraft (javaw.exe) is running.$RESET"
} else {
    Write-Host "$RED  [!] Minecraft (javaw.exe) is NOT running.$RESET"
}

$badProcesses = @("vape", "drip", "koth", "cheatengine", "processhacker", "systeminformer", "doomsday", "autoclicker", "reach", "destruct")
$found = $false
foreach ($bad in $badProcesses) {
    if ($processes -like "*$bad*") {
        Write-Host "$RED  [!] FLAG: Detected running cheat process -> $bad$RESET"
        $found = $true
    }
}
if (-not $found) { Write-Host "$GREEN  [✓] No blacklisted process signatures detected.$RESET" }

# 2. Prefetch History Check
Write-Host "`n$CYAN[2/4] Checking Execution Forensics (Prefetch)...$RESET"
$prefetchPath = "C:\Windows\Prefetch"
if (Test-Path $prefetchPath) {
    $pfFiles = Get-ChildItem -Path $prefetchPath -Filter "*.pf" -ErrorAction SilentlyContinue
    if ($pfFiles.Count -lt 15) {
        Write-Host "$RED  [!] WARNING: Low Prefetch count ($($pfFiles.Count) files). Possible recent wipe/bypass attempt.$RESET"
    }
    $recent = $pfFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 5
    foreach ($file in $recent) {
        $time = $file.LastWriteTime.ToString("HH:mm:ss")
        Write-Host "  [-] Executed at $time -> $($file.Name)"
    }
} else {
    Write-Host "$RED  [!] ALERT: Prefetch directory inaccessible or disabled.$RESET"
}

# 3. NTFS USN Journal Deletion Check
Write-Host "`n$CYAN[3/4] Checking USN Journal for Recent Executable Deletions...$RESET"
try {
    $usnData = fsutil usn readjournal C: csv 2>$null
    $deletedFiles = $usnData | Where-Object { $_ -match "0x80000200|DELETE" } | Where-Object { $_ -match "\.exe|\.jar|\.dll|\.zip" }
    if ($deletedFiles) {
        $uniqueDeletes = $deletedFiles | Select-Object -First 5
        foreach ($del in $uniqueDeletes) {
            $fileName = ($del -split ",")[-1].Replace('"','')
            Write-Host "$RED  [!] ALERT: Recently deleted binary -> $fileName$RESET"
        }
    } else {
        Write-Host "$GREEN  [✓] No suspicious deletions found in USN Journal.$RESET"
    }
} catch {
    Write-Host "  [-] USN Journal query skipped."
}

# 4. Anti-Forensic Service Integrity Check
Write-Host "`n$CYAN[4/4] Checking System Service Integrity...$RESET"
foreach ($service in @("SysMain", "EventLog")) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc.Status -eq "Running") {
        Write-Host "$GREEN  [✓] Service $service is RUNNING.$RESET"
    } else {
        Write-Host "$RED  [!] ALERT: Service $service is STOPPED or DISABLED.$RESET"
    }
}

Write-Host "$MAGENTA `n ==========================================================$RESET"
Write-Host "$CYAN [★] SCAN COMPLETED SUCCESSFULLY$RESET"
Write-Host "$MAGENTA ==========================================================$RESET"
