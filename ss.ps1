# ==============================================================================
# AstroSS - Official Aura-Styled Forensic Suite
# ==============================================================================

If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$WorkDir = "$env:USERPROFILE\Downloads\AstroSSTool"
if (!(Test-Path $WorkDir)) { New-Item -ItemType Directory -Force -Path$WorkDir | Out-Null }

[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="AstroSS // Aura Suite" Height="680" Width="1000" 
    WindowStartupLocation="CenterScreen" Background="#0c0a10" Foreground="White" 
    ResizeMode="CanMinimize" AllowsTransparency="False" WindowStyle="SingleBorderWindow">
    
    <Window.Resources>
        <Style TargetType="Button" x:Key="AuraCard">
            <Setter Property="Background" Value="#15121c"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#251f33"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="10" Padding="15">
                            <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Top"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Background" Value="#1d1727"/>
                                <Setter TargetName="border" Property="BorderBrush" Value="#c084fc"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="Button" x:Key="SidebarBtn">
            <Setter Property="Background" Value="#15121c"/>
            <Setter Property="Foreground" Value="#d8b4fe"/>
            <Setter Property="BorderBrush" Value="#251f33"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Height" Value="40"/>
            <Setter Property="Margin" Value="0,0,0,8"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="b" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="8">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="b" Property="Background" Value="#c084fc"/>
                                <Setter TargetName="b" Property="TextElement.Foreground" Value="#0c0a10"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="15">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="240"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="130"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Grid.Column="0" Background="#100e16" BorderBrush="#1f1a29" BorderThickness="1" CornerRadius="12" Padding="15" Margin="0,0,12,0">
            <DockPanel>
                <StackPanel DockPanel.Dock="Top">
                    <TextBlock Text="✦ ASTROSS" FontSize="18" FontWeight="Black" Foreground="#c084fc" Margin="0,5,0,25"/>
                    <TextBlock Text="CORE CONTROLS" FontSize="10" Foreground="#6b7280" FontWeight="Bold" Margin="0,0,0,10"/>
                    
                    <Button x:Name="BtnFolder" Content="Open Workspace" Style="{StaticResource SidebarBtn}"/>
                    <Button x:Name="BtnClean" Content="Purge Cache" Style="{StaticResource SidebarBtn}"/>
                    <Button x:Name="BtnNetLock" Content="Toggle NetLock" Style="{StaticResource SidebarBtn}" Foreground="#f87171"/>
                </StackPanel>

                <StackPanel DockPanel.Dock="Bottom">
                    <Border Background="#15121c" BorderBrush="#251f33" BorderThickness="1" CornerRadius="8" Padding="10">
                        <StackPanel>
                            <TextBlock Text="STATUS: ONLINE" FontSize="10" FontWeight="Bold" Foreground="#4ade80"/>
                            <TextBlock Text="Astro Suite v2.0" FontSize="10" Foreground="#9ca3af" Margin="0,3,0,0"/>
                        </StackPanel>
                    </Border>
                </StackPanel>
            </DockPanel>
        </Border>

        <DockPanel Grid.Row="0" Grid.Column="1">
            <Border DockPanel.Dock="Top" Background="#100e16" BorderBrush="#1f1a29" BorderThickness="1" CornerRadius="12" Padding="20" Margin="0,
