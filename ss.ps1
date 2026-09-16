Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime.InteropServices

# ==============================================================================
# WIN32 API FOR ROUNDED CORNERS & DRAGGING
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

function Make-Rounded {
    param($control, $radius = 24)
    try {
        $rgn = [Win32]::CreateRoundRectRgn(0, 0, $control.Width, $control.Height, $radius, $radius)
        [Win32]::SetWindowRgn($control.Handle, $rgn, $true)
    } catch {}
}

# ==============================================================================
# ASTRO-AURA PARTICLE SYSTEM OVERLAY (HTML/JS EMBEDDED IN WEBVIEW2)
# ==============================================================================
$WorkDir = "$env:USERPROFILE\Downloads\AstroSSTool"
if (!(Test-Path $WorkDir)) { New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null }

$HtmlFile = "$WorkDir\index.html"
$HtmlContent = @"
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; user-select: none; }
        body, html { width: 100%; height: 100%; background: #09080b; overflow: hidden; font-family: 'Segoe UI', Tahoma, sans-serif; }
        #canvas-bg { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 1; pointer-events: none; }
        
        .ui-container { position: relative; z-index: 2; width: 100%; height: 100%; display: flex; flex-direction: column; padding: 25px; color: #fff; }
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(168, 85, 247, 0.2); padding-bottom: 15px; }
        .logo { font-size: 16px; font-weight: 800; color: #d8b4fe; letter-spacing: 2px; text-shadow: 0 0 10px rgba(168, 85, 247, 0.5); }
        .subtitle { font-size: 11px; color: #6b7280; margin-top: 2px; }

        .grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; margin-top: 20px; }
        .card { background: rgba(18, 16, 23, 0.7); border: 1px solid rgba(168, 85, 247, 0.15); border-radius: 12px; padding: 18px; backdrop-filter: blur(10px); transition: all 0.3s ease; }
        .card:hover { border-color: rgba(168, 85, 247, 0.5); box-shadow: 0 0 20px rgba(168, 85, 247, 0.15); }
        .card-title { font-size: 13px; font-weight: 700; color: #c084fc; margin-bottom: 8px; }
        .card-desc { font-size: 11px; color: #9ca3af; line-height: 1.4; }

        .btn { margin-top: 12px; background: linear-gradient(135deg, #7c3aed, #4f46e5); border: none; border-radius: 6px; color: white; padding: 8px 14px; font-size: 11px; font-weight: 700; cursor: pointer; transition: 0.2s; }
        .btn:hover { opacity: 0.9; box-shadow: 0 0 12px rgba(124, 58, 237, 0.6); }

        .console { margin-top: auto; background: #050507; border: 1px solid #1f1b29; border-radius: 8px; padding: 12px; font-family: 'Consolas', monospace; font-size: 11px; color: #4ade80; height: 90px; overflow-y: auto; }
    </style>
</head>
<body>
    <canvas id="canvas-bg"></canvas>
    <div class="ui-container">
        <div class="header">
            <div>
                <div class="logo">✦ ASTROSSTOOL // FORENSIC SUITE</div>
                <div class="subtitle">Built by astrovoidmc_ • Aura Engine Active</div>
            </div>
        </div>

        <div class="grid">
            <div class="card">
                <div class="card-title">🔍 Process & Prefetch Scanner</div>
                <div class="card-desc">Deep-scans prefetch artifacts, shimcache, and active memory hooks for injected clients.</div>
                <button class="btn" onclick="runScan('Prefetch')">Execute Scan</button>
            </div>
            <div class="card">
                <div class="card-title">🛡️ NetLock Firewall</div>
                <div class="card-desc">Instantly block unauthorized socket connections and ghost communication loops.</div>
                <button class="btn" onclick="runScan('NetLock')">Toggle NetLock</button>
            </div>
        </div>

        <div class="console" id="logBox">
            [12:32:03] AstroSSTool initialized successfully. Aura particle canvas online.<br>
            [12:32:03] Ready for artifact inspection...
        </div>
    </div>

    <script>
        // Particle Background Engine
        const canvas = document.getElementById('canvas-bg');
        const ctx = canvas.getContext('2d');
        let particles = [];

        function resize() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }
        window.addEventListener('resize', resize);
        resize();

        for (let i = 0; i < 45; i++) {
            particles.push({
                x: Math.random() * canvas.width,
                y: Math.random() * canvas.height,
                vx: (Math.random() - 0.5) * 0.6,
                vy: (Math.random() - 0.5) * 0.6,
                radius: Math.random() * 1.8 + 0.5,
                alpha: Math.random() * 0.6 + 0.2
            });
        }

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.fillStyle = 'rgba(168, 85, 247, 0.4)';
            ctx.strokeStyle = 'rgba(168, 85, 247, 0.08)';

            particles.forEach((p, index) => {
                p.x += p.vx;
                p.y += p.vy;

                if (p.x < 0 || p.x > canvas.width) p.vx *= -1;
                if (p.y < 0 || p.y > canvas.height) p.vy *= -1;

                ctx.beginPath();
                ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
                ctx.fillStyle = \`rgba(168, 85, 247, \${p.alpha})\`;
                ctx.fill();

                for (let j = index + 1; j < particles.length; j++) {
                    let p2 = particles[j];
                    let dist = Math.hypot(p.x - p2.x, p.y - p2.y);
                    if (dist < 110) {
                        ctx.beginPath();
                        ctx.moveTo(p.x, p.y);
                        ctx.lineTo(p2.x, p2.y);
                        ctx.stroke();
                    }
                }
            });
            requestAnimationFrame(animate);
        }
        animate();

        function runScan(type) {
            const box = document.getElementById('logBox');
            const time = new Date().toTimeString().split(' ')[0];
            box.innerHTML += \`<br>[\${time}] Executing \${type} protocol analysis...\`;
            box.scrollTop = box.scrollHeight;
        }
    </script>
</body>
</html>
"@
Set-Content -Path $HtmlFile -Value $HtmlContent -Encoding UTF8

# ==============================================================================
# POWERSHELL WEBVIEW2 WINDOW HOSTING THE PARTICLE UI
# ==============================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -Path "$env:ProgramFiles (x86)\Microsoft\EdgeWebView\Application\*\WebView2Loader.dll" -ErrorAction SilentlyContinue

$form = New-Object System.Windows.Forms.Form
$form.Text = "AstroSSTool // Forensic Suite"
$form.Size = New-Object System.Drawing.Size(840, 520)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#09080b")
$form.TopMost = $true
$form.Add_Shown({ Make-Rounded -control $form -radius 24 })

# Draggable Titlebar Hook
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Size = New-Object System.Drawing.Size(840, 32)
$titleBar.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($titleBar)

$titleBar.Add_MouseDown({
    if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        [Win32]::ReleaseCapture()
        [Win32]::SendMessage($form.Handle, 0xA1, 0x2, 0)
    }
})

# Close Button Overlay
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "✕"
$btnClose.Size = New-Object System.Drawing.Size(35, 32)
$btnClose.Location = New-Object System.Drawing.Point(805, 0)
$btnClose.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClose.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$btnClose.FlatAppearance.BorderSize = 0
$btnClose.BackColor = [System.Drawing.Color]::Transparent
$btnClose.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnClose.Add_Click({ $form.Close() })
$titleBar.Controls.Add($btnClose)

# WebView2 Element rendering the particle HTML canvas smoothly
$webView = New-Object Microsoft.Web.WebView2.WinForms.WebView2
$webView.Size = New-Object System.Drawing.Size(840, 488)
$webView.Location = New-Object System.Drawing.Point(0, 32)
$form.Controls.Add($webView)

$form.Add_Shown({
    $webView.EnsureCoreWebView2Async().ContinueWith({
        $webView.CoreWebView2.Navigate([System.Uri]("$HtmlFile").AbsoluteUri)
    }, [System.Threading.Tasks.TaskScheduler]::FromCurrentSynchronizationContext())
})

[void]$form.ShowDialog()
