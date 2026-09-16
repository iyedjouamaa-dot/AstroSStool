# ==============================================================================
# AstroSSTool - Web UI Launcher (WebView2 Particle Renderer)
# ==============================================================================

If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName Microsoft.VisualBasic

# Ensure WebView2 Loader assembly is available
try {
    Add-Type -Path "$PSScriptRoot\packages\Microsoft.Web.WebView2.*\lib\net45\Microsoft.Web.WebView2.WinForms.dll" -ErrorAction SilentlyContinue
} catch {}

# Create Windows Form Container
$form = New-Object System.Windows.Forms.Form
$form.Text = "AstroSSTool"
$form.Size = New-Object System.Drawing.Size(950, 650)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#09080b")

# Custom Draggable TitleBar
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size(950, 32)
$titleBar.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0f0d14")
$form.Controls.Add($titleBar)

$dragging = $false
$offset = $null
$titleBar.Add_MouseDown({ if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) { $global:dragging = $true; $global:offset = $_.Location } })
$titleBar.Add_MouseUp({ $global:dragging = $false })
$titleBar.Add_MouseMove({ if ($global:dragging) { $form.Location = New-Object System.Drawing.Point(($form.Location.X + $_.X - $global:offset.X), ($form.Location.Y + $_.Y - $global:offset.Y)) } })

# Close / Minimize Controls
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "✕"
$btnClose.Size = New-Object System.Drawing.Size(35, 32)
$btnClose.Location = New-Object System.Drawing.Point(915, 0)
$btnClose.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClose.ForeColor = [System.Drawing.Color]::Gray
$btnClose.FlatAppearance.BorderSize = 0
$btnClose.Add_Click({ $form.Close() })
$titleBar.Controls.Add($btnClose)

# WebView Host for your index.html
$webView = New-Object Microsoft.Web.WebView2.WinForms.WebView2
$webView.Size = New-Object System.Drawing.Size(950, 618)
$webView.Location = New-Object System.Drawing.Point(0, 32)
$form.Controls.Add($webView)

$htmlPath = "$PSScriptRoot\index.html"

$form.Add_Shown({
    $webView.EnsureCoreWebView2Async().ContinueWith({
        if (Test-Path $htmlPath) {
            $webView.CoreWebView2.Navigate([System.Uri]("$htmlPath").AbsoluteUri)
        } else {
            $webView.CoreWebView2.Navigate("https://github.com/iyedjouamaa-dot")
        }
    }, [System.Threading.Tasks.TaskScheduler]::FromCurrentSynchronizationContext())
})

[void]$form.ShowDialog()
