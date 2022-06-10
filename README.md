# Hammerspoon local configuration

## Dependancies for features

### Zoom

1. Create a focus mode that you will use to prevent notifications in System Preferences -> Notifications & Focus -> Focus. You will want to allow notifications from Hammerspoon. ![Example Focus Mode](/docs/images/focus-mode.png)
2. Using the macOS shortcuts app, create 2 shortcuts for starting and stopping the focus mode. ![Example Shortcut to Start Focus Mode](/docs/images/shortcut.png)
3. Edit config.lua and update `config.zoom.{start|stop}` with the names of the new shortcuts.

### Darkmode

Install OpenInTerminal-Lite.app and OpenInEditor-Lite.app from <https://github.com/Ji4n1ng/OpenInTerminal>

### Location

For each wifi network you want to monitor for managing your muting activity, add the SSID of the network and configure the boolean options for `muteOnPower` and `muteOnBattery`.
