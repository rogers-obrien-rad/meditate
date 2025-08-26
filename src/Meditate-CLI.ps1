param(
    [Parameter(Mandatory=$false)]
    [int]$Interval = 60,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("API", "KeyPress", "MouseMove", "Both")]
    [string]$Method = "API",
    
    [Parameter(Mandatory=$false)]
    [switch]$Help,

    [Parameter(Mandatory=$false)]
    [switch]$Quiet
)

# Display help information
if ($Help) {
    Write-Host "🧘‍♂️ Meditate - Keep Your System Zen and Awake" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "DESCRIPTION:" -ForegroundColor Yellow
    Write-Host "  Meditate keeps your system awake during long processes using mindful"
    Write-Host "  digital meditation techniques. Choose your preferred method of staying active."
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\Meditate-CLI.ps1 [-Interval <seconds>] [-Method <method>] [-Quiet] [-Help]"
    Write-Host ""
    Write-Host "PARAMETERS:" -ForegroundColor Yellow
    Write-Host "  -Interval    Meditation breathing interval in seconds (default: 60)"
    Write-Host "  -Method      Meditation technique:"
    Write-Host "               API (default) - Mindful Windows power management"
    Write-Host "               KeyPress - Gentle F15 key meditation"
    Write-Host "               MouseMove - Subtle cursor zen movements"
    Write-Host "               Both - Balanced key press and mouse harmony"
    Write-Host "  -Quiet       Silent meditation mode (minimal output)"
    Write-Host "  -Help        Display this wisdom"
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\Meditate-CLI.ps1                              # Default meditation"
    Write-Host "  .\Meditate-CLI.ps1 -Method KeyPress             # Key press meditation"
    Write-Host "  .\Meditate-CLI.ps1 -Interval 30 -Method Both    # Balanced approach, 30s intervals"
    Write-Host "  .\Meditate-CLI.ps1 -Quiet                       # Silent session"
    Write-Host ""
    Write-Host "Press Ctrl+C to end your meditation session gracefully" -ForegroundColor Green
    return
}

# Validate interval
if ($Interval -lt 1) {
    Write-Error "🚫 Meditation interval must be at least 1 second for proper mindfulness"
    return
}

# Load required assemblies
Add-Type -AssemblyName System.Windows.Forms

# Define Windows API constants for SetThreadExecutionState
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

# Function to prevent sleep using Windows API
function Set-SystemActive {
    [Win32]::SetThreadExecutionState([Win32+EXECUTION_STATE]::ES_CONTINUOUS -bor [Win32+EXECUTION_STATE]::ES_SYSTEM_REQUIRED -bor [Win32+EXECUTION_STATE]::ES_DISPLAY_REQUIRED)
}

# Function to reset sleep settings
function Reset-SystemSleep {
    [Win32]::SetThreadExecutionState([Win32+EXECUTION_STATE]::ES_CONTINUOUS)
}

# Function to send key press
function Send-KeyPress {
    [System.Windows.Forms.SendKeys]::SendWait("{F15}")
}

# Function to move mouse
function Move-Mouse {
    $currentX = [System.Windows.Forms.Cursor]::Position.X
    $currentY = [System.Windows.Forms.Cursor]::Position.Y
    
    # Move mouse 1 pixel right then back
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point(($currentX + 1), $currentY)
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($currentX, $currentY)
}

# Get method description for logging
function Get-MethodDescription($method) {
    switch ($method) {
        "API" { return "🔮 Mindful Power Management" }
        "KeyPress" { return "⌨️ Gentle Key Meditation" }
        "MouseMove" { return "🖱️ Cursor Zen Movements" }
        "Both" { return "⚖️ Balanced Harmony" }
        default { return "🧘 Digital Zen" }
    }
}

# Logging function
function Write-MeditateLog($message, $isQuiet = $false) {
    if (-not $isQuiet -and -not $Quiet) {
        $timestamp = Get-Date -Format 'HH:mm:ss'
        Write-Host "[$timestamp] $message" -ForegroundColor Cyan
    }
}

# Display startup information
if (-not $Quiet) {
    Write-Host ""
    Write-Host "🧘‍♂️ Meditate - Digital Mindfulness Session Starting" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════════" -ForegroundColor DarkMagenta
    Write-Host "Method: $(Get-MethodDescription $Method)" -ForegroundColor Yellow
    Write-Host "Breathing Interval: $Interval seconds" -ForegroundColor Yellow
    Write-Host "Mode: $(if ($Quiet) { '🤫 Silent Meditation' } else { '📢 Mindful Logging' })" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press Ctrl+C to end your session gracefully" -ForegroundColor Green
    Write-Host ""
}

$iteration = 0

try {
    # If using API method, set it once at the start
    if ($Method -eq "API") {
        Write-MeditateLog "🔮 Elevating system consciousness - transcending sleep mode"
        Set-SystemActive
        
        # Keep the script running and occasionally refresh the setting
        while ($true) {
            $iteration++
            Start-Sleep -Seconds $Interval
            
            # Refresh the execution state periodically
            Set-SystemActive
            Write-MeditateLog "🔄 Consciousness renewed - breath #$iteration"
        }
    } else {
        # Use periodic activities for other methods
        while ($true) {
            $iteration++
            
            switch ($Method) {
                "KeyPress" {
                    Send-KeyPress
                    Write-MeditateLog "⌨️ Gentle F15 touch sent - breath #$iteration"
                }
                "MouseMove" {
                    Move-Mouse
                    Write-MeditateLog "🖱️ Cursor zen movement completed - breath #$iteration"
                }
                "Both" {
                    Move-Mouse
                    Start-Sleep -Milliseconds 500
                    Send-KeyPress
                    Write-MeditateLog "⚖️ Balanced harmony achieved - breath #$iteration"
                }
            }
            
            Start-Sleep -Seconds $Interval
        }
    }
}
catch {
    if (-not $Quiet) {
        Write-Host ""
        Write-Host "🙏 Meditation session ended gracefully" -ForegroundColor Green
    }
}
finally {
    # Reset system sleep settings if we were using the API method
    if ($Method -eq "API") {
        Reset-SystemSleep
        Write-MeditateLog "🌙 System returned to natural sleep patterns"
    }
    
    if (-not $Quiet) {
        Write-Host ""
        Write-Host "✨ Digital meditation complete after $iteration breaths" -ForegroundColor Magenta
        Write-Host "🧘‍♂️ Your system found its zen. Namaste." -ForegroundColor Magenta
        Write-Host ""
    }
}
