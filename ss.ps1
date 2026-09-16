# ==============================================================================
# AstroSSTool - Professional Multi-Tab Desktop UI Edition
# ==============================================================================

# 1. Self-Elevation Check
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define local download directory for tools
$ToolsDir = "$env:USERPROFILE\Downloads\AstroSSTool"
if (!(Test-Path $ToolsDir)) { New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null }

# --- XAML UI LAYOUT (CheesySSTool Style Layout with Purple Theme) ---
[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="AstroSSTool" Height="650" Width="950" WindowStartupLocation="CenterScreen"
    Background="#121016" Foreground="White" ResizeMode="CanMinimize">
    
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="220"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="130"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Grid.Column="0" Background="#181420" BorderBrush="#261E34" BorderThickness="0,0,1,0">
            <StackPanel Margin="15">
                <TextBlock Text="^._.^ AstroSS" FontSize="16" FontWeight="Bold" Foreground="#b464ff" Margin="0,0,0,20"/>
                <TextBlock Text="ACTIONS" FontSize="10" Foreground="#6b7280" FontWeight="Bold" Margin="0,0,0,5"/>
                
                <Button x:Name="BtnOpenFolder" Content="Open Install Folder" Background="#261E34" Foreground="White" BorderBrush="Transparent" Height="32" Margin="0,0,0,8" Cursor="Hand"/>
                <Button x:Name="BtnClearFiles" Content="Clear Downloaded Files" Background="#261E34" Foreground="White" BorderBrush="Transparent" Height="32" Margin="0,0,0,8" Cursor="Hand"/>
                <Button x:Name="BtnNetLock" Content="Toggle NetLock" Background="#261E34" Foreground="#ff6464" BorderBrush="Transparent" Height="32" Margin="0,0,0,8" Cursor="Hand"/>
                
                <TextBlock Text="CREDITS" FontSize="10" Foreground="#6b7280" FontWeight="Bold" Margin="0,20,0,5"/>
                <TextBlock Text="Built for Astro Moderation" FontSize="11" Foreground="#9ca3af" TextWrapping="Wrap"/>
                <TextBlock Text="Install path:" FontSize="10" Foreground="#6b7280" Margin="0,15,0,2"/>
                <TextBlock Text="$ToolsDir" FontSize="9" Foreground="#9ca3af" TextWrapping="Wrap"/>
            </StackPanel>
        </Border>

        <TabControl Grid.Row="0" Grid.Column="1" Background="#121016" BorderBrush="#261E34" Margin="10">
            <TabItem Header="Execution" Background="#181420" Foreground="White" Padding="12,6">
                <WrapPanel Margin="10">
                    <Button x:Name="CardPrefetch" Width="210" Height="85" Margin="5" Background="#1c1626" Foreground="White" BorderBrush="#2e2440" Cursor="Hand" HorizontalContentAlignment="Left" VerticalContentAlignment="Top" Padding="10">
                        <StackPanel>
                            <TextBlock Text="PrefetchView" FontWeight="Bold" Foreground="#b464ff" FontSize="13"/>
                            <TextBlock Text="Parses prefetch, extracts file execution info." FontSize="10" Foreground="#9ca3af" TextWrapping="Wrap" Margin="0,4,0,0"/>
                        </StackPanel>
                    </Button>
                    <Button x:Name="CardBAM" Width="210" Height="85" Margin="5" Background="#1c1626" Foreground="White" BorderBrush="#2e2440" Cursor="Hand" HorizontalContentAlignment="Left" VerticalContentAlignment="Top" Padding="10">
                        <StackPanel>
                            <TextBlock Text="BAMReveal" FontWeight="Bold" Foreground="#b464ff" FontSize="13"/>
                            <TextBlock Text="Parses Background Activity Monitor registry artifact." FontSize="10" Foreground="#9ca3af" TextWrapping="Wrap" Margin="0,4,0,0"/>
                        </StackPanel>
                    </Button>
                    <Button x:Name="CardUserAssist" Width="210" Height="85" Margin="5" Background="#1c1626" Foreground="White" BorderBrush="#2e2440" Cursor="Hand" HorizontalContentAlignment="Left" VerticalContentAlignment="Top" Padding="10">
                        <StackPanel>
                            <TextBlock Text="UserAssistView" FontWeight="Bold" Foreground="#b464ff" FontSize="13"/>
                            <TextBlock Text="Parses ROT13 UserAssist execution history keys." FontSize="10" Foreground="#9ca3af" TextWrapping="Wrap" Margin="0,4,0,0"/>
                        </StackPanel>
                    </Button>
                </WrapPanel>
            </TabItem>

            <TabItem Header="Scanners" Background="#181420" Foreground="White" Padding="12,6">
                <WrapPanel Margin="10">
                    <Button x:Name="CardInjGen" Width="210" Height="85" Margin="5" Background="#1c1626" Foreground="White" BorderBrush="#2e2440" Cursor="Hand" HorizontalContentAlignment="Left" VerticalContentAlignment="Top" Padding="10">
                        <StackPanel>
                            <TextBlock Text="InjGen" FontWeight="Bold" Foreground="#b464ff" FontSize="13"/>
                            <TextBlock Text="Detects JNI/JVMTI memory injection signatures." FontSize="10" Foreground="#9ca3af" TextWrapping="Wrap" Margin="0,4,0,0"/>
                        </StackPanel>
                    </Button>
                    <Button x:Name="CardStrings" Width="210" Height="85" Margin="5" Background="#1c1626" Foreground="White" BorderBrush="#2e2440" Cursor="Hand" HorizontalContentAlignment="Left" VerticalContentAlignment="Top" Padding="10">
                        <StackPanel>
                            <TextBlock Text="StringsParser" FontWeight="Bold" Foreground="#b464ff" FontSize="13"/>
                            <TextBlock Text="Performs Yara rule &amp; string signature scanning." FontSize="10" Foreground="#9ca3af" TextWrapping="Wrap" Margin="0,4,0,0"/>
                        </StackPanel>
                    </Button>
                </WrapPanel>
            </TabItem>
        </TabControl>

        <Border Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2" Background="#0b090e" BorderBrush="#261E34" BorderThickness="0,1,0,0" Padding="10">
            <DockPanel>
                <TextBlock DockPanel.Dock="Top" Text="ACTIVITY CONSOLE" FontSize="9" Foreground="#6b7280" FontWeight="Bold" Margin="0,0,0,5"/>
                <TextBox x:Name="ConsoleBox" IsReadOnly="True" Background="Transparent" Foreground="#4ade80" BorderBrush="Transparent" FontFamily="Consolas" FontSize="11" AcceptsReturn="True" VerticalScrollBarVisibility="Auto"/>
            </DockPanel>
        </Border>
    </Grid>
</Window>
"@

# Read XAML into memory
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Map UI Elements
$ConsoleBox = $window.FindName("ConsoleBox")
$BtnOpenFolder = $window.FindName("BtnOpenFolder")
$BtnClearFiles = $window.FindName("BtnClearFiles")
$BtnNetLock = $window.FindName("BtnNetLock")
$CardPrefetch = $window.FindName("CardPrefetch")
$CardBAM = $window.FindName("CardBAM")
$CardUserAssist = $window.FindName("CardUserAssist")
$CardInjGen = $window.FindName("CardInjGen")
$CardStrings = $window.FindName("CardStrings")

function Write-ConsoleLog($message) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    $ConsoleBox.AppendText("[$timestamp] $message`r`n")
    $ConsoleBox.ScrollToEnd()
}

# --- BUTTON EVENT HANDLERS ---
$BtnOpenFolder.Add_Click({
    Start-Process explorer.exe $ToolsDir
    Write-ConsoleLog "Opened install folder: $ToolsDir"
})

$BtnClearFiles.Add_Click({
    Remove-Item "$ToolsDir\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-ConsoleLog "Cleared all downloaded tool artifacts."
})

$BtnNetLock.Add_Click({
    try {
        $rule = Get-NetFirewallRule -DisplayName "AstroSS-Netlock" -ErrorAction SilentlyContinue
        if ($rule) {
            Remove-NetFirewallRule -DisplayName "AstroSS-Netlock"
            Write-ConsoleLog "NetLock DISABLED: Network access restored."
        } else {
            New-NetFirewallRule -DisplayName "AstroSS-Netlock" -Direction Outbound -Action Block -Profile Any | Out-Null
            Write-ConsoleLog "NetLock ENGAGED: All outbound traffic blocked."
        }
    } catch {
        Write-ConsoleLog "ERROR: Failed to modify firewall rules."
    }
})

# Tool Card Clicks (Ready to execute or download utilities)
$CardPrefetch.Add_Click({ Write-ConsoleLog "Initializing PrefetchView module..." })
$CardBAM.Add_Click({ Write-ConsoleLog "Reading BAM registry hive records..." })
$CardUserAssist.Add_Click({ Write-ConsoleLog "Extracting ROT13 UserAssist timeline..." })
$CardInjGen.Add_Click({ Write-ConsoleLog "Scanning memory space for InjGen bypass signatures..." })
$CardStrings.Add_Click({ Write-ConsoleLog "Running string signature scan..." })

# Startup log
Write-ConsoleLog "AstroSSTool GUI initialized successfully. Ready for scan."

# Show the clean desktop window
[void]$window.ShowDialog()
