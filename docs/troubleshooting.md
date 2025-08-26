# Troubleshooting

## Common Issues

### The PowerShell window appears and stays open
- Launch using the Desktop shortcut created by `src/Create-Shortcut.ps1`.
- The shortcut starts PowerShell with `-WindowStyle Hidden` so the console is not obtrusive.

### Execution policy warning
- Run this once in the same PowerShell session, then re-run the shortcut creator:
```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\src\Create-Shortcut.ps1
```

### The app auto-starts a session when I open it
- This has been corrected. If it persists, ensure you are on the latest release and re-create the shortcut.

### Breath count increments too fast / by seconds
- Fixed in the GUI: breath increments only when the configured interval elapses.
- Update to the latest release if you still see this behavior.

### System still sleeps while meditating (API method)
- Ensure "API" is selected (recommended) and that you see journal entries like "Renewed system awareness".
- Some corporate policies may override user power settings; try "Both" method as a fallback.

### How do I stop it?
- Click "End Session" in the app, or just close the window. The app resets system sleep settings on exit.

### Shortcut not found when searching "Meditate"
- Run `src/Create-Shortcut.ps1` again to recreate the shortcut on the Desktop.
- You can also pin the shortcut to Start/Taskbar.

### Still having issues?
- Please open an issue with your Windows version and a short description of what happened.
