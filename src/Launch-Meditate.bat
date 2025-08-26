@echo off
title Meditate - Digital Zen Launcher
cd /d "%~dp0"

echo.
echo 🧘‍♂️ Meditate - Keep Your System Zen and Awake
echo ════════════════════════════════════════════
echo.
echo Starting your digital meditation session...
echo.

REM Check if PowerShell execution policy allows script execution
powershell.exe -Command "if ((Get-ExecutionPolicy) -eq 'Restricted') { Write-Host '⚠️  PowerShell execution policy is restricted.' -ForegroundColor Yellow; Write-Host '   Setting policy for current user...' -ForegroundColor Yellow; Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; Write-Host '✅ Execution policy updated successfully!' -ForegroundColor Green }"

REM Launch the GUI version
powershell.exe -ExecutionPolicy Bypass -File "Meditate-GUI.ps1"

echo.
echo 🙏 Meditation session ended. Your system found its zen.
echo.
pause
