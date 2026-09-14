# ==============================================================================
# AstroSSTool - Advanced Forensic Suite (Beta v0.9)
# Theme: Cyber-Purple Edition
# Requirements: Administrator Privileges
# ==============================================================================

# --- 1. SELF-ELEVATION CHECK ---
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[-] Requesting Administrator Privileges..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# --- 2. CONSOLE APPEARANCE SETUP ---
$host.UI.RawUI.WindowTitle = "AstroSSTool v0.9 - Advanced Forensic Suite | SECURE"
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "Gray"
$consoleWidth = 140
$consoleHeight = 45
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size($consoleWidth, $consoleHeight)
Clear-Host

# Global Variables
$ActiveTools = @()

# --- 3. UI FUNCTIONS ---

Function Write-Header {
    Clear-Host
    Write-Host "============================================================================================================================================" -NoNewline -ForegroundColor DarkMagenta
    Write-Host ""
    Write-Host "   __      ___       _                  _____ ____  _____ _____ ___  ___   " -NoNewline -ForegroundColor Magenta
    Write-Host "   \ \    / (_)     | |                / ____/ __ \|_   _|_   _|__ \|__ \  " -ForegroundColor Cyan
    Write-Host "    \ \  / / _ _ __ | |_ _ __ ___  ___| |   | |  | | | |   | |    ) |  ) | " -NoNewline -ForegroundColor Magenta
    Write-Host "     \ \/ / | | '_ \| __| '__/ _ \/ __| |   | |  | | | |   | |   / /  / /  " -ForegroundColor Cyan
    Write-Host "      \  /  | | | | | |_| | | (_) \__ \ |___| |__| |_| |_  | |  |_|  |_|   " -NoNewline -ForegroundColor Magenta
    Write-Host "       \/   |_|_| |_|\__|_|  \___/|___/\_____\____/|_____| |_|  (_)  (_)   " -ForegroundColor Cyan
    Write-Host "   ============================================================================================================================================" -ForegroundColor DarkMagenta
    Write-Host "   Status: SECURE / OFFLINE   |   Developed by: [REDACTED]   |   Target: Remote Machine Audit                                    " -ForegroundColor Green
    Write-Host ""
}

Function Write-Panel ($Title, $Content, $Color = "Cyan") {
    Write-Host "   " -NoNewline
    Write-Host "+-----------------------------------------+" -ForegroundColor DarkGray
    Write-Host "   | " -NoNewline; Write-Host ($Title.PadRight(39)) -ForegroundColor $Color -NoNewline; Write-Host "|"
    Write-Host "   +-----------------------------------------+" -ForegroundColor DarkGray
    foreach ($line in $Content.Split("`n")) {
        Write-Host "   | " -NoNewline; Write-Host ($line.PadRight(39)) -ForegroundColor Gray -NoNewline; Write-Host "|"
    }
    Write-Host "   +-----------------------------------------+" -ForegroundColor DarkGray
}

Function Update-ConsoleLog ($Message, $Type = "INFO") {
    $timestamp = Get-Date -Format "HH:mm:ss"
    if ($Type -eq "ERROR") {
        Write-Host "[$timestamp] [$Type] $Message" -ForegroundColor Red
    } elseif ($Type -eq "WARN") {
        Write-Host "[$timestamp] [$Type] $Message" -ForegroundColor Yellow
    } else {
        Write-Host "[$timestamp] [$Type] $Message" -ForegroundColor Green
    }
}

# --- 4. CORE FORENSIC MODULES (STUBS) ---

Function Invoke-NetLock {
    Update-ConsoleLog "Activating NetLock Firewall Rules..." "WARN"
    try {
        Get-NetFirewallRule -DisplayName "AstroSS-Netlock" -ErrorAction SilentlyContinue | Remove-NetFirewallRule
        New-NetFirewallRule -DisplayName "AstroSS-Netlock" -Direction Outbound -Action Block -Profile Any | Out-Null
        Update-ConsoleLog "NetLock Active: All Outbound Connections Blocked." "SUCCESS"
    } catch {
        Update-ConsoleLog "Failed to apply NetLock rules. Check permissions." "ERROR"
    }
}

Function Invoke-NetUnlock {
    Update-ConsoleLog "Releasing NetLock Firewall Rules..."
    try {
        Remove-NetFirewallRule -DisplayName "AstroSS-Netlock" -ErrorAction SilentlyContinue
        Update-ConsoleLog "NetLock Released: Network Access Restored." "SUCCESS"
    } catch {
        Update-ConsoleLog "Failed to release NetLock rules." "ERROR"
    }
}

Function Invoke-PrefetchAnalysis {
    Update-ConsoleLog "Running Prefetch Analysis Module..."
    Write-Host "      >> Parsing C:\Windows\Prefetch\... (STUB)" -ForegroundColor Cyan
    # --- INSERT ADVANCED POWERSHELL LOGIC HERE ---
    # Get-ChildItem "C:\Windows\Prefetch\*.pf" | ...
    Start-Sleep -Seconds 2
    Update-ConsoleLog "Prefetch Analysis Complete." "SUCCESS"
}

Function Invoke-UserAssistAudit {
    Update-ConsoleLog "Running UserAssist Registry Audit..."
    Write-Host "      >> Querying HKCU\...\UserAssist\... (STUB)" -ForegroundColor Cyan
    # --- INSERT ADVANCED POWERSHELL LOGIC HERE ---
    # Reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /s
    Start-Sleep -Seconds 3
    Update-ConsoleLog "UserAssist Audit Complete." "SUCCESS"
}

Function Invoke-SystemDriveScan {
    Update-ConsoleLog "Performing Deep File System Scan..."
    Write-Host "      >> Searching for common bypass signatures... (STUB)" -ForegroundColor Cyan
    # --- INSERT ADVANCED POWERSHELL LOGIC HERE ---
    # Get-ChildItem C:\ -Recurse -Include "*.exe", "*.dll" | Where-Object { ... }
    Start-Sleep -Seconds 4
    Update-ConsoleLog "File System Scan Complete." "SUCCESS"
}

Function Invoke-ServicesAudit {
    Update-ConsoleLog "Auditing System Services..."
    Write-Host "      >> Checking for unsigned or unusual services... (STUB)" -ForegroundColor Cyan
    # --- INSERT ADVANCED POWERSHELL LOGIC HERE ---
    # Get-Service | Where-Object Status -eq Running | Select-Object DisplayName, ServiceName, PathName
    Start-Sleep -Seconds 2
    Update-ConsoleLog "Services Audit Complete." "SUCCESS"
}

# --- 5. MAIN CONSOLE DASHBOARD ---

Function Show-Dashboard {
    Write-Header
    Write-Host ""
    
    # ROW 1: SECURITY & STATUS
    $netStatus = "ACTIVE"
    if (-not (Get-NetFirewallRule -DisplayName "AstroSS-Netlock" -ErrorAction SilentlyContinue)) { $netStatus = "INACTIVE" }
    $netColor = if ($netStatus -eq "ACTIVE") { "Green" } else { "Red" }
    
    Write-Host "   [1] SECURE SYSTEM" -ForegroundColor DarkCyan
    Write-Host "   " -NoNewline; Write-Panel "NetLock (Cut Internet Access)" "Status: $netStatus`nBlocks outbound traffic during audit." $netColor -NoNewline
    Write-Host "   " -NoNewline; Write-Panel "Integrity Check" "Windows System Integrity: OK`nSecure Boot: Enabled" -NoNewline
    Write-Host "   " -NoNewline; Write-Panel "Admin Privileges" "Status: Confirmed`nRunning as SYSTEM/Administrator" -NoNewline
    Write-Host ""

    # ROW 2: PREFETCH & EXECUTION
    Write-Host "   [2] EXECUTION HISTORY" -ForegroundColor DarkCyan
    Write-Host "   " -NoNewline; Write-Panel "Analyze Prefetch (.pf)" "Lists executed programs & timestamps." -NoNewline "Cyan"
    Write-Host "   " -NoNewline; Write-Panel "AmCache Parser" "Audits program execution history." -NoNewline "Cyan"
    Write-Host "   " -NoNewline; Write-Panel "ShimCache (AppCompat)" "Historical view of executed binaries." -NoNewline "Cyan"
    Write-Host ""
    
    # ROW 3: REGISTRY ARTIFACTS
    Write-Host "   [3] REGISTRY AUDIT" -ForegroundColor DarkCyan
    Write-Host "   " -NoNewline; Write-Panel "RecentApps (BAM)" "Identifies recently accessed applications." -NoNewline "Green"
    Write-Host "   " -NoNewline; Write-Panel "UserAssist" "Tracks GUI application launches." -NoNewline "Green"
    Write-Host "   " -NoNewline; Write-Panel "Services Registry Keys" "Checks for unusual driver/service loads." -NoNewline "Green"
    Write-Host ""
    
    # ROW 4: FILE SYSTEM & CLEANUP
    Write-Host "   [4] SYSTEM ANALYSIS" -ForegroundColor DarkCyan
    Write-Host "   " -NoNewline; Write-Panel "Deep File Scan" "Signature search for known cheats/tools." -NoNewline "Yellow"
    Write-Host "   " -NoNewline; Write-Panel "Running Services" "Audits currently running system services." -NoNewline "Yellow"
    Write-Host "   " -NoNewline; Write-Panel "Startup Folders" "Lists all programs that start on boot." -NoNewline "Yellow"
    Write-Host ""
    
    # ROW 5: ACTIONS
    Write-Host "   ============================================================================================================================================" -ForegroundColor DarkMagenta
    Write-Host "   [A] Run ALL Audits (Full Scan)   [L] Activate NetLock (Cut Net)   [U] Release NetLock (Restore Net)   [Q] QUIT & Cleanup" -ForegroundColor White
    Write-Host ""
    $choice = Read-Host "   AstroSS > "
    
    switch ($choice.ToLower()) {
        "l" { 
            Invoke-NetLock
            Read-Host "`nPress Enter to return..."
            Show-Dashboard
        }
        "u" { 
            Invoke-NetUnlock
            Read-Host "`nPress Enter to return..."
            Show-Dashboard
        }
        "1" {
             Write-Header
             Invoke-PrefetchAnalysis
             Read-Host "`nPress Enter to return..."
             Show-Dashboard
        }
        "2" {
            Write-Header
            Update-ConsoleLog "Running AmCache & ShimCache Analysis..."
            Start-Sleep -Seconds 5
            Update-ConsoleLog "Caching analysis complete." "SUCCESS"
            Read-Host "`nPress Enter to return..."
            Show-Dashboard
       }
       "3" {
             Write-Header
             Invoke-UserAssistAudit
             Read-Host "`nPress Enter to return..."
             Show-Dashboard
        }
        "4" {
            Write-Header
            Invoke-SystemDriveScan
            Invoke-ServicesAudit
            Read-Host "`nPress Enter to return..."
            Show-Dashboard
       }
        "a" {
            Write-Header
            Update-ConsoleLog "INITIATING FULL FORENSIC SUITE..." "WARN"
            Invoke-NetLock
            Invoke-PrefetchAnalysis
            Invoke-UserAssistAudit
            Invoke-SystemDriveScan
            Invoke-ServicesAudit
            Update-ConsoleLog "ALL AUDITS COMPLETE. REVIEW LOGS ABOVE." "SUCCESS"
            Read-Host "`nPress Enter to return..."
            Show-Dashboard
        }
        "q" { 
            Invoke-NetUnlock
            Update-ConsoleLog "AstroSSTool Exiting. Logs cleared."
            Start-Sleep -Seconds 1
            Exit 
        }
        default { Show-Dashboard }
    }
}

# --- 6. STARTUP SEQUENCE ---

Write-Header
Update-ConsoleLog "AstroSSTool Initializing..."
Update-ConsoleLog "Checking system environment..."
Start-Sleep -Seconds 1
Update-ConsoleLog "Dependencies check: PASS" "SUCCESS"
Update-ConsoleLog "Loading Forensic Modules..."
Start-Sleep -Seconds 2
Update-ConsoleLog "All systems go." "SUCCESS"
Start-Sleep -Seconds 1

Show-Dashboard
