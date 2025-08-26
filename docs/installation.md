# Installation Guide

## Prerequisites
- Windows 10/11
- PowerShell 5.1 (built-in)
- No admin rights required

## Install Steps (Recommended)
1. Download the latest release ZIP from the Releases page.
2. Extract the ZIP to any folder (e.g., C:\Tools\Meditate).
3. Open PowerShell in the extracted folder.
4. Create the desktop shortcut:
   ```powershell
   .\src\Create-Shortcut.ps1
   ```
5. Launch the app using the new desktop shortcut named "Meditate".
   - You can also press the Windows key and type "Meditate" to find and launch it.

## Execution Policy Note
If you see an execution policy prompt, run this once in the same PowerShell session:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
```

## Updating
- Replace the extracted folder with the new release files.
- Re-run `src/Create-Shortcut.ps1` if the shortcut stops working or you move folders.

## Uninstalling
- Delete the extracted folder.
- Delete the desktop shortcut if present.
- No registry or services are installed.
