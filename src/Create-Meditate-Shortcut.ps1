# Create-Meditate-Shortcut.ps1
# Run this once to create a desktop shortcut for Meditate

Write-Host "🧘‍♂️ Creating Meditate shortcut..." -ForegroundColor Magenta

# Get the directory where this script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$meditateGuiPath = Join-Path $scriptDir "Meditate-GUI.ps1"

# Check if Meditate-GUI.ps1 exists
if (-not (Test-Path $meditateGuiPath)) {
    Write-Error "❌ Could not find Meditate-GUI.ps1 in the same directory as this script"
    Write-Host "Make sure both files are in the same folder:" -ForegroundColor Yellow
    Write-Host "  - Create-Meditate-Shortcut.ps1" -ForegroundColor Yellow
    Write-Host "  - Meditate-GUI.ps1" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    return
}

# Create shortcut on desktop
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "Meditate.lnk"

try {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    
    # Set shortcut properties
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Normal -File `"$meditateGuiPath`""
    $shortcut.WorkingDirectory = $scriptDir
    $shortcut.Description = "Meditate - Keep Your System Zen and Awake"
    $shortcut.IconLocation = "powershell.exe,0"  # Use PowerShell icon
    
    # Save the shortcut
    $shortcut.Save()
    
    Write-Host "✅ Success! Meditate shortcut created on desktop" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now:" -ForegroundColor Cyan
    Write-Host "  📍 Double-click the 'Meditate' shortcut on your desktop" -ForegroundColor White
    Write-Host "  📍 Copy the shortcut anywhere you need it" -ForegroundColor White
    Write-Host "  📍 Pin it to taskbar by right-clicking the shortcut" -ForegroundColor White
    Write-Host ""
    Write-Host "🧘 The shortcut will launch Meditate without needing .bat files!" -ForegroundColor Green
    
} catch {
    Write-Error "❌ Failed to create shortcut: $($_.Exception.Message)"
}

Write-Host ""
Read-Host "Press Enter to exit"
