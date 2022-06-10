local config = {}
config.global = {} -- this will be accessible via hsm.config in modules

local ufile = require('utils.file')

-- global paths
config.global.paths = {}

config.global.paths.base  = os.getenv('HOME')
config.global.paths.tmp   = os.getenv('TMPDIR')
config.global.paths.hs    = ufile.toPath(config.global.paths.base, '.hammerspoon')
config.global.paths.icons = ufile.toPath(config.global.paths.hs, 'icons')

-- zoom
config.zoom = {
	shortcut = {
		start = 'Start Video Call Focus', -- shortcut name for starting the video call focus mode
		stop = 'End Video Call Focus' -- shortcut name for stopping the video call focus mode
	}
}

-- darkmode
config.darkmode = {
	toolbar = {
		['Open in Editor'] = { appPath = '/Applications/OpenInEditor-Lite.app', icon = 'vscode' },
		['Open in Terminal'] = { appPath = '/Applications/OpenInTerminal-Lite.app', icon = 'iterm' }
	}
}

-- location
config.location = {
	ssid = {
		['HOME WIFI'] = {},
		['WORK WIFI'] = { muteOnPower = true, muteOnBattery = false }
	}
}

return config
