# Create a shortcut for Meditate

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$meditateGuiPath = Join-Path $scriptDir "Meditate.ps1"

# Create shortcut on desktop
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "Meditate.lnk"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)

# Set shortcut properties
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$meditateGuiPath`""
$shortcut.WorkingDirectory = $scriptDir
$shortcut.Description = "Meditate - Keep Your System Zen and Awake"
$shortcut.IconLocation = "powershell.exe,0"
 
# Also set the shortcut's window style to Minimized as a fallback (some hosts ignore Hidden)
$shortcut.WindowStyle = 7

# Save the shortcut
$shortcut.Save()

Write-Host "Shortcut created successfully on desktop!"
