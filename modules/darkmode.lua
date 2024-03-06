-- module: finder darkmode icon replacement
local m = {}

local function updateToolbarIcon(appPath, icon, dark)
	local iconsFolder = hsm.config.paths.icons .. "/toolbar"
	local theme = dark and "dark" or "light"

	hs.execute('fileicon set "' .. appPath .. '" "' .. iconsFolder .. '/icon_' .. icon .. '_' .. theme .. '.icns"', true)
end

local function updateIcons()
	local isDarkMode = (hs.settings.get('AppleInterfaceStyle') == 'Dark')

	for _, setting in pairs(m.config.toolbar) do
		updateToolbarIcon(setting.appPath, setting.icon, isDarkMode)
	end
end

function m.start()
	updateIcons()
	hs.settings.watchKey('dark_mode', 'AppleInterfaceStyle', function()
		updateIcons()
	end)
end

function m.stop()
	hs.settings.watchKey('dark_mode', 'AppleInterfaceStyle', nil)
end

return m
