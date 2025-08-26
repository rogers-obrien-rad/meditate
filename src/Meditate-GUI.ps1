Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Check and set execution policy if needed
try {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($currentPolicy -eq 'Restricted') {
        Write-Host "🔧 Adjusting PowerShell execution policy for current user..." -ForegroundColor Yellow
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "✅ Execution policy updated successfully!" -ForegroundColor Green
    }
} catch {
    Write-Warning "Could not update execution policy. You may need to run: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
}

# Define Windows API for SetThreadExecutionState
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [FlagsAttribute]
    public enum EXECUTION_STATE : uint {
        ES_AWAYMODE_REQUIRED = 0x00000040,
        ES_CONTINUOUS = 0x80000000,
        ES_DISPLAY_REQUIRED = 0x00000002,
        ES_SYSTEM_REQUIRED = 0x00000001
    }

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern uint SetThreadExecutionState(EXECUTION_STATE esFlags);
}
"@

# XAML for the GUI
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Meditate - Keep Your System Zen and Awake" Height="450" Width="520" ResizeMode="NoResize"
        WindowStartupLocation="CenterScreen" Background="#F8F9FA">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Header -->
        <StackPanel Grid.Row="0" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,20">
            <TextBlock Text="🧘‍♂️" FontSize="28" VerticalAlignment="Center" Margin="0,0,10,0"/>
            <TextBlock Text="Meditate" FontSize="28" FontWeight="Bold" Foreground="#6C5CE7" VerticalAlignment="Center"/>
        </StackPanel>

        <!-- Method Selection -->
        <GroupBox Grid.Row="1" Header="🔧 Activity Method" Margin="0,0,0,15" Padding="10" BorderBrush="#DDD6FE">
            <StackPanel>
                <RadioButton Name="RadioAPI" Content="Windows API - Mindful Power Management (Recommended)" IsChecked="True" Margin="5" FontWeight="SemiBold"/>
                <RadioButton Name="RadioKeyPress" Content="Key Press - Gentle F15 Touches" Margin="5"/>
                <RadioButton Name="RadioMouseMove" Content="Mouse Movement - Subtle Cursor Zen" Margin="5"/>
                <RadioButton Name="RadioBoth" Content="Balanced Approach - Key Press &amp; Mouse Movement" Margin="5"/>
            </StackPanel>
        </GroupBox>

        <!-- Interval Setting -->
        <GroupBox Grid.Row="2" Header="⏱️ Meditation Interval" Margin="0,0,0,15" Padding="10" BorderBrush="#DDD6FE">
            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
                <TextBlock Text="Breathe every " VerticalAlignment="Center" Margin="5,0"/>
                <TextBox Name="IntervalBox" Text="60" Width="60" VerticalAlignment="Center" TextAlignment="Center" 
                         BorderBrush="#6C5CE7" Padding="5"/>
                <TextBlock Text=" seconds" VerticalAlignment="Center" Margin="5,0"/>
            </StackPanel>
        </GroupBox>

        <!-- Control Buttons -->
        <StackPanel Grid.Row="3" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,0,0,15">
            <Button Name="StartButton" Content="🚀 Start Meditation" Width="140" Height="40" Margin="15,0" 
                    Background="#00B894" Foreground="White" FontWeight="Bold" BorderThickness="0" 
                    Style="{DynamicResource {x:Static ToolBar.ButtonStyleKey}}"/>
            <Button Name="StopButton" Content="🛑 End Session" Width="140" Height="40" Margin="15,0" 
                    Background="#E17055" Foreground="White" FontWeight="Bold" IsEnabled="False" BorderThickness="0"
                    Style="{DynamicResource {x:Static ToolBar.ButtonStyleKey}}"/>
        </StackPanel>

        <!-- Status Display -->
        <GroupBox Grid.Row="4" Header="📊 Current State" Margin="0,0,0,10" Padding="8" BorderBrush="#DDD6FE">
            <StackPanel>
                <TextBlock Name="StatusText" Text="🧘 Ready to begin your digital meditation..." Margin="5" FontSize="12" FontWeight="SemiBold"/>
                <ProgressBar Name="ProgressBar" Height="6" Margin="5,8,5,5" Visibility="Collapsed" 
                            Foreground="#6C5CE7" Background="#F1F2F6"/>
            </StackPanel>
        </GroupBox>

        <!-- Activity Log -->
        <GroupBox Grid.Row="5" Header="📝 Meditation Journal" Padding="8" BorderBrush="#DDD6FE">
            <ScrollViewer Name="LogScroller" VerticalScrollBarVisibility="Auto">
                <TextBlock Name="LogText" FontFamily="Segoe UI Mono" FontSize="10" TextWrapping="Wrap" 
                          Foreground="#2D3436" Background="White" Padding="8" Margin="2"/>
            </ScrollViewer>
        </GroupBox>

        <!-- Footer -->
        <StackPanel Grid.Row="6" HorizontalAlignment="Center" Margin="0,15,0,0">
            <TextBlock Text="🌟 Peaceful productivity, zero interruptions" 
                      HorizontalAlignment="Center" FontSize="11" Foreground="#636E72" FontStyle="Italic"/>
            <TextBlock Text="Double-click the journal to clear entries" 
                      HorizontalAlignment="Center" FontSize="9" Foreground="#B2BEC3" Margin="0,2,0,0"/>
        </StackPanel>
    </Grid>
</Window>
"@

# Load XAML
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Get UI elements
$startButton = $window.FindName("StartButton")
$stopButton = $window.FindName("StopButton")
$statusText = $window.FindName("StatusText")
$logText = $window.FindName("LogText")
$logScroller = $window.FindName("LogScroller")
$intervalBox = $window.FindName("IntervalBox")
$progressBar = $window.FindName("ProgressBar")
$radioAPI = $window.FindName("RadioAPI")
$radioKeyPress = $window.FindName("RadioKeyPress")
$radioMouseMove = $window.FindName("RadioMouseMove")
$radioBoth = $window.FindName("RadioBoth")

# Global variables
$script:isRunning = $false
$script:timer = $null
$script:iteration = 0

# Functions
function Add-LogEntry($message) {
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logEntry = "[$timestamp] $message`n"
    $logText.Text += $logEntry
    
    # Auto-scroll to bottom
    $logScroller.ScrollToBottom()
}

function Set-SystemActive {
    [Win32]::SetThreadExecutionState([Win32+EXECUTION_STATE]::ES_CONTINUOUS -bor [Win32+EXECUTION_STATE]::ES_SYSTEM_REQUIRED -bor [Win32+EXECUTION_STATE]::ES_DISPLAY_REQUIRED)
}

function Reset-SystemSleep {
    [Win32]::SetThreadExecutionState([Win32+EXECUTION_STATE]::ES_CONTINUOUS)
}

function Send-KeyPress {
    [System.Windows.Forms.SendKeys]::SendWait("{F15}")
}

function Move-Mouse {
    $currentX = [System.Windows.Forms.Cursor]::Position.X
    $currentY = [System.Windows.Forms.Cursor]::Position.Y
    
    [System.Windows.Forms.Cursor]::Position = [System.Drawing.Point]::new(($currentX + 1), $currentY)
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.Cursor]::Position = [System.Drawing.Point]::new($currentX, $currentY)
}

function Get-SelectedMethod {
    if ($radioAPI.IsChecked) { return "API" }
    if ($radioKeyPress.IsChecked) { return "KeyPress" }
    if ($radioMouseMove.IsChecked) { return "MouseMove" }
    if ($radioBoth.IsChecked) { return "Both" }
    return "API"
}

function Get-MethodDescription($method) {
    switch ($method) {
        "API" { return "🔮 Mindful Power Management" }
        "KeyPress" { return "⌨️ Gentle Key Touches" }
        "MouseMove" { return "🖱️ Subtle Cursor Movements" }
        "Both" { return "⚖️ Balanced Approach" }
        default { return "🧘 Digital Zen" }
    }
}

function Start-Activity {
    if ($script:isRunning) { return }
    
    # Validate interval
    $interval = 0
    if (-not [int]::TryParse($intervalBox.Text, [ref]$interval) -or $interval -lt 1) {
        [System.Windows.MessageBox]::Show("Please enter a valid meditation interval (1 second or greater)", "Invalid Input", "OK", "Warning")
        return
    }
    
    $script:isRunning = $true
    $script:iteration = 0
    $method = Get-SelectedMethod
    $methodDesc = Get-MethodDescription $method
    
    # UI Updates
    $startButton.IsEnabled = $false
    $stopButton.IsEnabled = $true
    $statusText.Text = "🧘 Meditating - $methodDesc every $interval seconds"
    $progressBar.Visibility = "Visible"
    $progressBar.IsIndeterminate = $true
    
    Add-LogEntry "🚀 Started digital meditation session using $methodDesc"
    
    # Set initial API state if using API method
    if ($method -eq "API") {
        Set-SystemActive
        Add-LogEntry "🔮 System consciousness elevated - sleep mode transcended"
    }
    
    # Create and start timer
    $script:timer = New-Object System.Windows.Threading.DispatcherTimer
    $script:timer.Interval = [TimeSpan]::FromSeconds($interval)
    $script:timer.Add_Tick({
        $script:iteration++
        $method = Get-SelectedMethod
        
        try {
            switch ($method) {
                "API" {
                    Set-SystemActive
                    Add-LogEntry "🔄 Renewed system awareness (breath #$($script:iteration))"
                }
                "KeyPress" {
                    Send-KeyPress
                    Add-LogEntry "⌨️ Gentle F15 touch sent (breath #$($script:iteration))"
                }
                "MouseMove" {
                    Move-Mouse
                    Add-LogEntry "🖱️ Cursor performed micro-meditation (breath #$($script:iteration))"
                }
                "Both" {
                    Move-Mouse
                    Start-Sleep -Milliseconds 500
                    Send-KeyPress
                    Add-LogEntry "⚖️ Balanced touch & movement harmony (breath #$($script:iteration))"
                }
            }
        }
        catch {
            Add-LogEntry "⚠️ Meditation interrupted: $($_.Exception.Message)"
        }
    })
    
    $script:timer.Start()
}

function Stop-Activity {
    if (-not $script:isRunning) { return }
    
    $script:isRunning = $false
    
    if ($script:timer) {
        $script:timer.Stop()
        $script:timer = $null
    }
    
    # Reset system sleep if we were using API
    $method = Get-SelectedMethod
    if ($method -eq "API") {
        Reset-SystemSleep
        Add-LogEntry "🌙 System returned to natural sleep patterns"
    }
    
    # UI Updates
    $startButton.IsEnabled = $true
    $stopButton.IsEnabled = $false
    $statusText.Text = "🧘 Session complete - Your system found its zen"
    $progressBar.Visibility = "Collapsed"
    $progressBar.IsIndeterminate = $false
    
    Add-LogEntry "✨ Meditation session ended gracefully after $($script:iteration) breaths"
}

# Event handlers
$startButton.Add_Click({ Start-Activity })
$stopButton.Add_Click({ Stop-Activity })

# Handle window closing
$window.Add_Closing({
    Stop-Activity
})

# Clear log function (double-click log to clear)
$logText.Add_MouseDoubleClick({
    $logText.Text = ""
    Add-LogEntry "📝 Meditation journal cleared - Fresh start achieved"
})

# Show initial log entry
Add-LogEntry "🧘‍♂️ Meditate v1.0 initialized - Ready to keep your system mindfully awake"
Add-LogEntry "💡 Tip: Choose your preferred meditation method above and click Start"

# Show the window
$window.ShowDialog() | Out-Null
