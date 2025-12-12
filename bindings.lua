--
-- Key binding setup for all modules and misc functionality
--
local bindings = {}

-- Store hotkeys so we can disable them on reload
local active_hotkeys = {}

-- define some modifier key combinations
local mod = {
	s   = { 'shift' },
	o   = { 'alt' },
	c   = { 'cmd' },
	ct  = { 'ctrl' },
	cc  = { 'cmd', 'ctrl' },
	co  = { 'cmd', 'alt' },
	os  = { 'alt', 'shift' },
	cos = { 'cmd', 'alt', 'shift' },
}

local function keyCode(key, modifiers)
	modifiers = modifiers or {}
	return function()
		hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
		hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()
	end
end

local function remapKey(key, modifiers, keyCode)
	return hs.hotkey.new(modifiers, key, keyCode, nil, keyCode)
end

local globalBindings = {
	{ '§', {}, keyCode('3', mod.o) }
}

function bindings.bind()
	-- First, disable any existing hotkeys
	bindings.unbind()

	for _, v in ipairs(globalBindings) do
		local hotkey = remapKey(v[1], v[2], v[3])
		hotkey:enable()
		table.insert(active_hotkeys, hotkey)
	end
end

function bindings.unbind()
	for _, hotkey in ipairs(active_hotkeys) do
		if hotkey then
			hotkey:disable()
			hotkey:delete()
		end
	end
	active_hotkeys = {}
end

return bindings
