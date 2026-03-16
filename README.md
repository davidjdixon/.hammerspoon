# Hammerspoon local configuration

## Camera

Toggle the video call focus mode based on whether any camera is currently in use.

### Dependencies

1. Create a focus mode that you will use to prevent notifications in System Preferences -> Notifications & Focus -> Focus. You will want to allow notifications from Hammerspoon. ![Example Focus Mode](/docs/images/focus-mode.png)
2. Using the macOS shortcuts app, create 2 shortcuts for starting and stopping the focus mode. ![Example Shortcut to Start Focus Mode](/docs/images/shortcut.png)
3. Edit config.lua and update `config.camera.shortcut.{start|stop}` with the names of the shortcuts.

### Behavior

When any connected camera reports `isInUse() == true`, the module runs the configured `start` Shortcut. When no cameras are in use, it runs the configured `stop` Shortcut. The module also runs a forced reconciliation every `config.camera.safetyCheckMinutes` minutes, defaulting to 15, so focus state is re-applied even if a watcher event is missed.

## Darkmode

Auto adjust custom toolbar icons to dark mode variations when which to Dark Mode.

### Dependencies

1. Install OpenInTerminal-Lite.app and OpenInEditor-Lite.app from <https://github.com/Ji4n1ng/OpenInTerminal>
2. Add the above apps to the Finder by dragging to the toolbar. ![Apps added to Finder toolbar](/docs/images/dark-mode-finder-apps.png)

### Behavior

The module watches the macOS appearance setting and reapplies the configured Finder toolbar icons using the matching `light` or `dark` `.icns` asset for each toolbar app.

## Location

Location based preferences, based on Wifi detection (currently whether to enable sound or not when conected to power/battery).

### Dependencies

For each wifi network you want to monitor for managing your muting activity, add the SSID of the network and configure the boolean options for `muteOnPower` and `muteOnBattery`.

### Behavior

The module tracks both Wi-Fi SSID and power source. For configured networks, it mutes or unmutes the default output device based on the current `muteOnPower` and `muteOnBattery` flags.

## Audio

Ensure preferred audio input and output devices are selected whenever they are available.

### Dependencies

Set `config.audio.inputDeviceName` to the exact input device name you want to prefer, and `config.audio.outputDeviceName` to the output device you want to keep as default. When either device is connected and available, Hammerspoon will switch the macOS default input or output back to it.

### Behavior

The module listens for system audio-device changes and re-selects the configured default input and output devices whenever those devices are available, including on initial startup.

## Spotify

Bind the hardware media keys to Spotify volume instead of system volume.

### Behavior

`F11` lowers Spotify volume by 5%, `F12` raises it by 5%, and `F10` toggles mute by restoring the last non-zero Spotify volume.
