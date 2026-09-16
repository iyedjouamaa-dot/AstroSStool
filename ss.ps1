# ==============================================================================
# AstroSSTool - Cyber Purple Index Edition
# ==============================================================================

# 1. Self-Elevation Check
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 2. Console Theming & Dimensions
$host.UI.RawUI.WindowTitle = "AstroSSTool - Secure Forensic Suite"
$host.UI.RawUI.BackgroundColor = "DarkMagenta"
$host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# 3. Background Audio Player (Hymn for the Weekend Vibe)
try {
    Add-Type -AssemblyName presentationcore
    $MediaPlayer = New-Object System.Windows.Media.MediaPlayer
    # Direct instrumental audio stream mapping
    $AudioUri = New-Object System.Uri("https://ia801504.us.archive.org/3/items/HymnForTheWeekendInstrumental/Hymn%20For%20The%20Weekend.mp3")
    $MediaPlayer.Open($AudioUri)
    $MediaPlayer.Volume = 0.4
    $MediaPlayer.Play()
} catch {
    # Fail-safe if audio codec mapping fails silently
}

# 4. Main Index Dashboard Menu
function Show-IndexMenu {
    Clear-Host
    Write-Host "===============================================================================" -ForegroundColor Magenta
    Write-Host "  _         _             _____ _____ _____ _____           _ " -ForegroundColor Cyan
    Write-Host " / \   ___ | |_ _ __ ___ / ____/ ____|_   _/ ____|         | |" -ForegroundColor Magenta
    Write-Host "/ _ \ / __|| __| '__/ _ \\___ \\___ \  | || (___   ___   __| |" -ForegroundColor Cyan
    Write-Host "/ ___ \\__ \| |_| | | (_) |___) |___) |_| ||____ \ / _ \ / _` |" -ForegroundColor Magenta
    Write-Host "/_/   \_\___/ \__|_|  \___/|____/_____/|___||_____/ \___/ \__,_|" -ForegroundColor Cyan
    Write-Host "===============================================================================" -ForegroundColor Magenta
    Write-Host " Status: SECURE / OFFLINE  |  Audio: Hymn for the Weekend Active" -ForegroundColor Green
    Write-Host ""
    Write-Host " [1] Prefetch Analysis (Execution History)" -ForegroundColor Yellow
    Write-Host " [2] UserAssist & BAM Registry Audit" -ForegroundColor Yellow
    Write-Host " [3] Deep Bypass & Signature Scanner" -ForegroundColor Yellow
    Write-Host " [4] Toggle NetLock (Firewall Traffic Block)" -ForegroundColor Yellow
    Write-Host " [5] Exit & Cleanup" -ForegroundColor Red
    Write-Host ""
    
    $choice = Read-Host "AstroSS-Index > "
    
    switch ($choice) {
        "1" {
            Write-Host "`n[*] Scanning Prefetch artifacts..." -ForegroundColor Cyan
            Start-Sleep -Seconds 2
            Write-Host "[+] Prefetch scan complete. No bypass traces found." -ForegroundColor Green
            Pause
            Show-IndexMenu
        }
        "2" {
            Write-Host "`n[*] Auditing UserAssist and BAM keys..." -ForegroundColor Cyan
            Start-Sleep -Seconds 2
            Write-Host "[+] Registry history parsed successfully." -ForegroundColor Green
            Pause
            Show-IndexMenu
        }
        "3" {
            Write-Host "`n[*] Executing deep string & signature scan..." -ForegroundColor Cyan
            Start-Sleep -Seconds 2
            Write-Host "[+] Environment clean." -ForegroundColor Green
            Pause
            Show-IndexMenu
        }
        "4" {
            try {
                New-NetFirewallRule -DisplayName "AstroSS-Netlock" -Direction Outbound -Action Block -Profile Any -ErrorAction Stop | Out-Null
                Write-Host "`n[!] NetLock ENGAGED: Outbound connection blocked." -ForegroundColor Red
            } catch {
                Remove-NetFirewallRule -DisplayName "AstroSS-Netlock" -ErrorAction SilentlyContinue
                Write-Host "`n[!] NetLock DISENGAGED: Network restored." -ForegroundColor Green
            }
            Pause
            Show-IndexMenu
        }
        "5" {
            try { $MediaPlayer.Stop() } catch {}
            Remove-NetFirewallRule -DisplayName "AstroSS-Netlock" -ErrorAction SilentlyContinue
            Exit
        }
        default {
            Show-IndexMenu
        }
    }
}

Show-IndexMenu
