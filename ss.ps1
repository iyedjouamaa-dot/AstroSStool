# ==============================================================================
# AstroSSTool - Native WebView2 Modern UI Edition
# ==============================================================================

# Self-Elevation Check
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Create local HTML workspace
$WorkDir = "$env:USERPROFILE\Downloads\AstroSSTool"
if (!(Test-Path $WorkDir)) { New-Item -ItemType Directory -Force -Path$WorkDir | Out-Null }

$HtmlFile = "$WorkDir\index.html"

# Write the exact modern UI design matching your video preview
$HtmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AstroSSTool</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0b090e; color: #fff; overflow: hidden; height: 100vh; display: flex; }
        
        /* Starry background animation */
        .stars { position: fixed; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; background: radial-gradient(ellipse at bottom, #1b1328 0%, #0b090e 100%); z-index: -1; }
        .star { position: absolute; background: #b464ff; border-radius: 50%; animation: twinkle 3s infinite ease-in-out; opacity: 0.5; }
        @keyframes twinkle { 0%, 100% { opacity: 0.2; transform: scale(0.8); } 50% { opacity: 1; transform: scale(1.2); } }

        /* Sidebar */
        .sidebar { width: 230px; background: rgba(18, 14, 24, 0.85); border-right: 1px solid #261E34; display: flex; flex-direction: column; padding: 20px; justify-content: space-between; }
        .logo-area { display: flex; align-items: center; gap: 10px; font-weight: bold; color: #b464ff; font-size: 16px; margin-bottom: 25px; }
        
        .action-group label { font-size: 10px; color: #6b7280; font-weight: bold; letter-spacing: 1px; display: block; margin-bottom: 8px; }
        .btn { width: 100%; background: #1c1626; border: 1px solid #2e2440; color: #fff; padding: 10px; text-align: left; border-radius: 6px; cursor: pointer; margin-bottom: 8px; font-size: 12px; transition: 0.2s; }
        .btn:hover { background: #261e34; border-color: #b464ff; }
        .btn-danger { color: #ff6464; }

        .credits { font-size: 11px; color: #9ca3af; border-top: 1px solid #261E34; padding-top: 15px; }
        .credits b { color: #fff; display: block; margin-bottom: 4px; }
        .path { font-size: 9px; color: #6b7280; margin-top: 5px; word-break: break-all; }

        /* Main Workspace */
        .main-content { flex: 1; display: flex; flex-direction: column; padding: 20px; }
        
        /* Top Status Bar */
        .status-bar { background: rgba(24, 20, 32, 0.7); border: 1px solid #261E34; border-radius: 8px; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .status-title { font-size: 18px; font-weight: bold; color: #fff; }
        .status-subtitle { font-size: 11px; color: #9ca3af; margin-top: 2px; }
        .badge { background: #14532d; color: #4ade80; padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: bold; border: 1px solid #166534; }

        /* Tabs */
        .tabs { display: flex; gap: 8px; margin-bottom: 15px; border-bottom: 1px solid #261E34; padding-bottom: 10px; }
        .tab { background: transparent; border: none; color: #9ca3af; padding: 6px 14px; cursor: pointer; font-size: 13px; border-radius: 4px; font-weight: 500; }
        .tab.active { background: #b464ff; color: #fff; font-weight: bold; }

        /* Tool Cards Grid */
        .cards-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; overflow-y: auto; max-height: 310px; padding-right: 5px; }
        .card { background: rgba(24, 20, 32, 0.6); border: 1px solid #261E34; border-radius: 8px; padding: 15px; cursor: pointer; transition: 0.2s; }
        .card:hover { border-color: #b464ff; background: rgba(30, 24, 42, 0.8); transform: translateY(-2px); }
        .card-title { font-weight: bold; font-size: 13px; color: #b464ff; margin-bottom: 5px; }
        .card-desc { font-size: 11px; color: #9ca3af; line-height: 1.3; }

        /* Terminal Console */
        .console { background: #070509; border: 1px solid #261E34; border-radius: 8px; padding: 12px; margin-top: auto; height: 90px; font-family: 'Courier New', Courier, monospace; font-size: 11px; color: #4ade80; overflow-y: auto; }
        .console-title { font-size: 9px
