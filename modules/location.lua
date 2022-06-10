-- module: location switching features
local m = {}

local uapp = require('utils.app')

-- Wifi-detected location settings

local function switchFeatures()

	hsm.log.d("switchFeatures: Wifi='" .. (m.currentLocation or "None") .. "', Power=" .. (m.isPluggedIn and "true" or "false"))

	if m.config.ssid[m.currentLocation] == nil then
		return
	end

	if m.isPluggedIn and m.config.ssid[m.currentLocation].muteOnPower == true then
		hsm.log.d("switchFeatures: muted")
		hs.audiodevice.defaultOutputDevice():setMuted(true)
	elseif not m.isPluggedIn and m.config.ssid[m.currentLocation].muteOnBattery == false then
		hsm.log.d("switchFeatures: un-muted")
		hs.audiodevice.defaultOutputDevice():setMuted(false)
	end
end

local function wifiChanged()
	local newLocation = hs.wifi.currentNetwork()
	local lastLocation = m.currentLocation

	hsm.log.d("Wifi Changed: " .. hs.wifi.currentNetwork())

	if newLocation == lastLocation then
		hsm.log.d("no loc change")
		return
	end

	m.currentLocation = newLocation

	-- perform actions for leaving locations before joining
	if lastLocation then
		uapp.notify('Wifi', 'Left ' .. lastLocation, 2)
	end

	if newLocation then
		uapp.notify('Wifi', 'Joined ' .. newLocation, 2)
	end

	switchFeatures()
end

local function isAC()
	return hs.battery.powerSource() == 'AC Power'
end

local function powerChanged()
	m.isPluggedIn = isAC()

	hsm.log.d("Power Changed: " .. hs.battery.powerSource())

	if m.isPluggedIn == m.wasPluggedIn then
		return
	end

	m.wasPluggedIn = m.isPluggedIn

	switchFeatures()
end

function m.start()
	hsm.log.d("wifi ssid: " .. hs.wifi.currentNetwork())
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
