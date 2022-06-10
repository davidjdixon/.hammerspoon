# Hammerspoon local configuration

## Zoom

Preventing notifications from opening when in a zoom call.

### Dependancies

1. Create a focus mode that you will use to prevent notifications in System Preferences -> Notifications & Focus -> Focus. You will want to allow notifications from Hammerspoon. ![Example Focus Mode](/docs/images/focus-mode.png)
2. Using the macOS shortcuts app, create 2 shortcuts for starting and stopping the focus mode. ![Example Shortcut to Start Focus Mode](/docs/images/shortcut.png)
3. Edit config.lua and update `config.zoom.{start|stop}` with the names of the new shortcuts.

## Darkmode

Auto adjust custom toolbar icons to dark mode variations when which to Dark Mode.

### Dependancies

1. Install OpenInTerminal-Lite.app and OpenInEditor-Lite.app from <https://github.com/Ji4n1ng/OpenInTerminal>
2. Add the above apps to the Finder by dragging to the toolbar. ![Apps added to Finder toolbar](/docs/images/dark-mode-finder-apps.png)

## Location

Location based preferences, based on Wifi detection (currently whether to enable sound or not when conected to power/battery).

### Dependancies

For each wifi network you want to monitor for managing your muting activity, add the SSID of the network and configure the boolean options for `muteOnPower` and `muteOnBattery`.
