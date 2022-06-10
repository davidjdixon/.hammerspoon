-- module: zoom
--
-- Requires creation of a focus mode in MacOS system preferences
-- and creating shortcuts in Shotcuts app that starts/stops the focus.
--
-- TODO: instead of just turning off focus, look to restore prev focus

local m = {}

local uapp = require('utils.app')
local zoom = hs.loadSpoon('Zoom', false)

local function updateZoomStatus(event)
	if (event == 'from-running-to-meeting') then
		hs.shortcuts.run(m.config.shortcut.start)
		uapp.notify('Video Focus Mode', 'Started', 2)
	elseif (event == 'from-meeting-to-running') then
		hs.shortcuts.run(m.config.shortcut.stop)
		uapp.notify('Video Focus Mode', 'Ended', 2)
	end
end

function m.start()
	zoom:setStatusCallback(updateZoomStatus)
	zoom:start()
end

function m.stop()
	zoom:stop()
end

return m