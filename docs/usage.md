# Usage Instructions

## Launching the App (Recommended)
- Use the Desktop shortcut named "Meditate" created by `src/Create-Shortcut.ps1`.
- You can also press the Windows key and type "Meditate" to search and launch the shortcut.

The shortcut starts PowerShell hidden so you only see the app window.

## Using the GUI
1. Choose a meditation method:
   - API (recommended): Uses Windows power API to keep the system awake
   - KeyPress: Sends safe F15 key presses periodically
   - MouseMove: Moves the mouse 1px and back periodically
   - Both: Combines KeyPress + MouseMove
2. Set the interval (seconds) between actions.
3. Click "Start Meditation" to begin; click "End Session" to stop.
4. Watch the "Meditation Journal" for recent activity (breath count increments by interval).
5. The status bar shows whether the system is being kept awake.

Notes:
- Stopping a session restores system sleep to normal.
- Starting a new session cleans up any previous timers/state.

## Command Line (Alternative)
For silent sessions without the GUI, run from the project folder:
```powershell
# Default (60s interval, API method)
.\Meditate-CLI.ps1

# Custom interval and method
.\Meditate-CLI.ps1 -Interval 30 -Method KeyPress

# Silent mode (minimal output)
.\Meditate-CLI.ps1 -Quiet
```

Parameters:
- `-Interval <int>`: seconds (>= 1)
- `-Method <API|KeyPress|MouseMove|Both>`
- `-Quiet`: reduce output

## Exiting
- Close the window or click "End Session". The app restores normal sleep settings and exits cleanly.
