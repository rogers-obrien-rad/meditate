# Ensure any previous sessions are terminated
$currentPID = $PID
$scriptName = $MyInvocation.MyCommand.Name
$previousInstances = Get-Process -Name powershell | Where-Object {
    $_.Id -ne $currentPID -and $_.CommandLine -like "*$scriptName*"
} -ErrorAction SilentlyContinue

if ($previousInstances) {
    Write-Host "Closing previous Meditate sessions..." -ForegroundColor Yellow
    $previousInstances | ForEach-Object { $_.Kill() }
    Start-Sleep -Seconds 1  # Give time for cleanup
}

# Reset system execution state in case a previous instance didn't clean up properly
$resetCode = @"
using System;
using System.Runtime.InteropServices;

public static class Reset {
    [Flags]
    public enum EXECUTION_STATE : uint {
        ES_CONTINUOUS = 0x80000000
    }

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern EXECUTION_STATE SetThreadExecutionState(EXECUTION_STATE esFlags);
}
"@

try {
    Add-Type -TypeDefinition $resetCode -Language CSharp -ErrorAction SilentlyContinue
    [Reset]::SetThreadExecutionState([Reset+EXECUTION_STATE]::ES_CONTINUOUS) | Out-Null
} catch {}

# Clear any global variables from previous sessions
Remove-Variable -Name isRunning, timer, iteration, logHistory, lastTickTime, nextTickDue, intervalSeconds -ErrorAction SilentlyContinue -Scope Global

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Define Windows API for keeping the system awake
$Win32Code = @"
using System;
using System.Runtime.InteropServices;

public static class Win32 {
    [Flags]
    public enum EXECUTION_STATE : uint {
        ES_CONTINUOUS = 0x80000000,
        ES_SYSTEM_REQUIRED = 0x00000001,
        ES_DISPLAY_REQUIRED = 0x00000002,
        ES_AWAYMODE_REQUIRED = 0x00000040
    }

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern EXECUTION_STATE SetThreadExecutionState(EXECUTION_STATE esFlags);
}
"@

Add-Type -TypeDefinition $Win32Code -Language CSharp -ErrorAction SilentlyContinue

# Ensure system is in normal state (not preventing sleep)
try { [Win32]::SetThreadExecutionState([Win32+EXECUTION_STATE]::ES_CONTINUOUS) } catch {}

# Stop any previously running meditation processes
$currentPID = $PID
$allPowerShell = Get-Process -Name powershell -ErrorAction SilentlyContinue
foreach($proc in $allPowerShell) {
    if ($proc.Id -ne $currentPID) {
        try {
            $proc.CloseMainWindow() | Out-Null
            Start-Sleep -Milliseconds 100
            if (!$proc.HasExited) { $proc.Kill() }
        } catch {}
    }
}

# Force kill any previous instances of this script
Get-Process -Name powershell -ErrorAction SilentlyContinue | Where-Object {
    $_.Id -ne $PID
} | ForEach-Object {
    try { $_.Kill(); Start-Sleep -Milliseconds 100 } catch {}
}

# Stop any Windows API execution state from previous runs
try {
    [Win32]::SetThreadExecutionState([Win32+EXECUTION_STATE]::ES_CONTINUOUS) 
} catch {}

# Hard reset of all global variables to ensure clean startup - IMPORTANT: start with NOT running
$global:isRunning = $false
$global:timer = $null
$global:iteration = 0
# Create a new empty log history
$global:logHistory = New-Object System.Collections.Generic.List[string]

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Meditate - Keep Your System Awake"
$form.Size = New-Object System.Drawing.Size(550, 580)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Create fonts
$titleFont = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$headerFont = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$normalFont = New-Object System.Drawing.Font("Segoe UI", 9)

# Title label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(150, 20)
$titleLabel.Size = New-Object System.Drawing.Size(250, 30)
$titleLabel.Text = "Meditate"
$titleLabel.Font = $titleFont
$titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($titleLabel)

# Method group box
$methodGroupBox = New-Object System.Windows.Forms.GroupBox
$methodGroupBox.Location = New-Object System.Drawing.Point(30, 60)
$methodGroupBox.Size = New-Object System.Drawing.Size(490, 140)
$methodGroupBox.Text = "Activity Method"
$methodGroupBox.Font = $headerFont
$form.Controls.Add($methodGroupBox)

# Radio buttons for methods
$radioAPI = New-Object System.Windows.Forms.RadioButton
$radioAPI.Location = New-Object System.Drawing.Point(20, 30)
$radioAPI.Size = New-Object System.Drawing.Size(450, 20)
$radioAPI.Text = "Windows API - Mindful Power Management (Recommended)"
$radioAPI.Font = $normalFont
$radioAPI.Checked = $true
$methodGroupBox.Controls.Add($radioAPI)

$radioKeyPress = New-Object System.Windows.Forms.RadioButton
$radioKeyPress.Location = New-Object System.Drawing.Point(20, 55)
$radioKeyPress.Size = New-Object System.Drawing.Size(450, 20)
$radioKeyPress.Text = "Key Press - Gentle F15 Touches"
$radioKeyPress.Font = $normalFont
$methodGroupBox.Controls.Add($radioKeyPress)

$radioMouseMove = New-Object System.Windows.Forms.RadioButton
$radioMouseMove.Location = New-Object System.Drawing.Point(20, 80)
$radioMouseMove.Size = New-Object System.Drawing.Size(450, 20)
$radioMouseMove.Text = "Mouse Movement - Subtle Cursor Zen"
$radioMouseMove.Font = $normalFont
$methodGroupBox.Controls.Add($radioMouseMove)

$radioBoth = New-Object System.Windows.Forms.RadioButton
$radioBoth.Location = New-Object System.Drawing.Point(20, 105)
$radioBoth.Size = New-Object System.Drawing.Size(450, 20)
$radioBoth.Text = "Balanced Approach - Key Press and Mouse Movement"
$radioBoth.Font = $normalFont
$methodGroupBox.Controls.Add($radioBoth)

# Interval group box
$intervalGroupBox = New-Object System.Windows.Forms.GroupBox
$intervalGroupBox.Location = New-Object System.Drawing.Point(30, 210)
$intervalGroupBox.Size = New-Object System.Drawing.Size(490, 70)
$intervalGroupBox.Text = "Meditation Interval"
$intervalGroupBox.Font = $headerFont
$form.Controls.Add($intervalGroupBox)

# Interval label
$intervalLabel = New-Object System.Windows.Forms.Label
$intervalLabel.Location = New-Object System.Drawing.Point(140, 30)
$intervalLabel.Size = New-Object System.Drawing.Size(100, 20)
$intervalLabel.Text = "Breathe every"
$intervalLabel.Font = $normalFont
$intervalLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$intervalGroupBox.Controls.Add($intervalLabel)

# Interval textbox
$intervalTextBox = New-Object System.Windows.Forms.TextBox
$intervalTextBox.Location = New-Object System.Drawing.Point(250, 30)
$intervalTextBox.Size = New-Object System.Drawing.Size(50, 20)
$intervalTextBox.Text = "60"
$intervalTextBox.Font = $normalFont
$intervalTextBox.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
$intervalGroupBox.Controls.Add($intervalTextBox)

# Seconds label
$secondsLabel = New-Object System.Windows.Forms.Label
$secondsLabel.Location = New-Object System.Drawing.Point(310, 30)
$secondsLabel.Size = New-Object System.Drawing.Size(70, 20)
$secondsLabel.Text = "seconds"
$secondsLabel.Font = $normalFont
$secondsLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$intervalGroupBox.Controls.Add($secondsLabel)

# Buttons panel
$buttonsPanel = New-Object System.Windows.Forms.Panel
$buttonsPanel.Location = New-Object System.Drawing.Point(30, 290)
$buttonsPanel.Size = New-Object System.Drawing.Size(490, 50)
$form.Controls.Add($buttonsPanel)

# Start button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Location = New-Object System.Drawing.Point(120, 10)
$startButton.Size = New-Object System.Drawing.Size(120, 30)
$startButton.Text = "Start Meditation"
$startButton.Font = $normalFont
$startButton.BackColor = [System.Drawing.Color]::FromArgb(0, 184, 148)
$startButton.ForeColor = [System.Drawing.Color]::White
$startButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonsPanel.Controls.Add($startButton)

# Stop button
$stopButton = New-Object System.Windows.Forms.Button
$stopButton.Location = New-Object System.Drawing.Point(250, 10)
$stopButton.Size = New-Object System.Drawing.Size(120, 30)
$stopButton.Text = "End Session"
$stopButton.Font = $normalFont
$stopButton.BackColor = [System.Drawing.Color]::FromArgb(225, 112, 85)
$stopButton.ForeColor = [System.Drawing.Color]::White
$stopButton.Enabled = $false
$stopButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonsPanel.Controls.Add($stopButton)

# Status panel
$statusPanel = New-Object System.Windows.Forms.Panel
$statusPanel.Location = New-Object System.Drawing.Point(30, 350)
$statusPanel.Size = New-Object System.Drawing.Size(490, 30)
$form.Controls.Add($statusPanel)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(0, 5)
$statusLabel.Size = New-Object System.Drawing.Size(490, 20)
$statusLabel.Text = "Ready to begin your digital meditation..."
$statusLabel.Font = $normalFont
$statusLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$statusPanel.Controls.Add($statusLabel)

# Log group box
$logGroupBox = New-Object System.Windows.Forms.GroupBox
$logGroupBox.Location = New-Object System.Drawing.Point(30, 390)
$logGroupBox.Size = New-Object System.Drawing.Size(490, 140)
$logGroupBox.Text = "Meditation Journal"
$logGroupBox.Font = $headerFont
$form.Controls.Add($logGroupBox)

# Log textbox
$logTextBox = New-Object System.Windows.Forms.TextBox
$logTextBox.Location = New-Object System.Drawing.Point(10, 25)
$logTextBox.Size = New-Object System.Drawing.Size(470, 105)
$logTextBox.Multiline = $true
$logTextBox.Font = New-Object System.Drawing.Font("Consolas", 8)
$logTextBox.ReadOnly = $true
$logTextBox.ScrollBars = "Vertical"
$logGroupBox.Controls.Add($logTextBox)

# Functions
function Add-LogEntry($message) {
    # Always work with the global log history collection
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logEntry = "[$timestamp] $message"
    $global:logHistory.Add($logEntry)
    
    # Keep only the last 5 entries
    if ($global:logHistory.Count -gt 5) {
        $global:logHistory.RemoveAt(0)
    }
    
    # Clear the display and show only current entries
    $logTextBox.Clear()
    foreach ($entry in $global:logHistory) {
        $logTextBox.AppendText($entry + "`r`n")
    }
    $logTextBox.SelectionStart = $logTextBox.Text.Length
    $logTextBox.ScrollToCaret()
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
    
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(($currentX + 1), $currentY)
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($currentX, $currentY)
}

function Get-SelectedMethod {
    if ($radioAPI.Checked) { return "API" }
    if ($radioKeyPress.Checked) { return "KeyPress" }
    if ($radioMouseMove.Checked) { return "MouseMove" }
    if ($radioBoth.Checked) { return "Both" }
    return "API"
}

function Get-MethodDescription($method) {
    switch ($method) {
        "API" { return "Mindful Power Management" }
        "KeyPress" { return "Gentle Key Touches" }
        "MouseMove" { return "Subtle Cursor Movements" }
        "Both" { return "Balanced Approach" }
        default { return "Digital Zen" }
    }
}

function Start-Activity {
    # Explicitly check global variable to prevent issues
    if ($global:isRunning -eq $true) { return }
    
    # Validate interval
    $interval = 0
    if (-not [int]::TryParse($intervalTextBox.Text, [ref]$interval) -or $interval -lt 1) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid meditation interval (1 second or greater)", "Invalid Input", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    # Clean any existing state before starting
    Stop-Activity -Silent $true
    
    # Now set up new state
    $global:isRunning = $true
    $global:iteration = 0
    $method = Get-SelectedMethod
    $methodDesc = Get-MethodDescription $method
    
    # UI Updates
    $startButton.Enabled = $false
    $stopButton.Enabled = $true
    $statusLabel.Text = "Meditating - $methodDesc every $interval seconds"
    
    Add-LogEntry "Started digital meditation session using $methodDesc"
    
    # Set initial API state if using API method
    if ($method -eq "API") {
        Set-SystemActive
        Add-LogEntry "System consciousness elevated - sleep mode transcended"
    }
    
    # Create and start timer using Windows.Forms.Timer
    # This timer type isn't always accurate, so we'll implement a check
    $global:timer = New-Object System.Windows.Forms.Timer
    $global:timer.Interval = 1000  # Check every second instead
    $global:nextTickDue = [DateTime]::Now.AddSeconds($interval)
    $global:intervalSeconds = $interval
    
    $global:timer.Add_Tick({
        $method = Get-SelectedMethod
        
        try {
            if ([DateTime]::Now -ge $global:nextTickDue) {
                # Increment breath count only when the scheduled interval elapses
                $global:iteration++
                switch ($method) {
                    "API" {
                        Set-SystemActive
                        Add-LogEntry "Renewed system awareness (breath #$global:iteration)"
                    }
                    "KeyPress" {
                        Send-KeyPress
                        Add-LogEntry "Gentle F15 touch sent (breath #$global:iteration)"
                    }
                    "MouseMove" {
                        Move-Mouse
                        Add-LogEntry "Cursor zen movement completed (breath #$global:iteration)"
                    }
                    "Both" {
                        Move-Mouse
                        Start-Sleep -Milliseconds 500
                        Send-KeyPress
                        Add-LogEntry "Balanced touch and movement harmony (breath #$global:iteration)"
                    }
                }
                $global:nextTickDue = [DateTime]::Now.AddSeconds($global:intervalSeconds)
            }
        }
        catch {
            Add-LogEntry "Meditation interrupted: $($_.Exception.Message)"
        }
    })
    
    $global:timer.Start()
}

function Stop-Activity {
    param([bool]$Silent = $false)
    
    # Always stop timer regardless of isRunning state
    if ($global:timer) {
        try {
            $global:timer.Stop()
            $global:timer.Dispose()
            $global:timer = $null
        } catch {}
    }

    # Reset execution state back to normal
    Reset-SystemSleep

    # Only update UI and log if we were actually running
    if ($global:isRunning) {
        # Update UI
        $global:isRunning = $false
        $startButton.Enabled = $true
        $stopButton.Enabled = $false
        $statusLabel.Text = "Meditation stopped - System will sleep normally"

        # Log the completed session
        if (-not $Silent) {
            Add-LogEntry "Meditation session ended after $global:iteration intervals"
        }
    }
}

# Add button event handlers
$startButton.Add_Click({ Start-Activity })
$stopButton.Add_Click({
    Stop-Activity
    $startButton.Enabled = $true
    $stopButton.Enabled = $false
})

# Handle form closing
$form.Add_FormClosing({
    # Ensure clean shutdown
    Stop-Activity
    
    # Force reset of system execution state
    Reset-SystemSleep
    
    # Ensure application exits cleanly
    [System.Windows.Forms.Application]::Exit()
})

# Make absolutely sure the log is cleared
$logTextBox.Clear()
$logTextBox.Text = ""
$global:logHistory = New-Object System.Collections.Generic.List[string]

# Reset status display to initial state
$statusLabel.Text = "Ready - System will sleep normally"

# Ensure buttons are in correct initial state
$startButton.Enabled = $true
$stopButton.Enabled = $false

# Show only initialization message
Add-LogEntry "Meditate v1.0 initialized - NOT running"

# Show the form
[System.Windows.Forms.Application]::Run($form)

# Clean up resources and ensure proper exit
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

# Clean up without trying to release non-existent COM objects

# Reset execution state one final time
Reset-SystemSleep

# Exit cleanly and forcefully
$host.UI.RawUI.FlushInputBuffer()

# Make absolutely sure we reset system execution state
try {
    [Reset]::SetThreadExecutionState([Reset+EXECUTION_STATE]::ES_CONTINUOUS) | Out-Null
} catch {
    [Win32]::SetThreadExecutionState([Win32+EXECUTION_STATE]::ES_CONTINUOUS)
}

# Force exit with no lingering processes
[System.Environment]::Exit(0)
