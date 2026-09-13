[CmdletBinding()]
param()

$Host.UI.RawUI.WindowTitle = "AstroSSTool v1.0.0 - Interactive Suite"
$Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(120, 50)

function Show-Header {
    Clear-Host
    Write-Host "   ___  ___ _____ _____  _____  _____ _____ _____ _____ _____  _____" -ForegroundColor DarkMagenta
    Write-Host "  / _ \/  ___|_   _|  _ \|  _  |  ___/  ___/  ___|_   _|  _ \|  _  |" -ForegroundColor DarkMagenta
    Write-Host " / /_\ \ `--.  | | | |_) | | | | |__ \ `--.\ `--.  | | | |_) | | | |" -ForegroundColor DarkMagenta
    Write-Host " |  _  |`--. \ | | |  _ <| | | |  __| `--. \`--. \ | | |  _ <| | | |" -ForegroundColor DarkMagenta
    Write-Host " | | | /\__/ / | | | |_) \ \_/ / |___/\__/ /\__/ / | | | |_) \ \_/ /" -ForegroundColor DarkMagenta
    Write-Host " \_| |_/\____/  \_/|____/ \___/\____/\____/\____/  \_/ |____/ \___/" -ForegroundColor DarkMagenta
    Write-Host "                --- FORENSIC MODERATION SUITE ---" -ForegroundColor Cyan
    Write-Host " [★] Version: 1.0.0 | Repository: iyedjouamaa-dot/AstroSSTool" -ForegroundColor Cyan
    Write-Host " ==================================================================" -ForegroundColor DarkGray
}

function Run-FullScan {
    Show-Header
    Write-Host "`n[+] Running Full Automated Forensic Scan..." -ForegroundColor Yellow
    
    # 1. Process Check
    Write-Host "`n[1/4] Scanning Active Processes..." -ForegroundColor Cyan
    $processes = Get-Process | Select-Object -ExpandProperty ProcessName
    if ($processes -contains "javaw") { Write-Host "  [✓] Minecraft (javaw.exe) active." -ForegroundColor Green } else { Write-Host "  [!] Minecraft not running." -ForegroundColor Red }
    
    $badProcesses = @("vape", "drip", "koth", "cheatengine", "processhacker", "systeminformer", "doomsday", "autoclicker", "reach", "destruct")
    $found = $false
    foreach ($bad in $badProcesses) {
        if ($processes -like "*$bad*") { Write-Host "  [!] FLAG: Detected process -> $bad" -ForegroundColor Red; $found = $true }
    }
    if (-not $found) { Write-Host "  [✓] No blacklisted process signatures." -ForegroundColor Green }

    # 2. Prefetch
    Write-Host "`n[2/4] Checking Prefetch Forensics..." -ForegroundColor Cyan
    $prefetchPath = "C:\Windows\Prefetch"
    if (Test-Path $prefetchPath) {
        $pfFiles = Get-ChildItem -Path $prefetchPath -Filter "*.pf" -ErrorAction SilentlyContinue
        if ($pfFiles.Count -lt 15) { Write-Host "  [!] WARNING: Low Prefetch count ($($pfFiles.Count)). Possible wipe." -ForegroundColor Red }
        $pfFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 3 | ForEach-Object {
            Write-Host "  [-] Executed: $($_.LastWriteTime.ToString('HH:mm:ss')) -> $($_.Name)" -ForegroundColor Gray
        }
    }

    # 3. USN Journal
    Write-Host "`n[3/4] Checking USN Journal Deletions..." -ForegroundColor Cyan
    try {
        $usnData = fsutil usn readjournal C: csv 2>$null
        $deletedFiles = $usnData | Where-Object { $_ -match "0x80000200|DELETE" } | Where-Object { $_ -match "\.exe|\.jar|\.dll|\.zip" }
        if ($deletedFiles) {
            $deletedFiles | Select-Object -First 3 | ForEach-Object {
                Write-Host "  [!] Deleted Binary: $(($_ -split ',')[-1].Replace('"',''))" -ForegroundColor Red
            }
        } else { Write-Host "  [✓] No suspicious deletions found." -ForegroundColor Green }
    } catch { Write-Host "  [-] USN Journal query skipped." -ForegroundColor Gray }

    # 4. Services
    Write-Host "`n[4/4] Checking Service Integrity..." -ForegroundColor Cyan
    foreach ($service in @("SysMain", "EventLog")) {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc.Status -eq "Running") { Write-Host "  [✓] Service $service is RUNNING." -ForegroundColor Green } else { Write-Host "  [!] Service $service is STOPPED." -ForegroundColor Red }
    }

    Write-Host "`n==================================================================" -ForegroundColor DarkGray
    Write-Host " Press any key to return to the main menu..." -ForegroundColor Yellow
    [void][System.Console]::ReadKey($true)
}

function Open-ProcessScanner {
    Show-Header
    Write-Host "`n[+] LIVE PROCESS INSPECTOR" -ForegroundColor Yellow
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 15 ProcessName, Id, WorkingSet | Format-Table -AutoSize
    Write-Host "Press any key to return to main menu..." -ForegroundColor Yellow
    [void][System.Console]::ReadKey($true)
}

function Main-Menu {
    while ($true) {
        Show-Header
        Write-Host " [1] Run Full Automated Forensic Scan" -ForegroundColor Green
        Write-Host " [2] Open Live Process Inspector" -ForegroundColor Cyan
        Write-Host " [3] Launch External Tools (System Informer / Process Hacker)" -ForegroundColor Magenta
        Write-Host " [4] Exit AstroSSTool" -ForegroundColor Red
        Write-Host "==================================================================" -ForegroundColor DarkGray
        
        $choice = Read-Host " Select an option [1-4]"
        switch ($choice) {
            "1" { Run-FullScan }
            "2" { Open-ProcessScanner }
            "3" { 
                Write-Host "`n[+] Launching external diagnostic utilities..." -ForegroundColor Yellow
                Start-Process "taskmgr.exe"
                Start-Sleep -Seconds 1
            }
            "4" { exit }
            default { 
                Write-Host " Invalid option. Press any key..." -ForegroundColor Red
                [void][System.Console]::ReadKey($true)
            }
        }
    }
}

# Admin Verification
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host " [!] FATAL: AstroSSTool must be run as Administrator." -ForegroundColor Red
    exit
}

Main-Menu
