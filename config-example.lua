local config              = {}
config.global             = {} -- this will be accessible via hsm.config in modules

local ufile               = require('utils.file')

-- global paths
config.global.paths       = {}

config.global.paths.base  = os.getenv('HOME')
config.global.paths.tmp   = os.getenv('TMPDIR')
config.global.paths.hs    = ufile.toPath(config.global.paths.base, '.hammerspoon')
config.global.paths.icons = ufile.toPath(config.global.paths.hs, 'icons')

-- darkmode
config.darkmode           = {
	-- Map Finder toolbar app paths to icon basenames under icons/toolbar.
	toolbar = {
		['Open in Editor'] = { appPath = '/Applications/OpenInEditor-Lite.app', icon = 'vscode' },
		['Open in Terminal'] = { appPath = '/Applications/OpenInTerminal-Lite.app', icon = 'iterm' }
	}
}

-- location
config.location           = {
	-- Per-SSID behavior flags. Networks omitted here are observed but do not
	-- trigger any mute changes.
	ssid = {
		['HOME WIFI'] = {},
		['WORK WIFI'] = { muteOnPower = true, muteOnBattery = false }
	}
}

-- audio
config.audio              = {
	-- Preferred system audio devices. They are only selected when the named
	-- device is currently available.
	inputDeviceName = 'Elgato Wave:3',
	outputDeviceName = 'Creative Pebble Pro'
}

-- camera
config.camera             = {
	-- These Shortcuts are invoked when camera usage changes. "start" should
	-- enable the focus mode and "stop" should disable it.
	shortcut = {
		start = 'Start Video Call Focus', -- shortcut name for starting the video call focus mode
		stop = 'End Video Call Focus' -- shortcut name for stopping the video call focus mode
	},
	-- Safety reconciliation interval in minutes. This re-checks camera usage and
	-- re-applies the correct focus state if a watcher event was missed.
	safetyCheckMinutes = 15
}

return config
