--
-- Key binding setup for all modules and misc functionality
--
local bindings = {}

-- define some modifier key combinations
local mod = {
	s   = { 'shift' },
	o   = { 'alt' },
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

local function remapKey(modifiers, key, keyCode)
	hs.hotkey.bind(modifiers, key, keyCode, nil, keyCode)
end

function bindings.bind()
	remapKey({}, '§', keyCode('3', mod.o))
end

return bindings
