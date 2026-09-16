# ==============================================================================
# AstroSSTool - Native WPF Dark Theme Edition
# ==============================================================================

# Self-Elevation Check
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$ToolsDir = "$env:USERPROFILE\Downloads\AstroSSTool"
if (!(Test-Path $ToolsDir)) { New-Item -ItemType Directory -Force -Path$ToolsDir | Out-Null }

[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="AstroSSTool" Height="650" Width="980" WindowStartupLocation="CenterScreen"
    Background="#0b090e" Foreground="White" ResizeMode="CanMinimize">
    
    <Window.Resources>
        <Style TargetType="Button" x:Key="CardButtonStyle">
            <Setter Property="Background" Value="#17121f"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#2b203c"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6" Padding="12">
                            <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Top"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#21192e"/>
                    <Setter Property="BorderBrush" Value="#b464ff"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style TargetType="Button" x:Key="SidebarButtonStyle">
            <Setter Property="Background" Value="#17121f"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#2b203c"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Height" Value="34"/>
            <Setter Property="Margin" Value="0,0,0,6"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                    <Setter Property="Background" Value="#261b36"/>
                    <Setter Property="BorderBrush" Value="#b464ff"/>
                </Trigger>
            </Style.Triggers>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="230"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="120"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Grid.Column="0" Background="#120e17" BorderBrush="#1f1729" BorderThickness="0,0,1,0" Padding="15">
            <StackPanel>
                <TextBlock Text="^._.^ AstroSS" FontSize="16" FontWeight="Bold" Foreground="#b464ff" Margin="0,0,0,25"/>
                
                <TextBlock Text="ACTIONS" FontSize="10" Foreground="#6b7280" FontWeight="Bold" Margin="0,0,0,8"/>
                <Button x:Name="BtnOpenFolder" Content="Open Install Folder" Style="{StaticResource SidebarButtonStyle}"/>
                <Button x:Name="BtnClearFiles" Content="Clear Downloaded Files" Style="{StaticResource SidebarButtonStyle}"/>
                <Button x:Name="BtnNetLock" Content="Toggle NetLock" Style="{StaticResource SidebarButtonStyle}" Foreground="#ff6464"/>
                
                <TextBlock Text="CREDITS" FontSize="10" Foreground="#6b7280" FontWeight="Bold" Margin="0,30,0,5"/>
                <TextBlock Text="Made by Astro" FontSize="11" Foreground="#d1d5db" FontWeight="Bold"/>
                <TextBlock Text="Install path:" FontSize="10" Foreground="#6b7280" Margin="0,15,0,2"/>
                <TextBlock Text="$ToolsDir" FontSize="9" Foreground="#9ca3af" TextWrapping="Wrap"/>
            </StackPanel>
        </Border>

        <DockPanel Grid.Row="0" Grid.Column="1" Margin="15">
            <Border DockPanel.Dock="Top" Background="#120e17" BorderBrush="#1f1729" BorderThickness="1" CornerRadius="8" Padding="15" Margin="0,0,0,12">
                <Grid>
                    <StackPanel VerticalAlignment="Center">
                        <TextBlock Text="Ready" FontSize="18" FontWeight="Bold" Foreground="White"/>
                        <TextBlock Text="Select a tool to launch or download it." FontSize="11" Foreground="#9ca3af" Margin="0,2,0,0"/>
                    </StackPanel>
                    <Border HorizontalAlignment="Right" VerticalAlignment="Center" Background="#064e3b" BorderBrush="#065f46" BorderThickness="1" CornerRadius="12" Padding="12,4">
                        <TextBlock Text="IDLE" FontSize="11" FontWeight="Bold" Foreground="#4ade80"/>
                    </Border>
                </Grid>
            </Border>

            <TabControl Background="Transparent" BorderBrush="#1f1729">
                <TabItem Header="Orbdiff" Background="#120e17" Foreground="White" Padding="14,6">
                    <WrapPanel Margin="0,10,0,0">
                        <Button Style="{StaticResource CardButtonStyle}" Width="215" Height="85" Margin="0,0,8,8" Tag="PrefetchView">
                            <StackPanel>
                                <TextBlock Text="PrefetchView" FontWeight="Bold" Foreground="#b464ff" FontSize="13"/>
                                <TextBlock Text="Parses prefetch, extracts file info" FontSize="11" Foreground="#9ca3af" TextWrapping="Wrap" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Button>
                        <Button Style="{StaticResource CardButtonStyle}" Width="215" Height="85" Margin="0,0,8,8" Tag="BAMReveal">
                            <StackPanel>
                                <TextBlock Text="BAMReveal" FontWeight="Bold" Foreground="#b464ff" FontSize="13"/>
                                <TextBlock Text="Parses BAM forensic artifact" FontSize="11" Foreground="#9ca3af" TextWrapping="Wrap" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Button>
                        <Button Style="{StaticResource CardButtonStyle}" Width="215" Height="85" Margin="0,0,8,8" Tag="StringsParser">
                            <StackPanel>
                                <TextBlock Text="StringsParser" FontWeight="Bold" Foreground="#b464ff" FontSize="13"/>
                                <TextBlock Text="Strings + YARA + signatures scanner" FontSize="11" Foreground="#9ca3af" TextWrapping="Wrap" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Button>
                        <Button Style="{StaticResource CardButtonStyle}" Width="215" Height="85" Margin="0,0,8,8" Tag="InjGen">
                            <StackPanel>
                                <TextBlock Text="InjGen" FontWeight="Bold" Foreground="#b464ff" FontSize="13"/>
                                <TextBlock Text="Detects JNI/JVMTI memory injections" FontSize="11" Foreground="#9ca3af" TextWrapping="Wrap" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Button>
                    </WrapPanel>
                </TabItem>

                <TabItem Header="Spokwn" Background="#120e17" Foreground="White" Padding="14,6">
                    <WrapPanel Margin="0,10,0,0">
                        <Button Style="{StaticResource CardButtonStyle}" Width="215" Height="85" Margin="0,0,8,8">
                            <StackPanel>
                                <TextBlock Text="UserAssistView" FontWeight="Bold" Foreground="#b464ff" FontSize="13"/>
                                <TextBlock Text="Parses ROT13 UserAssist execution history" FontSize="11" Foreground="#9ca3af" TextWrapping="Wrap" Margin="0,4,0,0"/>
                            </StackPanel>
                        </Button>
                    </WrapPanel>
                </TabItem>
            </TabControl>
        </DockPanel>

        <Border Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2" Background="#070509" BorderBrush="#1f1729" BorderThickness="0,1,0,0" Padding="15">
            <DockPanel>
                <TextBlock DockPanel.Dock="Top" Text="ACTIVITY CONSOLE" FontSize="9" Foreground="#6b7280" FontWeight="Bold" Margin="0,0,0,5"/>
                <TextBox x:Name="ConsoleBox" IsReadOnly="True" Background="Transparent" Foreground="#4ade80" BorderBrush="Transparent" BorderThickness="0" FontFamily="Consolas" FontSize="11" AcceptsReturn="True" VerticalScrollBarVisibility="Auto"/>
            </DockPanel>
        </Border>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Map Elements
$ConsoleBox =$window.FindName("ConsoleBox")
$BtnOpenFolder =$window.FindName("BtnOpenFolder")
$BtnClearFiles =$window.FindName("BtnClearFiles")
$BtnNetLock =$window.FindName("BtnNetLock")

function Write-ConsoleLog($msg) {$timestamp = Get-Date -Format "HH:mm:ss"
    $ConsoleBox.AppendText("[$timestamp]$msg`r`n")
    $ConsoleBox.ScrollToEnd()
}

# Bind Sidebar Actions
$BtnOpenFolder.Add_Click({
    Start-Process explorer.exe $ToolsDir
    Write-ConsoleLog "Opened install directory: $ToolsDir"
})

$BtnClearFiles.Add_Click({
    Remove-Item "$ToolsDir\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-ConsoleLog "Cleared downloaded tool cache."
})

$BtnNetLock.Add_Click({
    try {
        $rule = Get-NetFirewallRule -DisplayName "AstroSS-Netlock" -ErrorAction SilentlyContinue
        if ($rule) {
            Remove-NetFirewallRule -DisplayName "AstroSS-Netlock"
            Write-ConsoleLog "NetLock DISABLED: Network access restored."
        } else {
            New-NetFirewallRule -DisplayName "AstroSS-Netlock" -Direction Outbound -Action Block -Profile Any | Out-Null
            Write-ConsoleLog "NetLock ENGAGED: Outbound traffic blocked."
        }
    } catch {
        Write-ConsoleLog "ERROR: Failed to update firewall rules."
    }
})

# Bind Tool Cards dynamically
$window.FindName("Orbdiff").Content | Get-Member -Name "Add_Click" -ErrorAction SilentlyContinue

Write-ConsoleLog "Files
