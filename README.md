# 🧘‍♂️ Meditate

> Keep Your System Zen and Awake

**Meditate** is a mindful solution for preventing your Windows computer from going to sleep during long-running processes like large file downloads, Revit operations, or data processing tasks. Inspired by the Pokémon move "Meditate," this app keeps your system in a peaceful state of digital awareness.

## ✨ Features

- 🔮 **Mindful Power Management** - Uses Windows API for reliable sleep prevention
- ⌨️ **Gentle Key Meditation** - Sends non-intrusive F15 key presses
- 🖱️ **Cursor Zen Movements** - Subtle mouse movements that don't interfere
- ⚖️ **Balanced Harmony** - Combines multiple techniques for maximum effectiveness
- 🎨 **Beautiful GUI** - Modern, zen-inspired interface
- 📝 **Meditation Journal** - Real-time activity logging
- 🤫 **Silent Mode** - Command-line version for minimal distraction
- 🚀 **Zero Installation** - Pure PowerShell, no external dependencies

## 🚀 Quick Start

### Option 1: Easy Launch (Recommended)
1. Download the latest release
2. Extract the files to any folder
3. Double-click `Launch-Meditate.bat`
4. Choose your meditation method and click "Start Meditation"

### Option 2: GUI Version
```powershell
.\Meditate-GUI.ps1
```

### Option 3: Command Line
```powershell
# Default meditation (60 seconds, Windows API)
.\Meditate-CLI.ps1

# Custom interval and method
.\Meditate-CLI.ps1 -Interval 30 -Method KeyPress

# Silent mode
.\Meditate-CLI.ps1 -Quiet
```

## 🎯 Use Cases

Perfect for:
- **BIM Workflows** - Keep Revit active during large model processing
- **File Downloads** - Prevent interruptions during large transfers
- **Data Processing** - Maintain system activity during long calculations
- **Rendering Tasks** - Keep your workstation awake during overnight renders
- **Remote Sessions** - Prevent disconnections during RDP/VNC sessions

## 🧘 Meditation Methods

### 🔮 Windows API (Recommended)
Uses the Windows `SetThreadExecutionState` API to directly tell the system to stay awake. Most reliable and efficient method.

### ⌨️ Gentle Key Meditation
Sends F15 key presses at regular intervals. F15 is safe because most applications don't use this key, so it won't interfere with your work.

### 🖱️ Cursor Zen Movements
Moves the mouse cursor by 1 pixel and back. Subtle movements that maintain system activity without disrupting your workflow.

### ⚖️ Balanced Harmony
Combines both key presses and mouse movements for maximum compatibility across different system configurations.

## 📋 Requirements

- Windows 10/11 (PowerShell 5.1 or later)
- No additional software installation required
- Administrator rights not needed

## 🛡️ Safety & Privacy

- **No network connections** - Works completely offline
- **No data collection** - Everything runs locally
- **Minimal system impact** - Uses negligible CPU and memory
- **Clean shutdown** - Properly restores system sleep settings when stopped
- **Non-intrusive** - Designed to work alongside your applications without interference

## 📖 Documentation

- [Installation Guide](docs/installation.md)
- [Usage Instructions](docs/usage.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the Pokémon move "Meditate" - *The user quietly focuses its mind and calms its spirit*
- Built for BIM professionals who need reliable system availability
- Created with mindfulness and attention to user experience

---

**🧘‍♂️ Find your digital zen. Keep your system mindfully awake.**
