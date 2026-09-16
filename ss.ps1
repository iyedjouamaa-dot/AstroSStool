# ==============================================================================
# AstroSS - Native Aura-Styled Forensic Suite
# ==============================================================================

If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$WorkDir = "$env:USERPROFILE\Downloads\AstroSSTool"
if (!(Test-Path $WorkDir)) { New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null }

[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="AstroSS" Height="620" Width="920" 
    WindowStartupLocation="CenterScreen" Background="#09080b" Foreground="White" 
    WindowStyle="None" AllowsTransparency="True" ResizeMode="CanMinimize">
    
    <Window.Resources>
        <Style TargetType="Button" x:Key="ToolCard">
            <Setter Property="Background" Value="#121017"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#1f1b29"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="cardBorder" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8" Padding="14">
                            <ContentPresenter/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="cardBorder" Property="Background" Value="#1a1623"/>
                                <Setter TargetName="cardBorder" Property="BorderBrush" Value="#a855f7"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="Button" x:Key="SideBtn">
            <Setter Property="Background" Value="#121017"/>
            <Setter Property="Foreground" Value="#d8b4fe"/>
            <Setter Property="BorderBrush" Value="#1f1b29"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Height" Value="36"/>
            <Setter Property="Margin" Value="0,0,0,6"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="sBorder" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="sBorder" Property="Background" Value="#a855f7"/>
                                <Setter TargetName="sBorder" Property="TextElement.Foreground" Value="#09080b"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border Background="#09080b" BorderBrush="#1f1b29" BorderThickness="1" CornerRadius="10">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="35"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="110"/>
            </Grid.RowDefinitions>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="220"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <!-- CUSTOM TITLEBAR -->
            <Grid Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="2" Background="#0f0d14" Name="TitleBarGrid">
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="12,0,0,0">
                    <TextBlock Text="✦  ASTROSS // MODERATION SUITE" FontSize="11" FontWeight="Bold" Foreground="#a855f7"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,0,8,0">
                    <Button x:Name="BtnMinimize" Content="—" Width="30" Height="22" Background="Transparent" Foreground="#888" BorderThickness="0" Cursor="Hand"/>
                    <Button x:Name="BtnClose" Content="✕" Width="30" Height="22" Background="Transparent" Foreground="#888" BorderThickness="0" Cursor="Hand"/>
                </StackPanel>
            </Grid>

            <!-- SIDEBAR -->
            <Border Grid.Row="1" Grid.Column="0" Background="#0f0d14" BorderBrush="#1f1b29" BorderThickness="0,0,1,0" Padding="12">
                <DockPanel>
                    <StackPanel DockPanel.Dock="Top">
                        <TextBlock Text="CONTROLS" FontSize="9" FontWeight="Bold" Foreground="#555" Margin="0,0,0,8"/>
                        <Button x:Name="BtnFolder" Content="Open Folder" Style="{StaticResource SideBtn}"/>
                        <Button x:Name="BtnPurge" Content="Clear Cache" Style="{StaticResource SideBtn}"/>
                        <Button x:Name="BtnNetLock" Content="Toggle NetLock" Style="{StaticResource SideBtn}" Foreground="#f87171"/>
                    </StackPanel>
                    <StackPanel DockPanel.Dock="Bottom">
                        <Border Background="#121017" BorderBrush="#1f1b29" BorderThickness="1" CornerRadius="6" Padding="10">
                            <StackPanel>
                                <TextBlock Text="STATUS: ACTIVE" FontSize="9" FontWeight="Bold" Foreground="#4ade80"/>
                                <TextBlock Text="v2.5 Professional" FontSize="9" Foreground="#666" Margin="0,2,0,0"/>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </DockPanel>
            </Border>

            <!-- MAIN CONTENT AREA -->
            <DockPanel Grid.Row="1" Grid.Column="1" Margin="15">
                <TextBlock DockPanel.Dock="Top" Text="Execution &amp; Artifact Analysis" FontSize="16" FontWeight="Bold" Foreground="White" Margin="0,0,0,12"/>
                
                <WrapPanel>
                    <Button Style="{StaticResource ToolCard}" Width="205" Height="90" Margin="0,0,8,8">
                        <StackPanel>
                            <TextBlock Text="PrefetchParser" FontWeight="Bold" Foreground="#c084fc" FontSize="12"/>
                            <TextBlock Text="Extracts execution timestamps from prefetch files." FontSize="10" Foreground="#888" TextWrapping="Wrap" Margin="0,4,0,0"/>
                        </StackPanel>
                    </Button>
                    <Button Style="{StaticResource ToolCard}" Width="205" Height="90" Margin="0,0,8,8">
                        <StackPanel>
                            <TextBlock Text="BAM Monitor" FontWeight="Bold" Foreground="#c084fc" FontSize="12"/>
                            <TextBlock Text="Background Activity Monitor telemetry scanner." FontSize="10" Foreground="#888" TextWrapping="Wrap" Margin="0,4,0,0"/>
                        </StackPanel>
                    </Button>
                    <Button Style="{StaticResource ToolCard}" Width="205" Height="90" Margin="0,0,8,8">
                        <StackPanel>
                            <TextBlock Text="ShimCache" FontWeight="Bold" Foreground="#c084fc" FontSize="12"/>
                            <TextBlock Text="AppCompatFlags historical execution audit." FontSize="10" Foreground="#888" TextWrapping="Wrap" Margin="0,4,0,0"/>
                        </StackPanel>
                    </Button>
                </WrapPanel>
            </DockPanel>

            <!-- TERMINAL CONSOLE -->
            <Border Grid.Row="2" Grid.Column="0" Grid.ColumnSpan="2" Background="#070609" BorderBrush="#1f1b29" BorderThickness="0,1,0,0" Padding="12">
                <DockPanel>
                    <TextBlock DockPanel.Dock="Top" Text="CONSOLE TELEMETRY" FontSize="9" FontWeight="Bold" Foreground="#7c3aed" Margin="0,0,0,4"/>
                    <TextBox x:Name="ConsoleBox" IsReadOnly="True" Background="Transparent" Foreground="#4ade80" BorderBrush="Transparent" BorderThickness="0" FontFamily="Consolas" FontSize="10" AcceptsReturn="True" VerticalScrollBarVisibility="Auto"/>
                </DockPanel>
            </Border>
        </Grid>
    </Border>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Window Controls & Dragging Binding
$window.FindName("BtnClose").Add_Click({ $window.Close() })
$window.FindName("BtnMinimize").Add_Click({ $window.WindowState = "Minimized" })
$window.FindName("TitleBarGrid").Add_MouseDown({
    if ($_.ChangedButton -eq "Left") { $window.DragMove() }
})

$ConsoleBox = $window.FindName("ConsoleBox")
$BtnFolder = $window.FindName("BtnFolder")
$BtnPurge = $window.FindName("BtnPurge")
$BtnNetLock = $window.FindName("BtnNetLock")

function Log($msg) {
    $time = Get-Date -Format "HH:mm:ss"
    $ConsoleBox.AppendText("[$time] $msg`r`n")
    $ConsoleBox.ScrollToEnd()
}

$BtnFolder.Add_Click({
    Start-Process explorer.exe $WorkDir
    Log "Opened directory: $WorkDir"
})

$BtnPurge.Add_Click({
    Remove-Item "$WorkDir\*" -Recurse -Force -ErrorAction SilentlyContinue
    Log "Purged local session temporary files."
})

$BtnNetLock.Add_Click({
    try {
        $rule = Get-NetFirewallRule -DisplayName "AstroSS-Netlock" -ErrorAction SilentlyContinue
        if ($rule) {
            Remove-NetFirewallRule -DisplayName "AstroSS-Netlock"
            Log "NetLock deactivated. Network restored."
        } else {
            New-NetFirewallRule -DisplayName "AstroSS-Netlock" -Direction Outbound -Action Block -Profile Any | Out-Null
            Log "NetLock engaged. Outbound connections blocked."
        }
    } catch {
        Log "Error modifying firewall states."
    }
})

Log "AstroSS initialized successfully. Ready."
[void]$window.ShowDialog()
