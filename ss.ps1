[CmdletBinding()]
param()

$Host.UI.RawUI.WindowTitle = "AstroSSTool v1.0.0"
Clear-Host

$BANNER = @"
   ___  ___ _____ _____  _____  _____ _____ _____ _____ _____  _____ 
  / _ \/  ___|_   _|  _ \|  _  |  ___/  ___/  ___|_   _|  _ \|  _  |
 / /_\ \ `--.  | | | |_) | | | | |__ \ `--.\ `--.  | | | |_) | | | |
 |  _  |`--. \ | | |  _ <| | | |  __| `--. \`--. \ | | |  _ <| | | |
 | | | /\__/ / | | | |_) \ \_/ / |___/\__/ /\__/ / | | | |_) \ \_/ /
 \_| |_/\____/  \_/|____/ \___/\____/\____/\____/  \_/ |____/ \___/ 
                --- FORENSIC MODERATION SUITE ---
"@

Write-Host $BANNER -ForegroundColor DarkMagenta
Write-Host " [★] Version: 1.0.0 | Repository: iyedjouamaa-dot/AstroSSTool" -ForegroundColor Cyan
Write-Host " ==========================================================" -ForegroundColor DarkGray

# Admin Check
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host " [!] FATAL: AstroSSTool must be run as Administrator." -ForegroundColor Red
    exit
}

# 1. Active Process Check
Write-Host "`n[1/4] Scanning Active Processes..." -ForegroundColor Cyan
$processes = Get-Process | Select-Object -ExpandProperty ProcessName
if ($processes -contains "javaw") {
    Write-Host "  [✓] Minecraft (javaw.exe) is running." -ForegroundColor Green
} else {
    Write-Host "  [!] Minecraft (javaw.exe) is NOT running." -ForegroundColor Red
}

$badProcesses = @("vape", "drip", "koth", "cheatengine", "processhacker", "systeminformer", "doomsday", "autoclicker", "reach", "destruct")
$found = $false
foreach ($bad in $badProcesses) {
    if ($processes -like "*$bad*") {
        Write-Host "  [!] FLAG: Detected running cheat process -> $bad" -ForegroundColor Red
        $found = $true
    }
}
if (-not $found) { Write-Host "  [✓] No blacklisted process signatures detected." -ForegroundColor Green }

# 2. Prefetch Check
Write-Host "`n[2/4] Checking Execution Forensics (Prefetch)..." -ForegroundColor Cyan
$prefetchPath = "C:\Windows\Prefetch"
if (Test-Path $prefetchPath) {
    $pfFiles = Get-ChildItem -Path $prefetchPath -Filter "*.pf" -ErrorAction SilentlyContinue
    if ($pfFiles.Count -lt 15) {
        Write-Host "  [!] WARNING: Low Prefetch count ($($pfFiles.Count) files). Possible wipe." -ForegroundColor Red
    }
    $recent = $pfFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 5
    foreach ($file in $recent) {
        Write-Host "  [-] Executed at $($file.LastWriteTime.ToString('HH:mm:ss')) -> $($file.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "  [!] ALERT: Prefetch directory inaccessible." -ForegroundColor Red
}

# 3. USN Journal Check
Write-Host "`n[3/4] Checking USN Journal for Recent Executable Deletions..." -ForegroundColor Cyan
try {
    $usnData = fsutil usn readjournal C: csv 2>$null
    $deletedFiles = $usnData | Where-Object { $_ -match "0x80000200|DELETE" } | Where-Object { $_ -match "\.exe|\.jar|\.dll|\.zip" }
    if ($deletedFiles) {
        foreach ($del in ($deletedFiles | Select-Object -First 5)) {
            Write-Host "  [!] ALERT: Recently deleted binary -> $(($del -split ',')[-1].Replace('"',''))" -ForegroundColor Red
        }
    } else {
        Write-Host "  [✓] No suspicious deletions found in USN Journal." -ForegroundColor Green
    }
} catch {
    Write-Host "  [-] USN Journal query skipped." -ForegroundColor Gray
}

# 4. Services Check
Write-Host "`n[4/4] Checking System Service Integrity..." -ForegroundColor Cyan
foreach ($service in @("SysMain", "EventLog")) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc.Status -eq "Running") {
        Write-Host "  [✓] Service $service is RUNNING." -ForegroundColor Green
    } else {
        Write-Host "  [!] ALERT: Service $service is STOPPED." -ForegroundColor Red
    }
}

Write-Host "`n ==========================================================" -ForegroundColor DarkGray
Write-Host " [★] SCAN COMPLETED" -ForegroundColor Cyan
Write-Host " ==========================================================" -ForegroundColor DarkGray
