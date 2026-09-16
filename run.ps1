Add-Type -AssemblyName System.Windows.Forms

# Load WebView2 assembly (built into Windows 10/11 via Edge)
Add-Type -Path "$env:ProgramFiles (x86)\Microsoft\EdgeWebView\Application\*\WebView2Loader.dll" -ErrorAction SilentlyContinue

$form = New-Object System.Windows.Forms.Form
$form.Text = "AstroSSTool"
$form.Size = New-Object System.Drawing.Size(950, 650)
$form.StartPosition = "CenterScreen"

$webView = New-Object Microsoft.Web.WebView2.WinForms.WebView2
$webView.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($webView)

$htmlPath = "$PSScriptRoot\index.html"

$form.Add_Shown({
    $webView.EnsureCoreWebView2Async().ContinueWith({
        $webView.CoreWebView2.Navigate($htmlPath)
    }, [System.Threading.Tasks.TaskScheduler]::FromCurrentSynchronizationContext())
})

[void]$form.ShowDialog()
