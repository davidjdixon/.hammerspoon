-- module: finder darkmode icon replacement
local m = {}

-- Finder toolbar apps do not switch icons automatically, so this helper swaps
-- in the correct `.icns` asset for the current macOS appearance.
local function updateToolbarIcon(appPath, icon, dark)
	local iconsFolder = hsm.config.paths.icons .. '/toolbar'
	local theme = dark and 'dark' or 'light'

	hs.execute('fileicon set "' .. appPath .. '" "' .. iconsFolder .. '/icon_' .. icon .. '_' .. theme .. '.icns"', true)
end

-- Re-apply every configured toolbar icon whenever the system appearance flips
-- between light and dark mode.
local function updateIcons()
	local isDarkMode = (hs.settings.get('AppleInterfaceStyle') == 'Dark')

	for _, setting in pairs(m.config.toolbar) do
		updateToolbarIcon(setting.appPath, setting.icon, isDarkMode)
	end
end

function m.start()
	-- Apply the correct icons immediately, then watch for later appearance
	-- changes so Finder stays in sync without a reload.
	updateIcons()
	hs.settings.watchKey('dark_mode', 'AppleInterfaceStyle', function()
		updateIcons()
	end)
end

function m.stop()
	hs.settings.watchKey('dark_mode', 'AppleInterfaceStyle', nil)
end

return m
