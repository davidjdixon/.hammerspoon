-- module: location switching features
local m = {}

local uapp = require('utils.app')

-- Wifi-detected location settings

-- Apply location-specific audio behavior based on the current SSID and power
-- source. Unknown networks are intentionally ignored.
local function switchFeatures()
	hsm.log.d('switchFeatures: Wifi="' ..
		(m.currentLocation or 'None') .. '", Power=' .. (m.isPluggedIn and 'true' or 'false'))

	if m.config.ssid[m.currentLocation] == nil then
		return
	end

	if m.isPluggedIn and m.config.ssid[m.currentLocation].muteOnPower == true then
		hsm.log.d('switchFeatures: muted')
		hs.audiodevice.defaultOutputDevice():setMuted(true)
	elseif not m.isPluggedIn and m.config.ssid[m.currentLocation].muteOnBattery == false then
		hsm.log.d('switchFeatures: un-muted')
		hs.audiodevice.defaultOutputDevice():setMuted(false)
	end
end

-- Wi-Fi changes define the current location profile. Enter/leave notifications
-- are informational, while the actual behavior change happens in switchFeatures.
local function wifiChanged()
	local newLocation = (hs.wifi.currentNetwork() or 'N/A')
	local lastLocation = m.currentLocation

	hsm.log.d('Wifi Changed: ' .. newLocation)

	hsm.log.d('newLocation: ' .. newLocation .. ' / lastLocation: ' .. lastLocation)

	if newLocation == lastLocation then
		hsm.log.d('no loc change')
		return
	end

	m.currentLocation = newLocation

	-- perform actions for leaving locations before joining
	if lastLocation ~= 'N/A' then
		uapp.notify('Wifi', 'Left ' .. lastLocation, 2)
	end

	if newLocation ~= 'N/A' then
		uapp.notify('Wifi', 'Joined ' .. newLocation, 2)
	end

	switchFeatures()
end

local function isAC()
	return hs.battery.powerSource() == 'AC Power'
end

-- Power changes are handled separately so the same SSID can behave differently
-- on battery versus mains power.
local function powerChanged()
	m.isPluggedIn = isAC()

	hsm.log.d('Power Changed: ' .. hs.battery.powerSource())

	if m.isPluggedIn == m.wasPluggedIn then
		return
	end

	m.wasPluggedIn = m.isPluggedIn

	switchFeatures()
end

-- This primes location services once on startup so macOS grants the required
-- permissions before the Wi-Fi and power automations run.
local function initLocation()
	if hs.location.servicesEnabled() then
		hs.location.start()

		hs.timer.doAfter(2, function()
			local location = hs.location.get()
			if location then
				print('Current Location:')
				print('Latitude: ' .. (location.latitude or 'N/A'))
				print('Longitude: ' .. (location.longitude or 'N/A'))
				print('Altitude: ' .. (location.altitude or 'N/A'))
				print('Horizontal Accuracy: ' .. (location.horizontalAccuracy or 'N/A'))
				print('Vertical Accuracy: ' .. (location.verticalAccuracy or 'N/A'))
			else
				print('Unable to retrieve location information.')
			end

			hs.location.stop()
		end)
	else
		print('Location services are not enabled.')
	end
end

function m.start()
	-- Seed the current state before starting watchers so the first feature switch
	-- uses the active SSID and power source instead of waiting for a change event.
	initLocation() -- enable location services
	hsm.log.d('wifi ssid: ' .. (hs.wifi.currentNetwork() or 'N/A'))
	m.currentLocation = hs.wifi.currentNetwork()
	m.isPluggedIn = isAC()

	m.wifiWatcher = hs.wifi.watcher.new(wifiChanged)
	m.powerWatcher = hs.battery.watcher.new(powerChanged)

	m.wifiWatcher:start()
	m.powerWatcher:start()
end

function m.stop()
	m.wifiWatcher:stop()
	m.powerWatcher:stop()

	m.wifiWatcher = nil
	m.powerWatcher = nil
end

return m
