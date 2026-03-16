-- module: Spotify Volume Control
local m = {}

local bindings = {}

-- Round to the nearest step so repeated volume changes stay aligned with the
-- configured 5% increments rather than drifting on Spotify's raw values.
local function round(num, mult)
  return math.floor(num / mult + 0.5) * mult
end

local function bind()
  -- Bind raw media keys directly to Spotify volume instead of the system output
  -- volume so speakers and app volume can be controlled independently.
  -- volume ↓
  bindings.f11 = hs.hotkey.bind('', 'f11', function()
    local targetVol = round(hs.spotify.getVolume(), 5) - 5
    hs.spotify.setVolume(targetVol)
    hs.alert.closeAll(0.0)
    hs.alert.show('Spotify Volume ' .. targetVol .. '%', {})
  end)

  -- volume ↑
  bindings.f12 = hs.hotkey.bind('', 'f12', function()
    local targetVol = round(hs.spotify.getVolume(), 5) + 5
    hs.spotify.setVolume(targetVol)
    hs.alert.closeAll(0.0)
    hs.alert.show('Spotify Volume ' .. targetVol .. '%', {})
  end)

  local lastSpotifyVolume = nil

  -- mute
  bindings.f10 = hs.hotkey.bind('', 'f10', function()
    local curVol = hs.spotify.getVolume()
    local targetVol
    if curVol == 0 then
      targetVol = lastSpotifyVolume
    else
      targetVol = 0
      lastSpotifyVolume = round(curVol, 5)
    end
    hs.spotify.setVolume(targetVol)
    hs.alert.closeAll(0.0)
    hs.alert.show('Spotify Volume ' .. targetVol .. '%', {})
  end)
end

local function unbind()
  -- Hotkeys must be removed on reload or duplicate handlers will accumulate.
  for _, binding in ipairs(bindings) do
    binding.delete()
  end
end


function m.start()
  bind()
end

function m.stop()
  unbind()
end

return m
